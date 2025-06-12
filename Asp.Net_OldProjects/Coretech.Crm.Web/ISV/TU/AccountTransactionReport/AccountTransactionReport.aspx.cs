using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Microsoft.Reporting.WebForms;
using System;
using System.Web.UI;

public partial class AccountTransactionReport_AccountTransactionReport : BasePage
{
    private string _reportId = string.Empty;
    private string _recordId = string.Empty;
    ReportViewer rw = new ReportViewer();



    protected void Page_Load(object sender, EventArgs e)
    {
        
    }


    private void QScript(string message)
    {
        Page.ClientScript.RegisterStartupScript(this.GetType(), "CallMyFunction", message, true);
    }


    protected void lbSearch_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(RadioButtonList1.SelectedValue) ||
            new_StartDate.SelectedDate == DateTime.MinValue
            || new_EndDate.SelectedDate == DateTime.MinValue)
        {
            return;
        }

        TuFactory.AccountTransactionReport.Common.ReportManager reportManager = new TuFactory.AccountTransactionReport.Common.ReportManager();
        Guid reportId = reportManager.GetReportId((TuFactory.AccountTransactionReport.Object.ReportType.Types)ValidationHelper.GetInteger(RadioButtonList1.SelectedValue));

        if (reportId == Guid.Empty)
        {
            QScript("alert('Seçilen rapor yok ya da artık görüntülenemiyor.');");
        }
        else
        {
            hdnReportId.Value = reportId.ToString();
            StartDate.Value = new_StartDate.SelectedDate.ToString();
            EndDate.Value = new_EndDate.SelectedDate.ToString();
            Source.Value = RadioButtonList2.SelectedValue;
            QScript("ShowAccountTransactionReport(2);");
        }
    }
}