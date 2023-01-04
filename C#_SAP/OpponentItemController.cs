using System.Net;
using System.Net.Http;
using System.Web.Http;
using Sniper.Api.Util.WebService;

namespace Sniper.Api.Controllers
{
#if (!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif
    [RoutePrefix("sniperapp/opponentitem")]
    public class OpponentItemController : ApiController
    {
        private readonly WsClient _wsClient;

        public OpponentItemController()
        {
            _wsClient = new WsClient();
        }


        [Route("transfer")]
        [HttpPost]
        public HttpResponseMessage TransferPrice([FromUri] string userName)
        {
            //var response =
            //    _client.MakeRequest(c => c.ZXX_FM_GET_OPPORT_4PARTNER_WS(new ZXX_FM_GET_OPPORT_4PARTNER_WSRequest(
            //        new ZXX_FM_GET_OPPORT_4PARTNER_WS
            //        {
            //            IV_USER_NAME = userName.ToUpper(),
            //        })));

           // return Request.CreateResponse(HttpStatusCode.OK, model);



            return Request.CreateResponse(HttpStatusCode.OK);
        }

    }
}
