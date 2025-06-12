using System;
using System.Collections.Generic;
using System.Web.UI;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Fraud;
using TuFactory.Object;
using TuFactory.Object.Confirm;
using TuFactory.Object.User;
using TuFactory.TuUser;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using TuFactory.CustAccount.Business;
using TuFactory.UptCard.Business;

public partial class Fraud_Detail_ConfirmAccount : BasePage
{
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private DynamicSecurity DynamicSecurity;
    CustAccountFraudFactory ff = new CustAccountFraudFactory();
    private void TranslateMessages()
    {
        ToolbarButtonContinue.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_CONTINUE");
        ToolbarButtonContinue1.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_CONTINUE");
        ToolbarButtonCancel.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_INTERRUPT");
        ToolbarButtonCancel1.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_INTERRUPT");

        ToolbarButtonConfirm.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_CONFIRM");

        ToolbarButtonReturn.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_RETURN");
        ToolbarButtonReturn1.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_RETURN");
        ToolbarButtonMd.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING_DETAIL");
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_FraudLog.GetHashCode(), null);
        TranslateMessages();
        if (!RefleX.IsAjxPostback)
        {
            hdnRecId.Value = QueryHelper.GetString("recid");
            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", ""},
                                {"ObjectId", TuEntityEnum.New_CustAccountFraudLog.GetHashCode().ToString()},
                                {"recid", hdnRecId.Value}
                            };
            var urlparam = QueryHelper.RefreshUrl(query);
            PanelIframe.AutoLoad.Url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            ReConfigureButtons();
        }
    }

    private void ReConfigureButtons()
    {
        var ret = string.Empty;
        var result = ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out ret);

        ToolbarButtonContinue.Visible = false;
        ToolbarButtonContinue1.Visible = false;
        ToolbarButtonCancel.Visible = false;
        ToolbarButtonCancel1.Visible = false;
        ToolbarButtonConfirm.Visible = false;
        ToolbarButtonReturn.Visible = false;
        ToolbarButtonReturn1.Visible = false;
        if (QueryHelper.GetString("readonly") != "1")
        {
            switch (result)
            {
                case FraudConfirmStatus.ISLEM_DEVAM_ETTIRME_ONAYI_BEKLIYOR:
                case FraudConfirmStatus.ISLEM_KESILME_ONAYI_BEKLIYOR:
                    if (_userApproval.ApprovalFraud)
                    {
                        ToolbarButtonConfirm.Visible = true;
                        ToolbarButtonReturn.Visible = true;
                        ToolbarButtonReturn1.Visible = true;
                    }
                    break;
                case FraudConfirmStatus.ISLEM_DEVAM_ETTIRME_ONAYI_GERI_CEVRILDI:
                case FraudConfirmStatus.ISLEM_KESILME_ONAYI_GERI_CEVRILDI:
                case FraudConfirmStatus.ISLEM_OTOMATIK_KESILDI:
                case "":
                    if (DynamicSecurity.PrvAppend)
                    {
                        ToolbarButtonContinue.Visible = true;
                        ToolbarButtonContinue1.Visible = true;
                        ToolbarButtonCancel.Visible = true;
                        ToolbarButtonCancel1.Visible = true;
                    }
                    break;

            }
        }
    }
    protected void Continue(object sender, AjaxEventArgs e)
    {
        if (!DynamicSecurity.PrvAppend)
            return;
        ff.AmlConfirmRequest(ValidationHelper.GetGuid(hdnRecId.Value), new_FraudContinueReason.Value, ValidationHelper.GetGuid(new_FraudContinueReasonId.Value), true);
        Confirm();
    }

    protected void Confirm(object sender, AjaxEventArgs e)
    {
        Confirm();
    }

    private void Confirm()
    {
        Guid fraudLogId = ValidationHelper.GetGuid(hdnRecId.Value);

        if (!_userApproval.ApprovalFraud)
            return;
        var statusTypeName = string.Empty;
        var confirm = false;
        var staus = ff.GetAmlStatus(fraudLogId, out statusTypeName);

        if (staus == FraudConfirmStatus.ISLEM_KESILME_ONAYI_BEKLIYOR)
        {
            confirm = ff.AmlInterruptConfirm(fraudLogId);
        }
        else if (staus == FraudConfirmStatus.ISLEM_DEVAM_ETTIRME_ONAYI_BEKLIYOR)
        {
            confirm = ff.AmlConfirm(fraudLogId);
        }
        if (!confirm)
            return;

        ff.GetAmlStatus(fraudLogId, out statusTypeName);

        if (!string.IsNullOrEmpty(statusTypeName))
        {
            var opType = new CardClientService().GetCustAccountOperationType(fraudLogId);
            if (opType.Item2 == TuFactory.CustAccount.Object.CustAccountOperationType.Hesaptan_UPT_Karta_Transfer)
            {
                var cardClientService = new CardClientService();
                var result = cardClientService.FinishTransferToCardOperation(opType.Item1, App.Params.CurrentUser.SystemUserId);
                if(!result.ServiceResponse)
                {
                    statusTypeName = result.RETURN_DESCRIPTION;
                }
            }

            QScript("alert('" + statusTypeName + "');");
            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
        }
    }

    protected void Cancel(object sender, AjaxEventArgs e)
    {
        if (!DynamicSecurity.PrvAppend)
            return;
        ff.AmlConfirmRequest(ValidationHelper.GetGuid(hdnRecId.Value), new_FraudCancelReason.Value, ValidationHelper.GetGuid(new_FraudCancelReasonId.Value), false);

        var opType = new CardClientService().GetCustAccountOperationType(ValidationHelper.GetGuid(hdnRecId.Value));

        if (opType.Item2 == TuFactory.CustAccount.Object.CustAccountOperationType.Hesaptan_UPT_Karta_Transfer)
        {
            Cancel();
            ff.AmlInterruptConfirm(ValidationHelper.GetGuid(hdnRecId.Value));
        }
        else
        {
            var ret = string.Empty;
            ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out ret);
            if (!string.IsNullOrEmpty(ret))
            {
                QScript("alert('" + ret + "');");
                QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
            }
        }
    }

    protected void ConfirmCancel(object sender, AjaxEventArgs e)
    {
        Cancel();
    }

    private void Cancel()
    {
        if (!_userApproval.ApprovalFraud)
            return;

        var ret = string.Empty;
        var staus = ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out ret);

        if (_userApproval.ApprovalFraud)
        {
            if (staus == FraudConfirmStatus.ISLEM_KESILME_ONAYI_BEKLIYOR)
            {
                ff.AmlStatusChange(ValidationHelper.GetGuid(hdnRecId.Value), FraudConfirmStatus.ISLEM_KESILME_ONAYI_GERI_CEVRILDI, new_FraudConfirmCancelReason.Value, ValidationHelper.GetGuid(new_FraudConfirmCancelReasonId.Value));
            }
            else if (staus == FraudConfirmStatus.ISLEM_DEVAM_ETTIRME_ONAYI_BEKLIYOR)
            {
                ff.AmlStatusChange(ValidationHelper.GetGuid(hdnRecId.Value), FraudConfirmStatus.ISLEM_DEVAM_ETTIRME_ONAYI_GERI_CEVRILDI, new_FraudConfirmCancelReason.Value, ValidationHelper.GetGuid(new_FraudConfirmCancelReasonId.Value));
            }
        }
        else
        {
            return;
        }

        ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out ret);
        if (!string.IsNullOrEmpty(ret))
        {
            QScript("alert('" + ret + "');");
            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
        }
    }
}
