using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;

using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web.UI.WebControls;
using TuFactory.Data;
using TuFactory.Reconciliation.CorpReconciliation;
using UptBankReconciliation;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_Detail_CorpCommissionReconcliation : BasePage
    {

        private Guid QueryId = Guid.Empty;
        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                CreateViewGrid();

                var recId = QueryHelper.GetString("recid");

                if (!string.IsNullOrEmpty(recId))
                {

                    PanelXShow.Visible = true;
                    PanelSave.Visible = false;

                    hdnRecId.SetValue(recId);
                    hdnRecId.Value = recId;
                 
                    LoadTotalData(sender, null);

                }
                else
                {
                    PanelXShow.Visible = false;
                    PanelSave.Visible = true;  

                    new_StartDate.Value = DateTime.Today;
                    new_EndDate.Value = DateTime.Today;
                }


            }
        }

        protected void SaveReConciliation(object sender, AjaxEventArgs e)
        {
            var startDate = ValidationHelper.GetDate(new_StartDate.Value);
            var endDate = ValidationHelper.GetDate(new_EndDate.Value);

            try
            {
                QScript("LogCurrentPage();");


                FileInfo fi = new FileInfo(SaveFileServer(upload1.FileName));

                CorpCommissionReconciliationFactory reconcliationFactory = new CorpCommissionReconciliationFactory();
                Guid recId = reconcliationFactory.SaveCorpReconciliation(startDate, endDate, ValidationHelper.GetGuid(new_IntegrationChannelId.Value), fi.Name, fi.FullName);


                DataSet ds = reconcliationFactory.ImportExcelXLS(fi.FullName, true);

                ICorpReconciliationManager manager = CorpCommissionReconciliationFactory.GetCorpReconciliationManager(recId);

                manager.InsertCorpReconciliation(recId, ds);


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



        private string SaveFileServer(string file)
        {
            FileInfo fi = new FileInfo(file);
            string fileFullName = DateTime.Now.ToString("yyyyMMddhhmmss") + "_CorpCommissionData_" + file;
            using (var impersonator = new Impersonator())
            {
                impersonator.Impersonate(ExcelImportFactory.ImporterUser, ExcelImportFactory.ImporterDomain, ExcelImportFactory.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);
                upload1.PostedFile.SaveAs(Path.Combine(ExcelImportFactory.ImportPath, fi.Name));
            }

            return Path.Combine(ExcelImportFactory.ImportPath, fi.Name);
        }



        public void CreateViewGrid()
        {
            var gpc = new GridPanelCreater();
            gpc.CreateViewGrid("CorpReconciliationView", GrdCorpReconciliation);

            string strSelected = ViewFactory.GetViewIdbyUniqueName("CorpReconciliationView").ToString();

            QueryId = ValidationHelper.GetGuid(strSelected);

            hdnViewList.Value = strSelected;

            if (string.IsNullOrEmpty(strSelected))
                return;
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));

            var getColumnList = new UserPoolMapDb().GetColumnList(Convert.ToInt32(hdnPoolId.Value), QueryId, new UserPoolMapDb().GetAttributeListString(new UserPoolMapDb().getColumnSet(gpw.View.ColumnSetXml)));
            List<GridColumns> lstAddetColumn = GrdCorpReconciliation.ColumnModel.Columns.ToList();
            GrdCorpReconciliation.ClearColumns();

            foreach (GridColumns item in lstAddetColumn)
            {
                var count = (from c in getColumnList
                             where c.AttributeName == item.Header && c.Hide == true
                             select c).Count();
                if (count == 0)
                    GrdCorpReconciliation.AddColumn(item);
            }
            GrdCorpReconciliation.ReConfigure();

            var defaultEditPage = gpw.View.DefaultEditPage.ToString();
            hdnViewDefaultEditPage.Value = defaultEditPage;


        }


        private void LoadTotalData(object sender, AjaxEventArgs e)
        {
            var recId = hdnRecId.Value;
            DataTable retDt = new DataTable();
            if (!string.IsNullOrEmpty(recId))
            {
                //retDt = loadData(ValidationHelper.GetGuid(recId));

                DataTable dt = new DataTable();

                CorpCommissionReconciliationFactory reconcliationFactory = new CorpCommissionReconciliationFactory();
                var header = reconcliationFactory.GetCorpReconcliationHeader(ValidationHelper.GetGuid(recId));
                if (header != null)
                {
                    //new_StartDate.SetValue(header.StartDate);
                    //new_EndDate.SetValue(header.EndDate);

                    if (header.ReconcliationStatus == 1 || header.ReconcliationStatus == 2)
                    {
                        MessageBox msg = new MessageBox() { Height = 200 };
                        msg.Show("Bilgi", "İşleminiz kuyrukta beklemektedir, sonucu işlem bittiğinde görebilirsiniz.");
                        GrdCorpReconciliation.Clear();
                        GrdCorpReconciliation.DataBind();
                    }

                    else if (header.ReconcliationStatus == 3)
                    {
                        string sql = @"		SELECT New_CorpReconciliationDetailId,New_CorpReconciliationDetailId AS ID,TuReferans ,TuReferans AS VALUE,new_CorpReference,
										new_Amount,
										new_AmountCurrency,
										new_AmountCurrencyName,
                                        new_AmountCurrencyName AS new_Amount_CurrencyName,
										new_Commission,
										new_CommissionCurrency,
										new_CommissionCurrencyName,
                                        new_CommissionCurrencyName AS new_Commission_CurrencyName,

										new_CorpCommission,
										new_CorpCommissionCurrency,
										new_CorpCommissionCurrencyName,
                                        new_CorpCommissionCurrencyName AS new_CorpCommission_CurrencyName,

										new_CorpStatus,
										new_ConfirmStatusId,
										new_ConfirmStatusIdName,	
                                        new_UptDate,
										new_UptDate AS new_UptDateUtcTime,
                                        new_CorpDate,
										new_CorpDate AS new_CorpDateUtcTime,
	                                    LEFT(CONVERT(VARCHAR, new_UptDate, 120), 10) AS UptDateStr ,
	                                    LEFT(CONVERT(VARCHAR, new_CorpDate, 120), 10)  AS CorpDateStr ,	                            
	                                    new_ReconciliationResult AS new_ReconcliationStatus,
	                                    rs.Label AS new_ReconciliationResultName,
                                        CreatedByName,
                                        CreatedOn,
	                                    new_CorpReconciliationHeaderId AS CorpReconciliationHeaderId ,
										new_CorpReconciliationHeaderIdName AS CorpReconciliationHeaderIdName
	                                 FROM vNew_CorpReconciliationDetail(NOLOCK) dt
	                                 LEFT JOIN new_PLNew_CorpReconciliationDetail_new_ReconciliationResult rs ON rs.Value = dt.new_ReconciliationResult
	                                 WHERE new_CorpReconciliationHeaderId = @CorpReconcliationHeaderId AND DeletionStateCode =0 ";


                        var sort = GrdCorpReconciliation.ClientSorts();
                        if (sort == null)
                        { sort = string.Empty; }



                        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CorpReconciliationView");
                        var spList = new List<CrmSqlParameter>();
                        spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "CorpReconcliationHeaderId", Value = ValidationHelper.GetGuid(recId) });

                        if (!string.IsNullOrEmpty(new_ReconciliationResult.Value))
                        {
                            sql += "AND new_ReconciliationResult=@ReconciliationResult ";
                            spList.Add(new CrmSqlParameter() { Dbtype = DbType.Int32, Paramname = "ReconciliationResult", Value = ValidationHelper.GetInteger(new_ReconciliationResult.Value) });

                        }
                        if (!string.IsNullOrEmpty(new_CorpReference.Value))
                        {
                            sql += "AND new_CorpReference=@CorpReference ";
                            spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "CorpReference", Value = ValidationHelper.GetString(new_CorpReference.Value) });

                        }
                        if (!string.IsNullOrEmpty(TuReferans.Value))
                        {
                            sql += "AND TuReferans=@TuReferans ";
                            spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "TuReferans", Value = ValidationHelper.GetString(TuReferans.Value) });

                        }


                        var gpc = new GridPanelCreater();
                        var cnt = 0;
                        var start = GrdCorpReconciliation.Start();
                        var limit = GrdCorpReconciliation.Limit();
                        var t = gpc.GetFilterData(sql, viewqueryid, sort, spList, start, limit, out cnt, out dt);
                        GrdCorpReconciliation.TotalCount = cnt;

                        if (e != null && (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1))
                        {
                            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
                            gpw.Export(dt);
                        }

                        GrdCorpReconciliation.DataSource = t;
                        GrdCorpReconciliation.DataBind();

                    }
                }

            }
        }


        protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
        {

            LoadTotalData(sender, e);
        }

        protected void ShowReConciliation(object sender, AjaxEventArgs e)
        {
            LoadTotalData(sender, e);
        }
        protected void new_IntegrationChannelLoad(object sender, AjaxEventArgs e)
        {
            string strSql = @"Select New_IntegrationChannelId AS ID,New_IntegrationChannelId,ChannelName AS VALUE,ChannelName,new_ExtCode AS ExtCode, '001' AS IntegrationChannelType 
From vNew_IntegrationChannel (NOLOCK) WHERE DeletionStateCode=0";
            const string sort = "";
            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("IntegrationChannelComboView");
            var gpc = new GridPanelCreater();
            int cnt;
            var start = new_IntegrationChannelId.Start();
            var limit = new_IntegrationChannelId.Limit();
            var spList = new List<CrmSqlParameter>();




            var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
            new_IntegrationChannelId.TotalCount = cnt;
            new_IntegrationChannelId.DataSource = t;
            new_IntegrationChannelId.DataBind();

        }



    }
}

