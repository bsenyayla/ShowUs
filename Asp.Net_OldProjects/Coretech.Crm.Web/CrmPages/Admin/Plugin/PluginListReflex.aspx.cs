using System;
using RefleXFrameWork;
using Coretech.Crm.Factory.Crm.Plugin;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Labels;
public partial class CrmPages_Admin_Plugin_PluginListReflex : Coretech.Crm.Web.UI.RefleX.AdminPage
{
    public CrmPages_Admin_Plugin_PluginListReflex()
    {
        ObjectId = EntityEnum.Entity.GetHashCode();
    }
    void TranslateMessages()
    {

        _grdsma.ColumnModel.Columns[0].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_NAME);
        _grdsma.ColumnModel.Columns[1].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_PLUGIN_CLASSNAME);
   
    }
    protected override void OnPreInit(EventArgs e)
    {
        TranslateMessages();
        base.OnPreInit(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        }
        var dllId = QueryHelper.GetString("PluginDllId");
        if (!RefleX.IsAjxPostback)
        {
            if (!string.IsNullOrEmpty(dllId))
            {
                hPluginDllId.Value = dllId;
            }
        }
    }
    protected void Store1_Refresh(object sender, AjaxEventArgs e)
    {
        var vf = new PluginFactory();
        _grdsma.DataSource = vf.GetPluginList(ValidationHelper.GetGuid(hPluginDllId.Value));
        _grdsma.DataBind();
    }
}