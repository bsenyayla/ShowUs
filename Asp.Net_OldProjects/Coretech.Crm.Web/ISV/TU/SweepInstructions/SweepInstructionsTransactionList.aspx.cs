using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using Newtonsoft.Json;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;
using System.Web;
using UPTCache = UPT.Shared.CacheProvider.Service;
using Integration3rd.Cloud.Domain;
using TuFactory.SweepInstructions;

public partial class SweepInstructionsTransactionList : BasePage
{
    MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };

    SweepInstructionsFactory fac = new SweepInstructionsFactory();

    protected void Page_Load(object sender, EventArgs e)
    {
        
        if (!RefleX.IsAjxPostback)
        {
            RR.RegisterIcon(Icon.Add);
            AddMessages();
            SetDefaults();

            
        }
       
    }
    private TuUser _activeUser;

    private void SetDefaults()
    {
        var ufFactory = new TuUserFactory();
        _activeUser = ufFactory.GetActiveUser();
        cloudPaymentDateS.Value = DateTime.Now.Date.AddDays(-2);
        cloudPaymentDateE.Value = DateTime.Now.Date;
    }

    private void AddMessages()
    {
        CreatedOnmf.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("CreatedOn",
            TuEntityEnum.New_CustAccountOperations.GetHashCode());
        
        var Messages = new
        {
            NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM"),
            NEW_CUSTACCOUNTOPERATION_SURE_REJECT = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_REJECT")
        };
        RegisterClientScriptBlock("DasMessages", string.Format("var DasMessages={0};", JsonConvert.SerializeObject(Messages)));

        //new_OfficeId.EmptyText = CrmLabel.TranslateMessage("CRM.ENTITY_FILTER_EMPTY_TEXT");

        New_SweepInstructionsId.FieldLabel = "Süpürme Talimatı";
        btnRefresh.Text = CrmLabel.TranslateMessage("CRM_TOOLSEARCH");
        //btnCashTransaction.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_CASH_ACCOUNT");
        //btnDepositOperation.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_DEPOSIT_ACCOUNT"); 
    }

    private string GetListName()
    {
        return "CORPORATED_BLOCKED_TRANSACTION_LIST";
       //throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM.ENTITY_NEEDS_PERMISSION"), "RegionalManager,SalesManager,Administrator,PricingManager,Dealer"));

    }

    protected override void OnInit(EventArgs e)
    {
        var gpc = new GridPanelCreater();
        //gpc.CreateViewGridModels(GetListName(), gpCustAccountOperationHeader, true);
        base.OnInit(e);
    }



    protected void btnNewRecord_Click(object sender, AjaxEventArgs e)
    {

        try
        {
            Guid transactionId;
            int transactionType;
            int corporateTypeId;
            Guid systemUserId = App.Params.CurrentUser.SystemUserId;

            BasePage.QScript("var url = window.top.GetWebAppRoot + '/ISV/TU/LimitApproverManagement/LimitApproverManagementHeader.aspx?ObjectId=202000018&islemTip=yeniKayit" +
                             "&gridpanelid=GridPanelMonitoring&PoolId=3'; window.top.newWindowRefleX(url, { maximized: false, width: 1000, height: 600, resizable: true, modal: true, maximizable: false });");

            //var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            //ms.Show(".", "İlgili işlem onaylandı.");

        }
        catch (Exception ex)
        {

            var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", "Hata!! İşlem Yapılamadı");

            LogUtil.WriteException(ex, "LimitApproverManagementList.btnNewRecord_Click", "Exception");
            throw ex;
        }


        //GridPanelConfirmHistory.DataBind();
    }


    protected void newSenderUptAccountLoad(object sender, AjaxEventArgs e)
    {
        try
        {
            Guid corporationId = ValidationHelper.GetGuid(new_CorporationId.Value);
            DataSet ds = fac.GetUptAccountLoadList(App.Params.CurrentUser.SystemUserId, corporationId, Guid.Empty);
            if (ds.Tables[0].Rows.Count > 0)
            {
                new_SenderAccountId.TotalCount = ds.Tables[0].Rows.Count;
                new_SenderAccountId.DataSource = ds.Tables[0];
                new_SenderAccountId.DataBind();

                
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.SweepInstructionsList.SweepInstructionsTransactionList.newSenderUptAccountLoad", "Exception");
        }
    }

    protected void newRecipientCorpAccountLoad(object sender, AjaxEventArgs e)
    {
        string action = "Coretech.Crm.Web.ISV.TU.SweepInstructionsList.SweepInstructionsTransactionList.newRecipientCorpAccountLoad";
        try
        {
            if (String.IsNullOrEmpty(new_SenderAccountId.Value))
            {
                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "Gönderen hesabı seçiniz!");
                return;
            }

            if (String.IsNullOrEmpty(new_CorporationId.Value))
            {
                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "Kurum seçiniz!");
                return;
            }

            Guid currencyId = Guid.Empty;
            Guid senderAccountId = ValidationHelper.GetGuid(new_SenderAccountId.Value);
            Guid corporationId = Guid.Empty;
            if (senderAccountId != Guid.Empty)
            {

                //var senderAccount = UPTCache.AccountService.GetAccountByAccountId(senderAccountId);
                var senderAccount = fac.GetAccountInfo(senderAccountId);
                if (senderAccount == null)
                {
                    var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                    ms.Show(".", "Cache Üzerinde müşteri hesabı bulunamadı");

                    LogUtil.WriteException(new Exception("Cache üzerinde müşteri hesabı bulunamadı"), action, "Exception");
                    return;
                }

                if (senderAccount.Currency != null)
                    currencyId = ValidationHelper.GetGuid(senderAccount.Currency.CurrencyId);
            }
            corporationId = ValidationHelper.GetGuid( new_CorporationId.Value);
            DataSet ds = fac.GetCorpAccountLoadList(App.Params.CurrentUser.SystemUserId, currencyId, corporationId, (int)OfficeAccountOperationType.TALIMAT_HESABI,Guid.Empty);
            if (ds.Tables[0].Rows.Count > 0)
            {
                new_RecipientInstructionsCorpAccountId.TotalCount = ds.Tables[0].Rows.Count;
                new_RecipientInstructionsCorpAccountId.DataSource = ds.Tables[0];
                new_RecipientInstructionsCorpAccountId.DataBind();
            }


        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, action, "Exception");
        }
    }

    protected void GpCorporatedPreInfoListReload(object sender, AjaxEventArgs e)
    {
        

        var sd = new StaticData();
        var sort = GridPanelCloudAccountTransactionList.ClientSorts() ?? string.Empty;

        string strSql;
        

        strSql = @"select 
	                    SIT.New_SweepInstructionsTransactionId Id,
                        null VALUE,
                        FORMAT(dbo.fnUTCToLocalTimeForUser(SIT.CreatedOn,@SystemuserId),'dd.MM.yyyy HH:mm:ss') CreatedOnUtcTime,
		                SIT.*,
		                ISNULL(SIT.new_IsVirmentCreate,0) IsVirmentCreate,
		                C.New_CorporationId CorporationId,
		                C.CorporationName,
                        EST.Label ErrorStatusLabel,
                        STS.Label TransactionStatusLabel
	                from vNew_SweepInstructionsTransaction SIT (NoLock)
	                INNER JOIN vNew_SweepInstructions S  (NoLock) ON S.New_SweepInstructionsId = SIT.new_SweepInstructionsId
	                INNER JOIN vNew_Accounts A (NOLOCK) ON A.New_AccountsId = SIT.new_SenderAccountId
	                INNER JOIN vNew_CorporationAccount CA (NOLOCK) ON CA.new_AccountId = A.New_AccountsId AND CA.new_CorparationID = S.new_CorporationId AND CA.new_OperationType = 7 
	                INNER JOIN vNew_Corporation C (NOLOCK) ON C.New_CorporationId = CA.new_CorparationID
                    LEFT JOIN new_PLNew_SweepInstructionsTransaction_new_ErrorStatus EST (NOLOCK) ON EST.VALUE = SIT.new_ErrorStatus AND EST.LangId = 1055
                    LEFT JOIN new_PLNew_SweepInstructionsTransaction_new_TransactionStatus STS (NOLOCK) ON STS.VALUE = SIT.new_TransactionStatus AND STS.LangId = 1055
	                where SIT.DeletionStateCode = 0 ";

        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];


        //var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("vSweepInstructionsTransactionMain");
        var spList = new List<CrmSqlParameter>();

        if (!string.IsNullOrEmpty(New_SweepInstructionsId.Value))
        {
            strSql += " AND SIT.New_SweepInstructionsId = @New_SweepInstructionsId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "New_SweepInstructionsId",
                    Value = ValidationHelper.GetGuid(New_SweepInstructionsId.Value)
                }
                );
        }

        if (!string.IsNullOrEmpty(new_CorporationId.Value))
        {
            strSql += " AND C.new_CorporationId = @new_CorporationId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_CorporationId",
                    Value = ValidationHelper.GetGuid(new_CorporationId.Value)
                }
                );
        }

        if (!string.IsNullOrEmpty(new_SenderAccountId.Value))
        {
            strSql += " AND SIT.new_SenderAccountId = @new_SenderAccountId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_SenderAccountId",
                    Value = ValidationHelper.GetGuid(new_SenderAccountId.Value)
                }
                );

        }

        if (!string.IsNullOrEmpty(new_RecipientInstructionsCorpAccountId.Value))
        {
            strSql += " AND SIT.new_RecipientInstructionsCorpAccountId = @new_RecipientInstructionsCorpAccountId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_RecipientInstructionsCorpAccountId",
                    Value = ValidationHelper.GetGuid(new_RecipientInstructionsCorpAccountId.Value)
                }
                );

        }

        if (!string.IsNullOrEmpty(ReferenceNo.Value))
        {
            strSql += " AND SIT.Reference = @ReferenceNo ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.String,
                    Paramname = "ReferenceNo",
                    Value = ValidationHelper.GetString(ReferenceNo.Value)
                }
                );

        }

        if (new_ErrorStatus.Checked)
        {
            strSql += " AND isnull(SIT.new_ErrorStatus,-1) > 1 ";
        }


        if (!string.IsNullOrEmpty(new_TransactionStatus.Value))
        {
            strSql += " AND SIT.new_TransactionStatus=@new_TransactionStatus ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Int32,
                    Paramname = "new_TransactionStatus",
                    Value = ValidationHelper.GetInteger(new_TransactionStatus.Value)
                }
                );
        }

        if (cloudPaymentDateS.Value.HasValue)
        {
            strSql += " AND CAST(CONVERT(varchar,SIT.CreatedOn,23) AS datetime) >= @cloudPaymentDateS ";
            
            var CreatedOnSs = cloudPaymentDateS.Value.Value;
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Date,
                    Paramname = "cloudPaymentDateS",
                    Value = CreatedOnSs
                }
                );
        }
        if (cloudPaymentDateE.Value.HasValue)
        {
            strSql += " AND CAST(CONVERT(varchar,SIT.CreatedOn,23) AS datetime) <=  @cloudPaymentDateE ";
            var CreatedOnEe = cloudPaymentDateE.Value.Value;
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Date,
                    Paramname = "cloudPaymentDateE",
                    Value = CreatedOnEe
                }
                );
        }

        //strSql += " order by A.new_CloudPaymentDate DESC ";

        DataTable dt = new DataTable();
        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelCloudAccountTransactionList.Start();
        var limit = GridPanelCloudAccountTransactionList.Limit();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dt);
        GridPanelCloudAccountTransactionList.TotalCount = cnt;

        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
            gpw.Export(dt);
        }


        GridPanelCloudAccountTransactionList.DataSource = t;
        GridPanelCloudAccountTransactionList.DataBind();

    }


    protected void ToExcelExport(object sender, AjaxEventArgs e)
    {
        try
        {



            var recId = hdnRecId.Value;

            //UptTransactionReport reconcliationFactory = new CorporatedPreInfoFactory();

            //var header = reconcliationFactory.GetUptTransactionReportExportData(ValidationHelper.GetGuid(recId));
            var header = "";

            string strXml = "";/// header.File.Trim();

            this.Response.Clear();
            this.Response.AddHeader("Content-Disposition", "attachment; filename=submittedData.xml");
            //this.Response.AddHeader("Content-Length", strXml.Length.ToString());
            this.Response.ContentType = "application/xml";
            this.Response.Write(strXml);

            //this.Response.End();
            this.Response.Flush();
            HttpContext.Current.ApplicationInstance.CompleteRequest();
            this.Response.End();
            //this.Response.WriteFile(Server.MapPath("~/test.xml"));


        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message.ToString());
            throw;
        }



    }







}