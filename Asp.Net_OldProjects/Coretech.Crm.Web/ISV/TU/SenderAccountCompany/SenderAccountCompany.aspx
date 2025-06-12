<%@ Page Language="C#" AutoEventWireup="true" Inherits="SenderAccountCompany_SenderAccountCompany" Codebehind="SenderAccountCompany.aspx.cs" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/SenderAccountCompany.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <rx:RegisterResources runat="server" ID="RR"/>
    </div>
    </form>
</body>
</html>

