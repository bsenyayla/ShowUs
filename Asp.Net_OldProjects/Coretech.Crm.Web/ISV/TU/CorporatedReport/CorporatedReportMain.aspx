<%@ Page Language="C#" AutoEventWireup="true" Inherits="CorporatedReport_Main" CodeBehind="CorporatedReportMain.aspx.cs" %>

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
                <rx:Tab ID="TabCustomerReport" runat="server" Title="Müşteri Adedi Raporu"
                    TabMode="Frame" Url="Detail/_CustomerReport.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="TabQrReport" runat="server" Title="Qr Hareketleri Raporu"
                    TabMode="Frame" Url="Detail/_QrReportPool.aspx" Closable="false">
                </rx:Tab>


                <%-- <rx:Tab ID="TabProcessMonitoringDetail" runat="server" Title="CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING_DETAIL"
                TabMode="Frame" Url="Detail/_MonitoringDetail.aspx" Closeable="false">
            </rx:Tab>--%>
            </Tabs>
        </rx:TabPanel>
    </form>
</body>
</html>
