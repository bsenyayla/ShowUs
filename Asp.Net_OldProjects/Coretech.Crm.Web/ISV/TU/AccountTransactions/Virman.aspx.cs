using System;
using System.Data;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Data;
using TuFactory.Object;
using TuFactory.Object.User;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using TuFactory.AccountTransactions;
using TuFactory.AccountTransactions.Objects;
using TuFactory.Object.Virements;
using TuFactory.Virement;
using System.Globalization;
using Coretech.Crm.Factory;
using TuFactory.Virement.Objects;
using TuFactory.TuUser;
using TuFactory.VirtualIban;
using TuFactory.CustAccount;

public partial class AccountTransactions_Virman : BasePage
{
    #region Variables
    private string _CountryCurrencyID;
    private string _CountryCurrencyIDName;
    private bool _IsPartlyCollection = false; //Bu kurumda parcalı tahsilat kullanılır.
    private TuUserApproval _userApproval = null;
    private string TransactionType = string.Empty;
    public Guid recId = Guid.Empty;

    //bireyselMüşteriHesapKodları
    string individualCustomerAccounts;
    //tüzel müşteri 
    string corporateCustomerAccounts;
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

        //bireyselMüşteriHesapKodları
        individualCustomerAccounts = App.Params.GetConfigKeyValue("INSTRUCTED_OPERATIONS_INDIVIDUAL_CUSTOMER_ACCOUNTS");
        //tüzel müşteri 
        corporateCustomerAccounts = App.Params.GetConfigKeyValue("INSTRUCTED_OPERATIONS_CORPORATE_CUSTOMER_ACCOUNTS");

