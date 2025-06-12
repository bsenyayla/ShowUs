function getInternetExplorerVersion() {
    var rv = -1; // Return value assumes failure.
    if (navigator.appName == 'Microsoft Internet Explorer') {
        var ua = navigator.userAgent;
        var re = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
        if (re.exec(ua) != null)
            rv = parseFloat(RegExp.$1);
    }
    return rv;
}
function checkVersion() {
    var msg = "";
    var ver = getInternetExplorerVersion();
    if (ver > -1) {
        if (ver >= 8.0) {
            var dmode = parseFloat(document.documentMode);

            if (parseInt(dmode) != parseInt(ver)) {
                msg = "You should use Same Explorer Document Mode and Explorer version. Please check documentation.";
            }
        }
        else {
            var ua = navigator.userAgent;
            var re = new RegExp("Trident");
            if (re.exec(ua) == null) {
                msg = "You should upgrade your copy of Internet Explorer to 8 or higher.";
            }
        }
    }
    if (msg != "") {
        alert(msg);
        window.document.location = GetWebAppRoot + "/Isv/Tu/Helps/helpLogin.aspx";
    }
}