using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class Mobile_Report : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void OperationType_Fill(object sender, AjaxEventArgs e)
    {
        try
        {
            double dateDiff = (ValidationHelper.GetDate(new_EndDate.Value) - ValidationHelper.GetDate(new_StartDate.Value)).TotalDays;
            if (dateDiff > 30)
            {
                var messageBox = new MessageBox();
                messageBox.Show("Tarih aralığı 30 günden daha fazla olamaz.");
                return;
            }

            var sd = new StaticData();
            sd.AddParameter("CorporationId", System.Data.DbType.Guid, ValidationHelper.GetGuid(new_CorporationId.Value));
            sd.AddParameter("OfficeId", System.Data.DbType.Guid, ValidationHelper.GetGuid(new_OfficeId.Value));
            sd.AddParameter("StartDate", System.Data.DbType.Date, ValidationHelper.GetDate(new_StartDate.Value));
            sd.AddParameter("EndDate", System.Data.DbType.Date, ValidationHelper.GetDate(new_EndDate.Value));
            sd.AddParameter("OperationType", System.Data.DbType.Int32, ValidationHelper.GetInteger(string.IsNullOrEmpty(OperationType.Value) ? -1 : ValidationHelper.GetInteger(OperationType.Value)));
            sd.AddParameter("IsDocument", System.Data.DbType.Int32, ValidationHelper.GetInteger(IsDocument.Value));
            DataTable dt = sd.ReturnDatasetSp("spGetMobileDocumentPivot").Tables[0];

            GrdTotalCount.DataSource = dt;
            GrdTotalCount.DataBind();

        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "MobileDocument.Report");
        }

    }

    protected void MobileDocumentReport_Fill(object sender, AjaxEventArgs e)
    {
        try
        {
            double dateDiff = (ValidationHelper.GetDate(new_EndDate.Value) - ValidationHelper.GetDate(new_StartDate.Value)).TotalDays;
            if (dateDiff > 30)
            {
                var messageBox = new MessageBox();
                messageBox.Show("Tarih aralığı 30 günden daha fazla olamaz.");
                return;
            }

            var sd = new StaticData();
            sd.AddParameter("CorporationId", System.Data.DbType.Guid, ValidationHelper.GetGuid(new_CorporationId.Value));
            sd.AddParameter("OfficeId", System.Data.DbType.Guid, ValidationHelper.GetGuid(new_OfficeId.Value));
            sd.AddParameter("StartDate", System.Data.DbType.Date, ValidationHelper.GetDate(new_StartDate.Value));
            sd.AddParameter("EndDate", System.Data.DbType.Date, ValidationHelper.GetDate(new_EndDate.Value));
            sd.AddParameter("OperationType", System.Data.DbType.Int32, ValidationHelper.GetInteger(string.IsNullOrEmpty(OperationType.Value) ? -1 : ValidationHelper.GetInteger(OperationType.Value)));
            DataTable dt = sd.ReturnDatasetSp("spGetMobileDocumentReport").Tables[0];

            GridPanel1.DataSource = dt;
            GridPanel1.DataBind();
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "MobileDocument.Report");
        }

    }

    protected void ExportExcelReport1(object sender, AjaxEventArgs e)
    {
        try
        {
            double dateDiff = (ValidationHelper.GetDate(new_EndDate.Value) - ValidationHelper.GetDate(new_StartDate.Value)).TotalDays;
            if (dateDiff > 30)
            {
                var messageBox = new MessageBox();
                messageBox.Show("Tarih aralığı 30 günden daha fazla olamaz.");
                return;
            }

            var sd = new StaticData();
            sd.AddParameter("CorporationId", System.Data.DbType.Guid, ValidationHelper.GetGuid(new_CorporationId.Value));
            sd.AddParameter("OfficeId", System.Data.DbType.Guid, ValidationHelper.GetGuid(new_OfficeId.Value));
            sd.AddParameter("StartDate", System.Data.DbType.Date, ValidationHelper.GetDate(new_StartDate.Value));
            sd.AddParameter("EndDate", System.Data.DbType.Date, ValidationHelper.GetDate(new_EndDate.Value));
            sd.AddParameter("OperationType", System.Data.DbType.Int32, ValidationHelper.GetInteger(string.IsNullOrEmpty(OperationType.Value) ? -1 : ValidationHelper.GetInteger(OperationType.Value)));
            sd.AddParameter("IsDocument", System.Data.DbType.Int32, ValidationHelper.GetInteger(IsDocument.Value));
            DataTable dt = sd.ReturnDatasetSp("spGetMobileDocumentPivot").Tables[0];

            if (dt.Rows.Count > 0)
            {
                var n = string.Format("Export-{0:yyyy-MM-dd_hh-mm-ss-tt}.xls", DateTime.Now);
                Export.ExportDownloadData(dt, n);
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "MobileDocument.Report.Excel");
        }
    }

    protected void ExportExcelReport2(object sender, AjaxEventArgs e)
    {
        try
        {
            double dateDiff = (ValidationHelper.GetDate(new_EndDate.Value) - ValidationHelper.GetDate(new_StartDate.Value)).TotalDays;
            if (dateDiff > 30)
            {
                var messageBox = new MessageBox();
                messageBox.Show("Tarih aralığı 30 günden daha fazla olamaz.");
                return;
            }

            var sd = new StaticData();
            sd.AddParameter("CorporationId", System.Data.DbType.Guid, ValidationHelper.GetGuid(new_CorporationId.Value));
            sd.AddParameter("OfficeId", System.Data.DbType.Guid, ValidationHelper.GetGuid(new_OfficeId.Value));
            sd.AddParameter("StartDate", System.Data.DbType.Date, ValidationHelper.GetDate(new_StartDate.Value));
            sd.AddParameter("EndDate", System.Data.DbType.Date, ValidationHelper.GetDate(new_EndDate.Value));
            sd.AddParameter("OperationType", System.Data.DbType.Int32, ValidationHelper.GetInteger(string.IsNullOrEmpty(OperationType.Value) ? -1 : ValidationHelper.GetInteger(OperationType.Value)));
            DataTable dt = sd.ReturnDatasetSp("spGetMobileDocumentReport").Tables[0];

            if (dt.Rows.Count > 0)
            {
                var n = string.Format("Export-{0:yyyy-MM-dd_hh-mm-ss-tt}.xls", DateTime.Now);
                Export.ExportDownloadData(dt, n);
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "MobileDocument.Report.Excel");
        }
    }
}
