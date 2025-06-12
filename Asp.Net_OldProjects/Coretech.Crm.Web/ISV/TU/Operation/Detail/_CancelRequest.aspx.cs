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
using TuFactory.TuUser;
using TuFactory.Transfer;
using TuFactory.Data;
using UPT.Shared.Service.User.Service;
using TuFactory.TransactionManagers.Refund.RefundTransfer.Cancel;
using TuFactory.Domain.Refund;
using TuFactory.TransactionManagers.Refund;
using TuFactory.ExtensionManager;
using TuFactory.ExtensionManager.Services;
using TuFactory.TransactionManagers.Cancel.Domains;
using TuFactory.TransactionManagers.Cancel.Result;
using TuFactory.TransactionManagers.Cancel;
using System.Data;
using Coretech.Crm.PluginData;

public partial class Operation_Detail_CancelRequest : BasePage
{
    //CRM.NEW_TRANSACTIONCONFIRM_REJECT
    //
    //
    private TuUserApproval _userApproval = null;
    private DynamicSecurity _dynamicSecurity;
    private TuUser _activeUser = null;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };

    private void TranslateMessages()
    {
        ToolbarButtonConfirm.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CANCEL_REQUEST");
    }

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

        if (!RefleX.IsAjxPostback)
        {
            hdnObjectId.Value = QueryHelper.GetString("objectid");
            hdnRecId.Value = QueryHelper.GetString("recid");
            GetSecurity();

            var cf = new ConfirmFactory();
            var ctype = string.Empty;
            var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(hdnRecId.Value), null, out ctype);
            if (
                (ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_Transfer.GetHashCode() && ts == TuConfirmStatus.GonderimYeniKayitHataAldiBekliyor)
                ||
                (ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_Payment.GetHashCode() && ts == TuConfirmStatus.OdemeAmlGecti)
                )
            {
                BasePage.QScript("trStatus = '" + ts + "';");
            }


            if (ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_Transfer.GetHashCode())
            {
                TransferDb tdb = new TransferDb();
                bool cancelPoolNotDisplatCorporation = tdb.GetCancelPoolNotDisplayCorporation(ValidationHelper.GetGuid(hdnRecId.Value));
                if(cancelPoolNotDisplatCorporation)
                {
                    ToolbarButtonConfirm.Text = "Seçili kurumun işlemini iptal edemezsiniz.";
                    ToolbarButtonConfirm.SetDisabled(true);
                }

                string targetTransactionTypeCode = tdb.GetTransferTargetTransactionTypeCode(ValidationHelper.GetGuid(hdnRecId.Value));
                if ((targetTransactionTypeCode == "002" || targetTransactionTypeCode == "003") && !ValidationHelper.GetBoolean(new ParametertDb().getParameterValue("EFT_CANCELABLE"), false))
                {
                    ToolbarButtonConfirm.Visible = false;
                }
                else if (targetTransactionTypeCode == TransactionType.HESABA_KURUMA_GONDERIM && !_userApproval.SepaRefundStart)
                {
                    ToolbarButtonConfirm.Visible = false;
                }
                else if (targetTransactionTypeCode == TransactionType.SWIFT_GONDERIM || targetTransactionTypeCode == TransactionType.YP_HAVALE)
                {
                    ToolbarButtonConfirm.Visible = false;
                }
                else
                {
                    ToolbarButtonConfirm.Visible = true;
                }
            }


            //Kullanıcı, kendi ofisine ait kayıtların iptal/iade/düzeltme işlemlerini yapabilir.
            if (_userApproval.OfficeCancelReturnEditPermit)
            {
                TransferDb transferService = new TransferDb();
                UserService userService = new UserService();
                Guid transferOfficeID = transferService.GetTransferOfficeID(ValidationHelper.GetGuid(hdnRecId.Value));
                Guid userOfficeID = userService.GetOfficeID(App.Params.CurrentUser.SystemUserId, null);

                //Kullanıcı ofisi, transferin ofisi ile aynı değilse buton görünmez.
                if (userOfficeID != transferOfficeID)
                    ToolbarButtonConfirm.Visible = false;
            }

            var readonlyform = string.Empty;
            switch (ValidationHelper.GetInteger(hdnObjectId.Value))
            {
                case (int)TuEntityEnum.New_Transfer:
                    readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_PAGE"));
                    break;
                case (int)TuEntityEnum.New_Payment:
                    readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("PAYMENT_READONLY_PAGE"));
                    break;
                case (int)TuEntityEnum.New_RefundTransfer:
                    var readonlyformTmp = ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_PAGE"));

                    var queryTmp = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyformTmp },
                                {"ObjectId", TuEntityEnum.New_Transfer.GetHashCode().ToString()},
                            };
                    var urlparamTmp = QueryHelper.AddUrlString("/CrmPages/AutoPages/EditReflex.aspx", queryTmp);
                    ClientScript.RegisterClientScriptBlock(typeof(string), "transferUrl", "var transferUrl=" + SerializeString(urlparamTmp) + ";", true);

                    break;
            }
            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyform},
                                {"ObjectId", hdnObjectId.Value},
                                {"recid", hdnRecId.Value}
                            };
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
        var cf = new ConfirmFactory();
        var isnew = cf.GetCancelValidDate(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                              ValidationHelper.GetGuid(hdnRecId.Value));
        if (!isnew)
        {
            if (!_userApproval.CancelStartOldDate)
            {
                QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOUHAVENOT_PERMISSION") + "');");

                return false;
            }
        }
        if (!_userApproval.CancelStart)
        {
            QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOUHAVENOT_PERMISSION") + "');");

            return false;
        }
        return true;
    }

    protected void CancelRequest_old(object sender, AjaxEventArgs e)
    {
        if (ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_RefundTransfer.GetHashCode())
        {
            CancelRefundTransfer();
            return;
        }

        var cf = new ConfirmFactory();
        var ctype = string.Empty;
        var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(hdnRecId.Value), null, out ctype);
        try
        {
            /*Gönderim Yeni Kayıt (Hata aldı bekliyor) statüsündeki işlemleri ayrı bir akıştan iptal edebilmek için eklendi.*/
            if (ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_Transfer.GetHashCode() && ts == TuConfirmStatus.GonderimYeniKayitHataAldiBekliyor)
            {
                TransferWSCancelRequestFactory cancelfactory = new TransferWSCancelRequestFactory();
                cancelfactory.CancelTR000ETransactions(ValidationHelper.GetGuid(hdnRecId.Value));
                QScript("alert('Gönderim işlemi iptal edilmiştir.');");
                QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
                return;
            }
            else if (ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_Payment.GetHashCode() && ts == TuConfirmStatus.OdemeAmlGecti)
            {
                TransferWSCancelRequestFactory cancelfactory = new TransferWSCancelRequestFactory();
                string ret = cancelfactory.CancelPA004APayment(ValidationHelper.GetGuid(hdnRecId.Value));

                if (string.IsNullOrEmpty(ret))
                {
                    QScript("alert('ödeme işlemi iptal edilmiştir.');");
                }
                else
                {
                    QScript("alert('İşlem kurum havuzundan iptal edilirken hata aldı. Hata: " + ret + "');");
                }

                QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
                return;
            }
        }
        catch (TuException ex)
        {
            ex.Show();
            return;
        }

        try
        {
            var errordata = string.Empty;
            var ret = false;
            if (IfTransferPayment())
            {
                /*Daha Bitmedi*/
                if (ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_Transfer.GetHashCode())
                {
                    ConfirmDb cdb = new ConfirmDb();
                    string banka_islem_no;
                    string tuRef = cdb.GetTransferTuref(ValidationHelper.GetGuid(hdnRecId.Value), out banka_islem_no);

                    TransferWSCancelRequestFactory cancelfac = new TransferWSCancelRequestFactory();
                    WSCancelCheck obj = new WSCancelCheck() { ISLEM_TIPI = "G", TU_REFERANS = tuRef, BANKA_ISLEM_NO = 0 };
                    WSCancelCheckOut cRet = cancelfac.CancelCheck(obj);

                    if (cRet.IsCancellable == "H")
                    {
                        _msg.Show(".", "", cRet.OutStatus.RESPONSE_DATA);
                        return;
                    }
                }

                /*Daha Bitmedi*/
                ret = cf.CheckAccountingCancelRequest(ValidationHelper.GetGuid(hdnRecId.Value),
                                                      ValidationHelper.GetInteger(hdnObjectId.Value, 0), null,
                                                      out errordata);
            }

            TuFactory.Data.TransferDb td = new TuFactory.Data.TransferDb();
            string channel = td.GetChannelByTransferId(ValidationHelper.GetGuid(hdnRecId.Value));
            if (channel == "4")/*4-Ptt İşlemi*/
            {
                _msg.Show(".", "", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_ONLY_PTT_CANCEL"));
                return;
            }

            if (errordata != string.Empty)
                throw new TuException { ErrorMessage = errordata };
        }
        catch (TuException ex)
        {
            ex.Show();
            return;
        }
        catch (Exception)
        {
            _msg.Show(".", "", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            return;
        }

        if (!GetSecurity())
            return;

        switch (ts)
        {
            case TuConfirmStatus.OdemeOnayaGonderildi:
            case TuConfirmStatus.OdemeYeniKayit:
            case TuConfirmStatus.OdemeOnayRedEdildi:
            case TuConfirmStatus.OdemeOnayGeriCevrildi:
            case TuConfirmStatus.OdemeOnayBekliyor:
            case TuConfirmStatus.OdemeOnayli:
            case TuConfirmStatus.OdemeTamamlandi:

            case TuConfirmStatus.GonderimOnayaGonderildi:
            case TuConfirmStatus.GonderimYeniKayit:

            case TuConfirmStatus.GonderimTamamlandi:
            case TuConfirmStatus.GonderimOdemeAmlGecti:
            case TuConfirmStatus.GonderimOnayGeriCevrildi:
            case TuConfirmStatus.GonderimOnayli:
            case TuConfirmStatus.GonderimAltOnayBekleniyor:
            case TuConfirmStatus.GonderimOnayiBekliyor:
            case TuConfirmStatus.IadeGonderimTamamlandi:
            case TuConfirmStatus.IadeOdemeTamamlandi:
            case TuConfirmStatus.GonderimKaydiKurumaIletildi:
            case TuConfirmStatus.GonderimYeniKayitHataAldiBekliyor:
                break;
            default:
                _msg.Show(".", "", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
                return;
                break;
        }

        try
        {
            if (IfTransferPayment())
            {
                if (ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("WITH_EXTENSION_MANAGER")) == true)
                {
                    if (ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_Payment.GetHashCode()
                        && ts == TuConfirmStatus.OdemeTamamlandi)
                    {
                        var extensionDb = new ExtensionDb();

                        var payment = new TuFactory.Business.Data.Payment().GetPayment(ValidationHelper.GetGuid(hdnRecId.Value), true);

                        bool isCorporationAvailable = extensionDb.GetExtensionMappingByCorporationId(payment.PaidByCorporation.CorporationId);
                        //Zaten ekran burası channel kontrolüne gerek yok
                        if (isCorporationAvailable == true)
                        {
                            var transactionService = new TransactionService<TuFactory.Domain.Payment>(TuFactory.ExtensionManager.Model.TransactionTypeCodeEnum.PYC, TuFactory.ExtensionManager.Model.CustomerAmountDirectionEnum._Negative, TuFactory.ExtensionManager.Model.Operation.OnValidatePayment);
                            var transactionServiceResult = transactionService.Request(payment);
                            if (!transactionServiceResult.ReturnCode)
                            {
                                LogUtil.Write(transactionServiceResult.ReturnData, "_CancelRequest.aspx");
                                throw new TuException { ErrorMessage = transactionServiceResult.ReturnData, ErrorCode = transactionServiceResult.ReturnCode.ToString() };
                            }
                        }
                    }

                    if (ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_RefundPayment.GetHashCode() && ts == TuConfirmStatus.IadeOdemeTamamlandi)
                    {
                        var extensionDb = new ExtensionDb();
                        var refundPayment = new TuFactory.Business.Data.Refund().GetRefundPayment(ValidationHelper.GetGuid(hdnRecId.Value));

                        bool isCorporationAvailable = extensionDb.GetExtensionMappingByCorporationId(refundPayment.RefundCorporation.CorporationId);
                        //Zaten ekran burası channel kontrolüne gerek yok
                        if (isCorporationAvailable == true)
                        {
                            var transactionService = new TransactionService<TuFactory.Domain.Refund.RefundPayment>(TuFactory.ExtensionManager.Model.TransactionTypeCodeEnum.RPC, TuFactory.ExtensionManager.Model.CustomerAmountDirectionEnum._Negative, TuFactory.ExtensionManager.Model.Operation.OnValidateRefundPayment);
                            var transactionServiceResult = transactionService.Request(refundPayment);
                            if (!transactionServiceResult.ReturnCode)
                            {
                                throw new TuException { ErrorMessage = transactionServiceResult.ReturnData, ErrorCode = transactionServiceResult.ReturnCode.ToString() };
                            }
                        }
                    }
                }

                cf.CreateTransactionCancelConfirmLine(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(hdnRecId.Value));


            }
        }
        catch (TuException ex)
        {
            _msg.Show(".", ex.ErrorMessage);
            return;
        }
        catch (Exception ex)
        {
            _msg.Show(".", "", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR") + ex.Message);
            return;
        }

        if (IfTransferPayment())
        {
            QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CANCEL_REQUEST_OK") + "');");
        }
        else
        {
            QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_CANCELED") + "');");
        }

        QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
    }

    protected void CancelRequest(object sender, AjaxEventArgs e)
    {
        
        if (ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_RefundTransfer.GetHashCode())
        {
            CancelRefundTransfer();
            return;
        }

        if (ValidationHelper.GetGuid(new_CancelReason.Value, Guid.Empty) == Guid.Empty)
        {
            QScript("alert('İptal Sebebini giriniz!');");
            return;
        }

        
        
        

            var ret = string.Empty;
            var staticData = new StaticData();
            staticData.AddParameter("RefundReasonId", DbType.Guid, ValidationHelper.GetGuid(new_CancelReason.Value));

            string sql = @"select new_ExtCode
                           from vNew_RefundReason REF
                           where DeletionStateCode = 0 and REF.New_RefundReasonId = @RefundReasonId ";
            ret = ValidationHelper.GetString(staticData.ExecuteScalar(sql));

            if (ret == "004" && ValidationHelper.GetString(new_CancelExplanation.Value) == "")
            {
                QScript("alert('İptal Açıklamasını giriniz!');");
                return;
            }
            
        
       
        #region Cancel Manager
        Guid cancelReason = ValidationHelper.GetGuid(new_CancelReason.Value);
        string cancelExplanation = ValidationHelper.GetString(new_CancelExplanation.Value);

        TransactionDto transferDto = new TransactionDto(ValidationHelper.GetGuid(hdnRecId.Value), ValidationHelper.GetInteger(hdnObjectId.Value, 0), ExecutionChannel.WEBUI, OperationType.Check, cancelReason, cancelExplanation);

        var transactionCancelManager = new TransactionCancelManager<bool, bool, bool>(transferDto, _userApproval);

        Either<bool, List<Error>> checkResult = new Either<bool, List<Error>>(false);
        Either<bool, List<Error>> requestResult = new Either<bool, List<Error>>(false);
        #endregion

        checkResult = transactionCancelManager.Check();

        checkResult.Evaluate(
            result => //Success
            {
                transferDto.OperationType = OperationType.Request;
                requestResult = transactionCancelManager.Request();
            },
            error => EvaluateResult(error) //error
            );

        if (checkResult.GetResponse() == true)
        {
            requestResult.Evaluate(
                result => FinishRequest(),//Success
                error => EvaluateResult(error));//error
        }
    }

    private void FinishRequest()
    {
        if (IfTransferPayment())
        {
            QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CANCEL_REQUEST_OK") + "');");
        }
        else
        {
            QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_CANCELED") + "');");
        }

        QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
    }

    private void EvaluateResult(List<Error> error)
    {
        if (error != null)
        {
            foreach (var item in error)
            {
                switch (item.ErrorType)
                {
                    case ErrorType.Script:
                        QScript(item.ErrorMessage);
                        break;
                    case ErrorType.String:
                    case ErrorType.TuException:
                        var message = item.TuException == null ? item.ErrorMessage : item.TuException.ErrorMessage;
                        _msg.Height = 250;
                        _msg.Width = 400;
                        _msg.Show(".", message);
                        break;
                    default:
                        break;
                }
            }
        }
    }

    void CancelRefundTransfer()
    {
        try
        {
            RefundTransferCancelManager refundTransferCancelManager = new RefundTransferCancelManager();
            RefundTransferCancel refundTransferCancel = new RefundTransferCancel();
            refundTransferCancel.CancelType = RefundTransferCancelTypes.Cancel;
            refundTransferCancel.RefundTransfer = new RefundTransfer() { RefundTransferId = ValidationHelper.GetGuid(QueryHelper.GetString("recid")) };
            RefundResponse response = refundTransferCancelManager.CancelRefundTransfer(refundTransferCancel);
            if (response.ResponseCode == RefundResponseCodes.Error)
            {
                _msg.Show(".", ".", response.ResponseMessage);
                return;
            }
            //var rf = new RefundFactory();
            //rf.CancelRefundTransfer(ValidationHelper.GetGuid(hdnRecId.Value), Guid.Empty, string.Empty); /*Hatada TuException Dönüyor o da Show ediliyor.*/
        }
        catch (TuException ex)
        {
            _msg.Show(".", ex.ErrorMessage);
            return;
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "CancelRequestPage.CancelRefundTransfer");
            _msg.Show(".", "", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            return;
        }

        QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_CANCELED") + "');");
        QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
    }

    private bool IfTransferPayment()
    {
        return ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_Transfer.GetHashCode() ||
        ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_Payment.GetHashCode() ||
        ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_TransferEdit.GetHashCode() ||
        ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_RefundPayment.GetHashCode()
        ;
    }
}