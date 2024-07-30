using System;
using System.Collections.Generic;
using System.Configuration;
using System.Net;
using System.Linq;
using System.Net.Http;
using System.Security.Claims;
using System.Web.Http;
using System.Web.Http.Description;
using AutoMapper;
using RestSharp;
using Sniper.Api.Authorization;
using Sniper.Api.Util.Log;
using Sniper.Core.Models.Common;
using Sniper.Core.Models.News;

namespace Sniper.Api.Controllers
{
#if(!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif
    [RoutePrefix("sniperapp/news")]
    public class NewsController : ApiController
    {
        private readonly IRestClient _restClient;
        private readonly LogUtil _logUtil;

        public NewsController()
        {
            _restClient = new RestClient(ConfigurationManager.AppSettings["CmsApiUrlBase"]);
            _logUtil = new LogUtil(GetType());
        }

        [Route("{languageCode}")]
        [ResponseType(typeof(IEnumerable<NewsItemModel>))]
        public HttpResponseMessage Get(string languageCode)
        {
            var principal = Request.GetRequestContext().Principal as ClaimsPrincipal;

            var allNews = new List<NewsItemModel>();

            try
            {
                string roles = string.Join("|", principal.Claims.Where(c => c.Type == ClaimTypes.Role && c.Value != SniperRoles.SniperBaseUser).Select(c => c.Value).ToArray());

                var request = new RestRequest("/news/getall?languageCode=" + languageCode + "&roles=" + roles + "&cc=" + AuthUtil.GetUserCountry(Request));

                var response = _restClient.Get(request);

                var newsModel = Mapper.Map<ResponseModel<NewsModel>>(response);

                if (newsModel.StatusCode == 0)
                {
                    allNews.AddRange(newsModel.Data.NewsItems);
                }
            }

            catch (Exception)
            {
                // ignored
            }

            var newsReponse = new ResponseModel<NewsModel>
            {
                Data = new NewsModel
                {
                    NewsItems = allNews
                },
                StatusCode = (int)Core.Models.Common.ResponseStatus.Success,
                Status = Core.Models.Common.ResponseStatus.Success.ToString("f")
            };

            return Request.CreateResponse(HttpStatusCode.OK, newsReponse);
        }
    }
}
