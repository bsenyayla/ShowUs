function ShowConfirmWindow(GridId, Id, ObjectId) {
    var url = window.top.GetWebAppRoot + "/ISV/TU/Operation/Detail/_TransactionRouter.aspx?recid=" + Id + "&ObjectId=" + ObjectId;
    url += "&gridpanelid=" + GridId
    if (window != null) {
        url += "&tabframename=" + window.name;
    }
    if (window.parent != null) {
        url += "&pawinid=" + window.parent.name;
    }
    window.top.newWindowRefleX(url, { maximized: false, width: 800, height: 600, resizable: true, modal: true, maximizable: true });
}

