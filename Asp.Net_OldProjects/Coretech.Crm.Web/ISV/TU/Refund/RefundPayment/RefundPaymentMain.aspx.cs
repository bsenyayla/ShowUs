using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.Refund;
using Coretech.Crm.Data.Crm.Dynamic;
using System.Web.Security.AntiXss;

public partial class Refund_RefundPaymentMain : BasePage
{
    private string _CountryCurrencyID;
    private string _CountryCurrencyIDName;
    private bool _IsPartlyCollection = false; //Bu kurumda parcalı tahsilat kullanılır.

    void TranslateMessage()
    {
        //QScript(string.Format("var dugmemesaj = {0};", CrmLabel.TranslateMessage("CRM.NEW_REFUNDPAYMENT_ISIDENTITYSHOW")));
        isIdentityShowMessage.Value = CrmLabel.TranslateMessage("CRM.NEW_REFUNDPAYMENT_ISIDENTITYSHOW");
        btnSave.Text = CrmLabel.TranslateMessage("CRM.NEW_REFUNDPAYMENT_ISLEMI_TAMAMLA");
        IFRAME_SENDER.Title = CrmLabel.TranslateMessage("CRM.NEW_REFUNDPAYMENT_GONDERICIBILGILERI");

        RxM.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_RefundMethod",
                                                                TuEntityEnum.New_RefundPayment.GetHashCode());
        pnlPayment.Title = CrmLabel.TranslateMessage("CRM.NEW_REFUNDPAYMENT_ODEMEBILGILERI");
        pnlKimlik.Title = CrmLabel.TranslateMessage("CRM.NEW_REFUNDPAYMENT_GONDERICIKIMLIK");
        PnlAlici.Title = CrmLabel.TranslateMessage("CRM.NEW_REFUNDPAYMENT_ALICI");
        GetMessage();
    }

    void GetMessage()
    {
        var staticData = new StaticData();
        staticData.AddParameter("OperationType", DbType.Int32, 4);
        staticData.AddParameter("systemuserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        TuLabelMessage.Text = ValidationHelper.GetString(
                staticData.ExecuteScalar("EXEC spGetCountryTransferMessages @OperationType,@systemuserId"));
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.Url.ToString().Contains("'") || Request.Url.ToString().Contains("script") || Request.Url.ToString().Contains("alert"))
        {
            Response.Redirect(App.Params.GetConfigKeyValue("logouturl", "~/login.aspx"));
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

            new_CountryId.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_CountryID"]));
            new_RefundByCorporation.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_CorporationID"]));
            new_RefundByOffice.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_OfficeID"]));
            _CountryCurrencyID = ValidationHelper.GetString(dt.Rows[0]["new_CurrencyID"]);
            _CountryCurrencyIDName = ValidationHelper.GetString(dt.Rows[0]["new_CurrencyIDName"]);
            _IsPartlyCollection = ValidationHelper.GetBoolean(dt.Rows[0]["new_IsPartlyCollection"]);
        }


        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
            //FieldsetReason.Visible = false;
            New_RefundPaymentId.Value = QueryHelper.GetString("recid");


            LoadData();
            ReConfigureScreen();
        }
    }

    protected void LoadData()
    {
        var df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };
        var py = df.Retrieve(TuEntityEnum.New_RefundPayment.GetHashCode(),
                                          ValidationHelper.GetGuid(New_RefundPaymentId.Value),
                                          DynamicFactory.RetrieveAllColumns);

        new_SenderId.FillDynamicEntityData(py);
        new_RefundAmount.FillDynamicEntityData(py);
        new_RefundExpenseAmount.FillDynamicEntityData(py);
        decimal refundExpenseAmount = py.GetMoneyValue("new_RefundExpenseAmount");
        if (refundExpenseAmount == 0)
        {
            new_RefundExpenseAmount.d1.Value = 0;
            new_RefundExpenseAmount.c1.SetValue(_CountryCurrencyID, _CountryCurrencyIDName);
        }
        new_RefundMethod.FillDynamicEntityData(py);
        new_RefundPaymentAmount.FillDynamicEntityData(py);
        new_RefundPaymentAmount2.d1.Value = 0;
        new_RefundPaymentAmount2.c1.SetValue(_CountryCurrencyID, _CountryCurrencyIDName);
        new_RefundPaymentAmount2.FillDynamicEntityData(py);
        new_RefundCost.FillDynamicEntityData(py);
        if (!(ValidationHelper.GetDecimal(new_RefundCost.c1.Value, 0) > 0))
        {
            new_RefundCost.SetVisible(false);
        }

        new_TransferId.FillDynamicEntityData(py);

        new_RrecipientName.FillDynamicEntityData(py);
        new_SenderIdentificationCardTypeID.FillDynamicEntityData(py);

        new_SenderIdentificationCardNo.FillDynamicEntityData(py);
        new_IdentityChecked.FillDynamicEntityData(py);

        if (ValidationHelper.GetInteger(new_RefundMethod.Value) == TransferCollectionMethodEnum.Single.GetHashCode())
        {
            new_RefundPaymentAmount.Items[0].SetDisabled(true);
        }
        else
        {
            new_RefundPaymentAmount.Items[0].SetDisabled(false);
        }

        List<Guid> paymentCurrencies = GetPaymentCurrencies();
        if (!paymentCurrencies.Exists(c => c == ValidationHelper.GetGuid(new_RefundPaymentAmount.c1.Value)))
        {
            new_RefundPaymentAmount.c1.Clear();
            new_RefundPaymentAmount.d1.Clear();
            new_RefundPaymentAmount.d1.Value = 0;

            if (_IsPartlyCollection)
            {
                new_RefundPaymentAmount2.c1.Clear();
                new_RefundPaymentAmount2.d1.Clear();
                new_RefundPaymentAmount2.d1.Value = 0;
            }
        }

        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        new_RrecipientName.SetValue(cryptor.DecryptInString(new_RrecipientName.Value));


        const string readonlyform = "00000020-d33b-4a0e-a166-5f6b4ec8e699";
        var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyform},
                                {"ObjectId", TuEntityEnum.New_Sender.GetHashCode().ToString()},
                                {"recid", py.GetLookupValue("new_SenderId").ToString()},
                                {"mode","-1"}
                            };
        var redirecturl =
            ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx");
        redirecturl = redirecturl + QueryHelper.RefreshUrl(query);
        BasePage.QScript("IFRAME_SENDER.load('" + redirecturl + "');");

        Parity1.Clear();
        if (new_RefundPaymentAmount.d1.Value > 0)
        {
            Parity1.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_RefundPaymentCurrencyParity", TuEntityEnum.New_RefundPayment.GetHashCode()) + ":&nbsp;&nbsp;" +
                        Math.Round(((CrmDecimal)py["new_RefundPaymentCurrencyParity"]).Value, 6).ToString());
        }
        if (_IsPartlyCollection)
        {
            Parity2.Clear();
            if (new_RefundPaymentAmount2.d1.Value > 0)
            {
                Parity2.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_RefundPayment2CurrencyParity", TuEntityEnum.New_RefundPayment.GetHashCode()) + ":&nbsp;&nbsp;" +
                                Math.Round(((CrmDecimal)py["new_RefundPayment2CurrencyParity"]).Value, 6).ToString());
            }
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

    void ReConfigureScreen()
    {
        var sd = new StaticData();
        sd.ClearParameters();
        new_RefundPaymentAmount2.Disabled = true;
        RxM.Disabled = true;
        //var amount = ValidationHelper.GetDBDecimal(((CrmDecimalComp)new_Amount.Items[0]).Value);
        if (!_IsPartlyCollection)
        {
            //RxM.Visible = false;
            //new_RefundPaymentAmount2.Visible = false;
            //l1.Visible = false;
        }
        else
        {
            new_RefundPaymentAmount2.Disabled = false;
            new_RefundMethod.Disabled = false;
            if (string.IsNullOrEmpty(New_RefundPaymentId.Value) || ValidationHelper.GetInteger(new_RefundMethod.Value) == TransferCollectionMethodEnum.Single.GetHashCode())
            {
                new_RefundPaymentAmount2.c1.SetValue(_CountryCurrencyID, _CountryCurrencyIDName);
                new_RefundPaymentAmount2.SetVisible(false);
                new_RefundPaymentAmount2.Items[0].SetVisible(false);


            }
        }

        //  const string script = "CheckAllControls();";
        // QScript(script);

    }
    protected void new_RefundMethodOnChange(object sender, AjaxEventArgs e)
    {
        if (ValidationHelper.GetInteger(new_RefundMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        {

            new_RefundPaymentAmount2.SetVisible(true);
            new_RefundPaymentAmount2.Items[0].SetVisible(true);

            new_RefundPaymentAmount.Items[0].SetDisabled(false);
            new_RefundPaymentAmount.Items[0].Clear();
            new_RefundPaymentAmount2.Items[0].Clear();
            new_RefundPaymentAmount.d1.Value = 0;
            new_RefundPaymentAmount2.d1.Value = 0;
        }
        else
        {
            new_RefundPaymentAmount2.SetVisible(false);
            new_RefundPaymentAmount2.Items[0].SetVisible(false);
            new_RefundPaymentAmount.Items[0].SetDisabled(true);
            new_RefundPaymentAmount.Items[0].Clear();
            new_RefundPaymentAmount2.Items[0].Clear();
        }
        CalculateOnEvent(sender, e);

    }
    protected void new_RefundPaymentAmountCurrencyOnChange(object sender, AjaxEventArgs e)
    {
        if (_IsPartlyCollection)
        {
            if (((CrmComboComp)new_RefundPaymentAmount.Items[1]).Value == _CountryCurrencyID)
            {
                new_RefundMethod.Value = TransferCollectionMethodEnum.Single.GetHashCode().ToString();
                new_RefundMethod.SetValue(TransferCollectionMethodEnum.Single.GetHashCode().ToString());
            }
            else
            {

                new_RefundMethod.SetValue(TransferCollectionMethodEnum.Multiple.GetHashCode().ToString());
                new_RefundMethod.Value = TransferCollectionMethodEnum.Multiple.GetHashCode().ToString();
            }
            new_CollectionMethodOnChange(sender, e);
        }
        else
        {
            CalculateOnEvent(sender, e);
        }


        //if (ValidationHelper.GetInteger(new_RefundMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        //{
        //    new_RefundMethodOnChange(sender, e);
        //}
        //else
        //{
        //    CalculateOnEvent(sender, e);
        //}
    }

    public void ReconfigureByCollectionMethod()
    {
        if (ValidationHelper.GetInteger(new_RefundMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        {
            new_RefundPaymentAmount2.SetVisible(true);
            new_RefundPaymentAmount.Items[0].SetDisabled(false);

        }
        else
        {
            new_RefundPaymentAmount2.SetVisible(false);
            new_RefundPaymentAmount.Items[0].SetDisabled(true);

        }

    }
    protected void new_CollectionMethodOnChange(object sender, AjaxEventArgs e)
    {
        ReconfigureByCollectionMethod();
        if (ValidationHelper.GetInteger(new_RefundMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        {
            new_RefundPaymentAmount.Items[0].Clear();
            new_RefundPaymentAmount2.Items[0].Clear();
            new_RefundPaymentAmount.d1.Value = 0;
            new_RefundPaymentAmount2.d1.Value = 0;
        }
        else
        {
            new_RefundPaymentAmount.Items[0].Clear();
            new_RefundPaymentAmount2.Items[0].Clear();
        }

        CalculateOnEvent(sender, e);

    }
    protected void CalculateOnEvent(object sender, AjaxEventArgs e)
    {
        var sd = new StaticData();

        try
        {
            var pamount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_RefundPaymentAmount.Items[0]).Value, 0);
            var pamountCurrency = ValidationHelper.GetGuid(((CrmComboComp)new_RefundPaymentAmount.Items[1]).Value);
            if (!CheckCalculation())
                return;
            var changedObject = string.Empty;
            if (sender.GetType() == typeof(CrmDecimalComp))
                changedObject = ((CrmDecimalComp)(sender)).UniqueName;
            if (sender.GetType() == typeof(CrmComboComp))
                changedObject = ((CrmComboComp)(sender)).UniqueName;
            if (sender.GetType() == typeof(CrmPicklistComp))
                changedObject = ((CrmPicklistComp)(sender)).UniqueName;

            var tpc = new RefundFactory();
            var ret = tpc.Calculate(
                ValidationHelper.GetGuid(New_RefundPaymentId.Value),
                changedObject,
                pamount,
                pamountCurrency,
                ValidationHelper.GetInteger(new_RefundMethod.Value, 1),
                false);


            if (ret.RefundPaymentAmount > 0)
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
                Parity2.Clear();

                new_RefundPaymentAmount.Items[0].SetValue(ret.RefundPaymentAmount);
                new_RefundPaymentAmount.Items[1].SetValue(ret.RefundPaymentAmountCurrency.ToString());
                Parity1.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_RefundPaymentCurrencyParity", TuEntityEnum.New_RefundPayment.GetHashCode()) + ":&nbsp;&nbsp;" +
                    Math.Round(ValidationHelper.GetDecimal(ret.RefundPaymentCurrencyParity, 0), 6).ToString());

                new_RefundPaymentAmount2.Items[0].SetValue(ret.RefundPaymentAmount2);
                new_RefundPaymentAmount2.Items[1].SetValue(ret.RefundPaymentAmount2Currency.ToString());
                if (ret.RefundPaymentAmount2 > 0)
                    Parity2.SetHtml("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CrmLabel.TranslateAttributeLabelMessage("new_RefundPayment2CurrencyParity", TuEntityEnum.New_RefundPayment.GetHashCode()) + ":&nbsp;&nbsp;" +
                        Math.Round(ValidationHelper.GetDecimal(ret.RefundPayment2CurrencyParity, 0), 6).ToString());

                if (ret.KambiyoAmount > 0)
                {
                    
                    new_KambiyoAmount.Hidden = false;
                    new_KambiyoAmount.Show();
                    new_KambiyoAmount.Items[0].SetIValue(ret.KambiyoAmount);
                    new_KambiyoAmount.Items[1].SetIValue(ret.KambiyoAmountCurrency);
                }
                else
                {
                    pnlPayment.Height = 90;
                    new_KambiyoAmount.Hidden = true;
                    new_KambiyoAmount.Hide();
                }

            }


        }
        catch (Exception ex)
        {
            e.Message = ex.Message;
            e.Success = false;
        }
    }
    bool CheckCalculation()
    {
        if (ValidationHelper.GetGuid(new_CountryId.Value) == Guid.Empty)
        {
            ShowRequiredFields(new_CountryId.FieldLabel);
            return false;
        }
        if (ValidationHelper.GetGuid(new_RefundByCorporation.Value) == Guid.Empty)
        {
            ShowRequiredFields(new_RefundByCorporation.FieldLabel);
            return false;
        }

        return true;
    }
    private void ShowRequiredFields(string myLabel)
    {
        var msg = CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED");
        var m = new MessageBox { Width = 400 };
        m.Show(string.Format(msg, myLabel));
        return;
    }

    protected void SaveOnClick(object sender, AjaxEventArgs e)
    {
        var pamount = ValidationHelper.GetDecimal(((CrmDecimalComp)new_RefundPaymentAmount.Items[0]).Value, 0);
        var pamountCurrency = ValidationHelper.GetGuid(((CrmComboComp)new_RefundPaymentAmount.Items[1]).Value);
        if (!CheckCalculation())
            return;
        var changedObject = "new_RefundPaymentAmount";

        var tpc = new RefundFactory();
        var ret = tpc.Calculate(ValidationHelper.GetGuid(New_RefundPaymentId.Value), changedObject, pamount, pamountCurrency, ValidationHelper.GetInteger(new_RefundMethod.Value, 1), true);
        if (ret.Message != string.Empty)
        {
            var message = ret.Message;
            var msg = new MessageBox { Width = 500 };
            msg.Show(message);
            return;
        }

        var serialNumber = DynamicDb.GetSequenceId("DKT", null);
        if (string.IsNullOrEmpty(serialNumber))
        {
            var m = new MessageBox { Width = 400, Height = 180 };
            m.Show("Unable to create the serial number");
            return;
        }

        var de = new DynamicEntity(TuEntityEnum.New_RefundPayment.GetHashCode());
        de.AddBooleanProperty("new_IdentityChecked", true);
        de.AddKeyProperty("New_RefundPaymentId", ValidationHelper.GetGuid(New_RefundPaymentId.Value));
        de.AddStringProperty("new_SerialNumber", serialNumber);

        var df = new DynamicFactory(ERunInUser.CalingUser);
        try
        {
            df.Update(de.ObjectId, de);
        }
        catch (Coretech.Crm.Objects.Crm.CrmException ex)
        {
            e.Message = ex.ErrorMessage;
            e.Success = false;
            return;
        }


        const string formId = "172efa17-e211-452e-9e0c-7c8cd16e3353";//payment page in 2nc sayfası
        var url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx");

        Page.Response.Redirect(string.Format("{0}?defaulteditpageid={1}&ObjectId={2}&mode=1&recid={3}", url, formId, TuEntityEnum.New_RefundPayment.GetHashCode(), New_RefundPaymentId.Value));

    }
}
