<%@ Page Language="C#" AutoEventWireup="true" Inherits="DayOff_DayOff" Async="true" Codebehind="DayOff.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title></title>
</head>
<body>
    <rx:RegisterResources runat="server" ID="RR" />
    <form id="form1" runat="server">
        <div>
            <table style="width: 100%">
                <tr>
                    <td>
                        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="80" AutoWidth="true"
                            Border="true" Frame="true" Title="Gün Sonu Muhasebe İşlemleri">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="30%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout1" runat="server">
                                            <Body>
                                                <rx:DateField ID="DayOffStartDate" runat="server" FieldLabel="Başlangıç Tarihi"></rx:DateField>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="30%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout2" runat="server">
                                            <Body>
                                                <rx:DateField ID="DayOffEndDate" runat="server" FieldLabel="Bitiş Tarihi"></rx:DateField>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="14%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout3">
                                            <Body>
                                                <rx:Button ID="btnList" runat="server" Text="Gün Sonu Listesi" Icon="Find">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnDayOffList_Click"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                                                                                <rx:Button ID="BtnDataExcel" runat="server" Text="Excel'e Al" Icon="PageExcel" Download="true">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnDayOffExcelExport_Click"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColoumnLayout4" ColumnWidth="14%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout4">
                                            <Body>
                                                <rx:Button ID="BtnDataCreate" runat="server" Text="Gün Sonu Oluştur" Icon="DatabaseAdd">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnDayOffDataCreate_Click"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                                                                                <rx:Button ID="BtnReSendData" runat="server" Text="Gün Sonunu Tekrar Aktar" Icon="Reload">
                                                    <AjaxEvents>
                                                        <Click Before="return confirm('Belirtilen tarihlerdeki gün sonu, tekrar aktarılacaktır. Tekrar aktarımı onaylıyor musunuz?')" OnEvent="BtnReSendData_Click"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="10%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout5">
                                            <Body>
                                                <rx:Button ID="BtnValidReport" runat="server" Text="Verileri Sına" Icon="Report">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnValidReport_Click"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                                                                                <rx:Button ID="BtnDayOffClose" runat="server" Text="Gün Sonu Kapat" Icon="BinClosed">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnDayOffClose_Click"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>


                              
                            </Body>
                        </rx:PanelX>
                    </td>
                </tr>
            </table>
            <rx:PanelX ID="Pnl1" runat="server">
                <Body>
                    <rx:GridPanel runat="server" ID="GridPanelMainAccount" AutoWidth="true" Editable="false" Mode="Remote" AutoLoad="false" AjaxPostable="true">
                        <TopBar>
                            <rx:ToolBar ID="toolBar1" runat="server" ContainerPadding="true">
                                <Items>
                                </Items>
                            </rx:ToolBar>
                        </TopBar>
                        <DataContainer>
                            <DataSource OnEvent="GridPanelMainAccountOnEvent">
                            </DataSource>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="TARİH" ColumnId="0" DataIndex="TransactionDate" Width="100"></rx:GridColumns>
                                <rx:GridColumns Header="DURUM" ColumnId="1" DataIndex="Status" Width="350"></rx:GridColumns>
                                <rx:GridColumns Header="SAYI" ColumnId="2" DataIndex="LineCount" Width="100"></rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                    </rx:GridPanel>
                </Body>
            </rx:PanelX>
        </div>
        <div>
            <rx:Window ID="windowReport" runat="server" Width="800" Height="600" Modal="true"
                CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="true" Resizable="false"
                CloseAction="Hide" ShowOnLoad="false">
                <Body>
                    <p>Toplamlar</p>
                    <rx:GridPanel runat="server" ID="DayoffValidateReportGrid" AutoHeight="Normal" Height="150" Editable="false" Mode="Remote" AutoLoad="false" 
                        AjaxPostable="true">
                        <DataContainer>
                            <DataSource OnEvent="DayoffValidateReportGridOnLoad">
                            </DataSource>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="DOVIZ TIPI" ColumnId="0" DataIndex="DOVIZ_TIPI" Width="70"></rx:GridColumns>
                                <rx:GridColumns Header="DEGISIM TUTARI - ON MUHASEBE" ColumnId="1" DataIndex="DEGISIM_TUTARI_ON_MUHASEBE" Align="Right" Width="200"></rx:GridColumns>
                                <rx:GridColumns Header="DEGISIM TUTARI - GUN SONU" ColumnId="2" DataIndex="DEGISIM_TUTARI_GUN_SONU" Align="Right" Width="200"></rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                    </rx:GridPanel>
                    <p>Gün Sonu Sorunlu İşlemler</p>
                    <rx:GridPanel runat="server" ID="DayoffValidateReportGrid2" AutoWidth="true" Editable="false" Mode="Remote" AutoLoad="false" AjaxPostable="true">
                        <TopBar>
                            <rx:ToolBar ID="toolBar2" runat="server" ContainerPadding="true">
                                <Items>
                                </Items>
                            </rx:ToolBar>
                        </TopBar>
                        <DataContainer>
                            <DataSource OnEvent="DayoffValidateReportGrid2OnLoad">
                            </DataSource>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="ISLEM NO" ColumnId="0" DataIndex="ISLEM_NO" Width="120"></rx:GridColumns>
                                <rx:GridColumns Header="DOVIZ TIPI" ColumnId="1" DataIndex="DOVIZ_TIPI" Align="Right" Width="70"></rx:GridColumns>
                                <rx:GridColumns Header="ACIKLAMA" ColumnId="2" DataIndex="ACIKLAMA" Align="Right" Width="400"></rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel4" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                    </rx:GridPanel>
                </Body>
            </rx:Window>
        </div>
    </form>
</body>
</html>
