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

public partial class SenderBlockedList : BasePage
{


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
        mfsender.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_SenderId",
            TuEntityEnum.New_CustAccountOperations.GetHashCode());
        var Messages = new
        {
            NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM"),
            NEW_CUSTACCOUNTOPERATION_SURE_REJECT = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_REJECT")
        };
        RegisterClientScriptBlock("DasMessages", string.Format("var DasMessages={0};", JsonConvert.SerializeObject(Messages)));

        new_CustomerType.EmptyText =
        new_SenderId.EmptyText =
        new_CustomerType.EmptyText =
        new_CustomerType.EmptyText =
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


    protected void btnAddCorporateEditUpdate_Click(object sender, AjaxEventArgs e)
    {

        var query = new Dictionary<string, string>
        {
            {"ObjectId", "201900037"},
            {"fromCustomerAccountScreen", "1"},
            {"gridpanelid", ""},
            {
                "defaulteditpageid", "F2CCC69F-0E4C-481F-846A-F76F96AEC69C         "
            },
            { "SourceForm", "CustomerAccount" }
        };

        var urlparam = QueryHelper.RefreshUrl(query);
        QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/CrmPages/AutoPages/EditReflex.aspx" + urlparam + "', { maximized: false, width: 950, height: 400, resizable: true, modal: true, maximizable: false });");
    }

    protected void btnAddCorporatePersonEditUpdate_Click(object sender, AjaxEventArgs e)
    {
        //string recId = blockedId.Value;
        string recId = "";
        string url = "ISV/TU/Sender/SenderBlocked/SenderPersonBlockedForm.aspx?SourceForm=CustomerAccount&fromCustomerAccountScreen=2&RecordId=" + recId; 
        //var urlparam = QueryHelper.RefreshUrl(query);
        QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '" + url  + "', { maximized: false, width: 950, height: 400, resizable: true, modal: true, maximizable: false });");
    }

    protected void GpCorporateBlockedListReload(object sender, AjaxEventArgs e)
    {
        

        var sd = new StaticData();
        var sort = GridPanelCorporateBlockedList.ClientSorts() ?? string.Empty;
        string strSql = @" SELECT *
                            FROM fnTuGetSenderAndPersonBlockedList(@SystemUserId) tnr 
					        WHERE 1=1 ";

        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];


        var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var spList = new List<CrmSqlParameter>();

        spList.Add(
            new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "SystemUserId",
                Value = ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId)
            }
            );


        if (!string.IsNullOrEmpty(new_CustomerType.Value))
        {
            strSql += " AND tnr.CorporateType=@CorporateType ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Int32,
                    Paramname = "CorporateType",
                    Value = ValidationHelper.GetInteger(new_CustomerType.Value)
                }
                );
        }


        if (!string.IsNullOrEmpty(new_TransactionType.Value))
        {
            strSql += " AND tnr.TransactionType=@TransactionType ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Int32,
                    Paramname = "TransactionType",
                    Value = ValidationHelper.GetInteger(new_TransactionType.Value)
                }
                );
        }

        if (!string.IsNullOrEmpty(new_SenderId.Value))
        {
            strSql += " AND tnr.SenderId = @new_SenderId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_SenderId",
                    Value = ValidationHelper.GetGuid(new_SenderId.Value)
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

        strSql += " ORDER BY tnr.CreatedOn DESC ";

        foreach (var crmSqlParameter in spList)
        {
            sd.AddParameter(crmSqlParameter.Paramname, crmSqlParameter.Dbtype, crmSqlParameter.Value);
        }

        DataTable dt = sd.ReturnDataset(strSql).Tables[0];

        GridPanelCorporateBlockedList.TotalCount = dt.Rows.Count;
        GridPanelCorporateBlockedList.DataSource = dt;
        GridPanelCorporateBlockedList.DataBind();


    }
    









}