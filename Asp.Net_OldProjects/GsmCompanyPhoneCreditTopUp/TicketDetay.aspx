<%@ Page Language="C#" MasterPageFile="~/Yonetim/Yonetim.master" AutoEventWireup="true" CodeFile="TicketDetay.aspx.cs" Inherits="Yonetim_TicketDetay" Title="Ticket Detay" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
 <script src="../Scripts/jquery-1.3.2.js" type="text/javascript"></script>

    <script type="text/javascript">
 function hede(ad) 
    {
      $("div#"+ad).slideToggle("fast");
    }
    
    function setSonucVisible()
    {
       var ddl=document.getElementById("ctl00_ContentPlaceHolder1_ddlAktivite");
       if((window.location.href.indexOf('WebUI')==-1 && ddl.value=="4") || (window.location.href.indexOf('WebUI')>-1 && ddl.value=="4"))
       {
        $("#ctl00_ContentPlaceHolder1_ddlSonuc").show();
        $("#ctl00_ContentPlaceHolder1_Label1").show();
         $("#ctl00_ContentPlaceHolder1_ddlOneri").show();
        $("#ctl00_ContentPlaceHolder1_Label2").show();
       }
       else
       {
        $("#ctl00_ContentPlaceHolder1_ddlSonuc").hide();
        $("#ctl00_ContentPlaceHolder1_Label1").hide();
          $("#ctl00_ContentPlaceHolder1_ddlOneri").hide();
        $("#ctl00_ContentPlaceHolder1_Label2").hide();
        }
    }
    </script>

    <style type="text/css">
        .style1
        {
            width: 100%;
        }
        .style2
        {
            width: 150px;
            font-weight: bold;
        }
        .style4
        {
            width: 197px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<asp:ImageButton ImageUrl="~/images/arrow_left.png" ID="ImageButton1" Width="30px" 
                            Height="30px" runat="server" onclick="ImageButton1_Click" ToolTip="Anasayfa" />
<div id="Div1" style="padding-left: 7px; background-color: #5D7B9D; color: White;
        font-weight: bold; width: 650px; cursor: pointer;" onclick="hede('Bilgi')">
        Genel Bilgi</div>
    <div id="Bilgi" style="padding-left: 4px; border-color: Black; border-width: 1px;
        border-style: dotted; width: 650px; padding-bottom: 24px;">
        <table class="style1">
            <tr>
                <td class="style2">
                    Ticket Tarihi:
                </td>
                <td>
                    <asp:Label ID="lblTicketTarih" runat="server"></asp:Label>
                </td>
            </tr>
            <tr>
                <td class="style2">
                    Müşteri:
                </td>
                <td>
                    <asp:Label ID="lblMusteri" runat="server"></asp:Label>
                    &nbsp;
                    <asp:HyperLink ID="HyperLink1" runat="server" Target="_blank">Detay</asp:HyperLink>
                    <asp:HiddenField ID="hdnMusteriId" runat="server" />
                </td>
            </tr>
            <tr>
                <td class="style2">
                    Telefon No:
                </td>
                <td>
                    <asp:Label ID="lblTelefonNo" runat="server"></asp:Label>
                </td>
            </tr>
            <tr>
                <td class="style2">
                    Kategori:
                </td>
                <td>
                    <asp:Label ID="lblKategori" runat="server"></asp:Label>
                </td>
            </tr>
            <tr>
                <td class="style2">
                    Alt Kategori:
                </td>
                <td>
                    <asp:Label ID="lblAltKategori" runat="server"></asp:Label>
                </td>
            </tr>
            <tr>
                <td class="style2">
                    Agent:
                </td>
                <td>
                    <asp:Label ID="lblAgent" runat="server"></asp:Label>
                </td>
            </tr>
            <tr>
                <td class="style2">
                    Durumu:
                </td>
                <td>
                    <asp:Label ID="lblDurum" runat="server"></asp:Label>
                </td>
            </tr>
            <tr>
                <td class="style2">
                    Sonuç:
                </td>
                <td>
                    <asp:Label ID="lblSonuc" runat="server"></asp:Label>
                </td>
            </tr>
            <tr>
                <td class="style2">
                    Sonuç Tarihi:
                </td>
                <td>
                    <asp:Label ID="lblSonucTarih" runat="server"></asp:Label>
                </td>
            </tr>
            <tr>
                <td class="style2" valign="top">
                    Açıklama:
                </td>
                <td>
                    <asp:Label ID="lblAciklama" runat="server"></asp:Label>
                </td>
            </tr>
        </table>
    </div>
    <div id="Div2" style="padding-left: 7px; background-color: #5D7B9D; color: White;
        font-weight: bold; width: 650px; cursor: pointer; margin-top: 7px;" onclick="hede('Detay')">
        Detay</div>
    <div id="Detay" style="padding-left: 4px; width: 650px; border-color: Black; border-width: 1px;
        border-style: dotted; padding-top: 5px; padding-right: 4px; padding-bottom: 4px;">
        <asp:DataList ID="DataList1" runat="server">
            <ItemTemplate>
                <table style="width: 645px; border: solid 1px black" align="center">
                    <tr>
                        <td style="width: 450px" colspan="2">
                            &nbsp;
                        </td>
                        <td style="width: 195px">
                            <%# Eval("Agent") %>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 250px">
                            <%# Eval("Status") %>
                        </td>
                        <td style="width: 200px;">
                        </td>
                        <td style="width: 195px">
                            <%# Eval("Tarih") %>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" style="width: 645px">
                            <i>
                                <%# Eval("Aciklama") %></i>
                        </td>
                    </tr>
                </table>
            </ItemTemplate>
        </asp:DataList>
    </div>
    <div id="Div3" style="padding-left: 7px; background-color: #5D7B9D; color: White;
        font-weight: bold; width: 650px; cursor: pointer; margin-top: 7px;" onclick="hede('Detay')"
        runat="server">
        Aktivite Girişi</div>
    <div id="Div4" style="padding-left: 4px; width: 650px; border-color: Black; border-width: 1px;
        border-style: dotted; padding-top: 5px; padding-right: 4px; padding-bottom: 4px;"
        runat="server">
        <table class="style1">
            <tr>
                <td class="style4">
                    Aktivite:
                </td>
                <td>
                    <asp:DropDownList ID="ddlAktivite" runat="server" Width="400px">
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td class="style4">
                    <asp:Label ID="Label1" runat="server" Text="Sonuç:" Style="display: none"></asp:Label>
                </td>
                <td>
                    <asp:DropDownList ID="ddlSonuc" runat="server" Width="400px" Style="display: none">
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td class="style4">
                        <asp:Label ID="Label2" runat="server" Text="Churn Öneri:" Style="display: none"></asp:Label></td>
                <td>
                   <asp:DropDownList ID="ddlOneri" runat="server" Width="400px" Style="display: none">
                    </asp:DropDownList>
            <tr>
                <td class="style4" valign="top">
                    Açıklama:
                </td>
                <td>
                    <asp:TextBox ID="txtAciklama" runat="server" Height="100px" TextMode="MultiLine"
                        Width="400px"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td class="style4">
                    &nbsp;
                </td>
                <td>
                    <asp:CheckBox ID="cbAciklamayaEkle" runat="server" Text="Müşteri Açıklamasına Gir"
                        Visible="False" />
                </td>
            </tr>
            <tr>
                <td class="style4">
                    &nbsp;
                </td>
                <td>
                    <asp:Button ID="btnKaydet" runat="server" Text="Kaydet" OnClick="btnKaydet_Click" />
                </td>
            </tr>
            <tr>
                <td class="style4">
                    &nbsp;
                </td>
                <td>
                    &nbsp;
                </td>
            </tr>
        </table>
    </div>
</asp:Content>

