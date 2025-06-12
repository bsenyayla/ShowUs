<%@ WebHandler Language="C#" Class="GetData" %>

using System;
using System.Collections.Generic;
using System.Web;
using System.Web.SessionState;
using Coretech.Crm.Factory.BootstarptPage;
using Coretech.Crm.Objects.BootstarptPage.Data;
using Coretech.Crm.Utility.Util;
using Newtonsoft.Json;

public class GetData : IHttpHandler, IReadOnlySessionState
{

    public void ProcessRequest(HttpContext context)
    {
        var sqlkey = QueryHelper.GetString("Key");
        var Parameters = QueryHelper.GetString("Parameters");
        var Sqloptions = QueryHelper.GetString("Options");

        List<SqlParameters>sqlParameters = null;
        SqlOptions SqlOptions = null;
        if (!string.IsNullOrEmpty(Parameters))
            sqlParameters = JsonConvert.DeserializeObject<List<SqlParameters>>(Parameters);
        if (!string.IsNullOrEmpty(Sqloptions))
            SqlOptions = JsonConvert.DeserializeObject<SqlOptions>(Sqloptions);

        var dataop = new DataOperations();
        var totalCount = 0;
        context.Response.ContentType = "application/javascript";
        context.Response.Write(dataop.ReturnDataToJsonFormatted(sqlkey, sqlParameters, SqlOptions, out totalCount));
        //context.Response.Write(output);
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}