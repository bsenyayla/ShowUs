using System;
using System.Collections.Generic;
using System.Web.UI;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm.DynamicWs;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Factory;

public partial class CrmPages_Admin_DynamicWs_FnCallList : AdminPage
{
    public CrmPages_Admin_DynamicWs_FnCallList()
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
            hdnMethodId.Text = QueryHelper.GetString("MethodId");
        }
    }
    protected void btnDelete_OnEvent(object sender, AjaxEventArgs e) {
        if(!string.IsNullOrEmpty(e.ExtraParams["Deleted"]))
        {
            var a = e.ExtraParams["Deleted"];
            var delete = ValidationHelper.GetGuid(a);
            var wf = new WebServiceFactory();
            wf.DeleteWebServiceMethodCall(delete);
            Store1_Refresh(sender, null);
        }

    }
    protected void Store1_Refresh(object sender, StoreRefreshDataEventArgs e)
    {

        var wf = new WebServiceFactory();
        var list = wf.GetWebServiceMethodCallList(ValidationHelper.GetGuid(hdnMethodId.Text));
        var nlist = new List<object>();
        foreach (var item in list)
        {

            var label=string.Empty;
            if(App.Params.CurrentEntity.ContainsKey(item.ObjectId))
                label=App.Params.CurrentEntity[item.ObjectId].GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId);
        
            nlist.Add(
                new
                    {
                        item.EntityId,
                        item.MethodCallId,
                        item.MethodId,
                        item.Name,
                        EntityIdName = label
                    
                    }
                );
        }
        Store1.DataSource = nlist;

        Store1.DataBind();
    }

}