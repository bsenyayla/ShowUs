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

public partial class SweepInstructionsLogListDetail : BasePage
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
            newOfficeLoad(null, null);
        }
       
    }
    private TuUser _activeUser;

    private void SetDefaults()
    {
        var ufFactory = new TuUserFactory();
        _activeUser = ufFactory.GetActiveUser();

        cloudPaymentDateS.SetIValue(DateTime.Now.ToString("dd.MM.yyyy") + " 00:00:00");
        cloudPaymentDateE.SetIValue(DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss"));
    }

    private void AddMessages()
    {
        New_SweepInstructionsId.FieldLabel = "Süpürme Talimatı";
        New_SweepInstructionsTransactionIdText.FieldLabel = "İşlem No";

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
        if ( ValidationHelper.GetGuid( New_SweepInstructionsId.Value ) == Guid.Empty)
        {
            ShowMessage("Süpürme Talimatı seçmelisiniz!");
            GridPanelCloudAccountTransactionList.DataBind();
            return;
        }

        if ( cloudPaymentDateS.Value == null)
        {
            ShowMessage("Başlangıç tarihi seçmelisiniz!");
            GridPanelCloudAccountTransactionList.DataBind();
            return;
        }

        if (cloudPaymentDateE.Value == null)
        {
            ShowMessage("Bitiş tarihi seçmelisiniz!");
            GridPanelCloudAccountTransactionList.DataBind();
            return;
        }

        var sd = new StaticData();
        var sort = GridPanelCloudAccountTransactionList.ClientSorts() ?? string.Empty;

        string strSql;

        strSql = @"select 
                            SIL.New_SweepInstructionsLogId Id,
                            null VALUE,
                            SIL.*,
                            V.ReferenceNo VirmanNo,
                            SNT.Label TransactionCodeLabel,
                            FORMAT(dbo.fnUTCToLocalTimeForUser(SIL.CreatedOn, @SystemuserId), 'dd.MM.yyyy HH:mm:ss') CreatedOnUtcTime,
                            FORMAT(dbo.fnUTCToLocalTimeForUser(SIL.ModifiedOn, @SystemuserId), 'dd.MM.yyyy HH:mm:ss') ModifiedTime
                         from vNew_SweepInstructionsLog SIL (NoLock)
                         INNER JOIN new_PLNew_SweepInstructionsLog_new_TransactionCode SNT(NOLOCK) ON SNT.Value = SIL.new_TransactionCode AND SNT.LangId = 1055
                         LEFT OUTER JOIN vNew_Virman V (NoLock) ON V.New_VirmanId = SIL.new_VirmanId
                         WHERE SIL.DeletionStateCode = 0 ";

        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];


        //var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("vSweepInstructionsMain");
        var spList = new List<CrmSqlParameter>();

        if (!string.IsNullOrEmpty(New_SweepInstructionsId.Value))
        {
            strSql += " AND SIL.New_SweepInstructionsId = @New_SweepInstructionsId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "New_SweepInstructionsId",
                    Value = ValidationHelper.GetGuid(New_SweepInstructionsId.Value)
                }
                );
        }


        if (!string.IsNullOrEmpty(New_SweepInstructionsTransactionIdText.Value))
        {
            strSql += " AND SIL.New_SweepInstructionsTransactionIdName = @New_SweepInstructionsTransactionIdName ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.String,
                    Paramname = "New_SweepInstructionsTransactionIdName",
                    Value = ValidationHelper.GetString(New_SweepInstructionsTransactionIdText.Value)
                }
                );
        }

        if (!string.IsNullOrEmpty(new_TransactionCode.Value))
        {
            strSql += " AND SIL.new_TransactionCode = @new_TransactionCode ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Int32,
                    Paramname = "new_TransactionCode",
                    Value = ValidationHelper.GetInteger(new_TransactionCode.Value)
                }
                );
        }

        if (cloudPaymentDateS.Value.HasValue)
        {
            strSql += " AND CAST(CONVERT(varchar,SIL.CreatedOn,23) AS datetime) >= @cloudPaymentDateS ";
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
            strSql += " AND CAST(CONVERT(varchar,SIL.CreatedOn,23) AS datetime) <=  @cloudPaymentDateE ";
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

    void ShowMessage(string messageText)
    {
        MessageBox messageBox = new MessageBox();
        messageBox.Width = 400;
        messageBox.Height = 200;
        messageBox.Show(messageText);
    }





}