<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_Main" Codebehind="PTTMain2.aspx.cs" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="PTTMainform" runat="server">
    <rx:RegisterResources runat="server" ID="RR" />
    <rx:TabPanel runat="server" ID="TabPanel1" AutoHeight="Auto" AutoWidth="true">
        <Tabs>
            <rx:Tab ID="Tab_EFTMonitoring" runat="server" Title="EFT İşlemleri"
                TabMode="Frame" Url="_EFTMonitoring.aspx" Closable="false">
            </rx:Tab>
            <rx:Tab ID="Tab_PaymentMonitoring" runat="server" Title="Ödeme İşlemleri"
                TabMode="Frame" Url="_PaymentMonitoring.aspx" Closable="false">
            </rx:Tab>
            <rx:Tab ID="Tab_YPUPTMonitoring" runat="server" Title="YPUPT İşlemleri"
                TabMode="Frame" Url="_YPUPTMonitoring.aspx" Closable="false">
            </rx:Tab>
            <rx:Tab ID="Tab_RefundMonitoring" runat="server" Title="İade İşlemleri"
                TabMode="Frame" Url="_RefundMonitoring.aspx" Closable="false">
            </rx:Tab>
        </Tabs>
    </rx:TabPanel>
    </form>
</body>
</html>
