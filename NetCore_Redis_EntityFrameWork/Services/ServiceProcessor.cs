using CRCAPI.Services.Attributes;
using CRCAPI.Services.Exceptions;
using CRCAPI.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Localization;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.Enums;
using StandartLibrary.Models.ViewModels;
using System;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading;

namespace CRCAPI.Services
{

    [TransientDependency(ServiceType = typeof(IServiceProcessor))]
    public class ServiceProcessor : IServiceProcessor
    {

        private readonly IHttpContextAccessor httpContextAccessor;
        private readonly ILogCoreMan logCoreMan;
        public ServiceProcessor(IHttpContextAccessor httpContextAccessor, ILogCoreMan logCoreMan)
        {
            this.httpContextAccessor = httpContextAccessor;
            this.logCoreMan = logCoreMan;

        }

        public ServiceResponse Call<T, TResult>(Func<T, TResult> action, T parameter, [CallerMemberName] string memberName = "", [CallerFilePath] string sourceFilePath = "", [CallerLineNumber] int sourceLineNumber = 0)
        {
            object result = null;
            Exception exception = null;
            try
            {
                result = action(parameter);
            }
            catch (Exception ex)
            {
                exception = ex;
            }

            return CreateResponse(result, exception, memberName, sourceFilePath, sourceLineNumber);
        }
        public ServiceResponse Call<T1, T2, TResult>(Func<T1,T2, TResult> action, T1 parameter, T2 parameter2, [CallerMemberName] string memberName = "", [CallerFilePath] string sourceFilePath = "", [CallerLineNumber] int sourceLineNumber = 0)
        {
            object result = null;
            Exception exception = null;
            try
            {
                result = action(parameter, parameter2);
            }
            catch (Exception ex)
            {
                exception = ex;
            }

            return CreateResponse(result, exception, memberName, sourceFilePath, sourceLineNumber);
        }


        public ServiceResponse Call<TResult>(Func<TResult> action, [CallerMemberName] string memberName = "", [CallerFilePath] string sourceFilePath = "", [CallerLineNumber] int sourceLineNumber = 0)
        {
            object result = null;
            Exception exception = null;
            try
            {
                result = action();
            }
            catch (Exception ex)
            {
                exception = ex;
            }

            return CreateResponse(result, exception, memberName, sourceFilePath, sourceLineNumber);
        }

        public ServiceResponse Call<T>(Action<T> action, T parameter, [CallerMemberName] string memberName = "", [CallerFilePath] string sourceFilePath = "", [CallerLineNumber] int sourceLineNumber = 0)
        {
            object result = null;
            Exception exception = null;
            try
            {
                action(parameter);
            }
            catch (Exception ex)
            {
                exception = ex;
            }

            return CreateResponse(result, exception, memberName, sourceFilePath, sourceLineNumber);
        }


        public ServiceResponse Call(Action action, [CallerMemberName] string memberName = "", [CallerFilePath] string sourceFilePath = "", [CallerLineNumber] int sourceLineNumber = 0)
        {
            object result = null;
            Exception exception = null;
            try
            {
                action();
            }
            catch (Exception ex)
            {
                exception = ex;
            }

            return CreateResponse(result, exception, memberName, sourceFilePath, sourceLineNumber);
        }


        public ServiceResponse Create<T>(T parameter, [CallerMemberName] string memberName = "", [CallerFilePath] string sourceFilePath = "", [CallerLineNumber] int sourceLineNumber = 0)
        {
            return CreateResponse(parameter, null, memberName, sourceFilePath, sourceLineNumber);
        }

        protected ServiceResponse CreateResponse(object data, Exception ex, string memberName, string sourceFilePath, int sourceLineNumber)
        {
            var lang = string.Empty;
            var feature = httpContextAccessor.HttpContext.Features.Get<IRequestCultureFeature>();
            if (feature != null)
            {
                lang = feature.RequestCulture.UICulture.TwoLetterISOLanguageName;
            }
            else
            {
                lang = Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName;
            }
            var response = new ServiceResponse()
            {
                ErrorCode = ErrorCode.Success
            };
            if (ex != null)
            {
                if (ex is BusinessException)
                {
                    var exx = (BusinessException)ex;
                    response.ErrorCode = exx.ErrorCode;
                    response.Message = exx.Message;
                }
                else if (ex is CameraException)
                {
                    var exx = (CameraException)ex;
                    response.Data = exx.Response;
                }
                else
                {
                    response.ErrorCode = ErrorCode.SystemException;
                    response.Message = "System error. Please contact your administrator.";
                }

                Log(memberName, sourceFilePath, sourceLineNumber, ex);
            }
            else
            {
                response.Data = data;
                response.Message = "OK";    // localization yapılabilir..
            }
            return response;
        }

        private void Log(string memberName, string sourceFilePath, int sourceLineNumber, Exception ex)
        {
            var log = new StringBuilder();

            log.Append("memberName: " + memberName);
            log.AppendLine("sourceFilePath: " + sourceFilePath);
            log.AppendLine("sourceLineNumber: " + sourceLineNumber);
            logCoreMan.Error(log.ToString(), ex, sourceFilePath);
        }
    }
}
