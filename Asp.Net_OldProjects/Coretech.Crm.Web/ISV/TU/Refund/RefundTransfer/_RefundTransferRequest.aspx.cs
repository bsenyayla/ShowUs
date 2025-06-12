using System;
using System.Collections.Generic;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using TuFactory.Object.Confirm;
using TuFactory.Object.User;
using TuFactory.Refund;
using TuFactory.TuUser;
using TuFactory.Object.Refund;
using TuFactory.Data;
using TuFactory.Domain.Refund;
using UPTCache = UPT.Shared.CacheProvider.Service;
using UPTCacheObjects = UPT.Shared.CacheProvider.Model;
using TuFactory.TransactionManagers.Refund.RefundTransfer;
using TuFactory.TransactionManagers.Refund;
using System.Data;
using Coretech.Crm.PluginData;

public partial class Refund_RefundTransfer_Operation_Detail_CancelRequest : BasePage
{
    protected void CalculateAmountWithExpense(object sender, AjaxEventArgs e)
    {
        //if (new_RefundExpense.Checked)
        //{
        //    lAmountWithExpense.SetValue(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_TOTALAMOUNTWITHEXPENSECAPTION") + " : " + "100");
        //}
        //else
        //{
        //    lAmountWithExpense.Clear();
        //    //(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_TOTALAMOUNTWITHEXPENSECAPTION") + " : " + "200");
        //}
    }

