using System;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Users;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Factory;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using RefleXFrameWork;
using AjaxEventArgs = Coolite.Ext.Web.AjaxEventArgs;

public partial class CrmPages_AutoPages_Pages_AssignTo : BasePage
{
    private DynamicSecurity dynamicSecurity;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            hdnRecid.Text = QueryHelper.GetString("RecordId");
            hdnObjectId.Text = QueryHelper.GetString("ObjectId");
            UserCmp.Value = App.Params.CurrentUser.SystemUserId.ToString();
            CheckSecurity();
            ToolbarButton1.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_ASSIGN_BTNASSIGN);
            UserCmp.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_ASSIGN_USERNAME);
            QScript("window.top.R.WindowMng.getActiveWindow().setTitle(" + ScriptCreater.SerializeString(CrmLabel.TranslateMessage(LabelEnum.CRM_ASSIGN)) + ");");
        }

    }
    void CheckSecurity()
    {
        dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                             (string.IsNullOrEmpty(hdnRecid.Text)
                                  ? (Guid?)null
                                  : ValidationHelper.GetGuid(hdnRecid.Text)));
        if (!dynamicSecurity.PrvAssign)
        {
            Response.Redirect("~/CrmPages/AutoPages/Error.aspx?message="+"Kaydı Atama Hakkınız Yok");
        }
    }

    protected void StoreOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var uf = new UsersFactory();
        StoreUser.DataSource = uf.GetUserList();
        StoreUser.DataBind();
    }

    protected void ClickOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            if (ValidationHelper.GetGuid(UserCmp.SelectedItem.Value) != Guid.Empty)
            {
                CheckSecurity();
                var df = new DynamicFactory(ERunInUser.CalingUser);
                df.Assign(QueryHelper.GetInteger("ObjectId"), ValidationHelper.GetGuid(QueryHelper.GetString("RecordId")), ValidationHelper.GetGuid(UserCmp.SelectedItem.Value));
                
                //MessageShow("USER_ASSIGNED");
            }
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }
}