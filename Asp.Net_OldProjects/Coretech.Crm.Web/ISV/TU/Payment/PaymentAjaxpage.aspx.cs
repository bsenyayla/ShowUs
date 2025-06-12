using System;
using System.Data;
using System.Web.UI;
using AjaxPro;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Newtonsoft.Json;
using RefleXFrameWork;
using TuFactory.KpsAps;
using TuFactory.Object;
using TuFactory.Object.AjaxObject;
using TuFactory.Payment;
using TuFactory.Sender;

public partial class Payment_PaymentAjaxpage : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            Utility.RegisterTypeForAjax(typeof(AjaxMethods));

            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage", "var NEW_RECIPIENT_VALIDDATEOFIDENDITY_NOT_VALID="
               + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_RECIPIENT_VALIDDATEOFIDENDITY_NOT_VALID")) + ";", true);

            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage1", "var NEW_RECIPIENT_KPS_ZORUNLU="
                           + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_RECIPIENT_KPS_ZORUNLU")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage2", "var NEW_RECIPIENT_KPS_HATALI="
                                      + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_RECIPIENT_KPS_HATALI")) + ";", true);
            Page.ClientScript.RegisterClientScriptInclude("key", "JS/PaymentAjaxpage.js?" + new Random().Next(10000000));
        }
    }
    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {

        [AjaxMethod()]
        public PaymentCalculate CalculateData(
            string recordId, string property, decimal propertyAmount, string propertyAmountCurrency

            )
        {
            var tpc = new PaymentFactory();
           //var ret = tpc.Calculate(ValidationHelper.GetGuid(recordId), property, propertyAmount, ValidationHelper.GetGuid(propertyAmountCurrency));

            return new PaymentCalculate();
        }
        [AjaxMethod()]
        public AjxKpsPerson GetKpsData(string senderIdendificationNumber1, string nationalityId)
        {
            var ret = new AjxKpsPerson();
            var sf = new SenderFactory();
            try
            {
                ret = sf.GetKpsData(senderIdendificationNumber1, ValidationHelper.GetGuid(nationalityId));
            }
            catch (Exception)
            {
                ret.new_cameFromKps = false;
            }

            return ret;
        }
        [AjaxMethod()]
        public AjxAddress GetApsData(string senderIdendificationNumber1, string nationalityId)
        {
            var ret = new AjxAddress();
            var sf = new KpsApsFactory();
            try
            {
                ret = sf.GetApsData(senderIdendificationNumber1, ValidationHelper.GetGuid(nationalityId));
            }
            catch (Exception)
            {

            }

            return ret;
        }

        [AjaxMethod()]
        public bool GetRequaredNationality(string nationalityId)
        {
            var ret = false;
            try
            {
                var sd = new StaticData();
                string strsql =
                    "select COUNT(*) from vnew_nationality Where new_ExtCode='TR' and New_nationalityId=@New_nationalityId";
                sd.AddParameter("New_nationalityId", DbType.Guid, ValidationHelper.GetGuid(nationalityId));
                ret = ValidationHelper.GetBoolean(sd.ExecuteScalar(strsql));

            }
            catch (Exception)
            {

            }

            return ret;
        }
        [AjaxMethod()]
        public string GetRecipientBirthdate(string dtmBirthdate)
        {
            var ret = string.Empty;
            try
            {
                var sd = new StaticData();
                sd.AddParameter("BirthDate", DbType.Date, ValidationHelper.GetDate(dtmBirthdate, App.Params.CurrentUser.UserCulture));
                sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
                const string strsql = "select dbo.fnTuPaymentBirthdateCheck(@BirthDate,@SystemUserId ) ";
                ret = ValidationHelper.GetString(sd.ExecuteScalar(strsql));
            }
            catch (Exception)
            {

            }

            return ret;
        }

        [AjaxMethod()]
        public bool IsIdentificationValidDate(string strIdentificationCardType)
        {
            var ret = false;
            var sd = new StaticData();
            sd.AddParameter("new_IdentificationCardType", DbType.Guid, ValidationHelper.GetGuid(strIdentificationCardType));
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            //strIdentificationCardType
            const string strsql = @"
SELECT COUNT(*) FROM dbo.vNew_CountryIdentificatonCardType ct
WHERE 
	new_CountryID in (
(SELECT new_CountryID FROM dbo.SystemUserExtension se 
 INNER JOIN dbo.vNew_Corporation co ON co.new_CorporationID=se.new_CorporationID
 WHERE SystemUserId=@SystemUserId)
)
AND new_IdentificationCardType=@new_IdentificationCardType
AND new_IdExpirationDateIsRequared=1
AND isnull(ct.DeletionStateCode,0)=0
";
            ret = ValidationHelper.GetBoolean(sd.ExecuteScalar(strsql));
            return ret;
        }
    }


}