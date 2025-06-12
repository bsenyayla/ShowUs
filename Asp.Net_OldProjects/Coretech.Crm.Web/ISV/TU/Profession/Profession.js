function ShowProfession(senderId, pageTitle) {
    var config = GetWebAppRoot + "/ISV/TU/Profession/Profession.aspx?senderId=" + senderId;
    window.top.newWindow(config, {
        title: pageTitle,
        width: 450,
        height: 300,
        draggable: false,
        resizable: false,
        modal: true
    });
}