using System;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object.User;
using TuFactory.TuUser;

namespace Fraud
{
    public partial class Fraud_Main : BasePage
    {
        private TuUserApproval _userApproval = null;
        private TuUser _activeUser = null;
        private void TranslateMessage()
        {
            TabPendingTransactions.Title = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_PENDING_TRANSACTIONS");
            TabProcessMonitoring.Title = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_PROCESS_MONITORING");
            TabPendingAccountActions.Title = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTFRAUDLOG_PENDING_ACTIONS");
            TabAccountMonitoring.Title = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTFRAUDLOG_MONITORING");
            var ufFactory = new TuUserFactory();
            _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

            //if (!_userApproval.ApprovalConfirm)
            //{
            //    TabPendingTransactions.Hidden = true;
            //}
            //if (!_userApproval.ShowCancelPool)
            //{
            //    TabProcessMonitoring.Hidden = true;
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
}