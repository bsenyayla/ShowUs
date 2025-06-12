function ShowUserPoolMap() {
    var config = GetWebAppRoot + "/ISV/TU/UserCountrols/UserPoolMap.ascx?RecordId=" + hdnRecid.getValue();
    window.top.newWindow(config, { title: 'User Security Role', width: 800, height: 500, resizable: false });
}