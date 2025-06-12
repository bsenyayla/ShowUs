using System;
using System.Collections.Generic;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.DynamicWs;
using Coretech.Crm.Factory.Crm.Template;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Objects.Crm.DynamicWs;

public partial class CrmPages_Admin_DynamicWs_FnCallEdit : AdminPage
{
    public CrmPages_Admin_DynamicWs_FnCallEdit()
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
            hdnMethodCallId.Text = QueryHelper.GetString("MethodCallId");
            if (string.IsNullOrEmpty(hdnMethodCallId.Text))
            {
                hdnMethodCallId.Text = GuidHelper.New().ToString();

            }
            else
            {
                FillData();
            }
            FillStore();

        }
    }
    internal void FillStore()
    {
        var ws = new WebServiceFactory();
        var mid = ValidationHelper.GetGuid(hdnMethodId.Text);
        StoreParameter.DataSource = ws.GetWebServiceMethodParameterList(mid);
        StoreParameter.DataBind();


        var objects = new List<object>();
        foreach (var item in App.Params.CurrentEntity.Values)
        {
            objects.Add(
                new
                    {
                        ObjectId = item.ObjectId,
                        Label = item.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                        UniqueName = item.UniqueName,
                        AttributeId = item.EntityId,
                        ReferencedObjectId = item.ObjectId
                    });
        }
        StoreEntityObjectAttributeList.DataSource = objects;
        StoreEntityObjectAttributeList.DataBind();

    }
    internal void FillData()
    {
        var i = ValidationHelper.GetGuid(hdnMethodCallId.Text);
        WebServiceFactory Wf = new WebServiceFactory();
        var mc = Wf.GetWebServiceMethodCall(i);

        cmbParameter.Value = mc.EntityId.ToString();
        EntityObjectAttributeList.Value = mc.EntityId.ToString();
        strGrdDefault.DataSource = mc.ParameterValueList;
        strGrdDefault.DataBind();

        txtName.Text = mc.Name;

    }


    protected void BtnSave_Click(object sender, AjaxEventArgs e)
    {
        var json = e.ExtraParams["Values"];
        var degerler = JSON.Deserialize<Dictionary<string, string>[]>(json);
        var mc = new MethodCall();
        var mcid = ValidationHelper.GetGuid(hdnMethodCallId.Text);

        mc.MethodCallId = mcid;
        mc.EntityId = ValidationHelper.GetGuid(EntityObjectAttributeList.SelectedItem.Value);
        mc.MethodId = ValidationHelper.GetGuid(hdnMethodId.Value);
        mc.Name = txtName.Text;
        mc.ParameterValueList = new List<MethodParameterValue>();
        var tf = new TemplateFactory();
        foreach (var t in degerler)
        {
            var xml = "";
            tf.HtmlToXml(t["Value"], ref xml);

            mc.ParameterValueList.Add(new MethodParameterValue
                                          {
                                              MethodParameterId = ValidationHelper.GetGuid(t["MethodParameterId"]),
                                              ParameterName = t["ParameterName"],
                                              Value = t["Value"],
                                              ValueXml = xml
                                          });

        }
        WebServiceFactory Wf = new WebServiceFactory();
        Wf.AddUpdateUpdateWebServiceMethodCall(mc);


    }
}