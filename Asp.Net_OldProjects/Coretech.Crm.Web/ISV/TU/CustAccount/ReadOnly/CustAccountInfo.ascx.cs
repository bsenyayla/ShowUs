using System;
using System.Collections.Generic;
using System.Web.UI;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using Coretech.Crm.Factory.Crm.Parameters;
using TuFactory.Object;
using TuFactory.CustAccount;

public partial class CustAccount_ReadOnly_CustAccountInfo : UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        var operationID = QueryHelper.GetString("recid");
        var custAccountDb = new CustAccountDb();
        var custAccountOperation = custAccountDb.GetCustAccountOperation(ValidationHelper.GetGuid(operationID));
        if (!RefleX.IsAjxPostback)
        {
           // var CustomerAccountCombo = (Page.FindControl("new_CustAccountId_Container") as ComboField);
            Dictionary<string, string> queryAccount;
            queryAccount = new Dictionary<string, string>
                            {
                                {"defaulteditpageid",  ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_CUSTACCOUNTS_FORM"))},
                                {"ObjectId", ( (int)TuEntityEnum.New_CustAccounts).ToString()},
                                {"recid", ValidationHelper.GetString(custAccountOperation.Rows[0]["new_CustAccountId"])}
                            };
            var urlparamSender = QueryHelper.RefreshUrl(queryAccount);
            PanelCustomerAccountInfo.AutoLoad.Url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparamSender);
        }
    }
}