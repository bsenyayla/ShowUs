<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_DynamicUrl_DynamicUrlList" Codebehind="DynamicUrlList.aspx.cs" %>
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
                <ext:JsonReader ReaderID="DynamicUrlId">
                    <Fields>
                        <ext:RecordField Name="Name">
                        </ext:RecordField>
                        <ext:RecordField Name="Url">
                        </ext:RecordField>
                        <ext:RecordField Name="DynamicUrlId">
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
                                     <ext:Button ID="Delete" Icon="Delete" runat="server" text="Sil">
                                    <AjaxEvents>
                                        <Click OnEvent="DeleteDynamicUrl">
                                            <EventMask ShowMask="true" />
                                            <ExtraParams>
                                                <ext:Parameter Name="Values" Value="Ext.encode(#{GridPanel1}.getRowsValues(true))"
                                                    Mode="Raw" />
                                            </ExtraParams>
                                        </Click>
                                    </AjaxEvents>
                                </ext:Button>
                                </Items>
                            </ext:Toolbar>
                        </TopBar>
                        <ColumnModel ID="ColumnModel1" runat="server">
                            <Columns>
                                <ext:Column Header="Name" DataIndex="Name" MenuDisabled="true" Width="200" Hidden="false"
                                    Sortable="false">
                                </ext:Column>
                                <ext:Column Header="Url" DataIndex="Url" MenuDisabled="true" Hidden="false" Width="450" Sortable="false">
                                </ext:Column>
                                <ext:Column Header="DynamicUrlId" DataIndex="DynamicUrlId" Width="100" Hidden="true"
                                    Sortable="false">
                                </ext:Column>
                            </Columns>
                        </ColumnModel>
                        <Listeners>
                            <DblClick Handler="ShowWindow(this,1);" />
                            
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
//    function EditWindow(a, b, c) {
//        var guid = a.getRowsValues()[0].DynamicUrlId;
//        var config = "Admin/DynamicWs/DynamicUrlEdit.aspx?DynamicUrlId=" + guid;
//        window.top.newWindow(config, { title: 'Plugin', width: 800, height: 600, resizable: true });
//    }
    function ShowWindow(sender, arg) {

        var config = GetWebAppRoot + "/CrmPages/Admin/DynamicUrl/DynamicUrlEdit.aspx";
        if (arg == 0) {
            config = config + "?DynamicUrlId=";
        }
        else {
            config = config + "?DynamicUrlId=" + sender.getRowsValues()[0].DynamicUrlId;
        }
        window.top.newWindowRefleX(config, { title: 'Dynamic Url Edit', width: 600, height: 480, resizable: true });

    }
</script>
