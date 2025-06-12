<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_Main" CodeBehind="Main.aspx.cs" %>

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
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:TabPanel runat="server" ID="TabPanel1" AutoHeight="Auto" AutoWidth="true">
            <Tabs>
                <rx:Tab ID="TabProcessMonitoring" runat="server" Title="CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING"
                    TabMode="Frame" Url="Detail/_Monitoring.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="TabOperationPool" runat="server" Title="CRM.NEW_PROCESSMONITORING_OPERATION_POOL"
                    TabMode="Frame" Url="Detail/_OperationPool.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="TabPendingTransactions" runat="server" Title="CRM.NEW_PROCESSMONITORING_PENDING_TRANSACTIONS"
                    TabMode="Frame" Url="Detail/_PendingTransactions.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="TabCancelPool" runat="server" Title="CRM.NEW_PROCESSMONITORING_CANCEL_POOL"
                    TabMode="Frame" Url="Detail/_CancelPool.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="TabRefundPool" runat="server" Title="CRM.NEW_PROCESSMONITORING_INTEGRATION_REFUND_POOL"
                    TabMode="Frame" Url="Detail/_IntegrationRefundPool.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="TabProblemTransaction" runat="server" Title="CRM.NEW_PROCESSMONITORING_PROBLEM_TRANSACTION_POOL"
                    TabMode="Frame" Url="Detail/_ProblemTransactionPool.aspx" Closable="false">
                </rx:Tab>

                 <rx:Tab ID="TabGsmTransaction" runat="server" Title="CRM.NEW_PROCESSMONITORING_GSM_TRANSACTION_POOL"
                    TabMode="Frame" Url="Detail/_GsmTransactionPool.aspx" Closable="false">
                </rx:Tab>

                 <rx:Tab ID="TabEArchivePool" runat="server" Title="İşlem Arşiv Statüsü"
                    TabMode="Frame" Url="Detail/_EArchivePool.aspx" Closable="false">
                </rx:Tab>

                



                <%-- <rx:Tab ID="TabProcessMonitoringDetail" runat="server" Title="CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING_DETAIL"
                TabMode="Frame" Url="Detail/_MonitoringDetail.aspx" Closeable="false">
            </rx:Tab>--%>
            </Tabs>
        </rx:TabPanel>
    </form>
</body>
</html>
