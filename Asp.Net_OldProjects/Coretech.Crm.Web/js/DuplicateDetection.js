
function ShowDDwindow(duplicateDetectionRuleId, duplicateDetectionResultId, ParentAction) {
    window.top.ddParentWindow = window;
    var itemGuid = guid();
    var Qstring = "";
    
    Qstring = GetWebAppRoot + "/CrmPages/AutoPages/DDReflex.aspx?duplicateDetectionRuleId=" + duplicateDetectionRuleId
    + "&duplicateDetectionResultId=" + duplicateDetectionResultId
    + "&ParentAction=" + ParentAction
    + "&rlistframename=" + window.name
    + "&rnd=" + itemGuid;

    if (window.parent != null)
        Qstring += "&pframename=" + window.parent.name;


    var Width = 800;
    var Height = 600;
    window.top.newWindowRefleX(Qstring, { maximized: false, width: Width, height: Height, resizable: true, modal: true, maximizable: true });
}
function btnSaveNewRecord_Click() {
    if (window.top.ddParentWindow != null) {
        w = window.top.ddParentWindow;
        w.hdnDDAction.setValue("5");
        w.hdnDDParentAction.setValue(ParentAction.getValue());
        w.btnDDSave.click(w);
        top.R.WindowMng.getActiveWindow().hide();
    }
}

function btnSaveSelectedRecord_Click() {
    if (window.top.ddParentWindow != null) {
        w = window.top.ddParentWindow;
        if(IsNull(GridPanelMonitoring.selectedRecord.ID)) {
            alert(windo.top.Messages.CRM_YOU_MUST_SELECT_RECORD);
            return;
        }
        w.hdnRecid.setValue(GridPanelMonitoring.selectedRecord.ID);
        w.hdnDDAction.setValue("6");
        w.hdnDDParentAction.setValue(ParentAction.getValue());
        w.btnDDSave.click(w);
        top.R.WindowMng.getActiveWindow().hide();
    }
}