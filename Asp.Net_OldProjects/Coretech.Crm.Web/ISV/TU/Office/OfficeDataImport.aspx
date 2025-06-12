<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OfficeDataImport.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Office.OfficeDataImport" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        function imgRenderer(record, rowIndex, colIndex, store) {
            if (record == 0) {
                return "<img style='width:16px;height:16px;' src='../../../images/OfficeDataImport/1494503953_icon-man.png' />";
            }
            else if (record == 1) {
                return "<img style='width:16px;height:16px;' src='../../../images/OfficeDataImport/1494503307_user_run.png' />";
            }
            else (record == 2)
            {
                return "<img style='width:16px;height:16px;' src='../../../images/OfficeDataImport/1494502879_finish_flag.png' />";
            }
        }

        function imgRendererDetail(record, rowIndex, colIndex, store) {
            if (record == 0) {
                return "<img style='width:16px;height:16px;' src='../../../images/1495118945_error.png' />";
            }
            else if (record == 1) {
                return "<img style='width:16px;height:16px;' src='../../../images/1495118987_OK.png' />";
            }
        }

        function ShowOfficeDataImportTask() {
            var config = GetWebAppRoot + "/ISV/TU/Office/OfficeDataImportTask.aspx";
            window.top.newWindowRefleX(config, {
                width: 500, height: 275, resizable: true, modal: true, maximizable: true, listeners:
                       {
                           close: function (el, e) {
                               gpOfficeData.reload();

                               return true;
                           }
                       }
            });
        }

        function filter() {
            try {
                windowNewFilter.hide();
                gpOfficeData.reload();
            }
            catch (err) {

            }
        }

        function componentClear() {
            txtSearch.clear();
            txtStartDate.clear();
            txtEndDate.clear();
        }
    </script>
</head>
<body>
    <rx:RegisterResources runat="server" ID="RR" />
    <form id="form1" runat="server">
        <div>
            <rx:KeyMap runat="server" ID="KeyMap1">
                <rx:KeyBinding>
                    <Keys>
                        <rx:Key Code="F9">
                            <Listeners>
                                <Event Handler="filter();" />
                            </Listeners>
                        </rx:Key>
                    </Keys>
                </rx:KeyBinding>
            </rx:KeyMap>
            <rx:KeyMap runat="server" ID="KeyMap2">
                <rx:KeyBinding>
                    <Keys>
                        <rx:Key Code="F8">
                            <Listeners>
                                <Event Handler="windowNewFilter.show();" />
                            </Listeners>
                        </rx:Key>
                    </Keys>
                </rx:KeyBinding>
            </rx:KeyMap>
            <rx:Hidden ID="hdnSelectedId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnFilePath" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusCode" runat="server"></rx:Hidden>
            <rx:PanelX ID="wrapper" runat="server" Border="false">
                <Body>
                    <rx:GridPanel runat="server" ID="gpOfficeData" AutoWidth="true" AutoHeight="Normal" AutoScroll="true"
                        Height="250" AutoLoad="true" Mode="Remote">
                        <DataContainer>
                            <DataSource OnEvent="GetData">
                            </DataSource>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns ColumnId="ID" Width="100" Header="Aktarım No" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="ID" />
                                <rx:GridColumns ColumnId="HEADER" Width="150" Header="Açıklama" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="HEADER" />
                                <rx:GridColumns ColumnId="FILENAME" Width="250" Header="Dosya Adı" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="FILENAME" />
                                <rx:GridColumns ColumnId="PATH" Width="450" Header="Dosya Yolu" Sortable="false"
                                    MenuDisabled="true" Hidden="true" DataIndex="PATH">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="UserName" Width="200" Header="İşlem Sahibi" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="UserName" />
                                <rx:GridColumns ColumnId="STARTDATE" Width="120" Header="Başlama Tarihi" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="STARTDATE" />
                                <rx:GridColumns ColumnId="ENDDATE" Width="120" Header="Bitiş Tarihi" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="ENDDATE" />
