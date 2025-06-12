<%@ Page Language="C#" AutoEventWireup="true" Inherits="CacheMonitor_CacheMonitor" Codebehind="CacheMonitor.aspx.cs" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../css/custom.css" rel="stylesheet" />
</head>
<body style="background-color: white">
    <form id="form1" runat="server">
        <div>
            <h1>UPT Cache Monitor</h1>
            <table>
                <tr>
                    <td>Cache Üzerinde Bulunan Dosya Sayısı : 
                    </td>
                    <td>
                        <asp:Label ID="lblCacheCount" runat="server" Text="Label" Font-Bold="True"></asp:Label>
                    </td>
                    <td>
                        <asp:Button ID="Button4" runat="server" Text="Button" OnClick="Button4_Click" />
                    </td>
                </tr>
            </table>
            <hr />
            <table>
                <tr>
                    <td>Model Seçiniz :
                        
                    </td>
                    <td>
                        <asp:DropDownList ID="ddlModel" runat="server">
                        </asp:DropDownList>
                    </td>
                    <td>
                        <asp:Button ID="btnCacheData" runat="server" Text="Cache' den Getir" OnClick="btnCacheData_Click" />
                    </td>
                    <td>
                        <asp:Button ID="btnCacheSet" runat="server" Text="Cache' den Silinenleri Ekle" OnClick="btnCacheSet_Click" />
                    </td>
                    <td>
                        <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" Text="Sil" />
                    </td>
                </tr>
                <tr>
                    <td>Boyut :
                    </td>
                    <td>
                        <asp:Label ID="lblModelSize" runat="server" Text="-" Font-Bold="True"></asp:Label>
                    </td>
                    <td>Kayıt Sayısı :
                    </td>
                    <td>
                        <asp:Label ID="lblRowCount" runat="server" Font-Bold="True"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>Tarih Seçiniz :
                    </td>
                    <td>
                        <asp:TextBox ID="txtDatetime" runat="server">

                        </asp:TextBox>
                    </td>
                    <td>
                        <asp:Button ID="Button2" runat="server" OnClick="Button2_Click" Text="Monitor" />
                    </td>
                </tr>
                <tr>
                    <asp:GridView ID="GridView1" CssClass="table table-striped table-bordered" runat="server" CellPadding="4" ForeColor="#333333" GridLines="None" OnRowDataBound="GridView1_RowDataBound">
                    </asp:GridView>
                </tr>
                <tr>
                    <asp:Button ID="Button3" runat="server" OnClick="Button3_Click" Text="Monitor" />
                </tr>
            </table>

        </div>
    </form>
</body>
</html>
