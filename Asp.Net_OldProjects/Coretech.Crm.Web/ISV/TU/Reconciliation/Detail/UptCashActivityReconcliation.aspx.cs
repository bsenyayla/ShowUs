using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;

using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI.WebControls;
using TuFactory.Cash;
using TuFactory.Data;
using TuFactory.Exceptions;
//using TuFactory.Reconciliation.UptReconcliation;
using UptBankReconciliation;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_Detail_UptCashActivityReconcliation : BasePage
    {

        private Guid QueryId = Guid.Empty;
        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                CreateViewGrid();

                dStartDate.ReadOnly = false;
                dStartDate.Value = DateTime.Today.AddDays(-1);

            }
        }

        private DataSet GetUptReconcliationTotal(Guid officeId, DateTime startDate)
        {

            CashReconciliationFactory fac = new CashReconciliationFactory();

            DataSet ds = fac.GetCashReconciliationData(officeId, startDate);

            return ds;
        }


        protected void GetOfficeTotals(object sender, AjaxEventArgs e)
        {
            DataSet ds = GetUptReconcliationTotal(ValidationHelper.GetGuid(new_OfficeId.Value), ValidationHelper.GetDate(dStartDate.Value));

            GrdTotalCount.DataSource = ds.Tables[0];
            GrdTotalCount.DataBind();
            GrdTotalAmount.DataSource = ds.Tables[1];
            GrdTotalAmount.DataBind();


        }

        public void CreateViewGrid()
        {
            var gpc = new GridPanelCreater();
            gpc.CreateViewGrid("CashTRansactionListView", GrdCashTransactions);

            string strSelected = ViewFactory.GetViewIdbyUniqueName("CashTRansactionListView").ToString();

            QueryId = ValidationHelper.GetGuid(strSelected);

            hdnViewList.Value = strSelected;

            if (string.IsNullOrEmpty(strSelected))
                return;
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));

            var getColumnList = new UserPoolMapDb().GetColumnList(Convert.ToInt32(hdnPoolId.Value), QueryId, new UserPoolMapDb().GetAttributeListString(new UserPoolMapDb().getColumnSet(gpw.View.ColumnSetXml)));
            List<GridColumns> lstAddetColumn = GrdCashTransactions.ColumnModel.Columns.ToList();
            GrdCashTransactions.ClearColumns();

            foreach (GridColumns item in lstAddetColumn)
            {
                var count = (from c in getColumnList
                             where c.AttributeName == item.Header && c.Hide == true
                             select c).Count();
                if (count == 0)
                    GrdCashTransactions.AddColumn(item);
            }
            GrdCashTransactions.ReConfigure();

            var defaultEditPage = gpw.View.DefaultEditPage.ToString();
            hdnViewDefaultEditPage.Value = defaultEditPage;


        }
        protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
        {
            if (string.IsNullOrEmpty(new_OfficeId.Value))
            {
                GrdCashTransactions.Clear();
                GrdCashTransactions.DataBind();
                return;
            }
            if (dStartDate.Value == null)
            {
                GrdCashTransactions.Clear();
                GrdCashTransactions.DataBind();
                return;
            }


            DataTable retDt = new DataTable();

            DataTable dt = new DataTable();
            string sql = @"	SELECT   New_CashTransactionId AS ID,New_CashTransactionId,CashTransactionRefNo AS VALUE,CashTransactionRefNo,ct.CreatedBy,ct.CreatedByName, 
                                CASE 
	                                WHEN cth.new_ConfirmDate IS NULL THEN ct.CreatedOn
	                                ELSE cth.new_ConfirmDate
                                END AS [CreatedOn],
                                CASE 
	                                WHEN cth.new_ConfirmDate IS NULL THEN ct.CreatedOn
	                                ELSE cth.new_ConfirmDate
                                END AS [CreatedOnUtcTime]
                                ,new_CashNameID,new_CashNameIDName,new_Amount ,new_AmountCurrency,new_AmountCurrencyName,new_AmountCurrencyName AS new_Amount_CurrencyName,
								new_TransferID,new_TransferIDName ,new_PaymentID,new_PaymentIDName ,new_RefundPaymentID,
								new_RefundPaymentIDName ,new_GsmPaymentId,new_GsmPaymentIdName,ctt.Label AS new_TransactionTypeName,
								ct.new_TransactionType,new_Balance,new_BalanceCurrency,new_BalanceCurrencyName,new_BalanceCurrencyName AS new_Balance_CurrencyName 
                                FROM vNew_CashTransaction(NOLOCK) ct 
                                LEFT OUTER JOIN vNew_CashTransactionHeader (NOLOCK) cth ON ct.new_CashTransactionHeaderId = cth.new_CashTransactionHeaderId AND cth.new_Status=2
                                INNER JOIN new_PLNew_CashTransaction_new_TransactionType ctt ON ctt.Value=ct.new_TransactionType AND ctt.LangId=1055
                                INNER JOIN vNew_Cash(NOLOCK) c ON c.New_CashId = ct.new_CashNameID AND c.DeletionStateCode=0
                                WHERE ct.DeletionStateCode=0 AND CAST(DATEADD(HOUR,3 ,CASE 
	                                WHEN cth.new_ConfirmDate IS NULL THEN ct.CreatedOn
	                                ELSE cth.new_ConfirmDate
                                END) AS DATE)=@Date AND c.new_OfficeName=@OfficeId 
                            ";

            var sort = GrdCashTransactions.ClientSorts();
            if (sort == null)
            { sort = string.Empty; }

            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CashTRansactionListView");
            var spList = new List<CrmSqlParameter>();

            if (!string.IsNullOrEmpty(new_OfficeId.Value))
            {
                spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "OfficeId", Value = new_OfficeId.Value });
            }

            if (dStartDate.Value != null)
            {
                spList.Add(new CrmSqlParameter() { Dbtype = DbType.Date, Paramname = "Date", Value = ValidationHelper.GetDate(dStartDate.Value) });
            }

            if (!string.IsNullOrEmpty(new_CashNameID.Value))
            {
                sql += " AND c.New_CashId=@CashId ";
                spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "CashId", Value = new_CashNameID.Value });
            }
            if (!string.IsNullOrEmpty(cmbCurrency.Value))
            {
                sql += " AND new_AmountCurrencyName=@CurrencyName ";
                spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "CurrencyName", Value = cmbCurrency.Value });
            }

            try
            {
                var gpc = new GridPanelCreater();
                var cnt = 0;
                var start = GrdCashTransactions.Start();
                var limit = GrdCashTransactions.Limit();
                var t = gpc.GetFilterData(sql, viewqueryid, sort, spList, start, limit, out cnt, out dt);
                GrdCashTransactions.TotalCount = cnt;

                if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
                {
                    var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
                    gpw.Export(dt);
                }

                GrdCashTransactions.DataSource = t;
                GrdCashTransactions.DataBind();
            }
            catch (TuException ex)
            {
                ex.Show();
            }


        }


        protected void new_CashIdLoadEvent(object sender, AjaxEventArgs e)
        {
        
            if (new_OfficeId.IsEmpty)
            {
                var msg = new MessageBox { Width = 500 };
                msg.Show("Ofis Seçmelisiniz!");
                return;
            }

            string strSql = @"	Select New_CashId AS ID,New_CashId,CashName AS VALUE,CashName
	 From vNew_Cash (NOLOCK) WHERE DeletionStateCode=0 AND  new_OfficeName =@OfficeId";
            const string sort = "";
            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CashLookup");
            var gpc = new GridPanelCreater();
            int cnt;
            var start = new_CashNameID.Start();
            var limit = new_CashNameID.Limit();
            var spList = new List<CrmSqlParameter>();

            var prm1 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "OfficeId",
                Value = ValidationHelper.GetGuid(new_OfficeId.Value)
            };
            spList.Add(prm1);         


            var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
            new_CashNameID.TotalCount = cnt;
            new_CashNameID.DataSource = t;
            new_CashNameID.DataBind();
        }


    }

}








