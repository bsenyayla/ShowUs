using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Web.UI;
using TuFactory.Object;

public partial class Sender_UserControl_SenderInfo : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        var recID = QueryHelper.GetString("recid");
        if (!RefleX.IsAjxPostback)
        {
            Dictionary<string, string> querySender = new Dictionary<string, string>();

            var sd = new StaticData();
            sd.AddParameter("recID", System.Data.DbType.String, recID);
            var SenderId = ValidationHelper.GetGuid(sd.ReturnDataset("Select new_SenderId From vNew_Payment(NoLock) Where New_PaymentId = @recID").Tables[0].Rows[0]["new_SenderId"],Guid.Empty);

            querySender = new Dictionary<string, string>
                            {
                                {"defaulteditpageid",  ValidationHelper.GetString(ParameterFactory.GetParameterValue("SENDER_INFO_FORM"))},
                                {"ObjectId", ( (int)TuEntityEnum.New_Sender).ToString()},
                                {"recid", ValidationHelper.GetString(SenderId)}
                            };

            var urlparamSender = QueryHelper.RefreshUrl(querySender);
            PanelCustomerAccount.AutoLoad.Url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparamSender);
        }
    }
}