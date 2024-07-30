
using Microsoft.AspNetCore.Http.Internal;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Newtonsoft.Json;
using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using System.Web;
using StandartLibrary.Models.ViewModels.Common;
using System.Globalization;
using StandartLibrary.Models.Enums;

namespace CRCAPI.Services.Binders
{
    /// <summary>
    /// Custom payload binder.
    /// </summary>
    public class PayloadBinder : IModelBinder
    {
        /// <summary>
        /// Model binder method override.
        /// </summary>
        /// <param name="bindingContext">Current context.</param>
        /// <returns>Task</returns>
        public Task BindModelAsync(ModelBindingContext bindingContext)
        {
            try
            {
                dynamic payload = null;
                var bodyStr = string.Empty;

                if (bindingContext.HttpContext.Request.Method == "GET")
                {
                    var dic = HttpUtility.ParseQueryString(bindingContext.HttpContext.Request.QueryString.ToString());
                    bodyStr = JsonConvert.SerializeObject(dic.AllKeys.ToDictionary(i => i, i => dic[i]));
                }
                else
                {
                    var req = bindingContext.HttpContext.Request;
                    //req.EnableRewind();
                    req.EnableBuffering();

                    using (StreamReader reader = new StreamReader(req.Body, Encoding.UTF8, true, 1024, true))
                    {
                        bodyStr = reader.ReadToEnd();
                    }
                    if (req.HasFormContentType )
                    {
                        var dic = HttpUtility.ParseQueryString(bodyStr);
                        bodyStr = JsonConvert.SerializeObject(dic.AllKeys.ToDictionary(i => i, i => dic[i]));
                    }
                    else
                    {
                        req.Body.Position = 0;
                        bodyStr = bodyStr.Trim('\"');
                    }
                }


                if (bindingContext.ModelType.IsConstructedGenericType)
                {
                    var type = bindingContext.ModelType.GenericTypeArguments[0];
                    bool isPrimitiveType = type.GetTypeInfo().IsPrimitive || type.GetTypeInfo().IsValueType || (type == typeof(string));
                    if (!isPrimitiveType && !string.IsNullOrEmpty(bodyStr))
                    {
                        var model = Activator.CreateInstance(type);
                        JsonConvert.PopulateObject(bodyStr, model, new JSONSettings(CultureInfo.GetCultureInfo("en")).Settings);
                        payload = Activator.CreateInstance(bindingContext.ModelType, model);
                    }
                    else if (!string.IsNullOrEmpty(bodyStr))
                    {
                        if (type == typeof(Int64))
                        {
                            payload = Activator.CreateInstance(bindingContext.ModelType, Convert.ToInt64(bodyStr));
                        }
                        else if (type == typeof(Int32))
                        {
                            payload = Activator.CreateInstance(bindingContext.ModelType, Convert.ToInt32(bodyStr));
                        }
                        else if (type == typeof(Int16))
                        {
                            payload = Activator.CreateInstance(bindingContext.ModelType, Convert.ToInt16(bodyStr));
                        }
                        else if (type == typeof(decimal))
                        {
                            payload = Activator.CreateInstance(bindingContext.ModelType, Convert.ToDecimal(bodyStr));
                        }
                        else if (type == typeof(Guid))
                        {
                            payload = Activator.CreateInstance(bindingContext.ModelType, Guid.Parse(bodyStr));
                        }
                        else
                        {
                            payload = Activator.CreateInstance(bindingContext.ModelType, bodyStr);
                        }
                    }
                    else
                    {
                        payload = Activator.CreateInstance(bindingContext.ModelType);
                    }
                }
                else
                {
                    payload = Activator.CreateInstance(bindingContext.ModelType);
                }

                //payload.Language = bindingContext.ActionContext.HttpContext.GetLanguage();

                bindingContext.Result = ModelBindingResult.Success(payload);
                return Task.CompletedTask;
            }
            catch(Exception ex)
            {
                throw new BusinessException("Payload binding error", ErrorCode.PayloadBindingException);
            }
        }
    }
}