function ShowWindow(GridId, Id) {
    var url = window.top.GetWebAppRoot + "/ISV/TU/Fraud/Detail/_ConfirmAccount.aspx?recid=" + Id;
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
    var url = window.top.GetWebAppRoot + "/ISV/TU/Fraud/Detail/_ConfirmAccount.aspx?recid=" + Id;
    url += "&gridpanelid=" + GridId

    if (window != null) {
        url += "&tabframename=" + window.name;
        url += "&rlistframename=" + window.name
    }
    if (window.parent != null) {
        url += "&pawinid=" + window.parent.name;
        url += "&pframename=" + window.parent.name;
    }

    url += "&readonly=1";

    window.top.newWindowRefleX(url, { maximized: false, width: 900, height: 600, resizable: true, modal: true, maximizable: true });
}

function ShowMonitoringDetailLite() {
    var config = "../ISV/TU/Fraud/Detail/_AccountMonitoringDetailLite.aspx?recid=" + hdnRecId.getValue();
    window.top.newWindow(config, { title: ToolbarButtonMd.text, width: 800, height: 500, resizable: true });
}