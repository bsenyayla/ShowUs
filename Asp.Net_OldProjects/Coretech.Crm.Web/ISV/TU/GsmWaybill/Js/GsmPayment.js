function ShowHideRadio(id) {

    ReceivedOptionEur_1.setReadOnly(true);
    ReceivedOptionEur_2.setReadOnly(true);
    ReceivedOptionUsd_1.setReadOnly(true);
    ReceivedOptionUsd_2.setReadOnly(true);
    ReceivedOptionTry.setReadOnly(true);

    SelectedCollectionOption.setValue(id);

    if (id == 'RadioEur') {
        ReceivedOptionEur_1.setReadOnly(false);
        ReceivedOptionEur_1.change();

    }
    else if (id == 'RadioUsd') {
        ReceivedOptionUsd_1.setReadOnly(false);
        ReceivedOptionUsd_1.change();

    }
    else if (id == 'RadioTry') {
        ReceivedOptionTry.change();
    }
}

function CheckValidationBeforeLoad(msg, e) {

    if (document.getElementById('RadioEur').checked == false && document.getElementById('RadioUsd').checked == false && document.getElementById('RadioTry').checked == false) {
        alert('Tahsilat seçeneklerinden birini seçmeniz gerekiyor.');
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }
}




function RefreshParetnGridForGsmPayment(IsCloseCurrentFrame) {

    if (_gridpanelid != "") {
        var w = null;
        w = window.top.frames[_rlistframename];
        if (IsNull(window.top.frames[_rlistframename])) {
            if (!IsNull(window.parent)) {
                if (window.parent.name == _rlistframename) {
                    w = window.parent;

                }
                else if (!IsNull(window.parent.parent)) {
                    if (window.parent.parent.name == _rlistframename) {
                        w = window.parent.parent;
                    }
                }
            }
        }
        if (!IsNull(w)) {
            if (!R.isEmpty(_gridpanelid)) {
                runScript(w, "" + _gridpanelid + ".getData();");
            }
        }
    }
    if (IsCloseCurrentFrame) {
        if (top.R.WindowMng.getActiveWindow() != 0) {
            R.clearDirty();
            gsmCurrentPage.hide();

        }
    }

}

var gsmCurrentPage = null;

function LogGsmCurrentPage() {
    gsmCurrentPage = top.R.WindowMng.getActiveWindow();
}








var gsmPaymentCurrentPage = null;
function SetGsmCurrentPage() {
    gsmPaymentCurrentPage = top.R.WindowMng.getActiveWindow();
}



function GsmDekontBas() {
    if (hdnReportId.getValue() != "") {
        ShowGsmReport(hdnReportId.getValue(), hdnRecid.getValue(), "&doExport=1&OpenInWindow=1");
    }
}

function ShowGsmReport(reportid, recordid, extension, maximized) {
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



function checkStatus() {
    var ret = confirm('İptal işlemi onaya gönderilecektir, Onaylıyor musunuz?');
    return ret;
}

function checkConfirmStatus() {
    var ret = confirm('İptal işlemini onaylıyorsunuz, Emin misiniz?');
    return ret;
}





function ToolbarButtonClear_Clear() {
    win.new_SenderID.clear();
    win.new_SenderID.setValue(null);
    win.new_SenderID.change();
    window.location = window.location;
}






function ShowGsmPaymentHistory() {
    var config = "../ISV/TU/GsmWaybill/_GsmPaymentHistoryMonitoring.aspx?recid=" + New_GsmPaymentId.getValue();
    window.top.newWindow(config, { title: ToolbarButtonMd.text, width: 800, height: 500, resizable: true });
}

