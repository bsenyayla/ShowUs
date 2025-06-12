using System;
using System.Data;
using System.Web.UI;
using AjaxPro;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using Newtonsoft.Json;
using RefleXFrameWork;
using TuFactory.Data;
using TuFactory.KpsAps;
using TuFactory.Object;
using TuFactory.Object.AjaxObject;
using TuFactory.Payment;
using TuFactory.Sender;
using TuFactory.Utility;
using Coretech.Crm.Data.Crm.Dynamic;
using TuFactory.Confirm;
using TuFactory.Object.Confirm;
using TuFactory.TransactionManagers.Payment;
using System.Net;
using System.Collections.Generic;
using System.Security.Cryptography.X509Certificates;
using System.Net.Security;

using UPTCache = UPT.Shared.CacheProvider.Service;
using System.Data.Common;
using System.Globalization;

public partial class Payment_PaymentMain : BasePage
{
    #region Variables
    private string _CountryCurrencyID;
    private string _CountryCurrencyIDName;
    private bool _IsPartlyCollection = false; //Bu kurumda parcalı tahsilat kullanılır.
    private DynamicSecurity DynamicSecurity;

    #endregion

    #region General Methods

    void TranslateMessage()
    {
        gpRecipients.ColumnModel.Columns[1].Header = CrmLabel.TranslateMessage("CRM.NEW_SENDER_FULLNAME"); //Müşteri Ad-Soyad
        gpRecipients.ColumnModel.Columns[2].Header = CrmLabel.TranslateMessage("CRM.NEW_SENDER_NEW_NATIONALITYID_UYRUK1"); //Uyruk
        gpRecipients.ColumnModel.Columns[3].Header = CrmLabel.TranslateMessage("CRM.NEW_SENDER_SENDERIDENTIFICATIONNUMBER1"); //Vatandaşlık No
        gpRecipients.ColumnModel.Columns[4].Header = CrmLabel.TranslateMessage("CRM.NEW_SENDER_NEW_IDENDIFICATIONCARDTYPEID_KIMLIK TIPI"); //Kimlik Tipi
        gpRecipients.ColumnModel.Columns[5].Header = CrmLabel.TranslateMessage("CRM.NEW_SENDER_NEW_IDENTITYNO_KIMLIK NO"); //Kimlik Numarası

        lCustomerSearchInfo.Text = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_CUSTOMER_SEARCH_INFO_TEXT");
        bNewCustomer.Text = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_NEW_CUSTOMER"); //Yeni Alıcı Oluştur
        bRecipientSearch.Text = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_CORPACCOUNTMONITORING_BTN_SEARCH"); //Ara
        new_IsPersonalSecurity.FieldLabel = CrmLabel.TranslateMessage("CRM.NEW_SENDER_KVKK_PERMISSION_TEXT");
        tfRecipient.FieldLabel = CrmLabel.TranslateMessage("CRM.NEW_RECIPIENT");

        btnSave.Text = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_BTNPAYMENT");
        btnKpsAps.Text = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_KPSAPSCHECK");
        RxM.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_PaymentMethod",
                                                                TuEntityEnum.New_Payment.GetHashCode());
        pnlPayment.Title = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_ODEMEBILGILERI");
        pnlAlici.Title = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_ALICIBILGILERI");
        pnlKimlik.Title = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_KIMLIK_BILGILERI");
        GetMessage();
    }

    void GetMessage()
    {
        var staticData = new StaticData();
        staticData.AddParameter("OperationType", DbType.Int32, 1);
        staticData.AddParameter("systemuserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        var msg = ValidationHelper.GetString(
                staticData.ExecuteScalar("EXEC spGetCountryTransferMessages @OperationType,@systemuserId"));
        var msgt = msg.Replace("*", "").Replace(" ", "");
        if (!string.IsNullOrEmpty(msgt))
            TuLabelMessage.Text = msg;

        QScript("window.top.R.WindowMng.getActiveWindow().setTitle(window.top.PnlCenter.title);");
    }

    void ReConfigureScreen()
    {
        var sd = new StaticData();
        sd.ClearParameters();
        if (new_PaidAmount2.Visible)
            new_PaidAmount2.Disabled = true;
        new_PaymentMethod.Disabled = true;

        if (new_PaidAmount2.Visible)
            new_PaidAmount2.c1.SetValue(_CountryCurrencyID, _CountryCurrencyIDName);
        //var amount = ValidationHelper.GetDBDecimal(((CrmDecimalComp)new_Amount.Items[0]).Value);

        if (_IsPartlyCollection)
        {
            if (string.IsNullOrEmpty(New_PaymentId.Value) || ValidationHelper.GetInteger(new_PaymentMethod.Value) == TransferCollectionMethodEnum.Single.GetHashCode())
            {
                new_PaidAmount2.c1.SetValue(_CountryCurrencyID, _CountryCurrencyIDName);
                new_PaidAmount2.SetVisible(false);
                new_PaidAmount2.d1.SetVisible(false);
            }
        }

        //sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        //sd.AddParameter("ObjectId", DbType.Int32, TuEntityEnum.New_Transfer.GetHashCode());
        //sd.AddParameter("Amount", DbType.Decimal, amount);
        //sd.AddParameter("FromCurrencyID", DbType.Guid, ValidationHelper.GetDBGuid(new_AmountCurrency2.Value));
        //var script = sd.ExecuteScalar(@"Exec spTUFormRequiredWf2 @SystemUserId,@ObjectId,@Amount,@FromCurrencyID").ToString();
        const string script = "CheckAllControls();";
        QScript(script);

    }


    void ShowCustomerDataProtection()
    {
        wPersonalSecurity.Hide();
        lIsPersonalSecurity.Hide();
        if
        (
            UPTCache.CountryService.GetCountryByCountryId(App.Params.CurrentUser.CountryId).IsPersonalSecurity &&
            UPTCache.CorporationService.GetCorporationByCorporationId(App.Params.CurrentUser.CorporationId).IsCustomerDataProtectionActive
        )
        {
            HdnIsPersonalSecuritySeen.SetValue(true);
            PersonalSecurityFieldSet.Show();
            new_IsPersonalSecurity.SetDisabled(true);
            new_IsPersonalSecurity.Show();
            new_IsPersonalSecurity.RequirementLevel = RLevel.BusinessRequired;
        }
        else
        {
            HdnIsPersonalSecuritySeen.SetValue(false);
            new_IsPersonalSecurity.RequirementLevel = RLevel.None;
            new_IsPersonalSecurity.Hide();
            PersonalSecurityFieldSet.Hide();
        }
    }

    bool CheckCalculation()
    {
        if (ValidationHelper.GetGuid(new_CountryId.Value) == Guid.Empty)
        {
            ShowRequiredFields(new_CountryId.FieldLabel);
            return false;
        }
        if (ValidationHelper.GetGuid(new_PaidByCorporation.Value) == Guid.Empty)
        {
            ShowRequiredFields(new_PaidByCorporation.FieldLabel);
            return false;
        }

        return true;
    }

    #endregion

    #region Load Methods

    protected void Page_Load(object sender, EventArgs e)
    {
        DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_Payment.GetHashCode(), null);

        if (!(DynamicSecurity.PrvCreate || DynamicSecurity.PrvRead || DynamicSecurity.PrvWrite))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Role PrvCreate,PrvDelete,PrvWrite");
        }


        var sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        var dt =
            sd.ReturnDataset(
                @"
SELECT u.new_CorporationID,c.new_CountryID,u.new_OfficeID , co.new_CurrencyID,new_CurrencyIDName,c.new_IsPartlyCollection FROM vSystemUser u
INNER JOIN vNew_Corporation c on u.new_CorporationID = c.New_CorporationId
LEFT OUTER JOIN vnew_country co ON co.New_CountryId=c.new_CountryID Where SystemUserId = @SystemUserId
")
                .Tables[0];

        if (dt.Rows.Count > 0)
        {
            //new_CountryId.Value = ValidationHelper.GetString(dt.Rows[0]["new_CountryID"]);
            new_CountryId.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_CountryID"]));

            //new_PaidByCorporation.Value = ValidationHelper.GetString(dt.Rows[0]["new_CorporationID"]);
            new_PaidByCorporation.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_CorporationID"]));

            //new_PaidByOffice.Value = ValidationHelper.GetString(dt.Rows[0]["new_OfficeID"]);
            new_PaidByOffice.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_OfficeID"]));

            _CountryCurrencyID = ValidationHelper.GetString(dt.Rows[0]["new_CurrencyID"]);
            _CountryCurrencyIDName = ValidationHelper.GetString(dt.Rows[0]["new_CurrencyIDName"]);
            _IsPartlyCollection = ValidationHelper.GetBoolean(dt.Rows[0]["new_IsPartlyCollection"]);
        }

        if (!_IsPartlyCollection)
        {
            RxM.Visible = false;
            new_PaidAmount2.Visible = false;
            l1.Visible = false;
        }

        if (!RefleX.IsAjxPostback)
        {
            ShowCustomerDataProtection();

            Utility.RegisterTypeForAjax(typeof(AjaxClientMethods));

            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage", "var NEW_RECIPIENT_VALIDDATEOFIDENDITY_NOT_VALID="
               + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_RECIPIENT_VALIDDATEOFIDENDITY_NOT_VALID")) + ";", true);

            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage1", "var NEW_RECIPIENT_KPS_ZORUNLU="
                           + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_RECIPIENT_KPS_ZORUNLU")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage2", "var NEW_RECIPIENT_KPS_HATALI="
                                      + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_RECIPIENT_KPS_HATALI")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "multiplePhoneCodeCountries", "var multiplePhoneCodeCountries="
               + GetMultiplePhoneCodeCountries() + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage3", "var MULTIPLE_PHONE_CODE_INVALID="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.ENTITY_CRM.ENTITY_MULTIPLEPHONECODE_INVALID")) + ";", true);

            //new_RecipientCountryID.Focus();
            TranslateMessage();
            //FieldsetReason.Visible = false;
            New_PaymentId.Value = QueryHelper.GetString("recid");


            LoadData();
            ReConfigureScreen();

            //new_GSMCountryId.Listeners.Change.Handler = "document.getElementById('_new_MobilePhone').value = new_GSMCountryId.selectedRecord.new_TelephoneCode;";
            new_GSMCountryId.Listeners.Change.Handler = "setCountryPhoneCode(new_GSMCountryId.selectedRecord.new_TelephoneCode, 'recipientPayment');";

            pnlAlici.SetVisible(false);
            pnlKimlik.SetVisible(false);
            PersonalSecurityFieldSet.SetVisible(false);
        }
    }

    protected void LoadData()
    {

        var df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };
        var py = df.Retrieve(TuEntityEnum.New_Payment.GetHashCode(),
                                          ValidationHelper.GetGuid(New_PaymentId.Value),
                                          DynamicFactory.RetrieveAllColumns);

        new_SenderId.FillDynamicEntityData(py);
        new_TransferAmount.FillDynamicEntityData(py);
        new_ExpenseAmount.FillDynamicEntityData(py);
        new_TotalPayableAmount.FillDynamicEntityData(py);
        new_PaymentMethod.FillDynamicEntityData(py);
        new_PaidAmount1.FillDynamicEntityData(py);
        new_PaidAmount2.FillDynamicEntityData(py);
        new_SenderCountryId.FillDynamicEntityData(py);
        //new_ExpenseAmount.FillDynamicEntityData(py);
        new_TransferID.FillDynamicEntityData(py);
        new_ReceipentFullname.FillDynamicEntityData(py);
        new_NationalityID.FillDynamicEntityData(py);
        new_RecipientIdentificationCardNumber.FillDynamicEntityData(py);
        new_RecipientName.FillDynamicEntityData(py);
        new_RecipientMiddleName.FillDynamicEntityData(py);
        new_RecipientLastName.FillDynamicEntityData(py);
        new_FatherName.FillDynamicEntityData(py);
        new_BirthPlace.FillDynamicEntityData(py);
        new_Birthdate.FillDynamicEntityData(py);
        new_GSMCountryId.FillDynamicEntityData(py);
        new_MobilePhone.FillDynamicEntityData(py);
        new_MotherName.FillDynamicEntityData(py);
        new_Address.FillDynamicEntityData(py);
        new_IdentificatonCardTypeId.FillDynamicEntityData(py);
        new_CameFromKps.FillDynamicEntityData(py);
        new_cameFromAps.FillDynamicEntityData(py);
        new_IdentificatonCardTypeNo.FillDynamicEntityData(py);
        new_IdentityWasSeen.FillDynamicEntityData(py);
        new_ValidDateOfIdendity.FillDynamicEntityData(py);
        new_DateOfIdentity.FillDynamicEntityData(py);
        new_CorporationOfIdentity.FillDynamicEntityData(py);
        if (ValidationHelper.GetInteger(new_PaymentMethod.Value) == TransferCollectionMethodEnum.Single.GetHashCode())
        {
            new_PaidAmount1.d1.SetDisabled(true);
        }
        else
        {
            new_PaidAmount1.d1.SetDisabled(false);
        }

        List<Guid> paymentCurrencies = GetPaymentCurrencies();
        if (!paymentCurrencies.Exists(c => c == ValidationHelper.GetGuid(new_PaidAmount1.c1.Value)))
        {
            new_PaidAmount1.c1.Clear();
            new_PaidAmount1.d1.Clear();
            new_PaidAmount1.d1.Value = 0;

            if (_IsPartlyCollection)
            {
                new_PaidAmount2.c1.Clear();
                new_PaidAmount2.d1.Clear();
                new_PaidAmount2.d1.Value = 0;
            }
        }

        Parity1.Clear();
        if (new_PaidAmount1.d1.Value > 0)
        {
            Parity1.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaidParity1", TuEntityEnum.New_Payment.GetHashCode()) + ":&nbsp;&nbsp;" +
                        Math.Round(((CrmDecimal)py["new_TransferPaidParity1"]).Value, 6).ToString());
        }
        if (_IsPartlyCollection)
        {
            Parity2.Clear();
            if (new_PaidAmount2.d1.Value > 0)
            {
                Parity2.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaidParity2", TuEntityEnum.New_Payment.GetHashCode()) + ":&nbsp;&nbsp;" +
                                Math.Round(((CrmDecimal)py["new_TransferPaidParity2"]).Value, 6).ToString());
            }
        }

        PaymentFactory pf = new PaymentFactory();
        //Alıcı isim decryption
        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        new_RecipientName.SetValue(cryptor.DecryptInString(new_RecipientName.Value));
        new_RecipientMiddleName.SetValue(cryptor.DecryptInString(new_RecipientMiddleName.Value));
        new_RecipientLastName.SetValue(cryptor.DecryptInString(new_RecipientLastName.Value));


        // try catch bloğu TYUPT-2463 kodlu jira maddesine istinaden eklenilmiştir
        // blok içerisindeki alanların null object referance hatası vermesi üzerine talepte belirtilen hata ekrana basılıp aktif sayfa sonlandırıldı.
        try
        {
            if (pf.IsBeneficiaryNameMaskKvvkCheck(ValidationHelper.GetGuid(new_TransferID.Value)))
            {
                //hdnRecipientFullName.SetIValue(cryptor.DecryptInString(new_ReceipentFullname.Value));
                new_ReceipentFullname.SetIValue(pf.BeneficiaryNameMask(cryptor.DecryptInString(new_ReceipentFullname.Value.Trim())));
                new_ReceipentFullname.SetValue(pf.BeneficiaryNameMask(cryptor.DecryptInString(new_ReceipentFullname.Value.Trim())));
                new_ReceipentFullname.Value = pf.BeneficiaryNameMask(cryptor.DecryptInString(new_ReceipentFullname.Value.Trim()));
                new_ReceipentFullname.Text = pf.BeneficiaryNameMask(cryptor.DecryptInString(new_ReceipentFullname.Value.Trim()));
            }
            else
            {
                new_ReceipentFullname.SetIValue(cryptor.DecryptInString(new_ReceipentFullname.Value));
                new_ReceipentFullname.Text = cryptor.DecryptInString(new_ReceipentFullname.Value);
            }
        }
        catch (Exception ex)
        {
            // var fields = "new_CalculatedExpenseAmount.clear();new_CalculatedExpenseAmountCurrency.clear();new_ReceivedPaymentAmount.clear();new_ReceivedPaymentAmountCurrency.clear();new_ReceivedAmount1.clear();new_ReceivedAmount1Currency.clear();new_ReceivedAmount2.clear();new_ReceivedAmount2Currency.clear();new_Amount.focus();";
            // var errorMessage = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_COULDNT_GET_THE_EXCHANGE_RATE");
            QScript("alert('İşlem ödemenin denendiği ilk hizmet noktadan alınabilir ya da lütfen UPT Saha Destek Birimi (sahadestekbirimi@upt.com.tr) adresi üzerinden iletişime geçiniz.');");
            this.ActiveWindowClose();
            return;
        }


        hdnRecipientName.SetValue(cryptor.DecryptInString(new_RecipientName.Value));
        hdnRecipientLastName.SetValue(cryptor.DecryptInString(new_RecipientLastName.Value));
        hdnRecipientIdentificationCardNumber.SetValue(new_RecipientIdentificationCardNumber.Value);
        hdnMobilePhone.SetValue(new_MobilePhone.Value);

        var userCountry = UPT.Shared.CacheProvider.Service.CountryService.GetCountryByCountryId(App.Params.CurrentUser.CountryId);
        if (userCountry != null && userCountry.IsoCode3 != "" && userCountry.IsoCode3 != "TUR")
        {
            new_ProfessionID.Clear();
            new_ProfessionID.SetVisible(false);
            //new_ProfessionID.Visible = true;
            new_ProfessionID.RequirementLevel = RLevel.None;
        }
        else
        {
            new_ProfessionID.Clear();
            new_ProfessionID.SetVisible(true);
            //new_ProfessionID.Visible = false;
            new_ProfessionID.RequirementLevel = RLevel.BusinessRequired;
        }

        var nationality = UPTCache.NationalityService.GetNationalityByNationalityId(ValidationHelper.GetGuid(new_NationalityID.Value));

        if (nationality != null && nationality.ExtCode == "KZ")
        {
            new_CorporationOfIdentity.SetRequirementLevel(RLevel.BusinessRequired);
            new_DateOfIdentity.SetRequirementLevel(RLevel.BusinessRequired);
            new_ValidDateOfIdendity.SetVisible(true);
        }
        else
        {
            new_CorporationOfIdentity.SetRequirementLevel(RLevel.None);
            new_DateOfIdentity.SetRequirementLevel(RLevel.None);
            new_CorporationOfIdentity.SetVisible(false);
            new_CorporationOfIdentity.Clear();
        }
    }

    List<Guid> GetPaymentCurrencies()
    {
        List<Guid> list = new List<Guid>();

        const string sql = @"
		    SELECT 
	            DISTINCT new_CurrencyId AS CurrencyId
            FROM vNew_OfficeTransactionType ott (NOLOCK)
            INNER JOIN vNew_TransactionType tt (NOLOCK)
            ON ott.new_TransactionTypeID = tt.New_TransactionTypeId AND tt.DeletionStateCode = 0
            WHERE 
            ott.DeletionStateCode = 0 
            AND tt.new_ExtCode = '008'
            AND new_OfficeID = @OfficeId
            ORDER BY 1";
        var staticData = new StaticData();
        staticData.AddParameter("OfficeId", DbType.Guid, App.Params.CurrentUser.Office.OfficeId);
        var ds = staticData.ReturnDataset(sql);

        for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
        {
            list.Add(ValidationHelper.GetGuid(ds.Tables[0].Rows[i]["CurrencyId"]));
        }

        return list;
    }

    #endregion

    #region Control Event Methods
    protected void new_PaymentMethodOnChange(object sender, AjaxEventArgs e)
    {
        if (ValidationHelper.GetInteger(new_PaymentMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        {

            if (new_PaidAmount2.Visible)
            {
                new_PaidAmount2.SetVisible(true);
                new_PaidAmount2.d1.SetVisible(true);
            }

            new_PaidAmount1.d1.SetDisabled(false);
            new_PaidAmount1.d1.Clear();
            new_PaidAmount1.d1.Value = 0;
            if (new_PaidAmount2.Visible)
            {
                new_PaidAmount2.d1.Clear();
                new_PaidAmount2.d1.Value = 0;
            }
        }
        else
        {
            if (new_PaidAmount2.Visible)
            {
                new_PaidAmount2.SetVisible(false);
                new_PaidAmount2.d1.SetVisible(false);
                new_PaidAmount2.d1.Clear();
            }
            new_PaidAmount1.d1.SetDisabled(true);
            new_PaidAmount1.d1.Clear();
        }
        CalculateOnEvent(sender, e);

    }
    protected void new_PaidAmount1CurrencyOnChange(object sender, AjaxEventArgs e)
    {
        if (_IsPartlyCollection)
        {
            if (((CrmComboComp)new_PaidAmount1.c1).Value == _CountryCurrencyID)
            {
                new_PaymentMethod.Value = TransferCollectionMethodEnum.Single.GetHashCode().ToString();
                new_PaymentMethod.SetValue(TransferCollectionMethodEnum.Single.GetHashCode().ToString());
            }
            else
            {

                new_PaymentMethod.SetValue(TransferCollectionMethodEnum.Multiple.GetHashCode().ToString());
                new_PaymentMethod.Value = TransferCollectionMethodEnum.Multiple.GetHashCode().ToString();
            }
            new_CollectionMethodOnChange(sender, e);
        }
        else
        {
            CalculateOnEvent(sender, e);
        }







        //if (ValidationHelper.GetInteger(new_PaymentMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        //{
        //    new_PaymentMethodOnChange(sender, e);
        //}
        //else
        //{
        //    CalculateOnEvent(sender, e);
        //}
    }
    protected void new_CollectionMethodOnChange(object sender, AjaxEventArgs e)
    {
        ReconfigureByCollectionMethod();
        if (ValidationHelper.GetInteger(new_PaymentMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        {
            new_PaidAmount1.d1.Clear();
            new_PaidAmount1.d1.Value = 0;
            if (new_PaidAmount2.Visible)
            {
                new_PaidAmount2.d1.Clear();
                new_PaidAmount2.d1.Value = 0;
            }
        }
        else
        {
            new_PaidAmount1.d1.Clear();
            if (new_PaidAmount2.Visible)
                new_PaidAmount2.d1.Clear();
        }

        CalculateOnEvent(sender, e);

    }
    protected void new_NationalityIDOnChange(object sender, AjaxEventArgs e)
    {

        var nationality = UPTCache.NationalityService.GetNationalityByNationalityId(ValidationHelper.GetGuid(new_NationalityID.Value));

        if (nationality != null && nationality.ExtCode == "KZ")
        {
            new_CorporationOfIdentity.SetVisible(true);
            new_CorporationOfIdentity.SetRequirementLevel(RLevel.BusinessRequired);
            new_DateOfIdentity.SetRequirementLevel(RLevel.BusinessRequired);
            new_ValidDateOfIdendity.SetVisible(true);
        }
        else
        {
            new_CorporationOfIdentity.SetRequirementLevel(RLevel.None);
            new_DateOfIdentity.SetRequirementLevel(RLevel.None);
            new_CorporationOfIdentity.SetVisible(false);
            new_CorporationOfIdentity.Clear();
        }
    }

    public void ReconfigureByCollectionMethod()
    {
        if (ValidationHelper.GetInteger(new_PaymentMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        {
            if (new_PaidAmount2.Visible)
                new_PaidAmount2.SetVisible(true);
            new_PaidAmount1.d1.SetDisabled(false);
        }
        else
        {
            if (new_PaidAmount2.Visible)
                new_PaidAmount2.SetVisible(false);
            new_PaidAmount1.d1.SetDisabled(true);
        }
    }
    #endregion

    #region Protected Events

    protected void btnKpsApsOnEvent(object sender, AjaxEventArgs e)
    {

    }

    protected void SaveOnClick(object sender, AjaxEventArgs e)
    {
        var paymentFactory = new PaymentFactory();

        if (!ValidationHelper.GetBoolean(new_CameFromKps.Value) && ValidationHelper.GetGuid(new_NationalityID.Value) == ValidationHelper.GetGuid("FC942C41-55FF-49AD-83AA-2F165AEE2E04"))
        {

            var m = new MessageBox { Width = 400, Height = 300 };
            string requiredmsg = "Lütfen Kps yapınız.!";
            m.Show(requiredmsg);
            return;

        }


        if (ValidationHelper.GetBoolean(HdnIsPersonalSecuritySeen.Value))
        {
            if (!ValidationHelper.GetBoolean(new_IsPersonalSecurity.Value))
            {
                var m = new MessageBox { Width = 400, Height = 300 };
                string requiredmsg = "Kişisel Verilerin Korunması Kanunu Aydınlatma ve Açık Rıza Metni ve Muvafakatnamesi alanı zorunlu bir alandır. Lütfen ekranda yer alan ilgili butonu tıklayarak formun çıktısını alınız ve müşteriye imzalatınız.";
                m.Show(requiredmsg);
                return;
            }
        }

        if (new_MobilePhone.Value.Length < 13)
        {
            var msg = CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED");
            var m = new MessageBox { Width = 400, Height = 180 };
            string requiredmsg = string.Format(msg, new_MobilePhone.FieldLabel);
            m.Show(msg, requiredmsg);
            return;
        }


        var staticData = new StaticData();
        staticData.ClearParameters();

        staticData.AddParameter("@SystemUserId", DbType.Guid, ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId));
        staticData.AddParameter("@Address", DbType.String, new_Address.Value);
        staticData.AddParameter("@CameFromAps", DbType.Boolean, ValidationHelper.GetBoolean(new_cameFromAps.Value));

        bool addressCheck = ValidationHelper.GetBoolean(staticData.ExecuteScalarSp("spTuCheckAddressLength"), false);


        if (!addressCheck)
        {
            var msg = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_ADDRES_MUST_BE_AT_LEAST_20_CHARACTERS");
            var m = new MessageBox { Width = 400, Height = 180 };
            string requiredmsg = string.Format(msg, new_Address.FieldLabel);
            m.Show(msg, requiredmsg);
            return;
        }

        PaymentDb pdb = new PaymentDb();
        DataTable dt = pdb.GetTransferByPaymentId(ValidationHelper.GetGuid(New_PaymentId.Value), null);
        string paymentNumber = ValidationHelper.GetString(dt.Rows[0]["new_TransferIDName"]);
        var transferId = ValidationHelper.GetGuid(dt.Rows[0]["new_TransferID"]);
        var isFromIntegrationPool = ValidationHelper.GetBoolean(dt.Rows[0]["new_new_IsFromIntegrationPool"], false);

        if (paymentFactory.IsBeneficiaryNameMaskKvvkCheck(transferId))
        {
            var beneficiaryFullName = paymentFactory.MergeFullName(new_RecipientName.Value,
                new_RecipientMiddleName.Value, new_RecipientLastName.Value);

            string recipientFullNameDb = pdb.GetRecipientFullName(ValidationHelper.GetGuid(New_PaymentId.Value));

            /*TYUPT-1456*/
            var advancedCompare = (App.Params.GetConfigKeyValue("ENABLE_ADVANCED_NAME_COMPARE", "false").Trim().ToLower() == "true") ? true : false;
            if (advancedCompare)
            {
                var names = recipientFullNameDb.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                if (names.Length > 1)
                {
                    //Soyadı alanı zorunlu ve isim içinde olması gerekmekte...
                    var lastName = names[names.Length - 1];
                    if (!paymentFactory.AdvancedNameCompare(lastName, beneficiaryFullName, 99M, true))
                    {
                        QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_RECIPIENT_NAME_DOES_NOT_MATCH") + "');return false;");
                        return;
                    }
                    //Soyadı tamam ise tam listeyi arıyor...
                    if (!paymentFactory.AdvancedNameCompare(recipientFullNameDb, beneficiaryFullName))
                    {
                        QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_RECIPIENT_NAME_DOES_NOT_MATCH") + "');return false;");
                        return;
                    }
                }
                else
                {
                    QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_RECIPIENT_NAME_DOES_NOT_MATCH") + "');return false;");
                    return;
                }
            }
            else
            {
                if (!paymentFactory.BeneficiaryNameCompare(paymentFactory.ReplaceSpecialCharacter(recipientFullNameDb), paymentFactory.ReplaceSpecialCharacter(beneficiaryFullName)))
                {
                    QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_RECIPIENT_NAME_DOES_NOT_MATCH") + "');return false;");
                    return;
                }
            }
        }


        ConfirmFactory cf = new ConfirmFactory();
        var pstatus = cf.GetTransactionStatus(TuEntityEnum.New_Payment.GetHashCode(), ValidationHelper.GetGuid(New_PaymentId.Value));
        if (pstatus == TuConfirmStatus.OdemeUPTMerkeziOnayinda) //Odeme AML onayında ise islemi ilerletme.
        {
            var message = BasePage.SerializeString(CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_SCENARIO_DID_NOT_PASS_THE_CHECK"));
            message = string.Format(message, paymentNumber);

            QScript("LogCurrentPage();");
            QScript("alert(" + BasePage.SerializeString(message) + "); ");
            QScript("RefreshParetnGridForCashTransaction(true);");
            return;
        }

        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        var pamount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_PaidAmount1.d1).Value, 0);
        var pamountCurrency = ValidationHelper.GetGuid(((CrmComboComp)new_PaidAmount1.c1).Value);
        if (!CheckCalculation())
            return;




        var serialNumber = DynamicDb.GetSequenceId("DKT", null);
        if (string.IsNullOrEmpty(serialNumber))
        {
            var m = new MessageBox { Width = 400, Height = 180 };
            m.Show("Unable to create the serial number");
            return;
        }
        bool checkPaymentFraud = false;
        try
        {
            if (hdnRecipientName.Value != new_RecipientName.Value || hdnRecipientLastName.Value != new_RecipientLastName.Value || hdnMobilePhone.Value != new_MobilePhone.Value)
            {
                checkPaymentFraud = true;
            }

        }
        catch (Exception ex)
        {
            var message = ex.Message;
            var msg = new MessageBox { Width = 500, Height = 250 };
            msg.Show(message);
            return;
        }

        PaymentManager pManager = new PaymentManager();

        var payment = pManager.GetPayment(ValidationHelper.GetGuid(New_PaymentId.Value));

        payment.PaidAmount1 = new TuFactory.Domain.ConvertedMoney()
        {
            Amount = ValidationHelper.GetDecimal(new_PaidAmount1.d1.Value, 0),
            Currency = new TuFactory.Domain.Currency()
            {
                CurrencyId = ValidationHelper.GetGuid(new_PaidAmount1.c1.Value)
            }
        };

        if (ValidationHelper.GetDecimal(new_PaidAmount2.d1.Value, 0) > 0)
        {
            payment.PaidAmount2 = new TuFactory.Domain.ConvertedMoney()
            {
                Amount = ValidationHelper.GetDecimal(new_PaidAmount2.d1.Value, 0),
                Currency = new TuFactory.Domain.Currency()
                {
                    CurrencyId = ValidationHelper.GetGuid(new_PaidAmount2.c1.Value)
                }
            };
        }
        payment.Nationality = new TuFactory.Domain.Nationality() { NationalityId = ValidationHelper.GetGuid(new_NationalityID.Value) };
        payment.GsmCountry = new TuFactory.Domain.Country() { CountryId = ValidationHelper.GetGuid(new_GSMCountryId.Value) };
        payment.IdentificatonCardType = new TuFactory.Domain.IdentificationCardType() { IdentificationCardTypeId = ValidationHelper.GetGuid(new_IdentificatonCardTypeId.Value) };
        payment.PaymentId = ValidationHelper.GetGuid(New_PaymentId.Value);
        payment.BirthPlace = ValidationHelper.GetString(new_BirthPlace.Value);
        payment.Address = new_Address.Value;
        payment.RecipientIdentificationCardNumber = new_RecipientIdentificationCardNumber.Value;
        payment.RecipientName = cryptor.EncryptInString(new_RecipientName.Value);
        payment.RecipientMiddleName = cryptor.EncryptInString(new_RecipientMiddleName.Value);
        payment.FatherName = new_FatherName.Value;
        payment.RecipientLastName = cryptor.EncryptInString(new_RecipientLastName.Value);
        payment.IdentificatonCardTypeNo = new_IdentificatonCardTypeNo.Value;
        payment.Birthdate = ValidationHelper.GetDate(new_Birthdate.Value);
        payment.ValidDateOfIdendity = ValidationHelper.GetDate(new_ValidDateOfIdendity.Value);
        payment.DateOfIdentity = ValidationHelper.GetDate(new_DateOfIdentity.Value);
        payment.CorporationOfIdentity = ValidationHelper.GetInteger(new_CorporationOfIdentity.Value);
        payment.MobilePhone = ValidationHelper.GetString(new_MobilePhone.Value);
        payment.IdentityWasSeen = true;
        payment.cameFromAps = ValidationHelper.GetBoolean(new_cameFromAps.Value);
        payment.CameFromKps = ValidationHelper.GetBoolean(new_CameFromKps.Value);
        payment.SerialNumber = ValidationHelper.GetString(serialNumber);
        payment.PaymentMethod = ValidationHelper.GetInteger(new_PaymentMethod.Value, 1);
        payment.Channel = TuChannelTypeEnum.Ekran.GetHashCode();
        payment.RecipientChanged = checkPaymentFraud;
        payment.IsFromIntegrationPool = isFromIntegrationPool;
        payment.checkPaymentFraud = checkPaymentFraud;
        payment.IsPersonalSecurity = ValidationHelper.GetBoolean(new_IsPersonalSecurity.Value);
        payment.Profession = ValidationHelper.GetGuid(new_ProfessionID.Value);

        if (!hfRecipient.IsEmpty)
        {
            payment.CustomerId = ValidationHelper.GetGuid(hfRecipient.Value);
        }

        var response = pManager.UpdatePayment(payment);

        if (response.ResponseCode == PaymentRequestResponseCodes.TransactionCompleted)
        {
            const string formId = "3529707d-3d29-464f-bbaf-7a20ce8c1d9a";//payment page in 2nc sayfası
            var url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx");
            var tdb = new TransferDb();

            var result = tdb.PaymentValidate(ValidationHelper.GetGuid(New_PaymentId.Value), false, null);
            if (!string.IsNullOrEmpty(result.Message))
            {
                var err = new TuException { ErrorMessage = result.Message, ErrorCode = result.ErrorCode };
                err.Show();
            }
            else
            {
                string RecipientFullName = ValidationHelper.GetString(new_RecipientName.Value) + " " + (string.IsNullOrEmpty(ValidationHelper.GetString(new_RecipientMiddleName.Value)) ? string.Empty :
                        ValidationHelper.GetString(new_RecipientMiddleName.Value) + " ") + ValidationHelper.GetString(new_RecipientLastName.Value);
                ReportParamWriter.WriteReportRecipientPaymentParameter(ValidationHelper.GetGuid(New_PaymentId.Value), RecipientFullName, null);

                Page.Response.Redirect(string.Format("{0}?defaulteditpageid={1}&ObjectId={2}&mode=1&recid={3}&PoolId=7", url, formId, TuEntityEnum.New_Payment.GetHashCode(), New_PaymentId.Value));
            }
        }
        else
        {
            var err = new TuException { ErrorMessage = response.ResponseMessage, ErrorCode = "UpdatePayment" };
            err.Show();
        }
    }

    protected void new_CountryIdentificationTypeLoad(object sender, AjaxEventArgs e)
    {
        if (ValidationHelper.GetGuid(new_NationalityID.Value, Guid.Empty) == Guid.Empty)
        {
            var m = new MessageBox { Width = 400, Height = 180 };
            var msg2 = CrmLabel.TranslateMessage("Uyruk Seçimi Yapılmamış.");
            m.Show(msg2);
            return;
        }

        string strSql = @"Declare @Data table(new_IdentificationCardType UniqueIdentifier, new_IdentificationCardTypeName nvarchar(100))
            Declare @ExtCode nvarchar(50)
            Declare @Domesic bit
            Declare @Foreigner bit
            Select @ExtCode = new_ExtCode from vNew_nationality(nolock) where New_nationalityId = @NationalityID and DeletionStateCode = 0
            if @ExtCode = 'TR'
            BEGIN
	            Set @Domesic = 1
	            Set @Foreigner = 0
            END
            ELSE
            BEGIN
	            Set @Domesic = 0
	            Set @Foreigner = 1
            END

            Declare @CountryId uniqueidentifier
			Declare @CorporationId uniqueidentifier
            Select @CountryId = cor.new_CountryID, @CorporationId = su.new_CorporationID from vSystemUser(nolock) su inner join vNew_Corporation(nolock) cor
            on su.new_CorporationId = cor.New_CorporationId
            Where su.SystemUserId = @SystemUserId and su.DeletionStateCode = 0 and cor.DeletionStateCode = 0

            If (@Domesic = 1)
            BEGIN
	            IF EXISTS(Select * from vNew_CountryIdentificatonCardType(nolock) cict inner join
	            vNew_CountryIDCTAuth(nolock) cicta
	            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
	            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsDomestic,0) = @Domesic and cicta.new_CorporationId = @CorporationId)
	            BEGIN
		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict inner join
		            vNew_CountryIDCTAuth(nolock) cicta
		            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsDomestic,0) = @Domesic and cicta.new_CorporationId = @CorporationId				
	            END

		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict 
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cict.DeletionStateCode = 0 and ISNULL(cict.new_IsDomestic,0) = @Domesic
					and cict.New_CountryIdentificatonCardTypeId Not in 
						(
							Select cict.New_CountryIdentificatonCardTypeId from vNew_CountryIdentificatonCardType(nolock) cict inner join
							vNew_CountryIDCTAuth(nolock) cicta
							on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
							where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsDomestic,0) = 0 and cicta.new_CorporationId = @CorporationId	
						)
	         
            END

            If (@Foreigner = 1)
            BEGIN
	            IF EXISTS(Select * from vNew_CountryIdentificatonCardType(nolock) cict inner join
	            vNew_CountryIDCTAuth(nolock) cicta
	            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
	            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsForeigner,0) = @Foreigner and cicta.new_CorporationId = @CorporationId)
	            BEGIN
		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict inner join
		            vNew_CountryIDCTAuth(nolock) cicta
		            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsForeigner,0) = @Foreigner and cicta.new_CorporationId = @CorporationId
	            END

		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict 
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cict.DeletionStateCode = 0 and ISNULL(cict.new_IsForeigner,0) = @Foreigner
					and cict.New_CountryIdentificatonCardTypeId not in
						(
							Select cict.New_CountryIdentificatonCardTypeId from vNew_CountryIdentificatonCardType(nolock) cict inner join
							vNew_CountryIDCTAuth(nolock) cicta
							on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
							where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsForeigner,0) = 0 and cicta.new_CorporationId = @CorporationId
						)

            END

		  Select distinct cict.New_IdentificatonCardTypeId AS ID, l.Value AS VALUE, l.Value AS new_IdentificationCardTypeName from vNew_IdentificatonCardType(nolock) cict 
		  INNER JOIN @Data d On cict.New_IdentificatonCardTypeId = d.new_IdentificationCardType
		  LEFT JOIN New_IdentificatonCardTypeLabel(nolock) l On cict.New_IdentificatonCardTypeId = l.New_IdentificatonCardTypeId
		  Where cict.DeletionStateCode = 0 And l.LangId = (SELECT vsu.LanguageId FROM dbo.vSystemUser(nolock) vsu   WHERE  vsu.SystemUserId	= @SystemUserId AND vsu.DeletionStateCode = 0)";

        StaticData sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId));
        sd.AddParameter("NationalityID", DbType.Guid, ValidationHelper.GetGuid(new_NationalityID.Value, Guid.Empty));

        var like = new_IdentificatonCardTypeId.Query();

        if (!string.IsNullOrEmpty(like))
        {

            strSql += " AND l.Value LIKE  @new_IdentificationCardTypeName + '%' ";
            sd.AddParameter("new_IdentificationCardTypeName", DbType.String, like);
        }
        try
        {
            BindCombo(new_IdentificatonCardTypeId, sd, strSql);
        }
        catch (Exception ex)
        {
            var m = new MessageBox { Width = 400, Height = 180 };
            var msg2 = CrmLabel.TranslateMessage(ex.Message);
            m.Show(msg2);
            return;
        }
    }

    private void BindCombo(CrmComboComp combo, StaticData sd, string strSql)
    {
        var start = combo.Start() - 1;
        var limit = combo.Limit();

        if (start < 0)
        {
            start = 0;
        }

        BindCombo(combo, sd, strSql, start, limit);
    }

    private void BindCombo(CrmComboComp combo, StaticData sd, string strSql, int start, int limit)
    {
        var t = sd.ReturnDataset(strSql).Tables[0];

        //var start = combo.Start() - 1;
        //var limit = combo.Limit();

        DataTable t2 = t.Clone();

        var end = start + limit > t.Rows.Count ? t.Rows.Count : start + limit;

        for (int i = start; i < end; i++)
        {
            DataRow dr = t2.NewRow();
            dr.ItemArray = t.Rows[i].ItemArray;
            t2.Rows.Add(dr);
        }

        combo.TotalCount = t.Rows.Count;
        combo.DataSource = t2;
        combo.DataBind();
    }

    protected void CalculateOnEvent(object sender, AjaxEventArgs e)
    {
        var sd = new StaticData();

        try
        {
            var pamount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_PaidAmount1.d1).Value, 0);
            var pamountCurrency = ValidationHelper.GetGuid(((CrmComboComp)new_PaidAmount1.c1).Value);
            if (!CheckCalculation())
                return;
            var changedObject = string.Empty;
            if (sender.GetType() == typeof(CrmDecimalComp))
                changedObject = ((CrmDecimalComp)(sender)).UniqueName;
            if (sender.GetType() == typeof(CrmComboComp))
                changedObject = ((CrmComboComp)(sender)).UniqueName;
            if (sender.GetType() == typeof(CrmPicklistComp))
                changedObject = ((CrmPicklistComp)(sender)).UniqueName;

            var tpc = new PaymentFactory();
            var ret = tpc.Calculate(
                ValidationHelper.GetGuid(New_PaymentId.Value),
                changedObject,
                pamount,
                pamountCurrency,
                ValidationHelper.GetInteger(new_PaymentMethod.Value, 1),
                false);


            if (ret.PaidAmount1 > 0)
            {
                if (!string.IsNullOrEmpty(ret.Message))
                {
                    var message = ret.Message;
                    //new_ExpenseAmount.Items[0].SetValue(ValidationHelper.GetDecimal(result.Rows[0]["CalculatedExpenseAmount"], 0));
                    //new_ReceivedAmount1.d1.SetValue(ValidationHelper.GetDecimal(result.Rows[0]["new_ReceivedAmount1"], 0));
                    //new_ReceivedAmount1.c1.SetValue(ValidationHelper.GetString(result.Rows[0]["new_ReceivedAmount1Text"]));
                    var msg = new MessageBox { Width = 500 };
                    msg.Show(message);
                }
                Parity1.Clear();
                if (new_PaidAmount2.Visible)
                    Parity2.Clear();

                new_PaidAmount1.d1.SetValue(ret.PaidAmount1);
                new_PaidAmount1.c1.SetValue(ret.PaidAmount1Currency.ToString());
                Parity1.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaidParity1", TuEntityEnum.New_Payment.GetHashCode()) + ":&nbsp;&nbsp;" +
                    Math.Round(ValidationHelper.GetDecimal(ret.TransferPaidParity1, 0), 6).ToString());

                if (new_PaidAmount2.Visible)
                {
                    new_PaidAmount2.d1.SetValue(ret.PaidAmount2);
                    new_PaidAmount2.c1.SetValue(ret.PaidAmount2Currency.ToString());
                }
                if (new_PaidAmount2.Visible)
                    if (ret.PaidAmount2 > 0)
                        Parity2.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaidParity2", TuEntityEnum.New_Payment.GetHashCode()) + ":&nbsp;&nbsp;" +
                            Math.Round(ValidationHelper.GetDecimal(ret.TransferPaidParity2, 0), 6).ToString());

                if (ret.KambiyoAmount > 0)
                {
                    new_KambiyoAmount.Hidden = false;
                    new_KambiyoAmount.Show();
                    new_KambiyoAmount.Items[0].SetIValue(ret.KambiyoAmount);
                    new_KambiyoAmount.Items[1].SetIValue(ret.KambiyoAmountCurrency);
                }
                else
                {
                    new_KambiyoAmount.Hidden = true;
                    new_KambiyoAmount.Hide();
                }

            }
            ReConfigureScreen();

        }
        catch (Exception ex)
        {
            e.Message = ex.Message;
            e.Success = false;
        }
    }

    #endregion

    #region Customer

    protected void SearchCustomer(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(tfRecipient.Value.Trim()))
        {
            StaticData sd = new StaticData();
            sd.AddParameter("SearchKey", DbType.String, tfRecipient.Value.Trim().ToUpper().TurkishToLatin());
            sd.AddParameter("LanguageId", DbType.Int32, App.Params.CurrentUser.LanguageId);
            DataTable dt = sd.ReturnDatasetSp("spGetCustomers").Tables[0];
            if (dt.Rows.Count == 0)
            {
                HideCustomerPanels();
                hfRecipient.Clear();

                MessageBox msgBox = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
                msgBox.Show(CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_RECORDNOTFOUND"));
            }
            else if (dt.Rows.Count == 1)
            {
                hfRecipient.Value = dt.Rows[0]["CustomerId"].ToString();
                hfRecipient.SetValue(dt.Rows[0]["CustomerId"]);
                SetCustomer();
            }
            else
            {
                HideCustomerPanels();
                hfRecipient.Clear();

                gpRecipients.DataSource = dt;
                gpRecipients.DataBind();
                wRecipient.Show();
            }
        }
    }

    protected void SetCustomer()
    {
        if (!hfRecipient.IsEmpty)
        {
            ClearCustomerControls();

            var df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };
            var py = df.Retrieve(TuEntityEnum.New_Sender.GetHashCode(),
                                              ValidationHelper.GetGuid(hfRecipient.Value),
                                              DynamicFactory.RetrieveAllColumns);

            var customer = new SenderFactory().GetSender(ValidationHelper.GetGuid(hfRecipient.Value));

            new_NationalityID.SetValue(customer.NationalityID);
            new_RecipientIdentificationCardNumber.SetValue(customer.IdentificationNumber);
            new_RecipientName.SetValue(customer.FirstName);
            new_RecipientLastName.SetValue(customer.LastName);
            new_RecipientMiddleName.SetValue(customer.MiddleName);
            new_FatherName.SetValue(customer.fatherName);
            new_MotherName.SetValue(customer.motherName);

            CultureInfo ci = new CultureInfo(App.Params.CurrentUser.CultureCode);

            DateTime myDate = new DateTime();
            myDate = customer.BirthDate;
            // Bu salaklığı Componentin mask yapısından dolayı yaptım. 
            var datePattern = ci.DateTimeFormat.ShortDatePattern.Replace("d", "dd").Replace("M", "MM").Replace("MMMM", "MM").Replace("dddd", "dd");

            string us = myDate.Date.ToString(datePattern, ci);
            new_Birthdate.SetValue(us);
            new_Birthdate.SetIValue(DateTime.Now);
            new_BirthPlace.SetValue(customer.BirthPlace);
            new_GSMCountryId.SetValue(customer.GSMCountryId);
            new_MobilePhone.SetValue(customer.gsm);
            new_Address.SetValue(customer.HomeAddress);
            new_ProfessionID.SetValue(customer.ProfessionId);
            new_CameFromKps.SetValue(customer.CameFromKps);
            SetCustomerFieldsDisabled(true, customer.CameFromKps);

            if
            (
                UPTCache.CountryService.GetCountryByCountryId(App.Params.CurrentUser.CountryId).IsPersonalSecurity &&
                UPTCache.CorporationService.GetCorporationByCorporationId(App.Params.CurrentUser.CorporationId).IsCustomerDataProtectionActive
            )
            {
                PersonalSecurityFieldSet.SetVisible(true);

                bool IsPersonalSecurity = GetIsPersonalSecurityInfo(ValidationHelper.GetGuid(hfRecipient.Value));
                new_IsPersonalSecurity.SetValue(IsPersonalSecurity);
                new_IsPersonalSecurity.SetDisabled(IsPersonalSecurity);

                if (IsPersonalSecurity)
                {
                    lIsPersonalSecurity.Show();
                    new_IsPersonalSecurity.SetDisabled(true);
                    bPersonalSecurity.SetVisible(false);
                }
                else
                {
                    lIsPersonalSecurity.SetVisible(false);
                    new_IsPersonalSecurity.SetDisabled(true);
                    bPersonalSecurity.Show();
                }

            }
            else
            {
                PersonalSecurityFieldSet.SetVisible(false);
            }



            pnlAlici.SetVisible(true);
            pnlKimlik.SetVisible(true);

            var nationality = UPTCache.NationalityService.GetNationalityByNationalityId(ValidationHelper.GetGuid(customer.NationalityID));

            if (nationality != null && nationality.ExtCode == "KZ")
            {
                new_CorporationOfIdentity.SetVisible(true);
                new_CorporationOfIdentity.SetRequirementLevel(RLevel.BusinessRequired);
                new_DateOfIdentity.SetRequirementLevel(RLevel.BusinessRequired);
                new_ValidDateOfIdendity.SetVisible(true);
            }
            else
            {
                new_CorporationOfIdentity.SetRequirementLevel(RLevel.None);
                new_DateOfIdentity.SetRequirementLevel(RLevel.None);
                new_CorporationOfIdentity.SetVisible(false);
                new_CorporationOfIdentity.Clear();
            }

            QScript("R.reSize();");
        }
        else
        {
            HideCustomerPanels();
        }
    }

    protected void SelectCustomer(object sender, AjaxEventArgs e)
    {
        var rowSelectionModel = ((RowSelectionModel)gpRecipients.SelectionModel[0]);
        if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
        {
            hfRecipient.Value = rowSelectionModel.SelectedRows[0].CustomerId.ToString();
            hfRecipient.SetValue(rowSelectionModel.SelectedRows[0].CustomerId);
            wRecipient.Hide();
            SetCustomer();
        }
        else
        {
            return;
        }
    }

    protected void NewCustomer(object sender, AjaxEventArgs e)
    {
        ClearCustomerControls();

        if
        (
            UPTCache.CountryService.GetCountryByCountryId(App.Params.CurrentUser.CountryId).IsPersonalSecurity &&
            UPTCache.CorporationService.GetCorporationByCorporationId(App.Params.CurrentUser.CorporationId).IsCustomerDataProtectionActive
        )
        {
            PersonalSecurityFieldSet.SetVisible(true);


            lIsPersonalSecurity.SetVisible(false);
            new_IsPersonalSecurity.SetDisabled(true);
            bPersonalSecurity.Show();


        }
        else
        {
            PersonalSecurityFieldSet.SetVisible(false);
        }

        pnlAlici.SetVisible(true);
        pnlKimlik.SetVisible(true);
        PersonalSecurityFieldSet.SetVisible
        (
            (
                UPTCache.CountryService.GetCountryByCountryId(App.Params.CurrentUser.CountryId).IsPersonalSecurity &&
                UPTCache.CorporationService.GetCorporationByCorporationId(App.Params.CurrentUser.CorporationId).IsCustomerDataProtectionActive
            )
        );
        QScript("R.reSize();");

        SetCustomerFieldsDisabled(false, false);
    }

    protected void OpenCustomerDataProtectionApplicationForm(object sender, AjaxEventArgs e)
    {
        var customerIdStr = hfRecipient.Value;
        var customerId = ValidationHelper.GetGuid(customerIdStr);
        if (!string.IsNullOrEmpty(new_SenderId.Value))
        {
            DynamicFactory df = new DynamicFactory(ERunInUser.CalingUser);
            DynamicEntity de = df.RetrieveWithOutPlugin
            (
                TuEntityEnum.New_Sender.GetHashCode(),
                ValidationHelper.GetGuid(customerIdStr),
                new string[] { "new_Name", "new_MiddleName", "new_LastName", "new_NationalityId" }
            );

            string customerName = string.Empty;
            if (string.IsNullOrEmpty(de.GetStringValue("new_MiddleName")))
            {
                customerName = de.GetStringValue("new_Name") + " " + de.GetStringValue("new_LastName");
            }
            else
            {
                customerName = de.GetStringValue("new_Name") + " " + de.GetStringValue("new_MiddleName") + " " + de.GetStringValue("new_LastName");
            }

            Guid nationalityId = de.GetLookupValue("new_NationalityId");
            if (nationalityId == Guid.Empty)
            {
                nationalityId = ValidationHelper.GetGuid(((CrmComboComp)Page.FindControl("new_NationalityId_Container")).Value);
            }

            if (string.IsNullOrWhiteSpace(customerName))
            {
                var name = ((CrmTextFieldComp)Page.FindControl("new_RecipientName_Container")).Value;
                var middleName = ((CrmTextFieldComp)Page.FindControl("new_RecipientMiddleName_Container")).Value;
                var LastName = ((CrmTextFieldComp)Page.FindControl("new_RecipientLastName_Container")).Value;

                if (string.IsNullOrEmpty(middleName))
                {
                    customerName = name + " " + LastName;
                }
                else
                {
                    customerName = name + " " + middleName + " " + LastName;
                }
            }

            pPersonalSecurity.LoadUrl(string.Format("/ISV/TU/KVKK/ApplicationForm.aspx?SenderName={0}&NationalityId={1}", customerName, nationalityId));
            wPersonalSecurity.Show();
            new_IsPersonalSecurity.SetValue(true);
        }
    }

    //protected void IsPersonalSecurityChanged(object sender, AjaxEventArgs e)
    //{
    //    string customerIdStr = string.Empty;
    //    Guid customerId;

    //    try
    //    {
    //        if (!hfRecipient.IsEmpty)
    //        {
    //            customerIdStr = hfRecipient.Value;
    //            customerId = ValidationHelper.GetGuid(customerIdStr);
    //        }
    //        else //Yeni Alıcı
    //        {
    //            SetCustomerFieldsDisabled(true);
    //        }

    //        OpenCustomerDataProtectionApplicationForm(customerIdStr);
    //    }
    //    catch (Exception ex)
    //    {
    //        LogUtil.WriteException(ex, "PaymentMain.IsPersonalSecurityChanged");
    //        MessageBox msg = new MessageBox() { Modal = true, Width = 800, Height = 150 };
    //        msg.Show(CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_HATA_OLUSTU"));
    //    }
    //}

    //void OpenCustomerDataProtectionApplicationForm(string customerId)
    //{
    //    QScript("alert('"+ CrmLabel.TranslateMessage("CRM.NEW_SENDER_KVKK_PERMISSION_WARNING") + "');");
    //    new_IsPersonalSecurity.SetValue(true);
    //    new_IsPersonalSecurity.SetDisabled(true);
    //    //MessageBox msg = new MessageBox() { Modal = true, Width = 800, Height = 150 };
    //    //msg.Show(CrmLabel.TranslateMessage("CRM.NEW_SENDER_KVKK_PERMISSION_WARNING"));

    //    string customerName = string.Empty;
    //    if (string.IsNullOrEmpty(new_RecipientMiddleName.Value.Trim()))
    //    {
    //        customerName = new_RecipientName.Value.Trim() + " " + new_RecipientLastName.Value.Trim();
    //    }
    //    else
    //    {
    //        customerName = new_RecipientName.Value.Trim() + " " + new_RecipientMiddleName.Value.Trim() + " " + new_RecipientLastName.Value.Trim();
    //    }
    //    pPersonalSecurity.LoadUrl(string.Format("/ISV/TU/KVKK/ApplicationForm.aspx?SenderName={0}&NationalityId={1}", customerName, new_NationalityID.Value));
    //    wPersonalSecurity.Show();



    //}

    bool GetIsPersonalSecurityInfo(Guid senderId)
    {
        var staticData = new StaticData();
        var result = false;

        try
        {
            staticData.AddParameter("senderId", DbType.Guid, senderId);
            result = ValidationHelper.GetBoolean(staticData.ReturnDatasetSp("GetPersonalSecurityInfo").Tables[0].Rows[0]["Result"]);
        }
        catch (Exception ex)
        {
            throw ex;
        }

        return result;
    }

    void SetCustomerFieldsDisabled(bool disabled, bool cameFromKps)
    {
        new_NationalityID.SetDisabled(disabled);
        new_RecipientIdentificationCardNumber.SetDisabled(disabled);
        new_RecipientName.SetDisabled(disabled);
        new_RecipientLastName.SetDisabled(disabled);
        new_RecipientMiddleName.SetDisabled(disabled);

        btnKpsAps.SetDisabled(cameFromKps);

    }

    void HideCustomerPanels()
    {
        pnlAlici.SetVisible(false);
        pnlKimlik.SetVisible(false);
        PersonalSecurityFieldSet.SetVisible(false);
    }

    void ClearCustomerControls()
    {
        hfRecipient.Clear();
        tfRecipient.Clear();

        new_NationalityID.Clear();
        new_RecipientIdentificationCardNumber.Clear();
        new_RecipientName.Clear();
        new_RecipientLastName.Clear();
        new_RecipientMiddleName.Clear();
        new_FatherName.Clear();
        new_MotherName.Clear();
        new_Birthdate.Clear();
        new_BirthPlace.Clear();
        new_GSMCountryId.Clear();
        new_MobilePhone.Clear();
        new_Address.Clear();
        new_ProfessionID.Clear();
        new_IdentificatonCardTypeId.Clear();
        new_IdentificatonCardTypeNo.Clear();
        new_DateOfIdentity.Clear();
        new_CorporationOfIdentity.Clear();
    }

    #endregion

    #region Private Events

    private void ShowRequiredFields(string myLabel)
    {
        var msg = CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED");
        var m = new MessageBox { Width = 400 };
        m.Show(string.Format(msg, myLabel));
        return;
    }
    private string GetMultiplePhoneCodeCountries()
    {
        WebClient client = new WebClient();
        return client.DownloadString(App.Params.GetConfigKeyValue("ApplicationHTTPS") + "/ISV/TU/Handlers/PhoneCodeHandler.ashx?method=list");
    }
    #endregion
}

#region Ajax Methods
[AjaxNamespace("AjaxMethods")]
public class AjaxClientMethods
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

    [AjaxMethod()]
    public bool IsNationalityKZ(string nationalityID)
    {

        var nationality = UPTCache.NationalityService.GetNationalityByNationalityId(ValidationHelper.GetGuid(nationalityID));

        if (nationality != null && nationality.ExtCode == "KZ")
        {
            return true;
        }
        else
        {
            return false;
        }
    }
   
}
#endregion