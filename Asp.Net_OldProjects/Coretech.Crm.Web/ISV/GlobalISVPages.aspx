<%@ Page Language="C#" AutoEventWireup="true" Inherits="ISV_GlobalISVPages"
    ValidateRequest="false" Codebehind="GlobalISVPages.aspx.cs" %>

<%@ Register Assembly="Coretech.Crm.Objects" Namespace="Coretech.Crm.Objects.Crm.CustomControl"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../js/Global.js" type="text/javascript"></script>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR" Theme="Slate" AnyChart="true" />
    </form>
</body>
</html>
<script language="javascript">
    function RedirectParentWindow() {
        //        RefreshParentTab();
        var win = window.top.R.WindowMng.getWindowById(_pawinid);
        if (win != null) {
            frame = win.getTab("Tabpanel1").getTabIFrame(window._tabframename);
            frame.location = frame.location;
        }
    }
    
</script>
