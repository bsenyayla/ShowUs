using PagedList;
using SharedCRCMS.Filter;
using SharedCRCMS.Models;
using SharedCRCMS.Service;
using SharedCRCMS.Service.LogManager;
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
    public class BaseOfQuotationsController : BaseController
    {
        private CRCMSEntities db = new CRCMSEntities();

        // GET: BaseOfQuotations
        [UserActivityFilter]
        public ActionResult Index()
        {
            return View("BaseOfQuotations");
        }

        [HttpPost]
        [UserActivityFilter]
        public JsonResult Ajax_GetList(
                         int document_id = 0,
                         int customer_id = 0,
                         string smcsCode = "",
                         int model_id = 0,
                         int CounterDeliveryMethodId = 0,
                         string CustomerApproval_ApprovedDate_Begin = "",
                         string CustomerApproval_ApprovedDate_End = "",
                         string division = "",
                         string QuatationDateOfEntry_Begin = "",
                         string QuatationDateOfEntry_End = "",
                         int group_id = 0)
        {
            var counter = db.Counter_List.ToList();
            var filterDocId = counter.Where(x => x.CounterStatusId == (int)StandartLibrary.Models.Enums.CounterStatus.Approved || x.CounterStatusId == (int)StandartLibrary.Models.Enums.CounterStatus.QuotationRejected
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
            if (division != "")
                documents = documents.Where(w => w.SegmentText == division).ToList();
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
            var deliveryMethod = db.CounerCabinetDeliveryMethod.ToArray();
            var pauseList = db.Counter_Pause.ToArray();
            var counterOrderedParts = db.CounterOrderedParts.ToArray();
            var projectsList = (from one in documents
                                join two in db.Counter_List on one.DocumentId equals two.DocumentId into ps
                                from two in ps.DefaultIfEmpty()
                                join three in db.ReceptionItem on one.DocumentId equals three.DocumentId
                                join four in db.Group on three.GroupId equals four.GroupId
                                select (new
                                {//.ToString(StandartLibrary.Lang.Resources.TimeSpanFormat)
                                 //new TimeSpan(pauses.Where(x => x.DocumentId == one.DocumentId && x.Type == 1 && x.StopDate != null).Sum(x => (x.StopDate.Value - x.StartDate).Ticks)).ToString(StandartLibrary.Lang.Resources.TimeSpanFormat), //Время пауз работы над дефектовкой
                                    four.GroupId,
                                    GroupName = four.Name != null ? four.Name : "",
                                    one.DocumentId,
                                    one.DocumentNumber,
                                    one.QuotationAmount,
                                    one.QuotationCurrency,
                                    CustomerName = one.Customer != null ? one.Customer.Name : "",
                                    one.SmcsCode,
                                    smcsComponentDescription = smcsComponent.Count(x => x.Code == one.SmcsCode) > 0 ? smcsComponent.FirstOrDefault(x => x.Code == one.SmcsCode)?.GetLocalized(x => x.Description, x => x.SMCSComponentID) : "",
                                    ModelName = one.Model != null ? one.Model.Name : "",
                                    Division = one.SegmentText != null ? one.SegmentText : "",
                                    CustomerApproval_ApprovedDate = (DateTime?)(two.PreparingQuotation_StartDate.HasValue ? two.PreparingQuotation_StartDate.Value : (DateTime?)null),
                                    DeliveryMethodName = two.CustomerApproval_DeliveryMethodId != null ? deliveryMethod.FirstOrDefault(x => x.DeliveryMethodId == two.CustomerApproval_DeliveryMethodId)?.Name : "",
                                    DeliveryMethodId = two.CustomerApproval_DeliveryMethodId,
                                    QuatationDateOfEntry = two.PreparingQuotation_DateOfEntry.HasValue ? two.PreparingQuotation_DateOfEntry.Value.ToString("dd.MM.yyyy") : "",
                                    QuatationDateOfEntryDate = two.PreparingQuotation_DateOfEntry,
                                    QuatationStartDate = two.PreparingQuotation_StartDate.HasValue ? two.PreparingQuotation_StartDate.Value.ToString("dd.MM.yyyy") : "",
                                    QuatationEndDate = two.PreparingQuotation_CompletedDate.HasValue ? two.PreparingQuotation_CompletedDate.Value.ToString("dd.MM.yyyy") : "",
                                    TotalNumberOfDaysToPrepareQuatation = (two.PreparingQuotation_StartDate.HasValue && two.PreparingQuotation_CompletedDate.HasValue) ? (two.PreparingQuotation_CompletedDate.Value - two.PreparingQuotation_StartDate.Value).Days.ToString() : "",
                                    ActualPreparationTimeQuatation = (two.PreparingQuotation_StartDate.HasValue && two.PreparingQuotation_CompletedDate.HasValue) ? (two.PreparingQuotation_CompletedDate.Value - two.PreparingQuotation_StartDate.Value).ToString(StandartLibrary.Lang.Resources.TimeSpanFormat) : "",
                                    CausesOfPauses = String.Concat(pauseList.Where(x => x.Type == 1 && x.DocumentId == one.DocumentId).Select(x => x.Description + " / ")),
                                    Approved_Rejection = two.CustomerApproval_IsApproved.HasValue && two.CustomerApproval_IsApproved.Value ? @StandartLibrary.Lang.Resources.Approved_5466 : @StandartLibrary.Lang.Resources.Renouncement_5467,
                                    CostOfPreRepair = two.PreparingQuotation_CostPreQuotation.HasValue ? two.PreparingQuotation_CostPreQuotation.ToString() : "",
                                    CostOfApprovedRepairs = two.CustomerApproval_CostSignedQuotation.HasValue ? two.CustomerApproval_CostSignedQuotation.ToString() : "",
                                    TotalNumberOfDaysWaitingForApproval_Rejection = (two.CustomerApproval_ApprovedDate.HasValue && two.PreparingQuotation_CompletedDate.HasValue) ? (two.CustomerApproval_ApprovedDate.Value - two.PreparingQuotation_CompletedDate.Value).Days.ToString() : "",
                                    DateOfApproval_Rejection = two.CustomerApproval_ApprovedDate.HasValue ? two.CustomerApproval_ApprovedDate.Value.ToString("dd.MM.yyyy") : (two.CustomerApproval_AnswerReceivedDate.HasValue ? two.CustomerApproval_AnswerReceivedDate.Value.ToString("dd.MM.yyyy") : ""),
                                    OrderDate = two.InPartsOrdering_OrderedDate.HasValue ? two.InPartsOrdering_OrderedDate.Value.ToString("dd.MM.yyyy") : "",
                                    DeliveryMethod = two.CustomerApproval_DeliveryMethodId.HasValue ? deliveryMethod.FirstOrDefault(x => x.DeliveryMethodId == two.CustomerApproval_DeliveryMethodId)?.Name : "",
                                    DateOfArrivalOfSparePart = counterOrderedParts.Count(x => x.DocumentId == one.DocumentId && x.DateStock != null) > 0 ? counterOrderedParts.First(x => x.DocumentId == one.DocumentId)?.DateStock.Value.ToString("dd.MM.yyyy") : "",
                                    ActualDeliveryTimeForSparePart = two.InPartsOrdering_AllPartsInAvalibleDate.HasValue ? two.InPartsOrdering_AllPartsInAvalibleDate.Value.ToString("dd.MM.yyyy") : "",
                                    CostParts = String.Format("{0:0.##}", two.CustomerApproval_IsApproved != null && two.CustomerApproval_IsApproved.Value ?
                                        (two.CustomerApproval_CostParts != null ? two.CustomerApproval_CostParts.Value : 0) :
                                        (two.PreparingQuotation_CostParts != null ? two.PreparingQuotation_CostParts.Value : 0)),
                                    CostRecovery = String.Format("{0:0.##}", two.CustomerApproval_IsApproved != null && two.CustomerApproval_IsApproved.Value ?
                                        (two.CustomerApproval_CostRecovery != null ? two.CustomerApproval_CostRecovery.Value : 0) :
                                        (two.PreparingQuotation_CostRecovery != null ? two.PreparingQuotation_CostRecovery.Value : 0)),
                                    CostReman = String.Format("{0:0.##}", two.CustomerApproval_IsApproved != null && two.CustomerApproval_IsApproved.Value ?
                                        (two.CustomerApproval_CostReman != null ? two.CustomerApproval_CostReman.Value : 0) :
                                        (two.PreparingQuotation_CostReman != null ? two.PreparingQuotation_CostReman.Value : 0)),
                                    CostTransportation = String.Format("{0:0.##}", two.CustomerApproval_IsApproved != null && two.CustomerApproval_IsApproved.Value ?
                                        (two.CustomerApproval_CostTransportation != null ? two.CustomerApproval_CostTransportation.Value : 0) :
                                        (two.PreparingQuotation_CostTransportation != null ? two.PreparingQuotation_CostTransportation.Value : 0)),
                                    CostWork = String.Format("{0:0.##}", two.CustomerApproval_IsApproved != null && two.CustomerApproval_IsApproved.Value ?
                                        (two.CustomerApproval_CostWork != null ? two.CustomerApproval_CostWork.Value : 0) :
                                        (two.PreparingQuotation_CostWork != null ? two.PreparingQuotation_CostWork.Value : 0)),
                                    CostQuotation = String.Format("{0:0.##}", two.CustomerApproval_IsApproved != null && two.CustomerApproval_IsApproved.Value ?
                                        (two.CustomerApproval_CostSignedQuotation != null ? two.CustomerApproval_CostSignedQuotation.Value : 0) :
                                        (two.PreparingQuotation_CostPreQuotation != null ? two.PreparingQuotation_CostPreQuotation.Value : 0))
                                })).ToList().Distinct();

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
            if (!string.IsNullOrEmpty(QuatationDateOfEntry_Begin))
            {
                var beginDate = DateTime.Parse(QuatationDateOfEntry_Begin);
                projectsList = projectsList.Where(w => w.QuatationDateOfEntryDate != null && w.QuatationDateOfEntryDate.Value >= beginDate).ToList();
            }
            if (!string.IsNullOrEmpty(QuatationDateOfEntry_End))
            {
                var endDate = DateTime.Parse(QuatationDateOfEntry_End);
                projectsList = projectsList.Where(w => w.QuatationDateOfEntryDate != null && w.QuatationDateOfEntryDate.Value <= endDate).ToList();
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

        [HttpPost, ValidateInput(false)]
        public JsonResult Ajax_QuotationEdit(int documentId,
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
            int CurrencyType,
            string Comment,
            string[] Customers,
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
                item.PreparingQuotation_CostParts = CostParts.Length > 0 ? decimal.Parse(CostParts.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.PreparingQuotation_CostWork = CostWork.Length > 0 ? decimal.Parse(CostWork.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.PreparingQuotation_CostRecovery = CostRecovery.Length > 0 ? decimal.Parse(CostRecovery.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.PreparingQuotation_CostTransportation = CostTransportation.Length > 0 ? decimal.Parse(CostTransportation.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.PreparingQuotation_CostReman = CostReman.Length > 0 ? decimal.Parse(CostReman.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.PreparingQuotation_CostPreQuotation = CostPreQuotation.Length > 0 ? decimal.Parse(CostPreQuotation.Replace(",", "."), NumberStyles.Number) : (decimal?)null;
                item.PreparingQuotation_CurrencyType = CurrencyType;
                item.PreparingQuotation_IsNotSpareParts = IsNotSpareParts;
                item.PreparingQuotation_IsSparePartsInStock = IsSparePartsInStock;
                item.Comment = Comment;
                db.SaveChanges();
            }
            db.SaveChanges();

            //var userName = "";
            //try
            //{
            //    userName = SharedCRCMS.Service.Helper.GetADUserProfile(User.Identity.Name).UserName;
            //}
            //catch (Exception ex)
            //{
            //    LogMan.Error("Ajax_QuotationEdit", ex);
            //}
            try
            {
                //var message = $"{Counter.Lang.Resources.ДобрыйДень}!\n                      "
                //+ $"\n{Counter.Lang.Resources.ВоВложенииКотировкиИОтчетПоРемонту}                   "
                //+ $"\n{Counter.Lang.Resources.ДоставкаЗапасныхЧастей}:                                  "
                //+ $"\n{Counter.Lang.Resources.Авиа} - " + item.PreparingQuotation_DeliveryTermsAviaDays
                //+ $"\n{Counter.Lang.Resources.Трак} - " + item.PreparingQuotation_DeliveryTermsTruckDays
                //+ $"\n{Counter.Lang.Resources.ПрошуПодписатьКотировку   }                            "
                //+ $"\n{Counter.Lang.Resources.Спасибо   }                                              "
                //+ $"\n\n\n{Counter.Lang.Resources.СУважением}, " + userName;

                if (item != null)
                {
                    var toList = new List<string>();
                    var ccList = new List<string>();

                    var document = db.Documents.FirstOrDefault(x => x.DocumentId == item.DocumentId);
                    if (document != null)
                    {
                        var customerId = document?.CustomerId;
                        if (customerId.HasValue)
                        {
                            toList.AddRange(db.Counter_PSSR_Email.Where(x => x.CustomerId == customerId && x.Type == 1).Select(x => x.Email).ToArray());
                            ccList.AddRange(db.Counter_PSSR_Email.Where(x => x.CustomerId == customerId && x.Type == 2).Select(x => x.Email).ToArray());
                        }

                        if (Emails != null && Emails.Any())
                            toList.AddRange(Emails);

                        if (toList.Any() || ccList.Any())
                        {
                            var uploadIds = db.Uploads
                                .Where(x => x.DocumentId == documentId && (x.TypeId == 17 || x.TypeId == 2))
                                .Select(s => s.UploadId).ToList();

                            var smcsComponent = db.SMCSComponent.FirstOrDefault(x => x.Code == document.SmcsCode);

                            var group = (from one in db.Documents
                                         join two in db.ReceptionItem on one.DocumentId equals two.DocumentId
                                         join three in db.Group on two.GroupId equals three.GroupId
                                         where (one.DocumentId == documentId)
                                         select three).Distinct().FirstOrDefault();

                            var mailQueueParameter = new MailQueueParameterModel
                            {
                                //Subject = StandartLibrary.Lang.Resources.Quotation_5516,
                                Subject = "{Quotation_5516}",
                                Title = "{Quotation_Detail}",
                                UploadIds = uploadIds,
                                MailQueueTypeId = (int)MailQueueType.BaseOfQuotation,
                                BaseOfQuotation = new BaseOfQuotationModel
                                {
                                    DocumentNumber = document.DocumentNumber,
                                    CustomerName = document.Customer != null ? document.Customer.Name : "",
                                    Division = document.SegmentText,
                                    Component = smcsComponent != null ? smcsComponent.GetLocalized(x => x.Description, x => x.SMCSComponentID) : "",
                                    ModelName = document.Model != null ? document.Model.Name : "",
                                    IsNotSpareParts = IsNotSpareParts,
                                    IsSparePartsInWarehousesRK = IsSparePartsInWarehousesRK,
                                    IsSparePartsInStock = IsSparePartsInStock,
                                    IsSparePartsProvideTheCustomer = IsSparePartsProvideTheCustomer,
                                    GroupName = group != null ? group.Name : "",
                                }
                            };
                            SharedCRCMS.Service.SmtpService.SendMail(mailQueueParameter, toList, ccList);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogMan.Error("Ajax_QuotationEdit", ex);
            }
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }
    }
}