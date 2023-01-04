using PagedList;
using SharedCRCMS.Filter;
using SharedCRCMS.Models;
using SharedCRCMS.Service;
using StandartLibrary.Models.Enums;
using System;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.Mvc;

namespace Counter.Controllers
{
    [Authorize]
    [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW)]
    public class SearchDocumentController : BaseController
    {
        private CRCMSEntities db = new CRCMSEntities();

        // GET: SearchDocument
        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R)]
        [UserActivityFilter]
        public ActionResult Index(int document_id = 0)
        {
            ViewBag.document_id = document_id;
            ViewBag.document_number = (document_id > 0 ? db.Documents.Single(x => x.DocumentId == document_id).DocumentNumber : "");
            return View("SearchDocument");
        }

        //https://trello.com/c/FaiD158o/659-teklif-mod%C3%BCl%C3%BC-d%C3%BCzenle-sayfas%C4%B1-gizlenmeli
        /*public ActionResult Edit(int document_id = 0)
        {
            ViewBag.document_id = document_id;
            ViewBag.document_number = (document_id > 0 ? db.Documents.Single(x => x.DocumentId == document_id).DocumentNumber : "");
            ViewBag.counterItem = db.Counter_List.Single(x => x.DocumentId == document_id);
            return View("SearchDocumentEdit");
        }*/

        [HttpPost, ValidateInput(false)]
        public JsonResult Save(int document_id, bool existsSpareParts, int deliveryMethodId, bool IsAllPartsInAvalible,
            string OrderedDate, string DeliveryTermsTruckDays, string DeliveryTermsAviaDays, bool SparePartsInWarehousesRK,
            string CostParts,
            string CostWork,
            string CostRecovery,
            string CostTransportation,
            string CostReman,
            string CostPreQuotation,
            string CostRelativeOfTheNewNode,
            string SignedCostParts,
            string SignedCostWork,
            string SignedCostRecovery,
            string SignedCostTransportation,
            string SignedCostReman,
            string SignedCostSignedQuotation,
            string SignedCostRelativeOfTheNewNode,
            bool existsRestorationWork,
            bool isSparePartsProvideTheCustomer,
            bool IsReman
            )
        {
            CostParts = Regex.Replace(CostParts, "[^0-9\\,\\.]", "").Trim();
            CostWork = Regex.Replace(CostWork, "[^0-9\\,\\.]", "").Trim();
            CostRecovery = Regex.Replace(CostRecovery, "[^0-9\\,\\.]", "").Trim();
            CostTransportation = Regex.Replace(CostTransportation, "[^0-9\\,\\.]", "").Trim();
            CostReman = Regex.Replace(CostReman, "[^0-9\\,\\.]", "").Trim();
            CostPreQuotation = Regex.Replace(CostPreQuotation, "[^0-9\\,\\.]", "").Trim();
            CostRelativeOfTheNewNode = Regex.Replace(CostRelativeOfTheNewNode, "[^0-9\\,\\.]", "").Trim();

            SignedCostParts = Regex.Replace(SignedCostParts, "[^0-9\\,\\.]", "").Trim();
            SignedCostWork = Regex.Replace(SignedCostWork, "[^0-9\\,\\.]", "").Trim();
            SignedCostRecovery = Regex.Replace(SignedCostRecovery, "[^0-9\\,\\.]", "").Trim();
            SignedCostTransportation = Regex.Replace(SignedCostTransportation, "[^0-9\\,\\.]", "").Trim();
            SignedCostReman = Regex.Replace(SignedCostReman, "[^0-9\\,\\.]", "").Trim();
            SignedCostSignedQuotation = Regex.Replace(SignedCostSignedQuotation, "[^0-9\\,\\.]", "").Trim();
            SignedCostRelativeOfTheNewNode = Regex.Replace(SignedCostRelativeOfTheNewNode, "[^0-9\\,\\.]", "").Trim();

            var item = db.Counter_List.Single(x => x.DocumentId == document_id);
            item.CustomerApproval_ExistsSpareParts = existsSpareParts;
            item.CustomerApproval_DeliveryMethodId = deliveryMethodId;
            item.InPartsOrdering_IsAllPartsInAvalible = IsAllPartsInAvalible;
            item.SparePartsInWarehousesRK = SparePartsInWarehousesRK;

            item.PreparingQuotation_CostParts = CostParts.Length > 0 ? decimal.Parse(CostParts.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
            item.PreparingQuotation_CostWork = CostWork.Length > 0 ? decimal.Parse(CostWork.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
            item.PreparingQuotation_CostRecovery = CostRecovery.Length > 0 ? decimal.Parse(CostRecovery.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
            item.PreparingQuotation_CostTransportation = CostTransportation.Length > 0 ? decimal.Parse(CostTransportation.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
            item.PreparingQuotation_CostReman = CostReman.Length > 0 ? decimal.Parse(CostReman.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
            item.PreparingQuotation_CostPreQuotation = CostPreQuotation.Length > 0 ? decimal.Parse(CostPreQuotation.Replace(",", "."), NumberStyles.Number) : (decimal?)null;
            item.PreparingQuotation_CostRelativeOfTheNewNode = CostRelativeOfTheNewNode.Length > 0 ? decimal.Parse(CostRelativeOfTheNewNode.Replace(",", "."), NumberStyles.Number) : (decimal?)null;

            item.CustomerApproval_CostParts = SignedCostParts.Length > 0 ? decimal.Parse(SignedCostParts.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
            item.CustomerApproval_CostWork = SignedCostWork.Length > 0 ? decimal.Parse(SignedCostWork.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
            item.CustomerApproval_CostRecovery = SignedCostRecovery.Length > 0 ? decimal.Parse(SignedCostRecovery.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
            item.CustomerApproval_CostTransportation = SignedCostTransportation.Length > 0 ? decimal.Parse(SignedCostTransportation.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
            item.CustomerApproval_CostReman = SignedCostReman.Length > 0 ? decimal.Parse(SignedCostReman.Replace(",", "."), NumberStyles.AllowDecimalPoint) : (decimal?)null;
            item.CustomerApproval_CostSignedQuotation = SignedCostSignedQuotation.Length > 0 ? decimal.Parse(SignedCostSignedQuotation.Replace(",", "."), NumberStyles.Number) : (decimal?)null;
            item.CustomerApproval_CostRelativeOfTheNewNode = SignedCostRelativeOfTheNewNode.Length > 0 ? decimal.Parse(SignedCostRelativeOfTheNewNode.Replace(",", "."), NumberStyles.Number) : (decimal?)null;

            item.CustomerApproval_ExistsRestorationWork = existsRestorationWork;
            item.CustomerApproval_IsSparePartsProvideTheCustomer = isSparePartsProvideTheCustomer;
            if (!string.IsNullOrEmpty(OrderedDate))
            {
                item.InPartsOrdering_OrderedDate = DateTime.Parse(OrderedDate);
            }
            else
                item.InPartsOrdering_OrderedDate = null;

            item.PreparingQuotation_DeliveryTermsTruckDays = DeliveryTermsTruckDays;
            item.PreparingQuotation_DeliveryTermsAviaDays = DeliveryTermsAviaDays;
            item.CustomerApproval_IsReman = IsReman;
            db.SaveChanges();
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        //document_id: @(documentId),
        //            existsSpareParts: $("#existsSpareParts1").prop('checked') ? true : false,
        //            deliveryMethodId: $("#deliveryMethod0").prop('checked') ? 0 : ($("#deliveryMethod1").prop('checked') ? 1 : 2),
        //            IsAllPartsInAvalible:$("#IsAllPartsInAvalible").prop('checked') ? true : false,
        //            OrderedDate: $("#deliveryMethod0").val(),
        //            DeliveryTermsTruckDays:$("#DeliveryTermsTruckDays").val(),
        //            DeliveryTermsAviaDays:$("#DeliveryTermsAviaDays").val(),
        public ActionResult CancelReceivedDenial(int document_id = 0)
        {
            //Отмена отказа и переменищение в Customer Approval
            var item = db.Counter_List.Single(x => x.DocumentId == document_id);
            item.LastChangeDate = DateTime.Now;
            item.CustomerApproval_IsAnswerReceived = false;
            item.CustomerApproval_AnswerReceivedDate = null;
            item.InPartsOrdering_IsAllPartsInAvalible = null;
            item.InPartsOrdering_IsOrdered = null;
            item.CounterStatusId = (int)CounterStatus.PreparingQuotation;
            db.SaveChanges();
            return Json(new { Status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ReturnOnAwaitingOrder(int document_id = 0)
        {
            //Отмена отказа и переменищение в Customer Approval
            var item = db.Counter_List.Single(x => x.DocumentId == document_id);
            item.LastChangeDate = DateTime.Now;
            item.CounterStatusId = (int)CounterStatus.QuotationSent;
            item.CustomerApproval_IsApproved = true;
            item.InPartsOrdering_IsAllPartsInAvalible = null;
            item.InPartsOrdering_IsOrdered = null;
            db.SaveChanges();
            return Json(new { Status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ReturnOnAwaitingParts(int document_id = 0)
        {
            //Отмена отказа и переменищение в Customer Approval
            var item = db.Counter_List.Single(x => x.DocumentId == document_id);
            item.LastChangeDate = DateTime.Now;
            item.CounterStatusId = (int)CounterStatus.AnswerReceived;
            item.InPartsOrdering_IsAllPartsInAvalible = null;
            item.InPartsOrdering_IsOrdered = null;
            db.SaveChanges();
            return Json(new { Status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ReturnOnCustomerApproval(int document_id = 0)
        {
            //Отмена отказа и переменищение в Customer Approval
            var item = db.Counter_List.Single(x => x.DocumentId == document_id);
            item.LastChangeDate = DateTime.Now;
            item.CounterStatusId = (int)CounterStatus.PreparingQuotation;
            item.InPartsOrdering_IsAllPartsInAvalible = null;
            item.InPartsOrdering_IsOrdered = null;
            item.PreparingQuotation_IsCompleted = true;
            db.SaveChanges();
            return Json(new { Status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [UserActivityFilter]
        public JsonResult Ajax_SearchHZ(int document_id = 0)
        {
            //Номер|Заказчик|Дивизион|Компонент|Модель машины|Дефектовка|Additional|Техотчет|Комментарии|Дата поступления

            var filterDocIdSECompleted = db.ServiceEngineer_List.Where(x => x.PreparingOfReport_StopDate != null).Select(x => x.DocumentId).ToArray(); // Завершенные наряды из SE
            var filterDocIdInCounter = db.Counter_List.Select(x => x.DocumentId).ToArray();
            var filterDocIdInProjectExpenses = db.Counter_List.Where(x => x.CounterStatusId == (int)CounterStatus.PriceOpening && x.PreparingQuotation_StateId == 0).Select(x => x.DocumentId).ToArray();
            var filterDocIdInCounterHZ1 = db.Counter_List.Where(x => x.CounterStatusId == (int)CounterStatus.Start && x.PreparingQuotation_StateId == 0).Select(x => x.DocumentId).ToArray();
            var filterDocIdInCounterHZ2 = db.Counter_List.Where(x => x.CounterStatusId == (int)CounterStatus.Start && x.PreparingQuotation_StateId != 0).Select(x => x.DocumentId).ToArray();

            var documents = db.Documents.Where(x =>
                                                        !((filterDocIdSECompleted.Contains(x.DocumentId)
                                                                && !filterDocIdInCounter.Contains(x.DocumentId))
                                                        || filterDocIdInProjectExpenses.Contains(x.DocumentId)
                                                        || filterDocIdInCounterHZ1.Contains(x.DocumentId)
                                                        )
                                                        && filterDocIdInCounterHZ2.Contains(x.DocumentId)
                                                        && x.DocumentId == document_id
                                                    ).ToList();

            var projectsList = (from one in documents
                                join two in db.ServiceEngineer_List on one.DocumentId equals two.DocumentId into ps
                                from two in ps.DefaultIfEmpty()
                                select (new
                                {
                                    one.DocumentCreateDate,
                                    one.DocumentId,
                                    one.DocumentNumber
                                })).ToList();

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
    }
}