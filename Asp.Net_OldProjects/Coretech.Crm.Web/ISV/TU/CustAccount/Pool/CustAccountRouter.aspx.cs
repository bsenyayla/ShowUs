using System;
using System.Collections.Generic;
using System.Web.UI;
using Coretech.Crm.Factory;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object.User;
using TuFactory.TuUser;
using Object = TuFactory.CustAccount.Object;
using TuFactory.CustAccount.Business;

public partial class CustAccount_Pool_CustAccountRouter : BasePage
{
    private TuUserApproval _userApproval = null;
    private static string _blankurl = "about:blank";
    MessageBox ms = new MessageBox { MessageType = EMessageType.Information, Modal = true };

    protected void Page_Load(object sender, EventArgs e)
    {
        string redirecturl = _blankurl;
        var query = new Dictionary<string, string>();
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

        var recid = QueryHelper.GetString("recid");

        if (QueryHelper.GetBoolean("doReceiptEdit", false))
        {
            query.Add("doReceiptEdit", "1");
        }

        var ts = new CustAccountOperations().GetCustAccountConfirmStatus(ValidationHelper.GetGuid(recid));
        switch (ts)
        {
            case Object.CustAccountStatus.IslemAmlKontrol:
            case Object.CustAccountStatus.IslemAmlOnayBeklemede:
            case Object.CustAccountStatus.IslemUptMerkeziOnayinda:
            case Object.CustAccountStatus.IslemUptMerkezOnayiniGecti:
            case Object.CustAccountStatus.IslemIptalEdildi:
            case Object.CustAccountStatus.HesapAcmaOnayiBekliyor:
            case Object.CustAccountStatus.HesapAcmaIptalEdildiAMLFraud:
            case Object.CustAccountStatus.HesabaParaAktarmaOnayiBekliyor:
            case Object.CustAccountStatus.HesabaParaAktarmaIptalEdildiAMLFraud:
            case Object.CustAccountStatus.HesaptanNakitCekmeOnayiBekliyor:
            case Object.CustAccountStatus.HesaptanNakitCekmeIptalEdildiAMLFraud:
            case Object.CustAccountStatus.HesapKapatmaIptalEdildiAMLFraud:
            case Object.CustAccountStatus.HesabaParaAktarmaAMLFraudOnayiBekliyor:
            case Object.CustAccountStatus.HesapAcmaAMLFraudOnayiBekliyor:
            case Object.CustAccountStatus.HesapKapatmaAMLFraudOnayiBekliyor:
            case Object.CustAccountStatus.HesaptanNakitCekmeAMLFraudOnayiBekliyor:
            case Object.CustAccountStatus.HesabaParaAktarmaIcOnayBekliyor:
            case Object.CustAccountStatus.HesapAcmaIcOnayBekliyor:
            case Object.CustAccountStatus.HesapKapatmaIcOnayBekliyor:
            case Object.CustAccountStatus.HesaptanNakitCekmeIcOnayBekliyor:
            case Object.CustAccountStatus.HesabaParaAktarmaIptalEdildiIcOnay:
            case Object.CustAccountStatus.HesapAcmaIptalEdildiIcOnay:
            case Object.CustAccountStatus.HesapKapatmaIptalEdildiIcOnay:
            case Object.CustAccountStatus.HesaptanNakitCekmeIptalEdildiIcOnay:

            case Object.CustAccountStatus.UPTKartanHesabaParaTransferiAMLFraudOnayiBekliyor:
            case Object.CustAccountStatus.UPTKartaParaTransferiAMLFraudOnayiBekliyor:
            case Object.CustAccountStatus.UPTKartaParaTransferiIcOnayBekliyor:
            case Object.CustAccountStatus.UPTKartanHesabaParaTransferiIcOnayBekliyor:
                redirecturl = "CustAccountReadOnly.aspx";
                break;
            //case Object.CustAccountStatus.HesapKapatmaOnayiBekliyor:
            //    redirecturl = _userApproval.CustAccountCancelConfirm ? "CustAccountCancelConfirm.aspx" : _blankurl;
            //    break;
            case Object.CustAccountStatus.HesapKapatmaTamamlandi:
            case Object.CustAccountStatus.HesaptanNakitCekmeTamamlandi:
            case Object.CustAccountStatus.HesabaParaAktarmaTamamlandi:
            case Object.CustAccountStatus.HesapAcmaTamamlandi:
            case Object.CustAccountStatus.UPTKartanHesabaParaTransferiTamamlandi:
            case Object.CustAccountStatus.UPTKartaParaTransferiTamamlandi:

            case Object.CustAccountStatus.HesapAcildiDekontBasilacak:
            case Object.CustAccountStatus.HesapKapatmaDekontBasilacak:
            case Object.CustAccountStatus.HesabaParaAktarildDekontBasilacak:
            case Object.CustAccountStatus.HesaptanNakitCekmeDekontBasilacak:
            case Object.CustAccountStatus.UPTKartanHesabaParaTransferiDekontBasilacak:
            case Object.CustAccountStatus.UPTKartaParaTransferiDekontBasilacak:
                redirecturl = "CustAccountReceipt.aspx";
                break;
        }

        if (redirecturl != _blankurl)
        {

            Page.Response.Redirect(redirecturl + QueryHelper.RefreshUrl(query));
        }
        else
        {
            Page.Response.Redirect("CustAccountReadOnly.aspx" + QueryHelper.RefreshUrl(query));
        }
        //else
        //{
        //    QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOUHAVENOT_PERMISSION") + "');");
        //    QScript("try{Frame_PanelIframe.SpecialCloseRefreshParentGrid();}catch(exc){}");
        //}
    }
}