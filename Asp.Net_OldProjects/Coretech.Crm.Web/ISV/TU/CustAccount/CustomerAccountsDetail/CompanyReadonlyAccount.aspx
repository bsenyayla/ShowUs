<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_CustomerAccountsDetail_CompanyReadonlyAccount" Codebehind="CompanyReadonlyAccount.aspx.cs" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="CompanyReadonlyAccount.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <rx:RegisterResources runat="server" ID="RR"/>
    </div>
    </form>
</body>
</html>
