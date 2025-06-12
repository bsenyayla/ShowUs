
var GlobalDeletedGrid = null;
var GlobalDeletedCount = 0;
var GlobalDeletedErrorCount = 0;
var GlobalDeletedForm = null;

function GlobalDelete(Myform, Gbp, ObjectId) {
    if (Gbp.getRowsValues().length == 0)
        return;
    window.top.WindowDeleteList.show();
    window.top.WindowDeleteListProgress.reset();
    window.top.WindowDeleteListGrid.emptyData();
    window.top.GlobalDeletedGrid = Gbp;
    window.top.GlobalDeletedForm = Myform;
    window.top.GlobalDeletedErrorCount = 0;
    window.top.GlobalDeletedCount = 0;
    window.top.BtnDeleteOk.setDisabled(false);

    window.top.WindowDeleteListGrid.emptyData();
    window.top.WindowDeleteListGrid.clearData();
    if (Gbp != null) {

        for (var i = 0; i < Gbp.getRowsValues().length; i++) {
            var item = { "ID": Gbp.getRowsValues()[i].ID, "NAME": Gbp.getRowsValues()[i].VALUE, "OBJECTID": ObjectId };
            window.top.WindowDeleteListGrid.insertRec(item);
            item = null
        }
    }

    if (Myform != null) {
        var item = { "ID": Myform.hdnRecid.getValue(), "NAME": Myform.hdnRecidName.getValue(), "OBJECTID": ObjectId };
        window.top.WindowDeleteListGrid.insertRec(item);
        item = null
    }
    window.top.WindowDeleteListGrid.getData();
}

function DeleteTemplate(record, row, col, td) {
    return '<img id="DeleteImg' + row + '" class="imgEdit" onclick="DeleteErrorMessages(this.alt)"  style="cursor:pointer;" src="' + GetWebAppRoot + '/images/wait.png" />';
}

function DeleteErrorMessages(message) {
    if (!R.isEmpty(message))
        R.MessageBox(R.ScriptErrorTitleText, R.ScriptErrorMsgText, message, true, R.MessageType.Warning, R.ButtonType.OK, function () { }, false, 400, 150);
}

function GlobalDeleteAllList(btn) {
    window.top.BtnDeleteOk.setDisabled(true);
    var recs = window.top.WindowDeleteListGrid.data.Records;
    for (var i = 0; i < recs.length; i++) {
        R.AjaxMethods.GlobalDelete(i, recs[i].ID, recs[i].OBJECTID, RefreshDeleteList);
    }
}
var RefreshDeleteList = function (result) {
    var r = JSON.decode(result);
    if (r == null) r = JSON2.parse(result);
    var stores = window.top.WindowDeleteListGrid.data.Records;
    window.top.WindowDeleteListProgress.progressCount = stores.length;
    window.top.GlobalDeletedCount++;
    if (r.Result == "1") {
        window.top.document.getElementById("DeleteImg" + r.Order).src = GetWebAppRoot + "/images/success.png";
    } else if (r.Result == "0") {
        window.top.document.getElementById("DeleteImg" + r.Order).src = GetWebAppRoot + "/images/error.png";
        window.top.document.getElementById("DeleteImg" + r.Order).alt = r.ErrorMessage;
        var errText = window.top.document.getElementById("divbodytd3r" + r.Order + "WindowDeleteListGrid");
        if (errText) {
            window.top.document.getElementById("trtblrow" + r.Order + "WindowDeleteListGrid").style.backgroundColor = "#CCCCCC";
            errText.innerHTML = "<span style='color:#8B0000' alt='" + r.ErrorMessage + "'  >" + r.ErrorMessage + "</span>";
            //errText.innerText = r.ErrorMessage;
        }


        window.top.GlobalDeletedErrorCount++
    }
    window.top.WindowDeleteListProgress.updateProgress(window.top.GlobalDeletedCount, stores.length + "/" + window.top.GlobalDeletedCount);

    if (stores.length == window.top.GlobalDeletedCount) {
        window.top.WindowDeleteListProgress.reset(false);
        if (window.top.GlobalDeletedGrid != null && window.top.GlobalDeletedErrorCount == 0) {
            window.top.WindowDeleteList.hide();
        }
        if (window.top.GlobalDeletedGrid != null) {
            window.top.GlobalDeletedGrid.clear();
            if (FrameWorkType == 'RefleX') {
                try {
                    window.top.GlobalDeletedGrid.getData();
                } catch (e) {
                    if (window.top.GlobalDeletedGrid.store) {
                        window.top.GlobalDeletedGrid.store.reload();
                    }
                }
            } else {
                window.top.GlobalDeletedGrid.store.reload();
            }
        }
        else if (window.top.GlobalDeletedForm != null) {
            if (FrameWorkType == 'RefleX') {
                if (window.top.GlobalDeletedErrorCount == 0) {
                    window.top.WindowDeleteList.hide();
                    window.top.GlobalDeletedForm.RefreshParetnGrid(true);

                }

            } else {
                if (window.top.GlobalDeletedErrorCount == 0) {
                    window.top.WindowDeleteList.hide();
                    window.top.GlobalDeletedForm.RefreshParetnGrid();
                    top.Ext.WindowMgr.getActive().close();
                }

            }
        }
    }
}
