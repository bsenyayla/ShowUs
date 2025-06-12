using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using Services;
using Services.Interfaces;
using System;
using System.Collections.Generic;
using TuFactory.CustAccount.Business;
using TuFactory.CustAccount.Business.Service;
using TuFactory.CustAccount.Object;
using TuFactory.Domain.Enums;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;

public partial class CustAccount_ApprovePool_DetailPool_ApprovePoolConfirm : BasePage
{
    private static string _blankurl = "about:blank";
    private static Guid _recid;
    private static string urlparam;
    private TuUserApproval _userApproval = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        _recid = QueryHelper.GetGuid("recid");


        if (!RefleX.IsAjxPostback)
        {
            ToolbarButtonReject.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTAPRROVEPOOL_REJECTACTION");
            LoadUserPrivilege();
            LoadLabel();

            var readonlyForm = CustAccountOperations.GetCustAccountOperationsReadOnlyPageId(_recid);
            var query = new Dictionary<string, string>
            {
                {"ObjectId", TuEntityEnum.New_CustAccountOperations.GetHashCode().ToString()},
                {"defaulteditpageid", readonlyForm.ToString()},
                {"recid", _recid.ToString()},
            };

            var url = QueryHelper.AddUpdateString(this, HTTPUtil.GetEditpage(), query);

            CustAccountOperationsDetail.AutoLoad.Url = url;          
        }
    }

    private void LoadLabel()
    {
        var ts = new TuFactory.CustAccount.Business.CustAccountOperations().GetCustAccountConfirmStatus(ValidationHelper.GetGuid(_recid));
        switch (ts)
        {
            case CustAccountStatus.HesapAcmaIcOnayBekliyor:
            case CustAccountStatus.HesabaParaAktarmaIcOnayBekliyor:
            case CustAccountStatus.HesaptanNakitCekmeIcOnayBekliyor:
                lblInfo.SetVisible(true);
                lblInfo.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTAPRROVEPOOL_OPERATIONAPPROVEDROLE_NEEDED");
                break;
            case CustAccountStatus.HesapKapatmaIcOnayBekliyor:
                lblInfo.SetVisible(true);
                lblInfo.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTAPRROVEPOOL_OPERATIONCLOSEACCOUNTROLE_NEEDED");
                break;
            default:
                lblInfo.SetVisible(false);
                break;
        }
    }

    private void LoadUserPrivilege()
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        var ts = new TuFactory.CustAccount.Business.CustAccountOperations().GetCustAccountConfirmStatus(ValidationHelper.GetGuid(_recid));
        if (_userApproval.CustAccountOperationApprover)
        {
            switch (ts)
            {
                case CustAccountStatus.HesapAcmaIcOnayBekliyor:
                case CustAccountStatus.HesabaParaAktarmaIcOnayBekliyor:
                case CustAccountStatus.HesaptanNakitCekmeIcOnayBekliyor:
                    btnConfirm.SetVisible(true);
                    btnReject.SetVisible(true);
                    break;
            }
        }
        if (_userApproval.CustAccountCloseConfirm && ts == CustAccountStatus.HesapKapatmaIcOnayBekliyor)
        {
            btnConfirm.SetVisible(true);
            btnReject.SetVisible(true);
        }
    }

    protected void btnConfirmOnClick(object sender, AjaxEventArgs e)
    {
        if (ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("WORK_WITH_THE_NEW_CUSTACCOUNT_SERVICE")))
        {
            btnConfirmOnClick2(sender, e);
            return;
        }

        CustAccountApprovePoolService approvePoolService = new CustAccountApprovePoolService();
        try
        {
            approvePoolService.ApproveCustAccountOperation(ValidationHelper.GetGuid(_recid));
            TuFactory.CustAccount.Business.CustAccountOperations accountOperations = new TuFactory.CustAccount.Business.CustAccountOperations();
            var operationType = accountOperations.GetCustAccountOperationType(ValidationHelper.GetGuid(_recid));
            ConfirmFactory amlFraudService = new ConfirmFactory();

            if (operationType != TuFactory.CustAccount.Object.CustAccountOperationType.Hesap_Kapatma)
            {
                var amlFraudResponse = amlFraudService.AmlFraudProcess(ValidationHelper.GetGuid(_recid));
                if (!amlFraudResponse.result)
                {
                    Alert(amlFraudResponse.message);
                    QScript("RefreshParetnGrid(true);");
                    return;
                }
            }

            Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTAPRROVEPOOL_OPERATIONAPPROVED"));
            Response.Redirect("ConfirmRouter.aspx?recid=" + _recid);

        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex);
        }
        finally
        {

        }
    }

    protected void btnConfirmOnClick2(object sender, AjaxEventArgs e)
    {
        ICustAccountOperationService<object> _service = null;
        try
        {
            var ts = new TuFactory.CustAccount.Business.CustAccountOperations().GetCustAccountConfirmStatus(ValidationHelper.GetGuid(_recid));

            switch (ts)
            {
                case CustAccountStatus.HesapAcmaIcOnayBekliyor:
                    _service = new CreateAccountService<object>();
                    break;
                case CustAccountStatus.HesapKapatmaIcOnayBekliyor:
                    _service = new CloseAccountService<object>();
                    break;
                case CustAccountStatus.HesabaParaAktarmaIcOnayBekliyor:
                    _service = new CashDepositService<object>();
                    break;
                case CustAccountStatus.HesaptanNakitCekmeIcOnayBekliyor:
                    _service = new CashWithdrawalService<object>();
                    break;
                default:
                    break;
            }

            var response = _service.ApproveConfirm(ValidationHelper.GetGuid(_recid));

            switch (response.OperationLevel)
            {
                case OperationLevel.FraudCheck:
                    if (response.ResponseStatus == ServiceResponseStatus.Error)
                    {
                        Alert(response.RETURN_DESCRIPTION);
                        BasePage.QScript("RefreshParetnGrid(true);");
                        return;
                    }
                    break;
                default:
                    break;
            }

            Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTAPRROVEPOOL_OPERATIONAPPROVED"));
            Response.Redirect("ConfirmRouter.aspx?recid=" + _recid);
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "CustAccount_ApprovePool_DetailPool_ApprovePoolConfirm.btnConfirmOnClick");
            Alert(ex.Message);
        }

    }

    protected void btnRejectOnClick(object sender, AjaxEventArgs e)
    {
        try
        {
            if (ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("WORK_WITH_THE_NEW_CUSTACCOUNT_SERVICE")))
            {
                ICustAccountOperationService<object> _service = null;
                var ts = new TuFactory.CustAccount.Business.CustAccountOperations().GetCustAccountConfirmStatus(ValidationHelper.GetGuid(_recid));

                switch (ts)
                {
                    case CustAccountStatus.HesapAcmaIcOnayBekliyor:
                        _service = new CreateAccountService<object>();
                        break;
                    case CustAccountStatus.HesapKapatmaIcOnayBekliyor:
                        _service = new CloseAccountService<object>();
                        break;
                    case CustAccountStatus.HesabaParaAktarmaIcOnayBekliyor:
                        _service = new CashDepositService<object>();
                        break;
                    case CustAccountStatus.HesaptanNakitCekmeIcOnayBekliyor:
                        _service = new CashWithdrawalService<object>();
                        break;
                    default:
                        break;
                }

                var response = _service.ApproveReject(ValidationHelper.GetGuid(_recid), txtRejectReason.Value);
                if (response.ResponseStatus == ServiceResponseStatus.Error)
                {
                    Alert(response.RETURN_DESCRIPTION);
                    return;
                }
            }
            else
            {
                CustAccountApprovePoolService approvePoolService = new CustAccountApprovePoolService();
                approvePoolService.RejectCustAccountOperation(ValidationHelper.GetGuid(_recid), txtRejectReason.Value);
            }

            Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTAPRROVEPOOL_OPERATIONREJECTED"));
            QScript("windowReject.hide();");
            QScript("RefreshParetnGrid(true);");
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex);
        }
        finally
        {

        }
    }
}