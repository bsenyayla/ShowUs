using System;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Data;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.Transfer;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using TuFactory.Profession;

public partial class Transfer_PreAuthorizedTransfer : BasePage
{
    private TuUserApproval _userApproval = null;
    private string TransactionType = string.Empty;
    public Guid recId = Guid.Empty;
    #region Variables
    private string _CountryCurrencyID;
    private string _CountryCurrencyIDName;
    private bool _IsPartlyCollection = false; //Bu kurumda parcalı tahsilat kullanılır.
    #endregion


    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {

        }
        base.OnPreInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {

        //if (App.Params.CurrentUser.SystemUserId != ValidationHelper.GetGuid("00000000-AAAA-BBBB-CCCC-000000000001"))
        //{
        //    Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Role PrvCreate,PrvDelete,PrvWrite");
        //}
        var sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        var dt =
            sd.ReturnDataset(
                @"
SELECT u.new_CorporationID,c.new_CountryID,u.new_OfficeID , co.new_CurrencyID,new_CurrencyIDName,c.new_IsPartlyCollection,o.new_CountryID OfficeCountryId
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
        }
        if (!RefleX.IsAjxPostback)
        {
            ConfigureFirstLoadData();
            HideRecipientControls();
            QScript("try { window.top.R.WindowMng.getActiveWindow().setTitle(window.top.PnlCenter.title+" + BasePage.SerializeString("  [" + App.Params.CurrentUser.BusinessUnitIdName + " / " + App.Params.CurrentUser.FullName + "]") + "); } catch(err) { }");

        }
        RxM.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_CollectionMethod",
                                                                 TuEntityEnum.New_Transfer.GetHashCode());
        new_CollectionMethod.SetDisabled(true);
    }

    protected void ClearAll(object sender, AjaxEventArgs e)
    {
        new_RecipientCountryID.Clear();
        new_RecipientCorporationId.Clear();
        new_TransactionTargetOptionID.Clear();
        new_SourceTransactionTypeID.Clear();
        new_AmountCurrency2.Clear();
        new_SenderID.Clear();

        new_RecipientID.Clear();
        new_RecipientName.Clear();
        new_RecipientMiddleName.Clear();
        new_RecipientLastName.Clear();
        new_RecipientIBAN.Clear();
        new_RecipientBicIBAN.Clear();
        new_RecipientAccountNumber.Clear();
        new_RecipientBicAccountNumber.Clear();
        new_RecipienNickName.Clear();
        new_RecipientAddress.Clear();
        new_RecipientCardNumber.Clear();
        //new_RecipientFatherName.Clear();
        //new_RecipientMotherName.Clear();

        new_RecipientGSMCountryId.Clear();
        new_RecipientGSM.Clear();
        new_RecipientEmail.Clear();
        new_Explanation.Clear();

        new_EftBank.Clear();
        //new_EftCity.Clear();
        new_EftBranch.Clear();
        new_EftPaymentMethodID.Clear();

        new_BicBank.Clear();
        new_BicBankBranch.Clear();
        //new_BicBankCity.Clear();
        new_BicCode.Clear();

        new_CorpSendAccountNumber.Clear();
    }

    private void HideRecipientControls()
    {
        new_RecipientID.SetVisible(false);
        new_RecipientName.SetVisible(false);
        new_RecipientMiddleName.SetVisible(false);
        new_RecipientLastName.SetVisible(false);
        new_RecipientIBAN.SetVisible(false);
        new_RecipientBicIBAN.SetVisible(false);
        new_RecipientAccountNumber.SetVisible(false);
        new_RecipientBicAccountNumber.SetVisible(false);
        new_RecipienNickName.SetVisible(false);
        new_RecipientAddress.SetVisible(false);
        new_RecipientCardNumber.SetVisible(false);
        //new_RecipientFatherName.SetVisible(false);
        //new_RecipientMotherName.SetVisible(false);

        new_RecipientGSMCountryId.SetVisible(false);
        new_RecipientGSM.SetVisible(false);
        new_RecipientEmail.SetVisible(false);
        new_Explanation.SetVisible(false);

        new_EftBank.SetVisible(false);
        //new_EftCity.SetVisible(false);
        new_EftBranch.SetVisible(false);
        new_EftPaymentMethodID.SetVisible(false);

        new_BicBank.SetVisible(false);
        new_BicBankBranch.SetVisible(false);
        //new_BicBankCity.SetVisible(false);
        new_BicCode.SetVisible(false);

        new_CorpSendAccountNumber.SetVisible(false);

        btnBack.SetVisible(false);
    }

    protected void ShowIsmeControl()
    {
        //new_RecipientID.SetVisible(true);
        new_RecipientName.SetVisible(true);
        new_RecipientMiddleName.SetVisible(true);
        new_RecipientLastName.SetVisible(true);
        //new_RecipientFatherName.SetVisible(true);
        //new_RecipientMotherName.SetVisible(true);
        new_RecipienNickName.SetVisible(true);
        new_RecipientAddress.SetVisible(true);

        new_RecipientGSMCountryId.SetVisible(true);
        new_RecipientGSM.SetVisible(true);
        new_RecipientEmail.SetVisible(true);
        new_Explanation.SetVisible(true);
        PanelX3.Height = 100;


    }

    protected void ShowEftControl()
    {
        //new_RecipientID.SetVisible(true);
        new_RecipientName.SetVisible(true);
        new_RecipientMiddleName.SetVisible(true);
        new_RecipientLastName.SetVisible(true);
        //new_RecipientFatherName.SetVisible(true);
        //new_RecipientMotherName.SetVisible(true);
        new_RecipienNickName.SetVisible(true);
        new_RecipientAddress.SetVisible(true);

        new_RecipientIBAN.SetVisible(true);
        new_RecipientAccountNumber.SetVisible(true);
        new_RecipientCardNumber.SetVisible(true);

        new_EftBank.SetVisible(true);
        //new_EftCity.SetVisible(true);
        new_EftBranch.SetVisible(true);
        new_EftPaymentMethodID.SetVisible(true);
    }

    protected void ShowBicControl()
    {
        new_RecipientID.SetVisible(true);
        new_RecipientName.SetVisible(true);
        new_RecipientMiddleName.SetVisible(true);
        new_RecipientLastName.SetVisible(true);
        //new_RecipientFatherName.SetVisible(true);
        //new_RecipientMotherName.SetVisible(true);
        new_RecipienNickName.SetVisible(true);
        new_RecipientAddress.SetVisible(true);

        new_RecipientBicIBAN.SetVisible(true);
        new_RecipientBicAccountNumber.SetVisible(true);
        new_RecipientCardNumber.SetVisible(true);

        new_BicBank.SetVisible(true);
        //new_BicBankCity.SetVisible(true);
        new_BicBankBranch.SetVisible(false);
        new_BicCode.SetVisible(true);
    }

    protected void GetPreAuthorizedTransfer(object sender, AjaxEventArgs e)
    {
        HideRecipientControls();
        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();

        PreAuthorizedTransferFactory preFac = new PreAuthorizedTransferFactory();
        var dt = new DataTable();
        try
        {
            dt = preFac.GetPreAuthorizedTransfer(TransferTuRef.Value);

            if (dt == null)
            {
                QScript("alert('Transfer Yok');");
            }
            else
            {
                TransactionType = dt.Rows[0]["ISLEM_TIPI"].ToString();

                if (TransactionType == "001")
                {
                    ShowIsmeControl();
                }
                else if (TransactionType == "002")
                {
                    ShowEftControl();
                }
                else if (TransactionType == "003")
                {
                    ShowBicControl();
                }

                Session["TransferId"] = dt.Rows[0]["TransferId"].ToString();
                recId = ValidationHelper.GetGuid(dt.Rows[0]["TransferId"]);
                New_TransferId.Value = dt.Rows[0]["TransferId"].ToString();

                new_TargetTransactionTypeID.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["ISLEM_TIPI_ID"]), ValidationHelper.GetString(dt.Rows[0]["ISLEM_TIPI_IDNAME"]));

                CreatedBy.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["ISLEMI_OLUSTURAN"]), ValidationHelper.GetString(dt.Rows[0]["ISLEMI_OLUSTURAN"]));
                new_Channel.SetValue(ValidationHelper.GetInteger(dt.Rows[0]["KANAL"]));

                new_RecipientCountryID.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["ALICI_ULKE_ID"]), ValidationHelper.GetString(dt.Rows[0]["ALICI_ULKE_ADI"]));

                string islemTipiKod = ValidationHelper.GetString(dt.Rows[0]["ISLEM_TIPI_KOD"]);
                if (ValidationHelper.GetGuid(dt.Rows[0]["ALICI_KURUM_ID"]) == Guid.Empty && (islemTipiKod == "002" || islemTipiKod == "003"))
                {
                    new_RecipientCorporationId.Items.Add(new ListItem("-1", CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_DIGER")));
                    new_RecipientCorporationId.SetValue("-1", CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_DIGER"));
                }
                else
                {
                    if (islemTipiKod == "001" && ValidationHelper.GetGuid(dt.Rows[0]["ALICI_KURUM_ID"]) == Guid.Empty)
                    {
                        new_RecipientCorporationId.Items.Add(new ListItem("-1", CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_UPT_HAVUZU")));
                        new_RecipientCorporationId.SetValue("-1", CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_UPT_HAVUZU"));
                    }
                    else
                    {
                        new_RecipientCorporationId.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["ALICI_KURUM_ID"]), ValidationHelper.GetString(dt.Rows[0]["ALICI_KURUM_ADI"]));
                    }
                }

                new_TransactionTargetOptionID.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["HEDEF_ISLEM_ID"]), ValidationHelper.GetString(dt.Rows[0]["HEDEF_ISLEM"]));
                new_SourceTransactionTypeID.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["KAYNAK_ISLEM_ID"]), ValidationHelper.GetString(dt.Rows[0]["KAYNAK_ISLEM"]));
                new_AmountCurrency2.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["GONDERILEN_TUTAR_PARAKOD_ID"]), ValidationHelper.GetString(dt.Rows[0]["GONDERILEN_TUTAR_PARAKOD"]));
                new_SenderID.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["GONDEREN_ID"]), ValidationHelper.GetString(dt.Rows[0]["GONDEREN"]));
                new_SenderIdentificationCardTypeID.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["GONDEREN_KIMLIK_TIPI_ID"]), ValidationHelper.GetString(dt.Rows[0]["GONDEREN_KIMLIK_TIPI_ADI"]));
                new_SenderIdendificationNumber1.SetValue(ValidationHelper.GetString(dt.Rows[0]["GONDEREN_VATANDASLIK_NO"]));
                new_SenderIdentificationCardNo.SetValue(ValidationHelper.GetString(dt.Rows[0]["GONDEREN_KIMLIK_NO"]));
                new_SenderNationalityId.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["GONDEREN_UYRUK_ID"]), ValidationHelper.GetString(dt.Rows[0]["GONDEREN_UYRUK"]));
                new_SenderName.SetValue(ValidationHelper.GetString(dt.Rows[0]["GONDEREN_AD"]));
                new_SenderMiddleName.SetValue(ValidationHelper.GetString(dt.Rows[0]["GONDEREN_ORTAAD"]));
                new_SenderLastName.SetValue(ValidationHelper.GetString(dt.Rows[0]["GONDEREN_SOYAD"]));
                new_FatherName.SetValue(ValidationHelper.GetString(dt.Rows[0]["GONDEREN_BABAADI"]));
                new_BirthDate.SetValue(ValidationHelper.GetDate(dt.Rows[0]["GONDEREN_DOGUM_TARIHI"]));
                new_SenderNumber.SetValue(ValidationHelper.GetString(dt.Rows[0]["GONDERICI_NUMARASI"]));
                new_SenderGSMCountryId.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["GONDEREN_TEL_ULKE_ID"]), ValidationHelper.GetString(dt.Rows[0]["GONDEREN_TEL_ULKE_ADI"]));
                new_SenderGSM.SetValue(ValidationHelper.GetString(dt.Rows[0]["GONDEREN_TEL"]));
                new_RecipientID.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["ALICI_ID"]), cryptor.DecryptInString(ValidationHelper.GetString(dt.Rows[0]["ALICI_IDNAME"])));
                new_RecipientName.SetValue(cryptor.DecryptInString(ValidationHelper.GetString(dt.Rows[0]["ALICI_AD"])));
                new_RecipientMiddleName.SetValue(cryptor.DecryptInString(ValidationHelper.GetString(dt.Rows[0]["ALICI_ORTAAD"])));
                new_RecipientLastName.SetValue(cryptor.DecryptInString(ValidationHelper.GetString(dt.Rows[0]["ALICI_SOYAD"])));
                new_RecipientIBAN.SetValue(ValidationHelper.GetString(dt.Rows[0]["ALICI_IBAN"]));
                new_RecipientBicIBAN.SetValue(ValidationHelper.GetString(dt.Rows[0]["ALICI_BIC_IBAN"]));
                new_EftBank.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["ALICI_EFT_BANK"]), ValidationHelper.GetString(dt.Rows[0]["ALICI_EFT_BANKNAME"]));
                new_BicBank.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["ALICI_BIC_BANK"]), ValidationHelper.GetString(dt.Rows[0]["ALICI_BIC_BANKNAME"]));

                new_EftBranch.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["ALICI_EFT_BANK_SUBE"]), ValidationHelper.GetString(dt.Rows[0]["ALICI_EFT_BANK_SUBE_NAME"]));
                new_BicBankBranch.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["ALICI_BIC_BANK_SUBE"]), ValidationHelper.GetString(dt.Rows[0]["ALICI_BIC_BANK_SUBE_NAME"]));
                new_Explanation.SetValue(ValidationHelper.GetString(dt.Rows[0]["EXPLANATION"]));

                new_BicCode.SetValue(ValidationHelper.GetString(dt.Rows[0]["ALICI_BICCODE"]));
                new_RecipientBicAccountNumber.SetValue(ValidationHelper.GetString(dt.Rows[0]["ALICI_BIC_ACCOUNTNUMBER"]));

                new_RecipientAccountNumber.SetValue(ValidationHelper.GetString(dt.Rows[0]["ALICI_ACCOUNT_NUMBER"]));
                new_RecipientCardNumber.SetValue(ValidationHelper.DecryptString(dt.Rows[0]["ALICI_CARD_NUMBER"].ToString()));

                new_RecipientGSMCountryId.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["ALICI_TEL_COUNTRYID"]), ValidationHelper.GetString(dt.Rows[0]["ALICI_TEL_COUNTRYIDNAME"]));
                new_RecipientGSM.SetValue(ValidationHelper.GetString(dt.Rows[0]["ALICI_TEL"]));

                new_Amount.Items[1].SetValue(ValidationHelper.GetGuid(dt.Rows[0]["GONDERILEN_TUTAR_PARAKOD_ID"]));
                new_Amount.Items[1].SetDisabled(true);
                new_Amount.Items[0].SetValue(ValidationHelper.GetDecimal(dt.Rows[0]["GONDERILEN_TUTAR"], 0));
                new_Amount.Items[0].SetDisabled(true);

                new_ExpenseAmount.Items[1].SetValue(ValidationHelper.GetGuid(dt.Rows[0]["MASRAF_PARAKODU_ID"]));
                new_ExpenseAmount.Items[1].SetDisabled(true);
                new_ExpenseAmount.Items[0].SetValue(ValidationHelper.GetDecimal(dt.Rows[0]["MASRAF_TUTARI"], 0));
                new_ExpenseAmount.Items[0].SetDisabled(true);

                new_CalculatedExpenseAmount.Items[1].SetValue(ValidationHelper.GetGuid(dt.Rows[0]["MASRAF_PARAKODU_ID"]));
                new_CalculatedExpenseAmount.Items[1].SetDisabled(true);
                new_CalculatedExpenseAmount.Items[0].SetValue(ValidationHelper.GetDecimal(dt.Rows[0]["MASRAF_TUTARI"], 0));
                new_CalculatedExpenseAmount.Items[0].SetDisabled(true);

                new_ReceivedPaymentAmount.Items[1].SetValue(ValidationHelper.GetGuid(dt.Rows[0]["GONDERILEN_TUTAR_PARAKOD_ID"]));
                new_ReceivedPaymentAmount.Items[1].SetDisabled(true);
                new_ReceivedPaymentAmount.Items[0].SetValue(ValidationHelper.GetDecimal(dt.Rows[0]["GONDERILEN_TUTAR"], 0));
                new_ReceivedPaymentAmount.Items[0].SetDisabled(true);

                new_ReceivedAmount1.Items[1].SetValue(ValidationHelper.GetGuid(dt.Rows[0]["TAHSIL_TUTAR1_DOVIZ_ID"]));
                new_ReceivedAmount1.Items[0].SetValue(ValidationHelper.GetDecimal(dt.Rows[0]["TAHSIL_TUTAR1"], 0));

                //new_EftBank.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["ALICI_EFT_BANK"]), ValidationHelper.GetString(dt.Rows[0]["ALICI_EFT_BANKNAME"]));
                //new_EftBank.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["ALICI_EFT_BANK"]), ValidationHelper.GetString(dt.Rows[0]["ALICI_EFT_BANKNAME"]));
                //new_EftBank.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["ALICI_EFT_BANK"]), ValidationHelper.GetString(dt.Rows[0]["ALICI_EFT_BANKNAME"]));
                new_EftPaymentMethodID.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["EFT_GONDERIM_TURU_ID"]));

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

            }
        }
        catch (Exception ex)
        {
            QScript("alert('" + ex.Message + "');");

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

    protected void CalculateOnEvent(object sender, AjaxEventArgs e)
    {
        var sd = new StaticData();
        var trId = ValidationHelper.GetGuid(Session["TransferId"]);

        try
        {
            var ramount = ValidationHelper.GetDBDecimal(((CrmDecimalComp)new_ReceivedAmount1.Items[0]).Value);
            var amount = ValidationHelper.GetDBDecimal(((CrmDecimalComp)new_Amount.Items[0]).Value);
            if (amount == null || amount == DBNull.Value)
                return;

            //if (!CheckCalculation())
            //    return;

            var changedObject = string.Empty;
            if (sender.GetType() == typeof(CrmDecimalComp))
                changedObject = ((CrmDecimalComp)(sender)).UniqueName;
            if (sender.GetType() == typeof(CrmComboComp))
                changedObject = ((CrmComboComp)(sender)).UniqueName;
            if (sender.GetType() == typeof(CrmPicklistComp))
                changedObject = ((CrmPicklistComp)(sender)).UniqueName;



            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            //sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid("00000001-3797-46B8-B74D-3A0320BEE3AD"));//web_user

            sd.AddParameter("CountryID", DbType.Guid, ValidationHelper.GetDBGuid(new_CorporationCountryId.Value));
            //sd.AddParameter("CountryID", DbType.Guid, ValidationHelper.GetDBGuid("0BFC8AF0-EDAC-482C-83C6-11D833A7A05B")); //TÜRKİYE

            sd.AddParameter("CorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_CorporationID.Value));
            //sd.AddParameter("CorporationID", DbType.Guid, ValidationHelper.GetDBGuid("0BFC8B02-72D0-41D1-A645-704762A003C2")); //WEB

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


            sd.AddParameter("ChannelUser", DbType.Guid, ValidationHelper.GetDBGuid(CreatedBy.Value));
            sd.AddParameter("Channel", DbType.Int32, ValidationHelper.GetDBInteger(new_Channel.Value));

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
            ReConfigureScreen();



        }
        catch (Exception ex)
        {
            e.Message = ex.Message;
            e.Success = false;
        }
    }

    void ReConfigureScreen()
    {
        //var sd = new StaticData();
        //sd.ClearParameters();
        //var amount = ValidationHelper.GetDBDecimal(((CrmDecimalComp)new_Amount.Items[0]).Value);

        //sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        //sd.AddParameter("ObjectId", DbType.Int32, TuEntityEnum.New_Transfer.GetHashCode());
        //sd.AddParameter("Amount", DbType.Decimal, amount);
        //sd.AddParameter("FromCurrencyID", DbType.Guid, ValidationHelper.GetDBGuid(new_AmountCurrency2.Value));
        //var script = sd.ExecuteScalar(@"Exec spTUFormRequiredWf2 @SystemUserId,@ObjectId,@Amount,@FromCurrencyID").ToString();
        //QScript(script);

        //const string scriptt = "CheckAllControls();";
        //QScript(scriptt);

        //QScript("alert(new_SenderID.getValue());");

        //QScript("Frame_PanelX2.new_SenderID.setValue('" + ValidationHelper.GetDBGuid("0BFC8B14-8671-43B6-B856-0A0A79D12F9B") + "');");

    }

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

    protected void new_AmountOnChange(object sender, AjaxEventArgs e)
    {
        //if (new_ReceivedAmount1.c1.Value == string.Empty)
        //{
        //    new_ReceivedAmount1.c1.Value = GetDefaultReceivedAmount1Currency();
        //    if (_IsPartlyCollection)
        //    {
        //        if (new_ReceivedAmount1.c1.Value == _CountryCurrencyID)
        //        {
        //            new_CollectionMethod.Value = TransferCollectionMethodEnum.Single.GetHashCode().ToString();
        //            new_CollectionMethod.SetValue(TransferCollectionMethodEnum.Single.GetHashCode().ToString());
        //        }
        //        else
        //        {

        //            new_CollectionMethod.SetValue(TransferCollectionMethodEnum.Multiple.GetHashCode().ToString());
        //            new_CollectionMethod.Value = TransferCollectionMethodEnum.Multiple.GetHashCode().ToString();
        //        }



        //        new_CollectionMethodOnChange(sender, e);
        //    }
        //}

        //if (ValidationHelper.GetInteger(new_CollectionMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        //{
        //    new_CollectionMethodOnChange(sender, e);
        //    //CalculateOnEvent(sender, e);
        //}
        //else
        //{
        //    CalculateOnEvent(sender, e);
        //}

        //GetTransferOutherCalculateScript();
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

        if (!ValidationHelper.GetBoolean(new_IdentityWasSeen.Value))
        {
            var msg = CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED");
            var m = new MessageBox { Width = 400, Height = 180 };
            string requiredmsg = string.Format(msg, new_IdentityWasSeen.FieldLabel);
            var msg2 = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_IDENTITY_WASNOT_SEEN");
            m.Show(msg, requiredmsg + "   " + msg2);
            return;
        }

        var trans = (new StaticData()).GetDbTransaction();

        if (string.IsNullOrEmpty(New_TransferId.Value))
        {
            New_TransferId.Value = Session["TransferId"].ToString();
            recId = ValidationHelper.GetGuid(New_TransferId.Value);

        }
        var sd = new StaticData();
        try
        {
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            sd.AddParameter("CountryID", DbType.Guid, ValidationHelper.GetDBGuid(new_CorporationCountryId.Value));
            sd.AddParameter("CorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_CorporationID.Value));
            sd.AddParameter("TransactionTypeID", DbType.Guid, ValidationHelper.GetDBGuid(new_TargetTransactionTypeID.Value));
            sd.AddParameter("RecipientCountryID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCountryID.Value));
            sd.AddParameter("Amount", DbType.Decimal, ValidationHelper.GetDBDecimal(((CrmDecimalComp)new_Amount.Items[0]).Value));
            sd.AddParameter("AmountCurrency", DbType.Guid, ValidationHelper.GetDBGuid(new_AmountCurrency2.Value));
            sd.AddParameter("ReceivedAmount1Currency", DbType.Guid, ValidationHelper.GetDBGuid(((CrmComboComp)new_ReceivedAmount1.Items[1]).Value));
            sd.AddParameter("ReceivedAmount1", DbType.Decimal, ValidationHelper.GetDBDecimal(((CrmDecimalComp)new_ReceivedAmount1.Items[0]).Value));
            sd.AddParameter("SenderId", DbType.Guid, ValidationHelper.GetDBGuid(new_SenderID.Value));
            sd.AddParameter("TransferId", DbType.Guid, recId);
            sd.AddParameter("CollectionMethod", DbType.Int32, ValidationHelper.GetInteger(new_CollectionMethod.Value));
            sd.AddParameter("ChangedObject", DbType.String, "new_ReceivedAmount1");
            sd.AddParameter("ChannelUser", DbType.Guid, ValidationHelper.GetDBGuid(CreatedBy.Value));
            sd.AddParameter("Channel", DbType.Int32, ValidationHelper.GetDBInteger(new_Channel.Value));
            sd.AddParameter("RecipientCorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCorporationId.Value));
            sd.AddParameter("EftBank", DbType.Guid, ValidationHelper.GetDBGuid(new_EftBank.Value));


            var result = sd.ExecuteScalarSp(@"SpTuCalculate", trans);

            if (!string.IsNullOrEmpty(ValidationHelper.GetString(result, "")))
                throw new Exception(ValidationHelper.GetString(result));

        }
        catch (Exception ex)
        {
            StaticData.Rollback(trans);
            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
            return;
        }

        try
        {
            var tdb = new TransferDb();
            var resultLimit = tdb.TransferValidate(recId, null, false, trans);
            if (!string.IsNullOrEmpty(resultLimit.Message))
                throw new TuException { ErrorMessage = resultLimit.Message, ErrorCode = resultLimit.ErrorCode };
        }
        catch (TuException ex)
        {
            StaticData.Rollback(trans);
            MessageBox msg = new MessageBox();
            msg.Show(ex.Message + "-" + ex.ErrorMessage);
            return;
        }

        try
        {
            TransferDb db = new TransferDb();
            db.UpdatePreAuthorizedTransfer(ValidationHelper.GetGuid(New_TransferId.Value), App.Params.CurrentUser.SystemUserId, trans);
        }
        catch (Exception ex)
        {
            StaticData.Rollback(trans);
            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
            return;
        }
        StaticData.Commit(trans);
        Session["TransferId"] = null;
        var formId = ParameterFactory.GetParameterValue("CRM_TU_TRANSFER_RESULT_FORMID");
        var url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx");


        Page.Response.Redirect(string.Format("{0}?defaulteditpageid={1}&ObjectId=201100072&mode=1&recid={2}", url, formId, New_TransferId.Value));
        //Page.Response.Redirect(@"http://localhost/Coretech.Crm.Web/CrmPages/AutoPages/EditReflex.aspx?defaulteditpageid=00000020-581E-4B71-8D5D-983F5537E928&ObjectId=201100072&mode=1&recid=783279e1-49c0-472f-9190-91d3c5b94420");

    }

    protected void btnBackOnEvent(object sender, AjaxEventArgs e)
    {
        if (string.IsNullOrEmpty(New_TransferId.Value))
        {
            New_TransferId.Value = Session["TransferId"].ToString();
            recId = ValidationHelper.GetGuid(New_TransferId.Value);

        }
        if (recId != null && recId != Guid.Empty)
        {
            Page.Response.Redirect(Page.ResolveClientUrl("~/isv/tu/transfer/TransferMain.aspx") + "?recid=" + recId + "&IsPreAuthorized=1" + "&ExternalPreAuthorizedSenderId=" + new_SenderID.Value);
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



}