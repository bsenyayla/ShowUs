using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;

public partial class Operation_Detail_MonitoringDetail : BasePage
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            pnl1.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_SEARCH");
            btnDownload.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
            CreateViewGrid();
        }

    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("PROCESSMONITORING_DETAIL", GridPanelMonitoring);
        string strSelected;
        strSelected = ViewFactory.GetViewIdbyUniqueName("PROCESSMONITORING_DETAIL").ToString();
        hdnViewList.Value = strSelected;

        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
        var DefaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnViewDefaultEditPage.Value = DefaultEditPage;


    }
    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        var sd = new StaticData();
        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;
        string strSql = @"
        	Select Mt.ProcessMonitoring AS VALUE ,Mt.New_ProcessMonitoringId AS ID ,Mt.ProcessMonitoring,Mt.new_TransactionItemId,Mt.new_TransactionItemIdName,
hi.CreatedOn new_TransactionDate,hi.CreatedOnUtcTime new_TransactionDateUtcTime ,
Mt.new_TransactionAmount,Mt.new_TransactionAmountCurrencyName AS new_TransactionAmount_CurrencyName,Mt.new_TransactionAmountCurrency,Mt.new_TransactionAmountCurrencyName,Mt.new_CostAmount,Mt.new_CostAmountCurrencyName AS new_CostAmount_CurrencyName,Mt.new_CostAmountCurrency,Mt.new_CostAmountCurrencyName,Mt.new_SenderId,Mt.new_SenderIdName,Mt.new_SenderNumber,Mt.new_SenderIdentificationCardNumber,Mt.new_RecipientFullName,Mt.new_RecipientCountry,Mt.new_RecipientCountryName,hi.OwningUser,hi.OwningUserName,ObjectId 
, Mt.new_TransactionConfirmId,
Mt.new_TransactionConfirmIdName,
Mt.new_OperationType,
Mt.new_OperationTypeName,
hi.new_ConfirmStatusId as new_ConfirmStatus,
hi.new_ConfirmStatusIdName as new_ConfirmStatusName,
Mt.new_SourceTransactionTypeID,
Mt.new_SourceTransactionTypeIDName,
Mt.new_TargetTransactionTypeID,
Mt.new_TargetTransactionTypeIDName,
Mt.new_ReceivedAmount1,
Mt.new_ReceivedAmount1Currency,
Mt.new_ReceivedAmount1CurrencyName,
Mt.new_ReceivedAmount2,
Mt.new_ReceivedAmount2Currency,
Mt.new_ReceivedAmount2CurrencyName,
Mt.new_TotalReceivedAmount,
Mt.new_TotalReceivedAmountCurrency,
Mt.new_TotalReceivedAmountCurrencyName,
Mt.new_ReceivedAmount1CurrencyName as new_ReceivedAmount1_CurrencyName,
Mt.new_ReceivedAmount2CurrencyName as new_ReceivedAmount2_CurrencyName,
Mt. new_TotalReceivedAmountCurrencyName as new_TotalReceivedAmount_CurrencyName
from  dbo.tvNew_ProcessMonitoring(@SystemUserId) as Mt
INNER JOIN tvNew_TarnsactionHistory(@SystemUserId) as hi (NOLOCK) on hi.new_PaymentId=mt.New_ProcessMonitoringId OR hi.new_TransferId=mt.New_ProcessMonitoringId
            Where 1=1
        ";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("PROCESSMONITORING_DETAIL");
        var spList = new List<CrmSqlParameter>();
        if (new_Country.Value != "")
        {
            strSql += " And new_Country=@new_Country";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_Country",
                Value = ValidationHelper.GetGuid(new_Country.Value)
            });
        }
        if (new_CorporationId.Value != "")
        {
            strSql += " And new_CorporationId=@new_CorporationId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_CorporationId",
                Value = ValidationHelper.GetGuid(new_CorporationId.Value)
            });
        }
        if (new_OfficeId.Value != "")
        {
            strSql += " And new_OfficeId=@new_OfficeId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_OfficeId",
                Value = ValidationHelper.GetGuid(new_OfficeId.Value)
            });
        }
        if (new_FormTransactionDate1.Value != null)
        {

            strSql += " And new_TransactionDateUtcTime>=@new_FormTransactionDate1";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "new_FormTransactionDate1",
                Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_FormTransactionDate1.Value), App.Params.CurrentUser.SystemUserId)
            });
        }
        if (new_FormTransactionDate2.Value != null)
        {
            strSql += " And new_TransactionDateUtcTime<(@new_FormTransactionDate2)";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "new_FormTransactionDate2",
                Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_FormTransactionDate2.Value).AddDays(1), App.Params.CurrentUser.SystemUserId)
            });
        }
        if (new_FormAmount1.Value != null)
        {
            strSql += " And new_TransactionAmount>=@new_FormAmount1";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Decimal,
                Paramname = "new_FormAmount1",
                Value = ValidationHelper.GetDecimal(new_FormAmount1.Value, 0)
            });
        }
        if (new_FormAmount2.Value != null)
        {
            strSql += " And new_TransactionAmount<=@new_FormAmount2";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Decimal,
                Paramname = "new_FormAmount2",
                Value = ValidationHelper.GetDecimal(new_FormAmount2.Value, 0)
            });
        }
        if (new_FormTransactionAmountCurrency.Value != "")
        {
            strSql += " And new_TransactionAmountCurrency=@new_FormTransactionAmountCurrency";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormTransactionAmountCurrency",
                Value = ValidationHelper.GetGuid(new_FormTransactionAmountCurrency.Value)
            });
        }
        if (new_FormTransactionTypeID.Value != "")
        {
            strSql += " And new_TargetTransactionTypeID=@new_FormTransactionTypeID";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormTransactionTypeID",
                Value = ValidationHelper.GetGuid(new_FormTransactionTypeID.Value)
            });
        }
        if (new_FormCustomerNumber.Value != "")
        {
            strSql += " And new_SenderIdentificationCardNumber=@new_FormCustomerNumber";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_FormCustomerNumber",
                Value = ValidationHelper.GetString(new_FormCustomerNumber.Value)
            });
        }
        if (new_FormReceiverCountryId.Value != "")
        {
            strSql += " And new_RecipientCountry=@new_FormReceiverCountryId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormReceiverCountryId",
                Value = ValidationHelper.GetGuid(new_FormReceiverCountryId.Value)
            });
        }
        if (ProcessMonitoring.Value != "")
        {
            strSql += " And MT.ProcessMonitoring like '%'+@ProcessMonitoring +'%'";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "ProcessMonitoring",
                Value = ValidationHelper.GetString(ProcessMonitoring.Value)
            });
        }
        if (new_SenderId.Value != "")
        {
            strSql += " And MT.new_SenderId=@new_SenderId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_SenderId",
                Value = ValidationHelper.GetGuid(new_SenderId.Value)
            });
        }
        var gpc = new GridPanelCreater();


        var cnt = 0;
        var start = GridPanelMonitoring.Start();
        var limit = GridPanelMonitoring.Limit();
        var dtb = new DataTable();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
        GridPanelMonitoring.TotalCount = cnt;

        List<string> fields = new List<string>() { "new_RecipientFullName" };
        t = cryptor.DecryptFieldsInFilterData(fields, t);

        try
        {
            if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            {
                var gpw = new GridPanelView(0, ValidationHelper.GetGuid(hdnViewList.Value));
                gpw.Export(dtb);

            }

        }
        catch (Exception)
        {

            throw;
        } 
        GridPanelMonitoring.DataSource = t;
        GridPanelMonitoring.DataBind();

    }


}