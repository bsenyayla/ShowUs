function CheckDoReceipt() {
    if (hdndoReceipt.getValue() == "1" || hdndoReceiptEdit.getValue() == "1") {
        var f = top.window.frames["Frame_PnlCenter"];        
        f.document.location = f.document.location;
        setTimeout(function () {
            alert(hdnOnayMessage.getValue()); ToolbarButtonReceipt.click(ToolbarButtonReceipt);
        }, 2000);
    }
}

function ShowClientSideWindow() {
    if (hdnReportId.getValue() != "") {
        ShowReport2(hdnReportId.getValue(), hdnRecid.getValue(), "&doExport=1&OpenInWindow=1");
    }
}

function Transfer3rdDetail() {
    var config = "../ISV/TU/Transfer/Transfer3rdDetail.aspx?EntityId=" + hdnEntityId.getValue() + "&RecordId=" + hdnRecid.getValue();
    window.top.newWindow(config, { title: 'LogViewer', width: 800, height: 500, resizable: false });
}



function LogWindow() {
    var config = "AutoPages/LogViewer.aspx?EntityId=" + hdnEntityId.getValue() + "&RecordId=" + hdnRecid.getValue();
    window.top.newWindow(config, { title: 'LogViewer', width: 800, height: 500, resizable: false });
}
function ShowMonitoringDetailLite() {
    var config = "../ISV/TU/Operation/Detail/_MonitoringDetailLite.aspx?EntityId=" + hdnEntityId.getValue() + "&recid=" + hdnRecid.getValue();
    window.top.newWindow(config, { title: ToolbarButtonMd.text, width: 800, height: 500, resizable: true });
}

function ShowReport2(reportid, recordid, extension, maximized) {
    var m = R.isEmpty(maximized) ? true : maximized;
    var Qstring = GetWebAppRoot + "/CrmPages/AutoPages/Reports/ShowReport.aspx?ReportId=" + reportid
    + "&RecordId=" + recordid
    if (extension != null)
        Qstring += extension;
    window.top.newWindowRefleX(Qstring, { maximized: m, width: 800, height: 600, resizable: true, modal: true, maximizable: true, listeners:
            {
                close: function (el, e) {
                    var w1 = window.top.R.WindowMng.getActiveWindow().getIFrame().window;

                    var w = window.top.R.WindowMng.getWindowById(window.name.replace("Frame_", ""));
                    if (w != null)
                        w.hide();

                    w1.close();
                    return true;
                }
            }
    });
}