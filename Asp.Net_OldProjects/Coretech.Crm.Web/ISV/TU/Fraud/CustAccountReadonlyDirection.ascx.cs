using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Web.UI;
using TuFactory.Fraud;
using TuFactory.Object;
using TuFactory.Object.Confirm;
using TuFactory.Object.CustAccountAml;
using TuFactory.CustAccount.Business;

public partial class Fraud_CustAccountReadonlyDirection : UserControl
{
    CustAccountFraudFactory ff = new CustAccountFraudFactory();
    protected void Page_Load(object sender, EventArgs e)
    {
        var recID = QueryHelper.GetString("recid");
        Dictionary<string, string> querySender = new Dictionary<string, string>();
        Dictionary<string, string> queryAccountOperation = new Dictionary<string, string>();
        
        if (!RefleX.IsAjxPostback)
        {
            CustAccountAml custOperation = ff.GetCustAccountOperation(ValidationHelper.GetGuid(recID));
            queryAccountOperation = new Dictionary<string, string>
                            {
                                {"defaulteditpageid",  ValidationHelper.GetString(CustAccountOperations.GetCustAccountOperationsReadOnlyPageId(custOperation.AccountOperationID))},
                                {"ObjectId", ( (int)TuEntityEnum.New_CustAccountOperations).ToString()},
                                {"recid", ValidationHelper.GetString(custOperation.AccountOperationID)}
                            };
            switch (custOperation.OperationType)
            {
                case CustAccountOperationType.ACCOUNT_OPEN:
                    LblOperationDetail.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTFRAUDLOG_CUST_ACCOUNT_OPEN_MSG");
                    break;
                case CustAccountOperationType.ACCOUNT_DEPOSIT:
                    LblOperationDetail.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTFRAUDLOG_CUST_ACCOUNT_DEPOSIT");
                    break;
                case CustAccountOperationType.ACCOUNT_WITHDRAW:
                    LblOperationDetail.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTFRAUDLOG_CUST_ACCOUNT_WITHDRAW");
                    break;
            }
            var urlparamAccountOperation = QueryHelper.RefreshUrl(queryAccountOperation);
            PanelCustomerAccountOperation.AutoLoad.Url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparamAccountOperation);
        }
    }
}