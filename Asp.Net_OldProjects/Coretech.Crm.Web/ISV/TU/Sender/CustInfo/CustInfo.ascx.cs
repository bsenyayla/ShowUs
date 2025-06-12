using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Web.UI;
using TuFactory.CustAccount;
using TuFactory.CustAccount.Business;
using TuFactory.CustAccount.Object;
using TuFactory.Object;

public partial class Sender_CustInfo_CustInfo : UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        var recID = QueryHelper.GetString("recid");
        var custAccountDb = new CustAccountDb();

       var custAccountOperation =   custAccountDb.GetCustAccountOperation(ValidationHelper.GetGuid(recID));

        if (!RefleX.IsAjxPostback)
        {
            Dictionary<string, string> querySender = new Dictionary<string, string>();
            //var SenderCombo = (Page.FindControl("new_SenderId_Container") as ComboField);
            //var CustAccountTypeCombo = (Page.FindControl("new_CustAccountTypeId_Container") as ComboField);
            CustInfoFactory custFactory = new CustInfoFactory();

            var custAccountType = custFactory.GetCustAccountTypeCode(ValidationHelper.GetGuid(custAccountOperation.Rows[0]["new_CustAccountTypeId"]));

            switch (custAccountType)
            {
                case CustAccountType.TUZEL:
                    querySender = new Dictionary<string, string>
                            {
                                {"defaulteditpageid",  ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_CUSTACCOUNT_CORP_WITHSENDERDOCUMENT_FORM"))},
                                {"ObjectId", ( (int)TuEntityEnum.New_Sender).ToString()},
                                {"recid", ValidationHelper.GetString(custAccountOperation.Rows[0]["new_SenderId"])}
                            };
                    break;
                case CustAccountType.GERCEK:
                    querySender = new Dictionary<string, string>
                            {
                                {"defaulteditpageid",  ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_TRANSFER_WITHSENDERDOCUMENT_FORM"))},
                                {"ObjectId", ( (int)TuEntityEnum.New_Sender).ToString()},
                                {"recid", ValidationHelper.GetString(custAccountOperation.Rows[0]["new_SenderId"])}
                            };
                    break;
                default:
                    break;
            }
            var urlparamSender = QueryHelper.RefreshUrl(querySender);
            PanelCustomerAccount.AutoLoad.Url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparamSender);
        }
    }
}