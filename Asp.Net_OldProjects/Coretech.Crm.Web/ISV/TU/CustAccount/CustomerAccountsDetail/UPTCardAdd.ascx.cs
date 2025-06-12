using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using System;
using System.Linq;
using System.Web.UI;
using TuFactory.CustAccount.Business;
using TuFactory.Object;
using TuFactory.Sender;
using TuFactory.UptCard.Business;
using static TuFactory.Fraud.FraudScanFactory;
using UPTCache = UPT.Shared.CacheProvider.Service;

public partial class CustAccount_CustomerAccountsDetail_UPTCardAdd : System.Web.UI.UserControl
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
        CustAccountOperations custAccountOperation = new CustAccountOperations();
        #region UPT Card
        //TRY Hesabı olacak + Akif Kartı Bulunmayacak ( Müşterinin sadece aktif bir kartı olabilir. )
        if (custAccountOperation.GetCustAccountsInfo(ValidationHelper.GetGuid(_recid), null)
            .Where(custAccount => custAccount.AccountCurrencyID
                    == UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId).Count() > 0
            && new CardClientService().HasSenderActiveCard(ValidationHelper.GetGuid(_recid)).ServiceResponse == false
            && new SenderAfterSaveDb().GetSenderFraudStatus(_recid) == CustomerFraudStatus.FraudConfirmed.GetHashCode()
            )
        {
            RefleXFrameWork.ToolbarButton addUptCardButton = new RefleXFrameWork.ToolbarButton();
            addUptCardButton.ID = "btnAddUptCard";
            addUptCardButton.Icon = Icon.Creditcards;
            addUptCardButton.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTS_ADD_UPT_CARD");
            string uptCardEditFormID = ValidationHelper.GetString(ParameterFactory.GetParameterValue("UPT_CARD_EDIT_FORM"));
            var urlparam = "?defaulteditpageid=" + uptCardEditFormID + "&ObjectId=" + ((int)TuEntityEnum.New_UptCard).ToString()
                + "&senderID=" + _recid + "&mode=1";

            string newWindow = "window.top.newWindowRefleX(window.top.GetWebAppRoot + '/CrmPages/AutoPages/EditReflex.aspx" +
                                urlparam + "', { maximized: false, width: 960, height: 600, resizable: true, modal: true, maximizable: false });";

            addUptCardButton.Listeners.Click.Handler = newWindow;
            editToolbar.Items.Insert(editToolbar.Items.Count - 6, addUptCardButton);
        }
        #endregion

        ToolbarFill toolbarFill = new ToolbarFill();
        toolbarFill.ID = "fill1";
        editToolbar.Items.Insert(editToolbar.Items.Count - 1, toolbarFill);

        #region Doküman Incelendi Onayı
        RefleXFrameWork.ToolbarButton btnUpdateCustAccountDocumentInspected = new RefleXFrameWork.ToolbarButton();
        btnUpdateCustAccountDocumentInspected.ID = "btnUpdateCustAccountDocumentInspected";
        btnUpdateCustAccountDocumentInspected.Icon = Icon.PagePortrait;
        btnUpdateCustAccountDocumentInspected.Text = ValidationHelper.GetString(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTS_BTN_DOCUMENT_INSPECT") ,"Evrak Kontrolü Tamamlandı");
        btnUpdateCustAccountDocumentInspected.AjaxEvents.Click.Event += new RefleXFrameWork.AjaxComponentListener.AjaxEventHandler((sender, EventArgs) => btnUpdateCustAccountDocumentInspectedClick_Event(sender, EventArgs));

        if (btnUpdateCustAccountDocumentInspectedStatus(_recid))
        {
            btnUpdateCustAccountDocumentInspected.Disabled = true;
            btnUpdateCustAccountDocumentInspected.Enabled = false;
        }
        else
        {
            btnUpdateCustAccountDocumentInspected.Disabled = false;
            btnUpdateCustAccountDocumentInspected.Enabled = true;
        }
        editToolbar.Items.Insert(editToolbar.Items.Count - 1, btnUpdateCustAccountDocumentInspected);
        #endregion
    }

    private bool btnUpdateCustAccountDocumentInspectedStatus(Guid recordId)
    {
        var staticData = new StaticData();
        try
        {
            if (_recid == null)
                return false;

            staticData.AddParameter("SenderId", System.Data.DbType.Guid, _recid);
            return ValidationHelper.GetBoolean(
                staticData.ExecuteScalar("select isnull(new_CustAccountDocumentInspected, 0) as Inspected from New_SenderExtension(nolock) where New_SenderId = @SenderId"), 
                false);

        }
        catch (Exception e)
        {
            LogUtil.WriteException(e, "CustAccountDocumentInspection");
            return false;
        }
    }

    private void btnUpdateCustAccountDocumentInspectedClick_Event(object sender, AjaxEventArgs e)
    {
        var messageBox = new MessageBox { Height = 200 };
        if (btnUpdateCustAccountDocumentInspectedStatus(_recid))
        {
            messageBox.MessageType = EMessageType.Warning;
            messageBox.Show("İlgili kişiye ait dokümanlar zaten onaylanmış!");
            return;
        }

        var staticData = new StaticData();
        try
        {
            var currentUser = App.Params.CurrentUser.SystemUserId;
            staticData.AddParameter("User", System.Data.DbType.Guid, currentUser);
            staticData.AddParameter("SenderId", System.Data.DbType.Guid, _recid);
            //staticData.AddParameter("Status", System.Data.DbType.Boolean, true);
            //staticData.ExecuteNonQuery("update New_SenderExtension set new_CustAccountDocumentInspected=@Status, new_CustAccountDocumentInspectedBy=@User where New_SenderId = @SenderId");
            staticData.ExecuteNonQuery("update New_SenderExtension set new_CustAccountDocumentInspected=1, new_CustAccountDocumentInspectedBy=@User where New_SenderId = @SenderId");
        }
        catch
        {
            messageBox.MessageType = EMessageType.Error;
            messageBox.Show("İşlem tipi seçilmedi yada yanlış bir işlem tipi seçildi.");
            return;
        }
        messageBox.MessageType = EMessageType.Information;
        messageBox.Show("İlgili kişiye ait dokümanlar onaylanmıştır.");
        return;
    }

    // Select* from ViewQuery Where UniqueName = 'ACCOUNT_CUSTOMERS_SENDER_VIEW'
}