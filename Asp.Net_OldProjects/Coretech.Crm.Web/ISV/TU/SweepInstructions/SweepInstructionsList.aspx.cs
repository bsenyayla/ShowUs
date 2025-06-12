using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
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
using Coretech.Crm.Factory.Exporter;
using System.Web;
using TuFactory.Corporation;
using TuFactory.SweepInstructions;
using UPTCache = UPT.Shared.CacheProvider.Service;
using Integration3rd.Cloud.Domain;

public partial class SweepInstructionsList : BasePage
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
    }

    private void AddMessages()
    {
        
        
        var Messages = new
        {
            NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM"),
            NEW_CUSTACCOUNTOPERATION_SURE_REJECT = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_REJECT")
        };
        RegisterClientScriptBlock("DasMessages", string.Format("var DasMessages={0};", JsonConvert.SerializeObject(Messages)));

        //new_OfficeId.EmptyText = CrmLabel.TranslateMessage("CRM.ENTITY_FILTER_EMPTY_TEXT");
        btnRefresh.Text = CrmLabel.TranslateMessage("CRM_TOOLSEARCH");
        
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
            LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.SweepInstructionsList.SweepInstructionsListDetail.newSenderUptAccountLoad", "Exception");
        }
    }

    protected void newRecipientCorpAccountLoad(object sender, AjaxEventArgs e)
    {
        string action = "Coretech.Crm.Web.ISV.TU.SweepInstructionsList.SweepInstructionsListDetail.newRecipientCorpAccountLoad";

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

        Guid corporationId = Guid.Empty;

        try
        {
            Guid currencyId = Guid.Empty;
            Guid senderAccountId = ValidationHelper.GetGuid(new_SenderAccountId.Value);
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

            corporationId = ValidationHelper.GetGuid(new_CorporationId.Value);
            DataSet ds = fac.GetCorpAccountLoadList(App.Params.CurrentUser.SystemUserId, currencyId, corporationId, (int)OfficeAccountOperationType.TALIMAT_HESABI,Guid.Empty);
            if (ds.Tables[0].Rows.Count > 0)
            {
                new_RecipientCorparationAccountId.TotalCount = ds.Tables[0].Rows.Count;
                new_RecipientCorparationAccountId.DataSource = ds.Tables[0];
                new_RecipientCorparationAccountId.DataBind();
            }

            
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, action, "Exception");
        }
    }

    protected void newOfficeLoad(object sender, AjaxEventArgs e)
    {
        try
        {
            string strSql = @"SELECT 
                                O.New_OfficeId ID,
	                            O.OfficeName VALUE,
	                            O.new_CorporationID,
	                            O.new_CorporationIDName,
                                O.New_OfficeId,
                                O.OfficeName,
	                            O.new_CountryID,
	                            O.new_CountryIDName,
	                            new_StateId,
	                            new_StateIdName,
	                            new_CityId,
	                            new_CityIdName,
                                new_Adress,
                                new_ZipCode,
	                            new_Telephone,
	                            new_BrandId,
	                            new_BrandIdName,
	                            new_OwnOfficeCode,
	                            new_ReferenceCode,
	                            new_RefId,
	                            new_BranchNo,
                                new_BDDKCode,
                                new_BrandIdName
                            From  nltvNew_Office(@SystemUserId) O
                            WHERE DeletionStateCode=0 
                                    AND EXISTS(SELECT 1 FROM vNew_CloudAccountTransaction A (NoLock) 
                                                WHERE A.new_OfficeId = O.New_OfficeId)
                            ORDER BY O.OfficeName asc";

            StaticData sd = new StaticData();
            sd.ClearParameters();
            sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId));
            DataSet ds = sd.ReturnDataset(strSql);
            if (ds.Tables[0].Rows.Count > 0)
            {
                //new_OfficeId.TotalCount = ds.Tables[0].Rows.Count;
                //new_OfficeId.DataSource = ds.Tables[0];
                //new_OfficeId.DataBind();
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.CloudAccountTransaction.CloudAccountTransactionList.newOfficeLoad", "Exception");
        }
    }



    protected void btnNewRecord_Click(object sender, AjaxEventArgs e)
    {

        try
        {
            Guid transactionId;
            int transactionType;
            int corporateTypeId;
            Guid systemUserId = App.Params.CurrentUser.SystemUserId;

            BasePage.QScript("var url = window.top.GetWebAppRoot + '/ISV/TU/SweepInstructions/SweepInstructionsListDetail.aspx?ObjectId=202000056&islemTip=yeniKayit" +
                             "&gridpanelid=GridPanelMonitoring&PoolId=3'; window.top.newWindowRefleX(url, { maximized: false, width: 800, height: 550, resizable: true, modal: true, maximizable: false });");

            //var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            //ms.Show(".", "İlgili işlem onaylandı.");

        }
        catch (Exception ex)
        {

            var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", "Hata!! İşlem Yapılamadı");

            LogUtil.WriteException(ex, "SweepInstructionsList.btnNewRecord_Click", "Exception");
            throw ex;
        }


        //GridPanelConfirmHistory.DataBind();
    }

    protected void GpCorporatedPreInfoListReload(object sender, AjaxEventArgs e)
    {
        

        var sd = new StaticData();
        var sort = GridPanelCloudAccountTransactionList.ClientSorts() ?? string.Empty;

        string strSql;
        


            strSql = @"SELECT  
	                        S.New_SweepInstructionsId Id,
                            null VALUE,
	                        S.CreatedByName Olusturan,
	                        S.ModifiedByName Duzenleyen,
                            FORMAT(dbo.fnUTCToLocalTimeForUser(S.CreatedOn,@SystemuserId),'dd.MM.yyyy HH:mm:ss') CreatedOnUtcTime,
                            FORMAT(dbo.fnUTCToLocalTimeForUser(S.ModifiedOn,@SystemuserId),'dd.MM.yyyy HH:mm:ss') ModifiedTime,
                            SIS.Label StatusLabel,
                            SIC.Label ConfirmStatusLabel,
                            SIB.Label SweepBalanceLabel,
                            SIT.Label SweepTypeLabel,
                            STT.Label TransferTimeLabel,
                             CAST(S.new_SweepHour AS nvarchar(10)) + ':' + CAST(S.new_SweepMinute AS nvarchar(10)) SweepTime,
                            S.*,
							C.new_CorporationCode,
							C.CorporationName
                        FROM vNew_SweepInstructions S (NoLock)
                        LEFT OUTER JOIN vNew_Corporation C (NoLock) ON C.New_CorporationId = S.new_CorporationId
                        LEFT OUTER JOIN new_PLNew_SweepInstructions_new_InstructionsConfirmStatus SIC (NOLOCK) ON SIC.Value = S.new_InstructionsConfirmStatus AND SIC.LangId = 1055
                        LEFT OUTER JOIN new_PLNew_SweepInstructions_new_InstructionsStatus SIS (NOLOCK) ON SIS.Value = S.new_InstructionsStatus AND SIS.LangId = 1055
                        LEFT OUTER JOIN new_PLNew_SweepInstructions_new_SweepBalance SIB (NOLOCK) ON SIB.Value = S.new_SweepBalance AND SIB.LangId = 1055
                        LEFT OUTER JOIN new_PLNew_SweepInstructions_new_SweepType SIT (NOLOCK) ON SIT.Value = S.new_SweepType AND SIT.LangId = 1055
                        LEFT OUTER JOIN new_PLNew_SweepInstructions_new_TransferTime STT (NOLOCK) ON STT.Value = S.new_TransferTime AND STT.LangId = 1055
                        WHERE 1=1
	                        AND S.DeletionStateCode = 0 ";

       

        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];


        //var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("vSweepInstructionsMain");
        var spList = new List<CrmSqlParameter>();


        if (!string.IsNullOrEmpty(new_CorporationId.Value))
        {
            strSql += " AND S.new_CorporationId = @new_CorporationId ";
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
            strSql += " AND S.new_SenderAccountId = @new_SenderAccountId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_SenderAccountId",
                    Value = ValidationHelper.GetGuid(new_SenderAccountId.Value)
                }
                );
        }


        if (!string.IsNullOrEmpty(new_RecipientCorparationAccountId.Value))
        {
            strSql += " AND S.new_RecipientCorparationAccountId = @new_RecipientCorparationAccountId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_RecipientCorparationAccountId",
                    Value = ValidationHelper.GetGuid(new_RecipientCorparationAccountId.Value)
                }
                );
        }

        if (new_InstructionsStatus.Checked)
        {
            strSql += " AND isnull(S.new_InstructionsStatus,0) = 0 ";
        }else
        {
            strSql += " AND isnull(S.new_InstructionsStatus,0) = 1 ";
        }


        //if (!string.IsNullOrEmpty(new_Status.Value))
        //{
        //    strSql += " AND A.new_Status=@new_Status ";
        //    spList.Add(
        //        new CrmSqlParameter
        //        {
        //            Dbtype = DbType.Int32,
        //            Paramname = "new_Status",
        //            Value = ValidationHelper.GetInteger(new_Status.Value)
        //        }
        //        );
        //}


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