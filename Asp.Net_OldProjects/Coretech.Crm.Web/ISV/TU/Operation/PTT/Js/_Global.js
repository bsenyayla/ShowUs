function RefreshParetnGrid() {
    window.top.SpecialCloseRefreshParentGrid();
}

/*
PoolId=1    confirm     ---OPERATION_POOL
PoolId=2    bekleyen    ---PENDING_TRANSACTIONS
PoolId=3    monitoring  ---PROCESS_MONITORING
PoolId=4    monitoringd  ---PROCESS_MONITORING_DETAIL

*/
function ShowWindow(GridId, Id, ObjectId, PoolId) {
    var url = window.top.GetWebAppRoot + "/ISV/TU/Operation/Detail/_TransactionRouter.aspx?recid=" + Id + "&ObjectId=" + ObjectId;
    url += "&gridpanelid=" + GridId
    url += "&PoolId=" + PoolId

    if (window != null) {
        url += "&tabframename=" + window.name;
        url += "&rlistframename=" + window.name
    }
    if (window.parent != null) {
        url += "&pawinid=" + window.parent.name;
        url += "&pframename=" + window.parent.name;
    }

    window.top.newWindowRefleX(url, { maximized: false, width: 900, height: 600, resizable: true, modal: true, maximizable: false });
}

function ToolbarButtonClearOnClik() {
    location.reload(true);
}

function ShowRefundClick(Id) {
    var url = GetWebAppRoot + "/ISV/TU/Refund/RefundTransfer/_RefundTransferRequest.aspx?TransferId=" + Id;
    window.top.newWindowRefleX(url, { maximized: false, width: 800, height: 600, resizable: true, modal: true, maximizable: true });

}

function OpenHelp() {
    btnInfo.click();
}