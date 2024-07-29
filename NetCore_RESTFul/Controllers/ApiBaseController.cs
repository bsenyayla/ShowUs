using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json.Serialization;
using StandartLibrary.Models.ViewModels.Common;
using System.Globalization;
using System.Text.Json;

namespace Crcapi.Controllers
{
    public class ApiBaseController : Controller
    {
        public override JsonResult Json(object data = null)
        {
            var jsonSettings = new JSONSettings(CultureInfo.GetCultureInfo("tr")).Settings;
            jsonSettings.ContractResolver = new CamelCasePropertyNamesContractResolver();
            return Json(data, jsonSettings);
        }

        public string ToJson<T>(T data)
        {
            return JsonSerializer.Serialize<T>(data);
        }

    }
}