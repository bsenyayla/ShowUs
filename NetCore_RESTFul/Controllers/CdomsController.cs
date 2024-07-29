using CRCAPI.Services.Filters;
using CRCAPI.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using StandartLibrary.Models.ViewModels;
using StandartLibrary.Models.ViewModels.Common;
using StandartLibrary.Models.ViewModels.Request;

namespace Crcapi.Controllers
{
    [Authorize(AuthenticationSchemes = "BasicAuthentication")]
    [Route("api/[controller]")]
    [ApiController]
    public class CdomsController : Controller
    {
        private readonly IServiceProcessor serviceProcessor;
        private readonly IAttachmentService attacthmentService;
        private readonly IAreaService areaService;
        private readonly IProcessService statusService;
        private readonly IChecklistService checklistService;
        private readonly IMetricsService metricsService;
        private readonly IHttpContextAccessor context;
        private readonly ICrmService crmService;

        public CdomsController(IServiceProcessor serviceProcessor, IAttachmentService attacthmentService, IAreaService areaService,
            IProcessService statusService, IChecklistService checklistService, IMetricsService metricsService, IHttpContextAccessor context, ICrmService crmService)
        {
            this.serviceProcessor = serviceProcessor;
            this.attacthmentService = attacthmentService;
            this.areaService = areaService;
            this.statusService = statusService;
            this.checklistService = checklistService;
            this.metricsService = metricsService;
            this.context = context;
            this.crmService = crmService;
            this.context.HttpContext.Response.Headers.Add("Content-Type", "application/json");
            this.context.HttpContext.Response.Headers.Add("Accept-Charset", "utf-8");
        }


        [HttpPost("getStatus")]
        public JsonResult GetWorkOrderStatus(Payload<WorkOrderStatusRequest> request)
        {
            var response = serviceProcessor.Call(statusService.GetWorkOrderStatus, request.Model);
            return Json(response);
        }


        [HttpPost("getStatusList")]
        public JsonResult GetWorkOrderStatusList(Payload<WorkOrderStatusListRequest> request)
        {
            var response = serviceProcessor.Call(statusService.GetWorkOrderStatusList, request.Model);
            return Json(response);
        }

        [AllowAnonymous]
        [HttpPost("getWorkOrderDetail")]
        public JsonResult GetWorkOrderDetail(Payload<WorkOrderInfosRequest> request)
        {
            var response = serviceProcessor.Call(crmService.GetWorkOrderDetailsByCutomerNo, request.Model.CustomerCode, request.Model.DocumentIds);
            return Json(response);
        }

        [HttpPost("getWorkOrderAttachment")]
        public JsonResult GetWorkOrderAttachemnt(Payload<WorkOrderInfoAttachmentRequest> request)
        {
            var response = serviceProcessor.Call(attacthmentService.GetAttachmentContent, request.Model.AttachmentId);
            return Json(response);
        }

        [HttpPost("addAttachment")]
        [ServiceFilter(typeof(UserActivityFilter))]
        public JsonResult AddAttachment(Payload<Shell<AddAttachmentRequest>> request)
        {
            var response = serviceProcessor.Call(attacthmentService.AddAttachment, request.Model.Data);
            return Json(response);
        }


        [HttpPost("getAttachments")]
        [ServiceFilter(typeof(UserActivityFilter))]
        public JsonResult GetAttachments(Payload<Shell<GetAttachmentListRequest>> request)
        {
            var response = serviceProcessor.Call(attacthmentService.GetAttachments, request.Model.Data);
            return Json(response);
        }


        [HttpPost("getAttachment")]
        [ServiceFilter(typeof(UserActivityFilter))]
        public JsonResult GetAttachment(Payload<Shell<GetAttachmentRequest>> request)
        {
            var response = serviceProcessor.Call(attacthmentService.GetAttachment, request.Model.Data);
            return Json(response);
        }


        [HttpPost("getAreaList")]
        public JsonResult GetAreaList(Payload<Shell> request)
        {
            var response = serviceProcessor.Call(areaService.GetAreaList);
            return Json(response);
        }


        [HttpPost("updateStatus")]
        [ServiceFilter(typeof(UserActivityFilter))]
        public JsonResult UpdateStatus(Payload<Shell<UpdateStatusRequest>> request)
        {
            var response = serviceProcessor.Call(statusService.UpdateStatus, request.Model.Data, request.Model.TransactionId);
            return Json(response);
        }


        [HttpPost("checkForSubmitedCheckLists")]
        public JsonResult CheckForSubmitedCheckLists(Payload<Shell<CheckForSubmitedCheckListRequest>> request)
        {
            var response = serviceProcessor.Call(checklistService.CheckForSubmitedCheckLists, request.Model.Data);
            return Json(response);
        }

        [HttpPost("cdomsMetrics")]
        public JsonResult cdomsMetrics(MetricsRequest request)
        {
            var response = serviceProcessor.Call(metricsService.GetStat, request);
            return Json(response);
        }
    }
}