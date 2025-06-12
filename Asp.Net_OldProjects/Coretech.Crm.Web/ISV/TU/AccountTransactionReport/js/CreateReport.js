function ShowAccountTransactionReport(doExport) {
    var strFilter = "StartDate;EndDate;Source";

    var strValues = [
     StartDate.value,
     EndDate.value,
     Source.value
    ];


    var Qstring = GetWebAppRoot + "/CrmPages/AutoPages/Reports/ShowReport.aspx?ReportId=" + hdnReportId.value
+ "&RecordId=" + hdnRecid.value + "&doExport=" + doExport + "&OpenInWindow=1"
+ "&Parameters=" + strFilter
    for (var i = 0; i < strValues.length; i++) {
        Qstring += "&p" + i + "=" + strValues[i];
    }

    window.top.newWindow(Qstring, { maximized: false, width: 900, height: 600, resizable: true, modal: true, maximizable: false });
}