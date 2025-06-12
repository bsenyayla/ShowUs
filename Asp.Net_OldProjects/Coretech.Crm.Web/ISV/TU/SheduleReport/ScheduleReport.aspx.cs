using System;
using TuFactory.SheduleReport;

public partial class SheduleReport_ScheduleReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void Button1_Click(object sender, EventArgs e)
    {
        string args = "StartDate=2016-05-01;EndDate=2016-05-06";
        ScheduleReportManager scheduleReportManager = new ScheduleReportManager(TuFactory.ScheduleReport.Model.ScheduleObject.ReportTypeEnum.CashReconciliation,
            TuFactory.ScheduleReport.Model.ScheduleObject.ExportTypeEnum.Excel);
        scheduleReportManager.Args = args;
        scheduleReportManager.ExecuteReport();
    }
}