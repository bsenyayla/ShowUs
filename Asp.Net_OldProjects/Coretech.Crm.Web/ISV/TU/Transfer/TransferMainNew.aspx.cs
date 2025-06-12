using AjaxPro;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Info;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using Coretech.Crm.Web.UI.RefleX.View;
using Newtonsoft.Json;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Web;
using TuFactory.Common.Transfer.Helper;
using TuFactory.Integrationd3rdLayer.Object;
using TuFactory.Object;
using TuFactory.Object.Transfer;
using TuFactory.Transfer;
using Coretech.Crm.Data.Crm.Dynamic;
using TuFactory.TuUser;
using TuFactory.Object.User;
using TuFactory.Sender;
using TuFactory.CreditCheck.Domain;
using TuFactory.CreditCheck;
using TuFactory.Recipient;
using TuFactory.Domain;
using System.Net;
using UPTCache = UPT.Shared.CacheProvider.Service;
using TuFactory.TransactionManagers.Sender;
using System.Security.Cryptography.X509Certificates;
using System.Net.Security;
using TuFactory.Profession;

public partial class Transfer_TransferMainNew : BasePage
{
    //Değişkenler
    #region Variables
    private string _CountryCurrencyID;
    private string _CountryCurrencyIDName;
    private bool _IsPartlyCollection = false; //Bu kurumda parcalı tahsilat kullanılır.
    private DynamicSecurity DynamicSecurity;
    private bool _isIBANMandatoryForSwift;
    private string CorporationTransferCalculateScript = string.Empty;
    private decimal UserCostReductionRate;
    private TuUserApproval _userApproval = null;
    //static Guid OtherSerderCorporationUserId = Guid.Empty;

    private TuFactory.Domain.Transfer Transaction = new TuFactory.Domain.Transfer();

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {


        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

        if (!_userApproval.StartTransactionForOtherCorp)
        {
            new_OptionalCorporationId.Clear();
            new_OptionalCorporationId.Hide();
            new_OptionalCorporationId.RequirementLevel = RLevel.None;
        }
        else
        {
            if (!string.IsNullOrEmpty(new_OptionalCorporationId.Value))
            {
                HdnStartTransactionForOtherCorp.SetValue(1);
                HdnStartTransactionForOtherCorp.SetIValue(1);
            }
        }

        if (HdnStartTransactionForOtherCorp.Value == "1")
        {
            //OtherSerderCorporationUserId = GetOtherSenderCorporationSystemUserId(ValidationHelper.GetGuid(new_OptionalCorporationId.Value));
            HdnOtherSerderCorporationUserId.SetIValue(GetOtherSenderCorporationSystemUserId(ValidationHelper.GetGuid(new_OptionalCorporationId.Value)));
            HdnOtherSerderCorporationUserId.SetValue(GetOtherSenderCorporationSystemUserId(ValidationHelper.GetGuid(new_OptionalCorporationId.Value)));
            Session["OtherSerderCorporationUserId"] = HdnOtherSerderCorporationUserId.Value;
        }

        this.new_CalculatedExpenseAmount.c1.Enabled = false;
        DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_Transfer.GetHashCode(), null);
        if (!(DynamicSecurity.PrvCreate || DynamicSecurity.PrvRead || DynamicSecurity.PrvWrite))
            Response.End();

        var sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));
        var dt =
            sd.ReturnDataset(
                @"
SELECT u.new_CorporationID,c.new_CountryID,u.new_OfficeID , co.new_CurrencyID,new_CurrencyIDName,c.new_IsPartlyCollection,o.new_CountryID OfficeCountryId, o.new_OwnOfficeCode, o.new_ReferenceCode
FROM vSystemUser(nolock) u
INNER JOIN vNew_Corporation c on u.new_CorporationID = c.New_CorporationId
INNER JOIN vNew_Office o on o.New_OfficeId=u.new_OfficeID
LEFT OUTER JOIN vnew_country co ON co.New_CountryId=c.new_CountryID Where SystemUserId = @SystemUserId
")
                .Tables[0];

        if (dt.Rows.Count > 0)
        {
            if (string.IsNullOrEmpty(New_TransferId.Value))
            {
                new_CorporationCountryId.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_CountryID"]), "");
                new_CorporationID.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_CorporationID"]), "");
                new_OfficeID.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_OfficeID"]), "");
                new_SenderCountryID.SetValue(ValidationHelper.GetString(dt.Rows[0]["OfficeCountryId"]), "");

            }
            _CountryCurrencyID = ValidationHelper.GetString(dt.Rows[0]["new_CurrencyID"]);
            _CountryCurrencyIDName = ValidationHelper.GetString(dt.Rows[0]["new_CurrencyIDName"]);
            _IsPartlyCollection = ValidationHelper.GetBoolean(dt.Rows[0]["new_IsPartlyCollection"]);
            new_CorporationID.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_CorporationID"]), "");
            HdnOwnOfficeCode.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_OwnOfficeCode"]));
            HdnOfficeReferenceCode.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_ReferenceCode"]));
        }

        if (!_IsPartlyCollection)
        {
            RxM.Visible = false;
            new_ReceivedAmount2.Visible = false;
            new_CollectionMethod.Value = "1";
        }

        ExternalTranslateMessage();
        if (!RefleX.IsAjxPostback)
        {
            ShowCustomerDataProtection();

            if (String.IsNullOrEmpty(QueryHelper.GetString("creditDataID")))
            {
                SetReceiverInformationPanelVisibility(false);
            }
            new_TransferReasonID.SetVisible(false);
            CorporationCountryFormParameterForDisplayControl();

            Page.ClientScript.RegisterStartupScript(typeof(string), "InvalidGsm", "var InvalidGsm="
                  + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_PHONENUMBER_INVALID_EMPTY")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage", "var NEW_SENDER_VALIDDATEOFIDENDITY_NOT_VALID="
               + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_VALIDDATEOFIDENDITY_NOT_VALID")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage1", "var TURKEY_COUNTRY_ID="
                + JsonConvert.SerializeObject(ValidationHelper.GetString(ParameterFactory.GetParameterValue("TURKEY_COUNTRY_ID"))) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage2", "var AKTIFBANK_ODEME_ID="
                + JsonConvert.SerializeObject(TransferType.AktifbankOdemesi) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage3", "var TL_CURRENCY_ID="
                + JsonConvert.SerializeObject(ValidationHelper.GetString(ParameterFactory.GetParameterValue("TL_CURRENCY_ID"))) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage4", "var EFT_GONDERIM="
                + JsonConvert.SerializeObject(ValidationHelper.GetString(ParameterFactory.GetParameterValue("EFT_GONDERIM"))) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage5", "var CREDIT_EFT_PAYMENT_METHOD_ID="
                + JsonConvert.SerializeObject(ValidationHelper.GetString(ParameterFactory.GetParameterValue("CREDIT_EFT_PAYMENT_METHOD_ID"))) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage6", "var AKTIFBANK_ODEMESI="
                + JsonConvert.SerializeObject(ValidationHelper.GetString(ParameterFactory.GetParameterValue("AKTIFBANK_ODEMESI"))) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage7", "var TURKEY_COUNTRY_ID="
                + JsonConvert.SerializeObject(ValidationHelper.GetString(ParameterFactory.GetParameterValue("TURKEY_COUNTRY_ID"))) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "multiplePhoneCodeCountries", "var multiplePhoneCodeCountries="
                + GetMultiplePhoneCodeCountries() + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage8", "var MULTIPLE_PHONE_CODE_INVALID="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.ENTITY_CRM.ENTITY_MULTIPLEPHONECODE_INVALID")) + ";", true);
            Utility.RegisterTypeForAjax(typeof(AjaxMethods));
            //Kredi Ödeme Planı ekranından gelmesi durumu:
            if (QueryHelper.GetString("fromCheckCredit") != "1")
            {
                new_RecipientCountryID.Focus();
            }
            TranslateMessage();
            FieldsetReason.Visible = false;
            New_TransferId.Value = QueryHelper.GetString("recid");
            IsPreAuthorized.Value = QueryHelper.GetString("IsPreAuthorized");
            ExternalPreAuthorizeSenderId.Value = QueryHelper.GetString("ExternalPreAuthorizedSenderId");


            if (!string.IsNullOrEmpty(IsPreAuthorized.Value) && IsPreAuthorized.Value == "1")
            {
                try
                {
                    sd = new StaticData();
                    sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));
                    sd.AddParameter("TransferId", DbType.Guid, ValidationHelper.GetGuid(New_TransferId.Value));

                    var resultt = sd.ExecuteScalarSp(@"SpTuUpdatePreAuthorizedTransfer");
                }
                catch (Exception ex)
                {

                    MessageBox msg = new MessageBox();
                    msg.Show(ex.Message);
                    return;
                }
            }

            LoadData();
            //ReConfigureScreen();

            // Kontrol yerleşimini düzenle
            QScript("R.reSize();");
            ConfigureFirstLoadData();
            //new_RecipientGSMCountryId.Listeners.Change.Handler = "document.getElementById('_new_RecipientGSM').value = new_RecipientGSMCountryId.selectedRecord.new_TelephoneCode;";
            new_RecipientGSMCountryId.Listeners.Change.Handler = "setCountryPhoneCode(new_RecipientGSMCountryId.selectedRecord.new_TelephoneCode, 'recipient');";

            DataTable dtSourceTransactionType = GetSourceTransactionType();
            if (dtSourceTransactionType.Rows.Count == 1) //Eger tek tahsilat tipi varsa, o tipi isaretle ve disabled yap.
            {
                SourceTransactionTypeLoad(null, null);
                new_SourceTransactionTypeID.SetValue(dtSourceTransactionType.Rows[0]["ID"], dtSourceTransactionType.Rows[0]["VALUE"]);
                new_SourceTransactionTypeID.SetDisabled(true);

                SourceTransactionTypeIDOnEvent(null, null);
            }

            //Kredi Ödeme Planı ekranından gelmesi durumu:
            if (QueryHelper.GetString("fromCheckCredit") == "1")
            {
                if (!String.IsNullOrEmpty(QueryHelper.GetString("creditDataID")))
                {
                    CreditPaymentPlanPrepare();
                }
            }
        }
        new_CalculatedExpenseAmount.Items[1].SetDisabled(true);
        setUserCostReductionRate();
    }
    #endregion

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

    protected void OpenCustomerDataProtectionApplicationForm(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(new_SenderID.Value))
        {
            pPersonalSecurity.LoadUrl(string.Format("/ISV/TU/KVKK/ApplicationForm.aspx?SenderId={0}", new_SenderID.Value));
            wPersonalSecurity.Show();
            new_IsPersonalSecurity.SetValue(true);
        }
    }

    #region Load Methods

    private void CreditPaymentPlanPrepare()
    {
        new_CollectionMethod.Value = TransferCollectionMethodEnum.Single.GetHashCode().ToString(); //Tek Parça
        new_SenderID.AjaxEvents.Change.Event -= CalculateOnEvent;
        var credit = GetCreditInfo(ValidationHelper.GetGuid(QueryHelper.GetString("creditDataID")));
        QScript("SetReceipentCountryID();");
        new_RecipientCountryID.SetValue(ValidationHelper.GetString(ParameterFactory.GetParameterValue("TURKEY_COUNTRY_ID")), "Türkiye");
        new_RecipientIDChangeOnEvent(null, null);
        QScript("SetTransactionTargetOptionID();");
        QScript("SetAmountCurrency2();");
        new_AmountCurrency2.SetValue(ValidationHelper.GetString(ParameterFactory.GetParameterValue("TL_CURRENCY_ID")), "TL");
        new_TransactionTargetOptionID.Value = TransferType.AktifbankOdemesi;
        TransactionTargetOptionChange(null, null);
        new_AmountCurrencyOnEvent(null, null);
        QScript("SetTargetTransactionTypeID();");
        new_TargetTransactionTypeID.SetValue(ValidationHelper.GetString(ParameterFactory.GetParameterValue("AKTIFBANK_ODEMESI")), "Aktifbank Ödemesi");
        new_TargetTransactionTypeID.Value = ValidationHelper.GetString(ParameterFactory.GetParameterValue("AKTIFBANK_ODEMESI"));
        new_Amount.Items[1].SetIValue(ValidationHelper.GetString(ParameterFactory.GetParameterValue("TL_CURRENCY_ID")));
        new_Amount.Items[0].SetIValue(ValidationHelper.GetDecimal(credit.TUTAR.Replace(',', '.'), 0));
        QScript("ChangeAmount();");
        SenderSingularityControl receipent = new SenderFactory().GetSender(ValidationHelper.GetGuid(QueryHelper.GetString("senderID")));
        CreditFillRecepient(receipent);
        QScript(String.Format("FillReceipent('{0}','{1}','{2}','{3}','{4}','{5}','{6}');", receipent.FirstName, receipent.LastName, receipent.MiddleName, receipent.motherName, receipent.fatherName, credit.HESAP_NO, receipent.gsm));
        new_RecipientName.Value = receipent.FirstName;
        new_RecipientLastName.Value = receipent.LastName;
        new_RecipientMiddleName.Value = receipent.MiddleName;
        new_RecipientIBAN.Value = credit.HESAP_NO;
        var sourceTransaction = new TransferPageFactory().GetSourceTransactionType("004");//Nakit Tahsilat
        new_SourceTransactionTypeID.SetValue(sourceTransaction.ID, sourceTransaction.Text);
        QScript("DisableFields();");
        if (QueryHelper.GetString("fromCreateSender") == "1")
        {
            QScript("CloseSenderCreateScreen();");
        }
    }

    private void CreditFillRecepient(SenderSingularityControl recepient)
    {
        RecipientFactory rf = new RecipientFactory();
        Guid recepientID = rf.GetRecepientID(ValidationHelper.GetGuid(QueryHelper.GetString("senderID")), recepient.FullName, ValidationHelper.GetGuid(new_TargetTransactionTypeID.Value));
        if (recepientID != Guid.Empty)
        {
            new_RecipientID.Value = ValidationHelper.GetString(recepientID);
            new_RecipientID.SetValue(recepientID, recepient.FullName);
        }
    }
    void ConfigureFirstLoadData()
    {
        if (_IsPartlyCollection)
        {
            if (string.IsNullOrEmpty(New_TransferId.Value))
            {

                new_CollectionMethod.Value = TransferCollectionMethodEnum.Multiple.GetHashCode().ToString();
                new_ReceivedAmount2.c1.SetValue(_CountryCurrencyID, _CountryCurrencyIDName);
            }
            else
            {
                if (new_ReceivedAmount2.c1.Value != string.Empty)
                    new_ReceivedAmount2.c1.SetValue(_CountryCurrencyID, _CountryCurrencyIDName);
            }

            new_CollectionMethod.SetDisabled(true);
            ReconfigureByCollectionMethod();
        }
    }

    protected void LoadData()
    {

        var query = new Dictionary<string, string>
            {
                {"SourceTransactionTypeID", new_SourceTransactionTypeID.Value},
                {"fromCheckCredit",QueryHelper.GetString("fromCheckCredit")},
                {"senderID", string.IsNullOrEmpty(ExternalPreAuthorizeSenderId.Value) ?
                    (string.IsNullOrEmpty(QueryHelper.GetString("SecondScreenSenderId")) ? QueryHelper.GetString("senderID") : QueryHelper.GetString("SecondScreenSenderId"))
                    : ExternalPreAuthorizeSenderId.Value },
                {"MainCurrency",new_AmountCurrency2.Value}
            };




        Panel_SenderInformation.AutoLoad.Url = "TransferSenderFind.aspx" + QueryHelper.RefreshUrl(query);
        //Panel_SenderInformation.AutoLoad.Url = "TransferSenderFind.aspx?SourceTransactionTypeID=";

        if (string.IsNullOrEmpty(New_TransferId.Value))
        {
            return;
        }



        TransferPageFactory tpf = new TransferPageFactory();
        Guid transferUserId = tpf.GetTransferOwnerUserId(ValidationHelper.GetGuid(New_TransferId.Value));

        DynamicFactory df;
        if (transferUserId != Guid.Empty)
        {
            df = new DynamicFactory(transferUserId) { ActivePage = Page };
        }
        else
        {
            df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };
        }

        var tr = df.Retrieve(TuEntityEnum.New_Transfer.GetHashCode(),
                                          ValidationHelper.GetGuid(New_TransferId.Value),
                                          DynamicFactory.RetrieveAllColumns);




        TransferTuRef.Value = tr.GetStringValue("TransferTuRef");
        new_CorporationCountryId.FillDynamicEntityData(tr);
        new_RecipientCorporationId.FillDynamicEntityData(tr);
        new_CorporationID.FillDynamicEntityData(tr);
        new_ConfirmReasonId.FillDynamicEntityData(tr);
        new_ConfirmReasonDescription.FillDynamicEntityData(tr);
        new_OfficeID.FillDynamicEntityData(tr);
        new_SourceTransactionTypeID.FillDynamicEntityData(tr);
        new_RecipientCountryID.FillDynamicEntityData(tr);
        new_TargetTransactionTypeID.FillDynamicEntityData(tr);
        new_SenderID.FillDynamicEntityData(tr);

        new_Explanation.FillDynamicEntityData(tr);
        new_TransactionTargetOptionID.FillDynamicEntityData(tr);
        new_AmountCurrency2.FillDynamicEntityData(tr);
        new_IbanisNotKnown.FillDynamicEntityData(tr);

        new_RecipientGSMCountryId.FillDynamicEntityData(tr);
        new_RecipientGSM.FillDynamicEntityData(tr);
        new_RecipientFatherName.FillDynamicEntityData(tr);
        new_RecipientMotherName.FillDynamicEntityData(tr);
        //new_RecipientHomeTelephone.FillDynamicEntityData(tr);
        //new_RecipientWorkTelephone.FillDynamicEntityData(tr);
        new_RecipientName.FillDynamicEntityData(tr);
        new_RecipientMiddleName.FillDynamicEntityData(tr);
        new_RecipientLastName.FillDynamicEntityData(tr);
        new_RecipientEmail.FillDynamicEntityData(tr);
        new_RecipienNickName.FillDynamicEntityData(tr);
        new_RecipientAddress.FillDynamicEntityData(tr);
        new_RecipientCardNumber.FillDynamicEntityData(tr);
        new_RecipientBirthDate.FillDynamicEntityData(tr);
        new_TestQuestionID.FillDynamicEntityData(tr);
        new_TestQuestionReply.FillDynamicEntityData(tr);
        new_MoneySourceOther.FillDynamicEntityData(tr);
        new_TransferReasonOther.FillDynamicEntityData(tr);

        new_SenderIdentificationCardTypeID.FillDynamicEntityData(tr);
        new_SenderIdentificationCardNo.FillDynamicEntityData(tr);
        new_ValidDateOfSenderIdentificationCard.FillDynamicEntityData(tr);
        new_DateOfIdendity.FillDynamicEntityData(tr);
        new_TransferReasonID.FillDynamicEntityData(tr);
        new_MoneySourceID.FillDynamicEntityData(tr);

        new_EftCity.FillDynamicEntityData(tr);
        new_EftBank.FillDynamicEntityData(tr);
        new_EftPaymentMethodID.FillDynamicEntityData(tr);
        new_EftBranch.FillDynamicEntityData(tr);

        new_BicBank.FillDynamicEntityData(tr);
        new_BicBankCity.FillDynamicEntityData(tr);
        new_BicBankBranch.FillDynamicEntityData(tr);
        new_BicCode.FillDynamicEntityData(tr);


        new_RecipientID.FillDynamicEntityData(tr);
        new_RecipientIBAN.FillDynamicEntityData(tr);
        new_RecipientBicIBAN.FillDynamicEntityData(tr);
        new_RecipientAccountNumber.FillDynamicEntityData(tr);
        new_RecipientBicAccountNumber.FillDynamicEntityData(tr);

        new_RecipientRegionId.FillDynamicEntityData(tr);
        new_RecipientCityId.FillDynamicEntityData(tr);
        new_BrandId.FillDynamicEntityData(tr);
        new_RecipientOfficeId.FillDynamicEntityData(tr);
        new_CorpSendAccountNumber.FillDynamicEntityData(tr);

        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        new_RecipientName.SetValue(cryptor.DecryptInString(new_RecipientName.Value));
        new_RecipientMiddleName.SetValue(cryptor.DecryptInString(new_RecipientMiddleName.Value));
        new_RecipientLastName.SetValue(cryptor.DecryptInString(new_RecipientLastName.Value));
        new_RecipienNickName.SetValue(cryptor.DecryptInString(new_RecipienNickName.Value));

        new_RecipientIDChangeOnEvent(null, null);

        new_CorporationChangeOnEvent(null, null);
        new_AmountCurrency2.FillDynamicEntityData(tr);

        if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
        {
            bool isEFT = Convert.ToBoolean(isEFTHiddenField.Value);
            if (isEFT)
            {
                if (string.IsNullOrEmpty(new_RecipientIBAN.Value))
                {
                    new_IbanisNotKnown.SetValue(true);
                    new_IbanisNotKnown.Checked = true;
                    new_IbanisNotKnownOnEvent(null, null);
                }
            }
            else
            {
                if (!_isIBANMandatoryForSwift)
                {
                    if (string.IsNullOrEmpty(new_RecipientBicIBAN.Value))
                    {
                        new_IbanisNotKnown.SetValue(true);
                        new_IbanisNotKnown.Checked = true;
                        new_IbanisNotKnownOnEvent(null, null);
                    }
                }
            }
        }

        new_Amount.Items[1].SetDisabled(true);
        new_ReceivedAmount2.FillDynamicEntityData(tr);
        new_CollectionMethod.FillDynamicEntityData(tr);
        if (ValidationHelper.GetInteger(new_CollectionMethod.Value) == TransferCollectionMethodEnum.Single.GetHashCode())
        {
            new_ReceivedAmount1.Items[0].SetDisabled(true);
        }
        else
        {
            new_ReceivedAmount1.Items[0].SetDisabled(false);
        }

        Parity1.Clear();
        Parity1.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaymentCurrencyParity1", TuEntityEnum.New_Transfer.GetHashCode()) + ":&nbsp;&nbsp;" +
            Math.Round(ValidationHelper.GetDecimal(((CrmDecimal)tr["new_TransferPaymentCurrencyParity1"]).Value, 0), 6).ToString());
        if (_IsPartlyCollection)
        {

            Parity2.Clear();
            if (new_ReceivedAmount2.d1.Value > 0)
                Parity2.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaymentCurrencyParity2", TuEntityEnum.New_Transfer.GetHashCode()) + ":&nbsp;&nbsp;" +
                    Math.Round(ValidationHelper.GetDecimal(((CrmDecimal)tr["new_TransferPaymentCurrencyParity2"]).Value, 0), 6).ToString());
        }



        new_ExpenseAmount.Items[0].SetDisabled(true);
        new_ExpenseAmount.Items[1].SetDisabled(true);

        new_Amount.FillDynamicEntityData(tr);
        new_ExpenseAmount.FillDynamicEntityData(tr);
        new_CalculatedExpenseAmount.FillDynamicEntityData(tr);
        new_ReceivedAmount1.FillDynamicEntityData(tr);
        new_ReceivedExpenseAmount.FillDynamicEntityData(tr);
        new_ReceivedPaymentAmount.FillDynamicEntityData(tr);
        new_ReceivedPaymentAmountParity.SetValue(((CrmDecimal)tr["new_ReceivedPaymentAmountParity"]).Value);
        new_ReceivedPaymentAmountParityRateType.SetValue(((Lookup)tr["new_ReceivedPaymentAmountParityRateTypeID"]).Value);



        new_TotalReceivedAmount.FillDynamicEntityData(tr);

        if (!string.IsNullOrEmpty(new_ConfirmReasonId.Value))
            FieldsetReason.Visible = true;

        var sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));
        sd.AddParameter("ObjectId", DbType.Int32, TuEntityEnum.New_Transfer.GetHashCode());
        sd.AddParameter("Amount", DbType.Decimal, ((CrmDecimalComp)new_Amount.Items[0]).Value);
        sd.AddParameter("FromCurrencyID", DbType.Guid, ValidationHelper.GetDBGuid(new_AmountCurrency2.Value));
        sd.AddParameter("RecipientCorporationId", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCorporationId.Value));
        sd.AddParameter("RecipientCountryId", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCountryID.Value));
        var script = sd.ExecuteScalar(@"Exec spTUFormRequiredWf2_New @SystemUserId,@ObjectId,@Amount,@FromCurrencyID,@RecipientCorporationId,@RecipientCountryId").ToString();

        QScript(script);
        //if (!string.IsNullOrEmpty(new_SenderID.Value))
        //    Panel_SenderInformation.AutoLoad.Url = Panel_SenderInformation.AutoLoad.Url + new_SenderID.Value;



        var status = df.Retrieve(TuEntityEnum.New_ConfirmStatus.GetHashCode(), tr.GetLookupValue("new_ConfirmStatus"), new string[] { "new_Code" });
        btnSave.Visible = status.GetStringValue("new_Code") != "TR008"; //Gönderim Askıda

        if (true)/*Burda ön onaylı transfer ekranından yönlendiğinin kontrolünü yap*/
        {

            new_AmountOnChange(new_Amount.d1, null);

            if (String.IsNullOrEmpty(new_RecipientCorporationId.Value))
            {
                RecipientCorporationLoad(0, 50);

                DataTable dt = (DataTable)new_RecipientCorporationId.DataSource;
                if (dt.Rows.Count > 0)
                {
                    if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
                    {
                        new_RecipientCorporationId.SetValue("00000000-0000-0000-0000-000000000001", "Diğer");
                        new_RecipientCorporationId.SetDisabled(true);
                    }
                    else if (new_TransactionTargetOptionID.Value == TransferType.IsmeGonderim)
                    {
                        new_RecipientCorporationId.SetValue("00000000-0000-0000-0000-000000000001", "Upt Havuzu");
                        new_RecipientCorporationId.SetDisabled(true);
                    }

                }
            }
        }
        new_RecipientID.Text = cryptor.DecryptInString(new_RecipientID.Text);
        new_RecipienNickName.SetValue(cryptor.DecryptInString(new_RecipienNickName.Value));

        //Kredi Ödeme Planı ekranından gelmesi durumu:
        if (QueryHelper.GetString("fromCheckCreditPrevious") == "1")
        {
            QScript("DisableFields();");
            QScript("DisableSenderInfo();");
            CreditDisableAmountFields();
        }
    }

    #endregion

    #region Attribute Events

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

    protected void new_OptionalCountryLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"Select New_CorporationId AS ID, CorporationName AS VALUE, CorporationName ,new_CorporationCode from vNew_Corporation(NoLock) Where DeletionStateCode = 0 And new_TransactionUserId is not null";

        StaticData sd = new StaticData();

        var like = new_OptionalCorporationId.Query();
        if (!string.IsNullOrEmpty(like))
        {
            strSql += @" AND CorporationName LIKE '%' + @CorporationName + '%' ";
            sd.AddParameter("CorporationName", DbType.String, like);
        }

        strSql += " ORDER BY CorporationName";

        BindCombo(new_OptionalCorporationId, sd, strSql);
    }

    protected void new_RecipientCountryLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"/* DECLARE @SystemUserId UNIQUEIDENTIFIER =  '00000001-2211-44A8-BAAA-89AC131336A9' */

            DECLARE @LangId AS INT
            DECLARE @TempLangId AS INT
            SELECT @LangId = LanguageId FROM vSystemUser
            WHERE SystemUserId = @SystemUserId           
                  
			DECLARE @SystemUserOfficeId AS UNIQUEIDENTIFIER
			DECLARE @SystemUserCorporationId AS UNIQUEIDENTIFIER
			SELECT 
				@SystemUserOfficeId = new_OfficeID,
				@SystemUserCorporationId = new_CorporationID
			FROM SystemUserExtension u
			WHERE u.SystemUserId = @SystemUserId

            DECLARE @NakitOdeme AS UNIQUEIDENTIFIER
            SELECT @NakitOdeme = New_TransactionTypeId FROM vNew_TransactionType
            WHERE new_ExtCode = '008' AND DeletionStateCode = 0

            DECLARE @IsmeGonderim AS UNIQUEIDENTIFIER
            SELECT @IsmeGonderim = New_TransactionTypeId FROM vNew_TransactionType
            WHERE new_ExtCode = '001' AND DeletionStateCode = 0

            DECLARE @HesabaGonderim AS UNIQUEIDENTIFIER
            SELECT @HesabaGonderim = New_TransactionTypeId FROM vNew_TransactionType
            WHERE new_ExtCode = '011' AND DeletionStateCode = 0

            DECLARE @HesabaOdeme AS UNIQUEIDENTIFIER
            SELECT @HesabaOdeme = New_TransactionTypeId FROM vNew_TransactionType
            WHERE new_ExtCode = '012' AND DeletionStateCode = 0

            DECLARE @EFTGonderim AS UNIQUEIDENTIFIER
            SELECT @EFTGonderim = New_TransactionTypeId FROM vNew_TransactionType
            WHERE new_ExtCode = '002' AND DeletionStateCode = 0

            DECLARE @SwiftGonderim AS UNIQUEIDENTIFIER
            SELECT @SwiftGonderim = New_TransactionTypeId FROM vNew_TransactionType
            WHERE new_ExtCode = '003' AND DeletionStateCode = 0

            CREATE TABLE #SystemUserOfficeTransactionTypes
            (
                  TransactionTypeId UNIQUEIDENTIFIER 
            )

            INSERT #SystemUserOfficeTransactionTypes
            SELECT DISTINCT ott.new_TransactionTypeID
            FROM vNew_OfficeTransactionType ott
            WHERE ott.new_OfficeID = @SystemUserOfficeId AND ott.DeletionStateCode=0

            SELECT 
                        c.new_CountryID AS ID, 
                        CASE @TempLangId 
                             WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                             ELSE cl.Value
                        END AS new_CountryIDName,
                        CASE @TempLangId 
                             WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                             ELSE cl.Value
                        END AS VALUE
            FROM New_CountryBase c
            INNER JOIN New_CountryLabel cl
            ON c.New_CountryId = cl.New_CountryId AND cl.LangId = @LangId
            WHERE c.new_CountryID IN
            (
                  SELECT new_CountryID FROM (
                        --Kurumun ofislerinin isme gonderim yetkisi varsa; nakit odeme yapabilen ofislerin ulkeleri
                        SELECT DISTINCT new_CountryID 
                        FROM OfficeTransactionTypeCumulativeTable ctt
                        WHERE
                        (
                              ctt.new_TransactionTypeID = @NakitOdeme /* Nakit odeme yetkisi */
                              AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @IsmeGonderim) /* Isme gonderim yetkisi kontrolu */
                        )
                        OR
                        (
                              ctt.new_TransactionTypeID = @HesabaOdeme /* Hesaba odeme yetkisi */              
                              AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @HesabaGonderim) /* Hesaba gonderim yetkisi kontrolu */
                        )
                        AND new_CountryID NOT IN
						(
							SELECT DISTINCT cbc.new_CountryId FROM vNew_CorporationBlockedCountries cbc
							WHERE cbc.new_CountryId = ctt.new_CountryID AND cbc.new_CorporationId = @SystemUserCorporationId AND cbc.DeletionStateCode = 0
							AND CBC.new_BlockedCorporation is null
				
							UNION
				
							SELECT DISTINCT cbc.new_CountryId FROM vNew_CorporationBlockedCountries cbc
							WHERE cbc.new_CountryId = ctt.new_CountryID AND cbc.new_CorporationId = @SystemUserCorporationId AND cbc.DeletionStateCode = 0
							AND CBC.new_BlockedCorporation is not null and cbc.new_BlockedCorporation <> ctt.New_CorporationId
						)           

                        UNION

                        --Kullanicinin ofisinde EFT yetkisi varsa, Turkiye
                        SELECT c.new_CountryID 
                        FROM vNew_Country c
                        WHERE
                        c.new_CountryShortCode = 'TR' /* Turkiye */ 
                        /* EFT yetkisi kontrolu */
                        AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @EFTGonderim)
                        /* DeletionStateCode kontrolu */ 
                        AND c.DeletionStateCode = 0                        
                  ) AS T

                  UNION

                  --Kullanicinin ofisinde swift yetkisi varsa, SWIFT ulkeleri
                  SELECT DISTINCT new_CountryID 
                  FROM BicBankBranchCumulativeTable
                  WHERE 
                  EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @SwiftGonderim) /* Swift yetkisi kontrolu */
            )";

        StaticData sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));

        var like = new_RecipientCountryID.Query();
        if (!string.IsNullOrEmpty(like))
        {
            strSql += @" AND (CASE @TempLangId 
                             WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                             ELSE cl.Value
                        END LIKE '%' + @CountryName + '%' ";
            sd.AddParameter("CountryName", DbType.String, like.Replace("İ", "I"));
            like = like.Replace("i", "İ");
            like = like.Replace("ı", "I");
            strSql += @" OR CASE @TempLangId 
                             WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                             ELSE cl.Value
                        END LIKE '%' + UPPER(@CountryNameTR COLLATE SQL_Latin1_General_CP1_CI_AS) + '%' )";
            sd.AddParameter("CountryNameTR", DbType.String, like);
        }

        strSql += " ORDER BY CountryName DROP TABLE #SystemUserOfficeTransactionTypes";

        BindCombo(new_RecipientCountryID, sd, strSql);
    }

    protected void new_BicBankLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"SELECT DISTINCT bb.New_BicBankId AS ID, bb.BankName AS VALUE, bb.BankName
			FROM vNew_BicBank bb 
			WHERE bb.new_Country = @RecipientCountryID AND bb.DeletionStateCode = 0 ";

        var like = new_BicBank.Query();

        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("SWIFT_BANKS_LOOKUP");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_BicBank.Start();
        var limit = new_BicBank.Limit();
        var spList = new List<CrmSqlParameter>(){
                             new CrmSqlParameter
                                 {
                                     Dbtype = DbType.Guid,
                                     Paramname = "RecipientCountryID",
                                     Value = ValidationHelper.GetGuid(new_RecipientCountryID.Value)
                                 }
        };

        if (!string.IsNullOrEmpty(like))
        {
            strSql += " AND bb.BankName LIKE @BankName + '%' ";
            spList.Add(new CrmSqlParameter
            {
                Dbtype = DbType.String,
                Paramname = "BankName",
                Value = like
            });
        }

        const string sort = "[{\"field\":\"BankName\",\"direction\":\"Asc\"}]";


        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_BicBank.TotalCount = cnt;
        new_BicBank.DataSource = t;
        new_BicBank.DataBind();
    }

    protected void new_BicBankCityLoad(object sender, AjaxEventArgs e)
    {
        const string strSql = @"SELECT DISTINCT bbc.new_BicBankCityId AS ID, bbc.CityName AS VALUE, bbc.CityName
			FROM vNew_BicBankCity bbc
			WHERE bbc.new_BicBank = @BicBank AND bbc.DeletionStateCode = 0";
        const string sort = "";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("SWIFT_BANK_CITIES_LOOKUP");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_BicBankCity.Start();
        var limit = new_BicBankCity.Limit();
        var spList = new List<CrmSqlParameter>(){
                        new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "BicBank",
                                    Value = ValidationHelper.GetGuid(new_BicBank.Value)
                                }
        };
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_BicBankCity.TotalCount = cnt;
        new_BicBankCity.DataSource = t;
        new_BicBankCity.DataBind();
    }

    protected void new_CountryIdentificationTypeLoad(object sender, AjaxEventArgs e)
    {
        if (((CrmDecimalComp)new_Amount.Items[0]).Value > 0)
        {
            CorporationCountryFormParameterForDisplayControl();
            ReConfigureScreen2();
        }

        var dft = new DynamicFactory(ERunInUser.CalingUser);
        var trt = dft.RetrieveWithOutPlugin(TuEntityEnum.New_Sender.GetHashCode(), ValidationHelper.GetGuid(new_SenderID.Value), new string[] { "new_NationalityID" });
        Guid new_NationalityID = ValidationHelper.GetGuid(trt.GetLookupValue("new_NationalityID"));

        if (new_NationalityID == Guid.Empty)
        {
            var m = new MessageBox { Width = 400, Height = 180 };
            var msg2 = CrmLabel.TranslateMessage("Uyruk Seçimi Yapılmamış.");
            m.Show(msg2);
            return;
        }

        string strSql = @"--DECLARE @NationalityID uniqueidentifier=(Select New_nationalityId from vNew_nationality where new_ExtCode = 'TR' and DeletionStateCode = 0)
--Declare @CountryId Uniqueidentifier='0BFC8AF0-EDAC-482C-83C6-11D833A7A05B'
--Declare @SystemUserId Uniqueidentifier='00000001-9C47-4ABB-9E73-62C8F88E8BA8'

Declare @Data table(new_IdentificationCardType UniqueIdentifier, new_IdentificationCardTypeName nvarchar(100))
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


            If (@Domesic = 1)
            BEGIN
	            IF EXISTS(Select * from vNew_CountryIdentificatonCardType(nolock) cict inner join
	            vNew_CountryIDCTAuth(nolock) cicta
	            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
	            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsDomestic,0) = @Domesic
				and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0))
	            BEGIN
		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict inner join
		            vNew_CountryIDCTAuth(nolock) cicta
		            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsDomestic,0) = @Domesic
					and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0)
	            END

		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict 
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cict.DeletionStateCode = 0 and ISNULL(cict.new_IsDomestic,0) = @Domesic
					and cict.New_CountryIdentificatonCardTypeId not in
						(
							Select cict.New_CountryIdentificatonCardTypeId from vNew_CountryIdentificatonCardType(nolock) cict inner join
							vNew_CountryIDCTAuth(nolock) cicta
							on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
							where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsDomestic,0) = 0
							and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0)
						)

            END

            If (@Foreigner = 1)
            BEGIN
	            IF EXISTS(Select * from vNew_CountryIdentificatonCardType(nolock) cict inner join
	            vNew_CountryIDCTAuth(nolock) cicta
	            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
	            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsForeigner,0) = @Foreigner
				and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0))
	            BEGIN
		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict inner join
		            vNew_CountryIDCTAuth(nolock) cicta
		            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsForeigner,0) = @Foreigner
					and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0)
	            END

		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict 
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cict.DeletionStateCode = 0 and ISNULL(cict.new_IsForeigner,0) = @Foreigner
					and cict.New_CountryIdentificatonCardTypeId not in
						(
							Select cict.New_CountryIdentificatonCardTypeId from vNew_CountryIdentificatonCardType(nolock) cict inner join
							vNew_CountryIDCTAuth(nolock) cicta
							on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
							where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsForeigner,0) = 0
							and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0)
						)

            END

		  Select distinct new_IdentificationCardType AS ID, l.Value AS VALUE, l.Value AS new_IdentificationCardTypeName from vNew_IdentificatonCardType(nolock) cict 
		  INNER JOIN @Data d On cict.New_IdentificatonCardTypeId = d.new_IdentificationCardType
		  LEFT JOIN New_IdentificatonCardTypeLabel(nolock) l On cict.New_IdentificatonCardTypeId = l.New_IdentificatonCardTypeId
		  Where cict.DeletionStateCode = 0 And l.LangId = (SELECT vsu.LanguageId FROM dbo.vSystemUser(nolock) vsu   WHERE  vsu.SystemUserId	= @SystemUserId AND vsu.DeletionStateCode = 0)";

        StaticData sd = new StaticData();
        sd.AddParameter("CountryId", DbType.Guid, ValidationHelper.GetGuid(new_CorporationCountryId.Value));
        sd.AddParameter("NationalityID", DbType.Guid, ValidationHelper.GetGuid(trt.GetLookupValue("new_NationalityID")));
        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty)));

        var like = new_SenderIdentificationCardTypeID.Query();

        if (!string.IsNullOrEmpty(like))
        {

            strSql += " AND l.Value LIKE  @new_IdentificationCardTypeName + '%' ";
            sd.AddParameter("new_IdentificationCardTypeName", DbType.String, like);
        }

        BindCombo(new_SenderIdentificationCardTypeID, sd, strSql);
    }

    protected bool IsCountryIdentificationType(Guid identificationCardTypeId)
    {
        bool result = false;
        var dft = new DynamicFactory(ERunInUser.CalingUser);
        var trt = dft.RetrieveWithOutPlugin(TuEntityEnum.New_Sender.GetHashCode(), ValidationHelper.GetGuid(new_SenderID.Value), new string[] { "new_NationalityID" });
        Guid new_NationalityID = ValidationHelper.GetGuid(trt.GetLookupValue("new_NationalityID"));

        string strSql = @"--DECLARE @NationalityID uniqueidentifier=(Select New_nationalityId from vNew_nationality where new_ExtCode = 'TR' and DeletionStateCode = 0)
--Declare @CountryId Uniqueidentifier='0BFC8AF0-EDAC-482C-83C6-11D833A7A05B'
--Declare @SystemUserId Uniqueidentifier='00000001-9C47-4ABB-9E73-62C8F88E8BA8'

Declare @Data table(new_IdentificationCardType UniqueIdentifier, new_IdentificationCardTypeName nvarchar(100))
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


            If (@Domesic = 1)
            BEGIN
	            IF EXISTS(Select * from vNew_CountryIdentificatonCardType(nolock) cict inner join
	            vNew_CountryIDCTAuth(nolock) cicta
	            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
	            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsDomestic,0) = @Domesic
				and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0))
	            BEGIN
		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict inner join
		            vNew_CountryIDCTAuth(nolock) cicta
		            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsDomestic,0) = @Domesic
					and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0)
	            END

		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict 
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cict.DeletionStateCode = 0 and ISNULL(cict.new_IsDomestic,0) = @Domesic
					and cict.New_CountryIdentificatonCardTypeId not in
						(
							Select cict.New_CountryIdentificatonCardTypeId from vNew_CountryIdentificatonCardType(nolock) cict inner join
							vNew_CountryIDCTAuth(nolock) cicta
							on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
							where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsDomestic,0) = 0
							and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0)
						)

            END

            If (@Foreigner = 1)
            BEGIN
	            IF EXISTS(Select * from vNew_CountryIdentificatonCardType(nolock) cict inner join
	            vNew_CountryIDCTAuth(nolock) cicta
	            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
	            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsForeigner,0) = @Foreigner
				and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0))
	            BEGIN
		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict inner join
		            vNew_CountryIDCTAuth(nolock) cicta
		            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsForeigner,0) = @Foreigner
					and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0)
	            END

		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict 
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cict.DeletionStateCode = 0 and ISNULL(cict.new_IsForeigner,0) = @Foreigner
					and cict.New_CountryIdentificatonCardTypeId not in
						(
							Select cict.New_CountryIdentificatonCardTypeId from vNew_CountryIdentificatonCardType(nolock) cict inner join
							vNew_CountryIDCTAuth(nolock) cicta
							on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
							where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsForeigner,0) = 0
							and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0)
						)

            END

		  Select distinct cict.New_IdentificatonCardTypeId AS ID,  l.Value AS Value, l.Value AS new_IdentificationCardTypeName, l.Value AS IdentificationCardTypeName from vNew_IdentificatonCardType(nolock) cict 
		  INNER JOIN @Data d On cict.New_IdentificatonCardTypeId = d.new_IdentificationCardType
		  LEFT JOIN New_IdentificatonCardTypeLabel(nolock) l On cict.New_IdentificatonCardTypeId = l.New_IdentificatonCardTypeId
		  Where cict.DeletionStateCode = 0 And l.LangId = (SELECT vsu.LanguageId FROM dbo.vSystemUser(nolock) vsu   WHERE  vsu.SystemUserId	= @SystemUserId AND vsu.DeletionStateCode = 0) And cict.New_IdentificatonCardTypeId =  @IdentificationCardType";

        StaticData sd = new StaticData();
        sd.AddParameter("CountryId", DbType.Guid, ValidationHelper.GetGuid(new_CorporationCountryId.Value));
        sd.AddParameter("NationalityID", DbType.Guid, ValidationHelper.GetGuid(trt.GetLookupValue("new_NationalityID")));
        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty)));
        sd.AddParameter("IdentificationCardType", DbType.Guid, identificationCardTypeId);

        DataTable dt = new DataTable();
        try
        {
            dt = sd.ReturnDataset(strSql).Tables[0];
        }
        catch (Exception ex)
        {

            var m = new MessageBox { Width = 400, Height = 180 };
            var msg2 = CrmLabel.TranslateMessage(ex.Message);
            m.Show(msg2);
            result = false;
        }

        if (dt.Rows.Count > 0)
        {
            result = true;
        }
        else
        {
            result = false;
        }
        return result;
    }

    protected void new_BicBankBranchLoad(object sender, AjaxEventArgs e)
    {
        const string strSql = @"SELECT DISTINCT 
            bbb.New_BicBankBranchId AS ID, 
            (case when len(isnull(bbb.BicBankBranchName, '')) < 1 then '- (' + bbb.new_BicCode+')'  else bbb.BicBankBranchName end) AS VALUE, 
            bbb.new_BicCode, 
            (case when len(isnull(bbb.BicBankBranchName, '')) < 1 then  '-' else bbb.BicBankBranchName end) BicBankBranchName
			FROM vNew_BicBankBranch bbb
			WHERE bbb.new_BicBankCity = @BicBankCity AND bbb.DeletionStateCode = 0";
        const string sort = "";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("SWIFT_BANK_BRANCHES_LOOKUP");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_BicBankBranch.Start();
        var limit = new_BicBankBranch.Limit();
        var spList = new List<CrmSqlParameter>(){
                        new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "BicBankCity",
                                    Value = ValidationHelper.GetGuid(new_BicBankCity.Value)
                                }
        };
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_BicBankBranch.TotalCount = cnt;
        new_BicBankBranch.DataSource = t;
        new_BicBankBranch.DataBind();
    }

    protected void new_RecipientID2OnEvent(object sender, AjaxEventArgs e)
    {
        if (_userApproval.UsersForRecipients)
        {
            string userSql = @"SELECT us.FullName AS VALUE,NEWID() AS ID,us.FirstName AS RecipientName,us.LastName new_NickName 
	                            FROM vSystemUser us 
		                            INNER JOIN vNew_Office O ON O.New_OfficeId = us.new_OfficeID
		                            INNER JOIN vNew_Office PO ON PO.New_OfficeId = O.new_ParentOfficeID
		                            INNER JOIN vSystemUser pUs ON pUs.new_OfficeID=PO.New_OfficeId
	                            WHERE pUs.SystemUserId=@SystemUserId AND us.DeletionStateCode=0 AND us.IsDisabled=0
	                            UNION ALL 
	                            SELECT  usr.FullName AS VALUE,NEWID() AS ID,usr.FirstName AS RecipientName,usr.LastName new_NickName 
	                            FROM vSystemUser usr 
		                            INNER JOIN vNew_Office O ON O.New_OfficeId = usr.new_OfficeID
		                            INNER JOIN vSystemUser uu ON uu.new_OfficeID=o.New_OfficeId
	                            WHERE uu.SystemUserId = @SystemUserId AND uu.DeletionStateCode=0 AND o.DeletionStateCode=0 AND usr.DeletionStateCode=0";

            var query = ValidationHelper.GetString(Page.Request["query"], "");

            const string sort = "";
            var viewqueryid = ValidationHelper.GetGuid("b2d802e8-3544-4778-bb1b-112638a0aaa7");
            var gpc = new GridPanelCreater();
            int cnt;
            var start = new_RecipientID.Start();
            var limit = new_RecipientID.Limit();
            var spList = new List<CrmSqlParameter>
                         {

                                 new CrmSqlParameter
                                     {
                                         Dbtype = DbType.Guid,
                                         Paramname = "systemuser",
                                         Value = ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty)
                                     },

                         };
            var t = gpc.GetFilterData(query, userSql, viewqueryid, sort, spList, start, limit, out cnt);

            TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
            List<string> fields = new List<string>() { "VALUE", "RecipientName", "new_NickName" };
            t = cryptor.DecryptFieldsInFilterData(fields, t);
            new_RecipientID.TotalCount = cnt;
            new_RecipientID.DataSource = t;
            new_RecipientID.DataBind();

        }
        else
        {
            string strSql = @"
Select DISTINCT RecipientName AS VALUE ,New_RecipientId AS ID ,RecipientName,new_NickName from  dbo.nltvNew_Recipient(@SystemUserId) mt
where new_SenderID = @new_SenderID and new_TransactionTypeId = @new_TransactionTypeId 
AND  mt.new_BicBankCountryId is null or mt.new_BicBankCountryId = @CountryId 
		";

            var query = ValidationHelper.GetString(Page.Request["query"], "");

            const string sort = "";
            var viewqueryid = ValidationHelper.GetGuid("b2d802e8-3544-4778-bb1b-112638a0aaa7");
            var gpc = new GridPanelCreater();
            int cnt;
            var start = new_RecipientID.Start();
            var limit = new_RecipientID.Limit();
            var spList = new List<CrmSqlParameter>
                         {
                             new CrmSqlParameter
                                 {
                                     Dbtype = DbType.Guid,
                                     Paramname = "new_TransactionTypeId",
                                     Value = ValidationHelper.GetGuid(new_TargetTransactionTypeID.Value)
                                 },
                             new CrmSqlParameter
                                 {
                                     Dbtype = DbType.Guid,
                                     Paramname = "new_SenderID",
                                     Value = ValidationHelper.GetGuid(new_SenderID.Value)
                                 },
                                 new CrmSqlParameter
                                     {
                                         Dbtype = DbType.Guid,
                                         Paramname = "systemuser",
                                         Value = ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty)
                                     },
                                new CrmSqlParameter
                                 {
                                     Dbtype = DbType.Guid,
                                     Paramname = "CountryId",
                                     Value = ValidationHelper.GetGuid(new_RecipientCountryID.Value)
                                 },
                         };
            var t = gpc.GetFilterData(query, strSql, viewqueryid, sort, spList, start, limit, out cnt);

            TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
            List<string> fields = new List<string>() { "VALUE", "RecipientName", "new_NickName" };
            t = cryptor.DecryptFieldsInFilterData(fields, t);
            new_RecipientID.TotalCount = cnt;
            new_RecipientID.DataSource = t;
            new_RecipientID.DataBind();
        }




    }

    protected void new_AmountCurrency2OnEvent(object sender, AjaxEventArgs e)
    {
        new_CalculatedExpenseAmountDefaultValue.Value = string.Empty;
        new_CalculatedExpenseAmountDefaultValue.SetIValue(string.Empty);

        string strSql = @"
/*
DECLARE @SystemUser UNIQUEIDENTIFIER = '00000001-2211-44A8-BAAA-89AC131336A9'
DECLARE @RecipientCountryID UNIQUEIDENTIFIER = '0bfc8af0-edac-482c-83c6-11d833a7a05b'
DECLARE @RecipientCorporationID UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
DECLARE @RecipientOfficeID UNIQUEIDENTIFIER = 'E5CDD873-D64F-4974-8C3D-000300DE0541'
DECLARE @TransactionTargetOptionID UNIQUEIDENTIFIER = '07a57964-9bfc-e511-b4e3-54442fe8720d'

select * from vNew_Country where CountryName ='Rusya'
select * from vNew_Corporation where CorporationName LIKE '%Russlav%'
select * from vSystemUser where UserName='epos'
select * from vNew_TransactionTargetOption
select new_OfficeId from vNew_Office WHERE new_CorporationId = '0BFC8B02-816A-4DF0-9391-38339EEBCD79'
and DeletionStateCode = 0
*/

DECLARE @SystemUserOfficeId AS UNIQUEIDENTIFIER
SELECT @SystemUserOfficeId = new_OfficeID FROM SystemUserExtension u
WHERE u.SystemUserId = @SystemUser

DECLARE @NakitOdeme AS UNIQUEIDENTIFIER
SELECT @NakitOdeme = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '008' AND DeletionStateCode = 0

DECLARE @IsmeGonderim AS UNIQUEIDENTIFIER
SELECT @IsmeGonderim = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '001' AND DeletionStateCode = 0

DECLARE @HesabaGonderim AS UNIQUEIDENTIFIER
SELECT @HesabaGonderim = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '011' AND DeletionStateCode = 0

DECLARE @HesabaOdeme AS UNIQUEIDENTIFIER
SELECT @HesabaOdeme = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '012' AND DeletionStateCode = 0

DECLARE @EFTGonderim AS UNIQUEIDENTIFIER
SELECT @EFTGonderim = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '002' AND DeletionStateCode = 0

DECLARE @SwiftGonderim AS UNIQUEIDENTIFIER
SELECT @SwiftGonderim = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '003' AND DeletionStateCode = 0

DECLARE @TransactionTargetOptionCode AS NVARCHAR(10)
SELECT @TransactionTargetOptionCode = new_TransactionTargetOptionCode FROM
vNew_TransactionTargetOption ttt
WHERE 
ttt.New_TransactionTargetOptionId = @TransactionTargetOptionID
AND ttt.DeletionStateCode = 0

CREATE TABLE #SystemUserOfficeTransactionTypes
(
	TransactionTypeId UNIQUEIDENTIFIER,
	CurrencyId UNIQUEIDENTIFIER
)

INSERT #SystemUserOfficeTransactionTypes
SELECT DISTINCT ott.new_TransactionTypeID, ott.new_CurrencyId
FROM vNew_OfficeTransactionType ott
WHERE ott.new_OfficeID = @SystemUserOfficeId AND ott.DeletionStateCode=0

IF @RecipientOfficeID IS NULL
BEGIN
	SELECT 
		CurrencyId ID,
		CurrencyId new_CurrencyId,
		Currencyname new_CurrencyIdName,
		Currencyname VALUE
	FROM tvCurrency(@SystemUser)
	WHERE CurrencyId IN
	(
		--Kullanıcının ofisinin Isme Gonderim için tanimli doviz cinsleri, 
		--eger nakit odeme yapılabilen ulke-kurum-ofislerinin doviz cinsleri arasinda bulunuyorsa gosterilir.
		SELECT DISTINCT
			CurrencyId
		FROM #SystemUserOfficeTransactionTypes 
		WHERE 
		TransactionTypeId = @IsmeGonderim /* Isme Gonderim */ 
		AND CurrencyId IN
		(
			SELECT
				new_CurrencyId
			FROM OfficeTransactionTypeCumulativeTable
			WHERE new_ExtCode = '008'    
			AND 
			(
				(@RecipientCorporationID IS NULL AND new_CountryID = @RecipientCountryID)
				OR
				(@RecipientCorporationID IS NOT NULL AND New_CorporationId = @RecipientCorporationID AND new_CountryID = @RecipientCountryID) 
			)
			AND @TransactionTargetOptionCode = '002' /* Hedef islem secenegi -  Isme Gonderim */
		)

		UNION

		--Kullanıcının ofisinin Hesaba Gonderim için tanimli doviz cinsleri, 
		--eger hesaba odeme yapılabilen kurum-ofislerinin doviz cinsleri arasinda bulunuyorsa gosterilir.
		SELECT DISTINCT
			CurrencyId
		FROM #SystemUserOfficeTransactionTypes 
		WHERE 
		TransactionTypeId = @HesabaGonderim /* Hesaba Gonderim */ 
		AND CurrencyId IN
		(
			SELECT
				new_CurrencyId
			FROM OfficeTransactionTypeCumulativeTable
			WHERE new_ExtCode = '012' /* Hesaba Odeme */    
			AND 
			(
				(@RecipientCorporationID IS NULL AND new_CountryID = @RecipientCountryID)
				OR
				(@RecipientCorporationID IS NOT NULL AND New_CorporationId = @RecipientCorporationID AND new_CountryID = @RecipientCountryID) 
			)
			AND @TransactionTargetOptionCode = '001' /* Hedef islem secenegi - Hesaba Gonderim */
		)

		UNION

		--Hesaba Gonderim ise, kullanicinin tum doviz cinsleri, alici ulke TR ise ya da islem Swift ise gosterilir.
		--KK Gonderim ise, kullanicinin tum doviz cinsleri, alici ulke TR ise gosterilir. 
		SELECT DISTINCT
			CurrencyId
		FROM #SystemUserOfficeTransactionTypes
		WHERE
		@RecipientCorporationID IS NULL
		AND 
		(
			(
				@TransactionTargetOptionCode = '001' /* Hesaba gonderim */
				AND
				(
					(
						TransactionTypeId = @EFTGonderim /* EFT */
						AND 
						(
							SELECT new_CountryShortCode FROM vNew_Country WHERE new_CountryID = @RecipientCountryID AND DeletionStateCode = 0
						) = 'TR' /* Alici ulke Turkiye */
					)
					OR
					(
						TransactionTypeId = @SwiftGonderim /* Swift */
					)
				)
			)
			OR
			(
				@TransactionTargetOptionCode = '006' /* Aktifbank Ödemesi */
				AND
				(
					(
						TransactionTypeId = @EFTGonderim /* EFT */
						AND 
						(
							SELECT new_CountryShortCode FROM vNew_Country WHERE new_CountryID = @RecipientCountryID AND DeletionStateCode = 0
						) = 'TR' /* Alici ulke Turkiye */
					)
				)
			)
			OR
			(
				@TransactionTargetOptionCode = '004' /* Kredi kartina gonderim */
				AND
				(
					(
						TransactionTypeId = @EFTGonderim /* EFT */
						AND 
						(
							SELECT new_CountryShortCode FROM vNew_Country WHERE new_CountryID = @RecipientCountryID AND DeletionStateCode = 0
						) = 'TR' /* Alici ulke Turkiye */
					)
				)
			)
		)
	)
END
ELSE
BEGIN
	SELECT 
		CurrencyId ID,
		CurrencyId new_CurrencyId,
		Currencyname new_CurrencyIdName,
		Currencyname VALUE
	FROM tvCurrency(@SystemUser)
	WHERE CurrencyId IN
	(
		--Kullanıcının ofisinin Isme Gonderim için tanimli doviz cinsleri, 
		--eger nakit odeme yapılabilen ulke-kurum-ofislerinin doviz cinsleri arasinda bulunuyorsa gosterilir. 
		SELECT DISTINCT
			CurrencyId
		FROM #SystemUserOfficeTransactionTypes 
		WHERE 
		TransactionTypeId = @IsmeGonderim /* Isme Gonderim */ 
		AND CurrencyId IN
		(
			SELECT
				new_CurrencyId
			FROM vNew_OfficeTransactionType
			WHERE new_TransactionTypeID = @NakitOdeme /* Nakit Odeme */  
			AND new_OfficeID = @RecipientOfficeID
			AND @TransactionTargetOptionCode = '002' /* Hedef islem secenegi -  Isme Gonderim */
		)
		
		UNION
		
		--Kullanıcının ofisinin Hesaba Gonderim için tanimli doviz cinsleri, 
		--eger hesaba odeme yapılabilen kurum-ofislerinin doviz cinsleri arasinda bulunuyorsa gosterilir.
		SELECT DISTINCT
			CurrencyId
		FROM #SystemUserOfficeTransactionTypes 
		WHERE 
		TransactionTypeId = @HesabaGonderim /* Hesaba Gonderim */ 
		AND CurrencyId IN
		(
			SELECT
				new_CurrencyId
			FROM vNew_OfficeTransactionType
			WHERE new_TransactionTypeID = @HesabaOdeme /* Hesaba Odeme */    
			AND new_OfficeID = @RecipientOfficeID
			AND @TransactionTargetOptionCode = '001' /* Hedef islem secenegi - Hesaba Gonderim */
		)
		
		UNION
		
		--Hesaba Gonderim ise, kullanicinin tum doviz cinsleri, alici ulke TR ise ya da islem Swift ise gosterilir.
		--KK Gonderim ise, kullanicinin tum doviz cinsleri, alici ulke TR ise gosterilir. 
		SELECT DISTINCT
			CurrencyId
		FROM #SystemUserOfficeTransactionTypes
		WHERE
		@RecipientCorporationID IS NULL
		AND 
		(
			(
				@TransactionTargetOptionCode = '001' /* Hesaba gonderim */
				AND
				(
					(
						TransactionTypeId = @EFTGonderim /* EFT */
						AND 
						(
							SELECT new_CountryShortCode FROM vNew_Country WHERE new_CountryID = @RecipientCountryID AND DeletionStateCode = 0
						) = 'TR' /* Alici ulke Turkiye */
					)
					OR
					(
						TransactionTypeId = @SwiftGonderim /* Swift */
					)
				)
			)
			OR
			(
				@TransactionTargetOptionCode = '006' /* Aktifbank Ödemesi */
				AND
				(
					(
						TransactionTypeId = @EFTGonderim /* EFT */
						AND 
						(
							SELECT new_CountryShortCode FROM vNew_Country WHERE new_CountryID = @RecipientCountryID AND DeletionStateCode = 0
						) = 'TR' /* Alici ulke Turkiye */
					)
				)
			)
			OR
			(
				@TransactionTargetOptionCode = '004' /* Kredi kartina gonderim */
				AND
				(
					(
						TransactionTypeId = @EFTGonderim /* EFT */
						AND 
						(
							SELECT new_CountryShortCode FROM vNew_Country WHERE new_CountryID = @RecipientCountryID AND DeletionStateCode = 0
						) = 'TR' /* Alici ulke Turkiye */
					)
				)
			)
		)
	)
END

DROP TABLE #SystemUserOfficeTransactionTypes";

        StaticData sd = new StaticData();
        sd.AddParameter("SystemUser", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));
        sd.AddParameter("RecipientCountryID", DbType.Guid, ValidationHelper.GetGuid(new_RecipientCountryID.Value));
        sd.AddParameter("RecipientCorporationID", DbType.Guid, new_RecipientCorporationId.Value != "00000000-0000-0000-0000-000000000001" ? ValidationHelper.GetGuid(new_RecipientCorporationId.Value) : ValidationHelper.GetDBGuid(Guid.Empty));
        sd.AddParameter("RecipientOfficeID", DbType.Guid, ValidationHelper.GetGuid(new_RecipientOfficeId.Value));
        sd.AddParameter("TransactionTargetOptionID", DbType.Guid, ValidationHelper.GetGuid(new_TransactionTargetOptionID.Value));

        BindCombo(new_AmountCurrency2, sd, strSql);
    }

    protected void new_TransactionTargetOptionIDOnEvent(object sender, AjaxEventArgs e)
    {
        #region OLD_SQL
        const string strSql2 = @"
/* DECLARE @SystemUser UNIQUEIDENTIFIER = '00000001-2211-44A8-BAAA-89AC131336A9'
DECLARE @RecipientCountryID UNIQUEIDENTIFIER = '0BFC8AF0-EDAC-482C-83C6-11D833A7A05B' */

DECLARE @SystemUserOfficeId AS UNIQUEIDENTIFIER
DECLARE @SystemUserCorporationId AS UNIQUEIDENTIFIER
SELECT 
    @SystemUserOfficeId = new_OfficeID,
    @SystemUserCorporationId = new_CorporationID
FROM SystemUserExtension u
WHERE u.SystemUserId = @SystemUser

DECLARE @NakitOdeme AS UNIQUEIDENTIFIER
SELECT @NakitOdeme = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '008' AND DeletionStateCode = 0

DECLARE @IsmeGonderim AS UNIQUEIDENTIFIER
SELECT @IsmeGonderim = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '001' AND DeletionStateCode = 0

DECLARE @HesabaGonderim AS UNIQUEIDENTIFIER
SELECT @HesabaGonderim = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '011' AND DeletionStateCode = 0

DECLARE @HesabaOdeme AS UNIQUEIDENTIFIER
SELECT @HesabaOdeme = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '012' AND DeletionStateCode = 0

DECLARE @EFTGonderim AS UNIQUEIDENTIFIER
SELECT @EFTGonderim = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '002' AND DeletionStateCode = 0

DECLARE @SwiftGonderim AS UNIQUEIDENTIFIER
SELECT @SwiftGonderim = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '003' AND DeletionStateCode = 0

CREATE TABLE #SystemUserOfficeTransactionTypes
(
	TransactionTypeId UNIQUEIDENTIFIER 
)

INSERT #SystemUserOfficeTransactionTypes
SELECT DISTINCT ott.new_TransactionTypeID
FROM vNew_OfficeTransactionType ott
WHERE ott.new_OfficeID = @SystemUserOfficeId AND ott.DeletionStateCode=0

DECLARE @IsBlockedCountry AS BIT = 0

/*
IF EXISTS(
	SELECT 1 FROM vNew_CorporationBlockedCountries cbc
	WHERE cbc.new_CorporationID = @SystemUserCorporationId AND cbc.new_CountryId = @RecipientCountryID AND cbc.DeletionStateCode = 0 and CBC.new_BlockedCorporation is null
)
BEGIN
	SET @IsBlockedCountry = 1		
END
*/


IF EXISTS(SELECT 1 
		    FROM vNew_CorporationBlockedCountries cbc
		   WHERE cbc.new_CorporationID = @SystemUserCorporationId 
			 AND cbc.new_CountryId = @RecipientCountryID 
			 AND cbc.DeletionStateCode = 0 
			 AND cbc.new_BlockedCorporation IS NULL)
	BEGIN
		SET @IsBlockedCountry = 1		
	END
ELSE IF NOT EXISTS(SELECT DISTINCT 1
				     FROM OfficeTransactionTypeCumulativeTable cc
				    WHERE cc.new_TransactionTypeID = @NakitOdeme
				      AND cc.new_CountryID = @RecipientCountryID
				      AND cc.New_CorporationId not in(
					    SELECT cbc.new_BlockedCorporation 
                          FROM vNew_CorporationBlockedCountries cbc
					     WHERE cbc.new_CorporationID = @SystemUserCorporationId 
					       AND cbc.new_CountryId = @RecipientCountryID 
					       AND cbc.DeletionStateCode = 0 
					       AND cbc.new_BlockedCorporation is not null))
	BEGIN
		SET @IsBlockedCountry = 1		
	END


--Kurumun ofislerinin isme gonderim yetkisi varsa ve secili alici ulkede nakit odeme yetkisi olan bir ofis varsa; Isme Gonderim 
--Kurumun ofislerinin hesaba gonderim yetkisi varsa ve secili alici ulkede hesaba odeme yetkisi olan bir ofis varsa; Isme Gonderim 
SELECT DISTINCT 
    tto.new_TransactionTargetOptionId as ID, 
    tto.new_TransactionTargetOptionId, 
    tto.TransactionTargetOption as VALUE, 
    tto.TransactionTargetOption as TransactionTargetOption
FROM nltvNew_TransactionTargetOption(@SystemUser) tto
WHERE 
(
	(
		EXISTS(
			SELECT 1 FROM OfficeTransactionTypeCumulativeTable
			WHERE 
			new_CountryID = @RecipientCountryID
			AND new_TransactionTypeID = @NakitOdeme /* Nakit odeme */
		)
		AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @IsmeGonderim) /* Isme gonderim yetkisi kontrolu */
		AND tto.new_TransactionTargetOptionCode = '002' /* Hedef islem secenegi - Isme Gonderim */
	)
	OR
	(
		EXISTS(
			SELECT 1 FROM OfficeTransactionTypeCumulativeTable
			WHERE 
			new_CountryID = @RecipientCountryID
			AND new_TransactionTypeID = @HesabaOdeme /* Hesaba odeme */
		)
		/* Hesaba gonderim yetkisi kontrolu */
		AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @HesabaGonderim) /* Hesaba gonderim yetkisi kontrolu */
		AND tto.new_TransactionTargetOptionCode = '001' /* Hedef islem secenegi - Hesaba Gonderim */
	)
)
AND tto.DeletionStateCode = 0         
AND @IsBlockedCountry = 0

