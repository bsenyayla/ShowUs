using AjaxPro;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Web.UI.RefleX;
using Newtonsoft.Json;
using System;
using System.Web.UI;
using TuFactory.CustAccount.Business;
using TuFactory.CustAccount.Object;
using TuFactory.Object;
using TuFactory.Sender;
using TuFactory.SenderDocument;

public partial class SenderAccountCompany_SenderAccountCompany : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        CustInfoFactory custFactory = new CustInfoFactory();
        Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage5", "var CRM_NEW_SENDER_SINGULARITY_CONFIRM="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_SINGULARITY_CONFIRM")) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "InvalidGsm", "var InvalidGsm="
                  + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_PHONENUMBER_INVALID_EMPTY")) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "LabelText2", "var CRM_NEW_SENDER_COMPANYNAME_LABEL="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_COMPANYNAME_LABEL")) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "LabelText1", "var CRM_NEW_SENDER_VKN_LABEL="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_VKN_LABEL")) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "LabelText3", "var CRM_NEW_SENDER_COMPANYCOUNTRY_LABEL="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_COMPANYCOUNTRY_LABEL")) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "NationTurkeyParam", "var TurkeyID="
               + JsonConvert.SerializeObject(SenderNationalityID.Turkey) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "IdentificationType", "var IdentificationType="
               + JsonConvert.SerializeObject(App.Params.GetConfigKeyValue("OTHER_IDENTIFICATION_TYPE", Convert.ToString(Guid.Empty))) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "CorpCustType", "var CorpCustType="
                + JsonConvert.SerializeObject(custFactory.GetAccountTypeID(CustAccountType.TUZEL)) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "CorpReadOnlyForm", "var CorpReadOnlyForm="
                + JsonConvert.SerializeObject(App.Params.GetConfigKeyValue("READONLY_SENDER_FOR_CUSTACCOUNT_CORP_FORM")) + "; ", true);
        QScript("CustomerAccountScreenSetSenderID();");
        QScript("LoadCompanyAccountScreen();");
        QScript("SetCorpCustomerAccountType();");
        QScript("InsertSenderDocuments();");
        Utility.RegisterTypeForAjax(typeof(AjaxMethods));
    }
    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {
        [AjaxMethod()]
        public SingularityControlReponse CheckSenderSingularity(string mersisNo, string VKN, string CompanyName)
        {
            SenderFactory senderService = new SenderFactory();

            return senderService.CheckIfSingularityExists(mersisNo, VKN, CompanyName);
        }

        [AjaxMethod()]
        public bool UpdateIsDomesticValue()
        {
            SenderFactory senderService = new SenderFactory();
            string countryCode = senderService.GetUserCountryCode();
            if (countryCode == SenderNationality.TC)
            {
                return false;
            }
            else
            {
                return true;
            }
        }

        [AjaxMethod()]
        public AjxChannelCorpObj GetChannelCorpValues(string recID)
        {
            Guid senderID;
            if (recID == string.Empty)
                senderID = Guid.Empty;
            else
                senderID = new Guid(recID);
            SenderFactory sc = new SenderFactory();
            return sc.GetLocalCorpChannelValues(senderID);
        }

        [AjaxMethod()]
        public void InsertSenderDocumentsIfNecessary(Guid senderID, Guid custTypeID, Guid nationID)
        {
            SenderDocumentFactory docService = new SenderDocumentFactory();
            try
            {
                docService.InsertSenderDocumentsIfNecessary(senderID, custTypeID, nationID);
            }
            catch
            {
                throw;
            }
        }
    }
}