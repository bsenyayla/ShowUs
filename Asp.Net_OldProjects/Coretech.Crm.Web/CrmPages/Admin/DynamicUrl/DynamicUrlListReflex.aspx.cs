using System;
using Coretech.Crm.Factory;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX.View;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Factory.Crm.DynamicUrl;

public partial class CrmPages_Admin_DynamicUrl_DynamicUrlListReflex : Coretech.Crm.Web.UI.RefleX.AdminPage
{
    public CrmPages_Admin_DynamicUrl_DynamicUrlListReflex()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    void TranslateMessages()
    {
        btnNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        Delete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        GridPanel1.ColumnModel.Columns[0].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_NAME);

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
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=PrvRead");
        }
    }
    protected void Store1_Refresh(object sender, AjaxEventArgs e)
    {

        var vf = new DynamicUrlFactory(App.Params.CurrentUser.SystemUserId);

        GridPanel1.DataSource = vf.GetDynamicUrlList();
        GridPanel1.DataBind();
    }
    protected void DeleteDynamicUrl(object sender, AjaxEventArgs e)
    {
        var Values = e.ExtraParams["Values"];
        DynamicUrlFactory vf = new DynamicUrlFactory(App.Params.CurrentUser.SystemUserId);

        var degerler = GridPanel1.SelectionModel[0] as RowSelectionModel;
        var dynamicUrId = string.Empty;

        foreach (var dictionary in degerler.SelectedRows)
        {
            dynamicUrId += dictionary["DynamicUrlId"] + ",";

        }
        MessageBox msg = new MessageBox();
        try
        {
            if (!string.IsNullOrEmpty(dynamicUrId))
            {
                vf.DeleteDynamicUrl(dynamicUrId);

                GridPanel1.Reload();
            }
        }
            
        catch (Exception ex)
        {
            msg.Show(ex.Message);
        }

    }
}