    //CRM.NEW_TRANSACTIONCONFIRM_REJECT
    //
    //
    private TuUserApproval _userApproval = null;
    private DynamicSecurity _dynamicSecurity;
    private TuUser _activeUser = null;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private void TranslateMessages()
    {

        ToolbarButtonBtnRefund.Text = CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_IADESINEBASLA");
        PanelRefundTransferReason.Title = CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_PANEL_BASLIK");

    }
    //private void ReConfigureButtons()
    //{
    //    if (!_userApproval.ApprovalCancel)//        ToolbarButtonConfirm.Visible = false;
    //}
    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            TranslateMessages();
        }
        base.OnPreInit(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

        if (!_userApproval.RefundExpenseStart)
        {
            new_RefundExpense.Hide();
        }

        if (!RefleX.IsAjxPostback)
        {

            SetWindowTitle("CRM.NEW_REFUNDTRANSFER_EKRAN");

            hdnObjectId.Value = QueryHelper.GetString("objectid");
            hdnRecId.Value = QueryHelper.GetString("recid");
            GetSecurity();

            //new_RefundSubReasonId.Visible = false;
            //new_RefundSubReasonId.SetVisible(false);

            var readonlyform = string.Empty;
            switch (ValidationHelper.GetInteger(hdnObjectId.Value))
            {
                case (int)TuEntityEnum.New_Transfer:
                    readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_LITE_PAGE"));
                    break;
                case (int)TuEntityEnum.New_Payment:
                    readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("PAYMENT_READONLY_PAGE"));
                    break;
            }
            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyform},
                                {"ObjectId", hdnObjectId.Value},
                                {"recid", hdnRecId.Value}

                            };
            if (TuEntityEnum.New_Transfer.GetHashCode() == ValidationHelper.GetInteger(hdnObjectId.Value))
                query.Add("noplugin", "1");

            var urlparam = QueryHelper.RefreshUrl(query);
            PanelIframe.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
        }

        _dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                          (string.IsNullOrEmpty(hdnRecId.Value)
                                                               ? (Guid?)null
                                                               : ValidationHelper.GetGuid(hdnRecId.Value)));

    }

    public bool GetSecurity()
    {
        if (!_userApproval.RefundStart)
        {
            QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOUHAVENOT_PERMISSION") + "');");

            return false;
        }
        return true;
    }

    protected void RefundIt(object sender, AjaxEventArgs e)
    {
        if (!_dynamicSecurity.PrvWrite)
        {
            _msg.Show(".", "", CrmLabel.TranslateMessage("CRM_RECORD_UPDATE_SECURITY"));
            return;
        }

        //var cf = new ConfirmFactory();
        //var ctype = string.Empty;
        //var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(hdnRecId.Value), null, out ctype);

        //var rf = new RefundFactory();

        if (!GetSecurity())
        {
            return;
        }

        ////Eger isme Gonderim Disinda Tamanlanan bir islem dahi olsa  hata verecek.
        //if
        //(
        //    (
        //        (
        //            (ctype == TransactionType.ISME_GONDERIM || ctype == TransactionType.HESABA_EFT_GONDERIM || ctype == TransactionType.SWIFT_GONDERIM)
        //            &&
        //            (ts == TuConfirmStatus.GonderimTamamlandi || ts == TuConfirmStatus.GonderimKaydiKurumaIletildi || ts == TuConfirmStatus.GonderimIslemiKurumdanIadesiIsteniyor || ts == TuConfirmStatus.GonderimOdemeAmlGecti)
        //        )
        //        ||
        //        (
        //            (ctype == TransactionType.HESABA_KURUMA_GONDERIM)
        //            &&
        //            (ts == TuConfirmStatus.GonderimTamamlandi || ts == TuConfirmStatus.GonderimKaydiKurumaIletildi || ts == TuConfirmStatus.GonderimTamamlandiOdemesiYapildi || ts == TuConfirmStatus.GonderimIslemiKurumdanIadesiIsteniyor || ts == TuConfirmStatus.GonderimOdemeAmlGecti)
        //        )
        //    ) == false
        //)
        //{
        //    _msg.Show(".", "", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
        //    return;
        //}



        //var refundReason = new UPTCacheObjects.RefundReason();

        var ret = string.Empty;
        var staticData = new StaticData();
        staticData.AddParameter("RefundReasonId", DbType.Guid, ValidationHelper.GetGuid(new_RefundReasonId.Value));

        string sql = @"select new_ExtCode
                           from vNew_RefundReason REF
                           where DeletionStateCode = 0 and REF.New_RefundReasonId = @RefundReasonId ";
        ret = ValidationHelper.GetString(staticData.ExecuteScalar(sql));

        if (ret == "004" && ValidationHelper.GetString(new_RefundReasonDescription.Value) == "")
        {
            QScript("alert('Iade Açıklamasını giriniz!');");
            return;
        }


        try
        {
            RefundTransferManager refundTransferManager = new RefundTransferManager();

            RefundTransfer refundTransfer = new RefundTransfer();
            refundTransfer.Transfer = new RefundTransferHelper().GetTransferDataForRefund(ValidationHelper.GetGuid(hdnRecId.Value));
            refundTransfer.RefundReason = new RefundReason()
            {
                RefundReasonId = ValidationHelper.GetGuid(new_RefundReasonId.Value),
                RefundSubReasonId = ValidationHelper.GetGuid(new_RefundSubReasonId.Value, Guid.Empty),
                RefundReasonText = new_RefundReasonDescription.Value
            };
            refundTransfer.RefundExpense = new_RefundExpense.Checked;
            refundTransfer.RefundExpenseReason = new RefundExpenseReason()
            {
                RefundExpenseReasonId = ValidationHelper.GetGuid(new_RefundExpenseReason.Value),
                RefundExpenseReasonText = new_RefundExpenseReasonDesc.Value
            };
            refundTransfer.Channel = (int)TuChannelTypeEnum.Ekran;
            refundTransfer.Corporation = new TuFactory.Domain.Corporation(App.Params.CurrentUser.CorporationId, true);
            refundTransfer.Office = new TuFactory.Domain.Office() { OfficeId = App.Params.CurrentUser.Office.OfficeId };

            RefundResponse response = refundTransferManager.RefundTransferRequest(refundTransfer);
            if (response.ResponseCode == RefundResponseCodes.Error)
            {
                _msg.Show("İade Gönderim / Refund Transfer", "", response.ResponseMessage);
                return;
            }
            else
            {
                if (response.ResponseCode == RefundResponseCodes.RefundTransferRequestCompleted)
                {
                    QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_REQUEST_OK") + "');");
                }
                else if (response.ResponseCode == RefundResponseCodes.RefundTransferConfirmCompleted)
                {
                    QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_CONFIRM_OK") + "');");
                }
            }

            //var corporationId = new RefundDb().GetCorporationIdByTransferId(ValidationHelper.GetGuid(hdnRecId.Value));
            //if (corporationId != Guid.Empty && corporationId == ValidationHelper.GetGuid(App.Params.GetConfigKeyValue("TK_NKOLAY_ID")))
            //{

            //    refundReason = UPT.Shared.CacheProvider.Service.RefundReasonService.GetRefundReasonByRefundReasonId(ValidationHelper.GetGuid(new_RefundReasonId.Value));

            //    if (refundReason != null && refundReason.TransactionType == (int)RefundReasonTransactionType.OnayliDevamEtsin)
            //    {
            //        rf.CreateRefundTransferRequest(ValidationHelper.GetGuid(hdnRecId.Value), ValidationHelper.GetGuid(new_RefundReasonId.Value),
            //            ValidationHelper.GetGuid(new_RefundSubReasonId.Value, Guid.Empty), new_RefundReasonDescription.Value, new_RefundExpense.Checked,
            //            ValidationHelper.GetGuid(new_RefundExpenseReason.Value), new_RefundExpenseReasonDesc.Value, null, string.Empty);
            //        QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_REQUEST_OK") + "');");
            //    }
            //    else if (refundReason != null && refundReason.TransactionType == (int)RefundReasonTransactionType.OnaysizDevamEtsin)
            //    {
            //        rf.CreateRefundTransferRequest(ValidationHelper.GetGuid(hdnRecId.Value), ValidationHelper.GetGuid(new_RefundReasonId.Value), ValidationHelper.GetGuid(new_RefundSubReasonId.Value, Guid.Empty), new_RefundReasonDescription.Value, new_RefundExpense.Checked, ValidationHelper.GetGuid(new_RefundExpenseReason.Value), new_RefundExpenseReasonDesc.Value, null, string.Empty);

            //        if (new_RefundExpense.Checked)
            //        {
            //            new RefundFactory().CreateRefundTransferConfirm(ValidationHelper.GetGuid(hdnRecId.Value), Guid.Empty, string.Empty, true, ValidationHelper.GetGuid(new_RefundExpenseReason.Value), new_RefundExpenseReasonDesc.Value, (int)TuChannelTypeEnum.Ekran);
            //        }
            //        else
            //        {
            //            new RefundFactory().CreateRefundTransferConfirm(ValidationHelper.GetGuid(hdnRecId.Value), Guid.Empty, string.Empty, false, Guid.Empty, string.Empty, (int)TuChannelTypeEnum.Ekran);
            //        }
            //        QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_CONFIRM_OK") + "');");
            //    }
            //}
            //else
            //{
            //    rf.CreateRefundTransferRequest(ValidationHelper.GetGuid(hdnRecId.Value), ValidationHelper.GetGuid(new_RefundReasonId.Value), ValidationHelper.GetGuid(new_RefundSubReasonId.Value, Guid.Empty), new_RefundReasonDescription.Value, new_RefundExpense.Checked, ValidationHelper.GetGuid(new_RefundExpenseReason.Value), new_RefundExpenseReasonDesc.Value, null, string.Empty);
            //    QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_REQUEST_OK") + "');");
            //}
        }
        catch (TuException ex)
        {
            _msg.Show(".", ex.ErrorMessage);
            return;
        }
        catch (Exception ex)
        {
            _msg.Show(".", "", CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_ERROR"));
            return;
        }

        QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
    }

    protected void RefundExpenseStatusChanged()
    {
        throw new Exception();
    }

    protected void new_RefundReasonIdOnEvent(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(new_RefundReasonId.Value))
        {
            RefundFactory rf = new RefundFactory();
            if (rf.RefundReasonHasSubReason(ValidationHelper.GetGuid(new_RefundReasonId.Value)))
            {
                new_RefundSubReasonId.SetVisible(true);
                new_RefundSubReasonId.Visible = true;
                new_RefundSubReasonId.Clear();
            }
            else
            {
                new_RefundSubReasonId.Clear();
                new_RefundSubReasonId.Visible = false;
                new_RefundSubReasonId.SetVisible(false);
            }
        }

    }
}