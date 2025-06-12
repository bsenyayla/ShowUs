using System;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm.CustomControl;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;

public partial class CrmPages_Admin_CustomControl_CustomControlList : AdminPage
{
    public CrmPages_Admin_CustomControl_CustomControlList()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        }
        var dllId = QueryHelper.GetString("CustomControlDllId");
        if (!string.IsNullOrEmpty(dllId))
        {
            hCustomControlDllId.Value = dllId;
        }
        
    }
    protected void Store1_Refresh(object sender, StoreRefreshDataEventArgs e)
    {
        var vf = new CustomControlFactory();
        Store1.DataSource = vf.GetCustomControlList(ValidationHelper.GetGuid(hCustomControlDllId.Value));
        Store1.DataBind();
    }
}