<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_DynamicWs_WebServiceFnList" Codebehind="WebServiceFnList.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ext:Hidden ID="WebServiceId" runat="server">
        </ext:Hidden>
        <ext:Store ID="Store1" runat="server" AutoLoad="true" OnRefreshData="Store1_Refresh">
            <Proxy>
                <ext:DataSourceProxy />
            </Proxy>
            <Reader>
                <ext:JsonReader ReaderID="MethodId">
                    <Fields>
                        <ext:RecordField Name="ClassName">
                        </ext:RecordField>
                        <ext:RecordField Name="Name">
                        </ext:RecordField>
                        <ext:RecordField Name="ReturnType">
                        </ext:RecordField>
                        <ext:RecordField Name="MethodId">
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
                                <ext:Column Header="ClassName" DataIndex="ClassName" MenuDisabled="true" Width="100"
                                    Hidden="false" Sortable="false">
                                </ext:Column>
                                <ext:Column Header="Name" DataIndex="Name" MenuDisabled="true" Hidden="false" Width="200"
                                    Sortable="false">
                                </ext:Column>
                                <ext:Column Header="ReturnType" DataIndex="ReturnType" MenuDisabled="true" Hidden="false"
                                    Width="100" Sortable="false">
                                </ext:Column>
                                <ext:Column ColumnID="Image1" DataIndex="ImageHref" Width="70" Header="Edit Result"
                                    Sortable="false" MenuDisabled="true">
                                    <Commands>
                                        <ext:ImageCommand CommandName="WebServiceMethodResult" Icon="TableRow">
                                        </ext:ImageCommand>
                                    </Commands>
                                </ext:Column>
                                <ext:Column ColumnID="Image1" DataIndex="ImageHref" Width="70" Header="Call List"
                                    Sortable="false" MenuDisabled="true">
                                    <Commands>
                                        <ext:ImageCommand CommandName="WebServiceMethodCallList" Icon="ChartOrganisation">
                                        </ext:ImageCommand>
                                    </Commands>
                                </ext:Column>
                                <ext:Column Header="MethodId" DataIndex="MethodId" Width="100" Hidden="true" Sortable="false">
                                </ext:Column>
                            </Columns>
                        </ColumnModel>
                        <Listeners>
                            <Command Fn="cmdHandler" />
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
        var guid = a.getRowsValues()[0].MethodId;
        var config = "Admin/DynamicWs/FnEdit.aspx?MethodId=" + guid;
        window.top.newWindow(config, { title: 'Method Edit', width: 700, height: 400, resizable: true });
    }
    function cmdHandler(a, b, c) {
        switch (a) {
            case 'WebServiceMethodResult':
                var guid = b.id;
                var config = "Admin/DynamicWs/FnResult.aspx?MethodId=" + guid;
                window.top.newWindow(config, { title: 'Method Result Edit', width: 700, height: 400, resizable: true });
                break;
            case 'WebServiceMethodCallList':
                var guid = b.id;
                var config = "Admin/DynamicWs/FnCallList.aspx?MethodId=" + guid;
                window.top.newWindow(config, { title: 'Fn Call List', width: 700, height: 400, resizable: true });
                break;
            default:

        }
    }
    
</script>
