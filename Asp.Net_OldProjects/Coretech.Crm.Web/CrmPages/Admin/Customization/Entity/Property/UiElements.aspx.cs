using System;
using System.Collections.Generic;
using System.Web.UI;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Crm.View;
using Coolite.Ext.Web;

public partial class CrmPages_Admin_Customization_Entity_Property_FormAndView : AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_FormAndView()
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
            hdnObjectId.Text = QueryHelper.GetString("ObjectId");
        }
    }

    protected void Store1_Refresh(object sender, StoreRefreshDataEventArgs e)
    {
        ViewFactory vf = new ViewFactory();
        this.Store1.DataSource = vf.GetViewListByObjectId(ValidationHelper.GetInteger(hdnObjectId.Text,0));

       
        this.Store1.DataBind();
    }
    protected void DeleteViewQuery(object sender, AjaxEventArgs e)
    {
        var Values = e.ExtraParams["Values"];
        ViewFactory vf = new ViewFactory();

        var degerler = JSON.Deserialize<Dictionary<string, string>[]>(Values);
        var viewQueryId = string.Empty;
        foreach (var dictionary in degerler)
        {
            viewQueryId += dictionary["ViewQueryId"] + ",";

        }

        try
        {
            if (!string.IsNullOrEmpty(viewQueryId))
            {
                vf.DeleteViewQuery(viewQueryId);

                GridPanel1.Reload();
            }
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }

    }
}
