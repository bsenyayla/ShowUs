using System;
using System.Collections.Generic;
using System.Web.UI;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Object = TuFactory.CustAccount.Object;
using TuFactory.CustAccount.Business;

public partial class CustAccount_ApprovePool_DetailPool_ConfirmRouter : BasePage
{
    private static string _blankurl = "about:blank";
    protected void Page_Load(object sender, EventArgs e)
    {
        string redirecturl = _blankurl;
        var query = new Dictionary<string, string>();
        var recid = QueryHelper.GetString("recid");
        var ts = new CustAccountOperations().GetCustAccountConfirmStatus(ValidationHelper.GetGuid(recid));
        switch (ts)
        {
            case Object.CustAccountStatus.HesapAcildiDekontBasilacak:
            case Object.CustAccountStatus.HesapKapatmaDekontBasilacak:
            case Object.CustAccountStatus.HesabaParaAktarildDekontBasilacak:
            case Object.CustAccountStatus.HesaptanNakitCekmeDekontBasilacak:
                redirecturl = "../../Pool/CustAccountReceipt.aspx";
                break;
            default:
                redirecturl = "../../Pool/CustAccountReadOnly.aspx";
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
    }
}