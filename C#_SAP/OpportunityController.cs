using System.Collections.Generic;
using System.Dynamic;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using AutoMapper;
using Sniper.Api.Authorization;
using Sniper.Api.BorusanService;
using Sniper.Api.Util.Cache;
using Sniper.Api.Util.WebService;
using Sniper.Core.Models.Common;
using Sniper.Core.Models.Offers;
using Sniper.Core.Models.Offers.Request;
using Sniper.Core.Models.Opportunity;
using Sniper.Core.Utils;

namespace Sniper.Api.Controllers
{
#if(!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif
    [RoutePrefix("sniperapp/opportunity")]
    public class OpportunityController : ApiController
    {
        private readonly WsClient _client;

        private readonly Dictionary<string, string> _offeritemdictionary;
       
        public OpportunityController()
        {
            _client = new WsClient();
            _offeritemdictionary = SapNameManager.GetSapNames(typeof(OfferInfoItemModel));
        }

        [Route("add/offer/{userName}/{opportunity}/{type}")]
        [HttpPost]
        public HttpResponseMessage SetProposal([FromUri] string userName, [FromUri]string opportunity, [FromUri]string type, [FromBody]ProposalModel request)
        {
            var response =
                _client.MakeRequest(c => c.ZXX_FM_CRM_OPPORT_TO_QUOT_WS(new ZXX_FM_CRM_OPPORT_TO_QUOT_WSRequest
                {
                    ZXX_FM_CRM_OPPORT_TO_QUOT_WS = new ZXX_FM_CRM_OPPORT_TO_QUOT_WS
                    {
                        IV_USER_NAME = userName.ToUpper(),
                        IS_HEADER = Mapper.Map<ZCRM_S_ORDER_HEADER>(request.OfferInfo),
                        IS_REF_HEADER = new ZCRM_S_REF_DOC_HEADER
                        {
                            PROCESS_TYPE = type,
                            OBJECT_ID = opportunity
                        },
                        IT_ITEM = Mapper.Map<ZCRM_S_ORDER_ITEM[]>(request.Products),
                        IT_QUOT_PYM = Mapper.Map<ZCRM_S_QUOT_PAYM_PLN[]>(request.PaymentPlans)

                    }
                }));

            var model = Mapper.Map<ResponseModel<ExpandoObject>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("{userName}")]
        [HttpGet]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Short)]
        public HttpResponseMessage GetOpportunities([FromUri] string userName, [FromUri] bool isPSSR=false)
        {
            var response =
                _client.MakeRequest(c => c.ZXX_FM_GET_OPPORT_4PARTNER_WS(new ZXX_FM_GET_OPPORT_4PARTNER_WSRequest(
                    new ZXX_FM_GET_OPPORT_4PARTNER_WS
                    {
                        IV_USER_NAME = userName.ToUpper(),
                        IV_OTHER = isPSSR ? "X" : "" 
                    })));

            var model = Mapper.Map<ResponseModel<OpportunityModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }


        [Route("offers/{userName}/{formId}")]
        [HttpGet]
        public HttpResponseMessage GetOffers([FromUri] string userName, [FromUri] string formId)
        {
            var response =
                _client.MakeRequest(c => c.ZXX_FM_CRM_GET_QUOT_4OPPORT_WS(new ZXX_FM_CRM_GET_QUOT_4OPPORT_WSRequest(
                    new ZXX_FM_CRM_GET_QUOT_4OPPORT_WS
                    {
                        IV_USER_NAME = userName.ToUpper(),
                        IV_OBJECT_ID = formId.PadLeft(10, '0')
                    })));

            var model = Mapper.Map<ResponseModel<OfferModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }


        [Route("offerfields/{userName}/{fieldName}")]
        [HttpGet]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Long)]
        public HttpResponseMessage GetOfferDetailFields([FromUri]string userName, [FromUri]string fieldName)
        {
            var response = _client.MakeRequest(x => x.ZXX_FM_FIELD_SH(new ZXX_FM_FIELD_SHRequest
            {
                ZXX_FM_FIELD_SH = new ZXX_FM_FIELD_SH
                {
                    IV_USER_NAME = userName.ToUpper(),
                    IV_FIELD_NAME = _offeritemdictionary[fieldName]
                }
            }));

            var model = Mapper.Map<ResponseModel<FieldNameModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("offer/detail/{userName}/{formId}")]
        [HttpGet]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Short)]
        public HttpResponseMessage GetOffer([FromUri] string userName, [FromUri] string formId)
        {
            var response =
                _client.MakeRequest(c => c.ZXX_FM_CRM_GET_QUOT_DETAILS(new ZXX_FM_CRM_GET_QUOT_DETAILSRequest
                {
                    ZXX_FM_CRM_GET_QUOT_DETAILS = new ZXX_FM_CRM_GET_QUOT_DETAILS
                    {
                        IV_USER_NAME = userName.ToUpper(),
                        IV_OBJECT_ID = formId,
                        IV_PROCESS_TYPE = "Y201" //Static for RUN
                    }
                }));

            var model = Mapper.Map<ResponseModel<ProposalModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("offer/detailwpt/{userName}/{formId}/{processtype}")]
        [HttpGet]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Short)]
        public HttpResponseMessage GetOfferWithProcessType([FromUri] string userName, [FromUri] string formId,  [FromUri] string processtype)
        {
            var response =
                _client.MakeRequest(c => c.ZXX_FM_CRM_GET_QUOT_DETAILS(new ZXX_FM_CRM_GET_QUOT_DETAILSRequest
                {
                    ZXX_FM_CRM_GET_QUOT_DETAILS = new ZXX_FM_CRM_GET_QUOT_DETAILS
                    {
                        IV_USER_NAME = userName.ToUpper(),
                        IV_OBJECT_ID = formId,
                        IV_PROCESS_TYPE = processtype.ToUpper()
                    }
                }));

            var model = Mapper.Map<ResponseModel<ProposalModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("detail/{userName}/{formId}")]
        [HttpGet]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Short)]
        public HttpResponseMessage GetOpportunityDetail([FromUri] string userName, [FromUri] string formId)
        {
            var response =
                _client.MakeRequest(c => c.ZXX_FM_GET_OPPORT_4PARTNER_WS(new ZXX_FM_GET_OPPORT_4PARTNER_WSRequest(
                    new ZXX_FM_GET_OPPORT_4PARTNER_WS
                    {
                        IV_USER_NAME = userName.ToUpper(),
                        IV_OTHER = "" ,
                        IV_OBJECT_ID = formId
                    })));

            var model = Mapper.Map<ResponseModel<OpportunityModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }
    }
}
