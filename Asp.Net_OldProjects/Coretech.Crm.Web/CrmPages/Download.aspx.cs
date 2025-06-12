using System;
using System.Configuration;
using System.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;

public partial class CrmPages_Download : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            var fileName = HttpContext.Current.Request.QueryString["EFile"];
            if (!string.IsNullOrEmpty(fileName))
            {

                xfile.Text = HTTPUtil.GetWebAppRoot() + "/" +
                    App.Params.GetConfigKeyValue("ExportPath") + "/" + fileName;
            }
        }
    }
}