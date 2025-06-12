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
using System.Linq;
using Coretech.Crm.Factory.Crm.Dynamic;

public partial class Fraud_Detail_PendingTransactions : BasePage
{
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        _activeUser = ufFactory.GetActiveUser();
        //if (!_userApproval.ApprovalConfirm)
        //    btnConfirm.visible = false;
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
        gpc.CreateViewGrid("FRAUDLOG_LIST", GridPanelMonitoring);
        string strSelected;
        strSelected = ViewFactory.GetViewIdbyUniqueName("FRAUDLOG_LIST").ToString();
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
            if (string.IsNullOrEmpty(new_RecipientFullName.Value) && string.IsNullOrEmpty(new_SenderId.Value))
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

            GridPanelMonitoring.DataBind();
            return;
        }



        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;
        string strSql =
            @" 
        	Select 
 Mt.New_FraudLogId AS ID 
,Mt.ReferenceNo AS VALUE 
,Mt.New_FraudLogId 
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
,Mt.new_ScenerioID
,Mt.new_ScenerioIDName
,Mt.new_Amount
,Mt.new_AmountCurrency
,Mt.new_AmountCurrencyName
,Mt.new_AmountCurrencyName as new_Amount_CurrencyName
,Mt.new_SenderID
,Mt.new_SenderIDName
,Mt.new_RecipientID
,Mt.new_RecipientIDName
,Mt.new_RecipientName
,Mt.new_CorporationCountryIDName
,Mt.new_CorporationCountryID
,Mt.new_RecipientCountryIDName
,Mt.new_RecipientCountryID
,Mt.new_TransactionTargetOptionIDName
,Mt.new_TransactionTargetOptionID
,Mt.new_SourceTransactionTypeIDName
,Mt.new_SourceTransactionTypeID
,Mt.new_TargetTransactionTypeIDName
,Mt.new_TargetTransactionTypeID
,Mt.new_TransactionItemIdName
,Mt.new_TransactionItemId
,Mt.new_CorporationOffice
,Mt.new_SenderInfo
,Mt.new_RecipientInfo
,Mt.new_OperationDate
,Mt.new_OperationDateUtcTime
,Mt.new_OperationUserId
,Mt.new_OperationUserIdName
,Mt.new_BlackListNo
,Mt.new_RecordCategory
,Mt.new_TransferID
,Mt.new_TransferIDName
,Mt.new_PaymentID
,Mt.new_PaymentIDName
,Mt.new_RecipientAccountNumber
,Mt.new_RecipientIBAN
,Mt.new_SenderAccountNumber
,Mt.new_SenderIBAN
,Mt.new_OfficeId
,Mt.new_OfficeIdName
,Mt.new_CorporationId
,Mt.new_CorporationIdName
,Mt.new_FraudStatus
,Mt.new_FraudStatusName
,Mt.new_FraudCancelReasonIdName
,Mt.new_FraudCancelReasonId
,Mt.new_FraudCancelReason
,Mt.new_FraudContinueReasonIdName
,Mt.new_FraudContinueReasonId
,Mt.new_FraudConfirmStatusIdName
,Mt.new_FraudConfirmStatusId
,Mt.new_FraudConfirmCancelReasonIdName
,Mt.new_FraudConfirmCancelReasonId
,Mt.new_FraudConfirmCancelReason
,Mt.new_FraudContinueReason
,Mt.new_OperationDateForCountry
,Mt.new_GsmPaymentId
,Mt.new_GsmPaymentIdName
from  dbo.nltvnew_fraudLog(@SystemUserId) as Mt
Inner Join vnew_FraudConfirmStatus fc on Mt.new_FraudConfirmStatusId=FC.New_FraudConfirmStatusId
Where 1=1 
And Mt.new_FraudStatus =1
and Fc.new_ExtCode not in('FR004','FR004C')
";

        /*Inner Join vNew_FraudConfirmStatus Cs on (Cs.New_FraudConfirmStatusId=Mt.new_FraudConfirmStatusId AND Cs.DeletionStateCode=0)*/

        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("FRAUDLOG_LIST");
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
            strSql += " And MT.CreatedOn >=  @CreatedOnUtcTime"; // dbo.fnLocalTimeToUTCForUser(@CreatedOnUtcTime,@SystemUserId)";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "CreatedOnUtcTime",
                Value = ValidationHelper.GetDate(new_FormTransactionDate1.Value)
            });
        }
        if (new_FormTransactionDate2.Value != null)
        {
            strSql += " And MT.CreatedOn < @CreatedOnUtcTime2 + 1";//dbo.fnLocalTimeToUTCForUser(@CreatedOnUtcTime2,@SystemUserId)+1";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "CreatedOnUtcTime2",
                Value = ValidationHelper.GetDate(new_FormTransactionDate2.Value)
            });
        }



        //if (ProcessMonitoring.Value != "")
        //{
        //    strSql += " And MT.new_TransferIDName like '%'+@new_TransferIDName +'%'";
        //    spList.Add(new CrmSqlParameter()
        //    {
        //        Dbtype = DbType.String,
        //        Paramname = "new_TransferIDName",
        //        Value = ValidationHelper.GetString(ProcessMonitoring.Value)
        //    });
        //}

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

        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        if (new_RecipientFullName.Value != "")
        {
            strSql += " And MT.new_RecipientIDName like '%'+@new_RecipientFullName +'%'";
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

        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelMonitoring.Start();
        var limit = GridPanelMonitoring.Limit();
        var dtb = new DataTable();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
        GridPanelMonitoring.TotalCount = cnt;


        List<string> fields = new List<string>() { "new_RecipientIDName", "new_RecipientName" };
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

        if (!_userApproval.ReferenceCanBeSeen)
        {
            List<Dictionary<string, object>> maskedList = new List<Dictionary<string, object>>();

            foreach (var item in t)
            {
                string tu_Ref = item.Where(x => x.Key.Equals("ReferenceNo")).Select(x => x.Value).FirstOrDefault().ToString();
                var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref); // string.Concat(tu_Ref.Substring(0, 3), "".PadRight(10, 'X'));

                item["ReferenceNo"] = masked_tu_ref;
                item["new_TransferIDName"] = masked_tu_ref;
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

}