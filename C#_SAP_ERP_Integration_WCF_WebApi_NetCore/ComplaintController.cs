using System.Net;
using System.Net.Http;
using System.Web.Http;
using AutoMapper;
using Sniper.Api.BorusanService;
using Sniper.Api.Util.Cache;
using Sniper.Api.Util.WebService;
using Sniper.Core.Models.Common;
using Sniper.Core.Models.Complaint;
using Sniper.Core.Models.Complaint.Request;
using Sniper.Core.Models.Common;
using Sniper.Api.Authorization;

namespace Sniper.Api.Controllers
{
#if (!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif
    [RoutePrefix("sniperapp/complaint")]
    public class ComplaintController : ApiController
    {
        private readonly WsClient _client;
        public ComplaintController()
        {
            _client = new WsClient();
        }

        [Route("list/{userName}")]
        [HttpGet]
        public HttpResponseMessage GetComplaints([FromUri] string userName)
        {
            var response = _client.MakeRequest(c => c.ZXX_FM_COMPLAINT_LIST(new ZXX_FM_COMPLAINT_LISTRequest(
                    new ZXX_FM_COMPLAINT_LIST
                    {
                        IV_USER_NAME = userName.ToUpper()
                    })));

            var model = Mapper.Map<ResponseModel<PSSRComplaintModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("{userName}/{complaintId}")]
        [HttpGet]
        public HttpResponseMessage GetComplaint([FromUri] string userName, [FromUri] string complaintId)
        {
            var response = _client.MakeRequest(c => c.ZXX_FM_COMPLAINT_DETAILS(new ZXX_FM_COMPLAINT_DETAILSRequest(
                    new ZXX_FM_COMPLAINT_DETAILS
                    {
                        IV_USER_NAME = userName.ToUpper(),
                        IV_OBJECT_ID = complaintId
                    })));

            var model = Mapper.Map<ResponseModel<PSSRComplaintModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("personel/{userName}")]
        [HttpGet]
        [CacheInvalidate]
        [SniperOutputCache(CacheType.Medium)]
        public HttpResponseMessage GetResponsiblePersonel([FromUri] string userName)
        {
            var response = _client.MakeRequest(c => c.ZXX_FM_PERSONEL_BP(new ZXX_FM_PERSONEL_BPRequest(
                    new ZXX_FM_PERSONEL_BP
                    {
                        IV_USER_NAME = userName.ToUpper(),
                    })));

            var model = Mapper.Map<ResponseModel<FieldNameModel>>(response);


            return Request.CreateResponse(HttpStatusCode.OK, model);
        }


        [Route("status/{userName}")]
        [HttpGet]
        [CacheInvalidate]
        [SniperOutputCache(CacheType.Medium)]
        public HttpResponseMessage GetStatusList([FromUri] string userName)
        {
            var response = _client.MakeRequest(c => c.ZXX_FM_GET_STATUS_CUST(new ZXX_FM_GET_STATUS_CUSTRequest(
                new ZXX_FM_GET_STATUS_CUST
                {
                    IV_USER_NAME = userName.ToUpper(),
                    IV_LANGU = "T",
                    IV_USER_STAT_PROC = "ZIBA" //HardCoded for Complaint
                })));

            var model = Mapper.Map<ResponseModel<FieldNameModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("messageTypes/{userName}")]
        [HttpGet]
        [CacheInvalidate]
        [SniperOutputCache(CacheType.Medium)]
        public HttpResponseMessage GetMessageTypes([FromUri] string userName)
        {
            var response = _client.MakeRequest(c => c.ZXX_FM_GET_TEXT_CUST(new ZXX_FM_GET_TEXT_CUSTRequest(
                new ZXX_FM_GET_TEXT_CUST
                {
                    IV_USER_NAME = userName.ToUpper(),
                    IV_LANGU = "T",
                    IV_TEXTPROCEDURE = "ZIT00001" //HardCoded for Complaint

                })));

            var model = Mapper.Map<ResponseModel<FieldNameModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("update/{userName}")]
        [HttpPost]
        public HttpResponseMessage UpdateComplaint([FromUri] string userName, [FromBody] ComplaintRequest request)
        {
            var allText = request.Texts.Count > 0 ? "X" : string.Empty;

            var response = _client.MakeRequest(c => c.ZXX_FM_COMPLAINT_UPDATE(new ZXX_FM_COMPLAINT_UPDATERequest(
                    new ZXX_FM_COMPLAINT_UPDATE
                    {
                        IV_USER_NAME = userName.ToUpper(),
                        IV_OBJECT_ID = request.Id,
                        IS_COMPLAINT_X = new ZCRM_S_COMPLAINT_UPDATE_X
                        {
                            STAT = "X",
                            ALLTEXTS = allText,
                            PARTNER = "X"
                        },
                        IS_COMPLAINT = new ZCRM_S_COMPLAINT_UPDATE
                        {
                            ALLTEXTS = Mapper.Map<ZXX_COMT_TEXT_TEXTDATA[]>(request.Texts),
                            PARTNER = request.ResponsiblePersonelId,
                            STAT = request.StatusId
                        }
                    })));

            var model = Mapper.Map<ResponseModel<string>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }
    }
}
