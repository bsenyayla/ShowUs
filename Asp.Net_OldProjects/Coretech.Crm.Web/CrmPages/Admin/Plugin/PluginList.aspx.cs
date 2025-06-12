using System;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm.Plugin;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;

public partial class CrmPages_Admin_Plugin_PluginList : AdminPage
{
    public CrmPages_Admin_Plugin_PluginList()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        }
        var dllId = QueryHelper.GetString("PluginDllId");
        if (!string.IsNullOrEmpty(dllId))
        {
            hPluginDllId.Value = dllId;
        }
        
    }
    protected void Store1_Refresh(object sender, StoreRefreshDataEventArgs e)
    {
        var vf = new PluginFactory();
        Store1.DataSource = vf.GetPluginList(ValidationHelper.GetGuid(hPluginDllId.Value));
        Store1.DataBind();
    }
}