using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using System;
using System.Web.UI;
using TuFactory.Object;
using TuFactory.Sender;

public partial class Sender_UserControl_SenderCDDComplateConfirm : UserControl
{
    Guid _recid = ValidationHelper.GetGuid(QueryHelper.GetString("recId"));
    protected override void OnInit(EventArgs e)
    {
        _recid = QueryHelper.GetGuid("recid");//sender_ID

        var senderFactory = new SenderFactory();

        var cddHistoryUser = senderFactory.GetCDDHistoryUser(_recid);

        if (App.Params.CurrentUser.SystemUserId != cddHistoryUser)
        {

            RefleXFrameWork.ToolBar editToolbar = Page.FindControl("EditToolbar_Container") as RefleXFrameWork.ToolBar;
            DynamicFactory df = new DynamicFactory(ERunInUser.SystemAdmin);
            #region Reject

            RefleXFrameWork.ToolbarButton BtnCDDStatus = new RefleXFrameWork.ToolbarButton();
            BtnCDDStatus.ID = "BtnCDDStatus";
            BtnCDDStatus.Icon = Icon.PageGo;
            BtnCDDStatus.Text = "CDD Onayı";
            string uptCardEditFormID = ValidationHelper.GetString(ParameterFactory.GetParameterValue("UPT_CARD_EDIT_FORM"));

            string newWindow = "window.top.newWindowRefleX(window.top.GetWebAppRoot + '/ISV/TU/Sender/SenderCDDRejectDescription.aspx?recId=" + _recid + "', { maximized: false, width: 500, height: 200, resizable: true, modal: true, maximizable: false });";

            BtnCDDStatus.Listeners.Click.Handler = newWindow;
            editToolbar.Items.Insert(editToolbar.Items.Count - 6, BtnCDDStatus);
        }

        #endregion
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        var senderAfterSaveDb = new SenderAfterSaveDb();
        var cddStatus = senderAfterSaveDb.GetSenderCDDStatus(_recid);

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
}
