using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web.UI;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Reporting;
using Coretech.Crm.Utility.Util;
using Microsoft.Reporting.WebForms;

using ReportParameter = Microsoft.Reporting.WebForms.ReportParameter;
using Warning = Microsoft.Reporting.WebForms.Warning;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.PluginData;
using System.Data;

public partial class CrmPages_AutoPages_Reports_ShowReport : Page
{
    private DynamicSecurity _dynamicSecurity;
    private string _reportId = string.Empty;
    private string _recordId = string.Empty;
    private string _fileName = string.Empty;
    string _reportCulture="en-GB";
    protected void Page_Load(object sender, EventArgs e)
    {
        string tranferTuRef = "";
         

       //Comment yazdım.
        _reportCulture = App.Params.CurrentUser.CultureCode;
        Page.Culture = ValidationHelper.GetString(ParameterFactory.GetParameterValue("REPORT_CULTURE"), _reportCulture);
        Page.UICulture = ValidationHelper.GetString(ParameterFactory.GetParameterValue("REPORT_CULTURE"), _reportCulture);
        if (!IsPostBack)
        {

            var bc = Request.Browser;
            var name = bc.Browser;
            if (name != "IE")
            {
                bd.Style.Clear();
                bd.Style.Add("overflow", "auto");

            }
            //ReportViewer1.SizeToReportContent = false;
            //ReportViewer1.Style.Add("margin-bottom", "26px");
            ReportViewer1.ServerReport.ReportServerUrl = new Uri(ReportServer.ReportServerViewUrl);
            _reportId = QueryHelper.GetString("ReportId");
            _recordId = QueryHelper.GetString("RecordId");
            if (!string.IsNullOrEmpty(QueryHelper.GetString("FileName")))
            {
                _fileName = QueryHelper.GetString("FileName");
            }
            else
            {
                _fileName = _reportId;
            }




            _dynamicSecurity = DynamicFactory.GetSecurity(EntityEnum.Reports.GetHashCode(),
                                                         ValidationHelper.GetGuid(_reportId));

            var de = new DynamicEntity(EntityEnum.Reports.GetHashCode());
            var df = new DynamicFactory(ERunInUser.CalingUser);
            de = df.Retrieve(EntityEnum.Reports.GetHashCode(), ValidationHelper.GetGuid(_reportId),
                             DynamicFactory.RetrieveAllColumns);
            if (!_dynamicSecurity.PrvRead)
            {
                Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Reports PrvRead");
            }
            ReportViewer1.ServerReport.ReportPath = String.Format("{0}/{1}", ReportServer.ReportFolder, _fileName);
            ReportViewer1.ServerReport.ReportServerCredentials = new MyReportServerCredentials();

            /*
            var li = new List<ReportParameter>
                         {
                             new ReportParameter("SystemUserId", App.Params.CurrentUser.SystemUserId.ToString(), false),
                             new ReportParameter("Sql", GetReportSql(_reportId, _recordId), false),
                             new ReportParameter("BarcodeContentBase64", new TuFactory.BarcodeManager.BarcodeFactory().StringToBarcodeBase64(tranferTuRef).ToString(),false)
                         }; 
                         */

            var li = new List<ReportParameter>
                         {
                             new ReportParameter("SystemUserId", App.Params.CurrentUser.SystemUserId.ToString(), false),
                             new ReportParameter("Sql", GetReportSql(_reportId, _recordId), false)
                         };

            //var myparams = new ReportParameter[2];

            if (!string.IsNullOrEmpty(QueryHelper.GetString("Parameters")))
            {
                var plist = QueryHelper.GetString("Parameters");
                for (var index = 0; index < plist.Split(';').Length; index++)
                {
                    var param = plist.Split(';')[index];
                    var value = QueryHelper.GetString("p" + index);
                    if (string.IsNullOrEmpty(value))
                        value = null;
                    li.Add(new ReportParameter(param, value, false));
                }
            }

            ReportParameterInfoCollection parameters = ReportViewer1.ServerReport.GetParameters();
            try
            {
                if (parameters["BarcodeContentBase64"] != null)
                {
                    
                    if (!String.IsNullOrEmpty(_recordId))
                    {
                        TuFactory.Domain.Reports report = new TuFactory.Reports.TuReports().GetReport(ValidationHelper.GetGuid(_reportId));

                        Guid transferId = ValidationHelper.GetGuid( new Guid(_recordId));
                        var transferRow = new TuFactory.TransactionManagers.Transfer.TransferManager().GetTransfer(transferId);

                        if (transferRow != null)
                            tranferTuRef = transferRow.TransferTuRef;


                        if (report.EntityName == "New_Payment")
                        {
                            if (String.IsNullOrEmpty(tranferTuRef))
                            {
                                var payment = new TuFactory.TransactionManagers.Payment.PaymentManager().GetPayment(transferId);
                                if (payment.Transfer != null)
                                {
                                    tranferTuRef = payment.Transfer.TransferTuRef;
                                    transferId = payment.Transfer.TransferId;
                                }
                            }
                        }


                        if (report.EntityName == "New_RefundPayment")
                        {
                            Guid refundPaymentId = ValidationHelper.GetGuid(new Guid(_recordId));
                            var refundPayment = GetRefundPaymentTransferId(refundPaymentId);

                            var transferRow2 = new TuFactory.TransactionManagers.Transfer.TransferManager().GetTransfer(refundPayment);

                            if (transferRow2 != null)
                            {
                                tranferTuRef = transferRow2.TransferTuRef;
                                transferId = transferRow2.TransferId;
                            }
                        }


                        //tranferTuRef boş değilse
                        if (!String.IsNullOrEmpty(tranferTuRef))
                        {
                            string encrypBarcode = new TuFactory.BarcodeManager.BarcodeFactory().BarcodeToEncrypt(transferId, App.Params.CurrentUser.SystemUserId, (tranferTuRef));
                            //string tes2 = new TuFactory.BarcodeManager.BarcodeFactory().BarcodeToDecrypt((encrypBarcode));
                            string barcodePredixCode = GetReportBarcodeCode(new Guid(_reportId));
                            string barcode = !String.IsNullOrEmpty(barcodePredixCode) ? barcodePredixCode + encrypBarcode : encrypBarcode;

                            if (!String.IsNullOrEmpty(barcode))
                            {
                                ReportParameter li2 = new ReportParameter("BarcodeContentBase64", new TuFactory.BarcodeManager.BarcodeFactory().StringToBarcodeBase64(barcode).ToString(), false);
                                li.Add(li2);  
                            }
                        }else
                        {
                            ReportParameter li2 = new ReportParameter("BarcodeContentBase64", "", false);
                            li.Add(li2);
                        }


                    }
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "CrmPages_AutoPages_Reports_ShowReport", "Exception");
            }
           

            ReportViewer1.ServerReport.SetParameters(li.ToArray());
            ReportViewer1.ServerReport.Timeout = 1000 * 60 * 10;
            ReportViewer1.ServerReport.Refresh();
            ReportViewer1.AsyncRendering = false;




            DisableUnwantedExportFormats();
            if (de.Properties.Contains("ShowExportControls") && !de.GetBooleanValue("ShowExportControls"))
            {
                ReportViewer1.ShowExportControls = false;
            }

            if (de.Properties.Contains("new_PromptAreaCollapsed") && de.GetBooleanValue("new_PromptAreaCollapsed"))
            {
                ReportViewer1.PromptAreaCollapsed = true;
            }

            if (QueryHelper.GetString("doExport").ToUpper() == "1")
            {
                Warning[] warnings;
                string[] streamids;
                string mimeType;
                string encoding;
                string extension;
                string etype = "PDF";
                if (QueryHelper.GetString("exportType") != string.Empty)
                {
                    etype = QueryHelper.GetString("exportType");
                }
                var bytes = ReportViewer1.ServerReport.Render(
                  etype, null, out mimeType, out encoding, out extension,
                  out streamids, out warnings);
                Response.Buffer = true;
                Response.Clear();
                Response.ContentType = mimeType;
                if (QueryHelper.GetString("OpenInWindow").ToUpper() == "1")
                {
                    //AttachmentParametresiNiKaldirdim.
                    Response.AddHeader("content-disposition", "filename=" + Guid.NewGuid() + "." + extension);
                }
                else
                {
                    Response.AddHeader("content-disposition", "attachment; filename=" + Guid.NewGuid() + "." + extension);
                }

                Response.BinaryWrite(bytes);
                Response.Flush();
                Response.End();

            }
            if (QueryHelper.GetString("doExport").ToUpper() == "2")
            {
                Warning[] warnings;
                string[] streamids;
                string mimeType;
                string encoding;
                string extension;
                string etype = "EXCEL";
                string reportname = Guid.NewGuid().ToString();

                if (QueryHelper.GetString("ReportName") != string.Empty)
                {
                    reportname = QueryHelper.GetString("ReportName");
                }

                if (QueryHelper.GetString("exportType") != string.Empty)
                {
                    etype = QueryHelper.GetString("exportType");
                }
                var bytes = ReportViewer1.ServerReport.Render(
                  etype, null, out mimeType, out encoding, out extension,
                  out streamids, out warnings);
                Response.Buffer = true;
                Response.Clear();
                Response.ContentType = mimeType;
                //if (QueryHelper.GetString("OpenInWindow").ToUpper() == "1")
                //{
                //AttachmentParametresiNiKaldirdim.
                //    Response.AddHeader("content-disposition", "filename=" + Guid.NewGuid() + "." + extension);
                //}
                //else
                //{
                Response.AddHeader("content-disposition", "attachment; filename=" + reportname + "." + extension);
                //}

                Response.BinaryWrite(bytes);
                Response.Flush();
                Response.End();

            }
        }
        else
            DisableUnwantedExportFormats();
    }
    private string GetReportSql(string reportId, string recordId)
    {
        var retSql = string.Empty;
        retSql = SqlCreater.GetReportSql(ValidationHelper.GetGuid(reportId), ValidationHelper.GetGuid(recordId), App.Params.CurrentUser.SystemUserId);
        return retSql;
    }

