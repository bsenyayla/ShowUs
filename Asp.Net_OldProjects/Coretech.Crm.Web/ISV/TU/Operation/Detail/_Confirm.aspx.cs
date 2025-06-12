using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Info;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using TuFactory.Object.Confirm;
using TuFactory.Object.User;
using TuFactory.TuUser;
using TuFactory.Refund;
using TuFactory.Data;
using TuFactory.TransactionManagers.Refund.RefundTransfer;
using TuFactory.Domain.Refund;
using UPTCache = UPT.Shared.CacheProvider.Service;
using UPTCacheObjects = UPT.Shared.CacheProvider.Model;
using TuFactory.TransactionManagers.Refund;
using TuFactory.TransactionManagers.Refund.RefundTransfer.Cancel;
using TuFactory.Integration3rd;

public partial class Operation_Detail_Confirm : BasePage
{
    //CRM.NEW_TRANSACTIONCONFIRM_REJECT
    //
    //
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };

    private void TranslateMessages()
    {
        ToolbarButtonConfirm.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CONFIRM");
        ToolbarButtonReturn.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_RETURN");
        ToolbarButtonReturn1.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_RETURN");
        ToolbarButtonReject.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_REJECT");
        ToolbarButtonReject1.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_REJECT");
        ToolbarButtonRefundExpenseConfirm.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CONFIRM");
        btnTransfer.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSFEREDIT_SHOW_TRANSFER");

    }

    private void ReConfigureButtons()
    {
        if (!(_userApproval.ApprovalConfirm || _userApproval.ApprovalRefund))
        {
            ToolbarButtonConfirm.Visible = false;
        }
        if (!_userApproval.ApprovalReturn)
        {
            ToolbarButtonReturn.Visible = false;
            ToolbarButtonReturn1.Visible = false;
        }
        if (!(_userApproval.ApprovalReject || _userApproval.ApprovalRefund))
        {
            ToolbarButtonReject.Visible = false;
        }
    }

    protected void btnInformationOnEvent(object sender, AjaxEventArgs e)
    {
        var infoList = Info.GetEntityHelpsByName("MONITORING", this);
        if (infoList == null) return;
        var b = HttpContext.Current;
        b.Response.ClearContent();
        b.Response.ClearHeaders();
        b.Response.Clear();
        var f = new FileInfo(Server.MapPath(infoList.Command));
        var fs = File.Open(Server.MapPath(infoList.Command), FileMode.Open);

        var ms = new MemoryStream();
        fs.CopyTo(ms);

        var buffer = ms.ToArray();

        b.Response.AddHeader("Content-Disposition", string.Format(CultureInfo.InvariantCulture, "attachment; filename=\"{0}\"", new object[] { f.Name }));
        var length = buffer.Length;
        b.Response.AddHeader("ContentLength", length.ToString(CultureInfo.InvariantCulture));
        if (buffer.Length > 0)
        {
            b.Response.BinaryWrite(buffer);
        }
        b.Response.Flush();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        if (new_RejectmReasonId.DataContainer.DataSource.Columns.Count > 0)
        {
            new_RejectmReasonId.DataContainer.DataSource.Columns[0].Title = "Red Sebebi";
        }
        //_activeUser = ufFactory.GetActiveUser();

        if (!RefleX.IsAjxPostback)
        {
            ReConfigureButtons();
            TranslateMessages();
            hdnObjectId.Value = QueryHelper.GetString("objectid");
            hdnRecId.Value = QueryHelper.GetString("recid");
            var readonlyform = string.Empty;
            switch (ValidationHelper.GetInteger(hdnObjectId.Value))
            {
                case (int)TuEntityEnum.New_Transfer:
                    readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_PAGE"));
                    break;
                case (int)TuEntityEnum.New_Payment:
                    readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("PAYMENT_READONLY_PAGE"));
                    ToolbarButtonReturn.Visible = false;
                    break;
                case (int)TuEntityEnum.New_TransferEdit:
                    readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFEREDIT_DEFAULT_PAGE"));
                    break;
                case (int)TuEntityEnum.New_RefundPayment:
                    ToolbarButtonReturn.Visible = false;
                    break;
                case (int)TuEntityEnum.New_RefundTransfer:
                    var readonlyformTmp = ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_LITE_PAGE"));

                    var queryTmp = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyformTmp }
                                ,{"ObjectId", TuEntityEnum.New_Transfer.GetHashCode().ToString()}
                                //,{"noplugin", "1"}
                            };

                    var urlparamTmp = QueryHelper.AddUrlString("/CrmPages/AutoPages/EditReflex.aspx", queryTmp);
                    ClientScript.RegisterClientScriptBlock(typeof(string), "transferUrl", "var transferUrl=" + SerializeString(urlparamTmp) + ";", true);
                    ToolbarButtonReturn.Visible = false;

                    var df = new DynamicFactory(ERunInUser.CalingUser);
                    var de = df.RetrieveWithOutPlugin(TuEntityEnum.New_RefundTransfer.GetHashCode(), ValidationHelper.GetGuid(hdnRecId.Value),
                               new string[] { "new_RefundExpense", "new_RefundExpenseReason", "new_RefundExpenseReasonDesc", "new_IsRefundAmountModified" });
                    new_RefundExpense.SetValue(de.GetBooleanValue("new_RefundExpense"));
                    new_RefundExpenseReason.SetValue(de.GetLookupValue("new_RefundExpenseReason"));
                    new_RefundExpenseReasonDesc.SetValue(de.GetStringValue("new_RefundExpenseReasonDesc"));

                    //Transfer web servisi ile gelen iade gönderim talepleri, tutar degerini farkli kilabiliyor. Bu durumda, masraf duzenleme ihtiyacı yoktur.
                    if (de.GetBooleanValue("new_IsRefundAmountModified"))
                    {
                        ToolbarButtonConfirm.AjaxEvents.Click.Event += Confirm;
                        ToolbarButtonConfirm.Listeners.Click.Handler = "";
                    }
                    else
                    {
                        //Swift isleminde masraf iadesi yoksa, onayda tekrar sorulmaz.
                        string targetTransactionType = new TuFactory.Data.TransferDb().GetTransferTargetTransactionTypeByRefundTransfer(ValidationHelper.GetGuid(hdnRecId.Value));
                        if (!(targetTransactionType == "003" && !de.GetBooleanValue("new_RefundExpense")))
                        {
                            //Onayda masraf düzenleme penceresi açılacak.
                            ToolbarButtonConfirm.AjaxEvents.Click.Event -= Confirm;
                            ToolbarButtonConfirm.Listeners.Click.Handler = "windowRefundExpenseConfirm.show();";
                        }
                    }

                    break;
            }
            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyform},
                                {"ObjectId", hdnObjectId.Value},
                                {"recid", hdnRecId.Value}
                            };
            var urlparam = QueryHelper.RefreshUrl(query);
            hiddenUrl.Value = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            var cf = new ConfirmFactory();
            var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(hdnRecId.Value));
            switch (ts)
            {
                case TuConfirmStatus.GonderimDuzeltmeAltOnayBekleniyor:
                case TuConfirmStatus.GonderimDuzeltmeOnayiBekliyor:


                    var df = new DynamicFactory(ERunInUser.CalingUser);
                    var de = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(hdnRecId.Value),
                               new string[] { "new_TransferEditId" });
                    if (de.GetLookupValue("new_TransferEditId") != Guid.Empty)
                    {
                        readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFEREDIT_DEFAULT_PAGE"));

                        query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyform},
                                {"ObjectId", TuEntityEnum.New_TransferEdit.GetHashCode().ToString()},
                                {"recid", de.GetLookupValue("new_TransferEditId").ToString()}
                            };
                        PanelIframe.Height = 480;
                        urlparam = QueryHelper.RefreshUrl(query);
                        PanelIframe.AutoLoad.Url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);

                    }
                    break;
                default:
                    PanelIframe.AutoLoad.Url = hiddenUrl.Value;
                    PanelIframe.Buttons.Clear();
                    btnTransfer.Visible = false;
                    break;

            }

        }

    }

    private TuConfirmList GetRejectList()
    {
        return new TuConfirmList()
        {
            ConfirmReasonId = ValidationHelper.GetGuid(new_RejectmReasonId.Value),
            Description = new_RejectReasonDescription.Value,
            ObjectId = ValidationHelper.GetInteger(hdnObjectId.Value, 0),
            RecId = ValidationHelper.GetGuid(hdnRecId.Value),
            ActivePage = Page
        };
    }

    private TuConfirmList GetConfirmList()
    {
        return new TuConfirmList()
        {
            ConfirmReasonId = ValidationHelper.GetGuid(new_ConfirmReasonId.Value),
            Description = new_ConfirmReasonDescription.Value,
            ObjectId = ValidationHelper.GetInteger(hdnObjectId.Value, 0),
            RecId = ValidationHelper.GetGuid(hdnRecId.Value),
            ActivePage = Page
        };
    }

    private bool SetConfirm(List<TuConfirmList> cl)
    {
        var cf = new ConfirmFactory();
        var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(hdnRecId.Value));
        switch (ts)
        {
            case TuConfirmStatus.GonderimOnayiBekliyor:
            case TuConfirmStatus.GonderimAltOnayBekleniyor:

            case TuConfirmStatus.OdemeOnayBekliyor:
            case TuConfirmStatus.OdemeAltOnayBekliyor:

            case TuConfirmStatus.IadeOdemeOnayBekliyor:
            case TuConfirmStatus.IadeOdemeAltOnayBekliyor:
                break;
            case TuConfirmStatus.GonderimDuzeltmeAltOnayBekleniyor:
            case TuConfirmStatus.GonderimDuzeltmeOnayiBekliyor:
                for (var i = 0; i < cl.Count; i++)
                {
                    var df = new DynamicFactory(ERunInUser.CalingUser);
                    var de = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), cl[i].RecId,
                                new string[] { "new_TransferEditId" });
                    if (de.GetLookupValue("new_TransferEditId") != Guid.Empty)
                    {
                        cl[i].ObjectId = TuEntityEnum.New_TransferEdit.GetHashCode();
                        cl[i].RecId = de.GetLookupValue("new_TransferEditId");
                    }

                }
                break;
            default:
                _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
                return false;
                break;
        }


        List<TuConfirmList> new_ConfirmList = new List<TuConfirmList>();
        bool hasOutFile = false;
        foreach (var confirmList in cl)
        {
            if (confirmList.ObjectId == (int)TuEntityEnum.New_Transfer && confirmList.Approval == ETuUserApproval.Confirm)
            {
                var trs = cf.GetTransactionStatus(confirmList.ObjectId, confirmList.RecId);
                if (trs == TuConfirmStatus.GonderimIptalOnayBekliyor)
                {
                    ConfirmDb cdb = new ConfirmDb();
                    var isOut = cdb.GetTransferIsCancelFileOut(confirmList.RecId);
                    if (!isOut)
                    {
                        new_ConfirmList.Add(confirmList);
                    }
                    else
                    {
                        if (_userApproval.RunAsManuel)
                        {
                            new_ConfirmList.Add(confirmList);
                        }
                        else
                        {
                            hasOutFile = true;
                        }
                    }
                }
                else
                {
                    new_ConfirmList.Add(confirmList);
                }

            }
            else if (confirmList.ObjectId == (int)TuEntityEnum.New_RefundTransfer && confirmList.Approval == ETuUserApproval.Confirm)
            {
                var trs = cf.GetTransactionStatus(confirmList.ObjectId, confirmList.RecId);
                if (trs == TuConfirmStatus.IadeGonderimOnayBekliyor)
                {
                    ConfirmDb cdb = new ConfirmDb();
                    var isOut = cdb.GetTransferIsCancelFileOut(confirmList.RecId);
                    if (!isOut)
                    {
                        new_ConfirmList.Add(confirmList);
                    }
                    else
                    {
                        if (_userApproval.RunAsManuel)
                        {
                            new_ConfirmList.Add(confirmList);
                        }
                        else
                        {
                            hasOutFile = true;
                        }
                    }
                }
            }
            else //Odeme iptallerinde hata aliyorduk, eskisi gibi calismasi icin bunu ekledim.
            {
                new_ConfirmList.Add(confirmList);
            }
        }


        try
        {
            if (new_ConfirmList.Count > 0)
            {
                var config = new Coretech.Crm.Objects.Crm.Plugin.PluginBaseConfig { ActivePage = this };
                cf.Confirm(new_ConfirmList, config);
                for (int indexOfConfirmList = 0; indexOfConfirmList < new_ConfirmList.Count; indexOfConfirmList++)
                {
                    TuFactory.Utility.ReportParamWriter.UpdateReportRecipientParameter(new_ConfirmList[indexOfConfirmList].RecId, null);
                }

                /*
                TuFactory.Data.PostMessage pm = new TuFactory.Data.PostMessage();
                pm.AddPostMessageTransferCorrectionApproved(ValidationHelper.GetGuid(QueryHelper.GetString("recid")), App.Params.CurrentUser.SystemUserId, null);
                */
                

                cf.AfterConfirm(new_ConfirmList, ETuConfirmType.Transaction);

            }
            else
            {
                _msg.Show(".", ".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOU_HAVENOT_CANCELFILECONFIRMAUTHORY"));
                return false;
            }
        }
        catch (InvalidOperationException ioe)
        {
            BasePage.QScript("alert('" + ioe.Message + "');");
            BasePage.QScript("RefreshParetnGrid(true);");
            return false;
        }
        catch (TuException ex)
        {
            _msg.Height = 250;
            _msg.Width = 450;


            _msg.Show("", "ErrorId: " + ex.ErrorCode + " - " + ex.ErrorMessage);
            //ex.ShowErrorId();
            return false;
        }
        catch (Exception ex)
        {
            var errorId = LogUtil.WriteException(ex);
            var tux = new TuException(ex.Message, errorId.ToString()) { ErrorId = errorId };
            tux.ShowErrorId();
            //_msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            return false;
        }
        return true;
    }

    private void BankDepositEftCancel(Guid recId)
    {
        var i3Rd = new Integration3Rd();
        try
        {
            var paymentNoticeResponse = i3Rd.CancelPaymentOrder(recId);
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "ConfirmFactory.BankDepositEftCancel");
        }

        LogUtil.Write(string.Format("{0} transferId için PaymentNotice(Canceled) çağrıldı", recId), "i3Rd.CancelPaymentOrder");
    }


    protected void Confirm(object sender, AjaxEventArgs e)
    {
        try
        {
            if (!_userApproval.ApprovalConfirm && !_userApproval.ApprovalRefund)
                return;

            var ret = false;

            if (ValidationHelper.GetInteger(hdnObjectId.Value) != (int)TuEntityEnum.New_RefundTransfer)
            {
                var cl = new List<TuConfirmList>();
                var clitem = GetConfirmList();
                clitem.Approval = ETuUserApproval.Confirm;
                cl.Add(clitem);
                ret = SetConfirm(cl);

                
            }
            else
            {
                DynamicFactory df = new DynamicFactory(ERunInUser.CalingUser);
                DynamicEntity de = df.Retrieve(TuEntityEnum.New_RefundTransfer.GetHashCode(), ValidationHelper.GetGuid(QueryHelper.GetString("recid")), new string[] { "new_TransferId" });


                bool hasOutFile = false;

                ConfirmDb cdb = new ConfirmDb();
                var isOut = cdb.GetRefundTransferIsFileOut(de.GetLookupValue("new_TransferId"));
                if (!isOut)
                {
                    //new_refundTransferConfirmList.Add(refundtransferItem);
                }
                else
                {
                    if (_userApproval.RunAsManuel)
                    {
                        //new_refundTransferConfirmList.Add(refundtransferItem);
                    }
                    else
                    {
                        hasOutFile = true;
                    }
                }

                if (!hasOutFile)
                {
                    var cf = new ConfirmFactory();
                    var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(hdnRecId.Value));
                    if (ts != TuConfirmStatus.IadeGonderimOnayBekliyor)
                    {
                        _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
                        ret = false;
                        return;
                    }




                    



                    RefundTransferManager refundTransferManager = new RefundTransferManager();
                    RefundTransfer refundTransfer = new RefundTransferHelper().GetRefundTransferByRefundTransferId(ValidationHelper.GetGuid(QueryHelper.GetString("recid")));

                    UPTCacheObjects.RefundReason refundReason = UPTCache.RefundReasonService.GetRefundReasonByRefundReasonId(ValidationHelper.GetGuid(new_RefundExpenseReason.Value));
                    if (refundReason != null)
                    {
                        refundTransfer.RefundReason = new RefundReason()
                        {
                            RefundReasonId = refundReason.RefundReasonId,
                            RefundReasonCode = refundReason.ExtCode,
                            RefundReasonText = new_RefundExpenseReasonDesc.Value
                        };
                    }
                    refundTransfer.RefundExpense = new_RefundExpense.Checked;
                    refundTransfer.Channel = (int)TuChannelTypeEnum.Ekran;

                    RefundResponse response = refundTransferManager.RefundTransferConfirm(refundTransfer);
                    if (response.ResponseCode != RefundResponseCodes.Error)
                    {
                        BankDepositEftCancel(refundTransfer.Transfer.TransferId);

                        ret = true;
                    }
                    else
                    {
                        _msg.Show(".", ".", response.ResponseMessage);
                        ret = false;
                    }

                    //if (new_RefundExpense.Checked)
                    //{
                    //    new RefundFactory().CreateRefundTransferConfirm(de.GetLookupValue("new_TransferId"), Guid.Empty, string.Empty, true, ValidationHelper.GetGuid(new_RefundExpenseReason.Value), new_RefundExpenseReasonDesc.Value, (int)TuChannelTypeEnum.Ekran);
                    //    ret = true;
                    //}
                    //else
                    //{
                    //    new RefundFactory().CreateRefundTransferConfirm(de.GetLookupValue("new_TransferId"), Guid.Empty, string.Empty, false, Guid.Empty, string.Empty, (int)TuChannelTypeEnum.Ekran);
                    //    ret = true;
                    //}
                }
                else
                {
                    _msg.Show(".", ".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOU_HAVENOT_CANCELFILECONFIRMAUTHORY"));
                    ret = false;
                }
            }

            if (ret)
            {
                QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CONFIRMED") + "');");
                // QScript("Frame_PanelIframe.SpecialRefreshParentGrid();");
                QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
            }
        }
        catch (TuException ex)
        {
            ex.ShowErrorId();
        }
        catch (Exception ex)
        {
            var errorId = LogUtil.WriteException(ex);
            var tux = new TuException(ex.Message, errorId.ToString()) { ErrorId = errorId };
            tux.ShowErrorId();
        }
    }

    protected void Return(object sender, AjaxEventArgs e)
    {
        if (!_userApproval.ApprovalConfirm)
            return;

        var cl = new List<TuConfirmList>();
        var clitem = GetConfirmList();
        clitem.Approval = ETuUserApproval.Return;
        cl.Add(clitem);
        var ret = SetConfirm(cl);

        if (ret)
        {
            QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_RETURNED") + "');");
            //QScript("Frame_PanelIframe.SpecialRefreshParentGrid();");
            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
        }
    }

    protected void Reject(object sender, AjaxEventArgs e)
    {
        if (!_userApproval.ApprovalConfirm && !_userApproval.ApprovalRefund)
            return;

        var ret = false;
        if (ValidationHelper.GetInteger(hdnObjectId.Value) != (int)TuEntityEnum.New_RefundTransfer)
        {
            var cl = new List<TuConfirmList>();
            var clitem = GetRejectList();
            clitem.Approval = ETuUserApproval.Reject;
            cl.Add(clitem);
            ret = SetConfirm(cl);
        }
        else
        {
            RefundTransferCancelManager refundTransferCancelManager = new RefundTransferCancelManager();
            RefundTransferCancel refundTransferCancel = new RefundTransferCancel();
            refundTransferCancel.CancelType = RefundTransferCancelTypes.Reject;
            refundTransferCancel.RefundTransfer = new RefundTransfer() { RefundTransferId = ValidationHelper.GetGuid(QueryHelper.GetString("recid")) };
            refundTransferCancel.CancelReason = new TuFactory.Domain.ConfirmReason() { ConfirmReasonId = ValidationHelper.GetGuid(new_RejectmReasonId.Value) };
            refundTransferCancel.CancelReasonText = new_RejectReasonDescription.Value;
            RefundResponse response = refundTransferCancelManager.CancelRefundTransfer(refundTransferCancel);
            ret = response.ResponseCode == RefundResponseCodes.RefundTransferCancelConfirmCompleted;
            if (ret == false)
            {
                _msg.Show(".", ".", response.ResponseMessage);
                return;
            }

            //new RefundFactory().CancelRefundTransfer(ValidationHelper.GetGuid(QueryHelper.GetString("recid")), ValidationHelper.GetGuid(new_RejectmReasonId.Value), new_RejectReasonDescription.Value);
            //ret = true;
        }

        if (ret)
        {
            QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_RETURNED") + "');");
            //QScript("Frame_PanelIframe.SpecialRefreshParentGrid();");
            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
        }
    }
}