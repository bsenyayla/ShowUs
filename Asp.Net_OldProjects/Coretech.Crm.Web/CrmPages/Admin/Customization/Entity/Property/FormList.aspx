<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Entity_Property_FormList" Codebehind="FormList.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script language="javascript">
        function ShowWindow(sender, arg) {
            var config = "/Admin/Customization/Entity/Property/FormEdit.aspx?objectid=" + hdnObjectId.value;
            if (arg == 0) {
                config = config + "&FormId=";
            }
            else {
                config = config + "&FormId=" + sender.getRowsValues()[0].FormId;
            }
            //object.load(config)
            //object[0].id
            //show(animateTarget, cb, scope)	Variant
            window.top.newWindow(config, { title: 'FormEdit', width: 1000, height: 600, resizable: true });
            //object.show(parent.parent.Panel2, parent.parent.Panel2, parent.parent.Panel2);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ext:Hidden runat="server" ID="hdnObjectId">
        </ext:Hidden>
        <ext:Store ID="Store1" runat="server" AutoLoad="true" OnRefreshData="Store1_Refresh">
            <Proxy>
                <ext:DataSourceProxy />
            </Proxy>
            <Reader>
                <ext:JsonReader ReaderID="FormId">
                    <Fields>
                        <ext:RecordField Name="Name">
                        </ext:RecordField>
                        <ext:RecordField Name="Description">
                        </ext:RecordField>
                        <ext:RecordField Name="FormId">
                        </ext:RecordField>
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:ViewPort ID="ViewPort1" runat="server">
            <Body>
                <ext:FitLayout runat="server">
                    <ext:GridPanel ID="GridPanel1" runat="server" StoreID="Store1" TrackMouseOver="false">
                        <TopBar>
                            <ext:Toolbar runat="server">
                                <Items>
                                    <ext:Button Icon="New" runat="server">
                                        <Listeners>
                                            <Click Handler="ShowWindow(this,0);" />
                                        </Listeners>
                                    </ext:Button>
                                    <ext:Button ID="Delete" Icon="Delete" runat="server" text="Sil">
                                        <AjaxEvents>
                                            <Click OnEvent="DeleteForm" >
                                            <EventMask  ShowMask="true"/>
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
                                <ext:ImageCommandColumn ColumnID="Image1" DataIndex="ImageHref" Width="20" Sortable="false"
                                    MenuDisabled="true">
                                </ext:ImageCommandColumn>
                                <ext:Column Header="Name" DataIndex="Name" MenuDisabled="true" Width="300" Hidden="false"
                                    Sortable="false">
                                </ext:Column>
                                <ext:Column Header="Description" DataIndex="Description" MenuDisabled="true" Hidden="false"
                                    Sortable="false">
                                </ext:Column>
                                <ext:Column Header="FormId" DataIndex="FormId" Width="100" Hidden="true" Sortable="false">
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
