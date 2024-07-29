using System.Net;
using System.Net.Http;
using System.Web.Http;
using Sniper.Core.Models.Common;
using System.Web.Http.Description;
using Sniper.Core.Models.MachineSelection;
using RestSharp;
using System.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.Linq;
using Sniper.Api.Authorization;
using System.Threading.Tasks;
using System.Net.Http.Headers;
using System.IO;

namespace Sniper.Api.Controllers
{
#if (!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif
    [RoutePrefix("sniperapp/machineselection")]
    public class MachineSelectionController : ApiController
    {
        [Route("calculate")]
        [HttpPost]
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage CalculateParameter([FromBody] MachineRequest request)
        {
            if (!ModelState.IsValid)
                return Request.CreateResponse(HttpStatusCode.BadRequest);

            MachineSelectionResult res = new MachineSelectionResult(request);

            ResponseModel<MachineSelectionResponse> response = new ResponseModel<MachineSelectionResponse>();
            response.Status = Core.Models.Common.ResponseStatus.Success.ToString("f");
            response.StatusCode = (int)Core.Models.Common.ResponseStatus.Success;
            response.Data = res.CalculateParams();

            return Request.CreateResponse(HttpStatusCode.OK, response);
        }

        [Route("parameters")]
        [HttpGet]
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage GetParameters()
        {
            var restClient = new RestClient(ConfigurationManager.AppSettings["CmsApiUrlBase"]);
            var linkreq = new RestRequest("/configuration/getmachinewizardconfig");
            var linkresponse = restClient.Execute(linkreq);

            ResponseModel<MachineSelectionParameters> response = new ResponseModel<MachineSelectionParameters>();
            response.Status = Core.Models.Common.ResponseStatus.Success.ToString("f");
            response.StatusCode = (int)Core.Models.Common.ResponseStatus.Success;
            response.Data = JsonConvert.DeserializeObject<MachineSelectionParameters>(linkresponse.Content);

            return Request.CreateResponse(HttpStatusCode.OK, response);
        }

        [Route("model/{brand}/{modelName}")]
        [HttpGet]
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage ComparisonData([FromUri] string brand, [FromUri] string modelName)
        {
            if (!ModelState.IsValid)
                return Request.CreateResponse(HttpStatusCode.BadRequest);

            var restClient = new RestClient(ConfigurationManager.AppSettings["CmsApiUrlBase"]);
            var linkreq = new RestRequest("/configuration/getmachinecompariondata");
            var linkresponse = restClient.Execute(linkreq);

            ResponseModel<List<MachineComparisonResult>> response = new ResponseModel<List<MachineComparisonResult>>();

            response.Status = Core.Models.Common.ResponseStatus.Success.ToString("f");
            response.StatusCode = (int)Core.Models.Common.ResponseStatus.Success;
            response.Data = JsonConvert.DeserializeObject<List<MachineComparisonResult>>(linkresponse.Content).Where(x => x.Brand == brand && x.Model == modelName).ToList();

            return Request.CreateResponse(HttpStatusCode.OK, response);
        }

        [Route("comparisondata")]
        [HttpGet]
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage DownloadFile()
        {
            var restClient = new RestClient(ConfigurationManager.AppSettings["CmsApiUrlBase"]);
            var linkreq = new RestRequest("/configuration/getmachinemodeldata");
            var linkresponse = restClient.Execute(linkreq);

            var result = Request.CreateResponse(HttpStatusCode.OK);

            result.Content = new StreamContent(new MemoryStream(JsonConvert.DeserializeObject<byte[]>(linkresponse.Content)));
            result.Content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
            result.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
            {
                FileName = "ComparisonData.xlsx"
            };

            return result;
        }
    }
}
