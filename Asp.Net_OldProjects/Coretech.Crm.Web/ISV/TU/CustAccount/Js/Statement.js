function ShowAccountStatementReport(doExport) {
    var strFilter = "AccountId;StartDate;EndDate";

    var strValues = [
     new_CustAccountId.getValue(),
     cmbStatementDateStart.getValue(),
     cmbStatementDateEnd.getValue(),
    ];


    var Qstring = GetWebAppRoot + "/CrmPages/AutoPages/Reports/ShowReport.aspx?ReportId=" + hdnReportId.getValue()
+ "&RecordId=" + "&doExport=" + doExport + "&OpenInWindow=1"
+ "&Parameters=" + strFilter
    for (var i = 0; i < strValues.length; i++) {
        Qstring += "&p" + i + "=" + strValues[i];
    }

    window.top.newWindow(Qstring, { maximized: false, width: 900, height: 700, resizable: true, modal: true, maximizable: false });
}