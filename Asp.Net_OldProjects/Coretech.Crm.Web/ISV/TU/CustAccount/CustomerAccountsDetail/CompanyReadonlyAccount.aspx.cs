using AjaxPro;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Web.UI.RefleX;
using Newtonsoft.Json;
using RefleXFrameWork;
using System;
using System.Web.UI;
using TuFactory.CustAccount.Business;
using TuFactory.Object;
using TuFactory.SenderDocument;

public partial class CustAccount_CustomerAccountsDetail_CompanyReadonlyAccount : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            CustInfoFactory custFactory = new CustInfoFactory();
            Page.ClientScript.RegisterStartupScript(typeof(string), "LabelText1", "var CRM_NEW_SENDER_VKN_LABEL="
                  + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_VKN_LABEL")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "LabelText3", "var CRM_NEW_SENDER_COMPANYCOUNTRY_LABEL="
                  + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_COMPANYCOUNTRY_LABEL")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "CorpReadOnlyForm", "var CorpReadOnlyForm="
                    + JsonConvert.SerializeObject(App.Params.GetConfigKeyValue("CUSTACCOUNT_SENDERS_COMPANY_READONLY")) + "; ", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "NationTurkeyParam", "var TurkeyID="
                   + JsonConvert.SerializeObject(SenderNationalityID.Turkey) + ";", true);
            QScript("LoadCompanyAccountScreen();");
            QScript("InsertSenderDocuments();");
            Utility.RegisterTypeForAjax(typeof(AjaxMethods));
        }
    }
    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {

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