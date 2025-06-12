<%@ Page Language="C#" AutoEventWireup="true" Inherits="Refund_NKolay_refundmonitor" Codebehind="RefundMonitor.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
        <script type="text/javascript">
            function DataRender() {
                for (var i = 0; i < GridPanelEftMonitor.data.Records.length; i++) {
                    if (GridPanelEftMonitor.data.Records[i].DURUM_KODUID == 9) {
                        $("trtblrow" + (i) + "GridPanelEftMonitor").style.backgroundColor = "#FFFFFF ";
                    }
                    else if (GridPanelEftMonitor.data.Records[i].DURUM_KODUID == 6) {
                        $("trtblrow" + (i) + "GridPanelEftMonitor").style.backgroundColor = "#EDBA34";
                    }
                    else {
                        $("trtblrow" + (i) + "GridPanelEftMonitor").style.backgroundColor = "#BBFFBB"
                    }
                }
            }
    </script>
</head>
<body>
    <rx:RegisterResources runat="server" ID="RR" />
    <form id="form1" runat="server">
        <div>
            <table style="width: 100%">
                <tr>
                    <td></td>
                </tr>
                <tr>
                    <td>
                        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="40" AutoWidth="true"
                            Border="true" Frame="true" Title="Filtreler">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="30%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout1" runat="server">
                                            <Body>
                                                <rx:DateField ID="StartDate" runat="server" FieldLabel="Başlangıç Tarihi"></rx:DateField>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="30%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout2" runat="server">
                                            <Body>
                                                <rx:DateField ID="EndDate" runat="server" FieldLabel="Bitiş Tarihi"></rx:DateField>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="30%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout4" runat="server">
                                            <Body>
                                                <rx:TextField ID="KrediBasvuruNo" runat="server" FieldLabel="Kredi Başvuru No"></rx:TextField>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColoumnLayout2" ColumnWidth="10%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout3">
                                            <Body>
                                                <rx:Button ID="BtnDataCreate" runat="server" Text="Hareketleri Görüntüle" Icon="DatabaseAdd">
                                                    <Listeners>
                                                        <Click Handler="GridPanelEftMonitor.reload();" />
                                                    </Listeners>
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
                    <rx:GridPanel runat="server" ID="GridPanelEftMonitor" AutoWidth="true" Editable="false" Mode="Remote" AutoLoad="false" AjaxPostable="true" Title="Detaylar">
                        <TopBar>
                            <rx:ToolBar ID="toolBar1" runat="server" ContainerPadding="true">
                                <Items>
                                </Items>
                            </rx:ToolBar>
                        </TopBar>
                        <DataContainer>
                            <DataSource OnEvent="GridPanelEftMonitorOnEvent">
                            </DataSource>
                        </DataContainer>
                        <Listeners>
                            <LoadComplete Handler="DataRender();" />
                        </Listeners>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="ID" ColumnId="0" DataIndex="ID" Align="Right" Width="100" Hidden="true"></rx:GridColumns>
                                <rx:GridColumns Header="KREDI BASVURU NO" ColumnId="1" DataIndex="KREDI_BASVURU_NO" Width="150"></rx:GridColumns>
                                <rx:GridColumns Header="ACIKLAMA" ColumnId="2" DataIndex="ACIKLAMA" Width="300"></rx:GridColumns>
                                <rx:GridColumns Header="DURUM KODU" ColumnId="3" DataIndex="DURUM_KODU" Width="100"></rx:GridColumns>
                                <rx:GridColumns Header="UPT DURUM KODU" ColumnId="4" DataIndex="UPT_DURUM_KODU" Width="150"></rx:GridColumns>
                                <rx:GridColumns Header="KAYIT TARIHI" ColumnId="5" DataIndex="OLUSTURMA_TARIHI" Width="150"></rx:GridColumns>
                                <rx:GridColumns Header="GUNCELLEME TARIHI" ColumnId="6" DataIndex="MODIFIEDON" Width="150"></rx:GridColumns>
                                <rx:GridColumns Header="CAGRI ADEDI" ColumnId="3" DataIndex="CAGRI_ADEDI" Width="100"></rx:GridColumns>
                                <rx:GridColumns Header="DURUM_KODUID" ColumnId="3" DataIndex="DURUM_KODUID" Width="100" Hidden="true"></rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                        <BottomBar>
                            <rx:PagingToolBar ID="ptb" runat="server" ControlId="GridPanelEftMonitor">
                            </rx:PagingToolBar>
                        </BottomBar>
                    </rx:GridPanel>
                </Body>
            </rx:PanelX>


        </div>
    </form>
</body>
</html>
