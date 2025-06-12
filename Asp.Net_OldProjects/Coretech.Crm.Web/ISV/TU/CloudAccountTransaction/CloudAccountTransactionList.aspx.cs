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

public partial class CloudAccountTransactionList : BasePage
{
    MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };

    

    protected void Page_Load(object sender, EventArgs e)
    {
        
        if (!RefleX.IsAjxPostback)
        {
            RR.RegisterIcon(Icon.Add);
            AddMessages();
            SetDefaults();
            newOfficeLoad(null, null);
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

        new_OfficeId.EmptyText =
         CrmLabel.TranslateMessage("CRM.ENTITY_FILTER_EMPTY_TEXT");
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
                            WHERE O.DeletionStateCode=0 
                                AND O.new_CloudFirmCode is not null 
                                AND O.statuscode = 1
                                    /* N KOLAY ÖN YÜZÜNÜ KULLANAN BAYİLER listeye gelmesin */
                                and NOT EXISTS (SELECT 1 FROM vNew_Office OFC WHERE OFC.New_OfficeId = O.new_ParentOfficeID 
                                                AND OFC.DeletionStateCode = 0 AND OFC.new_OwnOfficeCode = 'OFF6873878') ";

            string searchtext = this.Context.Items["query"] != null ? this.Context.Items["query"].ToString() : "";

            if (!string.IsNullOrEmpty(searchtext))
                strSql += " AND O.OfficeName LIKE '%" + searchtext + "%'";


            strSql += " ORDER BY O.OfficeName asc ";

            StaticData sd = new StaticData();
            sd.ClearParameters();
            sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId));
            DataSet ds = sd.ReturnDataset(strSql);
            if (ds.Tables[0].Rows.Count > 0)
            {
                new_OfficeId.TotalCount = ds.Tables[0].Rows.Count;
                new_OfficeId.DataSource = ds.Tables[0];
                new_OfficeId.DataBind();
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

    protected void GpCorporatedPreInfoListReload(object sender, AjaxEventArgs e)
    {
        

        var sd = new StaticData();
        var sort = GridPanelCloudAccountTransactionList.ClientSorts() ?? string.Empty;

        string strSql;
        


            strSql = @"SELECT  
	                        A.New_CloudAccountTransactionId Id,
                            null VALUE,
	                        A.Reference ReferenceNo,
                            V.ReferenceNo VirmanReferenceNo,
                            FORMAT(A.new_CloudPaymentDate,'dd.MM.yyyy HH:mm:ss') CloudPaymentDateUtcTime,
                            dbo.fn_FormatWithCommas(A.new_Amount,2) Amount,
	                        O.new_CorporationID,
	                        O.new_CorporationIDName,
                            STT.Label new_ErrorStatusName,
                            STT.Label ErrorStatusLabel,
                            CPT.Label StatusLabel,
	                        A.CreatedByName Olusturan,
	                        A.ModifiedByName Duzenleyen,
                            FORMAT(dbo.fnUTCToLocalTimeForUser(A.CreatedOn,@SystemuserId),'dd.MM.yyyy HH:mm:ss') CreatedOnUtcTime,
                            FORMAT(dbo.fnUTCToLocalTimeForUser(A.ModifiedOn,@SystemuserId),'dd.MM.yyyy HH:mm:ss') ModifiedTime,
                            A.*   
                        FROM vNew_CloudAccountTransaction A (NoLock)
                        LEFT JOIN new_PLNew_CloudAccountTransaction_new_ErrorStatus STT (NOLOCK) ON STT.VALUE = A.new_ErrorStatus AND STT.LangId = 1055
                        LEFT JOIN new_PLNew_CloudAccountTransaction_new_CloudPaymentStatus CPT (NOLOCK) ON CPT.VALUE = A.new_CloudPaymentStatus AND CPT.LangId = 1055
                        LEFT JOIN vNew_Office O (NoLock) ON O.New_OfficeId = A.new_OfficeId
                        LEFT JOIN vNew_Virman V (NoLock) ON V.New_VirmanId = A.new_VirmanId 
                        WHERE 1=1
	                        AND A.DeletionStateCode = 0 ";

       

        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];


        //var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("vCloudAccountTransaction");
        var spList = new List<CrmSqlParameter>();

        if (!string.IsNullOrEmpty(new_OfficeId.Value))
        {
            strSql += " AND A.new_OfficeId = @new_OfficeId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_OfficeId",
                    Value = ValidationHelper.GetGuid(new_OfficeId.Value)
                }
                );
        }

        if (!string.IsNullOrEmpty(new_SenderFullName.Value))
        {
            strSql += " AND A.new_SenderFullName = @new_SenderFullName ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.String,
                    Paramname = "new_SenderFullName",
                    Value = ValidationHelper.GetString(new_SenderFullName.Value)
                }
                );

        }

        if (!string.IsNullOrEmpty(new_SenderIban.Value))
        {
            strSql += " AND A.new_SenderIban = @new_SenderIban ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.String,
                    Paramname = "new_SenderIban",
                    Value = ValidationHelper.GetString(new_SenderIban.Value)
                }
                );

        }

        if (!string.IsNullOrEmpty(ReferenceNo.Value))
        {
            strSql += " AND A.Reference = @ReferenceNo ";
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
            strSql += " AND isnull(A.new_ErrorStatus,-1) > 1 ";
        }

        if (new_IsNkolayRepresentative.Checked)
        {
            strSql += " AND isnull(A.new_IsNkolayRepresentative,0) = 1 ";
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

        if (cloudPaymentDateS.Value.HasValue)
        {
            strSql += " AND CAST(CONVERT(varchar,A.new_CloudPaymentDate,23) AS datetime) >= @cloudPaymentDateS ";
            //var CreatedOnSs = sd.FnLocalTimeToUtcForUser(CreatedOnS.Value.Value, App.Params.CurrentUser.SystemUserId);
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
            //var CreatedOnEe = sd.FnLocalTimeToUtcForUser(CreatedOnE.Value.Value, App.Params.CurrentUser.SystemUserId);

            //strSql += " AND A.CreatedOn<=DATEADD(day,1,@CreatedOnE)";
            strSql += " AND CAST(CONVERT(varchar,A.new_CloudPaymentDate,23) AS datetime) <=  @cloudPaymentDateE ";
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