        new_CorporationSwiftInfo.FieldLabel = "Kurum Swift Bilgileri : ";
        new_CustAccountsId.FieldLabel = "Gönderen Alt Hesap";
        if (!RefleX.IsAjxPostback)
        {
            var ufFactory = new TuUserFactory();
            _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

            new_VirmanId.Value = QueryHelper.GetString("recid");

            //Eft Ayrıntıları
            PanelEftDetail.SetVisible(false);
            new_EftSenderName.SetValue(GetParameterByName("VIRMAN_SENDER_NAME"));
            //new_EftSenderTelephone.SetValue(GetParameterByName("VIRMAN_SENDER_TEL"));
            new_EftSenderTCKN.SetValue(GetParameterByName("VIRMAN_SENDER_VKN"));

            //Swift Ayrıntıları
            PanelSwiftDetail.SetVisible(false);
            new_SwfSenderName.SetValue(GetParameterByName("VIRMAN_SENDER_NAME"));
            //new_SwfSenderTelephone.SetValue(GetParameterByName("VIRMAN_SENDER_TEL"));
            new_SwfSenderAdres.SetValue(GetParameterByName("VIRMAN_SENDER_ADRES"));

            //btnVirementCancelRequest.Visible = false;
            btnVirementCancel.Visible = false;
            btnVirementCancelConfirm.Visible = false;
            btnVirementCancelUndo.Visible = false;
            new_CustAccountsId.SetVisible(false);

            VirementLoad(new_VirmanId.Value);
            LoadData();


  
        }

    }

    private void LoadData()
    {
        new_VirmanId.Value = QueryHelper.GetString("recid");

        if (!string.IsNullOrEmpty(new_VirmanId.Value))
        {
            DataTable dt = VirementFactory.Instance.GetVirementProperty(ValidationHelper.GetGuid(new_VirmanId.Value));
            int source = 0;
            VirementStatus status = 0;
            Guid modifiedBy = Guid.Empty;

            if (dt.Rows.Count > 0)
            {
                source = ValidationHelper.GetInteger(dt.Rows[0]["new_Source"], 0);
                status = (VirementStatus)ValidationHelper.GetInteger(dt.Rows[0]["new_Status"], 0);
                modifiedBy = ValidationHelper.GetGuid(dt.Rows[0]["ModifiedBy"], Guid.Empty);

                //source 1=İşlem,2=Operasyon
                if (source == 2 && status != VirementStatus.VirementCancelled && status != VirementStatus.VirementCancelOnConfirm && status != VirementStatus.AccountTransactionCreated)
                {
                    btnVirementCancel.Visible = true;
                    btnVirementCancel.SetVisible(true);
                }

                //if (source == 2 && status == VirementStatus.VirementCancelOnConfirm && modifiedBy != Guid.Empty && modifiedBy == Guid.Parse(App.Params.GetConfigKeyValue("ADMIN_USER_ID")))

                if (_userApproval.VirementCancelConfirm && source == 2 && status == VirementStatus.VirementCancelOnConfirm)
                {
                    btnVirementCancelConfirm.Visible = true;
                    btnVirementCancelConfirm.SetVisible(true);

                    btnVirementCancelUndo.Visible = true;
                    btnVirementCancelUndo.SetVisible(true);
                }
            }


            if (ValidationHelper.GetGuid(new_VirmanId.Value) != Guid.Empty)
            {
                Account SenderAccount = AccountTransactionFactory.Instance.GetAccountDetail(new_SenderAccountId.Value);
                if (individualCustomerAccounts.Contains(SenderAccount.AccountNumber) || corporateCustomerAccounts.Contains(SenderAccount.AccountNumber))
                {

                    new_CustAccountsId.SetVisible(true);
                    new_CustAccountsId.Visible = true;
                }
            }
        }

        VirementType type = new VirementDb().GetVirementType(ValidationHelper.GetGuid(new_VirementType.Value));

        if (type != null)
        {
            if (type.Code.Equals("005") || type.Code.Equals("006") || type.Code.Equals("007") || type.Code.Equals("008"))
            {
                new_RecipientAccountId.SetVisible(false);
                new_RecipientSwiftAccountNo.SetVisible(true);
                new_CorporationSwiftInfo.SetVisible(true);
                new_TransferedAmount.SetVisible(false);
                new_RecipientAccountCurrencyIdName.SetVisible(false);
            }
            else
            {
                new_RecipientAccountId.SetVisible(true);
                new_RecipientSwiftAccountNo.SetVisible(false);
                new_CorporationSwiftInfo.SetVisible(false);
            }
            if (type.Code.Equals("001") || type.Code.Equals("007"))
            {
                new_Explanation.Visible = true;
                new_Explanation.SetVisible(true);
            }
            else
            {
                new_Explanation.Visible = false;
                new_Explanation.SetVisible(false);
            }
        }
    }

    protected void AccountChangeOnEvent(object sender, AjaxEventArgs e)
    {

        if (string.IsNullOrEmpty(new_VirementType.Value))
        {
            var msg = "Lütfen önce [ İşlem Tipi ] alanını seçiniz.";
            var m = new MessageBox { Width = 400, Height = 180 };
            string requiredmsg = string.Format(msg, new_TransactionRate.FieldLabel);
            m.Show(msg, requiredmsg);
            new_SenderAccountId.Clear();
            new_VirementType.Focus();
            return;
        }

        var c = (CrmComboComp)sender;
        if (c.UniqueName == "new_SenderAccountId")
        {
            new_RecipientAccountId.Value = string.Empty;
            new_RecipientAccountId.Clear();
            new_Amount.Clear();
            new_SenderAccountCurrencyId.Clear();
            new_RecipientAccountCurrencyId.Clear();
            new_TransactionRate.Clear();
            new_TransferedAmount.Clear();
            new_SenderAccountCurrencyIdName.Clear();
        }
        if (c.UniqueName == "new_RecipientAccountId")
        {
            new_RecipientAccountCurrencyIdName.Clear();
        }

        Account SenderAccount = AccountTransactionFactory.Instance.GetAccountDetail(new_SenderAccountId.Value);
        Account RecipientAccount = AccountTransactionFactory.Instance.GetAccountDetail(new_RecipientAccountId.Value);

        if (!string.IsNullOrEmpty(new_SenderAccountId.Value) && !string.IsNullOrEmpty(new_RecipientAccountId.Value) && new_SenderAccountId.Value.Equals(new_RecipientAccountId.Value))
        {
            var msg = "Seçilen Hesaplar Aynı Olamaz!";
            var m = new MessageBox { Width = 400, Height = 180 };
            string requiredmsg = string.Format(msg, new_TransactionRate.FieldLabel);
            m.Show(msg, requiredmsg);

            new_RecipientAccountId.Clear();

            return;
        }
        
        if (!String.IsNullOrEmpty(SenderAccount.AccountNumber))
        {
            if (individualCustomerAccounts.Contains(SenderAccount.AccountNumber) || corporateCustomerAccounts.Contains(SenderAccount.AccountNumber))
            {
                new_CustAccountsId.SetVisible(true);
                new_CustAccountsId.Visible = true;
            }
            else
            {
                new_CustAccountsId.Clear();
                new_CustAccountsId.SetVisible(false);
                new_CustAccountsId.Visible = false;
            }
        }else
        {
            new_CustAccountsId.Clear();
            new_CustAccountsId.SetVisible(false);
            new_CustAccountsId.Visible = false;
        }
        new_SenderAccountCurrencyId.SetValue(SenderAccount.CurrencyId);
        new_RecipientAccountCurrencyId.SetValue(RecipientAccount.CurrencyId);

        if (new_VirementType.SelectedItems[0]["new_Code"] == "002")
        {
            new_SenderAccountCurrencyIdName.SetValue(RecipientAccount.CurrencyCode);
            new_RecipientAccountCurrencyIdName.SetValue(SenderAccount.CurrencyCode);
        }
        else
        {
            new_SenderAccountCurrencyIdName.SetValue(SenderAccount.CurrencyCode);
            new_RecipientAccountCurrencyIdName.SetValue(RecipientAccount.CurrencyCode);
        }

        if (!String.IsNullOrEmpty(new_SenderAccountId.Value) && !String.IsNullOrEmpty(new_RecipientAccountId.Value))
        {
            if (SenderAccount.CurrencyId == RecipientAccount.CurrencyId || new_VirementType.SelectedItems[0]["new_Code"] == "006")
            {
                new_TransactionRate.SetValue(1);
            }
            else if (new_VirementType.SelectedItems[0]["new_Code"] == "004" || new_VirementType.SelectedItems[0]["new_Code"] == "003" || new_VirementType.SelectedItems[0]["new_Code"] == "002")
            {
                new_TransactionRate.Clear();
            }
            else
            {
                decimal rate = ValidationHelper.GetDecimal(AccountCurrencyFactory.Instance.GetCurrencyRate(SenderAccount.CurrencyCode, RecipientAccount.CurrencyCode), 0);
                new_TransactionRate.SetValue(rate);
            }
        }
        else
        {
            return;
        }
    }

    protected void AmountChangeOnEvent(object sender, AjaxEventArgs e)
    {
        string VirementCode = new_VirementType.SelectedItems[0]["new_Code"];
        if (VirementCode == "001" || VirementCode == "005" || VirementCode == "006" || VirementCode == "007") // Virman, Swift, Eft, Havale de kur 1
        {
            new_TransactionRate.SetValue(1);
            new_TransferedAmount.SetValue(new_Amount.Value);
            new_RecipientAccountCurrencyId.SetValue(new_SenderAccountCurrencyId.Value);
        }

        if (VirementCode == "004") //Arbitraj
        {
            string senderAccountCurrencyCode = new_SenderAccountId.SelectedItems[0]["new_BalanceCurrencyName"];
            string recipientAccountCurrencyCode = new_RecipientAccountId.SelectedItems[0]["new_BalanceCurrencyName"];

            if (senderAccountCurrencyCode == "USD" || (senderAccountCurrencyCode == "EUR" && recipientAccountCurrencyCode == "GBP"))
            {
                if (ValidationHelper.GetDecimal(new_Amount.Value, 0) != 0 && ValidationHelper.GetDecimal(new_TransactionRate.Value, 0) != 0)
                {
                    decimal transferedAmount = ValidationHelper.GetDecimal(new_Amount.Value, 0, CultureInfo.InvariantCulture) / ValidationHelper.GetDecimal(new_TransactionRate.Value, 0, CultureInfo.InvariantCulture);
                    //var amount = String.Format("{0:0.00}", Math.Truncate(transferedAmount * 100) / 100);
                    var amount = String.Format("{0:0.00}", Math.Round(transferedAmount, 2));
                    new_TransferedAmount.SetValue(amount);
                }
            }
            else
            {
                if (ValidationHelper.GetDecimal(new_Amount.Value, 0) != 0 && ValidationHelper.GetDecimal(new_TransactionRate.Value, 0) != 0)
                {
                    decimal transferedAmount = ValidationHelper.GetDecimal(new_Amount.Value, 0, CultureInfo.InvariantCulture) * ValidationHelper.GetDecimal(new_TransactionRate.Value, 0, CultureInfo.InvariantCulture);
                    //var amount = String.Format("{0:0.00}", Math.Truncate(transferedAmount * 100) / 100);
                    var amount = String.Format("{0:0.00}", Math.Round(transferedAmount, 2));
                    new_TransferedAmount.SetValue(amount);
                }
            }
        }
        else
        {
            if (ValidationHelper.GetDecimal(new_Amount.Value, 0) != 0 && ValidationHelper.GetDecimal(new_TransactionRate.Value, 0) != 0)
            {
                decimal transferedAmount = ValidationHelper.GetDecimal(new_Amount.Value, 0, CultureInfo.InvariantCulture) * ValidationHelper.GetDecimal(new_TransactionRate.Value, 0, CultureInfo.InvariantCulture);
                //var amount = String.Format("{0:0.00}", Math.Truncate(transferedAmount * 100) / 100);
                var amount = String.Format("{0:0.00}", Math.Round(transferedAmount, 2));
                new_TransferedAmount.SetValue(amount);
            }
        }


        //Yaziyla gostermece
        switch (VirementCode)
        {
            case "006": //EFT
                new_EftAmountText.SetValue(TuFactory.Utility.Num2TxtConverter.Convert(ValidationHelper.GetDecimal(new_Amount.Value, 0), "TL", "Kuruş"));
                break;
            case "005": //Swift
                new_SwfAmountText.SetValue(TuFactory.Utility.Num2TxtConverter.Convert(ValidationHelper.GetDecimal(new_Amount.Value, 0), null, new_SenderAccountCurrencyIdName.Value));
                break;
            default:
                break;
        }
    }

    protected void SenderAccountCurrencyChange(object sender, AjaxEventArgs e)
    {
    }

    protected void VirementTypeChange(object sender, AjaxEventArgs e)
    {
        var virementTypeCode = string.Empty;
        if (new_VirementType.SelectedItems != null)
        {
            virementTypeCode = new_VirementType.SelectedItems[0]["new_Code"];
        }

        if (virementTypeCode == "001" || virementTypeCode == "001")
        {
            new_RecipientAccountId.Clear();
            new_RecipientAccountId.SetRequirementLevel(RLevel.BusinessRequired);
            new_RecipientAccountId.Hidden = false;
            new_RecipientAccountId.SetVisible(true);
            new_RecipientAccountId.Visible = true;

            new_RecipientSwiftAccountNo.Clear();
            new_RecipientSwiftAccountNo.SetRequirementLevel(RLevel.None);
            new_RecipientSwiftAccountNo.Hidden = true;
            new_RecipientSwiftAccountNo.SetVisible(false);
            new_RecipientSwiftAccountNo.Visible = false;

            new_CorporationSwiftInfo.Clear();
            new_CorporationSwiftInfo.Hidden = true;
            new_CorporationSwiftInfo.SetVisible(false);
            new_CorporationSwiftInfo.Visible = false;


            new_TransactionRate.Clear();
            new_TransactionRate.ReadOnly = true;
            new_TransactionRate.SetReadOnly(true);

            new_TransferedAmount.SetRequirementLevel(RLevel.None);
            new_TransferedAmount.Visible = false;
            new_TransferedAmount.SetVisible(false);

            new_RecipientAccountCurrencyIdName.Visible = false;
            new_RecipientAccountCurrencyIdName.SetVisible(false);

            new_TransactionRate.Visible = false;
            new_TransactionRate.SetVisible(false);

            PanelEftDetail.SetVisible(false);
            PanelSwiftDetail.SetVisible(false);
        }
        else if (virementTypeCode == "005" || virementTypeCode == "006" || virementTypeCode == "007") /*Swift*/
        {

            new_RecipientAccountId.SetRequirementLevel(RLevel.None);
            new_RecipientAccountId.Clear();
            new_RecipientAccountId.Hidden = true;
            new_RecipientAccountId.SetVisible(false);
            new_RecipientAccountId.Visible = false;

            new_RecipientSwiftAccountNo.SetRequirementLevel(RLevel.BusinessRequired);
            new_RecipientSwiftAccountNo.Hidden = false;
            new_RecipientSwiftAccountNo.SetVisible(true);
            new_RecipientSwiftAccountNo.Visible = true;

            new_CorporationSwiftInfo.Hidden = false;
            new_CorporationSwiftInfo.SetVisible(true);
            new_CorporationSwiftInfo.Visible = true;


            new_TransactionRate.Visible = true;
            new_TransactionRate.SetVisible(true);
            new_TransactionRate.SetReadOnly(false);
            new_TransactionRate.ReadOnly = false;
            new_TransactionRate.Clear();

            new_TransferedAmount.SetRequirementLevel(RLevel.None);
            new_TransferedAmount.Visible = false;
            new_TransferedAmount.SetVisible(false);

            new_RecipientAccountCurrencyIdName.Visible = false;
            new_RecipientAccountCurrencyIdName.SetVisible(false);

            if (virementTypeCode == "006") /*Eft*/
            {
                PanelEftDetail.SetVisible(true);

                new_TransactionRate.SetIValue(1);
                new_TransactionRate.SetValue(1);
                new_TransactionRate.Value = 1;
                new_TransactionRate.SetReadOnly(true);
                new_TransactionRate.ReadOnly = true;
                new_TransactionRate.Clear();

      
            }
            else
            {
           

                PanelEftDetail.SetVisible(false);
            }

            if (virementTypeCode == "005")
            {
                PanelSwiftDetail.SetVisible(true);
                new_CorporationSwiftInfo.SetVisible(true);
                


            }
            else
            {
                PanelSwiftDetail.SetVisible(false);
                new_CorporationSwiftInfo.SetVisible(false);
            }
        }
        else
        {
            new_RecipientSwiftAccountNo.SetRequirementLevel(RLevel.None);
            new_RecipientSwiftAccountNo.Clear();
            new_RecipientSwiftAccountNo.Hidden = true;
            new_RecipientSwiftAccountNo.SetVisible(false);
            new_RecipientSwiftAccountNo.Visible = false;

            new_CorporationSwiftInfo.Clear();
            new_CorporationSwiftInfo.Hidden = true;
            new_CorporationSwiftInfo.SetVisible(false);
            new_CorporationSwiftInfo.Visible = false;


            new_RecipientAccountId.SetRequirementLevel(RLevel.BusinessRequired);
            new_RecipientAccountId.Hidden = false;
            new_RecipientAccountId.SetVisible(true);
            new_RecipientAccountId.Visible = true;

            new_TransferedAmount.SetRequirementLevel(RLevel.BusinessRequired);
            new_TransferedAmount.Visible = true;
            new_TransferedAmount.SetVisible(true);

            new_RecipientAccountCurrencyIdName.Visible = true;
            new_RecipientAccountCurrencyIdName.SetVisible(true);

            new_TransactionRate.Visible = true;
            new_TransactionRate.SetVisible(true);
            new_TransactionRate.SetReadOnly(false);
            new_TransactionRate.ReadOnly = false;
            new_TransactionRate.Clear();

            PanelEftDetail.SetVisible(false);
            PanelSwiftDetail.SetVisible(false);
        }

        if(virementTypeCode =="001" || virementTypeCode == "007")
        {
            new_Explanation.Visible = true;
            new_Explanation.SetVisible(true);
        }
        else
        {
            new_Explanation.Visible = false;
            new_Explanation.SetVisible(false);
        }


        if (virementTypeCode == "001" || virementTypeCode == "005" || virementTypeCode == "006" || virementTypeCode == "007")
        {
            if (virementTypeCode != "006")
            {

                new_AccountTransactionTypeId.Hidden = false;
                new_AccountTransactionTypeId.SetVisible(true);
                new_AccountTransactionTypeId.Visible = true;


            }

            new_TransactionRate.Hide();
            new_TransactionRate.Hidden = true;
        }
        else
        {
            new_AccountTransactionTypeId.Hidden = true;
            new_AccountTransactionTypeId.SetVisible(false);
            new_AccountTransactionTypeId.Visible = false;
        }

        ClearAll();
    }

    protected void SwfBicCountryOnChange(object sender, AjaxEventArgs e)
    {
        new_SwfBicBank.Clear();
        new_SwfBicBankCity.Clear();
        new_SwfBicCode.Clear();
    }

    protected void SwfBicBankOnChange(object sender, AjaxEventArgs e)
    {
        new_SwfBicBankCity.Clear();
        new_SwfBicCode.Clear();

        string strSql = @"
        IF EXISTS (
        SELECT 1 
          FROM vNew_BicBankBranch bb
         WHERE bb.new_BicBank = @RecipientBicBankID 
           AND bb.new_BicCode LIKE '%XXX' 
           AND DeletionStateCode = 0
        )
        BEGIN
	        SELECT TOP 1 new_BicBankBranchId, SUBSTRING(bb.new_BicCode,0,9) AS new_BicCode, bb.new_BicBankName, bb.new_BicBankCity, bb.new_BicBankCityName
	          FROM vNew_BicBankBranch bb
	         WHERE bb.new_BicBank = @RecipientBicBankID 
	           AND bb.new_BicCode LIKE '%XXX' 
	           AND DeletionStateCode = 0
        END
        ELSE
        BEGIN
	        SELECT TOP 1 new_BicBankBranchId, SUBSTRING(bb.new_BicCode,0,9) AS new_BicCode, bb.new_BicBankName, bb.new_BicBankCity, bb.new_BicBankCityName
	          FROM vNew_BicBankBranch bb
	         WHERE bb.new_BicBank = @RecipientBicBankID 
	           AND DeletionStateCode = 0
        END";

        StaticData sd = new StaticData();
        sd.AddParameter("RecipientBicBankID", DbType.Guid, ValidationHelper.GetGuid(new_SwfBicBank.Value));

        DataTable dt = sd.ReturnDataset(strSql).Tables[0];
        if (dt.Rows.Count > 0)
        {
            new_SwfBicBankCity.Value = dt.Rows[0]["new_BicBankCity"].ToString();
            new_SwfBicBankCity.SetValue(dt.Rows[0]["new_BicBankCity"].ToString());

            new_SwfBicCode.Value = dt.Rows[0]["new_BicCode"].ToString();
            new_SwfBicCode.SetValue(dt.Rows[0]["new_BicCode"].ToString());

            new_BicBankHidden.Value = dt.Rows[0]["new_BicBankName"].ToString();
            new_BicBankHidden.SetValue(dt.Rows[0]["new_BicBankName"].ToString());

            new_SwfRecipientBranch.Value = dt.Rows[0]["new_BicBankBranchId"].ToString();
            new_SwfRecipientBranch.SetValue(dt.Rows[0]["new_BicBankBranchId"].ToString());
        }
    }

    protected void SwfExpenseSenderOnChange(object sender, AjaxEventArgs e)
    {
        if (new_IsSwfExpenseSender.Checked)
        {
            new_SwfExpenseRecipient.Checked = false;
            new_SwfExpenseRecipient.SetValue(false);
            new_SwfExpenseRecipient.SetIValue(false);
        }
    }

    protected void SwfExpenseRecipientOnChange(object sender, AjaxEventArgs e)
    {
        if (new_SwfExpenseRecipient.Checked)
        {
            new_IsSwfExpenseSender.Checked = false;
            new_IsSwfExpenseSender.SetValue(false);
            new_IsSwfExpenseSender.SetIValue(false);
        }
    }

    //protected void VirementCancelRequestEvent(object sender, AjaxEventArgs e)
    //{
    //    btnVirementCancel.Visible = true;
    //    btnVirementCancel.SetVisible(true);


    //    //btnVirementCancelRequest.Visible = false;
    //    //btnVirementCancelRequest.SetVisible(false);


    //    //new_TransactionCancelRate.Visible = true;
    //    //new_TransactionCancelRate.SetVisible(true);
    //    //new_TransactionCancelRate.ReadOnly = false;
    //    //new_TransactionCancelRate.SetReadOnly(false);

    //    new_SenderAccountId.ReadOnly = true;
    //    new_RecipientAccountId.ReadOnly = true;
    //    new_Amount.ReadOnly = true;
    //    new_SenderAccountCurrencyId.ReadOnly = true;
    //    new_RecipientAccountCurrencyId.ReadOnly = true;
    //    new_TransactionRate.ReadOnly = true;
    //    new_TransferedAmount.ReadOnly = true;
    //    new_SenderAccountCurrencyIdName.ReadOnly = true;
    //    new_RecipientAccountCurrencyIdName.ReadOnly = true;

    //    new_SenderAccountId.SetReadOnly(true);
    //    new_RecipientAccountId.SetReadOnly(true);
    //    new_Amount.SetReadOnly(true);
    //    new_SenderAccountCurrencyId.SetReadOnly(true);
    //    new_RecipientAccountCurrencyId.SetReadOnly(true);
    //    new_TransactionRate.SetReadOnly(true);
    //    new_TransferedAmount.SetReadOnly(true);
    //    new_SenderAccountCurrencyIdName.SetReadOnly(true);
    //    new_RecipientAccountCurrencyIdName.SetReadOnly(true);


    //}

    protected void VirementCancelEvent(object sender, AjaxEventArgs e)
    {

        //if (new_TransactionCancelRate.IsEmpty)
        //{
        //    var msg = "Lütfen iptal kurunu giriniz.";
        //    var m = new MessageBox { Width = 400, Height = 180 };
        //    string requiredmsg = string.Format(msg, new_TransactionCancelRate.FieldLabel);
        //    m.Show(msg, requiredmsg);
        //    new_TransactionCancelRate.Focus();
        //    return;
        //}

        new_VirmanId.Value = QueryHelper.GetString("recid");

        try
        {
            DataTable dt = VirementFactory.Instance.GetVirementProperty(ValidationHelper.GetGuid(new_VirmanId.Value));
            //string createdOn = ValidationHelper.GetDate(dt.Rows[0]["CreatedOn"]).ToShortDateString();

            //if (createdOn.Equals(DateTime.Now.ToShortDateString()))
            //{
            //    VirementFactory.Instance.UpdateVirementCancellationStatus(Guid.Parse(new_VirmanId.Value));

            //    QScript("LogCurrentPage();");
            //    QScript("alert(" + BasePage.SerializeString("Talimatlı işlem iptal onayı statüsüne alınmıştır.") + "); ");
            //    QScript("RefreshParetnGridForCashTransaction(true);");
            //}
            //else
            //{
            //    QScript("LogCurrentPage();");
            //    QScript("alert(" + BasePage.SerializeString("Sadece aynı gün içerisinde yapılmış bir talimatlı işlemi iptal edebilirsiniz.") + "); ");
            //    QScript("RefreshParetnGridForCashTransaction(true);");
            //}
            VirementFactory.Instance.UpdateVirementCancellationStatus(Guid.Parse(new_VirmanId.Value));

            QScript("LogCurrentPage();");
            QScript("alert(" + BasePage.SerializeString("Talimatlı işlem iptal onayı statüsüne alınmıştır.") + "); ");
            QScript("RefreshParetnGridForCashTransaction(true);");
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    protected void VirementCancelConfirmEvent(object sender, AjaxEventArgs e)
    {
        new_VirmanId.Value = QueryHelper.GetString("recid");

        if (!string.IsNullOrEmpty(new_VirmanId.Value))
        {
            try
            {
                VirementFactory.Instance.VirementCancelConfirm(Guid.Parse(new_VirmanId.Value));

                QScript("LogCurrentPage();");
                QScript("alert(" + BasePage.SerializeString("İptal işlemi başarı ile gerçekleşti.") + "); ");
                QScript("RefreshParetnGridForCashTransaction(true);");
            }
            catch (Exception ex)
            {
                QScript("LogCurrentPage();");
                QScript("alert(" + BasePage.SerializeString("İptal işlemi sırasında hata oluştu: " + ex.Message) + "); ");
                QScript("RefreshParetnGridForCashTransaction(true);");
            }
        }
    }

    protected void VirementCancelUndoEvent(object sender, AjaxEventArgs e)
    {
        new_VirmanId.Value = QueryHelper.GetString("recid");

        try
        {
            VirementFactory.Instance.UpdateUndoVirementCancellationStatus(Guid.Parse(new_VirmanId.Value));

            QScript("LogCurrentPage();");
            QScript("alert(" + BasePage.SerializeString("Talimatlı İşlemin iptali başarılı bir şekilde geri alınmıştır.") + "); ");
            QScript("RefreshParetnGridForCashTransaction(true);");
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    protected void SenderAccountLoad(object sender, AjaxEventArgs e)
    {
        if (string.IsNullOrEmpty(new_VirementType.Value))
        {
            var msg = "Lütfen önce [ İşlem Tipi ] alanını seçiniz.";
            var m = new MessageBox { Width = 400, Height = 180 };
            string requiredmsg = string.Format(msg, new_TransactionRate.FieldLabel);
            m.Show(msg, requiredmsg);
            new_SenderAccountId.Clear();
            new_VirementType.Focus();
            return;
        }


        string strSql = @"spTuGetAccountByOperationType";

        var like = new_SenderAccountId.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("AccountLookupView");
        var gpc = new GridPanelCreater();

        var start = new_SenderAccountId.Start();
        var limit = new_SenderAccountId.Limit();

        StaticData sd = new StaticData();
        sd.AddParameter("VirementType", DbType.String, new_VirementType.SelectedItems == null ? new_VirementType.Value : new_VirementType.SelectedItems[0]["new_Code"]);
        sd.AddParameter("AccountType", DbType.String, "S");
        sd.AddParameter("Key", DbType.String, like);
        DataSet ds = sd.ReturnDatasetSp(strSql);
        if (ds.Tables.Count > 0)
        {
            new_SenderAccountId.TotalCount = ds.Tables[0].Rows.Count;
            new_SenderAccountId.DataSource = ds.Tables[0];
            new_SenderAccountId.DataBind();
        }
    }

    protected void CustAccountLoad(object sender, AjaxEventArgs e)
    {
        try
        {
            string strSql;

            Guid senderAccountId = ValidationHelper.GetGuid(new_SenderAccountId.Value);

            if (senderAccountId== Guid.Empty)
            {
                var msg = "Lütfen önce [ Gönderen Hesap ] alanını seçiniz.";
                var m = new MessageBox { Width = 400, Height = 180 };
                string requiredmsg = string.Format(msg, new_TransactionRate.FieldLabel);
                m.Show(msg, requiredmsg);
                new_SenderAccountId.Focus();
                return;
            }
            Account senderAccount = AccountTransactionFactory.Instance.GetAccountDetail(senderAccountId.ToString());


            strSql = @"Select 
                            New_CustAccountsId ID,
                            CONCAT(CustAccountNumber,' / ', new_SenderIdName) VALUE,
                            CustAccountNumber,
                            new_SenderIdName,
                            new_CustAccountCurrencyIdName, 
                            new_balance,
                            A.new_CustAccountTypeId,
                            A.new_CustAccountTypeIdName,
                            CAR.new_EXTCODE,
                            A.new_BlockedType
                    from vNew_CustAccounts A (NoLock)
                    LEFT OUTER JOIN vNew_CustAccountRestrictions CAR (NOLOCK) ON CAR.New_CustAccountRestrictionsId = A.new_CustAccountRestrictionId
                    Where A.DeletionStateCode = 0 
                            AND A.statuscode = 1 
                            AND ISNULL(CAR.new_EXTCODE,'') NOT IN ('001','003') /* işlem kısıtı yoksa */
                            AND ISNULL(A.new_BlockedType,'0') <> 1 /* TAM BLOKE DEGILSE */ ";

            if (corporateCustomerAccounts.Contains(senderAccount.AccountNumber))
            {
                strSql += @" AND new_CustAccountTypeIdName='Tüzel' ";
            }
            else
            {
                strSql += @" AND new_CustAccountTypeIdName='Gerçek' ";
            }


            strSql += " AND A.new_CustAccountCurrencyId = @CurrencyId ";

            string searchtext = this.Context.Items["query"] != null ? this.Context.Items["query"].ToString() : "";
            if (!string.IsNullOrEmpty(searchtext))
                strSql += " AND  CONCAT(CustAccountNumber,' / ', new_SenderIdName) LIKE '%" + searchtext + "%'";



            strSql += " ORDER BY new_SenderIdName asc ";

 
 

            StaticData sd = new StaticData();
            sd.ClearParameters();
            //sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId));
            sd.AddParameter("CurrencyId", DbType.Guid, ValidationHelper.GetGuid(senderAccount.CurrencyId));
            DataSet ds = sd.ReturnDataset(strSql);
            if (ds.Tables[0].Rows.Count > 0)
            {
                new_CustAccountsId.TotalCount = ds.Tables[0].Rows.Count;
                new_CustAccountsId.DataSource = ds.Tables[0];
                new_CustAccountsId.DataBind();
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "AccountTransactions_Virman.CustAccountLoad", "Exception");
        }
    }

    protected void AccountTransactionTypeLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"spTuGetAccountTransactionType";

        var like = new_AccountTransactionTypeId.Query();
        var gpc = new GridPanelCreater();

        var start = new_SenderAccountId.Start();
        var limit = new_SenderAccountId.Limit();

        StaticData sd = new StaticData();
        sd.AddParameter("Key", DbType.String, like);
        DataSet ds = sd.ReturnDatasetSp(strSql);
        if (ds.Tables.Count > 0)
        {
            new_AccountTransactionTypeId.TotalCount = ds.Tables[0].Rows.Count;
            new_AccountTransactionTypeId.DataSource = ds.Tables[0];
            new_AccountTransactionTypeId.DataBind();
        }
    }
    
    protected void EftCity2BranchReset(object sender, AjaxEventArgs e)
    {
        new_EftBranch.Clear();
    }

    protected void EftBank2CityBranchReset(object sender, AjaxEventArgs e)
    {
        new_EftBranch.Clear();
        new_EftCityId.Clear();
    }

    protected void RecipientAccountLoad(object sender, AjaxEventArgs e)
    {
        if (string.IsNullOrEmpty(new_VirementType.Value))
        {
            var msg = "Lütfen önce [ İşlem Tipi ] alanını seçiniz.";
            var m = new MessageBox { Width = 400, Height = 180 };
            string requiredmsg = string.Format(msg, new_TransactionRate.FieldLabel);
            m.Show(msg, requiredmsg);
            new_SenderAccountId.Clear();
            new_VirementType.Focus();
            return;
        }

        string strSql = @"spTuGetAccountByOperationType";

        const string sort = "";
        var like = new_RecipientAccountId.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("AccountLookupView");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_RecipientAccountId.Start();
        var limit = new_RecipientAccountId.Limit();

        StaticData sd = new StaticData();
        sd.AddParameter("VirementType", DbType.String, new_VirementType.SelectedItems[0]["new_Code"]);
        sd.AddParameter("AccountType", DbType.String, "R");
        sd.AddParameter("Key", DbType.String, like);
        if (!String.IsNullOrEmpty(new_SenderAccountId.Value))
        {
            sd.AddParameter("SenderAccountId", DbType.Guid, ValidationHelper.GetGuid(new_SenderAccountId.Value));
        }
        else
        {
            var m = new MessageBox { Width = 400, Height = 180 };
            m.Show("Uyarı", "Önce Gönderen Hesabı seçmelisiniz!");//CrmLabel.TranslateMessage("CRM.NEW_VIRMAN_VIRMAN_CANT_UPDATE"));
            return;
        }

        DataSet ds = sd.ReturnDatasetSp(strSql);

        if (ds.Tables.Count > 0)
        {
            new_RecipientAccountId.TotalCount = ds.Tables[0].Rows.Count;
            new_RecipientAccountId.DataSource = ds.Tables[0];
            new_RecipientAccountId.DataBind();
        }
    }

    protected void VirementTypeLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"SELECT 
                                Name AS VALUE,
                                New_VirementTypeId AS ID,
                                new_Code,
                                Name
                        FROM vNew_VirementType WHERE DeletionStateCode=0
                        AND new_IsConfirmBased = 1
                        ORDER BY new_Code";

        StaticData sd = new StaticData();
        DataSet ds = sd.ReturnDataset(strSql);
        if (ds.Tables.Count > 0)
        {
            new_VirementType.TotalCount = ds.Tables[0].Rows.Count;
            new_VirementType.DataSource = ds.Tables[0];
            new_VirementType.DataBind();
        }
    }

    protected void CorporationSwiftInfoLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"SELECT 
                            New_CorporationSwiftInfoId ID,
	                        RecipientSwiftAccountNo + '/' + new_CorporationIdName VALUE,
	                        New_CorporationSwiftInfoId,
	                        RecipientSwiftAccountNo,
	                        new_SwfBicCode,
	                        new_SwfBicCode CODE,
                            new_SwfBicBankName,
                            new_SwfBicBankCityName,
                            new_CorporationIdName,
                            new_SwfBicCode,
                            new_SwfRecipientAdres,
                            new_SwfRecipientName,
                            new_SwfBicCountryName
                         From vNew_CorporationSwiftInfo (NoLock)
                        WHERE DeletionStateCode=0
                        ORDER BY RecipientSwiftAccountNo asc";

        StaticData sd = new StaticData();
        DataSet ds = sd.ReturnDataset(strSql);
        if (ds.Tables.Count > 0)
        {
            new_CorporationSwiftInfo.TotalCount = ds.Tables[0].Rows.Count;
            new_CorporationSwiftInfo.DataSource = ds.Tables[0];
            new_CorporationSwiftInfo.DataBind();
        }
    }
    protected void CorporationSwiftInfoChangeOnEvent(object sender, AjaxEventArgs e)
    {
        //Guid corporationSwiftInfoId = new_CorporationSwiftInfo.SelectedItems[0]["new_Code"];
        Guid corporationSwiftInfoId = ValidationHelper.GetGuid( new_CorporationSwiftInfo.Value);

        if (corporationSwiftInfoId != Guid.Empty)
        {
            string strSql = @"SELECT 
                                    A.*,
                                    BNK.new_BicCode BicCode
                                 From vNew_CorporationSwiftInfo(NoLock) A
                                INNER JOIN vNew_BicBank BNK (NoLock) ON BNK.New_BicBankId = A.new_SwfBicBank
                                WHERE A.DeletionStateCode=0
                                        and A.New_CorporationSwiftInfoId = @RecId
                                ORDER BY RecipientSwiftAccountNo asc";
            
            
            StaticData sd = new StaticData();
            sd.AddParameter("RecId", DbType.Guid, ValidationHelper.GetGuid(corporationSwiftInfoId));
            DataTable dt = sd.ReturnDataset(strSql).Tables[0];
            
           new_RecipientSwiftAccountNo.SetValue(dt.Rows[0]["RecipientSwiftAccountNo"].ToString());
            new_SwfRecipientName.SetValue(dt.Rows[0]["new_SwfRecipientName"].ToString());
            new_SwfRecipientAdres.SetValue(dt.Rows[0]["new_SwfRecipientAdres"].ToString());
            new_SwfBicCountry.SetValue(dt.Rows[0]["new_SwfBicCountry"].ToString());
            new_SwfBicBank.SetValue(dt.Rows[0]["new_SwfBicBank"].ToString());
            new_SwfBicBank.SetValue(dt.Rows[0]["new_SwfBicBank"].ToString());
            new_SwfBicBankCity.SetValue(dt.Rows[0]["new_SwfBicBankCity"].ToString());
            new_SwfBicCode.SetValue(dt.Rows[0]["BicCode"].ToString());
        }
    }

    protected void btnSaveOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            Guid systemUserId = ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId);
            Guid senderAccountId = ValidationHelper.GetGuid(new_SenderAccountId.Value);
            Account senderAccount = AccountTransactionFactory.Instance.GetAccountDetail(senderAccountId.ToString());

            string senderAccountNumber = senderAccount.AccountNumber;

            Guard(senderAccount);

            VirementBase item = BuildVirement();

            if (item.VirementType.Equals("005"))
            {
                item.SwiftDetails = BuildSwift();
            }

            if (item.VirementType.Equals("006"))
            {
                item.EftDetails = BuildEft();
            }

            VirementResult result = VirementFactory.Instance.SaveVirement(item);
            if (result.Success)
            {
                ClearAll();

                string reportId = VirementFactory.Instance.GetAuthorizationFormId(item);

                if (result.VirmanId != Guid.Empty)
                {
                    if (String.IsNullOrEmpty(senderAccountNumber))
                    {
                        senderAccount = AccountTransactionFactory.Instance.GetAccountDetail(senderAccountId.ToString());
                        senderAccountNumber = senderAccount.AccountNumber;
                    }


                    if (!String.IsNullOrEmpty(senderAccountNumber))
                    {
                        if (individualCustomerAccounts.Contains(senderAccountNumber) || corporateCustomerAccounts.Contains(senderAccountNumber))
                        {
                            StaticData sd = new StaticData();
                            var tr = sd.GetDbTransaction();
                            try
                            {
                                var custAccountDepositDt = VirementFactory.Instance.SaveCreateCustAccountOperation(result.VirmanId, tr);

                                Guid custAccountOperationId = ValidationHelper.GetGuid(custAccountDepositDt.Rows[0]["CustAccountOperationId"]);

                                if (custAccountOperationId != Guid.Empty)
                                    VirementFactory.Instance.CreateCustAccountTransactions(custAccountOperationId, tr);
                                

                                tr.Commit();
                            }
                            catch (Exception ex2)
                            {
                                tr.Rollback();
                                LogUtil.WriteException(ex2, "AccountTransactions_Virman.btnSaveOnEvent");
                            }

                        }
                    }
                }

                QScript("LogCurrentPage();");
                QScript("alert(" + BasePage.SerializeString("İşlem başarı ile gerçekleşti.") + "); ");

                QScript(string.Format("hdnReportId.setValue('{0}');", reportId));
                QScript(string.Format("hdnRecid.setValue('{0}');", ValidationHelper.GetString(item.VirmanId)));
                QScript("ShowClientSideWindow();");
                QScript("RefreshParetnGridForCashTransaction(true);");

                //if (item.VirementType.Equals("005"))
                //{
                //    TuFactory.Utility.ReportParamWriter.writeReportRecipientParameter(item.ReferenceNo, item.SwiftDetails.RecipientName);
                //}
                //if (item.VirementType.Equals("006"))
                //{
                //    TuFactory.Utility.ReportParamWriter.writeReportRecipientParameter(item.ReferenceNo, item.EftDetails.RecipientName);
                //}
            }
            else
            {
                var m = new MessageBox { Width = 400, Height = 180 };
                m.Show(CrmLabel.TranslateMessage("CRM.NEW_VIRMAN_TRANSACTION_HAS_ERROR"), result.ErrorMessage);
                return;
            }

        }
        catch (Exception ex)
        {
            var m = new MessageBox { Width = 400, Height = 180 };
            m.Show(CrmLabel.TranslateMessage("CRM.NEW_VIRMAN_TRANSACTION_HAS_ERROR"), ex.Message);
            return;
        }
    }

    private void ClearAll()
    {
        new_AccountTransactionTypeId.Clear();
        new_SenderAccountId.Clear();
        new_RecipientAccountId.Clear();
        new_Amount.Clear();
        new_SenderAccountCurrencyId.Clear();
        new_RecipientAccountCurrencyId.Clear();
        new_TransactionRate.Clear();
        new_TransferedAmount.Clear();
        new_SenderAccountCurrencyIdName.Clear();
        new_RecipientAccountCurrencyIdName.Clear();
        new_Explanation.Clear();
    }

    private void Guard(Account senderAccount)
    {
        var virementTypeCode = string.Empty;
        if (new_VirementType.SelectedItems != null)
        {
            if (ValidationHelper.GetGuid(new_VirementType.Value) == Guid.Empty)
            {
                throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_VirementType.FieldLabel));
            }

            virementTypeCode = new_VirementType.SelectedItems[0]["new_Code"];
        }
        else
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_VirementType.FieldLabel));
        }

        if (!string.IsNullOrEmpty(new_VirmanId.Value))
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM.NEW_VIRMAN_VIRMAN_CANT_UPDATE"), new_VirmanId.FieldLabel));
        }

        if (ValidationHelper.GetGuid(new_SenderAccountId.Value, Guid.Empty) == Guid.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_SenderAccountId.FieldLabel));
        }

        if (virementTypeCode != "005" && virementTypeCode != "006" && virementTypeCode != "007")
        {
            if (ValidationHelper.GetGuid(new_RecipientAccountId.Value, Guid.Empty) == Guid.Empty)
            {
                throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_RecipientAccountId.FieldLabel));
            }
        }
        else
        {
            if (ValidationHelper.GetString(new_RecipientSwiftAccountNo.Value, string.Empty) == string.Empty)
            {
                throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_RecipientSwiftAccountNo.FieldLabel));
            }
        }

        if (ValidationHelper.GetDecimal(new_Amount.Value, 0) == 0)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_Amount.FieldLabel));

        }
        if (ValidationHelper.GetDecimal(new_TransactionRate.Value, 0) == 0)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_TransactionRate.FieldLabel));
        }


        /*
         Alt Hesap kontrolleri
         */
        #region alt hesap kontrolleri

        Guid custAccountId = ValidationHelper.GetGuid(new_CustAccountsId.Value);
        Guid senderAccountId = ValidationHelper.GetGuid(new_SenderAccountId.Value);
        string senderAccountNumber = senderAccount.AccountNumber;

        if (String.IsNullOrEmpty(senderAccountNumber))
        {
            senderAccount = AccountTransactionFactory.Instance.GetAccountDetail(senderAccountId.ToString());
            senderAccountNumber = senderAccount.AccountNumber;
        }

        //bireysel ve tüzel müşteri hesaplarında, alt hesap zorunludur
        if (!String.IsNullOrEmpty(senderAccountNumber))
        {
            if (individualCustomerAccounts.Contains(senderAccountNumber) || corporateCustomerAccounts.Contains(senderAccountNumber))
            {
                if (custAccountId == Guid.Empty)
                {
                    throw new Exception(CrmLabel.TranslateMessage("CRM.ENTITY_CUST_ACCOUNT_CURRENCY_VIRMAN_REQUIRED_FIELD_ERROR"));
                }
            }
        }
        
        //alt hesap seçili değilse kontrolleri yapma
        if (custAccountId == Guid.Empty)
            return;

        CustAccountDb accountDb = new CustAccountDb();
        DataTable dt = accountDb.GetCustAccount(custAccountId);

        bool isBlocked =  ValidationHelper.GetBoolean(dt.Rows[0]["new_IsBlocked"], false);
        int blockedType = ValidationHelper.GetInteger(dt.Rows[0]["BlockedType"], 0);
        Guid currencyId = ValidationHelper.GetGuid(dt.Rows[0]["CurrencyId"]);
        decimal balance = ValidationHelper.GetDecimal(dt.Rows[0]["new_Balance"],0);
        decimal blockedAmount = ValidationHelper.GetDecimal(dt.Rows[0]["new_BlockedAmount"], 0);
        decimal avaibleBalance = balance - blockedAmount;
        string restrictionsCode = ValidationHelper.GetString(dt.Rows[0]["RestrictionsCode"]);

        decimal amount = ValidationHelper.GetDecimal(new_Amount.Value, 0);

        //hesap bloke mi
        if (isBlocked)
        {
            if (blockedType == 1)
            {
                throw new Exception(CrmLabel.TranslateMessage("CRM.ENTITY_CUST_ACCOUNT_ISBLOCKED_ERROR"));
            }
            else
            {

                //bakiye kontrolü
                //işlem sonucu alt hesap bakiyesi 0 ın altına düşerse
                if ((avaibleBalance - amount) < 0)
                {
                    throw new Exception(CrmLabel.TranslateMessage("CRM.ENTITY_CUST_ACCOUNT_BALANCE_ERROR"));
                }
                
            }
        }
        else
        {
            //bakiye kontrolü
            //işlem sonucu alt hesap bakiyesi 0 ın altına düşerse
            if ((avaibleBalance - amount) < 0)
            {
                throw new Exception(CrmLabel.TranslateMessage("CRM.ENTITY_CUST_ACCOUNT_BALANCE_ERROR"));
            }
        }

        //gönderici hesap ile gönderici alt hesap, para birimleri eşit değil
        if (currencyId != senderAccount.CurrencyId)
        {
            throw new Exception(CrmLabel.TranslateMessage("CRM.ENTITY_CUST_ACCOUNT_CURRENCY_ARE_INCOMPATIBLE_ERROR"));
        }



        //hesap kısıt kontrolü
        if (restrictionsCode == "001" || restrictionsCode == "003")
        {
            throw new Exception(CrmLabel.TranslateMessage("CRM.ENTITY_CUST_ACCOUNT_RESTRICTIONS_ERROR"));
        }

        #endregion
    }

    private void GuardEft()
    {
        if (ValidationHelper.GetString(new_EftRecipientName.Value, string.Empty) == string.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_EftRecipientName.FieldLabel));
        }

        if (ValidationHelper.GetGuid(new_EftBank.Value, Guid.Empty) == Guid.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_EftBank.FieldLabel));
        }

        if (ValidationHelper.GetString(new_EftPaymentType.Value, string.Empty) == string.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_EftPaymentType.FieldLabel));
        }

        if (ValidationHelper.GetGuid(new_EftCityId.Value, Guid.Empty) == Guid.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_EftCityId.FieldLabel));
        }

        if (ValidationHelper.GetString(new_EftBranch.Value, string.Empty) == string.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_EftBranch.FieldLabel));
        }
    }

    private void GuardSwift()
    {
        if (ValidationHelper.GetString(new_SwfSenderName.Value, string.Empty) == string.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_SwfSenderName.FieldLabel));
        }

        if (ValidationHelper.GetString(new_SwfSenderAdres.Value, string.Empty) == string.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_SwfSenderAdres.FieldLabel));
        }

        //if (ValidationHelper.GetString(new_SwfSenderTelephone.Value, string.Empty) == string.Empty)
        //{
        //    throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_SwfSenderTelephone.FieldLabel));
        //}

        if (ValidationHelper.GetString(new_SwfAmountText.Value, string.Empty) == string.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_SwfAmountText.FieldLabel));
        }

        if (ValidationHelper.GetString(new_SwfRecipientName.Value, string.Empty) == string.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_SwfRecipientName.FieldLabel));
        }

        if (ValidationHelper.GetGuid(new_SwfBicCountry.Value, Guid.Empty) == Guid.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_SwfBicCountry.FieldLabel));
        }

        if (ValidationHelper.GetGuid(new_SwfBicBank.Value, Guid.Empty) == Guid.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_SwfBicBank.FieldLabel));
        }

        if (ValidationHelper.GetGuid(new_SwfBicBankCity.Value, Guid.Empty) == Guid.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_SwfBicBankCity.FieldLabel));
        }

        if (ValidationHelper.GetString(new_SwfBicCode.Value, string.Empty) == string.Empty)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_SwfBicCode.FieldLabel));
        }

        if (ValidationHelper.GetBoolean(new_IsSwfExpenseSender.Value, false) == false && ValidationHelper.GetBoolean(new_SwfExpenseRecipient.Value, false) == false)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_IsSwfExpenseSender.FieldLabel, new_SwfExpenseRecipient.FieldLabel));
        }

        if (ValidationHelper.GetBoolean(new_IsSwfGorunmeyenKalemTransfer.Value, false) == false)
        {
            throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_IsSwfGorunmeyenKalemTransfer.FieldLabel));
        }
    }

    private VirementBase BuildVirement()
    {
        try
        {
            VirementBase item = VirementFactory.Instance.CreateVirement(new_VirementType.SelectedItems[0]["new_Code"], VirementSources.Operation);
            item.VirementTypeId = ValidationHelper.GetGuid(new_VirementType.Value);
            item.AccountTransactionTypeId= ValidationHelper.GetGuid(new_AccountTransactionTypeId.Value);
            item.SenderAccountDescription = string.Empty; //new_SenderAccountDescription.Value;
            item.RecipientAccountDescription = string.Empty; //new_RecipientAccountDescription.Value;
            item.TransactionDescription = string.Empty; //new_TransactionDescription.Value;
            item.SenderAccountId = ValidationHelper.GetGuid(new_SenderAccountId.Value);
            item.SenderAccountCurrencyId = ValidationHelper.GetGuid(new_SenderAccountCurrencyId.Value);
            item.RecipientAccountId = ValidationHelper.GetGuid(new_RecipientAccountId.Value);
            item.RecipientAccountCurrencyId = ValidationHelper.GetGuid(new_RecipientAccountCurrencyId.Value);
            item.TransactionRate = ValidationHelper.GetDecimal(new_TransactionRate.Value, 0);
            item.Amount = item.VirementType == "002" ? ValidationHelper.GetDecimal(new_TransferedAmount.Value, 0) : ValidationHelper.GetDecimal(new_Amount.Value, 0);
            item.TransferedAmount = item.VirementType == "002" ? ValidationHelper.GetDecimal(new_Amount.Value, 0) : ValidationHelper.GetDecimal(new_TransferedAmount.Value, 0);
            item.RecipientSwiftAccountNo = new_RecipientSwiftAccountNo.Value;
            item.Source = VirementSources.Operation;
            item.Status = VirementStatus.AccountTransactionNotCreated;
            item.StatusDescription = "Talimat tanımı yapıldı, aktarım bekleniyor."; // VirementStatus.AccountTransactionNotCreated.ToString();
            item.Explanation = new_Explanation.Value;
            item.CustAccountId = ValidationHelper.GetGuid(new_CustAccountsId.Value);
            return item;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    private Eft BuildEft()
    {
        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        try
        {
            GuardEft();

            TuFactory.Object.Virements.Eft VirmanEft = new Eft();
            VirmanEft.SenderName = ValidationHelper.GetString(GetParameterByName("EFT_SENDER_NAME"));
            VirmanEft.SenderAccountNo = ValidationHelper.GetGuid(new_SenderAccountId.Value);
            VirmanEft.SenderTCKN = ValidationHelper.GetString(GetParameterByName("EFT_SENDER_VKN"));
            //VirmanEft.SenderTel = ValidationHelper.GetString(GetParameterByName("EFT_SENDER_TEL"));
            VirmanEft.RecipientName = ValidationHelper.GetString(new_EftRecipientName.Value);
            VirmanEft.RecipientBank = ValidationHelper.GetGuid(new_EftBank.Value);
            VirmanEft.RecipientAcountNoIbanCC = ValidationHelper.GetString(new_RecipientSwiftAccountNo.Value);
            //VirmanEft.RecipientFatherName = ValidationHelper.GetString(new_EftRecipientFatherName.Value);
            //VirmanEft.RecipientBirthDate = ValidationHelper.GetDate(new_EftRecipientBirth.Value, CultureInfo.InvariantCulture);
            VirmanEft.PaymentType = ValidationHelper.GetGuid(new_EftPaymentType.Value);
            VirmanEft.Amount = ValidationHelper.GetDecimal(new_Amount.Value, 0);
            VirmanEft.AmountText = ValidationHelper.GetString(new_EftAmountText.Value);
            VirmanEft.RecipientAdres = ValidationHelper.GetString(new_EftRecipientAdres.Value);
            //VirmanEft.RecipientTel = ValidationHelper.GetString(new_EftRecipientTelephone.Value);
            VirmanEft.BankCity = ValidationHelper.GetGuid(new_EftCityId.Value);
            VirmanEft.BankBranch = ValidationHelper.GetGuid(new_EftBranch.Value);

            //SENDER50KARAKTER
            //if (VirmanEft.SenderName.Length > 50)
            //{
            //    Exception ex = new Exception(CrmEngine.Params.CurrentParameters.ContainsKey("SENDERNAMETOOLONG") ? ValidationHelper.GetString(CrmEngine.Params.CurrentParameters["SENDERNAMETOOLONG"].TextValue) : "Gönderici 50 karakterden fazla olamaz!");
            //    throw ex;
            //}

            return VirmanEft;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    private Swift BuildSwift()
    {
        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        try
        {
            GuardSwift();

            TuFactory.Object.Virements.Swift VirmanSwift = new Swift();
            VirmanSwift.BicCountry = ValidationHelper.GetGuid(new_SwfBicCountry.Value);
            VirmanSwift.BankCity = ValidationHelper.GetGuid(new_SwfBicBankCity.Value);
            VirmanSwift.RecipientBank = ValidationHelper.GetGuid(new_SwfBicBank.Value);
            VirmanSwift.BicCode = ValidationHelper.GetString(new_SwfBicCode.Value);
            VirmanSwift.Amount = ValidationHelper.GetDecimal(new_Amount.Value, 0);
            VirmanSwift.AmountText = ValidationHelper.GetString(new_SwfAmountText.Value);
            VirmanSwift.Attachments = ValidationHelper.GetString(new_SwfAttachments.Value);
            VirmanSwift.SenderAccountNo = ValidationHelper.GetGuid(new_SenderAccountId.Value);
            VirmanSwift.RecipientAcountNo = ValidationHelper.GetString(new_RecipientSwiftAccountNo.Value);
            VirmanSwift.RecipientAdres = ValidationHelper.GetString(new_SwfRecipientAdres.Value);
            VirmanSwift.RecipientName = ValidationHelper.GetString(new_SwfRecipientName.Value);
            VirmanSwift.IsExpenseSender = ValidationHelper.GetBoolean(new_IsSwfExpenseSender.Value);
            VirmanSwift.IsExpenseRecipient = ValidationHelper.GetBoolean(new_SwfExpenseRecipient.Value);
            VirmanSwift.IsGorunmeyenKalemTransfer = ValidationHelper.GetBoolean(new_IsSwfGorunmeyenKalemTransfer.Value);
            VirmanSwift.IsCashImport = ValidationHelper.GetBoolean(new_IsSwfCashImport.Value);
            VirmanSwift.Referance = ValidationHelper.GetString(new_SwfReference.Value);
            VirmanSwift.InvoiceDate = ValidationHelper.GetDate(new_SwfInvoiceDate.Value);
            VirmanSwift.InvoiceNo = ValidationHelper.GetString(new_SwfInvoiceNo.Value);
            VirmanSwift.BankBranch = ValidationHelper.GetGuid(new_SwfRecipientBranch.Value);

            return VirmanSwift;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    private void GetTransactionTypeProperty(Guid TransactionTypeId)
    {
        StaticData sd = new StaticData();
        string sql = @"Select TransactionType,new_Code,new_Reference_Prefix From vNew_AccountTransactionTypes 
Where New_AccountTransactionTypesId=@AccountTransactionTypesId and DeletionStateCode=0";
        sd.AddParameter("AccountTransactionTypesId", DbType.Guid, TransactionTypeId);
        DataSet ds = sd.ReturnDataset(sql);
        if (ds.Tables.Count > 0 & ds.Tables[0].Rows.Count > 0)
        {
            TransactionTypeCode.Value = ds.Tables[0].Rows[0]["new_Code"].ToString();
            TransactionTypePrefixCode.Value = ds.Tables[0].Rows[0]["new_Reference_Prefix"].ToString();
            TransactionTypeIdName.Value = ds.Tables[0].Rows[0]["TransactionType"].ToString();
        }
    }

    private void GetAccountCurrencyIdName(string VirementTypeCode, string SenderAccountId, string RecipientAccountId)
    {
        try
        {
            AccountTransactionDb accountDb = new AccountTransactionDb();
            Account senderAcc = accountDb.GetAccountDetail(SenderAccountId);
            Account recipientAcc = accountDb.GetAccountDetail(RecipientAccountId);

            if (VirementTypeCode.Equals("002"))
            {
                new_SenderAccountCurrencyIdName.SetValue(recipientAcc.CurrencyCode);
                new_RecipientAccountCurrencyIdName.SetIValue(senderAcc.CurrencyCode);
            }
            else
            {
                if (VirementTypeCode.Equals("001"))
                {
                    new_SenderAccountCurrencyIdName.SetValue(senderAcc.CurrencyCode);
                    new_RecipientAccountCurrencyIdName.Visible = false;
                }
                else
                {
                    new_SenderAccountCurrencyIdName.SetValue(senderAcc.CurrencyCode);
                    new_RecipientAccountCurrencyIdName.SetIValue(recipientAcc.CurrencyCode);
                }
            }
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    private string GetParameterByName(string ParameterName)
    {
        StaticData sd = new StaticData();

        string sql = "EXEC [spGetParameterByName] @PARAMETERNAME";

        sd.AddParameter("@PARAMETERNAME", DbType.String, ParameterName);

        DataTable dtParam = sd.ReturnDataset(sql).Tables[0];



        return dtParam.Rows[0]["textValue"].ToString();
    }

    private void VirementLoad(string recId)
    {
        try
        {
            if (!string.IsNullOrEmpty(recId))
            {
                
                btnSave.Visible = false;

                var df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };
                var tr = df.Retrieve(TuEntityEnum.New_Virman.GetHashCode(), ValidationHelper.GetGuid(new_VirmanId.Value), DynamicFactory.RetrieveAllColumns);

                new_VirementType.ReadOnly = true;
                new_VirementType.FillDynamicEntityData(tr);

                new_SenderAccountId.ReadOnly = true;
                new_SenderAccountId.FillDynamicEntityData(tr);
                new_SenderAccountCurrencyIdName.FillDynamicEntityData(tr);
                new_RecipientAccountId.ReadOnly = true;
                new_RecipientAccountId.FillDynamicEntityData(tr);
                new_Explanation.FillDynamicEntityData(tr);

                //CustAccountLoad(null, null);
                new_CustAccountsId.ReadOnly = true;
                new_CustAccountsId.FillDynamicEntityData(tr);
                //New_CustAccountsId.SetValue(tr["new_CustAccountsId"].ToString());

                VirementType type = new VirementDb().GetVirementType(ValidationHelper.GetGuid(new_VirementType.Value));
                if (type != null)
                {
                    if (new_SenderAccountId.Value != null)
                    {
                        GetAccountCurrencyIdName(type.Code, new_SenderAccountId.Value, new_RecipientAccountId.Value);
                    }

                    if (type.Code.Equals("002"))
                    {
                        new_Amount.ReadOnly = true;
                        new_Amount.SetValue(tr.GetDecimalValue("new_TransferedAmount"));

                        new_TransferedAmount.ReadOnly = true;
                        new_TransferedAmount.SetValue(tr.GetDecimalValue("new_Amount"));
                    }
                    else
                    {
                        new_Amount.ReadOnly = true;
                        new_Amount.SetValue(tr.GetDecimalValue("new_Amount"));

                        if (type.Code.Equals("001"))
                        {
                            new_TransferedAmount.Visible = false;
                            new_TransactionRate.Visible = false;
                           
                        }
                        else
                        {
                            new_TransferedAmount.ReadOnly = true;
                            new_TransferedAmount.SetValue(tr.GetDecimalValue("new_TransferedAmount"));
                        }
                    }
                }

                new_TransactionRate.ReadOnly = true;
                new_TransactionRate.FillDynamicEntityData(tr);

                //new_TransactionCancelRate.ReadOnly = true;
                //new_TransactionCancelRate.FillDynamicEntityData(tr);

                new_RecipientSwiftAccountNo.ReadOnly = true;
                new_RecipientSwiftAccountNo.FillDynamicEntityData(tr);

                new_EftBranch.ReadOnly = true;
                new_EftBranch.FillDynamicEntityData(tr);

                VirementDetailLoad(recId, type.Code);
            }
            else
            {
                btnSave.Visible = true;
            }
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    private void VirementDetailLoad(string recId, string typeCode)
    {
        var df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };
        //var vi = new AccountTransactionDb().GetVirementDetailId(new_VirmanId.Value);

        var vi = VirementFactory.Instance.GetVirementDetailId(new_VirmanId.Value);

        var tr = df.Retrieve(TuEntityEnum.New_VirmanDetail.GetHashCode(), ValidationHelper.GetGuid(vi), DynamicFactory.RetrieveAllColumns);
        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();

        if (typeCode.Equals("006"))
        {
            PanelEftDetail.SetVisible(true);
            new_TransferedAmount.SetVisible(false);
            new_RecipientAccountCurrencyIdName.SetVisible(false);

            new_EftSenderName.ReadOnly = true;
            new_EftSenderName.FillDynamicEntityData(tr);

            new_EftSenderTCKN.ReadOnly = true;
            new_EftSenderTCKN.FillDynamicEntityData(tr);

            //new_EftSenderTelephone.ReadOnly = true;
            //new_EftSenderTelephone.FillDynamicEntityData(tr);

            new_EftRecipientName.ReadOnly = true;
            new_EftRecipientName.FillDynamicEntityData(tr);
            new_EftRecipientName.SetValue(cryptor.DecryptInString(new_EftRecipientName.Value));

            new_EftBank.ReadOnly = true;
            new_EftBank.FillDynamicEntityData(tr);

            new_EftCityId.ReadOnly = true;
            new_EftCityId.FillDynamicEntityData(tr);

            new_EftBranch.ReadOnly = true;
            new_EftBranch.FillDynamicEntityData(tr);

            //new_EftRecipientFatherName.ReadOnly = true;
            //new_EftRecipientFatherName.FillDynamicEntityData(tr);

            //new_EftRecipientBirth.ReadOnly = true;
            //new_EftRecipientBirth.FillDynamicEntityData(tr);

            new_EftRecipientAdres.ReadOnly = true;
            new_EftRecipientAdres.FillDynamicEntityData(tr);

            //new_EftRecipientTelephone.ReadOnly = true;
            //new_EftRecipientTelephone.FillDynamicEntityData(tr);

            new_EftPaymentType.ReadOnly = true;
            new_EftPaymentType.FillDynamicEntityData(tr);

            new_EftAmountText.ReadOnly = true;
            new_EftAmountText.FillDynamicEntityData(tr);
        }

        if (typeCode.Equals("005"))
        {
            PanelSwiftDetail.SetVisible(true);
            new_TransferedAmount.SetVisible(false);
            new_RecipientAccountCurrencyIdName.SetVisible(false);
            new_RecipientAccountId.SetVisible(false);

            new_RecipientSwiftAccountNo.ReadOnly = true;
            new_RecipientSwiftAccountNo.SetVisible(true);
            new_RecipientSwiftAccountNo.FillDynamicEntityData(tr);

            new_CorporationSwiftInfo.ReadOnly = true;
            new_CorporationSwiftInfo.SetVisible(true);


            new_SwfAmountText.ReadOnly = true;
            new_SwfAmountText.FillDynamicEntityData(tr);

            new_SwfRecipientName.ReadOnly = true;
            new_SwfRecipientName.FillDynamicEntityData(tr);
            new_SwfRecipientName.SetValue(cryptor.DecryptInString(new_SwfRecipientName.Value));

            new_SwfRecipientAdres.ReadOnly = true;
            new_SwfRecipientAdres.FillDynamicEntityData(tr);

            new_EftRecipientName.ReadOnly = true;
            new_EftRecipientName.FillDynamicEntityData(tr);

            new_SwfBicCountry.ReadOnly = true;
            new_SwfBicCountry.FillDynamicEntityData(tr);

            new_SwfBicBankCity.ReadOnly = true;
            new_SwfBicBankCity.FillDynamicEntityData(tr);

            new_SwfBicBank.ReadOnly = true;
            new_SwfBicBank.FillDynamicEntityData(tr);

            new_SwfBicCode.ReadOnly = true;
            new_SwfBicCode.FillDynamicEntityData(tr);

            new_IsSwfExpenseSender.ReadOnly = true;
            new_IsSwfExpenseSender.FillDynamicEntityData(tr);

            new_SwfExpenseRecipient.ReadOnly = true;
            new_SwfExpenseRecipient.FillDynamicEntityData(tr);

            new_IsSwfGorunmeyenKalemTransfer.ReadOnly = true;
            new_IsSwfGorunmeyenKalemTransfer.FillDynamicEntityData(tr);

            new_IsSwfCashImport.ReadOnly = true;
            new_IsSwfCashImport.FillDynamicEntityData(tr);

            new_SwfReference.ReadOnly = true;
            new_SwfReference.FillDynamicEntityData(tr);

            new_SwfInvoiceDate.ReadOnly = true;
            new_SwfInvoiceDate.FillDynamicEntityData(tr);

            new_SwfInvoiceNo.ReadOnly = true;
            new_SwfInvoiceNo.FillDynamicEntityData(tr);

            new_SwfAttachments.ReadOnly = true;
            new_SwfAttachments.FillDynamicEntityData(tr);
        }
    }
}