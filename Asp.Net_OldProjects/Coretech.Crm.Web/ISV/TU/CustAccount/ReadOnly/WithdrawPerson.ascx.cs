using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Web.UI;
using TuFactory.CustAccount.Object;
using TuFactory.Object;
using TuFactory.CustAccount.Business;

public partial class CustAccount_ReadOnly_WithdrawPerson : UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        var recID = QueryHelper.GetString("recid");
        if (!RefleX.IsAjxPostback)
        {
            Dictionary<string, string> queryWithdrawPerson = new Dictionary<string, string>();
            CustInfoFactory custFactory = new CustInfoFactory();
            var CustAccountTypeCombo = (Page.FindControl("new_CustAccountTypeId_Container") as ComboField);
            var SenderCombo = (Page.FindControl("new_SenderId_Container") as ComboField);
            var custAccountTypeCode = custFactory.GetCustAccountTypeCode(ValidationHelper.GetGuid(CustAccountTypeCombo.Value));
            var SenderPersonCombo = (Page.FindControl("new_SenderPersonId_Container") as ComboField);
            switch (custAccountTypeCode)
            {
                case CustAccountType.GERCEK:
                    queryWithdrawPerson = new Dictionary<string, string>
                            {
                                {"defaulteditpageid",  ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_TRANSFER_FORM"))},
                                {"ObjectId", ( (int)TuEntityEnum.New_Sender).ToString()},
                                {"recid", ValidationHelper.GetString(SenderCombo.Value)}
                            };
                    break;
                case CustAccountType.TUZEL:
                        queryWithdrawPerson = new Dictionary<string, string>
                            {
                                {"defaulteditpageid",  ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_PERSON_FORM"))},
                                {"ObjectId", ( (int)TuEntityEnum.New_SenderPerson).ToString()},
                                {"recid", ValidationHelper.GetString(SenderPersonCombo.Value)}
                            };
                        break;
            }
            var urlparamWithdrawPerson = QueryHelper.RefreshUrl(queryWithdrawPerson);
            PanelSenderPersonWithdraw.AutoLoad.Url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparamWithdrawPerson);
        }
    }
}