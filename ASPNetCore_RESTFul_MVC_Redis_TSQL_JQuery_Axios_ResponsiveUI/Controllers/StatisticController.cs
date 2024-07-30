using CRCAPI.Services.Filters;
using CRCAPI.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using StandartLibrary.Models.ViewModels;
using StandartLibrary.Models.ViewModels.Common;
using StandartLibrary.Models.ViewModels.Crcms;
using StandartLibrary.Models.ViewModels.Request;
using System;
using System.Collections.Generic;

namespace CRCAPI.Controllers
{
    [Authorize(AuthenticationSchemes = "BasicAuthentication")]
    [Route("api/[controller]")]
    [ApiController]
    public class StatisticController : Controller
    {
        //private readonly IServiceProcessor serviceProcessor;
        //private readonly IAttachmentService attacthmentService;
        //private readonly IAreaService areaService;
        //private readonly IProcessService statusService;
        //private readonly IChecklistService checklistService;
        //private readonly IMetricsService metricsService;
        private readonly IHttpContextAccessor context;
        private readonly IStatisticService statisticService;

        public StatisticController(IStatisticService statisticProcessor, IHttpContextAccessor context) {
            this.statisticService = statisticProcessor;
            this.context = context;
            this.context.HttpContext.Response.Headers.Add("Content-Type", "application/json");
            this.context.HttpContext.Response.Headers.Add("Accept-Charset", "utf-8");
        }

        /*
            Başlangıç tarihi :
            bitiş tarihi :
            Lokasyon : gebze , ankara
         */
        //Rpt  toplam komponent sayısı
        [HttpPost("GetTotalNumberOfComponents")]
        public JsonResult GetTotalNumberOfComponents(StatisticRequest req) {
            return Json(statisticService.GetTotalComponentData(req));
        }

        [HttpPost("GetInputGraphData")]
        public JsonResult GetInputGraphData(StatisticRequest req) {
            return Json(statisticService.GetInput(req));
        }

        [HttpPost("GetOutputGraphData")]
        public JsonResult GetOutputGraphData(StatisticRequest req) {
            return Json(statisticService.GetOutput(req));
        }

        [HttpPost("GetProcessBasedGraphData")]
        public JsonResult GetProcessBasedGraphData(StatisticRequest req) {
            return Json(statisticService.GetProcessBased(req));
        }

        
        [HttpPost("GetFinancialGraphData")]
        public JsonResult GetFinancialGraphData(StatisticRequest req) {
            return Json(statisticService.GetFinancialStatus(req));
        }

        
        //Rpt  GetTatGraphData
        [HttpPost("GetTatGraphData")]
        public JsonResult GetTatGraphData(StatisticRequest req) {
            return Json(statisticService.GetTatData(req));
        }

        //Rpt  GetCRCRequestData
        [HttpPost("GetCRCRequestData")]
        public JsonResult GetCRCRequestData(StatisticRequest req) {
            return Json(statisticService.GetCRCRequestCount(req));
        }

        //Rpt  Capacity
        [HttpPost("GetCapacityData")]
        public JsonResult GetCapacityData(StatisticRequest req) {
            CapacityGraphData rData = statisticService.GetCapacityOccupancyData(req);
            return Json(rData);
        }



        [HttpPost("testMetrics")]
        public JsonResult testMetrics(Payload<string> request) {
            ServiceResponse retVal = new ServiceResponse();
            StatisticView dataModel = new StatisticView();
            
            StandartLibrary.Models.ViewModels.Request.StatisticRequest req = new StatisticRequest();
            req.BeginDate = DateTime.Now;
            req.EndDate = DateTime.Now.AddDays(-120);
            //var grapDataGroup = statisticService.GetTotalComponentCountForComponentGroup(req);
            //var grapDataSegment = statisticService.GetTotalComponentCountForSegment(req);
            //dataModel.TotalNumberOfComponentsGraphsForGroup = grapDataGroup;
            //dataModel.TotalNumberOfComponentsGraphsForSegment = grapDataSegment;

            retVal.Data = dataModel;
            retVal.Message = "çalışıyor....";
            return Json(retVal);
        }


    }
}

