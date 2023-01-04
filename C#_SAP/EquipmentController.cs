using AutoMapper;
using Sniper.Api.Authorization;
using Sniper.Api.BorusanService;
using Sniper.Api.Handlers;
using Sniper.Api.NotificationExtensions;
using Sniper.Api.Util.WebService;
using Sniper.Core.Models.Common;
using Sniper.Core.Models.Customer.Detail;
using Sniper.Core.Utils;
using System.Collections.Generic;
using System.Dynamic;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Description;

namespace Sniper.Api.Controllers
{
#if(!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif
    [RoutePrefix("sniperapp/equipment")]
    public class EquipmentController : ApiController
    {
        private readonly WsClient _client;
        private WsClient _replicateClient;
        private readonly Dictionary<string, string> _dictionary;
        public EquipmentController()
        {
            _client = new WsClient();
            _replicateClient = new WsClient();
            _dictionary = SapNameManager.GetSapNames(typeof(EquipmentModel));
        }

        [Route("options/other/{userName}")]
        [HttpGet]
        [ResponseType(typeof(List<OtherEquipmentModel>))]
        public HttpResponseMessage GetOtherEquipments([FromUri]string userName)
        {
            var response = _client.MakeRequest(c => c.ZXX_FM_REKP_RAKIP_URUN(new ZXX_FM_REKP_RAKIP_URUNRequest
            {
                ZXX_FM_REKP_RAKIP_URUN = new ZXX_FM_REKP_RAKIP_URUN
                {
                    IV_USER_NAME = userName.ToUpper()
                }
            }));

            var model = Mapper.Map<ResponseModel<List<OtherEquipmentModel>>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);

        }

        [Route("delete/other/{userName}/{customerId}/{*productName}")]
        [HttpGet]
        public HttpResponseMessage DeleteOtherEquipment([FromUri]string userName, [FromUri]string customerId, [FromUri]string productName)
        {
            var response = _client.MakeRequest(c => c.ZXX_FM_REKP_DELL(new ZXX_FM_REKP_DELLRequest
            {
                ZXX_FM_REKP_DELL = new ZXX_FM_REKP_DELL
                {
                    IV_MUS_BP = customerId,
                    IV_USER_NAME = userName.ToUpper(),
                    IV_RAKIP_URUN = productName
                }
            }));

            var model = Mapper.Map<ResponseModel<ExpandoObject>>(response);


            return Request.CreateResponse(HttpStatusCode.OK, model);

        }

        [Route("add/other/{userName}/{customerId}/{*productId}")]
        [HttpGet]
        public HttpResponseMessage AddOtherEquipment([FromUri]string userName, [FromUri]string customerId, [FromUri]string productId)
        {
            var response = _client.MakeRequest(c => c.ZXX_FM_REKP_ADD(new ZXX_FM_REKP_ADDRequest
            {
                ZXX_FM_REKP_ADD = new ZXX_FM_REKP_ADD
                {
                    IV_MUS_BP = customerId,
                    IV_USER_NAME = userName.ToUpper(),
                    IV_PRODUCT_ID = productId
                }
            }));

            var model = Mapper.Map<ResponseModel<ExpandoObject>>(response);


            return Request.CreateResponse(HttpStatusCode.OK, model);

        }

