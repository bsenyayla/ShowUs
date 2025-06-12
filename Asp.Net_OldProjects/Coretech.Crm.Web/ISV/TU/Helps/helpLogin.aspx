<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Page Language="C#" AutoEventWireup="true" Inherits="helpLogin" Codebehind="helpLogin.aspx.cs" %>


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .style1
        {
            width: 837px;
            height: 193px;
        }
        .style2
        {
            width: 837px;
            height: 196px;
        }
        .style3
        {
            width: 837px;
            height: 235px;
        }
        .style4
        {
            font-family: Verdana;
            font-size: small;
        }
    </style>
</head>
<body>

    <p class="style4">
        &nbsp;Press &quot;F12&quot; to open Internet Explorer Developer Tool Bar then 
    </p>
    <p class="style4">
        reconfigure your Internet Explorer browser mode and document mode like 
        below 
    </p>
    <p>
        <img alt="" class="style1" src="Images/10-10.png" /></p>
    <p>
        <img alt="" class="style2" src="Images/8-8.png" /></p>
    <p>
        <img alt="" class="style3" src="Images/9-9.png" /></p>

</body>
</html>

<script language="javascript">
    document.onload = checkVersion();
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
        var err = "";
        var ver = getInternetExplorerVersion();
        if (ver > -1) {
            if (ver >= 8.0) {
                var dmode = parseFloat(document.documentMode);

                if (parseInt(dmode) != parseInt(ver)) {
                    err = "You should use same Explorer Document Mode and Explorer version. Please check documentation.";
                }
            }
            else {
                var ua = navigator.userAgent;
                var re = new RegExp("Trident");
                if (re.exec(ua) == null) {
                    err = "You should upgrade your copy of Internet Explorer to 8 or higher.";
                }
            }
        }
        if (err == "") {
            window.document.location = GetWebAppRoot + "/Login.aspx";
        }
    }
</script>