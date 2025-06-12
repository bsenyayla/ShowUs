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

public partial class SweepInstructionsHistoryList : BasePage
{
    MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };

    SweepInstructionsFactory fac = new SweepInstructionsFactory();

    protected void Page_Load(object sender, EventArgs e)
    {

        hdnRecId.Value = QueryHelper.GetString("RecordId");
        GpCorporatedPreInfoListReload(null, null);

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
                            SIB.Label SweepBalanceLabel,
                            SIT.Label SweepTypeLabel,
                            STT.Label TransferTimeLabel,
                            HTT.Label HistoryLabel,
                             CAST(S.new_SweepHour AS nvarchar(10)) + ':' + CAST(S.new_SweepMinute AS nvarchar(10)) SweepTime,
                            S.*   
                        FROM vNew_SweepInstructionsHistory S (NoLock)
                        LEFT OUTER JOIN new_PLNew_SweepInstructions_new_InstructionsStatus SIS (NOLOCK) ON SIS.Value = S.new_InstructionsStatus AND SIS.LangId = 1055
                        LEFT OUTER JOIN new_PLNew_SweepInstructions_new_SweepBalance SIB (NOLOCK) ON SIB.Value = S.new_SweepBalance AND SIB.LangId = 1055
                        LEFT OUTER JOIN new_PLNew_SweepInstructions_new_SweepType SIT (NOLOCK) ON SIT.Value = S.new_SweepType AND SIT.LangId = 1055
                        LEFT OUTER JOIN new_PLNew_SweepInstructions_new_TransferTime STT (NOLOCK) ON STT.Value = S.new_TransferTime AND STT.LangId = 1055
                        LEFT OUTER JOIN new_PLNew_SweepInstructionsHistory_new_HistoryType HTT (NOLOCK) ON HTT.Value = S.new_HistoryType AND HTT.LangId = 1055
                        WHERE 1=1
	                        AND S.DeletionStateCode = 0 ";

       

        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];


        //var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("vSweepInstructionsMain");
        var spList = new List<CrmSqlParameter>();


  
            strSql += " AND S.new_SweepInstructionsId = @new_SweepInstructionsId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_SweepInstructionsId",
                    Value = ValidationHelper.GetGuid(hdnRecId.Value)
                }
                );
      
 


        //strSql += " order by A.new_CloudPaymentDate DESC ";

        DataTable dt = new DataTable();
        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelCloudAccountTransactionList.Start();
        var limit = GridPanelCloudAccountTransactionList.Limit();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dt);
        GridPanelCloudAccountTransactionList.TotalCount = cnt;

        //if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        //{
        //    var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
        //    gpw.Export(dt);
        //}


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