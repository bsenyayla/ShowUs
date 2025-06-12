<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_Pool_CustAccountReadOnly" Codebehind="CustAccountReadOnly.aspx.cs" %>

<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />

        <rx:PanelX runat="server" ID="CustAccountOperationsDetail" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="True">
            <AutoLoad Url="about:blank" ShowMask="true" />
            <Body>
            </Body>

        </rx:PanelX>
    </form>
</body>
</html>
