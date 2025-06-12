function ShowConfirmWindow(id)
{
    var url = window.top.GetWebAppRoot;
    url += "/ISV/TU/CustAccount/ApprovePool/DetailPool/ApprovePoolConfirm.aspx";
    
    url += "?recid=" + id;
    if (window != null) {
        url += "&tabframename=" + window.name;
        url += "&rlistframename=" + window.name;
    }
    if (window.parent != null) {
        url += "&pawinid=" + window.parent.name;
        url += "&pframename=" + window.parent.name;
    }
    window.top.newWindowRefleX(url, { maximized: false, width: 1024, height: 600, resizable: true, modal: true, maximizable: true });
}