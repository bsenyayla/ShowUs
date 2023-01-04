using OfficeOpenXml;
using PagedList;
using SharedCRCMS.Filter;
using SharedCRCMS.Service;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Counter.Controllers
{
    [Authorize]
    [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW)]
    public class InPartsOrderingController : BaseController
    {
        private SharedCRCMS.Models.CRCMSEntities db = new SharedCRCMS.Models.CRCMSEntities();

        private struct OrderedPartItem
        {
            public int DocumentId;
            public string DocumentNumber;
            public DateTime? DateStock;
            public string DateStockStr;
            public string Number;
            public string Description;
            public string Segment;
            public decimal Count;
        }

        public ActionResult UploadPlanDeliveredPartsDate(int type = 1)
        {
            var isSavedSuccessfully = true;
            var lstBuff = new List<OrderedPartItem>();

            var fileName = Request.Files[0].FileName;
            HttpPostedFileBase file = Request.Files[0];
            //Save file content goes here

            if (file != null && file.ContentLength > 0)
            {
                using (var package = new ExcelPackage(file.InputStream))
                {
                    var workbook = package.Workbook;
                    var worksheet = workbook.Worksheets.First();
                    var fileType = (worksheet.Cells["D1".ToString()].Value.ToString().IndexOf("Сегмент", StringComparison.OrdinalIgnoreCase) > -1 || worksheet.Cells["D1".ToString()].Value.ToString().IndexOf(Counter.Lang.Resources.Сегмент, StringComparison.OrdinalIgnoreCase) > -1) ? 2 : 1;

                    db.Configuration.AutoDetectChangesEnabled = false;
                    db.Configuration.ValidateOnSaveEnabled = false;
                    var lstInsert = new List<StockTransferPartsListItem>();
                    int lastRow = worksheet.Dimension.End.Row;
                    var rowNumber = 1;

                    while (true)
                    {
                        rowNumber++;
                        if (rowNumber > lastRow)
                            break;
                        try
                        {
                            var DocNumber = "";
                            if (worksheet.Cells["A" + rowNumber.ToString()].Value != null)
                            {
                                DocNumber = worksheet.Cells["A" + rowNumber.ToString()].Value.ToString().Trim();
                            }

                            if (DocNumber.Length > 0)
                            {
                                var sSegment = "";
                                if (worksheet.Cells["D" + rowNumber.ToString()].Value != null)
                                {
                                    sSegment = worksheet.Cells["D" + rowNumber.ToString()].Value.ToString().Trim();
                                }

                                DateTime? dDate = null;
                                try
                                {
                                    if (worksheet.Cells["L" + rowNumber.ToString()].Value != null)
                                    {
                                        if (worksheet.Cells["L" + rowNumber.ToString()].Value.ToString().Length < 10)
                                            continue;
                                        if (worksheet.Cells["L" + rowNumber.ToString()].Value.GetType() == typeof(DateTime))
                                        {
                                            dDate = (DateTime)worksheet.Cells["L" + rowNumber.ToString()].Value;
                                        }
                                        else
                                        {
                                            var sDate = worksheet.Cells["L" + rowNumber.ToString()].Value.ToString().Trim().Replace("\\", ".").Replace("//", ".");
                                            if (sDate.Length > 10)
                                                sDate = sDate.Substring(0, 10);
                                            var aDate = sDate.Split(new string[] { "." }, StringSplitOptions.None);
                                            dDate = new DateTime(int.Parse(aDate[2].Trim()), int.Parse(aDate[1].Trim()), int.Parse(aDate[0].Trim()));
                                        }
                                    }
                                }
                                catch (Exception ex)
                                {
                                    return Json(new { Status = -5, Description = "Ошибка в строке №" + rowNumber.ToString() + ". Неверный формат даты в столбце L." });
                                }
                                var sNumber = "";
                                if (worksheet.Cells[(fileType == 1 ? "F" : "E") + rowNumber.ToString()].Value != null)
                                {
                                    sNumber = worksheet.Cells[(fileType == 1 ? "F" : "E") + rowNumber.ToString()].Value.ToString().Trim();
                                }

                                var sDescription = "";
                                if (worksheet.Cells[(fileType == 1 ? "G" : "F") + rowNumber.ToString()].Value != null)
                                {
                                    sDescription = worksheet.Cells[(fileType == 1 ? "G" : "F") + rowNumber.ToString()].Value.ToString().Trim();
                                }

                                decimal Count = 0;
                                if (worksheet.Cells[(fileType == 1 ? "E" : "G") + rowNumber.ToString()].Value != null)
                                {
                                    Count = decimal.Parse(worksheet.Cells[(fileType == 1 ? "E" : "G") + rowNumber.ToString()].Value.ToString().Trim().Replace(".", ","));
                                }
                                var doc = db.Documents.SingleOrDefault(x => x.DocumentNumber.IndexOf(DocNumber) > -1);
                                if (doc != null)
                                {
                                    lstBuff.Add(new OrderedPartItem()
                                    {
                                        DocumentId = doc.DocumentId,
                                        DocumentNumber = doc.DocumentNumber,
                                        DateStock = dDate,
                                        Number = sNumber,
                                        Description = sDescription,
                                        Segment = sSegment,
                                        Count = Count
                                    });
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            return Json(new { Status = -5, Description = "Ошибка в строке №" + rowNumber.ToString() });
                        }
                    }
                    int b = 0;
                    b++;
                    ////////////////////////////////////////
                    lstBuff = lstBuff.GroupBy(x => new
                    {
                        DocumentId = x.DocumentId,
                        DocumentNumber = x.DocumentNumber,
                        Number = x.Number,
                        Description = x.Description,
                        Segment = x.Segment
                    }).Select(z => new OrderedPartItem
                    {
                        DocumentId = z.Key.DocumentId,
                        DocumentNumber = z.Key.DocumentNumber,
                        Number = z.Key.Number,
                        Description = z.Key.Description,
                        Segment = z.Key.Segment,
                        DateStock = z.Max(z1 => z1.DateStock),
                        Count = z.Sum(z1 => z1.Count)
                    }).ToList();

                    var ddd = lstBuff.Select(x => x.DocumentId).ToArray();
                    var del = db.CounterOrderedParts.Where(x => ddd.Contains(x.DocumentId));
                    if (del.Count() > 0)
                        db.CounterOrderedParts.RemoveRange(del);
                    db.SaveChanges();
                    /////////////////////////

                    db.CounterOrderedParts.AddRange(lstBuff.Select(x => new StandartLibrary.Models.DataModels.CounterOrderedParts()
                    {
                        CreateDate = DateTime.Now,
                        DocumentId = x.DocumentId,
                        DocumentNumber = x.DocumentNumber,
                        DateStock = x.DateStock,
                        DateStockStr = x.DateStock.ToString(),
                        Number = x.Number,
                        Description = x.Description,
                        Segment = x.Segment,
                        Count = x.Count
                    }).ToArray());
                    db.SaveChanges();
                }
            }

            if (isSavedSuccessfully)
            {
                return Json(new { Status = 0, Description = "OK" });
            }
            else
            {
                return Json(new { Status = -4, Description = StandartLibrary.Lang.Resources.StockSaveFileError });
            }
        }

        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW)]
        public ActionResult Index()
        {
            return View("InPartsOrdering");
        }

        [HttpPost]
        [UserActivityFilter]
        public JsonResult Ajax_AwatingOrder_GetList(
                                 int document_id = 0,
                                 int customer_id = 0,
                                 string smcsCode = "",
                                 int model_id = 0,
                                 int CounterDeliveryMethodId = 0,
                                 string CustomerApproval_ApprovedDate_Begin = "", string CustomerApproval_ApprovedDate_End = "",
                                 string division = "")
        {
            var counter = db.Counter_List.ToList();
            var filterDocId = counter.Where(x => x.CounterStatusId == (int)CounterStatus.QuotationSent && x.CustomerApproval_IsApproved != null && x.CustomerApproval_IsApproved == true
                    ).Select(x => x.DocumentId).ToArray();

            var userSmcsCode = new Counter.Controllers.AJAXController().GetUserGroupSmscCode(User);
            var documents = db.Documents.Where(x => filterDocId.Contains(x.DocumentId)
                                                && (userSmcsCode.Contains(x.SmcsCode))).ToList();

            #region Filters

            if (document_id != 0)
                documents = documents.Where(w => w.DocumentId == document_id).ToList();
            if (customer_id != 0)
                documents = documents.Where(w => w.CustomerId == customer_id).ToList();
            if (model_id != 0)
                documents = documents.Where(w => w.ModelId == model_id).ToList();
            if (smcsCode != "")
                documents = documents.Where(w => w.SmcsCode == smcsCode).ToList();

            #endregion Filters

            var docsId = documents.Select(z => z.DocumentId).ToArray();
            var uploads = db.Uploads.Where(x => docsId.Contains(x.DocumentId)).ToArray();
            var smcsComponent = db.SMCSComponent.ToArray();
            var customerPSSR = db.Counter_CustomerPSSR.ToArray();
            var deliveryMethod = db.CounerCabinetDeliveryMethod.ToArray();

            var projectsList = (from one in documents
                                join two in db.Counter_List on one.DocumentId equals two.DocumentId into ps
                                from two in ps.DefaultIfEmpty()
                                select (new
                                {
                                    one.DocumentId,
                                    one.DocumentNumber,
                                    CustomerName = one.Customer != null ? one.Customer.Name : "",
                                    one.SmcsCode,
                                    smcsComponentDescription = smcsComponent.Count(x => x.Code == one.SmcsCode) > 0 ? smcsComponent.Single(x => x.Code == one.SmcsCode).GetLocalized(x => x.Description, x => x.SMCSComponentID) : "",
                                    ModelName = one.Model != null ? one.Model.Name : "",
                                    Division = one.SegmentText != null ? one.SegmentText : "",
                                    CustomerApproval_ApprovedDate = two.PreparingQuotation_StartDate.Value,
                                    DeliveryMethodName = two.CustomerApproval_DeliveryMethodId != null ? deliveryMethod.Single(x => x.DeliveryMethodId == two.CustomerApproval_DeliveryMethodId).Name : "",
                                    DeliveryMethodId = two.CustomerApproval_DeliveryMethodId
                                })).ToList();

            #region Filters

            /*if (CounterDeliveryMethodId != 0)
            {
                projectsList = projectsList.Where(w => w.DeliveryMethodId != null && w.DeliveryMethodId == CounterDeliveryMethodId).ToList();
            }*/
            if (!string.IsNullOrEmpty(CustomerApproval_ApprovedDate_Begin))
            {
                var beginDate = DateTime.Parse(CustomerApproval_ApprovedDate_Begin);
                projectsList = projectsList.Where(w => w.CustomerApproval_ApprovedDate >= beginDate).ToList();
            }
            if (!string.IsNullOrEmpty(CustomerApproval_ApprovedDate_End))
            {
                var endDate = DateTime.Parse(CustomerApproval_ApprovedDate_End);
                projectsList = projectsList.Where(w => w.CustomerApproval_ApprovedDate <= endDate).ToList();
            }
            if (!string.IsNullOrEmpty(division))
            {
                projectsList = projectsList.Where(w => w.Division != null && w.Division.ToUpper() == division.ToUpper()).ToList();
            }

            #endregion Filters

            try
            {
                int recordsCount = projectsList.Count();
                int pageSize = int.Parse(Request["length"]);
                pageSize = pageSize < 0 ? recordsCount : pageSize;
                int fromRow = int.Parse(Request["start"]);
                int sEcho = int.Parse(Request["draw"]);
                int pageNumber = (fromRow + pageSize) / pageSize;
                if (pageNumber == 0) pageNumber = 1;
                var searchId = Guid.NewGuid().ToString();
                Session.Add("search_result_" + searchId, projectsList.Select(x => x.DocumentId).Distinct().ToArray());
                return Json(new { draw = sEcho, recordsTotal = recordsCount, recordsFiltered = recordsCount, data = projectsList.ToPagedList(pageNumber, pageSize), searchId = searchId }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { draw = 0, recordsTotal = 0, recordsFiltered = 0, data = "" }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        [UserActivityFilter]
        public JsonResult Ajax_AwaitingParts_GetList(
                                 int document_id = 0,
                                 int customer_id = 0,
                                 string smcsCode = "",
                                 int model_id = 0,
                                 int CounterDeliveryMethodId = 0,
                                 string CustomerApproval_ApprovedDate_Begin = "", string CustomerApproval_ApprovedDate_End = "",
                                 string InPartsOrdering_OrderedDate_Begin = "", string InPartsOrdering_OrderedDate_End = "",
                                 string division = "")
        {
            var counter = db.Counter_List.ToList();
            var filterDocId = counter.Where(x => x.CounterStatusId == (int)CounterStatus.AnswerReceived && x.InPartsOrdering_IsAllPartsInAvalible != true
                    ).Select(x => x.DocumentId).ToArray();

            var userSmcsCode = new Counter.Controllers.AJAXController().GetUserGroupSmscCode(User);
            var documents = db.Documents.Where(x => filterDocId.Contains(x.DocumentId)
                                && (userSmcsCode.Contains(x.SmcsCode))).ToList();

            #region Filters

            if (document_id != 0)
                documents = documents.Where(w => w.DocumentId == document_id).ToList();
            if (customer_id != 0)
                documents = documents.Where(w => w.CustomerId == customer_id).ToList();
            if (model_id != 0)
                documents = documents.Where(w => w.ModelId == model_id).ToList();
            if (smcsCode != "")
                documents = documents.Where(w => w.SmcsCode == smcsCode).ToList();

            #endregion Filters

            var docsId = documents.Select(z => z.DocumentId).ToArray();
            var uploads = db.Uploads.Where(x => docsId.Contains(x.DocumentId)).ToArray();
            var smcsComponent = db.SMCSComponent.ToArray();
            var customerPSSR = db.Counter_CustomerPSSR.ToArray();
            var deliveryMethod = db.CounerCabinetDeliveryMethod.ToArray();

            var projectsList = (from one in documents
                                join two in db.Counter_List on one.DocumentId equals two.DocumentId into ps
                                from two in ps.DefaultIfEmpty()
                                select (new
                                {
                                    one.DocumentId,
                                    one.DocumentNumber,
                                    CustomerName = one.Customer != null ? one.Customer.Name : "",
                                    one.SmcsCode,
                                    smcsComponentDescription = smcsComponent.Count(x => x.Code == one.SmcsCode) > 0 ? smcsComponent.Single(x => x.Code == one.SmcsCode).GetLocalized(x => x.Description, x => x.SMCSComponentID) : "",
                                    ModelName = one.Model != null ? one.Model.Name : "",
                                    Division = one.SegmentText != null ? one.SegmentText : "",
                                    CustomerApproval_ApprovedDate = two.PreparingQuotation_StartDate != null ? two.PreparingQuotation_StartDate.Value : new DateTime(1900, 1, 1),
                                    InPartsOrdering_OrderedDate = two.InPartsOrdering_OrderedDate != null ? two.InPartsOrdering_OrderedDate.Value : new DateTime(1900, 1, 1),
                                    DeliveryMethodName = two.CustomerApproval_DeliveryMethodId != null ? deliveryMethod.Single(x => x.DeliveryMethodId == two.CustomerApproval_DeliveryMethodId).Name : "",
                                    DeliveryMethodId = two.CustomerApproval_DeliveryMethodId
                                })).ToList();

            #region Filters

            /*if (CounterDeliveryMethodId != 0)
            {
                projectsList = projectsList.Where(w => w.DeliveryMethodId != null && w.DeliveryMethodId == CounterDeliveryMethodId).ToList();
            }*/
            if (!string.IsNullOrEmpty(CustomerApproval_ApprovedDate_Begin))
            {
                var beginDate = DateTime.Parse(CustomerApproval_ApprovedDate_Begin);
                projectsList = projectsList.Where(w => w.CustomerApproval_ApprovedDate >= beginDate).ToList();
            }
            if (!string.IsNullOrEmpty(CustomerApproval_ApprovedDate_End))
            {
                var endDate = DateTime.Parse(CustomerApproval_ApprovedDate_End);
                projectsList = projectsList.Where(w => w.CustomerApproval_ApprovedDate <= endDate).ToList();
            }
            if (!string.IsNullOrEmpty(InPartsOrdering_OrderedDate_Begin))
            {
                var beginDate = DateTime.Parse(InPartsOrdering_OrderedDate_Begin);
                projectsList = projectsList.Where(w => w.InPartsOrdering_OrderedDate >= beginDate).ToList();
            }
            if (!string.IsNullOrEmpty(InPartsOrdering_OrderedDate_End))
            {
                var endDate = DateTime.Parse(InPartsOrdering_OrderedDate_End);
                projectsList = projectsList.Where(w => w.InPartsOrdering_OrderedDate <= endDate).ToList();
            }
            if (!string.IsNullOrEmpty(division))
            {
                projectsList = projectsList.Where(w => w.Division != null && w.Division.ToUpper() == division.ToUpper()).ToList();
            }

            #endregion Filters

            try
            {
                int recordsCount = projectsList.Count();
                int pageSize = int.Parse(Request["length"]);
                pageSize = pageSize < 0 ? recordsCount : pageSize;
                int fromRow = int.Parse(Request["start"]);
                int sEcho = int.Parse(Request["draw"]);
                int pageNumber = (fromRow + pageSize) / pageSize;
                if (pageNumber == 0) pageNumber = 1;
                var searchId = Guid.NewGuid().ToString();
                Session.Add("search_result_" + searchId, projectsList.Select(x => x.DocumentId).Distinct().ToArray());
                return Json(new { draw = sEcho, recordsTotal = recordsCount, recordsFiltered = recordsCount, data = projectsList.ToPagedList(pageNumber, pageSize), searchId = searchId }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { draw = 0, recordsTotal = 0, recordsFiltered = 0, data = "" }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult Ajax_Ordered_AllPartsInAvalible(int documentId)
        {
            var item = db.Counter_List.Single(x => x.DocumentId == documentId);
            item.LastChangeDate = DateTime.Now;
            item.InPartsOrdering_IsOrdered = true;
            item.InPartsOrdering_OrderedDate = DateTime.Now;
            item.InPartsOrdering_IsAllPartsInAvalible = true;
            item.CounterStatusId = (int)CounterStatus.Approved; //При выборе все ЗЧ в наличии наряд переходит в кабинет планировщика по текущему принципу,   а также в базу котировок
            var counterOrdered = db.CounterOrderedParts.FirstOrDefault(x => x.DocumentId == documentId);
            if (counterOrdered != null)
            {
                counterOrdered.DateStock = DateTime.Now;
            }
            else
            {
                var doc = db.Documents.Single(x => x.DocumentId == documentId);
                db.CounterOrderedParts.Add(new StandartLibrary.Models.DataModels.CounterOrderedParts()
                {
                    DocumentId = documentId,
                    DocumentNumber = doc.DocumentNumber,
                    DateStockStr = "",
                    DateStock = DateTime.Now,
                    CreateDate = DateTime.Now,
                    Number = "",
                    Description = "",
                    Segment = ""
                });
            }
            db.SaveChanges();
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult Ajax_Ordered_WaitSpareParts(int documentId)
        {
            var item = db.Counter_List.Single(x => x.DocumentId == documentId);
            item.LastChangeDate = DateTime.Now;
            item.InPartsOrdering_IsOrdered = true;
            item.InPartsOrdering_OrderedDate = DateTime.Now;
            item.CounterStatusId = (int)CounterStatus.AnswerReceived;//При выборе ожидаем ЗЧ переходит в раздел Ожидающие запчастей
            db.SaveChanges();
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult Ajax_AwaitingParts_AllPartsInAvalible(int documentId)
        {
            var item = db.Counter_List.Single(x => x.DocumentId == documentId);
            item.LastChangeDate = DateTime.Now;
            item.InPartsOrdering_AllPartsInAvalibleDate = DateTime.Now;
            item.InPartsOrdering_IsAllPartsInAvalible = true;
            item.CounterStatusId = (int)CounterStatus.Approved; //При выборе все ЗЧ в наличии наряд переходит в кабинет планировщика по текущему принципу,   а также в базу котировок
            db.SaveChanges();
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }
    }
}