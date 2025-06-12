using System;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Factory.Crm.CustomControl;
public partial class CrmPages_Admin_CustomControl_CustomControlDllList : Coretech.Crm.Web.UI.RefleX.AdminPage
{
    public CrmPages_Admin_CustomControl_CustomControlDllList()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    void TranslateMessages()
    {
        Button1.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        GridPanel1.ColumnModel.Columns[1].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_NAME);
        GridPanel1.ColumnModel.Columns[2].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_PLUGIN_LOCATION);
        GridPanel1.ColumnModel.Columns[3].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_PLUGIN_FILE_PATH);
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
        var vf = new CustomControlFactory();
        GridPanel1.DataSource = vf.GetCustomControlDllList();
        GridPanel1.DataBind();
    }
}