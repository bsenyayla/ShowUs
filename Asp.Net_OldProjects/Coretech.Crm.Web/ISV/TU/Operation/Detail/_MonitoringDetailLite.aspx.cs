using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Object.User;
using System.Linq;
using TuFactory.TuUser;
using Coretech.Crm.Factory;

public partial class Operation_Detail_MonitoringDetailLite : BasePage
{
    private TuUserApproval _userApproval = null;

    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

        if (!RefleX.IsAjxPostback)
        {
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
        try
        {
            var sort = GridPanelMonitoring.ClientSorts();
            if (sort == null)
                sort = string.Empty;
            string strSql = @"
        	SELECT * FROM 
            (
	            SELECT	Mt.ProcessMonitoring AS VALUE ,			
			            Mt.New_ProcessMonitoringId AS ID ,Mt.ProcessMonitoring,
			            Mt.new_TransactionItemId,Mt.new_TransactionItemIdName,
			            hi.CreatedOn new_TransactionDate,hi.CreatedOnUtcTime new_TransactionDateUtcTime ,
			            Mt.new_TransactionAmount,Mt.new_TransactionAmountCurrencyName AS new_TransactionAmount_CurrencyName,
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
			            hi.OwningUser,
			            hi.OwningUserName,
			            ObjectId,
			            Mt.new_TransactionConfirmId,
			            Mt.new_TransactionConfirmIdName,
			            Mt.new_OperationType,
			            Mt.new_OperationTypeName,
			            hi.new_ConfirmStatusId AS new_ConfirmStatus,
			            hi.new_ConfirmStatusIdName AS new_ConfirmStatusName,
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
			            Mt.new_ReceivedAmount1CurrencyName AS new_ReceivedAmount1_CurrencyName,
			            Mt.new_ReceivedAmount2CurrencyName AS new_ReceivedAmount2_CurrencyName,
			            Mt. new_TotalReceivedAmountCurrencyName AS new_TotalReceivedAmount_CurrencyName,
			            Mt.new_RecipientCorporationId,
			            Mt.new_RecipientCorporationIdName

	              FROM  dbo.tvNew_ProcessMonitoring(@SystemUserId) AS Mt
            INNER JOIN  nltvNew_TarnsactionHistory(@SystemUserId) AS hi ON hi.new_PaymentId = mt.New_ProcessMonitoringId 

             UNION ALL

	            SELECT	Mt.ProcessMonitoring AS VALUE ,			
			            Mt.New_ProcessMonitoringId AS ID ,Mt.ProcessMonitoring,
			            Mt.new_TransactionItemId,Mt.new_TransactionItemIdName,
			            hi.CreatedOn new_TransactionDate,hi.CreatedOnUtcTime new_TransactionDateUtcTime ,
			            Mt.new_TransactionAmount,Mt.new_TransactionAmountCurrencyName AS new_TransactionAmount_CurrencyName,
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
			            hi.OwningUser,
			            hi.OwningUserName,
			            ObjectId,
			            Mt.new_TransactionConfirmId,
			            Mt.new_TransactionConfirmIdName,
			            Mt.new_OperationType,
			            Mt.new_OperationTypeName,
			            hi.new_ConfirmStatusId AS new_ConfirmStatus,
			            hi.new_ConfirmStatusIdName AS new_ConfirmStatusName,
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
			            Mt.new_ReceivedAmount1CurrencyName AS new_ReceivedAmount1_CurrencyName,
			            Mt.new_ReceivedAmount2CurrencyName AS new_ReceivedAmount2_CurrencyName,
			            Mt. new_TotalReceivedAmountCurrencyName AS new_TotalReceivedAmount_CurrencyName,
			            Mt.new_RecipientCorporationId,
			            Mt.new_RecipientCorporationIdName

	              FROM  dbo.tvNew_ProcessMonitoring(@SystemUserId) AS Mt
            INNER JOIN  nltvNew_TarnsactionHistory(@SystemUserId) AS hi ON hi.new_TransferId = mt.New_ProcessMonitoringId 

             UNION ALL

	            SELECT	Mt.ProcessMonitoring AS VALUE ,			
			            Mt.New_ProcessMonitoringId AS ID ,Mt.ProcessMonitoring,
			            Mt.new_TransactionItemId,Mt.new_TransactionItemIdName,
			            hi.CreatedOn new_TransactionDate,hi.CreatedOnUtcTime new_TransactionDateUtcTime ,
			            Mt.new_TransactionAmount,Mt.new_TransactionAmountCurrencyName AS new_TransactionAmount_CurrencyName,
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
			            hi.OwningUser,
			            hi.OwningUserName,
			            ObjectId,
			            Mt.new_TransactionConfirmId,
			            Mt.new_TransactionConfirmIdName,
			            Mt.new_OperationType,
			            Mt.new_OperationTypeName,
			            hi.new_ConfirmStatusId AS new_ConfirmStatus,
			            hi.new_ConfirmStatusIdName AS new_ConfirmStatusName,
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
			            Mt.new_ReceivedAmount1CurrencyName AS new_ReceivedAmount1_CurrencyName,
			            Mt.new_ReceivedAmount2CurrencyName AS new_ReceivedAmount2_CurrencyName,
			            Mt. new_TotalReceivedAmountCurrencyName AS new_TotalReceivedAmount_CurrencyName,
			            Mt.new_RecipientCorporationId,
			            Mt.new_RecipientCorporationIdName

	              FROM  dbo.tvNew_ProcessMonitoring(@SystemUserId) AS Mt
            INNER JOIN  nltvNew_TarnsactionHistory(@SystemUserId) AS hi ON hi.new_RefundPaymentId = mt.New_ProcessMonitoringId 

            ) MT 

            WHERE  1=1";

            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("PROCESSMONITORING_DETAIL");
            var spList = new List<CrmSqlParameter>();
            var processMonitoringId = QueryHelper.GetString("recid");
            strSql += " And MT.ID = @New_ProcessMonitoringId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "New_ProcessMonitoringId",
                Value = ValidationHelper.GetGuid(processMonitoringId)
            });

            var gpc = new GridPanelCreater();


            var cnt = 0;
            var start = GridPanelMonitoring.Start();
            var limit = GridPanelMonitoring.Limit();
            var dtb = new DataTable();
            var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
            GridPanelMonitoring.TotalCount = cnt;

            TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
            List<string> fields = new List<string>() { "new_RecipientFullName"};
            t = cryptor.DecryptFieldsInFilterData(fields, t);

            if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            {
                if (!_userApproval.ReferenceCanBeSeen)
                {
                    DataTable maskedData = new DataTable();
                    maskedData = dtb.Clone();

                    foreach (DataRow item in dtb.Rows)
                    {
                        string tu_Ref = item.Field<string>("ProcessMonitoring");
                        var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref);  //string.Concat(tu_ref.Substring(0, 3), "".PadRight(10, 'X'));

                        item["ProcessMonitoring"] = masked_tu_ref;
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
                    var masked_tu_ref = string.Concat(tu_Ref.Substring(0, 3), "".PadRight(8, 'X'));

                    item["ProcessMonitoring"] = masked_tu_ref;
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
}