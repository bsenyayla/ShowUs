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

public partial class CorporatedPreInfoList : BasePage
{
    MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };

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
        CreatedOnS.Value = DateTime.Now.Date;
        CreatedOnE.Value = DateTime.Now.Date;
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

        new_New_CorporatedType.EmptyText =
        new_CorparateCentralRegistryServiceNumber.EmptyText =
        new_New_CorporatedType.EmptyText =
        new_StatusId.EmptyText =
        new_StatusId.EmptyText =
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


    protected void GpCorporatedPreInfoListReload(object sender, AjaxEventArgs e)
    {
        

        var sd = new StaticData();
        var sort = GridPanelCorporatedPreInfoList.ClientSorts() ?? string.Empty;

        

        string strSql = @" SELECT tnr.New_CorporatedPreInfoId Id,
                                    tnr.CorparateName,
                                    tnr.new_UserNameSurname,
                                    tnr.new_MobilePhone,
                                    tnr.new_EMail,
                                    tnr.new_CorparateTaxNo,
                                    tnr.new_StatusId,
                                    STT.Label new_StatusIdName,
                                    FORMAT(dbo.fnUTCToLocalTimeForUser(TNR.CreatedOn,@SystemuserId),'dd.MM.yyyy') CreatedOnUtcTime,
                                    new_New_CorporatedTypeName,
                                    tnr.CreatedOn
                            FROM vNew_CorporatedPreInfo(NoLock) tnr 
                            INNER JOIN new_PLNew_CorporatedPreInfo_new_StatusId (NoLock) STT 
                                                ON STT.LangId = 1055 
                                                and STT.Value = TNR.new_StatusId
					        WHERE 1=1 ";

        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];


        //var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("ViewCorporatedPreInfoList");
        var spList = new List<CrmSqlParameter>();

        if (!string.IsNullOrEmpty(new_New_CorporatedType.Value))
        {
            strSql += " AND tnr.new_New_CorporatedType=@new_New_CorporatedType ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Int32,
                    Paramname = "CorporateType",
                    Value = ValidationHelper.GetInteger(new_New_CorporatedType.Value)
                }
                );
        }


        if (!string.IsNullOrEmpty(new_StatusId.Value))
        {
            strSql += " AND tnr.new_StatusId=@new_StatusId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Int32,
                    Paramname = "new_StatusId",
                    Value = ValidationHelper.GetInteger(new_StatusId.Value)
                }
                );
        }

        if (!string.IsNullOrEmpty(new_CorparateCentralRegistryServiceNumber.Value))
        {
            strSql += " AND tnr.new_CorparateCentralRegistryServiceNumber LIKE @new_CorparateCentralRegistryServiceNumber ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.String,
                    Paramname = "new_CorparateCentralRegistryServiceNumber",
                    Value = ValidationHelper.GetGuid(new_CorparateCentralRegistryServiceNumber.Value)
                }
                );
        }

        
        if (CreatedOnS.Value.HasValue)
        {
            strSql += " AND tnr.CreatedOn>=@CreatedOns";
            var CreatedOnSs = sd.FnLocalTimeToUtcForUser(CreatedOnS.Value.Value, App.Params.CurrentUser.SystemUserId);
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Date,
                    Paramname = "CreatedOns",
                    Value = CreatedOnSs
                }
                );
        }
        if (CreatedOnE.Value.HasValue)
        {
            var CreatedOnEe = sd.FnLocalTimeToUtcForUser(CreatedOnE.Value.Value, App.Params.CurrentUser.SystemUserId);

            strSql += " AND tnr.CreatedOn<=DATEADD(day,1,@CreatedOnE)";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Date,
                    Paramname = "CreatedOnE",
                    Value = CreatedOnEe
                }
                );
        }
        


        //foreach (var crmSqlParameter in spList)
        //{
        //    sd.AddParameter(crmSqlParameter.Paramname, crmSqlParameter.Dbtype, crmSqlParameter.Value);
        //}

        //DataTable dt = sd.ReturnDataset(strSql).Tables[0];

        //GridPanelCorporatedPreInfoList.TotalCount = dt.Rows.Count;
        //GridPanelCorporatedPreInfoList.DataSource = dt;
        //GridPanelCorporatedPreInfoList.DataBind();


        //strSql += " ORDER BY tnr.CreatedOn desc ";

        DataTable dt = new DataTable();
        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelCorporatedPreInfoList.Start();
        var limit = GridPanelCorporatedPreInfoList.Limit();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dt);
        GridPanelCorporatedPreInfoList.TotalCount = cnt;

        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
            gpw.Export(dt);
        }


        GridPanelCorporatedPreInfoList.DataSource = t;
        GridPanelCorporatedPreInfoList.DataBind();

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