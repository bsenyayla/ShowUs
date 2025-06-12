<%@ Page Language="C#" MasterPageFile="~/Yonetim/Yonetim.master" AutoEventWireup="true" CodeFile="TicketsV2.aspx.cs" Inherits="Yonetim_TicketsV2" Title="Ticketlar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">

<style type="text/css">
.style1
{
width: 100%;
}
.style2
{
width: 129px;
}
.style3
{
}
.style4
{
width: 309px;
}
.style5
{
width: 162px;
}
</style>

    <script src="../Scripts/jquery-1.3.2.js" type="text/javascript"></script>

    <script type="text/javascript">
    function hede(ad) 
    {
      $("div#"+ad).slideToggle("fast");
    }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <asp:ImageButton ImageUrl="~/images/home.png" ID="ImageButton1" Width="30px" 
                            Height="30px" runat="server" onclick="ImageButton1_Click" ToolTip="Anasayfa" />
    <asp:Label ID="lblMesaj" runat="server" Text=""></asp:Label>
    <br />
    <div id="kisayolAramaBaslik" style="padding-left: 7px; background-color: #5D7B9D;
        color: White; font-weight: bold; width: 800px; cursor: pointer; margin-top: 7px;"
        onclick="hede('kisayolArama')">
        KISAYOLLAR
    </div>
    <div id="kisayolArama">
        <fieldset style="width: 800px;">
            <legend>Kısayollar</legend>
            <asp:Button ID="btnUzerimdekiAktifTicketlar" runat="server" Text="Üzerimdeki Aktif Ticketlar"
                OnClick="btnUzerimdekiAktifTicketlar_Click" Width="350px" />
            <br />
            <br />
            <asp:Button ID="btnDepartmanımdakiBostakiTicketlar" runat="server" Text="Departmanımdaki Boştaki Ticketlar"
                Width="350px" OnClick="btnDepartmanımdakiBostakiTicketlar_Click" />
        </fieldset>
    </div>
    <br />
    <div id="detayliAramabaslik" style="padding-left: 7px; background-color: #5D7B9D;
        color: White; font-weight: bold; width: 800px; cursor: pointer; margin-top: 7px;"
        onclick="hede('detayliArama')">
        DETAYLI ARAMA
    </div>
    <div id="detayliArama" style="display:none;">
        <fieldset style="width: 800px;">
            <legend>Arama Kriterleri</legend>
            <table class="style1">
                <tr>
                    <td class="style2">
                        Departman:
                    </td>
                    <td class="style4">
                        <asp:DropDownList ID="ddlDepartman" runat="server" Width="250px" AutoPostBack="True"
                            OnSelectedIndexChanged="ddlDepartman_SelectedIndexChanged">
                        </asp:DropDownList>
                    </td>
                    <td class="style5">
                        Açılış Tarihi (Başlangıç):
                    </td>
                    <td>
                        <asp:TextBox ID="txtAcilisTarihBaslangic" runat="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td class="style2">
                        Kategori:
                    </td>
                    <td class="style4">
                        <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:DropDownList ID="ddlKategori" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlKategori_SelectedIndexChanged"
                                    Width="250px">
                                </asp:DropDownList>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="ddlDepartman" 
                                    EventName="SelectedIndexChanged" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </td>
                    <td class="style5">
                        Açılış Tarihi (Bitiş):
                    </td>
                    <td>
                        <asp:TextBox ID="txtAcilisTarihBitis" runat="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td class="style2">
                        Alt Kategori:
                    </td>
                    <td class="style4">
                        <asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:DropDownList ID="ddlAltKategori" runat="server" Width="250px">
                                </asp:DropDownList>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="ddlKategori" 
                                    EventName="SelectedIndexChanged" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </td>
                    <td class="style5">
                        Kapanış Tarihi (Başlangıç):
                    </td>
                    <td>
                        <asp:TextBox ID="txtKapanisTarihBaslangic" runat="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td class="style2">
                        Türü:
                    </td>
                    <td class="style4">
                        <asp:DropDownList ID="ddlTur" runat="server" Width="250px">
                            <asp:ListItem>Boştaki</asp:ListItem>
                            <asp:ListItem>Aktif</asp:ListItem>
                            <asp:ListItem>Kapalı</asp:ListItem>
                            <asp:ListItem>Tümü</asp:ListItem>
                        </asp:DropDownList>
                    </td>
                    <td class="style5">
                        Kapanış Tarihi (Bitiş):
                    </td>
                    <td>
                        <asp:TextBox ID="txtKapanisTarihBitis" runat="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td class="style2">
                        Kimin Üzerinde:
                    </td>
                    <td class="style4">
                        <asp:DropDownList ID="ddlKiminUzerinde" runat="server" Width="250px">
                            <asp:ListItem>Benim</asp:ListItem>
                            <asp:ListItem>Diğer Kişiler</asp:ListItem>
                            <asp:ListItem Selected="True">Tümü</asp:ListItem>
                        </asp:DropDownList>
                    </td>
                    <td class="style5">
                        Açan Personel:
                    </td>
                    <td>
                        <asp:TextBox ID="txtAcanPersonel" runat="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td class="style2">
                        Durumu:
                    </td>
                    <td class="style4">
                        <asp:DropDownList ID="ddlDurum" runat="server" Width="250px">
                        </asp:DropDownList>
                    </td>
                    <td class="style5">
                        Kapatan Personel:
                    </td>
                    <td>
                        <asp:TextBox ID="txtKapatanPersonel" runat="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td class="style2">
                        Kapanma Nedeni:
                    </td>
                    <td class="style4">
                        <asp:DropDownList ID="ddlKapanmaNeden" runat="server" Width="250px">
                        </asp:DropDownList>
                    </td>
                    <td class="style5">
                        &nbsp;
                    </td>
                    <td>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td class="style2">
                        Müşteri Telefonu:
                    </td>
                    <td class="style4">
                        <asp:TextBox ID="txtMusteriTelefon" runat="server"></asp:TextBox>
                    </td>
                    <td class="style5">
                        &nbsp;
                    </td>
                    <td>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td class="style2">
                        &nbsp;
                    </td>
                    <td class="style4">
                        &nbsp;
                    </td>
                    <td class="style5">
                        &nbsp;
                    </td>
                    <td>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td class="style2">
                        &nbsp;
                    </td>
                    <td class="style3" colspan="2">
                        <asp:Button ID="btnAra" runat="server" Text="ARA" Width="250px" OnClick="btnAra_Click" />
                    </td>
                    <td>
                        &nbsp;
                    </td>
                </tr>
            </table>
        </fieldset>
    </div>
    <br />
    <br />
    <asp:LinkButton ID="lbExcel" runat="server" OnClick="ExceleAktarClick">Excele Aktar</asp:LinkButton>
    <asp:GridView ID="GridView1" runat="server" CellPadding="4" ForeColor="#333333" 
        GridLines="None" AutoGenerateColumns="False">
        <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
        <FooterStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
        <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
        <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
        <EditRowStyle BackColor="#999999" />
        <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
        <Columns>
            <asp:TemplateField>
                <ItemTemplate>
                    <a href='TicketDetay.aspx?Id=<%# Eval("Id") %>'>Detay</a>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <a target="_blank" href='../MusteriBilgileri.aspx?MusteriId=<%# Eval("MusteriId") %>'>Müşteri</a>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="Id" HeaderText="Id" />
            <asp:BoundField DataField="Tarih" HeaderText="Tarih" />
            <asp:BoundField DataField="Müşteri" HeaderText="Müşteri" />
            <asp:BoundField DataField="MusteriId" HeaderText="Müşteri No" />
            <asp:BoundField DataField="Kategori" HeaderText="Kategori" />
            <asp:BoundField DataField="AltKategori" HeaderText="AltKategori" />
            <asp:BoundField DataField="Aciklama" HeaderText="Aciklama" />
            <asp:BoundField DataField="TicketAgent" HeaderText="TicketAgent" />
            <asp:BoundField DataField="Durum" HeaderText="Durum" />
            <asp:BoundField DataField="DurumAgent" HeaderText="DurumAgent" />
            <asp:BoundField DataField="Sonuc" HeaderText="Sonuc" />
            <asp:BoundField DataField="SonucTarih" HeaderText="SonucTarih" />
            <asp:BoundField DataField="SonucAgent" HeaderText="SonucAgent" />
            <asp:BoundField DataField="UyelikTarih" HeaderText="UyelikTarih" />
            <asp:BoundField DataField="uyelikAgent" HeaderText="UyelikAgent" />
            <asp:BoundField DataField="Oneri" HeaderText="Oneri" />
            <asp:BoundField DataField="Paket1" HeaderText="Paket1" />
            <asp:BoundField DataField="Paket2" HeaderText="Paket2" />
            <asp:BoundField DataField="Paket3" HeaderText="Paket3" />
         
            <asp:BoundField DataField="Paket1Fiyat" HeaderText="Paket1Fiyat" />
            <asp:BoundField DataField="Paket2Fiyat" HeaderText="Paket2Fiyat" />
            <asp:BoundField DataField="Paket3Fiyat" HeaderText="Paket3Fiyat" />
            <asp:BoundField DataField="Paket1Tarih" HeaderText="Paket1Tarih" />
            <asp:BoundField DataField="Paket2Tarih" HeaderText="Paket2Tarih" />
            <asp:BoundField DataField="Paket3Tarih" HeaderText="Paket3Tarih" />
        </Columns>
    </asp:GridView>
</asp:Content>

