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

public partial class SweepInstructionsLogList : BasePage
{
    MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };

    SweepInstructionsFactory fac = new SweepInstructionsFactory();

    protected void Page_Load(object sender, EventArgs e)
    {
        hdnRecId.Value = QueryHelper.GetString("RecordId");

        if (!RefleX.IsAjxPostback)
        {

            RR.RegisterIcon(Icon.Add);
            AddMessages();
            SetDefaults();
            GpCorporatedPreInfoListReload(null, null);
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
        


            strSql = @"select 
                            SIL.New_SweepInstructionsLogId Id,
                            SIL.*,
                            SNT.Label TransactionCodeLabel,
                            FORMAT(dbo.fnUTCToLocalTimeForUser(SIL.CreatedOn,@SystemuserId),'dd.MM.yyyy HH:mm:ss') CreatedOnUtcTime,
                            FORMAT(dbo.fnUTCToLocalTimeForUser(SIL.ModifiedOn,@SystemuserId),'dd.MM.yyyy HH:mm:ss') ModifiedTime
                       from vNew_SweepInstructionsLog SIL (NoLock)
                       INNER JOIN new_PLNew_SweepInstructionsLog_new_TransactionCode SNT (NOLOCK) ON SNT.Value = SIL.new_TransactionCode AND SNT.LangId = 1055 
                       WHERE SIL.DeletionStateCode = 0 
                            AND SIL.new_SweepInstructionsId = @new_SweepInstructionsId ";

       

        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];


        //var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("vSweepInstructionsLog");
        var spList = new List<CrmSqlParameter>();


        spList.Add(
            new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "new_SweepInstructionsId",
                Value = ValidationHelper.GetGuid(hdnRecId.Value)
            }
            );

 

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