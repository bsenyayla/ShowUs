using OfficeOpenXml;
using SharedCRCMS.Filter;
using SharedCRCMS.Models.Tickets;
using SharedCRCMS.Service;

//using SharedCRCMS.Models;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.Enums;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

//CounterStatusId = 1; Вкладка Preparing Quotation(ПОдготовка котировки)CounterStatusId = 2; Котировка завершена передедит во вкладку Customer Approval(На одобрении)
//CounterStatusId = 3; Одобрен, переходит во вкладку InParts
//CounterStatusId = 4;//При выборе ожидаем ЗЧ переходит в раздел Ожидающие запчастей
//CounterStatusId = 5; //При выборе все ЗЧ в наличии наряд переходит в кабинет планировщика по текущему принципу,   а также в базу котировок
//CounterStatusId = 6;//Отказ
namespace Counter.Controllers
{
    [Authorize]
    [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW)]
    public class AJAXController : BaseController
    {
        public class Description
        {
            public string Code { get; set; }
            public string SmcsCode { get; set; }
            public string Name { get; set; }
        }

        public class CountOfDocuments
        {
            public int WaitingForTreatment { get; set; }
            public int Treated { get; set; }
            public int InAnticipationOfComponent { get; set; }
            public int PendingPlanning { get; set; }
            public int Planned { get; set; }

            public int WaitingForReport { get; set; }
            public int OnQuotation { get; set; }
            public int Archive { get; set; }
        }

        private SharedCRCMS.Models.CRCMSEntities db = new SharedCRCMS.Models.CRCMSEntities();
        private TicketsEntities dbTicket = new TicketsEntities();

        private class uploadItem
        {
            public int DocumentId;
            public int Type;
        }

        public string[] GetUserGroupSmscCode(System.Security.Principal.IPrincipal user)
        {
            try
            {
                using (var db = new SharedCRCMS.Models.CRCMSEntities())
                {
                    //var localUser = db.LocalUser.AsNoTracking().FirstOrDefault(x => x.SID == user.Identity.Name);
                    //var group = db.Counter_UserGroup.AsNoTracking().FirstOrDefault(x => x.UserId == localUser.UserId);

                    var groups = PermissionGroupId(user.Identity.Name, new PermissionEnum[] { PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW });
                    int totalGroupCount = db.Group.Select(x => x).Count();

                    if (groups == null || groups.Count == totalGroupCount)
                    {
                        return db.Documents.Select(x => x.SmcsCode).Distinct().ToArray();
                    }
                    else
                    {
                        var smcsCode = db.SMCSComponentGroup.AsNoTracking().Where(x => groups.Contains(x.GroupId)).Select(x => x.Code).ToArray();
                        return smcsCode;
                    }
                }
            }
            catch (Exception ex)
            {
                return new string[0];
            }
        }

        [HttpPost]
        public JsonResult SetCurrentGroupId(int GroupId)
        {
            var localUser = db.LocalUser.SingleOrDefault(x => x.SID == User.Identity.Name);
            var userGroupItem = db.Counter_UserGroup.SingleOrDefault(x => x.UserId == localUser.UserId);
            if (userGroupItem == null)
            {
                db.Counter_UserGroup.Add(new Counter_UserGroup() { UserId = localUser.UserId, GroupId = GroupId });
            }
            else
            {
                userGroupItem.GroupId = GroupId;
            }
            db.SaveChanges();
            return Json(new { status = "ok" }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetCounterDeliveryMethod(string name, string searchId)
        {
            var producers = db.CounerCabinetDeliveryMethod.Where(p => p.Name.ToLower().Contains(name.ToLower())).Select(p => new { name = p.Name, id = p.DeliveryMethodId });
            return Json(producers, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetProducer(string name, string searchId)
        {
            int[] cache = new int[0];
            try
            {
                cache = (int[])Session["search_result_" + searchId];
            }
            catch (Exception ex)
            { }
            var docs = db.Documents.Where(x => cache.Contains(x.DocumentId)).Where(x => x.ProducerId != null).Select(x => x.ProducerId.Value).Distinct();
            var producers = db.Producers.Where(p => docs.Contains(p.ProducerId) && p.Name.ToLower().Contains(name.ToLower()) || p.Code.ToLower().Contains(name.ToLower())).Select(p => new { name = p.Name, id = p.ProducerId });
            return Json(producers, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetCustomer(string name, string searchId)
        {
            int[] cache = new int[0];
            try
            {
                cache = (int[])Session["search_result_" + searchId];
            }
            catch (Exception ex)
            { }
            var docs = db.Documents.Where(x => cache.Contains(x.DocumentId)).Where(x => x.CustomerId != null).Select(x => x.CustomerId.Value).Distinct();
            var customers = db.Customers.Where(p => docs.Contains(p.CustomerId) && p.Name.ToLower().Contains(name.ToLower()) || p.Code.ToLower().Contains(name.ToLower())).Select(p => new { name = p.Name, id = p.CustomerId });
            return Json(customers, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetCustomerAll(string name)
        {
            var customers = db.Customers.Where(p => p.Name.ToLower().Contains(name.ToLower()) || p.Code.ToLower().Contains(name.ToLower())).Select(p => new { name = p.Name, id = p.CustomerId });
            return Json(customers, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetCustomerPSSR(string name)
        {
            var existsCounterId = db.Counter_PSSR_Customer.Select(x => x.CustomerId).Distinct().ToArray();
            var arrCustomers = db.Customers.Where(x => existsCounterId.Contains(x.CustomerId)).ToArray();
            var customers = arrCustomers.Where(p => p.Name.ToUpper().Contains(name)).Select(p => new { name = p.Name, id = p.Name });
            return Json(customers, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [UserActivityFilter]
        public JsonResult GetWOPssr(int DocumentId)
        {
            var doc = db.Documents.Single(p => p.DocumentId == DocumentId);

            return Json(doc, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetEmailPSSR(string name)
        {
            var emails = db.Counter_PSSR_Email
                                            .Where(p => p.Email.ToUpper().Contains(name))
                                            .Select(p => new { name = p.Email, id = p.Email })
                                            .Distinct()
                                            .ToList();
            return Json(emails, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetModel(string name, string searchId)
        {
            int[] cache = new int[0];
            try
            {
                cache = (int[])Session["search_result_" + searchId];
            }
            catch (Exception ex)
            { }
            var docs = db.Documents.Where(x => cache.Contains(x.DocumentId)).Where(x => x.ModelId != null).Select(x => x.ModelId.Value).Distinct();
            var models = db.Models.Where(p => docs.Contains(p.ModelId) && p.Name.ToLower().Contains(name.ToLower())).Select(p => new { name = p.Name, id = p.ModelId });
            return Json(models, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetDocumentNumber_ProjectExpenses(string name)
        {
            name = name.ToLower();
            var filterDocIdSECompleted = db.ServiceEngineer_List.Where(x => x.PreparingOfReport_StopDate != null).Select(x => x.DocumentId).ToArray(); // Завершенные наряды из SE
            var filterDocIdInCounter = db.Counter_List.Select(x => x.DocumentId).ToArray();
            var filterDocIdInCounter0 = db.Counter_List.Where(x => x.CounterStatusId == (int)CounterStatus.Start).Select(x => x.DocumentId).ToArray();
            var documents = db.Documents.Where(p => ((!filterDocIdSECompleted.Contains(p.DocumentId) && !filterDocIdInCounter.Contains(p.DocumentId))
                                                        || filterDocIdInCounter0.Contains(p.DocumentId))
                    && p.DocumentNumber.ToLower().Contains(name.ToLower())).Select(s => new { name = s.DocumentNumber, id = s.DocumentId });
            return Json(documents, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetDocumentNumber(string name, string searchId = "")
        {
            if (searchId.Length > 0)
            {
                int[] cache = new int[0];
                try
                {
                    cache = (int[])Session["search_result_" + searchId];
                }
                catch (Exception ex)
                { }
                var documents = db.Documents.Where(p => cache.Contains(p.DocumentId)
                    && p.DocumentNumber.ToLower().Contains(name.ToLower())).Select(s => new { name = s.DocumentNumber, id = s.DocumentId });
                return Json(documents, JsonRequestBehavior.AllowGet);
            }
            else
            {
                var documents = db.Documents.Where(p =>
                    p.DocumentNumber.ToLower().Contains(name.ToLower())).Select(s => new { name = s.DocumentNumber, id = s.DocumentId });
                return Json(documents, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public JsonResult GetMachinesSN(string name, string searchId)
        {
            int[] cache = new int[0];
            try
            {
                cache = (int[])Session["search_result_" + searchId];
            }
            catch (Exception ex)
            { }
            var documents = db.Documents.Where(p => cache.Contains(p.DocumentId) && p.MachinesSN.ToLower().Contains(name.ToLower())).GroupBy(g => new { g.MachinesSN }).Select(s => new { name = s.Key.MachinesSN, id = s.Key.MachinesSN });
            return Json(documents, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetComponentSN(string name, string searchId)
        {
            int[] cache = new int[0];
            try
            {
                cache = (int[])Session["search_result_" + searchId];
            }
            catch (Exception ex)
            { }
            var documents = db.Documents.Where(p => cache.Contains(p.DocumentId) && p.ComponentSN.ToLower().Contains(name.ToLower())).GroupBy(g => new { g.ComponentSN }).Select(s => new { name = s.Key.ComponentSN, id = s.Key.ComponentSN });
            return Json(documents, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetSmcsCode(string name, string searchId)
        {
            int[] cache = new int[0];
            try
            {
                cache = (int[])Session["search_result_" + searchId];
            }
            catch (Exception ex)
            { }

            var docs = db.Documents.Where(x => cache.Contains(x.DocumentId)).Where(x => x.SmcsCode != null && x.SmcsCode.Length > 0).Select(x => x.SmcsCode).Distinct();
            var comp = db.SMCSComponent.Where(x => docs.Contains(x.Code)).ToList();
            foreach (var item in comp)
            {
                item.Description = item.GetLocalized(x => x.Description, x => x.SMCSComponentID);
            }
            var result = comp
                            .Where(p => p.Description.ToLower().Contains(name.ToLower()))
                            .Select(p => new { name = p.Description, code = p.Code, id = p.Code });
            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetDivision(string name, string searchId)
        {
            int[] cache = new int[0];
            try
            {
                cache = (int[])Session["search_result_" + searchId];
            }
            catch (Exception ex)
            { }

            var result = db.Documents
                .Where(x => cache.Contains(x.DocumentId) && x.SegmentText.Contains(name))
                .Select(x => x.SegmentText)
                .Distinct()
                .Select(x => new
                {
                    name = x,
                    id = x
                })
                .Distinct()
                .ToArray();

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [UserActivityFilter]
        public JsonResult UploadedQuotation(int documentId, int quotationType)
        {
            string CostParts = "0";
            string CostWork = "0";
            string CostRecovery = "0";
            string CostTransportation = "0";
            string CostReman = "0";
            string CostRelativeOfTheNewNode = "0";
            int Status = 0;
            var fileName = "";
            try
            {
                fileName = Request.Files[0].FileName;
                HttpPostedFileBase file = Request.Files[0];
                //Save file content goes here

                if (file != null && file.ContentLength > 0)
                {
                    using (var package = new ExcelPackage(file.InputStream))
                    {
                        var workbook = package.Workbook;
                        var worksheet = workbook.Worksheets.First();
                        decimal nds = (decimal)1.12;
                        var isNDS = false;
                        if (worksheet.Cells["AA11"].Value != null)
                            isNDS = worksheet.Cells["AA11"].Value.ToString().IndexOf("НДС вкл", StringComparison.CurrentCultureIgnoreCase) > -1;
                        var col = "AA";
                        if (worksheet.Cells[col + "12"] != null && worksheet.Cells[col + "12"].Value != null && worksheet.Cells[col + "12"].Value.ToString().Trim().Length > 0)
                            try { CostParts = (Math.Round(Decimal.Parse(worksheet.Cells[col + "12"].Value.ToString()) / (isNDS ? nds : 1), 2)).ToString(); } catch (Exception ex) { }
                        if (worksheet.Cells[col + "15"] != null && worksheet.Cells[col + "15"].Value != null && worksheet.Cells[col + "15"].Value.ToString().Trim().Length > 0)
                            try { CostWork = (Math.Round(Decimal.Parse(worksheet.Cells[col + "15"].Value.ToString()) / (isNDS ? nds : 1), 2)).ToString(); } catch (Exception ex) { }
                        if (worksheet.Cells[col + "21"] != null && worksheet.Cells[col + "21"].Value != null && worksheet.Cells[col + "21"].Value.ToString().Trim().Length > 0)
                            try { CostRecovery = (Math.Round(Decimal.Parse(worksheet.Cells[col + "21"].Value.ToString()) / (isNDS ? nds : 1), 2)).ToString(); } catch (Exception ex) { }
                        if (worksheet.Cells[col + "24"] != null && worksheet.Cells[col + "24"].Value != null && worksheet.Cells[col + "24"].Value.ToString().Trim().Length > 0)
                            try { CostTransportation = (Math.Round(Decimal.Parse(worksheet.Cells[col + "24"].Value.ToString()) / (isNDS ? nds : 1), 2)).ToString(); } catch (Exception ex) { }
                        if (worksheet.Cells[col + "27"] != null && worksheet.Cells[col + "27"].Value != null && worksheet.Cells[col + "27"].Value.ToString().Trim().Length > 0)
                            try { CostReman = (Math.Round(Decimal.Parse(worksheet.Cells[col + "27"].Value.ToString()) / (isNDS ? nds : 1), 2)).ToString(); } catch (Exception ex) { }
                        if (worksheet.Cells[col + "30"] != null && worksheet.Cells[col + "30"].Value != null && worksheet.Cells[col + "30"].Value.ToString().Trim().Length > 0)
                            try { CostRelativeOfTheNewNode = (Math.Round(Decimal.Parse(worksheet.Cells[col + "30"].Value.ToString()) / (isNDS ? nds : 1), 2)).ToString(); } catch (Exception ex) { }

                        Status = 1;
                    }
                }
            }
            catch (Exception ex)
            {
                //CostParts = "";
                //CostWork = "";
                //CostRecovery = "";
                //CostTransportation = "";
                //CostReman = "";
                //CostRelativeOfTheNewNode = "";
            }
            var newFileName = "";
            if (quotationType == 1 && fileName.IndexOf("tk", StringComparison.OrdinalIgnoreCase) == -1)
                newFileName = System.IO.Path.GetFileNameWithoutExtension(fileName) + "_TK" + System.IO.Path.GetExtension(fileName);
            else if (quotationType == 2 && fileName.IndexOf("avia", StringComparison.OrdinalIgnoreCase) == -1)
                newFileName = System.IO.Path.GetFileNameWithoutExtension(fileName) + "_AVIA" + System.IO.Path.GetExtension(fileName);

            Upload(documentId, 17, newFileName);

            return Json(new
            {
                documentId = documentId,
                typeId = 17,
                quotationType = quotationType,
                CostParts = CostParts,
                CostWork = CostWork,
                CostRecovery = CostRecovery,
                CostTransportation = CostTransportation,
                CostReman = CostReman,
                CostRelativeOfTheNewNode = CostRelativeOfTheNewNode,
                Status = Status
            }, JsonRequestBehavior.AllowGet);
        }

        public JsonResult UploadedSignedQuotation(int documentId)
        {
            string CostParts = "";
            string CostWork = "";
            string CostRecovery = "";
            string CostTransportation = "";
            string CostReman = "";
            string CostRelativeOfTheNewNode = "";
            int Status = 0;
            var fileName = "";
            try
            {
                fileName = Request.Files[0].FileName;
                HttpPostedFileBase file = Request.Files[0];
                if (file != null && file.ContentLength > 0)
                {
                    using (var package = new ExcelPackage(file.InputStream))
                    {
                        var workbook = package.Workbook;
                        var worksheet = workbook.Worksheets.First();
                        var col = "AA";
                        decimal nds = (decimal)1.12;
                        var isNDS = false;
                        if (worksheet.Cells["AA11"].Value != null)
                            isNDS = worksheet.Cells["AA11"].Value.ToString().IndexOf("НДС вкл", StringComparison.CurrentCultureIgnoreCase) > -1;

                        if (worksheet.Cells[col + "12"] != null && worksheet.Cells[col + "12"].Value != null && worksheet.Cells[col + "12"].Value.ToString().Trim().Length > 0)
                            try { CostParts = (Math.Round(Decimal.Parse(worksheet.Cells[col + "12"].Value.ToString()) / (isNDS ? nds : 1), 2)).ToString(); } catch (Exception ex) { }
                        if (worksheet.Cells[col + "15"] != null && worksheet.Cells[col + "15"].Value != null && worksheet.Cells[col + "15"].Value.ToString().Trim().Length > 0)
                            try { CostWork = (Math.Round(Decimal.Parse(worksheet.Cells[col + "15"].Value.ToString()) / (isNDS ? nds : 1), 2)).ToString(); } catch (Exception ex) { }
                        if (worksheet.Cells[col + "21"] != null && worksheet.Cells[col + "21"].Value != null && worksheet.Cells[col + "21"].Value.ToString().Trim().Length > 0)
                            try { CostRecovery = (Math.Round(Decimal.Parse(worksheet.Cells[col + "21"].Value.ToString()) / (isNDS ? nds : 1), 2)).ToString(); } catch (Exception ex) { }
                        if (worksheet.Cells[col + "24"] != null && worksheet.Cells[col + "24"].Value != null && worksheet.Cells[col + "24"].Value.ToString().Trim().Length > 0)
                            try { CostTransportation = (Math.Round(Decimal.Parse(worksheet.Cells[col + "24"].Value.ToString()) / (isNDS ? nds : 1), 2)).ToString(); } catch (Exception ex) { }
                        if (worksheet.Cells[col + "27"] != null && worksheet.Cells[col + "27"].Value != null && worksheet.Cells[col + "27"].Value.ToString().Trim().Length > 0)
                            try { CostReman = (Math.Round(Decimal.Parse(worksheet.Cells[col + "27"].Value.ToString()) / (isNDS ? nds : 1), 2)).ToString(); } catch (Exception ex) { }
                        if (worksheet.Cells[col + "30"] != null && worksheet.Cells[col + "30"].Value != null && worksheet.Cells[col + "30"].Value.ToString().Trim().Length > 0)
                            try { CostRelativeOfTheNewNode = (Math.Round(Decimal.Parse(worksheet.Cells[col + "30"].Value.ToString()) / (isNDS ? nds : 1), 2)).ToString(); } catch (Exception ex) { }

                        Status = 1;
                    }
                }
            }
            catch (Exception ex)
            {
                //CostParts = "";
                //CostWork = "";
                //CostRecovery = "";
                //CostTransportation = "";
                //CostReman = "";
                //CostRelativeOfTheNewNode = "";
            }

            Upload(documentId, 24);

            return Json(new
            {
                documentId = documentId,
                typeId = 24,
                CostParts = CostParts,
                CostWork = CostWork,
                CostRecovery = CostRecovery,
                CostTransportation = CostTransportation,
                CostReman = CostReman,
                CostRelativeOfTheNewNode = CostRelativeOfTheNewNode,
                Status = Status
            }, JsonRequestBehavior.AllowGet);
        }

        public JsonResult UploadNotApplicable(int documentId, int typeId)
        {
            var upload = new Upload();
            upload.DocumentId = documentId;
            upload.TypeId = typeId;
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
            return Json(new { status = "ok", documentId = documentId, typeId = typeId }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [UserActivityFilter]
        public JsonResult Upload(int documentId, int typeId, string newFileName = "")
        {
            var appSetting = AppSettingService.AppSetting;
            bool thumb = false; int zoneId = 0;
            //var file = Request.Files[0];
            Response.ContentType = "text/plain";
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            string root = appSetting.Uploads.Uploads_UploadsFolder + "\\" + documentId + "\\" + typeId + "\\";
            if (thumb)
            {
                root = root + "Photo\\";
            }
            bool isExists = System.IO.Directory.Exists(root);
            if (!isExists)
                System.IO.Directory.CreateDirectory(root);

            for (int i = 0; i < Request.Files.Count; i++)
            {
                var file = Request.Files[i];
                FileInfo fi = new FileInfo(file.FileName);
                string ext = fi.Extension;
                var dateNow = DateTime.Now;
                Random rnd = new Random();
                int card = rnd.Next(9999);
                string fileName = String.Format("{0}_{1}-{2}" + ext, documentId, typeId, card);
                try
                {
                    file.SaveAs(root + fileName);
                }
                catch (Exception)
                {
                    card = rnd.Next(9999);
                    fileName = String.Format("{0}_{1}-{2}" + ext, documentId, typeId, card);
                    file.SaveAs(root + fileName);
                }
                if (thumb)
                {
                    if (!System.IO.Directory.Exists(root + "Thumb\\"))
                        System.IO.Directory.CreateDirectory(root + "Thumb\\");
                    Image image = Image.FromFile(root + fileName);
                    Image imageThumb = image.GetThumbnailImage(120, 100, null, IntPtr.Zero);
                    imageThumb.Save(root + "Thumb\\" + fileName);
                    image.Dispose();
                }

                var upload = new Upload();
                upload.DocumentId = documentId;
                upload.TypeId = typeId;
                upload.Extension = ext;
                upload.Name = newFileName.Length > 0 ? newFileName : Path.GetFileName(file.FileName);
                upload.Path = root + fileName;
                upload.SizeKB = file.InputStream.Length / 1024;
                upload.DateUpload = dateNow;
                upload.ZoneId = zoneId;
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
            return Json(new { documentId = documentId, typeId = typeId }, JsonRequestBehavior.AllowGet);

            //return Json(new { documentId = documentId, typeId = typeId, name = fileName, originalName = Path.GetFileName(file.FileName), extension = ext, saveDate = string.Format("{0:dd.MM.yyyy}", dateNow), size = file.InputStream.Length / 1024 }, JsonRequestBehavior.AllowGet);
        }

        public JsonResult RemoveUpload(int uploadId)
        {
            var item = db.Uploads.SingleOrDefault(x => x.UploadId == uploadId);
            if (item != null)
            {
                var documentId = item.DocumentId;
                var typeId = item.TypeId;
                db.Uploads.Remove(item);
                db.SaveChanges();
                return Json(new { status = "ok", documentId = documentId, typeId = typeId, count = db.Uploads.Count(x => x.DocumentId == documentId && x.TypeId == typeId) }, JsonRequestBehavior.AllowGet);
            }
            else
                return Json(new { status = "notexists" }, JsonRequestBehavior.AllowGet);
        }

        public string GetUploadsList(int typeId, int id = 0, int zoneId = 0, int documentId = 0)
        {
            var appSetting = AppSettingService.AppSetting;
            var result = "";
            if (documentId == 0)
            {
                try
                {
                    var uploadDocument = db.Uploads.FirstOrDefault(x => x.ReferenceId == id && x.ZoneId == zoneId);
                    if (uploadDocument != null)
                        documentId = uploadDocument.DocumentId;
                }
                catch (Exception)
                {
                    //
                }
            }
            bool isPermitted = PermissionCheck(PermissionEnum.COUNTER_CABINET_RW);

            var upload =
                db.Uploads.Where(
                    c =>
                        (c.ReferenceId == id && c.TypeId == typeId && c.ZoneId == zoneId) ||
                        (documentId > 0 && c.DocumentId == documentId && c.TypeId == typeId && c.ZoneId == zoneId));
            //<ul class="resultUploadedFile"><li><a href="/Home/DownloadFile?uploadId=88930">7487191 Defect list.xlsx</a> - 25.12.2018 (Abay YERKIN) - <span style="color: red; cursor: pointer" onclick="RemovedFile(29857,1,88930,'True');"> удалить</span></li></ul>
            foreach (var item in upload)
            {
                if (result.Length > 0)
                    result += "<br>";
                result = result + "<li><a href='" + appSetting.ProjectUrl.WorkOrderHistoryPath + "/Home/DownloadFile?uploadId=" + item.UploadId.ToString() +
                        "' target='_blank'>" + item.Name + "</a> - " + (item.DateUpload != null ? item.DateUpload.Value.ToString("dd.MM.yyyy") : "") + " (" + item.UserName + ") - <span style=\"color: red; cursor: pointer\"" + (isPermitted == true ? "onclick=\"RemovedFile(" + item.UploadId.ToString() + "); \"> " : " cdoms_perm=\"COUNTER_CABINET_RW\" >") + StandartLibrary.Lang.Resources.Delete_5574 + "</span></li>";
            }
            return "<ul class=\"resultUploadedFile\">" + result + "</ul>";
        }

        [HttpPost]
        public JsonResult GetCounterItem(int documentId)
        {
            var item = db.Counter_List.Single(x => x.DocumentId == documentId);
            return Json(item, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetPavilion(string name, string searchId)
        {
            int[] cache = new int[0];
            try
            {
                cache = (int[])Session["search_result_" + searchId];
            }
            catch (Exception ex)
            { }
    List<int> docPavilion = (from one in db.Documents
                         join two in db.DocumentArea on one.DocumentId equals two.DocumentId into sResultDocumentArea
                         where sResultDocumentArea.Count() > 0
                         join three in db.Areas on sResultDocumentArea.OrderByDescending(x => x.DocumentAreaId).FirstOrDefault().AreaId equals three.AreaId into sAreas
                         where sAreas.Count() > 0
                         join four in db.Pavilion on sAreas.OrderByDescending(x => x.PavilionId).FirstOrDefault().PavilionId equals four.PavilionId
                         select four.PavilionId).Distinct().ToList();


            var models = db.Pavilion.Where(p => docPavilion.Contains(p.PavilionId) && p.Name.ToLower().Contains(name.ToLower())).Select(p => new { name = p.Name, id = p.PavilionId });
            return Json(models, JsonRequestBehavior.AllowGet);
        }
        //HKaya
        [HttpGet]
        public JsonResult GetGroup(string name, string searchId)
        {
            int[] cache = new int[0];
            try
            {
                cache = (int[])Session["search_result_" + searchId];
            }
            catch (Exception ex)
            { }
            var docs = db.ReceptionItem .Where(x => cache.Contains(x.DocumentId)).Where(x => x.GroupId != null).Select(x => x.GroupId.Value).Distinct();
            var groups = db.Group.Where(p => docs.Contains(p.GroupId) && p.Name.ToLower().Contains(name.ToLower())).Select(p => new { name = p.Name, id = p.GroupId });
            return Json(groups, JsonRequestBehavior.AllowGet);
        }
    }
}