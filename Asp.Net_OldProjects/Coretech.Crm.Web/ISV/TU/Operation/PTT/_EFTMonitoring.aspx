<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_PTT_EFT_Monitoring" Codebehind="_EFTMonitoring.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>

</head>
<body>
    <form id="form1" runat="server">
        <rx:KeyMap runat="server" ID="KeyMap1">
            <rx:KeyBinding>
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="ToolbarButtonFind.click(e);" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:KeyMap runat="server" ID="KeyMap2">
            <rx:KeyBinding Ctrl="true">
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="ToolbarButtonClear.click(e);" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>

        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Button ID="btnInfo" runat="server" Download="True" Hidden="True">
            <AjaxEvents>
                <Click OnEvent="btnInformationOnEvent">
                </Click>
            </AjaxEvents>
        </rx:Button>
        <table style="width: 100%">
            <tr>
            </tr>
            <tr>
                <td>
                    <rx:PanelX runat="server" ID="pnlButton" AutoHeight="Normal" Height="184" AutoWidth="true"
                        Border="true" Frame="true" Title="Mutabakat Global UPT">
                        <Tools>
                            <Items>
                                <rx:ToolButton IconCls="icon-information" runat="server" ID="btnInformation">
                                    <Listeners>
                                        <Click Handler="OpenHelp(1)" />
                                    </Listeners>
                                </rx:ToolButton>
                            </Items>
                        </Tools>
                        <Body>
                            <table width="92%" align="left">

                                <tr>
                                    <td>
                                        <br />
                                    </td>
                                    <td>
                                        <table width="30%" align="left">
                                            <tr>
                                                <td colspan="3">
                                                    <br />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="left">
                                                    <asp:Label ID="LabelDateField" runat="server" Text="Tarih Aralığı : "></asp:Label>
                                                </td>
                                                <td>
                                                    <rx:DateField runat="server" ID="DateFieldBegin" DateMode="Date"></rx:DateField>
                                                </td>
                                                <td>
                                                    <rx:DateField runat="server" ID="DateFieldEnd" DateMode="Date" Visible="false"></rx:DateField>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="Label_CheckBox" runat="server" Text="Mütabakatsızlar listelensin mi? "></asp:Label>
                                                </td>
                                                <td colspan="2">
                                                    <rx:CheckField ID="CheckField_NonAggreements" runat="server" Text="Mütabakatsızlar listelensin mi? "></rx:CheckField>
                                                </td>

                                                <td>
                                                    <rx:Button runat="server" ID="Button1" Text="encrypt" Icon="MagnifierZoomIn" Width="100">
                                                        <AjaxEvents>
                                                            <Click OnEvent="GoldenCrownDeneme">
                                                            </Click>
                                                        </AjaxEvents>
                                                    </rx:Button>
                                                    <rx:TextField runat="server" ID="denemeTextInput" Width="200"></rx:TextField>
                                                    <rx:TextField runat="server" ID="denemeTextField" Width="1000"></rx:TextField>
                                                    <rx:Button runat="server" ID="Button2" Text="decrypy" Icon="MagnifierZoomIn" Width="100">
                                                        <AjaxEvents>
                                                            <Click OnEvent="GoldenCrownDeneme2">
                                                            </Click>
                                                        </AjaxEvents>
                                                    </rx:Button>
                                                    <rx:TextField runat="server" ID="TextField1" Width="200"></rx:TextField>
                                                </td>

                                            </tr>
                                            <tr>
                                                <td colspan="3">
                                                    <rx:Button runat="server" ID="ToolbarButtonFind" Text="Bul (F9)" Icon="MagnifierZoomIn" Width="100">
                                                        <AjaxEvents>
                                                            <Click OnEvent="ButtonFindClick">
                                                            </Click>
                                                        </AjaxEvents>
                                                    </rx:Button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <rx:Button runat="server" ID="Button3" Text="MarketingGet" Icon="Anchor" Width="100">
                                                        <AjaxEvents>
                                                            <Click OnEvent="GoldenCrownDeneme3">
                                                            </Click>
                                                        </AjaxEvents>
                                                    </rx:Button>
                                                </td>
                                                <td>
                                                    <rx:TextField runat="server" ID="TextField2" Width="200"></rx:TextField>
                                                </td>
                                                <td colspan="2">
                                                    <rx:TextField runat="server" ID="TextField3" Width="1000"></rx:TextField>
                                                </td>
                                            </tr>
                                        </table>

                                    </td>
                                </tr>
                            </table>

                        </Body>
                    </rx:PanelX>
                </td>
            </tr>
            <tr>
                <td>
                    <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="226" AutoWidth="true"
                        Border="true" Frame="true" Title="EFT İşlemleri">


                        <Body>

                            <rx:ColumnLayout runat="server" ID="ColumnLayout0" ColumnWidth="18%" BorderWidth="1" BorderColor="Transparent">
                                <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout001">
                                        <Body>
                                            <asp:Label ID="LabelSpace01" runat="server" Height="22"></asp:Label>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout002">
                                        <Body>
                                            <asp:Label ID="LabelSpace02" runat="server" Height="26"></asp:Label>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout003">
                                        <Body>
                                            <asp:Label ID="LabelLine01" runat="server" Height="22" Width="94%" Style="text-align: right" Text="Giden UPT İşlem Toplamı"></asp:Label>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout004">
                                        <Body>
                                            <asp:Label ID="LabelLine02" runat="server" Height="22" Width="94%" Style="text-align: right" Text="Giden UPT Masraf Toplamı"></asp:Label>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout005">
                                        <Body>
                                            <asp:Label ID="LabelLine03" runat="server" Height="22" Width="94%" Style="text-align: right" Text="Giden UPT Genel Toplam"></asp:Label>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout006">
                                        <Body>
                                            <asp:Label ID="LabelLine04" runat="server" Height="22" Width="94%" Style="text-align: right" Text="Giden UPT İşlem Adedi"></asp:Label>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout007">
                                        <Body>
                                            <asp:Label ID="LabelLine05" runat="server" Height="22" Width="94%" Style="text-align: right" Text="İptal Giden UPT Toplamı"></asp:Label>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout008">
                                        <Body>
                                            <asp:Label ID="LabelLine06" runat="server" Height="22" Width="94%" Style="text-align: right" Text="İptal Giden UPT Masraf Toplamı"></asp:Label>
                                        </Body>
                                    </rx:RowLayout>

                                    <rx:RowLayout runat="server" ID="RowLayout009">
                                        <Body>
                                            <asp:Label ID="LabelLine07" runat="server" Height="22" Width="94%" Style="text-align: right" Text="İptal Giden UPT Adedi"></asp:Label>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout010">
                                        <Body>
                                            <asp:Label ID="LabelLine08" runat="server" Height="22" Width="94%" Style="text-align: right" Text="BORÇ"></asp:Label>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout runat="server" ID="ColumnLayoutTRY" ColumnWidth="27%" BorderWidth="1" BorderColor="LightSteelBlue">
                                <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout101">
                                        <Body>
                                            <table width="60%" align="center">
                                                <tr align="center">
                                                    <td style="width: 50%">
                                                        <asp:Label ID="LabelDovizCinsi1" runat="server" Text="Döviz Cinsi" Style=""></asp:Label></td>
                                                    <td>
                                                        <asp:TextBox ID="TextBox_DovizCinsi01" runat="server" ReadOnly="true" Height="17" Width="64%" Text="TRY" Style="text-align: center"></asp:TextBox></td>
                                                </tr>
                                            </table>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout102">
                                        <Body>
                                            <table width="100%" height="22">
                                                <tr align="center">
                                                    <td style="width: 50%">
                                                        <asp:Label ID="LabelColumn10" runat="server" Text="PTT Bank" Style="text-align: center"></asp:Label></td>
                                                    <td style="width: 50%">
                                                        <asp:Label ID="LabelColumn11" runat="server" Text="UPT" Style="text-align: center"></asp:Label></td>
                                                </tr>
                                            </table>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout103">
                                        <Body>
                                            <table width="100%" height="22">
                                                <tr align="center">
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_GidUITop0" Text="0.00" runat="server" ReadOnly="true" Width="60%" Style="text-align: right"></asp:TextBox></td>
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_GidUITop1" Text="0.00" runat="server" ReadOnly="true" Width="60%" Style="text-align: right"></asp:TextBox></td>
                                                </tr>
                                            </table>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout105">
                                        <Body>
                                            <table width="100%" height="22">
                                                <tr align="center">
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_GidUMTop0" Text="0.00" runat="server" ReadOnly="true" Width="60%" Style="text-align: right"></asp:TextBox></td>
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_GidUMTop1" Text="0.00" runat="server" ReadOnly="true" Width="60%" Style="text-align: right"></asp:TextBox></td>
                                                </tr>
                                            </table>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout107">
                                        <Body>
                                            <table width="100%" height="22">
                                                <tr align="center">
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_GidUGTop0" Text="0.00" runat="server" ReadOnly="true" Width="60%" Style="text-align: right"></asp:TextBox></td>
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_GidUGTop1" Text="0.00" runat="server" ReadOnly="true" Width="60%" Style="text-align: right"></asp:TextBox></td>
                                                </tr>
                                            </table>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout106">
                                        <Body>
                                            <table width="100%" height="22">
                                                <tr align="center">
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_GidUIAded0" Text="0" runat="server" ReadOnly="true" Width="60%" Style="text-align: left"></asp:TextBox></td>
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_GidUIAded1" Text="0" runat="server" ReadOnly="true" Width="60%" Style="text-align: left"></asp:TextBox></td>
                                                </tr>
                                            </table>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout108">
                                        <Body>
                                            <table width="100%" height="22">
                                                <tr align="center">
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_IpGidUTop0" Text="0.00" runat="server" ReadOnly="true" Width="60%" Style="text-align: right"></asp:TextBox></td>
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_IpGidUTop1" Text="0.00" runat="server" ReadOnly="true" Width="60%" Style="text-align: right"></asp:TextBox></td>
                                                </tr>
                                            </table>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout109">
                                        <Body>
                                            <table width="100%" height="22">
                                                <tr align="center">
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_IpGidUMasTop0" Text="0.00" runat="server" ReadOnly="true" Width="60%" Style="text-align: right"></asp:TextBox></td>
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_IpGidUMasTop1" Text="0.00" runat="server" ReadOnly="true" Width="60%" Style="text-align: right"></asp:TextBox></td>
                                                </tr>
                                            </table>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout110">
                                        <Body>
                                            <table width="100%" height="22">
                                                <tr align="center">
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_IpGidUAded0" Text="0" runat="server" ReadOnly="true" Width="60%" Style="text-align: left"></asp:TextBox></td>
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_IpGidUAded1" Text="0" runat="server" ReadOnly="true" Width="60%" Style="text-align: left"></asp:TextBox></td>
                                                </tr>
                                            </table>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout111">
                                        <Body>
                                            <table width="100%" height="22">
                                                <tr align="center">
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_Borc0" Text="0.00" runat="server" ReadOnly="true" Width="60%" Style="text-align: right"></asp:TextBox></td>
                                                    <td style="width: 50%">
                                                        <asp:TextBox ID="TextBox_Data1_Borc1" Text="0.00" runat="server" ReadOnly="true" Width="60%" Style="text-align: right"></asp:TextBox></td>
                                                </tr>
                                            </table>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                            <%--<rx:ColumnLayout runat="server" ID="ColumnLayoutEUR" ColumnWidth="27%" BorderWidth="1" BorderColor="LightSteelBlue">
                                <Rows>
                                    
                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout runat="server" ID="ColumnLayoutUSD" ColumnWidth="27%" BorderWidth="1" BorderColor="LightSteelBlue">
                                <Rows>
                                    
                                </Rows>
                            </rx:ColumnLayout>--%>
                        </Body>

                    </rx:PanelX>
                    <rx:PanelX ID="pnl2" runat="server" AutoHeight="Auto" AutoWidth="true">
                        <Body>
                            <rx:GridPanel runat="server" ID="GridPanelMonitoring" AutoWidth="true" AutoHeight="Auto"
                                Editable="false" Mode="Remote" AutoLoad="true" Width="1200" AjaxPostable="true">
                                <DataContainer>
                                    <DataSource OnEvent="ToolbarButtonFindClick">
                                    </DataSource>
                                    <Parameters>
                                        <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                                        <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                                    </Parameters>
                                </DataContainer>
                                <SelectionModel>
                                    <rx:RowSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server" ShowNumber="true">
                                        <Listeners>
                                            <RowDblClick Handler="ShowWindowReadOnly(GridPanelMonitoring.id,GridPanelMonitoring.selectedRecord.ID);" />
                                        </Listeners>
                                    </rx:RowSelectionModel>
                                </SelectionModel>
                                <ColumnModel>
                                    <Columns>
                                        <rx:GridColumns Header="Banka işlem no" ColumnId="new_CommissionAmount" DataIndex="new_CommissionAmount"
                                            Align="Right">
                                        </rx:GridColumns>
                                        <rx:GridColumns Header="UPT Döviz Tutarı" ColumnId="1" DataIndex="new_CommissionAmount"
                                            Align="Right">
                                        </rx:GridColumns>
                                        <rx:GridColumns Header="UPT Döviz Kodu" ColumnId="2" DataIndex="new_CommissionAmount"
                                            Align="Right">
                                        </rx:GridColumns>
                                        <rx:GridColumns Header="UPT TL Tutarı" ColumnId="3" DataIndex="new_CommissionAmount"
                                            Align="Right">
                                        </rx:GridColumns>
                                        <rx:GridColumns Header="UPT TL Masraf Tutarı" ColumnId="4" DataIndex="new_CommissionAmount"
                                            Align="Right">
                                        </rx:GridColumns>
                                        <rx:GridColumns Header="PTT İşlem No" ColumnId="5" DataIndex="new_CommissionAmount"
                                            Align="Right">
                                        </rx:GridColumns>
                                        <rx:GridColumns Header="İşlem Tipi " ColumnId="6" DataIndex="new_CommissionAmount"
                                            Align="Right">
                                        </rx:GridColumns>
                                        <rx:GridColumns Header="PTT Döviz Tutarı" ColumnId="7" DataIndex="new_CommissionAmount"
                                            Align="Right">
                                        </rx:GridColumns>
                                        <rx:GridColumns Header="PTT Döviz Kodu" ColumnId="8" DataIndex="new_CommissionAmount"
                                            Align="Right">
                                        </rx:GridColumns>
                                        <rx:GridColumns Header="PTT TL Tutarı" ColumnId="9" DataIndex="new_CommissionAmount"
                                            Align="Right">
                                        </rx:GridColumns>
                                        <rx:GridColumns Header="PTT TL Masraf Tutarı" ColumnId="10" DataIndex="new_CommissionAmount"
                                            Align="Right">
                                        </rx:GridColumns>
                                        <rx:GridColumns Header="UPT Referans" ColumnId="11" DataIndex="new_CommissionAmount"
                                            Align="Right">
                                        </rx:GridColumns>
                                    </Columns>
                                </ColumnModel>
                                <BottomBar>
                                    <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelMonitoring">
                                        <Buttons>
                                            <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload">
                                                <AjaxEvents>
                                                    <Click OnEvent="ToolbarButtonFindClick">
                                                        <EventMask ShowMask="false" />
                                                        <ExtraParams>
                                                            <rx:Parameter Name="Excel" Value="1" Mode="Value" />
                                                        </ExtraParams>
                                                    </Click>
                                                </AjaxEvents>
                                            </rx:SmallButton>
                                        </Buttons>
                                    </rx:PagingToolBar>
                                </BottomBar>
                                <LoadMask ShowMask="true" />
                            </rx:GridPanel>
                        </Body>
                    </rx:PanelX>
                </td>
            </tr>
        </table>



        <rx:Window ID="windowTotal" runat="server" Width="500" Height="200" Modal="true"
            Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false"
            Title="CRM.NEW_PROCESSMONITORING_LIST_TOTAL">
            <Body>
                <rx:GridPanel runat="server" ID="GridPanelTotal" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
                    Height="150" Editable="false" Mode="local" AutoLoad="false" Width="1200" AjaxPostable="true">
                    <SelectionModel>
                        <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true" SingleSelect="true">
                        </rx:RowSelectionModel>
                    </SelectionModel>
                    <LoadMask ShowMask="true" />
                </rx:GridPanel>
            </Body>
        </rx:Window>
    </form>
</body>
</html>
