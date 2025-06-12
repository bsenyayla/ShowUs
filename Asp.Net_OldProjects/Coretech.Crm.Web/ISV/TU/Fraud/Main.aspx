<%@ Page Language="C#" AutoEventWireup="true" Inherits="Fraud.Fraud_Main" Codebehind="Main.aspx.cs" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:TabPanel runat="server" ID="TabPanel1" AutoHeight="Auto" AutoWidth="true">
        <Tabs>
             <rx:Tab ID="TabPendingTransactions" runat="server" Title="CRM.NEW_FRAUDLOG_PENDING_TRANSACTIONS" TabMode="Frame"
                Url="Detail/_PendingTransactions.aspx" Closeable="false">
            </rx:Tab>
            
            <rx:Tab ID="TabProcessMonitoring" runat="server" Title="CRM.NEW_FRAUDLOG_PROCESS_MONITORING" TabMode="Frame"
                Url="Detail/_Monitoring.aspx" Closeable="false">
            </rx:Tab>

            <rx:Tab ID="TabPendingAccountActions" runat="server" Title="CRM.NEW_CUSTACCOUNTFRAUDLOG_PENDING_ACTIONS" TabMode="Frame"
                Url="Detail/_PendingAccountActions.aspx" Closeable="false">
            </rx:Tab>
            
            <rx:Tab ID="TabAccountMonitoring" runat="server" Title="CRM.NEW_CUSTACCOUNTFRAUDLOG_MONITORING" TabMode="Frame"
                Url="Detail/_AccountMonitoring.aspx" Closeable="false">
            </rx:Tab>

        </Tabs>
    </rx:TabPanel>
    </form>
</body>
</html>
