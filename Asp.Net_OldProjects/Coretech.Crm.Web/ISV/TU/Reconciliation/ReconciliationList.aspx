<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reconciliation_ReconciliationList" CodeBehind="ReconciliationList.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:TabPanel runat="server" ID="TabPanel1" AutoHeight="Auto" AutoWidth="true">
            <Tabs>
                <rx:Tab ID="TabAb" runat="server" Title="AB Mutabakat"
                    TabMode="Frame" Url="Detail/_Ab.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="TabAb2" runat="server" Title="AB Mutabakat (Yeni)"
                    TabMode="Frame" Url="Detail/_Ab2.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="TabCorporation" runat="server" Title="CRM.NEW_RECONCILIATION_CORPORATION"
                    TabMode="Frame" Url="Detail/_Corporation.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="TabPreAccounting" runat="server" Title="Ön Muhasebe Mutabakat"
                    TabMode="Frame" Url="Detail/PreAccounting.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="TabLogo" runat="server" Title="Logo Mutabakat"
                    TabMode="Frame" Url="Detail/_Logo.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="TabOnlineUPT" runat="server" Title="Online UPT Mutabakat"
                    TabMode="Frame" Url="Detail/_OnlineUPT.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="TabGsmPayment" runat="server" Title="Oto Mutabakat"
                    TabMode="Frame" Url="Detail/AccountExtract.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="TabUptBankCheck" runat="server" Title="UPT - Banka Hesap Hareketi Mutabakatı"
                    TabMode="Frame" Url="Detail/UptBankTotalCheck.aspx" Closable="false">
                </rx:Tab>
                <%--<rx:Tab ID ="TabFreeAbAccount" runat="server" Title="Akustik Serbest Fiş"
                    TabMode="Frame" Url="../FreeAccounting/ManuelAbAccounting.aspx" Closable="false">
                </rx:Tab>--%>
                <rx:Tab ID="Tab1" runat="server" Title="Kurum Komisyon Mutabakat"
                    TabMode="Frame" Url="Detail/_CorporationCommission.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="Tab2" runat="server" Title="Kasa Aktivite Mutabakat"
                    TabMode="Frame" Url="Detail/UptCashActivityReconcliation.aspx" Closable="false">
                </rx:Tab>
                <rx:Tab ID="Tab3" runat="server" Title="Dış Sistem Mutabakat"
                    TabMode="Frame" Url="Detail/ExternalSystemReconcliation.aspx" Closable="false">
                </rx:Tab>
                       <rx:Tab ID="Tab3rdBankAccount" runat="server" Title="Ucuncu Banka Hesapları Mutabakat"
                    TabMode="Frame" Url="Detail/3rdBankAccountReconciliation.aspx" Closable="false">
                </rx:Tab>
                <%-- <rx:Tab ID="Tab4" runat="server" Title="Kurum Komisyon Mutabakat Yeni"
                    TabMode="Frame" Url="Detail/CorpCommissionReconcliation.aspx" Closable="false">
                </rx:Tab>--%>
            </Tabs>
        </rx:TabPanel>
    </form>s
</body>
</html>
