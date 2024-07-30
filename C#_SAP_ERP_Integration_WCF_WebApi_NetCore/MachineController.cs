using System.Configuration;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Description;
using AutoMapper;
using RestSharp;
using Sniper.Api.Authorization;
using Sniper.Api.BorusanService;
using Sniper.Api.Util.Cache;
using Sniper.Api.Util.Log;
using Sniper.Api.Util.WebService;
using Sniper.Core.Models.Common;
using Sniper.Core.Models.Machine;

namespace Sniper.Api.Controllers
{
#if(!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif
    [RoutePrefix("sniperapp/machine")]
    public class MachineController : ApiController
    {
        private readonly WsClient _client;
        private readonly IRestClient _restClient;
        private readonly LogUtil _log;
        public MachineController()
        {
            _client = new WsClient();
            _restClient = new RestClient(ConfigurationManager.AppSettings["CmsApiUrlBase"]);
            _log = new LogUtil(GetType());
        }

        [Route("search/{userName}/{language}/{productId}")]
        [HttpGet]
        [ResponseType(typeof(MachineModel))]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Short)]
        public HttpResponseMessage SearchMachine([FromUri]string userName, [FromUri]string language, [FromUri]string productId)
        {
            //Get the machine image from CMS (first image)
            var imageRequest = new RestRequest("/machine/getmachineimage?languageCode=" + language + "&path=" + productId + "&cc=" + AuthUtil.GetUserCountry(Request));

            //Update: No more languageParameter for sap service
            var response = _client.MakeRequest(c => c.ZXX_FM_ENVANTER(new ZXX_FM_ENVANTERRequest
            {
                ZXX_FM_ENVANTER = new ZXX_FM_ENVANTER
                {
                    IV_PRODH = productId,
                    IV_USER_NAME = userName.ToUpper()
                }
            }));

            var model = Mapper.Map<ResponseModel<MachineModel>>(response);

            var imageResponse = _restClient.Get(imageRequest);

            if (imageResponse.StatusCode != HttpStatusCode.NotFound && string.IsNullOrEmpty(imageResponse.ErrorMessage))
            {
                model.Data.Image = Mapper.Map<ResponseModel<MachineImageModel>>(imageResponse).Data.ImagePath;
            }

            return Request.CreateResponse(HttpStatusCode.OK, model);

        }


        [Route("image/{language}/{productId}")]
        [HttpGet]
        public HttpResponseMessage GetMachineImage([FromUri]string language, [FromUri]string productId)
        {
            //Get the machine image from CMS (first image)
            var request = new RestRequest("/machine/getmachineimage?languageCode=" + language + "&path=" + productId + "&cc=" + AuthUtil.GetUserCountry(Request));

            var response = _restClient.Get(request);

            var model = Mapper.Map<ResponseModel<MachineImageModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);

        }
    }
}