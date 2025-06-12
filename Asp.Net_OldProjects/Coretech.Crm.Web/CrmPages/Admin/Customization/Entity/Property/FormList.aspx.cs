using System;
using System.Collections.Generic;
using System.Web.UI;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm.Form;
using Coretech.Crm.Web.UI;

public partial class CrmPages_Admin_Customization_Entity_Property_FormList : AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_FormList()
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
        FormFactory vf = new FormFactory();
        this.Store1.DataSource = vf.GetFormListByObjectId(ValidationHelper.GetInteger(hdnObjectId.Text, 0));
        this.Store1.DataBind();
    }
    
    protected void DeleteForm(object sender, AjaxEventArgs e)
    {
        var Values = e.ExtraParams["Values"];
        FormFactory vf = new FormFactory();
       
        var degerler = JSON.Deserialize<Dictionary<string, string>[]>(Values);
        var formId=string.Empty;
        foreach (var dictionary in degerler)
        {
            formId+= dictionary["FormId"]+",";
            
        }

        try
        {
            if (!string.IsNullOrEmpty(formId))
            {
                vf.DeleteForms(formId);

                GridPanel1.Reload();
            }
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
       
    }
}