UNION

--Kurumun EFT yetkisi varsa ve alici ulke Turkiye ise; Hesaba Gonderim
SELECT DISTINCT 
    tott.new_TransactionTargetOptionId as ID, 
    tott.new_TransactionTargetOptionId, 
    tott.new_TransactionTargetOptionIdName as VALUE, 
    tott.new_TransactionTargetOptionIdName as TransactionTargetOption
FROM nltvNew_TargetOptionTransactionType(@SystemUser) tott
INNER JOIN OfficeTransactionTypeCumulativeTable ctt
ON ctt.new_TransactionTypeID = tott.new_TransactionTypeId
WHERE 
ctt.new_CountryID = @RecipientCountryID
AND ctt.new_CountryShortCode = 'TR'
AND ctt.new_ExtCode = '002'
AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @EFTGonderim) /* EFT gonderim yetkisi kontrolu */
AND tott.DeletionStateCode = 0

UNION

--Kurumun Swift yetkisi varsa ve alici ulke Swift tablosundaki bir ulke ise; Hesaba Gonderim
SELECT DISTINCT
    tott.new_TransactionTargetOptionId as ID, 
    tott.new_TransactionTargetOptionId, 
    tott.new_TransactionTargetOptionIdName as VALUE, 
    tott.new_TransactionTargetOptionIdName as TransactionTargetOption
FROM nltvNew_TargetOptionTransactionType(@SystemUser) tott
INNER JOIN vNew_TransactionType tt
ON tott.new_TransactionTypeId = tt.New_TransactionTypeId AND tt.DeletionStateCode = 0
WHERE 
tt.new_ExtCode = '003'
/* Swift yetkisi kontrolu */
AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @SwiftGonderim) /* Swift gonderim yetkisi kontrolu */
AND EXISTS(
    SELECT 1 FROM BicBankBranchCumulativeTable bbb
    WHERE bbb.new_CountryID = @RecipientCountryID
)
AND tott.DeletionStateCode = 0

DROP TABLE #SystemUserOfficeTransactionTypes";
        #endregion

        #region NEW_SQL
        const string strSql = @"
/*DECLARE @SystemUser UNIQUEIDENTIFIER = '00000001-2211-44A8-BAAA-89AC131336A9'
DECLARE @RecipientCountryID UNIQUEIDENTIFIER = 'F5F8F4B8-B7A8-499B-8A56-3B4AD930A16E'*/

DECLARE @TransactionTargetOptionId UNIQUEIDENTIFIER

SELECT @TransactionTargetOptionId = New_TransactionTargetOptionId FROM vNew_TransactionTargetOption 
WHERE new_TransactionTargetOptionCode = '001' AND DeletionStateCode = 0 /*Hesaba Gönderim */

DECLARE @SystemUserOfficeId AS UNIQUEIDENTIFIER
DECLARE @SystemUserCorporationId AS UNIQUEIDENTIFIER

DECLARE @NakitOdeme AS UNIQUEIDENTIFIER
SELECT @NakitOdeme = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '008' AND DeletionStateCode = 0

DECLARE @IsmeGonderim AS UNIQUEIDENTIFIER
SELECT @IsmeGonderim = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '001' AND DeletionStateCode = 0

DECLARE @HesabaGonderim AS UNIQUEIDENTIFIER
SELECT @HesabaGonderim = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '011' AND DeletionStateCode = 0

DECLARE @HesabaOdeme AS UNIQUEIDENTIFIER
SELECT @HesabaOdeme = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '012' AND DeletionStateCode = 0

DECLARE @AktifbankOdemesi AS UNIQUEIDENTIFIER
SELECT @AktifbankOdemesi = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '021' AND DeletionStateCode = 0

DECLARE @EFTGonderim AS UNIQUEIDENTIFIER
SELECT @EFTGonderim = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '002' AND DeletionStateCode = 0

DECLARE @SwiftGonderim AS UNIQUEIDENTIFIER
SELECT @SwiftGonderim = New_TransactionTypeId FROM vNew_TransactionType
WHERE new_ExtCode = '003' AND DeletionStateCode = 0

SELECT 
    @SystemUserOfficeId = new_OfficeID,
    @SystemUserCorporationId = new_CorporationID
FROM SystemUserExtension u
WHERE u.SystemUserId = @SystemUser

CREATE TABLE #CountryPriorCorporation
(
	CorporationId UNIQUEIDENTIFIER
)

IF EXISTS(
	SELECT 1
	FROM vNew_CountryPriorCorporation cpc
	WHERE new_CountryId=@RecipientCountryID 
	AND new_TransactionTargetOptionId = @TransactionTargetOptionId
	AND new_SenderCorporationId = @SystemUserCorporationId
	AND cpc.DeletionStateCode=0
)
BEGIN
	INSERT #CountryPriorCorporation
	SELECT
	new_CorporationId
	FROM vNew_CountryPriorCorporation cpc
	WHERE new_CountryId=@RecipientCountryID 
	AND new_TransactionTargetOptionId = @TransactionTargetOptionId
	AND new_SenderCorporationId = @SystemUserCorporationId
	AND cpc.DeletionStateCode=0
END
ELSE
BEGIN
	INSERT #CountryPriorCorporation
	SELECT
	new_CorporationId
	FROM vNew_CountryPriorCorporation cpc
	WHERE new_CountryId=@RecipientCountryID 
	AND new_TransactionTargetOptionId = @TransactionTargetOptionId
	AND new_SenderCorporationId IS NULL
	AND cpc.DeletionStateCode=0
END

