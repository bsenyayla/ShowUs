using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.CustAccount.Object;
using TuFactory.Object;

public partial class CustAccount_ReadOnly_DepositPerson : UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        var recID = QueryHelper.GetString("recid");
        if (!RefleX.IsAjxPostback)
        {
            Dictionary<string, string> querySenderDepositInfo = new Dictionary<string, string>();
            var SenderTypeCombo = (Page.FindControl("new_SenderType_Container") as ComboField);
            var SenderIDCombo = (Page.FindControl("new_SenderId_Container") as ComboField);
            var DifferentSenderCombo = (Page.FindControl("new_3rdSenderId_Container") as ComboField);
            var SenderPersonCombo = (Page.FindControl("new_SenderPersonId_Container") as ComboField);
            switch (ValidationHelper.GetInteger(SenderTypeCombo.Value,0))
            {
                case (int)DepositThirdSenderTypeEnum.Own:
                    querySenderDepositInfo = new Dictionary<string, string>
                            {
                                {"defaulteditpageid",  ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_TRANSFER_FORM"))},
                                {"ObjectId", ( (int)TuEntityEnum.New_Sender).ToString()},
                                {"recid", ValidationHelper.GetString(SenderIDCombo.Value)}
                            };
                    break;
                case (int)DepositThirdSenderTypeEnum.DifferentSender:
                    querySenderDepositInfo = new Dictionary<string, string>
                            {
                                {"defaulteditpageid",  ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_TRANSFER_FORM"))},
                                {"ObjectId", ( (int)TuEntityEnum.New_Sender).ToString()},
                                {"recid", ValidationHelper.GetString(DifferentSenderCombo.Value)}
                            };
                    break;
                case (int)DepositThirdSenderTypeEnum.SenderPerson:
                    querySenderDepositInfo = new Dictionary<string, string>
                            {
                                {"defaulteditpageid",  ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_PERSON_FORM"))},
                                {"ObjectId", ( (int)TuEntityEnum.New_SenderPerson).ToString()},
                                {"recid", ValidationHelper.GetString(SenderPersonCombo.Value)}
                            };
                    break;
                   
            }
            var urlparamSenderDepositInfo = QueryHelper.RefreshUrl(querySenderDepositInfo);
            PanelSenderPerson.AutoLoad.Url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparamSenderDepositInfo);
        }
    }
}