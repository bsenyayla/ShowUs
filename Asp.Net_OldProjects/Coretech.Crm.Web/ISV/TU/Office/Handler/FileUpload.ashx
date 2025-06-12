<%@ WebHandler Language="C#" Class="FileUpload" %>

using System;
using System.Web;

public class FileUpload : IHttpHandler
{

    public void ProcessRequest(HttpContext context) 
    {
        string fname = string.Empty;
        
        try
        {
            if (context.Request.Files.Count > 0)
            {
                HttpFileCollection files = context.Request.Files;
                for (int i = 0; i < files.Count; i++)
                {
                    HttpPostedFile file = files[i];
                    fname = context.Server.MapPath("~/OfficeData/" + DateTime.Now.ToString("yyyyMMddhhmmss_") + file.FileName);
                    //fname = Coretech.Crm.Factory.App.Params.GetConfigKeyValue("LocalPath") + strUploadPath + DateTime.Now.ToString("yyyyMMddhhmmss_") + file.FileName;
                    file.SaveAs(fname);
                }
            }
            context.Response.ContentType = "text/plain";
            context.Response.Write(fname);

        }
        catch (Exception ex)
        {
            Coretech.Crm.Utility.Util.LogUtil.WriteException(ex);
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}