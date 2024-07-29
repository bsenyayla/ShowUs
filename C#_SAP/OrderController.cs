using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Description;
using AutoMapper;
using Sniper.Api.Authorization;
using Sniper.Api.BorusanService;
using Sniper.Api.Util.WebService;
using Sniper.Core.Models.Common;
using Sniper.Core.Models.Common;
using Sniper.Core.Models.Orders;
using Sniper.Core.Models.Orders.Request;

namespace Sniper.Api.Controllers
{
#if (!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif
    [RoutePrefix("sniperapp/order")]
    public class OrderController : ApiController
    {
        private readonly WsClient _client;
        public OrderController()
        {
            _client = new WsClient();
        }

        [Route("{userName}")]
        [HttpPost]
        [ResponseType(typeof(List<OrderModel>))]
        public HttpResponseMessage GetOrderItems([FromUri]string userName, [FromBody]OrderRequest request)
        {
            var response = _client.MakeRequest(c => c.ZXX_FM_PARCA_SIPARIS_TAKIP(new ZXX_FM_PARCA_SIPARIS_TAKIPRequest
            {
                ZXX_FM_PARCA_SIPARIS_TAKIP = new ZXX_FM_PARCA_SIPARIS_TAKIP
                {
                    IV_USER_NAME = userName.ToUpper(),
                    IV_BO = request.OnlyBO ? "X" : string.Empty,
                    IV_MATNR = request.ItemNo,
                    IV_KUNNR = request.Orderer,
                    IV_SECIM = request.Type,
                    IV_VBELN = request.OrderNo,
                }
            }));

            var model = Mapper.Map<ResponseModel<OrderModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);

        }

        [Route("fields/{userName}")]
        [HttpGet]
        [ResponseType(typeof(List<FieldNameModel>))]
        public HttpResponseMessage GetCustomerNames([FromUri]string userName)
        {
            var response = _client.MakeRequest(c => c.ZXX_FM_MUS_SH(new ZXX_FM_MUS_SHRequest
            {
                ZXX_FM_MUS_SH = new ZXX_FM_MUS_SH
                {
                    IV_USER_NAME = userName.ToUpper()
                }
            }));

            var model = Mapper.Map<ResponseModel<FieldNameModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

    }
}
