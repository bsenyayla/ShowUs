using System;
using System.Text;
using System.Threading;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Http;
using StandartLibrary.Models.Enums;
using Newtonsoft.Json;
using StandartLibrary.Models.ViewModels;

namespace CRCAPI.Services.Extensions
{
    public static class LogExtentions
    {
        public static string GetSolutionName(this ResultExecutedContext context)
        {
            if (context.Controller == null || string.IsNullOrWhiteSpace(context.Controller.ToString()))
                return string.Empty;

            var controller = context.Controller.ToString();

            int length = controller.IndexOf(".Controllers");

            if (length == -1)
                return string.Empty;

            return controller.Substring(0, length);
        }

        public static string GetUserName(this ResultExecutedContext context)
        {
            var userName = string.Empty;

            if (context != null && context.HttpContext.User != null && context.HttpContext.User.Identity.IsAuthenticated)
            {
                userName = context.HttpContext.User.Identity.Name;
            }
            else
            {
                var threadPincipal = Thread.CurrentPrincipal;
                if (threadPincipal != null && threadPincipal.Identity.IsAuthenticated)
                {
                    userName = threadPincipal.Identity.Name;
                }
            }

            return userName;
        }

        public static string GetInnerExceptionMessage(this Exception ex)
        {
            if (ex.InnerException == null)
                return ex.Message;

            return ex.Message + Environment.NewLine + " InnerException:" + GetInnerExceptionMessage(ex.InnerException);
        }

        public static string GetRequestBody(this HttpRequest request)
        {
            var result = string.Empty;

            request.Body.Position = 0;
            using (var stream = new System.IO.StreamReader(request.Body, Encoding.UTF8, true, 1024, leaveOpen: true))
            {
                result = stream.ReadToEnd();
            }
            request.Body.Position = 0;

            return result;
        }

        public static string GetResponseBody(this HttpResponse response, out ActionStatusEnum actionStatusEnum)
        {
            actionStatusEnum = ActionStatusEnum.Success;

            var result = string.Empty;

            response.Body.Position = 0;
            using (var stream = new System.IO.StreamReader(response.Body, Encoding.UTF8, true, 1024, leaveOpen: true))
            {
                result = stream.ReadToEnd();
            }
            response.Body.Position = 0;

            if (result.Contains("errorCode") || result.Contains("ErrorCode"))
            {
                try
                {
                    var obj = JsonConvert.DeserializeObject<ServiceResponse>(result);

                    if (obj.ErrorCode != ErrorCode.Success)
                    {
                        actionStatusEnum = ActionStatusEnum.Error;
                        return result;
                    }

                    result = string.Empty;

                }
                catch (Exception)
                {
                }
            }

            return result;
        }
    }
}
