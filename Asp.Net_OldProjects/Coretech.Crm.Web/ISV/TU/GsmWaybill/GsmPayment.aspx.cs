using System.Collections.Generic;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using Upt.Core.Domain;
using Newtonsoft.Json;
using Upt.GsmPayment.Business;
using Upt.GsmPayment.Domain;
using System;
using Coretech.Crm.Factory;
using Upt.Core.Business;
using Upt.GsmPayment.Business.Utils;
using System.Globalization;
using TuFactory.TransactionManagers.Accounting.Calculate;
using TuFactory.TuUser;
using TuFactory.Object.User;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using TuFactory.Object;
using Coretech.Crm.Factory.Crm.Dynamic;
using System.Data.Common;
using Coretech.Crm.PluginData;
using TuFactory.Cash;
using TuFactory.TuBlacklist.Domain;
using TuFactory.TuBlacklist.Business.Transfer;
using TuFactory.TuBlacklist.Business.GsmPayment;
using Coretech.Crm.Factory.Crm;

public partial class GsmWaybill_GsmPayment : BasePage
{
    private TuUserApproval _userApproval = null;
    private DynamicSecurity DynamicSecurity;
    string reportId = "AC0305CB-C2C9-E511-BBCF-005056B200AF";
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private TuUser _activeUser = null;

