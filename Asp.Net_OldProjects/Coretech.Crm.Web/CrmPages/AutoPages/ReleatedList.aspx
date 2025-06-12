<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_ReleatedList"
    ValidateRequest="false" Codebehind="ReleatedList.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
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
    <div>
        <ext:Store ID="StoreViewer" runat="server" AutoLoad="false" RemoteSort="true">
            <Reader>
                <ext:JsonReader ReaderID="RowNum" Root="Records" TotalProperty="totalCount">
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
                <ext:Parameter Name="viewqueryid" Value="#{ViewQuery}.getValue()" Mode="Raw">
                </ext:Parameter>
                <ext:Parameter Name="query" Value="#{FilterText}.getValue()" Mode="Raw">
                </ext:Parameter>
                <ext:Parameter Name="feachxml" Value="#{FetchXML}.getValue()" Mode="Raw">
                </ext:Parameter>
               
            </BaseParams>
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
        <ext:Hidden ID="ViewQuery" runat="server">
        </ext:Hidden>
        <ext:Hidden ID="FetchXML" runat="server">
        </ext:Hidden>
        <ext:Hidden ID="MapXML" runat="server">
        </ext:Hidden>
        <ext:Hidden ID="hdnDefaultEditPage" runat="server">
        </ext:Hidden>
        <ext:Hidden ID="hdnObjectId" runat="server">
        </ext:Hidden>
        
    </div>
    <ext:ViewPort ID="ViewPort1" runat="server">
        <Body>
            <ext:FitLayout ID="FitLayout1" runat="server">
                <Items>
                    <ext:GridPanel ID="GridPanelViewer" runat="server" StoreID="StoreViewer" TrackMouseOver="false" ContextMenuID="mnuExport">
                        <TopBar>
                            <ext:Toolbar ID="Toolbar1" runat="server">
                                <Items>
                                    <ext:Button ID="BtnNew" Icon="Add" Text="New" runat="server">
                                        <Listeners>
                                            <Click Handler="ShowEditTab(#{GridPanelViewer}.id,'',#{hdnDefaultEditPage}.getValue(),#{hdnObjectId}.getValue(), GetMapXMLValue(#{MapXML}.getValue()) );" />
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
                                    <ext:TriggerField ID="FilterText" EnableKeyEvents="true" runat="server" Width="200"
                                        EmptyText="Aranacak Kelimeyi Giriniz">
                                        <Triggers>
                                            <ext:FieldTrigger Icon="Search" />
                                        </Triggers>
                                        <Listeners>
                                            <KeyPress Handler="if(e.getKey()==Ext.EventObject.ENTER){#{StoreViewer}.load()}" />
                                            <TriggerClick Handler="#{StoreViewer}.load()" />
                                        </Listeners>
                                    </ext:TriggerField>
                                    <ext:Button ID="BtnDelete" Icon="Delete" Text="Delete" runat="server">
                                            <Listeners>
                                                <Click Handler="window.top.GlobalDelete(null,#{GridPanelViewer},#{hdnObjectId}.getValue());" />
                                            </Listeners>
                                        </ext:Button>
                                    <ext:ToolbarFill />
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
                                    <ext:Button Text="Sıralamayı Kaydet" Width="60" ID="btnSaveSort" runat="server" Icon="ShapeUngroup">
                                    <Listeners>
                                    <Click Handler="SaveSorting()" />
                                    </Listeners>
                                    </ext:Button>
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
                        <Listeners>
                            <CellDblClick Handler="ShowEditTab(#{GridPanelViewer}.id,this.getRowsValues()[0].ID,#{hdnDefaultEditPage}.getValue(),#{hdnObjectId}.getValue());" />
                        </Listeners>
                        <SelectionModel>
                            <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" />
                        </SelectionModel>
                        <BottomBar>
                            <ext:PagingToolbar ID="PagingToolBar1" runat="server" DisplayInfo="true" StoreID="StoreViewer"
                                PageSize="50" />
                        </BottomBar>
                        <LoadMask ShowMask="true" />
                        <Plugins>
                            <ext:GenericPlugin ID="GenericPlugin1" runat="server" InstanceOf="Ext.ux.dd.GridDragDropRowOrder">
                                <CustomConfig>
                                    <ext:ConfigItem Name="scrollable" Value="true">
                                    </ext:ConfigItem>
                                </CustomConfig>
                            </ext:GenericPlugin>
                        </Plugins>
                    </ext:GridPanel>
                </Items>
            </ext:FitLayout>
        </Body>
    </ext:ViewPort>
    </form>
</body>
</html>
<script src="../../js/GridOrdering.js" type="text/javascript"></script>
<script src="../../js/MultiSortGrid.js" type="text/javascript"></script>
<script>
    function SaveSorting() {
        var strXml = "<sorting sortattributeid='" + sortattributeid + "'>";
        for (i = 0; i < GridPanelViewer.store.data.items.length; i++) {
            strXml +="<sortitem id='" +GridPanelViewer.store.data.items[i].data.ID +"'/>"
        }
        strXml += "</sorting>";
        Coolite.AjaxMethods.UpdateSorting(strXml);
    }
</script>