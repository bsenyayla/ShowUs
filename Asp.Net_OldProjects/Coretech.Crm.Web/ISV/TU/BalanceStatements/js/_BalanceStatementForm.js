function ShowAccountStatementReport(doExport) {
    var strFilter = "CorporationId;AccStatementId;StartDate;EndDate"; 

    var strValues = [
     new_Corporation.getValue(),
     new_AccStatementID.getValue(),
     new_StartDate.getValue(),
     new_EndDate.getValue(),
    ];


    var Qstring = GetWebAppRoot + "/CrmPages/AutoPages/Reports/ShowReport.aspx?ReportId=" + hdnReportId.getValue()
+ "&RecordId=" + hdnRecid.getValue() + "&doExport=" + doExport + "&OpenInWindow=1"
+ "&Parameters=" + strFilter
    for (var i = 0; i < strValues.length; i++) {
        Qstring += "&p" + i + "=" + strValues[i];
    }

    window.top.newWindow(Qstring, { maximized: false, width: 900, height: 600, resizable: true, modal: true, maximizable: false });
}

function ShowDownloadPage(recId) {
    var config = GetWebAppRoot + "ISV/TU/BalanceStatements/DownloadBalanceStatement.aspx?RecordId=" + recId;
    window.top.newWindow(config, { title: 'Download Page', width: 800, height: 500, resizable: false });
}