    private void TranslateMessages()
    {

        ToolbarButtonMd.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING_DETAIL");

    }


    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            new_GsmNumber.Clear();
        }
        base.OnPreInit(e);
    }

    #region Load Event

    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);


        DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_GsmPayment.GetHashCode(), null);
        if (!(DynamicSecurity.PrvCreate || DynamicSecurity.PrvRead || DynamicSecurity.PrvWrite))
            Response.End();


        if (!RefleX.IsAjxPostback)
        {
            TranslateMessages();
            New_GsmPaymentId.Value = QueryHelper.GetString("recid");
            bool fromPool = ValidationHelper.GetBoolean(QueryHelper.GetString("FromPool"), false);


            SetGsmCountryTelephoneCode();
            btnGetReconcliationData.SetVisible(false);
            btnCancel.SetVisible(false);
            btnConfirm.SetVisible(false);
            btnReject.SetVisible(false);
            btnPrint.SetVisible(false);

            if (!String.IsNullOrEmpty(New_GsmPaymentId.Value))
            {
                LoadData(fromPool);
            }
            else
            {
                new_PackageName.SetVisible(false);
                new_PackageAmountH.SetVisible(false);
                new_ExpenseAmountH.SetVisible(false);
            }

            var query = new Dictionary<string, string>
                {
                    {"fromCheckCredit",QueryHelper.GetString("fromCheckCredit")},
                    {"senderID", ValidationHelper.GetString(new_SenderId.Value) },
                    {"callPage", ValidationHelper.GetString("GsmPayment") },

                };




            Panel_SenderInformation.AutoLoad.Url = "../Transfer/TransferSenderFind.aspx" + QueryHelper.RefreshUrl(query);
            Panel_SenderInformation.LoadUrl(Panel_SenderInformation.AutoLoad.Url);



            hdnReportId.Value = App.Params.GetConfigKeyValue("GSM_PAYMENT_REPORTID");





        }
    }

    private void LoadData(bool fromGsmTransactionPool)
    {
        GsmTransactionService service = new GsmTransactionService();
        GsmTransaction transaction = service.GetGsmPayment(ValidationHelper.GetGuid(New_GsmPaymentId.Value));

        new_GsmCountryId.SetValue(transaction.GsmOperator.Country.new_GsmCountryId, transaction.GsmOperator.Country.CountryName);
        new_GsmCountryId.Value = transaction.GsmOperator.Country.new_GsmCountryId.ToString();
        new_GsmOperatorId.SetValue(transaction.GsmOperator.new_GsmOperatorId, transaction.GsmOperator.Name);
        CorporationReference.SetValue(transaction.IntegratorReference);
        GsmIntegratorCode.SetValue(transaction.IntegratorCode);
        GsmTransactionReference.SetValue(transaction.TransactionReference);
        new_SenderId.SetValue(transaction.SenderId);
        new_SenderId.Value = transaction.SenderId.ToString();
        new_PackageName.SetValue(transaction.Package.Name);
        new_PackageAmountH.d1.SetIValue(transaction.Package.Price.Amount);
        new_PackageAmountH.c1.SetValue(transaction.Package.Price.Currency.CurrencyId, transaction.Package.Price.Currency.ISOCurrencyCode);
        new_ExpenseAmountH.d1.SetIValue(transaction.Package.ExpenseAmount.Amount);
        new_ExpenseAmountH.c1.SetValue(transaction.Package.ExpenseAmount.Currency.CurrencyId, transaction.Package.ExpenseAmount.Currency.ISOCurrencyCode);


        QScript(@" document.getElementById('_new_GsmNumber').value='" + transaction.Msisdn.CountryCode + @"';
                   document.getElementById('__new_GsmNumber').value='" + transaction.Msisdn.PhoneNumber.Substring(0, 3) + @"';
                   document.getElementById('___new_GsmNumber').value='" + transaction.Msisdn.PhoneNumber.Substring(3, transaction.Msisdn.PhoneNumber.Length - 3) + @"';");

        new_GsmCountryId.SetDisabled(true);
        new_GsmOperatorId.SetDisabled(true);
        new_GsmNumber.SetDisabled(true);
        btnGetReconcliationData.SetVisible(true);
        btnGetPackages.SetVisible(false);
        new_PackageName.SetVisible(true);
        new_PackageAmountH.SetVisible(true);
        new_ExpenseAmountH.SetVisible(true);


        if (transaction.LoadStatus == GsmLoadStatus.Yukleme_Tamamlandi.GetHashCode() && _userApproval.GsmCancelStart) // && fromGsmTransactionPool)
        {
            btnCancel.SetVisible(true);
        }
        else
        {
            btnCancel.SetVisible(false);
        }

        if (
            transaction.LoadStatus == GsmLoadStatus.Yukleme_Iptal_Onay_Bekliyor.GetHashCode() &&
            _userApproval.GsmApprovalCancel && fromGsmTransactionPool &&
            transaction.ModifiedBy.SystemUserId != App.Params.CurrentUser.SystemUserId
        )
        {
            btnConfirm.SetVisible(true);
            btnReject.SetVisible(true);
        }
        else
        {
            btnConfirm.SetVisible(false);
            btnReject.SetVisible(false);
        }

        if (transaction.LoadStatus == GsmLoadStatus.Yukleme_Tamamlandi.GetHashCode() || transaction.LoadStatus == GsmLoadStatus.Yukleme_Iptal_Edildi.GetHashCode() || transaction.LoadStatus == GsmLoadStatus.Yukleme_Iptal_Edildi_Dekont_Basıldı.GetHashCode())
        {
            btnPrint.SetVisible(true);
        }
        else
        {
            btnPrint.SetVisible(false);
        }

    }

    protected void new_GsmCountryIdLoad(object sender, AjaxEventArgs e)
    {
        var like = new_GsmCountryId.Query();
        List<GsmCountry> list = GetGsmCountries(like);

        new_GsmCountryId.TotalCount = list.Count;
        new_GsmCountryId.DataSource = list;
        new_GsmCountryId.DataBind();
    }

    private List<GsmCountry> GetGsmCountries(string key)
    {
        GsmCountryService service = new GsmCountryService();

        return service.GetGsmCountries(key, App.Params.CurrentUser.SystemUserId);

    }

    #endregion

    #region Change Event

    protected void new_GsmCountryIdChangeOnEvent(object sender, AjaxEventArgs e)
    {
        if (new_GsmCountryId.SelectedItems != null)
        {
            var telephoneCode = new_GsmCountryId.SelectedItems[0]["new_TelephoneCode"];

            if (telephoneCode != string.Empty)
            {
                if (telephoneCode == "0090")
                {
                    new_GsmOperatorId.SetDisabled(false);
                    //GsmoperatorPackageType.SetVisible(true);
                    //GsmoperatorPackageType.Visible = true;


                }
                else
                {
                    new_GsmOperatorId.Clear();
                    new_GsmOperatorId.SetDisabled(true);
                    //GsmoperatorPackageType.SetVisible(false);
                    //GsmoperatorPackageType.Visible = false;



                }
            }
        }
    }

    protected void new_GsmOperatorIdChangeOnEvent(object sender, AjaxEventArgs e)
    {

    }

    protected void ReceivedOptionEur_OnChange(object sender, AjaxEventArgs e)
    {
        var packageAmount = new_PackageAmount.d1.Value;
        var packageAmountCurrency = ValidationHelper.GetGuid(new_PackageAmount.c1.Value);

        var expenseAmount = new_ExpenseAmount.d1.Value;
        var expenseAmountCurrency = ValidationHelper.GetGuid(new_ExpenseAmount.c1.Value);

        var receivedAmount1 = ReceivedOptionEur_1.d1.Value;
        var receivedOptionEurAmount = ValidationHelper.GetDecimal(ReceivedOptionEurAmount.Value, 0);
        var receivedAmount1Currency = ValidationHelper.GetGuid(ReceivedOptionEur_1.c1.Value);

        if (receivedOptionEurAmount - receivedAmount1 < 0)
        {
            var msg = new MessageBox { Width = 500, Height = 250 };
            msg.Show("Tahsil tutarı işlem tutarından büyük olamaz!");
            ReceivedOptionEur_1.d1.SetValue(receivedOptionEurAmount);
            ReceivedOptionEur_2.d1.SetValue(0);
            return;
        }


        if (ValidationHelper.GetDecimal(ReceivedExpenseOptionEurAmount.Value, 0) > receivedAmount1)
        {
            var msg = new MessageBox { Width = 500, Height = 250 };
            msg.Show("Tahsil tutarı 1 masraftan küçük olamaz!");
            ReceivedOptionEur_1.d1.SetValue(receivedOptionEurAmount);
            ReceivedOptionEur_2.d1.SetValue(0);
            return;
        }



        ExchangeRateService exchangeRateService = new ExchangeRateService();
        Money received1 = new Money() { Amount = ValidationHelper.GetDecimal(receivedOptionEurAmount - receivedAmount1, 0), Currency = GsmPaymentCacheManager.CurrencyIds[receivedAmount1Currency] };

        //CurrencyConversion currencyConversation = exchangeRateService.ConvertCurrency(received1, "TRY", false);
        CurrencyConversion currencyConversation = exchangeRateService.ConvertCurrency(received1, "TRY", true);


        if (currencyConversation != null)
        {
            decimal kambiyoValue = ValidationHelper.GetDecimal(App.Params.GetConfigKeyValue("KAMBIYO_VALUE", "2"), 2);

            decimal KambiyoAmount = Math.Round((currencyConversation.ToAmount.Amount / (decimal)1000) * kambiyoValue, 2);

            if (KambiyoAmount > 0)
            {
                new_KambiyoAmount.Hidden = false;
                new_KambiyoAmount.Show();
                new_KambiyoAmount.d1.SetValue(KambiyoAmount);
                new_KambiyoAmount.c1.SetValue(ReceivedOptionTry.c1.Value);
            }
            else
            {
                new_KambiyoAmount.d1.Clear();
                new_KambiyoAmount.Hidden = true;
                new_KambiyoAmount.Hide();

            }

            //EUR tutar hesaplanırken kambiyo tutar hesaplanmadığı için EUR daki tahsil tutarı 2 hesaplanırken kambiyo hesaplanıp tahsil tutarı 2 ye ekleniyor.
            ReceivedOptionEur_2.d1.SetValue(currencyConversation.ToAmount.Amount + KambiyoAmount);
        }
    }

    protected void ReceivedOptionUsd_OnChange(object sender, AjaxEventArgs e)
    {
        var packageAmount = new_PackageAmount.d1.Value;
        var packageAmountCurrency = ValidationHelper.GetGuid(new_PackageAmount.c1.Value);

        var expenseAmount = new_ExpenseAmount.d1.Value;
        var expenseAmountCurrency = ValidationHelper.GetGuid(new_ExpenseAmount.c1.Value);

        var receivedAmount1 = ReceivedOptionUsd_1.d1.Value;
        var receivedOptionUsdAmount = ValidationHelper.GetDecimal(ReceivedOptionUsdAmount.Value, 0);
        var receivedAmount1Currency = ValidationHelper.GetGuid(ReceivedOptionUsd_1.c1.Value);

        if (receivedOptionUsdAmount - receivedAmount1 < 0)
        {
            var msg = new MessageBox { Width = 500, Height = 250 };
            msg.Show("Tahsil tutarı işlem tutarından büyük olamaz!");
            ReceivedOptionUsd_1.d1.SetValue(receivedOptionUsdAmount);
            ReceivedOptionUsd_2.d1.SetValue(0);
            return;
        }

        if (ValidationHelper.GetDecimal(ReceivedExpenseOptionUsdAmount.Value, 0) > receivedAmount1)
        {
            var msg = new MessageBox { Width = 500, Height = 250 };
            msg.Show("Tahsil tutarı 1 masraftan küçük olamaz!");
            ReceivedOptionUsd_1.d1.SetValue(receivedOptionUsdAmount);
            ReceivedOptionUsd_2.d1.SetValue(0);
            return;
        }

        ExchangeRateService exchangeRateService = new ExchangeRateService();
        Money received1 = new Money() { Amount = ValidationHelper.GetDecimal(receivedOptionUsdAmount - receivedAmount1, 0), Currency = GsmPaymentCacheManager.CurrencyIds[receivedAmount1Currency] };

        CurrencyConversion currencyConversation = exchangeRateService.ConvertCurrency(received1, "TRY", false);

        if (currencyConversation != null)
        {
            ReceivedOptionUsd_2.d1.SetValue(Math.Round(currencyConversation.ToAmount.Amount, 2));
        }


        if (received1.Currency.CurrencyId != packageAmountCurrency)
        {
            /*USD seçenek hesaplanırken içine arbitrajdan dolayı kambiyo dahil edilmişti, USD tahsil tutarı 2 ye ekstra bir kambiyo tutarı eklemiyoruz, 
             sadece kambiyo tutar alanına tüm usd tutarın kambiyo oranı kadar TL karşılığını yazarız.*/

            decimal kambiyoValue = ValidationHelper.GetDecimal(App.Params.GetConfigKeyValue("KAMBIYO_VALUE", "2"), 2);

            Money kambiyoUsdAmount = new Money() { Amount = ValidationHelper.GetDecimal((receivedOptionUsdAmount / (decimal)1000) * kambiyoValue, 0), Currency = received1.Currency };
            CurrencyConversion kambiyoConversation = exchangeRateService.ConvertCurrency(kambiyoUsdAmount, "TRY", false);

            if (kambiyoConversation != null)
            {
                new_KambiyoAmount.Hidden = false;
                new_KambiyoAmount.Show();
                new_KambiyoAmount.d1.SetValue(kambiyoConversation.ToAmount.Amount);
                new_KambiyoAmount.c1.SetValue(ReceivedOptionTry.c1.Value);
            }
        }
        else
        {
            new_KambiyoAmount.Hidden = true;
            new_KambiyoAmount.Hide();
        }

    }

    protected void ReceivedOptionTry_OnChange(object sender, AjaxEventArgs e)
    {
        decimal kambiyoValue = ValidationHelper.GetDecimal(App.Params.GetConfigKeyValue("KAMBIYO_VALUE", "2"), 2);

        var receivedAmount1 = ReceivedOptionTry.d1.Value;

        decimal kambiyoAmount = Math.Round(ValidationHelper.GetDecimal((receivedAmount1 / (decimal)1000) * kambiyoValue, 0), 2);


        if (kambiyoAmount > 0)
        {
            new_KambiyoAmount.Hidden = false;
            new_KambiyoAmount.Show();
            new_KambiyoAmount.d1.SetValue(kambiyoAmount);
            new_KambiyoAmount.c1.SetValue(ReceivedOptionTry.c1.Value);
        }
        else
        {
            new_KambiyoAmount.Hidden = true;
            new_KambiyoAmount.Hide();
        }

    }


    #endregion

    #region Click Event

    protected void btnTopup_Click(object sender, AjaxEventArgs e)
    {
        try
        {
            decimal kambiyoValue = ValidationHelper.GetDecimal(App.Params.GetConfigKeyValue("KAMBIYO_VALUE", "2"), 2);


            QScript("LogGsmCurrentPage();");

            Money ReceivedAmount1 = new Money();
            Money ReceivedAmount2 = new Money();
            Money ReceivedExpenseAmount = new Money();

            decimal parity1 = 0;
            decimal parity2 = 0;

            decimal originalParity1 = 0;
            decimal originalParity2 = 0;

            if (SelectedCollectionOption.Value == "RadioEur")
            {
                ReceivedAmount1 = new Money() { Amount = ValidationHelper.GetDecimal(ReceivedOptionEur_1.d1.Value, 0), Currency = GsmPaymentCacheManager.CurrencyIds[ValidationHelper.GetGuid(ReceivedOptionEur_1.c1.Value)] };
                ReceivedAmount2 = new Money() { Amount = ValidationHelper.GetDecimal(ReceivedOptionEur_2.d1.Value, 0), Currency = GsmPaymentCacheManager.CurrencyIds[ValidationHelper.GetGuid(ReceivedOptionEur_2.c1.Value)] };
                ReceivedExpenseAmount = new Money() { Amount = ValidationHelper.GetDecimal(ReceivedExpenseOptionEurAmount.Value, 0), Currency = GsmPaymentCacheManager.CurrencyIds[ValidationHelper.GetGuid(ReceivedOptionEur_1.c1.Value)] };

                parity1 = ValidationHelper.GetDecimal(NumEurParity1.Value, 0, CultureInfo.CurrentCulture);
                parity2 = ValidationHelper.GetDecimal(NumEurParity2.Value, 0, CultureInfo.CurrentCulture);

                originalParity1 = ValidationHelper.GetDecimal(NumEurOriginalParity1.Value, 0, CultureInfo.CurrentCulture);
                originalParity2 = ValidationHelper.GetDecimal(NumEurOriginalParity2.Value, 0, CultureInfo.CurrentCulture);

                string res = CheckAmount(ReceivedAmount1.Amount);
                if (!string.IsNullOrEmpty(res))
                {
                    var msg = new MessageBox { Width = 500, Height = 250 };
                    msg.Show(res);
                    return;
                }
            }
            else if (SelectedCollectionOption.Value == "RadioUsd")
            {
                ReceivedAmount1 = new Money() { Amount = ValidationHelper.GetDecimal(ReceivedOptionUsd_1.d1.Value, 0, CultureInfo.CurrentCulture), Currency = GsmPaymentCacheManager.CurrencyIds[ValidationHelper.GetGuid(ReceivedOptionUsd_1.c1.Value)] };
                ReceivedAmount2 = new Money() { Amount = ValidationHelper.GetDecimal(ReceivedOptionUsd_2.d1.Value, 0, CultureInfo.CurrentCulture), Currency = GsmPaymentCacheManager.CurrencyIds[ValidationHelper.GetGuid(ReceivedOptionUsd_2.c1.Value)] };
                ReceivedExpenseAmount = new Money() { Amount = ValidationHelper.GetDecimal(ReceivedExpenseOptionUsdAmount.Value, 0), Currency = GsmPaymentCacheManager.CurrencyIds[ValidationHelper.GetGuid(ReceivedOptionUsd_1.c1.Value)] };


                parity1 = ValidationHelper.GetDecimal(NumUsdParity1.Value, 0, CultureInfo.CurrentCulture);
                parity2 = ValidationHelper.GetDecimal(NumUsdParity2.Value, 0, CultureInfo.CurrentCulture);

                originalParity1 = ValidationHelper.GetDecimal(NumUsdOriginalParity1.Value, 0, CultureInfo.CurrentCulture);
                originalParity2 = ValidationHelper.GetDecimal(NumUsdOriginalParity2.Value, 0, CultureInfo.CurrentCulture);

                string res = CheckAmount(ReceivedAmount1.Amount);
                if (!string.IsNullOrEmpty(res))
                {
                    var msg = new MessageBox { Width = 500, Height = 250 };
                    msg.Show(res);
                    return; 
                }


            }
            else if (SelectedCollectionOption.Value == "RadioTry")
            {
                ReceivedAmount1 = new Money() { Amount = ValidationHelper.GetDecimal(ReceivedOptionTry.d1.Value, 0, CultureInfo.CurrentCulture), Currency = GsmPaymentCacheManager.CurrencyIds[ValidationHelper.GetGuid(ReceivedOptionTry.c1.Value)] };
                ReceivedExpenseAmount = new Money() { Amount = ValidationHelper.GetDecimal(ReceivedExpenseOptionTryAmount.Value, 0), Currency = GsmPaymentCacheManager.CurrencyIds[ValidationHelper.GetGuid(ReceivedOptionTry.c1.Value)] };

                parity1 = ValidationHelper.GetDecimal(NumTryParity1.Value, 0, CultureInfo.CurrentCulture);
                originalParity1 = ValidationHelper.GetDecimal(NumTryOriginalParity1.Value, 0, CultureInfo.CurrentCulture);

            }


            Guid gsmPaymentId = ValidationHelper.GetGuid(New_GsmPaymentId.Value, Guid.Empty);

            GsmTransactionService service = new GsmTransactionService();
            GsmTransaction transaction = service.GetGsmPayment(gsmPaymentId);

            transaction.Package.ReceivedAmount1 = ReceivedAmount1;
            transaction.Package.ReceivedAmount1Parity = parity1;
            transaction.Package.ReceivedAmount1OriginalParity = originalParity1;
            transaction.Package.ReceivedAmount2 = ReceivedAmount2;
            transaction.Package.ReceivedAmount2Parity = parity2;
            transaction.Package.ReceivedAmount2OriginalParity = originalParity2;
            transaction.Package.ReceivedExpenseAmount = ReceivedExpenseAmount;
            if (new_KambiyoAmount != null && ValidationHelper.GetDecimal(new_KambiyoAmount.d1.Value, 0) > 0)
            {
                transaction.Package.KambiyoTutar = new Money()
                {
                    Amount = ValidationHelper.GetDecimal(new_KambiyoAmount.d1.Value, 0),
                    Currency = GsmPaymentCacheManager.CurrencyIds[ValidationHelper.GetGuid(new_KambiyoAmount.c1.Value)]
                };
            }


            CalculateTransaction(transaction);



            bool result = service.CommitTransaction(transaction);

            if (result)
            {
                string transactionIntegrationRef = transaction.IntegratorReference;

                QScript("alert('İşleminiz başarı ile tamamlandı. Upt Ref:" + transaction.TransactionReference + "');");


                QScript(string.Format("hdnReportId.setValue('{0}');", reportId));
                QScript(string.Format("hdnRecid.setValue('{0}');", ValidationHelper.GetString(New_GsmPaymentId.Value)));

                QScript("GsmDekontBas();");


                QScript("RefreshParetnGridForGsmPayment(true);");
            }
            else
            {
                QScript("alert('İşleminiz upt merkezi onayında. Upt Ref:" + transaction.TransactionReference + "');");
                QScript("RefreshParetnGridForGsmPayment(true);");

            }
        }
        catch (Exception ex)
        {
            var msg = new MessageBox { Width = 500, Height = 250 };
            msg.Show("Hata: " + ex.Message);
        }






    }

    private string CheckAmount(decimal amount)
    {
        decimal kalan = amount % 5;
        if (kalan > 0)
        {
            return "Döviz tahsilatlarda küsüratlı tahsil yapamazsınız, lütfen tahsilat tutarını güncelleyin!";
        }
        else
        {
            return string.Empty;
        }
    }

    protected void btnGetPackages_Click(object sender, AjaxEventArgs e)
    {
        if (!GetPackageValidation())
        {
            return;
        }

        try
        {
            GsmOperator gsmOperator = new GsmOperator();

            if (!string.IsNullOrEmpty(new_GsmOperatorId.Value))
            {
                GsmOperatorService operatorService = new GsmOperatorService();
                gsmOperator = operatorService.GetGsmOperator(ValidationHelper.GetGuid(new_GsmOperatorId.Value));
            }

            string errorMsg = string.Empty;

            var countryPhoneCode = new_GsmCountryId.SelectedItems[0]["new_TelephoneCode"];
            PackageType packageType = null;
            if (countryPhoneCode == "0090")
            {
                //var integratorPackageTypeCode = GsmoperatorPackageType.SelectedItems[0]["PackageTypeCode"];
                //var packageTypeName = GsmoperatorPackageType.SelectedItems[0]["PackageTypeName"];
                //packageType = new PackageType() { PackageTypeCode = integratorPackageTypeCode, PackageTypeName = packageTypeName };
            }




            string phoneNumber = GetPhoneNumber(new_GsmNumber.Value);

            GsmCountryService countryService = new GsmCountryService();
            GsmCountry gsmCountry = countryService.GetGsmCountry(ValidationHelper.GetGuid(new_GsmCountryId.Value));

            GsmTransactionService service = new GsmTransactionService();
            GsmTransaction transaction = service.CreateTransaction(ValidationHelper.GetGuid(new_SenderId.Value), new GsmPhone() { CountryCode = countryPhoneCode, PhoneNumber = phoneNumber, Country = gsmCountry }, gsmOperator, packageType, out errorMsg);

            if (transaction != null && transaction.GsmOperator != null)
            {
                if (string.IsNullOrEmpty(new_GsmOperatorId.Value))
                {
                    new_GsmOperatorId.SetValue(transaction.GsmOperator.ID, transaction.GsmOperator.Name);
                }

                New_GsmPaymentId.SetIValue(ValidationHelper.GetString(transaction.TransactionId, string.Empty));

                GrdPackages.DataSource = transaction.GsmOperator.Packages;
                GrdPackages.DataBind();
            }
            else
            {
                GrdPackages.Clear();

                var msg = new MessageBox { Width = 500, Height = 250 };
                msg.Show(errorMsg);
                return;
            }
        }
        catch (Exception ex)
        {
            var msg = new MessageBox { Width = 500, Height = 250 };
            msg.Show("Hata!", ex.Message);
            return;
        }



    }

    private string GetPhoneNumber(string gsmNumber)
    {
        string[] a = gsmNumber.Split(' ');
        if (a.Length == 3)
        {
            gsmNumber = a[1] + a[2];
        }
        return gsmNumber;
    }

    private bool GetPackageValidation()
    {
        if (new_GsmCountryId.IsEmpty)
        {
            var msg = new MessageBox { Width = 500, Height = 250 };
            msg.Show("Ülke seçmelisiniz!");
            return false;
        }

        if (string.IsNullOrEmpty(new_GsmNumber.Value))
        {
            var msg = new MessageBox { Width = 500, Height = 250 };
            msg.Show("Telefon numarası girmelisiniz!");
            return false;
        }

        return true;
    }

    protected void LoadPackage(object sender, AjaxEventArgs e)
    {
        try
        {
            if (new_SenderId.IsEmpty)
            {
                var msg = new MessageBox { Width = 500, Height = 250 };
                msg.Show("Gönderici seçmelisiniz!");
                return;
            }


            Package selectedPackage = GetPackage();

            if (selectedPackage != null)
            {
                Guid gsmPaymentId = ValidationHelper.GetGuid(New_GsmPaymentId.Value, Guid.Empty);
                GsmTransactionService service = new GsmTransactionService();
                GsmTransaction transaction = service.GetGsmPayment(gsmPaymentId);

                transaction.SenderId = ValidationHelper.GetGuid(new_SenderId.Value);
                transaction.Package = selectedPackage;

                SetPackageValues(transaction);

                service.UpdateGsmTransactionSelectedPackage(transaction);

                service.SetTransactionPackage(transaction);

                SetCollectionOptions(transaction);

                #region Blacklist Request

                if (!ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("PAYGATE_ISACTIVE"), false))
                {
                    transaction.Sender = service.GetGsmSender(transaction.SenderId);
                    BlacklistInput input = new BlacklistInput() { GsmPayment = transaction };
                    new GsmPaymentBlackListManager().GetTransferBlackListCheck(input, true);
                }
                #endregion





                gsmTransactiomnDetail.Show();
            }

        }
        catch (UPT.Shared.Entity.TuException.TuException exc)
        {
            exc.Show();
        }


    }

    private Package GetPackage()
    {
        var degerler = ((RowSelectionModel)GrdPackages.SelectionModel[0]);
        if (degerler != null && degerler.SelectedRows != null)
        {
            //Gridde Money object halinde taşındığı için json kullanılarak objeye cast edildi.
            var pricejson = degerler.SelectedRows[0].Price;
            var wholeSalePricejson = degerler.SelectedRows[0].WholeSalePrice;

            string output = JsonConvert.SerializeObject(pricejson);
            Money price = JsonConvert.DeserializeObject<Money>(output);


            string wholeSalePriceoutput = JsonConvert.SerializeObject(wholeSalePricejson);
            Money wholeSaleprice = JsonConvert.DeserializeObject<Money>(wholeSalePriceoutput);

            var expenseAmountjson = degerler.SelectedRows[0].ExpenseAmount;

            string expenseAmountStr = JsonConvert.SerializeObject(expenseAmountjson);
            Money expenseAmount = JsonConvert.DeserializeObject<Money>(expenseAmountStr);

            var expensejson = degerler.SelectedRows[0].Expense;

            string expenseStr = JsonConvert.SerializeObject(expensejson);
            GsmExpense expense = JsonConvert.DeserializeObject<GsmExpense>(expenseStr);



            var PackageId = ValidationHelper.GetGuid(degerler.SelectedRows[0].PackageId);
            var name = ValidationHelper.GetString(degerler.SelectedRows[0].Name);
            var code = ValidationHelper.GetString(degerler.SelectedRows[0].Code);
            var packetAmount = ValidationHelper.GetString(degerler.SelectedRows[0].PriceStr);

            var exParam1 = ValidationHelper.GetString(degerler.SelectedRows[0].ExParam1);

            var exParam2 = ValidationHelper.GetString(degerler.SelectedRows[0].ExParam2);

            PackageType packageType = null;

            //if (GsmoperatorPackageType.SelectedItems != null)
            //{
            //    var integratorPackageTypeCode = GsmoperatorPackageType.SelectedItems[0]["PackageTypeCode"];
            //    var packageTypeName = GsmoperatorPackageType.SelectedItems[0]["PackageTypeName"];
            //    string talepId = ValidationHelper.GetString(GsmoperatorPackageType.SelectedItems[0]["TalepId"]);
            //    packageType = new PackageType() { PackageTypeCode = integratorPackageTypeCode, PackageTypeName = packageTypeName, TalepId = talepId };
            //}


            Package selectedPackage = new Package()
            {
                Name = name,
                Code = code,
                Price = price,
                WholeSalePrice = wholeSaleprice,
                ExpenseAmount = expenseAmount,
                Expense = expense,
                GsmOperatorPackageType = packageType,
                ExParam1 = exParam1,
                ExParam2 = exParam2
            };

            return selectedPackage;
        }
        return null;
    }

    private void SetPackageValues(GsmTransaction gsmTransaction)
    {
        txtPackageName.SetValue(gsmTransaction.Package.Name);

        new_PackageAmount.d1.SetIValue(gsmTransaction.Package.Price.Amount);
        new_PackageAmount.c1.SetValue(gsmTransaction.Package.Price.Currency.CurrencyId, gsmTransaction.Package.Price.Currency.ISOCurrencyCode);

        new_ExpenseAmount.d1.SetIValue(gsmTransaction.Package.ExpenseAmount.Amount);
        new_ExpenseAmount.c1.SetValue(gsmTransaction.Package.ExpenseAmount.Currency.CurrencyId, gsmTransaction.Package.ExpenseAmount.Currency.ISOCurrencyCode);

        new_GsmOperatorIdW.SetValue(gsmTransaction.GsmOperator.ID, gsmTransaction.GsmOperator.Name);


        new_GsmNumberW.SetValue(gsmTransaction.Msisdn.ToString());
    }

    private void SetCollectionOptions(GsmTransaction transaction)
    {

        if (transaction.CollectingOptions.Count == 3)
        {
            //EUR
            ReceivedOptionEur_1.d1.SetValue(transaction.CollectingOptions["EUR"].Amount1.Amount);
            ReceivedOptionEur_1.c1.SetValue(transaction.CollectingOptions["EUR"].Amount1.Currency.CurrencyId, transaction.CollectingOptions["EUR"].Amount1.Currency.ISOCurrencyCode);
            ReceivedOptionEurAmount.SetIValue(transaction.CollectingOptions["EUR"].Amount1.Amount);

            ReceivedExpenseOptionEurAmount.SetIValue(transaction.CollectingOptions["EUR"].ReceivedExpenseAmount.Amount);

            NumEurParity1.Clear();
            NumEurParity1.SetValue(transaction.CollectingOptions["EUR"].Amount1CurrencyConversion.Parity);
            NumEurOriginalParity1.Clear();
            NumEurOriginalParity1.SetValue(transaction.CollectingOptions["EUR"].Amount1CurrencyConversion.OriginalParity);
            NumEurParity2.Clear();
            NumEurParity2.SetValue(transaction.CollectingOptions["TRY"].Amount1CurrencyConversion.Parity);
            NumEurOriginalParity2.Clear();
            NumEurOriginalParity2.SetValue(transaction.CollectingOptions["TRY"].Amount1CurrencyConversion.OriginalParity);


            ReceivedOptionEur_2.d1.SetValue(0);
            ReceivedOptionEur_2.c1.SetValue(transaction.CollectingOptions["TRY"].Amount1.Currency.CurrencyId, transaction.CollectingOptions["TRY"].Amount1.Currency.ISOCurrencyCode);

            //USD
            ReceivedOptionUsd_1.d1.SetValue(transaction.CollectingOptions["USD"].Amount1.Amount);
            ReceivedOptionUsd_1.c1.SetValue(transaction.CollectingOptions["USD"].Amount1.Currency.CurrencyId, transaction.CollectingOptions["USD"].Amount1.Currency.ISOCurrencyCode);
            ReceivedOptionUsdAmount.SetIValue(transaction.CollectingOptions["USD"].Amount1.Amount);
            ReceivedExpenseOptionUsdAmount.SetIValue(transaction.CollectingOptions["USD"].ReceivedExpenseAmount.Amount);

            NumUsdParity1.Clear();
            NumUsdParity1.SetValue(transaction.CollectingOptions["USD"].Amount1CurrencyConversion.Parity);
            NumUsdOriginalParity1.Clear();
            NumUsdOriginalParity1.SetValue(transaction.CollectingOptions["USD"].Amount1CurrencyConversion.OriginalParity);

            ReceivedOptionUsd_2.d1.SetValue(0);
            ReceivedOptionUsd_2.c1.SetValue(transaction.CollectingOptions["TRY"].Amount1.Currency.CurrencyId, transaction.CollectingOptions["TRY"].Amount1.Currency.ISOCurrencyCode);
            NumUsdParity2.Clear();
            NumUsdParity2.SetValue(transaction.CollectingOptions["TRY"].Amount1CurrencyConversion.Parity);
            NumUsdOriginalParity2.Clear();
            NumUsdOriginalParity2.SetValue(transaction.CollectingOptions["TRY"].Amount1CurrencyConversion.OriginalParity);

            //TRY
            ReceivedOptionTry.d1.SetValue(transaction.CollectingOptions["TRY"].Amount1.Amount);
            ReceivedOptionTry.c1.SetValue(transaction.CollectingOptions["TRY"].Amount1.Currency.CurrencyId, transaction.CollectingOptions["TRY"].Amount1.Currency.ISOCurrencyCode);
            ReceivedExpenseOptionTryAmount.SetIValue(transaction.CollectingOptions["TRY"].ReceivedExpenseAmount.Amount);
            NumTryParity1.Clear();
            NumTryParity1.SetValue(transaction.CollectingOptions["TRY"].Amount1CurrencyConversion.Parity);
            NumTryOriginalParity1.Clear();
            NumTryOriginalParity1.SetValue(transaction.CollectingOptions["TRY"].Amount1CurrencyConversion.OriginalParity);
        }


        ReceivedOptionEur_1.c1.SetDisabled(true);
        ReceivedOptionEur_2.c1.SetDisabled(true);
        ReceivedOptionUsd_1.c1.SetDisabled(true);
        ReceivedOptionUsd_2.c1.SetDisabled(true);
        ReceivedOptionTry.c1.SetDisabled(true);
    }

    private void CalculateTransaction(GsmTransaction transaction)
    {
        CalculateFactory calcFactory = new CalculateFactory();
        TuFactory.Domain.ConvertedMoney muhasebeTutar = calcFactory.GetAccountMoney(transaction.CorporationId, transaction.OfficeId, transaction.Package.Price, 1);
        TuFactory.Domain.ConvertedMoney muhasebeMasrafTutar = calcFactory.GetAccountMoney(transaction.CorporationId, transaction.OfficeId, transaction.Package.Expense.ExpenseAmount, 1);


        GsmExpenseService expenseService = new GsmExpenseService();
        transaction.Package.CommissionAmount = expenseService.GetGsmCommissionAmount(transaction);


        transaction.Package.MuhasebeTutar = new Upt.Core.Domain.Money() { Amount = muhasebeTutar.Amount, Currency = new Upt.Core.Domain.Currency() { CurrencyId = muhasebeTutar.Currency.CurrencyId, ISOCurrencyCode = muhasebeTutar.Currency.ISOCurrencyCode } }; //transaction.Package.Price.ToCopy();
        transaction.Package.MuhasebeMasrafTutar = new Upt.Core.Domain.Money() { Amount = muhasebeMasrafTutar.Amount, Currency = new Upt.Core.Domain.Currency() { CurrencyId = muhasebeMasrafTutar.Currency.CurrencyId, ISOCurrencyCode = muhasebeMasrafTutar.Currency.ISOCurrencyCode } }; //transaction.Package.Price.ToCopy();
        transaction.Package.MuhasebeMasrafTutarParity = muhasebeMasrafTutar.Parity;
        transaction.Package.MuhasebeTutarParity = muhasebeTutar.Parity;
        transaction.Package.MuhasebeMasrafTutarOriginalParity = muhasebeMasrafTutar.OriginalParity;
        transaction.Package.MuhasebeTutarOriginalParity = muhasebeTutar.OriginalParity;



    }

    #endregion

    #region Other Methods

    private void SetGsmCountryTelephoneCode()
    {
        //Gsm ülkesinin telefon kodunu js tarafından setliyoruz, cs tarafından setledeğimizde bug var, 
        //  telefon numarasını girildikten sonra ülkeyi değiştirisen kontroö dağılıyor, 
        //  ülke kodunu başa değil sona setliyor.


        new_GsmCountryId.Listeners.Change.Handler = @"if(new_GsmCountryId.selectedRecord.new_TelephoneCode != undefined)
                                                        {
                                                            document.getElementById('_new_GsmNumber').value = new_GsmCountryId.selectedRecord.new_TelephoneCode; 
                                                        }";
    }

    #endregion

    protected void new_GsmoperatorPackageTypeLoad(object sender, AjaxEventArgs e)
    {
        var telephoneCode = new_GsmCountryId.SelectedItems[0]["new_TelephoneCode"];

        GsmOperator gsmOperator = new GsmOperator();

        if (!string.IsNullOrEmpty(new_GsmOperatorId.Value))
        {
            GsmOperatorService operatorService = new GsmOperatorService();
            gsmOperator = operatorService.GetGsmOperator(ValidationHelper.GetGuid(new_GsmOperatorId.Value));
        }


        GsmOperatorService service = new GsmOperatorService();
        List<PackageType> list = service.GetOperatorPackageTypes(telephoneCode, gsmOperator.IntegratorGsmOperatorCode);

        //GsmoperatorPackageType.DataSource = list;
        //GsmoperatorPackageType.DataBind();
    }


    //Kanaldan operatorleri birdefalık çekmek için hazırlandı.

    //protected void btnGetOperatorLoad_Click(object sender, AjaxEventArgs e)
    //{
    //    GsmOperatorService service = new GsmOperatorService();
    //    service.SaveGsmOperator("NKOLAY", "TR");
    //}


    protected void btnGetReconcliationData_Click(object sender, AjaxEventArgs e)
    {
        GsmTransactionService service = new GsmTransactionService();

        //List<TransactionListItem> list = service.GetTransactionList(GsmIntegratorCode.Value, DateTime.Now.AddDays(-30), DateTime.Now);

        TransactionInfoItem item = service.GetTransactionInfo(GsmIntegratorCode.Value, CorporationReference.Value);
        if (item != null && !string.IsNullOrEmpty(item.CorporationStatusCode))
        {
            txtCorporationReference.SetValue(item.CorporationTransactionNumber);
            txtCorporationStatus.SetValue(item.CorporationStatusDesc);
            txtTransactionReference.SetValue(GsmTransactionReference.Value);
            txtOperatorName.SetValue(item.GsmOperatorName);
            txtMsisdn.SetValue(item.Msisdn);

            gsmPaymentCorporationDetail.Show();

        }

    }

    protected void btnCancel_Click(object sender, AjaxEventArgs e)
    {
        QScript("LogGsmCurrentPage();");

        Guid gsmPaymentId = ValidationHelper.GetGuid(New_GsmPaymentId.Value, Guid.Empty);

        GsmTransactionService service = new GsmTransactionService();

        TransactionInfoItem item = service.GetTransactionInfo(GsmIntegratorCode.Value, CorporationReference.Value);

        if (item.CorporationStatusCode == "999" || item.CorporationStatusCode == "998")
        {
            service.CancelRequestGsmPayment(gsmPaymentId, App.Params.CurrentUser.SystemUserId);

            QScript("alert('İptal işlemi onaya gönderildi.');");
            QScript("RefreshParetnGridForGsmPayment(true);");
            //QScript("RefreshParetnGrid(true)");
        }
        else
        {
            var msg = new MessageBox { Width = 600, Height = 250 };
            msg.Show("İşlemin statüsü iptal için uygun değildir. StatusCode=" + item.CorporationStatusCode + ", Status=" + item.CorporationStatusDesc);
            return;
        }

    }
    protected void btnReject_Click(object sender, AjaxEventArgs e)
    {
        QScript("LogGsmCurrentPage();");

        Guid gsmPaymentId = ValidationHelper.GetGuid(New_GsmPaymentId.Value, Guid.Empty);
        GsmTransactionService service = new GsmTransactionService();
        service.RejectGsmPaymentCancel(gsmPaymentId, App.Params.CurrentUser.SystemUserId);

        QScript("alert('İptal işlemi geri çevrildi.');");
        QScript("RefreshParetnGridForGsmPayment(true);");
        //QScript("RefreshParetnGrid(true)");

    }


    protected void btnConfirm_Click(object sender, AjaxEventArgs e)
    {
        QScript("LogGsmCurrentPage();");
        Guid gsmPaymentId = ValidationHelper.GetGuid(New_GsmPaymentId.Value, Guid.Empty);

        GsmTransactionService service = new GsmTransactionService();

        service.CancelConfirmGsmPayment(gsmPaymentId, App.Params.CurrentUser.SystemUserId);

        QScript("alert('İşlem İptal Edildi.');");


        QScript(string.Format("hdnReportId.setValue('{0}');", reportId));
        QScript(string.Format("hdnRecid.setValue('{0}');", ValidationHelper.GetString(New_GsmPaymentId.Value)));

        QScript("GsmDekontBas();");



        QScript("RefreshParetnGridForGsmPayment(true);");
    }

    protected void btnPrint_Click(object sender, AjaxEventArgs e)
    {
        GsmTransactionService service = new GsmTransactionService();
        GsmTransaction transaction = service.GetGsmPayment(ValidationHelper.GetGuid(New_GsmPaymentId.Value));
        CashFactory cashFactory = new CashFactory();
        Guid cashId = cashFactory.GetUserCashId(App.Params.CurrentUser.SystemUserId);

        StaticData sd = new StaticData();
        DbTransaction tr = sd.GetDbTransaction();
        if (transaction.LoadStatus == GsmLoadStatus.Yukleme_Iptal_Edildi.GetHashCode() && cashId != Guid.Empty)
        {
            try
            {
                service.CreateGsmPaymentCashTransaction(transaction, tr);

                service.UpdateGsmTransactionLoadStatus(GsmLoadStatus.Yukleme_Iptal_Edildi_Dekont_Basıldı, transaction.TransactionId, App.Params.CurrentUser.SystemUserId, tr);

                StaticData.Commit(tr);

            }
            catch (Exception)
            {
                StaticData.Rollback(tr);

                throw;
            }

        }
        Guid gsmPaymentId = ValidationHelper.GetGuid(New_GsmPaymentId.Value, Guid.Empty);

        QScript(string.Format("hdnReportId.setValue('{0}');", reportId));
        QScript(string.Format("hdnRecid.setValue('{0}');", ValidationHelper.GetString(New_GsmPaymentId.Value)));

        QScript("GsmDekontBas();");
    }

}