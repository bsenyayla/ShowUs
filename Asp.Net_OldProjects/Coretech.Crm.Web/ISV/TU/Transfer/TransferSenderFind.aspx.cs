using System;
using System.Collections.Generic;
using System.Data;
using AjaxPro;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.Transfer;
using TuFactory.CustAccount.Business;
using Coretech.Crm.PluginData;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;

public partial class Transfer_TransferSenderFind : BasePage
{
    private bool isTuzel;

    private void TranslateMessage()
    {
        //new_NationalityID.FieldLabel = new_SenderIdendificationNumber1.FieldLabel;
        //new_IdendificationCardTypeID.FieldLabel = new_IdentityNo.FieldLabel;
        ToolbarButtonFind.Text = CrmLabel.TranslateMessage(
            "CRM.NEW_TRANSFER_SENDER_FINDE_BUTTON") + " (F9)";
        ToolbarButtonClear.Text = CrmLabel.TranslateMessage(
            "CRM.NEW_TRANSFER_SENDER_FINDE_CLEAR_BUTTON") + " (Ctrl+F9)";
        btnSenderEditUpdate.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_BTN_SENDEREDIT");
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        var senderId = ValidationHelper.GetGuid(Page.Request["senderId"], Guid.Empty);
        var SourceTransactionTypeID = ValidationHelper.GetGuid(Page.Request["SourceTransactionTypeID"], Guid.Empty);
        //QScript("MainCurrency.setValue(window.parent.parent.frames[1].new_AmountCurrency2.getValue());");
        QScript("if (window.parent.parent.frames[1].new_AmountCurrency2 != undefined) { MainCurrency.setValue(window.parent.parent.frames[1].new_AmountCurrency2.getValue());}");

        //new_SenderPersonId.Hide();

        if (GetTransactionTypeCode(SourceTransactionTypeID) == "013") //Hesaptan Gönderim
        {
            new_CustAccountTypeId.RequirementLevel = RLevel.BusinessRequired;
            new_CustAccountTypeId.Show();

            new_CustAccountId.RequirementLevel = RLevel.BusinessRequired;
            new_CustAccountId.Show();

            new_CustAccountCurrencyId.Show();
            new_CustAccountBalance.Show();
        }
        else
        {
            new_CustAccountTypeId.RequirementLevel = RLevel.None;
            new_CustAccountTypeId.Hide();

            new_CustAccountId.RequirementLevel = RLevel.None;
            new_CustAccountId.Hide();

            new_CustAccountCurrencyId.Hide();
            new_CustAccountBalance.Hide();
        }



        if (senderId != Guid.Empty && string.IsNullOrEmpty(new_SenderID.Value))
        {
            new_SenderID.SetValue(senderId);
            RefreshSender(senderId);
        }

        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
            Utility.RegisterTypeForAjax(typeof(AjaxMethods));

            //Kredi Ödeme Planı ekranından gelmesi durumu:
            if (QueryHelper.GetString("fromCheckCredit") == "1")
            {
                if (!String.IsNullOrEmpty(QueryHelper.GetString("creditDataID")))
                {
                    QScript("SetCreditSender();");
                    PrepareControlsForCredit();
                }
            }
        }
    }

    private void PrepareControlsForCredit()
    {
        btnSenderEditUpdate.SetVisible(false);
        ToolbarButtonFind.SetVisible(false);
        ToolbarButtonClear.SetVisible(false);
        new_SenderID.SetDisabled(true);
        new_SenderNumber.SetDisabled(true);
        new_SenderIdendificationNumber1.SetDisabled(true);
        new_NationalityID.SetDisabled(true);
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

    protected void CustAccountTypeOnEvent(object sender, AjaxEventArgs e)
    {
        if (GetCustAccountTypeCode(ValidationHelper.GetGuid(new_CustAccountTypeId.Value)) == "001")
        {
            QScript("new_SenderPersonId.setRequirementLevel(0);new_SenderPersonId.hide();");
        }
        else
        {
            QScript("new_SenderPersonId.setRequirementLevel(2);new_SenderPersonId.show();");
        }
    }

    protected void new_CustAccountId_OnChange(object sender, AjaxEventArgs e)
    {
        QScript("parent.new_CustAccountId.setValue('" + new_CustAccountId.Value + "',null,null,true);");
        QScript("parent.new_SenderPersonId.setValue('" + new_SenderPersonId.Value + "',null,null,true);");
        SetCustAccountCurrencyId(ValidationHelper.GetGuid(new_CustAccountId.Value));
    }

    protected void new_CustAccountId_OnEvent(object sender, AjaxEventArgs e)
    {
        //QScript("MainCurrency.setValue(window.parent.parent.frames[1].new_AmountCurrency2.getValue());");
        QScript("if (window.parent.parent.frames[1].new_AmountCurrency2 != undefined) { MainCurrency.setValue(window.parent.parent.frames[1].new_AmountCurrency2.getValue());}");



        string strSql = @"Select 
                        New_CustAccountsId AS ID
                        ,CustAccountNumber
                        ,CustAccountNumber AS VALUE
                        ,new_CorporationIdName
                        ,new_SenderId
                        ,new_SenderIdName
                        ,new_CustAccountRestrictionId
                        ,new_CustAccountRestrictionIdName
                        ,new_CustAccountTypeId
                        ,new_CustAccountTypeIdName
                        ,new_OfficeId
                        ,new_OfficeIdName
                        ,new_CustAccountCurrencyId
                        ,new_CustAccountCurrencyIdName
                        ,new_CustAccountRestrictionDescription
                        ,new_Balance
                        ,new_IsBlocked
                        ,new_BlockedAmount
                        ,new_BlockedStartDate
                        ,new_BlockedEndDate
                        ,new_BlockedDescription
                        ,new_BlockedType
                        ,new_OwnerSenderNumber
                        ,Fake
                        From vNew_CustAccounts(NoLock) Where DeletionStateCode = 0 And StatusCode = 1";
        var query = ValidationHelper.GetString(Page.Request["query"], "");
        const string sort = "";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CUSTACCOUNTS_LOOKUP");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_SenderID.Start();
        var limit = new_SenderID.Limit();
        var spList = new List<CrmSqlParameter>
        {
        };
        if (new_CustAccountTypeId.Value != string.Empty)
        {
            strSql += " And new_SenderId=@SenderId And new_CustAccountCurrencyId=@CurrencyId";
            spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "SenderId", Value = ValidationHelper.GetGuid(new_SenderID.Value) });
            spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "CurrencyId", Value = ValidationHelper.GetGuid(MainCurrency.Value) });
        }

        var t = gpc.GetFilterData(query, strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_CustAccountId.TotalCount = cnt;
        new_CustAccountId.DataSource = t;
        new_CustAccountId.DataBind();

    }

    private void SetCustAccountCurrencyId(Guid custAccountId)
    {
        var mainCurrency = ValidationHelper.GetGuid(MainCurrency, Guid.Empty);

        if (mainCurrency != Guid.Empty)
        {
            var sd = new StaticData();
            sd.AddParameter("", DbType.Guid, MainCurrency);
            DataTable dt = sd.ReturnDataset(@"Select New_CustAccountsId From vNew_CustAccounts(NoLock) 
Where New_CustAccountsId = @CustAccountId And  new_CustAccountCurrencyId = @CustAccountCurrencyId
And DeletionStateCode = 0").Tables[0];

            if (dt.Rows.Count > 0)
            {
                custAccountId = ValidationHelper.GetGuid(dt.Rows[0]["New_CustAccountsId"]);
            }
        }


        var df = new DynamicFactory(ERunInUser.CalingUser);
        var de = df.RetrieveWithOutPlugin(TuEntityEnum.New_CustAccounts.GetHashCode(), custAccountId, new[] { "new_CustAccountCurrencyId",
            "new_Balance", "new_SenderId", "new_CustAccountTypeId" });
        var currency = de.GetLookupValue("new_CustAccountCurrencyId");
        var balance = de.GetDecimalValue("new_Balance");
        if (currency != Guid.Empty)
        {
            var sender = de.Properties["new_SenderId"] as Lookup;
            var custAccountTypeId = de.Properties["new_CustAccountTypeId"] as Lookup;

            new_CustAccountCurrencyId.SetValue(ValidationHelper.GetString(((Lookup)de["new_CustAccountCurrencyId"]).Value), ((Lookup)de["new_CustAccountCurrencyId"]).name);
            new_CustAccountCurrencyId.Value = ValidationHelper.GetString(currency);
            new_CustAccountBalance.SetValue(ValidationHelper.GetString(balance));
        }
        else
        {
            new_CustAccountCurrencyId.Clear();
            new_CustAccountBalance.Clear();
        }
    }

    protected void btnSenderEditUpdate_Click(object sender, AjaxEventArgs e)
    {
        Dictionary<string, string> query;
        if (new_SenderID.Value == string.Empty)
        {
            query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", "79ca3881-a18e-e511-b92d-54442fe8720d"},
                                {"ObjectId",( (int)TuEntityEnum.New_Sender).ToString()},
                                {"fromTransferScreen","1"}
                                //{"mode", "3"}
                            };
        }
        else
        {
            query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", "79ca3881-a18e-e511-b92d-54442fe8720d"},
                                {"ObjectId",( (int)TuEntityEnum.New_Sender).ToString()},
                                {"recid", new_SenderID.Value},
                                {"fromTransferScreen","1"}
                                //{"mode", "3"}
                            };
        }
        var urlparam = QueryHelper.RefreshUrl(query);
        QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/CrmPages/AutoPages/EditReflex.aspx" + urlparam + "', { maximized: false, width: 1100, height: 500, resizable: true, modal: true, maximizable: false });");
    }

    protected void new_SenderIDOnEvent(object sender, AjaxEventArgs e)
    {
        //string strSql = @" SELECT Sender AS VALUE , New_SenderId AS ID ,* FROM nltvNew_Sender(@SystemUserId) as Mt Where DeletionStateCode=0 AND new_SenderType=1 AND isnull(Sender,'''')<>'''' ";
        string strSql = @" SELECT Sender AS VALUE , New_SenderId AS ID ,* FROM vNew_Sender(NOLOCK) as Mt Where DeletionStateCode=0 AND new_SenderType=1 ";
        var query = ValidationHelper.GetString(Page.Request["query"], "");
        const string sort = "";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("FINDE_SENDER_LOOKUP");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_SenderID.Start();
        var limit = new_SenderID.Limit();
        var spList = new List<CrmSqlParameter>
        {
        };
        if (new_CustAccountTypeId.Value != string.Empty)
        {
            strSql += "and Mt.new_CustAccountTypeId=@new_CustAccountTypeId";
            spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "new_CustAccountTypeId", Value = ValidationHelper.GetGuid(new_CustAccountTypeId.Value) });
        }

        var t = gpc.GetFilterData(query, strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_SenderID.TotalCount = cnt;
        new_SenderID.DataSource = t;
        new_SenderID.DataBind();
    }

    private string GetCustAccountTypeCode(Guid CustAccountTypeId)
    {
        string result = string.Empty;
        if (CustAccountTypeId == Guid.Empty)
            return result;

        DataTable dt = new DataTable();

        try
        {
            var sd = new StaticData();
            sd.AddParameter("CustAccountTypeId", DbType.Guid, CustAccountTypeId);
            dt = sd.ReturnDataset(@"Select new_EXTCODE From vNew_CustAccountType(NoLock)
                                            Where DeletionStateCode = 0 And New_CustAccountTypeId = @CustAccountTypeId
                                            ").Tables[0];
            result = ValidationHelper.GetString(dt.Rows[0]["new_EXTCODE"]);
        }
        catch (Exception ex)
        {
            throw ex;
        }

        return result;
    }


    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        var ms = new MessageBox { Modal = true };

        string callPage = QueryHelper.GetString("callPage");

        var tpf = new TransferPageFactory();
        var ret = tpf.FindeSenderbyIdentificationNumber(ValidationHelper.GetGuid(QueryHelper.GetString("recid")),
            Guid.Empty,
            "",
            ValidationHelper.GetGuid(new_NationalityID.Value),
            ValidationHelper.GetString(new_SenderIdendificationNumber1.Value),
            ValidationHelper.GetString(new_SenderNumber.Value),
            ValidationHelper.GetGuid(new_SenderID.Value)
            );

        if (ret.SenderId != Guid.Empty)
        {
            if (new_NationalityID.IsEmpty && new_SenderIdendificationNumber1.IsEmpty && new_SenderNumber.IsEmpty && new_SenderID.IsEmpty)
            {
                ret.SenderId = Guid.Empty;
            }


            if (callPage == "GsmPayment")
            {
                QScript("parent.new_SenderId.setValue('" + ret.SenderId + "',null,null,true);");
            }
            else
            {
                QScript("parent.new_SenderID.setValue('" + ret.SenderId + "',null,null,true);");
                QScript("parent.new_SenderIdentificationCardTypeID.setValue('" + ret.IdendificationCardTypeID + "',null,null,true);");
                QScript("parent.new_SenderIdentificationCardNo.setValue('" + ret.IdentityNo + "',null,null,true);");
            }



            //new_SenderNumber.SetValue(ret.);

            new_NationalityID.SetValue(ret.NationalityId);
            new_SenderIdendificationNumber1.SetValue(ret.IdentityNo);



            if (ret.BeWarned)
                Alert(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDER_WARNING"));

            //var readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_FORM"));
            //var query = new Dictionary<string, string>
            //                {
            //                    {"defaulteditpageid", "b2b001f0-8293-e511-b92d-54442fe8720d"},
            //                    {"ObjectId",( (int)TuEntityEnum.New_Sender).ToString()},
            //                    {"recid", ret.SenderId.ToString()},
            //                    {"mode", "-1"}
            //                };
            //var urlparam = QueryHelper.RefreshUrl(query);
            //SenderDetail.AutoLoad.Url =
            //    Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            //SenderDetail.LoadUrl(SenderDetail.AutoLoad.Url);
            RefreshSender(ret.SenderId);
            //Kredi Ödeme Planı ekranından gelmesi durumunda tutarları temizlemiyoruz:
            if (QueryHelper.GetString("fromCheckCredit") != "1" && callPage != "GsmPayment")
            {
                QScript("parent.new_ExpenseAmount.clear();");
                QScript("parent.new_Amount.clear();");
                QScript("parent.new_ReceivedAmount1.clear();");
                QScript("parent.new_ReceivedAmount1Currency.clear();");
                QScript("parent.new_CalculatedExpenseAmount.clear();");
                QScript("parent.new_CalculatedExpenseAmountCurrency.clear();");
                QScript("parent.new_TotalReceivedAmount.clear();");
                QScript("parent.new_TotalReceivedAmountCurrency.clear();");
            }
        }
        else
        {
            if (!new_SenderID.IsEmpty)
            {
                ms.MessageType = EMessageType.Error;
                ms.Show(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDER_NOT_FOUND"));
            }
        }
    }

    private void RefreshSender(Guid senderId)
    {
        var query = new Dictionary<string, string>();
        var ms = new MessageBox { Modal = true };
        isTuzel = isTuzelAccountType();
        var isCreditSender = QueryHelper.GetString("fromCheckCredit");
        var SourceTransactionTypeID = ValidationHelper.GetGuid(Page.Request["SourceTransactionTypeID"], Guid.Empty);
        var transactionTypeCode = GetTransactionTypeCode(SourceTransactionTypeID);

        if (senderId != Guid.Empty)
        {
            var readonlyRealform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_FOR_CUSTACCOUNT_REAL_FORM"));
            var readonlyTuzelform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_FOR_CUSTACCOUNT_CORP_FORM"));
            var checkSenderForm = ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_CREDIT_SENDER_FORM"));
            // 14 Hesaptan Gönderim
            if (transactionTypeCode != "14" && isCreditSender != "1")
            {
                //Normal gönderim işlemi kısa senderpage i setle
                query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", ValidationHelper.GetString(GetFormIdByFormName("ReadOnly_Sender_Frm_New"))},
                                {"ObjectId",( (int)TuEntityEnum.New_Sender).ToString()},
                                {"recid", senderId.ToString()},
                                {"mode", "-1"}
                            };
            }
            else
            {


                query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", isCreditSender == "1" ? checkSenderForm : (isTuzel ? readonlyTuzelform : readonlyRealform)},
                                {"ObjectId",( (int)TuEntityEnum.New_Sender).ToString()},
                                {"recid", senderId.ToString()},
                                {"mode", "-1"}
                            };
            }


            var urlparam = QueryHelper.RefreshUrl(query);
            SenderDetail.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            SenderDetail.LoadUrl(SenderDetail.AutoLoad.Url);
            QScript(" R.reSize();");
        }
        else
        {
            if (!new_SenderID.IsEmpty)
            {
                ms.MessageType = EMessageType.Error;
                ms.Show(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDER_NOT_FOUND"));
            }
        }
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

    public Guid GetFormIdByFormName(string formName)
    {
        Guid formId = Guid.Empty;

        var sd = new StaticData();
        sd.AddParameter("FormName", System.Data.DbType.String, formName);

        try
        {
            formId = ValidationHelper.GetGuid(sd.ReturnDataset("Select * From Form Where Name = @FormName And DeletionStateCode = 0").Tables[0].Rows[0]["FormId"]);
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex);
            throw ex;
        }
        return formId;
    }

    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {

        [AjaxMethod()]
        public TransferCalculate CalculateData(
            string recordId, string property, decimal propertyAmount, string propertyAmountCurrency

            )
        {
            var tpc = new TransferPageCalculateFactory();
            var ret = tpc.Calculate(ValidationHelper.GetGuid(recordId), property, propertyAmount, ValidationHelper.GetGuid(propertyAmountCurrency));

            return ret;
        }


    }
}