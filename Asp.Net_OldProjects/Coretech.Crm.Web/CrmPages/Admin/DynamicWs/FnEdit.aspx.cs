using System;
using System.Collections.Generic;
using System.Web.UI;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.DynamicWs;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;

public partial class CrmPages_Admin_DynamicWs_FnEdit : AdminPage
{
    public CrmPages_Admin_DynamicWs_FnEdit()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
         if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        }
        if (!Page.IsPostBack) {
            hdnMethodId.Text = QueryHelper.GetString("MethodId");
            FillPage();
        }
    }
    internal void FillPage()
    {
        var mid = ValidationHelper.GetGuid(hdnMethodId.Text);
        var wf=new WebServiceFactory();
        var sm=wf.GetWebServiceMethod(mid);
        if(sm!=null)
        {
            txtClassName.Text = sm.ClassName;
            txtName.Text = sm.Name;
            txtReturnType.Text = sm.ReturnType;
            nmbTimeOutMs.Number = sm.TimeOutMs;
            
            cmbEntityId.Value = sm.EntityId.ToString();

        }

    }

    protected void BtnSave_Click(object sender, AjaxEventArgs e)
    {
        var mid = ValidationHelper.GetGuid(hdnMethodId.Text);
        var wf = new WebServiceFactory();
        var sm = wf.GetWebServiceMethod(mid);
        sm.TimeOutMs = ValidationHelper.GetInteger( nmbTimeOutMs.Number,1000);
        sm.EntityId = ValidationHelper.GetGuid(cmbEntityId.SelectedItem.Value);
        wf.AddUpdateWebServiceMethod(sm);

    }
    protected void EntityStoreOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var elist = new List<object>();
        foreach (var entity in App.Params.CurrentEntity.Values)
        {
            elist.Add(new { entity.ObjectId, entity .EntityId,Label=entity.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId)});
            
        }
        entitystore.DataSource = elist;
        entitystore.DataBind();
    }
}