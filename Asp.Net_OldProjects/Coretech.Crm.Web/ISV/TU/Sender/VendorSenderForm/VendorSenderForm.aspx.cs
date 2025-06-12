using System;
using System.Web.UI;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using Coretech.Crm.Factory.Crm;
using AjaxPro;
using Newtonsoft.Json;
using TuFactory.Object;
using TuFactory.Object.AjaxObject;
using TuFactory.Sender;
using Coretech.Crm.Utility.Util;
using TuFactory.KpsAps;
using TuFactory.Object.Sender;
using TuFactory.CreditCheck;

public partial class Sender_VendorSenderForm_VendorSenderForm : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            LoadMessages();
            Utility.RegisterTypeForAjax(typeof(AjaxMethods));
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage", "var NEW_TRANSFER_SENDER_VALIDDATEOFIDENDITY_NOT_VALID="
                + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDER_VALIDDATEOFIDENDITY_NOT_VALID")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "InvalidGsm", "var InvalidGsm="
                  + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_PHONENUMBER_INVALID_EMPTY")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage1", "var NEW_SENDER_KPSZORUNLU="
                           + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_KPSZORUNLU")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage2", "var NEW_SENDER_KPS_HATALI="
                                      + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_KPS_HATALI")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage3", "var NEW_SENDER_IDENDITYNO_MUST_BE_NUMBER="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_IDENDITYNO_MUST_BE_NUMBER")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage4", "var NEW_SENDER_IDENDITYNO_MUST_BE_ELEVEN_CHAR="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_IDENDITYNO_MUST_BE_ELEVEN_CHAR")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage5", "var CRM_NEW_SENDER_SINGULARITY_CONFIRM="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_SINGULARITY_CONFIRM")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage6", "var CRM_NEW_SENDER_MULTIPLESINGULARITY_CONFIRM="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_MULTIPLESINGULARITY_CONFIRM")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "LabelText2", "var CRM_NEW_SENDER_FOREIGNIDENTIFICATIONID_LABEL="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_FOREIGNIDENTIFICATIONID_LABEL")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "NationTurkeyParam", "var TurkeyID="
               + JsonConvert.SerializeObject(SenderNationalityID.Turkey) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "LabelText1", "var CRM_NEW_SENDER_IDENTIFICATION_NUMBER="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_NEW_SENDERIDENDIFICATIONNUMBER1_UYRUK 1 KIMLIK NO")) + ";", true);
            QScript("UpdateIsDomesticValue();");
            QScript("UpdateChannelAndCorp();");

            var isKpsNecessary = QueryHelper.GetString("automaticKps");
            if (isKpsNecessary == "1")
            {
                CreditCheckFactory ccf = new CreditCheckFactory();
                string senderIdentificationNum = ccf.GetTempCreditTcknInfo(ValidationHelper.GetGuid(QueryHelper.GetString("dataId")));
                if (!String.IsNullOrEmpty(senderIdentificationNum))
                {
                    new_NationalityID.SetValue(SenderNationalityID.Turkey);
                    new_SenderIdendificationNumber1.SetValue(senderIdentificationNum);
                    new_NationalityID.SetDisabled(true);
                    new_SenderIdendificationNumber1.SetDisabled(true);
                    QScript("SetKpsData();");
                }
            }
        }
    }
    public void LoadMessages()
    {
        pnl_General.Title = CrmLabel.TranslateMessage("CRM.NEW_SENDER_GENERALINFORMATION");
        btnSave.Text = CrmLabel.TranslateMessage("DASH_SAVE");
        KpsButton.Text = CrmLabel.TranslateMessage("CRM.NEW_SENDER_KPS_APS");
        //PanelKimlikBilgileri.Title = CrmLabel.TranslateMessage("CRM.NEW_SENDER_IDENTITY_INFORMATION");
    }

    protected void SaveClick(object sender, EventArgs e)
    {
        Sender senderObj = new Sender 
        { name = new_Name.RealValue,
        middleName = new_MiddleName.RealValue,
        surName = new_LastName.RealValue,
        nationalityID = ValidationHelper.GetGuid(new_NationalityID.Value),
        senderIdentificationNumber1 = new_SenderIdendificationNumber1.Value,
        identificationCardTypeID = ValidationHelper.GetGuid(new_IdendificationCardTypeID.Value),
        identityNo = new_IdentityNo.RealValue,
        birthPlace = new_BirthPlace.RealValue,
        birthDate = new_BirthDate.RealValue,
        motherName = new_MotherName.RealValue,
        fatherName = new_FatherName.RealValue,
        placeOfIdentity = new_PlaceOfIdendity.RealValue,
        dateOfIdentity = new_DateOfIdendity.Value,
        validDateOfIdentity = new_ValidDateOfIdendity.Value,
        homeCountryID = ValidationHelper.GetGuid(new_HomeCountry.Value),
        homeCity = new_HomeCity.Value,
        homeZipCode = ValidationHelper.GetString(new_HomeZipCode.Value),
        GSMCountryID = ValidationHelper.GetGuid(new_GSMCountryId.Value),
        GSM = new_GSM.Value,
        homeAddress = new_HomeAdress.Value,
        senderSegmentationID = ValidationHelper.GetGuid(new_SenderSegmentationID.Value),
        eMail = new_E_Mail.Value,
        cameFromKps = new_CameFromKps.Value,
        cameFromAps = new_cameFromAps.Value,
        homeCityID = ValidationHelper.GetGuid(new_HomeCityId.Value),
        isDomestic = new_IsDomestic.Value,
        channelCreated = ValidationHelper.GetInteger(new_ChannelCreated.Value),
        channelModified = ValidationHelper.GetInteger(new_ChannelModified.Value),
        corporationCreated = new_CorporationCreated.Value,
        corporationModified = new_CorporationModified.Value,
        countryOfIdentityID = ValidationHelper.GetGuid(new_CountryOfIdendity.Value)
        };

        SenderFactory sf = new SenderFactory();
        Guid senderID = sf.SaveSender(senderObj, Page, null);
        hdnRecid.Value = ValidationHelper.GetString(senderID);
    }

    #region AjaxMethods
    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {
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
        public bool UpdateIsDomesticValue()
        {
            SenderFactory senderService = new SenderFactory();
            string countryCode = senderService.GetUserCountryCode();
            if (countryCode == CountryShortCode.Turkey)
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
    }
    #endregion
}