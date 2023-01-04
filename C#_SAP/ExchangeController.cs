using System;
using System.Configuration;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Xml;
using System.Xml.Serialization;
using RestSharp;
using Sniper.Api.Authorization;
using Sniper.Api.Models.Xml;
using Sniper.Api.Util.Cache;
using Sniper.Api.Util.Log;
using Sniper.Core.Models.Common;
using ResponseStatus = Sniper.Core.Models.Common.ResponseStatus;

namespace Sniper.Api.Controllers
{
#if(!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif

    [RoutePrefix("sniperapp/exchange")]
    public class ExchangeController : ApiController
    {
        private readonly IRestClient _restClient;
        private readonly LogUtil _log;

        public ExchangeController()
        {
            _restClient = new RestClient(ConfigurationManager.AppSettings["ExchangeUrl"]);
            _log = new LogUtil(GetType());
        }

        [Route]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Medium)]
        public HttpResponseMessage Get()
        {
            var model = new ResponseModel<ExchangeModel>();
            var xmlString = _restClient.Get(new RestRequest()).Content;
            var message = new HttpResponseMessage(HttpStatusCode.OK);

            try
            {
                using (var xmlReader = XmlReader.Create(new StringReader(xmlString)))
                {
                    model.Data = (ExchangeModel)new XmlSerializer(typeof(ExchangeModel)).Deserialize(xmlReader);
                    model.Status = ResponseStatus.Success.ToString("f");
                    model.StatusCode = (int)ResponseStatus.Success;
                    message.Content = new ObjectContent<ResponseModel<ExchangeModel>>(model,
                        new JsonMediaTypeFormatter());
                }
            }
            catch (Exception ex)
            {
                _log.Error("ExchangeControlller error", ex);
                model.Data = null;
                model.Status = ResponseStatus.CmsError.ToString("f");
                model.StatusCode = (int)ResponseStatus.CmsError;
                message.Content = new ObjectContent<ResponseModel<ExchangeModel>>(model, new JsonMediaTypeFormatter());
            }

            return message;
        }
    }
}