        [Route("edit/{userName}")]
        [HttpPost]
        public HttpResponseMessage EditCustomerEquipment([FromUri]string userName, [FromBody]EquipmentModel equipment)
        {
            var equipFieldsResponse = _replicateClient.MakeRequest(x => x.ZXX_FM_EKP_FIELDS(new ZXX_FM_EKP_FIELDSRequest
            {
                ZXX_FM_EKP_FIELDS = new ZXX_FM_EKP_FIELDS
                {
                    IV_USER_NAME = userName.ToUpper(),
                    IV_FIELD_NAME = "ZZ0011"
                }
            }));

            var applicationcodes = Mapper.Map<ResponseModel<FieldNameModel>>(equipFieldsResponse);

            _replicateClient = new WsClient(); 

            var responseForOld = _replicateClient.MakeRequest(x => x.ZXX_FM_EKP_GET_SN(new ZXX_FM_EKP_GET_SNRequest
            {
                ZXX_FM_EKP_GET_SN = new ZXX_FM_EKP_GET_SN
                {
                    IV_USER_NAME = userName.ToUpper(),
                    IV_SER_NO = equipment.SerialNumber
                }
            }));

            var oldModel = Mapper.Map<ResponseModel<EquipmentModel>>(responseForOld);

            var response = _client.MakeRequest(x => x.ZXX_FM_EKP_SET(new ZXX_FM_EKP_SETRequest
            {
                ZXX_FM_EKP_SET = new ZXX_FM_EKP_SET
                {
                    IV_USER_NAME = userName.ToUpper(),
                    IT_EKP = Mapper.Map<ZSL_S_EKP_C[]>(equipment)
                }
            }));

            var model = Mapper.Map<ResponseModel<ExpandoObject>>(response);

            if (applicationcodes.Data != null && applicationcodes.Data.Values != null)
            {
                oldModel.Data.ApplicationCodeText = applicationcodes.Data.Values.Find(x => x.Value.Equals(oldModel.Data.ApplicationCode))?.Name;
                equipment.ApplicationCodeText = applicationcodes.Data.Values.Find(x => x.Value.Equals(equipment.ApplicationCode))?.Name;
            }

            if (model != null && model.StatusCode == 0)
            {
                NotificationRequestModel<EquipmentModel> notificationRequestModel = new NotificationRequestModel<EquipmentModel>
                {
                    CountryCode = AuthUtil.GetUserDataDefault(Request).CountryCode,
                    CustomerId = equipment.CustomerId,
                    NewModel = equipment,
                    NotifiedAction = NotificationSchemaConstants.addUpdateCustomerEquipment,
                    UserName = userName,
                    OldModel = oldModel.Data
                };

                NotificationHandler<EquipmentModel>.InsertNotification(notificationRequestModel);
            }

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }


        [Route("get/fields/{userName}/{fieldName}")]
        [HttpGet]
        //[CacheInvalidate]
        //[SniperOutputCache(type: CacheType.Long)]
        public HttpResponseMessage GetFields([FromUri]string userName, [FromUri]string fieldName)
        {
            var response = _client.MakeRequest(x => x.ZXX_FM_EKP_FIELDS(new ZXX_FM_EKP_FIELDSRequest
            {
                ZXX_FM_EKP_FIELDS = new ZXX_FM_EKP_FIELDS
                {
                    IV_USER_NAME = userName.ToUpper(),
                    IV_FIELD_NAME = _dictionary[fieldName]
                }
            }));

            var model = Mapper.Map<ResponseModel<FieldNameModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }


        [Route("search/{userName}/{serialNo}")]
        [HttpGet]
        public HttpResponseMessage GetEquipmentBySerialNumber([FromUri]string userName, [FromUri]string serialNo)
        {
            var response = _client.MakeRequest(x => x.ZXX_FM_EKP_GET_SN(new ZXX_FM_EKP_GET_SNRequest
            {
                ZXX_FM_EKP_GET_SN = new ZXX_FM_EKP_GET_SN
                {
                    IV_USER_NAME = userName.ToUpper(),
                    IV_SER_NO = serialNo
                }
            }));

            var model = Mapper.Map<ResponseModel<EquipmentModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("list/{userName}/{customerId}")]
        [HttpGet]
        public HttpResponseMessage GetEquipments([FromUri] string userName, [FromUri] string customerId)
        {
            var response = _client.MakeRequest(x => x.ZXX_FM_EKP_GET(new ZXX_FM_EKP_GETRequest
            {
                ZXX_FM_EKP_GET = new ZXX_FM_EKP_GET
                {
                    IV_USER_NAME = userName.ToUpper(),
                    IV_MUS_BP = customerId
                }
            }));

            var model = Mapper.Map<ResponseModel<List<EquipmentModel>>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("list/pair/{userName}/{customerId}")]
        [HttpGet]
        public HttpResponseMessage GetEquipmentsKeyValue([FromUri] string userName, [FromUri] string customerId)
        {
            var response = _client.MakeRequest(x => x.ZXX_FM_EKP_GET(new ZXX_FM_EKP_GETRequest
            {
                ZXX_FM_EKP_GET = new ZXX_FM_EKP_GET
                {
                    IV_USER_NAME = userName.ToUpper(),
                    IV_MUS_BP = customerId
                }
            }));

            var model = Mapper.Map<ResponseModel<FieldNameModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

    }
}
