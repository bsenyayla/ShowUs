using System.Configuration;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using AutoMapper;
using RestSharp;
using Sniper.Core.Models.Common;
using Sniper.Core.Models.Configuration;
using Sniper.Core.Utils;
using Sniper.Core.Models;
using System.Collections.Generic;
using Sniper.Api.Authorization;
using Sniper.Api.Util.Cache;
using ResponseStatus = Sniper.Core.Models.Common.ResponseStatus;
using Sniper.Core.SAPRest.FieldModels;
using Sniper.Core.SAPRest;
using System.Linq;
using System.Web.Http.Description;

namespace Sniper.Api.Controllers
{
#if(!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif
    [RoutePrefix("sniperapp/configuration")]
    public class ConfigurationController : ApiController
    {
        private readonly IRestClient _restClient;

        private readonly Dictionary<string, string> _relatedpersonfields;

        public ConfigurationController()
        {
            _restClient = new RestClient(ConfigurationManager.AppSettings["CmsApiUrlBase"]);
            _relatedpersonfields = SapNameManager.GetSapNames(typeof(RelatedPersonFieldModel));
        }

        [Route]
        public HttpResponseMessage Get()
        {
            var request = new RestRequest("/configuration/getall");
            var response = _restClient.Get(request);
            var model = Mapper.Map<ResponseModel<ConfigurationModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);

        }

        [Route("usersections/{userGroup}")]
        public HttpResponseMessage GetUserSections(string userGroup)
        {
            var request = new RestRequest("/configuration/getusersections?userGroup=" + userGroup + "&cc=" + AuthUtil.GetUserCountry(Request));
            var response = _restClient.Get(request);
            var model = Mapper.Map<ResponseModel<UserSectionModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("fields/relatedperson/{username}/{field}")]
        [HttpGet]
        [ResponseType(typeof(FieldNameModel))]

        //NOCACHE because user can be using in english or turkish
        public HttpResponseMessage GetRelatedPersonFieldNames([FromUri] string username, [FromUri] string field)
        {
            var model = SAPRestService.GetFieldName(username.ToUpper(), AuthUtil.GetUserDataDefault(Request).MobileLanguageShort, _relatedpersonfields[field]);
            FieldNameModel res = new FieldNameModel();
            
            ///  Uygulama ekibi modelinin çalışma şeklinden dolayı backendde key value değişikliği yapıldı...  
            ///  22.10.2019 foskan not best practice
            res.Values = model.Select(x => new FieldNameItemModel { Name = x.VALUE, Value = x.KEY }).ToList();

            return Request.CreateResponse(HttpStatusCode.OK, res);
        }

        /// <summary>
        /// </summary>
        /// <param name="id">Searching id</param>
        /// <param name="type">Csv type</param>
        /// <returns></returns>
        [Route("parameters/{id}/{type}")]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Short)]
        public HttpResponseMessage GetCalculationParameters(string id, string type)
        {
            try
            {
                var calculationParameters = SearchParameters(System.Web.HttpUtility.UrlDecode(id), type);

                return calculationParameters.IsEmpty() ?
                    NoCalculationParametersFound(id) :
                    CalculationParametersFound(calculationParameters);
            }
            catch
            {
                return ErrorReadingCalculationParametersFile();
            }
        }


        [Route("parameterkeys/{type}")]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Short)]
        public HttpResponseMessage GetCalculationParameterKeys(string type)
        {
            try
            {
                var calculationParametersMedia = GetCalculationParametersMediaFromCms(type);
                var calculationParameterKeys = new CalculationParameterKeysModel();
                var calculationParametersParser = new CalculationParametersParser(calculationParametersMedia.Path, ConfigurationManager.AppSettings["CalculationParametersCSVSeparator"][0]);
                calculationParameterKeys.ParameterKeys = calculationParametersParser.ListOfKeys();


                var response = Request.CreateResponse(HttpStatusCode.OK, new ResponseModel<CalculationParameterKeysModel>
                {
                    Data = calculationParameterKeys
                });

                return response;
            }
            catch
            {
                return ErrorReadingCalculationParametersFile();
            }
        }

        [Route("parameters/{type}")]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Short)]
        public HttpResponseMessage GetAllTable(string type)
        {
            try
            {
                var file = GetCalculationParametersMediaFromCms(type);
                var tableModel = new CalculationTableModel();
                var calculationParametersParser = new CalculationParametersParser(file.Path, ConfigurationManager.AppSettings["CalculationParametersCSVSeparator"][0]);

                tableModel.Keys = calculationParametersParser.ListOfKeys();

                foreach (var key in tableModel.Keys)
                {
                    var calculationParameters = SearchParameters(System.Web.HttpUtility.UrlDecode(key), type);

                    tableModel.Table.Add(calculationParameters.Parameters);
                }

     
                return Request.CreateResponse(HttpStatusCode.OK, new ResponseModel<CalculationTableModel>
                {
                    Data = tableModel,
                    Status = ResponseStatus.Success.ToString("f"),
                    StatusCode = (int)ResponseStatus.Success
                });
            }
            catch
            {
                return ErrorReadingCalculationParametersFile();
            }
        }


        private CalculationParametersModel SearchParameters(string id, string type)
        {
            var calculationParametersMedia = GetCalculationParametersMediaFromCms(type);
            var calculationParameters = new CalculationParametersModel();
            var calculationParametersParser = new CalculationParametersParser(calculationParametersMedia.Path, ConfigurationManager.AppSettings["CalculationParametersCSVSeparator"][0]);
            calculationParameters.Parameters = calculationParametersParser.FindCalculationParameters(id);
            return calculationParameters;
        }


        private MediaModel GetCalculationParametersMediaFromCms(string type)
        {
            var cmsRequest = new RestRequest("/configuration/getcalculationparameters?type=" + type);

            var cmsResponse = _restClient.Get(cmsRequest);

            return Mapper.Map<ResponseModel<MediaModel>>(cmsResponse).Data;
        }

        private HttpResponseMessage CalculationParametersFound(CalculationParametersModel calculationParameters)
        {
            return Request.CreateResponse(HttpStatusCode.OK, new ResponseModel<CalculationParametersModel>
            {
                Data = calculationParameters
            });
        }



        private HttpResponseMessage NoCalculationParametersFound(string id)
        {
            return Request.CreateResponse(HttpStatusCode.NotFound, new ResponseModel<ErrorModel>
            {
                StatusCode = (int)ResponseStatus.Success,
                Status = ResponseStatus.Success.ToString("f"),
                Messages = new List<string> { "No parameters found for model id " + id }
            });
        }

        private HttpResponseMessage ErrorReadingCalculationParametersFile()
        {
            return Request.CreateResponse(HttpStatusCode.InternalServerError, new ResponseModel<ErrorModel>()
            {
                StatusCode = (int)ResponseStatus.CmsError,
                Status = ResponseStatus.CmsError.ToString("f"),
                Messages = new List<string> { "error reading calculation parameters file" }
            });
        }
    }
}
