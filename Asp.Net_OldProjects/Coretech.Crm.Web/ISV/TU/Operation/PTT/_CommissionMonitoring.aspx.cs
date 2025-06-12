using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Info;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;

public partial class Operation_PTT_Commission_Monitoring : BasePage
{
    private TuUser _activeUser = null;
    private DynamicSecurity _dynamicSecurityPayment;
    private DynamicSecurity _dynamicSecurityTransfer;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private TuUserApproval _userApproval = null;
   
    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("COMMISSIONMONITORING", GridPanelMonitoring);
        string strSelected = ViewFactory.GetViewIdbyUniqueName("COMMISSIONMONITORING").ToString();
        hdnViewList.Value = strSelected;

        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
        var defaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnViewDefaultEditPage.Value = defaultEditPage;

        gpc.CreateViewGrid("COMMISSIONMONITORING_TOTALS", GridPanelTotal);
        string strSelected1 = ViewFactory.GetViewIdbyUniqueName("COMMISSIONMONITORING_TOTALS").ToString();
        hdnViewListTotal.Value = strSelected1;

        gpc.CreateViewGrid("COMMISSIONMONITORING_SUMMARY", GridPanelCommmissionTotal);
        string strSelected2 = ViewFactory.GetViewIdbyUniqueName("COMMISSIONMONITORING_SUMMARY").ToString();
        hdnViewListCommissionTotal.Value = strSelected2;
    }

    protected void BtnHoldClick(object sender, AjaxEventArgs e)
    {
        HoldResume(ETuHoldResume.Hold);


    }

    protected void btnInformationOnEvent(object sender, AjaxEventArgs e)
    {
        var infoList = Info.GetEntityHelpsByName("COMMISSIONMONITORING", this);
        if (infoList == null) return;
        var b = HttpContext.Current;
        b.Response.ClearContent();
        b.Response.ClearHeaders();
        b.Response.Clear();
        var f = new FileInfo(Server.MapPath(infoList.Command));
        var fs = File.Open(Server.MapPath(infoList.Command), FileMode.Open);

        var ms = new MemoryStream();
        fs.CopyTo(ms);

        var buffer = ms.ToArray();

        b.Response.AddHeader("Content-Disposition", string.Format(CultureInfo.InvariantCulture, "attachment; filename=\"{0}\"", new object[] { f.Name }));
        var length = buffer.Length;
        b.Response.AddHeader("ContentLength", length.ToString(CultureInfo.InvariantCulture));
        if (buffer.Length > 0)
        {
            b.Response.BinaryWrite(buffer);
        }
        b.Response.Flush();
    }

    protected void BtnResumeClick(object sender, AjaxEventArgs e)
    {
        HoldResume(ETuHoldResume.Resume);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        _activeUser = ufFactory.GetActiveUser();
        if (!RefleX.IsAjxPostback)
        {

            TranslateMessages();
            CreateViewGrid();
            FillSecurity();
            //if (!_dynamicSecurityTransfer.PrvCreate)
            //    ToolbarButtonPayment.Visible = false;
            //if (!_dynamicSecurityPayment.PrvCreate)
            //    ToolbarButtonPayment.Visible = false;
            new_FormTransactionTypeEft.Hide();
            new_CorporationId.Value = _activeUser.CorporationId.ToString();
            new_OfficeId.Value = _activeUser.OfficeId.ToString();
        }

    }

    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;

        string strSqlMain = @"
        SELECT Mt.ProcessMonitoring AS VALUE,
				Mt.New_ProcessMonitoringId AS ID, 
				Mt.ProcessMonitoring,
				Mt.new_TransactionItemId,
				Mt.new_TransactionItemIdName,
				Mt.new_TransactionDate,
				Mt.new_TransactionDateUtcTime,
				Mt.new_TransactionAmount,
				Mt.new_TransactionAmountCurrencyName AS new_TransactionAmount_CurrencyName,
				Mt.new_TransactionAmountCurrency,
				Mt.new_TransactionAmountCurrencyName,
				Mt.new_CostAmount,
				Mt.new_CostAmountCurrencyName AS new_CostAmount_CurrencyName,
				Mt.new_CostAmountCurrency,
				Mt.new_CostAmountCurrencyName,
				Mt.new_SenderId,
				Mt.new_SenderIdName,
				Mt.new_SenderNumber,
				Mt.new_SenderIdentificationCardNumber,
				Mt.new_RecipientFullName,
				Mt.new_RecipientCountry,
				Mt.new_RecipientCountryName,
				Mt.OwningUser,
				Mt.OwningUserName,ObjectId,
				Mt.new_TransactionConfirmId,
				Mt.new_TransactionConfirmIdName,
				Mt.new_ConfirmStatus,
				Mt.new_ConfirmStatusName,
				Mt.new_OperationType,
				Mt.new_OperationTypeName,
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
				Mt.new_TotalReceivedAmountCurrencyName as new_TotalReceivedAmount_CurrencyName,
				Mt.new_UpdateUserId,
				Mt.new_UpdateUserIdName,
				Mt.new_UpdateConfirmRejectUserId,
				Mt.new_UpdateConfirmRejectUserIdName,
				Mt.new_CorporationId,
				Mt.new_CorporationIdName,
				Mt.new_OfficeId,
				Mt.new_OfficeIdName,
				Mt.new_PayingCorporationId,
				Mt.new_PayingCorporationIdName,
				Mt.new_RecipientCorporationId,
				Mt.new_RecipientCorporationIdName,
				Mt.new_PayingOfficeId,
				Mt.new_PayingOfficeIdName,
				Mt.new_PayingUserId,
				Mt.new_PayingUserIdName,
				Mt.new_PaymentDate,
				Mt.new_PaymentDateUtcTime,
				new_TransferPaymentId,
				new_TransferPaymentIdName,
				new_FileTransactionNumber,
				new_CountryName,
				Mt.new_TransferIdName,
				Mt.new_TransferId,
				Mt.new_NationalityID,
				Mt.new_NationalityIDName,
				Mt.new_SenderCountryIDName,
				Mt.new_SenderCountryID,
				Mt.new_CancelDate,
				Mt.new_CancelDateUtcTime,
				new_RecipientGsm,
                Mt.new_CommissionCost,
                Mt.new_CommissionCostCurrencyName AS new_CommissionCost_CurrencyName,
	            Mt.new_CommissionCostCurrency,
	            Mt.new_CommissionCostCurrencyName,
	            Mt.new_CommissionLocalCost,
	            Mt.new_CommissionLocalCostCurrency,
	            Mt.new_CommissionLocalCostCurrencyName

		   FROM dbo.tvNew_CommissionMonitoring(@SystemUserId) AS Mt
