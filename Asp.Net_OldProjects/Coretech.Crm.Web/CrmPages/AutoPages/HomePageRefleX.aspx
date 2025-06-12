<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_HomePageRefleX" Codebehind="HomePageRefleX.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script src="../../js/DynamicFilter.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <title></title>
    <style>
        .clsFilterAnd {
            color: red;
        }

        .clsFilterObject {
            font-weight: bold;
            color: blue;
        }

        .clsFilterCondition {
            font-weight: bold;
            color: green;
        }

        .clsFilterValue {
            font-weight: bold;
            color: rgb(177, 94, 177);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <ajx:RegisterResources runat="server" ID="RR" />
        <ajx:KeyMap runat="server" ID="KeyMap1">
            <ajx:KeyBinding>
                <Keys>
                    <ajx:Key Code="F9">
                        <Listeners>
                            <Event Handler="GridPanelViewer.reload();" />
                        </Listeners>
                    </ajx:Key>
                    <ajx:Key Code="ENTER">
                        <Listeners>
                            <Event Handler="GridPanelViewer.reload();" />
                        </Listeners>
                    </ajx:Key>
                </Keys>
            </ajx:KeyBinding>
        </ajx:KeyMap>
        <div style="display: none">
            <ajx:Hidden runat="server" ID="hdnObjectId">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnRecid">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnDefaultEditPage">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnViewQueryId">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnSelectedViewQueryId">
            </ajx:Hidden>

        </div>
        <ajx:PanelX runat="server" ID="GridPanelViewerSearch" Height="105" AutoWidth="true"
            Collapsible="true" Collapsed="true" AutoHeight="Normal" BackColor="Silver" Title=""
            AutoScroll="true">
            <Tools>
                <Items>

                    <ajx:ToolButton runat="server" ID="BtnClear" ToolTip="Clear" ToolTypeIcon="Gear">
                        <Listeners>
                            <Click Handler="ClearFilter();" />
                        </Listeners>
                    </ajx:ToolButton>
                    <ajx:ToolButton runat="server" ID="BtnFilterSearch" ToolTip="Search F9" ToolTypeIcon="Refresh">
                        <Listeners>
                            <Click Handler="GridPanelViewer.reload();" />
                        </Listeners>
                    </ajx:ToolButton>
                </Items>
            </Tools>
            <Buttons>
                <ajx:Button ID="_BtnClear" Text="" Icon="Erase" runat="server">
                    <Listeners>
                        <Click Handler="ClearFilter();" />
                    </Listeners>
                </ajx:Button>
                <ajx:Button ID="_BtnFilter" Text="" Icon="Magnifier" runat="server">
                    <Listeners>
                        <Click Handler="GridPanelViewer.reload();" />
                    </Listeners>
                </ajx:Button>
            </Buttons>
            <Body>
            </Body>
        </ajx:PanelX>
        <ajx:GridPanel runat="server" ID="GridPanelViewer" AutoWidth="true" AutoHeight="Auto"
            TrackMouseOver="false" Editable="false" Mode="Remote" AutoLoad="false" AjaxPostable="false">
            <DataContainer>
                <Parameters>
                    <ajx:Parameter Name="start" Value="0" Mode="Value"></ajx:Parameter>
                    <ajx:Parameter Name="limit" Value="CmbPageSize.getValue()" Mode="Raw"></ajx:Parameter>
                    <ajx:Parameter Name="viewqueryid" Value="CmbViewList.getValue()" Mode="Raw"></ajx:Parameter>
                    <ajx:Parameter Name="query" Value="FilterText.getValue()" Mode="Raw"></ajx:Parameter>
                    <ajx:Parameter Name="filterquery" Value="FilterGetQuery()" Mode="Raw"></ajx:Parameter>
                </Parameters>
            </DataContainer>
            <TopBar>
                <ajx:ToolBar runat="server" ID="toolbar1">
                    <Items>
                        <ajx:ToolbarButton ID="btnNew" Icon="Add" Text="New" runat="server">
                            <Listeners>
                                <Click Handler="ShowEditWindow(GridPanelViewer.id,'',hdnDefaultEditPage.getValue(),hdnObjectId.getValue());" />
                            </Listeners>
                        </ajx:ToolbarButton>
                        <ajx:ToolbarButton runat="server" ID="btnExport" Icon="PageWhiteExcel" MenuClickType="Full">
                            <Menu>
                                <ajx:Menu runat="server" ID="mnuExport1">
                                    <Items>
                                        <ajx:MenuItem ID="btnExportCurrentPage" runat="server" Text="Export_to_Excel" Icon="PageWhiteExcel">
                                            <Listeners>
                                                <Click Handler="ExportExcel(0);" />
                                            </Listeners>
                                        </ajx:MenuItem>
                                        <ajx:MenuItem ID="btnExportAllPage" runat="server" Text="Export_To_Excel_(All_Page)"
                                            Icon="PageWhiteExcel">
                                            <Listeners>
                                                <Click Handler="ExportExcel(1);" />
                                            </Listeners>
                                        </ajx:MenuItem>
                                    </Items>
                                </ajx:Menu>
                            </Menu>
                        </ajx:ToolbarButton>
                        <ajx:ToolbarSeparator ID="btnExportSeparator" runat="server" />
                        <ajx:ToolbarButton ID="btnAssign" Icon="PackageGo" Text="Assign" runat="server">
                            <Listeners>
                                <Click Handler="window.top.GlobalAssign(GridPanelViewer,hdnObjectId.getValue());" />
                            </Listeners>
                        </ajx:ToolbarButton>
                        <ajx:ToolbarSeparator ID="btnAssignSeparator" runat="server" />
                        <ajx:ToolbarButton ID="btnDelete" Icon="Delete" Text="Delete" runat="server">
                            <Listeners>
                                <Click Handler="window.top.GlobalDelete(null,GridPanelViewer,hdnObjectId.getValue());" />
                            </Listeners>
                        </ajx:ToolbarButton>
                        <ajx:ToolbarSeparator ID="btnDeleteSeparator" runat="server" />
                        <ajx:TextField ID="FilterText" runat="server" Width="200" EmptyText="Aranacak Kelimeyi Giriniz">
                            <Listeners>
                                <KeyPress Handler="if(e.keyCode == VKeyCode.VK_RETURN){TextField1Search.click()}" />
                            </Listeners>
                        </ajx:TextField>
                        <ajx:ToolbarSeparator ID="ToolbarSeparator1" runat="server" />
                        <ajx:ToolbarButton ID="TextField1Search" runat="server" Icon="Magnifier">
                            <Listeners>
                                <Click Handler="GridPanelViewer.reload();" />
                            </Listeners>
                        </ajx:ToolbarButton>
                        <ajx:ToolbarSeparator ID="ToolbarSeparator3" runat="server" />
                        <ajx:ComboField runat="server" ID="CmbPageSize" Width="50" Editable="false">
                            <Items>
                                <ajx:ListItem Text="25" Value="25" />
                                <ajx:ListItem Text="50" Value="50" />
                                <ajx:ListItem Text="100" Value="100" />
                                <ajx:ListItem Text="250" Value="250" />
                            </Items>
                            <Listeners>
                                <Change Handler="if(R.isEmpty(CmbPageSize.getValue()))CmbPageSize.setValue(50); PagingToolBar1.pageSize=parseInt(CmbPageSize.getValue()); GridPanelViewer.reload()" />
                            </Listeners>
                        </ajx:ComboField>
                        <ajx:ToolbarSeparator ID="ToolbarSeparator4" runat="server" />
                        <ajx:Label ID="Label1" Text="View" runat="server" Width="80" ForeColor="White">
                        </ajx:Label>
                        <ajx:ComboField runat="server" ID="CmbViewList" Width="300" Editable="false" Mode="Local">
                            <AjaxEvents>
                                <Change OnEvent="CmbViewListSelect">
                                    <EventMask ShowMask="true" />
                                </Change>
                            </AjaxEvents>
                        </ajx:ComboField>
                        <ajx:ToolbarFill ID="ToolbarFill1" runat="server"></ajx:ToolbarFill>
                        <ajx:ToolbarButton runat="server" ID="btnImportExcel" Icon="PageExcel" MenuClickType="Full">
                            <Listeners>
                                <Click Handler="ShowExcelImport(GridPanelViewer.id,hdnObjectId.getValue());" />
                            </Listeners>
                        </ajx:ToolbarButton>
                        <ajx:Label ID="lblInfo" runat="server" Icon="Information" Width="20">
                            <Listeners>
                                <Click Handler="ShowPageInfo();" />
                            </Listeners>
                        </ajx:Label>
                    </Items>
                </ajx:ToolBar>
            </TopBar>
            <SelectionModel>
                <ajx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="false">
                    <Listeners>
                        <RowDblClick Handler="hdnRecid.setValue(GridPanelViewer.selectedRecord.ID);ShowEditWindow(GridPanelViewer.id,GridPanelViewer.selectedRecord.ID,hdnDefaultEditPage.getValue(),hdnObjectId.getValue());" />
                    </Listeners>
                </ajx:RowSelectionModel>
            </SelectionModel>
            <BottomBar>
                <ajx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelViewer">
                </ajx:PagingToolBar>
            </BottomBar>
            <LoadMask ShowMask="true" />
        </ajx:GridPanel>
    </form>
</body>
</html>
<script type="text/javascript" language="javascript">

    function showDefaultEditPageByRecId() {
        if (hdnRecid.getValue() != "") {
            ShowEditWindow(GridPanelViewer.id, hdnRecid.getValue(), hdnDefaultEditPage.getValue(), hdnObjectId.getValue())
        }
    }

</script>