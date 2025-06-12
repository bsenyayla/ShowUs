<%@ Page Language="C#" AutoEventWireup="true" Inherits="AccountTransactionReport_AccountTransactionReport" Codebehind="AccountTransactionReport.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../css/bootstrap.min.css" rel="stylesheet" />
    <script src="js/CreateReport.js"></script>
</head>


<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <asp:HiddenField ID="hdnRecid" runat="server" />
        <asp:HiddenField ID="hdnReportId" runat="server" />
        <asp:HiddenField ID="StartDate" runat="server" />
        <asp:HiddenField ID="EndDate" runat="server" />
        <asp:HiddenField ID="Source" runat="server" />
        <div style="margin: 10px 0px 0px 10px">
            <asp:Label ID="Header" runat="server" Text="Hesap Hareketi Raporlama Ekranı" ForeColor="#FBBC06" Font-Size="Large" Font-Bold="true"></asp:Label>
            <hr />
            <div>

                <asp:Label ID="Label4" runat="server" Text="Kaynak" ForeColor="#FBBC06" Font-Size="Small" Font-Bold="true"></asp:Label>
                <br />
                <asp:RadioButtonList ID="RadioButtonList2" runat="server" Width="300px" RepeatDirection="Horizontal" style="display:inline">
                    <asp:ListItem Text="&nbsp; UPT &nbsp;&nbsp;&nbsp;" Value="1" Selected="True" />
                    <asp:ListItem Text="&nbsp; LOGO" Value="2" />
                </asp:RadioButtonList>
                <br />
                <div>
                    <div style="float: left">
                        <asp:Label ID="Label1" runat="server" Text="Rapor Tipi" ForeColor="#FBBC06" Font-Size="Small" Font-Bold="true"></asp:Label>
                        <br />
                        <br />
                        <asp:RadioButtonList ID="RadioButtonList1" runat="server" Width="300px">
                            <asp:ListItem Text="&nbsp; Kasa İşlemleri Raporu Özet" Value="1" Selected="True" />
                            <asp:ListItem Text="&nbsp; Kasa İşlemleri Raporu Detay" Value="2" />
                            <asp:ListItem Text="&nbsp; Kurum Cari Hesap Raporı Özet" Value="3" />
                            <asp:ListItem Text="&nbsp; Kurum Cari Hesap Raporı Detay" Value="4" />
                            <asp:ListItem Text="&nbsp; Gelir Hesapları Raporu Özet" Value="5" />
                            <asp:ListItem Text="&nbsp; Gelir Hesapları Raporu Detay" Value="6" />
                            <asp:ListItem Text="&nbsp; Gider Hesapları Raporu Özet" Value="7" />
                            <asp:ListItem Text="&nbsp; Gider Hesapları Raporu Detay" Value="8" />
                            <asp:ListItem Text="&nbsp; Talimatlı İşlemler Özet" Value="9" />
                            <asp:ListItem Text="&nbsp; Talimatlı İşlemler Detay" Value="10" />
                            <asp:ListItem Text="&nbsp; Hakediş Raporu Detay" Value="11" />
                        </asp:RadioButtonList>
                        <br />
                        <asp:LinkButton ID="LinkButton1" runat="server" type="button" OnClick="lbSearch_Click" class="btn btn-success">Excel'le Çözümle
                         <span class="caret"></span>
                        </asp:LinkButton>
                    </div>
                    <div style="float: left; width: 39px; color: #FBBC06">
                        &nbsp;&nbsp;&nbsp;&nbsp; 
                    </div>
                    <div style="float: left">
                        <asp:Label ID="Label2" runat="server" Text="Başlangıç Tarihi" ForeColor="#FBBC06" Font-Size="Small" Font-Bold="true"></asp:Label>
                        <br />
                        <br />
                        
                        <asp:Calendar ID="new_StartDate"  DayHeaderStyle-BackColor="#FBBC06"  OtherMonthDayStyle-BackColor="White" runat="server">
                            <TitleStyle BackColor="White" />
                        </asp:Calendar>
                    </div>
                    <div style="float: left; width: 39px; color: #FBBC06">
                        &nbsp;&nbsp;&nbsp;&nbsp; 
                    </div>
                    <div style="float: left">
                        <asp:Label ID="Label3" runat="server" Text="Bitiş Tarihi" ForeColor="#FBBC06" Font-Size="Small" Font-Bold="true"></asp:Label>
                        <br />
                        <br />
                        <asp:Calendar ID="new_EndDate" DayHeaderStyle-BackColor="#FBBC06" runat="server">
                            <TitleStyle BackColor="White" />
                        </asp:Calendar>
                    </div>
                </div>
            </div>
    </form>
</body>
</html>