CREATE TABLE #SystemUserOfficeTransactionTypes
(
	TransactionTypeId UNIQUEIDENTIFIER 
)

INSERT #SystemUserOfficeTransactionTypes
SELECT DISTINCT ott.new_TransactionTypeID
FROM vNew_OfficeTransactionType ott
WHERE ott.new_OfficeID = @SystemUserOfficeId AND ott.DeletionStateCode=0

DECLARE @IsBlockedCountry AS BIT = 0

IF EXISTS(SELECT 1 
		    FROM vNew_CorporationBlockedCountries cbc
		   WHERE cbc.new_CorporationID = @SystemUserCorporationId 
			 AND cbc.new_CountryId = @RecipientCountryID 
			 AND cbc.DeletionStateCode = 0 
			 AND cbc.new_BlockedCorporation IS NULL)
	BEGIN
		SET @IsBlockedCountry = 1		
	END
ELSE IF NOT EXISTS(SELECT DISTINCT 1
				     FROM OfficeTransactionTypeCumulativeTable cc
				    WHERE (cc.new_TransactionTypeID = @NakitOdeme OR cc.new_TransactionTypeID = @HesabaOdeme)
				      AND cc.new_CountryID = @RecipientCountryID
				      AND cc.New_CorporationId not in(
					    SELECT cbc.new_BlockedCorporation 
                          FROM vNew_CorporationBlockedCountries cbc
					     WHERE cbc.new_CorporationID = @SystemUserCorporationId 
					       AND cbc.new_CountryId = @RecipientCountryID 
					       AND cbc.DeletionStateCode = 0 
					       AND cbc.new_BlockedCorporation is not null))
	BEGIN
		SET @IsBlockedCountry = 1		
	END


--Kurumun ofislerinin isme gonderim yetkisi varsa ve secili alici ulkede nakit odeme yetkisi olan bir ofis varsa; Isme Gonderim 
SELECT DISTINCT 
    tto.new_TransactionTargetOptionId as ID, 
    tto.new_TransactionTargetOptionId, 
    tto.TransactionTargetOption as VALUE, 
    tto.TransactionTargetOption as TransactionTargetOption
FROM nltvNew_TransactionTargetOption(@SystemUser) tto
WHERE 
EXISTS(
	SELECT 1 FROM OfficeTransactionTypeCumulativeTable
	WHERE 
	new_CountryID = @RecipientCountryID
	AND new_TransactionTypeID = @NakitOdeme /* Nakit odeme */
)
AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @IsmeGonderim) /* Isme gonderim yetkisi kontrolu */
AND tto.new_TransactionTargetOptionCode = '002' /* Hedef islem secenegi - Isme Gonderim */
AND tto.DeletionStateCode = 0         
AND @IsBlockedCountry = 0

UNION

--Kurumun ofislerinin hesaba gonderim yetkisi varsa ve secili alici ulkede hesaba odeme yetkisi olan bir ofis varsa; Hesaba Gonderim 
SELECT DISTINCT 
    tto.new_TransactionTargetOptionId as ID, 
    tto.new_TransactionTargetOptionId, 
    tto.TransactionTargetOption as VALUE, 
    tto.TransactionTargetOption as TransactionTargetOption
FROM nltvNew_TransactionTargetOption(@SystemUser) tto
WHERE 
EXISTS(
	SELECT 1 FROM OfficeTransactionTypeCumulativeTable
	WHERE 
	new_CountryID = @RecipientCountryID
	AND new_TransactionTypeID = @HesabaOdeme /* Hesaba odeme */
	AND New_CorporationId IN (SELECT CorporationId FROM #CountryPriorCorporation)
)
/* Hesaba gonderim yetkisi kontrolu */
AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @HesabaGonderim) /* Hesaba gonderim yetkisi kontrolu */
AND tto.new_TransactionTargetOptionCode = '001' /* Hedef islem secenegi - Hesaba Gonderim */
AND tto.DeletionStateCode = 0         
AND @IsBlockedCountry = 0

UNION

--Kurumun EFT yetkisi varsa ve alici ulke Turkiye ise; Hesaba Gonderim
SELECT DISTINCT 
    tott.new_TransactionTargetOptionId as ID, 
    tott.new_TransactionTargetOptionId, 
    tott.new_TransactionTargetOptionIdName as VALUE, 
    tott.new_TransactionTargetOptionIdName as TransactionTargetOption
FROM nltvNew_TargetOptionTransactionType(@SystemUser) tott
INNER JOIN OfficeTransactionTypeCumulativeTable ctt
ON ctt.new_TransactionTypeID = tott.new_TransactionTypeId
WHERE 
ctt.new_CountryID = @RecipientCountryID
AND ctt.new_CountryShortCode = 'TR'
AND ctt.new_ExtCode = '002'
AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @EFTGonderim) /* EFT gonderim yetkisi kontrolu */
AND tott.DeletionStateCode = 0

UNION

--Kurumun Aktifbank Ödemesi yetkisi varsa ve alici ulke Turkiye ise; Hesaba Gonderim
SELECT DISTINCT 
    tott.new_TransactionTargetOptionId as ID, 
    tott.new_TransactionTargetOptionId, 
    tott.new_TransactionTargetOptionIdName as VALUE, 
    tott.new_TransactionTargetOptionIdName as TransactionTargetOption
FROM nltvNew_TargetOptionTransactionType(@SystemUser) tott
INNER JOIN OfficeTransactionTypeCumulativeTable ctt
ON ctt.new_TransactionTypeID = tott.new_TransactionTypeId
WHERE 
ctt.new_CountryID = @RecipientCountryID
AND ctt.new_CountryShortCode = 'TR'
AND ctt.new_ExtCode = '021'
AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @AktifbankOdemesi) /* EFT gonderim yetkisi kontrolu */
AND tott.DeletionStateCode = 0

UNION

--Kurumun Swift yetkisi varsa ve alici ulke Swift tablosundaki bir ulke ise; Hesaba Gonderim
SELECT DISTINCT
    tott.new_TransactionTargetOptionId as ID, 
    tott.new_TransactionTargetOptionId, 
    tott.new_TransactionTargetOptionIdName as VALUE, 
    tott.new_TransactionTargetOptionIdName as TransactionTargetOption
FROM nltvNew_TargetOptionTransactionType(@SystemUser) tott
INNER JOIN vNew_TransactionType tt
ON tott.new_TransactionTypeId = tt.New_TransactionTypeId AND tt.DeletionStateCode = 0
WHERE 
tt.new_ExtCode = '003'
/* Swift yetkisi kontrolu */
AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @SwiftGonderim) /* Swift gonderim yetkisi kontrolu */
AND EXISTS(
    SELECT 1 FROM BicBankBranchCumulativeTable bbb
    WHERE bbb.new_CountryID = @RecipientCountryID
)
AND tott.DeletionStateCode = 0

DROP TABLE #CountryPriorCorporation

