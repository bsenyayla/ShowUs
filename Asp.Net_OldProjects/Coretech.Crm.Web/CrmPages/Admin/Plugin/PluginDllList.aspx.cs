using System;
using RefleXFrameWork;
using Coretech.Crm.Factory.Crm.Plugin;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Labels;
public partial class CrmPages_Admin_Plugin_PluginDllList : Coretech.Crm.Web.UI.RefleX.AdminPage
{
    public CrmPages_Admin_Plugin_PluginDllList()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    void TranslateMessages()
    {
          Button1.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
       _grdsma.ColumnModel.Columns[1].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_NAME);
        _grdsma.ColumnModel.Columns[2].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_PLUGIN_LOCATION);
        _grdsma.ColumnModel.Columns[3].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_PLUGIN_FILE_PATH);
    }
    protected override void OnPreInit(EventArgs e)
    {
        TranslateMessages();
        base.OnPreInit(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!DynamicSecurity.PrvRead)
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvRead");
        }
        if (!RefleXFrameWork.RefleX.IsAjxPostback)
        {

        }
    }
    protected void Store1_Refresh(object sender, AjaxEventArgs e)
    {
        var vf = new PluginFactory();
      _grdsma.DataSource = vf.GetPluginDllList();
        _grdsma.DataBind();
    }
}