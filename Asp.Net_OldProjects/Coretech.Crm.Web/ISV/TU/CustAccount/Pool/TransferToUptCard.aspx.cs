using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using Domain.Entities;
using RefleXFrameWork;
using Services;
using Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Linq;
using System.Web.UI;
using TuFactory.CustAccount.Business;
using TuFactory.CustAccount.Business.Service;
using TuFactory.CustAccount.Object;
using TuFactory.Domain.Enums;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.Profession;
using TuFactory.TuUser;
using TuFactory.UptCard.Business;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;
using Object = TuFactory.CustAccount.Object;

public partial class CustAccount_Pool_TransferToUptCard : BasePage
{
    #region Variables
    private TuUser _activeUser = null;
    private bool _IsPartlyCollection = false; //Bu kurumda parcalı tahsilat kullanılır.
    private decimal UserCostReductionRate;
    private string _CountryCurrencyID;
    private string _CountryCurrencyIDName;
    private TuUserApproval _userApproval = null;
    private DynamicSecurity DynamicSecurity;
    bool isNewAmount;
    private bool isTuzel;
    private const string aboutblank = "about:blank";
    private CardClientService _cardClientService;
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        //this.new_CalculatedExpenseAmount.c1.Enabled = false;
        DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_CustAccountType.GetHashCode(), null);
        if (!(DynamicSecurity.PrvCreate || DynamicSecurity.PrvRead || DynamicSecurity.PrvWrite))
            Response.End();

        var sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        var dt =
            sd.ReturnDataset(
                @"
                    SELECT 
                    u.new_CorporationID,c.new_CountryID,u.new_OfficeID , co.new_CurrencyID,new_CurrencyIDName,c.new_IsPartlyCollection,
                    o.new_CountryID OfficeCountryId,cao.New_CustAccountOperationTypeId as CustAccountOperationTypeId
                    FROM vSystemUser(nolock) u
                    INNER JOIN vNew_Corporation c on u.new_CorporationID = c.New_CorporationId
                    INNER JOIN vNew_Office o on o.New_OfficeId=u.new_OfficeID
                    LEFT OUTER JOIN vnew_country co ON co.New_CountryId=c.new_CountryID 
                    LEFT OUTER JOIN vnew_custaccountOperationType cao on cao.new_EXTCODE='008' and cao.DeletionStateCode=0
                    Where SystemUserId = @SystemUserId
                    ")
                .Tables[0];

        if (dt.Rows.Count > 0)
        {

            _CountryCurrencyID = ValidationHelper.GetString(dt.Rows[0]["new_CurrencyID"]);
            _CountryCurrencyIDName = ValidationHelper.GetString(dt.Rows[0]["new_CurrencyIDName"]);
            _IsPartlyCollection = false; //Direk TL olarak çıkması lazım.
            new_CorporationId.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_CorporationID"]));
            new_CustAccountOperationTypeId.Value = ValidationHelper.GetString(dt.Rows[0]["CustAccountOperationTypeId"]);//Hesaptan UPT Karta Para Yatırma
            new_CorporationCountryId.Value = ValidationHelper.GetString(dt.Rows[0]["new_CountryID"]);
        }

        if (!RefleX.IsAjxPostback)
        {
            RR.RegisterIcon(Icon.Add);
            TranslateMessage();
            PrepareItems();
            SetDefaults();
            ReConfigureScreen();
            QScript("pageLoad();");
        }
        new_CalculatedExpenseAmount.Items[1].SetDisabled(true);
        setUserCostReductionRate();
    }

    protected void setUserCostReductionRate()
    {
        if (new_UserCostReductionRate.Value == null)
        {
            var sd = new StaticData();
            sd.AddParameter("@systemuserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
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

            new_CalculatedExpenseAmount.Items[0].SetDisabled(false);
        }
    }

    void ReConfigureScreen()
    {
        var sd = new StaticData();
        sd.ClearParameters();

        new_UPTCardTransferAmount.c1.Disabled = true;
        new_UPTCardTransferAmount.c1.Disabled = true;
        new_CustAccountTypeId.Disabled = true;
        new_PaidAmount1.c1.Disabled = true;
        new_PaidAmount1.d1.Disabled = true;
    }

    private void SetDefaults()
    {
        mfsender.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_SenderId",
         TuEntityEnum.New_CustAccountOperations.GetHashCode());
        lblnew_CustAccountTypeId2.FieldLabel =
        lblnew_CustAccountTypeId3.FieldLabel =
        CrmLabel.TranslateAttributeLabelMessage("new_CustAccountTypeId", TuEntityEnum.New_CustAccountOperations.GetHashCode());
        mlCustAccount2.FieldLabel =
        mlCustAccount3.FieldLabel =
        CrmLabel.TranslateAttributeLabelMessage("new_CustAccountId", TuEntityEnum.New_CustAccountOperations.GetHashCode());

        lblnew_SenderId2.FieldLabel =
        lblnew_SenderId3.FieldLabel =
        CrmLabel.TranslateAttributeLabelMessage("new_SenderId", TuEntityEnum.New_CustAccountOperations.GetHashCode());

        lblnew_PaymentAmount2.FieldLabel =
      lblnew_PaymentAmount3.FieldLabel =
      CrmLabel.TranslateAttributeLabelMessage("new_UPTCardTransferAmount", TuEntityEnum.New_CustAccountOperations.GetHashCode());
        //Gercek Hesap Seçiliyor.
        new_CustAccountTypeId.Value = new TuFactory.CustAccount.Business.CustAccountOperations().GetCustAccountTypeList().Where(t => t.Code == "001").FirstOrDefault().Id.ToString().ToLower();
        new_PaymentMethod.Value = TransferCollectionMethodEnum.Single.GetHashCode().ToString();
        new_UPTCardTransferAmount.c1.SetValue(_CountryCurrencyID, _CountryCurrencyIDName);
        var ufFactory = new TuUserFactory();
        _activeUser = ufFactory.GetActiveUser();
        new_CorporationId.Value = _activeUser.CorporationId.ToString();
        new_OfficeId.Value = _activeUser.OfficeId.ToString();

    }

    public void PrepareItems()
    {
        TuUserApproval userApproval = new TuUserFactory().GetApproval(App.Params.CurrentUser.SystemUserId);
        //Bakiye görme yetkisi yoksa
        if (!userApproval.CustAccountBalanceView)
        {
            new_CustAccountBalance.Hide();
            lblBalance.Hide();
            QScript("comboViewHideBalance();");
        }
    }

    private void TranslateMessage()
    {
        RxM.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_PaymentMethod",
                                                                TuEntityEnum.New_Payment.GetHashCode());
        new_IdentityWasSeenReadOnly.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_IdentityWasSeen", TuEntityEnum.New_CustAccountOperations.GetHashCode());
    }

    protected void CalculateOnEvent(object sender, AjaxEventArgs e)
    {
        ExpenseProcessor();
        var sd = new StaticData();

        try
        {

            var paymentmount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_UPTCardTransferAmount.d1).Value, 0);

            var pamountCurrency = ValidationHelper.GetGuid(((CrmComboComp)new_PaidAmount1.c1).Value);
            if (!CheckCalculation())
                return;

            CustInfoFactory infoServ = new CustInfoFactory();
            var accountTypeCode = infoServ.GetCustAccountTypeCode(ValidationHelper.GetGuid(new_CustAccountTypeId.Value));
            int senderType = (int)DepositThirdSenderTypeEnum.Own;
            var tpc = new TransactionOperations();
            var ret = tpc.Calculate(
                paymentmount,
                ValidationHelper.GetGuid(new_CustAccountId.Value),
                !isNewAmount ? new_CalculatedExpenseAmount.d1.Value : null,
                !isNewAmount ? ValidationHelper.GetGuid(new_CalculatedExpenseAmount.c1.Value) : Guid.Empty,
                ValidationHelper.GetGuid(new_SenderId.Value),
                ValidationHelper.GetGuid(new_CorporationId.Value),
                ValidationHelper.GetGuid(new_OfficeId.Value),
                ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value),
                pamountCurrency,
                ValidationHelper.GetInteger(new_PaymentMethod.Value, 1),
                Guid.Empty,
                senderType);


            if (ret.PaidAmount1 > 0)
            {
                if (!string.IsNullOrEmpty(ret.Message))
                {
                    if (ret.calculatedExpenseAmount != null)
                    {
                        new_ExpenseAmount.Items[0].SetValue(
                            ValidationHelper.GetDecimal(ret.calculatedExpenseAmount, 0));
                        new_PaidAmount1.Items[0].SetValue(
                            ValidationHelper.GetDecimal(ret.PaidAmount1, 0));
                    }

                    var msg = new MessageBox { Width = 500 };
                    msg.Show(ret.Message);
                }
                else
                {
                    new_PaidAmount1.Items[0].SetValue(ret.PaidAmount1);
                    new_PaidAmount1.Items[1].SetValue(ret.PaidAmount1Currency.ToString());

                    new_ReceivedExpenseAmount.Items[0].SetValue(ret.receivedExpenseAmount);
                    new_ReceivedExpenseAmount.c1.SetValue(ret.receivedExpenseAmountCurrency);

                    new_ExpenseAmount.Items[0].SetValue(ret.ExpenseAmount);
                    new_ExpenseAmount.Items[1].SetValue(ret.ExpenseAmountCurrency);

                    if (new_CalculatedExpenseCurrencyDefaultValue.Value !=
                        ValidationHelper.GetString(ret.calculatedExpenseAmountCurrency) ||
                        new_CalculatedExpenseAmountDefaultValue.Value == "0" ||
                        new_CalculatedExpenseAmountDefaultValue.Value == string.Empty)
                    {
                        new_CalculatedExpenseAmountDefaultValue.Value =
                            ValidationHelper.GetDecimal(ret.calculatedExpenseAmount, 0).ToString();
                        new_CalculatedExpenseCurrencyDefaultValue.Value =
                            ValidationHelper.GetString(ret.calculatedExpenseAmountCurrency);
                        new_CalculatedExpenseAmountDefaultValue.SetIValue(
                            ValidationHelper.GetDecimal(ret.calculatedExpenseAmount, 0));
                        new_CalculatedExpenseCurrencyDefaultValue.SetIValue(
                            ValidationHelper.GetString(ret.calculatedExpenseAmountCurrency));
                    }

                    new_CalculatedExpenseAmount.Items[0].SetIValue(
                        ValidationHelper.GetDecimal(ret.calculatedExpenseAmount, 0));
                    new_CalculatedExpenseAmount.Items[1].SetIValue(
                        ValidationHelper.GetString(ret.calculatedExpenseAmountCurrency));


                    new_TotalPayedAmount.Items[0].SetValue(
                        ValidationHelper.GetDecimal(ret.totalPayedAmount, 0));
                    new_TotalPayedAmount.Items[1].SetValue(
                        ValidationHelper.GetGuid(ret.totalPayedAmountCurrency));
                    new_UPTCardTransferAmount.Items[0].SetValue(ValidationHelper.GetDecimal(ret.uptCardPaymentAmount, 0));
                    new_UPTCardTransferAmount.Items[1].SetValue(ValidationHelper.GetString(ret.uptCardPaymentAmountCurrency));
                    Parity1.Clear();

                    Parity1.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaidParity1", TuEntityEnum.New_Payment.GetHashCode()) + ":&nbsp;&nbsp;" +
                     Math.Round(ValidationHelper.GetDecimal(ret.TransferPaidParity1, 0), 6).ToString());
                }
            }
            else
            {
                if (!string.IsNullOrEmpty(ret.Message))
                {
                    var msg = new MessageBox { Width = 500, Height = 200 };
                    msg.Show(ret.Message);
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

    private void ClearFieldsForCustAccountID()
    {
        new_UPTCardTransferAmount.c1.Clear();
        new_UPTCardTransferAmount.d1.Clear();
        txtCardNumber.Clear();
        new_ExpenseAmount.c1.Clear();
        new_ExpenseAmount.d1.Clear();
        new_CalculatedExpenseAmount.c1.Clear();
        new_CalculatedExpenseAmount.d1.Clear();
        new_PaidAmount1.c1.Clear();
        new_PaidAmount1.d1.Clear();
        new_TotalPayedAmount.c1.Clear();
        new_TotalPayedAmount.d1.Clear();
    }

    bool CheckCalculation()
    {
        if (ValidationHelper.GetGuid(new_CorporationCountryId.Value) == Guid.Empty)
        {
            ShowRequiredFields(new_CorporationCountryId.FieldLabel);
            return false;
        }
        if (ValidationHelper.GetGuid(new_CorporationId.Value) == Guid.Empty)
        {
            ShowRequiredFields(new_CorporationId.FieldLabel);
            return false;
        }
        if (ValidationHelper.GetDecimal(new_UPTCardTransferAmount.d1.Value, 0) <= 0)
        {
            return false;
        }
        return true;
    }

    private void ShowRequiredFields(string fieldLabel)
    {
        throw new NotImplementedException();
    }

    protected void ExpenseProcessor()
    {
        decimal realCostAmount = ValidationHelper.GetDecimal(string.IsNullOrEmpty(new_CalculatedExpenseAmountDefaultValue.Value) ? "0" : new_CalculatedExpenseAmountDefaultValue.Value, 0);
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

    #region ComponentEvents
    protected void new_CustAccountId_OnChange(object sender, AjaxEventArgs e)
    {
        var custAccountId = Guid.Empty;
        if (!string.IsNullOrEmpty(new_CustAccountId.Value))
        {
            custAccountId = ValidationHelper.GetGuid(new_CustAccountId.Value);
            var message = new TuFactory.CustAccount.Business.CustAccountOperations().IsAvailableCustAccount(custAccountId);
            if (message != string.Empty)
            {
                new_CustAccountId.Clear();
                Upt.Alert(message);

                return;
            }
        }
        else
        {
            CustAccountIdDetail.AutoLoad.Url = aboutblank;
            CustAccountIdDetail.LoadUrl(CustAccountIdDetail.AutoLoad.Url);
            ClearFieldsForCustAccountID();
            return;
        }

        RefreshCustAccount(custAccountId);
        SetCustAccountCurrencyId(custAccountId);
        new_PaidAmount1CurrencyOnChange(sender, e);
    }

    protected void new_PaidAmount1CurrencyOnChange(object sender, AjaxEventArgs e)
    {
        SetCollectionMethod(sender, e);
    }

    protected void new_UPTCardTransferAmount_OnChange(object sender, AjaxEventArgs e)
    {
        if (new_PaidAmount1.c1.Value == string.Empty)
        {
            return;
        }
        setUserCostReductionRate();

        if (((Coretech.Crm.Web.UI.RefleX.AutoGenerate.CrmDecimalComp)sender).UniqueName != "new_PaymentAmount")
        {
            isNewAmount = false;
            sender = this.new_UPTCardTransferAmount.d1;
        }
        else
        {
            isNewAmount = true;
            RebuildExpenseProcess(Guid.Empty, null);
        }
        CalculateOnEvent(sender, e);
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

    protected void RebuildExpenseProcess(Guid custAccountOperationsId, DbTransaction transaction)
    {
        resetExpenseProcess();
        setUserCostReductionRate();
        var sd = new StaticData();

        try
        {

            if (!CheckCalculation())
                return;
            var paymentmount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_UPTCardTransferAmount.d1).Value, 0);
            var pamountCurrency = ValidationHelper.GetGuid(((CrmComboComp)new_PaidAmount1.c1).Value);
            var tpc = new TransactionOperations();
            CustInfoFactory infoServ = new CustInfoFactory();
            var accountTypeCode = infoServ.GetCustAccountTypeCode(ValidationHelper.GetGuid(new_CustAccountTypeId.Value));
            int senderType = (int)DepositThirdSenderTypeEnum.Own;

            var retcalc = tpc.Calculate(
                paymentmount
                , ValidationHelper.GetGuid(new_CustAccountId.Value)
                , !isNewAmount ? new_CalculatedExpenseAmount.d1.Value : null
                , !isNewAmount ? ValidationHelper.GetGuid(new_CalculatedExpenseAmount.c1.Value) : Guid.Empty
                , ValidationHelper.GetGuid(new_SenderId.Value),
                ValidationHelper.GetGuid(new_CorporationId.Value),
                ValidationHelper.GetGuid(new_OfficeId.Value),
                ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value),
                pamountCurrency,
                ValidationHelper.GetInteger(new_PaymentMethod.Value, 1),
                custAccountOperationsId,
                senderType,
                transaction);
            if (custAccountOperationsId == Guid.Empty)
            {
                if (!string.IsNullOrEmpty(retcalc.Message))
                {
                    if (retcalc.calculatedExpenseAmount != null)
                    {
                        new_ExpenseAmount.Items[0].SetValue(
                            ValidationHelper.GetDecimal(retcalc.calculatedExpenseAmount, 0));
                        new_PaidAmount1.Items[0].SetValue(
                            ValidationHelper.GetDecimal(retcalc.PaidAmount1, 0));
                    }

                    var msg = new MessageBox { Width = 500 };
                    msg.Show(retcalc.Message);
                    btnNext_Screen1.SetDisabled(true);
                }
                else
                {
                    btnNext_Screen1.SetDisabled(false);
                    new_PaidAmount1.Items[0].SetValue(retcalc.PaidAmount1);
                    new_PaidAmount1.Items[1].SetValue(retcalc.PaidAmount1Currency.ToString());

                    new_ReceivedExpenseAmount.Items[0].SetValue(retcalc.receivedExpenseAmount);
                    new_ReceivedExpenseAmount.Items[1].SetValue(retcalc.receivedExpenseAmountCurrency);

                    new_ExpenseAmount.Items[0].SetValue(retcalc.ExpenseAmount);
                    new_ExpenseAmount.Items[1].SetValue(retcalc.ExpenseAmountCurrency);

                    if (new_CalculatedExpenseCurrencyDefaultValue.Value !=
                        ValidationHelper.GetString(retcalc.calculatedExpenseAmountCurrency) ||
                        new_CalculatedExpenseAmountDefaultValue.Value == "0" ||
                        new_CalculatedExpenseAmountDefaultValue.Value == string.Empty)
                    {
                        new_CalculatedExpenseAmountDefaultValue.Value =
                            ValidationHelper.GetDecimal(retcalc.calculatedExpenseAmount, 0).ToString();
                        new_CalculatedExpenseCurrencyDefaultValue.Value =
                            ValidationHelper.GetString(retcalc.calculatedExpenseAmountCurrency);
                        new_CalculatedExpenseAmountDefaultValue.SetIValue(
                            ValidationHelper.GetDecimal(retcalc.calculatedExpenseAmount, 0));
                        new_CalculatedExpenseCurrencyDefaultValue.SetIValue(
                            ValidationHelper.GetString(retcalc.calculatedExpenseAmountCurrency));
                    }

                    new_CalculatedExpenseAmount.Items[0].SetValue(
                        ValidationHelper.GetDecimal(retcalc.calculatedExpenseAmount, 0));
                    new_CalculatedExpenseAmount.Items[1].SetIValue(
                        ValidationHelper.GetString(retcalc.calculatedExpenseAmountCurrency));


                    new_TotalPayedAmount.Items[0].SetValue(
                        ValidationHelper.GetDecimal(retcalc.totalPayedAmount, 0));
                    new_TotalPayedAmount.Items[1].SetValue(
                        ValidationHelper.GetGuid(retcalc.totalPayedAmountCurrency));
                    new_UPTCardTransferAmount.Items[0].SetValue(ValidationHelper.GetDecimal(retcalc.uptCardPaymentAmount, 0));
                    new_UPTCardTransferAmount.Items[1].SetValue(ValidationHelper.GetString(retcalc.uptCardPaymentAmountCurrency));
                    Parity1.Clear();

                }
            }

        }
        catch (Exception ex)
        {
            if (transaction != null)
                throw;

            MessageBox msgBox = new MessageBox();
            msgBox.Show(ex.Message);
        }
    }


    void SetCollectionMethod(object sender, AjaxEventArgs e)
    {
        new_PaymentMethod.Value = TransferCollectionMethodEnum.Single.GetHashCode().ToString();
        new_CollectionMethodOnChange(sender, e);
    }

    protected void new_CollectionMethodOnChange(object sender, AjaxEventArgs e)
    {
        if (ValidationHelper.GetInteger(new_PaymentMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        {
            new_PaidAmount1.d1.Clear();
            new_PaidAmount1.d1.Value = 0;

        }
        else
        {
            new_PaidAmount1.d1.Clear();
        }

        CalculateOnEvent(sender, e);

    }

    private void SetCustAccountCurrencyId(Guid custAccountId)
    {
        var df = new DynamicFactory(ERunInUser.CalingUser);
        var de = df.RetrieveWithOutPlugin(TuEntityEnum.New_CustAccounts.GetHashCode(), custAccountId, new[] { "new_CustAccountCurrencyId", "new_Balance", "new_IsBlocked",
            "new_BlockedAmount", "new_BlockedStartDate", "new_BlockedEndDate",
            "new_BlockedType","new_SenderId", "new_CustAccountTypeId"  });
        var currency = de.GetLookupValue("new_CustAccountCurrencyId");
        var balance = TuFactory.CustAccount.Business.CustAccountOperations.GetActiveBalance(custAccountId);

        if (currency != Guid.Empty)
        {
            var sender = de.Properties["new_SenderId"] as Lookup;
            var custAccountTypeId = de.Properties["new_CustAccountTypeId"] as Lookup;

            new_CustAccountCurrencyId.SetValue(ValidationHelper.GetString(((Lookup)de["new_CustAccountCurrencyId"]).Value), ((Lookup)de["new_CustAccountCurrencyId"]).name);
            new_CustAccountCurrencyId.Value = ValidationHelper.GetString(currency);
            new_PaidAmount1.c1.Value = ValidationHelper.GetString(currency);
            new_PaidAmount1.c1.SetValue(ValidationHelper.GetString(((Lookup)de["new_CustAccountCurrencyId"]).Value), ((Lookup)de["new_CustAccountCurrencyId"]).name);
            new_CustAccountBalance.SetValue(ValidationHelper.GetString(balance));

            if (sender != null && sender.Value != ValidationHelper.GetGuid(new_SenderId.Value))
            {
                new_SenderId.SetValue(sender.Value.ToString(), sender.name);
                new_SenderId.Value = sender.Value.ToString();
                new_SenderId_OnChange(null, null);
            }
            if (custAccountTypeId != null && custAccountTypeId.Value != ValidationHelper.GetGuid(new_CustAccountTypeId.Value))
            {
                new_CustAccountTypeId.SetValue(custAccountTypeId.Value.ToString(), custAccountTypeId.name);
                new_CustAccountTypeId.Value = custAccountTypeId.Value.ToString();
            }

        }
        else
        {
            new_CustAccountCurrencyId.Clear();
            new_CustAccountBalance.Clear();
        }
    }

    protected void SenderProfessionCheck(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(new_SenderId.Value))
        {
            var professionDb = new ProfessionDb();
            if (!professionDb.ExistsSenderProfessionInfo(ValidationHelper.GetGuid(new_SenderId.Value)))
            {
                QScript(string.Format("ShowProfession('{0}','{1}');", new_SenderId.Value, CrmLabel.TranslateMessage("CRM.NEW_PROFESSION_CONTROL_FORM")));
                return;
            }
            else
            {
                QScript("Screen1_Next();");
            }
        }
    }

    protected void new_SenderId_OnChange(object sender, AjaxEventArgs e)
    {
        var senderId = ValidationHelper.GetGuid(new_SenderId.Value);

        if (!string.IsNullOrEmpty(new_SenderId.Value))
        {
            var professionDb = new ProfessionDb();
            if (!professionDb.ExistsSenderProfessionInfo(ValidationHelper.GetGuid(senderId)))
            {
                QScript(string.Format("ShowProfession('{0}','{1}');", new_SenderId.Value, CrmLabel.TranslateMessage("CRM.NEW_PROFESSION_CONTROL_FORM")));
            }
        }

        if (senderId == Guid.Empty)
        {
            new_CustAccountId.Clear();
            new_CustAccountCurrencyId.Clear();
            new_CustAccountBalance.Clear();
            CustAccountIdDetail.AutoLoad.Url = aboutblank;
            CustAccountIdDetail.LoadUrl(CustAccountIdDetail.AutoLoad.Url);
            SenderDetail.AutoLoad.Url = aboutblank;
            SenderDetail.LoadUrl(SenderDetail.AutoLoad.Url);
        }
        else
        {
            try
            {
                var activeUPTCards = new CardClientService().GetSenderActiveCards(ValidationHelper.GetGuid(new_SenderId.Value));
                if (activeUPTCards.ServiceResponse.Count == 0)
                {
                    Upt.Alert(CrmLabel.TranslateMessage("CRM.NEW_UPTCARD_NO_ACTIVE_CARD_FOUND"));
                    new_SenderId.Clear();
                    return;
                }
                else
                {
                    var card = activeUPTCards.ServiceResponse.FirstOrDefault();
                    txtCardNumber.SetValue(card.CardNumber);
                    UptCardID.SetValue(card.UptCardID.ToString());
                    CardNumber2.SetValue(card.CardNumber);
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "UPTCard");
                Upt.Alert("UptCard Hata: " + ex.Message);
            }
        }

        RefreshSender(senderId);
    }

    private void RefreshSender(Guid senderId)
    {
        var ms = new MessageBox { Modal = true };

        if (senderId != Guid.Empty)
        {
            var readonlyRealform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_FOR_CUSTACCOUNT_REAL_FORM"));
            var readonlyTuzelform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_FOR_CUSTACCOUNT_CORP_FORM"));

            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", isTuzel ? readonlyTuzelform : readonlyRealform},
                                {"ObjectId",( (int)TuEntityEnum.New_Sender).ToString()},
                                {"recid", senderId.ToString()},
                                {"mode", "-1"}
                            };
            var urlparam = QueryHelper.RefreshUrl(query);
            SenderDetail.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            SenderDetail.LoadUrl(SenderDetail.AutoLoad.Url);
            QScript(" R.reSize();");
        }
        else
        {
            if (!new_SenderId.IsEmpty)
            {
                ms.MessageType = EMessageType.Error;
                ms.Show(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDER_NOT_FOUND"));
            }
        }
    }
    private void RefreshCustAccount(Guid custAccountId)
    {
        var ms = new MessageBox { Modal = true };


        if (custAccountId != Guid.Empty)
        {
            var readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_NEW_CUSTACCOUNTS_FORM"));

            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyform},
                                {"ObjectId",( (int)TuEntityEnum.New_CustAccounts).ToString()},
                                {"recid", custAccountId.ToString()},
                                {"mode", "-1"}
                            };
            var urlparam = QueryHelper.RefreshUrl(query);
            CustAccountIdDetail.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            CustAccountIdDetail.LoadUrl(CustAccountIdDetail.AutoLoad.Url);
            QScript(" R.reSize();");
        }
        else
        {
            CustAccountIdDetail.AutoLoad.Url = aboutblank;
            CustAccountIdDetail.LoadUrl(CustAccountIdDetail.AutoLoad.Url);

            if (!new_SenderId.IsEmpty)
            {
                ms.MessageType = EMessageType.Error;
                ms.Show(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_CUSTACCOUNT_NOT_FOUND"));
            }
        }
    }

    TransferToUptCardItem GetTransferToUptCardItem()
    {
        #region TransferToUptCardItem Object

        TransferToUptCardItem transferToUptCardItem = new TransferToUptCardItem();

        transferToUptCardItem.CustAccountOperationType = new Domain.Entities.CustAccountOperationType()
        {
            CustAccountOperationTypeId = ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value)
        };

        transferToUptCardItem.UptCard = new UptCard()
        {
            UptCardId = ValidationHelper.GetGuid(UptCardID.Value)
        };

        transferToUptCardItem.Sender = new Sender()
        {
            SenderId = ValidationHelper.GetGuid(new_SenderId.Value)
        };

        transferToUptCardItem.CustAccountType = new Domain.Entities.CustAccountType()
        {
            CustAccountTypeId = ValidationHelper.GetGuid(new_CustAccountTypeId.Value)
        };

        transferToUptCardItem.CustAccountCurrency = new Currency()
        {
            CurrencyId = ValidationHelper.GetGuid(new_CustAccountCurrencyId.Value)
        };

        transferToUptCardItem.Corporation = new Corporation()
        {
            CorporationId = ValidationHelper.GetGuid(new_CorporationId.Value)
        };

        transferToUptCardItem.Office = new Office()
        {
            OfficeId = ValidationHelper.GetGuid(new_OfficeId.Value)
        };

        transferToUptCardItem.CustAccount = new Domain.Entities.CustAccount()
        {
            CustAccountId = ValidationHelper.GetGuid(new_CustAccountId.Value)
        };

        transferToUptCardItem.SenderIdentificationCardType = new IdentificatonCardType()
        {
            New_IdentificatonCardTypeId = ValidationHelper.GetGuid(new_SenderIdentificationCardTypeID.Value)
        };

        transferToUptCardItem.IdentityWasSeen = ValidationHelper.GetBoolean(new_IdentityWasSeen.Value);
        transferToUptCardItem.SenderIdentificationCardNo = ValidationHelper.GetString(new_SenderIdentificationCardNo.Value);
        transferToUptCardItem.PaymentMethod = ValidationHelper.GetInteger(new_PaymentMethod.Value, 1);

        if (new_PaidAmount1.d1.Value != null)
        {
            transferToUptCardItem.PaidAmount1 = new TransactionAmount()
            {
                Amount = new_PaidAmount1.d1.Value.Value,
                AmountCurrency = new Currency()
                {
                    CurrencyId = ValidationHelper.GetGuid(new_PaidAmount1.c1.Value)
                }
            };

            transferToUptCardItem.PaymentAmount = new TransactionAmount()
            {
                Amount = new_PaidAmount1.d1.Value.Value,
                AmountCurrency = new Currency()
                {
                    CurrencyId = ValidationHelper.GetGuid(new_PaidAmount1.c1.Value)
                }
            };

        }

        if (new_UPTCardTransferAmount.d1.Value != null)
        {
            transferToUptCardItem.UptCardTransferAmount = new TransactionAmount()
            {
                Amount = new_UPTCardTransferAmount.d1.Value.Value,
                AmountCurrency = new Currency()
                {
                    CurrencyId = ValidationHelper.GetGuid(new_UPTCardTransferAmount.c1.Value)
                }
            };

        }

        CalculateTransferToUptCardRequest calculateTransferToUptCardRequest = new CalculateTransferToUptCardRequest();
        calculateTransferToUptCardRequest.Amount = new TransactionAmount()
        {
            Amount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_UPTCardTransferAmount.d1).Value, 0)
        };

        if (!isNewAmount)
        {
            calculateTransferToUptCardRequest.CustomExpense = new TransactionAmount()
            {
                Amount = new_CalculatedExpenseAmount.d1.Value.Value,
                AmountCurrency = new Currency()
                {
                    CurrencyId = ValidationHelper.GetGuid(new_CalculatedExpenseAmount.c1.Value)
                }
            };
        }

        calculateTransferToUptCardRequest.AttributeAmount = new TransactionAmount()
        {
            AmountCurrency = new Currency()
            {
                CurrencyId = ValidationHelper.GetGuid(new_CalculatedExpenseAmount.c1.Value)
            }
        };

        calculateTransferToUptCardRequest.CustAccount = new Domain.Entities.CustAccount()
        {
            CustAccountId = ValidationHelper.GetGuid(new_CustAccountId.Value)
        };

        calculateTransferToUptCardRequest.Corporation = new Corporation()
        {
            CorporationId = ValidationHelper.GetGuid(new_CorporationId.Value)
        };

        calculateTransferToUptCardRequest.Office = new Office()
        {
            OfficeId = ValidationHelper.GetGuid(new_OfficeId.Value)
        };

        calculateTransferToUptCardRequest.CustAccountOperationTypeId = ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value);
        calculateTransferToUptCardRequest.CustAccountOperationId = transferToUptCardItem.CustAccountOperationId;
        calculateTransferToUptCardRequest.PaymentMethod = ValidationHelper.GetInteger(new_PaymentMethod.Value, 1);

        CustInfoFactory infoServ = new CustInfoFactory();
        var accountTypeCode = infoServ.GetCustAccountTypeCode(ValidationHelper.GetGuid(new_CustAccountTypeId.Value));
        int senderType = accountTypeCode == Object.CustAccountType.GERCEK ? (int)DepositThirdSenderTypeEnum.Own : (int)DepositThirdSenderTypeEnum.SenderPerson;
        calculateTransferToUptCardRequest.SenderType = senderType;

        calculateTransferToUptCardRequest.Sender = new Sender()
        {
            SenderId = ValidationHelper.GetGuid(transferToUptCardItem.Sender.SenderId)
        };

        transferToUptCardItem.Calculate = calculateTransferToUptCardRequest;

        #endregion

        return transferToUptCardItem;
    }

    protected void btnFinishOnClickEvent2(object sender, AjaxEventArgs e)
    {
        ICustAccountOperationService<object> _service = new TransferToUptCardService<object>();
        ICustAccountItem transferToUptCardItem = GetTransferToUptCardItem();
        var response = _service.Request(transferToUptCardItem);

        switch (response.OperationLevel)
        {
            case OperationLevel.AgeCheck:
            case OperationLevel.AccountCheckLimit:
            case OperationLevel.Calculate:
            
                Alert(response.RETURN_DESCRIPTION);
                break;
            case OperationLevel.CreateException:
            case OperationLevel.PreAccountingBalanceCheck:
            case OperationLevel.PrepareStatuUpdateException:
                // Mesaj alt methodlardan throw edilecek
                break;
            case OperationLevel.ConfirmCheck:
            case OperationLevel.FraudCheck:
            case OperationLevel.CardTopUp:
                if (response.ResponseStatus == ServiceResponseStatus.Error)
                {
                    BasePage.QScript("btnFinis.hide();");
                    Alert(response.RETURN_DESCRIPTION);
                    BasePage.QScript("RefreshParetnGrid(true);");
                    return;
                }
                break;
            default:
                break;
        }

        Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_MUSTRECIPMENT"));
        Response.Redirect("CustAccountRouter.aspx?recid=" + transferToUptCardItem.CustAccountOperationId);
    }



    protected void btnFinishOnClickEvent(object sender, AjaxEventArgs e)
    {
        if (ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("WORK_WITH_THE_NEW_CUSTACCOUNT_SERVICE")))
        {
            btnFinishOnClickEvent2(sender, e);
            return;
        }


        StaticData sd = new StaticData();
        var tr = sd.GetDbTransaction();
        DynamicFactory df = new DynamicFactory(ERunInUser.CalingUser);
        df.GetBeginTrans(tr);
        var id = Guid.Empty;
        DynamicEntity de = new DynamicEntity(TuEntityEnum.New_CustAccountOperations.GetHashCode());
        try
        {
            string operationDescription = string.Empty;

            de.AddLookupProperty("new_CustAccountOperationTypeId", "",
                ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value));
            de.AddLookupProperty("new_SenderId", "", ValidationHelper.GetGuid(new_SenderId.Value));
            de.AddLookupProperty("new_CustAccountTypeId", "", ValidationHelper.GetGuid(new_CustAccountTypeId.Value));
            de.AddLookupProperty("new_CustAccountCurrencyId", "",
                ValidationHelper.GetGuid(new_CustAccountCurrencyId.Value));
            de.AddLookupProperty("new_CorporationId", "", ValidationHelper.GetGuid(new_CorporationId.Value));
            de.AddLookupProperty("new_OfficeId", "", ValidationHelper.GetGuid(new_OfficeId.Value));
            de.AddLookupProperty("new_CustAccountId", "", ValidationHelper.GetGuid(new_CustAccountId.Value));
            de.AddPicklistProperty("new_PaymentMethod", ValidationHelper.GetInteger(new_PaymentMethod.Value, 1));


            if (!string.IsNullOrEmpty(new_OperationDescription.Value))
            {
                operationDescription = ValidationHelper.GetString(new_OperationDescription.Value);
            }
            else
            {
                operationDescription = string.Format("UPT Kart  - {0}", de.GetStringValue("CustAccountOperationName"));
            }

            de.AddStringProperty("new_OperationDescription", operationDescription);

            if (new_PaidAmount1.d1.Value != null)
            {
                de.AddMoneyProperty("new_PaidAmount1", new_PaidAmount1.d1.Value.Value,
                    new Lookup("new_PaidAmount1Currency", ValidationHelper.GetGuid(new_PaidAmount1.c1.Value)));
                de.AddMoneyProperty("new_PaymentAmount", new_PaidAmount1.d1.Value.Value,
                    new Lookup("new_PaymentAmountCurrency", ValidationHelper.GetGuid(new_PaidAmount1.c1.Value)));
            }

            if (new_UPTCardTransferAmount.d1.Value != null)
            {
                de.AddMoneyProperty("new_UPTCardTransferAmount", new_UPTCardTransferAmount.d1.Value.Value,
                    new Lookup("new_UPTCardTransferAmountCurrency", ValidationHelper.GetGuid(new_UPTCardTransferAmount.c1.Value)));
            }

            de.AddLookupProperty("new_SenderIdentificationCardTypeID", "",
                ValidationHelper.GetGuid(new_SenderIdentificationCardTypeID.Value));
            de.AddBooleanProperty("new_IdentityWasSeen", ValidationHelper.GetBoolean(new_IdentityWasSeen.Value));
            de.AddStringProperty("new_SenderIdentificationCardNo",
                ValidationHelper.GetString(new_SenderIdentificationCardNo.Value));
            if (ValidationHelper.GetGuid(UptCardID.Value) != Guid.Empty)
            {
                de.AddLookupProperty("new_UptCard", "",
                ValidationHelper.GetGuid(UptCardID.Value));
            }


            id = df.Create(TuEntityEnum.New_CustAccountOperations.GetHashCode(), de);

            #region CheckForParameters
            //Hesap bakiye kontrolü + UPT Kart Minimum/Maksimum Limit Kontrolleri
            string ret = ValidateUptCardTransfer(tr);

            if (!string.IsNullOrEmpty(ret))
            {
                id = Guid.Empty;
                throw new TuException(ValidationHelper.GetString(ret), "CUST001");
            }
            #endregion

            var paymentmount = ValidationHelper.GetDecimal(new_UPTCardTransferAmount.d1.Value, 0);
            var pamount = ValidationHelper.GetDecimal(new_PaidAmount1.d1.Value, 0);
            var pamountCurrency = ValidationHelper.GetGuid(new_PaidAmount1.c1.Value);

            RebuildExpenseProcess(id, tr);

            //_cardClientService.InsertAccountTransactionBankRef(bankTopUpResponse.ServiceResponse.RRN, id);

            StaticData.Commit(tr);
        }
        catch (CrmException exc)
        {
            StaticData.Rollback(tr);
            var msg = new MessageBox();
            msg.Show(exc.ErrorMessage);
            return;
        }
        catch (TuException exc)
        {
            StaticData.Rollback(tr);
            exc.Show();
            return;
        }
        catch (Exception exc)
        {
            StaticData.Rollback(tr);
            var msg = new MessageBox();
            msg.Show(exc.Message);
            return;
        }

        //CustAccount.Business.
        if (id != Guid.Empty)
        {

            sd.AddParameter("CustAccountOperationsId", DbType.Guid, id);
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            var ret1 = ValidationHelper.GetString(sd.ExecuteScalarSp("SpTuCustAccountTransferToCardPrepare"));
            if (!string.IsNullOrEmpty(ret1))
            {
                ValidationHelper.GetString(ret1);
            }
            try
            {
                // Karta para transferinde onay mekanizması olmayacak...
                //CustAccountApprovePoolService approvePoolService = new CustAccountApprovePoolService();
                //Object.CustAccountApprovePoolResponse approvePoolResponse = approvePoolService.ApproveStageProcess(id);
                //if (!approvePoolResponse.result)
                //{
                //    BasePage.QScript("btnFinis.hide();");
                //    Alert(approvePoolResponse.message);
                //    BasePage.QScript("RefreshParetnGrid(true);");
                //    return;
                //}

                ConfirmFactory amlFraudService = new ConfirmFactory();
                var amlFraudResponse = amlFraudService.AmlFraudProcess(id);
                if (!amlFraudResponse.result)
                {

                    BasePage.QScript("btnFinis.hide();");
                    Alert(amlFraudResponse.message);
                    BasePage.QScript("RefreshParetnGrid(true);");
                }
                else
                {
                    /*Paygate aktifse top up dekont basın arkasında çalışacak.*/
                    if (!ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("PAYGATE_ISACTIVE"), false))
                    {
                        _cardClientService = new CardClientService();

                        var canFinish = _cardClientService.FinishTransferToCardOperation(id, App.Params.CurrentUser.SystemUserId);

                        if (canFinish.ServiceResponse)
                        {
                            Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_MUSTRECIPMENT"));
                            Response.Redirect("CustAccountRouter.aspx?recid=" + id);
                        }
                        else
                        {
                            Alert("Hata: " + canFinish.RETURN_DESCRIPTION);
                            _cardClientService.RollbackCustAccountOperation(id, App.Params.CurrentUser.SystemUserId);
                            BasePage.QScript("btnFinis.hide();");

                        }
                    }
                    else
                    {
                        BasePage.QScript("btnFinis.hide();");
                        Response.Redirect("CustAccountRouter.aspx?recid=" + id);
                    }
                }
            }
            catch (TuException exc)
            {
                _cardClientService = new CardClientService();
                _cardClientService.RollbackCustAccountOperation(id, App.Params.CurrentUser.SystemUserId);

                Alert(exc.ErrorMessage);
                BasePage.QScript("RefreshParetnGrid(true);");

            }
            catch (Exception exc)
            {
                Alert(exc.Message);
                BasePage.QScript("RefreshParetnGrid(true);");
            }
        }
    }

    private string ValidateUptCardTransfer(DbTransaction tr)
    {
        Guid custAccountId = ValidationHelper.GetGuid(new_CustAccountId.Value);
        decimal paymentAmount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_PaymentAmountReadOnly.d1).Value, 0);
        decimal paidAmount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_PaidAmount1ReadOnly.d1).Value, 0);

        decimal balance = CustAccountOperations.GetBalance(custAccountId, tr);
        if (balance - paidAmount < 0)
        {
            return CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_BALANCE_LOWERTHAN_ZERO");
        }
        decimal balanceActive = CustAccountOperations.GetActiveBalance(custAccountId, tr);
        if (balanceActive - paidAmount < 0)
        {
            return CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_BALANCE_LOWERTHAN_BLOCKED");
        }
        var cardLimits = new CardClientService().GetCardLimits(ValidationHelper.GetGuid(UptCardID.Value));
        if (cardLimits.ServiceResponse.MinimumLimit != null && paymentAmount < cardLimits.ServiceResponse.MinimumLimit)
        {
            return CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_UPT_CARD_MINIMUM_LIMIT_VALIDATION");
        }
        if (cardLimits.ServiceResponse.MaximumLimit != null && paymentAmount > cardLimits.ServiceResponse.MaximumLimit)
        {
            return CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_UPT_CARD_MAXIMUM_LIMIT_VALIDATION");
        }
        return String.Empty;
    }
    #endregion

    protected void new_CountryIdentificationTypeLoad(object sender, AjaxEventArgs e)
    {


        var dft = new DynamicFactory(ERunInUser.CalingUser);
        DynamicEntity trt = new DynamicEntity();

        trt = dft.RetrieveWithOutPlugin(TuEntityEnum.New_Sender.GetHashCode(), ValidationHelper.GetGuid(new_SenderId.Value), new string[] { "new_NationalityID" });

        Guid new_NationalityID = ValidationHelper.GetGuid(trt.GetLookupValue("new_NationalityID"));

        if (new_NationalityID == Guid.Empty)
        {
            var m = new MessageBox { Width = 400, Height = 180 };
            var msg2 = CrmLabel.TranslateMessage("Uyruk Seçimi Yapılmamış.");
            m.Show(msg2);
            return;
        }

        string strSql = @"

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
        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId));

        var like = new_SenderIdentificationCardTypeID.Query();

        if (!string.IsNullOrEmpty(like))
        {

            strSql += " AND l.Value LIKE  @new_IdentificationCardTypeName + '%' ";
            sd.AddParameter("new_IdentificationCardTypeName", DbType.String, like);
        }

        BindCombo(new_SenderIdentificationCardTypeID, sd, strSql);
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
    public class Upt
    {
        public static void AlertMessage(String message)
        {
            Alert(CrmLabel.TranslateMessage(message));
        }
        public static void Alert(String message)
        {
            QScript("Upt.alert(" + BasePage.SerializeString(message) + ",1,'');");
        }
    }
}
