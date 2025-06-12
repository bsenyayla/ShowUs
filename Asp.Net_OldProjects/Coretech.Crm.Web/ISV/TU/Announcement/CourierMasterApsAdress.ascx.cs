using System;
using System.Web.UI;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;

public partial class CourierMasterApsAdress : UserControl
{
    Guid recId = ValidationHelper.GetGuid(QueryHelper.GetString("recId"));
    FileUpload document;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // var NotificationStatus = (Page.FindControl("new_NotificationStatus_Container") as ComboField);


            txtApsAdres.FieldLabel = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTCOURIERMASTER_COURIER_MASTER_APS_ADRESS");

            TuFactory.CourierManager.CourierFactory fn = new TuFactory.CourierManager.CourierFactory();
            string adress = fn.GetCustomerApsAdress(recId);
            txtApsAdres.SetValue(adress);
        }
    }

}
