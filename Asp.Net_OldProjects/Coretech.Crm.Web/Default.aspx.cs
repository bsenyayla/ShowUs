using System;
using Coretech.Crm.Factory;
using Coretech.Crm.Web.UI;
using System.Web;

public partial class _Default : BasePage 
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string absolutePath = HttpContext.Current.Request.PhysicalApplicationPath;
        if (!Page.IsPostBack)
        {
            Response.Redirect(App.Params.GetConfigKeyValue("ApplicationMainForm") != null
                                   ? Page.ResolveClientUrl("~/" +
                                                           App.Params.GetConfigKeyValue("ApplicationMainForm"))
                                   : Page.ResolveClientUrl("~/CrmPages/Main.aspx"));
        }
    }
   
}
