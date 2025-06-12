using System;
using System.Web.UI;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.WorkFlow;
using TuFactory.Object;
using Coretech.Crm.Web.UI.RefleX;
using System.Web.UI.HtmlControls;
using TuFactory.CustAccount.Business;
using TuFactory.TuUser;
using TuFactory.Object.User;
using Coretech.Crm.Factory;

public partial class CustAccount_Account_CustAccountBlockedApproval : System.Web.UI.UserControl
{
    Guid _recid = Guid.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {

    }
    private TuUserApproval _userApproval = null;
    protected override void OnInit(EventArgs e)
    {
        //todo:Yetki Kontrolü Yapılacak.
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        var ts = new TuFactory.CustAccount.Business.CustAccountOperations().GetCustAccountConfirmStatus(ValidationHelper.GetGuid(_recid));
        
        _recid = QueryHelper.GetGuid("recid");

        if (_recid != Guid.Empty)
        {
            DynamicFactory df = new DynamicFactory(ERunInUser.SystemAdmin);
            DynamicEntity de = df.Retrieve(TuEntityEnum.New_CustAccountBlockedApproval.GetHashCode(), _recid, new[] { "new_BlockedConfirmStatus" });


            RefleXFrameWork.ToolBar toolbarApp = new RefleXFrameWork.ToolBar();
            toolbarApp.ID = "toolbarApp";
           
            if (_userApproval.CustAccountBlockApprover && 
                de.GetPicklistValue("new_BlockedConfirmStatus") == TuFactory.CustAccount.Object.CustAccountBlocked.BlockedConfirmStatus.OnayBekliyor.GetHashCode())
            {
                RefleXFrameWork.ToolbarButton btnAccept = new RefleXFrameWork.ToolbarButton();
                btnAccept.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTBLOCKEDAPPROVAL_ACCEPT");
                btnAccept.ID = "btnConfirm";
                btnAccept.Icon = Icon.Accept;
                btnAccept.AjaxEvents.Click.Event += btnAcceptClick_Event;

                RefleXFrameWork.ToolbarButton btnCancel = new RefleXFrameWork.ToolbarButton();
                btnCancel.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTBLOCKEDAPPROVAL_CANCEL");
                btnCancel.ID = "btnCancel";
                btnCancel.Icon = Icon.Cancel;
                btnCancel.AjaxEvents.Click.Event += btnCancelClick_Event;

                toolbarApp.Items.Add(btnAccept);
                toolbarApp.Items.Add(btnCancel);

                var msg = Page.FindControl("MessageBar") as HtmlControl;
                //if (msg != null)
                //{

                //    pmessage.Attributes.Add("class", "warning");
                //    msg.Controls.Add(pmessage);
                   msg.Style.Add("display", "block");
                //}
                msg.Controls.Add(toolbarApp);
                //pmessage.Controls.Add(btnCancel);
            }
        }
        base.OnInit(e);
    }
    string getDesc() {
        var objd = Page.FindControl("new_OperationDescription_Container") as CrmTextAreaComp;
        if (objd != null)
            return objd.Value;
        return string.Empty;
    }
    void btnAcceptClick_Event(object sender, AjaxEventArgs e)
    {
        CustAccountBlocked.ConfirmBlocked(_recid, getDesc());
        BasePage.Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTBLOCKEDAPPROVAL_ACCEPT_MESSAGE"));
        BasePage.QScript("RefreshParetnGrid(true);");
    }
    void btnCancelClick_Event(object sender, AjaxEventArgs e)
    {
        CustAccountBlocked.RejectBlocked(_recid, getDesc());
        BasePage.Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTBLOCKEDAPPROVAL_CANCEL_MESSAGE"));
        BasePage.QScript("RefreshParetnGrid(true);");
    }
}