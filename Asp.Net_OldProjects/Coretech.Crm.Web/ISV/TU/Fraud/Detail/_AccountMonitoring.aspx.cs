using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Object.User;
using TuFactory.TuUser;
using Coretech.Crm.Factory.Crm.Dynamic;

public partial class Fraud_Detail_AccountMonitoring : BasePage
{
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        _activeUser = ufFactory.GetActiveUser();

        if (!RefleX.IsAjxPostback)
        {
            pnl1.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_SEARCH");
            btnDownload.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
            CreateViewGrid();
            //new_CorporationId.Value = _activeUser.CorporationId.ToString();
            //new_OfficeId.Value = _activeUser.OfficeId.ToString();

            if (new_FormTransactionDate1.Value != null)
            {
                new_FormTransactionDate2.Value = new_FormTransactionDate1.Value;
            }
        }
    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("CUSTACCOUNTFRAUDLOG_LIST", GridPanelAccountMonitoring);
        string strSelected;
        strSelected = ViewFactory.GetViewIdbyUniqueName("CUSTACCOUNTFRAUDLOG_LIST").ToString();
        hdnViewList.Value = strSelected;
        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
        var DefaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnViewDefaultEditPage.Value = DefaultEditPage;
    }

    private string GetFilterValidation()
    {
        string errMsg = string.Empty;
        int TransferDatePeriod = ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("TRANSFERDATE_AML_PERIOD"), 180);
        int TransferSenderRecipientDatePeriod = ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("TRANSFERDATE_AML_WITH_SENDER_RECIPIENT_PERIOD"), 240);

        if (!string.IsNullOrEmpty(ProcessMonitoring.Value))
        {
            return errMsg;
        }

        if (string.IsNullOrEmpty(ProcessMonitoring.Value) && (new_FormTransactionDate1.Value == null || new_FormTransactionDate2.Value == null))
        {
            errMsg = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_REF_AND_DATE_NOT_NULL");
        }

        if (string.IsNullOrEmpty(ProcessMonitoring.Value) && !(new_FormTransactionDate1.Value == null || new_FormTransactionDate2.Value == null))
        {
            if (string.IsNullOrEmpty(new_SenderId.Value))
            {
                double dateDiff = (ValidationHelper.GetDate(new_FormTransactionDate2.Value) - ValidationHelper.GetDate(new_FormTransactionDate1.Value)).TotalDays;
                if (dateDiff > TransferDatePeriod)
                {
                    errMsg = string.Format(CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_AML_NO_REF_MAX_N_DAY"), TransferDatePeriod);
                }
            }
            else
            {
                double dateDiff = (ValidationHelper.GetDate(new_FormTransactionDate2.Value) - ValidationHelper.GetDate(new_FormTransactionDate1.Value)).TotalDays;
                if (dateDiff > TransferSenderRecipientDatePeriod)
                {
                    errMsg = string.Format(CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_AML_NO_REF_MAX_N_DAY"), TransferSenderRecipientDatePeriod);
                }
            }
        }

        return errMsg;
    }

    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        string filtermsg = GetFilterValidation();
        if (!string.IsNullOrEmpty(filtermsg))
        {
            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", filtermsg);

            GridPanelAccountMonitoring.DataBind();
            return;
        }




        var sort = GridPanelAccountMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;
        string strSql = @"SELECT 
Mt.New_CustAccountFraudLogId AS ID
,Mt.ReferenceNo AS VALUE
,Mt.New_CustAccountFraudLogId
,Mt.ReferenceNo
,Mt.CreatedOn
,Mt.CreatedOnUtcTime
,Mt.ModifiedOn
,Mt.ModifiedOnUtcTime
,Mt.CreatedBy
,Mt.CreatedByName
,Mt.ModifiedBy
,Mt.ModifiedByName
,Mt.OwningUser
,Mt.OwningUserName
,Mt.OwningBusinessUnit
,Mt.OwningBusinessUnitName
,Mt.DeletionStateCode
,Mt.statuscode
,Mt.statuscodeName
,Mt.new_Amount
,Mt.new_AmountCurrency
,Mt.new_AmountCurrencyName
,Mt.new_AmountCurrencyName as new_Amount_CurrencyName
,Mt.new_FraudConfirmCancelReason
,Mt.new_FraudCancelReason
,Mt.new_OperationStatus
,Mt.new_OperationStatusName
,Mt.new_FraudStatus
,Mt.new_FraudStatusName
,Mt.new_FraudContinueReason
,Mt.new_SenderID
,Mt.new_SenderIDName
,Mt.new_CustAccountTypeId
,Mt.new_CustAccountTypeIdName
,Mt.new_OfficeId
,Mt.new_OfficeIdName
,Mt.new_CorporationId
,Mt.new_CorporationIdName
,Mt.new_ScenerioID
,Mt.new_ScenerioIDName
,Mt.new_CustAccountId
,Mt.new_CustAccountIdName
,Mt.new_CustAccountOperationType
,Mt.new_CustAccountOperationTypeName
,Mt.new_CustAccountOperationId
,Mt.new_CustAccountOperationIdName
,Mt.new_CustAccountCurrencyId
,Mt.new_CustAccountCurrencyIdName
,Mt.new_FraudConfirmStatusIdName
,Mt.new_FraudConfirmStatusId
,Mt.new_CustAccountFraudCancelReasonIdName
,Mt.new_CustAccountFraudCancelReasonId
,Mt.new_CustAccountFraudContinueReasonIdName
,Mt.new_CustAccountFraudContinueReasonId
,Mt.new_CustAccountFraudConfirmCancelReasonIdName
,Mt.new_CustAccountFraudConfirmCancelReasonId
from  dbo.nltvnew_custaccountfraudLog(@SystemUserId) as MT
Inner Join vnew_FraudConfirmStatus FC on MT.new_FraudConfirmStatusId=FC.New_FraudConfirmStatusId
Where 1=1 
";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CUSTACCOUNTFRAUDLOG_LIST");
        var spList = new List<CrmSqlParameter>();

        

        if (new_FormTransactionDate1.Value != null)
        {
            strSql += " And MT.CreatedOnUtcTime>=dbo.fnLocalTimeToUTCForUser(@CreatedOnUtcTime,@SystemUserId)";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "CreatedOnUtcTime",
                Value = ValidationHelper.GetDate(new_FormTransactionDate1.Value)
            });
        }
        if (new_FormTransactionDate2.Value != null)
        {
            strSql += " And MT.CreatedOnUtcTime<dbo.fnLocalTimeToUTCForUser(@CreatedOnUtcTime2,@SystemUserId)+1";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "CreatedOnUtcTime2",
                Value = ValidationHelper.GetDate(new_FormTransactionDate2.Value)
            });
        }
        if (ProcessMonitoring.Value != "")
        {
            strSql += " And MT.ReferenceNo like '%'+@ReferenceNo +'%'";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "ReferenceNo",
                Value = ValidationHelper.GetString(ProcessMonitoring.Value)
            });
        }
        if (new_CustAccountOperationType.Value != "")
        {
            strSql += " And MT.new_CustAccountOperationType = @new_OperationType ";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_OperationType",
                Value = ValidationHelper.GetGuid(new_CustAccountOperationType.Value)
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

        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelAccountMonitoring.Start();
        var limit = GridPanelAccountMonitoring.Limit();
        var dtb = new DataTable();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
        GridPanelAccountMonitoring.TotalCount = cnt;

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

        GridPanelAccountMonitoring.DataSource = t;
        GridPanelAccountMonitoring.DataBind();
    }
}