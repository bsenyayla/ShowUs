using PagedList;
using SharedCRCMS.Enums;
using SharedCRCMS.Filter;
using SharedCRCMS.Service;
using SharedCRCMS.Service.LogManager;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.EntityModels.MailQueue;
using StandartLibrary.Models.Enums;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.Mvc;

namespace Counter.Controllers
{
    [Authorize]
    [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW)]
    public class PreparingQuotationController : BaseController
    {
        private SharedCRCMS.Models.CRCMSEntities db = new SharedCRCMS.Models.CRCMSEntities();

        // GET: DefectList        
        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW)]
        [UserActivityFilter]
        public ActionResult Index()
        {
            ViewBag.Mode = 3;
            return View("PreparingQuotation");
        }

        /*
        [HttpPost]
        public JsonResult Ajax_ProjectExpensesAdd(int documentId)
        {
            var existItem = db.Counter_List.SingleOrDefault(x => x.DocumentId == documentId);
            if (existItem != null)
            {
                if (existItem.CounterStatusId == (int)CounterStatus.Start)
                {
                    existItem.DocumentId = documentId;
                    existItem.CounterStatusId = (int)CounterStatus.PriceOpening;
                    existItem.LastChangeDate = DateTime.Now;
                    existItem.PreparingQuotation_StateId = 0;
                    existItem.PreparingQuotation_IsCompleted = false;
                    existItem.PreparingQuotation_CompletedDate = null;
                    db.SaveChanges();
                    return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
                }
                else
                    return Json(new { status = "isexists" }, JsonRequestBehavior.AllowGet);
            }

            db.Counter_List.Add(new CounterList()
            {
                DocumentId = documentId,
                CounterStatusId = (int)CounterStatus.PriceOpening,
                LastChangeDate = DateTime.Now,
                PreparingQuotation_StateId = 0
            });
            db.SaveChanges();
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }*/

        [HttpPost]
        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_RW)]
        [UserActivityFilter]
        public JsonResult Ajax_Start(int documentId)
        {
            var item = db.Counter_List.SingleOrDefault(x => x.DocumentId == documentId);
            if (item != null)
            {
                item.CounterStatusId = (int)CounterStatus.PriceOpening;
                item.PreparingQuotation_StartDate = DateTime.Now;
                item.PreparingQuotation_StateId = 1;
                item.LastChangeDate = DateTime.Now;
            }
            else
            {
                var itemSE = db.ServiceEngineer_List.SingleOrDefault(x => x.DocumentId == documentId);

                LogMan.Info("Counter item added to DB in Ajax_Start" + item + (itemSE == null ? null : itemSE));
                db.Counter_List.Add(new CounterList()
                {
                    DocumentId = documentId,
                    CounterStatusId = (int)CounterStatus.PriceOpening,
                    LastChangeDate = DateTime.Now,
                    PreparingQuotation_StartDate = DateTime.Now,
                    PreparingQuotation_StateId = 1,
                    Comment = itemSE == null ? string.Empty : itemSE.Comment
                });
            }
            db.SaveChanges();
            var pauseItem = db.Counter_Pause.SingleOrDefault(x => x.DocumentId == documentId && x.Type == 1 && x.StopDate == null);
            if (pauseItem != null)
            {
                pauseItem.StopDate = DateTime.Now;
            }
            db.SaveChanges();

            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_RW)]
        [UserActivityFilter]
        public JsonResult Ajax_Pause(int documentId, string description)
        {
            var item = db.Counter_List.SingleOrDefault(x => x.DocumentId == documentId);
            if (item != null)
            {
                item.PreparingQuotation_StateId = 2;
                db.SaveChanges();
            }
            var pauseItem = db.Counter_Pause.SingleOrDefault(x => x.DocumentId == documentId && x.Type == 1 && x.StopDate == null);
            if (pauseItem != null)
            {
                pauseItem.StopDate = DateTime.Now;
            }
            db.Counter_Pause.Add(new Counter_Pause() { DocumentId = documentId, Type = 1, StartDate = DateTime.Now, Description = description });
            db.SaveChanges();
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_RW)]
        [UserActivityFilter]
        public JsonResult Ajax_ReturnToUpdate(int documentId, string description)
        {
            var item = db.Counter_List.SingleOrDefault(x => x.DocumentId == documentId);
            if (item != null)
            {
                item.LastChangeDate = DateTime.Now;
                item.PreparingQuotation_StateId = 4;
                db.SaveChanges();
            }
            var pauseItem = db.Counter_ReturnToUpdate.SingleOrDefault(x => x.DocumentId == documentId && x.StopDate == null);
            if (pauseItem != null)
            {
                pauseItem.StopDate = DateTime.Now;
            }
            db.Counter_ReturnToUpdate.Add(new Counter_ReturnToUpdate() { DocumentId = documentId, StartDate = DateTime.Now, Description = description });
            db.SaveChanges();
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost, ValidateInput(false)]
        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_RW)]
        public JsonResult Ajax_Stop(int documentId,
            bool IsNotSpareParts,
            bool IsSparePartsInStock,
            string DeliveryTermsTruckDays,
            string DeliveryTermsAviaDays,
            string CostParts,
            string CostWork,
            string CostRecovery,
            string CostTransportation,
            string CostReman,
            string CostPreQuotation,
            string CostRelativeOfTheNewNode,
            int CurrencyType,
            string Comment,
            string[] Customers,
            string WOpssr,
            string[] Emails,
            bool IsSparePartsInWarehousesRK,
            bool IsSparePartsProvideTheCustomer
        )
        {
            if (Customers != null)
                Customers = Customers.Where(x => x != null && x.Length > 0).Select(x => x.Trim().ToUpper()).Where(x => x.Length > 0).ToArray();
            if (Emails != null)
                Emails = Emails.Where(x => x != null && x.Length > 0).Select(x => x.Trim().ToUpper()).Where(x => x.Length > 0).ToArray();
            CostParts = Regex.Replace(CostParts, "[^0-9\\,\\.]", "").Trim();
            CostWork = Regex.Replace(CostWork, "[^0-9\\,\\.]", "").Trim();
            CostRecovery = Regex.Replace(CostRecovery, "[^0-9\\,\\.]", "").Trim();
            CostTransportation = Regex.Replace(CostTransportation, "[^0-9\\,\\.]", "").Trim();
            CostReman = Regex.Replace(CostReman, "[^0-9\\,\\.]", "").Trim();
            CostPreQuotation = Regex.Replace(CostPreQuotation, "[^0-9\\,\\.]", "").Trim();

            var notApplicableQuotation = db.Uploads.SingleOrDefault(x => x.DocumentId == documentId && x.TypeId == 17 && x.Name == "NotApplicable");
            var item = db.Counter_List.SingleOrDefault(x => x.DocumentId == documentId);
            if (item != null)
            {
                item.LastChangeDate = DateTime.Now;

                item.PreparingQuotation_IsCompleted = true;
                item.PreparingQuotation_CompletedDate = DateTime.Now;
                item.PreparingQuotation_StateId = 3;
                item.PreparingQuotation_IsNotSpareParts = IsNotSpareParts;
                item.PreparingQuotation_IsSparePartsInStock = IsSparePartsInStock;
                //item.PreparingQuotation_DeliveryTermsTruckDays = DeliveryTermsTruckDays;
                //item.PreparingQuotation_DeliveryTermsAviaDays = DeliveryTermsAviaDays;
                item.PreparingQuotation_CostParts = CostParts.Length > 0 ? decimal.Parse(CostParts.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.PreparingQuotation_CostWork = CostWork.Length > 0 ? decimal.Parse(CostWork.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.PreparingQuotation_CostRecovery = CostRecovery.Length > 0 ? decimal.Parse(CostRecovery.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.PreparingQuotation_CostTransportation = CostTransportation.Length > 0 ? decimal.Parse(CostTransportation.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.PreparingQuotation_CostReman = CostReman.Length > 0 ? decimal.Parse(CostReman.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.PreparingQuotation_CostPreQuotation = CostPreQuotation.Length > 0 ? decimal.Parse(CostPreQuotation.Replace(",", "."), NumberStyles.Number) : (decimal?)null;
                item.PreparingQuotation_CostRelativeOfTheNewNode = CostRelativeOfTheNewNode.Length > 0 ? decimal.Parse(CostRelativeOfTheNewNode.Replace(",", "."), NumberStyles.Number) : (decimal?)null;
                item.SparePartsInWarehousesRK = IsSparePartsInWarehousesRK;
                item.CustomerApproval_ExistsSpareParts = IsSparePartsInWarehousesRK;
                item.CustomerApproval_IsSparePartsProvideTheCustomer = IsSparePartsProvideTheCustomer;
                item.PreparingQuotation_CurrencyType = CurrencyType;
                item.Comment = Comment;
                if (notApplicableQuotation == null)
                    item.CounterStatusId = (int)CounterStatus.PreparingQuotation;
                else
                {
                    item.CounterStatusId = (int)CounterStatus.QuotationSent;
                    item.CustomerApproval_IsAnswerReceived = true;
                    item.CustomerApproval_AnswerReceivedDate = DateTime.Now;
                    item.CustomerApproval_IsApproved = true;
                    item.CustomerApproval_ApprovedDate = DateTime.Now;
                    //if ((DeliveryTermsTruckDays != null && DeliveryTermsTruckDays.Length > 0)
                    //    || (DeliveryTermsAviaDays != null && DeliveryTermsAviaDays.Length > 0))
                    //{
                    if (IsSparePartsInWarehousesRK || !IsNotSpareParts)
                    {
                        item.CustomerApproval_ExistsSpareParts = true;
                    }
                    notApplicableQuotation = db.Uploads.SingleOrDefault(x => x.DocumentId == documentId && x.TypeId == 24 && x.Name == "NotApplicable");
                    if (notApplicableQuotation == null)
                    {
                        var upload = new Upload();
                        upload.DocumentId = documentId;
                        upload.TypeId = 24;
                        upload.Extension = "";
                        upload.Name = "NotApplicable";
                        upload.Path = "NotApplicable";
                        upload.SizeKB = 0;
                        upload.DateUpload = DateTime.Now;
                        upload.ZoneId = 0;
                        try
                        {
                            var localUser = LoggedUser;
                            upload.UserId = localUser.SID;
                            upload.UserName = localUser.Name;
                        }
                        catch (Exception)
                        {
                        }
                        db.Uploads.Add(upload);
                        db.SaveChanges();
                    }
                }
                db.SaveChanges();
            }
            var pauseItem = db.ServiceEngineer_Pause.SingleOrDefault(x => x.DocumentId == documentId && x.Type == 1 && x.StopDate == null);
            if (pauseItem != null)
            {
                pauseItem.StopDate = DateTime.Now;
            }
            db.SaveChanges();

            //var userName = "";
            //try
            //{
            //    userName = SharedCRCMS.Service.Helper.GetADUserProfile(User.Identity.Name).UserName;
            //}
            //catch (Exception ex)
            //{
            //    LogMan.Error("Ajax_Stop", ex);
            //}

            try
            {
                //var message = $"{Counter.Lang.Resources.ДобрыйДень}!\n                      "
                // + $"\n{Counter.Lang.Resources.ВоВложенииКотировкиИОтчетПоРемонту}                   "
                // + $"\n{Counter.Lang.Resources.ДоставкаЗапасныхЧастей}:                                  "
                // + $"\n{Counter.Lang.Resources.Авиа} - " + item.PreparingQuotation_DeliveryTermsAviaDays
                // + $"\n{Counter.Lang.Resources.Трак} - " + item.PreparingQuotation_DeliveryTermsTruckDays
                // + $"\n{Counter.Lang.Resources.ПрошуПодписатьКотировку   }                            "
                // + $"\n{Counter.Lang.Resources.Спасибо   }                                              "
                // + $"\n\n\n{Counter.Lang.Resources.СУважением}, " + userName;

                var document = db.Documents.FirstOrDefault(x => x.DocumentId == documentId);

                var toList = new List<string>();
                var ccList = new List<string>();

                if (!string.IsNullOrEmpty(WOpssr))
                {
                    toList.Add(WOpssr);
                }

                if (Emails != null && Emails.Any())
                {
                    toList.AddRange(Emails);
                }

                //if (Customers != null && Customers.Any())
                //{
                //    var customersId = db.Customers.Where(x => Customers.Contains(x.Name.Trim().ToUpper())).Select(x => x.CustomerId).ToArray();

                //    toList.AddRange(db.Counter_PSSR_Email.Where(x => customersId.Contains(x.CustomerId) && x.Type == 1).Select(x => x.Email).ToArray());
                //    ccList.AddRange(db.Counter_PSSR_Email.Where(x => customersId.Contains(x.CustomerId) && x.Type == 2).Select(x => x.Email).ToArray());
                //}

                if (toList.Any() || ccList.Any())
                {
                    var uploadIds = db.Uploads.Where(x => x.DocumentId == documentId && (x.TypeId == 17 || x.TypeId == 2)).Select(s => s.UploadId).ToList();

                    var smcsComponent = db.SMCSComponent.FirstOrDefault(x => x.Code == document.SmcsCode);

                    var group = (from one in db.Documents
                                 join two in db.ReceptionItem on one.DocumentId equals two.DocumentId
                                 join three in db.Group on two.GroupId equals three.GroupId
                                 where (one.DocumentId == documentId)
                                 select three).Distinct().FirstOrDefault();

                    var mailQueueParameter = new MailQueueParameterModel
                    {
                        Subject = "{Quotation_5516}",
                        Title = "{Quotation_Detail}",
                        UploadIds = uploadIds,
                        MailQueueTypeId = (int)MailQueueType.BaseOfQuotation,
                        BaseOfQuotation = new BaseOfQuotationModel
                        {
                            DocumentNumber = long.Parse(document.DocumentNumber).ToString(),
                            CustomerName = document.Customer != null ? document.Customer.Name : "",
                            Division = document.SegmentText,
                            Component = smcsComponent != null ? smcsComponent.GetLocalized(x => x.Description, x => x.SMCSComponentID) : "",
                            ModelName = document.Model != null ? document.Model.Name : "",
                            MachinesSN = document.MachinesSN,
                            IsNotSpareParts = IsNotSpareParts,
                            IsSparePartsInWarehousesRK = IsSparePartsInWarehousesRK,
                            IsSparePartsInStock = IsSparePartsInStock,
                            IsSparePartsProvideTheCustomer = IsSparePartsProvideTheCustomer,
                            GroupName = group != null ? group.Name : "",
                        }
                    };

                    var oldMailQueue = db.MailQueue
                                            .Where(x => x.EmailTypeId == (int)MailQueueType.BaseOfQuotation && x.Parameters.Contains("\"DocumentNumber\":\"" + mailQueueParameter.BaseOfQuotation.DocumentNumber + "\""))
                                            .OrderByDescending(x => x.CreateDate)
                                            .FirstOrDefault();
                    if (oldMailQueue != null)
                    {
                        mailQueueParameter.Title = "{Quotation_Update_6910}";
                        mailQueueParameter.Subject = "{Quotation_Update_6910}";
                    }

                    SharedCRCMS.Service.SmtpService.SendMail(mailQueueParameter, toList, ccList);
                }
            }
            catch (Exception ex)
            {
                LogMan.Error("Ajax_Stop", ex);
            }
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_RW)]
        public JsonResult Ajax_SaveComment(int documentId, string comment)
        {
            var item = db.Counter_List.Single(x => x.DocumentId == documentId);
            item.LastChangeDate = DateTime.Now;
            item.Comment = comment;
            db.SaveChanges();
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [UserActivityFilter]
        public JsonResult Ajax_NotStarted_GetList(int document_id = 0,
                                            int customer_id = 0,
                                            string smcsCode = "",
                                            int model_id = 0,
                                            string ReceiptDate_Begin = "", string ReceiptDate_End = "",
                                            string division = "",
                                               int group_id = 0)

        {
            var pricingDrawingDocumentIds = db.ServiceEngineer_PricingDrawings.Where(k => k.PricingDrawing_Status == (int)PricingDrawingStatus.Approved).Select(k => k.DocumentId).ToList();
            var filterDocIdSECompleted = db.ServiceEngineer_List.Where(x => x.PreparingOfReport_StopDate != null).Select(x => x.DocumentId).ToArray();
            var filterDocIdInCounter = db.Counter_List.Select(x => x.DocumentId).ToArray();
            var filterDocIdInProjectExpenses = db.Counter_List.Where(x => x.CounterStatusId == (int)CounterStatus.PriceOpening && x.PreparingQuotation_StateId == 0).Select(x => x.DocumentId).ToArray();
            var filterDocIdInCounterHZ = db.Counter_List.Where(x => x.CounterStatusId == (int)CounterStatus.Start && x.PreparingQuotation_StateId == 0).Select(x => x.DocumentId).ToArray();
            var userSmcsCode = new Counter.Controllers.AJAXController().GetUserGroupSmscCode(User);
            var documentsQ = (from x in db.Documents
                              join di in db.DispatchItem on x.DocumentId equals di.DocumentId into grpX
                              from grp in grpX.DefaultIfEmpty()
                              join cl in db.Counter_List on x.DocumentId equals cl.DocumentId into clpX
                              from clp in clpX.DefaultIfEmpty()
                              where (
                                           (filterDocIdSECompleted.Contains(x.DocumentId) && !filterDocIdInCounter.Contains(x.DocumentId))
                                           || filterDocIdInProjectExpenses.Contains(x.DocumentId)
                                           || filterDocIdInCounterHZ.Contains(x.DocumentId)
                                           || (pricingDrawingDocumentIds.Contains(x.DocumentId))
                                     )
                                     //&& (userSmcsCode.Contains(x.SmcsCode) || document_id > 0)
                                     && grp == null
                                     && (clp == null || db.Counter_List.Where(k => k.PreparingQuotation_StateId == 0).Select(k => k.DocumentId).Contains(x.DocumentId))
                              //&& db.Counter_List.Where(k => k.PreparingQuotation_StateId == 0).Select(k => k.DocumentId).Contains(x.DocumentId)
                              select x).Distinct();

            #region Filters

            if (document_id != 0)
                documentsQ = documentsQ.Where(w => w.DocumentId == document_id);
            if (customer_id != 0)
                documentsQ = documentsQ.Where(w => w.CustomerId == customer_id);
            if (model_id != 0)
                documentsQ = documentsQ.Where(w => w.ModelId == model_id);
            if (smcsCode != "")
                documentsQ = documentsQ.Where(w => w.SmcsCode == smcsCode);
            if (group_id != 0)
                documentsQ = (from one in documentsQ
                              join two in db.ReceptionItem on one.DocumentId equals two.DocumentId
                             join three in db.Group on two.GroupId equals three.GroupId
                             where (three.GroupId == group_id)
                             select one).Distinct();

            #endregion Filters

            var documents = documentsQ.ToList();
            var docsId = documents.Select(z => z.DocumentId).ToArray();
            var uploads = db.Uploads.Where(x => docsId.Contains(x.DocumentId)).ToArray();
            var smcsComponent = db.SMCSComponent.ToArray();
            var customerPSSR = db.Counter_CustomerPSSR.ToArray();

            var projectsList = (from one in documents
                                join four in db.ReceptionItem on one.DocumentId equals four.DocumentId
                                join ten in db.Reception on four.ReceptionId equals ten.ReceptionId
                                join five in db.Group on four.GroupId equals five.GroupId
                                join ri in db.ReceptionItem on one.DocumentId equals ri.DocumentId into riPx
                                from ri in riPx.DefaultIfEmpty()
                                join two in db.ServiceEngineer_List on one.DocumentId equals two.DocumentId into ps
                                from two in ps.DefaultIfEmpty()
                                join three in db.DocumentType on one.DocumentTypeId equals three.DocumentTypeId into dt
                                from three in dt.DefaultIfEmpty()
                                let sq = (two != null ? db.ServiceEngineer_Quotations.Where(x => x.ServiceEngineer_ListId == two.Id).OrderByDescending(c => c.Quotation_Operation_Date).FirstOrDefault() : null)
                                select (new
                                {
                                    five.GroupId,
                                    GroupName = five.Name != null ? five.Name : "",
                                    one.DocumentCreateDate,
                                    one.DocumentId,
                                    one.DocumentNumber,
                                    CustomerName = one.Customer != null ? one.Customer.Name : "",
                                    one.SmcsCode,
                                    smcsComponentDescription = smcsComponent.Any(x => x.Code == one.SmcsCode) ? smcsComponent.Single(x => x.Code == one.SmcsCode).GetLocalized(x => x.Description, x => x.SMCSComponentID) : "",
                                    ModelName = one.Model != null ? one.Model.Name : "",
                                    Comment = two != null && two.Comment != null ? two.Comment : "",
                                    StatusId = (two != null ? two.StatusId : 0),
                                    UploadPricing = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 99), // todo: get correct type id
                                    UploadDefectList = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 1),
                                    UploadMachineShopForm = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 6),
                                    UploadTechnicalReport = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 2),
                                    UploadPhoto = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 7),
                                    Division = one.SegmentText != null ? one.SegmentText : "",
                                    ReceiptDate = two != null && two.PreparingOfReport_StopDate != null ? two.PreparingOfReport_StopDate.Value : DateTime.Now,
                                    IsProjectExpenses = filterDocIdInProjectExpenses.Contains(one.DocumentId),
                                    IsZsrt = (new string[] { "K1", "RO", "CR" }.Contains(three.Code) && ten.ReceptionDate  > new DateTime(2021, 03, 16)),
                                    Quotation_IsAccepted = two != null ? two.Quotation_IsAccepted : null,
                                    Quotation_Operation_Date = (sq != null && sq.Quotation_Operation_Date.HasValue) ? sq.Quotation_Operation_Date.Value.ToString("dd-MM-yyyy HH:mm") : "",
                                    Quotation_Operation_User = (sq != null && sq.Quotation_Operation_User != null ? (db.LocalUser.FirstOrDefault(x => x.SID == sq.Quotation_Operation_User) != null ? db.LocalUser.FirstOrDefault(x => x.SID == sq.Quotation_Operation_User).Name : sq.Quotation_Operation_User) : ""),
                                    Quotation_Operation_Description = (sq != null && sq.Quotation_Operation_Description != null) ? sq.Quotation_Operation_Description : "",

                                    //Quotation_Accepted_Description = (
                                    //((sq == null || two.Quotation_IsAccepted == null) && (ri != null && ri.GroupId.HasValue && ri.GroupId.Value != 7)) ? StandartLibrary.Lang.Resources.SentforApproval : 
                                    //                    ( (two != null && two.Quotation_IsAccepted.HasValue == false) ? "" : (two.Quotation_IsAccepted == true ? StandartLibrary.Lang.Resources.Approved_5466 : StandartLibrary.Lang.Resources.Rejected_6085)) 

                                    //                    )

                                    Quotation_Accepted_Description = GetQuotation_Accepted_Description(sq, ri, two)



                                })).ToList();

            #region Filters

            if (!string.IsNullOrEmpty(ReceiptDate_Begin))
            {
                var beginDate = DateTime.Parse(ReceiptDate_Begin);
                projectsList = projectsList.Where(w => w.ReceiptDate >= beginDate).ToList();
            }
            if (!string.IsNullOrEmpty(ReceiptDate_End))
            {
                var endDate = DateTime.Parse(ReceiptDate_End);
                projectsList = projectsList.Where(w => w.ReceiptDate <= endDate).ToList();
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
                projectsList = projectsList.Where(x => (((x.DocumentCreateDate != null)) || filterDocIdInProjectExpenses.Contains(x.DocumentId) || document_id > 0)).ToList();
                return Json(new { draw = sEcho, recordsTotal = recordsCount, recordsFiltered = recordsCount, data = projectsList.ToPagedList(pageNumber, pageSize), searchId = searchId }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { draw = 0, recordsTotal = 0, recordsFiltered = 0, data = "" }, JsonRequestBehavior.AllowGet);
            }
        }

        private string GetQuotation_Accepted_Description(ServiceEngineer_Quotations sq, ReceptionItem ri, ServiceEngineer_List two)
        {
            string output = string.Empty;

            //if ((sq == null || two.Quotation_IsAccepted == null)) // && (ri != null && ri.GroupId.HasValue && ri.GroupId.Value != 7)
            //{
            //    output = StandartLibrary.Lang.Resources.SentforApproval;
            //}
            if ((sq == null || (two != null && two.Quotation_IsAccepted.HasValue && two.Quotation_IsAccepted == null)))
            {
                if (ri.GroupId == 7)
                {
                    output = "İşlem Beklenmiyor";
                }
                else
                {
                    output = StandartLibrary.Lang.Resources.SentforApproval;
                }
            }
            else if (two.Quotation_IsAccepted == true)
            {
                output = StandartLibrary.Lang.Resources.Approved_5466;
            }
            else if (two.Quotation_IsAccepted == false)
            {
                output = StandartLibrary.Lang.Resources.Rejected_6085;
            }

            return output;
        }

        [HttpPost]
        [UserActivityFilter]
        public JsonResult Ajax_InProcess_GetList(int document_id = 0,
                                    int customer_id = 0,
                                    string smcsCode = "",
                                    int model_id = 0,
                                    string PreparingQuotation_StartDate_Begin = "", string PreparingQuotation_StartDate_End = "",
                                    string division = "",
                                     int group_id = 0)
        {
            var filterDocId = db.Counter_List.Where(x => (x.CounterStatusId == (int)CounterStatus.Start || x.CounterStatusId == (int)CounterStatus.PriceOpening) && (x.PreparingQuotation_StateId == 1 || x.PreparingQuotation_StateId == 2)).Select(x => x.DocumentId).ToArray();
            var filterDocIdInProjectExpenses = db.Counter_List.Where(x => x.CounterStatusId == (int)CounterStatus.PriceOpening && x.PreparingQuotation_StateId == 1).Select(x => x.DocumentId).ToArray();
            var userSmcsCode = new Counter.Controllers.AJAXController().GetUserGroupSmscCode(User);

            var documents = (from x in db.Documents
                             join di in db.DispatchItem on x.DocumentId equals di.DocumentId into grpx
                             from grp in grpx.DefaultIfEmpty()
                             where grp == null
                             && filterDocId.Contains(x.DocumentId)
                             //&& (userSmcsCode.Contains(x.SmcsCode) || document_id > 0)
                             select x).Distinct().ToList();
            #region Filters

            if (document_id != 0)
                documents = documents.Where(w => w.DocumentId == document_id).ToList();
            if (customer_id != 0)
                documents = documents.Where(w => w.CustomerId == customer_id).ToList();
            if (model_id != 0)
                documents = documents.Where(w => w.ModelId == model_id).ToList();
            if (smcsCode != "")
                documents = documents.Where(w => w.SmcsCode == smcsCode).ToList();
            if (group_id != 0)
                documents = (from one in documents
                             join two in db.ReceptionItem on one.DocumentId equals two.DocumentId
                             join three in db.Group on two.GroupId equals three.GroupId
                             where (three.GroupId == group_id)
                             select one).Distinct().ToList();
            #endregion Filters

            var docsId = documents.Select(z => z.DocumentId).ToArray();
            var uploads = db.Uploads.Where(x => docsId.Contains(x.DocumentId)).ToArray();
            var smcsComponent = db.SMCSComponent.ToArray();
            var customerPSSR = db.Counter_CustomerPSSR.ToArray();
            var docIds = documents.Select(x => x.DocumentId).ToList();
            var ms_inprocess = db.ReceptionItem.Where(x => docIds.Contains(x.DocumentId) && (x.GroupId.HasValue && x.GroupId.Value == (int)Groups.MS)).Select(d => d.DocumentId).ToList();

            var projectsList = (from one in documents
                                join two in db.Counter_List on one.DocumentId equals two.DocumentId into ps
                                from two in ps.DefaultIfEmpty()
                                join three in db.DocumentType on one.DocumentTypeId equals three.DocumentTypeId into dt
                                from three in dt.DefaultIfEmpty()
                                join sl in db.ServiceEngineer_List on one.DocumentId equals sl.DocumentId into sd
                                from sl in sd.DefaultIfEmpty()
                                join five in db.ReceptionItem on one.DocumentId equals five.DocumentId
                                join ten in db.Reception on five.ReceptionId equals ten.ReceptionId
                                join six in db.Group on five.GroupId equals six.GroupId
                                let sq =
                                sl != null
                                ? db.ServiceEngineer_Quotations.Where(x => x.ServiceEngineer_ListId == sl.Id).OrderByDescending(c => c.Quotation_Operation_Date).FirstOrDefault()
                                : null
                                let lu =
                                sq != null
                                ? db.LocalUser.FirstOrDefault(y => y.SID == sq.Quotation_Operation_User).Name
                                : ""
                                select (new
                                {
                                    six.GroupId,
                                    GroupName = six.Name != null ? six.Name : "",
                                    one.DocumentCreateDate,
                                    one.DocumentId,
                                    one.DocumentNumber,
                                    CustomerName = one.Customer != null ? one.Customer.Name : "",
                                    one.SmcsCode,
                                    smcsComponentDescription = smcsComponent.Any(x => x.Code == one.SmcsCode) ? smcsComponent.Single(x => x.Code == one.SmcsCode).GetLocalized(x => x.Description, x => x.SMCSComponentID) : "",
                                    ModelName = one.Model != null ? one.Model.Name : "",
                                    Comment = two != null && two.Comment != null ? two.Comment : "",
                                    StateId = (two != null ? two.PreparingQuotation_StateId : 0),
                                    PauseDescription = two != null && two.PreparingQuotation_StateId == 2 ? db.Counter_Pause.First(x => x.DocumentId == two.DocumentId && x.Type == 1 && x.StopDate == null).Description : "",
                                    UploadPricing = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 99),
                                    UploadDefectList = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 1),
                                    UploadMachineShopForm = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 6),
                                    UploadTechnicalReport = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 2),
                                    UploadPhoto = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 7),
                                    Division = one.SegmentText != null ? one.SegmentText : "",
                                    PreparingQuotation_StartDate = two != null && two.PreparingQuotation_StartDate.HasValue ? two.PreparingQuotation_StartDate.Value : default,
                                    IsZsrt = (new string[] { "K1", "RO", "CR" }.Contains(three.Code) && ten.ReceptionDate  > new DateTime(2021, 03, 16)),

                                    Quotation_IsAccepted = sl != null ? sl.Quotation_IsAccepted : null,

                                    Quotation_Operation_Date = (sq != null && sq.Quotation_Operation_Date.HasValue) ? sq.Quotation_Operation_Date.Value.ToString("dd-MM-yyyy HH:mm") : "",
                                    Quotation_Operation_User = lu,
                                    Quotation_Operation_Description = (sq != null && sq.Quotation_Operation_Description != null) ? sq.Quotation_Operation_Description : "",
                                    Quotation_Accepted_Description = (ms_inprocess != null && ms_inprocess.Contains(one.DocumentId)) ? "" : ((sq == null || sl.Quotation_IsAccepted == null) ? StandartLibrary.Lang.Resources.SentforApproval : (sl.Quotation_IsAccepted == true ? StandartLibrary.Lang.Resources.Approved_5466 : StandartLibrary.Lang.Resources.Rejected_6085))

                                })).ToList();

            #region Filters

            if (!string.IsNullOrEmpty(PreparingQuotation_StartDate_Begin))
            {
                var beginDate = DateTime.Parse(PreparingQuotation_StartDate_Begin);
                projectsList = projectsList.Where(w => w.PreparingQuotation_StartDate >= beginDate).ToList();
            }
            if (!string.IsNullOrEmpty(PreparingQuotation_StartDate_End))
            {
                var endDate = DateTime.Parse(PreparingQuotation_StartDate_End);
                projectsList = projectsList.Where(w => w.PreparingQuotation_StartDate <= endDate).ToList();
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
                projectsList = projectsList.Where(x => ((x.DocumentCreateDate != null && x.DocumentCreateDate >= new DateTime(2019, 2, 1)) || filterDocIdInProjectExpenses.Contains(x.DocumentId) || document_id > 0)).ToList();

                return Json(new { draw = sEcho, recordsTotal = recordsCount, recordsFiltered = recordsCount, data = projectsList.ToPagedList(pageNumber, pageSize), searchId = searchId }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { draw = 0, recordsTotal = 0, recordsFiltered = 0, data = "" }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        [UserActivityFilter]
        public JsonResult Ajax_Wait_GetList(int document_id = 0,
                                    int customer_id = 0,
                                    string smcsCode = "",
                                    int model_id = 0,
                                    string PreparingQuotation_StartDate_Begin = "", string PreparingQuotation_StartDate_End = "",
                                    string division = "",
                                       int group_id = 0)
        {
            var filterDocId = db.Counter_List.Where(x => x.CounterStatusId == (int)CounterStatus.PriceOpening && (x.PreparingQuotation_StateId == 4 || x.PreparingQuotation_StateId == 5)).Select(x => x.DocumentId).ToArray();
            var userSmcsCode = new Counter.Controllers.AJAXController().GetUserGroupSmscCode(User);

            var documents = (from d in db.Documents
                             join di in db.DispatchItem on d.DocumentId equals di.DocumentId into grpx
                             from grp in grpx.DefaultIfEmpty()
                             where filterDocId.Contains(d.DocumentId) && (userSmcsCode.Contains(d.SmcsCode))
                             && grp == null
                             select d).Distinct().ToList();

            #region Filters

            if (document_id != 0)
                documents = documents.Where(w => w.DocumentId == document_id).ToList();
            if (customer_id != 0)
                documents = documents.Where(w => w.CustomerId == customer_id).ToList();
            if (model_id != 0)
                documents = documents.Where(w => w.ModelId == model_id).ToList();
            if (smcsCode != "")
                documents = documents.Where(w => w.SmcsCode == smcsCode).ToList();
            if (group_id != 0)
                documents = (from one in documents
                             join two in db.ReceptionItem on one.DocumentId equals two.DocumentId
                             join three in db.Group on two.GroupId equals three.GroupId
                             where (three.GroupId == group_id)
                             select one).Distinct().ToList();
            #endregion Filters

            var docsId = documents.Select(z => z.DocumentId).ToArray();
            var uploads = db.Uploads.Where(x => docsId.Contains(x.DocumentId)).ToArray();
            var smcsComponent = db.SMCSComponent.ToArray();
            var customerPSSR = db.Counter_CustomerPSSR.ToArray();

            var projectsList = (from one in documents
                                join two in db.Counter_List on one.DocumentId equals two.DocumentId into ps
                                from two in ps.DefaultIfEmpty()
                                join three in db.DocumentType on one.DocumentTypeId equals three.DocumentTypeId into dt
                                from three in dt.DefaultIfEmpty()
                                where dt.Count() > 0
                                join five in db.ReceptionItem on one.DocumentId equals five.DocumentId
                                join ten in db.Reception on five.ReceptionId equals ten.ReceptionId
                                join six in db.Group on five.GroupId equals six.GroupId
                                select (new
                                {
                                    six.GroupId,
                                    GroupName = six.Name != null ? six.Name : "",
                                    one.DocumentId,
                                    one.DocumentNumber,
                                    CustomerName = one.Customer != null ? one.Customer.Name : "",
                                    one.SmcsCode,
                                    smcsComponentDescription = smcsComponent.Any(x => x.Code == one.SmcsCode) ? smcsComponent.Single(x => x.Code == one.SmcsCode).GetLocalized(x => x.Description, x => x.SMCSComponentID) : "",
                                    ModelName = one.Model != null ? one.Model.Name : "",
                                    Comment = two != null && two.Comment != null ? two.Comment : "",
                                    StateId = (two != null ? two.PreparingQuotation_StateId : 0),
                                    UploadPricing = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 99),
                                    UploadDefectList = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 1),
                                    UploadMachineShopForm = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 6),
                                    UploadTechnicalReport = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 2),
                                    UploadPhoto = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 7),
                                    Division = one.SegmentText != null ? one.SegmentText : "",
                                    PreparingQuotation_StartDate = two.PreparingQuotation_StartDate.Value,
                                    IsZsrt = (new string[] { "K1", "RO", "CR" }.Contains(three.Code) && ten.ReceptionDate  > new DateTime(2021, 03, 16)),

                                })).ToList();

            #region Filters

            if (!string.IsNullOrEmpty(PreparingQuotation_StartDate_Begin))
            {
                var beginDate = DateTime.Parse(PreparingQuotation_StartDate_Begin);
                projectsList = projectsList.Where(w => w.PreparingQuotation_StartDate >= beginDate).ToList();
            }
            if (!string.IsNullOrEmpty(PreparingQuotation_StartDate_End))
            {
                var endDate = DateTime.Parse(PreparingQuotation_StartDate_End);
                projectsList = projectsList.Where(w => w.PreparingQuotation_StartDate <= endDate).ToList();
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
        [ProvisionAccessAttribute(PermissionEnum.SERVICE_ENGINEER_RW)]
        [UserActivityFilter]
        public JsonResult QuotationControl_Approval(int documentId, string comment)
        {
            var item = db.ServiceEngineer_List.Single(x => x.DocumentId == documentId);
            item.Quotation_IsAccepted = null;

            var seq = new ServiceEngineer_Quotations
            {
                ServiceEngineer_ListId = item.Id,
                DocumentId = documentId,
                Quotation_Operation_Date = DateTime.Now,
                Quotation_Operation_User = User.Identity.Name,
                Quotation_Operation_Description = comment,
            };

            db.ServiceEngineer_Quotations.Add(seq);

            db.SaveChanges();

            var user = db.LocalUser.FirstOrDefault(x => x.SID == seq.Quotation_Operation_User);

            var document = db.Documents.FirstOrDefault(x => x.DocumentId == documentId);

            return Json(new
            {
                status = "ok",
                operationDate = seq.Quotation_Operation_Date.Value.ToString("dd-MM-yyyy HH:mm"),
                operationUser = user != null ? user.Name : seq.Quotation_Operation_User,
                operationStatus = StandartLibrary.Lang.Resources.SentforApproval,
                documentNumber = document != null ? document.DocumentNumber : documentId.ToString()
            }, JsonRequestBehavior.AllowGet);
        }
    }
}