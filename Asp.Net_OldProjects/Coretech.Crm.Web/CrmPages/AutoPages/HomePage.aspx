<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_HomePage" Codebehind="HomePage.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<%@ Register Assembly="Coretech.Crm.Web.UI" Namespace="Coretech.Crm.Web.UI.ExtPlugin"
    TagPrefix="plg" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork"
    TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .x-grid3-cell-inner a
        {
            color: Black;
            text-decoration: none;
        }
        .x-grid3-cell-inner a:hover
        {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR"/>
    <div style="display: none">
        <ext:Hidden runat="server" ID="hdnObjectId">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnRecid">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnDefaultEditPage">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnViewQueryId">
        </ext:Hidden>
    </div>
    <div>
        <ext:Store ID="StoreViewer" runat="server" RemoteSort="true" AutoLoad="false">
            <Reader>
                <ext:JsonReader ReaderID="ID" Root="Records" TotalProperty="totalCount">
                    <Fields>
                    </Fields>
                </ext:JsonReader>
            </Reader>
            <Proxy>
            </Proxy>
            <BaseParams>
                <ext:Parameter Name="start" Value="0" Mode="Raw">
                </ext:Parameter>
                <ext:Parameter Name="limit" Value="#{CmbPageSize}.getValue()" Mode="Raw">
                </ext:Parameter>
                <ext:Parameter Name="viewqueryid" Value="#{CmbViewList}.getValue()" Mode="Raw">
                </ext:Parameter>
                <ext:Parameter Name="query" Value="#{FilterText}.getValue()" Mode="Raw">
                </ext:Parameter>
            </BaseParams>
            <Listeners>
                <Load Handler="SetGridElapsedTime(store.reader.jsonData.elapsedtime);" />
            </Listeners>
        </ext:Store>
        <ext:Menu runat="server" ID="mnuExport">
            <Items>
                <ext:MenuItem runat="server" ID="mnuExportExcel" Text="Export_to_Excel" Icon="PageWhiteExcel">
                    <Listeners>
                        <Click Handler="ExportExcel(0);" />
                    </Listeners>
                </ext:MenuItem>
                <ext:MenuItem runat="server" ID="mnuExportExcelAll" Text="Export_To_Excel_(All_Page)"
                    Icon="PageWhiteExcel">
                    <Listeners>
                        <Click Handler="ExportExcel(1);" />
                    </Listeners>
                </ext:MenuItem>
                <ext:MenuItem runat="server" ID="mnuAssign" Text="AssingTo" Icon="Attach">
                    <Listeners>
                        <Click Handler="window.top.GlobalAssign(#{GridPanelViewer},#{hdnObjectId}.getValue());" />
                    </Listeners>
                </ext:MenuItem>
            </Items>
        </ext:Menu>
        <ext:ViewPort ID="ViewPort1" runat="server">
            <Body>
                <ext:FitLayout ID="FitLayout1" runat="server">
                    <Items>
                        <ext:GridPanel ID="GridPanelViewer" runat="server" StoreID="StoreViewer" TrackMouseOver="true"
                            ContextMenuID="mnuExport">
                            <TopBar>
                                <ext:Toolbar ID="Toolbar1" runat="server">
                                    <Items>
                                        <ext:Button ID="BtnNew" Icon="Add" Text="New" runat="server">
                                            <Listeners>
                                                <Click Handler="ShowEditWindow(#{GridPanelViewer}.id,'',#{hdnDefaultEditPage}.getValue(),#{hdnObjectId}.getValue());" />
                                            </Listeners>
                                        </ext:Button>
                                        <ext:Button runat="server" ID="btnExport" Icon="PageWhiteExcel">
                                            <Menu>
                                                <ext:Menu runat="server" ID="mnuExport1">
                                                    <Items>
                                                        <ext:MenuItem ID="MenuItem1" runat="server" Text="Export_to_Excel" Icon="PageWhiteExcel">
                                                            <Listeners>
                                                                <Click Handler="ExportExcel(0);" />
                                                            </Listeners>
                                                        </ext:MenuItem>
                                                        <ext:MenuItem ID="MenuItem2" runat="server" Text="Export_To_Excel_(All_Page)" Icon="PageWhiteExcel">
                                                            <Listeners>
                                                                <Click Handler="ExportExcel(1);" />
                                                            </Listeners>
                                                        </ext:MenuItem>
                                                    </Items>
                                                </ext:Menu>
                                            </Menu>
                                        </ext:Button>
                                        <ext:ToolbarSeparator>
                                        </ext:ToolbarSeparator>
                                        <ext:Button ID="BtnDelete" Icon="Delete" Text="Delete" runat="server">
                                            <Listeners>
                                                <Click Handler="window.top.GlobalDelete(null,#{GridPanelViewer},#{hdnObjectId}.getValue());" />
                                            </Listeners>
                                        </ext:Button>
                                        <ext:ToolbarSeparator />
                                        <ext:TriggerField EnableKeyEvents="true" ID="FilterText" runat="server" Width="300"
                                            EmptyText="Aranacak Kelimeyi Giriniz">
                                            <Triggers>
                                                <ext:FieldTrigger Icon="Search" />
                                            </Triggers>
                                            <Listeners>
                                                <KeyPress Handler="if(e.getKey()==Ext.EventObject.ENTER){#{StoreViewer}.load()}" />
                                                <TriggerClick Handler="#{StoreViewer}.load()" />
                                            </Listeners>
                                        </ext:TriggerField>
                                        <ext:ToolbarFill />
                                        <ext:ToolbarSeparator>
                                        </ext:ToolbarSeparator>
                                        <ext:ComboBox ID="CmbPageSize" runat="server" SelectedIndex="1" Width="100" Editable="false">
                                            <Items>
                                                <ext:ListItem Text="25" Value="25" />
                                                <ext:ListItem Text="50" Value="50" />
                                                <ext:ListItem Text="100" Value="100" />
                                                <ext:ListItem Text="250" Value="250" />
                                            </Items>
                                            <Listeners>
                                                <Select Handler="#{PagingToolBar1}.pageSize=parseInt(#{CmbPageSize}.getValue()); #{StoreViewer}.load()" />
                                            </Listeners>
                                        </ext:ComboBox>
                                        <ext:ToolbarSeparator>
                                        </ext:ToolbarSeparator>
                                        <ext:Label ID="Label1" Text="Ön Görüntü" runat="server" Width="1000">
                                        </ext:Label>
                                        <ext:ComboBox ID="CmbViewList" runat="server" Width="300" Editable="false">
                                            <AjaxEvents>
                                                <Select OnEvent="CmbViewList_Select">
                                                    <EventMask ShowMask="true" />
                                                </Select>
                                            </AjaxEvents>
                                        </ext:ComboBox>
                                        <ext:ToolbarSeparator>
                                        </ext:ToolbarSeparator>
                                    </Items>
                                </ext:Toolbar>
                            </TopBar>
                            <ColumnModel ID="ColumnModelViewer" runat="server">
                                <Columns>
                                    <ext:ImageCommandColumn ColumnID="Image1" DataIndex="ImageHref" Width="20" Sortable="false"
                                        MenuDisabled="true">
                                    </ext:ImageCommandColumn>
                                </Columns>
                            </ColumnModel>
                            <Plugins>
                                <plg:GridSearch runat="server" SearchText="Ara" Width="200" ID="gridsearch">
                                </plg:GridSearch>
                            </Plugins>
                            <Listeners>
                                <CellDblClick Handler="ShowEditWindow(#{GridPanelViewer}.id,this.getRowsValues()[0].ID,#{hdnDefaultEditPage}.getValue(),#{hdnObjectId}.getValue());" />
                            </Listeners>
                            <SelectionModel>
                                <ext:RowSelectionModel ID="RowSelectionModel1" runat="server">
                                    <Listeners>
                                        <RowSelect Handler="hdnRecid.setValue(record.data.ID);" />
                                    </Listeners>
                                </ext:RowSelectionModel>
                            </SelectionModel>
                            <BottomBar>
                                <ext:PagingToolbar ID="PagingToolBar1" runat="server" DisplayInfo="true" StoreID="StoreViewer"
                                    PageSize="50">
                                    <Items>
                                        <ext:ToolbarSpacer />
                                        <ext:Label runat="server" ID="ElapsedTime" StyleSpec="color:white" />
                                    </Items>
                                </ext:PagingToolbar>
                            </BottomBar>
                            <LoadMask ShowMask="true" />
                        </ext:GridPanel>
                    </Items>
                </ext:FitLayout>
            </Body>
        </ext:ViewPort>
    </div>
    </form>
</body>
</html>
<script src="../../js/MultiSortGrid.js" type="text/javascript"></script>
