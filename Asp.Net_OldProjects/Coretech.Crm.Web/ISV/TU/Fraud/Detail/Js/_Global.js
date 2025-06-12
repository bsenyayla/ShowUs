function RefreshParetnGrid() {
    window.top.SpecialCloseRefreshParentGrid();
}
function ShowWindowRec(GridId, Id) {
    var url = window.top.GetWebAppRoot + "/CrmPages/AutoPages/EditReflex.aspx?recid=" + Id;
    url += "&gridpanelid=" + GridId
    url += "&ObjectId=201100105&mode=-1" 


    if (window != null) {
        url += "&tabframename=" + window.name;
        url += "&rlistframename=" + window.name
    }
    if (window.parent != null) {
        url += "&pawinid=" + window.parent.name;
        url += "&pframename=" + window.parent.name;
    }

    window.top.newWindowRefleX(url, { maximized: false, width: 900, height: 600, resizable: true, modal: true, maximizable: true });
}

function ShowWindow(GridId, Id) {
    var url = window.top.GetWebAppRoot + "/ISV/TU/Fraud/Detail/_Confirm.aspx?recid=" + Id;
    url += "&gridpanelid=" + GridId
    
    if (window != null) {
        url += "&tabframename=" + window.name;
        url += "&rlistframename=" + window.name
    }
    if (window.parent != null) {
        url += "&pawinid=" + window.parent.name;
        url += "&pframename=" + window.parent.name;
    }
    
    window.top.newWindowRefleX(url, { maximized: false, width: 900, height: 600, resizable: true, modal: true, maximizable: true });
}
function ShowWindowReadOnly(GridId, Id) {
    var url = window.top.GetWebAppRoot + "/ISV/TU/Fraud/Detail/_ReadOnly.aspx?recid=" + Id;
    url += "&gridpanelid=" + GridId

    if (window != null) {
        url += "&tabframename=" + window.name;
        url += "&rlistframename=" + window.name
    }
    if (window.parent != null) {
        url += "&pawinid=" + window.parent.name;
        url += "&pframename=" + window.parent.name;
    }

    window.top.newWindowRefleX(url, { maximized: false, width: 900, height: 600, resizable: true, modal: true, maximizable: true });
}
function ShowMonitoringDetailLite() {
    var config = "../ISV/TU/Fraud/Detail/_MonitoringDetailLite.aspx?EntityId=" + hdnEntityId.getValue() + "&recid=" + hdnRecId.getValue();
    window.top.newWindow(config, { title: ToolbarButtonMd.text, width: 800, height: 500, resizable: true });
}