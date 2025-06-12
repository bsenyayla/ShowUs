using System;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm.DynamicWs;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Web.UI;

public partial class CrmPages_Admin_DynamicWs_WebService : AdminPage
{
    public CrmPages_Admin_DynamicWs_WebService()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {

        if (!(DynamicSecurity.PrvRead ))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvRead");
        }
    }
    protected void Store1_Refresh(object sender, StoreRefreshDataEventArgs e)
    {
        var vf = new WebServiceFactory();
        Store1.DataSource = vf.GetWebServiceList();
        Store1.DataBind();
    }
   
}