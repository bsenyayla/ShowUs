
var GlobalAssigndGrid = null;
var GlobalAssigndCount = 0;
var GlobalAssigndErrorCount = 0;

function GlobalAssign(Gbp, ObjectId) {
    if (Gbp.getRowsValues().length == 0)
        return;
    window.top.WindowAssignList.show();
    window.top.WindowAssignListProgress.reset();
    window.top.WindowAssignListGrid.emptyData();
    window.top.GlobalAssigndGrid = Gbp;
    window.top.GlobalAssigndErrorCount = 0;
    window.top.GlobalAssigndCount = 0;
    window.top.BtnAssignOk.setDisabled(false);
    window.top.WindowAssignListGrid.emptyData();
    window.top.WindowAssignListGrid.clearData();
    if (Gbp != null) {
        for (var i = 0; i < Gbp.getRowsValues().length; i++) {
            var item = { "ID": Gbp.getRowsValues()[i].ID, "NAME": Gbp.getRowsValues()[i].VALUE, "OBJECTID": ObjectId };
            window.top.WindowAssignListGrid.insertRec(item);
            item = null
        }
    }
    window.top.WindowAssignListGrid.getData();
}

function AssignTemplate(record, row, col, td) {
    return '<img id="AssignImg' + row + '" class="imgEdit" onclick="AssignErrorMessages(this.alt)"  style="cursor:pointer;" src="' + GetWebAppRoot + '/images/wait.png" />';
}

function AssignErrorMessages(message) {
    R.MessageBox(R.ScriptErrorTitleText, R.ScriptErrorMsgText, message, true, R.MessageType.Warning, R.ButtonType.OK, function () { }, false, 400, 150);
}

function GlobalAssignAllList(btn) {
    window.top.BtnAssignOk.setDisabled(true);
    var recs = window.top.WindowAssignListGrid.data.Records;
    for (var i = 0; i < recs.length; i++) {
        R.AjaxMethods.GlobalAssign(i, recs[i].ID, recs[i].OBJECTID, window.top.UserCmp.getValue(), RefreshAssignList);
    }
}
var RefreshAssignList = function (result) {
    var r = JSON.decode(result);
    var stores = window.top.WindowAssignListGrid.data.Records;
    window.top.WindowAssignListProgress.progressCount = stores.length;
    window.top.GlobalAssigndCount++;
    if (r.Result == "1") {
        window.top.document.getElementById("AssignImg" + r.Order).src = GetWebAppRoot + "/images/success.png";
    } else if (r.Result == "0") {
        window.top.document.getElementById("AssignImg" + r.Order).src = GetWebAppRoot + "/images/error.png";
        window.top.document.getElementById("AssignImg" + r.Order).alt = r.ErrorMessage;
        window.top.GlobalAssigndErrorCount++
    }

    window.top.WindowAssignListProgress.updateProgress(window.top.GlobalAssigndCount, stores.length + "/" + window.top.GlobalAssigndCount);

    if (stores.length == window.top.GlobalAssigndCount) {
        window.top.WindowAssignListProgress.reset(false);
        if (window.top.GlobalAssigndGrid != null && window.top.GlobalAssigndErrorCount == 0) {
            window.top.WindowAssignList.hide();
        }
        //fds;
        if (FrameWorkType == 'RefleX') {
            try {
                window.top.GlobalAssigndGrid.getData();
            } catch (e) {
                if (window.top.GlobalAssigndGrid.store) {
                    window.top.GlobalAssigndGrid.store.reload();
                }
            }
        } else {
            window.top.GlobalAssigndGrid.store.reload();
        }

    }
}
