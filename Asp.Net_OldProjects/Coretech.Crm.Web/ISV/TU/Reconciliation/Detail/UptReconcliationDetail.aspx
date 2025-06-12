<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reconcliation_Detail_UptReconcliationDetail" Codebehind="UptReconcliationDetail.aspx.cs" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>

            <asp:GridView ID="gvBank" runat="server" Caption="Akustik Kayıtları" EmptyDataText="Ya varsa?"></asp:GridView>
            <p>&nbsp;</p>
            <asp:GridView ID="gvUpt" runat="server" Caption="UPT Ön Muhasebe Kayıtları" EmptyDataText="Ya varsa?"></asp:GridView>
            <p>&nbsp;</p>
            <asp:GridView ID="gvTransfer" runat="server" Caption="Transfer Bilgileri" EmptyDataText="Ya varsa?"></asp:GridView>
            <p>&nbsp;</p>
            <asp:GridView ID="gvPayment" runat="server" Caption="Ödeme Bilgileri" EmptyDataText="Ya varsa?"></asp:GridView>
            <p>&nbsp;</p>
            <asp:GridView ID="gvRefundPayment" runat="server" Caption="İade Ödeme Bilgileri" EmptyDataText="Ya varsa?"></asp:GridView>
            <p>&nbsp;</p>
            <asp:GridView ID="gvRefundTransfer" runat="server" Caption="İade Gönderim Bilgileri" EmptyDataText="Ya varsa?"></asp:GridView>
        </div>
    </form>
</body>
</html>
