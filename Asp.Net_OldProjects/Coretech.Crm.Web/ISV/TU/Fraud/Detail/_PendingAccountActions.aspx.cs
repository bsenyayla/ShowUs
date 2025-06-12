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

public partial class Fraud_Detail_PendingAccountActions : BasePage
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
        int TransferDatePeriod = ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("TRANSFERDATE_PERIOD"), 180);
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
,MT.CreatedOn
,MT.CreatedOnUtcTime
,MT.ModifiedOn
,MT.ModifiedOnUtcTime
,MT.CreatedBy
,MT.CreatedByName
,MT.ModifiedBy
,MT.ModifiedByName
,MT.OwningUser
,MT.OwningUserName
,MT.OwningBusinessUnit
,MT.OwningBusinessUnitName
,MT.DeletionStateCode
,MT.statuscode
,MT.statuscodeName
,MT.new_Amount
,MT.new_AmountCurrency
,MT.new_AmountCurrencyName
,Mt.new_AmountCurrencyName as new_Amount_CurrencyName
,MT.new_FraudConfirmCancelReason
,MT.new_FraudCancelReason
,MT.new_OperationStatus
,MT.new_OperationStatusName
,MT.new_FraudStatus
,MT.new_FraudStatusName
,MT.new_FraudContinueReason
,MT.new_SenderID
,MT.new_SenderIDName
,MT.new_CustAccountTypeId
,MT.new_CustAccountTypeIdName
,MT.new_OfficeId
,MT.new_OfficeIdName
,MT.new_CorporationId
,MT.new_CorporationIdName
,MT.new_ScenerioID
,MT.new_ScenerioIDName
,MT.new_CustAccountId
,MT.new_CustAccountIdName
,MT.new_CustAccountOperationType
,MT.new_CustAccountOperationTypeName
,MT.new_CustAccountOperationId
,MT.new_CustAccountOperationIdName
,MT.new_CustAccountCurrencyId
,MT.new_CustAccountCurrencyIdName
,MT.new_FraudConfirmStatusIdName
,MT.new_FraudConfirmStatusId
,MT.new_CustAccountFraudCancelReasonIdName
,MT.new_CustAccountFraudCancelReasonId
,MT.new_CustAccountFraudContinueReasonIdName
,MT.new_CustAccountFraudContinueReasonId
,MT.new_CustAccountFraudConfirmCancelReasonIdName
,MT.new_CustAccountFraudConfirmCancelReasonId
from  dbo.nltvnew_custaccountfraudLog(@SystemUserId) as MT
Inner Join vnew_FraudConfirmStatus FC on MT.new_FraudConfirmStatusId=FC.New_FraudConfirmStatusId
Where 1=1 
And MT.new_FraudStatus =1
and FC.new_ExtCode not in('FR004','FR004C')
";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CUSTACCOUNTFRAUDLOG_LIST");
        var spList = new List<CrmSqlParameter>();
        //if (new_CorporationId.Value != "")
        //{
        //    strSql += " And MT.new_CorporationId=@new_CorporationId";
        //    spList.Add(new CrmSqlParameter()
        //    {
        //        Dbtype = DbType.Guid,
        //        Paramname = "new_CorporationId",
        //        Value = ValidationHelper.GetGuid(new_CorporationId.Value)
        //    });
        //}

        //if (new_OfficeId.Value != "")
        //{
        //    strSql += " And MT.new_OfficeId=@new_OfficeId";
        //    spList.Add(new CrmSqlParameter()
        //    {
        //        Dbtype = DbType.Guid,
        //        Paramname = "new_OfficeId",
        //        Value = ValidationHelper.GetGuid(new_OfficeId.Value)
        //    });
        //}
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