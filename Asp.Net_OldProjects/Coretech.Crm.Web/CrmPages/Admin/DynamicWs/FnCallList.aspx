<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_DynamicWs_FnCallList" ValidateRequest="false" Codebehind="FnCallList.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ext:Hidden ID="hdnMethodId" runat="server">
        </ext:Hidden>
        <ext:Store ID="Store1" runat="server" AutoLoad="true" OnRefreshData="Store1_Refresh">
            <Proxy>
                <ext:DataSourceProxy>
                </ext:DataSourceProxy>
            </Proxy>
            <Reader>
                <ext:JsonReader ReaderID="MethodCallId">
                    <Fields>
                        <ext:RecordField Name="MethodCallId">
                        </ext:RecordField>
                        <ext:RecordField Name="MethodId">
                        </ext:RecordField>
                        <ext:RecordField Name="EntityId">
                        </ext:RecordField>
                        <ext:RecordField Name="EntityIdName">
                        </ext:RecordField>
                        <ext:RecordField Name="Name">
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
                                    <ext:Button ID="btnNew" Icon="New" runat="server">
                                        <Listeners>
                                            <Click Handler="ShowWindow(this,0);" />
                                        </Listeners>
                                    </ext:Button>
                                </Items>
                                <Items>
                                    <ext:Button ID="btnDelete" Icon="Delete" runat="server" Text="Sil">
                                        <AjaxEvents>
                                            <Click OnEvent="btnDelete_OnEvent">
                                            <ExtraParams>
                                            <ext:Parameter Name="Deleted" Mode="Raw" Value="GetRowId()"></ext:Parameter>
                                            </ExtraParams>
                                                <EventMask ShowMask="true" />
                                            </Click>
                                        </AjaxEvents>
                                    </ext:Button>
                                </Items>
                            </ext:Toolbar>
                        </TopBar>
                        <ColumnModel ID="ColumnModel1" runat="server">
                            <Columns>
                                <ext:Column Header="Name" DataIndex="Name" MenuDisabled="true" Hidden="false" Width="200"
                                    Sortable="false">
                                </ext:Column>
                                <ext:Column Header="EntityIdName" DataIndex="EntityIdName" MenuDisabled="true" Hidden="false"
                                    Width="100" Sortable="false">
                                </ext:Column>
                                <ext:Column Header="MethodId" DataIndex="MethodId" Width="100" Hidden="true" Sortable="false">
                                </ext:Column>
                                <ext:Column Header="MethodCallId" DataIndex="MethodId" Width="100" Hidden="true"
                                    Sortable="false">
                                </ext:Column>
                            </Columns>
                        </ColumnModel>
                        <Listeners>
                            <CellDblClick Handler="ShowWindow(this,1);" />
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
    function GetRowId() {

        if (GridPanel1.getSelectionModel().getSelections().length>0) {
            return GridPanel1.getSelectionModel().getSelections()[0].id
        }
    }
    function ShowWindow(sender, arg) {

        var config = GetWebAppRoot + "/CrmPages/Admin/DynamicWs/FnCallEdit.aspx";
        if (arg == 0) {
            config = config + "?MethodCallId=";
        }
        else {
            config = config + "?MethodCallId=" + sender.getRowsValues()[0].MethodCallId;
        }
        config += "&MethodId=" + hdnMethodId.getValue();
        window.top.newWindow(config, { title: 'Fn Call Edit', width: 800, height: 480, resizable: true });

    }
</script>
