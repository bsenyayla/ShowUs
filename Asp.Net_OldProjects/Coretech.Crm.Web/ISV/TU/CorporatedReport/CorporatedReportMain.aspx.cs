using System;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object.User;
using TuFactory.TuUser;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using System.Data;

public partial class CorporatedReport_Main : BasePage
{
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    private void TranslateMessage()
    {
        /*
        TabOperationPool.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_OPERATION_POOL");
        TabPendingTransactions.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PENDING_TRANSACTIONS");
        TabCancelPool.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_CANCEL_POOL");
        TabProcessMonitoring.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING");
        TabRefundPool.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_INTEGRATION_REFUND_POOL");
        TabProblemTransaction.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PROBLEM_TRANSACTION_POOL");
        TabGsmTransaction.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_GSM_TRANSACTION_POOL");

        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

        if (!_userApproval.ApprovalConfirm && !_userApproval.ApprovalRefund)
        {
            TabOperationPool.Hidden = true;
        }
        if (!_userApproval.ShowCancelPool)
        {
            TabCancelPool.Hidden = true;
        }
        if (!_userApproval.RefundStart)
        {
            TabRefundPool.Hidden = true;
        }
        if (!_userApproval.ShowProblemTransaction)
        {
            TabProblemTransaction.Hidden = true;
        }
        */
    }

    private bool GetOfficeUsesMobileArchive(Guid officeId)
    {
        var sd = new StaticData();

        sd.AddParameter("officeId", DbType.Guid, officeId);
        bool gdret = ValidationHelper.GetBoolean(sd.ExecuteScalar("select new_UsesMobileArchive from vNew_Office (NoLock) where New_OfficeId = @officeId"));
        return gdret;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        bool EArchive = GetOfficeUsesMobileArchive(App.Params.CurrentUser.Office.OfficeId);
        

    }
    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
        }
        base.OnPreInit(e);
    }
}