DROP TABLE #SystemUserOfficeTransactionTypes";

        #endregion

        StaticData sd = new StaticData();
        sd.AddParameter("SystemUser", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));
        sd.AddParameter("RecipientCountryID", DbType.Guid, ValidationHelper.GetGuid(new_RecipientCountryID.Value));

        BindCombo(new_TransactionTargetOptionID, sd, strSql);
    }

    protected void SourceTransactionTypeLoad(object sender, AjaxEventArgs e)
    {
        const string strSql = @"DECLARE @SystemUserOfficeId UNIQUEIDENTIFIER

SELECT @SystemUserOfficeId = new_OfficeID FROM vSystemUser
WHERE SystemUserId = @SystemUserId AND DeletionStateCode = 0

SELECT DISTINCT new_TransactionTypeID AS ID, new_TransactionTypeID, new_TransactionTypeIDName AS VALUE, new_TransactionTypeIDName
FROM tvNew_OfficeTransactionType(@SystemUserId)
WHERE new_OfficeID = @SystemUserOfficeId
AND new_TransactionTypeID IN
(
	SELECT DISTINCT tt.New_TransactionTypeId FROM vNew_TransactionType tt
	INNER JOIN vNew_TransactionItem ti
	ON tt.new_TransactionItemID = ti.New_TransactionItemId AND ti.DeletionStateCode = 0
	WHERE ti.new_ExtCode = '001' AND tt.DeletionStateCode = 0
)
AND DeletionStateCode = 0";

        StaticData sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));

        BindCombo(new_SourceTransactionTypeID, sd, strSql);
    }

    DataTable GetSourceTransactionType()
    {
        const string strSql = @"DECLARE @SystemUserOfficeId UNIQUEIDENTIFIER

SELECT @SystemUserOfficeId = new_OfficeID FROM vSystemUser
WHERE SystemUserId = @SystemUserId AND DeletionStateCode = 0

SELECT DISTINCT new_TransactionTypeID AS ID, new_TransactionTypeID, new_TransactionTypeIDName AS VALUE, new_TransactionTypeIDName
FROM tvNew_OfficeTransactionType(@SystemUserId)
WHERE new_OfficeID = @SystemUserOfficeId
AND new_TransactionTypeID IN
(
	SELECT DISTINCT tt.New_TransactionTypeId FROM vNew_TransactionType tt
	INNER JOIN vNew_TransactionItem ti
	ON tt.new_TransactionItemID = ti.New_TransactionItemId AND ti.DeletionStateCode = 0
	WHERE ti.new_ExtCode = '001' AND tt.DeletionStateCode = 0
)
AND DeletionStateCode = 0";

        StaticData sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));

        return sd.ReturnDataset(strSql).Tables[0];
    }

    protected void new_IbanisNotKnownOnEvent(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(new_RecipientCorporationId.Value) && new_RecipientCorporationId.Value != "00000000-0000-0000-0000-000000000001")
        {
            return;
        }

        if (!string.IsNullOrEmpty(new_RecipientCorporationId.Value) && new_RecipientCorporationId.Value == "00000000-0000-0000-0000-000000000001" && !string.IsNullOrEmpty(new_RecipientCorporationIdHidden.Value))
        {
            return;
        }

        isEFTHiddenField.DataBind();
        bool isEft = bool.Parse(isEFTHiddenField.Value);

        if (new_IbanisNotKnown.Checked) //IBAN Yok / Bilinmiyor
        {
            new_RecipientIBAN.SetVisible(false);
            //new_RecipientIBAN.Visible = false;
            new_RecipientIBAN.Clear();
            new_RecipientBicIBAN.SetVisible(false);
            //new_RecipientBicIBAN.Visible = false;
            new_RecipientBicIBAN.Clear();
            if (isEft)
            {
                new_EftBank.SetVisible(true);
                new_EftCity.SetVisible(true);
                new_EftBranch.SetVisible(true);
                new_EftPaymentMethodID.SetVisible(true);

                new_BicBank.SetVisible(false);
                new_BicBankCity.SetVisible(false);
                new_BicBankBranch.SetVisible(false);
                new_BicCode.SetVisible(false);

                new_EftBank.SetRequirementLevel(RLevel.BusinessRequired);
                new_EftCity.SetRequirementLevel(RLevel.BusinessRequired);
                new_EftPaymentMethodID.SetRequirementLevel(RLevel.BusinessRequired);
                new_EftBranch.SetRequirementLevel(RLevel.BusinessRequired);

                new_RecipientAccountNumber.SetVisible(true);
                new_RecipientAccountNumber.SetRequirementLevel(RLevel.BusinessRequired);
                new_RecipientBicAccountNumber.SetRequirementLevel(RLevel.None);
            }
            else
            {
                new_EftBank.SetVisible(false);
                new_EftCity.SetVisible(false);
                new_EftBranch.SetVisible(false);
                new_EftPaymentMethodID.SetVisible(false);

                new_BicBank.SetVisible(true);
                new_BicBankCity.SetVisible(true);
                //new_BicBankBranch.SetVisible(true);
                new_BicCode.SetVisible(true);

                new_BicBank.SetRequirementLevel(RLevel.BusinessRequired);
                new_BicBankCity.SetRequirementLevel(RLevel.BusinessRequired);
                //new_BicBankBranch.SetRequirementLevel(RLevel.BusinessRequired);
                new_BicCode.SetRequirementLevel(RLevel.BusinessRequired);

                new_RecipientBicAccountNumber.SetVisible(true);
                new_RecipientBicAccountNumber.SetRequirementLevel(RLevel.BusinessRequired);
                new_RecipientAccountNumber.SetRequirementLevel(RLevel.None);
            }

            new_RecipientCardNumber.SetVisible(false);

            new_RecipientIBAN.SetRequirementLevel(RLevel.None);
            new_RecipientBicIBAN.SetRequirementLevel(RLevel.None);
            new_RecipientCardNumber.SetRequirementLevel(RLevel.None);

            //if (sender != null)
            //{
            //    if (isEft)
            //    {
            //        new_EftBank.Clear();
            //        new_EftCity.Clear();
            //        new_EftBranch.Clear();
            //        new_EftPaymentMethodID.Clear();
            //    }
            //    else
            //    {
            //        new_BicBank.Clear();
            //        new_BicBankCity.Clear();
            //        new_BicBankBranch.Clear();
            //        new_BicCode.Clear();
            //    }
            //}
        }
        else //IBAN Biliniyor
        {
            new_RecipientIBAN.SetVisible(isEft);
            new_RecipientBicIBAN.SetVisible(!isEft);
            new_EftBank.SetVisible(false);
            new_EftCity.SetVisible(false);
            new_EftBranch.SetVisible(false);
            new_RecipientCardNumber.SetVisible(false);
            new_RecipientAccountNumber.SetVisible(false);
            new_RecipientBicAccountNumber.SetVisible(false);
            new_EftPaymentMethodID.SetVisible(isEft);


            new_BicBank.SetVisible(!isEft);
            new_BicBankCity.SetVisible(false);
            new_BicBankBranch.SetVisible(false);
            new_BicCode.SetVisible(!isEft);

            new_RecipientIBAN.SetRequirementLevel(RLevel.BusinessRequired);
            new_RecipientBicIBAN.SetRequirementLevel(RLevel.BusinessRequired);
            new_EftBank.SetRequirementLevel(RLevel.None);
            new_EftCity.SetRequirementLevel(RLevel.None);
            new_EftBranch.SetRequirementLevel(RLevel.None);
            new_EftPaymentMethodID.SetRequirementLevel(RLevel.BusinessRequired);

            new_RecipientCardNumber.SetRequirementLevel(RLevel.None);
            new_RecipientAccountNumber.SetRequirementLevel(RLevel.None);
            new_RecipientBicAccountNumber.SetRequirementLevel(RLevel.None);

            new_BicBank.SetRequirementLevel(RLevel.BusinessRecommend);
            new_BicCode.SetRequirementLevel(RLevel.BusinessRecommend);

            //if (sender != null)
            //{
            //    new_EftBank.Clear();
            //    new_EftCity.Clear();
            //    new_EftBranch.Clear();
            //    new_EftPaymentMethodID.Clear();
            //}
        }
    }

    protected void new_AmountCurrencyOnEvent(object sender, AjaxEventArgs e)
    {
        new_Amount.Items[0].Clear();
        new_Amount.Items[1].Clear();
        new_CalculatedExpenseAmount.Items[0].Clear();
        new_CalculatedExpenseAmount.Items[1].Clear();
        new_ReceivedAmount1.Items[0].Clear();
        new_ReceivedAmount1.Items[1].Clear();
        if (new_ReceivedAmount2.Visible)
            new_ReceivedAmount2.Items[0].Clear();


        new_ReceivedExpenseAmount.Items[0].Clear();
        new_ReceivedExpenseAmount.Items[1].Clear();
        new_TotalReceivedAmount.Items[0].Clear();
        new_TotalReceivedAmount.Items[1].Clear();
        new_ExpenseAmount.Items[0].Clear();
        new_ExpenseAmount.Items[1].Clear();

        new_Amount.Items[1].SetValue(new_AmountCurrency2.Value);
        new_Amount.Items[1].SetDisabled(true);
        new_ReceivedAmount1.Items[0].SetDisabled(true);
        new_ExpenseAmount.Items[0].SetDisabled(true);
        new_ExpenseAmount.Items[1].SetDisabled(true);

        new_RecipientIDChangeOnEvent(null, null);



    }

    bool isNewAmount;


    protected void new_RecipientIBANOnChange(object sender, AjaxEventArgs e)
    {
        if (string.IsNullOrEmpty(ValidationHelper.GetString(new_RecipientIBAN.Value).Trim()))
            return;

        if (ValidationHelper.GetString(new_RecipientIBAN.Value).Trim().Length < 26)
            return;

        string returnMessage = string.Empty;
        string recipientBankCode = string.Empty;
        string recipientBankBranchCode = string.Empty;
        TransferPageFactory tpf = new TransferPageFactory();
        Guid result = tpf.GetEftBankId(ValidationHelper.GetString(new_RecipientIBAN.Value), null, out returnMessage, out recipientBankCode, out recipientBankBranchCode);

        try
        {


            if (result != Guid.Empty)
            {
                new_EftBank.Disabled = true;
                new_EftBank.SetIValue(result);
            }
            else
            {
                new_EftBank.SetIValue(null);
                var msg = returnMessage;
                MessageBox m = new MessageBox();
                m.MessageType = EMessageType.Warning;
                m.Modal = true;
                m.Show(returnMessage);
            }
        }
        catch (TuException)
        {

        }

    }

    protected void new_AmountOnChange(object sender, AjaxEventArgs e)
    {
        var integrationChannel = UPTCache.IntegrationChannelService.GetIntegrationChannelByCorporationId(ValidationHelper.GetGuid(new_RecipientCorporationId.Value));
        if ((integrationChannel != null && !ValidationHelper.GetBoolean(UPTCache.IntegrationChannelService.GetIntegrationChannelByCorporationId(ValidationHelper.GetGuid(new_RecipientCorporationId.Value)).DecimalNumber) || integrationChannel == null))
        {
            try
            {
                /* Bu kontrol bu bloğun içerisinde en üstte olmalı. Try Catch içerisine aldım. 
                 * İşlemler kesilmesin ama çalışmadığında nedeni Sistem hata mesajlarında izlebilir */
                var transactionTypeCode = UPTCache.TransactionTargetOptionService.GetTransactionTargetOptionByTransactionTargetOptionId(ValidationHelper.GetGuid(new_TransactionTargetOptionID.Value)).TransactionTargetOptionCode;
                var senderCountryCode = UPTCache.CountryService.GetCountryByCountryId(App.Params.CurrentUser.CountryId).CountryShortCode;
                var recipientCountryCode = UPTCache.CountryService.GetCountryByCountryId(ValidationHelper.GetGuid(new_RecipientCountryID.Value)).CountryShortCode;

                if (transactionTypeCode == "002" && senderCountryCode == "TR" && recipientCountryCode != "TR")
                {
                    var IsWholeNumner = ValidationHelper.IsWholeNumber(ValidationHelper.GetDouble(new_Amount.d1.Value.Value, 0));
                    if (!IsWholeNumner)
                    {
                        QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_THE_AMOUNT_FIELD_MUST_BE_AN_INTEGER") + "');new_Amount.focus();new_Amount.clear();return;");
                        return;
                    }
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex);
            }
        }

        setUserCostReductionRate();
        CorporationCountryFormParameterForDisplayControl();
        ReConfigureScreen2();
        GetTransferOutherCalculateScript(sender, e);

        if (((Coretech.Crm.Web.UI.RefleX.AutoGenerate.CrmDecimalComp)sender).UniqueName != "new_Amount")
        {
            isNewAmount = false;
            sender = this.new_Amount.d1;
        }
        else
        {
            isNewAmount = true;
            //new_CalculatedExpenseAmountDefaultValue.SetIValue(null);
            rebuildExpenseProcess();
        }
        //else if (((Coretech.Crm.Web.UI.RefleX.AutoGenerate.CrmDecimalComp)sender).UniqueName == "new_Amount") new_CalculatedExpenseAmountDefaultValue.SetValue("0");

        if (new_ReceivedAmount1.c1.Value == string.Empty)
        {
            new_ReceivedAmount1.c1.Value = GetDefaultReceivedAmount1Currency();
            if (_IsPartlyCollection)
            {
                if (new_ReceivedAmount1.c1.Value == _CountryCurrencyID)
                {
                    new_CollectionMethod.Value = TransferCollectionMethodEnum.Single.GetHashCode().ToString();
                    new_CollectionMethod.SetValue(TransferCollectionMethodEnum.Single.GetHashCode().ToString());
                }
                else
                {
                    new_CollectionMethod.SetValue(TransferCollectionMethodEnum.Multiple.GetHashCode().ToString());
                    new_CollectionMethod.Value = TransferCollectionMethodEnum.Multiple.GetHashCode().ToString();
                }
                new_CollectionMethodOnChange(sender, e);
            }
        }
        //+		sender	{Coretech.Crm.Web.UI.RefleX.AutoGenerate.CrmDecimalComp}	object {Coretech.Crm.Web.UI.RefleX.AutoGenerate.CrmDecimalComp}


        if (ValidationHelper.GetInteger(new_CollectionMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        {
            new_CollectionMethodOnChange(sender, e);
            //CalculateOnEvent(sender, e);
        }
        else
        {
            CalculateOnEvent(sender, e);
        }

        SelectedIdentificationCardType(new_SenderIdentificationCardTypeID);


        //Kredi Ödeme Planı ekranından gelmesi durumu:
        if (QueryHelper.GetString("fromCheckCredit") == "1")
        {
            CreditDisableAmountFields();
        }

    }

    private void CreditDisableAmountFields()
    {
        new_CalculatedExpenseAmount.Items[0].SetDisabled(true);
        new_CalculatedExpenseAmount.Items[1].SetDisabled(true);
        new_ReceivedPaymentAmount.Items[0].SetDisabled(true);
        new_ReceivedPaymentAmount.Items[1].SetDisabled(true);
        new_ReceivedExpenseAmount.Items[0].SetDisabled(true);
        new_ReceivedExpenseAmount.Items[1].SetDisabled(true);
        new_TotalReceivedAmount.Items[0].SetDisabled(true);
        new_TotalReceivedAmount.Items[1].SetDisabled(true);
        new_ExpenseAmount.Items[0].SetDisabled(true);
        new_ExpenseAmount.Items[1].SetDisabled(true);
        new_CollectionMethod.SetDisabled(true);
        new_ReceivedAmount1.Items[1].SetDisabled(true);
        new_ReceivedAmount2.Items[0].SetDisabled(true);
    }

    private void SelectedIdentificationCardType(CrmComboComp ccc)
    {
        var sd = new StaticData();
        sd.AddParameter("SenderId", DbType.Guid, ValidationHelper.GetGuid(new_SenderID.Value));
        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));
        try
        {
            DataTable dt = sd.ReturnDataset(@"Select s.new_IdendificationCardTypeID,l.Value As new_IdendificationCardTypeIDName from vNew_Sender(nolock) s inner join 
		  New_IdentificatonCardTypeLabel(nolock) l On s.new_IdendificationCardTypeID = l.New_IdentificatonCardTypeId
		  where s.New_SenderId = @SenderId And l.LangId = (SELECT vsu.LanguageId FROM dbo.vSystemUser(nolock) vsu  WHERE vsu.SystemUserId = @SystemUserId AND vsu.DeletionStateCode = 0)").Tables[0];

            if (IsCountryIdentificationType(ValidationHelper.GetGuid(dt.Rows[0]["new_IdendificationCardTypeID"])))
            {
                ccc.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["new_IdendificationCardTypeID"]), dt.Rows[0]["new_IdendificationCardTypeIDName"].ToString());
            }
            else
            {
                ccc.Clear();
            }
        }
        catch
        {
            ccc.SetValue(null, null);
        }
    }

    protected void new_ReceivedAmount1CurrencyOnChange(object sender, AjaxEventArgs e)
    {
        if (_IsPartlyCollection)
        {
            if (((CrmComboComp)new_ReceivedAmount1.Items[1]).Value == _CountryCurrencyID)
            {
                new_CollectionMethod.Value = TransferCollectionMethodEnum.Single.GetHashCode().ToString();
                new_CollectionMethod.SetValue(TransferCollectionMethodEnum.Single.GetHashCode().ToString());
            }
            else
            {

                new_CollectionMethod.SetValue(TransferCollectionMethodEnum.Multiple.GetHashCode().ToString());
                new_CollectionMethod.Value = TransferCollectionMethodEnum.Multiple.GetHashCode().ToString();
            }
            new_CollectionMethodOnChange(sender, e);
        }
        else
        {
            CalculateOnEvent(sender, e);
        }



    }

    private Credit GetCreditInfo(Guid DataID)
    {
        CreditCheckFactory ccf = new CreditCheckFactory();
        return ccf.GetCreditPayInfo(DataID);
    }

    protected void new_RecipienNickNameOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            string bank;
            string cur;
            if (e != null)
            {
                bank = e.ExtraParams["BankName"];
                cur = e.ExtraParams["Currency"];
            }
            var middleName = string.IsNullOrEmpty(new_RecipientMiddleName.Value) ? "" : new_RecipientMiddleName.Value + " ";

            if (TransferType.IsmeGonderim == new_TransactionTargetOptionID.Value)
                new_RecipienNickName.SetValue(new_RecipientName.Value + " " + middleName + new_RecipientLastName.Value);

            if (TransferType.HesabaGonderim == new_TransactionTargetOptionID.Value || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
            {
                new_RecipienNickName.SetValue(new_RecipientName.Value + " " + middleName + new_RecipientLastName.Value);
                new_RecipientAccountName.SetValue(new_RecipientName.Value + " " + middleName + new_RecipientLastName.Value);
            }

            if (TransferType.KartaGonderim == new_TransactionTargetOptionID.Value)
                new_RecipienNickName.SetValue(new_RecipientName.Value + " " + middleName + new_RecipientLastName.Value);

            /*
            if (TransferType.HesabaGonderim == new_TransactionTargetOptionID.Value)
                new_RecipienNickName.SetValue(new_RecipientName.Value + " " + new_RecipientLastName.Value + " " + bank + " " + cur);

            if (TransferType.KartaGonderim == new_TransactionTargetOptionID.Value)
                new_RecipienNickName.SetValue(new_RecipientName.Value + " " + new_RecipientLastName.Value + " " + bank + " " + cur);
            */
        }
        catch (Exception ex)
        {
            e.Message = ex.Message;
            e.Success = false;
        }
    }

    protected void new_CollectionMethodOnChange(object sender, AjaxEventArgs e)
    {
        ReconfigureByCollectionMethod();
        if (ValidationHelper.GetInteger(new_CollectionMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        {
            new_ReceivedAmount1.Items[0].Clear();
            new_ReceivedAmount1.d1.Value = 0;
            if (new_ReceivedAmount2.Visible)
            {
                new_ReceivedAmount2.Items[0].Clear();
                new_ReceivedAmount2.d1.Value = 0;
            }
        }
        else
        {
            new_ReceivedAmount1.Items[0].Clear();
            if (new_ReceivedAmount2.Visible)
                new_ReceivedAmount2.Items[0].Clear();
        }

        CalculateOnEvent(sender, e);

    }

    void SetReceiverInformationPanelVisibility(bool b)
    {
        ColumnLayout7.SetVisible(b);
        ColumnLayout8.SetVisible(b);
        ColumnLayout9.SetVisible(b);
    }

    protected void new_RecipientIDChangeOnEvent(object sender, AjaxEventArgs e)
    {
        UPT.Shared.CacheProvider.Model.Country rCountry = UPTCache.CountryService.GetCountryByCountryId(ValidationHelper.GetGuid(new_RecipientCountryID.Value));

        if (rCountry != null && rCountry.CountryShortCode == "DE")
        {
            QScript(" document.getElementById('___new_RecipientGSM').maxLength = 8;");
        }
        else
        {
            QScript(" document.getElementById('___new_RecipientGSM').maxLength = 7;");
        }

        HideRegionalControls();
        HideRequiredFieldsByCountry();
        var sd = new StaticData();

        sd = new StaticData();
        sd.ClearParameters();
        sd.AddParameter("@New_CountryId", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCountryID.Value));

        bool isUsedSecurityQuestion = false;
        bool isIBANMandatoryForSwift = false;
        bool isSwift = false;

        DataSet ds = sd.ReturnDataset(@"select new_IsUsedSecurityQuestion, new_IsIBANMandatoryForSwift from vNew_Country(nolock)
where DeletionStateCode = 0 and New_CountryId = @New_CountryId");
        if (ds.Tables[0].Rows.Count > 0)
        {
            isUsedSecurityQuestion = ValidationHelper.GetBoolean(ds.Tables[0].Rows[0]["new_IsUsedSecurityQuestion"]);
            isIBANMandatoryForSwift = ValidationHelper.GetBoolean(ds.Tables[0].Rows[0]["new_IsIBANMandatoryForSwift"]);
        }
        _isIBANMandatoryForSwift = isIBANMandatoryForSwift;

        if (isUsedSecurityQuestion)
        {
            new_TestQuestionID.SetVisible(true);
            new_TestQuestionReply.SetVisible(true);
        }
        else
        {
            new_TestQuestionID.SetVisible(false);
            new_TestQuestionReply.SetVisible(false);
        }

        ClearRequirementLevel();

        //sd.AddParameter("TransactionTargetOptionID", DbType.Guid, ValidationHelper.GetGuid(new_TransactionTargetOptionID.Value));
        //sd.AddParameter("EftBankId", DbType.Guid, DBNull.Value);
        //var tttID = sd.ExecuteScalar("select dbo.fnTUGetTargetTransactionType(@TransactionTargetOptionID,@EftBankId)").ToString();
        //if (!string.IsNullOrEmpty(tttID))
        //    new_TargetTransactionTypeID.SetValue(tttID);
        //else
        //    new_TargetTransactionTypeID.Clear();

        new_TargetTransactionTypeID.Clear();
        Guid transactionType = Guid.Empty;

        isEFTHiddenField.SetValue("false");
        SetReceiverInformationPanelVisibility(false);

        new_IbanisNotKnown.SetDisabled(false);

        if (new_TransactionTargetOptionID.Value == TransferType.IsmeGonderim) //İsme
        {
            SetReceiverInformationPanelVisibility(true);

            //new_EftBank.Visible = false;
            new_EftBank.SetVisible(false);
            new_Explanation.SetVisible(true);
            new_EftCity.SetVisible(false);
            new_EftBranch.SetVisible(false);
            new_RecipientCardNumber.SetVisible(false);
            new_RecipientAccountNumber.SetVisible(false);
            new_RecipientBicAccountNumber.SetVisible(false);
            new_IbanisNotKnown.SetVisible(false);
            new_RecipientIBAN.SetVisible(false);
            //new_RecipientIBAN.Visible = false;
            new_RecipientIBAN.Clear();
            new_RecipientBicIBAN.SetVisible(false);
            //new_RecipientBicIBAN.Visible = false;
            new_RecipientBicIBAN.Clear();
            new_EftPaymentMethodID.SetVisible(false);
            new_BicBank.SetVisible(false);
            new_BicBankCity.SetVisible(false);
            new_BicBankBranch.SetVisible(false);
            new_BicCode.SetVisible(false);
            new_CorpSendAccountNumber.SetVisible(false);
            new_CorpSendAccountNumber.SetRequirementLevel(RLevel.None);
            new_RecipientMotherName.SetRequirementLevel(RLevel.BusinessRecommend);
            new_RecipientFatherName.SetRequirementLevel(RLevel.BusinessRecommend);

            ClearRequirementLevel();

            transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='001'"));
            new_TargetTransactionTypeID.SetValue(transactionType);
        }

        if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi) //Hesaba
        {
            var df = new DynamicFactory(ERunInUser.CalingUser);
            var de = df.RetrieveWithOutPlugin((int)TuEntityEnum.New_Country, ValidationHelper.GetGuid(new_RecipientCountryID.Value), new string[] { "new_CountryShortCode" });
            string countryShortCode = de.GetStringValue("new_CountryShortCode");

            SetReceiverInformationPanelVisibility(new_AmountCurrency2.Value != string.Empty || countryShortCode != "TR");

            new_RecipientCardNumber.SetVisible(false);
            new_IbanisNotKnown.SetVisible(true);

            new_RecipientMotherName.SetRequirementLevel(RLevel.None);
            new_RecipientFatherName.SetRequirementLevel(RLevel.None);

            if (new_RecipientCorporationId.Value != null && new_RecipientCorporationId.Value != string.Empty && new_RecipientCorporationId.Value != "00000000-0000-0000-0000-000000000001")
            {
                isEFTHiddenField.SetValue("false");
                isEFTHiddenField.Value = "false";

                //new_EftBank.Visible = false;
                new_EftBank.SetVisible(false);

                new_EftCity.SetVisible(false);
                new_EftBranch.SetVisible(false);
                new_EftPaymentMethodID.SetVisible(false);
                new_BicBank.SetVisible(false);
                new_BicBankCity.SetVisible(false);
                new_BicBankBranch.SetVisible(false);
                new_BicCode.SetVisible(false);
                new_RecipientBicIBAN.SetVisible(false);
                //new_RecipientBicIBAN.Visible = false;
                new_RecipientBicIBAN.Clear();
                new_RecipientAccountNumber.SetVisible(false);
                new_RecipientBicAccountNumber.SetVisible(false);
                new_IbanisNotKnown.SetVisible(false);
                new_RecipientIBAN.SetVisible(false);
                //new_RecipientIBAN.Visible = false;
                new_RecipientIBAN.Clear();
                new_CorpSendAccountNumber.SetVisible(true);
                new_CorpSendAccountNumber.SetRequirementLevel(RLevel.BusinessRequired);

                if (new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
                    transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='021'"));//AktifBank Ödemesi
                else
                    transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='011'"));
                new_TargetTransactionTypeID.SetValue(transactionType);
            }
            else if (!string.IsNullOrEmpty(new_RecipientCorporationId.Value) && new_RecipientCorporationId.Value == "00000000-0000-0000-0000-000000000001" && !string.IsNullOrEmpty(new_RecipientCorporationIdHidden.Value))
            {
                isEFTHiddenField.SetValue("false");
                isEFTHiddenField.Value = "false";
                isSwift = false;
                new_Explanation.SetVisible(false);

                SetRequiredFieldsByCountry();

                //Gereksiz alanlar
                new_RecipientIBAN.SetVisible(false);
                //new_RecipientIBAN.Visible = false;
                new_RecipientIBAN.Clear();
                new_RecipientIBAN.SetRequirementLevel(RLevel.None);
                new_RecipientGSMCountryId.SetVisible(true);
                new_RecipientGSMCountryId.SetRequirementLevel(RLevel.BusinessRequired);
                new_CorpSendAccountNumber.SetVisible(false);
                new_CorpSendAccountNumber.SetRequirementLevel(RLevel.None);
                new_RecipientGSM.SetVisible(true);
                new_RecipientGSM.SetRequirementLevel(RLevel.BusinessRequired);
                new_RecipienNickName.SetVisible(false);
                new_RecipienNickName.SetRequirementLevel(RLevel.None);
                new_RecipientEmail.SetVisible(false);
                new_RecipientFatherName.SetVisible(false);
                new_RecipientMotherName.SetVisible(false);

                //new_EftBank.Visible = false;
                new_EftBank.SetVisible(false);

                new_EftCity.SetVisible(false);
                new_EftBranch.SetVisible(false);
                new_RecipientCardNumber.SetVisible(false);
                new_RecipientBicAccountNumber.SetVisible(false);
                new_IbanisNotKnown.SetVisible(false);
                new_EftPaymentMethodID.SetVisible(false);
                new_BicBankCity.SetVisible(false);
                new_BicBankBranch.SetVisible(false);
                new_CorpSendAccountNumber.SetVisible(false);

                transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='011'"));
                new_TargetTransactionTypeID.SetValue(transactionType);
            }
            else if (countryShortCode == "TR" && new_AmountCurrency2.Value != string.Empty && new_AmountCurrency2.Value == "00000014-4f7b-49ca-bd5d-38534d354185") //EFT
            {
                isEFTHiddenField.SetValue("true");
                isEFTHiddenField.Value = "true";

                //new_EftBank.Visible = true;
                new_EftBank.SetVisible(true);

                new_EftCity.SetVisible(true);
                new_EftBranch.SetVisible(true);
                new_EftPaymentMethodID.SetVisible(true);
                new_BicBank.SetVisible(false);
                new_BicBankCity.SetVisible(false);
                new_BicBankBranch.SetVisible(false);
                new_BicCode.SetVisible(false);
                new_RecipientIBAN.SetVisible(true);
                new_RecipientBicIBAN.SetVisible(false);
                new_RecipientAccountNumber.SetVisible(true);
                new_RecipientBicAccountNumber.SetVisible(false);
                new_CorpSendAccountNumber.SetVisible(false);

                if (new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
                    transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='021'"));//AktifBank Ödemesi
                else
                    transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='002'"));//EFT
                new_TargetTransactionTypeID.SetValue(transactionType);
            }
            else //SWIFT
            {
                isEFTHiddenField.SetValue("false");
                isEFTHiddenField.Value = "false";

                //new_EftBank.Visible = false;
                new_EftBank.SetVisible(false);

                new_EftCity.SetVisible(false);
                new_EftBranch.SetVisible(false);
                new_EftPaymentMethodID.SetVisible(false);
                new_BicBank.SetVisible(true);
                new_BicBankCity.SetVisible(true);
                new_BicBankBranch.SetVisible(true);
                new_BicCode.SetVisible(true);
                new_RecipientIBAN.SetVisible(false);
                //new_RecipientIBAN.Visible = false;
                new_RecipientIBAN.Clear();
                new_RecipientBicIBAN.SetVisible(true);
                //new_RecipientBicIBAN.Visible = false;
                new_RecipientBicIBAN.Clear();
                new_RecipientAccountNumber.SetVisible(false);
                new_RecipientBicAccountNumber.SetVisible(true);
                new_CorpSendAccountNumber.SetVisible(false);

                ////Alici ulke TR ise secilemez, bos gecilir. (KALDIRILDI - 18.09.2013)
                //if (countryShortCode == "TR")
                //{
                //    new_IbanisNotKnown.SetValue(false);
                //    new_IbanisNotKnown.SetDisabled(true);
                //}

                transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='003'"));
                new_TargetTransactionTypeID.SetValue(transactionType);

                isSwift = true;
            }
        }

        if (new_TransactionTargetOptionID.Value == TransferType.KartaGonderim)//KrediKartı
        {
            isEFTHiddenField.SetValue("true");
            isEFTHiddenField.Value = "true";

            SetReceiverInformationPanelVisibility(true);

            new_RecipientIBAN.Clear();
            new_RecipientBicIBAN.Clear();
            //new_EftBank.Visible = true;
            new_EftBank.SetVisible(true);

            new_EftCity.SetVisible(true);
            new_EftBranch.SetVisible(true);
            new_RecipientAccountNumber.SetVisible(false);
            new_RecipientBicAccountNumber.SetVisible(false);
            new_RecipientCardNumber.SetVisible(true);
            new_IbanisNotKnown.SetVisible(false);
            new_RecipientIBAN.SetVisible(false);
            //new_RecipientIBAN.Visible = false;
            new_RecipientIBAN.Clear();
            new_RecipientBicIBAN.SetVisible(false);
            //new_RecipientBicIBAN.Visible = false;
            new_RecipientBicIBAN.Clear();
            new_EftPaymentMethodID.SetVisible(false);
            new_BicBank.SetVisible(false);
            new_BicBankCity.SetVisible(false);
            new_BicBankBranch.SetVisible(false);
            new_BicCode.SetVisible(false);
            new_CorpSendAccountNumber.SetVisible(false);
            new_CorpSendAccountNumber.SetRequirementLevel(RLevel.None);
            new_RecipientIBAN.SetRequirementLevel(RLevel.None);
            new_RecipientBicIBAN.SetRequirementLevel(RLevel.None);
            new_EftBank.SetRequirementLevel(RLevel.BusinessRequired);
            new_EftCity.SetRequirementLevel(RLevel.BusinessRequired);
            new_EftBranch.SetRequirementLevel(RLevel.BusinessRequired);
            new_RecipientCardNumber.SetRequirementLevel(RLevel.BusinessRequired);
            new_RecipientAccountNumber.SetRequirementLevel(RLevel.None);
            new_RecipientBicAccountNumber.SetRequirementLevel(RLevel.None);
            new_EftPaymentMethodID.SetRequirementLevel(RLevel.None);

            new_RecipientMotherName.SetRequirementLevel(RLevel.None);
            new_RecipientFatherName.SetRequirementLevel(RLevel.None);

            transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='002'"));
            new_TargetTransactionTypeID.SetValue(transactionType);
        }

        if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
        {
            new_IbanisNotKnownOnEvent(sender, e);
        }

        if (!string.IsNullOrEmpty(new_RecipientID.Value))
        {
            /*Head Office yetkilisinin altındaki ofislerin kullanıcılarına para gönderebilmesi için geliştirildi.*/

            if (_userApproval.UsersForRecipients)
            {
                var RecipientUser = new_RecipientID.SelectedItems[0];

                if (RecipientUser != null)
                {
                    /*Bu itemda alıcıdan değil systemuser dan veri geliyor, comboda nickName alanına Lastname i setledik, şimd,i çağırırkende ordan çağırıyoruz, kafa karışmasın.*/

                    new_RecipientName.SetValue(RecipientUser["RecipientName"]);
                    new_RecipientMiddleName.SetValue("");
                    new_RecipientLastName.SetValue(RecipientUser["new_NickName"]);
                    new_RecipienNickName.SetValue(RecipientUser["RecipientName"] + " " + RecipientUser["new_NickName"]);

                    new_RecipientName.ReadOnly = true;
                    new_RecipientName.SetReadOnly(true);
                    new_RecipienNickName.ReadOnly = true;
                    new_RecipienNickName.SetReadOnly(true);
                    new_RecipientMiddleName.ReadOnly = true;
                    new_RecipientMiddleName.SetReadOnly(true);
                    new_RecipientLastName.ReadOnly = true;
                    new_RecipientLastName.SetReadOnly(true);
                }


            }
            else
            {
                new_RecipientName.SetReadOnly(false);
                new_RecipientMiddleName.SetReadOnly(false);
                new_RecipientLastName.SetReadOnly(false);
                new_RecipienNickName.SetReadOnly(false);
                new_RecipientMiddleName.ReadOnly = false;
                new_RecipientLastName.ReadOnly = false;
                new_RecipientName.ReadOnly = false;
                new_RecipienNickName.ReadOnly = false;

                var df = new DynamicFactory(ERunInUser.CalingUser);
                var data = df.RetrieveWithOutPlugin(TuEntityEnum.New_Recipient.GetHashCode(),
                                                    ValidationHelper.GetGuid(new_RecipientID.Value),
                                                    DynamicFactory.RetrieveAllColumns);
                List<string> fieldList = new List<string>() { "new_FirstName", "new_MiddleName", "new_LastName", "new_NickName" };
                TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
                data = cryptor.DecryptFieldsInDynamicEntity(fieldList, data);
                new_RecipientName.SetValue(data.GetStringValue("new_FirstName"));
                new_RecipientMiddleName.SetValue(data.GetStringValue("new_MiddleName"));
                new_RecipientLastName.SetValue(data.GetStringValue("new_LastName"));
                new_RecipientMotherName.SetValue(data.GetStringValue("new_MotherName"));
                new_RecipientFatherName.SetValue(data.GetStringValue("new_FatherName"));
                new_RecipientAddress.SetValue(data.GetStringValue("new_Adress"));
                //new_RecipientHomeTelephone.SetValue(data.GetStringValue("new_HomeTelephone"));
                //new_RecipientWorkTelephone.SetValue(data.GetStringValue("new_WorkTelephone"));
                if (data.Properties.Contains("new_GSMCountryId"))
                {
                    new_RecipientGSMCountryId.SetValue(((Lookup)data.Properties["new_GSMCountryId"]).Value.ToString(), ((Lookup)data.Properties["new_GSMCountryId"]).name);
                }
                new_RecipientGSM.SetValue(data.GetStringValue("new_GSM"));
                new_RecipienNickName.SetValue(data.GetStringValue("new_NickName"));
                new_RecipientEmail.SetValue(data.GetStringValue("new_Email"));
                new_RecipientBirthDate.SetValue(data.GetDateTimeValue("new_BirthDate"));

                new_RecipientIBAN.SetValue(new_RecipientIBAN.Visible ? data.GetStringValue("new_IbanNo") : null);
                new_RecipientIBAN.Value = (new_RecipientIBAN.Visible ? data.GetStringValue("new_IbanNo") : null); /* Bu Satırı silmeyiniz. Silerseniz aşağıdaki blok new_RecipientIBANOnChange(null, null) çalışmayacak. */

                new_RecipientBicIBAN.SetValue(new_RecipientBicIBAN.Visible ? data.GetStringValue("new_RecipientBicIBAN") : null);
                new_RecipientAccountNumber.SetValue(new_RecipientAccountNumber.Visible ? data.GetStringValue("new_AccountNumber") : null);
                new_RecipientBicAccountNumber.SetValue(new_RecipientBicAccountNumber.Visible ? data.GetStringValue("new_RecipientBicAccountNumber") : null);
                new_RecipientCardNumber.SetValue(new_RecipientCardNumber.Visible ? data.GetStringValue("new_RecipientCardNumber") : null);
                new_EftBank.SetValue(new_EftBank.Visible ? data.GetLookupValue("new_EftBank") : Guid.Empty);
                new_EftCity.SetValue(new_EftCity.Visible ? data.GetLookupValue("new_EftCity") : Guid.Empty);
                new_EftBranch.SetValue(new_EftBranch.Visible ? data.GetLookupValue("new_EftBranch") : Guid.Empty);
                new_EftPaymentMethodID.SetValue(new_EftPaymentMethodID.Visible ? data.GetLookupValue("new_EftPaymentMethodID") : Guid.Empty);
                new_BicCode.SetValue(new_BicCode.Visible ? data.GetStringValue("new_BicCode") : null);

                SetBankUIFieldsByBankBranchId(data.GetLookupValue("new_BicBankBranch"));

                if (!String.IsNullOrEmpty(new_RecipientIBAN.Value) && (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi))
                {
                    //if (data.GetLookupValue("new_EftBank") != Guid.Empty || data.GetLookupValue("new_EftBank") != null)
                    //{
                    new_RecipientIBANOnChange(null, null);
                    //}
                }

                if ((new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi) && !isIBANMandatoryForSwift)
                {
                    if (!string.IsNullOrEmpty(new_RecipientCorporationId.Value) && new_RecipientCorporationId.Value == "00000000-0000-0000-0000-000000000001" && !string.IsNullOrEmpty(new_RecipientCorporationIdHidden.Value))
                    {
                        new_IbanisNotKnown.SetValue(false);
                        new_IbanisNotKnown.Checked = false;
                    }
                    else
                    {
                        bool isEFT = Convert.ToBoolean(isEFTHiddenField.Value);
                        if (isEFT)
                        {
                            if (string.IsNullOrEmpty(data.GetStringValue("new_IbanNo")))
                            {
                                new_IbanisNotKnown.SetValue(true);
                                new_IbanisNotKnown.Checked = true;
                                new_IbanisNotKnownOnEvent(sender, e);
                            }
                        }
                        else
                        {
                            if (string.IsNullOrEmpty(data.GetStringValue("new_RecipientBicIBAN")))
                            {
                                new_IbanisNotKnown.SetValue(true);
                                new_IbanisNotKnown.Checked = true;
                                new_IbanisNotKnownOnEvent(sender, e);
                            }
                        }
                    }
                }
            }
        }
        else
        {
            if (!string.IsNullOrEmpty(New_TransferId.Value))
            {
                if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
                    new_IbanisNotKnownOnEvent(sender, e);
            }

            if (!string.IsNullOrEmpty(New_TransferId.Value) && string.IsNullOrEmpty(new_RecipientID.Value))
            {
                new_IbanisNotKnown.Checked = false;
                new_EftBranch.Clear();
                new_EftCity.Clear();
                new_EftBank.Clear();
                new_EftPaymentMethodID.Clear();
                new_BicBank.Clear();
                new_BicBankCity.Clear();
                new_BicBankBranch.Clear();
                new_BicCode.Clear();
                new_RecipientAccountNumber.Clear();
                new_RecipientBicAccountNumber.Clear();
                new_RecipientCardNumber.Clear();
                new_IbanisNotKnown.Clear();
                new_RecipientIBAN.Clear();
                new_RecipientBicIBAN.Clear();
                new_RecipientName.Clear();
                new_RecipientMiddleName.Clear();
                new_RecipientLastName.Clear();
                new_RecipientMotherName.Clear();
                new_RecipientFatherName.Clear();
                new_RecipientAddress.Clear();
                //new_RecipientHomeTelephone.Clear();
                //new_RecipientWorkTelephone.Clear();
                new_RecipientGSMCountryId.Clear();
                new_RecipientGSM.Clear();
                new_RecipienNickName.Clear();
                new_RecipientEmail.Clear();
                new_RecipientBirthDate.Clear();

                if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
                    new_IbanisNotKnownOnEvent(sender, e);
            }

            if (string.IsNullOrEmpty(New_TransferId.Value))
            {
                new_IbanisNotKnown.Checked = false;
                new_EftBranch.Clear();
                new_EftCity.Clear();
                new_EftBank.Clear();
                new_EftPaymentMethodID.Clear();
                new_BicBank.Clear();
                new_BicBankCity.Clear();
                new_BicBankBranch.Clear();
                new_BicCode.Clear();
                new_RecipientAccountNumber.Clear();
                new_RecipientBicAccountNumber.Clear();
                new_RecipientCardNumber.Clear();
                new_IbanisNotKnown.Clear();
                new_RecipientIBAN.Clear();
                new_RecipientBicIBAN.Clear();
                new_RecipientName.Clear();
                new_RecipientMiddleName.Clear();
                new_RecipientLastName.Clear();
                new_RecipientMotherName.Clear();
                new_RecipientFatherName.Clear();
                new_RecipientAddress.Clear();
                //new_RecipientHomeTelephone.Clear();
                //new_RecipientWorkTelephone.Clear(); 
                new_RecipientGSMCountryId.Clear();
                new_RecipientGSM.Clear();
                new_RecipienNickName.Clear();
                new_RecipientEmail.Clear();
                //new_RecipientCorporationId.Clear();

                if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
                    new_IbanisNotKnownOnEvent(sender, e);
            }
        }

        //Ulkede swift icin IBAN zorunlu ise, IBAN bilinmiyor kutusu secilemez olacak.
        if (isIBANMandatoryForSwift && isSwift)
        {
            new_IbanisNotKnown.SetValue(false);
            new_IbanisNotKnown.SetDisabled(true);
            new_IbanisNotKnownOnEvent(null, null);
        }



        if (sender != null && !sender.Equals(new_RecipientID))
        {
            // burada sender bilgileri clear edilecek
            new_SenderID.Clear();
            new_SenderIdentificationCardNo.Clear();
            new_SenderIdentificationCardTypeID.Clear();

            // aşağıdaki scriptle gönderici bilgileri frame'ini temizleriz
            QScript("document.getElementById('Frame_Panel_SenderInformation').contentWindow.ToolbarButtonClear_Clear();");
        }

        if (_userApproval.UsersForRecipients)
        {
            new_RecipientName.SetDisabled(true);
            new_RecipienNickName.SetDisabled(true);
            new_RecipientMiddleName.SetDisabled(true);
            new_RecipientLastName.SetDisabled(true);


        }
        else
        {
            new_RecipientName.SetDisabled(false);
            new_RecipienNickName.SetDisabled(false);
            new_RecipientMiddleName.SetDisabled(false);
            new_RecipientLastName.SetDisabled(false);
        }

    }
    protected void SourceTransactionTypeIDOnEvent(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(new_SourceTransactionTypeID.Value))
        {
            //Panel_SenderInformation.AutoLoad.Url = "TransferSenderFind.aspx?SourceTransactionTypeID=";
            //Panel_SenderInformation.AutoLoad.Url = Panel_SenderInformation.AutoLoad.Url + new_SourceTransactionTypeID.Value;
            var query = new Dictionary<string, string>
            {
                {"SourceTransactionTypeID", new_SourceTransactionTypeID.Value},
                {"fromCheckCredit",QueryHelper.GetString("fromCheckCredit")},
                {"senderID",QueryHelper.GetString("senderID")}
            };
            Panel_SenderInformation.AutoLoad.Url = "TransferSenderFind.aspx" + QueryHelper.RefreshUrl(query);
            Panel_SenderInformation.LoadUrl(Panel_SenderInformation.AutoLoad.Url);
        }

        if (GetTransactionTypeCode(ValidationHelper.GetGuid(new_SourceTransactionTypeID.Value)) == "013")
        {
            new_CustAccountId.Show();
            new_SenderPersonId.Show();
            BtnSenderPersonInfo.Show();
        }
        else
        {
            new_CustAccountId.Clear();
            new_CustAccountId.Hide();
            new_SenderPersonId.Clear();
            new_SenderPersonId.Hide();
            BtnSenderPersonInfo.Hide();
        }
    }

    private string GetTransactionTypeCode(Guid sourceTransactionTypeId)
    {
        string result = string.Empty;
        StaticData sd = new StaticData();
        DataTable dt = new DataTable();

        try
        {
            sd.AddParameter("sourceTransactionTypeId", DbType.Guid, sourceTransactionTypeId);
            dt = sd.ReturnDataset(@"Select new_ExtCode from vNew_TransactionType(NoLock)
WHere New_TransactionTypeId = @sourceTransactionTypeId And DeletionStateCode = 0").Tables[0];
            if (dt.Rows.Count > 0)
            {
                result = ValidationHelper.GetString(dt.Rows[0]["new_ExtCode"]);
            }
        }
        catch (Exception)
        {
            result = string.Empty;
        }

        return result;
    }

    private DataTable GetCountryPriorCorporation(string new_RecipientCountryID, string new_TransactionTargetOptionID, Guid SystemUserId)
    {
        var sd = new StaticData();
        sd.AddParameter("CountryId", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCountryID));
        sd.AddParameter("TransactionTargetOptionId", DbType.Guid, ValidationHelper.GetDBGuid(new_TransactionTargetOptionID));
        sd.AddParameter("SystemUserId", DbType.Guid, SystemUserId);

        DataTable dt = sd.ReturnDataset(@"
                            DECLARE @SenderCorporationId UNIQUEIDENTIFIER = NULL

                            SELECT 
	                            @SenderCorporationId = o.new_CorporationID
                            FROM vSystemUser u
                            INNER JOIN vNew_Office o
                            ON u.new_OfficeID = o.New_OfficeId AND o.DeletionStateCode = 0
                            WHERE u.SystemUserId = @SystemUserId

                            IF EXISTS(
	                            SELECT 1
	                            FROM vNew_CountryPriorCorporation cpc
	                            WHERE new_CountryId=@CountryId 
	                            AND new_TransactionTargetOptionId = @TransactionTargetOptionId
	                            AND new_SenderCorporationId = @SenderCorporationId
	                            AND cpc.DeletionStateCode=0
                            )
                            BEGIN
	                            SELECT TOP 1
	                            new_CorporationId,
	                            new_CorporationIdName
	                            FROM vNew_CountryPriorCorporation cpc
	                            WHERE new_CountryId=@CountryId 
	                            AND new_TransactionTargetOptionId = @TransactionTargetOptionId
	                            AND new_SenderCorporationId = @SenderCorporationId
	                            AND cpc.DeletionStateCode=0
                            END
                            ELSE
                            BEGIN
	                            SELECT TOP 1
	                            new_CorporationId,
	                            new_CorporationIdName
	                            FROM vNew_CountryPriorCorporation cpc
	                            WHERE new_CountryId=@CountryId 
	                            AND new_TransactionTargetOptionId = @TransactionTargetOptionId
	                            AND new_SenderCorporationId IS NULL
	                            AND cpc.DeletionStateCode=0
                            END").Tables[0];

        return dt;
    }

    private DataTable GetRequiredFieldsByCountry()
    {
        var ret = new DataTable();
        var staticData = new StaticData();
        staticData.AddParameter("RecipientCountryId", DbType.Guid, ValidationHelper.GetGuid(new_RecipientCountryID.Value));

        if (new_RecipientCorporationId.Value != "00000000-0000-0000-0000-000000000001")
        {
            staticData.AddParameter("RecipientCorporationId", DbType.Guid, ValidationHelper.GetGuid(new_RecipientCorporationId.Value));
        }
        else if (new_RecipientCorporationId.Value == "00000000-0000-0000-0000-000000000001" && !string.IsNullOrEmpty(new_RecipientCorporationIdHidden.Value))
        {
            staticData.AddParameter("RecipientCorporationId", DbType.Guid, ValidationHelper.GetGuid(new_RecipientCorporationIdHidden.Value));
        }
        else
        {
            staticData.AddParameter("RecipientCorporationId", DbType.Guid, Guid.Empty);
        }

        if (new_CorporationID.Value != string.Empty)
        {
            staticData.AddParameter("SenderCorporationId", DbType.Guid, ValidationHelper.GetGuid(new_CorporationID.Value));
        }

        staticData.AddParameter("TransactionType", DbType.Int32, 0); // 0 - Gönderim 1 Ödeme
        staticData.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        if (ValidationHelper.GetGuid(new_TransactionTargetOptionID.Value) != null && ValidationHelper.GetGuid(new_TransactionTargetOptionID.Value) != Guid.Empty)
        {
            staticData.AddParameter("TransactionTargetOptionId", DbType.Guid, ValidationHelper.GetGuid(new_TransactionTargetOptionID.Value));
        }


        ret = staticData.ReturnDatasetSp("spGetValidationRules").Tables[0];
        return ret;
    }

    private void HideRequiredFieldsByCountry()
    {
        new_RecipientAccountName.SetVisible(false);
        new_BicBank.SetVisible(false);
        new_RecipientAccountNumber.SetVisible(false);
        new_RecipientAccountType.SetVisible(false);
        new_RecipientBicIBAN.SetVisible(false);
        //new_RecipientBicIBAN.Visible = false;
        new_RecipientBicIBAN.Clear();
        new_BicCode.SetVisible(false);
        new_RecipientABACode.SetVisible(false);
        new_RecipientCity.SetVisible(false);
        new_RecipientSortCode.SetVisible(false);
        //new_Explanation.SetVisible(false);
        new_TransferReasonID.SetVisible(false);
        new_RecipientAddress.SetVisible(false);
        //new_RecipientAddress.Visible = false;
        // TYUPT-2359 - Rusya banka hesabına Contact kurumu ile gönderim yapılabilmesi
        new_IntegrationRecipientType.SetVisible(false);
        new_IntegrationRecipientRussianBicCode.SetVisible(false);
        new_IntegrationRecipientTaxNumber.SetVisible(false);
        new_IntegrationRecipientRegistrationReasonCode.SetVisible(false);
        //
        hdnRecipientAddressVisible.SetValue("false");
    }

    private void SetRequiredFieldsByCountry()
    {
        var ret = GetRequiredFieldsByCountry();

        //new_RecipientAccountName.SetVisible(false);
        //new_BicBank.SetVisible(false);
        //new_RecipientAccountNumber.SetVisible(false);
        //new_RecipientAccountType.SetVisible(false);
        //new_RecipientBicIBAN.SetVisible(false);
        ////new_RecipientBicIBAN.Visible = false;
        //new_RecipientBicIBAN.Clear();
        //new_BicCode.SetVisible(false);
        //new_RecipientABACode.SetVisible(false);
        //new_RecipientCity.SetVisible(false);
        //new_RecipientSortCode.SetVisible(false);
        //new_Explanation.SetVisible(false);

        //new_TransferReasonID.SetVisible(false);
        //new_RecipientAddress.SetVisible(false);
        //new_RecipientAddress.Visible = false;
        //hdnRecipientAddressVisible.SetValue("false");



        foreach (DataRow row in ret.Rows)
        {


            switch (row["UniqueName"].ToString())
            {
                case "RecipientAccountName":
                    new_RecipientAccountName.SetVisible(true);
                    new_RecipientAccountName.SetRequirementLevel(RLevel.BusinessRequired); break;
                case "BicBank.BicBankId":
                case "RecipientBankName":
                    new_BicBank.SetVisible(true);
                    new_BicBank.SetRequirementLevel(RLevel.BusinessRequired); break;
                case "RecipientAccountNumber":
                    new_RecipientAccountNumber.SetVisible(true);
                    new_RecipientAccountNumber.SetRequirementLevel(RLevel.BusinessRequired); break;
                case "RecipientAccountType":
                    new_RecipientAccountType.SetVisible(true);
                    new_RecipientAccountType.SetRequirementLevel(RLevel.BusinessRequired); break;
                case "RecipientBicIban":
                    new_RecipientBicIBAN.SetVisible(true);
                    new_RecipientBicIBAN.SetRequirementLevel(RLevel.BusinessRequired); break;
                case "BicCode":
                    new_BicCode.SetVisible(true);
                    new_BicCode.SetRequirementLevel(RLevel.BusinessRequired); break;
                case "RecipientABACode":
                    new_RecipientABACode.SetVisible(true);
                    new_RecipientABACode.SetRequirementLevel(RLevel.BusinessRequired); break;
                case "RecipientSortCode":
                    new_RecipientSortCode.SetVisible(true);
                    new_RecipientSortCode.SetRequirementLevel(RLevel.BusinessRequired); break;
                case "RecipientAddress":
                    new_RecipientAddress.SetVisible(true);
                    new_RecipientAddress.SetRequirementLevel(RLevel.BusinessRequired);
                    hdnRecipientAddressVisible.SetValue("true"); break;
                case "Explanation":
                    new_Explanation.SetVisible(true);
                    new_Explanation.SetRequirementLevel(RLevel.BusinessRequired); break;
                case "RecipientCity":
                    new_RecipientCity.SetVisible(true);
                    new_RecipientCity.SetRequirementLevel(RLevel.BusinessRequired); break;
                case "TransferReason.TransferReasonId":
                    new_TransferReasonID.SetVisible(true);
                    new_TransferReasonID.SetRequirementLevel(RLevel.BusinessRequired); break;
                // TYUPT - 2359 - Rusya banka hesabına Contact kurumu ile gönderim yapılabilmesi
                case "IntegrationRecipientType":
                    new_IntegrationRecipientType.SetVisible(true);
                    new_IntegrationRecipientType.SetRequirementLevel(RLevel.BusinessRequired);
                    break;
                case "IntegrationRecipientRussianBicCode ":
                    new_IntegrationRecipientRussianBicCode.SetVisible(true);
                    new_IntegrationRecipientRussianBicCode.SetRequirementLevel(RLevel.BusinessRequired);
                    break;
                case "IntegrationRecipientTaxNumber":
                    new_IntegrationRecipientTaxNumber.SetVisible(true);
                    new_IntegrationRecipientTaxNumber.SetRequirementLevel(RLevel.BusinessRequired);
                    break;
                case "IntegrationRecipientRegistrationReasonCode":
                    new_IntegrationRecipientRegistrationReasonCode.SetVisible(true);
                    new_IntegrationRecipientRegistrationReasonCode.SetRequirementLevel(RLevel.BusinessRequired);
                    break;
                //
                default:
                    break;
            }
        }

        //new_RecipientAddress.SetVisible(true);
        //new_RecipientAddress.SetRequirementLevel(RLevel.BusinessRequired);
        //new_RecipientCity.SetVisible(true);
        //new_RecipientCity.SetRequirementLevel(RLevel.BusinessRequired);
    }

    protected void TransactionTargetOptionChange(object sender, AjaxEventArgs e)
    {
        //var sd = new StaticData();

        new_RecipientCorporationId.SetDisabled(false);

        new_RecipientCorporationIdHidden.Clear();
        new_RecipientCorporationIdHidden.Value = string.Empty;


        RecipientCorporationLoad(0, 50);

        DataTable dt = (DataTable)new_RecipientCorporationId.DataSource;
        if (dt.Rows.Count > 0)
        {
            if (new_RecipientCorporationId.TotalCount > 0 && new_RecipientCorporationId.TotalCount == 1) //Eger, tek kurum varsa, o kurumu isaretle ve disabled yap.
            {
                DataTable dtCountryPrior = GetCountryPriorCorporation(new_RecipientCountryID.Value, new_TransactionTargetOptionID.Value, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));  //ValidationHelper.GetGuid(sd.ExecuteScalar("select new_CorporationId from vNew_CountryPriorCorporation where new_CountryId = @RecipientCountryID and new_TransactionTargetOptionId = @TransactionTargetOptionID and DeletionStateCode = 0"));
                if (dtCountryPrior.Rows.Count > 0)
                {
                    new_RecipientCorporationIdHidden.Value = ValidationHelper.GetString(dtCountryPrior.Rows[0]["new_CorporationId"]);
                    new_RecipientCorporationIdHidden.SetIValue(ValidationHelper.GetString(dtCountryPrior.Rows[0]["new_CorporationId"]));
                }

                new_RecipientCorporationId.SetValue(dt.Rows[0]["ID"], dt.Rows[0]["VALUE"]);
                new_RecipientCorporationId.SetDisabled(true);
            }
            else
            {
                //Birden fazla kurum varsa, varsayilan olarak secilen kurum var mi diye bakiliyor. Burada uygun bir kurum varsa o ataniyor.
                DataTable dt2 = GetCountryPriorCorporation(new_RecipientCountryID.Value, new_TransactionTargetOptionID.Value, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));
                if (dt2.Rows.Count > 0)
                {
                    DataRow[] drs = dt.Select("ID = '" + dt2.Rows[0]["new_CorporationId"].ToString() + "'");
                    if (drs.Length > 0)
                    {
                        new_RecipientCorporationId.SetValue(ValidationHelper.GetGuid(dt2.Rows[0]["new_CorporationId"]), ValidationHelper.GetString(dt2.Rows[0]["new_CorporationIdName"]));
                    }
                    else
                    {
                        //Varsayilan olarak atanan kurum yok, UPT Havuzu ya da Diger secenegi var mi diye bakiliyor. Varsa o ataniyor.
                        DataRow[] drs2 = dt.Select("ID = '00000000-0000-0000-0000-000000000001'");
                        if (drs2.Length > 0)
                        {
                            new_RecipientCorporationId.SetValue(drs2[0]["ID"], drs2[0]["VALUE"]);
                        }
                        else
                        {
                            //UPT Havuzu ve Diger secenegi de yoksa ilk oge atanir.
                            new_RecipientCorporationId.SetValue(dt.Rows[0]["ID"], dt.Rows[0]["VALUE"]);
                        }
                    }
                }
                else
                {
                    //Varsayilan olarak atanan kurum yok, UPT Havuzu ya da Diger secenegi var mi diye bakiliyor. Varsa o ataniyor.
                    DataRow[] drs2 = dt.Select("ID = '00000000-0000-0000-0000-000000000001'");
                    if (drs2.Length > 0)
                    {
                        new_RecipientCorporationId.SetValue(drs2[0]["ID"], drs2[0]["VALUE"]);
                    }
                    else
                    {
                        //UPT Havuzu ve Diger secenegi de yoksa ilk oge atanir.
                        new_RecipientCorporationId.SetValue(dt.Rows[0]["ID"], dt.Rows[0]["VALUE"]);
                    }
                }
            }

            RecipientAccountTypeLoad(null, null);
            new_CorporationChangeOnEvent(null, null);
        }

        //showHideEftSwiftObject(sender, e);
    }

    private void showHideEftSwiftObject(object sender, AjaxEventArgs e)
    {
        var sd = new StaticData();
        bool isSwift = false;
        new_TargetTransactionTypeID.Clear();
        Guid transactionType = Guid.Empty;


        sd = new StaticData();
        sd.ClearParameters();
        sd.AddParameter("@New_CountryId", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCountryID.Value));

        bool isUsedSecurityQuestion = false;
        bool isIBANMandatoryForSwift = false;


        DataSet ds = sd.ReturnDataset(@"select new_IsUsedSecurityQuestion, new_IsIBANMandatoryForSwift from vNew_Country(nolock)
where DeletionStateCode = 0 and New_CountryId = @New_CountryId");
        if (ds.Tables[0].Rows.Count > 0)
        {
            isUsedSecurityQuestion = ValidationHelper.GetBoolean(ds.Tables[0].Rows[0]["new_IsUsedSecurityQuestion"]);
            isIBANMandatoryForSwift = ValidationHelper.GetBoolean(ds.Tables[0].Rows[0]["new_IsIBANMandatoryForSwift"]);
        }
        _isIBANMandatoryForSwift = isIBANMandatoryForSwift;

        if (isUsedSecurityQuestion)
        {
            new_TestQuestionID.SetVisible(true);
            new_TestQuestionReply.SetVisible(true);
        }
        else
        {
            new_TestQuestionID.SetVisible(false);
            new_TestQuestionReply.SetVisible(false);
        }

        ClearRequirementLevel();
        HideRequiredFieldsByCountry();

        isEFTHiddenField.SetValue("false");
        SetReceiverInformationPanelVisibility(false);

        new_IbanisNotKnown.SetDisabled(false);

        if (new_TransactionTargetOptionID.Value == TransferType.IsmeGonderim) //İsme
        {
            SetReceiverInformationPanelVisibility(true);
            new_Explanation.SetVisible(true);
            new_EftBank.SetVisible(false);
            new_EftCity.SetVisible(false);
            new_EftBranch.SetVisible(false);
            new_RecipientCardNumber.SetVisible(false);
            new_RecipientAccountNumber.SetVisible(false);
            new_RecipientBicAccountNumber.SetVisible(false);
            new_IbanisNotKnown.SetVisible(false);
            new_RecipientIBAN.SetVisible(false);
            //new_RecipientIBAN.Visible = false;
            new_RecipientIBAN.Clear();
            new_RecipientBicIBAN.SetVisible(false);
            //new_RecipientBicIBAN.Visible = false;
            new_RecipientBicIBAN.Clear();
            new_EftPaymentMethodID.SetVisible(false);
            new_BicBank.SetVisible(false);
            new_BicBankCity.SetVisible(false);
            new_BicBankBranch.SetVisible(false);
            new_BicCode.SetVisible(false);
            new_CorpSendAccountNumber.SetVisible(false);
            new_CorpSendAccountNumber.SetRequirementLevel(RLevel.None);

            new_RecipientMotherName.SetRequirementLevel(RLevel.BusinessRecommend);
            new_RecipientFatherName.SetRequirementLevel(RLevel.BusinessRecommend);

            ClearRequirementLevel();


            transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='001'"));
            new_TargetTransactionTypeID.SetValue(transactionType);
        }
        if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi) //Hesaba veya AktifbankÖdemesi
        {
            var df = new DynamicFactory(ERunInUser.CalingUser);
            var de = df.RetrieveWithOutPlugin((int)TuEntityEnum.New_Country, ValidationHelper.GetGuid(new_RecipientCountryID.Value), new string[] { "new_CountryShortCode" });
            string countryShortCode = de.GetStringValue("new_CountryShortCode");

            SetReceiverInformationPanelVisibility(new_AmountCurrency2.Value != string.Empty || countryShortCode != "TR");

            new_RecipientCardNumber.SetVisible(false);
            new_IbanisNotKnown.SetVisible(true);

            new_RecipientMotherName.SetRequirementLevel(RLevel.None);
            new_RecipientFatherName.SetRequirementLevel(RLevel.None);

            if (!string.IsNullOrEmpty(new_RecipientCorporationId.Value) && new_RecipientCorporationId.Value != "00000000-0000-0000-0000-000000000001")
            {
                isEFTHiddenField.SetValue("false");
                isEFTHiddenField.Value = "false";
                isSwift = false;

                new_EftBank.SetVisible(false);
                new_EftCity.SetVisible(false);
                new_EftBranch.SetVisible(false);
                new_RecipientCardNumber.SetVisible(false);
                new_RecipientAccountNumber.SetVisible(false);
                new_RecipientBicAccountNumber.SetVisible(false);
                new_IbanisNotKnown.SetVisible(false);
                new_RecipientIBAN.SetVisible(false);
                //new_RecipientIBAN.Visible = false;
                new_RecipientIBAN.Clear();
                new_RecipientBicIBAN.SetVisible(false);
                //new_RecipientBicIBAN.Visible = false;
                new_RecipientBicIBAN.Clear();
                new_EftPaymentMethodID.SetVisible(false);
                new_BicBank.SetVisible(false);
                new_BicBankCity.SetVisible(false);
                new_BicBankBranch.SetVisible(false);
                new_BicCode.SetVisible(false);
                new_CorpSendAccountNumber.SetVisible(true);
                new_CorpSendAccountNumber.SetRequirementLevel(RLevel.BusinessRequired);

                transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='011'"));
                new_TargetTransactionTypeID.SetValue(transactionType);
            }
            else if (!string.IsNullOrEmpty(new_RecipientCorporationId.Value) && new_RecipientCorporationId.Value == "00000000-0000-0000-0000-000000000001" && !string.IsNullOrEmpty(new_RecipientCorporationIdHidden.Value))
            {
                isEFTHiddenField.SetValue("false");
                isEFTHiddenField.Value = "false";
                new_IbanisNotKnown.Checked = false;
                isSwift = false;
                new_Explanation.SetVisible(false);

                SetRequiredFieldsByCountry();

                //Gereksiz alanlar
                new_RecipientIBAN.SetVisible(false);
                //new_RecipientIBAN.Visible = false;
                new_RecipientIBAN.Clear();
                new_RecipientIBAN.SetRequirementLevel(RLevel.None);
                new_RecipientGSMCountryId.SetVisible(false);
                new_RecipientGSMCountryId.SetRequirementLevel(RLevel.None);
                new_CorpSendAccountNumber.SetVisible(false);
                new_CorpSendAccountNumber.SetRequirementLevel(RLevel.None);
                new_RecipientGSM.SetVisible(false);
                new_RecipientGSM.SetRequirementLevel(RLevel.None);
                new_RecipienNickName.SetVisible(false);
                new_RecipienNickName.SetRequirementLevel(RLevel.None);
                new_RecipientEmail.SetVisible(false);
                new_RecipientFatherName.SetVisible(false);
                new_RecipientMotherName.SetVisible(false);
                new_EftBank.SetVisible(false);
                new_EftCity.SetVisible(false);
                new_EftBranch.SetVisible(false);
                new_RecipientCardNumber.SetVisible(false);
                new_RecipientBicAccountNumber.SetVisible(false);
                new_IbanisNotKnown.SetVisible(false);
                new_EftPaymentMethodID.SetVisible(false);
                new_BicBankCity.SetVisible(false);
                new_BicBankBranch.SetVisible(false);
                new_CorpSendAccountNumber.SetVisible(false);

                transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='011'"));
                new_TargetTransactionTypeID.SetValue(transactionType);
            }
            else if (countryShortCode == "TR" && new_AmountCurrency2.Value != string.Empty && new_AmountCurrency2.Value == "00000014-4f7b-49ca-bd5d-38534d354185") //EFT
            {
                isEFTHiddenField.SetValue("true");
                isEFTHiddenField.Value = "true";

                new_EftBank.SetVisible(true);
                new_EftCity.SetVisible(true);
                new_EftBranch.SetVisible(true);
                new_EftPaymentMethodID.SetVisible(true);
                new_BicBank.SetVisible(false);
                new_BicBankCity.SetVisible(false);
                new_BicBankBranch.SetVisible(false);
                new_BicCode.SetVisible(false);
                new_RecipientIBAN.SetVisible(true);
                new_RecipientBicIBAN.SetVisible(false);
                new_RecipientAccountNumber.SetVisible(true);
                new_RecipientBicAccountNumber.SetVisible(false);
                new_CorpSendAccountNumber.SetVisible(false);
                new_CorpSendAccountNumber.SetRequirementLevel(RLevel.None);

                if (new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
                    transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='021'"));
                else
                    transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='002'"));
                new_TargetTransactionTypeID.SetValue(transactionType);
            }
            else //SWIFT
            {
                isEFTHiddenField.SetValue("false");
                isEFTHiddenField.Value = "false";

                new_EftBank.SetVisible(false);
                new_EftCity.SetVisible(false);
                new_EftBranch.SetVisible(false);
                new_EftPaymentMethodID.SetVisible(false);
                new_BicBank.SetVisible(true);
                new_BicBankCity.SetVisible(true);
                new_BicBankBranch.SetVisible(true);
                new_BicCode.SetVisible(true);
                new_RecipientIBAN.SetVisible(false);
                //new_RecipientIBAN.Visible = false;
                new_RecipientIBAN.Clear();
                new_RecipientBicIBAN.SetVisible(true);
                //new_RecipientBicIBAN.Visible = false;
                new_RecipientBicIBAN.Clear();
                new_RecipientAccountNumber.SetVisible(false);
                new_RecipientBicAccountNumber.SetVisible(true);
                new_CorpSendAccountNumber.SetVisible(false);
                new_CorpSendAccountNumber.SetRequirementLevel(RLevel.None);

                ////Alici ulke TR ise secilemez, bos gecilir. (KALDIRILDI - 18.09.2013)
                //if (countryShortCode == "TR")
                //{
                //    new_IbanisNotKnown.SetValue(false);
                //    new_IbanisNotKnown.SetDisabled(true);
                //}

                transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='003'"));
                new_TargetTransactionTypeID.SetValue(transactionType);

                isSwift = true;
            }
        }

        if (new_TransactionTargetOptionID.Value == TransferType.KartaGonderim)//KrediKartı
        {
            isEFTHiddenField.SetValue("true");
            isEFTHiddenField.Value = "true";


            SetReceiverInformationPanelVisibility(true);

            new_RecipientIBAN.Clear();
            new_RecipientBicIBAN.Clear();
            new_EftBank.SetVisible(true);
            new_EftCity.SetVisible(true);
            new_EftBranch.SetVisible(true);
            new_RecipientAccountNumber.SetVisible(false);
            new_RecipientBicAccountNumber.SetVisible(false);
            new_RecipientCardNumber.SetVisible(true);
            new_IbanisNotKnown.SetVisible(false);
            new_RecipientIBAN.SetVisible(false);
            //new_RecipientIBAN.Visible = false;
            new_RecipientIBAN.Clear();
            new_RecipientBicIBAN.SetVisible(false);
            //new_RecipientBicIBAN.Visible = false;
            new_RecipientBicIBAN.Clear();
            new_EftPaymentMethodID.SetVisible(false);
            new_BicBank.SetVisible(false);
            new_BicBankCity.SetVisible(false);
            new_BicBankBranch.SetVisible(false);
            new_BicCode.SetVisible(false);
            new_CorpSendAccountNumber.SetVisible(false);
            new_CorpSendAccountNumber.SetRequirementLevel(RLevel.None);

            new_RecipientIBAN.SetRequirementLevel(RLevel.None);
            new_RecipientBicIBAN.SetRequirementLevel(RLevel.None);
            new_EftBank.SetRequirementLevel(RLevel.BusinessRequired);
            new_EftCity.SetRequirementLevel(RLevel.BusinessRequired);
            new_EftBranch.SetRequirementLevel(RLevel.BusinessRequired);
            new_RecipientCardNumber.SetRequirementLevel(RLevel.BusinessRequired);
            new_RecipientAccountNumber.SetRequirementLevel(RLevel.None);
            new_RecipientBicAccountNumber.SetRequirementLevel(RLevel.None);
            new_EftPaymentMethodID.SetRequirementLevel(RLevel.None);

            new_RecipientMotherName.SetRequirementLevel(RLevel.None);
            new_RecipientFatherName.SetRequirementLevel(RLevel.None);

            transactionType = ValidationHelper.GetGuid(sd.ExecuteScalar(@"select New_TransactionTypeId from New_TransactionTypeExtension Where new_ExtCode='002'"));
            new_TargetTransactionTypeID.SetValue(transactionType);
        }

        if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
        {
            new_IbanisNotKnownOnEvent(sender, e);
        }

        if (!string.IsNullOrEmpty(new_RecipientID.Value))
        {
            var df = new DynamicFactory(ERunInUser.CalingUser);
            var data = df.RetrieveWithOutPlugin(TuEntityEnum.New_Recipient.GetHashCode(),
                                                ValidationHelper.GetGuid(new_RecipientID.Value),
                                                DynamicFactory.RetrieveAllColumns);
            List<string> fieldList = new List<string>() { "new_FirstName", "new_MiddleName", "new_LastName" };
            TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
            data = cryptor.DecryptFieldsInDynamicEntity(fieldList, data);
            new_RecipientName.SetValue(data.GetStringValue("new_FirstName"));
            new_RecipientMiddleName.SetValue(data.GetStringValue("new_MiddleName"));
            new_RecipientLastName.SetValue(data.GetStringValue("new_LastName"));
            new_RecipientMotherName.SetValue(data.GetStringValue("new_MotherName"));
            new_RecipientFatherName.SetValue(data.GetStringValue("new_FatherName"));
            new_RecipientAddress.SetValue(data.GetStringValue("new_Adress"));
            //new_RecipientHomeTelephone.SetValue(data.GetStringValue("new_HomeTelephone"));
            //new_RecipientWorkTelephone.SetValue(data.GetStringValue("new_WorkTelephone"));
            if (data.Properties.Contains("new_GSMCountryId"))
            {
                new_RecipientGSMCountryId.SetValue(((Lookup)data.Properties["new_GSMCountryId"]).Value.ToString(), ((Lookup)data.Properties["new_GSMCountryId"]).name);
            }
            new_RecipientGSM.SetValue(data.GetStringValue("new_GSM"));
            new_RecipienNickName.SetValue(data.GetStringValue("new_NickName"));
            new_RecipientEmail.SetValue(data.GetStringValue("new_Email"));
            new_RecipientBirthDate.SetValue(data.GetDateTimeValue("new_BirthDate"));

            //new_RecipientIBAN.SetValue(data.GetStringValue("new_IbanNo"));
            //new_RecipientBicIBAN.SetValue(data.GetStringValue("new_RecipientBicIBAN"));
            //new_RecipientAccountNumber.SetValue(data.GetStringValue("new_AccountNumber"));
            //new_RecipientBicAccountNumber.SetValue(data.GetStringValue("new_RecipientBicAccountNumber"));
            //new_RecipientCardNumber.SetValue(data.GetStringValue("new_RecipientCardNumber"));
            //new_EftBank.SetValue(data.GetLookupValue("new_EftBank"));
            //new_EftCity.SetValue(data.GetLookupValue("new_EftCity"));
            //new_EftBranch.SetValue(data.GetLookupValue("new_EftBranch"));
            //new_EftPaymentMethodID.SetValue(data.GetLookupValue("new_EftPaymentMethodID"));
            //new_BicCode.SetValue(data.GetStringValue("new_BicCode"));

            new_RecipientIBAN.SetValue(new_RecipientIBAN.Visible ? data.GetStringValue("new_IbanNo") : null);
            new_RecipientBicIBAN.SetValue(new_RecipientBicIBAN.Visible ? data.GetStringValue("new_RecipientBicIBAN") : null);
            new_RecipientAccountNumber.SetValue(new_RecipientAccountNumber.Visible ? data.GetStringValue("new_AccountNumber") : null);
            new_RecipientBicAccountNumber.SetValue(new_RecipientBicAccountNumber.Visible ? data.GetStringValue("new_RecipientBicAccountNumber") : null);
            new_RecipientCardNumber.SetValue(new_RecipientCardNumber.Visible ? data.GetStringValue("new_RecipientCardNumber") : null);
            new_EftBank.SetValue(new_EftBank.Visible ? data.GetLookupValue("new_EftBank") : Guid.Empty);
            new_EftCity.SetValue(new_EftCity.Visible ? data.GetLookupValue("new_EftCity") : Guid.Empty);
            new_EftBranch.SetValue(new_EftBranch.Visible ? data.GetLookupValue("new_EftBranch") : Guid.Empty);
            new_EftPaymentMethodID.SetValue(new_EftPaymentMethodID.Visible ? data.GetLookupValue("new_EftPaymentMethodID") : Guid.Empty);
            new_BicCode.SetValue(new_BicCode.Visible ? data.GetStringValue("new_BicCode") : null);

            SetBankUIFieldsByBankBranchId(data.GetLookupValue("new_BicBankBranch"));


            /*
            if(string.IsNullOrEmpty(QueryHelper.GetString("recid"))) // başka bir sayfadan geri tuşuyla açılmamışsa
            {
                
                //SetBankUIFieldsByBicCode(new_BicCode.Value);
            }
            else // başka bir sayfadan geldiyse (geri butonuna basarak mesela)
            { 
                // new_BicBankCity.SetValue(data.GetLookupValue("new_BicBankCity") de text kaybolduğu için aşağıdaki kod eklendi
                new_BicBankCity.SetValue(data.GetLookupValue("new_BicBankCity"), new_BicBankCity.Text);

                // new_BicBank.SetValue(data.GetLookupValue("new_BicBank") de text kaybolduğu için aşağıdaki kod eklendi
                new_BicBank.SetValue(data.GetLookupValue("new_BicBank"), new_BicBank.Text);

                new_BicBankBranch.SetValue(data.GetLookupValue("new_BicBankBranch"));
            }
            */





            if ((new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi) && !isIBANMandatoryForSwift)
            {
                bool isEFT = Convert.ToBoolean(isEFTHiddenField.Value);
                if (isEFT)
                {
                    if (string.IsNullOrEmpty(data.GetStringValue("new_IbanNo")))
                    {
                        new_IbanisNotKnown.SetValue(true);
                        new_IbanisNotKnown.Checked = true;
                        new_IbanisNotKnownOnEvent(sender, e);
                    }
                }
                else
                {
                    if (string.IsNullOrEmpty(data.GetStringValue("new_RecipientBicIBAN")))
                    {
                        new_IbanisNotKnown.SetValue(true);
                        new_IbanisNotKnown.Checked = true;
                        new_IbanisNotKnownOnEvent(sender, e);
                    }
                }
            }

        }
        else
        {
            if (!string.IsNullOrEmpty(New_TransferId.Value))
            {
                if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
                    new_IbanisNotKnownOnEvent(sender, e);
            }

            if (!string.IsNullOrEmpty(New_TransferId.Value) && string.IsNullOrEmpty(new_RecipientID.Value))
            {
                new_IbanisNotKnown.Checked = false;
                new_EftBranch.Clear();
                new_EftCity.Clear();
                new_EftBank.Clear();
                new_EftPaymentMethodID.Clear();
                new_BicBank.Clear();
                new_BicBankCity.Clear();
                new_BicBankBranch.Clear();
                new_BicCode.Clear();
                new_RecipientAccountNumber.Clear();
                new_RecipientBicAccountNumber.Clear();
                new_RecipientCardNumber.Clear();
                new_IbanisNotKnown.Clear();
                new_RecipientIBAN.Clear();
                new_RecipientBicIBAN.Clear();
                new_RecipientName.Clear();
                new_RecipientMiddleName.Clear();
                new_RecipientLastName.Clear();
                new_RecipientMotherName.Clear();
                new_RecipientFatherName.Clear();
                new_RecipientAddress.Clear();
                //new_RecipientHomeTelephone.Clear();
                //new_RecipientWorkTelephone.Clear();
                new_RecipientGSMCountryId.Clear();
                new_RecipientGSM.Clear();
                new_RecipienNickName.Clear();
                new_RecipientEmail.Clear();
                new_RecipientBirthDate.Clear();

                if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
                    new_IbanisNotKnownOnEvent(sender, e);
            }

            if (string.IsNullOrEmpty(New_TransferId.Value))
            {
                new_IbanisNotKnown.Checked = false;
                new_EftBranch.Clear();
                new_EftCity.Clear();
                new_EftBank.Clear();
                new_EftPaymentMethodID.Clear();
                new_BicBank.Clear();
                new_BicBankCity.Clear();
                new_BicBankBranch.Clear();
                new_BicCode.Clear();
                new_RecipientAccountNumber.Clear();
                new_RecipientBicAccountNumber.Clear();
                new_RecipientCardNumber.Clear();
                new_IbanisNotKnown.Clear();
                new_RecipientIBAN.Clear();
                new_RecipientBicIBAN.Clear();
                new_RecipientName.Clear();
                new_RecipientMiddleName.Clear();
                new_RecipientLastName.Clear();
                new_RecipientMotherName.Clear();
                new_RecipientFatherName.Clear();
                new_RecipientAddress.Clear();
                //new_RecipientHomeTelephone.Clear();
                //new_RecipientWorkTelephone.Clear(); 
                new_RecipientGSMCountryId.Clear();
                new_RecipientGSM.Clear();
                new_RecipienNickName.Clear();
                new_RecipientEmail.Clear();
                //new_RecipientCorporationId.Clear();

                if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
                    new_IbanisNotKnownOnEvent(sender, e);
            }
        }

        //Ulkede swift icin IBAN zorunlu ise, IBAN bilinmiyor kutusu secilemez olacak.
        if (isIBANMandatoryForSwift && isSwift)
        {
            new_IbanisNotKnown.SetValue(false);
            new_IbanisNotKnown.SetDisabled(true);
            new_IbanisNotKnownOnEvent(null, null);
        }



        if (sender != null && !sender.Equals(new_RecipientID))
        {
            // burada sender bilgileri clear edilecek
            new_SenderID.Clear();
            new_SenderIdentificationCardNo.Clear();
            new_SenderIdentificationCardTypeID.Clear();

            // aşağıdaki scriptle gönderici bilgileri frame'ini temizleriz
            QScript("document.getElementById('Frame_Panel_SenderInformation').contentWindow.ToolbarButtonClear_Clear();");
        }
    }

    protected void new_SenderPersonInformation_Click(object sender, AjaxEventArgs e)
    {
        RefreshSenderPerson(ValidationHelper.GetGuid(new_SenderPersonId.Value));
    }

    protected void new_RecipientCountryID_Click(object sender, AjaxEventArgs e)
    {
        //if (new_RecipientCountryID.Value != null)
        //{
        //    var sd = new StaticData();
        //    sd.AddParameter("@New_CountryId", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCountryID.Value));
        //    var PaymentPointLink = ValidationHelper.GetString(sd.ExecuteScalar(@"select top 1 new_LinkUrl from vNew_PaymentPointLinks(nolock) where new_CountryId = @New_CountryId "));
        //    if (PaymentPointLink != string.Empty)
        //    {
        //        if (PaymentPointLink.IndexOf("http://") != -1)
        //        {
        //            QScript("window.open('" + PaymentPointLink + "');");
        //        }
        //        else
        //        {
        //            QScript("window.open('http://" + PaymentPointLink + "');");
        //        }

        //    }

        //}


        string BrandId = new_BrandId.Value;
        string CountryId = new_RecipientCountryID.Value;
        string CorporationId = new_RecipientCorporationId.Value;
        string StateId = new_RecipientRegionId.Value;
        string CityId = new_RecipientCityId.Value;

        //window.top.newWindowRefleX(url, { maximized: false, width: 900, height: 600, resizable: true, modal: true, maximizable: false });

        QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/ISV/TU/Payment/PaymentLocations.aspx?CountryId=" + CountryId + "&CorporationId=" + CorporationId + "&BrandId=" + BrandId + "&StateId=" + StateId + "&CityId=" + CityId + "', { maximized: false, width: 1100, height: 600, resizable: true, modal: true, maximizable: false });");

        // ofis popupı açılacak
        //OfisPopup.Show();



    }

    protected void OfisGridPanelOnload(object sender, AjaxEventArgs e)
    {
    }

    protected void new_BicCodeChanged(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(new_BicCode.Value.Trim()))
        {
            SetBankUIFieldsByBicCode(new_BicCode.Value);
        }
    }

    protected void new_RecipientCityLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"SELECT DISTINCT ict.New_IntegrationCitiesId AS ID, ict.IntegrationCityName AS VALUE,ict.IntegrationCityName,ict.new_CityCode
			FROM vNew_IntegrationCities ict
			inner join vNew_IntegrationChannel ic on ic.New_IntegrationChannelId =ict.new_IntegrationChannelID
			inner join vNew_Corporation c on c.new_IntegrationChannelId=ic.New_IntegrationChannelId			
			WHERE ict.new_CountryId = @CountryId and c.New_CorporationId=@CorporationId 
			and  c.DeletionStateCode=0 and ic.DeletionStateCode=0 and ict.DeletionStateCode=0 ";

        const string sort = "";
        var like = new_RecipientCityId.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CITY_LOOKUP_VIEW");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_RecipientCityId.Start();
        var limit = new_RecipientCityId.Limit();
        var spList = new List<CrmSqlParameter>(){
                        new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "CountryId",
                                    Value = ValidationHelper.GetGuid(new_RecipientCountryID.Value)
                                },new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "CorporationId",
                                    Value = ValidationHelper.GetGuid(new_RecipientCorporationId.Value)
                                }
        };

        if (!string.IsNullOrEmpty(like))
        {

            strSql += " and ict.IntegrationCityName LIKE  @City + '%' ";
            spList.Add(new CrmSqlParameter
            {
                Dbtype = DbType.String,
                Paramname = "City",
                Value = like
            });
        }

        if (!String.IsNullOrEmpty(new_RecipientRegionId.Value))
        {
            strSql += " and ict.new_StateId=@RegionId";
            CrmSqlParameter prm1 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "RegionId",
                Value = ValidationHelper.GetGuid(new_RecipientRegionId.Value)
            };
            spList.Add(prm1);
        }

        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_RecipientCityId.TotalCount = cnt;
        new_RecipientCityId.DataSource = t;
        new_RecipientCityId.DataBind();
    }

    protected void new_RecipientBrandLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"SELECT DISTINCT ib.New_IntegrationBrandsId AS ID, ib.BrandName AS VALUE, ib.BrandName, ib.new_BrandCode--, ic.New_IntegrationCitiesId, ic.IntegrationCityName
	FROM vNew_IntegrationBrands ib
		left join vNew_IntegrationCityBrands cb on cb.new_BrandId=ib.New_IntegrationBrandsId and cb.DeletionStateCode=0
		left join vNew_IntegrationCities ic on cb.new_CityId = ic.New_IntegrationCitiesId and ic.DeletionStateCode=0
		inner join vNew_IntegrationChannel ich on ich.New_IntegrationChannelId =ib.new_IntegrationChannelID
		inner join vNew_Corporation c on c.new_IntegrationChannelId=ich.New_IntegrationChannelId		
	WHERE 			
		c.New_CorporationId=@CorporationId 
		and ib.new_CountryId = @CountryId
		and c.DeletionStateCode=0 and ib.DeletionStateCode=0 
		and ib.DeletionStateCode=0 and ich.DeletionStateCode=0 ";

        const string sort = "";
        var like = new_RecipientCityId.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("BRAND_LOOKUP_VIEW");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_BrandId.Start();
        var limit = new_BrandId.Limit();
        var spList = new List<CrmSqlParameter>(){
                        new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "CountryId",
                                    Value = ValidationHelper.GetGuid(new_RecipientCountryID.Value)
                                },
                                new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "CorporationId",
                                    Value = ValidationHelper.GetGuid(new_RecipientCorporationId.Value)
                                }
        };
        if (!string.IsNullOrEmpty(like))
        {

            strSql += " and ib.BrandName LIKE  @Brand + '%' ";
            spList.Add(new CrmSqlParameter
            {
                Dbtype = DbType.String,
                Paramname = "Brand",
                Value = like
            });
        }

        if (!String.IsNullOrEmpty(new_RecipientCityId.Value))
        {
            strSql += " and ic.New_IntegrationCitiesId=@CityId";
            CrmSqlParameter prm1 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "CityId",
                Value = ValidationHelper.GetGuid(new_RecipientCityId.Value)
            };
            spList.Add(prm1);
        }


        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_BrandId.TotalCount = cnt;
        new_BrandId.DataSource = t;

        new_BrandId.DataBind();
    }

    protected void new_LocationLoad(object sender, AjaxEventArgs e)
    {
        //        string strSql = @"SELECT DISTINCT o.New_OfficeId AS ID, o.OfficeName AS VALUE,o.OfficeName,o.new_BrandIdName,o.new_CityIdName,o.new_StateIdName
        //			FROM vNew_Office o			
        //			inner join vNew_OfficeTransactionType ott on ott.new_OfficeId=o.new_OfficeId
        //			inner join vNew_TransactionType tt on tt.New_TransactionTypeId=ott.new_TransactionTypeID
        //			inner join vNew_TargetOptionTransactionType tott on tott.new_TransactionTypeId=tt.New_TransactionTypeId					
        //			WHERE o.New_CorporationId=@CorporationId and o.new_CountryID=@CountryId and o.DeletionStateCode=0 and  o.DeletionStateCode=0
        //			and tott.new_TransactionTargetOptionId=@TransactionTargetOptionId and (tt.new_ExtCode ='008' OR tt.new_ExtCode ='012') ";

        string strSql = @"SELECT DISTINCT o.New_OfficeId AS ID, o.OfficeName AS VALUE,o.OfficeName,o.new_BrandIdName,o.new_CityIdName,o.new_StateIdName
                FROM vNew_Office o			
                INNER JOIN vNew_OfficeTransactionType ott on ott.new_OfficeId = o.new_OfficeId AND ott.DeletionStateCode = 0
                INNER JOIN vNew_TransactionType tt on tt.New_TransactionTypeId = ott.new_TransactionTypeID AND tt.DeletionStateCode = 0
                --INNER JOIN vNew_TargetOptionTransactionType tott on tott.new_TransactionTypeId = tt.New_TransactionTypeId AND tott.DeletionStateCode = 0				
                WHERE 
                o.DeletionStateCode = 0
                AND o.New_CorporationId = @CorporationId 
                AND o.new_CountryID = @CountryId
                --AND tott.new_TransactionTargetOptionId = @TransactionTargetOptionId 
                AND (tt.new_ExtCode ='008' OR tt.new_ExtCode ='012')";

        const string sort = "";
        var like = new_RecipientOfficeId.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("OFFICE_LOOKUP_VIEW_FOR_TRANSFER");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_RecipientOfficeId.Start();
        var limit = new_RecipientOfficeId.Limit();
        var spList = new List<CrmSqlParameter>(){
                        new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "CountryId",
                                    Value = ValidationHelper.GetGuid(new_RecipientCountryID.Value)
                                }
                                ,
                                new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "CorporationId",
                                    Value = ValidationHelper.GetGuid(new_RecipientCorporationId.Value)
                                }
                                ,
                                new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "TransactionTargetOptionId",
                                    Value = ValidationHelper.GetGuid(new_TransactionTargetOptionID.Value)
                                }
        };

        if (!string.IsNullOrEmpty(like))
        {

            strSql += " and (o.OfficeName LIKE  @Location + '%' or o.new_CityIdName LIKE  @Location + '%' or o.new_BrandIdName LIKE  @Location + '%' or o.new_StateIdName LIKE  @Location + '%')";
            spList.Add(new CrmSqlParameter
            {
                Dbtype = DbType.String,
                Paramname = "Location",
                Value = like
            });
        }

        if (!String.IsNullOrEmpty(new_RecipientRegionId.Value))
        {
            strSql += " and o.new_StateId=@RegionId";
            CrmSqlParameter prm1 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "RegionId",
                Value = ValidationHelper.GetGuid(new_RecipientRegionId.Value)
            };
            spList.Add(prm1);
        }
        if (!String.IsNullOrEmpty(new_RecipientCityId.Value))
        {
            strSql += " and o.new_CityId=@CityId";
            CrmSqlParameter prm2 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "CityId",
                Value = ValidationHelper.GetGuid(new_RecipientCityId.Value)
            };
            spList.Add(prm2);
        }
        if (!String.IsNullOrEmpty(new_BrandId.Value))
        {
            strSql += " and o.new_BrandId=@BrandId";
            CrmSqlParameter prm3 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "BrandId",
                Value = ValidationHelper.GetGuid(new_BrandId.Value)
            };
            spList.Add(prm3);
        }

        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_RecipientOfficeId.TotalCount = cnt;
        new_RecipientOfficeId.DataSource = t;
        new_RecipientOfficeId.DataBind();
    }

    private void OneLocationLoad(Guid OfficeId)
    {

        string strSql = @"SELECT DISTINCT o.New_OfficeId AS ID, o.OfficeName AS VALUE,o.OfficeName,o.new_BrandIdName,o.new_CityIdName,o.new_StateIdName
                FROM vNew_Office o			
                INNER JOIN vNew_OfficeTransactionType ott on ott.new_OfficeId = o.new_OfficeId AND ott.DeletionStateCode = 0
                INNER JOIN vNew_TransactionType tt on tt.New_TransactionTypeId = ott.new_TransactionTypeID AND tt.DeletionStateCode = 0                
                WHERE 
                o.DeletionStateCode = 0
                AND o.New_OfficeId = @OfficeId ";


        const string sort = "";
        var like = new_RecipientOfficeId.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("OFFICE_LOOKUP_VIEW_FOR_TRANSFER");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_RecipientOfficeId.Start();
        var limit = new_RecipientOfficeId.Limit();
        var spList = new List<CrmSqlParameter>(){
                        new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "OfficeId",
                                    Value = OfficeId
                                }

        };



        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_RecipientOfficeId.TotalCount = cnt;
        new_RecipientOfficeId.DataSource = t;
        new_RecipientOfficeId.DataBind();
    }

    protected void new_RecipientRegionLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"SELECT DISTINCT ir.New_IntegrationStatesId AS ID, ir.IntegrationStateName AS VALUE,ir.IntegrationStateName,ir.new_StateCode
			FROM vNew_IntegrationStates ir
			inner join vNew_IntegrationChannel ic on ic.New_IntegrationChannelId =ir.new_IntegrationChannelID
			inner join vNew_Corporation c on c.new_IntegrationChannelId=ic.New_IntegrationChannelId
			WHERE ir.new_CountryId = @CountryId and c.New_CorporationId=@CorporationId  
			and c.DeletionStateCode=0 and ic.DeletionStateCode=0 and ir.DeletionStateCode=0 ";

        const string sort = "";
        var like = new_RecipientRegionId.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("IntegrationStatesView");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_RecipientRegionId.Start();
        var limit = new_RecipientRegionId.Limit();
        var spList = new List<CrmSqlParameter>(){
                        new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "CountryId",
                                    Value = ValidationHelper.GetGuid(new_RecipientCountryID.Value)
                                },new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "CorporationId",
                                    Value = ValidationHelper.GetGuid(new_RecipientCorporationId.Value)
                                }
        };

        if (!string.IsNullOrEmpty(like))
        {

            strSql += " and ir.IntegrationStateName LIKE  @Region + '%' ";
            spList.Add(new CrmSqlParameter
            {
                Dbtype = DbType.String,
                Paramname = "Region",
                Value = like
            });
        }

        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_RecipientRegionId.TotalCount = cnt;
        new_RecipientRegionId.DataSource = t;
        new_RecipientRegionId.DataBind();
    }

    protected void new_RecipientCorporationLoad(object sender, AjaxEventArgs e)
    {
        RecipientCorporationLoad(null, null);
    }

    private void RecipientCorporationLoad(int? start, int? limit)
    {
        #region OLD_SQL
        string strSql2 = @"
/*DECLARE @TransactionTargetOptionID UNIQUEIDENTIFIER = '0BFC8B29-AE93-4226-BA23-4BC659890AB4'
DECLARE @CountryId UNIQUEIDENTIFIER = 'F5F8F4B8-B7A8-499B-8A56-3B4AD930A16E'
DECLARE @SystemUserId UNIQUEIDENTIFIER = '00000001-2211-44A8-BAAA-89AC131336A9'*/

DECLARE @LanguageId AS INT
SELECT @LanguageId = ISNULL(LanguageId, 1055) FROM vSystemUser WHERE SystemUserId = @SystemUserId

DECLARE @UPTHavuzu AS NVARCHAR(50) = 'UPT Havuzu'
DECLARE @Diger AS NVARCHAR(50) = 'Diğer'

SELECT @UPTHavuzu = Value FROM Label WHERE LabelName = 'CRM.NEW_TRANSFER_UPT_HAVUZU' AND LangId = @LanguageId
SELECT @Diger = Value FROM Label WHERE LabelName = 'CRM.NEW_TRANSFER_DIGER' AND LangId = @LanguageId

DECLARE @TransactionTargetOptionCode NVARCHAR(10)
SELECT @TransactionTargetOptionCode = new_TransactionTargetOptionCode FROM
vNew_TransactionTargetOption ttt
WHERE 
ttt.New_TransactionTargetOptionId = @TransactionTargetOptionID
AND ttt.DeletionStateCode = 0

SELECT * FROM
(
    SELECT DISTINCT 
	    CASE  ISNULL(ctt.new_UseUptPool,0)
		    WHEN 0 THEN ctt.New_CorporationId
		    ELSE '00000000-0000-0000-0000-000000000001' 
	    END AS ID,
	    CASE  ISNULL(ctt.new_UseUptPool,0)
		    WHEN 0 THEN ctt.CorporationName 
		    ELSE @UPTHavuzu
	    END AS VALUE,
	    CASE  ISNULL(ctt.new_UseUptPool,0)
		    WHEN 0 THEN ctt.CorporationName 
		    ELSE @UPTHavuzu
	    END AS CorporationName,
	    CASE  ISNULL(ctt.new_UseUptPool,0)
		    WHEN 0 THEN ctt.new_CorporationCode 
		    ELSE ''
	    END AS new_CorporationCode 
    FROM OfficeTransactionTypeCumulativeTable ctt
    WHERE ctt.new_CountryId = @CountryId 
    AND
    (
	    (
		    @TransactionTargetOptionCode = '002' /* Isme gonderim */
		    AND ctt.new_ExtCode = '008' /* Nakit Odeme */
	    )
	    OR
	    (
		    @TransactionTargetOptionCode = '001' /* Hesaba gonderim */
		    AND ctt.new_ExtCode = '012' /* Hesaba Odeme */
	    )
    )
    AND ctt.New_CorporationId NOT IN 
	(
		SELECT DISTINCT cbc.new_BlockedCorporation FROM vNew_CorporationBlockedCountries cbc
        INNER JOIN vSystemUser u
        ON cbc.new_CorporationID = u.new_CorporationID AND u.DeletionStateCode = 0
        WHERE u.SystemUserId = @SystemUserId AND cbc.DeletionStateCode = 0 AND cbc.new_BlockedCorporation is not null AND cbc.new_CountryId = @CountryId
    )

    UNION

    --EFT ya da swift yetkisi olan kurumlar icin 'Diger' seklinde bir kurum goster.
    SELECT DISTINCT
	    '00000000-0000-0000-0000-000000000001' AS ID, 
	    @Diger AS VALUE,
	    @Diger AS CorporationName,
	    '' AS new_CorporationCode    
    FROM OfficeTransactionTypeCumulativeTable ctt
    WHERE 
    (
        (
            @TransactionTargetOptionCode = '001' /* Hesaba gonderim */
            AND
            (
	            (
		            ctt.new_ExtCode = '002' /* EFT */
		            AND 
		            (
			            SELECT new_CountryShortCode FROM vNew_Country WHERE new_CountryID = @CountryId AND DeletionStateCode = 0
		            ) = 'TR' /* Alici ulke Turkiye */
	            )
	            OR
	            (
		            ctt.new_ExtCode = '003' /* Swift */
	            )
            )
        )
        OR
		(
			@TransactionTargetOptionCode = '004' /* Kredi kartina gonderim */
			AND
			(
				(
					ctt.new_ExtCode = '002' /* EFT */
					AND 
					(
						SELECT new_CountryShortCode FROM vNew_Country WHERE new_CountryID = @CountryId AND DeletionStateCode = 0
					) = 'TR' /* Alici ulke Turkiye */
				)
			)
		)
    )
) AS T";
        #endregion

        #region NEW_SQL
        string strSql = @"
/*DECLARE @TransactionTargetOptionID UNIQUEIDENTIFIER = '0BFC8B29-AE93-4226-BA23-4BC659890AB4'
DECLARE @CountryId UNIQUEIDENTIFIER = 'F5F8F4B8-B7A8-499B-8A56-3B4AD930A16E'
DECLARE @SystemUserId UNIQUEIDENTIFIER = '00000001-2211-44A8-BAAA-89AC131336A9'*/

DECLARE @LanguageId AS INT
SELECT @LanguageId = ISNULL(LanguageId, 1055) FROM vSystemUser WHERE SystemUserId = @SystemUserId

DECLARE @UPTHavuzu AS NVARCHAR(50) = 'UPT Havuzu'
DECLARE @Diger AS NVARCHAR(50) = 'Diğer'

SELECT @UPTHavuzu = Value FROM Label WHERE LabelName = 'CRM.NEW_TRANSFER_UPT_HAVUZU' AND LangId = @LanguageId
SELECT @Diger = Value FROM Label WHERE LabelName = 'CRM.NEW_TRANSFER_DIGER' AND LangId = @LanguageId

DECLARE @TransactionTargetOptionCode NVARCHAR(10)
SELECT @TransactionTargetOptionCode = new_TransactionTargetOptionCode FROM
vNew_TransactionTargetOption ttt
WHERE 
ttt.New_TransactionTargetOptionId = @TransactionTargetOptionID
AND ttt.DeletionStateCode = 0

SELECT * FROM
(
    SELECT DISTINCT 
	   CASE  ISNULL(ctt.new_UseUptPool,0)
		   WHEN 0 THEN ctt.New_CorporationId
		   ELSE '00000000-0000-0000-0000-000000000001' 
	   END AS ID,
	   CASE  ISNULL(ctt.new_UseUptPool,0)
		   WHEN 0 THEN ctt.CorporationName 
		   ELSE @UPTHavuzu
	   END AS VALUE,
	   CASE  ISNULL(ctt.new_UseUptPool,0)
		   WHEN 0 THEN ctt.CorporationName 
		   ELSE @UPTHavuzu
	   END AS CorporationName,
	   CASE  ISNULL(ctt.new_UseUptPool,0)
		   WHEN 0 THEN ctt.new_CorporationCode 
		   ELSE ''
	   END AS new_CorporationCode 
    FROM OfficeTransactionTypeCumulativeTable ctt
    INNER JOIN vNew_Corporation crp ON crp.New_CorporationId=ctt.New_CorporationId
    WHERE ctt.new_CountryId = @CountryId AND crp.new_CorporationTransactionRestriction in (2,3)
    AND
    (
	   (
		   @TransactionTargetOptionCode = '002' /* Isme gonderim */
		   AND ctt.new_ExtCode = '008' /* Nakit Odeme */
	   )
	   --OR
	   --(
		  -- @TransactionTargetOptionCode = '001' /* Hesaba gonderim */
		  -- AND ctt.new_ExtCode = '012' /* Hesaba Odeme */
	   --)
    )
    AND ctt.New_CorporationId NOT IN 
	(
		SELECT DISTINCT cbc.new_BlockedCorporation FROM vNew_CorporationBlockedCountries cbc
        INNER JOIN vSystemUser u
        ON cbc.new_CorporationID = u.new_CorporationID AND u.DeletionStateCode = 0
        WHERE u.SystemUserId = @SystemUserId AND cbc.DeletionStateCode = 0 AND cbc.new_BlockedCorporation is not null AND cbc.new_CountryId = @CountryId
    )

    UNION
    
    SELECT DISTINCT 
	   '00000000-0000-0000-0000-000000000001' AS ID, 
	   @Diger AS VALUE,
	   @Diger AS CorporationName,
	   '' AS new_CorporationCode 
    FROM OfficeTransactionTypeCumulativeTable ctt
    INNER JOIN vNew_Corporation crp ON crp.New_CorporationId=ctt.New_CorporationId
    WHERE ctt.new_CountryId = @CountryId AND crp.new_CorporationTransactionRestriction in (2,3)
    AND
    (
	   --(
		  -- @TransactionTargetOptionCode = '002' /* Isme gonderim */
		  -- AND ctt.new_ExtCode = '008' /* Nakit Odeme */
	   --)
	   --OR
	   (
		   @TransactionTargetOptionCode = '001' /* Hesaba gonderim */
		   AND ctt.new_ExtCode = '012' /* Hesaba Odeme */
	   )
    )
    AND ctt.New_CorporationId NOT IN 
	(
		SELECT DISTINCT cbc.new_BlockedCorporation FROM vNew_CorporationBlockedCountries cbc
        INNER JOIN vSystemUser u
        ON cbc.new_CorporationID = u.new_CorporationID AND u.DeletionStateCode = 0
        WHERE u.SystemUserId = @SystemUserId AND cbc.DeletionStateCode = 0 AND cbc.new_BlockedCorporation is not null AND cbc.new_CountryId = @CountryId
    )
    
    UNION
    

    --EFT ya da swift yetkisi olan kurumlar icin 'Diger' seklinde bir kurum goster.
    SELECT DISTINCT
	   '00000000-0000-0000-0000-000000000001' AS ID, 
	   @Diger AS VALUE,
	   @Diger AS CorporationName,
	   '' AS new_CorporationCode    
    FROM OfficeTransactionTypeCumulativeTable ctt
    INNER JOIN vNew_Corporation crp ON crp.New_CorporationId=ctt.New_CorporationId
    WHERE  crp.new_CorporationTransactionRestriction in (2,3) AND
    (
        (
            @TransactionTargetOptionCode = '001' /* Hesaba gonderim */
            AND
            (
	           (
		           ctt.new_ExtCode = '002' /* EFT */
		           AND 
		           (
			           SELECT new_CountryShortCode FROM vNew_Country WHERE new_CountryID = @CountryId AND DeletionStateCode = 0
		           ) = 'TR' /* Alici ulke Turkiye */
	           )
	           OR
	           (
		           ctt.new_ExtCode = '003' /* Swift */
	           )
            )
        )
        OR
		(
			@TransactionTargetOptionCode = '004' /* Kredi kartina gonderim */
			AND
			(
				(
					ctt.new_ExtCode = '002' /* EFT */
					AND 
					(
						SELECT new_CountryShortCode FROM vNew_Country WHERE new_CountryID = @CountryId AND DeletionStateCode = 0
					) = 'TR' /* Alici ulke Turkiye */
				)
			)
		)
		OR
		(
            @TransactionTargetOptionCode = '006' /* Aktifbank Ödeme (Kredi Ödemesi Bayi) */
            AND
            (
	           (
		           ctt.new_ExtCode = '002' /* EFT */
		           AND 
		           (
			           SELECT new_CountryShortCode FROM vNew_Country WHERE new_CountryID = @CountryId AND DeletionStateCode = 0
		           ) = 'TR' /* Alici ulke Turkiye */
	           )
	           OR
	           (
		           ctt.new_ExtCode = '003' /* Swift */
	           )
            )
        )
    )
) AS T";
        #endregion

        StaticData sd = new StaticData();
        sd.AddParameter("CountryId", DbType.Guid, ValidationHelper.GetGuid(new_RecipientCountryID.Value));
        sd.AddParameter("TransactionTargetOptionId", DbType.Guid, ValidationHelper.GetGuid(new_TransactionTargetOptionID.Value));
        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));

        var like = new_RecipientCorporationId.Query();

        if (!string.IsNullOrEmpty(like))
        {

            strSql += " WHERE CorporationName LIKE  @Corporation + '%' ";
            sd.AddParameter("Corporation", DbType.String, like);
        }

        strSql += " ORDER BY CorporationName";

        if (start.HasValue && limit.HasValue)
        {
            BindCombo(new_RecipientCorporationId, sd, strSql, start.Value, limit.Value);
        }
        else
        {
            BindCombo(new_RecipientCorporationId, sd, strSql);
        }
    }

    protected void new_LocationChangeOnEvent(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(new_RecipientOfficeId.Value))
        {

            StaticData sss = new StaticData();
            sss.AddParameter("RecipientOfficeId", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientOfficeId.Value));
            DataTable result = ((DataSet)sss.ReturnDataset(@"select top 1 new_CountryID,new_StateId,new_StateIdName,new_BrandId,new_BrandIdName,new_CityId,new_CityIdName from vNew_Office 
where New_OfficeId=@RecipientOfficeId")).Tables[0];

            if (result.Rows.Count > 0)
            {
                new_RecipientCityId.SetValue(ValidationHelper.GetGuid(result.Rows[0]["new_CityId"]), result.Rows[0]["new_CityIdName"].ToString());
                new_BrandId.SetValue(ValidationHelper.GetGuid(result.Rows[0]["new_BrandId"]), result.Rows[0]["new_BrandIdName"].ToString());
                new_RecipientRegionId.SetValue(ValidationHelper.GetGuid(result.Rows[0]["new_StateId"]), result.Rows[0]["new_StateIdName"].ToString());
            }
        }
        else
        {
            new_RecipientCityId.Clear();
            new_BrandId.Clear();
            new_RecipientRegionId.Clear();
        }
        new_AmountCurrency2.Clear();
    }

    protected void new_RegionChangeOnEvent(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(new_RecipientRegionId.Value))
        {
            new_RecipientCityId.Clear();
            new_BrandId.Clear();
            new_RecipientOfficeId.Clear();
        }
    }

    protected void new_CorporationChangeOnEvent(object sender, AjaxEventArgs e)
    {
        RegionalControlsRequirement regionalControlsRequirement = new RegionalControlsRequirement(ValidationHelper.GetDBGuid(new_RecipientCountryID.Value).ToString(), ValidationHelper.GetDBGuid(new_RecipientCorporationId.Value).ToString());

        if ((regionalControlsRequirement.new_IsRegional || regionalControlsRequirement.new_IsAgentRegional) && (new_TransactionTargetOptionID.Value == TransferType.IsmeGonderim || new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi))
        {
            ShowRegionalControls(regionalControlsRequirement);
        }
        else
        {

            HideRegionalControls();

        }

        if (sender != null)
        {
            new_AmountCurrency2.Clear();
        }

        showHideEftSwiftObject(sender, e);
    }

    protected void new_CityChangeOnEvent(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(new_RecipientCityId.Value))
        {
            new_BrandId.Clear();
            new_RecipientOfficeId.Clear();
        }
    }

    protected void new_BrandChangeOnEvent(object sender, AjaxEventArgs e)
    {
        RegionalControlsRequirement regionalControlsRequirement = new RegionalControlsRequirement(ValidationHelper.GetDBGuid(new_RecipientCountryID.Value).ToString(), ValidationHelper.GetDBGuid(new_RecipientCorporationId.Value).ToString());

        if (regionalControlsRequirement.new_IsAgentRegional)
        {


            if (!string.IsNullOrEmpty(new_BrandId.Value) && !string.IsNullOrEmpty(new_RecipientCorporationId.Value) && !string.IsNullOrEmpty(new_RecipientCountryID.Value))
            {

                StaticData sss = new StaticData();
                sss.AddParameter("RecipientBrandId", DbType.Guid, ValidationHelper.GetDBGuid(new_BrandId.Value));
                sss.AddParameter("CorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCorporationId.Value));
                sss.AddParameter("CountryID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCountryID.Value));

                DataTable result = ((DataSet)sss.ReturnDataset(@"select top 1 New_OfficeId,OfficeName from vNew_Office 
where New_BrandId=@RecipientBrandId and DeletionStateCode=0 and new_CorporationID=@CorporationID and new_CountryID=@CountryID
order by new_ReferenceCode")).Tables[0];

                new_RecipientOfficeId.Clear();
                if (result.Rows.Count > 0)
                {
                    //new_LocationLoad(null, null);
                    OneLocationLoad(ValidationHelper.GetGuid(result.Rows[0]["New_OfficeId"]));
                    new_RecipientOfficeId.SetValue(ValidationHelper.GetGuid(result.Rows[0]["New_OfficeId"]), result.Rows[0]["OfficeName"].ToString());
                    new_LocationChangeOnEvent(null, null);
                }
            }
            else
            {
                new_RecipientOfficeId.Clear();
            }
        }
        else
        {
            new_RecipientOfficeId.Clear();
        }
    }

    protected void BicBankChanged(object sender, AjaxEventArgs e)
    {
        new_BicBankCity.Clear();
        new_BicBankBranch.Clear();
        new_BicCode.Clear();

        string strSql = @"
        IF EXISTS (
        SELECT 1 
          FROM vNew_BicBankBranch bb
         WHERE bb.new_BicBank = @RecipientBicBankID 
           AND bb.new_BicCode LIKE '%XXX' 
           AND DeletionStateCode = 0
        )
        BEGIN
	        SELECT SUBSTRING(bb.new_BicCode,0,9) AS new_BicCode, bb.new_BicBankName 
	          FROM vNew_BicBankBranch bb
	         WHERE bb.new_BicBank = @RecipientBicBankID 
	           AND bb.new_BicCode LIKE '%XXX' 
	           AND DeletionStateCode = 0
        END
        ELSE
        BEGIN
	        SELECT TOP 1 SUBSTRING(bb.new_BicCode,0,9) AS new_BicCode, bb.new_BicBankName 
	          FROM vNew_BicBankBranch bb
	         WHERE bb.new_BicBank = @RecipientBicBankID 
	           AND DeletionStateCode = 0
        END";

        StaticData sd = new StaticData();
        sd.AddParameter("RecipientBicBankID", DbType.Guid, ValidationHelper.GetGuid(new_BicBank.Value));

        DataTable dt = sd.ReturnDataset(strSql).Tables[0];
        if (dt.Rows.Count > 0)
        {
            new_BicCode.Value = dt.Rows[0]["new_BicCode"].ToString();
            new_BicCode.SetValue(dt.Rows[0]["new_BicCode"].ToString());
            new_BicBankHidden.Value = dt.Rows[0]["new_BicBankName"].ToString();
            new_BicBankHidden.SetValue(dt.Rows[0]["new_BicBankName"].ToString());
        }
    }

    protected void BicBankCityChanged(object sender, AjaxEventArgs e)
    {
        new_BicBankBranch.Clear();
        new_BicCode.Clear();

        if (!string.IsNullOrEmpty(new_BicBankCity.Value) && !string.IsNullOrEmpty(new_BicBank.Value))
        {

            StaticData sss = new StaticData();
            sss.AddParameter("BicBankId", DbType.Guid, ValidationHelper.GetDBGuid(new_BicBank.Value));
            sss.AddParameter("BicBankCityId", DbType.Guid, ValidationHelper.GetDBGuid(new_BicBankCity.Value));
            DataTable result = ((DataSet)sss.ReturnDataset(@"select top 1 bbb.new_BicCode from vNew_BicBankBranch bbb
inner join vNew_BicBank bb on bb.New_BicBankId=bbb.new_BicBank and bb.DeletionStateCode=0
inner join vNew_BicBankCity bbc on bbc.New_BicBankCityId=bbb.new_BicBankCity and bbc.DeletionStateCode=0
where bbb.DeletionStateCode=0 and bb.New_BicBankId=@BicBankId and bbc.New_BicBankCityId=@BicBankCityId
order by new_BicCode")).Tables[0];


            if (result.Rows.Count > 0)
            {
                new_BicCode.SetValue(ValidationHelper.GetString(result.Rows[0]["new_BicCode"]));
            }
        }
        //new_BicCode.SetValue("ASD234ADXXX");
    }

    protected void RecipientAccountTypeLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"
	    SELECT iciv.new_Value AS ID, iciv.IntegrationChannelInputValueName AS VALUE, iciv.new_Value, iciv.IntegrationChannelInputValueName
          FROM vNew_IntegrationChannelInputValues iciv
    INNER JOIN vNew_IntegrationChannelInputs ici on iciv.new_InputID = ici.New_IntegrationChannelInputsId 
    INNER JOIN vNew_IntegrationChannel ic on ici.new_IntegrationChannelID = ic.New_IntegrationChannelId
    INNER JOIN vNew_Corporation co on ic.New_IntegrationChannelId = co.new_IntegrationChannelId
	     WHERE co.New_CorporationId = @CorporationID
	       AND ici.new_Country = @RecipientCountryID";

        StaticData sd = new StaticData();
        sd.AddParameter("CorporationID", DbType.Guid, ValidationHelper.GetGuid(new_RecipientCorporationIdHidden.Value));
        sd.AddParameter("RecipientCountryID", DbType.Guid, ValidationHelper.GetGuid(new_RecipientCountryID.Value));

        BindCombo(new_RecipientAccountType, sd, strSql);
    }

    #endregion

    #region Private Methods

    private Guid GetOtherSenderCorporationSystemUserId(Guid corporationId)
    {
        Guid result = Guid.Empty;
        var sd = new StaticData();
        sd.AddParameter("@CorporationId", DbType.Guid, corporationId);
        DataTable dt = sd.ReturnDataset("Select new_TransactionUserId from vNew_Corporation(NoLock) WHere New_CorporationId = @CorporationId and DeletionStateCode = 0").Tables[0];

        if (dt.Rows.Count > 0)
        {
            result = ValidationHelper.GetGuid(dt.Rows[0]["new_TransactionUserId"].ToString());
        }

        return result;
    }

    private void HideRegionalControls()
    {
        if (!String.IsNullOrEmpty(new_RecipientCorporationId.Value))
        {
            //            StaticData sd = new StaticData();
            //            sd.AddParameter("CountryId", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCountryID.Value));
            //            sd.AddParameter("CorporationId", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCorporationId.Value));

            //            bool? result = (bool?)sd.ExecuteScalar(@"select top 1 ISNULL(cc.new_IsRegional,0) As Region from vNew_IntegrationCountryCodes cc
            //inner join vNew_IntegrationChannel Ic on Ic.New_IntegrationChannelId=cc.new_IntegrationChannelId
            //inner join vNew_Corporation c on c.new_IntegrationChannelId=Ic.New_IntegrationChannelId
            //where cc.new_CountryId=@CountryId and c.New_CorporationId=@CorporationId and  cc.DeletionStateCode=0 and Ic.DeletionStateCode=0
            //order by Region desc");

            RegionalControlsRequirement regionalControlsRequirement = new RegionalControlsRequirement(new_RecipientCountryID.Value, new_RecipientCorporationId.Value);

            if (regionalControlsRequirement.new_IsRegional == false & regionalControlsRequirement.new_IsAgentRegional == false)
            {
                new_RecipientRegionId.Clear();
                new_RecipientCityId.Clear();
                new_BrandId.Clear();
                new_RecipientOfficeId.Clear();
                new_CorpSendAccountNumber.Clear();
                new_RecipientRegionId.SetVisible(false);
                new_RecipientCityId.SetVisible(false);
                new_BrandId.SetVisible(false);
                new_RecipientOfficeId.SetVisible(false);
                new_CorpSendAccountNumber.SetVisible(false);

                new_BrandId.SetRequirementLevel(RLevel.None);
                new_RecipientOfficeId.SetRequirementLevel(RLevel.None);

            }
        }
        else
        {
            new_RecipientRegionId.Clear();
            new_RecipientCityId.Clear();
            new_BrandId.Clear();
            new_RecipientOfficeId.Clear();
            new_CorpSendAccountNumber.Clear();
            new_RecipientRegionId.SetVisible(false);
            new_RecipientCityId.SetVisible(false);
            new_BrandId.SetVisible(false);
            new_RecipientOfficeId.SetVisible(false);
            new_CorpSendAccountNumber.SetVisible(false);

            new_BrandId.SetRequirementLevel(RLevel.None);
            new_RecipientOfficeId.SetRequirementLevel(RLevel.None);
        }

    }

    private void ShowRegionalControls(RegionalControlsRequirement regionalControlsRequirement)
    {

        if (regionalControlsRequirement.new_IsRegional)
        {
            new_RecipientRegionId.SetVisible(true);
            new_RecipientCityId.SetVisible(true);
            new_BrandId.SetVisible(true);
            new_RecipientOfficeId.SetVisible(true);
            new_CorpSendAccountNumber.SetVisible(true);
            new_BrandId.SetRequirementLevel(RLevel.BusinessRecommend);
            new_RecipientOfficeId.SetRequirementLevel(RLevel.BusinessRequired);
        }
        else if (regionalControlsRequirement.new_IsAgentRegional)
        {
            new_RecipientRegionId.SetVisible(false);
            new_RecipientCityId.SetVisible(false);
            new_BrandId.SetVisible(true);
            new_RecipientOfficeId.SetVisible(false);
            new_CorpSendAccountNumber.SetVisible(true);
            new_BrandId.SetRequirementLevel(RLevel.BusinessRequired);
            //new_RecipientOfficeId.SetRequirementLevel(RLevel.BusinessRequired); 
        }
    }

    private PayoutCurreny GetPayoutCurrenyCode(Guid RecipientCountryId, Guid RecipientCorporationId)
    {
        PayoutCurreny currency = null;
        string returnValue = string.Empty;
        try
        {
            var staticData = new StaticData();
            staticData.AddParameter("CorporationId", DbType.Guid, RecipientCorporationId);
            staticData.AddParameter("CountryId", DbType.Guid, RecipientCountryId);
            DataTable dataTable = staticData.ReturnDataset(@"Select Cur.ISOCurrencyCode CurrencyCode,ISNULL(Icc.new_ReceivedPaymentAmountParity,1) AS ReceivedPaymentAmountParity from vNew_Corporation Co (nolock)
            inner join vNew_IntegrationChannel Ic(nolock) On Co.new_IntegrationChannelId = Ic.New_IntegrationChannelId
            inner join vNew_IntegrationCountryCodes Icc(nolock) On Ic.New_IntegrationChannelId = Icc.new_IntegrationChannelId
            inner join vCurrency Cur(nolock) On Icc.new_PayoutCurrencyId = Cur.CurrencyId
            Where 
			Co.New_CorporationId = @CorporationId And Icc.new_CountryId = @CountryId And 
			Co.DeletionStateCode = 0 And Ic.DeletionStateCode = 0 And Icc.DeletionStateCode = 0 And Cur.DeletionStateCode = 0").Tables[0];
            if (dataTable.Rows.Count > 0)
            {
                currency = new PayoutCurreny();
                currency.PayoutCurrenyCode = ValidationHelper.GetString(dataTable.Rows[0]["CurrencyCode"]);
                currency.PayoutMargin = ValidationHelper.GetDecimal(dataTable.Rows[0]["ReceivedPaymentAmountParity"], 1);
            }
        }
        catch
        {

        }
        return currency;
    }

    private string GetPayinCurrenyCode(Guid AmountCurrenyId)
    {
        string returnValue = string.Empty;
        try
        {
            var staticData = new StaticData();
            staticData.AddParameter("CurrencyId", DbType.Guid, AmountCurrenyId);
            DataTable dataTable = staticData.ReturnDataset(@"Select ISOCurrencyCode from vCurrency(nolock) Where CurrencyId=@CurrencyId And DeletionStateCode = 0").Tables[0];
            if (dataTable.Rows.Count > 0)
            {
                returnValue = ValidationHelper.GetString(dataTable.Rows[0]["ISOCurrencyCode"]);
            }
        }
        catch
        {
            returnValue = string.Empty;
        }
        return returnValue;
    }

    private Guid GetCurrencyIdByIsoCode(string CurrencyCode)
    {
        Guid returnValue = Guid.Empty;
        try
        {
            var staticData = new StaticData();
            staticData.AddParameter("CurrencyCode", DbType.String, CurrencyCode);
            DataTable dataTable = staticData.ReturnDataset(@"Select CurrencyId from vCurrency(nolock) Where ISOCurrencyCode=@CurrencyCode And DeletionStateCode = 0").Tables[0];
            if (dataTable.Rows.Count > 0)
            {
                returnValue = ValidationHelper.GetGuid(dataTable.Rows[0]["CurrencyId"]);
            }
        }
        catch
        {
            returnValue = Guid.Empty;
        }
        return returnValue;
    }

    private void GetTransferOutherCalculateScript(object sender, AjaxEventArgs e)
    {
        bool returnValue = IsOtherCalculateScript();
        if (returnValue)
        {
            try
            {
                StaticData sd = new StaticData();
                sd.AddParameter("@RecipientCountryID", DbType.Guid, ValidationHelper.GetGuid(new_RecipientCountryID.Value));
                sd.AddParameter("@CorporationId", DbType.Guid, ValidationHelper.GetGuid(new_RecipientCorporationId.Value));
                sd.AddParameter("@AmountCurrency", DbType.Guid, ValidationHelper.GetGuid(new_AmountCurrency2.Value));
                sd.AddParameter("@Amount", DbType.Decimal, ((CrmDecimalComp)new_Amount.Items[0]).Value);
                DataTable dt = sd.ReturnDatasetSp(CorporationTransferCalculateScript).Tables[0];

                new_ReceivedPaymentAmount.Items[0].SetValue(ValidationHelper.GetDecimal(dt.Rows[0]["CALCULATE_AMOUNT"], 0));
                new_ReceivedPaymentAmount.Items[1].SetValue(ValidationHelper.GetGuid(dt.Rows[0]["PAYOUT_CURRENCY_ID"]));
                new_ReceivedPaymentAmountParity.SetValue(ValidationHelper.GetDecimal(dt.Rows[0]["PARITY"], 0));
                new_ReceivedPaymentAmountParityRateType.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["PARITY_RATE_TYPE"]));

                Parity3.Clear();
                Parity3.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_ReceivedPaymentAmountParity", TuEntityEnum.New_Transfer.GetHashCode()) + "&nbsp;&nbsp;" +
                    Math.Round(ValidationHelper.GetDecimal(dt.Rows[0]["PARITY"], 0), 6).ToString() /* + "&nbsp;" + 
                CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_TODAYS_RATE_IS_CALCULATED_FROM_THE_RECEIVER_TO_RECEIVER_THE_MONEY_IN_CASE_THE_OTHER")*/);
            }
            catch
            {
                new_ReceivedPaymentAmount.Items[0].SetValue(((CrmDecimalComp)new_Amount.Items[0]).Value);
                new_ReceivedPaymentAmount.Items[1].SetValue(ValidationHelper.GetGuid(((CrmComboComp)new_Amount.Items[1]).Value));
                Parity3.Clear();
                Parity3.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_ReceivedPaymentAmountParity", TuEntityEnum.New_Transfer.GetHashCode()) + "&nbsp;&nbsp;" +
                    Math.Round(ValidationHelper.GetDecimal(1, 0), 6).ToString() /* + "&nbsp;" +
                CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_TODAYS_RATE_IS_CALCULATED_FROM_THE_RECEIVER_TO_RECEIVER_THE_MONEY_IN_CASE_THE_OTHER")*/);
                new_ReceivedPaymentAmountParity.SetValue(1);
            }
        }
        else
        {
            var ret = new CurrencyRateReturnType();

            var i3rd = new TuFactory.Integration3rd.Integration3Rd();
            TuFactory.Integrationd3rdLayer.Integrationd3rd Integrator = i3rd.GetIntegratorByRecipientCorporationId(ValidationHelper.GetGuid(new_RecipientCorporationId.Value));
            PayoutCurreny payoutCurrency = GetPayoutCurrenyCode(ValidationHelper.GetGuid(new_RecipientCountryID.Value), ValidationHelper.GetGuid(new_RecipientCorporationId.Value));

            try
            {
                ret = Integrator.GetCurrencyRate(new IntagrateRateInput()
                {
                    Amount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_Amount.Items[0]).Value, 0),
                    FromCurrencyCode = GetPayinCurrenyCode(ValidationHelper.GetGuid(new_AmountCurrency2.Value)),
                    ToCurrencyCode = payoutCurrency.PayoutCurrenyCode,
                    RecipientCountryId = ValidationHelper.GetGuid(new_RecipientCountryID.Value),
                    RecipientCorporationId = ValidationHelper.GetGuid(new_RecipientCorporationId.Value),
                    AgentId = ValidationHelper.GetGuid(new_BrandId.Value),
                    RecipientOfficeId = ValidationHelper.GetGuid(new_RecipientOfficeId.Value),
                    TransferId = ValidationHelper.GetGuid(New_TransferId.Value)
                });
            }
            catch (Exception)
            {
                new_ReceivedPaymentAmount.Items[0].SetValue(((CrmDecimalComp)new_Amount.Items[0]).Value);
                new_ReceivedPaymentAmount.Items[1].SetValue(ValidationHelper.GetGuid(((CrmComboComp)new_Amount.Items[1]).Value));

                new_ReceivedPaymentOriginalAmount.Items[0].SetValue(((CrmDecimalComp)new_Amount.Items[0]).Value);
                new_ReceivedPaymentOriginalAmount.Items[1].SetValue(ValidationHelper.GetGuid(((CrmComboComp)new_Amount.Items[1]).Value));
                Parity3.Clear();
                Parity3.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_ReceivedPaymentAmountParity", TuEntityEnum.New_Transfer.GetHashCode()) + "&nbsp;&nbsp;" +
                    Math.Round(ValidationHelper.GetDecimal(1, 0), 6).ToString() /* + "&nbsp;" +
                CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_TODAYS_RATE_IS_CALCULATED_FROM_THE_RECEIVER_TO_RECEIVER_THE_MONEY_IN_CASE_THE_OTHER")*/);
                new_ReceivedPaymentAmountParity.SetValue(1);
                new_ReceivedPaymentOriginalAmountParity.SetValue(1);
            }

            if (ret.CurrencyRate != -1)
            {

                new_ReceivedPaymentOriginalAmount.Items[0].SetValue(ValidationHelper.GetDecimal(ret.PayoutAmount, 0));
                new_ReceivedPaymentOriginalAmount.Items[1].SetValue(ValidationHelper.GetGuid(GetCurrencyIdByIsoCode(ret.CurrencyIsoCode)));
                new_ReceivedPaymentOriginalAmountParity.SetValue(ValidationHelper.GetDecimal(ret.CurrencyRate, 0));

                /*Entegrasyon Kanalında tanımlı özel bir ödeme marjı tanımlı ise alıcıya ödenecek tutara uygulanır.*/
                if (payoutCurrency != null && payoutCurrency.PayoutMargin != 0)
                {
                    new_ReceivedPaymentAmount.Items[0].SetValue(ValidationHelper.GetDecimal(ret.PayoutAmount, 0) * payoutCurrency.PayoutMargin);
                    new_ReceivedPaymentAmount.Items[1].SetValue(ValidationHelper.GetGuid(GetCurrencyIdByIsoCode(ret.CurrencyIsoCode)));
                    new_ReceivedPaymentAmountParity.SetValue(ValidationHelper.GetDecimal(ret.CurrencyRate, 0) * payoutCurrency.PayoutMargin);
                    new_ReceivedPaymentAmountParityRateType.SetValue(ValidationHelper.GetGuid(ret.CurrencyRateType));
                }
                else
                {
                    new_ReceivedPaymentAmount.Items[0].SetValue(ValidationHelper.GetDecimal(ret.PayoutAmount, 0));
                    new_ReceivedPaymentAmount.Items[1].SetValue(ValidationHelper.GetGuid(GetCurrencyIdByIsoCode(ret.CurrencyIsoCode)));
                    new_ReceivedPaymentAmountParity.SetValue(ValidationHelper.GetDecimal(ret.CurrencyRate, 0));
                    new_ReceivedPaymentAmountParityRateType.SetValue(ValidationHelper.GetGuid(ret.CurrencyRateType));
                }

                if (ValidationHelper.GetBoolean(UPTCache.IntegrationChannelService.GetIntegrationChannelByCorporationId(ValidationHelper.GetGuid(new_RecipientCorporationId.Value)).DecimalNumber))
                {
                    new_Amount.Items[0].SetValue(ValidationHelper.GetDecimal(ret.ReturnTransactionAmount, 0));
                    new_Amount.Items[0].SetIValue(ValidationHelper.GetDecimal(ret.ReturnTransactionAmount, 0));
                    new_Amount.d1.Value = ValidationHelper.GetDecimal(ret.ReturnTransactionAmount, 0);
                }

                new_CustChargeAmount.SetValue(ret.CustChargeAmount);


                Parity3.Clear();
                Parity3.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_ReceivedPaymentAmountParity", TuEntityEnum.New_Transfer.GetHashCode()) + "&nbsp;&nbsp;" +
                    Math.Round(ValidationHelper.GetDecimal(ret.CurrencyRate, 0), 6).ToString());
            }
            else
            {
                new_ReceivedPaymentAmount.Items[0].SetValue(((CrmDecimalComp)new_Amount.Items[0]).Value);
                new_ReceivedPaymentAmount.Items[1].SetValue(ValidationHelper.GetGuid(((CrmComboComp)new_Amount.Items[1]).Value));

                new_ReceivedPaymentOriginalAmount.Items[0].SetValue(((CrmDecimalComp)new_Amount.Items[0]).Value);
                new_ReceivedPaymentOriginalAmount.Items[1].SetValue(ValidationHelper.GetGuid(((CrmComboComp)new_Amount.Items[1]).Value));

                Parity3.Clear();
                Parity3.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_ReceivedPaymentAmountParity", TuEntityEnum.New_Transfer.GetHashCode()) + "&nbsp;&nbsp;" +
                    Math.Round(ValidationHelper.GetDecimal(1, 0), 6).ToString() /* + "&nbsp;" +
                CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_TODAYS_RATE_IS_CALCULATED_FROM_THE_RECEIVER_TO_RECEIVER_THE_MONEY_IN_CASE_THE_OTHER")*/);
                new_ReceivedPaymentAmountParity.SetValue(1);
                new_ReceivedPaymentOriginalAmountParity.SetValue(1);
            }
        }
    }

    private bool IsOtherCalculateScript()
    {
        bool returnValue = false;
        try
        {
            StaticData sd = new StaticData();
            sd.AddParameter("CorporationId", DbType.Guid, ValidationHelper.GetGuid(new_RecipientCorporationId.Value));
            DataTable dt = sd.ReturnDataset("Select new_TransferCalculateScript from vNew_Corporation Where New_CorporationId = @CorporationId").Tables[0];
            CorporationTransferCalculateScript = dt.Rows[0]["new_TransferCalculateScript"].ToString();
            if (!string.IsNullOrEmpty(CorporationTransferCalculateScript))
            {
                returnValue = true;
            }
            else
            {
                returnValue = false;
            }
        }
        catch
        {
            returnValue = false;
        }
        return returnValue;
    }

    private void TranslateMessage()
    {
        //deneme
        btnSave.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_BTN_SAVE");
        btnPaymentPoints.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_BTN_PAYMENTPOINTS");
        Panel_SenderInformation.Title = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDER_INFORMATION");

        PanelX3.Title = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_RECEIVER_INFORMATION");
        PanelX4.Title = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_AMOUNT_INFORMATION");
        RxM.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_CollectionMethod",
                                                                 TuEntityEnum.New_Transfer.GetHashCode());
        GetMessage();
    }

    private void ExternalTranslateMessage()
    {
        BtnSenderPersonInfo.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_BTN_SENDERPERSONINFO");
    }

    private void ShowRequiredFields(string myLabel)
    {
        var msg = CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED");
        var m = new MessageBox { Width = 400 };
        m.Show(string.Format(msg, myLabel));
    }

    private string GetHiddenCardNumber(string cardNumber)
    {
        if (!string.IsNullOrEmpty(cardNumber) && cardNumber.Length > 8)
        {
            cardNumber = "****-****-****-" + cardNumber.Substring(cardNumber.Length - 4, 4);
        }
        else
        {
            cardNumber = "****";
        }

        return cardNumber;
    }

    protected void ClearRecipient(object sender, AjaxEventArgs e)
    {
        new_IbanisNotKnown.Checked = false;
        new_EftBranch.Clear();
        new_EftCity.Clear();
        new_EftBank.Clear();
        new_EftPaymentMethodID.Clear();
        new_BicBank.Clear();
        new_BicBankCity.Clear();
        new_BicBankBranch.Clear();
        new_BicCode.Clear();
        new_RecipientAccountNumber.Clear();
        new_RecipientBicAccountNumber.Clear();
        new_RecipientCardNumber.Clear();
        new_IbanisNotKnown.Clear();
        new_RecipientIBAN.Clear();
        new_RecipientBicIBAN.Clear();
        new_RecipientName.Clear();
        new_RecipientMiddleName.Clear();
        new_RecipientLastName.Clear();
        new_RecipientMotherName.Clear();
        new_RecipientFatherName.Clear();
        new_RecipientAddress.Clear();
        new_RecipientGSMCountryId.Clear();
        new_RecipientGSM.Clear();
        new_RecipienNickName.Clear();
        new_RecipientEmail.Clear();
        new_RecipientBirthDate.Clear();
        new_Explanation.Clear();
        new_RecipientID.Clear();
    }

    bool CheckBicCode(string bicCode)
    {
        var staticData = new StaticData();
        staticData.AddParameter("BicCode", DbType.String, bicCode);

        if (new_IbanisNotKnown.Checked)
        {
            var count = ValidationHelper.GetInteger(staticData.ExecuteScalar("SELECT COUNT(*) FROM vNew_BicBankBranch WHERE new_BicCode = @BicCode AND DeletionStateCode = 0"));
            return count == 1;
        }
        else
        {
            var count = ValidationHelper.GetInteger(staticData.ExecuteScalar(@"if(LEN(@BicCode)=8 or LEN(@BicCode) = 11)
                                                                            begin
                                                                            SELECT Count(1) FROM vNew_BicBankBranch WHERE new_BicCode like @BicCode +'%' AND DeletionStateCode = 0
                                                                            end
                                                                            else
                                                                            begin
                                                                            SELECT TOP 0 NULL
                                                                            end"));
            return Convert.ToBoolean(count);
        }
    }

    void SetBankUIFieldsByBankBranchId(Guid bankBranchId)
    {
        var staticData = new StaticData();
        staticData.AddParameter("New_BicBankBranchId", DbType.Guid, bankBranchId);
        DataSet dsBankData = staticData.ReturnDataset(@"SELECT 
                    New_BicBankBranchId, new_BicBank, 
                    new_BicBankName, new_BicBankCity, new_BicBankCityName,
                    New_BicBankBranchId, BicBankBranchName
                FROM vNew_BicBankBranch 
                WHERE 
                    New_BicBankBranchId = @New_BicBankBranchId AND DeletionStateCode = 0");

        if (dsBankData.Tables[0].Rows.Count == 1)
        {
            var row = dsBankData.Tables[0].Rows[0];

            new_BicBankCity.SetValue(row["new_BicBankCity"].ToString(), row["new_BicBankCityName"].ToString());
            new_BicBank.SetValue(row["new_BicBank"].ToString(), row["new_BicBankName"].ToString());

            new_BicBankBranch.SetValue(row["New_BicBankBranchId"].ToString(), row["BicBankBranchName"].ToString());
        }
    }

    void SetBankUIFieldsByBicCode(string bicCode)
    {
        var staticData = new StaticData();
        staticData.AddParameter("BicCode", DbType.String, bicCode);

        if (new_IbanisNotKnown.Checked)
        {
            DataSet ds = staticData.ReturnDataset("SELECT New_BicBankBranchId, new_BicBank, new_BicBankName, new_BicBankCity FROM vNew_BicBankBranch WHERE new_BicCode = @BicCode AND DeletionStateCode = 0");
            if (ds.Tables[0].Rows.Count == 1)
            {
                new_BicBank.SetValue(ds.Tables[0].Rows[0]["new_BicBank"], ds.Tables[0].Rows[0]["new_BicBankName"]);
                new_BicBankCity.SetValue(ds.Tables[0].Rows[0]["new_BicBankCity"]);
                new_BicBankBranch.SetValue(ds.Tables[0].Rows[0]["New_BicBankBranchId"]);
                BicBankChanged(null, null);
            }
            else
            {
                var m = new MessageBox { Width = 400, Height = 120 };
                var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_INCORRECT_BIC_CODE");
                m.Show("", msg2);
                return;
            }

        }
        else
        {
            DataSet ds = staticData.ReturnDataset(@"if(LEN(@BicCode)=8 or LEN(@BicCode)=11)
                                                begin
                                                SELECT top 1 New_BicBankBranchId, new_BicBank, new_BicBankName, new_BicBankCity FROM vNew_BicBankBranch WHERE new_BicCode like @BicCode +'%' AND DeletionStateCode = 0
                                                end
                                                else
                                                begin
                                                SELECT TOP 0 NULL
                                                end");


            if (bicCode.Trim().Length == 8)
            {
                if (ds.Tables[0].Rows.Count == 1)
                {
                    new_BicBank.SetValue(ds.Tables[0].Rows[0]["new_BicBank"], ds.Tables[0].Rows[0]["new_BicBankName"]);
                    BicBankChanged(null, null);
                }
                else
                {
                    var m = new MessageBox { Width = 400, Height = 120 };
                    var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_INCORRECT_BIC_CODE");
                    m.Show("", msg2);
                    return;
                }
            }
            else if (bicCode.Trim().Length == 11)
            {
                if (ds.Tables[0].Rows.Count == 1)
                {
                    new_BicBank.SetValue(ds.Tables[0].Rows[0]["new_BicBank"], ds.Tables[0].Rows[0]["new_BicBankName"]);
                    new_BicBankCity.SetValue(ds.Tables[0].Rows[0]["new_BicBankCity"]);
                    new_BicBankBranch.SetValue(ds.Tables[0].Rows[0]["New_BicBankBranchId"]);
                    BicBankChanged(null, null);
                }
                else
                {
                    var m = new MessageBox { Width = 400, Height = 120 };
                    var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_INCORRECT_BIC_CODE");
                    m.Show("", msg2);
                    return;
                }
            }
            else
            {
                var m = new MessageBox { Width = 400, Height = 120 };
                var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_INCORRECT_BIC_CODE");
                m.Show("", msg2);
                return;
            }

        }




    }

    void GetMessage()
    {
        var staticData = new StaticData();
        staticData.AddParameter("OperationType", DbType.Int32, 1);
        staticData.AddParameter("systemuserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));
        var msg = ValidationHelper.GetString(
                staticData.ExecuteScalar("EXEC spGetCountryTransferMessages @OperationType,@systemuserId"));
        var msgt = msg.Replace("*", "").Replace(" ", "");
        if (!string.IsNullOrEmpty(msgt))
            TuLabelMessage.Text = msg;

        QScript("try { window.top.R.WindowMng.getActiveWindow().setTitle(window.top.PnlCenter.title+" + BasePage.SerializeString("  [" + App.Params.CurrentUser.BusinessUnitIdName + " / " + App.Params.CurrentUser.FullName + "]") + "); } catch(err) { }");
    }

    bool CheckCalculation()
    {
        if (!string.IsNullOrEmpty(New_TransferId.Value) && string.IsNullOrEmpty(new_TargetTransactionTypeID.Value))
        {
            var dyfac = new DynamicFactory(ERunInUser.CalingUser);
            var dyentity = dyfac.RetrieveWithOutPlugin((int)TuEntityEnum.New_Transfer, ValidationHelper.GetGuid(New_TransferId.Value), new string[] { "new_TargetTransactionTypeID" });
            new_TargetTransactionTypeID.FillDynamicEntityData(dyentity);
        }


        if (ValidationHelper.GetGuid(new_CorporationCountryId.Value) == Guid.Empty)
        {
            ShowRequiredFields(new_CorporationCountryId.FieldLabel);
            return false;
        }
        if (ValidationHelper.GetGuid(new_CorporationID.Value) == Guid.Empty)
        {
            ShowRequiredFields(new_CorporationID.FieldLabel);
            return false;
        }
        if (ValidationHelper.GetGuid(new_TransactionTargetOptionID.Value) == Guid.Empty)
        {
            ShowRequiredFields(new_TransactionTargetOptionID.FieldLabel);
            return false;
        }
        if (ValidationHelper.GetGuid(new_TargetTransactionTypeID.Value) == Guid.Empty)
        {
            ShowRequiredFields(new_TargetTransactionTypeID.FieldLabel);
            return false;
        }
        if (ValidationHelper.GetGuid(new_RecipientCountryID.Value) == Guid.Empty)
        {
            ShowRequiredFields(new_RecipientCountryID.FieldLabel);
            return false;
        }
        if (ValidationHelper.GetGuid(new_AmountCurrency2.Value) == Guid.Empty)
        {
            ShowRequiredFields(new_AmountCurrency2.FieldLabel);
            return false;
        }
        return true;
    }

    void ReConfigureScreen()
    {
        var sd = new StaticData();
        sd.ClearParameters();
        var amount = ValidationHelper.GetDBDecimal(((CrmDecimalComp)new_Amount.Items[0]).Value);

        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));
        sd.AddParameter("ObjectId", DbType.Int32, TuEntityEnum.New_Transfer.GetHashCode());
        sd.AddParameter("Amount", DbType.Decimal, amount);
        sd.AddParameter("FromCurrencyID", DbType.Guid, ValidationHelper.GetDBGuid(new_AmountCurrency2.Value));
        var script = sd.ExecuteScalar(@"Exec spTUFormRequiredWf2 @SystemUserId,@ObjectId,@Amount,@FromCurrencyID").ToString();
        QScript(script);

        const string scriptt = "CheckAllControls();";
        QScript(scriptt);

        //QScript("alert(new_SenderID.getValue());");

        //QScript("Frame_PanelX2.new_SenderID.setValue('" + ValidationHelper.GetDBGuid("0BFC8B14-8671-43B6-B856-0A0A79D12F9B") + "');");

    }

    void ReConfigureScreen2()
    {
        var sd = new StaticData();
        sd.ClearParameters();
        var amount = ValidationHelper.GetDBDecimal(((CrmDecimalComp)new_Amount.Items[0]).Value);

        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));
        sd.AddParameter("ObjectId", DbType.Int32, TuEntityEnum.New_Transfer.GetHashCode());
        sd.AddParameter("Amount", DbType.Decimal, amount);
        sd.AddParameter("FromCurrencyID", DbType.Guid, ValidationHelper.GetDBGuid(new_AmountCurrency2.Value));
        sd.AddParameter("RecipientCorporationId", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCorporationId.Value));
        sd.AddParameter("RecipientCountryId", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCountryID.Value));
        var script = sd.ExecuteScalar(@"Exec spTUFormRequiredWf2_New @SystemUserId,@ObjectId,@Amount,@FromCurrencyID,@RecipientCorporationId,@RecipientCountryId").ToString();
        QScript(script);

        //const string scriptt = "CheckAllControls();"; Burayı kapamamızın nedeni yeni yapıya göre bu iş zaten ülke de tanımlanmayacak.
        //QScript(scriptt);

        //QScript("alert(new_SenderID.getValue());");

        //QScript("Frame_PanelX2.new_SenderID.setValue('" + ValidationHelper.GetDBGuid("0BFC8B14-8671-43B6-B856-0A0A79D12F9B") + "');");

    }

    private bool CheckNationality()
    {
        //İşlem yurt dışından yapılıyorsa TC Vatandaşlık No validasyon kontrolü yapma.
        if (!ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("TK_CONTROL_TC_SENDERIDENTIFICATION_NUMERIC", "false")))
        {
            return true;
        }
        SenderFactory senderService = new SenderFactory();
        string countryCode = senderService.GetUserCountryCode();
        if (countryCode != CountryShortCode.Turkey)
            return true;


        var staticData = new StaticData();
        staticData.AddParameter("SenderId", DbType.Guid, ValidationHelper.GetDBGuid(new_SenderID.Value));
        var continuee = ValidationHelper.GetBoolean(staticData.ExecuteScalar(@"declare @continue bit=1
                        declare @nationality nvarchar(50)
                        declare @IdendificationNumber nvarchar(50)
                        select @IdendificationNumber=new_SenderIdendificationNumber1,@nationality=new_NationalityIDName from vNew_Sender 
                        where New_SenderId=@SenderId
                        if(@nationality ='TC' or @nationality='Türkiye')
                        begin
                        	declare @isNumeric bit=0 
                        	set @isNumeric=ISNUMERIC(@IdendificationNumber)
                        	if (@isNumeric=1)
                        	begin
                        		set @continue=1
                        	end
                        	else
                        	begin 
                        		set @continue=0
                        	end
                        end
                        else	
                        begin
                        	set @continue=1
                        end
                        select @continue"));

        return continuee;
    }

    private string GetMultiplePhoneCodeCountries()
    {
        WebClient client = new WebClient();
        return client.DownloadString(App.Params.GetConfigKeyValue("ApplicationHTTPS") + "/ISV/TU/Handlers/PhoneCodeHandler.ashx?method=list");
    }

    #endregion

    #region Protected Methods

    protected void btnInformationOnEvent(object sender, AjaxEventArgs e)
    {
        var infoList = Info.GetEntityHelpsByName("TRANSFER_HELP", this);
        if (infoList == null) return;
        var b = HttpContext.Current;
        b.Response.ClearContent();
        b.Response.ClearHeaders();
        b.Response.Clear();
        var f = new FileInfo(Server.MapPath(infoList.Command));
        var fs = File.Open(Server.MapPath(infoList.Command), FileMode.Open);

        var ms = new MemoryStream();
        fs.CopyTo(ms);

        var buffer = ms.ToArray();

        b.Response.AddHeader("Content-Disposition", string.Format(CultureInfo.InvariantCulture, "attachment; filename=\"{0}\"", new object[] { f.Name }));
        var length = buffer.Length;
        b.Response.AddHeader("ContentLength", length.ToString(CultureInfo.InvariantCulture));
        if (buffer.Length > 0)
        {
            b.Response.BinaryWrite(buffer);
        }
        b.Response.Flush();
    }

    private void RefreshSenderPerson(Guid senderId)
    {

        var ms = new MessageBox { Modal = true };

        if (senderId != Guid.Empty)
        {
            var readonlyRealform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_PERSON_FORM"));
            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid",  readonlyRealform},
                                {"ObjectId",( (int)TuEntityEnum.New_SenderPerson).ToString()},
                                {"recid", senderId .ToString()},
                                {"mode", "-1"}
                            };

            var urlparam = QueryHelper.RefreshUrl(query);
            Panel_SenderPersonInformation.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            Panel_SenderPersonInformation.LoadUrl(Panel_SenderPersonInformation.AutoLoad.Url);
            SenderPersonInfo.Show();
            QScript(" R.reSize();");
        }
        else
        {
            if (senderId == Guid.Empty)
            {
                ms.MessageType = EMessageType.Error;
                ms.Show(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDER_NOT_FOUND"));
            }
        }
    }

    protected void btnSaveOnEvent(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(new_SenderID.Value))
        {
            var professionDb = new ProfessionDb();
            if (!professionDb.ExistsSenderProfessionInfo(ValidationHelper.GetGuid(new_SenderID.Value)))
            {
                QScript(string.Format("ShowProfession('{0}','{1}');", new_SenderID.Value, CrmLabel.TranslateMessage("CRM.NEW_PROFESSION_CONTROL_FORM")));
                return;
            }
        }

        if (ValidationHelper.GetBoolean(HdnIsPersonalSecuritySeen.Value, false))
        {
            if (!ValidationHelper.GetBoolean(new_IsPersonalSecurity.Value))
            {
                var m = new MessageBox { Width = 400, Height = 180 };
                string requiredmsg = "Kişisel Verilerin Korunması Kanunu Aydınlatma ve Açık Rıza Metni ve Muvafakatnamesi alanı zorunlu bir alandır. Lütfen ekranda yer alan ilgili butonu tıklayarak formun çıktısını alınız ve müşteriye imzalatınız.";
                m.Show(requiredmsg);
                return;
            }
        }
        if (!ValidationHelper.GetBoolean(new_IdentityWasSeen.Value))
        {
            var msg = CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED");
            var m = new MessageBox { Width = 400, Height = 180 };
            string requiredmsg = string.Format(msg, new_IdentityWasSeen.FieldLabel);
            var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_IDENTITY_WASNOT_SEEN");
            m.Show(msg, requiredmsg + "   " + msg2);
            return;
        }

        if (GetTransactionTypeCode(ValidationHelper.GetGuid(new_SourceTransactionTypeID.Value)) == "013")
        {
            if (string.IsNullOrEmpty(new_CustAccountId.Value))
            {
                var msg = CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED");
                var m = new MessageBox { Width = 400, Height = 180 };
                string requiredmsg = string.Format(msg, new_CustAccountId.FieldLabel);
                m.Show(msg, requiredmsg);
                return;
            }

            var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser);
            var de = dynamicFactory.RetrieveWithOutPlugin(TuEntityEnum.New_CustAccounts.GetHashCode(), ValidationHelper.GetGuid(new_CustAccountId.Value), new[] { "new_CustAccountCurrencyId",
            "new_Balance", "new_SenderId", "new_CustAccountTypeId" });
            var currency = de.GetLookupValue("new_CustAccountCurrencyId");
            var balance = de.GetDecimalValue("new_Balance");

            if (ValidationHelper.GetDecimal(balance, 0) == 0)
            {
                MessageBox m = new MessageBox();
                var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_INSUFFICIENT_FUNDS");
                m.Show(msg2);

                return;
            }
        }

        /*tyupt-792, eartport kullanılmadığı için şimdilik kapatıldı.*/

        //if ((new_RecipientAccountNumber.Value.Length > 34 || new_RecipientAccountNumber.Value.Length < 34) && new_RecipientCorporationIdHidden.Value.Length > 0)
        //{
        //    var staticData = new StaticData();
        //    staticData.AddParameter("RecipientCountryId", DbType.Guid, ValidationHelper.GetGuid(new_RecipientCountryID.Value));
        //    DataTable dt = staticData.ReturnDataset(@"Select * from vNew_Country(nolock)
        //                                            Where New_CountryId = @RecipientCountryId and new_CountryShortCode = 'IN' and DeletionStateCode = 0").Tables[0]; //Hindistan
        //    if (dt.Rows.Count > 0)
        //    {
        //        var m = new MessageBox { Width = 400, Height = 180 };
        //        var msg = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_THE_RECIPIENTACCOUNTNUMBER_CAN_BE_A_MAXIMUM_OF_34_CHARACTERS");
        //        m.Show(msg);
        //        return;
        //    }
        //}

        if (!CheckNationality())
        {
            var msg = CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED");
            var m = new MessageBox { Width = 400, Height = 180 };
            var msg2 = CrmLabel.TranslateMessage("CRM.NEW_SENDER_IDENDITYNO_MUST_BE_NUMBER");
            m.Show(msg, msg2);

            return;
        }

        //Singularity (tekillik) - Yabancı uyruklu gönderici için 32349 TL üzeri gönderimde YKN/VKN gerekiyor
        SenderFactory sc = new SenderFactory();
        SenderForeignIdentityIDControl sForeignControl = new SenderForeignIdentityIDControl
        {
            SenderID = ValidationHelper.GetGuid(new_SenderID.Value, Guid.Empty),
            Amount = ValidationHelper.GetDecimal(new_Amount.d1.Value, 0),
            CurrencyTypeID = ValidationHelper.GetGuid(new_Amount.c1.Value, Guid.Empty)
        };
        if (!sc.ControlForeignIdentityNoAndAmount(sForeignControl))
        {
            var msg = CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED");
            var m = new MessageBox { Width = 400, Height = 180 };
            var msg2 = CrmLabel.TranslateMessage("CRM.NEW_SENDER_FOREIGN_TRANSFERAMOUNT_REQUIRED");
            m.Show(msg, msg2);
            return;
        }

        bool isSendCorpAccount = false;

        if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
        {
            if (new_RecipientCorporationId.Value != null && new_RecipientCorporationId.Value != string.Empty && new_RecipientCorporationId.Value != "00000000-0000-0000-0000-000000000001")
            {
                isSendCorpAccount = true;
            }
            else if (!string.IsNullOrEmpty(new_RecipientCorporationId.Value) && new_RecipientCorporationId.Value == "00000000-0000-0000-0000-000000000001" && !string.IsNullOrEmpty(new_RecipientCorporationIdHidden.Value))
            {
                isSendCorpAccount = true;
            }

            string Recipient = ValidationHelper.GetString(new_RecipientName.Value) +
                           ValidationHelper.GetString(new_RecipientMiddleName.Value) +
                           ValidationHelper.GetString(new_RecipientLastName.Value);

        }

        if ((new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi) && !(Boolean.Parse(isEFTHiddenField.Value)) && !isSendCorpAccount)
        {
            //Swift isleminde IBAN biliniyorsa, banka adi ya da Swift kodu alanlarından en az bir doldurulmalidir.
            if (!new_IbanisNotKnown.Checked)
            {
                if (string.IsNullOrEmpty(new_BicCode.Value) && string.IsNullOrEmpty(new_BicBank.Value))
                {
                    var m = new MessageBox { Width = 400, Height = 160 };
                    var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SWIFT_IBAN_WARNING");
                    m.Show("", msg2);
                    return;
                }
            }

            //Swift kodunu kontrol et.
            if (!string.IsNullOrEmpty(new_BicCode.Value) && !CheckBicCode(new_BicCode.Value))
            {
                var m = new MessageBox { Width = 400, Height = 120 };
                var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_INCORRECT_BIC_CODE");
                m.Show("", msg2);
                return;
            }

            var staticData = new StaticData();
            staticData.ClearParameters();
            staticData.AddParameter("@SenderId", DbType.Guid, ValidationHelper.GetGuid(new_SenderID.Value));
            DataTable dataTable = staticData.ReturnDataset(@"Select * from vNew_Sender(nolock)
Where New_SenderId=@SenderId and Len(new_HomeAdress)<20 and DeletionStateCode = 0").Tables[0];
            if (dataTable.Rows.Count > 0)
            {
                var m = new MessageBox { Width = 400, Height = 180 };
                var msg2 = CrmLabel.TranslateMessage("CRM.NEW_SENDER_THE_SENDER_ADDRES_MUST_BE_AT_LEAST_20_CHARACTERS");
                m.Show(msg2);
                return;
            }
        }

        if ((new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi) && !(Boolean.Parse(isEFTHiddenField.Value)) && !isSendCorpAccount)
        {
            if (!new_IbanisNotKnown.Checked && !string.IsNullOrEmpty(new_RecipientBicIBAN.Value))
            {
                var dff = new DynamicFactory(ERunInUser.CalingUser);
                var trr = dff.RetrieveWithOutPlugin(TuEntityEnum.New_Country.GetHashCode(), ValidationHelper.GetGuid(new_RecipientCountryID.Value), new string[] { "new_CountryShortCode" });
                string countryShortCode = trr.GetStringValue("new_CountryShortCode");

                if (new_RecipientBicIBAN.Value.Length <= 1)
                {
                    var m = new MessageBox { Width = 400, Height = 180 };
                    var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_IBAN_COUNTRY_DIFFERENT");
                    m.Show(msg2);
                    return;
                }

                if (countryShortCode != new_RecipientBicIBAN.Value.Substring(0, 2).Trim())
                {
                    var m = new MessageBox { Width = 400, Height = 180 };
                    var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_IBAN_COUNTRY_DIFFERENT");
                    m.Show(msg2);
                    return;
                }
            }
        }
        else if ((new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi) && (Boolean.Parse(isEFTHiddenField.Value)) && !isSendCorpAccount)
        {
            if (!new_IbanisNotKnown.Checked && !string.IsNullOrEmpty(new_RecipientIBAN.Value))
            {
                var dff = new DynamicFactory(ERunInUser.CalingUser);
                var trr = dff.RetrieveWithOutPlugin(TuEntityEnum.New_Country.GetHashCode(), ValidationHelper.GetGuid(new_RecipientCountryID.Value), new string[] { "new_CountryShortCode" });
                string countryShortCode = trr.GetStringValue("new_CountryShortCode");

                if (new_RecipientIBAN.Value.Length <= 1)
                {
                    var m = new MessageBox { Width = 400, Height = 180 };
                    var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_IBAN_COUNTRY_DIFFERENT");
                    m.Show(msg2);
                    return;
                }

                if (countryShortCode != new_RecipientIBAN.Value.Substring(0, 2).Trim())
                {
                    var m = new MessageBox { Width = 400, Height = 180 };
                    var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_IBAN_COUNTRY_DIFFERENT");
                    m.Show(msg2);
                    return;
                }
            }
        }

        if ((new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi) && !(string.IsNullOrEmpty(new_RecipientCorporationIdHidden.Value)))
        {
            DataTable dtRequiredFieldsByCountry = GetRequiredFieldsByCountry();
            var rows = dtRequiredFieldsByCountry.Select("UniqueName = 'RecipientBicIban'");

            if (rows != null && rows.Length > 0)
            {
                if (!string.IsNullOrEmpty(new_RecipientBicIBAN.Value))
                {
                    var dff = new DynamicFactory(ERunInUser.CalingUser);
                    var trr = dff.RetrieveWithOutPlugin(TuEntityEnum.New_Country.GetHashCode(), ValidationHelper.GetGuid(new_RecipientCountryID.Value), new string[] { "new_CountryShortCode" });
                    string countryShortCode = trr.GetStringValue("new_CountryShortCode");

                    if (new_RecipientBicIBAN.Value.Length <= 1)
                    {
                        var m = new MessageBox { Width = 400, Height = 180 };
                        var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_IBAN_COUNTRY_DIFFERENT");
                        m.Show(msg2);
                        return;
                    }

                    if (countryShortCode != new_RecipientBicIBAN.Value.Substring(0, 2).Trim())
                    {
                        var m = new MessageBox { Width = 400, Height = 180 };
                        var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_IBAN_COUNTRY_DIFFERENT");
                        m.Show(msg2);
                        return;
                    }
                }
            }
        }

        var serialNumber = DynamicDb.GetSequenceId("DKT", null);
        if (string.IsNullOrEmpty(serialNumber))
        {
            var m = new MessageBox { Width = 400, Height = 180 };
            m.Show("Unable to create the serial number");
            return;
        }

        StaticData sd = new StaticData();

        string senderCity = ValidationHelper.GetString(sd.ExecuteScalar(@"
        SELECT ISNULL(o.new_CityIdName,'ISTANBUL') 
          FROM vSystemUser s (NOLOCK) 
    INNER JOIN vNew_Office o (nolock) on s.new_OfficeID = o.New_OfficeId
         WHERE s.SystemUserId = '" + (ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId.ToString() : HdnOtherSerderCorporationUserId.Value)
       + "'AND s.DeletionStateCode = 0"));

        var dft = new DynamicFactory(ERunInUser.CalingUser);
        var trt = dft.RetrieveWithOutPlugin(TuEntityEnum.New_Sender.GetHashCode(),
            ValidationHelper.GetGuid(new_SenderID.Value), new string[] { "new_NationalityID", "new_SenderIdendificationNumber1", "new_Name", "new_MiddleName",
                "new_LastName", "new_GSMCountryId", "new_GSM", "new_HomeAdress", "new_BirthDate", "new_FatherName","new_BirthPlace","new_HomeCountry", "new_HomeCity" });
        //string countryShortCode = trr.GetStringValue("new_CountryShortCode");


        //--------------------------------------------------------- Validasyon bitiş



        try
        {
            if (string.IsNullOrEmpty(TransferTuRef.Value))
            {
                TransferTuRef.Value = SequenceCreater.NewId("TR");
            }

            if (!CheckCalculation())
            {
                return;
            }

            var de = new DynamicEntity(TuEntityEnum.New_Transfer.GetHashCode());

            if (!string.IsNullOrEmpty(New_TransferId.Value))
            {
                Transaction.TransferId = ValidationHelper.GetGuid(New_TransferId.Value);
            }

            Transaction.TransferTuRef = TransferTuRef.Value;

            if (!string.IsNullOrEmpty(HdnIntegrationSessionIdentity.Value))
            {
                Transaction.IntegrationSessionIdentity = HdnIntegrationSessionIdentity.Value;
            }

            if (ValidationHelper.GetDecimal(HdnPartnerExpense.Value, 0) > 0)
            {
                Transaction.CustomExpense = new Money()
                {
                    Amount = ValidationHelper.GetDecimal(HdnPartnerExpense.Value, 0),
                    Currency = new Currency() { ISOCurrencyCode = HdnPartnerExpenseCurrency.Value, CurrencyId = UPTCache.CurrencyService.GetCurrencyByCurrencyCode(HdnPartnerExpenseCurrency.Value).CurrencyId }
                };
            }


            Transaction.SenderCorporationCountry = new Country() { CountryId = ValidationHelper.GetGuid(new_CorporationCountryId.Value) };
            Transaction.OtherSerderCorporationUserId = ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty);

            if (new_RecipientCorporationId.Value != "00000000-0000-0000-0000-000000000001")
            {
                Transaction.RecipientCorporation = new Corporation() { CorporationId = ValidationHelper.GetGuid(new_RecipientCorporationId.Value) };
            }
            else if (new_RecipientCorporationId.Value == "00000000-0000-0000-0000-000000000001" && !string.IsNullOrEmpty(new_RecipientCorporationIdHidden.Value))
            {
                Transaction.RecipientCorporation = new Corporation() { CorporationId = ValidationHelper.GetGuid(new_RecipientCorporationIdHidden.Value) };
            }
            else
            {
                Transaction.RecipientCorporation = new Corporation() { CorporationId = Guid.Empty };
            }

            Transaction.SenderCountry = new Country(ValidationHelper.GetGuid(new_SenderCountryID.Value), true);
            Transaction.SenderCorporation = new Corporation() { CorporationId = ValidationHelper.GetGuid(new_CorporationID.Value) };
            Transaction.RecipientRegionId = ValidationHelper.GetGuid(new_RecipientRegionId.Value);
            Transaction.RecipientCityId = ValidationHelper.GetGuid(new_RecipientCityId.Value);
            Transaction.BrandId = ValidationHelper.GetGuid(new_BrandId.Value);
            Transaction.RecipientOffice = new Office() { OfficeId = ValidationHelper.GetGuid(new_RecipientOfficeId.Value) };
            Transaction.SenderOffice = new Office() { OfficeId = ValidationHelper.GetGuid(new_OfficeID.Value), OwnOfficeCode = HdnOwnOfficeCode.Value, ReferenceCode = HdnOfficeReferenceCode.Value };
            Transaction.SourceTransactionType = new TransactionType() { TransactionTypeId = ValidationHelper.GetGuid(new_SourceTransactionTypeID.Value) };
            Transaction.RecipientCountry = new Country(ValidationHelper.GetGuid(new_RecipientCountryID.Value), true);
            Transaction.TargetTransactionType = new TransactionType() { TransactionTypeId = ValidationHelper.GetGuid(new_TargetTransactionTypeID.Value) };

            Transaction.Sender = new Sender()
            {
                SenderId = ValidationHelper.GetGuid(new_SenderID.Value),
                Nationality = new Nationality(trt.GetLookupValue("new_NationalityID"), true)
            };

            /*Sender bilgilerini objenin üzerine setler.*/
            new SenderManager().SetSender(Transaction);

            if (!_userApproval.UsersForRecipients)
            {
                Transaction.Recipient = new Recipient() { RecipientId = ValidationHelper.GetGuid(new_RecipientID.Value) };
            }

            Transaction.Explanation = ValidationHelper.GetString(new_Explanation.Value);
            Transaction.TransactionTargetOptionID = ValidationHelper.GetGuid(new_TransactionTargetOptionID.Value);
            Transaction.RecipientGsmCountry = new Country() { CountryId = ValidationHelper.GetGuid(new_RecipientGSMCountryId.Value) };
            Transaction.RecipientGSM = ValidationHelper.GetString(new_RecipientGSM.Value);
            Transaction.RecipientFatherName = ValidationHelper.GetString(new_RecipientFatherName.Value);
            Transaction.RecipientMotherName = ValidationHelper.GetString(new_RecipientMotherName.Value);
            Transaction.RecipientName = ValidationHelper.GetString(new_RecipientName.Value);
            Transaction.RecipientMiddleName = ValidationHelper.GetString(new_RecipientMiddleName.Value);
            Transaction.RecipientLastName = ValidationHelper.GetString(new_RecipientLastName.Value);
            Transaction.RecipientSave = true;
            Transaction.RecipientEmail = ValidationHelper.GetString(new_RecipientEmail.Value);
            Transaction.RecipientNickName = ValidationHelper.GetString(new_RecipienNickName.Value);

            if (hdnRecipientAddressVisible.Value == "true")
            {
                Transaction.RecipientAddress = ValidationHelper.GetString(new_RecipientAddress.Value);
            }


            Transaction.TestQuestion = new TestQuestion() { TestQuestionId = ValidationHelper.GetGuid(new_TestQuestionID.Value) };
            Transaction.TestQuestionReply = ValidationHelper.GetString(new_TestQuestionReply.Value);
            Transaction.RecipientBirthDate = ValidationHelper.GetDate(new_RecipientBirthDate.Value);
            Transaction.MoneySourceOther = ValidationHelper.GetString(new_MoneySourceOther.Value);
            Transaction.TransferReasonOther = ValidationHelper.GetString(new_TransferReasonOther.Value);
            Transaction.SenderIdentificationCardNo = ValidationHelper.GetString(new_SenderIdentificationCardNo.Value);
            Transaction.SenderIdentificationCardType = new TuFactory.Domain.IdentificationCardType(ValidationHelper.GetGuid(new_SenderIdentificationCardTypeID.Value), true);
            Transaction.SenderNationality = new Nationality(ValidationHelper.GetGuid(trt.GetLookupValue("new_NationalityID")), true);
            Transaction.SenderIdendificationNumber1 = ValidationHelper.GetString(trt.GetStringValue("new_SenderIdendificationNumber1"));
            Transaction.SenderName = ValidationHelper.GetString(trt.GetStringValue("new_Name"));
            Transaction.SenderBirthDate = ValidationHelper.GetDate(trt.GetDateTimeValue("new_BirthDate"));
            Transaction.SenderBirthPlace = ValidationHelper.GetString(trt.GetStringValue("new_BirthPlace"));
            Transaction.SenderFatherName = ValidationHelper.GetString(trt.GetStringValue("new_FatherName"));
            Transaction.SenderMiddleName = ValidationHelper.GetString(trt.GetStringValue("new_MiddleName"));
            Transaction.SenderLastName = ValidationHelper.GetString(trt.GetStringValue("new_LastName"));
            Transaction.SenderGsmCountry = new Country() { CountryId = ValidationHelper.GetGuid(trt.GetLookupValue("new_GSMCountryId")) };
            Transaction.SenderGsm = ValidationHelper.GetString(trt.GetStringValue("new_GSM"));
            Transaction.SenderHomeAdress = ValidationHelper.GetString(trt.GetStringValue("new_HomeAdress"));
            Transaction.SenderHomeCity = ValidationHelper.GetString(trt.GetStringValue("new_HomeCity"));
            Transaction.SenderHomeCountry = ValidationHelper.GetGuid(trt.GetLookupValue("new_HomeCountry"));
            Transaction.ValidDateOfSenderIdentificationCard = ValidationHelper.GetDate(new_ValidDateOfSenderIdentificationCard.Value);
            Transaction.DateOfIdendity = ValidationHelper.GetDate(new_DateOfIdendity.Value);
            Transaction.TransferReason = new TransferReason() { TransferReasonId = ValidationHelper.GetGuid(new_TransferReasonID.Value) };
            Transaction.MoneySource = new MoneySource() { MoneySourceId = ValidationHelper.GetGuid(new_MoneySourceID.Value) };
            Transaction.IbanisNotKnown = ValidationHelper.GetBoolean(new_IbanisNotKnown.Checked);
            Transaction.ConfirmStatus = new ConfirmStatus() { ConfirmStatusId = ValidationHelper.GetGuid(TransferType.GonderimYeniKayit) };


            DateTime valueDate = DateTime.UtcNow;
            if (new_TransactionTargetOptionID.Value != TransferType.IsmeGonderim)
            {
                valueDate = ValidationHelper.GetDate((new TransferPageFactory()).GetValueDate(ValidationHelper.GetGuid(new_AmountCurrency2.Value), Transaction.TransferId));
            }


            Transaction.ValueDate = valueDate;//ValidationHelper.GetDate((new TransferPageFactory()).GetValueDate(ValidationHelper.GetGuid(new_AmountCurrency2.Value), Transaction.TransferId));

            Transaction.CorpSendAccountNumber = ValidationHelper.GetString(new_CorpSendAccountNumber.Value);
            Transaction.SerialNumber = serialNumber;
            Transaction.Channel = 1;
            Transaction.CustChargeAmount = ValidationHelper.GetDecimal(new_CustChargeAmount.Value, 0);
            //Transaction.IsPersonalSecurity = ValidationHelper.GetBoolean(new_IsPersonalSecurity.Value, false);

            Transaction.ReceivedAmount1 = new ConvertedMoney()
            {
                Amount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_ReceivedAmount1.Items[0]).Value, 0),
                Currency = new Currency()
                {
                    CurrencyId = ValidationHelper.GetGuid(((CrmComboComp)new_ReceivedAmount1.Items[1]).Value)
                }
            };

            Transaction.CalculatedExpenseAmount = new ConvertedMoney
            {
                Amount = ValidationHelper.GetDecimal(new_CalculatedExpenseAmount.d1.Value, 0),
                Currency = new Currency()
                {
                    CurrencyId = ValidationHelper.GetGuid(new_CalculatedExpenseAmount.c1.Value)
                }
            };

            Transaction.CollectionMethod = (TransferCollectionMethod)ValidationHelper.GetInteger(new_CollectionMethod.Value);

            if (!string.IsNullOrEmpty(new_CustAccountId.Value))
            {
                Transaction.CustAccountId = ValidationHelper.GetGuid(new_CustAccountId.Value);
            }
            if (!string.IsNullOrEmpty(new_SenderPersonId.Value))
            {
                Transaction.SenderPersonId = ValidationHelper.GetGuid(new_SenderPersonId.Value);
            }

            if (HdnStartTransactionForOtherCorp.Value == "1")
            {
                Transaction.OptionalCorporation = new Corporation() { CorporationId = ValidationHelper.GetGuid(new_CorporationID.Value) };
                Transaction.OriginalRecordOwner = new SystemUser() { SystemUserId = ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId) };
                Transaction.IsOpsTransaction = true;
            }

            //İlgiz: Earthport için eklenen alanlar
            Transaction.RecipientBankName = ValidationHelper.GetString(new_BicBankHidden.Value);
            Transaction.RecipientAccountName = ValidationHelper.GetString(new_RecipientAccountName.Value);
            Transaction.RecipientAccountType = ValidationHelper.GetString(new_RecipientAccountType.Value);
            Transaction.RecipientCity = ValidationHelper.GetString(new_RecipientCity.Value);
            Transaction.RecipientABACode = ValidationHelper.GetString(new_RecipientABACode.Value);
            Transaction.RecipientSortCode = ValidationHelper.GetString(new_RecipientSortCode.Value);


            Transaction.SenderCity = senderCity;
            Transaction.ChangedObject = "new_ReceivedAmount1";

            Transaction.Amount = new Money()
            {
                Amount = (decimal)((CrmDecimalComp)new_Amount.Items[0]).Value,
                Currency = new Currency()
                {
                    CurrencyId = ValidationHelper.GetGuid(((CrmComboComp)new_Amount.Items[1]).Value)
                }
            };

            if ((float)((CrmDecimalComp)new_Amount.Items[0]).Value > 0)
            {
                Transaction.ReceivedPaymentAmount = new Money()
                {
                    Amount = (decimal)((CrmDecimalComp)new_ReceivedPaymentAmount.Items[0]).Value,
                    Currency = new Currency()
                    {
                        CurrencyId = ValidationHelper.GetGuid(((CrmComboComp)new_ReceivedPaymentAmount.Items[1]).Value)
                    }
                };

                Transaction.ReceivedPaymentOriginalAmount = new Money()
                {
                    Amount = (decimal)((CrmDecimalComp)new_ReceivedPaymentOriginalAmount.Items[0]).Value,
                    Currency = new Currency()
                    {
                        CurrencyId = ValidationHelper.GetGuid(((CrmComboComp)new_ReceivedPaymentOriginalAmount.Items[1]).Value)
                    }
                };


                Transaction.ReceivedPaymentAmountParity = ValidationHelper.GetDouble(ValidationHelper.GetDecimal(new_ReceivedPaymentAmountParity.Value, 0), 0);
                Transaction.ReceivedPaymentOriginalAmountParity = ValidationHelper.GetDouble(ValidationHelper.GetDecimal(new_ReceivedPaymentOriginalAmountParity.Value, 0), 0);

                Transaction.ReceivedPaymentAmountParityRateType = new TuFactory.Domain.ExchangeRate.ExchangeRateType()
                {
                    ExchangeRateTypeId = ValidationHelper.GetGuid(new_ReceivedPaymentAmountParityRateType.Value)
                };
            }

            /*Isme Gondeirmlerin disindaki her islemde kaydedilmesi zorunlu bir alanldir.*/
            if (new_TransactionTargetOptionID.Value != TransferType.IsmeGonderim)
            {
                Transaction.EftPaymentMethod = new TuFactory.Domain.Eft.EftPaymentMethod()
                {
                    EftPaymentMethodId = ValidationHelper.GetGuid(new_EftPaymentMethodID.Value)
                };
            }

            Transaction.IsEft = Boolean.Parse(isEFTHiddenField.Value);

            if (ValidationHelper.GetBoolean(new_IbanisNotKnown.Checked) || new_TransactionTargetOptionID.Value == TransferType.KartaGonderim)
            {
                if (Boolean.Parse(isEFTHiddenField.Value)) //EFT
                {
                    Transaction.EftCity = new TuFactory.Domain.Eft.EftCity() { CityId = ValidationHelper.GetGuid(new_EftCity.Value) };
                    Transaction.EftBank = new TuFactory.Domain.Eft.EftBank() { EftBankId = ValidationHelper.GetGuid(new_EftBank.Value) };
                    Transaction.EftBranch = new TuFactory.Domain.Eft.EftBranch() { EftBranchId = ValidationHelper.GetGuid(new_EftBranch.Value) };
                }
                else //SWIFT
                {
                    Transaction.BicBank = new TuFactory.Domain.Swift.BicBank() { BicBankId = ValidationHelper.GetGuid(new_BicBank.Value) };
                    Transaction.BicBankCity = new TuFactory.Domain.Swift.BicBankCity() { BicBankCityId = ValidationHelper.GetGuid(new_BicBankCity.Value) };
                    Transaction.BicBankBranch = new TuFactory.Domain.Swift.BicBankBranch() { BicBankBranchId = ValidationHelper.GetGuid(new_BicBankBranch.Value) };
                    Transaction.BicCode = ValidationHelper.GetString(new_BicCode.Value);
                }

                Transaction.RecipientIban = "";
                Transaction.RecipientBicIban = "";

                if (new_TransactionTargetOptionID.Value == TransferType.KartaGonderim)
                {
                    Transaction.RecipientAccountNumber = "";
                    Transaction.RecipientBicAccountNumber = "";
                    Transaction.RecipientCardNumber = ValidationHelper.EncryptString(new_RecipientCardNumber.Value);
                }
                if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim || new_TransactionTargetOptionID.Value == TransferType.AktifbankOdemesi)
                {
                    if (Boolean.Parse(isEFTHiddenField.Value)) //EFT
                    {
                        Transaction.RecipientAccountNumber = ValidationHelper.GetString(new_RecipientAccountNumber.Value);
                        Transaction.RecipientBicAccountNumber = "";
                        Transaction.RecipientCardNumber = "";
                    }
                    else
                    {
                        Transaction.RecipientBicAccountNumber = ValidationHelper.GetString(new_RecipientBicAccountNumber.Value);
                        Transaction.RecipientAccountNumber = "";
                        Transaction.RecipientCardNumber = "";
                    }
                }

                Transaction.RecipientCardNumberShown = GetHiddenCardNumber(ValidationHelper.GetString(new_RecipientCardNumber.Value));
            }
            else
            {
                if (Boolean.Parse(isEFTHiddenField.Value)) //EFT 
                {
                    Transaction.RecipientIban = ValidationHelper.GetString(new_RecipientIBAN.Value);
                }
                else
                {
                    Transaction.BicBank = new TuFactory.Domain.Swift.BicBank { BicBankId = ValidationHelper.GetGuid(new_BicBank.Value) };
                    Transaction.BicBankCity = new TuFactory.Domain.Swift.BicBankCity() { BicBankCityId = ValidationHelper.GetGuid(new_BicBankCity.Value) };
                    Transaction.BicBankBranch = new TuFactory.Domain.Swift.BicBankBranch() { BicBankBranchId = ValidationHelper.GetGuid(new_BicBankBranch.Value) };
                    Transaction.BicCode = ValidationHelper.GetString(new_BicCode.Value, null);
                    Transaction.RecipientBicIban = ValidationHelper.GetString(new_RecipientBicIBAN.Value);
                    Transaction.RecipientAccountNumber = ValidationHelper.GetString(new_RecipientAccountNumber.Value);
                }
            }

            // TYUPT-2359 - Rusya banka hesabına Contact kurumu ile gönderim yapılabilmesi
            if (new_TransactionTargetOptionID.Value == TransferType.HesabaGonderim)
            {
                Transaction.IntegrationRecipientType = ValidationHelper.GetInteger(new_IntegrationRecipientType.Value, 1);
                Transaction.IntegrationRecipientRussianBicCode = ValidationHelper.GetString(new_IntegrationRecipientRussianBicCode.Value);
                Transaction.IntegrationRecipientTaxNumber = ValidationHelper.GetString(new_IntegrationRecipientTaxNumber.Value);
                Transaction.IntegrationRecipientRegistrationReasonCode = ValidationHelper.GetString(new_IntegrationRecipientRegistrationReasonCode.Value);
            }
            //

            #region BlackList Data Set ediliyor


            Transaction.Sender.GSM = new Telephone()
            {
                Country = Transaction.SenderGsmCountry,
                PhoneNumber = Transaction.SenderGsm
            };

            Transaction.Sender.Name = Transaction.SenderName;
            Transaction.Sender.MiddleName = Transaction.SenderMiddleName;
            Transaction.Sender.LastName = Transaction.SenderLastName;
            Transaction.Sender.SenderIdentificationNumber1 = Transaction.SenderIdendificationNumber1;
            Transaction.Sender.BirthDate = Transaction.SenderBirthDate;
            Transaction.Sender.FatherName = Transaction.SenderFatherName;


            Transaction.Recipient.FirstName = Transaction.RecipientName;
            Transaction.Recipient.LastName = Transaction.RecipientLastName;
            Transaction.Recipient.MiddleName = Transaction.RecipientMiddleName;
            Transaction.Recipient.BirthDate = Transaction.RecipientBirthDate;
            Transaction.Recipient.FatherName = Transaction.RecipientFatherName;

            Transaction.Recipient.GSM = new TuFactory.Domain.Telephone()
            {
                Country = Transaction.RecipientGsmCountry,
                PhoneNumber = Transaction.RecipientGSM
            };

            if (QueryHelper.GetString("fromCheckCredit") == "1" && !String.IsNullOrEmpty(QueryHelper.GetString("creditDataID")))
            {
                Transaction.IsCreditPayment = true;
                Transaction.CreditDataId = ValidationHelper.GetGuid(QueryHelper.GetString("creditDataID"));
            }

            #endregion

            string returnMessage = new TuFactory.TransactionManagers.Transfer.TransferManager().TransferRequest(Transaction);
            if (!String.IsNullOrEmpty(returnMessage))
            {
                MessageBox messageBox = new MessageBox();
                messageBox.Show(returnMessage);
                return;
            }

            var formId = ParameterFactory.GetParameterValue("CRM_TU_TRANSFER_RESULT_FORMID");
            var url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx");
            Page.Response.Redirect(string.Format("{0}?defaulteditpageid={1}&ObjectId=201100072&mode=1&recid={2}", url, formId, Transaction.TransferId));
        }
        catch (TuException tt)
        {
            e.Message = tt.ErrorMessage;
            e.Success = false;
        }
        catch (Exception ex)
        {
            e.Message = ex.Message;
            e.Success = false;
        }
    }

    protected void CalculateOnEvent(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(new_SenderID.Value))
        {
            var professionDb = new ProfessionDb();
            if (!professionDb.ExistsSenderProfessionInfo(ValidationHelper.GetGuid(new_SenderID.Value)))
            {
                QScript(string.Format("ShowProfession('{0}','{1}');", new_SenderID.Value, CrmLabel.TranslateMessage("CRM.NEW_PROFESSION_CONTROL_FORM")));
            }
        }

        /*Moneygram için masrafı kurumdan çekip ekrana setleyecez. */
        decimal partnerExpenseAmount = 0;
        string partnerExpenseAmountCurrencyCode = string.Empty;

        //partnerExpenseAmount = DateTime.Now.Millisecond;
        //partnerExpenseAmountCurrencyCode = "USD";

        if (!string.IsNullOrEmpty(new_RecipientCorporationId.Value) && ValidationHelper.GetDecimal(((CrmDecimalComp)new_Amount.Items[0]).Value, 0) > 0 && ValidationHelper.GetGuid(new_Amount.c1.Value) != Guid.Empty)
        {
            var i3rd = new TuFactory.Integration3rd.Integration3Rd();
            ExpenseReturnType partnerExpense = i3rd.IntegrateGetExpense(new ExpenseRequestType()
            {

                recipientCorporationId = ValidationHelper.GetGuid(new_RecipientCorporationId.Value),
                amount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_Amount.Items[0]).Value, 0),
                receiveCountryCode = UPTCache.CountryService.GetCountryByCountryId(ValidationHelper.GetGuid(new_RecipientCountryID.Value)).IsoCode3,
                receiveCurrencyCode = UPTCache.CurrencyService.GetCurrencyByCurrencyId(ValidationHelper.GetGuid(new_Amount.c1.Value)).ISOCurrencyCode,
                sendCurrencyCode = UPTCache.CurrencyService.GetCurrencyByCurrencyId(ValidationHelper.GetGuid(new_Amount.c1.Value)).ISOCurrencyCode
            }, null
            );

            if (partnerExpense != null && partnerExpense.OutputStatus.RESPONSE == IntegrationStatus.response.Success)
            {
                HdnIntegrationSessionIdentity.SetValue(partnerExpense.PartnerSessionId);
                HdnPartnerExpense.SetValue(partnerExpense.partnerExpense.ExpenseAmount);
                HdnPartnerExpense.SetIValue(partnerExpense.partnerExpense.ExpenseAmount);
                //HdnPartnerExpense.Value = partnerExpense.partnerExpense.ExpenseAmount.ToString();
                HdnPartnerExpenseCurrency.SetValue(partnerExpense.partnerExpense.ExpenseAmountCurrencyCode);

                partnerExpenseAmount = partnerExpense.partnerExpense.ExpenseAmount;
                partnerExpenseAmountCurrencyCode = partnerExpense.partnerExpense.ExpenseAmountCurrencyCode;


            }
        }

        ExpenseProcessor();

        /* Müşteriden aydınlatma yükümlülüğü formu alındı mı bilgisini önceki transfer kayıtlarında varsa çekiliyor */
        bool IsPersonalSecurity = GetIsPersonalSecurityInfo(ValidationHelper.GetGuid(string.IsNullOrEmpty(new_SenderID.Value) ? QueryHelper.GetString("senderID") : new_SenderID.Value));
        if (!new_IsPersonalSecurity.Checked)
        {
            new_IsPersonalSecurity.SetIValue(IsPersonalSecurity);
        }
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

        var sd = new StaticData();

        try
        {
            var ramount = ValidationHelper.GetDBDecimal(((CrmDecimalComp)new_ReceivedAmount1.Items[0]).Value);
            var amount = ValidationHelper.GetDBDecimal(((CrmDecimalComp)new_Amount.Items[0]).Value);
            if (amount == null || amount == DBNull.Value)
                return;


            if (!CheckCalculation())
                return;

            var changedObject = string.Empty;
            if (sender.GetType() == typeof(CrmDecimalComp))
                changedObject = ((CrmDecimalComp)(sender)).UniqueName;
            if (sender.GetType() == typeof(CrmComboComp))
                changedObject = ((CrmComboComp)(sender)).UniqueName;
            if (sender.GetType() == typeof(CrmPicklistComp))
                changedObject = ((CrmPicklistComp)(sender)).UniqueName;

            sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));
            sd.AddParameter("CountryID", DbType.Guid, ValidationHelper.GetDBGuid(new_CorporationCountryId.Value));
            sd.AddParameter("CorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_CorporationID.Value));
            sd.AddParameter("TransactionTypeID", DbType.Guid, ValidationHelper.GetDBGuid(new_TargetTransactionTypeID.Value));
            sd.AddParameter("RecipientCountryID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCountryID.Value));
            sd.AddParameter("Amount", DbType.Decimal, amount);
            sd.AddParameter("AmountCurrency", DbType.Guid, ValidationHelper.GetDBGuid(new_AmountCurrency2.Value));
            sd.AddParameter("ReceivedAmount1Currency", DbType.Guid, ValidationHelper.GetDBGuid(((CrmComboComp)new_ReceivedAmount1.Items[1]).Value));
            sd.AddParameter("ReceivedAmount1", DbType.Decimal, ramount);
            sd.AddParameter("TransferId", DbType.Guid, DBNull.Value);
            sd.AddParameter("SenderId", DbType.Guid, ValidationHelper.GetDBGuid(new_SenderID.Value));
            sd.AddParameter("CollectionMethod", DbType.Int32, ValidationHelper.GetInteger(new_CollectionMethod.Value));
            sd.AddParameter("ChangedObject", DbType.String, changedObject);

            //if (((Coretech.Crm.Web.UI.RefleX.AutoGenerate.CrmDecimalComp)sender).UniqueName != "new_Amount")
            if (!isNewAmount)
            {
                sd.AddParameter("CustomExpense", DbType.Decimal, new_CalculatedExpenseAmount.d1.Value);
                sd.AddParameter("CustomExpenseCurrency", DbType.Guid, ValidationHelper.GetDBGuid(new_CalculatedExpenseAmount.c1.Value));
            }


            if (partnerExpenseAmount > 0)
            {
                sd.AddParameter("CustomExpense", DbType.Decimal, partnerExpenseAmount);
                sd.AddParameter("CustomExpenseCurrency", DbType.Guid, ValidationHelper.GetDBGuid(UPTCache.CurrencyService.GetCurrencyByCurrencyCode(partnerExpenseAmountCurrencyCode).CurrencyId));
            }



            sd.AddParameter("TransactionTargetOptionId", DbType.Guid, ValidationHelper.GetDBGuid(new_TransactionTargetOptionID.Value));
            sd.AddParameter("RecipientCorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCorporationId.Value));
            sd.AddParameter("EftBank", DbType.Guid, ValidationHelper.GetDBGuid(new_EftBank.Value));

            var result = sd.ReturnDatasetSp(@"SpTuCalculate").Tables[0];

            if (result.Rows.Count > 0)
            {
                if (result.Columns.Contains("ErrorMessage"))
                {
                    var message = result.Rows[0]["ErrorMessage"].ToString();
                    if (result.Columns.Contains("CalculatedExpenseAmount"))
                    {
                        new_ExpenseAmount.Items[0].SetValue(ValidationHelper.GetDecimal(result.Rows[0]["CalculatedExpenseAmount"], 0));
                        new_ReceivedAmount1.d1.SetValue(ValidationHelper.GetDecimal(result.Rows[0]["new_ReceivedAmount1"], 0));
                    }
                    //new_ReceivedAmount1.c1.SetValue(ValidationHelper.GetString(result.Rows[0]["new_ReceivedAmount1Text"]));
                    var msg = new MessageBox { Width = 500 };
                    msg.Show(message);
                }
                else
                {
                    new_AmountOld.SetValue(((CrmDecimalComp)new_Amount.Items[0]).Value);

                    new_ReceivedAmount1.Items[0].SetValue(ValidationHelper.GetDecimal(result.Rows[0]["TAHSILTUTARI"], 0));
                    new_ReceivedAmount1.c1.SetValue(ValidationHelper.GetString(result.Rows[0]["TAHSILTUTARIDOVIZ"]), ValidationHelper.GetString(result.Rows[0]["TAHSILTUTARIDOVIZTEXT"]));

                    new_ReceivedExpenseAmount.Items[0].SetValue(ValidationHelper.GetDecimal(result.Rows[0]["NETMASRAFTUTARI"], 0));
                    new_ReceivedExpenseAmount.Items[1].SetValue(ValidationHelper.GetString(result.Rows[0]["NETMASRAFTUTARIDOVIZ"]));

                    new_ExpenseAmount.Items[0].SetValue(ValidationHelper.GetDecimal(result.Rows[0]["INDIRIMLIMASRAFTUTARI"], 0));
                    new_ExpenseAmount.Items[1].SetValue(ValidationHelper.GetString(result.Rows[0]["INDIRIMLIMASRAFTUTARIDOVIZ"]));

                    if (new_CalculatedExpenseCurrencyDefaultValue.Value != ValidationHelper.GetString(result.Rows[0]["MASRAFTUTARIDOVIZ"]) || new_CalculatedExpenseAmountDefaultValue.Value == "0" || new_CalculatedExpenseAmountDefaultValue.Value == string.Empty)
                    {
                        new_CalculatedExpenseAmountDefaultValue.Value = ValidationHelper.GetDecimal(result.Rows[0]["MASRAFTUTARI"], 0).ToString();
                        new_CalculatedExpenseCurrencyDefaultValue.Value = ValidationHelper.GetString(result.Rows[0]["MASRAFTUTARIDOVIZ"]);
                        new_CalculatedExpenseAmountDefaultValue.SetIValue(ValidationHelper.GetDecimal(result.Rows[0]["MASRAFTUTARI"], 0));
                        new_CalculatedExpenseCurrencyDefaultValue.SetIValue(ValidationHelper.GetString(result.Rows[0]["MASRAFTUTARIDOVIZ"]));
                    }

                    new_CalculatedExpenseAmount.Items[0].SetIValue(ValidationHelper.GetDecimal(result.Rows[0]["MASRAFTUTARI"], 0));
                    new_CalculatedExpenseAmount.Items[1].SetIValue(ValidationHelper.GetString(result.Rows[0]["MASRAFTUTARIDOVIZ"]));


                    new_TotalReceivedAmount.Items[0].SetValue(ValidationHelper.GetDecimal(result.Rows[0]["TOPLAMTAHSIL"], 0));
                    new_TotalReceivedAmount.Items[1].SetValue(ValidationHelper.GetString(result.Rows[0]["TOPLAMTAHSILDOVIZ"]));

                    Parity1.Clear();
                    Parity1.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaymentCurrencyParity1", TuEntityEnum.New_Transfer.GetHashCode()) + "&nbsp;&nbsp;" +
                        Math.Round(ValidationHelper.GetDecimal(result.Rows[0]["new_TransferPaymentCurrencyParity1"], 0), 6).ToString());
                    if (_IsPartlyCollection)
                    {
                        Parity2.Clear();
                        new_ReceivedAmount2.Items[0].SetValue(ValidationHelper.GetDecimal(result.Rows[0]["TAHSILTUTARI2"], 0));
                        if (ValidationHelper.GetDecimal(result.Rows[0]["TAHSILTUTARI2"], 0) > 0)
                            Parity2.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaymentCurrencyParity2", TuEntityEnum.New_Transfer.GetHashCode()) + "&nbsp;&nbsp;" +
                                Math.Round(ValidationHelper.GetDecimal(result.Rows[0]["new_TransferPaymentCurrencyParity2"], 0), 6).ToString());
                    }
                }
            }
            //ReConfigureScreen();




        }
        catch (Exception ex)
        {
            e.Message = ex.Message;
            e.Success = false;
        }
    }

    private bool GetIsPersonalSecurityInfo(Guid senderId)
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

    #endregion

    #region Overrided Methods

    protected override void OnPreInit(EventArgs e)
    {
        var tb = new TriggerButton { TrgId = ID + "_Clear", BtnIcon = Icon.Erase };
        tb.AjaxEvents.Click.Event += ClearRecipient;
        new_RecipientID.Triggers.Add(tb);
        base.OnPreInit(e);
    }

    #endregion

    #region Public Methods

    public void ReconfigureByCollectionMethod()
    {
        if (ValidationHelper.GetInteger(new_CollectionMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        {
            new_ReceivedAmount2.SetVisible(true);
            new_ReceivedAmount1.Items[0].SetDisabled(false);

        }
        else
        {
            new_ReceivedAmount2.SetVisible(false);
            new_ReceivedAmount1.Items[0].SetDisabled(true);

        }
    }

    public void ClearRequirementLevel()
    {
        new_RecipientIBAN.SetRequirementLevel(RLevel.None);
        new_RecipientBicIBAN.SetRequirementLevel(RLevel.None);
        new_EftBank.SetRequirementLevel(RLevel.None);
        new_EftCity.SetRequirementLevel(RLevel.None);
        new_EftBranch.SetRequirementLevel(RLevel.None);
        new_RecipientCardNumber.SetRequirementLevel(RLevel.None);
        new_RecipientAccountNumber.SetRequirementLevel(RLevel.None);
        new_RecipientBicAccountNumber.SetRequirementLevel(RLevel.None);

        new_EftPaymentMethodID.SetRequirementLevel(RLevel.None);
    }
    public string GetDefaultReceivedAmount1Currency()
    {
        const string sql = @"
		IF EXISTS ( SELECT new_CurrencyId FROM dbo.vNew_OfficeTransactionType(nolock) WHERE new_OfficeID=@OfficeId AND DeletionStateCode=0 AND new_TransactionTypeID=@TransactionTypeID AND new_CurrencyId=@AmountCurrency )
		BEGIN
			select @AmountCurrency
		END
		ELSE
		BEGIN
			SELECT TOP 1 new_CurrencyId FROM dbo.vNew_OfficeTransactionType(nolock) WHERE new_OfficeID=@OfficeId AND DeletionStateCode=0 AND new_TransactionTypeID=@TransactionTypeID
		END";
        var staticData = new StaticData();
        staticData.AddParameter("OfficeId", DbType.Guid, ValidationHelper.GetGuid(new_OfficeID.Value));
        staticData.AddParameter("TransactionTypeID", DbType.Guid, ValidationHelper.GetGuid(new_TargetTransactionTypeID.Value));
        staticData.AddParameter("AmountCurrency", DbType.Guid, ValidationHelper.GetGuid(new_AmountCurrency2.Value));
        var receivedAmount1Currency = ValidationHelper.GetString(staticData.ExecuteScalar(sql));
        return receivedAmount1Currency;
    }
    #endregion

    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {
        [AjaxMethod()]
        public bool IsIdentificationValidDate(string strIdentificationCardType)
        {
            var ret = false;
            var sd = new StaticData();
            sd.AddParameter("new_IdentificationCardType", DbType.Guid, ValidationHelper.GetGuid(strIdentificationCardType));
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            //strIdentificationCardType
            const string strsql = @"
SELECT COUNT(*) FROM dbo.vNew_CountryIdentificatonCardType(nolock) ct
WHERE 
	new_CountryID in (
(SELECT new_CountryID FROM dbo.SystemUserExtension(nolock) se 
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
        public Credit GetCreditInfo(Guid DataID)
        {
            CreditCheckFactory ccf = new CreditCheckFactory();
            return ccf.GetCreditPayInfo(DataID);
        }
    }

    protected void ExpenseProcessor()
    {
        decimal realCostAmount = ValidationHelper.GetDecimal(new_CalculatedExpenseAmountDefaultValue.Value == null || new_CalculatedExpenseAmountDefaultValue.Value == string.Empty ? "0" : new_CalculatedExpenseAmountDefaultValue.Value, 0);
        decimal inputCostAmount;
        if (((CrmDecimalComp)new_CalculatedExpenseAmount.Items[0]).Value != null)
        {
            inputCostAmount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_CalculatedExpenseAmount.Items[0]).Value, 0);
        }
        else
        {
            inputCostAmount = realCostAmount;
        }

        if (realCostAmount != 0)
        {
            if (inputCostAmount != 0)
            {
                if (inputCostAmount > realCostAmount)
                {
                    new_CalculatedExpenseAmount.d1.Value = realCostAmount;

                    var m = new MessageBox { Width = 400, Height = 180 };
                    m.Show("", "", CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_EXPENSE_AMOUNT_LIMIT_MSG1"));
                }
                else if ((realCostAmount / 100 * (100 - UserCostReductionRate)) > inputCostAmount)
                {
                    new_CalculatedExpenseAmount.d1.Value = realCostAmount / 100 * (100 - UserCostReductionRate);

                    var m = new MessageBox { Width = 400, Height = 180 };
                    m.Show("", "", string.Format(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_EXPENSE_AMOUNT_LIMIT_MSG2"), UserCostReductionRate, "<BR><BR>", realCostAmount.ToString(), (realCostAmount / 100 * (100 - UserCostReductionRate))));
                }
            }
            else if (inputCostAmount == 0 && realCostAmount > inputCostAmount)
            {
                if (UserCostReductionRate != 100)
                {
                    new_CalculatedExpenseAmount.d1.Value = realCostAmount;

                    var m = new MessageBox { Width = 400, Height = 180 };
                    m.Show("", "", string.Format(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_EXPENSE_AMOUNT_LIMIT_MSG2"), UserCostReductionRate, "<BR><BR>", realCostAmount.ToString(), (realCostAmount / 100 * (100 - UserCostReductionRate))));

                }
            }
        }
    }

    protected void setUserCostReductionRate()
    {
        if (new_UserCostReductionRate.Value == null)
        {
            var sd = new StaticData();
            sd.AddParameter("@systemuserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));
            UserCostReductionRate = ValidationHelper.GetDecimal(sd.ExecuteScalar("select new_CostReductionRate from nltvsystemuser(@systemuserId) where SystemUserId = @systemuserId"), 0);
            new_UserCostReductionRate.Value = ValidationHelper.GetString(UserCostReductionRate.ToString(), "0");
            new_UserCostReductionRate.SetIValue(ValidationHelper.GetDecimal(UserCostReductionRate, 0));

            new_CalculatedExpenseAmount.Items[0].SetIValue(null);
            ((CrmDecimalComp)new_CalculatedExpenseAmount.Items[0]).Value = null;
            new_CalculatedExpenseAmount.Items[0].SetDisabled(true);

            new_CalculatedExpenseAmountDefaultValue.Value = string.Empty;
            new_CalculatedExpenseAmountDefaultValue.SetIValue(string.Empty);
        }
        else
        {
            UserCostReductionRate = ValidationHelper.GetDecimal(new_UserCostReductionRate.Value, 0);

            //Kredi Ödeme Planı ekranından gelmesi durumu:
            if (QueryHelper.GetString("fromCheckCredit") != "1" && QueryHelper.GetString("fromCheckCreditPrevious") != "1")
            {
                new_CalculatedExpenseAmount.Items[0].SetDisabled(false);
            }
        }
    }

    protected void resetExpenseProcess()
    {
        new_CalculatedExpenseAmount.Items[0].SetIValue(null);
        ((CrmDecimalComp)new_CalculatedExpenseAmount.Items[0]).Value = null;
        new_CalculatedExpenseAmount.Items[0].SetDisabled(true);

        new_CalculatedExpenseAmountDefaultValue.Value = string.Empty;
        new_CalculatedExpenseAmountDefaultValue.SetIValue(string.Empty);

        isNewAmount = true;
    }

    protected void rebuildExpenseProcess()
    {
        resetExpenseProcess();
        setUserCostReductionRate();

        var sd = new StaticData();

        try
        {
            var ramount = ValidationHelper.GetDBDecimal(((CrmDecimalComp)new_ReceivedAmount1.Items[0]).Value);
            var amount = ValidationHelper.GetDBDecimal(((CrmDecimalComp)new_Amount.Items[0]).Value);
            if (amount == null || amount == DBNull.Value)
                return;


            if (!CheckCalculation())
                return;

            sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty) == Guid.Empty ? App.Params.CurrentUser.SystemUserId : ValidationHelper.GetGuid(HdnOtherSerderCorporationUserId.Value, Guid.Empty));
            sd.AddParameter("CountryID", DbType.Guid, ValidationHelper.GetDBGuid(new_CorporationCountryId.Value));
            sd.AddParameter("CorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_CorporationID.Value));
            sd.AddParameter("TransactionTypeID", DbType.Guid, ValidationHelper.GetDBGuid(new_TargetTransactionTypeID.Value));
            sd.AddParameter("RecipientCountryID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCountryID.Value));
            sd.AddParameter("Amount", DbType.Decimal, amount);
            sd.AddParameter("AmountCurrency", DbType.Guid, ValidationHelper.GetDBGuid(new_AmountCurrency2.Value));
            sd.AddParameter("ReceivedAmount1Currency", DbType.Guid, ValidationHelper.GetDBGuid(((CrmComboComp)new_ReceivedAmount1.Items[1]).Value));
            sd.AddParameter("ReceivedAmount1", DbType.Decimal, ramount);
            sd.AddParameter("TransferId", DbType.Guid, DBNull.Value);
            sd.AddParameter("SenderId", DbType.Guid, ValidationHelper.GetDBGuid(new_SenderID.Value));
            sd.AddParameter("CollectionMethod", DbType.Int32, ValidationHelper.GetInteger(new_CollectionMethod.Value));
            sd.AddParameter("ChangedObject", DbType.String, this.new_Amount.d1.UniqueName);
            sd.AddParameter("TransactionTargetOptionId", DbType.Guid, ValidationHelper.GetDBGuid(new_TransactionTargetOptionID.Value));
            sd.AddParameter("EftBank", DbType.Guid, ValidationHelper.GetDBGuid(new_EftBank.Value));

            if (!isNewAmount)
            {
                sd.AddParameter("CustomExpense", DbType.Decimal, new_CalculatedExpenseAmount.d1.Value);
                sd.AddParameter("CustomExpenseCurrency", DbType.Guid, ValidationHelper.GetDBGuid(new_CalculatedExpenseAmount.c1.Value));
            }

            if (!string.IsNullOrEmpty(new_RecipientCorporationId.Value) && new_RecipientCorporationId.Value == "00000000-0000-0000-0000-000000000001" && !string.IsNullOrEmpty(new_RecipientCorporationIdHidden.Value))
            {
                sd.AddParameter("RecipientCorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCorporationIdHidden.Value));
            }
            else
            {
                sd.AddParameter("RecipientCorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCorporationId.Value));
            }

            var result = sd.ReturnDatasetSp(@"SpTuCalculate").Tables[0];
            if (result.Rows.Count > 0)
            {
                if (result.Columns.Contains("ErrorMessage"))
                {
                    var message = result.Rows[0]["ErrorMessage"].ToString();
                    if (result.Columns.Contains("CalculatedExpenseAmount"))
                    {
                        new_ExpenseAmount.Items[0].SetValue(ValidationHelper.GetDecimal(result.Rows[0]["CalculatedExpenseAmount"], 0));
                        new_ReceivedAmount1.d1.SetValue(ValidationHelper.GetDecimal(result.Rows[0]["new_ReceivedAmount1"], 0));
                    }
                    //Hata meydana geldiğinde 

                    //new_ReceivedAmount1.c1.SetValue(ValidationHelper.GetString(result.Rows[0]["new_ReceivedAmount1Text"]));
                    var msg = new MessageBox { Width = 500 };
                    msg.Show(message);
                }
                else
                {
                    new_AmountOld.SetValue(((CrmDecimalComp)new_Amount.Items[0]).Value);

                    new_ReceivedAmount1.Items[0].SetValue(ValidationHelper.GetDecimal(result.Rows[0]["TAHSILTUTARI"], 0));
                    new_ReceivedAmount1.c1.SetValue(ValidationHelper.GetString(result.Rows[0]["TAHSILTUTARIDOVIZ"]), ValidationHelper.GetString(result.Rows[0]["TAHSILTUTARIDOVIZTEXT"]));

                    new_ReceivedExpenseAmount.Items[0].SetValue(ValidationHelper.GetDecimal(result.Rows[0]["NETMASRAFTUTARI"], 0));
                    new_ReceivedExpenseAmount.Items[1].SetValue(ValidationHelper.GetString(result.Rows[0]["NETMASRAFTUTARIDOVIZ"]));

                    new_ExpenseAmount.Items[0].SetValue(ValidationHelper.GetDecimal(result.Rows[0]["INDIRIMLIMASRAFTUTARI"], 0));
                    new_ExpenseAmount.Items[1].SetValue(ValidationHelper.GetString(result.Rows[0]["INDIRIMLIMASRAFTUTARIDOVIZ"]));

                    if (new_CalculatedExpenseCurrencyDefaultValue.Value != ValidationHelper.GetString(result.Rows[0]["MASRAFTUTARIDOVIZ"]) || new_CalculatedExpenseAmountDefaultValue.Value == "0" || new_CalculatedExpenseAmountDefaultValue.Value == string.Empty)
                    {
                        new_CalculatedExpenseAmountDefaultValue.Value = ValidationHelper.GetDecimal(result.Rows[0]["MASRAFTUTARI"], 0).ToString();
                        new_CalculatedExpenseCurrencyDefaultValue.Value = ValidationHelper.GetString(result.Rows[0]["MASRAFTUTARIDOVIZ"]);
                        new_CalculatedExpenseAmountDefaultValue.SetIValue(ValidationHelper.GetDecimal(result.Rows[0]["MASRAFTUTARI"], 0));
                        new_CalculatedExpenseCurrencyDefaultValue.SetIValue(ValidationHelper.GetString(result.Rows[0]["MASRAFTUTARIDOVIZ"]));
                    }

                    new_CalculatedExpenseAmount.Items[0].SetIValue(ValidationHelper.GetDecimal(result.Rows[0]["MASRAFTUTARI"], 0));
                    new_CalculatedExpenseAmount.Items[1].SetIValue(ValidationHelper.GetString(result.Rows[0]["MASRAFTUTARIDOVIZ"]));


                    new_TotalReceivedAmount.Items[0].SetValue(ValidationHelper.GetDecimal(result.Rows[0]["TOPLAMTAHSIL"], 0));
                    new_TotalReceivedAmount.Items[1].SetValue(ValidationHelper.GetString(result.Rows[0]["TOPLAMTAHSILDOVIZ"]));

                    Parity1.Clear();
                    Parity1.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaymentCurrencyParity1", TuEntityEnum.New_Transfer.GetHashCode()) + "&nbsp;&nbsp;" +
                        Math.Round(ValidationHelper.GetDecimal(result.Rows[0]["new_TransferPaymentCurrencyParity1"], 0), 6).ToString());
                }
            }
        }
        catch (Exception ex)
        {
            MessageBox msgBox = new MessageBox();
            msgBox.Show(ex.Message);
        }
    }

    protected void CorporationCountryFormParameterForDisplayControl()
    {
        //new_TransferReasonID.SetVisible(false);
        new_MoneySourceID.SetVisible(false);
        new_ValidDateOfSenderIdentificationCard.SetVisible(false);
        new_DateOfIdendity.SetVisible(false);
    }
}