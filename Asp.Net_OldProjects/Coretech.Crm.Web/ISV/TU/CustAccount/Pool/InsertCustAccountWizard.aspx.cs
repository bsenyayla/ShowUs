using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Text;
using System.Web.UI;
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
using Coretech.Crm.Web.UI.RefleX.View;
using Newtonsoft.Json;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.TuUser;
using TuFactory.CustAccount.Business;
using Object = TuFactory.CustAccount.Object;
using TuFactory.Object.User;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;
using TuFactory.CustAccount.Business.Service;
using AjaxPro;
using TuFactory.SenderDocument;
using TuFactory.CustomerData;
using TuFactory.Profession;
using Domain.Entities;
using Services.Interfaces;
using Services;
using TuFactory.Domain.Enums;

public partial class CustAccount_Pool_InsertCustAccountWizard : BasePage
{
    private TuUser _activeUser = null;
    private bool _IsPartlyCollection = false; //Bu kurumda parcalı tahsilat kullanılır.
    private decimal UserCostReductionRate;
    private string _CountryCurrencyID;
    private string _CountryCurrencyIDName;
    private TuUserApproval _userApproval = null;
    private DynamicSecurity DynamicSecurity;
    private string blankUrl = "about:blank";
    bool isNewAmount;
    private bool isTuzel;
    private void PrepareItems()
    {

        var ds = DynamicFactory.GetSecurity(TuEntityEnum.New_CustAccountOperations.GetHashCode(), null);
        if (!ds.PrvCreate)
        {
            Response.End();
            //  BtnCreateTender.Hide();
        }
    }
    private void SetDefaults()
    {
        mfsender.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_SenderId",
         TuEntityEnum.New_CustAccountOperations.GetHashCode());
        lblnew_CustAccountTypeId2.FieldLabel =
            lblnew_CustAccountTypeId3.FieldLabel =
            lblnew_CustAccountTypeId4.FieldLabel =
            CrmLabel.TranslateAttributeLabelMessage("new_CustAccountTypeId", TuEntityEnum.New_CustAccountOperations.GetHashCode());
        lblnew_SenderId2.FieldLabel =
            lblnew_SenderId3.FieldLabel =
            lblnew_SenderId4.FieldLabel =
            CrmLabel.TranslateAttributeLabelMessage("new_SenderId", TuEntityEnum.New_CustAccountOperations.GetHashCode());
        new_IdentityWasSeenReadOnly.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_IdentityWasSeen", TuEntityEnum.New_CustAccountOperations.GetHashCode());
        var ufFactory = new TuUserFactory();
        _activeUser = ufFactory.GetActiveUser();
        new_CorporationId.Value = _activeUser.CorporationId.ToString();
        new_OfficeId.Value = _activeUser.OfficeId.ToString();

    }
    private void AddMessages()
    {
        var Messages = new
        {
            NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM"),
            NEW_CUSTACCOUNTOPERATION_SURE_REJECT = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_REJECT")
        };
        RegisterClientScriptBlock("DasMessages", string.Format("var DasMessages={0};", JsonConvert.SerializeObject(Messages)));
        Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage", "var documentNotComplete="
                + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_DOCUMENT_REQUIRED")) + ";", true);
        lblInfoDocumentOneStar.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_ONESTARDOCUMENTINFO");
        lblInfoDocumentTwoStar.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_TWOSTARDOCUMENTINFO");
        const string strCustAccountTypeCodetemp = "var CustAccountType_{0} = \"{1}\";";
        var sb = new StringBuilder();

        foreach (var item in new CustAccountOperations().GetCustAccountTypeList())
        {
            sb.AppendLine(string.Format(strCustAccountTypeCodetemp, item.Code, item.Id.ToLower()));
        }

        RegisterClientScriptBlock("strCustAccountTypeCodetemp", sb.ToString());
        sb.Clear();


    }
    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        isTuzel = isTuzelAccountType();
        this.new_CalculatedExpenseAmount.c1.Enabled = false;
        DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_CustAccountType.GetHashCode(), null);
        if (!(DynamicSecurity.PrvCreate || DynamicSecurity.PrvRead || DynamicSecurity.PrvWrite))
            Response.End();

        var sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        var dt =
            sd.ReturnDataset(
                @"
SELECT 
u.new_CorporationID,
c.new_CountryID,
u.new_OfficeID , 
co.new_CurrencyID,
new_CurrencyIDName,
c.new_IsPartlyCollection,
o.new_CountryID OfficeCountryId,
cao.New_CustAccountOperationTypeId as CustAccountOperationTypeId
FROM vSystemUser(nolock) u
INNER JOIN vNew_Corporation c on u.new_CorporationID = c.New_CorporationId
INNER JOIN vNew_Office o on o.New_OfficeId=u.new_OfficeID
LEFT OUTER JOIN vnew_country co ON co.New_CountryId=c.new_CountryID 
LEFT OUTER JOIN vnew_custaccountOperationType cao on cao.new_EXTCODE='001' and cao.DeletionStateCode=0
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




        if (!RefleX.IsAjxPostback)
        {
            //if (!_IsPartlyCollection)
            //{
            //    new_CollectionMethod.Visible = false;
            //    new_ReceivedAmount2.Visible = false;
            //}
            //else
            //{
            //    new_CollectionMethod.Value = TransferCollectionMethodEnum.Single.GetHashCode().ToString();
            //    new_CollectionMethod.SetValue(TransferCollectionMethodEnum.Single.GetHashCode().ToString());
            //}

            RR.RegisterIcon(Icon.Add);
            Utility.RegisterTypeForAjax(typeof(AjaxMethods));
            CreateViewGrid();
            //new_CustAccountTypeId.SetValue(Conti.ActiveUser.UserDealerId.ToString());
            AddMessages();
            PrepareItems();
            SetDefaults();
            ConfigureFirstLoadData();
            new_Amount.Items[1].SetDisabled(true);

        }
        new_CalculatedExpenseAmount.Items[1].SetDisabled(true);
        setUserCostReductionRate();
    }

    public bool isTuzelAccountType()
    {
        var tuzelid = string.Empty;
        var gercekid = string.Empty;
        foreach (var item in new CustAccountOperations().GetCustAccountTypeList())
        {
            if (item.Code == "001")
                gercekid = item.Id.ToLower();
            if (item.Code == "002")
                tuzelid = item.Id.ToLower();
        }
        return new_CustAccountTypeId.Value == tuzelid;
    }
    protected void btnSenderEditUpdate_Click(object sender, AjaxEventArgs e)
    {

        if (string.IsNullOrEmpty(new_CustAccountTypeId.Value))
        {
            ShowRequiredFields(new_CustAccountTypeId.FieldLabel);
            return;
        }
        var query = new Dictionary<string, string>
        {
            {"ObjectId", ((int) TuEntityEnum.New_Sender).ToString()},
            {"fromCustomerAccountScreen", "1"},
            {"gridpanelid", ""},
            {
                "defaulteditpageid",
                isTuzel ? "d834cb22-77a9-e511-b92d-54442fe8720d" : "5d08acf8-39ad-e511-9f11-28e347b36ba3"
            }
        };

        if (new_SenderId.Value != string.Empty)
        {
            query.Add("recid", new_SenderId.Value);
        }
        var urlparam = QueryHelper.RefreshUrl(query);
        QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/CrmPages/AutoPages/EditReflex.aspx" + urlparam + "', { maximized: false, width: 1100, height: 500, resizable: true, modal: true, maximizable: false });");
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

    protected void new_SenderId_OnChange(object sender, AjaxEventArgs e)
    {
        var senderId = ValidationHelper.GetGuid(new_SenderId.Value);
        if (senderId != Guid.Empty)
        {
            var df = new DynamicFactory(ERunInUser.SystemAdmin);
            var desender = df.RetrieveWithOutPlugin(TuEntityEnum.New_Sender.GetHashCode(), senderId, new[] { "new_CustAccountTypeId", "new_NationalityID" });
            var CustAccountTypeId = desender.GetLookupValue("new_CustAccountTypeId");
            var CustNationId = desender.GetLookupValue("new_NationalityID");

            var custAccountType = UPT.Shared.CacheProvider.Service.CustAccountTypeService.GetCustAccountTypeByTypeId(ValidationHelper.GetGuid(new_CustAccountTypeId.Value));
            var professionDb = new ProfessionDb();
            if (!professionDb.ExistsSenderProfessionInfo(ValidationHelper.GetGuid(new_SenderId.Value)) && custAccountType != null && custAccountType.ExtCode == "001")
            {
                QScript(string.Format("ShowProfession('{0}','{1}');", new_SenderId.Value, CrmLabel.TranslateMessage("CRM.NEW_PROFESSION_CONTROL_FORM")));
                return;
            }

            if (CustAccountTypeId != ValidationHelper.GetGuid(new_CustAccountTypeId.Value))
            {
                new_CustAccountTypeId.Value = CustAccountTypeId.ToString();
                new_CustAccountTypeId.SetValue(((Lookup)desender["new_CustAccountTypeId"]).Value.ToString(), ((Lookup)desender["new_CustAccountTypeId"]).name);
                isTuzel = isTuzelAccountType();
            }
            if (CustNationId != Guid.Empty)
                InsertSenderDocumentsIfNecessary(senderId, CustNationId);
        }
        
        RefreshSender(senderId);

    }

    public void InsertSenderDocumentsIfNecessary(Guid senderID, Guid nationID)
    {
        SenderDocumentFactory docService = new SenderDocumentFactory();
        try
        {
            if (!String.IsNullOrEmpty(new_CustAccountTypeId.Value) && ValidationHelper.GetGuid(new_CustAccountTypeId.Value,Guid.Empty) != Guid.Empty)
            {
                docService.InsertSenderDocumentsIfNecessary(senderID, ValidationHelper.GetGuid(new_CustAccountTypeId.Value), nationID);
            }
        }
        catch
        {
            throw;
        }
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
            SenderDetail.AutoLoad.Url = blankUrl;
            SenderDetail.LoadUrl(SenderDetail.AutoLoad.Url);
            if (!new_SenderId.IsEmpty)
            {
                ms.MessageType = EMessageType.Error;
                ms.Show(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDER_NOT_FOUND"));
            }
        }
    }
    protected override void OnInit(EventArgs e)
    {
        var gpc = new GridPanelCreater();
        base.OnInit(e);
        //gpc.CreateViewGridModels(GetListName(), gpCustAccountOperationHeader, true);

    }
    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        //gpc.CreateViewGrid(GetListName(), gpCustAccountOperationHeader, true);
    }

    private string GetListName()
    {
        return "CUSTACCOUNT_OPERATIONS_LIST";
    }
    public void SetCollectionMethod(object sender, AjaxEventArgs e)
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
    #region CalculationOperations
    protected void new_CustAccountCurrencyIdOnEvent(object sender, AjaxEventArgs e)
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

        new_Amount.Items[1].SetValue(new_CustAccountCurrencyId.Value);
        new_Amount.Items[1].SetDisabled(true);
        new_ReceivedAmount1.Items[0].SetDisabled(true);
        new_ExpenseAmount.Items[0].SetDisabled(true);
        new_ExpenseAmount.Items[1].SetDisabled(true);

        //new_RecipientIDChangeOnEvent(null, null);

        SetCollectionMethod(sender, e);

    }
    void ConfigureFirstLoadData()
    {
        QScript("PrepareDocumentInfoLabel();");
        if (_IsPartlyCollection)
        {

            if (new_ReceivedAmount2.c1.Value != string.Empty)
                new_ReceivedAmount2.c1.SetValue(_CountryCurrencyID, _CountryCurrencyIDName);

            new_CollectionMethod.SetDisabled(true);
            ReconfigureByCollectionMethod();
        }
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
    protected void new_AmountOnChange(object sender, AjaxEventArgs e)
    {
        setUserCostReductionRate();
        //CorporationCountryFormParameterForDisplayControl();
        //ReConfigureScreen2();
        if (((Coretech.Crm.Web.UI.RefleX.AutoGenerate.CrmDecimalComp)sender).UniqueName != "new_Amount")
        {
            isNewAmount = false;
            sender = this.new_Amount.d1;
        }
        else
        {
            isNewAmount = true;
            RebuildExpenseProcess(Guid.Empty, null);
        }
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
        if (ValidationHelper.GetInteger(new_CollectionMethod.Value) == TransferCollectionMethodEnum.Multiple.GetHashCode())
        {
            new_CollectionMethodOnChange(sender, e);
        }
        else
        {
            CalculateOnEvent(sender, e);
        }

        //SelectedIdentificationCardType(new_SenderIdentificationCardTypeID);
        //GetTransferOutherCalculateScript();

    }

    protected void CalculateOnEvent(object sender, AjaxEventArgs e)
    {

        ExpenseProcessor();

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

            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            //sd.AddParameter("CountryID", DbType.Guid, ValidationHelper.GetDBGuid(new_CorporationCountryId.Value));
            sd.AddParameter("CorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_CorporationId.Value));
            sd.AddParameter("CustAccountOperationTypeId", DbType.Guid, ValidationHelper.GetDBGuid(new_CustAccountOperationTypeId.Value));
            //sd.AddParameter("RecipientCountryID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCountryID.Value));
            sd.AddParameter("Amount", DbType.Decimal, amount);
            sd.AddParameter("AmountCurrency", DbType.Guid, ValidationHelper.GetDBGuid(new_CustAccountCurrencyId.Value));
            sd.AddParameter("ReceivedAmount1Currency", DbType.Guid, ValidationHelper.GetDBGuid(((CrmComboComp)new_ReceivedAmount1.Items[1]).Value));
            sd.AddParameter("ReceivedAmount1", DbType.Decimal, ramount);
            //sd.AddParameter("TransactionId", DbType.Guid, DBNull.Value);
            sd.AddParameter("SenderId", DbType.Guid, ValidationHelper.GetDBGuid(new_SenderId.Value));
            sd.AddParameter("CollectionMethod", DbType.Int32, ValidationHelper.GetInteger(new_CollectionMethod.Value));
            sd.AddParameter("ChangedObject", DbType.String, changedObject);
            //sd.AddParameter("SenderType", DbType.Int16, ValidationHelper.GetInteger(new_SenderType.));

            //if (((Coretech.Crm.Web.UI.RefleX.AutoGenerate.CrmDecimalComp)sender).UniqueName != "new_Amount")
            if (!isNewAmount)
            {
                sd.AddParameter("CustomExpense", DbType.Decimal, new_CalculatedExpenseAmount.d1.Value);
                sd.AddParameter("CustomExpenseCurrency", DbType.Guid, ValidationHelper.GetDBGuid(new_CalculatedExpenseAmount.c1.Value));
            }


            //sd.AddParameter("TransactionTargetOptionId", DbType.Guid, ValidationHelper.GetDBGuid(new_TransactionTargetOptionID.Value));
            //sd.AddParameter("RecipientCorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCorporationId.Value));
            //sd.AddParameter("EftBank", DbType.Guid, ValidationHelper.GetDBGuid(new_EftBank.Value));

            var result = sd.ReturnDatasetSp(@"[SpTuCustAccountCalculate]").Tables[0];



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
    protected void RebuildExpenseProcess(Guid custAccountOperationsId, DbTransaction transaction)
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

            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            //sd.AddParameter("CountryID", DbType.Guid, ValidationHelper.GetDBGuid(new_CorporationCountryId.Value));
            sd.AddParameter("CorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_CorporationId.Value));
            sd.AddParameter("CustAccountOperationTypeId", DbType.Guid, ValidationHelper.GetDBGuid(new_CustAccountOperationTypeId.Value));
            //sd.AddParameter("RecipientCountryID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCountryID.Value));
            sd.AddParameter("Amount", DbType.Decimal, amount);
            sd.AddParameter("AmountCurrency", DbType.Guid, ValidationHelper.GetDBGuid(new_CustAccountCurrencyId.Value));
            sd.AddParameter("ReceivedAmount1Currency", DbType.Guid, ValidationHelper.GetDBGuid(((CrmComboComp)new_ReceivedAmount1.Items[1]).Value));
            sd.AddParameter("ReceivedAmount1", DbType.Decimal, ramount);
            //sd.AddParameter("TransactionId", DbType.Guid, DBNull.Value);
            sd.AddParameter("SenderId", DbType.Guid, ValidationHelper.GetDBGuid(new_SenderId.Value));
            sd.AddParameter("CollectionMethod", DbType.Int32, ValidationHelper.GetInteger(new_CollectionMethod.Value));
            //sd.AddParameter("TransactionTargetOptionId", DbType.Guid, ValidationHelper.GetDBGuid(new_TransactionTargetOptionID.Value));
            //sd.AddParameter("EftBank", DbType.Guid, ValidationHelper.GetDBGuid(new_EftBank.Value));

            if (!isNewAmount)
            {
                sd.AddParameter("CustomExpense", DbType.Decimal, new_CalculatedExpenseAmount.d1.Value);
                sd.AddParameter("CustomExpenseCurrency", DbType.Guid, ValidationHelper.GetDBGuid(new_CalculatedExpenseAmount.c1.Value));
            }

            //if (!string.IsNullOrEmpty(new_RecipientCorporationId.Value) && new_RecipientCorporationId.Value == "00000000-0000-0000-0000-000000000001" && !string.IsNullOrEmpty(new_RecipientCorporationIdHidden.Value))
            //{
            //    sd.AddParameter("RecipientCorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCorporationIdHidden.Value));
            //}
            //else
            //{
            //    sd.AddParameter("RecipientCorporationID", DbType.Guid, ValidationHelper.GetDBGuid(new_RecipientCorporationId.Value));
            //}
            if (custAccountOperationsId != Guid.Empty)
            {
                sd.AddParameter("CustAccountOperationsId", DbType.Guid, custAccountOperationsId);
                sd.AddParameter("ChangedObject", DbType.String, this.new_ReceivedAmount1.d1.UniqueName);

                if (transaction != null)
                    sd.ExecuteNonQuerySp("SpTuCustAccountCalculate", transaction);
                else
                    sd.ExecuteNonQuerySp("SpTuCustAccountCalculate");
            }
            else
            {
                sd.AddParameter("ChangedObject", DbType.String, this.new_Amount.d1.UniqueName);

                var result = sd.ReturnDatasetSp(@"SpTuCustAccountCalculate").Tables[0];
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

        }
        catch (Exception ex)
        {
            if (transaction != null)
                throw;
            MessageBox msgBox = new MessageBox();
            msgBox.Show(ex.Message);
        }
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


    bool CheckCalculation()
    {



        if (ValidationHelper.GetGuid(new_CustAccountCurrencyId.Value) == Guid.Empty)
        {
            ShowRequiredFields(new_CustAccountCurrencyId.FieldLabel);
            return false;
        }
        return true;
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
    private void ShowRequiredFields(string myLabel)
    {
        var msg = CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED");
        var m = new MessageBox { Width = 400 };
        m.Show(string.Format(msg, myLabel));
    }
    #endregion

    #region AddBalance
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
    #endregion
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


    CreateAccountItem GetCreateAccountItem()
    {
        #region CreateAccountItem Object

        CreateAccountItem cashDepositItem = new CreateAccountItem();

        cashDepositItem.CustAccountOperationType = new CustAccountOperationType()
        {
            CustAccountOperationTypeId = ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value)
        };

        cashDepositItem.Sender = new Sender()
        {
            SenderId = ValidationHelper.GetGuid(new_SenderId.Value)
        };

        cashDepositItem.CustAccountType = new CustAccountType()
        {
            CustAccountTypeId = ValidationHelper.GetGuid(new_CustAccountTypeId.Value)
        };

        cashDepositItem.CustAccountCurrency = new Currency()
        {
            CurrencyId = ValidationHelper.GetGuid(new_CustAccountCurrencyId.Value)
        };

        cashDepositItem.Corporation = new Corporation()
        {
            CorporationId = ValidationHelper.GetGuid(new_CorporationId.Value)
        };

        cashDepositItem.Office = new Office()
        {
            OfficeId = ValidationHelper.GetGuid(new_OfficeId.Value)
        };

        cashDepositItem.SenderType = 1;
        cashDepositItem.OperationDescription = ValidationHelper.GetString(new_OperationDescription.Value);

        if (new_Amount.d1.Value != null)
        {
            cashDepositItem.Amount = new TransactionAmount()
            {
                Amount = new_Amount.d1.Value.Value,
                AmountCurrency = new Currency
                {
                    CurrencyId = ValidationHelper.GetGuid(new_Amount.c1.Value)
                }
            };
        }

        if (new_CalculatedExpenseAmount.d1.Value != null)
        {
            cashDepositItem.CalculatedExpenseAmount = new TransactionAmount()
            {
                Amount = new_CalculatedExpenseAmount.d1.Value.Value,
                AmountCurrency = new Currency
                {
                    CurrencyId = ValidationHelper.GetGuid(new_CalculatedExpenseAmount.c1.Value)
                }
            };
        }

        if (new_ReceivedAmount1.d1.Value != null)
        {
            cashDepositItem.ReceivedAmount1 = new TransactionAmount()
            {
                Amount = new_ReceivedAmount1.d1.Value.Value,
                AmountCurrency = new Currency
                {
                    CurrencyId = ValidationHelper.GetGuid(new_ReceivedAmount1.c1.Value)
                }
            };
        }

        if (new_ReceivedAmount2.d1.Value != null)
        {
            cashDepositItem.ReceivedAmount2 = new TransactionAmount()
            {
                Amount = new_ReceivedAmount2.d1.Value.Value,
                AmountCurrency = new Currency
                {
                    CurrencyId = ValidationHelper.GetGuid(new_ReceivedAmount2.c1.Value)
                }
            };
        }

        cashDepositItem.CollectionMethod = ValidationHelper.GetInteger(new_CollectionMethod.Value, 0);

        if (new_ReceivedExpenseAmount.d1.Value != null)
        {
            cashDepositItem.ReceivedExpenseAmount = new TransactionAmount()
            {
                Amount = new_ReceivedExpenseAmount.d1.Value.Value,
                AmountCurrency = new Currency
                {
                    CurrencyId = ValidationHelper.GetGuid(new_ReceivedExpenseAmount.c1.Value)
                }
            };
        }

        if (new_TotalReceivedAmount.d1.Value != null)
        {
            cashDepositItem.TotalReceivedAmount = new TransactionAmount()
            {
                Amount = new_TotalReceivedAmount.d1.Value.Value,
                AmountCurrency = new Currency
                {
                    CurrencyId = ValidationHelper.GetGuid(new_TotalReceivedAmount.c1.Value)
                }
            };
        }

        if (new_ExpenseAmount.d1.Value != null)
        {
            cashDepositItem.ExpenseAmount = new TransactionAmount()
            {
                Amount = new_ExpenseAmount.d1.Value.Value,
                AmountCurrency = new Currency
                {
                    CurrencyId = ValidationHelper.GetGuid(new_ExpenseAmount.c1.Value)
                }
            };
        }

        cashDepositItem.SenderIdentificationCardType = new IdentificatonCardType()
        {
            New_IdentificatonCardTypeId = ValidationHelper.GetGuid(new_SenderIdentificationCardTypeID.Value)
        };

        cashDepositItem.IdentityWasSeen = ValidationHelper.GetBoolean(new_IdentityWasSeen.Value);
        cashDepositItem.SenderIdentificationCardNo = ValidationHelper.GetString(new_SenderIdentificationCardNo.Value);


        #endregion

        #region Calculate Object

        cashDepositItem.Calculate = new CalculateCreateAccountRequest();

        cashDepositItem.Calculate.Amount = new TransactionAmount()
        {
            Amount = cashDepositItem.Amount.Amount,
            AmountCurrency = new Currency()
            {
                CurrencyId = cashDepositItem.Amount.AmountCurrency.CurrencyId
            }
        };

        cashDepositItem.Calculate.ReceivedAmount = new TransactionAmount()
        {
            Amount = cashDepositItem.ReceivedAmount1.Amount,
            AmountCurrency = new Currency()
            {
                CurrencyId = cashDepositItem.ReceivedAmount1.AmountCurrency.CurrencyId
            }
        };

        cashDepositItem.Calculate.CustAccountOperationTypeId = cashDepositItem.CustAccountOperationType.CustAccountOperationTypeId;

        cashDepositItem.Calculate.Sender = new Sender()
        {
            SenderId = cashDepositItem.Sender.SenderId
        };

        cashDepositItem.Calculate.Corporation = new Corporation()
        {
            CorporationId = cashDepositItem.Corporation.CorporationId
        };

        cashDepositItem.Calculate.Office = new Office()
        {
            OfficeId = cashDepositItem.Office.OfficeId
        };

        cashDepositItem.Calculate.CollectionMethod = cashDepositItem.CollectionMethod;
        cashDepositItem.Calculate.SenderType = cashDepositItem.SenderType;

        if (!cashDepositItem.IsNewAmount)
        {
            cashDepositItem.Calculate.CustomExpense = new TransactionAmount()
            {
                Amount = cashDepositItem.CalculatedExpenseAmount.Amount,
                AmountCurrency = new Currency()
                {
                    CurrencyId = cashDepositItem.CalculatedExpenseAmount.AmountCurrency.CurrencyId
                }
            };
        }


        if (cashDepositItem.CustAccountOperationId != Guid.Empty)
        {
            cashDepositItem.Calculate.CustAccountOperationId = cashDepositItem.CustAccountOperationId;
            cashDepositItem.Calculate.ChangedObject = "new_ReceivedAmount1";
        }
        else
        {
            cashDepositItem.Calculate.ChangedObject = "new_Amount";
        }

        #endregion

        return cashDepositItem;
    }

    protected void btnFinishOnClickEvent2(object sender, AjaxEventArgs e)
    {
        try
        {
            ICustAccountOperationService<object> _service = new CreateAccountService<object>();
            ICustAccountItem cashCreateAccountItem = GetCreateAccountItem();
            var response = _service.Request(cashCreateAccountItem);

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

            if ((string)response.ServiceResponse == Object.CustAccountStatus.HesapAcildiDekontBasilacak)
            {
                Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_MUSTRECIPMENT"));
                Response.Redirect("CustAccountRouter.aspx?recid=" + cashCreateAccountItem.CustAccountOperationId);
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "CustAccount_Pool_DepositTransaction");
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


        StaticData sd = new StaticData();
        var tr = sd.GetDbTransaction();
        DynamicFactory df = new DynamicFactory(ERunInUser.CalingUser);
        df.GetBeginTrans(tr);
        DynamicEntity de = new DynamicEntity(TuEntityEnum.New_CustAccountOperations.GetHashCode());
        var id = Guid.Empty;
        var msg = new MessageBox();

        try
        {

            de.AddLookupProperty("new_CustAccountOperationTypeId", "",
                ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value));
            de.AddLookupProperty("new_SenderId", "", ValidationHelper.GetGuid(new_SenderId.Value));
            de.AddLookupProperty("new_CustAccountTypeId", "", ValidationHelper.GetGuid(new_CustAccountTypeId.Value));
            de.AddLookupProperty("new_CustAccountCurrencyId", "",
                ValidationHelper.GetGuid(new_CustAccountCurrencyId.Value));
            de.AddLookupProperty("new_CustAccountRestrictionId", "",
                ValidationHelper.GetGuid(new_CustAccountRestrictionId.Value));
            de.AddLookupProperty("new_CorporationId", "", ValidationHelper.GetGuid(new_CorporationId.Value));
            de.AddLookupProperty("new_OfficeId", "", ValidationHelper.GetGuid(new_OfficeId.Value));
            de.AddStringProperty("new_CustAccountRestrictionDescription", new_CustAccountRestrictionDescription.Value);

            if (new_Amount.d1.Value != null)
            {
                de.AddMoneyProperty("new_Amount", new_Amount.d1.Value.Value,
                    new Lookup("new_AmountCurrency", ValidationHelper.GetGuid(new_Amount.c1.Value)));
            }
            if (new_CalculatedExpenseAmount.d1.Value != null)
            {
                de.AddMoneyProperty("new_CalculatedExpenseAmount", new_CalculatedExpenseAmount.d1.Value.Value,
                    new Lookup("new_CalculatedExpenseAmountCurrency",
                        ValidationHelper.GetGuid(new_CalculatedExpenseAmount.c1.Value)));
            }
            if (new_ReceivedAmount1.d1.Value != null)
            {
                de.AddMoneyProperty("new_ReceivedAmount1", new_ReceivedAmount1.d1.Value.Value,
                    new Lookup("new_ReceivedAmount1Currency", ValidationHelper.GetGuid(new_ReceivedAmount1.c1.Value)));
            }

            if (new_ReceivedAmount2.d1.Value != null)
            {
                de.AddMoneyProperty("new_ReceivedAmount2", new_ReceivedAmount2.d1.Value.Value,
                    new Lookup("new_ReceivedAmount2Currency", ValidationHelper.GetGuid(new_ReceivedAmount2.c1.Value)));
            }

            de.AddPicklistProperty("new_CollectionMethod", ValidationHelper.GetInteger(new_CollectionMethod.Value, 0));

            if (new_ReceivedExpenseAmount.d1.Value != null)
            {
                de.AddMoneyProperty("new_ReceivedExpenseAmount", new_ReceivedExpenseAmount.d1.Value.Value,
                    new Lookup("new_ReceivedExpenseAmountCurrency",
                        ValidationHelper.GetGuid(new_ReceivedExpenseAmount.c1.Value)));
            }
            if (new_TotalReceivedAmount.d1.Value != null)
            {
                de.AddMoneyProperty("new_TotalReceivedAmount", new_TotalReceivedAmount.d1.Value.Value,
                    new Lookup("new_TotalReceivedAmountCurrency",
                        ValidationHelper.GetGuid(new_TotalReceivedAmount.c1.Value)));
            }
            if (new_ExpenseAmount.d1.Value != null)
                de.AddMoneyProperty("new_ExpenseAmount", new_ExpenseAmount.d1.Value.Value,
                    new Lookup("new_ExpenseAmountCurrency", ValidationHelper.GetGuid(new_ExpenseAmount.c1.Value)));

            de.AddLookupProperty("new_SenderIdentificationCardTypeID", "",
                ValidationHelper.GetGuid(new_SenderIdentificationCardTypeID.Value));
            de.AddBooleanProperty("new_IdentityWasSeen", ValidationHelper.GetBoolean(new_IdentityWasSeen.Value));
            de.AddStringProperty("new_SenderIdentificationCardNo",
                ValidationHelper.GetString(new_SenderIdentificationCardNo.Value));
            de.AddLookupProperty("new_SenderPersonId", "", ValidationHelper.GetGuid(new_SenderPersonId.Value));

            if (!string.IsNullOrEmpty(new_OperationDescription.Value))
            {
                de.AddStringProperty("new_OperationDescription", ValidationHelper.GetString(new_OperationDescription.Value));
            }

            id = df.Create(TuEntityEnum.New_CustAccountOperations.GetHashCode(), de);

            if (string.IsNullOrEmpty(new_OperationDescription.Value))
            {
                string operationDescription = string.Format("Nakit Yatırma  - {0}", de.GetStringValue("CustAccountOperationName"));
                de.AddStringProperty("new_OperationDescription", operationDescription);

                df.Update(TuEntityEnum.New_CustAccountOperations.GetHashCode(), de);
            }

            CustomerDataProtectionService.SaveCustomerDataUsagePermission
            (
                ValidationHelper.GetGuid(new_SenderId.Value),
                CustomerDataUsagePermissionWorkflow.CustomerAccountCreate,
                CustomerDataUsagePermissionConfirmType.Form,
                tr
            );

            #region CheckForParameters
            sd.AddParameter("CustAccountOperationsId", DbType.Guid, id);
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            var ret = ValidationHelper.GetString(sd.ExecuteScalarSp("SpTuCustAccountCreateCheck", tr));
            if (!string.IsNullOrEmpty(ret))
            {
                throw new TuException(ValidationHelper.GetString(ret), "CUST001");
            }

            RebuildExpenseProcess(id, tr);
            StaticData.Commit(tr);


            #endregion


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

        /*İlgili Göndericinin Hesap Tipini Set Ediyoruz*/
        var aSet = new StaticData();
        aSet.AddParameter("SenderID", DbType.Guid, ValidationHelper.GetGuid(new_SenderId.Value));
        aSet.AddParameter("CustAccountTypeID", DbType.Guid, ValidationHelper.GetGuid(new_CustAccountTypeId.Value));
        aSet.ExecuteNonQuerySp("spTuCustAccountSetSenderAccountType");

        /*Eger hata vs yoksa simdi bir de AML kontrolune girecek.*/

        //CustAccount.Business.
        if (id != Guid.Empty)
        {

            sd.AddParameter("CustAccountOperationsId", DbType.Guid, id);
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            var ret1 = ValidationHelper.GetString(sd.ExecuteScalarSp("SpTuCustAccountCreatePrepare"));


            if (!string.IsNullOrEmpty(ret1))
            {
                Alert(ValidationHelper.GetString(ret1));
            }
            try
            {
                CustAccountApprovePoolService approvePoolService = new CustAccountApprovePoolService();
                Object.CustAccountApprovePoolResponse approvePoolResponse = approvePoolService.ApproveStageProcess(id);
                if (!approvePoolResponse.result)
                {
                    Alert(approvePoolResponse.message);
                    BasePage.QScript("btnFinis.hide();");
                    BasePage.QScript("RefreshParetnGrid(true);");
                    return;
                }

                ConfirmFactory amlFraudService = new ConfirmFactory();
                var amlFraudResponse = amlFraudService.AmlFraudProcess(id);
                if (!amlFraudResponse.result)
                {
                    Alert(amlFraudResponse.message);
                    BasePage.QScript("btnFinis.hide();");
                    BasePage.QScript("RefreshParetnGrid(true);");
                }
                var cs = new CustAccountOperations().GetCustAccountConfirmStatus(id);
                if (cs == Object.CustAccountStatus.HesapAcildiDekontBasilacak)
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

    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {
        public class DocumentNecessaryType {
            public bool Ret { get; set; }
            public string Message { get; set; }
        }
        [AjaxMethod()]
        public DocumentNecessaryType IsSenderDocumentNecessaryComplete(string senderID, string custAccountTypeID)
        {
            CustAccountOperations custService = new CustAccountOperations();
            var message = string.Empty;
            var ret = new DocumentNecessaryType();
            ret.Ret = custService.IsSenderDocumentNecessaryComplete(ValidationHelper.GetGuid(senderID), ValidationHelper.GetGuid(custAccountTypeID), out message);
            ret .Message=message;

            return ret;

        }
    }
}