using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using System;
using System.Web.UI;
using TuFactory.CustAccount.Business;
using TuFactory.Sender;
using static TuFactory.Fraud.FraudScanFactory;
using static TuFactory.Sender.SenderFactory;

public partial class CustAccount_CustomerAccountsDetail_CustAccountAdd : System.Web.UI.UserControl
{
    Guid _recid = Guid.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            var saveButton = Page.FindControl("btnSave_Container") as ToolbarButton;
            var btnAction = Page.FindControl("btnAction_Container") as ToolbarButton;
            var saveAsCopyButton = Page.FindControl("btnSaveAsCopy_Container") as ToolbarButton;
            var deleteButton = Page.FindControl("btnDelete_Container") as ToolbarButton;
            var btnSaveAndClose = Page.FindControl("btnSaveAndClose_Container") as ToolbarButton;
            var btnSaveAndNew = Page.FindControl("btnSaveAndNew_Container") as ToolbarButton;
            var refreshButton = Page.FindControl("btnRefresh_Container") as ToolbarButton;
            var btnPassive = Page.FindControl("btnPassive_Container") as ToolbarButton;

            refreshButton.SetVisible(false);
            refreshButton.SetDisabled(true);
            btnPassive.SetVisible(false);
            btnPassive.SetDisabled(true);
            saveButton.SetVisible(false);
            saveButton.SetDisabled(true);
            btnAction.SetVisible(false);
            btnAction.SetDisabled(true);
            btnSaveAndNew.SetVisible(false);
            btnSaveAndNew.SetDisabled(true);
            saveAsCopyButton.SetVisible(false);
            saveAsCopyButton.SetDisabled(true);
            deleteButton.SetVisible(false);
            deleteButton.SetDisabled(true);
            btnSaveAndClose.SetDisabled(true);
            btnSaveAndClose.SetVisible(false);
        }
    }
    protected override void OnInit(EventArgs e)
    {
        _recid = QueryHelper.GetGuid("recid");//sender_ID
        RefleXFrameWork.ToolBar editToolbar = Page.FindControl("EditToolbar_Container") as RefleXFrameWork.ToolBar;
        DynamicFactory df = new DynamicFactory(ERunInUser.SystemAdmin);

        var senderAfterSaveDb = new SenderAfterSaveDb();

        var fraudStatus = senderAfterSaveDb.GetSenderFraudStatus(_recid);
        var cddStatus = senderAfterSaveDb.GetSenderCDDStatus(_recid);
        var custAccountType = senderAfterSaveDb.GetSenderCustAccountTypeCode(_recid);

        #region Cust Account

        if (fraudStatus == CustomerFraudStatus.FraudConfirmed.GetHashCode() && cddStatus == CddStatus.CDDConfirmApproved.GetHashCode() && custAccountType =="Tüzel")
        {
            RefleXFrameWork.ToolbarButton addUptCardButton = new RefleXFrameWork.ToolbarButton();
            addUptCardButton.ID = "btnAddCustAccount";
            addUptCardButton.Icon = Icon.ApplicationAdd;
            addUptCardButton.Text = "Hesap Aç";//CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTS_ADD_UPT_CARD");

            var urlparam = "?senderID=" + _recid + "&mode=1";


            // ~/ISV/TU/CustAccount/CustomerAccountsDetail/CustAccountAddPage.aspx
            string newWindow = "window.top.newWindowRefleX(window.top.GetWebAppRoot + 'ISV/TU/CustAccount/CustomerAccountsDetail/CustAccountAddPage.aspx" +
                                urlparam + "', { maximized: false, width: 1000, height: 600, resizable: true, modal: true, maximizable: false });";

            addUptCardButton.Listeners.Click.Handler = newWindow;
            editToolbar.Items.Insert(editToolbar.Items.Count - 6, addUptCardButton);
        }
        else if(fraudStatus == CustomerFraudStatus.FraudConfirmed.GetHashCode() && custAccountType == "Gerçek")
        {
            RefleXFrameWork.ToolbarButton addUptCardButton = new RefleXFrameWork.ToolbarButton();
            addUptCardButton.ID = "btnAddCustAccount";
            addUptCardButton.Icon = Icon.ApplicationAdd;
            addUptCardButton.Text = "Hesap Aç";//CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTS_ADD_UPT_CARD");

            var urlparam = "?senderID=" + _recid + "&mode=1";


            // ~/ISV/TU/CustAccount/CustomerAccountsDetail/CustAccountAddPage.aspx
            string newWindow = "window.top.newWindowRefleX(window.top.GetWebAppRoot + 'ISV/TU/CustAccount/CustomerAccountsDetail/CustAccountAddPage.aspx" +
                                urlparam + "', { maximized: false, width: 1000, height: 600, resizable: true, modal: true, maximizable: false });";

            addUptCardButton.Listeners.Click.Handler = newWindow;
            editToolbar.Items.Insert(editToolbar.Items.Count - 6, addUptCardButton);
        }

        #endregion

    }


}