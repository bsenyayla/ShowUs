<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="MusteriAraDetay.aspx.cs" Inherits="MusteriAraDetay" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

        <table>
            <tr>
                <td>
                    Proje:</td>
                <td>
                    <asp:DropDownList ID="ddlProje" runat="server" AutoPostBack="True" 
                        onselectedindexchanged="ddlProje_SelectedIndexChanged">
                    <asp:ListItem>ACB-MOBIL</asp:ListItem>
                    <asp:ListItem>ACB-SIGORTA</asp:ListItem>
                    <asp:ListItem>AVIVA-SIGORTA</asp:ListItem>
                    <asp:ListItem>AK-SIGORTA</asp:ListItem>
                    <asp:ListItem>ZURICH-SIGORTA</asp:ListItem>
                    <asp:ListItem>AK-SIGORTA</asp:ListItem>
                    <asp:ListItem>MAPFRE-SIGORTA</asp:ListItem>
                    <asp:ListItem>ACE</asp:ListItem>
                    </asp:DropDownList>
                </td>
                <td>
                    &nbsp;</td>
                <td>
                    &nbsp;</td>
                <td>
                    &nbsp;</td>
            </tr>
            <tr>
                <td>
                    Telefon No:
                </td>
                <td>
                    <asp:TextBox ID="txtTelefonNo" runat="server"></asp:TextBox>
                </td>
                <td>
                    &nbsp;
                    <asp:Button ID="btnTelefonAra" runat="server" Text="Ara" 
                        onclick="btnTelefonAra_Click" />
                </td>
                <td>
                    &nbsp;
                    <asp:ImageButton ID="ImageButton1" runat="server" 
                        ImageUrl="~/images/yenimusteri.jpg" onclick="ImageButton1_Click" />
                </td>
                <td>
                    &nbsp;</td>
            </tr>
            <tr>
                <td>
                    TC Kimlik No:
                </td>
                <td>
                    <asp:TextBox ID="txtTcKimlikNo" runat="server"></asp:TextBox>
                </td>
                <td>
                    &nbsp;
                    <asp:Button ID="btnTcKimlikAra" runat="server" Text="Ara" 
                        onclick="btnTcKimlikAra_Click" />
                </td>
                <td>
                    &nbsp;
                </td>
                <td>
                    &nbsp;</td>
            </tr>
            <tr>
                <td>
                    Ad:
                </td>
                <td>
                    <asp:TextBox ID="txtAd" runat="server"></asp:TextBox>
                </td>
                <td>
                    Soyad:
                </td>
                <td>
                    <asp:TextBox ID="txtSoyad" runat="server"></asp:TextBox>
                </td>
                <td>
                    <asp:Button ID="btnAdSoyadAra" runat="server" Text="Ara" 
                        onclick="btnAdSoyadAra_Click" />
                </td>
            </tr>
        </table>

        <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="Red"></asp:Label>

    <br />
    <br />
    <asp:GridView ID="GridView1" runat="server">
    <Columns>
    
        <asp:TemplateField>
            <ItemTemplate>
              <a href="MusteriDetay.aspx?MusteriId=<%#Eval("Id") %>">Detay</a>
            </ItemTemplate>
        </asp:TemplateField>
    
    </Columns>
</asp:GridView>
    <br />
    </asp:Content>