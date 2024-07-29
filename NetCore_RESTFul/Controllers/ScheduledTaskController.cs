using CRCAPI.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Crcapi.Controllers
{
    [Authorize(AuthenticationSchemes = "BasicAuthentication")]
    [Route("api/[controller]")]
    [ApiController]
    public class ScheduledTaskController : Controller
    {
        private readonly IServiceProcessor serviceProcessor;
        private readonly IUserService userService;
        private readonly IMailQueueService mailQueueService;
        private readonly IPartManagementService partManagementService;
        private readonly IDocumentService documentService;
        private readonly IProcessService processService;
        private readonly ICrmService crmService;
        private readonly ICrcRequestService crcRequestService;

        public ScheduledTaskController(IServiceProcessor serviceProcessor, IUserService userService,
            IMailQueueService mailQueueService,
            IPartManagementService partManagementService,
            IDocumentService documentService, IProcessService processService, ICrmService crmService, ICrcRequestService crcRequestService)
        {
            this.serviceProcessor = serviceProcessor;
            this.userService = userService;
            this.mailQueueService = mailQueueService;
            this.partManagementService = partManagementService;
            this.documentService = documentService;
            this.processService = processService;
            this.crmService = crmService;
            this.crcRequestService = crcRequestService;
        }

        [HttpPost("SynchronizeTechnicians")]
        public JsonResult SynchronizeTechnicians()
        {
            var resp = serviceProcessor.Call(userService.SynchronizeTechnicians);
            return Json(resp);
        }

        [HttpPost("CRCDocumentAttachment")]
        public JsonResult CRCDocumentAttachment()
        {
            var resp = serviceProcessor.Call(crmService.AddCRCDocumentAttacments);
            return Json(resp);
        }

        [HttpPost("SendMail")]
        public ActionResult SendMail()
        {
            var resp = serviceProcessor.Call(mailQueueService.SendMail);
            return Json(resp);
        }

        [HttpPost("SendMailByMailQueueId")]
        public ActionResult SendMailByMailQueueId(int mailQueueId)
        {
            var resp = serviceProcessor.Call(mailQueueService.SendMailByMailQueueId, mailQueueId);
            return Json(resp);
        }

        [HttpPost("ViewMailByMailQueueId")]
        public ActionResult ViewMailByMailQueueId(int mailQueueId)
        {
            var resp = serviceProcessor.Call(mailQueueService.ViewMailByMailQueueId, mailQueueId);
            return Json(resp);
        }

        [HttpPost("GetPartStatus")]
        public JsonResult GetPartStatus()
        {
            var resp = serviceProcessor.Call(partManagementService.GetParts, string.Empty);
            return Json(resp);
        }

        [HttpPost("UpdateDocuments")]
        public JsonResult UpdateDocuments()
        {
            var resp = serviceProcessor.Call(documentService.UpdateDocuments);
            return Json(resp);
        }

        [HttpPost("UpdateDispatchedDocuments")]
        public JsonResult UpdateDispatchedDocuments()
        {
            var resp = serviceProcessor.Call(documentService.UpdateDispatchedDocuments);
            return Json(resp);
        }

        [HttpPost("RetryFailedProcesses")]
        public JsonResult RetryFailedProcesses()
        {
            var resp = serviceProcessor.Call(processService.RetryFailedProcesses);
            return Json(resp);
        }

        [HttpPost("UpdateQuotation")]
        public JsonResult GetQuotation()
        {
            var resp = serviceProcessor.Call(crmService.UpdateZsrtQuotation);
            return Json(resp);
        }

        [HttpPost("CrcRequestSendMailForComponentReceiveDate")]
        public JsonResult CrcRequestSendMailForComponentReceiveDate()
        {
            var resp = crcRequestService.CrcRequestSendMailForComponentReceiveDate();
            return Json(resp);
        }
    }
}