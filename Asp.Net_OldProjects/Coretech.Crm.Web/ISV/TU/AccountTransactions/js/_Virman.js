function ShowClientSideWindow() {
    if (hdnReportId.getValue() != "") {
        ShowReport2(hdnReportId.getValue(), hdnRecid.getValue(), "&doExport=1&OpenInWindow=1");
    }
}

function ShowReport2(reportid, recordid, extension, maximized) {
    var m = R.isEmpty(maximized) ? true : maximized;
    var Qstring = GetWebAppRoot + "/CrmPages/AutoPages/Reports/ShowReport.aspx?ReportId=" + reportid
    + "&RecordId=" + recordid
    if (extension != null)
        Qstring += extension;
    window.top.newWindowRefleX(Qstring, {
        maximized: m, width: 800, height: 600, resizable: true, modal: true, maximizable: true, listeners:
                {
                    close: function (el, e) {
                        return true;
                    }
                }
    });
}
