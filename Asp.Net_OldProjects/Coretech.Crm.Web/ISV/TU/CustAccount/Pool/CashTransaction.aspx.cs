using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Newtonsoft.Json;
using TuFactory.CustAccount.Business;
using Object = TuFactory.CustAccount.Object;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;
using TuFactory.CustAccount.Business.Service;
using System.Data.Common;
using TuFactory.CustAccount.Object;
using TuFactory.Profession;
using Domain.Entities;
using Services.Interfaces;
using Services;
using TuFactory.Domain.Enums;

public partial class CustAccount_Pool_CashTransaction : BasePage
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
    #endregion
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
        new_PaymentAmount.c1.Disabled = true;
        if (_IsPartlyCollection)
        {
            if (ValidationHelper.GetInteger(new_PaymentMethod.Value) == TransferCollectionMethodEnum.Single.GetHashCode())
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
        //const string script = "CheckAllControls();";
        //QScript(script);

    }
    void TranslateMessage()
    {
        //btnSave.Text = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_BTNPAYMENT");
        //btnKpsAps.Text = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_KPSAPSCHECK");
        RxM.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_PaymentMethod",
                                                                TuEntityEnum.New_Payment.GetHashCode());
        new_IdentityWasSeenReadOnly.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_IdentityWasSeen", TuEntityEnum.New_CustAccountOperations.GetHashCode());

        //pnlPayment.Title = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_ODEMEBILGILERI");
        //pnlAlici.Title = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_ALICIBILGILERI");
        //pnlKimlik.Title = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_KIMLIK_BILGILERI");

    }
    private void AddMessages()
    {
        var Messages = new
        {
            //NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM"),
            //NEW_CUSTACCOUNTOPERATION_SURE_REJECT = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_REJECT")
        };
        RegisterClientScriptBlock("DasMessages", string.Format("var DasMessages={0};", JsonConvert.SerializeObject(Messages)));
        const string strCustAccountTypeCodetemp = "var CustAccountType_{0} = \"{1}\";";
        var sb = new StringBuilder();


        foreach (var item in new TuFactory.CustAccount.Business.CustAccountOperations().GetCustAccountTypeList())
        {
            sb.AppendLine(string.Format(strCustAccountTypeCodetemp, item.Code, item.Id.ToLower()));
        }

        RegisterClientScriptBlock("strCustAccountTypeCodetemp", sb.ToString());
        sb.Clear();


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
      CrmLabel.TranslateAttributeLabelMessage("new_PaymentAmount", TuEntityEnum.New_CustAccountOperations.GetHashCode());

        var ufFactory = new TuUserFactory();
        _activeUser = ufFactory.GetActiveUser();
        new_CorporationId.Value = _activeUser.CorporationId.ToString();
        new_OfficeId.Value = _activeUser.OfficeId.ToString();

    }
    public bool isTuzelAccountType()
    {
        var tuzelid = string.Empty;
        var gercekid = string.Empty;
        foreach (var item in new TuFactory.CustAccount.Business.CustAccountOperations().GetCustAccountTypeList())
        {
            if (item.Code == "001")
                gercekid = item.Id.ToLower();
            if (item.Code == "002")
                tuzelid = item.Id.ToLower();
        }
        return new_CustAccountTypeId.Value == tuzelid;
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        isTuzel = isTuzelAccountType();
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
LEFT OUTER JOIN vnew_custaccountOperationType cao on cao.new_EXTCODE='003' and cao.DeletionStateCode=0
Where SystemUserId = @SystemUserId
")
                .Tables[0];

        if (dt.Rows.Count > 0)
        {

            _CountryCurrencyID = ValidationHelper.GetString(dt.Rows[0]["new_CurrencyID"]);
            _CountryCurrencyIDName = ValidationHelper.GetString(dt.Rows[0]["new_CurrencyIDName"]);
            _IsPartlyCollection = ValidationHelper.GetBoolean(dt.Rows[0]["new_IsPartlyCollection"]);
            new_CorporationId.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_CorporationID"]));
            new_CustAccountOperationTypeId.Value = ValidationHelper.GetString(dt.Rows[0]["CustAccountOperationTypeId"]);
            new_CorporationCountryId.Value = ValidationHelper.GetString(dt.Rows[0]["new_CountryID"]);
        }


        if (!_IsPartlyCollection)
        {
            RxM.Visible = false;
            new_PaidAmount2.Visible = false;
            l1.Visible = false;
            //new_PaidAmount1.Disabled = false;
            new_PaidAmount1.c1.Disabled = true;
            new_PaidAmount1.d1.Disabled = true;
            //new_PaidAmount1.SetDisabled(true);
        }

        if (!RefleX.IsAjxPostback)
        {
            RR.RegisterIcon(Icon.Add);
            AddMessages();
            TranslateMessage();
            PrepareItems();
            SetDefaults();
            //new_Amount.Items[1].SetDisabled(true);
            ReConfigureScreen();
            QScript("pageLoad();");
        }
        new_CalculatedExpenseAmount.Items[1].SetDisabled(true);
        setUserCostReductionRate();
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

    protected void CalculateOnEvent(object sender, AjaxEventArgs e)
    {

        ExpenseProcessor();
        var sd = new StaticData();

        try
        {

            var paymentmount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_PaymentAmount.d1).Value, 0);
            var paymentmountCurrency = ValidationHelper.GetGuid(((CrmComboComp)new_PaymentAmount.c1).Value);

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
            CustInfoFactory infoServ = new CustInfoFactory();
            var accountTypeCode = infoServ.GetCustAccountTypeCode(ValidationHelper.GetGuid(new_CustAccountTypeId.Value));
            int senderType = accountTypeCode == Object.CustAccountType.GERCEK ? (int)DepositThirdSenderTypeEnum.Own : (int)DepositThirdSenderTypeEnum.SenderPerson;
            var tpc = new TransactionOperations();
            var ret = tpc.Calculate(
                paymentmount,
                !isNewAmount ? new_CalculatedExpenseAmount.d1.Value : null,
                !isNewAmount ? ValidationHelper.GetGuid(new_CalculatedExpenseAmount.c1.Value) : Guid.Empty,
                ValidationHelper.GetGuid(new_CustAccountId.Value),
                ValidationHelper.GetGuid(new_SenderId.Value),
                ValidationHelper.GetGuid(new_CorporationId.Value),
                ValidationHelper.GetGuid(new_OfficeId.Value),
                ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value),
                changedObject,
                pamount,
                pamountCurrency,
                ValidationHelper.GetInteger(new_PaymentMethod.Value, 1),
                false,
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
                    new_PaymentAmount.Items[0].SetValue(ValidationHelper.GetDecimal(ret.paymentAmount, 0));
                    new_PaymentAmount.Items[1].SetValue(ValidationHelper.GetString(ret.paymentAmountCurrency));
                    new_CustTotalPayAmount.Items[0].SetValue(ret.custTotalPaymentAmount);
                    new_CustTotalPayAmount.Items[1].SetValue(ret.custTotalPaymentCurrency);
                    Parity1.Clear();
                    if (new_PaidAmount2.Visible)
                        Parity2.Clear();
                    Parity1.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaidParity1", TuEntityEnum.New_Payment.GetHashCode()) + ":&nbsp;&nbsp;" +
                     Math.Round(ValidationHelper.GetDecimal(ret.TransferPaidParity1, 0), 6).ToString());

                    if (new_PaidAmount2.Visible)
                    {
                        new_PaidAmount2.Items[0].SetValue(ret.PaidAmount2);
                        new_PaidAmount2.Items[1].SetValue(ret.PaidAmount2Currency.ToString());
                    }
                    if (new_PaidAmount2.Visible)
                        if (ret.PaidAmount2 > 0)
                            Parity2.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaidParity2", TuEntityEnum.New_Payment.GetHashCode()) + ":&nbsp;&nbsp;" +
                                Math.Round(ValidationHelper.GetDecimal(ret.TransferPaidParity2, 0), 6).ToString());

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
    private const string aboutblank = "about:blank";

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
        if (ValidationHelper.GetDecimal(new_PaymentAmount.d1.Value, 0) <= 0)
        {
            return false;
        }
        return true;
    }
    #region Private Events

    private void ShowRequiredFields(string myLabel)
    {
        var msg = CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED");
        var m = new MessageBox { Width = 400 };
        m.Show(string.Format(msg, myLabel));
        return;
    }

    #endregion

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
            var isRestricted = new TuFactory.CustAccount.Business.CustAccountOperations().IsRestrictedCustAccount(Object.TransactionTypeEnum.Cash, custAccountId);
            if (isRestricted)
            {
                new_CustAccountId.Clear();
                Upt.Alert(
                    string.Format(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_RESTRICTEDFORCASH"), new_CustAccountId.SelectedItems[0].VALUE)
                    );

                return;
            }
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

    private void ClearFieldsForCustAccountID()
    {
        new_PaymentAmount.c1.Clear();
        new_PaymentAmount.d1.Clear();
        new_ExpenseAmount.c1.Clear();
        new_ExpenseAmount.d1.Clear();
        new_CalculatedExpenseAmount.c1.Clear();
        new_CalculatedExpenseAmount.d1.Clear();
        new_PaidAmount1.c1.Clear();
        new_PaidAmount1.d1.Clear();
        new_PaidAmount2.c1.Clear();
        new_PaidAmount2.d1.Clear();
        new_PaymentMethod.Clear();
        new_CustTotalPayAmount.c1.Clear();
        new_CustTotalPayAmount.d1.Clear();
        new_TotalPayedAmount.c1.Clear();
        new_TotalPayedAmount.d1.Clear();
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
    private void SetCustAccountCurrencyId(Guid custAccountId)
    {
        var df = new DynamicFactory(ERunInUser.CalingUser);
        var de = df.RetrieveWithOutPlugin(TuEntityEnum.New_CustAccounts.GetHashCode(), custAccountId, new[] { "new_CustAccountCurrencyId", "new_Balance", "new_IsBlocked",
            "new_BlockedAmount", "new_BlockedStartDate", "new_BlockedEndDate",
            "new_BlockedType","new_SenderId", "new_CustAccountTypeId"  });
        var currency = de.GetLookupValue("new_CustAccountCurrencyId");
        var balance = TuFactory.CustAccount.Business.CustAccountOperations.GetActiveBalance(custAccountId);

        if (balance <= 0)
        {
            new_CustAccountId.Clear();
            Upt.Alert(
                string.Format(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_BALANCE_GREATER_THAN_ZERO"), new_CustAccountId.SelectedItems[0].VALUE)
                );

            return;
        }

        if (currency != Guid.Empty)
        {
            var sender = de.Properties["new_SenderId"] as Lookup;
            var custAccountTypeId = de.Properties["new_CustAccountTypeId"] as Lookup;

            new_CustAccountCurrencyId.SetValue(ValidationHelper.GetString(((Lookup)de["new_CustAccountCurrencyId"]).Value), ((Lookup)de["new_CustAccountCurrencyId"]).name);
            new_CustAccountCurrencyId.Value = ValidationHelper.GetString(currency);
            new_PaidAmount1.c1.Value = ValidationHelper.GetString(currency);
            new_PaidAmount1.c1.SetValue(ValidationHelper.GetString(((Lookup)de["new_CustAccountCurrencyId"]).Value), ((Lookup)de["new_CustAccountCurrencyId"]).name);
            new_PaymentAmount.c1.Value = ValidationHelper.GetString(currency);
            new_PaymentAmount.c1.SetValue(ValidationHelper.GetString(((Lookup)de["new_CustAccountCurrencyId"]).Value), ((Lookup)de["new_CustAccountCurrencyId"]).name);
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
            var custAccountType = UPT.Shared.CacheProvider.Service.CustAccountTypeService.GetCustAccountTypeByTypeId(ValidationHelper.GetGuid(new_CustAccountTypeId.Value));

            var professionDb = new ProfessionDb();
            if (!professionDb.ExistsSenderProfessionInfo(ValidationHelper.GetGuid(new_SenderId.Value)) && custAccountType != null && custAccountType.ExtCode == "001")
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

    protected void SenderOtpCheck(object sender, AjaxEventArgs e)
    {
        QScript("Screen2_Next();");

        if (!string.IsNullOrEmpty(new_SenderId.Value))
        {
            var custAccountType = UPT.Shared.CacheProvider.Service.CustAccountTypeService.GetCustAccountTypeByTypeId(ValidationHelper.GetGuid(new_CustAccountTypeId.Value));

            QScript(string.Format("ShowOtpContolPanel('{0}','{1}','{2}','{3}');", new_SenderId.Value, new_SenderPersonId.Value, custAccountType.ExtCode, "OTP Giriş Ekranı"));
            return;

        }
    }
    protected void new_SenderId_OnChange(object sender, AjaxEventArgs e)
    {
        var senderId = ValidationHelper.GetGuid(new_SenderId.Value);

        if (!string.IsNullOrEmpty(new_SenderId.Value))
        {
            var custAccountType = UPT.Shared.CacheProvider.Service.CustAccountTypeService.GetCustAccountTypeByTypeId(ValidationHelper.GetGuid(new_CustAccountTypeId.Value));

            var professionDb = new ProfessionDb();
            if (!professionDb.ExistsSenderProfessionInfo(ValidationHelper.GetGuid(senderId)) && custAccountType != null && custAccountType.ExtCode == "001")
            {
                QScript(string.Format("ShowProfession('{0}','{1}');", new_SenderId.Value, CrmLabel.TranslateMessage("CRM.NEW_PROFESSION_CONTROL_FORM")));
            }
        }

        if (senderId != Guid.Empty)
        {
            var df = new DynamicFactory(ERunInUser.SystemAdmin);
            var desender = df.RetrieveWithOutPlugin(TuEntityEnum.New_Sender.GetHashCode(), senderId, new[] { "new_CustAccountTypeId" });
            var CustAccountTypeId = desender.GetLookupValue("new_CustAccountTypeId");

            if (CustAccountTypeId != ValidationHelper.GetGuid(new_CustAccountTypeId.Value))
            {
                new_CustAccountTypeId.Value = CustAccountTypeId.ToString();
                new_CustAccountTypeId.SetValue(((Lookup)desender["new_CustAccountTypeId"]).Value.ToString(), ((Lookup)desender["new_CustAccountTypeId"]).name);
                isTuzel = isTuzelAccountType();
            }

        }
        else
        {
            new_CustAccountId.Clear();
            new_CustAccountCurrencyId.Clear();
            new_CustAccountBalance.Clear();
            CustAccountIdDetail.AutoLoad.Url = aboutblank;
            CustAccountIdDetail.LoadUrl(CustAccountIdDetail.AutoLoad.Url);
            SenderDetail.AutoLoad.Url = aboutblank;
            SenderDetail.LoadUrl(SenderDetail.AutoLoad.Url);
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
    protected void new_SenderPersonId_OnChange(object sender, AjaxEventArgs e)
    {
        var senderPersonId = ValidationHelper.GetGuid(new_SenderPersonId.Value);
        var ms = new MessageBox { Modal = true };

        if (senderPersonId != Guid.Empty)
        {
            var readonlyRealform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_PERSON_FORM"));
            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid",  readonlyRealform},
                                {"ObjectId",( (int)TuEntityEnum.New_SenderPerson).ToString()},
                                {"recid", senderPersonId .ToString()},
                                {"mode", "-1"}
                            };
            var urlparam = QueryHelper.RefreshUrl(query);
            SenderPersonDetail.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            SenderPersonDetail.LoadUrl(SenderPersonDetail.AutoLoad.Url);
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

    void SetCollectionMethod(object sender, AjaxEventArgs e)
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
    }
    protected void new_PaidAmount1CurrencyOnChange(object sender, AjaxEventArgs e)
    {
        SetCollectionMethod(sender, e);
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

    protected void new_PaymentAmount_OnChange(object sender, AjaxEventArgs e)
    {
        setUserCostReductionRate();
        //CorporationCountryFormParameterForDisplayControl();
        //ReConfigureScreen2();
        if (((Coretech.Crm.Web.UI.RefleX.AutoGenerate.CrmDecimalComp)sender).UniqueName != "new_PaymentAmount")
        {
            isNewAmount = false;
            sender = this.new_PaymentAmount.d1;
        }
        else
        {
            isNewAmount = true;
            RebuildExpenseProcess(Guid.Empty, null);
        }
        if (new_PaidAmount1.c1.Value == string.Empty)
        {
            new_PaidAmount1.c1.Value = GetDefaultReceivedAmount1Currency();
            if (_IsPartlyCollection)
            {
                if (new_PaidAmount1.c1.Value == _CountryCurrencyID)
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
        }
        if (ValidationHelper.GetInteger(new_PaymentMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        {
            new_CollectionMethodOnChange(sender, e);
        }
        else
        {
            CalculateOnEvent(sender, e);
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

    protected void RebuildExpenseProcess(Guid custAccountOperationsId, DbTransaction transaction)
    {
        resetExpenseProcess();
        setUserCostReductionRate();
        string changedObject;
        var sd = new StaticData();

        try
        {

            if (!CheckCalculation())
                return;
            var paymentmount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_PaymentAmount.d1).Value, 0);
            var pamount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_PaidAmount1.d1).Value, 0);
            var pamountCurrency = ValidationHelper.GetGuid(((CrmComboComp)new_PaidAmount1.c1).Value);
            var tpc = new TransactionOperations();
            CustInfoFactory infoServ = new CustInfoFactory();
            var accountTypeCode = infoServ.GetCustAccountTypeCode(ValidationHelper.GetGuid(new_CustAccountTypeId.Value));
            int senderType = accountTypeCode == Object.CustAccountType.GERCEK ? (int)DepositThirdSenderTypeEnum.Own : (int)DepositThirdSenderTypeEnum.SenderPerson;
            if (custAccountOperationsId != Guid.Empty)
            {
                changedObject = new_PaidAmount1.d1.UniqueName;
            }
            else
            {
                changedObject = new_PaymentAmount.d1.UniqueName;
            }
            var retcalc = tpc.Calculate(
                paymentmount
                , !isNewAmount ? new_CalculatedExpenseAmount.d1.Value : null
                , !isNewAmount ? ValidationHelper.GetGuid(new_CalculatedExpenseAmount.c1.Value) : Guid.Empty
                , ValidationHelper.GetGuid(new_CustAccountId.Value),
                ValidationHelper.GetGuid(new_SenderId.Value),
                ValidationHelper.GetGuid(new_CorporationId.Value),
                ValidationHelper.GetGuid(new_OfficeId.Value),
                ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value),
                changedObject,
                pamount,
                pamountCurrency,
                ValidationHelper.GetInteger(new_PaymentMethod.Value, 1),
                false,
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
                    new_PaymentAmount.Items[0].SetValue(ValidationHelper.GetDecimal(retcalc.paymentAmount, 0));
                    new_PaymentAmount.Items[1].SetValue(ValidationHelper.GetString(retcalc.paymentAmountCurrency));
                    new_CustTotalPayAmount.Items[0].SetValue(retcalc.custTotalPaymentAmount);
                    new_CustTotalPayAmount.Items[1].SetValue(retcalc.custTotalPaymentCurrency);
                    Parity1.Clear();
                    if (new_PaidAmount2.Visible)
                        Parity2.Clear();
                    Parity1.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaidParity1", TuEntityEnum.New_Payment.GetHashCode()) + ":&nbsp;&nbsp;" +
                     Math.Round(ValidationHelper.GetDecimal(retcalc.TransferPaidParity1, 0), 6).ToString());

                    if (new_PaidAmount2.Visible)
                    {
                        new_PaidAmount2.Items[0].SetValue(retcalc.PaidAmount2);
                        new_PaidAmount2.Items[1].SetValue(retcalc.PaidAmount2Currency.ToString());
                    }
                    if (new_PaidAmount2.Visible)
                        if (retcalc.PaidAmount2 > 0)
                            Parity2.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_TransferPaidParity2", TuEntityEnum.New_Payment.GetHashCode()) + ":&nbsp;&nbsp;" +
                                Math.Round(ValidationHelper.GetDecimal(retcalc.TransferPaidParity2, 0), 6).ToString());

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

    public string GetDefaultReceivedAmount1Currency()
    {
        const string sql = @"
		IF EXISTS ( SELECT vncc.new_CurrencyId  FROM vNew_CountryCurrency vncc LEFT OUTER JOIN vNew_Country vnc ON vnc.New_CountryId=vncc.new_CountryId WHERE vnc.new_CountryShortCode='TR' AND vnc.DeletionStateCode=0 AND vncc.DeletionStateCode=0 AND vncc.new_CurrencyId  =@AmountCurrency )
		BEGIN
			select @AmountCurrency
		END
		ELSE
		BEGIN
			SELECT TOP 1 vncc.new_CurrencyId  FROM vNew_CountryCurrency vncc LEFT OUTER JOIN vNew_Country vnc ON vnc.New_CountryId=vncc.new_CountryId WHERE vnc.new_CountryShortCode='TR' AND vnc.DeletionStateCode=0 AND vncc.DeletionStateCode=0 
		END";
        var staticData = new StaticData();
        //staticData.AddParameter("OfficeId", DbType.Guid, ValidationHelper.GetGuid(new_OfficeId.Value));
        //staticData.AddParameter("TransactionTypeID", DbType.Guid, ValidationHelper.GetGuid(new_TargetTransactionTypeID.Value));
        staticData.AddParameter("AmountCurrency", DbType.Guid, ValidationHelper.GetGuid(new_CustAccountCurrencyId.Value));
        var receivedAmount1Currency = ValidationHelper.GetString(staticData.ExecuteScalar(sql));
        return receivedAmount1Currency;
    }

    CashWithdrawalItem GetCashWithdrawalItem()
    {
        CashWithdrawalItem cashWithdrawalItem = new CashWithdrawalItem();

        cashWithdrawalItem.CustAccountOperationType = new Domain.Entities.CustAccountOperationType()
        {
            CustAccountOperationTypeId = ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value)
        };

        cashWithdrawalItem.Sender = new Sender()
        {
            SenderId = ValidationHelper.GetGuid(new_SenderId.Value)
        };

        cashWithdrawalItem.CustAccountType = new Domain.Entities.CustAccountType()
        {
            CustAccountTypeId = ValidationHelper.GetGuid(new_CustAccountTypeId.Value)
        };

        cashWithdrawalItem.CustAccountCurrency = new Currency()
        {
            CurrencyId = ValidationHelper.GetGuid(new_CustAccountCurrencyId.Value)
        };

        cashWithdrawalItem.Corporation = new Corporation()
        {
            CorporationId = ValidationHelper.GetGuid(new_CorporationId.Value)
        };

        cashWithdrawalItem.Office = new Office()
        {
            OfficeId = ValidationHelper.GetGuid(new_OfficeId.Value)
        };


        cashWithdrawalItem.CustAccount = new Domain.Entities.CustAccount()
        {
            CustAccountId = ValidationHelper.GetGuid(new_CustAccountId.Value)
        };

        cashWithdrawalItem.OperationDescription = ValidationHelper.GetString(new_OperationDescription.Value);
        cashWithdrawalItem.PaymentMethod = 1;

        if (new_CustTotalPayAmount.d1.Value != null)
        {
            cashWithdrawalItem.CustTotalPayAmount = new TransactionAmount()
            {
                Amount = new_CustTotalPayAmount.d1.Value.Value,
                AmountCurrency = new Currency
                {
                    CurrencyId = ValidationHelper.GetGuid(new_CustTotalPayAmount.c1.Value)
                }
            };
        }
        if (new_PaymentAmount.d1.Value != null)
        {
            cashWithdrawalItem.PaymentAmount = new TransactionAmount()
            {
                Amount = new_PaymentAmount.d1.Value.Value,
                AmountCurrency = new Currency
                {
                    CurrencyId = ValidationHelper.GetGuid(new_PaymentAmount.c1.Value)
                }
            };
        }

        if (new_PaidAmount1.d1.Value != null)
        {
            cashWithdrawalItem.PaidAmount1 = new TransactionAmount()
            {
                Amount = new_PaidAmount1.d1.Value.Value,
                AmountCurrency = new Currency
                {
                    CurrencyId = ValidationHelper.GetGuid(new_PaidAmount1.c1.Value)
                }
            };
        }

        if (new_PaidAmount2.d1.Value != null)
        {
            cashWithdrawalItem.PaidAmount2 = new TransactionAmount()
            {
                Amount = new_PaidAmount2.d1.Value.Value,
                AmountCurrency = new Currency
                {
                    CurrencyId = ValidationHelper.GetGuid(new_PaidAmount2.c1.Value)
                }
            };
        }

        cashWithdrawalItem.SenderIdentificationCardType = new IdentificatonCardType()
        {
            New_IdentificatonCardTypeId = ValidationHelper.GetGuid(new_SenderIdentificationCardTypeID.Value)
        };

        cashWithdrawalItem.IdentityWasSeen = ValidationHelper.GetBoolean(new_IdentityWasSeen.Value);
        cashWithdrawalItem.SenderIdentificationCardNo = ValidationHelper.GetString(new_SenderIdentificationCardNo.Value);
        cashWithdrawalItem.IsTuzel = isTuzel;

        if (new_SenderPersonId.Value != null)
        {
            cashWithdrawalItem.SenderPerson = new SenderPerson
            {
                SenderPersonId = ValidationHelper.GetGuid(new_SenderPersonId.Value)
            };

        }


        CalculateWithdrawalRequest calculateWithdrawalRequest = new CalculateWithdrawalRequest();
        calculateWithdrawalRequest.Amount = new TransactionAmount()
        {
            Amount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_PaymentAmount.d1).Value, 0)
        };

        if (!isNewAmount)
        {
            calculateWithdrawalRequest.CustomExpense = new TransactionAmount()
            {
                Amount = new_CalculatedExpenseAmount.d1.Value.Value,
                AmountCurrency = new Currency()
                {
                    CurrencyId = ValidationHelper.GetGuid(new_CalculatedExpenseAmount.c1.Value)
                }
            };
        }

        calculateWithdrawalRequest.CustAccount = new Domain.Entities.CustAccount()
        {
            CustAccountId = ValidationHelper.GetGuid(new_CustAccountId.Value)
        };

        calculateWithdrawalRequest.Corporation = new Corporation()
        {
            CorporationId = ValidationHelper.GetGuid(new_CorporationId.Value)
        };

        calculateWithdrawalRequest.Office = new Office()
        {
            OfficeId = ValidationHelper.GetGuid(new_OfficeId.Value)
        };

        calculateWithdrawalRequest.CustAccountOperationTypeId = ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value);
        calculateWithdrawalRequest.CustAccountOperationId = cashWithdrawalItem.CustAccountOperationId;

        string changedObject = string.Empty;
        if (calculateWithdrawalRequest.CustAccountOperationId != Guid.Empty)
        {
            changedObject = new_PaidAmount1.d1.UniqueName;
        }
        else
        {
            changedObject = new_PaymentAmount.d1.UniqueName;
        }
        calculateWithdrawalRequest.ChangedObject = changedObject;
        calculateWithdrawalRequest.AttributeName = changedObject;

        calculateWithdrawalRequest.AttributeAmount = new TransactionAmount()
        {
            Amount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_PaidAmount1.d1).Value, 0),
            AmountCurrency = new Currency()
            {
                CurrencyId = ValidationHelper.GetGuid(((CrmComboComp)new_PaidAmount1.c1).Value)
            }
        };

        calculateWithdrawalRequest.PaymentMethod = ValidationHelper.GetInteger(new_PaymentMethod.Value, 1);
        calculateWithdrawalRequest.CheckPowerOfCollection = false;

        CustInfoFactory infoServ = new CustInfoFactory();
        var accountTypeCode = infoServ.GetCustAccountTypeCode(ValidationHelper.GetGuid(new_CustAccountTypeId.Value));
        int senderType = accountTypeCode == Object.CustAccountType.GERCEK ? (int)DepositThirdSenderTypeEnum.Own : (int)DepositThirdSenderTypeEnum.SenderPerson;
        calculateWithdrawalRequest.SenderType = senderType;

        calculateWithdrawalRequest.Sender = new Sender()
        {
            SenderId = ValidationHelper.GetGuid(cashWithdrawalItem.Sender.SenderId)
        };

        cashWithdrawalItem.Calculate = calculateWithdrawalRequest;

        return cashWithdrawalItem;
    }

    protected void btnFinishOnClickEvent2(object sender, AjaxEventArgs e)
    {
        try
        {
            ICustAccountOperationService<object> _service = new CashWithdrawalService<object>();
            ICustAccountItem cashDepositItem = GetCashWithdrawalItem();
            var response = _service.Request(cashDepositItem);

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

            if ((string)response.ServiceResponse == Object.CustAccountStatus.HesaptanNakitCekmeDekontBasilacak)
            {
                Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_MUSTRECIPMENT"));
                Response.Redirect("CustAccountRouter.aspx?recid=" + cashDepositItem.CustAccountOperationId);
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "CustAccount_Pool_CashTransaction");
            Alert(ex.Message);
            BasePage.QScript("RefreshParetnGrid(true);");
        }
    }

    protected void btnFinishOnClickEvent(object sender, AjaxEventArgs e)
    {
        if (ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("WORK_WITH_THE_NEW_CUSTACCOUNT_SERVICE")))
        {
            btnFinishOnClickEvent2(sender, e);
            return;
        }

        #region otp control
        if (ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("TRANSFER_OTP_IS_ACTIVE"), false))
        {
            if (!ValidationHelper.GetBoolean(new_IsOtpConfirm.Value))
            {
                var m = new MessageBox { Width = 400, Height = 300 };
                string requiredmsg = "Gönderici Otp Kontrolü zorunludur. Lütfen Otp kontrolü yapınız.";
                m.Show(requiredmsg);
                return;
            }
        }
        #endregion


        #region AgeControl
        var msg = new MessageBox();
        TuFactory.CustAccount.Business.CustAccountOperations custOp = new TuFactory.CustAccount.Business.CustAccountOperations();
        if (!isTuzel)
        {
            bool isAdult = custOp.IsSenderAdult(ValidationHelper.GetGuid(new_SenderId.Value));
            if (isAdult == false)
            {
                msg.Show(String.Format(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDER_ERRORBIRTHDATE"), 18));
                return;
            }
        }
        else
        {
            bool isAdult = custOp.IsSenderPersonAdult(ValidationHelper.GetGuid(new_SenderPersonId.Value));
            if (isAdult == false)
            {
                msg.Show(String.Format(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDER_ERRORBIRTHDATE"), 18));
                return;
            }
        }
        #endregion

        StaticData sd = new StaticData();
        var tr = sd.GetDbTransaction();
        DynamicFactory df = new DynamicFactory(ERunInUser.CalingUser);
        df.GetBeginTrans(tr);
        var id = Guid.Empty;
        DynamicEntity de = new DynamicEntity(TuEntityEnum.New_CustAccountOperations.GetHashCode());
        try
        {

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
                de.AddStringProperty("new_OperationDescription", ValidationHelper.GetString(new_OperationDescription.Value));
            }


            if (new_CustTotalPayAmount.d1.Value != null)
            {
                de.AddMoneyProperty("new_CustTotalPayAmount", new_CustTotalPayAmount.d1.Value.Value,
                    new Lookup("new_CustTotalPayAmountCurrency", ValidationHelper.GetGuid(new_CustTotalPayAmount.c1.Value)));

            }
            if (new_PaymentAmount.d1.Value != null)
            {
                de.AddMoneyProperty("new_PaymentAmount", new_PaymentAmount.d1.Value.Value,
                    new Lookup("new_PaymentAmountCurrency", ValidationHelper.GetGuid(new_PaymentAmount.c1.Value)));
            }

            if (new_PaidAmount1.d1.Value != null)
            {
                de.AddMoneyProperty("new_PaidAmount1", new_PaidAmount1.d1.Value.Value,
                    new Lookup("new_PaidAmount1Currency", ValidationHelper.GetGuid(new_PaidAmount1.c1.Value)));
            }

            if (new_PaidAmount2.d1.Value != null)
            {
                de.AddMoneyProperty("new_PaidAmount2", new_PaidAmount2.d1.Value.Value,
                    new Lookup("new_PaidAmount2Currency", ValidationHelper.GetGuid(new_PaidAmount2.c1.Value)));
            }




            de.AddLookupProperty("new_SenderIdentificationCardTypeID", "",
                ValidationHelper.GetGuid(new_SenderIdentificationCardTypeID.Value));
            de.AddBooleanProperty("new_IdentityWasSeen", ValidationHelper.GetBoolean(new_IdentityWasSeen.Value));
            de.AddStringProperty("new_SenderIdentificationCardNo",
                ValidationHelper.GetString(new_SenderIdentificationCardNo.Value));
            if (isTuzel)
                de.AddLookupProperty("new_SenderPersonId", "", ValidationHelper.GetGuid(new_SenderPersonId.Value));

            id = df.Create(TuEntityEnum.New_CustAccountOperations.GetHashCode(), de);

            if (string.IsNullOrEmpty(new_OperationDescription.Value))
            {
                string operationDescription = string.Format("Nakit Çekme  - {0}", de.GetStringValue("CustAccountOperationName"));
                de.AddStringProperty("new_OperationDescription", operationDescription);

                df.Update(TuEntityEnum.New_CustAccountOperations.GetHashCode(), de);
            }

            #region CheckForParameters
            sd.AddParameter("CustAccountOperationsId", DbType.Guid, id);
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            var ret = ValidationHelper.GetString(sd.ExecuteScalarSp("SpTuCustAccountCashCreateCheck", tr));
            if (!string.IsNullOrEmpty(ret))
            {
                id = Guid.Empty;
                throw new TuException(ValidationHelper.GetString(ret), "CUST001");
            }
            #endregion

            var paymentmount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_PaymentAmount.d1).Value, 0);
            var pamount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_PaidAmount1.d1).Value, 0);
            var pamountCurrency = ValidationHelper.GetGuid(((CrmComboComp)new_PaidAmount1.c1).Value);

            RebuildExpenseProcess(id, tr);
            //Muhasebe Bakiyesi Yeterli mi?
            TransactionOperations top = new TransactionOperations();
            top.Save(id, 7, false, true, tr);

            StaticData.Commit(tr);

        }
        catch (CrmException exc)
        {
            StaticData.Rollback(tr);
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
            msg.Show(exc.Message);
            return;
        }

        //CustAccount.Business.
        if (id != Guid.Empty)
        {

            sd.AddParameter("CustAccountOperationsId", DbType.Guid, id);
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            var ret1 = ValidationHelper.GetString(sd.ExecuteScalarSp("SpTuCustAccountCashPrepare"));
            if (!string.IsNullOrEmpty(ret1))
            {
                ValidationHelper.GetString(ret1);
            }
            try
            {

                CustAccountApprovePoolService approvePoolService = new CustAccountApprovePoolService();
                Object.CustAccountApprovePoolResponse approvePoolResponse = approvePoolService.ApproveStageProcess(id);
                if (!approvePoolResponse.result)
                {
                    BasePage.QScript("btnFinis.hide();");
                    Alert(approvePoolResponse.message);
                    BasePage.QScript("RefreshParetnGrid(true);");
                    return;
                }

                ConfirmFactory amlFraudService = new ConfirmFactory();
                var amlFraudResponse = amlFraudService.AmlFraudProcess(id);
                if (!amlFraudResponse.result)
                {
                    BasePage.QScript("btnFinis.hide();");
                    Alert(amlFraudResponse.message);
                    BasePage.QScript("RefreshParetnGrid(true);");
                }
                var cs = new TuFactory.CustAccount.Business.CustAccountOperations().GetCustAccountConfirmStatus(id);
                if (cs == Object.CustAccountStatus.HesaptanNakitCekmeDekontBasilacak)
                {
                    Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_MUSTRECIPMENT"));
                    Response.Redirect("CustAccountRouter.aspx?recid=" + id);
                }
            }
            catch (TuException exc)
            {
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
    #endregion

    protected void new_CountryIdentificationTypeLoad(object sender, AjaxEventArgs e)
    {


        var dft = new DynamicFactory(ERunInUser.CalingUser);
        DynamicEntity trt = new DynamicEntity();
        if (!isTuzel)
        {
            trt = dft.RetrieveWithOutPlugin(TuEntityEnum.New_Sender.GetHashCode(), ValidationHelper.GetGuid(new_SenderId.Value), new string[] { "new_NationalityID" });
        }
        else
        {
            trt = dft.RetrieveWithOutPlugin(TuEntityEnum.New_SenderPerson.GetHashCode(), ValidationHelper.GetGuid(new_SenderPersonId.Value), new string[] { "new_NationalityID" });
        }
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

    #endregion
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
