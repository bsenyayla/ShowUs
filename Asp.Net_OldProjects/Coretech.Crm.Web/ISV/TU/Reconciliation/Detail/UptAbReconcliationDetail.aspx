<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reconciliation.Detail.Reconciliation_Detail_UptAbReconcliationDetail" CodeBehind="UptAbReconcliationDetail.aspx.cs" %>


<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="JS/TransferFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="TransferId" runat="server" />
        <rx:Hidden ID="PaymentId" runat="server" />
        <rx:Hidden ID="RefundpaymentId" runat="server" />
        <rx:Hidden ID="TransferReference" runat="server" />
        <rx:Hidden ID="TransactionType" runat="server" />
 
        <rx:PanelX runat="server" ID="pnlManualPreaccounting" AutoHeight="Normal" Height="600" AutoWidth="true"
            CustomCss="Section2" Title="Önmuhasebe Manuel Fiş Kesme" Collapsed="true" Collapsible="true"
            Border="false">
            <AutoLoad Url="about:blank" />
            <Body>
            </Body>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="pnlManualBankAccounting" AutoHeight="Normal" Height="600" AutoWidth="true"
            CustomCss="Section2" Title="Banka Muhasebesi Manuel Fiş Kesme" Collapsed="true" Collapsible="true" BackColor="YellowGreen"
            Border="false">
            <AutoLoad Url="about:blank" />
            <Body>
            </Body>
        </rx:PanelX>
        <rx:PanelX ID="PanelX1" runat="server" AutoHeight="Normal" Height="600" Width="500" ContainerPadding="true" Title="Hesap Hareketleri" Collapsed="true" Collapsible="true">
            <Body>
                <div>

                    <asp:GridView ID="gvBank" runat="server" Font-Size="Medium" Caption="Akustik Kayıtları" EmptyDataText="Ya varsa?"></asp:GridView>
                    <p>&nbsp;</p>
                    <asp:GridView ID="gvUpt" runat="server" Font-Size="Medium" Caption="UPT Ön Muhasebe Kayıtları" EmptyDataText="Ya varsa?"></asp:GridView>
                    <p>&nbsp;</p>
                    <asp:GridView ID="gvTransfer" runat="server" Font-Size="Medium" Caption="Transfer Bilgileri" EmptyDataText="Ya varsa?"></asp:GridView>
                    <p>&nbsp;</p>
                    <asp:GridView ID="gvPayment" runat="server" Font-Size="Medium" Caption="Ödeme Bilgileri" EmptyDataText="Ya varsa?"></asp:GridView>
                    <p>&nbsp;</p>
                    <asp:GridView ID="gvRefundPayment" runat="server" Font-Size="Medium" Caption="İade Ödeme Bilgileri" EmptyDataText="Ya varsa?"></asp:GridView>
                    <p>&nbsp;</p>
                    <asp:GridView ID="gvRefundTransfer" runat="server" Font-Size="Medium" Caption="İade Gönderim Bilgileri" EmptyDataText="Ya varsa?"></asp:GridView>
                </div>
            </Body>
        </rx:PanelX>
    </form>
    <p>
    </p>
</body>
</html>

