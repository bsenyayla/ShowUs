using System;
using System.Collections.Generic;
using System.Web.UI;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm.DynamicUrl;
using Coretech.Crm.Factory.Crm.Template;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.DynamicUrl;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Factory;
using ListItem = Coolite.Ext.Web.ListItem;

public partial class CrmPages_Admin_DynamicUrl_DynamicUrlEdit : AdminPage
{
    public CrmPages_Admin_DynamicUrl_DynamicUrlEdit()
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
            hdnDynamicUrlId.Text = QueryHelper.GetString("DynamicUrlId");

            if (string.IsNullOrEmpty(hdnDynamicUrlId.Text))
            {
                hdnDynamicUrlId.Text = GuidHelper.New().ToString();

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
        var ws = new DynamicUrlFactory(App.Params.CurrentUser.SystemUserId);
        var mid = ValidationHelper.GetGuid(hdnDynamicUrlId.Text);

        foreach (var value in App.Params.CurrentCustomControls.Values)
        {
            cmbCustomControlList.Items.Add(new ListItem(value.ClassName, value.CustomControlId.ToString()));
        }
        
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
        var id = ValidationHelper.GetGuid(hdnDynamicUrlId.Text);
        var Wf = new DynamicUrlFactory(App.Params.CurrentUser.SystemUserId);
        var mc = Wf.GetDynamicUrl(id);
        List<object> li = new List<object>();
        EntityObjectAttributeList.Value = mc.EntityId.ToString();

        foreach (Parameters par in mc.ParameterList)
        {
            li.Add(new { ParameterName = par.Name, Value = par.DynamicValue, DynamicUrlParameterId = GuidHelper.New() });
        }
        strGrdDefault.DataSource = li;
        strGrdDefault.DataBind();
        txtName.Text = mc.Name;
        
        txtUrl.Text = mc.Url;
        txtWidth.Text = mc.Style.Width.ToString();
        txtHeight.Text = mc.Style.Height.ToString();
        cmbOpenStyle.Value = mc.Style.Style.ToString();
        if (mc.CustomControlId!=Guid.Empty)
            cmbCustomControlList.Value = mc.CustomControlId.ToString();
        //strGrdDefault.DataSource = mc.ParameterValueList;
        //strGrdDefault.DataBind();
        //;

    }


    protected void BtnSave_Click(object sender, AjaxEventArgs e)
    {
        var json = e.ExtraParams["Values"];
        var degerler = JSON.Deserialize<Dictionary<string, string>[]>(json);
        var mc = new DynamicUrl();
        var mcid = ValidationHelper.GetGuid(hdnDynamicUrlId.Text);

        mc.DynamicUrlId = mcid;
        mc.EntityId = ValidationHelper.GetGuid(EntityObjectAttributeList.SelectedItem.Value);
        mc.DynamicUrlId = ValidationHelper.GetGuid(hdnDynamicUrlId.Value);
        mc.Name = txtName.Text;
        mc.Url = txtUrl.Text;
        if (ValidationHelper.GetGuid(cmbCustomControlList.SelectedItem.Value) != Guid.Empty)
            mc.CustomControlId = ValidationHelper.GetGuid(cmbCustomControlList.SelectedItem.Value);
        mc.ParameterList = new List<Parameters>();
        var tf = new TemplateFactory();
        foreach (var t in degerler)
        {
            var xml = "";
            tf.HtmlToXml(t["Value"], ref xml);

            mc.ParameterList.Add(new Parameters
            {
                DynamicValue = t["Value"],
                DynamicValueXml = xml,
                Name = t["ParameterName"]
            });

        }

        var wf = new DynamicUrlFactory(App.Params.CurrentUser.SystemUserId);
        mc.ParameterListXml = DynamicUrl.SerializeParameterList(mc.ParameterList);
        var style = new WindowStyle
                        {
                            Height = ValidationHelper.GetInteger(txtHeight.Value, 0),
                            Width = ValidationHelper.GetInteger(txtWidth.Value, 0),
                            Style = ValidationHelper.GetInteger(cmbOpenStyle.SelectedItem.Value, 0)
                        };
        mc.Style = style;
        mc.StyleXml = DynamicUrl.SerializeWindowStyle(style);

        wf.AddUpdateDynamicUrl(mc);
        
    }
}