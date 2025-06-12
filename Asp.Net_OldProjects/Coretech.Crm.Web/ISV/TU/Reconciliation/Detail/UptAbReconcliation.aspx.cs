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
using System.Globalization;
using System.Linq;
using System.Web.UI.WebControls;
using TuFactory.Data;
//using TuFactory.Reconciliation.UptReconcliation;
using UptBankReconciliation;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_Detail_UptAbReconcliation : BasePage
    {

        private Guid QueryId = Guid.Empty;
        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                CreateViewGrid();
                CreateproblemTransactionViewGrid();
                var recId = QueryHelper.GetString("recid");

                if (!string.IsNullOrEmpty(recId))
                {
                    hdnRecId.SetValue(recId);
                    btnSave.Visible = false;
                    btnGetReConciliation.Visible = true;
                    txtBankTransactionNumber.Visible = true;
                    cmbCurrency.Visible = true;
                    cmbDirection.Visible = true;
                    new_ReconcliationStatus.Visible = true;
                    new_ReconcliationStatus.Clear();
                    dEndDate.ReadOnly = true;
                    dStartDate.ReadOnly = true;

                    LoadTotalData(ValidationHelper.GetGuid(recId));
                }
                else
                {
                    btnSave.Visible = true;
                    btnGetReConciliation.Visible = false;
                    txtBankTransactionNumber.Visible = false;
                    cmbCurrency.Visible = false;
                    cmbDirection.Visible = false;
                    new_ReconcliationStatus.Visible = false;
                    dEndDate.ReadOnly = false;
                    dStartDate.ReadOnly = false;


                    dStartDate.Value = DateTime.Today;
                    dEndDate.Value = DateTime.Today;
                }


            }
        }

        protected void SaveReConciliation(object sender, AjaxEventArgs e)
        {
            var startDate = ValidationHelper.GetDate(dStartDate.Value);
            var endDate = ValidationHelper.GetDate(dEndDate.Value);

            try
            {
                QScript("LogCurrentPage();");

                UptReconcliationFactory reconcliationFactory = new UptReconcliationFactory();
                Guid recId = reconcliationFactory.SaveUptReconcliationHeader(App.Params.CurrentUser.SystemUserId, startDate, endDate);

                if (recId != null && recId != Guid.Empty)
                {
                    QScript("alert('İşleminiz kuyruğa alınmıştır, sonuçlandığında mail bilgilendirilmesi yapılacaktır.');");

                    QScript("RefreshParetnGridForCashTransaction(true);");

                }
                else
                {
                    MessageBox msg = new MessageBox() { Height = 200 };
                    msg.Show("Hata", "Bilinmeyen Hata!");
                }
            }
            catch (Exception ex)
            {
                MessageBox msg = new MessageBox() { Height = 200 };
                msg.Show("Hata", "", "İşlem sırasında bir hata ile karşılaşıldı. <br/> Hata: " + ex.Message);
            }

        }

        private void LoadTotalData(Guid uptReconcliationHeaderId)
        {
            DataSet totalds = GetUptReconcliationTotal(uptReconcliationHeaderId);

            GrdTotalReConciliationTotal1.DataSource = totalds.Tables[1];
            GrdTotalReConciliationTotal1.DataBind();

            //GrdTotalReConciliationTotal2.DataSource = totalds.Tables[1];
            //GrdTotalReConciliationTotal2.DataBind();

            //GrdProblemReconciliations.DataSource = totalds.Tables[0];
            //GrdProblemReconciliations.DataBind();

        }



        private DataSet GetUptReconcliationTotal(Guid uptReconcliationHeaderId)
        {

            UptReconcliationFactory fac = new UptReconcliationFactory();

            DataSet ds = fac.GetUptReconcliationTotal(uptReconcliationHeaderId);

            return ds;
        }

        public void CreateViewGrid()
        {
            var gpc = new GridPanelCreater();
            gpc.CreateViewGrid("ViewUptReconcliationDetail", GrdReConciliation);

            string strSelected = ViewFactory.GetViewIdbyUniqueName("ViewUptReconcliationDetail").ToString();

            QueryId = ValidationHelper.GetGuid(strSelected);

            hdnViewList.Value = strSelected;

            if (string.IsNullOrEmpty(strSelected))
                return;
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));

            var getColumnList = new UserPoolMapDb().GetColumnList(Convert.ToInt32(hdnPoolId.Value), QueryId, new UserPoolMapDb().GetAttributeListString(new UserPoolMapDb().getColumnSet(gpw.View.ColumnSetXml)));
            List<GridColumns> lstAddetColumn = GrdReConciliation.ColumnModel.Columns.ToList();
            GrdReConciliation.ClearColumns();

            foreach (GridColumns item in lstAddetColumn)
            {
                var count = (from c in getColumnList
                             where c.AttributeName == item.Header && c.Hide == true
                             select c).Count();
                if (count == 0)
                    GrdReConciliation.AddColumn(item);
            }
            GrdReConciliation.ReConfigure();

            var defaultEditPage = gpw.View.DefaultEditPage.ToString();
            hdnViewDefaultEditPage.Value = defaultEditPage;


        }

        public void CreateproblemTransactionViewGrid()
        {
            var gpc = new GridPanelCreater();
            gpc.CreateViewGrid("ViewUptRecProbTran", GrdProblemReconciliations);

            string strSelected = ViewFactory.GetViewIdbyUniqueName("ViewUptRecProbTran").ToString();

            QueryId = ValidationHelper.GetGuid(strSelected);

            hdnViewList.Value = strSelected;

            if (string.IsNullOrEmpty(strSelected))
                return;
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));

            var getColumnList = new UserPoolMapDb().GetColumnList(Convert.ToInt32(hdnPoolId.Value), QueryId, new UserPoolMapDb().GetAttributeListString(new UserPoolMapDb().getColumnSet(gpw.View.ColumnSetXml)));
            List<GridColumns> lstAddetColumn = GrdProblemReconciliations.ColumnModel.Columns.ToList();
            GrdProblemReconciliations.ClearColumns();

            foreach (GridColumns item in lstAddetColumn)
            {
                var count = (from c in getColumnList
                             where c.AttributeName == item.Header && c.Hide == true
                             select c).Count();
                if (count == 0)
                    GrdProblemReconciliations.AddColumn(item);
            }
            GrdProblemReconciliations.ReConfigure();

            var defaultEditPage = gpw.View.DefaultEditPage.ToString();
            hdnViewDefaultEditPage2.Value = defaultEditPage;


        }

        protected void ToolbarButtonFindProblemTransactionClick(object sender, AjaxEventArgs e)
        {
            var recId = hdnRecId.Value;
            DataTable retDt = new DataTable();
            if (!string.IsNullOrEmpty(recId))
            {
                //retDt = loadData(ValidationHelper.GetGuid(recId));

                DataTable dt = new DataTable();

                UptReconcliationFactory reconcliationFactory = new UptReconcliationFactory();
                var header = reconcliationFactory.GetUptReconcliationHeader(ValidationHelper.GetGuid(recId));
                if (header != null)
                {
                    CultureInfo ci = new CultureInfo(App.Params.CurrentUser.CultureCode);

                    DateTime myDate = new DateTime();
                    myDate = header.StartDate;
                    // Bu salaklığı Componentin mask yapısından dolayı yaptım. 
                    var datePattern = ci.DateTimeFormat.ShortDatePattern.Replace("d", "dd").Replace("M", "MM").Replace("MMMM", "MM").Replace("dddd", "dd");

                    string us = myDate.Date.ToString(datePattern, ci);
                    dStartDate.SetValue(us);
                    dStartDate.SetIValue(us);

                    DateTime myDate2 = new DateTime();
                    myDate2 = header.EndDate;

                    string us2 = myDate2.Date.ToString(datePattern, ci);
                    dEndDate.SetValue(us2);
                    dEndDate.SetIValue(us2);

                    if (header.ReconcliationStatus == 1)
                    {
                        MessageBox msg = new MessageBox() { Height = 200 };
                        msg.Show("Bilgi", "İşleminiz kuyrukta beklemektedir, sonucu işlem bittiğinde görebilirsiniz.");
                        GrdReConciliation.Clear();
                        GrdReConciliation.DataBind();
                    }
                    else if (header.ReconcliationStatus == 3)
                    {
                        MessageBox msg = new MessageBox() { Height = 200 };
                        msg.Show("Bilgi", "İşleminiz hata almış. Hata: " + header.ReconcliationStatusResult);
                        GrdReConciliation.Clear();
                        GrdReConciliation.DataBind();
                    }
                    else if (header.ReconcliationStatus == 2)
                    {
                        string sql = @"	SELECT BankTransactionNumber,
                                        New_UptReconcliationProblemTransactionId,
                                        New_UptReconcliationProblemTransactionId AS ID,
	                                    BankTransactionNumber AS VALUE,
	                                    new_CurrencyCode
				                        ,new_Amount
				                        ,new_TransferTuRef
				                        ,new_BankDescription
				                        ,new_Status
	                                 FROM vNew_UptReconcliationProblemTransaction (NOLOCK) dt	                     
	                                 WHERE New_UptReconcliationHeaderId = @UptReconcliationHeaderId AND DeletionStateCode =0 ";


                        var sort = GrdProblemReconciliations.ClientSorts();
                        if (sort == null)
                        { sort = string.Empty; }



                        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("ViewUptRecProbTran");
                        var spList = new List<CrmSqlParameter>();
                        spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "UptReconcliationHeaderId", Value = ValidationHelper.GetGuid(recId) });



                        var gpc = new GridPanelCreater();
                        var cnt = 0;
                        var start = GrdProblemReconciliations.Start();
                        var limit = GrdProblemReconciliations.Limit();
                        var t = gpc.GetFilterData(sql, viewqueryid, sort, spList, start, limit, out cnt, out dt);
                        GrdProblemReconciliations.TotalCount = cnt;

                        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
                        {
                            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
                            gpw.Export(dt);
                        }

                        GrdProblemReconciliations.DataSource = t;
                        GrdProblemReconciliations.DataBind();

                    }
                }

            }

        }

        protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
        {
            var recId = hdnRecId.Value;
            DataTable retDt = new DataTable();
            if (!string.IsNullOrEmpty(recId))
            {
                //retDt = loadData(ValidationHelper.GetGuid(recId));

                DataTable dt = new DataTable();

                UptReconcliationFactory reconcliationFactory = new UptReconcliationFactory();
                var header = reconcliationFactory.GetUptReconcliationHeader(ValidationHelper.GetGuid(recId));
                if (header != null)
                {
                    CultureInfo ci = new CultureInfo(App.Params.CurrentUser.CultureCode);

                    DateTime myDate = new DateTime();
                    myDate = header.StartDate;
                    // Bu salaklığı Componentin mask yapısından dolayı yaptım. 
                    var datePattern = ci.DateTimeFormat.ShortDatePattern.Replace("d", "dd").Replace("M", "MM").Replace("MMMM", "MM").Replace("dddd", "dd");

                    string us = myDate.Date.ToString(datePattern, ci);
                    dStartDate.SetValue(us);
                    dStartDate.SetIValue(us);

                    DateTime myDate2 = new DateTime();
                    myDate2 = header.EndDate;

                    string us2 = myDate2.Date.ToString(datePattern, ci);
                    dEndDate.SetValue(us2);
                    dEndDate.SetIValue(us2);
                    
                    //dStartDate.SetValue(header.StartDate);
                    //dEndDate.SetValue(header.EndDate);

                    if (header.ReconcliationStatus == 1)
                    {
                        MessageBox msg = new MessageBox() { Height = 200 };
                        msg.Show("Bilgi", "İşleminiz kuyrukta beklemektedir, sonucu işlem bittiğinde görebilirsiniz.");
                        GrdReConciliation.Clear();
                        GrdReConciliation.DataBind();
                    }
                    else if (header.ReconcliationStatus == 3)
                    {
                        MessageBox msg = new MessageBox() { Height = 200 };
                        msg.Show("Bilgi", "İşleminiz hata almış. Hata: " + header.ReconcliationStatusResult);
                        GrdReConciliation.Clear();
                        GrdReConciliation.DataBind();
                    }
                    else if (header.ReconcliationStatus == 2)
                    {
                        string sql = @"	SELECT BankTransactionNumber,
                                        New_UptReconcliationDetailId,
                                        New_UptReconcliationDetailId AS ID,
	                                    BankTransactionNumber AS VALUE,
	                                    new_UptReference AS	new_UptReference,
	                                    new_OperationType AS new_OperationType ,
	                                    new_Direction AS new_Direction ,
	                                    new_CurrencyCode AS new_CurrencyCode ,
	                                    new_Amount AS new_Amount ,
	                                    new_BankAmount AS new_BankAmount,
	                                    new_UptTransactionNumber AS new_UptTransactionNumber ,
	                                    new_UptDate AS new_UptDate ,
                                        new_UptDate AS new_UptDateUtcTime ,
	                                    new_BankDate AS new_BankDate ,
                                        new_BankDate AS new_BankDateUtcTime ,
	                                    LEFT(CONVERT(VARCHAR, new_UptDate, 120), 10) AS UptDateStr ,
	                                    LEFT(CONVERT(VARCHAR, new_BankDate, 120), 10)  AS BankDateStr ,
	                                    new_UptRow AS new_UptRow ,
	                                    new_BankRow AS new_BankRow ,
                                        ISNULL(new_DifferenceAmount,ISNULL(new_Amount,0)-ISNULL(new_BankAmount,0)) AS new_DifferenceAmount ,
	                                    new_ReconcliationStatus AS new_ReconcliationStatus,
	                                    rs.Label AS new_ReconcliationStatusName,
	                                    new_UptReconcliationHeaderId AS UptReconcliationHeaderId,
                                        CreatedByName,
                                        CreatedOn,
	                                    new_UptReconcliationHeaderIdName AS UptReconcliationHeaderIdName ,
                                        new_BankDescription
	                                 FROM vNew_UptReconcliationDetail (NOLOCK) dt
	                                 LEFT JOIN new_PLNew_UptReconcliationDetail_new_ReconcliationStatus rs ON rs.Value = dt.new_ReconcliationStatus
	                                 WHERE New_UptReconcliationHeaderId = @UptReconcliationHeaderId AND DeletionStateCode =0 ";


                        var sort = GrdReConciliation.ClientSorts();
                        if (sort == null)
                        { sort = string.Empty; }



                        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("ViewUptReconcliationDetail");
                        var spList = new List<CrmSqlParameter>();
                        spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "UptReconcliationHeaderId", Value = ValidationHelper.GetGuid(recId) });

                        if (!string.IsNullOrEmpty(cmbCurrency.Value))
                        {
                            spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "CurrencyCode", Value = cmbCurrency.Value });

                            sql += " AND new_CurrencyCode = @CurrencyCode";

                        }
                        if (!string.IsNullOrEmpty(cmbDirection.Value))
                        {
                            spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "Direction", Value = cmbDirection.Value });

                            sql += " AND new_Direction = @Direction";

                        }
                        if (!string.IsNullOrEmpty(txtBankTransactionNumber.Value))
                        {
                            spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "BankTransactionNumber", Value = txtBankTransactionNumber.Value });

                            sql += " AND BankTransactionNumber = @BankTransactionNumber";

                        }

                        if (!string.IsNullOrEmpty(new_ReconcliationStatus.Value))
                        {
                            spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "ReconcliationStatus", Value = new_ReconcliationStatus.Value });

                            sql += " AND new_ReconcliationStatus = @ReconcliationStatus";

                        }
                        if (!string.IsNullOrEmpty(txtUptReference.Value))
                        {
                            spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "UptReference", Value = txtUptReference.Value });

                            sql += " AND new_UptReference = @UptReference";
                        }

                        var gpc = new GridPanelCreater();
                        var cnt = 0;
                        var start = GrdReConciliation.Start();
                        var limit = GrdReConciliation.Limit();
                        var t = gpc.GetFilterData(sql, viewqueryid, sort, spList, start, limit, out cnt, out dt);
                        GrdReConciliation.TotalCount = cnt;

                        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
                        {
                            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
                            gpw.Export(dt);
                        }

                        GrdReConciliation.DataSource = t;
                        GrdReConciliation.DataBind();

                    }
                }

            }

        }


        protected void ToolbarButtonFind2Click(object sender, AjaxEventArgs e)
        {
            DataSet totalds = GetUptReconcliationTotal(ValidationHelper.GetGuid(hdnRecId.Value));

            if (totalds.Tables[0].Rows.Count > 0)
            {
                var n = string.Format("Upt Mutabakat Sorunlu işlemler-{0:yyyy-MM-dd_hh-mm-ss-tt}.xls", DateTime.Now);
                Export.ExportDownloadData(totalds.Tables[0], n);
            }

        }


    }
}

