using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using System.Web.Http.Description;
using AutoMapper;
using Newtonsoft.Json;
using Sniper.Api.Authorization;
using Sniper.Api.BorusanService;
using Sniper.Api.Util.Cache;
using Sniper.Api.Util.FileSystem;
using Sniper.Api.Util.Log;
using Sniper.Api.Util.WebService;
using Sniper.Core.Models.Common;
using Sniper.Core.Models.Expertise;
using Sniper.Core.Models.Expertise.Request;
using Sniper.Core.SAPRest;
using Sniper.Core.Utils;

namespace Sniper.Api.Controllers
{
#if(!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif

    [RoutePrefix("sniperapp/expertise")]
    public class ExpertiseController : ApiController
    {
        private readonly WsClient _client;
        private readonly LogUtil _logUtil;

        private readonly Dictionary<string, string> _dictionary;

        public ExpertiseController()
        {
            _client = new WsClient();
            _dictionary = SapNameManager.GetSapNames(typeof(FormModel));
            _logUtil = new LogUtil(typeof(ExpertiseController));
        }

        [Route("forms/{userName}")]
        [HttpGet]
        [ResponseType(typeof(ExpertiseModel))]
        public HttpResponseMessage GetExpertiseForms([FromUri] string userName)
        {
            var response = _client.MakeRequest(c => c.ZXX_FM_EXP_GET(new ZXX_FM_EXP_GETRequest
            {
                ZXX_FM_EXP_GET = new ZXX_FM_EXP_GET
                {
                    IV_USER_NAME = userName.ToUpper()
                }
            }));


            var model = Mapper.Map<ResponseModel<ExpertiseModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);

        }

        [Route("forms/add/{userName}")]
        [HttpPost]
        public async Task<HttpResponseMessage> PostExpertiseForm([FromUri] string userName)
        {
            try
            {
                if (!Request.Content.IsMimeMultipartContent("form-data"))
                {
                    throw new HttpResponseException
                        (Request.CreateResponse(HttpStatusCode.UnsupportedMediaType));
                }

                var form = JsonConvert.DeserializeObject<FormModel>(HttpContext.Current.Request.Form.Get("form"));

                if (form == null)
                {
                    return Request.CreateResponse(HttpStatusCode.BadRequest);
                }

                var postedFiles = HttpContext.Current.Request.Files;

                var allTasks = postedFiles
                    .GetMultiple("image")
                    .Select(x => FileManager.WriteFileAsync("ExpertisePhotoWrite", x.InputStream));

                await Task.WhenAll(allTasks).ContinueWith(task =>
                {
                    if (!task.IsFaulted && task.IsCompleted)
                    {
                        form.PhotoPaths.AddRange(task.Result.ToList());
                    }

                    else if (task.IsFaulted)
                    {
                        _logUtil.Error(task.Exception);
                    }
                });

                var expertisePostResult = SAPRestService.ExpertiseFormPost(userName, form);

                return Request.CreateResponse(HttpStatusCode.OK, expertisePostResult);
            }
            catch (System.Exception ex)
            {
                _logUtil.Error(ex.Message, ex);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [HttpPost]
        [Route("form/images")]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Long)]
        public async Task<HttpResponseMessage> GetImagesAsync([FromBody] ExpertiseImageRequest request)
        {
            //create 
            var model = new ResponseModel<PhotoModel>
            {
                Data = null,
                StatusCode = (int)ResponseStatus.CmsError,
                Status = ResponseStatus.CmsError.ToString("f"),
                Messages = new List<string>
                {
                    "An error has occured"
                }
            };

            var allTasks = from p in request.Paths
                           select FileManager.ReadFileAsync(p);

            await Task.WhenAll(allTasks).ContinueWith(task =>
            {
                if (!task.IsFaulted && task.IsCompleted)
                {
                    model = new ResponseModel<PhotoModel>
                    {
                        Data = new PhotoModel
                        {
                            Photos = task.Result.ToList(),
                        },
                        StatusCode = (int)ResponseStatus.Success,
                        Status = ResponseStatus.Success.ToString("f")
                    };
                }
            });


            return Request.CreateResponse(HttpStatusCode.OK, model);
        }


        [Route("forms/options/{userName}/{fieldName}/{param?}")]
        [HttpGet]
        [ResponseType(typeof(FieldNameModel))]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Long)]
        public HttpResponseMessage GetExpertiseFormOptions([FromUri] string userName, [FromUri] string fieldName, [FromUri] string param = "")
        {
            var response = _client.MakeRequest(c => c.ZXX_FM_EXP_FIELD(new ZXX_FM_EXP_FIELDRequest
            {
                ZXX_FM_EXP_FIELD = new ZXX_FM_EXP_FIELD
                {
                    IV_USER_NAME = userName.ToUpper(),
                    IV_FIELD_NAME = _dictionary[fieldName],
                    IV_FIELD_PARAM = param
                }
            }));

            var model = Mapper.Map<ResponseModel<FieldNameModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);

        }
    }
}