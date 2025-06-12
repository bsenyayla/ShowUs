using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using TuFactory.Object.User;
using TuFactory.TuUser;

public partial class CustAccount_ApprovePool_CustAccountMainPool : BasePage
{
    private TuUserApproval _userApproval = null;
    protected void Page_Load(object sender, EventArgs e)
    {
    }

    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            var ufFactory = new TuUserFactory();
            _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
            if (_userApproval.CustAccountOperationApprover)
            {
                Tab TabCustAccountOpenCloseOperation = new Tab();
                TabCustAccountOpenCloseOperation.TabIndex = 1;
                TabCustAccountOpenCloseOperation.Url = "DetailPool/CustAccountOpenCloseApprovePool.aspx";
                TabCustAccountOpenCloseOperation.Closable = false;
                TabCustAccountOpenCloseOperation.Title = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_ACCOUNT_OPEN_CLOSE_APPROVEPOOL");
                TabCustAccountOpenCloseOperation.ID = "TabCustAccountOpenCloseOperation";
                TabCustAccountOpenCloseOperation.TabMode = ETabMode.Frame;
                TabPanel1.Tabs.Add(TabCustAccountOpenCloseOperation);

                Tab TabCustAccountCashDrawCashDepositOperation = new Tab();
                TabCustAccountCashDrawCashDepositOperation.TabIndex = 2;
                TabCustAccountCashDrawCashDepositOperation.Url = "DetailPool/CustAccountDrawDepositApprovePool.aspx";
                TabCustAccountCashDrawCashDepositOperation.Closable = false;
                TabCustAccountCashDrawCashDepositOperation.Title = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_CASH_DRAW_DEPOSIT_APPROVEPOOL");
                TabCustAccountCashDrawCashDepositOperation.ID = "TabCustAccountCashDrawCashDepositOperation";
                TabCustAccountCashDrawCashDepositOperation.TabMode = ETabMode.Frame;
                TabPanel1.Tabs.Add(TabCustAccountCashDrawCashDepositOperation);

                Tab TabCorporatedCustAccountApproveOperation = new Tab();
                TabCorporatedCustAccountApproveOperation.TabIndex = 3;
                TabCorporatedCustAccountApproveOperation.Url = "DetailPool/CorporatedCustAccountApprovePool.aspx";
                TabCorporatedCustAccountApproveOperation.Closable = false;
                TabCorporatedCustAccountApproveOperation.Title = CrmLabel.TranslateMessage("CRM.NEW_SENDER_CORPORATED_SENDER_CDD_CONFIRMPOOL");
                TabCorporatedCustAccountApproveOperation.ID = "TabCorporatedCustAccountApproveOperation";
                TabCorporatedCustAccountApproveOperation.TabMode = ETabMode.Frame;
                TabPanel1.Tabs.Add(TabCorporatedCustAccountApproveOperation);
            }
            if (_userApproval.CustAccountBlockApprover)
            {
                Tab TabCustAccountBlockedOperation = new Tab();
                TabCustAccountBlockedOperation.TabIndex = 2;
                TabCustAccountBlockedOperation.Url = "DetailPool/CustAccountBlockApprove.aspx";
                TabCustAccountBlockedOperation.Closable = false;
                TabCustAccountBlockedOperation.Title = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_BLOCKEDACCOUNTS_APPROVEPOOL");
                TabCustAccountBlockedOperation.ID = "TabCustAccountBlockedOperation";
                TabCustAccountBlockedOperation.TabMode = ETabMode.Frame;
                TabPanel1.Tabs.Add(TabCustAccountBlockedOperation);
                
            }
        }
        base.OnPreInit(e);
    }
}