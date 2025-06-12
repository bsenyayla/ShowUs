using System;
using System.Collections.Generic;
using System.Web.UI;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object;
using Object = TuFactory.CustAccount.Object;
using TuFactory.CustAccount.Business;
using Coretech.Crm.Factory.Crm;

public partial class CustAccount_Pool_CustAccountCancelConfirm : BasePage
{
    private static string _blankurl = "about:blank";
    private static Guid _recid = Guid.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        _recid = QueryHelper.GetGuid("recid");

        if (!RefleX.IsAjxPostback)
        {
            var readonlyForm = CustAccountOperations.GetCustAccountOperationsReadOnlyPageId(_recid);
            var query = new Dictionary<string, string>
            {
                 {"ObjectId", TuEntityEnum.New_CustAccountOperations.GetHashCode().ToString()},
                {"defaulteditpageid", readonlyForm.ToString()},
                {"recid", _recid.ToString()}
            };

            var url = QueryHelper.AddUpdateString(this, HTTPUtil.GetEditpage(), query);

            CustAccountOperationsDetail.AutoLoad.Url = url;

        }
    }

    protected void btnDeleteOnClick(object sender, AjaxEventArgs e)
    {
        var ts = new CustAccountOperations().GetCustAccountConfirmStatus(_recid);
        switch (ts)
        {
            case Object.CustAccountStatus.HesapKapatmaOnayiBekliyor:
                try
                {
                    new TransactionOperations().TransactionOperationsCloseConfirm(_recid);
                    Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_COMPLETED"));
                    Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_MUSTRECIPMENT"));
                    BasePage.QScript("RefreshParetnGrid(true);");
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
            default:
                Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_RECEIPT_ERROR"));
                var query = new Dictionary<string, string>();
                Page.Response.Redirect("CustAccountRouter.aspx" + QueryHelper.RefreshUrl(query));

                break;
        }


    }
    protected void btnCancelOnClick(object sender, AjaxEventArgs e)
    {
        var ts = new CustAccountOperations().GetCustAccountConfirmStatus(_recid);
        switch (ts)
        {
            case Object.CustAccountStatus.HesapKapatmaOnayiBekliyor:
                try
                {
                    new TransactionOperations().TransactionOperationsCloseReject(_recid);
                    Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_COMPLETED"));
                    BasePage.QScript("RefreshParetnGrid(true);");
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
            default:
                Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_RECEIPT_ERROR"));
                var query = new Dictionary<string, string>();
                Page.Response.Redirect("CustAccountRouter.aspx" + QueryHelper.RefreshUrl(query));

                break;
        }


    }
}