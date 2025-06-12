using System;
using System.Web.UI;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using static TuFactory.Fraud.FraudScanFactory;

public partial class Sender_UserControl_CorporatedSender : UserControl
{

    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected override void OnInit(EventArgs e)
    {
        var p = this.Page as BasePage;
        if (p != null)
        {
            p.AfterSaveHandler += p_AfterSaveHandler;
        }
    }
    private void p_AfterSaveHandler(Guid recId, DynamicFactory df, DynamicEntity de, bool IsUpdate)
    {
        int fraudStatus;
        bool customerFraudCheck = true;
        var senderAfterSaveDb = new TuFactory.Sender.SenderAfterSaveDb();
        fraudStatus = senderAfterSaveDb.GetSenderFraudStatus(recId);

        if (fraudStatus == CustomerFraudStatus.NotFraud.GetHashCode())
        {
            customerFraudCheck = senderAfterSaveDb.CustomerFraudCheck(recId);
        }
        else if (fraudStatus == CustomerFraudStatus.FraudWaiting.GetHashCode() || fraudStatus == CustomerFraudStatus.FraudRejected.GetHashCode())
        {
            customerFraudCheck = false;
        }
        else if (fraudStatus == CustomerFraudStatus.FraudConfirmed.GetHashCode())
        {
            customerFraudCheck = true;
        }

        senderAfterSaveDb.UpdateCorporatedSenderDetail(recId);
    }

}
