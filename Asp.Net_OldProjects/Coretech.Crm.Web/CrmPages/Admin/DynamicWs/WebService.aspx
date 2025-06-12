<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_DynamicWs_WebService" Codebehind="WebService.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ext:Store ID="Store1" runat="server" AutoLoad="true" OnRefreshData="Store1_Refresh">
            <Proxy>
                <ext:DataSourceProxy />
            </Proxy>
            <Reader>
                <ext:JsonReader ReaderID="WebServiceId">
                    <Fields>
                        <ext:RecordField Name="Name">
                        </ext:RecordField>
                        <ext:RecordField Name="Url">
                        </ext:RecordField>
                        <ext:RecordField Name="WebServiceId">
                        </ext:RecordField>
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:ViewPort ID="ViewPort1" runat="server">
            <Body>
                <ext:FitLayout ID="FitLayout1" runat="server">
                    <ext:GridPanel ID="GridPanel1" runat="server" StoreID="Store1" TrackMouseOver="false">
                        <TopBar>
                            <ext:Toolbar ID="Toolbar1" runat="server">
                                <Items>
                                    <ext:Button ID="Button1" Icon="New" runat="server">
                                        <Listeners>
                                            <Click Handler="ShowWindow(this,0);" />
                                        </Listeners>
                                    </ext:Button>
                                </Items>
                            </ext:Toolbar>
                        </TopBar>
                        <ColumnModel ID="ColumnModel1" runat="server">
                            <Columns>
                                <ext:Column ColumnID="Image1" DataIndex="ImageHref" Width="40" Sortable="false" MenuDisabled="true">
                                    <Commands>
                                        <ext:ImageCommand CommandName="Edit" Icon="NoteEdit">
                                        </ext:ImageCommand>
                                    </Commands>
                                </ext:Column>
                                <ext:Column Header="Name" DataIndex="Name" MenuDisabled="true" Width="100" Hidden="false"
                                    Sortable="false">
                                </ext:Column>
                                <ext:Column Header="Url" DataIndex="Url" MenuDisabled="true" Hidden="false" Width="450" Sortable="false">
                                </ext:Column>
                                <ext:Column Header="WebServiceId" DataIndex="WebServiceId" Width="100" Hidden="true"
                                    Sortable="false">
                                </ext:Column>
                            </Columns>
                        </ColumnModel>
                        <Listeners>
                            <Command Handler="ShowWindow(this,1);" />
                            <CellDblClick Fn="EditWindow" />
                        </Listeners>
                        <SelectionModel>
                            <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" />
                        </SelectionModel>
                        <BottomBar>
                            <ext:PagingToolbar ID="PagingToolBar1" runat="server" StoreID="Store1" DisplayInfo="true"
                                DisplayMsg="Entity Listesi {0} - {1} Arası   -Toplam  {2} Kayıt" EmptyMsg="No employees to display" />
                        </BottomBar>
                        <LoadMask ShowMask="true" Msg="Loading Data..." />
                    </ext:GridPanel>
                </ext:FitLayout>
            </Body>
        </ext:ViewPort>
    </div>
    </form>
</body>
</html>
<script type="text/javascript" language="javascript">
    function EditWindow(a, b, c) {
        var guid = a.getRowsValues()[0].WebServiceId;
        var config = "Admin/DynamicWs/WebServiceFnList.aspx?WebServiceId=" + guid;
        window.top.newWindow(config, { title: 'Plugin', width: 800, height: 600, resizable: true });
    }
    function ShowWindow(sender, arg) {

        var config = GetWebAppRoot + "/CrmPages/Admin/DynamicWs/WebServiceEdit.aspx";
        if (arg == 0) {
            config = config + "?WebServiceId=";
        }
        else {
            config = config + "?WebServiceId=" + sender.getRowsValues()[0].WebServiceId;
        }
        window.top.newWindow(config, { title: 'PluginDllEdit', width: 600, height: 480, resizable: true });

    }
</script>
