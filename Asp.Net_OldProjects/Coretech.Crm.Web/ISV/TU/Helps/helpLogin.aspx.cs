using System;
using System.Web.UI;
using Coretech.Crm.Utility.Util;

public partial class helps_helpLogin : System.Web.UI.Page
{
   
    protected void Page_Load(object sender, EventArgs e)
    {
        Page.Header.Controls.Add(new LiteralControl("<script>var GetWebAppRoot='" + HTTPUtil.GetWebAppRoot() + "';</script>"));
            //Page.ClientScript.RegisterClientScriptBlock(typeof(string), "GetWebAppRoot", "var GetWebAppRoot='" + HTTPUtil.GetWebAppRoot() + "';", true);
    }
}