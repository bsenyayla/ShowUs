<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Plugin_PluginList" Codebehind="PluginList.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ext:Hidden ID="hPluginDllId" runat="server">
    </ext:Hidden>
    <ext:Store ID="Store1" runat="server" AutoLoad="true" OnRefreshData="Store1_Refresh">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="PluginId">
                <Fields>
                    <ext:RecordField Name="Name" />
                    <ext:RecordField Name="ClassName" />
                    <ext:RecordField Name="PluginId" />
                </Fields>
            </ext:JsonReader>
        </Reader>
    </ext:Store>
    <ext:ViewPort ID="ViewPort1" runat="server">
        <Body>
            <ext:FitLayout ID="FitLayout1" runat="server">
                <ext:GridPanel ID="GridPanel1" runat="server" StoreID="Store1" TrackMouseOver="false">
                    <ColumnModel ID="ColumnModel1" runat="server">
                        <Columns>
                            <ext:Column Header="Name" DataIndex="Name" MenuDisabled="true" Width="200" Hidden="false"
                                Sortable="false">
                            </ext:Column>
                            <ext:Column Header="ClassName" DataIndex="ClassName" Width="400" MenuDisabled="true" Hidden="false"
                                Sortable="false">
                            </ext:Column>
                            <ext:Column Header="PluginId" DataIndex="PluginId" Width="100" Hidden="true" Sortable="false">
                            </ext:Column>
                        </Columns>
                    </ColumnModel>
                    <Listeners>
                        <CellDblClick fn="ShowWindow" />
                    </Listeners>
                    <SelectionModel>
                        <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" />
                    </SelectionModel>
                    <BottomBar>
                        <ext:PagingToolbar ID="PagingToolBar1" runat="server" StoreID="Store1" DisplayInfo="true"
                            DisplayMsg="Entity Listesi {0} - {1} Arası   -Toplam  {2} Kayıt" />
                    </BottomBar>
                    <LoadMask ShowMask="true" Msg="Loading Data..." />
                </ext:GridPanel>
            </ext:FitLayout>
        </Body>
    </ext:ViewPort>
    </form>
</body>
</html>
<script type="text/javascript" language="javascript">
    function ShowWindow(a, b, c) {
        var guid = a.getRowsValues()[0].PluginId;
        var config = GetWebAppRoot + "/CrmPages/Admin/Plugin/PluginMessage.aspx?PluginId=" + guid;
        window.top.newWindow(config, { title: 'Plugin', width: 600, height: 400, resizable: false, modal: true });
    }
</script>
