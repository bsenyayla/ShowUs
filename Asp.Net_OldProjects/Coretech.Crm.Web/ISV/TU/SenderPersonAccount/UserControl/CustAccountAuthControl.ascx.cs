using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Web.UI;
using TuFactory.Sender;
using TuFactory.Sender.CorporateAccountSender;
using TuFactory.Sender.CorporateAccountSender.Model;
using static TuFactory.Fraud.FraudScanFactory;

public partial class SenderPersonAccount_UserControl_CustAccountAuthControl : UserControl
{
    Guid senderID = ValidationHelper.GetGuid(QueryHelper.GetString("new_SenderId"));
    Guid custAccountAuthId = ValidationHelper.GetGuid(QueryHelper.GetString("recId"));
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
       
    }

}
