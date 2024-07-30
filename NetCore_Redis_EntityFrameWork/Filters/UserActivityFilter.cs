using CRCAPI.Services.Extensions;
using CRCAPI.Services.Interfaces;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.Enums;
using StandartLibrary.Models.Helper;
using System;

namespace CRCAPI.Services.Filters
{
    public class UserActivityFilter : IResultFilter
    {
        private readonly ILogCoreMan _logMan;
        private readonly IConfiguration _configuration;

        private readonly UserActivityManager.UserActivityManager _userActivityManager;

        public UserActivityFilter(ILogCoreMan logMan, IConfiguration configuration)
        {
            _logMan = logMan;
            _configuration = configuration;

            _userActivityManager = new UserActivityManager.UserActivityManager(_configuration);
        }

        public void OnResultExecuted(ResultExecutedContext context) {
            var request = context.HttpContext.Request;

            var response = context.HttpContext.Response;

            var log = new UserActivity();
            log.CreateDate = DateTime.Now;
            log.Id = Guid.NewGuid();
            log.Module = context.GetSolutionName();
            log.Action = context.RouteData.Values["controller"].ToString();
            log.SubAction = context.RouteData.Values["action"].ToString();
            log.Ip = context.HttpContext.Connection.RemoteIpAddress.ToString();
            log.UserName = context.GetUserName();
            log.Referer = request.Headers["Referer"].ToString();
            log.Url = request.QueryString.ToString();
            log.UserAgent = request.Headers["User-Agent"].ToString();
            log.Params = JsonConvert.SerializeObject(new JsonParam {
                RequestBody = request.GetRequestBody(),
            });
            log.RequestType = request.Method;
            log.HttpStatus = response.StatusCode;
            log.ContentType = response.ContentType;

            if (request.Method == "POST") {
                log.Size = request.ContentLength.HasValue ? request.ContentLength.Value : 0;
            }
            else {
                log.Size = 0;
                String[] strArr = request.QueryString.ToString().Split('?');
                if (strArr.Length > 1) {
                    log.Size = strArr[1].Length;
                }
            }


            try {
                ActionStatusEnum actionStatusEnum;

                log.ActionLogData = response.GetResponseBody(out actionStatusEnum);
                log.ActionStatus = actionStatusEnum.ToString();

                _userActivityManager.InsertUserActivity(log);

            }
            catch (Exception ex) {
                _logMan.Error("UserActivityFilter Exception Message Details:" + ex.GetInnerExceptionMessage());

                log.ActionLogData = ex.GetInnerExceptionMessage();
                log.ActionStatus = ActionStatusEnum.Error.ToString();

                _userActivityManager.InsertUserActivity(log);

            }
        }

        public void OnResultExecuting(ResultExecutingContext context)
        {
        }

    }
}
