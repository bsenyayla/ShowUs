using System;
using System.Collections.Generic;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object;
using Object = TuFactory.CustAccount.Object;
using TuFactory.CustAccount.Business;
using Coretech.Crm.Factory.Crm;
using TuFactory.Reports;
using TuFactory.UptCard.Business;
using Coretech.Crm.Factory;
using Services.Interfaces;
using Services;
using Domain.Entities;
using TuFactory.Domain.Enums;
using TuFactory.Domain;

public partial class CustAccount_Pool_CustAccountReceipt : BasePage
{
    private static string _blankurl = "about:blank";
    private static Guid _recid = Guid.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        _recid = QueryHelper.GetGuid("recid");


        if (!RefleX.IsAjxPostback)
        {
            hdnRecid.Value = QueryHelper.GetString("recid");
            hdndoReceipt.Value = QueryHelper.GetString("doReceipt");

            var readonlyForm = CustAccountOperations.GetCustAccountOperationsReadOnlyPageId(_recid);
            var query = new Dictionary<string, string>
            {
                {"ObjectId", TuEntityEnum.New_CustAccountOperations.GetHashCode().ToString()},
                {"defaulteditpageid", readonlyForm.ToString()},
                {"recid", _recid.ToString()},
            };

            var url = QueryHelper.AddUpdateString(this, HTTPUtil.GetEditpage(), query);

            CustAccountOperationsDetail.AutoLoad.Url = url;
            //PTT operasyonu ise butonu gizle
            btnPrint.Visible = !new CustAccountOperations().IsPttOperation(hdnRecid.Value);
        }
    }

    protected void btnPrintOnClickEvent(object sender, AjaxEventArgs e)
    {
        var ts = new CustAccountOperations().GetCustAccountConfirmStatus(_recid);
        switch (ts)
        {
            case Object.CustAccountStatus.HesapKapatmaTamamlandi:
            case Object.CustAccountStatus.HesapKapatmaDekontBasilacak:
                QScript(string.Format("hdnReportId.setValue('{0}');",
                                      ValidationHelper.GetString(
                                          TuReports.GetReportId(TuReportTypeEnum.MusteriHesaplari_HesapKapatma, TuEntityEnum.New_CustAccountOperations, ValidationHelper.GetGuid(_recid))
                                          )));

                break;
            case Object.CustAccountStatus.HesabaParaAktarildDekontBasilacak:
            case Object.CustAccountStatus.HesabaParaAktarmaTamamlandi:
                QScript(string.Format("hdnReportId.setValue('{0}');",
                                          ValidationHelper.GetString(
                                              TuReports.GetReportId(TuReportTypeEnum.MusteriHesaplari_HesabaParaYatirma, TuEntityEnum.New_CustAccountOperations, ValidationHelper.GetGuid(_recid))
                                              )));
                break;
            case Object.CustAccountStatus.HesapAcmaTamamlandi:
            case Object.CustAccountStatus.HesapAcildiDekontBasilacak:
                QScript(string.Format("hdnReportId.setValue('{0}');",
                          ValidationHelper.GetString(
                              TuReports.GetReportId(TuReportTypeEnum.MusteriHesaplari_HesapAcma, TuEntityEnum.New_CustAccountOperations, ValidationHelper.GetGuid(_recid))
                              )));
                break;
            case Object.CustAccountStatus.HesaptanNakitCekmeTamamlandi:
            case Object.CustAccountStatus.HesaptanNakitCekmeDekontBasilacak:
                QScript(string.Format("hdnReportId.setValue('{0}');",
                          ValidationHelper.GetString(
                              TuReports.GetReportId(TuReportTypeEnum.MusteriHesaplari_HesaptanNakitTahsilat, TuEntityEnum.New_CustAccountOperations, ValidationHelper.GetGuid(_recid))
                              )));
                break;
            case Object.CustAccountStatus.UPTKartaParaTransferiDekontBasilacak:
            case Object.CustAccountStatus.UPTKartaParaTransferiTamamlandi:
                QScript(string.Format("hdnReportId.setValue('{0}');",
                          ValidationHelper.GetString(
                              TuReports.GetReportId(TuReportTypeEnum.MusteriHesaplari_UPTKartaTransfer, TuEntityEnum.New_CustAccountOperations, ValidationHelper.GetGuid(_recid))
                              )));
                break;
        }

        switch (ts)
        {
            case Object.CustAccountStatus.IslemAmlKontrol:
            case Object.CustAccountStatus.IslemAmlOnayBeklemede:
            case Object.CustAccountStatus.IslemUptMerkeziOnayinda:
            case Object.CustAccountStatus.IslemUptMerkezOnayiniGecti:
            case Object.CustAccountStatus.IslemIptalEdildi:
            case Object.CustAccountStatus.HesapAcmaOnayiBekliyor:
            case Object.CustAccountStatus.HesapAcmaIcOnayBekliyor:
            case Object.CustAccountStatus.HesapAcmaAMLFraudOnayiBekliyor:
            case Object.CustAccountStatus.HesapAcmaIptalEdildiAMLFraud:
            case Object.CustAccountStatus.HesapAcmaIptalEdildiIcOnay:
            case Object.CustAccountStatus.HesabaParaAktarmaOnayiBekliyor:
            case Object.CustAccountStatus.HesabaParaAktarmaIcOnayBekliyor:
            case Object.CustAccountStatus.HesabaParaAktarmaAMLFraudOnayiBekliyor:
            case Object.CustAccountStatus.HesabaParaAktarmaIptalEdildiAMLFraud:
            case Object.CustAccountStatus.HesabaParaAktarmaIptalEdildiIcOnay:
            case Object.CustAccountStatus.HesaptanNakitCekmeOnayiBekliyor:
            case Object.CustAccountStatus.HesaptanNakitCekmeIcOnayBekliyor:
            case Object.CustAccountStatus.HesaptanNakitCekmeAMLFraudOnayiBekliyor:
            case Object.CustAccountStatus.HesaptanNakitCekmeIptalEdildiAMLFraud:
            case Object.CustAccountStatus.HesaptanNakitCekmeIptalEdildiIcOnay:
            case Object.CustAccountStatus.HesapKapatmaOnayiBekliyor:
            case Object.CustAccountStatus.HesapKapatmaIcOnayBekliyor:
            case Object.CustAccountStatus.HesapKapatmaAMLFraudOnayiBekliyor:
            case Object.CustAccountStatus.HesapKapatmaIptalEdildiAMLFraud:
            case Object.CustAccountStatus.HesapKapatmaIptalEdildiIcOnay:
            case Object.CustAccountStatus.UPTKartanHesabaParaTransferiAMLFraudOnayiBekliyor:
            case Object.CustAccountStatus.UPTKartaParaTransferiAMLFraudOnayiBekliyor:
            case Object.CustAccountStatus.UPTKartanHesabaParaTransferiIcOnayBekliyor:
            case Object.CustAccountStatus.UPTKartaParaTransferiIcOnayBekliyor:
                Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_RECEIPT_ERROR"));
                break;

            case Object.CustAccountStatus.HesapKapatmaTamamlandi:
            case Object.CustAccountStatus.HesaptanNakitCekmeTamamlandi:
            case Object.CustAccountStatus.HesabaParaAktarmaTamamlandi:
            case Object.CustAccountStatus.HesapAcmaTamamlandi:
            case Object.CustAccountStatus.UPTKartaParaTransferiTamamlandi:
            case Object.CustAccountStatus.UPTKartanHesabaParaTransferiTamamlandi:

                QScript("ShowClientSideWindow();");
                break;
            case Object.CustAccountStatus.HesapAcildiDekontBasilacak:
            case Object.CustAccountStatus.HesapKapatmaDekontBasilacak:
            case Object.CustAccountStatus.HesabaParaAktarildDekontBasilacak:
            case Object.CustAccountStatus.HesaptanNakitCekmeDekontBasilacak:
            case Object.CustAccountStatus.UPTKartanHesabaParaTransferiDekontBasilacak:
                try
                {
                    if (ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("WORK_WITH_THE_NEW_CUSTACCOUNT_SERVICE")))
                    {
                        var custAccountOperationType = new CustAccountOperations().GetCustAccountOperationType(_recid);
                        ICustAccountOperationService<object> _service;
                        ResponseWrapper<object> response = new ResponseWrapper<object>();
                        switch (custAccountOperationType)
                        {
                            case TuFactory.CustAccount.Object.CustAccountOperationType.Hesaptan_UPT_Karta_Transfer:
                                _service = new TransferToUptCardService<object>();
                                TransferToUptCardItem transferToUptCardItem = new TransferToUptCardItem() { CustAccountOperationId = ValidationHelper.GetGuid(_recid) };
                                response = _service.Confirm(transferToUptCardItem);
                                if (response.ResponseStatus == ServiceResponseStatus.Error || response.ResponseStatus == ServiceResponseStatus.Warning)
                                {
                                    Alert(response.RETURN_DESCRIPTION);
                                    return;
                                }
                                break;
                            case TuFactory.CustAccount.Object.CustAccountOperationType.Hesap_Acma:
                                _service = new CreateAccountService<object>();  
                                CreateAccountItem createAccountItem = new CreateAccountItem() { CustAccountOperationId = ValidationHelper.GetGuid(_recid) };
                                response = _service.Confirm(createAccountItem);
                                if (response.ResponseStatus == ServiceResponseStatus.Error || response.ResponseStatus == ServiceResponseStatus.Warning)
                                {

                                    Alert(response.RETURN_DESCRIPTION);
                                    return;
                                }
                                break;
                            case TuFactory.CustAccount.Object.CustAccountOperationType.Hesap_Kapatma:
                                _service = new CloseAccountService<object>();
                                CloseAccountItem closeAccountItem = new CloseAccountItem() { CustAccountOperationId = ValidationHelper.GetGuid(_recid) };
                                response = _service.Confirm(closeAccountItem);
                                if (response.ResponseStatus == ServiceResponseStatus.Error || response.ResponseStatus == ServiceResponseStatus.Warning)
                                {
                                    Alert(response.RETURN_DESCRIPTION);
                                    return;
                                }
                                break;
                            case TuFactory.CustAccount.Object.CustAccountOperationType.Hesaba_Para_Yatirma:
                                _service = new CashDepositService<object>();
                                CashDepositItem cashDepositItem = new CashDepositItem() { CustAccountOperationId = ValidationHelper.GetGuid(_recid) };
                                response = _service.Confirm(cashDepositItem);
                                if (response.ResponseStatus == ServiceResponseStatus.Error || response.ResponseStatus == ServiceResponseStatus.Warning)
                                {
                                    Alert(response.RETURN_DESCRIPTION);
                                    return;
                                }
                                break;
                            case TuFactory.CustAccount.Object.CustAccountOperationType.Hesaptan_Nakit_cekme:
                                _service = new CashWithdrawalService<object>();
                                CashWithdrawalItem CashWithdrawalItem = new CashWithdrawalItem() { CustAccountOperationId = ValidationHelper.GetGuid(_recid) };
                                response = _service.Confirm(CashWithdrawalItem);
                                if (response.ResponseStatus == ServiceResponseStatus.Error || response.ResponseStatus == ServiceResponseStatus.Warning)
                                {
                                    Alert(response.RETURN_DESCRIPTION);
                                    return;
                                }
                                break;

                            default:
                                break;
                        }
                    }
                    else
                    {
                        new TransactionOperations().TransactionOperationsFinish(_recid);
                    }
                    Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_COMPLETED"));
                    QScript("ShowClientSideWindow();");
                }
                catch (TuException tuex)
                {
                    tuex.Show();
                }
                catch (Exception)
                {

                    throw;
                }

                break;
            case Object.CustAccountStatus.UPTKartaParaTransferiDekontBasilacak:

                if (ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("PAYGATE_ISACTIVE"), false))
                {
                    /* Reservli Olarak İşaretle */
                    new TransactionOperations().TransactionOperationsReserveStatus(_recid);

                    var _cardClientService = new CardClientService();

                    var canFinish = _cardClientService.FinishTransferToCardOperation(_recid, App.Params.CurrentUser.SystemUserId);

                    if (!canFinish.ServiceResponse)
                    {
                        Alert("Hata: " + canFinish.RETURN_DESCRIPTION);
                        return;
                    }
                }

                new TransactionOperations().TransactionOperationsFinishStatus(_recid);
                QScript("ShowClientSideWindow();");
                break;
            case Object.CustAccountStatus.UPTKartaParaTransferiReservli:
                QScript("alert('İşlem statüsü değiştiğinden aksiyon alınamaz.');");
                break;
        }


    }
}