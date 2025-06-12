using System;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;

public partial class AccountMonitoring_AccountMonitoringMain : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            ACCOUNTACTIVITY.Title = CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_TAB_ACCOUNT_ACTIVITY");
            ACCOUNTBALANCE.Title = CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_TAB_ACCOUNT_BALANCE");

            ACCOUNTACTIVITY.Url = "AccountActivity.aspx";
            ACCOUNTBALANCE.Url = "AccountBalance.aspx";
            TabPanel1.LoadUrl();
        }
    }
}