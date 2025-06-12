using System;
using System.Collections.Generic;
using System.Web.UI;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using TuFactory.Object.Confirm;
using TuFactory.Object.User;
using TuFactory.TuUser;

public partial class Operation_Detail_TransactionRouter : BasePage
{
    private TuUserApproval _userApproval = null;
    private static string _blankurl = "about:blank";
    MessageBox ms = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private enum TuPoolEnum
    {
        OperationPool = 1,/*confirm vs icin*/
        PendingTransactions = 2,/*gisecinin bekleyen isleri*/
        CancelPool = 3, /*tum isler*/
        ProcessMonitoring = 4, /*tum isler*/
        ProcessMonitoringDetail = 5, /* tum isler detay.*/
        IntegrationRefund = 6,
        WelcomePayment = 7,
        ProblemTransaction = 8

    }
    protected void Page_Load(object sender, EventArgs e)
    {
        RegisterClientScriptInclude("_GlobalJs", HTTPUtil.GetWebAppRoot() + "/ISV/TU/Operation/Detail/js/_Global.js");
        string redirecturl = _blankurl;
        var query = new Dictionary<string, string>();
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

        var objectid = QueryHelper.GetString("objectid");
        var recid = QueryHelper.GetString("recid");
        var poolId = QueryHelper.GetInteger("PoolId", 0);


        if (QueryHelper.GetBoolean("doReceiptEdit", false))
        {
            query.Add("doReceiptEdit", "1");
        }

        var cf = new ConfirmFactory();
        var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(objectid, 0), ValidationHelper.GetGuid(recid));
        if (poolId == (int)TuPoolEnum.OperationPool)
        {
            if (_userApproval.ApprovalConfirm || _userApproval.ApprovalReject || _userApproval.ApprovalReturn || _userApproval.ApprovalRefund)
            {

                switch (ts)
                {
                    case TuConfirmStatus.GonderimOnayiBekliyor:
                    case TuConfirmStatus.GonderimAltOnayBekleniyor:
                    case TuConfirmStatus.OdemeOnayBekliyor:
                    case TuConfirmStatus.OdemeAltOnayBekliyor:
                    case TuConfirmStatus.IadeOdemeOnayBekliyor:
                    case TuConfirmStatus.IadeOdemeAltOnayBekliyor:
                    case TuConfirmStatus.GonderimDuzeltmeOnayiBekliyor:
                    case TuConfirmStatus.GonderimDuzeltmeAltOnayBekleniyor:
                    case TuConfirmStatus.IadeGonderimOnayBekliyor:
                        redirecturl = "_Confirm.aspx";
                        break;
                }
            }
            if (_userApproval.ApprovalConfirm || _userApproval.ApprovalReject)
            {
                switch (ts)
                {
                    case TuConfirmStatus.GonderimIptalOnayBekliyor:
                    case TuConfirmStatus.GonderimIptalAltOnayBekliyor:
                    case TuConfirmStatus.OdemeIptalOnayBekliyor:
                    case TuConfirmStatus.OdemeIptalAltOnayBekliyor:
                    case TuConfirmStatus.IadeOdemeIptalOnayBekliyor:
                    case TuConfirmStatus.IadeOdemeIptalAltOnayBekliyor:
                        redirecturl = "_Cancel.aspx";
                        break;
                }
            }
        }
        else if (poolId == (int)TuPoolEnum.CancelPool)
        {
            if (_userApproval.CancelStart)
            {

                switch (ts)
                {
                    case TuConfirmStatus.GonderimOnayaGonderildi:
                    case TuConfirmStatus.GonderimYeniKayit:
                    case TuConfirmStatus.GonderimOdemeAmlGecti:
                    case TuConfirmStatus.GonderimTamamlandi:
                    case TuConfirmStatus.GonderimOnayGeriCevrildi:
                    case TuConfirmStatus.GonderimOnayli:
                    case TuConfirmStatus.GonderimOnayiBekliyor:
                    case TuConfirmStatus.IadeGonderimTamamlandi:
                    case TuConfirmStatus.OdemeOnayRedEdildi:
                    case TuConfirmStatus.OdemeOnayaGonderildi:
                    case TuConfirmStatus.OdemeYeniKayit:
                    case TuConfirmStatus.OdemeOnayGeriCevrildi:
                    case TuConfirmStatus.OdemeOnayBekliyor:
                    case TuConfirmStatus.OdemeAmlGecti:
                    case TuConfirmStatus.OdemeOnayli:
                    case TuConfirmStatus.OdemeTamamlandi:
                    case TuConfirmStatus.GonderimKaydiKurumaIletildi:

                    case TuConfirmStatus.IadeOdemeOnayRedEdildi:
                    case TuConfirmStatus.IadeOdemeOnayaGOnderildi:
                    case TuConfirmStatus.IadeOdemeYeniKayit:
                    case TuConfirmStatus.IadeOdemeOnayGericevrildi:
                    case TuConfirmStatus.IadeOdemeOnayBekliyor:
                    case TuConfirmStatus.IadeOdemeOnayli:
                    case TuConfirmStatus.IadeOdemeTamamlandi:
                    case TuConfirmStatus.GonderimYeniKayitHataAldiBekliyor:

                        redirecturl = "_CancelRequest.aspx";
                        break;

                }
            }
        }
        else if (poolId == (int)TuPoolEnum.IntegrationRefund)
        {
            if (_userApproval.RefundStart)
            {
                switch (ts)
                {
                    case TuConfirmStatus.GonderimIslemiKurumdanIadesiIsteniyor:
                        redirecturl = "_IntegrationRefund.aspx";
                        break;
                }
            }
        }
        else if (poolId == (int)TuPoolEnum.ProblemTransaction)
        {
            switch (ts)
            {
                case TuConfirmStatus.GonderimOdemeOnProvizyon:
                case TuConfirmStatus.GonderimYeniKayit:

                    redirecturl = "_ReadOnly.aspx"; //"_Receipt.aspx"
                    break;
            }
        }
        else
        {
            switch (ts)
            {
                case TuConfirmStatus.GonderimOnayaGonderildi:
                case TuConfirmStatus.GonderimYeniKayit:
                case TuConfirmStatus.GonderimOnayiBekliyor:
                case TuConfirmStatus.GonderimAltOnayBekleniyor:

                case TuConfirmStatus.OdemeOnayaGonderildi:
                case TuConfirmStatus.OdemeYeniKayit:
                case TuConfirmStatus.OdemeOnayBekliyor:
                case TuConfirmStatus.OdemeAltOnayBekliyor:

                case TuConfirmStatus.IadeOdemeOnayaGOnderildi:
                case TuConfirmStatus.IadeOdemeYeniKayit:
                case TuConfirmStatus.IadeOdemeOnayBekliyor:
                case TuConfirmStatus.IadeOdemeAltOnayBekliyor:

                    redirecturl = _userApproval.CancelStart ? "_Receipt.aspx" : _blankurl;
                    break;

                case TuConfirmStatus.GonderimIptalEdildi:
                case TuConfirmStatus.GonderimOnayli:
                case TuConfirmStatus.GonderimTamamlandi:
                case TuConfirmStatus.GonderimTamamlandiOdemesiYapildi:
                case TuConfirmStatus.GonderimIptalEdildiDekontBasildi:
                case TuConfirmStatus.GonderimDuzeltmeOnayGeriCevrildi:

                case TuConfirmStatus.OdemeIptalEdildiDekontBasildi:
                case TuConfirmStatus.OdemeTamamlandi:
                case TuConfirmStatus.OdemeIptalEdildi:
                case TuConfirmStatus.OdemeOnayli:
                case TuConfirmStatus.GonderimOdemeAmlGecti:
                case TuConfirmStatus.IadeOdemeIptalEdildiDekontBasildi:
                case TuConfirmStatus.IadeOdemeTamamlandi:
                case TuConfirmStatus.IadeOdemeIptalEdildi:
                case TuConfirmStatus.GonderimKaydiKurumaIletildi:
                case TuConfirmStatus.IadeOdemeOnayli:

                    redirecturl = "_Receipt.aspx";
                    break;
                case TuConfirmStatus.GonderimOnayRedEdildiParaIadesiBekleniyor:
                    redirecturl = "_Refund.aspx";
                    break;
                case TuConfirmStatus.IadeOdemeOnayRedEdildi:
                case TuConfirmStatus.OdemeOnayRedEdildi:
                case TuConfirmStatus.GonderimRedParaIadesiYapildi:
                case TuConfirmStatus.GonderimBeklemede:

                    var readonlyform = string.Empty;
                    switch (ValidationHelper.GetInteger(objectid, 0))
                    {
                        case (int)TuEntityEnum.New_Transfer:
                            readonlyform =
                                ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_PAGE"));
                            break;
                        case (int)TuEntityEnum.New_Payment:
                            readonlyform =
                                ValidationHelper.GetString(ParameterFactory.GetParameterValue("PAYMENT_READONLY_PAGE"));
                            break;
                    }
                    redirecturl =
                        Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx");
                    query.Add("defaulteditpageid", readonlyform);

                    break;

                case TuConfirmStatus.GonderimOnayGeriCevrildi:

                case TuConfirmStatus.OdemeBeklemede:
                case TuConfirmStatus.OdemeOnayGeriCevrildi:

                case TuConfirmStatus.IadeOdemeOnayGericevrildi:

                    redirecturl =
                        Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx");
                    query.Add("mode", "1");
                    break;
                case TuConfirmStatus.GonderimYeniKayitHataAldiBekliyor:

                    redirecturl = "_Transfer3rdErrorContinue.aspx";

                    break;


            }
        }

            if (redirecturl != _blankurl)
            {

                Page.Response.Redirect(redirecturl + QueryHelper.RefreshUrl(query), false);
            }
            else
            {
                Page.Response.Redirect("_ReadOnly.aspx" + QueryHelper.RefreshUrl(query), false);
            }
            //else
            //{
            //    QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOUHAVENOT_PERMISSION") + "');");
            //    QScript("try{Frame_PanelIframe.SpecialCloseRefreshParentGrid();}catch(exc){}");
            //}
        }
    }