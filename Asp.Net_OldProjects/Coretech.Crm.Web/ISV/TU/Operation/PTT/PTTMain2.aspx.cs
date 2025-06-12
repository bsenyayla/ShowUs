using System;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object.User;

public partial class Operation_PTTMain2 : BasePage
{
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    private void TranslateMessage()
    {
        //TabOperationPool.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_OPERATION_POOL");
        //TabPendingTransactions.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PENDING_TRANSACTIONS");
        //TabCancelPool.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_CANCEL_POOL");
        //TabProcessMonitoring.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING");
        //TabRefundPool.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_INTEGRATION_REFUND_POOL");

        //var ufFactory = new TuUserFactory();
        //_userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

        //if (!_userApproval.ApprovalConfirm && !_userApproval.ApprovalRefund)
        //{
        //    TabOperationPool.Hidden = true;
        //}
        //if (!_userApproval.ShowCancelPool)
        //{
        //    TabCancelPool.Hidden = true;
        //}
        //if (!_userApproval.RefundStart)
        //{
        //    TabRefundPool.Hidden = true;
        //}
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        
       

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