    private void DisableUnwantedExportFormats()
    {
        if (string.IsNullOrEmpty(QueryHelper.GetString("DisableExportTypes"))) return;

        string[] ExportTypes = QueryHelper.GetString("DisableExportTypes").Split(';');
        foreach (RenderingExtension extension in from extension in ReportViewer1.ServerReport.ListRenderingExtensions() from exportType in ExportTypes where extension.Name == exportType select extension)
        {
            ReflectivelySetVisibilityFalse(extension);
        }
    }

    private void ReflectivelySetVisibilityFalse(RenderingExtension extension)
    {
        FieldInfo info = extension.GetType().GetField("m_isVisible", BindingFlags.NonPublic | BindingFlags.Instance);
        if (info != null)
        {
            info.SetValue(extension, false);
        }
    }

     private string GetReportBarcodeCode(Guid reportId)
    {
        var sd = new StaticData();
        
        sd.AddParameter("reportId", DbType.Guid, reportId);
        var gdret = ValidationHelper.GetString(sd.ExecuteScalar("select BarcodePrefixCode from ReportsBase (NoLock) where ReportsId = @reportId"));
        return gdret;
    }

    private Guid GetRefundPaymentTransferId(Guid refundPaymentId)
    {
        var sd = new StaticData();

        sd.AddParameter("RefundPaymentId", DbType.Guid, refundPaymentId);
        var gdret = ValidationHelper.GetGuid(sd.ExecuteScalar("select a.new_TransferId from vNew_RefundPayment a (NoLock) where a.New_RefundPaymentId =  @RefundPaymentId "));
        return gdret;
    }

    private Guid GetRefundTransferTransferId(Guid refundTransferId)
    {
        var sd = new StaticData();

        sd.AddParameter("RefundTransferId", DbType.Guid, refundTransferId);
        var gdret = ValidationHelper.GetGuid(sd.ExecuteScalar("select a.new_TransferId from vNew_RefundTransfer a (NoLock) where a.New_RefundTransferId =  @RefundTransferId "));
        return gdret;
    }
}