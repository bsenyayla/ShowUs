using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Web;
using System.Linq;
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
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using TuFactory.Data;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;

public partial class Operation_Detail_Monitoring : BasePage
{
    private TuUser _activeUser = null;
    private DynamicSecurity _dynamicSecurityPayment;
    private DynamicSecurity _dynamicSecurityTransfer;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private TuUserApproval _userApproval = null;
    private Guid QueryId = Guid.Empty;
    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("PROCESSMONITORING", GridPanelMonitoring);

        string strSelected = ViewFactory.GetViewIdbyUniqueName("PROCESSMONITORING").ToString();

        QueryId = ValidationHelper.GetGuid(strSelected);

        hdnViewList.Value = strSelected;

        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));

        var getColumnList = new UserPoolMapDb().GetColumnList(Convert.ToInt32(hdnPoolId.Value), QueryId, new UserPoolMapDb().GetAttributeListString(new UserPoolMapDb().getColumnSet(gpw.View.ColumnSetXml)));
        List<GridColumns> lstAddetColumn = GridPanelMonitoring.ColumnModel.Columns.ToList();
        GridPanelMonitoring.ClearColumns();

        string FormHtmlString = string.Empty;
        foreach (GridColumns item in lstAddetColumn)
        {
            var count = (from c in getColumnList
                         where c.AttributeName == item.Header && c.Hide == true
                         select c).Count();
            if (count == 0)
                GridPanelMonitoring.AddColumn(item);

            if (item.Header != "Ux_New_ProcessMonitoringId")
                FormHtmlString += "<tr><b></b><td><b>&nbsp&nbsp&nbsp&nbsp" + item.Header + "</b></td><td>{" + item.DataIndex + "}</td></tr>";
        }

        RowExpander rowExpander = new RowExpander();
        rowExpander.Collapsed = true;
        rowExpander.Template = string.Format("<table>&nbsp&nbsp&nbsp&nbsp&nbsp<b><span style='color:red'>İşlem Detayları&nbsp(Transaction Details)</span></b><hr />{0}</table>", FormHtmlString);
        GridPanelMonitoring.SpecialSettings.Add(rowExpander);

        GridPanelMonitoring.ReConfigure();

        var defaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnViewDefaultEditPage.Value = defaultEditPage;

        gpc.CreateViewGrid("PROCESSMONITORING_TOTALS", GridPanelTotal);
        string strSelected1 = ViewFactory.GetViewIdbyUniqueName("PROCESSMONITORING_TOTALS").ToString();
        hdnViewListTotal.Value = strSelected1;
    }

    protected void BtnHoldClick(object sender, AjaxEventArgs e)
    {
        HoldResume(ETuHoldResume.Hold);
    }

    protected void btnInformationOnEvent(object sender, AjaxEventArgs e)
    {
        var infoList = Info.GetEntityHelpsByName("MONITORING", this);
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
            FillLogInfo();
            //if (!_dynamicSecurityTransfer.PrvCreate)
            //    ToolbarButtonPayment.Visible = false;
            //if (!_dynamicSecurityPayment.PrvCreate)
            //    ToolbarButtonPayment.Visible = false;
            new_FormTransactionTypeEft.Hide();
            new_CorporationId.Value = _activeUser.CorporationId.ToString();
            new_OfficeId.Value = _activeUser.OfficeId.ToString();
            if (new_FormTransactionDate1.Value != null)
            {
                new_FormTransactionDate2.Value = new_FormTransactionDate1.Value;
            }
        }
    }

    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        try
        {
            string filtermsg = GetFilterValidation();
            if (!string.IsNullOrEmpty(filtermsg))
            {
                var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", filtermsg);

                GridPanelMonitoring.DataBind();
                return;
            }


            var sort = GridPanelMonitoring.ClientSorts();
            if (sort == null)
                sort = string.Empty;

            string strSqlMain = @"
            SELECT *  FROM dbo.tvNew_ProcessMonitoring_20181127(@SystemUserId) AS Mt		  
		     WHERE 1=1
			AND mt.New_ConfirmStatus NOT IN ( Select New_ConfirmStatusId From vNew_ConfirmStatus(NOLOCK) cs WHERE  cs.new_Code IN('PA000','TR000','IP000','TR013') AND cs.DeletionStateCode=0) ";

            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("PROCESSMONITORING");
            var gpc = new GridPanelCreater();
            var cnt = 0;
            var start = GridPanelMonitoring.Start();
            var limit = GridPanelMonitoring.Limit();
            DataTable dtb = new DataTable();
            List<CrmSqlParameter> spList;
            List<Dictionary<string, object>> t = new List<Dictionary<string, object>>();
            string strSql = string.Empty;


            if (!string.IsNullOrEmpty(ProcessMonitoring.Value) && ProcessMonitoring.Value.Length == 11)
            {
                StaticData sd = new StaticData();
                strSql = GetStaticDataFilters(out sd);

                dtb = sd.ReturnDataset(strSqlMain + strSql).Tables[0];

                GridPanelView gpView = new GridPanelView(0, viewqueryid);
                List<string> passwordColumns;

                t = gpView.GetDataList(dtb, out passwordColumns);

            }
            else
            {
                strSql = GetFilters(out spList);
                Logger(spList);

                t = gpc.GetFilterData(strSqlMain + strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
                GridPanelMonitoring.TotalCount = cnt;

                TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
                List<string> fields = new List<string>() { "new_RecipientFullName" };
                t = cryptor.DecryptFieldsInFilterData(fields, t);
                
            }


            if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            {
                if (!_userApproval.ReferenceCanBeSeen)
                {
                    DataTable maskedData = new DataTable();
                    maskedData = dtb.Clone();

                    foreach (DataRow item in dtb.Rows)
                    {
                        string tu_Ref = item.Field<string>("ProcessMonitoring");
                        var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref);

                        item["ProcessMonitoring"] = masked_tu_ref;
                        //item["new_TransferIdName"] = masked_tu_ref;
                        //if (!string.IsNullOrEmpty(item["new_TransferPaymentIdName"].ToString()))
                        //    item["new_TransferPaymentIdName"] = masked_tu_ref;
                        item["VALUE"] = masked_tu_ref;

                        maskedData.ImportRow(item);
                    }

                    var gpw = new GridPanelView(0, ValidationHelper.GetGuid(hdnViewList.Value));
                    gpw.Export(maskedData);
                }
                else
                {
                    var gpw = new GridPanelView(0, ValidationHelper.GetGuid(hdnViewList.Value));
                    gpw.Export(dtb);
                }
            }

            if (!_userApproval.ReferenceCanBeSeen)
            {
                List<Dictionary<string, object>> maskedList = new List<Dictionary<string, object>>();

                foreach (var item in t)
                {
                    string tu_Ref = item.Where(x => x.Key.Equals("ProcessMonitoring")).Select(x => x.Value).FirstOrDefault().ToString();
                    var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref);

                    item["ProcessMonitoring"] = masked_tu_ref;
                    //item["new_TransferIdName"] = masked_tu_ref;
                    //if (!string.IsNullOrEmpty(item["new_TransferPaymentIdName"].ToString()))
                    //    item["new_TransferPaymentIdName"] = masked_tu_ref;
                    item["VALUE"] = masked_tu_ref;

                    maskedList.Add(item);
                }

                GridPanelMonitoring.DataSource = maskedList;
                GridPanelMonitoring.DataBind();
            }
            else
            {
                GridPanelMonitoring.DataSource = t;
                GridPanelMonitoring.DataBind();
            }

        }
        catch (Exception ex)
        {
            throw ex;
        }
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
from tvNew_ProcessMonitoring(@SystemUserId) mt
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

    protected void ToolbarButtonTransferClick(object sender, AjaxEventArgs e)
    {

    }

    void FillSecurity()
    {
        _dynamicSecurityTransfer = DynamicFactory.GetSecurity(TuEntityEnum.New_Transfer.GetHashCode(), null);
        _dynamicSecurityPayment = DynamicFactory.GetSecurity(TuEntityEnum.New_Payment.GetHashCode(), null);
    }

    private string GetFilterValidation()
    {
        string errMsg = string.Empty;

        int TransferDatePeriod = ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("TRANSFERDATE_PERIOD"), 30);
        int PaymentDatePeriod = ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("PAYMENTDATE_PERIOD"), 30);
        int CancelDatePeriod = ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("CANCELDATE_PERIOD"), 30);

        if (!string.IsNullOrEmpty(ProcessMonitoring.Value) || !string.IsNullOrEmpty(new_FileTransactionNumber.Value))
        {
            return errMsg;
        }
        else
        {


            if ((new_PaymentDate2.Value != null && new_PaymentDate3.Value != null))
            {
                return errMsg;
            }
            else if ((new_PaymentDate2.Value != null && new_PaymentDate3.Value == null))
            {
                errMsg = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MUST_ENTER_ENDPAYMENTDATE");
                return errMsg;
            }
            else if ((new_PaymentDate2.Value == null && new_PaymentDate3.Value != null))
            {
                errMsg = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MUST_ENTER_STARTPAYMENTDATE");
                return errMsg;
            }

            if ((new_FormTransactionDate1.Value == null || new_FormTransactionDate2.Value == null))
            {
                errMsg = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_REF_AND_DATE_NOT_NULL");
            }
            else
            {
                double dateDiff = (ValidationHelper.GetDate(new_FormTransactionDate2.Value) - ValidationHelper.GetDate(new_FormTransactionDate1.Value)).TotalDays;

                if (string.IsNullOrEmpty(new_RecipientCorporationId.Value) && string.IsNullOrEmpty(new_CorporationId.Value))
                {
                    if (string.IsNullOrEmpty(new_SenderId.Value) && string.IsNullOrEmpty(new_RecipientFullName.Value))
                    {

                        if (dateDiff > TransferDatePeriod)
                        {
                            if (string.IsNullOrEmpty(new_RecipientCorporationId.Value) && string.IsNullOrEmpty(new_CorporationId.Value))
                            {
                                errMsg = string.Format(CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_NO_REF_MAX_N_DAY"), TransferDatePeriod);
                            }
                        }
                    }
                    else
                    {
                        /*Gönderici veya alıcı girildiyse 90 gün yapabilsin.*/

                        if (dateDiff > 90)
                        {
                            if (string.IsNullOrEmpty(new_RecipientCorporationId.Value) && string.IsNullOrEmpty(new_CorporationId.Value))
                            {
                                errMsg = string.Format(CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_NO_REF_MAX_N_DAY"), 90);
                            }
                        }
                    }
                }
            }
        }


        return errMsg;
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
        if (new_PayingOfficeId.Value != "")
        {
            strSql += " And new_PayingOfficeId=@new_PayingOfficeId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_PayingOfficeId",
                Value = ValidationHelper.GetGuid(new_PayingOfficeId.Value)
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
            strSql += " And Mt.new_TargetTransactionTypeID=@new_FormTransactionTypeID";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormTransactionTypeID",
                Value = ValidationHelper.GetGuid(new_FormTransactionTypeID.Value)
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
        if (new_RecipientCorporationId.Value != "")
        {
            strSql += " And new_RecipientCorporationId=@new_RecipientCorporationId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_RecipientCorporationId",
                Value = ValidationHelper.GetGuid(new_RecipientCorporationId.Value)
            });
        }

        if (ProcessMonitoring.Value != "")
        {
            if (ProcessMonitoring.Value.Length == 11)
            {
                strSql += " And MT.ProcessMonitoring = @ProcessMonitoring";
            }
            else
            {
                strSql += " And MT.ProcessMonitoring like '%'+@ProcessMonitoring +'%'";
            }

            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "ProcessMonitoring",
                Value = ValidationHelper.GetString(ProcessMonitoring.Value)
            });
        }
        if (new_RecipientFullName.Value != "")
        {
            strSql += " And REPLACE(MT.new_RecipientFullName,' ','')  like '%'+@new_RecipientFullName +'%'";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_RecipientFullName",
                Value = cryptor.EncryptInString(ValidationHelper.GetString(new_RecipientFullName.Value.Replace(" ", "")))
            });
        }
        if (new_SenderId.Value != "")
        {
            strSql += " And REPLACE(MT.new_SenderIdName,' ','')  Like '%'+@new_SenderIdName +'%'";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_SenderIdName",
                Value = ValidationHelper.GetDBString(SqlCreater.GetLikeText(new_SenderId.Value.Replace(" ", "")))
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
        if (new_FileTransactionNumber.Value != "")
        {
            strSql += " And MT.new_FileTransactionNumber = @new_FileTransactionNumber ";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_FileTransactionNumber",
                Value = new_FileTransactionNumber.Value
            });
        }

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

         
        if (!String.IsNullOrEmpty( new_InstructionStartCorporationId.Value))
        {
            strSql += " And new_InstructionStartCorporationId=@new_InstructionStartCorporationId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_InstructionStartCorporationId",
                Value = ValidationHelper.GetGuid(new_InstructionStartCorporationId.Value)
            });
        }
        return strSql;

    }

    private string GetStaticDataFilters(out StaticData sd)
    {
        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        string strSql = string.Empty;
        sd = new StaticData();
        if (!string.IsNullOrEmpty(ProcessMonitoring.Value))
        {
            strSql += " And ProcessMonitoring=@ProcessMonitoring";
            sd.AddParameter("ProcessMonitoring", DbType.String, ProcessMonitoring.Value);
        }

        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);



        if (new_SenderCountryID.Value != "")
        {
            strSql += " And new_SenderCountryID=@new_Country";
            sd.AddParameter("new_Country", DbType.Guid, ValidationHelper.GetGuid(new_SenderCountryID.Value));
        }
        if (new_CorporationId.Value != "")
        {
            strSql += " And new_CorporationId=@new_CorporationId";
            sd.AddParameter("new_CorporationId", DbType.Guid, ValidationHelper.GetGuid(new_CorporationId.Value));
        }
        if (new_OfficeId.Value != "")
        {
            strSql += " And new_OfficeId=@new_OfficeId";
            sd.AddParameter("new_OfficeId", DbType.Guid, ValidationHelper.GetGuid(new_OfficeId.Value));
        }
        if (new_PayingCorporationId.Value != "")
        {
            strSql += " And new_PayingCorporationId=@new_PayingCorporationId";
            sd.AddParameter("new_PayingCorporationId", DbType.Guid, ValidationHelper.GetGuid(new_PayingCorporationId.Value));

        }
        if (new_PayingOfficeId.Value != "")
        {
            strSql += " And new_PayingOfficeId=@new_PayingOfficeId";
            sd.AddParameter("new_PayingOfficeId", DbType.Guid, ValidationHelper.GetGuid(new_PayingOfficeId.Value));

        }
        if (new_FormTransactionDate1.Value != null)
        {

            strSql += " And new_TransactionDate>=@new_FormTransactionDate1";
            sd.AddParameter("new_FormTransactionDate1", DbType.DateTime, ValidationHelper.GetDate(new_FormTransactionDate1.Value));

        }
        if (new_FormTransactionDate2.Value != null)
        {
            strSql += " And new_TransactionDate<(@new_FormTransactionDate2)";
            sd.AddParameter("new_FormTransactionDate2", DbType.DateTime, ValidationHelper.GetDate(new_FormTransactionDate2.Value).AddDays(1));

        }
        if (new_FormAmount1.Value != null)
        {
            strSql += " And new_TransactionAmount>=@new_FormAmount1";
            sd.AddParameter("new_FormAmount1", DbType.Decimal, ValidationHelper.GetDecimal(new_FormAmount1.Value, 0));

        }
        if (new_FormAmount2.Value != null)
        {
            strSql += " And new_TransactionAmount<=@new_FormAmount2";
            sd.AddParameter("new_FormAmount2", DbType.Decimal, ValidationHelper.GetDecimal(new_FormAmount2.Value, 0));

        }
        if (new_FormTransactionAmountCurrency.Value != "")
        {
            strSql += " And new_TransactionAmountCurrency=@new_FormTransactionAmountCurrency";
            sd.AddParameter("new_FormTransactionAmountCurrency", DbType.Guid, ValidationHelper.GetGuid(new_FormTransactionAmountCurrency.Value));

        }
        if (new_FormTransactionTypeID.Value != "")
        {
            strSql += " And Mt.new_TargetTransactionTypeID=@new_FormTransactionTypeID";
            sd.AddParameter("new_FormTransactionTypeID", DbType.Guid, ValidationHelper.GetGuid(new_FormTransactionTypeID.Value));

        }

        if (new_FormReceiverCountryId.Value != "")
        {
            strSql += " And new_RecipientCountry=@new_FormReceiverCountryId";
            sd.AddParameter("new_FormReceiverCountryId", DbType.Guid, ValidationHelper.GetGuid(new_FormReceiverCountryId.Value));

        }
        if (new_RecipientCorporationId.Value != "")
        {
            strSql += " And new_RecipientCorporationId=@new_RecipientCorporationId";
            sd.AddParameter("new_RecipientCorporationId", DbType.Guid, ValidationHelper.GetGuid(new_RecipientCorporationId.Value));
        }


        if (new_RecipientFullName.Value != "")
        {
            strSql += " And REPLACE(MT.new_RecipientFullName,' ','')  like '%'+@new_RecipientFullName +'%'";
            sd.AddParameter("new_RecipientFullName", DbType.String, cryptor.EncryptInString(ValidationHelper.GetString(new_RecipientFullName.Value.Replace(" ", ""))));

        }
        if (new_SenderId.Value != "")
        {
            strSql += " And REPLACE(MT.new_SenderIdName,' ','')  Like '%'+@new_SenderIdName +'%'";
            sd.AddParameter("new_SenderIdName", DbType.String, ValidationHelper.GetDBString(SqlCreater.GetLikeText(new_SenderId.Value.Replace(" ", ""))));

        }
        if (new_FormConfirmStatusId.Value != "")
        {
            strSql += " And MT.new_ConfirmStatus=@new_FormConfirmStatusId";
            sd.AddParameter("new_FormConfirmStatusId", DbType.Guid, ValidationHelper.GetGuid(new_FormConfirmStatusId.Value));

        }
        if (new_OperationType.Value != "")
        {
            strSql += " And MT.new_OperationType = @new_OperationType ";
            sd.AddParameter("new_OperationType", DbType.Int32, ValidationHelper.GetInteger(new_OperationType.Value));
        }
        if (new_FileTransactionNumber.Value != "")
        {
            strSql += " And MT.new_FileTransactionNumber = @new_FileTransactionNumber ";
            sd.AddParameter("new_FileTransactionNumber", DbType.String, ValidationHelper.GetString(new_FileTransactionNumber.Value));

        }

        if (new_PaymentDate2.Value != null)
        {

            strSql += " And (new_PaymentDateUtcTime>=@new_PaymentDate)";
            sd.AddParameter("new_PaymentDate", DbType.DateTime, ValidationHelper.GetDate(new_PaymentDate2.Value));

        }
        if (new_PaymentDate3.Value != null)
        {
            strSql += " And (new_PaymentDateUtcTime<@new_PaymentDate2)";
            sd.AddParameter("new_PaymentDate2", DbType.DateTime, ValidationHelper.GetDate(new_PaymentDate3.Value).AddDays(1));

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

        if (new_InstructionStartCorporationId.Value != "")
        {
            strSql += " And new_InstructionStartCorporationId=@new_InstructionStartCorporationId";
            sd.AddParameter("new_InstructionStartCorporationId", DbType.Guid, ValidationHelper.GetGuid(new_InstructionStartCorporationId.Value));

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
                var processMonitoringId = ValidationHelper.GetGuid(degerler.SelectedRows.ID);
                var cf = new ConfirmFactory();

                cf.ConfirmHoldResume(action, objectId, processMonitoringId);
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
            _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PLACE_SELECT_RECORD"));
        }
    }

    private void Logger(List<CrmSqlParameter> spList)
    {
        var de = new DynamicEntity(TuEntityEnum.New_ProcessMonitoring.GetHashCode());
        var deRetrived = new DynamicEntity(de.ObjectId);

        foreach (var parameter in spList)
        {
            if (parameter.Dbtype == DbType.String)
            {
                var masked_tu_ref = string.Empty;
                if (parameter.Paramname.Equals("ProcessMonitoring"))
                {
                    masked_tu_ref = TuFactory.Utility.Masker.MaskReference(parameter.Value.ToString());
                    de.AddStringProperty(parameter.Paramname, ValidationHelper.GetString(masked_tu_ref));
                }
                else
                {
                    de.AddStringProperty(parameter.Paramname, ValidationHelper.GetString(parameter.Value));
                }
            }
            if (parameter.Dbtype == DbType.Guid)
            {
                de.AddLookupProperty(parameter.Paramname, "", ValidationHelper.GetGuid(parameter.Value));
            }
            if (parameter.Dbtype == DbType.DateTime)
            {
                if (parameter.Paramname.Equals("new_FormTransactionDate1"))
                {
                    de.AddDateTimeProperty(parameter.Paramname, ValidationHelper.GetDate(parameter.Value).AddDays(1));
                }
                else
                {
                    de.AddDateTimeProperty(parameter.Paramname, ValidationHelper.GetDate(parameter.Value));
                }
            }
            if (parameter.Dbtype == DbType.Decimal)
            {
                de.AddDecimalProperty(parameter.Paramname, ValidationHelper.GetDecimal(parameter.Value, 0));
            }
            if (parameter.Paramname.Equals("new_FormAmount2"))
            {
                de.AddMoneyProperty(parameter.Paramname, decimal.Parse(parameter.Value.ToString()), new Lookup("TL", ValidationHelper.GetGuid(new_FormTransactionAmountCurrency.Value)));
            }
        }

        DynamicFactory df = new DynamicFactory(Coretech.Crm.Objects.Crm.WorkFlow.ERunInUser.SystemAdmin);
        var db = new Coretech.Crm.Data.Crm.Dynamic.DynamicDb();

        var recId = Guid.Empty;
        if (string.IsNullOrEmpty(hdnRecid.Value) || hdnRecid.Value.Equals(Guid.Empty))
        {
            var gdKey = GuidHelper.Newfoid(de.ObjectId);
            var logsql = "";
            List<CrmSqlParameter> logspList;
            TuFactory.Data.LogDb.CreateLogSql(out logsql, out logspList, deRetrived, de, Guid.Parse(hdnEntityId.Value), gdKey);

            if (logspList.Count > 0)
                db.Exec(logsql, App.Params.CurrentUser.SystemUserId, logspList);

            hdnRecid.SetValue(gdKey);
        }
        else
        {
            de.AddKeyProperty("New_ProcessMonitoringId", Guid.Parse(hdnRecid.Value));

            var logsql = "";
            List<CrmSqlParameter> logspList;
            TuFactory.Data.LogDb.CreateLogSql(out logsql, out logspList, deRetrived, de, Guid.Parse(hdnEntityId.Value), Guid.Parse(hdnRecid.Value));

            if (logspList.Count > 0)
                db.Exec(logsql, App.Params.CurrentUser.SystemUserId, logspList);
        }
    }

    private void TranslateMessages()
    {
        //ToolbarButtonTransfer.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_BTN_NEW_TRANSFER_RECORD");
        //ToolbarButtonPayment.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_BTN_NEW_PAYMENT_RECORD");

        //btnHold.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_HOLD");
        //btnResume.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_RESUME");
        btnDownload.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
        pnl1.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_SEARCH");
        BtnSb1.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_LIST_TOTAL");
        windowTotal.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_LIST_TOTAL");
        var all = CrmLabel.TranslateMessage("CRM.ENTITY_ALL");
        new_SenderCountryID.EmptyText = all;
        new_CorporationId.EmptyText = all;
        new_RecipientCorporationId.EmptyText = all;
        new_OfficeId.EmptyText = all;
        new_FormConfirmStatusId.EmptyText = all;
        new_FileTransactionNumber.EmptyText = all;
        new_OperationType.EmptyText = all;
        new_FormTransactionTypeID.EmptyText = all;
        //new_FormSourceTransactionTypeID.EmptyText = all;
        new_FormReceiverCountryId.EmptyText = all;
        //new_FormCustomerNumber.EmptyText = all;
        new_SenderId.EmptyText = all;
        new_RecipientFullName.EmptyText = all;
        new_PayingCorporationId.EmptyText = all;
        //new_Channel.EmptyText = all;
        new_PayingOfficeId.EmptyText = all;
        new_InstructionStartCorporationId.EmptyText = all;
    }

    private void FillLogInfo()
    {
        var entityId = TuFactory.Data.LogDb.GetBaseEntityId(TuEntityEnum.New_ProcessMonitoring.ToString());
        var recId = new TuFactory.Data.LogDb().GetLastRecordId(entityId);

        hdnEntityId.SetValue(entityId);
        hdnRecid.SetValue(recId);
    }

    protected void new_RecipientCorporationLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"Select c.New_CorporationCode As new_CorporationCode, c.New_CorporationId AS ID, c.CorporationName AS CorporationName, c.CorporationName AS VALUE from nltvNew_Corporation(@SystemUserId) c
                        Where c.DeletionStateCode = 0 And statuscode = 1";

        StaticData sd = new StaticData();

        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

        if (_userApproval.AllRecipientCorporation)
        {
            sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid("00000000-AAAA-BBBB-CCCC-000000000001"));
        }
        else
        {
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        }

        var like = ((CrmComboComp)sender).Query();
        if (!string.IsNullOrEmpty(like))
        {
            strSql += @" AND c.CorporationName LIKE '%' + @CorporationName + '%' ";
            sd.AddParameter("CorporationName", DbType.String, like);
        }

        strSql += " ORDER BY c.CorporationName";

        BindCombo(((CrmComboComp)sender), sd, strSql);
    }

    protected void new_CountryLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"/* DECLARE @SystemUserId UNIQUEIDENTIFIER =  '00000001-2211-44A8-BAAA-89AC131336A9' */
            DECLARE @LangId AS INT
            DECLARE @TempLangId AS INT
            SELECT @LangId = LanguageId FROM vSystemUser
            WHERE SystemUserId = @SystemUserId     
            SELECT		
                        c.new_CountryID AS ID, 
						cE.new_TelephoneCode,
                        CASE @TempLangId 
                             WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                             ELSE cl.Value
                        END AS CountryName,
                        CASE @TempLangId 
                             WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                             ELSE cl.Value
                        END AS VALUE
            FROM New_CountryBase c
            INNER JOIN New_CountryLabel cl
            ON c.New_CountryId = cl.New_CountryId AND cl.LangId = @LangId
			INNER JOIN New_CountryExtension cE
			ON c.New_CountryId = cE.New_CountryId
                 WHERE 
			C.DeletionStateCode = 0
			AND cE.new_TelephoneCode IS NOT NULL
			";

        StaticData sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);

        //var like = new_SenderCountryID.Query();
        var like = ((CrmComboComp)sender).Query();
        if (!string.IsNullOrEmpty(like))
        {
            strSql += @" AND (CASE @TempLangId 
                                WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                                ELSE cl.Value
                                END LIKE '%' + @CountryName + '%' 
                                OR CASE @TempLangId 
                                WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                                ELSE cl.Value
                                END LIKE '%' + UPPER(@CountryNameTR COLLATE SQL_Latin1_General_CP1_CI_AS) + '%' ) ";

            sd.AddParameter("CountryName", DbType.String, like.Replace("İ", "I"));
            like = like.Replace("i", "İ");
            like = like.Replace("ı", "I");

            sd.AddParameter("CountryNameTR", DbType.String, like);
        }

        strSql += " ORDER BY CountryName";

        BindCombo(((CrmComboComp)sender), sd, strSql);
    }

    private void BindCombo(CrmComboComp combo, StaticData sd, string strSql)
    {
        var start = combo.Start() - 1;
        var limit = combo.Limit();

        if (start < 0)
        {
            start = 0;
        }

        BindCombo(combo, sd, strSql, start, limit);
    }
    private void BindCombo(CrmComboComp combo, StaticData sd, string strSql, int start, int limit)
    {
        var t = sd.ReturnDataset(strSql).Tables[0];

        DataTable t2 = t.Clone();

        var end = start + limit > t.Rows.Count ? t.Rows.Count : start + limit;

        for (int i = start; i < end; i++)
        {
            DataRow dr = t2.NewRow();
            dr.ItemArray = t.Rows[i].ItemArray;
            t2.Rows.Add(dr);
        }

        combo.TotalCount = t.Rows.Count;
        combo.DataSource = t2;
        combo.DataBind();
    }
}