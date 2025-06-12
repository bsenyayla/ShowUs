using System;
using System.Web.UI;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm.DynamicWs;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;

public partial class CrmPages_Admin_DynamicWs_WebServiceFnList :AdminPage
{
    public CrmPages_Admin_DynamicWs_WebServiceFnList()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        }
        if (!Page.IsPostBack)
        {
            WebServiceId.Text = QueryHelper.GetString("WebServiceId");
        }
    }
    protected void Store1_Refresh(object sender, StoreRefreshDataEventArgs e)
    {
        var vf = new WebServiceFactory();
        var wsId = ValidationHelper.GetGuid(WebServiceId.Text);
        Store1.DataSource = vf.GetWebserviceMethodList(wsId);
        Store1.DataBind();
    }
}