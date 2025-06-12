using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.PluginData;
using Coretech.Crm.Reporting;
using Coretech.Crm.Utility.Util;
using System;
using System.Collections.Generic;
using System.Web.UI;
using TuFactory.AccountTransactionReport.Repository;
using ReportParameter = Microsoft.Reporting.WebForms.ReportParameter;
using Warning = Microsoft.Reporting.WebForms.Warning;
using UPTCache = UPT.Shared.CacheProvider.Service;
using UPTCacheObjects = UPT.Shared.CacheProvider.Model;


namespace Coretech.Crm.Web.ISV.TU.KVKK
{
    public partial class ApplicationForm : System.Web.UI.Page
    {
        private string reportId = string.Empty;
        private string senderName = string.Empty;
        private string nationalityId = string.Empty;
        string reportCulture = "en-GB";

        protected void Page_Load(object sender, EventArgs e)
        {
            //Comment yazdım.
            reportCulture = App.Params.CurrentUser.CultureCode;
            Page.Culture = ValidationHelper.GetString(ParameterFactory.GetParameterValue("REPORT_CULTURE"), reportCulture);
            Page.UICulture = ValidationHelper.GetString(ParameterFactory.GetParameterValue("REPORT_CULTURE"), reportCulture);
            if (!IsPostBack)
            {
                var bc = Request.Browser;
                var name = bc.Browser;
                if (name != "IE")
                {
                    bd.Style.Clear();
                    bd.Style.Add("overflow", "auto");
                }

                ReportViewer1.ServerReport.ReportServerUrl = new Uri(ReportServer.ReportServerViewUrl);
                
                senderName = QueryHelper.GetString("SenderName");
                nationalityId = QueryHelper.GetString("NationalityId");

                string nationality = GetNationality(ValidationHelper.GetGuid(nationalityId));

                if (nationality == "TR")
                {
                    reportId = new ReportManagerDb().GetReportIdByReportName("KVKK_FORM_TR").ToString();
                }
                else
                {
                    reportId = new ReportManagerDb().GetReportIdByReportName("KVKK_FORM_EN").ToString();
                }                
                
                ReportViewer1.ServerReport.ReportPath = String.Format("{0}/{1}", ReportServer.ReportFolder, reportId);
                ReportViewer1.ServerReport.ReportServerCredentials = new MyReportServerCredentials();

                var li = new List<ReportParameter>
                {
                    new ReportParameter("SenderName", senderName, false),
                };

                ReportViewer1.ServerReport.SetParameters(li.ToArray());
                ReportViewer1.ServerReport.Timeout = 1000 * 60 * 10;
                ReportViewer1.ServerReport.Refresh();
                ReportViewer1.AsyncRendering = false;

                Warning[] warnings;
                string[] streamids;
                string mimeType;
                string encoding;
                string extension;
                string etype = "PDF";

                var bytes = ReportViewer1.ServerReport.Render(
                  etype, null, out mimeType, out encoding, out extension,
                  out streamids, out warnings);
                Response.Buffer = true;
                Response.Clear();
                Response.ContentType = mimeType;
                Response.AddHeader("content-disposition", "filename=" + Guid.NewGuid() + "." + extension);


                Response.BinaryWrite(bytes);
                Response.Flush();
                Response.End();
            }
        }

        private string GetNationality(Guid nationalityId)
        {
            return UPTCache.NationalityService.GetNationalityByNationalityId(nationalityId).ExtCode;
        }
    }
}