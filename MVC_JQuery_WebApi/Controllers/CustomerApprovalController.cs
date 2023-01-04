using PagedList;
using SharedCRCMS.Filter;
using SharedCRCMS.Models;
using SharedCRCMS.Service;
using StandartLibrary.Models.Enums;
using StandartLibrary.Models.ViewModels.Crcms;
using System;
using System.Data.Entity;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.Mvc;

namespace Counter.Controllers
{
    [Authorize]
    [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW)]
    public class CustomerApprovalController : BaseController
    {
        private CRCMSEntities db = new CRCMSEntities();

        // GET: CustomerApproval
        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW)]
        [UserActivityFilter]
        public ActionResult Index()
        {
            return View("CustomerApproval");
        }

        [HttpPost]
        [UserActivityFilter]
        public JsonResult Ajax_OnApproval_GetList(int days = 10,
                                 int? duration = int.MaxValue,
                                 int document_id = 0,
                                 int customer_id = 0,
                                 string smcsCode = "",
                                 int model_id = 0,
                                 string PreparingQuotation_CompletedDate_Begin = "",
                                 string PreparingQuotation_CompletedDate_End = "",
                                 string division = "",
                                   int group_id = 0)
        {
            var counter = db.Counter_List.ToList();
            var filterDocId = counter.Where(x => x.CounterStatusId == (int)CounterStatus.PreparingQuotation
                    && x.PreparingQuotation_IsCompleted
                    ).Select(x => x.DocumentId).ToArray();

            var userSmcsCode = new Counter.Controllers.AJAXController().GetUserGroupSmscCode(User);

            var documents = (from x in db.Documents
                             join di in db.DispatchItem on x.DocumentId equals di.DocumentId into grpx
                             from grp in grpx.DefaultIfEmpty()
                             where grp == null
                             && filterDocId.Contains(x.DocumentId)
                             //&& (userSmcsCode.Contains(x.SmcsCode))
                             select x).Distinct();

            #region Filters

            if (document_id != 0)
                documents = documents.Where(w => w.DocumentId == document_id);
            if (customer_id != 0)
                documents = documents.Where(w => w.CustomerId == customer_id);
            if (model_id != 0)
                documents = documents.Where(w => w.ModelId == model_id);
            if (smcsCode != "")
                documents = documents.Where(w => w.SmcsCode == smcsCode);
            if (group_id != 0)
                documents = (from one in documents
                             join two in db.ReceptionItem on one.DocumentId equals two.DocumentId
                             join three in db.Group on two.GroupId equals three.GroupId
                             where (three.GroupId == group_id)
                             select one).Distinct();

            #endregion Filters

            StandartLibrary.Models.DataModels.SMCSComponent smcsComponent = new StandartLibrary.Models.DataModels.SMCSComponent();
            try
            {
                var projectsList = (from one in documents
                                    join two in db.Counter_List on one.DocumentId equals two.DocumentId into ps
                                    from two in ps.DefaultIfEmpty()
                                    where ps.Count() > 0
                                   join six in db.ReceptionItem on one.DocumentId equals six.DocumentId
                                    join ten in db.Reception on six.ReceptionId equals ten.ReceptionId
                                    join seven in db.Group on six.GroupId equals seven.GroupId
                                    where two.PreparingQuotation_CompletedDate != null
                                            &&
                                            DbFunctions.DiffDays(two.PreparingQuotation_CompletedDate.Value, DateTime.Now) >= days
                                            //&&
                                            //DbFunctions.DiffDays(two.PreparingQuotation_CompletedDate.Value, DateTime.Now) < (days + duration)
                                    join three in
                                                    (
                                                        from r in db.ReceptionItem
                                                        join ri in db.Reception on r.ReceptionId equals ri.ReceptionId
                                                        group r by r.DocumentId into grp
                                                        select new { DocumentId = grp.Key, ReceptionDate = grp.Select(x => x.Reception.ReceptionDate).Max() }
                                                    ) on one.DocumentId equals three.DocumentId into ri
                                    from three in ri.DefaultIfEmpty()
                                    join four in (
                                                    (from smc in db.SMCSComponent
                                                     join ngl in db.LocalizedProperty on smc.SMCSComponentID equals ngl.EntityId into ngGrp
                                                     from ng in ngGrp.DefaultIfEmpty()
                                                     where ng.Language == System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName
                                                         && ng.Entity == nameof(smcsComponent) && ng.Field == nameof(smcsComponent.Description)
                                                     select new { smc.Code, Val = (ng != null ? ng.Value : "") })) on one.SmcsCode equals four.Code

                                    join five in db.DocumentType on one.DocumentTypeId equals five.DocumentTypeId into dt
                                    from five in dt.DefaultIfEmpty()
                                    select (new CustomerApprovalViewModel()
                                    {
                                        DocumentId = one.DocumentId,
                                        DocumentNumber = one.DocumentNumber,
                                        GroupId= seven.GroupId,
                                        GroupName = seven.Name != null ? seven.Name : "",
                                        CustomerName = one.Customer != null ? one.Customer.Name : "",
                                        SmcsCode = one.SmcsCode,
                                        smcsComponentDescription = four != null ? four.Val : string.Empty,
                                        ModelName = one.Model != null ? one.Model.Name : "",
                                        CommentPSSR = two != null && two.CommentPSSR != null ? two.CommentPSSR : "",
                                        StateId = (two != null ? two.PreparingQuotation_StateId : 0),
                                        Division = one.SegmentText != null ? one.SegmentText : "",
                                        PreparingQuotation_CompletedDate = two.PreparingQuotation_CompletedDate != null ? two.PreparingQuotation_CompletedDate.Value : new DateTime(1900, 1, 1),
                                        PssrName = one.PssrName,
                                        ReceptionDate = (three != null ? three.ReceptionDate : (DateTime?)null),
                                        IsZsrt = (new string[] { "K1", "RO", "CR" }.Contains(five.Code) && ten.ReceptionDate  > new DateTime(2021, 03, 16)),
                                        QuotationAmount = one.QuotationAmount,
                                        QuotationCurrency = one.QuotationCurrency,
                                        QuotationDocStatus = one.QuotationDocStatus,
                                        QuotationDocStatusText = one.QuotationDocStatusText,
                                        DocumentType = one.DocumentType.Name,
                                        ArrivalReasonId = 0
                                    })).OrderByDescending(x => x.PreparingQuotation_CompletedDate).ToList();

                #region Filters

                if (!string.IsNullOrEmpty(PreparingQuotation_CompletedDate_Begin))
                {
                    var beginDate = DateTime.Parse(PreparingQuotation_CompletedDate_Begin);
                    projectsList = projectsList.Where(w => w.PreparingQuotation_CompletedDate >= beginDate).ToList();
                }
                if (!string.IsNullOrEmpty(PreparingQuotation_CompletedDate_End))
                {
                    var endDate = DateTime.Parse(PreparingQuotation_CompletedDate_End);
                    projectsList = projectsList.Where(w => w.PreparingQuotation_CompletedDate <= endDate).ToList();
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

                    var docIds = projectsList.Select(x => x.DocumentId).Distinct().ToList();
                    var listCrc = (from recItem in db.ReceptionItem
                                   join crcReq in db.CrcRequestComponent on recItem.RequestComponentId equals crcReq.CrcRequestComponentId
                                   where docIds.Contains(recItem.DocumentId)
                                   select (new { docId = recItem.DocumentId, Reason = crcReq.ComponentArrivalReason, GroupId = crcReq.GroupId })).ToList();

                    var listInt = (from recItem in db.ReceptionItem
                                   join intReq in db.InternalRequests on recItem.InternalRequestId equals intReq.RequestNumber
                                   join crcArr in db.CrcArrivalReasons on intReq.ComponentArrivalReason equals crcArr.Id
                                   where docIds.Contains(recItem.DocumentId)
                                   select (new { docId = recItem.DocumentId, Reason = (int?)crcArr.ArrivalReasonOrder, GroupId = intReq.GroupId })).ToList();

                    foreach (var item in projectsList)
                    {
                        if (listCrc.Where(x => x.docId == item.DocumentId).Any())
                        {
                            var t = listCrc.Where(x => x.docId == item.DocumentId).FirstOrDefault();
                            item.ArrivalReasonId = t.Reason.HasValue ? t.Reason.Value : 0;
                            item.GroupId = t.GroupId.HasValue ? t.GroupId : 0;
                        }
                        else if (listInt.Where(x => x.docId == item.DocumentId).Any())
                        {
                            var t = listInt.Where(x => x.docId == item.DocumentId).FirstOrDefault();
                            item.ArrivalReasonId = t.Reason.HasValue ? t.Reason.Value : 0;
                            item.GroupId = t.GroupId.HasValue ? t.GroupId : 0;
                        }
                    }

                    return Json(new { draw = sEcho, recordsTotal = recordsCount, recordsFiltered = recordsCount, data = projectsList.ToPagedList(pageNumber, pageSize), days = days, duration = duration, searchId = searchId }, JsonRequestBehavior.AllowGet);
                }
                catch (Exception ex)
                {
                    return Json(new { draw = 0, recordsTotal = 0, recordsFiltered = 0, data = "" }, JsonRequestBehavior.AllowGet);
                }
            }
            catch (Exception ex)
            {

                throw;
            }
        }

        [HttpPost]
        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_RW)]
        [UserActivityFilter]
        public JsonResult Ajax_SaveCommentPSSR(int documentId, string comment)
        {
            var item = db.Counter_List.Single(x => x.DocumentId == documentId);
            item.LastChangeDate = DateTime.Now;
            item.CommentPSSR = comment;
            db.SaveChanges();
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_RW)]
        [UserActivityFilter]
        public JsonResult Ajax_ReceivedDenial(int documentId)
        {
            var item = db.Counter_List.Single(x => x.DocumentId == documentId);
            item.LastChangeDate = DateTime.Now;
            item.CustomerApproval_IsAnswerReceived = true;
            item.CustomerApproval_AnswerReceivedDate = DateTime.Now;
            item.CounterStatusId = (int)CounterStatus.QuotationRejected;//Отказ
            db.SaveChanges();
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_RW)]
        [UserActivityFilter]
        public JsonResult Ajax_ReceivedUpdate(int documentId)
        {
            var item = db.Counter_List.Single(x => x.DocumentId == documentId);
            item.LastChangeDate = DateTime.Now;
            item.CustomerApproval_IsAnswerReceived = true;
            item.CustomerApproval_AnswerReceivedDate = DateTime.Now;
            item.CounterStatusId = (int)CounterStatus.PriceOpening;
            item.PreparingQuotation_StateId = 5;
            db.SaveChanges();
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_RW)]
        [UserActivityFilter]
        public JsonResult Ajax_AnswerReceivedApproved(int documentId,
            string CostParts,
            string CostWork,
            string CostRecovery,
            string CostTransportation,
            string CostReman,
            string CostSignedQuotation,
            string CostRelativeOfTheNewNode,
            int CurrencyType,
            int deliveryMethodId,
            bool existsRestorationWork,
            bool existsSpareParts,
            bool isSparePartsProvideTheCustomer,
            bool IsSparePartsInWarehousesRK,
            bool IsReman
             )
        {
            CostParts = Regex.Replace(CostParts, "[^0-9\\,\\.]", "").Trim();
            CostWork = Regex.Replace(CostWork, "[^0-9\\,\\.]", "").Trim();
            CostRecovery = Regex.Replace(CostRecovery, "[^0-9\\,\\.]", "").Trim();
            CostTransportation = Regex.Replace(CostTransportation, "[^0-9\\,\\.]", "").Trim();
            CostReman = Regex.Replace(CostReman, "[^0-9\\,\\.]", "").Trim();
            CostSignedQuotation = Regex.Replace(CostSignedQuotation, "[^0-9\\,\\.]", "").Trim();

            var item = db.Counter_List.SingleOrDefault(x => x.DocumentId == documentId);

            if (item != null)
            {
                item.LastChangeDate = DateTime.Now;
                item.CounterStatusId = (int)CounterStatus.QuotationSent;
                item.CustomerApproval_IsAnswerReceived = true;
                item.CustomerApproval_AnswerReceivedDate = DateTime.Now;
                item.CustomerApproval_IsApproved = true;
                item.CustomerApproval_ApprovedDate = DateTime.Now;
                item.CustomerApproval_CostParts = CostParts.Length > 0 ? decimal.Parse(CostParts.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.CustomerApproval_CostWork = CostWork.Length > 0 ? decimal.Parse(CostWork.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.CustomerApproval_CostRecovery = CostRecovery.Length > 0 ? decimal.Parse(CostRecovery.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.CustomerApproval_CostTransportation = CostTransportation.Length > 0 ? decimal.Parse(CostTransportation.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.CustomerApproval_CostReman = CostReman.Length > 0 ? decimal.Parse(CostReman.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
                item.CustomerApproval_CostSignedQuotation = CostSignedQuotation.Length > 0 ? decimal.Parse(CostSignedQuotation.Replace(",", "."), NumberStyles.Number) : (decimal?)null;
                item.CustomerApproval_CostRelativeOfTheNewNode = CostRelativeOfTheNewNode.Length > 0 ? decimal.Parse(CostRelativeOfTheNewNode.Replace(",", "."), NumberStyles.Number) : (decimal?)null;
                item.CustomerApproval_CurrencyType = CurrencyType;
                item.CustomerApproval_DeliveryMethodId = deliveryMethodId;
                item.CustomerApproval_ExistsRestorationWork = existsRestorationWork;
                item.CustomerApproval_ExistsSpareParts = existsSpareParts;
                item.CustomerApproval_IsSparePartsProvideTheCustomer = isSparePartsProvideTheCustomer;
                item.SparePartsInWarehousesRK = IsSparePartsInWarehousesRK;
                //if (item.PreparingQuotation_IsNotSpareParts == true)
                //{
                //    item.CounterStatusId = (int)CounterStatus.Approved;
                //}


                ////metotun ismi bile approved oldugundan  aşağıdaki kod bloğu saçma kalıyordu.
                item.CounterStatusId = (int)CounterStatus.Approved;
                /*
                if (item.CustomerApproval_ExistsSpareParts == true)
                {
                    item.CounterStatusId = (int)CounterStatus.Approved;
                }
                else
                {
                    item.CounterStatusId = (int)CounterStatus.PartsInStockOrQotationRejected;
                }
                */


                item.CustomerApproval_IsReman = IsReman;
                db.SaveChanges();
                //UploadPartsStatusController.RecalcPartsStatus(db, documentId);
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
            //}

            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult CheckMsFormDocument(string DocumentId)
        {
            int docID = Convert.ToInt32(DocumentId);

            var item = db.Uploads.Where(x => x.DocumentId == docID && x.TypeId == 6 && x.Name != "NotApplicable" && x.Deleted == false).Select(x => x).FirstOrDefault();

            if (item != null)
            {
                return Json("true", JsonRequestBehavior.AllowGet);
            }

            return Json("false", JsonRequestBehavior.AllowGet);
        }
    }
}