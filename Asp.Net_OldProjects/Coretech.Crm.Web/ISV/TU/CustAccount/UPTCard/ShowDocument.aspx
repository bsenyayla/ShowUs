<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ShowDocument.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.CustAccount.UPTCard.ShowDocument" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        function check(r) {
            var ua = navigator.userAgent.toLowerCase();
            return r.test(ua);
        }
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
        var css = function () {
            if (getInternetExplorerVersion() >= 9.0)
                document.body.className = "bodyStyle9";
            if (getInternetExplorerVersion() < 9.0)
                document.body.className = "bodyStyle8";
            if (document.readyState == "complete") {
                for (var i = 0; i < document.getElementsByTagName("div").length; i++) {
                    if (document.getElementsByTagName("div")[i].id)
                        if (document.getElementsByTagName("div")[i].id.toString().indexOf("ReportDiv") > -1) {
                            document.getElementsByTagName("div")[i].style.position = "absolute";
                            document.getElementsByTagName("div")[i].style.float = "left";
                            document.getElementsByTagName("div")[i].style.height = "95%";
                        }
                }
            }
            
        };
        var css2 = function () {
            if (check(/chrome/))
                return;

            for (var i = 0; i < document.getElementsByTagName("div").length; i++) {
                if (document.getElementsByTagName("div")[i].id)
                    if (document.getElementsByTagName("div")[i].id.toString().indexOf("ReportDiv") > -1) {
                        document.getElementsByTagName("div")[i].style.position = "absolute";
                        document.getElementsByTagName("div")[i].style.float = "left";
                        document.getElementsByTagName("div")[i].style.width = "100%";
                        document.getElementsByTagName("div")[i].style.height = "98%";


                        document.getElementsByTagName("div")[i].getElementsByTagName("div")[0].style.overflow = "auto";
                        document.getElementsByTagName("div")[i].getElementsByTagName("div")[0].style.height = "97%";
                        document.getElementsByTagName("div")[i].getElementsByTagName("div")[0].style.width = "100%";
                    }
            }
        };
        if (document.attachEvent)
            document.attachEvent('onreadystatechange', css);
        else
            document.addEventListener("DOMContentLoaded", css2, false);
    </script>
    <style type="text/css">
	    .bodyStyle8
        {
            overflow: scroll !important;
            height: 98% !important;
            width: 99% !important;
        }
        .bodyStyle9
        {
            overflow: hidden !important;
            height: 98% !important;
            width: 99% !important;
        }
        .bodyStyle
        {
            overflow: scroll !important;
            height: 98% !important;
            width: 99% !important;
            float: left !important;
            position: absolute !important;
        }
    </style>
</head>
<body class="bodyStyle" runat="server" id="bd">
    <form id="form1" runat="server">
     <asp:scriptmanager id="ScriptManager11" runat="server">
    </asp:scriptmanager>
    </form>
</body>
</html>
