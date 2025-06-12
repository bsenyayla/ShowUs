<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_DashboardList" Codebehind="DashboardList.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork"
    TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style>        
        #toolbar1 {width:100%!important;}
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR"/>
    <ajx:Hidden runat="server" ID="hdnObjectId">
    </ajx:Hidden>
    <ajx:Hidden runat="server" ID="hdnViewQueryId">
    </ajx:Hidden>
    <ajx:Hidden runat="server" ID="hdnDefaultEditPage">
    </ajx:Hidden>
    <ajx:Hidden runat="server" ID="hdnRecid">
    </ajx:Hidden>
    <ajx:GridPanel runat="server" ID="GridPanelViewer" AutoWidth="true" AutoHeight="Auto"
        Mode="Remote" AutoLoad="false">
        <TopBar>
            <ajx:ToolBar runat="server" ID="toolbar1">
                <Items>
                    <ajx:ToolbarButton ID="btnNew" Icon="Add" Text="New" runat="server">
                        <Listeners>
                            <Click Handler="ShowEditWindow(GridPanelViewer.id,'',hdnDefaultEditPage.getValue(),hdnObjectId.getValue());" />
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="btnExport" Icon="PageWhiteExcel">
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
                </Items>
            </ajx:ToolBar>
        </TopBar>
        <DataContainer>
            <DataSource DataUrl="../../Data/jsonCreater.ashx">
            </DataSource>
            <Parameters>
                <ajx:Parameter Mode="Value" Name="start" Value="0" />
                <ajx:Parameter Mode="Value" Name="limit" Value="25" />
                <ajx:Parameter Mode="Raw" Name="viewqueryid" Value="hdnViewQueryId.getValue();" />
            </Parameters>
        </DataContainer>
        <SelectionModel>
            <ajx:RowSelectionModel runat="server" >
                <Listeners>
                    <RowDblClick Handler="hdnRecid.setValue(GridPanelViewer.selectedRecord.ID);ShowEditWindow(GridPanelViewer.id,GridPanelViewer.selectedRecord.ID,hdnDefaultEditPage.getValue(),hdnObjectId.getValue());" />
                </Listeners>
            </ajx:RowSelectionModel>
        </SelectionModel>
        <LoadMask ShowMask="true" />
        <BottomBar>
            <ajx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelViewer">
            </ajx:PagingToolBar>
        </BottomBar>
    </ajx:GridPanel>
    </form>
</body>
</html>