LEFT OUTER JOIN vNew_ConfirmStatus (NOLOCK) cs ON cs.New_ConfirmStatusId = mt.New_ConfirmStatus
		  
		  WHERE 1=1
			AND (cs.new_Code NOT IN('PA000','TR000','IP000','TR013') AND cs.DeletionStateCode=0)";

        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("COMMISSIONMONITORING");
        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelMonitoring.Start();
        var limit = GridPanelMonitoring.Limit();
        DataTable dtb;
        List<CrmSqlParameter> spList;
        string strSql = GetFilters(out spList);
        var t = gpc.GetFilterData(strSqlMain + strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
        GridPanelMonitoring.TotalCount = cnt;

        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
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

        var list1 = t.FindAll(x => x["new_OperationType"].Equals(2) || x["new_OperationType"].Equals(4));
        if (list1.Count > 0)
        {
            foreach (var p in list1)
            {
                t.Remove(p);

                var commissionCost = new TuFactory.Data.CommissionDb().GetCommissionCost(
                    p["new_TransactionAmountCurrencyName"].ToString(),
                    t.FindAll(y => y["new_OperationType"].Equals(p["new_OperationType"])).Count
                );

                var rate = new TuFactory.Data.CommissionDb().GetRate(
                    p["new_TransactionAmountCurrencyName"].ToString()
                );

                p["new_CommissionCost"] = commissionCost;
                p["new_CommissionCost_CurrencyName"] = p["new_TransactionAmountCurrencyName"];
                p["new_CommissionCostCurrency"] = p["new_TransactionAmountCurrency"];
                p["new_CommissionCostCurrencyName"] = p["new_TransactionAmountCurrencyName"];

                p["new_CommissionLocalCost"] = commissionCost * rate;
                p["new_CommissionLocalCost_CurrencyName"] = p["new_TransactionAmountCurrencyName"];
                p["new_CommissionLocalCostCurrency"] = p["new_TransactionAmountCurrency"];
                p["new_CommissionLocalCostCurrencyName"] = p["new_TransactionAmountCurrencyName"];

                t.Add(p);
            }
        }

        GridPanelMonitoring.DataSource = t;
        GridPanelMonitoring.DataBind();
    }

    protected void ToolbarButtonPaymentClick(object sender, AjaxEventArgs e)
    {
    }

    protected void ToolbarButtonTotal(object sender, AjaxEventArgs e)
    {
        List<CrmSqlParameter> spList;
        string strSql = GetFilters(out spList);

        string strTotal = @"
        
        declare @ftable table ( 
new_TransactionAmount money ,new_TransactionAmountCurrencyName nvarchar(100),
new_CostAmount money ,new_CostAmountCurrencyName nvarchar(100),new_ReceivedAmount1 money,new_ReceivedAmount1CurrencyName nvarchar(100))

declare @ftable1 table 
(
	VALUE nvarchar(100), ID uniqueidentifier
,   new_FormTransactionAmount_CurrencyName  nvarchar(100)
,   new_FormTransactionAmountCurrencyName	nvarchar(100)
,	new_TransactionAmountCurrencyName				nvarchar(100)
,	new_TransactionAmount_CurrencyName				nvarchar(100)

,	new_TransactionAmount				money 
,	new_TransactionAmountCurrency		uniqueidentifier
,	new_CostAmount_CurrencyName			nvarchar(100)
,	new_CostAmountCurrencyName			nvarchar(100)
 
,	new_CostAmount						money 
,	new_CostAmountCurrency				uniqueidentifier 
,	new_ReceivedAmount1_CurrencyName	nvarchar(100)  
,	new_ReceivedAmount1CurrencyName		nvarchar(100)  
,	new_ReceivedAmount1					money 
,	new_ReceivedAmount1Currency			uniqueidentifier 
)

insert into @ftable
select 
Sum(new_TransactionAmount)			as new_TransactionAmount,
new_TransactionAmountCurrencyName,
Sum(new_CostAmount)					as new_CostAmount,
new_CostAmountCurrencyName,
sum(new_ReceivedAmount1)			as new_ReceivedAmount1,
new_ReceivedAmount1CurrencyName 
from tvNew_CommissionMonitoring(@SystemUserId) mt
left outer join vNew_ConfirmStatus cs on cs.New_ConfirmStatusId=mt.New_ConfirmStatus
Where 1=1
and (cs.new_Code not in ('PA000','TR000','IP000','TR013')and cs.DeletionStateCode=0)
"
    + strSql +//QSLe kosullarin aktarildigi yer.
        @"

group by new_TransactionAmountCurrencyName,new_CostAmountCurrencyName,new_ReceivedAmount1CurrencyName

DECLARE @fileDate VARCHAR(20) -- used for file name 
DECLARE @name VARCHAR(50) -- database name  
DECLARE @nameId VARCHAR(50) -- database name  

DECLARE db_cursor CURSOR FOR  
SELECT Currencyname ,CurrencyId
from vcurrency Where deletionstatecode=0


OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name  ,@nameId 

WHILE @@FETCH_STATUS = 0   
BEGIN   
if exists(select * from @ftable where new_TransactionAmountCurrencyName=@name or new_CostAmountCurrencyName=@name or new_ReceivedAmount1CurrencyName=@name)
BEGIN
insert into @ftable1(
new_FormTransactionAmountCurrencyName,
new_FormTransactionAmount_CurrencyName,
new_TransactionAmountCurrencyName	,
new_TransactionAmount_CurrencyName	,
new_TransactionAmount,
new_TransactionAmountCurrency,
new_CostAmountCurrencyName,
new_CostAmount_CurrencyName,
new_CostAmount,
new_CostAmountCurrency,
new_ReceivedAmount1CurrencyName,
new_ReceivedAmount1_CurrencyName,
new_ReceivedAmount1,
new_ReceivedAmount1Currency
)
 values (@name  , @name  ,@name  , @name  , (select sum(new_TransactionAmount) from @ftable where new_TransactionAmountCurrencyName=@name ),@nameId,
		@name   , @name  , (select sum(new_CostAmount) from @ftable where new_CostAmountCurrencyName=@name ),@nameId,
		@name   , @name  , (select sum(new_ReceivedAmount1) from @ftable where new_ReceivedAmount1CurrencyName=@name ),@nameId
		)   
END   
       FETCH NEXT FROM db_cursor INTO @name  ,@nameId 
END   

CLOSE db_cursor   
DEALLOCATE db_cursor
select * from @ftable1
        
        ";

        var sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        foreach (var crmSqlParameter in spList)
        {
            sd.AddParameter(crmSqlParameter.Paramname, crmSqlParameter.Dbtype, crmSqlParameter.Value);
        }
        var ret = sd.ReturnDataset(strTotal);

        GridPanelTotal.DataSource = ret.Tables[0];
        GridPanelTotal.DataBind();
    }

    protected void ToolbarButtonCommissionCalculateTotal(object sender, AjaxEventArgs e)
    {
        List<CrmSqlParameter> spList;
        string strSql = GetFilters(out spList);

        string strTotal = @"
        CREATE TABLE #SEBER
        (
	        new_TransactionAmount MONEY,
	        new_TransactionAmountCurrency UNIQUEIDENTIFIER,
	        new_TransactionAmountCurrencyName NVARCHAR(50),
	        new_OperationType INT,
	        new_OperationTypeName NVARCHAR(50),
	        new_CommissionCost MONEY,
	        new_CommissionCostCurrency UNIQUEIDENTIFIER,
	        new_CommissionCostCurrencyName NVARCHAR(50),
	        new_CommissionLocalCost MONEY,
	        new_CommissionLocalCostCurrency UNIQUEIDENTIFIER,
	        new_CommissionLocalCostCurrencyName NVARCHAR(50),
	        new_TransactionDateUtcTime DATETIME
        )

        DECLARE
        @new_TransactionAmount MONEY,
        @new_TransactionAmountCurrency UNIQUEIDENTIFIER,
        @new_TransactionAmountCurrencyName NVARCHAR(50),
        @new_OperationType INT,
        @new_OperationTypeName NVARCHAR(50),
        @new_CommissionCost MONEY,
        @new_CommissionCostCurrency UNIQUEIDENTIFIER,
        @new_CommissionCostCurrencyName NVARCHAR(50),
        @new_CommissionLocalCost MONEY,
        @new_CommissionLocalCostCurrency UNIQUEIDENTIFIER,
        @new_CommissionLocalCostCurrencyName NVARCHAR(50),
        @new_TransactionDateUtcTime DATETIME

        DECLARE db_cursor CURSOR FOR  
        SELECT  Mt.new_TransactionAmount,
		        Mt.new_TransactionAmountCurrency,
		        Mt.new_TransactionAmountCurrencyName,
		        Mt.new_OperationType,
		        Mt.new_OperationTypeName,
		        Mt.new_TransactionDateUtcTime

        FROM dbo.tvNew_CommissionMonitoring(@SystemUserId) AS Mt
        LEFT OUTER JOIN vNew_ConfirmStatus (NOLOCK) cs ON cs.New_ConfirmStatusId = mt.New_ConfirmStatus
		  
        WHERE 1=1
        AND (cs.new_Code NOT IN('PA000','TR000','IP000','TR013') AND cs.DeletionStateCode=0)"

            + strSql +

        @"
        
        OPEN db_cursor   
        FETCH NEXT FROM db_cursor INTO @new_TransactionAmount,@new_TransactionAmountCurrency,@new_TransactionAmountCurrencyName,@new_OperationType,@new_OperationTypeName,@new_TransactionDateUtcTime
        WHILE @@FETCH_STATUS = 0   
        BEGIN  
        DECLARE @Count INT = 0
        DECLARE @CommissionAmount MONEY = 0
        Declare @LocalCurrencyId uniqueidentifier, @TranCurrencyId uniqueidentifier
        Declare @LocalCommission money = 1

        IF(@new_OperationType = 2 OR @new_OperationType = 4) 
        BEGIN
	        SELECT @Count = COUNT(*)
	        FROM dbo.tvNew_CommissionMonitoring(@SystemUserId) AS Mt
	        LEFT OUTER JOIN vNew_ConfirmStatus (NOLOCK) cs ON cs.New_ConfirmStatusId = mt.New_ConfirmStatus
	        WHERE 1=1
	        AND (cs.new_Code NOT IN('PA000','TR000','IP000','TR013') AND cs.DeletionStateCode=0)"

            + strSql +

            @"
            And new_OperationType = @new_OperationType

	        SELECT @CommissionAmount = Ml.new_CommissionAmount
	        FROM vNew_DefinitionOfPayCommission (nolock) as Ml
	        WHERE 1=1
	        AND Ml.DeletionStateCode = 0
	        AND Ml.new_CurrenyIdName = @new_TransactionAmountCurrencyName
	        AND @Count BETWEEN Ml.new_LowerLimit AND new_UpLimit
	        ORDER BY new_LowerLimit, new_UpLimit

	        select @LocalCurrencyId = CurrencyId from vCurrency (nolock) where ISOCurrencyCode = 'TRY'
	        select @TranCurrencyId = CurrencyId from vCurrency (nolock) where ISOCurrencyCode = @new_TransactionAmountCurrencyName OR Currencyname = @new_TransactionAmountCurrencyName 
	        if(@TranCurrencyId <> @LocalCurrencyId)
	        begin
		        select @LocalCommission = dbo.fnGetExchanceRateMBDABuy(@SystemUserId, @TranCurrencyId, @LocalCurrencyId)
	        end

	        INSERT INTO #SEBER
	        SELECT 
	        @new_TransactionAmount,
	        @new_TransactionAmountCurrency,
	        @new_TransactionAmountCurrencyName,
	        @new_OperationType,
	        @new_OperationTypeName,
	        @CommissionAmount AS new_CommissionCost,
	        @new_TransactionAmountCurrency AS new_CommissionCostCurrency,
	        @new_TransactionAmountCurrencyName AS new_CommissionCostCurrencyName,
	        (@CommissionAmount * @LocalCommission) AS new_CommissionLocalCost,
	        @LocalCurrencyId AS new_CommissionLocalCostCurrency,
	        'TRY' AS new_CommissionLocalCostCurrencyName,
	        @new_TransactionDateUtcTime
        END

        FETCH NEXT FROM db_cursor INTO @new_TransactionAmount,@new_TransactionAmountCurrency,@new_TransactionAmountCurrencyName,@new_OperationType,@new_OperationTypeName,@new_TransactionDateUtcTime
        END

        CLOSE db_cursor
        DEALLOCATE db_cursor

        INSERT INTO #SEBER
        SELECT 	
        new_TransactionAmount,
        new_TransactionAmountCurrency,
        new_TransactionAmountCurrencyName,
        new_OperationType,
        new_OperationTypeName,
        new_CommissionCost,
        new_CommissionCostCurrency,
        new_CommissionCostCurrencyName,
        new_CommissionLocalCost,
        new_CommissionLocalCostCurrency,
        new_CommissionLocalCostCurrencyName,
        new_TransactionDateUtcTime

        FROM dbo.tvNew_CommissionMonitoring(@SystemUserId) AS Mt
        LEFT OUTER JOIN vNew_ConfirmStatus (NOLOCK) cs ON cs.New_ConfirmStatusId = mt.New_ConfirmStatus
        WHERE 1=1
        AND (cs.new_Code NOT IN('PA000','TR000','IP000','TR013') AND cs.DeletionStateCode=0)"

            + strSql +

        @"
        And new_OperationType = 1


        SELECT  
        new_TransactionAmountCurrencyName + ' ' + new_OperationTypeName AS new_OperationTypeName,
        count(new_TransactionAmount) AS new_TransactionAmountCount,
        sum(new_TransactionAmount) AS new_TransactionAmountTotal,
        new_TransactionAmountCurrencyName AS new_TransactionAmountTotalCurrency,
        sum(new_CommissionCost) AS new_CommissionCostTotal,
        new_CommissionCostCurrencyName AS new_CommissionCostTotalCurrency,
        sum(new_CommissionLocalCost) AS new_CommissionLocalCostTotal,
        new_CommissionLocalCostCurrencyName AS new_CommissionLocalCostTotalCurrency

        FROM #SEBER 
        GROUP BY new_OperationType, new_OperationTypeName, new_TransactionAmountCurrencyName,new_CommissionCostCurrencyName, new_CommissionLocalCostCurrencyName

        DROP TABLE #SEBER";

        var sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        foreach (var crmSqlParameter in spList)
        {
            sd.AddParameter(crmSqlParameter.Paramname, crmSqlParameter.Dbtype, crmSqlParameter.Value);
        }
        var ret = sd.ReturnDataset(strTotal);

        GridPanelCommmissionTotal.DataSource = ret.Tables[0];
        GridPanelCommmissionTotal.DataBind();
       
    }

    protected void ToolbarButtonTransferClick(object sender, AjaxEventArgs e)
    {

    }

    void FillSecurity()
    {
        _dynamicSecurityTransfer = DynamicFactory.GetSecurity(TuEntityEnum.New_Transfer.GetHashCode(), null);
        _dynamicSecurityPayment = DynamicFactory.GetSecurity(TuEntityEnum.New_Payment.GetHashCode(), null);
    }

    private string GetFilters(out List<CrmSqlParameter> spList)
    {
        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        var sd = new StaticData();
        string strSql = string.Empty;
        spList = new List<CrmSqlParameter>();
        if (new_SenderCountryID.Value != "")
        {
            strSql += " And new_SenderCountryID=@new_Country";

            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_Country",
                Value = ValidationHelper.GetGuid(new_SenderCountryID.Value)
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
        if (new_PayingCorporationId.Value != "")
        {
            strSql += " And new_PayingCorporationId=@new_PayingCorporationId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_PayingCorporationId",
                Value = ValidationHelper.GetGuid(new_PayingCorporationId.Value)
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
        if (new_FormTransactionTypeID.Value != "")
        {
            strSql += " And Mt.new_TargetTransactionTypeID=@new_FormTransactionTypeID";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormTransactionTypeID",
                Value = ValidationHelper.GetGuid(new_FormTransactionTypeID.Value)
            });
        }
        if (new_FormSourceTransactionTypeID.Value != "")
        {
            strSql += " And new_SourceTransactionTypeID=@new_FormSourceTransactionTypeID";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormSourceTransactionTypeID",
                Value = ValidationHelper.GetGuid(new_FormSourceTransactionTypeID.Value)
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
        if (new_FormReceiverCountryID.Value != "")
        {
            strSql += " And new_RecipientCountry=@new_FormReceiverCountryId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormReceiverCountryId",
                Value = ValidationHelper.GetGuid(new_FormReceiverCountryID.Value)
            });
        }
        if (new_RecepientCorporationId.Value != "")
        {
            strSql += " And new_RecipientCorporationId=@new_RecipientCorporationId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_RecipientCorporationId",
                Value = ValidationHelper.GetGuid(new_RecepientCorporationId.Value)
            });
        }
        if (CommissionMonitoring.Value != "")
        {
            //strSql += " And MT.CommissionMonitoring like '%'+@CommissionMonitoring +'%'";
            if (CommissionMonitoring.Value.Length == 11)
            {
                strSql += " And MT.CommissionMonitoring = @CommissionMonitoring";
            }
            else
            {
                strSql += " And MT.CommissionMonitoring like '%'+@CommissionMonitoring +'%'";
            }

            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "CommissionMonitoring",
                Value = ValidationHelper.GetString(CommissionMonitoring.Value)
            });
        }
        if (new_RecipientFullName.Value != "")
        {
            strSql += " And MT.new_RecipientFullName like '%'+@new_RecipientFullName +'%'";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_RecipientFullName",
                Value = cryptor.EncryptInString(ValidationHelper.GetString(new_RecipientFullName.Value))
            });
        }
        if (new_SenderId.Value != "")
        {
            strSql += " And MT.new_SenderIdName Like '%'+@new_SenderIdName +'%'";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_SenderIdName",
                Value = ValidationHelper.GetDBString(SqlCreater.GetLikeText(new_SenderId.Value))
            });
        }
        if (new_FormConfirmStatusId.Value != "")
        {
            strSql += " And MT.new_ConfirmStatus=@new_FormConfirmStatusId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormConfirmStatusId",
                Value = ValidationHelper.GetGuid(new_FormConfirmStatusId.Value)
            });
        }
        if (new_OperationType.Value != "")
        {
            strSql += " And MT.new_OperationType = @new_OperationType ";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Int32,
                Paramname = "new_OperationType",
                Value = ValidationHelper.GetInteger(new_OperationType.Value)
            });
        }
        //if (new_FileTransactionNumber.Value != "")
        //{
        //    strSql += " And MT.new_FileTransactionNumber = @new_FileTransactionNumber ";
        //    spList.Add(new CrmSqlParameter()
        //    {
        //        Dbtype = DbType.String,
        //        Paramname = "new_FileTransactionNumber",
        //        Value = new_FileTransactionNumber.Value
        //    });
        //}
        if (new_PaymentDate2.Value != null)
        {

            strSql += " And (new_PaymentDateUtcTime>=@new_PaymentDate)";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "new_PaymentDate",
                Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_PaymentDate2.Value), App.Params.CurrentUser.SystemUserId)

            });
        }
        if (new_PaymentDate3.Value != null)
        {
            strSql += " And (new_PaymentDateUtcTime<@new_PaymentDate2)";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "new_PaymentDate2",
                Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_PaymentDate3.Value).AddDays(1), App.Params.CurrentUser.SystemUserId)
            });
        }
        if (new_CancelDate1.Value != null)
        {
            strSql += " And new_CancelDateUtcTime>=@new_CancelDate1";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "new_CancelDate1",
                Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_CancelDate1.Value), App.Params.CurrentUser.SystemUserId)
            });
        }
        if (new_CancelDate2.Value != null)
        {
            strSql += " And new_CancelDateUtcTime<@new_CancelDate2";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "new_CancelDate2",
                Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_CancelDate2.Value).AddDays(1), App.Params.CurrentUser.SystemUserId)
            });
        }
        if (new_FormTransactionTypeEft.Value != null)
        {
            if (new_FormTransactionTypeEft.Value == "0")
            {
                strSql += " and ISNULL(new_RecipientCardNumber, '') <> '' ";
            }
            else if (new_FormTransactionTypeEft.Value == "1")
            {
                strSql += " and ISNULL(new_RecipientCardNumber, '') = '' ";
            }
        }

        return strSql;
    }

    private void HoldResume(ETuHoldResume action)
    {
        if (!_userApproval.ApprovalHoldResume)
        {
            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true };
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOUHAVENOT_PERMISSION"));

            return;
        }

        var degerler = ((RowSelectionModel)GridPanelMonitoring.SelectionModel[0]);
        if (degerler != null && degerler.SelectedRows != null)
        {

            try
            {
                var objectId = ValidationHelper.GetInteger(degerler.SelectedRows.ObjectId);
                var CommissionMonitoringId = ValidationHelper.GetGuid(degerler.SelectedRows.ID);
                var cf = new ConfirmFactory();

                cf.ConfirmHoldResume(action, objectId, CommissionMonitoringId);
                if (action == ETuHoldResume.Hold)
                    _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_HOLD_OK"));
                else if (action == ETuHoldResume.Resume)
                    _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_RESUME_OK"));

                QScript("ToolbarButtonFind.click();");
            }
            catch (TuException ex)
            {
                _msg.Show(".", ex.ErrorMessage);

            }
            catch (Exception ex)
            {

                _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            }


            //GridPanelMonitoring.Reload();
        }
        else
        {
            _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_CommissionMonitoring_PLACE_SELECT_RECORD"));
        }
    }

    private void TranslateMessages()
    {
        //ToolbarButtonTransfer.Text = CrmLabel.TranslateMessage("CRM.NEW_CommissionMonitoring_BTN_NEW_TRANSFER_RECORD");
        //ToolbarButtonPayment.Text = CrmLabel.TranslateMessage("CRM.NEW_CommissionMonitoring_BTN_NEW_PAYMENT_RECORD");

        //btnHold.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_HOLD");
        //btnResume.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_RESUME");
        btnDownload.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
        pnl1.Title = CrmLabel.TranslateMessage("CRM.NEW_CommissionMonitoring_SEARCH");
        //BtnSb1.Text = CrmLabel.TranslateMessage("CRM.NEW_CommissionMonitoring_LIST_TOTAL");
        //windowTotal.Title = CrmLabel.TranslateMessage("CRM.NEW_CommissionMonitoring_LIST_TOTAL");
        var all = CrmLabel.TranslateMessage("CRM.ENTITY_ALL");
        new_SenderCountryID.EmptyText = all;
        new_CorporationId.EmptyText = all;
        new_RecepientCorporationId.EmptyText = all;
        new_OfficeId.EmptyText = all;
        new_FormConfirmStatusId.EmptyText = all;
        //new_FileTransactionNumber.EmptyText = all;
        new_OperationType.EmptyText = all;
        new_FormTransactionTypeID.EmptyText = all;
        new_FormSourceTransactionTypeID.EmptyText = all;
        new_FormReceiverCountryID.EmptyText = all;
        new_FormCustomerNumber.EmptyText = all;
        new_SenderId.EmptyText = all;
        new_RecipientFullName.EmptyText = all;
        new_PayingCorporationId.EmptyText = all;
        new_RateDate.EmptyText = all;
    }
}