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
using System.Web;
using System.Web.UI.WebControls;
using TuFactory.Data;
using UptBankReconciliation;


namespace Reconciliation.Detail
{
    public partial class Reconciliation_Detail_UptTransactionReport : BasePage
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

                btnXmlExport.Visible = false;
                if (!string.IsNullOrEmpty(recId))
                {
                    hdnRecId.SetValue(recId);
                    btnSave.Visible = false;
                    btnGetReConciliation.Visible = true;
                    cmbCurrency.Visible = true;

                    dEndDate.ReadOnly = true;
                    dStartDate.ReadOnly = true;
                    cmbTrasactionTypeCode.ReadOnly = true;
                }
                else
                {
                    btnSave.Visible = true;
                    btnGetReConciliation.Visible = false;
                    cmbCurrency.Visible = false;
                    dEndDate.ReadOnly = false;
                    dStartDate.ReadOnly = false;
                    cmbTrasactionTypeCode.ReadOnly = false;
                    btnXmlExport.Visible = false;

                    dStartDate.Value = DateTime.Today;
                    dEndDate.Value = DateTime.Today;
                }

                LoadTransactionReportHeader(recId);
            }
        }

        protected void LoadTransactionReportHeader(string recId)
        {

            UptTransactionReportHeader header = null;
            if (!string.IsNullOrEmpty(recId))
            {
                             
                UptTransactionReport reconcliationFactory = new UptTransactionReport();
                header = reconcliationFactory.GetUptTransactionReportHeader(ValidationHelper.GetGuid(recId));
                if (header != null)
                {

                    cmbTrasactionTypeCode.SetValue(header.TransactionType);
                    cmbTrasactionTypeCode.Value = header.TransactionType.ToString();

                    CultureInfo ci = new CultureInfo(App.Params.CurrentUser.CultureCode);

                    DateTime myDate;
                    myDate = header.StartDate;
                    // Bu salaklığı Componentin mask yapısından dolayı yaptım. 
                    var datePattern = ci.DateTimeFormat.ShortDatePattern.Replace("d", "dd").Replace("M", "MM").Replace("MMMM", "MM").Replace("dddd", "dd");

                    string us = myDate.Date.ToString(datePattern, ci);
                    dStartDate.SetValue(us);
                    dStartDate.SetIValue(us);

                    DateTime myDate2;
                    myDate2 = header.EndDate;

                    string us2 = myDate2.Date.ToString(datePattern, ci);
                    dEndDate.SetValue(us2);
                    dEndDate.SetIValue(us2);
                }
            }
        }

        protected void SaveReConciliation(object sender, AjaxEventArgs e)
        {
            MessageBox msgBox = new MessageBox() { Height = 200 };

            var startDate = ValidationHelper.GetDate(dStartDate.Value);
            var endDate = ValidationHelper.GetDate(dEndDate.Value);
            var transactionTypeCode = ValidationHelper.GetString(cmbTrasactionTypeCode.Value);
            try
            {
                QScript("LogCurrentPage();");

                UptTransactionReport transactionReportFactory = new UptTransactionReport();
                Guid recId = transactionReportFactory.SaveUptReconcliationHeader(App.Params.CurrentUser.SystemUserId, startDate, endDate, transactionTypeCode);

                if (recId != Guid.Empty)
                {
                    QScript("alert('İşleminiz kuyruğa alınmıştır, sonuçlandığında mail bilgilendirilmesi yapılacaktır.');");

                    QScript("RefreshParetnGridForCashTransaction(true);");

                }
                else
                {
                    msgBox.Show("Hata", "Bilinmeyen Hata!");
                }
            }
            catch (Exception ex)
            {
                msgBox.Show("Hata", "", "İşlem sırasında bir hata ile karşılaşıldı. <br/> Hata: " + ex.Message);
            }

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
            gpc.CreateViewGrid("ViewUptTransactionReportDetail", GrdReConciliation);

            string strSelected = ViewFactory.GetViewIdbyUniqueName("ViewUptTransactionReportDetail").ToString();

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
                             where c.AttributeName == item.Header && c.Hide
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
            //var gpc = new GridPanelCreater();
            //gpc.CreateViewGrid("ViewUptRecProbTran", GrdProblemReconciliations);

            string strSelected = ViewFactory.GetViewIdbyUniqueName("ViewUptRecProbTran").ToString();

            QueryId = ValidationHelper.GetGuid(strSelected);

            hdnViewList.Value = strSelected;

            if (string.IsNullOrEmpty(strSelected))
                return;
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));

            //var getColumnList = new UserPoolMapDb().GetColumnList(Convert.ToInt32(hdnPoolId.Value), QueryId, new UserPoolMapDb().GetAttributeListString(new UserPoolMapDb().getColumnSet(gpw.View.ColumnSetXml)));


            var defaultEditPage = gpw.View.DefaultEditPage.ToString();
            hdnViewDefaultEditPage2.Value = defaultEditPage;


        }


        protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
        {
            MessageBox msgBox = new MessageBox() { Height = 200 };

            var recId = hdnRecId.Value;
            

            if (!string.IsNullOrEmpty(recId))
            {
                

                DataTable dt;

                UptTransactionReport reconcliationFactory = new UptTransactionReport();
                var header = reconcliationFactory.GetUptTransactionReportHeader(ValidationHelper.GetGuid(recId));
                if (header != null)
                {
                    CultureInfo ci = new CultureInfo(App.Params.CurrentUser.CultureCode);

                    DateTime myDate;
                    myDate = header.StartDate;
                    // Bu salaklığı Componentin mask yapısından dolayı yaptım. 
                    var datePattern = ci.DateTimeFormat.ShortDatePattern.Replace("d", "dd").Replace("M", "MM").Replace("MMMM", "MM").Replace("dddd", "dd");

                    string us = myDate.Date.ToString(datePattern, ci);
                    dStartDate.SetValue(us);
                    dStartDate.SetIValue(us);

                    DateTime myDate2;
                    myDate2 = header.EndDate;

                    string us2 = myDate2.Date.ToString(datePattern, ci);
                    dEndDate.SetValue(us2);
                    dEndDate.SetIValue(us2);
                    

                    if (header.ReportStatus == 1)
                    {

                        msgBox.Show("Bilgi", "İşleminiz kuyrukta beklemektedir, sonucu işlem bittiğinde görebilirsiniz.");
                        GrdReConciliation.Clear();
                        GrdReConciliation.DataBind();
                    }
                    else if (header.ReportStatus == 4)
                    {
                        msgBox.Show("Bilgi", "İşleminiz hata almış. Hata: " + header.ReportStatusDescription);
                        GrdReConciliation.Clear();
                        GrdReConciliation.DataBind();
                    }
                    else if (header.ReportStatus == 3)
                    {
                        string sql = @"SELECT 
                                          New_UptTransactionReportDetailId
                                          ,New_UptTransactionReportDetailId AS ID
                                          ,[UptReferenceNo] as UptReferenceNo
                                          ,[statuscode] as Statuscode
                                          ,[new_TransactionTypeCode]
                                          ,[new_UptTransactionReportHeaderId]
                                          ,[new_UptTransactionReportHeaderIdName]
                                          ,[new_SenderIdendificationNumber]
                                          ,[new_SenderCorparationVkn]
                                          ,[new_SenderCorparationTitle]
                                          ,[new_SenderCustomerStatus]
                                          ,[new_SenderName]
                                          ,[new_SenderSurname]
                                          ,[new_SenderDistrict]
                                          ,[new_SenderHomeZipCode]
                                          ,[new_SenderCityCode]
                                          ,[new_SenderCityName]
                                          ,[new_SenderGsm]
                                          ,[new_SenderEmail]
                                          ,[new_RecipientCustomerStatus]
                                          ,[new_RecipientCorparationVkn]
                                          ,[new_RecipientCorparationTitle]
                                          ,[new_RecipientName]
                                          ,[new_RecipientSurname]
                                          ,[new_RecipientIdentificationNo]
                                          ,[new_RecipientNationality]
                                          ,[new_SenderNationalityCode]
                                          ,[new_RecipientDistrictName]
                                          ,[new_RecipientHomeZipCode]
                                          ,[new_RecipientCityCode]
                                          ,[new_RecipientCityName]
                                          ,[new_RecipientGsm]
                                          ,[new_RecipientMail]
                                          ,[new_ProcessId]
                                          ,[new_ProcessDate]
                                          ,[new_PaymentDate]
                                          ,[new_TLAmount]
                                          ,[new_CurrencyAmount]
                                          ,[new_Currency]
                                          ,[new_CorpationDescription]
                                          ,[new_CustomerDescription]
                                          ,[new_ProcessType]
                                          ,[Fake]
                                    FROM vNew_UptTransactionReportDetail (NOLOCK) dt
                                    WHERE 
	                                    1=1
	                                    AND New_UptTransactionReportHeaderId = @UptTransactionReportHeaderId 
	                                    AND DeletionStateCode = 0  ";


                        var sort = GrdReConciliation.ClientSorts();
                        if (sort == null)
                        { sort = string.Empty; }



                        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("ViewUptTransactionReportDetail");
                        var spList = new List<CrmSqlParameter>();
                        spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "UptTransactionReportHeaderId", Value = ValidationHelper.GetGuid(recId) });
                        
                        if (!string.IsNullOrEmpty(cmbCurrency.Value))
                        {
                            spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "CurrencyCode", Value = cmbCurrency.Value });

                            sql += " AND new_Currency = @CurrencyCode ";

                        }
                       
                        if (!string.IsNullOrEmpty(txtUptReference.Value))
                        {
                            spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "UptReference", Value = txtUptReference.Value });

                            sql += " AND UptReferenceNo = @UptReference ";
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

        protected void ToXmlExport(object sender, AjaxEventArgs e)
        {
            try
            {



                var recId = hdnRecId.Value;

                UptTransactionReport reconcliationFactory = new UptTransactionReport();
               
                var header = reconcliationFactory.GetUptTransactionReportExportData(ValidationHelper.GetGuid(recId));

                if (string.IsNullOrEmpty(header.ToString().Trim()))
                {
                    msg.Show("Hata", "", "Xml verisi bulunamadı. <br/> Hata: ");
                    return;
                }

                string strXml = header.File.Trim();

                this.Response.Clear();
                this.Response.AddHeader("Content-Disposition", "attachment; filename=submittedData.xml");
                //this.Response.AddHeader("Content-Length", strXml.Length.ToString());
                this.Response.ContentType = "application/xml";
                this.Response.Write(strXml);

                //this.Response.End();
                this.Response.Flush();
                HttpContext.Current.ApplicationInstance.CompleteRequest();
                this.Response.End();
                //this.Response.WriteFile(Server.MapPath("~/test.xml"));


            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message.ToString());
                throw;
            }

            

        }


    }
}

