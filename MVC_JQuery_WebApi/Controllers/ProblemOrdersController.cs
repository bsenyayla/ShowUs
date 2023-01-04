using PagedList;
using SharedCRCMS.Models;
using SharedCRCMS.Service;
using StandartLibrary.Models.Enums;
using System;
using System.Linq;
using System.Web.Mvc;

namespace Counter.Controllers
{
    [Authorize]
    [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW)]
    public class ProblemOrdersController : BaseController
    {
        private CRCMSEntities db = new CRCMSEntities();

        // GET: ProblemOrders
        public ActionResult Index()
        {
            return View("ProblemOrders");
        }

        [HttpPost]
        public JsonResult Ajax_QueueAdd(int documentId)
        {
            if (db.ServiceEngineer_Queue.Where(x => x.DocumentId == documentId).Count() > 0)
                return Json(new { status = "isexists" }, JsonRequestBehavior.AllowGet);

            db.ServiceEngineer_Queue.Add(new StandartLibrary.Models.DataModels.ServiceEngineer_Queue()
            {
                DocumentId = documentId,
                AddDate = DateTime.Now
            });
            db.SaveChanges();
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult Ajax_ProblemOrders_GetList(int document_id = 0,
                                    int customer_id = 0,
                                    string smcsCode = "",
                                    int model_id = 0,
                                    string ReceiptDate_Begin = "", string ReceiptDate_End = "",
                                    string division = "")
        {
            //Номер|Заказчик|Дивизион|Компонент|Модель машины|Дефектовка|Additional|Техотчет|Комментарии|Дата поступления

            var DocIdUploadPreparingOfReport = db.Uploads.Where(x => x.TypeId == 1).Select(x => x.DocumentId).ToArray();
            var DocIdUploadMachineShopForm = db.Uploads.Where(x => x.TypeId == 6).Select(x => x.DocumentId).ToArray();
            var DocIdUploadTechnicalReport = db.Uploads.Where(x => x.TypeId == 2).Select(x => x.DocumentId).ToArray();

            var filterDocIdSE = db.ServiceEngineer_List.Select(x => x.DocumentId).ToArray(); // Завершенные наряды из SE
            var filterDocIdInCounter = db.Counter_List.Select(x => x.DocumentId).ToArray();
            var filterDocIdInSEQueue = db.ServiceEngineer_Queue.Select(x => x.DocumentId).ToArray();
            var userSmcsCode = new Counter.Controllers.AJAXController().GetUserGroupSmscCode(User);
            var documents = db.Documents.Where(x => ((DocIdUploadPreparingOfReport.Contains(x.DocumentId) &&
                                                        DocIdUploadMachineShopForm.Contains(x.DocumentId) &&
                                                        DocIdUploadTechnicalReport.Contains(x.DocumentId)) &&
                                                        !filterDocIdSE.Contains(x.DocumentId)
                                                         && !filterDocIdInCounter.Contains(x.DocumentId)
                                                         && !filterDocIdInSEQueue.Contains(x.DocumentId)
                                                    )).ToList();

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

            var projectsList = (from one in documents
                                join two in db.ServiceEngineer_List on one.DocumentId equals two.DocumentId into ps
                                from two in ps.DefaultIfEmpty()
                                select (new
                                {
                                    one.DocumentId,
                                    one.DocumentNumber,
                                    CustomerName = one.Customer != null ? one.Customer.Name : "",
                                    one.SmcsCode,
                                    smcsComponentDescription = smcsComponent.Count(x => x.Code == one.SmcsCode) > 0 ? smcsComponent.Single(x => x.Code == one.SmcsCode).GetLocalized(x => x.Description, x => x.SMCSComponentID) : "",
                                    ModelName = one.Model != null ? one.Model.Name : "",
                                    Comment = two != null && two.Comment != null ? two.Comment : "",
                                    StatusId = (two != null ? two.StatusId : 0),
                                    UploadDefectList = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 1),
                                    UploadMachineShopForm = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 6),
                                    UploadTechnicalReport = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 2),
                                    UploadPhoto = uploads.FirstOrDefault(x => x.DocumentId == one.DocumentId && x.TypeId == 7),
                                    Division = one.SegmentText != null ? one.SegmentText : "",
                                    ReceiptDate = two != null && one.DocumentCreateDate != null ? one.DocumentCreateDate.Value : DateTime.Now
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
                return Json(new { draw = sEcho, recordsTotal = recordsCount, recordsFiltered = recordsCount, data = projectsList.ToPagedList(pageNumber, pageSize), searchId = searchId }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { draw = 0, recordsTotal = 0, recordsFiltered = 0, data = "" }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}