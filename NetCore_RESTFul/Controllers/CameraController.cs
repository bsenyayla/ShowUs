using CRCAPI.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StandartLibrary.Models.ViewModels.Common;
using StandartLibrary.Models.ViewModels.Request;
using System.Net.Http;

namespace Crcapi.Controllers
{
    [Authorize(AuthenticationSchemes = "BasicAuthentication")]
    [Route("api/[controller]")]
    [ApiController]
    public class CameraController : Controller
    {
        private readonly IServiceProcessor serviceProcessor;
        private readonly ICameraService cameraService;

        public CameraController(IServiceProcessor serviceProcessor, ICameraService cameraService)
        {
            this.serviceProcessor = serviceProcessor;
            this.cameraService = cameraService;
        }

        [HttpPost("snapshot")]
        public JsonResult GetSnapshot(Payload<SnapshotRequest> request)
        {
            var response = serviceProcessor.Call(cameraService.GetSnapshot, request.Model);
            return Json(response.Data.ToString().Replace('/', '_').Replace('+', '|'));
        }

        [HttpPost("mjpeg")]
        public JsonResult GetMjpeg(Payload<CameraRequest> request)
        {
            var response = serviceProcessor.Call(cameraService.GetMjpeg, request.Model);
            return Json(response.Data.ToString().Replace('/', '_').Replace('+', '|'));
        }

        [HttpPost("h264")]
        public JsonResult GetH264(Payload<CameraRequest> request)
        {
            var response = serviceProcessor.Call(cameraService.GetH264, request.Model);
            return Json(response.Data.ToString().Replace('/', '_').Replace('+', '|'));
        }
    }
}