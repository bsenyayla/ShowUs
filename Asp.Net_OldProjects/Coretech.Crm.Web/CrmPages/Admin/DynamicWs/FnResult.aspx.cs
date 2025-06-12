using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.DynamicWs;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.DynamicWs;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;

public partial class CrmPages_Admin_DynamicWs_FnResult : AdminPage
{
    public CrmPages_Admin_DynamicWs_FnResult()
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
            FillData();
        }

    }
    internal void FillData()
    {
        var mid = ValidationHelper.GetGuid(hdnMethodId.Text);
        var wf = new WebServiceFactory();
        var sm = wf.GetWebServiceMethod(mid);
        var objects = new List<object>();
        foreach (
            var ea in
                App.Params.CurrentEntityAttribute.Values.Where(
                    ea =>
                    ea.EntityId == sm.EntityId && ea.AttributeOf == Guid.Empty &&
                    !ea.IsPKAttribute))
        {
            objects.Add(
                new
                    {
                        ea.AttributeId,
                        Label = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                        ea.UniqueName
                    });
        }

        var objlist = new List<object>();
        foreach (var t in wf.GetWebServiceMethodResultList(mid))
        {
            objlist.Add(new
                            {
                                t.AttributeId,
                                t.ColumnName,
                                t.DefaultValue,
                                t.Description,
                                t.MethodId,
                                t.ResultId,
                                AttributeIdName =
                            App.Params.CurrentEntityAttribute[t.AttributeId].GetLabelWithUniqueName(
                                App.Params.CurrentUser.LanguageId)
                            }
                );
        }
        Store1.DataSource = objlist;
        Store1.DataBind();

        StoreFromAttribute.DataSource = objects;
        StoreFromAttribute.DataBind();
    }

    protected void BtnSave_Click(object sender, AjaxEventArgs e)
    {
        var mid = ValidationHelper.GetGuid(hdnMethodId.Text);
    
      var Values = e.ExtraParams["Values"];
       var degerler = JSON.Deserialize<Dictionary<string, string>[]>(Values);
        var resList = new List<MethodResult>();
        var webServiceFactory = new WebServiceFactory();
        
        foreach (var t in degerler)
        {
            resList.Add(
                new MethodResult
                    {
                        AttributeId = ValidationHelper.GetGuid(t["AttributeId"]),
                        ColumnName = ValidationHelper.GetString(t["ColumnName"]),
                        DefaultValue = ValidationHelper.GetString(t["DefaultValue"]),
                        Description = ValidationHelper.GetString(t["Description"]),
                        MethodId = mid,
                        ResultId = ValidationHelper.GetGuid(t["ResultId"])
                        
                    }
                );
        }


        webServiceFactory.AddUpdateWebServiceMethodResultList(mid,resList);

    }
    
 
}