<%--                                <rx:GridColumns ColumnId="INTERVAL" Width="50" Header="Süre" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="INTERVAL" />--%>
                                <rx:GridColumns ColumnId="STATUS" Width="115" Header="Aktarım Durumu" Sortable="false" Align="Left"
                                    MenuDisabled="true" Hidden="false" DataIndex="STATUS">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="STATUSCODE" Width="15" Header="||||||" Sortable="false" Align="Center"
                                    MenuDisabled="true" Hidden="false" DataIndex="STATUSCODE">
                                    <Renderer Handler="return imgRenderer(record.data.STATUSCODE);" />
                                </rx:GridColumns>
                            </Columns>
                        </ColumnModel>

                        <SelectionModel>
                            <rx:RowSelectionModel ID="GridPanelPaymentsRowSelectionModel1" runat="server" ShowNumber="true">
                                <Listeners>
                                    <RowClick Handler="hdnSelectedId.clear();hdnSelectedId.setValue(gpOfficeData.selectedRecord.ID);
                                        hdnFilePath.clear();hdnFilePath.setValue(gpOfficeData.selectedRecord.PATH);
                                        hdnStatusCode.clear();hdnStatusCode.setValue(gpOfficeData.selectedRecord.STATUSCODE);"></RowClick>
                                </Listeners>
                                <AjaxEvents>
                                    <RowDblClick OnEvent="GetDataDetail">
                                    </RowDblClick>
                                </AjaxEvents>
                            </rx:RowSelectionModel>
                        </SelectionModel>
                        <BottomBar>
                            <rx:PagingToolBar ID="pagingToolBar" runat="server" ControlId="gpOfficeData">
                            </rx:PagingToolBar>
                        </BottomBar>
                        <TopBar>
                            <rx:ToolBar ID="toolBar1" runat="server">
                                <Items>
                                    <rx:Label ID="label1" runat="server" ImageUrl="../../../images/database-export.png" ImageHeight="36" ImageWidth="36" Width="40">
                                    </rx:Label>
                                    <rx:ToolbarSeparator ID="ToolbarSeparator7" runat="server"></rx:ToolbarSeparator>
                                    <rx:ToolbarButton ID="ToolbarButton4" runat="server" Icon="TimeGo" Text="<b>Aktarımı Manuel Başlat</b>">
                                        <AjaxEvents>
                                            <Click OnEvent="ImportManuelStart"></Click>
                                        </AjaxEvents>
                                    </rx:ToolbarButton>
                                    <rx:ToolbarButton ID="btnNew" runat="server" Icon="Add" Text="<b>Yeni Aktarım Oluştur</b>">
                                        <Listeners>
                                            <Click Handler="ShowOfficeDataImportTask();" />
                                        </Listeners>
                                    </rx:ToolbarButton>
                                    <rx:ToolbarButton ID="btnDelete" runat="server" Icon="Delete" Text="<b>Sil</b>">
                                    </rx:ToolbarButton>
                                    <rx:ToolbarSeparator ID="separator1" runat="server"></rx:ToolbarSeparator>
                                    <rx:ToolbarButton ID="btnRefresh" runat="server" Icon="ArrowRefresh" Text="<b>Yenile</b>">
                                        <Listeners>
                                            <Click Handler="gpOfficeData.reload();" />
                                        </Listeners>
                                    </rx:ToolbarButton>
                                    <rx:ToolbarSeparator ID="ToolbarSeparator2" runat="server"></rx:ToolbarSeparator>
                                    <rx:ToolbarButton ID="ToolbarButton1" runat="server" Icon="Zoom" Text="<b>Filtre İşlemleri {F8}</b>">
                                        <Listeners>
                                            <Click Handler="windowNewFilter.show();" />
                                        </Listeners>
                                    </rx:ToolbarButton>
                                    <rx:ToolbarButton ID="ToolbarButton2" runat="server" Icon="Reload" Text="<b>Filtreyi Geri Al</b>">
                                        <Listeners>
                                            <Click Handler="componentClear();gpOfficeData.reload();" />
                                        </Listeners>
                                    </rx:ToolbarButton>
                                    <rx:ToolbarButton ID="ToolbarButton3" runat="server" Icon="DiskDownload" Text="<b>Dosya Indir</b>" Download="true">
                                        <AjaxEvents>
                                            <Click OnEvent="FileDownload"></Click>
                                        </AjaxEvents>
                                    </rx:ToolbarButton>
                                </Items>
                            </rx:ToolBar>
                        </TopBar>
                    </rx:GridPanel>
                    <rx:GridPanel runat="server" ID="gpOfficeDataImportDetail" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
                        Height="150" AutoLoad="false" Mode="Remote">
                        <DataContainer>
                            <DataSource OnEvent="GetDataDetail">
                            </DataSource>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns ColumnId="STATUSCODE" Width="15" Header="Durum" Sortable="false" Align="Center"
                                    MenuDisabled="true" Hidden="false" DataIndex="STATUS">
                                    <Renderer Handler="return imgRendererDetail(record.data.STATUS);" />
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="ENTITYNAME" Width="15" Header="Kategori" Sortable="false" Align="Left"
                                    MenuDisabled="true" Hidden="false" DataIndex="ENTITYNAME">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="CREATEDON" Width="125" Header="İşlem Tarihi" Sortable="false" Align="Left"
                                    MenuDisabled="true" Hidden="false" DataIndex="CREATEDON">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="HEADER" Width="500" Header="Data" Sortable="false" Align="Left"
                                    MenuDisabled="true" Hidden="false" DataIndex="HEADER">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="CONTENT" Width="500" Header="Data" Sortable="false" Align="Left"
                                    MenuDisabled="true" Hidden="true" DataIndex="CONTENT">
                                </rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SpecialSettings>
                            <rx:RowExpander Template="<br/><br/><span style='color:red'>{CONTENT}</span>"
                                Collapsed="true" />
                        </SpecialSettings>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true" SingleSelect="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                        <BottomBar>
                            <rx:PagingToolBar ID="pagingToolBar1" runat="server" ControlId="gpOfficeDataImportDetail">
                            </rx:PagingToolBar>
                        </BottomBar>
                        <TopBar>
                            <rx:ToolBar ID="toolBar3" runat="server">
                                <Items>
                                    <rx:Label ID="label3" runat="server" ImageUrl="../images/1495116719_stock_view-details.png" ImageHeight="36" ImageWidth="36" Width="40">
                                    </rx:Label>
                                    <rx:ToolbarSeparator ID="ToolbarSeparator1" runat="server"></rx:ToolbarSeparator>
                                    <rx:Label ID="lblInfo" runat="server" Text="<b>İşlem Detaylarını aşağıdaki tabloadan görebilirsiniz</b>" ForeColor="White"></rx:Label>
                                </Items>
                            </rx:ToolBar>
                        </TopBar>
                    </rx:GridPanel>
                </Body>

            </rx:PanelX>

            <rx:Window ID="windowNewFilter" runat="server" Width="400" Height="190" Modal="true"
                CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
                CloseAction="Hide" ShowOnLoad="false" Border="false"
                Title="&nbsp;&nbsp;Filtre İşlemleri">
                <Body>

                    <rx:Label ID="label2" runat="server" ImageUrl="../../../images/filter.png" ImageHeight="24" ImageWidth="24" Width="40" Text="<b>Filtre İşlemleri</b>">
                    </rx:Label>
                    <rx:ColumnLayout ID="col1" runat="server" ColumnWidth="100%">
                        <Rows>
                            <rx:RowLayout ID="row1" runat="server">
                                <Body>
                                    <rx:TextField ID="txtSearch" runat="server" FieldLabel="Aktarım No"></rx:TextField>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout ID="ColumnLayout1" runat="server" ColumnWidth="100%">
                        <Rows>
                            <rx:RowLayout ID="RowLayout1" runat="server">
                                <Body>
                                    <rx:DateField ID="txtStartDate" runat="server" FieldLabel="Başlangıç Tarihi"></rx:DateField>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout ID="ColumnLayout2" runat="server" ColumnWidth="100%">
                        <Rows>
                            <rx:RowLayout ID="RowLayout2" runat="server">
                                <Body>
                                    <rx:DateField ID="txtEndDate" runat="server" FieldLabel="Bitiş Tarihi"></rx:DateField>
                                    <br />
                                    <br />
                                    <br />
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ToolBar ID="toolBar2" runat="server">
                        <Items>
                            <rx:ToolbarFill ID="toolBarFill1" runat="server"></rx:ToolbarFill>
                            <rx:Button ID="btn1" runat="server" Text="Bul {F9}" Icon="Magnifier">
                                <Listeners>
                                    <Click Handler="windowNewFilter.hide();gpOfficeData.reload();" />
                                </Listeners>
                            </rx:Button>
                        </Items>
                    </rx:ToolBar>
                </Body>
            </rx:Window>
        </div>
    </form>
</body>
</html>
