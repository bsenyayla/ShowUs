<%@ WebHandler Language="C#" Class="Globalisation" %>

using System;
using System.Web;
using System.Web.SessionState;
using Coretech.Crm.Factory;
using Newtonsoft.Json;


public class Globalisation : IHttpHandler, IReadOnlySessionState
{
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/javascript";
        dynamic dynGlobal = new
        {
            DateCultureInfo = App.Params.CurrentUser.UserCulture.DateTimeFormat,
            NumerCultureInfo = App.Params.CurrentUser.UserCulture.NumberFormat,
            
        };
        context.Response.Write(string.Format("var globalisation={0}", JsonConvert.SerializeObject(dynGlobal)));
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}