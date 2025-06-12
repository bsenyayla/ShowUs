using System;
using System.Collections.Generic;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Integration3rd;
using TuFactory.Object;
using TuFactory.Object.Confirm;
using TuFactory.Object.User;
using TuFactory.Reports;
using TuFactory.TuUser;
using TuFactory.Data;
using TuFactory.Transfer;
using Coretech.Crm.PluginData;
using System.Data;
using TuFactory.Confirm.Objects;
using TuFactory.CreditCheck;
using UPT.Shared.Service.User.Service;
using TuFactory.Refund;
using TuFactory.TransactionManagers.Transfer;

public partial class Operation_Detail_Receipt : BasePage
{
    private readonly ConfirmFactory cf = new ConfirmFactory();
    private readonly MessageBox ms = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private TuUserApproval _userApproval = null;

    protected void Page_Load(object sender, EventArgs e)
    {
        hdndoReceipt.Value = QueryHelper.GetString("doReceipt");

        var ufFactory = new TuUserFactory();
        ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        var dynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_TransferEdit.GetHashCode(), null);

        var dynamicSecurityMobileDocument = DynamicFactory.GetSecurity(TuEntityEnum.New_MobileDocument.GetHashCode(), null);

        if (!RefleX.IsAjxPostback)
        {


            TranslateMessages();
            hdnObjectId.Value = QueryHelper.GetString("objectid");
            hdnRecid.Value = QueryHelper.GetString("recid");
            hdndoReceipt.Value = QueryHelper.GetString("doReceipt");
            hdndoReceiptEdit.Value = QueryHelper.GetString("doReceiptEdit");
            hdnpoolId.Value = QueryHelper.GetString("PoolId");

            var poolId = QueryHelper.GetInteger("PoolId", 0);
            var readonlyform = string.Empty;
            switch (ValidationHelper.GetInteger(hdnObjectId.Value))
            {
                case (int)TuEntityEnum.New_Transfer:
                    readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_PAGE"));
                    hdnEntityId.Value = App.Params.CurrentEntity[TuEntityEnum.New_Transfer.GetHashCode()].EntityId.ToString();
                    break;
                case (int)TuEntityEnum.New_Payment:
                    readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("PAYMENT_READONLY_PAGE"));
                    hdnEntityId.Value = App.Params.CurrentEntity[TuEntityEnum.New_Payment.GetHashCode()].EntityId.ToString();
                    ToolbarButtonLog.Hide();
                    break;
            }
            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyform},
                                {"ObjectId", hdnObjectId.Value},
                                {"recid", hdnRecid.Value}
                            };
            string urlparam = QueryHelper.RefreshUrl(query);
            PanelIframe.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);

            QScript("CheckDoReceipt();");

            var ds = DynamicFactory.GetSecurity(TuEntityEnum.New_TransferEdit.GetHashCode(), null);
            string transactionType;
            var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
             ValidationHelper.GetGuid(hdnRecid.Value), null, out transactionType);
            var message = "";
            switch (ts)
            {
                case TuConfirmStatus.IadeGonderimOnaylandi:
                    message = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_REFUNDTRANSFER_HAS_COMPLETED"); break;
                case TuConfirmStatus.GonderimOnayli:
                    message = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TRANSFER_HAS_COMPLETED"); break;
                case TuConfirmStatus.OdemeOnayli:
                    message = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_PAYMENT_HAS_COMPLETED"); break;
                case TuConfirmStatus.IadeOdemeOnayli:
                    message = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_REFUNDPAYMENT_HAS_COMPLETED"); break;
                case TuConfirmStatus.GonderimDuzeltmeOnayli:
                    message = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TRANSFEREDIT_HAS_COMPLETED"); break;
                default:
                    message = TuConfirmStatus.GetConfirmStatusString(ts);
                    break;
            }
            hdnOnayMessage.Value = message;

            if (dynamicSecurityMobileDocument.PrvRead)
            {
                BtnTransferDocumentShow.Visible = true;
            }
            else
            {
                BtnTransferDocumentShow.Visible = false;
            }

            if (ds.PrvAppend)
            {
                if (ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_Transfer.GetHashCode())
                {


                    if ((ts == TuConfirmStatus.GonderimKaydiKurumaIletildi || ts == TuConfirmStatus.GonderimTamamlandi || ts == TuConfirmStatus.GonderimDuzeltmeOnayGeriCevrildi) && transactionType == TransactionType.ISME_GONDERIM)
                    {
                        if (dynamicSecurity.PrvAppend)
                        {
                            ToolbarButtonEdit.Visible = true;
                            ToolbarButtonEditMessage3rd.Visible = true;
                        }
                    }
                }
            }

            if (poolId != 4)
            {
                if (!(dynamicSecurity.PrvAppend))
                {
                    ToolbarButtonEdit.Visible = false;
                    ToolbarButtonEditMessage3rd.Visible = false;
                }
            }

            if (!_userApproval.CancelStart ||
                !(
                    (ts == TuConfirmStatus.IadeOdemeIptalEdildi) ||
                    (ts == TuConfirmStatus.IadeOdemeIptalEdildiDekontBasildi) ||
                    (ts == TuConfirmStatus.IadeOdemeTamamlandi)
                )

                )
            {
                ToolbarButtonCancel.Visible = false;
                //return;
            }

            BlockRefundButton(hdnRecid.Value);

            if (ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_Transfer.GetHashCode() &&
                (ts == TuConfirmStatus.GonderimTamamlandi || ts == TuConfirmStatus.GonderimKaydiKurumaIletildi || ts == TuConfirmStatus.GonderimTamamlandiOdemesiYapildi) &&
                (transactionType == TransactionType.ISME_GONDERIM || transactionType == TransactionType.HESABA_EFT_GONDERIM || transactionType == TransactionType.SWIFT_GONDERIM || transactionType == TransactionType.AKTIFBANK_ODEMESI || transactionType == TransactionType.HESABA_KURUMA_GONDERIM)
                )
            {
                if (!_userApproval.RefundStart)
                {
                    ToolbarButtonBtnRefund.Visible = false;
                }
                else if (transactionType == TransactionType.HESABA_EFT_GONDERIM && !ValidationHelper.GetBoolean(new ParametertDb().getParameterValue("EFT_CANCELABLE"), false))
                {
                    ToolbarButtonBtnRefund.Visible = false;
                }
                else if (transactionType != TransactionType.HESABA_KURUMA_GONDERIM && ts == TuConfirmStatus.GonderimTamamlandiOdemesiYapildi)
                {
                    ToolbarButtonBtnRefund.Visible = false;
                }
                else if (transactionType == TransactionType.HESABA_KURUMA_GONDERIM && !_userApproval.SepaRefundStart)
                {
                    ToolbarButtonBtnRefund.Visible = false;
                }
            }
            else
            {
                ToolbarButtonBtnRefund.Visible = false;
            }

            /*Entegrasyon Kanalı Boş ise Detay Butonu Gözükmesin*/
            var i3Rd = new Integration3Rd();
            var str = i3Rd.GetTransferIntegrationCode(ValidationHelper.GetGuid(hdnRecid.Value), null);
            if (str == string.Empty)
            {
                Btn3rdDetail.Visible = false;
                ToolbarButtonEditMessage3rd.Visible = false;
            }
            if (!string.IsNullOrEmpty(str))
            {
                string IntegrationAssembly = i3Rd.GetIntegrationClassByIntegrationChannelCode(str, null);

                if (IntegrationAssembly == string.Empty)
                {
                    Btn3rdDetail.Visible = false;
                }
            }
            if (transactionType == TransactionType.SWIFT_GONDERIM || transactionType == TransactionType.YP_HAVALE)
            {
                ToolbarButtonBtnRefund.Visible = false;
            }


            ToolbarButtonEditMessage3rd.Visible = false;



            //Kullanıcı, kendi ofisine ait kayıtların iptal/iade/düzeltme işlemlerini yapabilir.
            if (_userApproval.OfficeCancelReturnEditPermit)
            {
                TransferDb transferService = new TransferDb();
                UserService userService = new UserService();
                Guid transferOfficeID = transferService.GetTransferOfficeID(ValidationHelper.GetGuid(hdnRecid.Value));
                Guid userOfficeID = userService.GetOfficeID(App.Params.CurrentUser.SystemUserId, null);

                //Kullanıcı ofisi, transferin ofisi ile aynı değilse işlem devam etmez.
                if (userOfficeID != transferOfficeID)
                {
                    ToolbarButtonEdit.Visible = false;
                    ToolbarButtonReceipt.Visible = false;
                    ToolbarButtonCancel.Visible = false;
                    ToolbarButtonBtnRefund.Visible = false;
                    ToolbarButtonEditMessage3rd.Visible = false;
                }
            }
        }
    }

    protected void BtnRefundClick(object sender, AjaxEventArgs e)
    {
        //var refundFactory = new RefundFactory();
        //if(!refundFactory.GetRefundCancelPermission())
        //{
        //    QScript("alert('"+ CrmLabel.TranslateMessage("CRM.NEW_CORPORATION_REFUND_OR_CANCEL_CANT_SEND_TRANSFER_FROM_THIS_CORPORATION") +"');");
        //    return;
        //}

        var query = new Dictionary<string, string>
                            {
                                {"ObjectId", hdnObjectId.Value},
                                {"recid", hdnRecid.Value},
                            };

        /*İadeye istemeden önce kuruma cancel edilebilecekmi kontrolü yapılıyor.*/
        //if (ValidationHelper.GetInteger(hdnObjectId.Value, 0) == TuEntityEnum.New_Transfer.GetHashCode())
        //{
        //    ConfirmDb cdb = new ConfirmDb();
        //    string banka_islem_no;
        //    string tuRef = cdb.GetTransferTuref(ValidationHelper.GetGuid(hdnRecid.Value), out banka_islem_no);

        //    TransferWSCancelRequestFactory cancelfac = new TransferWSCancelRequestFactory();
        //    WSCancelCheck obj = new WSCancelCheck() { ISLEM_TIPI = "G", TU_REFERANS = tuRef, BANKA_ISLEM_NO = 0 };
        //    WSCancelCheckOut cRet = cancelfac.CancelCheckOnlyCorp(obj);

        //    if (cRet.IsCancellable == "H")
        //    {
        //        ms.Show(".", "", cRet.OutStatus.RESPONSE_DATA);
        //        return;
        //    }
        //}

        /*Daha Bitmedi*/

        string urlparam = QueryHelper.RefreshUrl(query);
        Response.Redirect(Page.ResolveClientUrl("~/ISV/TU/Refund/RefundTransfer/_RefundTransferRequest.aspx" + urlparam));

    }

    protected void CancelRequest(object sender, AjaxEventArgs e)
    {
        var query = new Dictionary<string, string>();
        Page.Response.Redirect("_CancelRequest.aspx" + QueryHelper.RefreshUrl(query));

    }

    protected void PrintReceipt(object sender, AjaxEventArgs e)
    {
        TuFactory.Data.PostMessage pm = new TuFactory.Data.PostMessage();
        var confirmFactory = new ConfirmFactory();
        var ts = confirmFactory.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                            ValidationHelper.GetGuid(hdnRecid.Value));
        switch (ts)
        {

            case TuConfirmStatus.IadeOdemeIptalEdildi:
            case TuConfirmStatus.IadeOdemeOnayli:
            case TuConfirmStatus.IadeOdemeTamamlandi:
            case TuConfirmStatus.IadeOdemeIptalEdildiDekontBasildi:

            case TuConfirmStatus.OdemeIptalEdildi:
            case TuConfirmStatus.OdemeOnayli:
            case TuConfirmStatus.OdemeTamamlandi:
            case TuConfirmStatus.OdemeIptalEdildiDekontBasildi:
            /*Tekrar tekrar Basnak icin*/
            case TuConfirmStatus.GonderimIptalEdildi:
            case TuConfirmStatus.GonderimTamamlandi:
            case TuConfirmStatus.GonderimTamamlandiOdemesiYapildi:
            case TuConfirmStatus.GonderimOnayli:
            case TuConfirmStatus.GonderimIptalEdildiDekontBasildi:
            case TuConfirmStatus.GonderimKaydiKurumaIletildi:

                break;

            default:
                ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
                return;
        }

        try
        {
            StaticData sdTemp = new StaticData();
            sdTemp.AddParameter("RecId", DbType.Guid, ValidationHelper.GetGuid(hdnRecid.Value));
            sdTemp.AddParameter("ObjectId", DbType.Int32, ValidationHelper.GetInteger(hdnObjectId.Value, 0));
            sdTemp.AddParameter("Status", DbType.String, ts);
            sdTemp.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            sdTemp.AddParameter("CreateDate", DbType.DateTime, DateTime.Now);
            sdTemp.ExecuteNonQuerySp("spReceiptStatusLog");
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "ReceiptStatusLog");
        }

        try
        {
            //Dekont basma eğer düzeltme sonucunda geliyorsa dekont bas butonu gizlenmeyecek, geri kalan durumlarda gizlenecek.s


            switch (ts)
            {
                case TuConfirmStatus.GonderimIptalEdildi:

                    /*dekont basın altında sadece statü update olacak ve kasa çalışacak*/
                    //confirmFactory.ConfirmPrintedWidthTrans(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                    //                            ETuConfirmType.TransactionCancel,
                    //                            ValidationHelper.GetGuid(hdnRecid.Value));

                    BlockReceiptButton(hdnRecid.Value);
                    confirmFactory.ConfirmPrintedForCancelOnlyStatusAndCash(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                                            ETuConfirmType.TransactionCancel,
                                                                            ValidationHelper.GetGuid(hdnRecid.Value), null);
                    QScript(string.Format("hdnReportId.setValue('{0}');",
                                          ValidationHelper.GetString(

                                          TuReports.GetReportId(TuReportTypeEnum.GonderimIptalIslemDekontu, TuEntityEnum.New_Transfer, ValidationHelper.GetGuid(hdnRecid.Value))
                                          )));

                    break;
                case TuConfirmStatus.OdemeIptalEdildi:
                    confirmFactory.ConfirmPrintedWidthTrans(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                ETuConfirmType.TransactionCancel,
                                                ValidationHelper.GetGuid(hdnRecid.Value));
                    QScript(string.Format("hdnReportId.setValue('{0}');",
                                          ValidationHelper.GetString(
                                               //ParameterFactory.GetParameterValue("DEKONT_ODEMEIPTALEDILDI")
                                               TuReports.GetReportId(TuReportTypeEnum.OdemeIptalIslemDekontu, TuEntityEnum.New_Payment, ValidationHelper.GetGuid(hdnRecid.Value))

                                              )));

                    break;

                case TuConfirmStatus.GonderimIptalEdildiDekontBasildi:
                    QScript(string.Format("hdnReportId.setValue('{0}');",
                                          ValidationHelper.GetString(
                                              //ParameterFactory.GetParameterValue("DEKONT_ODEMEIPTALEDILDI")
                                              TuReports.GetReportId(TuReportTypeEnum.GonderimIptalIslemDekontu, TuEntityEnum.New_Transfer, ValidationHelper.GetGuid(hdnRecid.Value))
                                              )));
                    break;
                case TuConfirmStatus.OdemeIptalEdildiDekontBasildi:
                    QScript(string.Format("hdnReportId.setValue('{0}');",
                                          ValidationHelper.GetString(
                                              //ParameterFactory.GetParameterValue("DEKONT_GONDERIMIPTALEDILDI")
                                              TuReports.GetReportId(TuReportTypeEnum.OdemeIptalIslemDekontu, TuEntityEnum.New_Payment, ValidationHelper.GetGuid(hdnRecid.Value))

                                              )));
                    break;

                case TuConfirmStatus.OdemeOnayli:
                    confirmFactory.ConfirmPrintedWidthTrans(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                ETuConfirmType.Transaction, ValidationHelper.GetGuid(hdnRecid.Value));
                    QScript(string.Format("hdnReportId.setValue('{0}');",
                                          ValidationHelper.GetString(
                                              //ParameterFactory.GetParameterValue("DEKONT_ODEMEONAYLI")
                                              TuReports.GetReportId(TuReportTypeEnum.OdemeIslemDekontu, TuEntityEnum.New_Payment, ValidationHelper.GetGuid(hdnRecid.Value))

                                              )));


                    pm.AddPostMessagePayment(ValidationHelper.GetGuid(hdnRecid.Value), App.Params.CurrentUser.SystemUserId);
                    break;
                case TuConfirmStatus.GonderimOnayli:
                    //confirmFactory.ConfirmPrintedWidthTrans(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                    //                            ETuConfirmType.Transaction,
                    //                            ValidationHelper.GetGuid(hdnRecid.Value));

                    StaticData sd = new StaticData();
                    sd.AddParameter("TransferId", DbType.Guid, ValidationHelper.GetGuid(hdnRecid.Value));
                    DataTable dt = sd.ReturnDataset("Select new_TransferEditId From vNew_Transfer(nolock) Where new_TransferId = @TransferId").Tables[0];
                    Guid TransferEditId = Guid.Empty;
                    if (dt.Rows.Count > 0)
                    {
                        TransferEditId = ValidationHelper.GetGuid(dt.Rows[0]["new_TransferEditId"]);
                    }

                    if (TransferEditId == Guid.Empty)
                    {
                        confirmFactory.ConfirmPrintedWidthTrans(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                ETuConfirmType.Transaction,
                                                ValidationHelper.GetGuid(hdnRecid.Value), false);
                    }
                    else
                    {
                        var cdb = new ConfirmDb();

                        cdb.ConfirmPrinted(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ETuConfirmType.Transaction, ValidationHelper.GetGuid(hdnRecid.Value), App.Params.CurrentUser.SystemUserId, false, null);

                        var tr = sd.GetDbTransaction();
                        var i3rd = new TuFactory.Integration3rd.Integration3Rd();
                        //TuFactory.Domain.Transfer transfer = new TransferManager().GetTransfer(ValidationHelper.GetGuid(hdnRecid.Value));
                        i3rd.IntegrateChangeTransfer(ValidationHelper.GetGuid(hdnRecid.Value), tr);

                        var df1 = new DynamicFactory(ERunInUser.SystemAdmin);
                        var drec1 = df1.RetrieveWithOutPlugin(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                 ValidationHelper.GetGuid(hdnRecid.Value),
                                                 new[] { "new_TransferEditId", "new_IsUpdated" });

                        QScript(string.Format("hdnReportId.setValue('{0}');",
                                              ValidationHelper.GetString(
                                                  //ParameterFactory.GetParameterValue("DEKONT_GONDERIM_DUZELTME")
                                                  TuReports.GetReportId(TuReportTypeEnum.GonderimIslemDuzeltmeDekontu, TuEntityEnum.New_Transfer, ValidationHelper.GetGuid(hdnRecid.Value))

                                                  )));





                        pm = new TuFactory.Data.PostMessage();
                        pm.AddPostMessage(ValidationHelper.GetGuid(hdnRecid.Value), App.Params.CurrentUser.SystemUserId);
                        break;



                    }

                    try
                    {
                        //Bayi Kredi Ödemeleri İçin SMS Göndermiyoruz.
                        //Geri kalan işlemlerde gönderiyoruz.
                        CreditCheckFactory ccf = new CreditCheckFactory();
                        var creditPaymentID = ccf.GetPaymentIDFromTransferID(ValidationHelper.GetGuid(hdnRecid.Value), null);
                        if (String.IsNullOrEmpty(creditPaymentID))
                        {
                            pm = new TuFactory.Data.PostMessage();
                            pm.AddPostMessage(ValidationHelper.GetGuid(hdnRecid.Value), App.Params.CurrentUser.SystemUserId);
                        }
                    }
                    catch
                    { }

                    QScript(string.Format("hdnReportId.setValue('{0}');",
                                          ValidationHelper.GetString(
                                              //ParameterFactory.GetParameterValue("DEKONT_GONDERIMONAYLI")
                                              TuReports.GetReportId(TuReportTypeEnum.GonderimIslemDekontu, TuEntityEnum.New_Transfer, ValidationHelper.GetGuid(hdnRecid.Value))

                                              )));
                    break;
                case TuConfirmStatus.OdemeTamamlandi:
                    QScript(string.Format("hdnReportId.setValue('{0}');",
                                          ValidationHelper.GetString(
                                              //ParameterFactory.GetParameterValue("DEKONT_ODEMEONAYLI")
                                              TuReports.GetReportId(TuReportTypeEnum.OdemeIslemDekontu, TuEntityEnum.New_Payment, ValidationHelper.GetGuid(hdnRecid.Value))

                                              )));

                    break;
                case TuConfirmStatus.GonderimKaydiKurumaIletildi:
                case TuConfirmStatus.GonderimTamamlandi:
                    var df = new DynamicFactory(ERunInUser.SystemAdmin);
                    var drec = df.RetrieveWithOutPlugin(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                             ValidationHelper.GetGuid(hdnRecid.Value),
                                             new[] { "new_TransferEditId", "new_IsUpdated" });

                    /* Eger Gonderim duzeltme islemi yapildi ise bu işlemde surekli print edilen sey gonderim duzeltme olmalidir.*/
                    //if (drec.GetBooleanValue("new_IsUpdated"))
                    if (QueryHelper.GetBoolean("doReceiptEdit", false))
                    {
                        QScript(string.Format("hdnReportId.setValue('{0}');",
                                              ValidationHelper.GetString(
                                                  //ParameterFactory.GetParameterValue("DEKONT_GONDERIM_DUZELTME")
                                                  TuReports.GetReportId(TuReportTypeEnum.GonderimIslemDuzeltmeDekontu, TuEntityEnum.New_Transfer, ValidationHelper.GetGuid(hdnRecid.Value))

                                                  )));

                    }
                    else
                    {
                        QScript(string.Format("hdnReportId.setValue('{0}');",
                                                  ValidationHelper.GetString(
                                                      //ParameterFactory.GetParameterValue("DEKONT_GONDERIMONAYLI")
                                                      TuReports.GetReportId(TuReportTypeEnum.GonderimIslemDekontu, TuEntityEnum.New_Transfer, ValidationHelper.GetGuid(hdnRecid.Value))

                                                      )));
                    }
                    break;
                case TuConfirmStatus.GonderimTamamlandiOdemesiYapildi:
                    QScript(string.Format("hdnReportId.setValue('{0}');",
                                                  ValidationHelper.GetString(
                                                      //ParameterFactory.GetParameterValue("DEKONT_GONDERIMONAYLI")
                                                      TuReports.GetReportId(TuReportTypeEnum.GonderimIslemDekontu, TuEntityEnum.New_Transfer, ValidationHelper.GetGuid(hdnRecid.Value))

                                                      )));

                    break;



                case TuConfirmStatus.IadeOdemeIptalEdildi:
                    confirmFactory.ConfirmPrintedWidthTrans(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                ETuConfirmType.TransactionCancel,
                                                ValidationHelper.GetGuid(hdnRecid.Value));
                    QScript(string.Format("hdnReportId.setValue('{0}');",
                                          ValidationHelper.GetString(
                                               //ParameterFactory.GetParameterValue("DEKONT_ODEMEIPTALEDILDI")
                                               TuReports.GetReportId(TuReportTypeEnum.IadeOdemeIptalDekontu, TuEntityEnum.New_RefundPayment, ValidationHelper.GetGuid(hdnRecid.Value))

                                              )));

                    break;

                case TuConfirmStatus.IadeOdemeIptalEdildiDekontBasildi:
                    QScript(string.Format("hdnReportId.setValue('{0}');",
                                          ValidationHelper.GetString(
                                              //ParameterFactory.GetParameterValue("DEKONT_GONDERIMIPTALEDILDI")
                                              TuReports.GetReportId(TuReportTypeEnum.IadeOdemeIptalDekontu, TuEntityEnum.New_RefundPayment, ValidationHelper.GetGuid(hdnRecid.Value))

                                              )));
                    break;
                case TuConfirmStatus.IadeOdemeOnayli:
                    confirmFactory.ConfirmPrintedWidthTrans(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                ETuConfirmType.Transaction, ValidationHelper.GetGuid(hdnRecid.Value));
                    QScript(string.Format("hdnReportId.setValue('{0}');",
                                          ValidationHelper.GetString(
                                              //ParameterFactory.GetParameterValue("DEKONT_ODEMEONAYLI")
                                              TuReports.GetReportId(TuReportTypeEnum.IadeOdemeDekontu, TuEntityEnum.New_RefundPayment, ValidationHelper.GetGuid(hdnRecid.Value))

                                              )));
                    break;
                case TuConfirmStatus.IadeOdemeTamamlandi:
                    QScript(string.Format("hdnReportId.setValue('{0}');",
                                          ValidationHelper.GetString(
                                              //ParameterFactory.GetParameterValue("DEKONT_ODEMEONAYLI")
                                              TuReports.GetReportId(TuReportTypeEnum.IadeOdemeDekontu, TuEntityEnum.New_RefundPayment, ValidationHelper.GetGuid(hdnRecid.Value))

                                              )));
                    pm.AddPostMessageRefundPayment(ValidationHelper.GetGuid(hdnRecid.Value), App.Params.CurrentUser.SystemUserId, null);
                    break;

            }
        }
        catch (TuException ex)
        {
            //ex.Show();
            ms.Width = 500;
            ms.Show(".", ex.ErrorMessage);
            return;
        }
        catch (Exception)
        {
            ms.Width = 500;
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            return;
        }


        QScript("ShowClientSideWindow();");
        //QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
    }

    protected void ReceiptEdit(object sender, AjaxEventArgs e)
    {


        string transactionType;
        var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                ValidationHelper.GetGuid(hdnRecid.Value), null, out transactionType);

        if (!((ts == TuConfirmStatus.GonderimKaydiKurumaIletildi || ts == TuConfirmStatus.GonderimTamamlandi || ts == TuConfirmStatus.GonderimDuzeltmeOnayGeriCevrildi) && transactionType == TransactionType.ISME_GONDERIM))
        {
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
            return;
        }



        try
        {
            //var df = new DynamicFactory(ERunInUser.SystemAdmin);
            //var detr = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(hdnRecid.Value),
            //                         new[] { "new_TransferEditId" });
            //var transferEditId = detr.GetLookupValue("new_TransferEditId");
            var transferEditId = Guid.Empty;
            var transferEditStatus = string.Empty;

            StaticData sd = new StaticData();
            sd.AddParameter("TransferId", DbType.Guid, ValidationHelper.GetGuid(hdnRecid.Value));
            DataSet ds = sd.ReturnDataset(@"SELECT te.New_TransferEditId, cs.new_Code FROM vNew_Transfer t
                                LEFT JOIN vNew_TransferEdit te
                                ON t.new_TransferEditId = te.New_TransferEditId AND te.DeletionStateCode = 0
                                LEFT JOIN vNew_ConfirmStatus cs
                                ON te.new_ConfirmStatusId = cs.New_ConfirmStatusId AND cs.DeletionStateCode = 0
                                WHERE t.New_TransferId = @TransferId");
            if (ds != null && ds.Tables[0].Rows.Count == 1)
            {
                transferEditId = ValidationHelper.GetGuid(ds.Tables[0].Rows[0]["New_TransferEditId"], Guid.Empty);
                transferEditStatus = ValidationHelper.GetString(ds.Tables[0].Rows[0]["new_Code"], string.Empty);
            }

            var query = new Dictionary<string, string>
                            {
                                {"ObjectId", hdnObjectId.Value},
                                {"recid", hdnRecid.Value},

                            };

            if (transferEditId != Guid.Empty && !(transferEditStatus == TuConfirmStatus.GonderimDuzeltmeOnayGeriCevrildi || transferEditStatus == TuConfirmStatus.GonderimDuzeltmeOnayRedEdildi))
            {
                query.Add("New_TransferEditId", transferEditId.ToString());
            }

            string urlparam = QueryHelper.RefreshUrl(query);
            Response.Redirect(Page.ResolveClientUrl("~/ISV/TU/TransferEdit/TransferEditMain.aspx" + urlparam));
        }
        catch (TuException ex)
        {
            ex.Show();
            //ms.Show(".", ex.ErrorMessage);
            return;
        }
        catch (Exception)
        {
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            return;
        }


        QScript("ShowClientSideWindow();");
        //QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
    }

    protected void ReceiptEditMessage3rd(object sender, AjaxEventArgs e)
    {
        string transactionType;
        var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                ValidationHelper.GetGuid(hdnRecid.Value), null, out transactionType);

        if (!((ts == TuConfirmStatus.GonderimKaydiKurumaIletildi || ts == TuConfirmStatus.GonderimTamamlandi || ts == TuConfirmStatus.GonderimDuzeltmeOnayGeriCevrildi) && transactionType == TransactionType.ISME_GONDERIM))
        {
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
            return;
        }

        try
        {
            var df = new DynamicFactory(ERunInUser.SystemAdmin);
            //var detr = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(hdnRecid.Value),
            //                         new[] { "new_TransferEditId" });
            //var transferEditId = detr.GetLookupValue("new_TransferEditId");

            var query = new Dictionary<string, string>
                            {
                                {"ObjectId", hdnObjectId.Value},
                                {"recid", hdnRecid.Value},

                            };
            //if (transferEditId != Guid.Empty)
            //    query.Add("New_TransferEditId", transferEditId.ToString());

            string urlparam = QueryHelper.RefreshUrl(query);
            Response.Redirect(Page.ResolveClientUrl("~/ISV/TU/TransferEdit/TransferEditMessage3rd.aspx" + urlparam));
        }
        catch (TuException ex)
        {
            ex.Show();
            //ms.Show(".", ex.ErrorMessage);
            return;
        }
        catch (Exception)
        {
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            return;
        }


        QScript("ShowClientSideWindow();");
        //QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
    }

    private void TranslateMessages()
    {
        ToolbarButtonReceipt.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_RECEIPT_PRINTING");
        ToolbarButtonEdit.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_RECEIPT_EDIT");
        ToolbarButtonLog.Text = CrmLabel.TranslateMessage("CRM_ACTION_MENU_SHOW_LOGWINDOW");
        hdnOnayMessage.Value = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CONFIRMED");
        ToolbarButtonCancel.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CANCEL_REQUEST");
        ToolbarButtonMd.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING_DETAIL");
        ToolbarButtonBtnRefund.Text = CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_IADESINEBASLA");
        Btn3rdDetail.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_BTN3RDDETAIL");
        ToolbarButtonEditMessage3rd.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_EDITMESESSAGE3RD");
        ToolbarButtonRefund.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_REFUND");
        ToolbarButtonEdit.Visible = false;
        ToolbarButtonEditMessage3rd.Visible = false;
    }

    private void BlockRefundButton(string TransferId)
    {
        TransferWSCancelRequestFactory f = new TransferWSCancelRequestFactory();
        try
        {
            var result = f.CheckEftTransferCorporationAndBank(TransferId);
            if (result)
            {
                ToolbarButtonBtnRefund.Visible = false;
            }
            else
            {
                ToolbarButtonBtnRefund.Visible = true;
            }
        }
        catch (Exception)
        {
            throw;
        }

    }

    private void BlockReceiptButton(string TransferId)
    {
        ConfirmFactory f = new ConfirmFactory();
        try
        {
            var result = f.CheckIfUserHasAuthorizationToPrintReceipt(TransferId);
            if (result.ResultCode == PrintReceiptResultCode.SUCCESS)
            {
                ToolbarButtonReceipt.Enabled = true;
            }
            else
            {
                ToolbarButtonReceipt.Enabled = false;
                throw new TuException(result.ResultMessage, PrintReceiptResultCode.ERROR.ToString());
            }
        }
        catch (TuException ex)
        {
            throw ex;
        }
    }

    protected void Refund(object sender, AjaxEventArgs e)
    {
        var cf = new ConfirmFactory();
        var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(hdnRecid.Value));
        if (ts != TuConfirmStatus.GonderimOdemeAmlGecti)
        {
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
            return;
        }

        try
        {
            cf.ConfirmRefundForTransferAndPayment(ValidationHelper.GetGuid(hdnRecid.Value), ValidationHelper.GetInteger(hdnObjectId.Value, 0));
        }
        catch (TuException ex)
        {
            ms.Show(".", ex.ErrorMessage);
            return;
        }
        catch (Exception ex)
        {
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            return;
        }
        QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_REFUNDED") + "');");
        QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
    }
}