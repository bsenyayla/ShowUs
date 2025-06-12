<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Administrations_SecurityRoles_SecurityRolesList" Codebehind="SecurityRolesList.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ext:Hidden runat="server" ID="hdnRoleId">
    </ext:Hidden>
    <ext:Store ID="store1" runat="server" OnRefreshData="StoreOnRefreshData" RemoteSort="true"
        AutoLoad="true">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="RoleId">
                <Fields>
                    <ext:RecordField Name="RoleId" Type="String" />
                    <ext:RecordField Name="Name" Type="String" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="RoleId" Direction="ASC" />
    </ext:Store>
    <ext:FormPanel runat="server" ID="panel1" BodyStyle="padding:10px" Frame="false"
        Border="false">
        <Body>
            <ext:FormLayout ID="FormLayout1" runat="server" LabelSeparator="">
                <ext:Anchor>
                    <ext:TextField runat="server" ID="RoleName" FieldLabel="Role Name" Width="150">
                    </ext:TextField>
                </ext:Anchor>
            </ext:FormLayout>
        </Body>
        <TopBar>
            <ext:Toolbar runat="server" ID="toolbar1">
                <Items>
                    <ext:ToolbarButton runat="server" ID="New" Icon="New">
                        <AjaxEvents>
                            <Click OnEvent="NewOnEvent">
                            </Click>
                        </AjaxEvents>
                    </ext:ToolbarButton>
                    <ext:ToolbarButton runat="server" ID="Add" Icon="Add">
                        <AjaxEvents>
                            <Click OnEvent="AddOnEvent">
                                <Confirmation Message="Bu Rolü Tanımlamak İstiyor musunuz?" ConfirmRequest="true"
                                    Title="Uyarı" />
                            </Click>
                        </AjaxEvents>
                    </ext:ToolbarButton>
                    <ext:ToolbarButton runat="server" ID="Delete" Icon="Delete">
                        <AjaxEvents>
                            <Click OnEvent="DeleteOnEvent">
                                <Confirmation Message="Seçili Rolü Silmek İstiyor musunuz?" ConfirmRequest="true"
                                    Title="Uyarı" />
                            </Click>
                        </AjaxEvents>
                    </ext:ToolbarButton>
                </Items>
            </ext:Toolbar>
        </TopBar>
    </ext:FormPanel>
    <ext:Panel runat="server" ID="pnl2" Frame="false" Border="false" LabelSeparator="">
        <Body>
            <ext:FitLayout ID="FitLayout1" runat="server">
                <ext:GridPanel ID="_grdsma" runat="server" AutoWidth="true" StripeRows="true" StoreID="store1"
                    Height="400">
                    <ColumnModel ID="_columnModel2" runat="server">
                        <Columns>
                            <ext:RowNumbererColumn />
                            <ext:Column Header="RoleId" DataIndex="RoleId" Width="50" Hidden="true" />
                            <ext:Column Header="Name" DataIndex="Name" Width="330" />
                        </Columns>
                    </ColumnModel>
                    <LoadMask ShowMask="true" />
                    <SelectionModel>
                        <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" SingleSelect="true">
                            <AjaxEvents>
                                <RowSelect OnEvent="RowSelectOnEvent">
                                    <ExtraParams>
                                        <ext:Parameter Name="Values" Value="Ext.encode(#{_grdsma}.getRowsValues())" Mode="Raw" />
                                    </ExtraParams>
                                </RowSelect>
                            </AjaxEvents>
                        </ext:RowSelectionModel>
                    </SelectionModel>
                    <Listeners>
                        <DblClick Handler="NewWindow();" />
                    </Listeners>
                </ext:GridPanel>
            </ext:FitLayout>
        </Body>
    </ext:Panel>
    <script type="text/javascript">
        function NewWindow() {
            var RoleId = _grdsma.getSelectionModel().selections.items[0].id;
            var config = "Admin/Administrations/SecurityRoles/RolePrivileges.aspx?RoleId=" + RoleId;
            window.top.newWindow(config, { title: 'RolePrivileges', width: 900, height: 600, resizable: true });
        }
    </script>
    </form>
</body>
</html>
