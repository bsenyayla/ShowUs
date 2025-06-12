using System;
using System.Collections.Generic;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.DynamicUrl;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Web.UI;

public partial class CrmPages_Admin_DynamicUrl_DynamicUrlList : AdminPage
{
    public CrmPages_Admin_DynamicUrl_DynamicUrlList()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!DynamicSecurity.PrvRead)
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=PrvRead");
        }
    }
    protected void Store1_Refresh(object sender, StoreRefreshDataEventArgs e)
    {

        var vf = new DynamicUrlFactory(App.Params.CurrentUser.SystemUserId);
        
        Store1.DataSource = vf.GetDynamicUrlList();
        Store1.DataBind();
    }
    protected void DeleteDynamicUrl(object sender, AjaxEventArgs e)
    {
        var Values = e.ExtraParams["Values"];
        DynamicUrlFactory vf = new DynamicUrlFactory(App.Params.CurrentUser.SystemUserId);

        var degerler = JSON.Deserialize<Dictionary<string, string>[]>(Values);
        var DynamicUrId = string.Empty;
        foreach (var dictionary in degerler)
        {
            DynamicUrId += dictionary["DynamicUrlId"] + ",";

        }

        try
        {
            if (!string.IsNullOrEmpty(DynamicUrId))
            {
                vf.DeleteDynamicUrl(DynamicUrId);

                GridPanel1.Reload();
            }
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }

    }
}