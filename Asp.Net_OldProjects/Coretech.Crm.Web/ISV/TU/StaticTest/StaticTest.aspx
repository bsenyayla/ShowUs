<%@ Page Language="C#" AutoEventWireup="true" Inherits="StaticTest_StaticTest" Codebehind="StaticTest.aspx.cs" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <table>
            <tr>
                <td>
                    <asp:Label runat="server" ID="lbl1" Text="Setlenecek Değer"></asp:Label>
                    
                </td>
                <td>
                <asp:TextBox runat="server" ID="txtStaticEntry"></asp:TextBox>
                    </td>
            </tr>
            <tr>
                <td><asp:Label runat="server" ID="Label1" Text="Gelen Değer"></asp:Label></td>
                <td><asp:TextBox runat="server" ID="txtStaticOut"></asp:TextBox></td>
            </tr>
            <tr>
                <td>
                    <asp:Button ID="btnSet" Text="Setle" runat="server" OnClick="btnSet_Click" />
                </td>
                <td><asp:Button ID="btnGetir" Text="Getir" runat="server" OnClick="btnGetir_Click" /></td> 
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
