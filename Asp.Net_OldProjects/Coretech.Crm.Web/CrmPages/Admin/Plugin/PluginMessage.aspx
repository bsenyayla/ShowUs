<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Plugin_PluginMessage" Codebehind="PluginMessage.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ext:Hidden runat="server" ID="hdnPluginId" />
    <ext:Hidden runat="server" ID="hdnPluginMessageId" />
    <ext:Store ID="entitystore" runat="server" OnRefreshData="EntityStoreOnRefreshData"
        WarningOnDirty="false" RemoteSort="true" AutoLoad="true">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader>
                <Fields>
                    <ext:RecordField Name="ObjectId" Type="Int" />
                    <ext:RecordField Name="Label" Type="String" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="ObjectId" Direction="ASC" />
    </ext:Store>
    <ext:Store ID="messagetype" runat="server" OnRefreshData="MessageTypeStoreOnRefreshData"
        WarningOnDirty="false" RemoteSort="true" AutoLoad="true">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader>
                <Fields>
                    <ext:RecordField Name="MessageTypeId" Type="String" />
                    <ext:RecordField Name="MessageName" Type="String" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="MessageTypeId" Direction="ASC" />
    </ext:Store>
    <ext:Store ID="messagelist" runat="server" OnRefreshData="MessageListStoreOnRefreshData"
        WarningOnDirty="false" RemoteSort="true" AutoLoad="true">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader>
                <Fields>
                    <ext:RecordField Name="PluginMessageId" Type="String" />
                    <ext:RecordField Name="MessageTypeId" Type="String" />
                    <ext:RecordField Name="PluginId" Type="String" />
                    <ext:RecordField Name="EntityId" Type="String" />
                    <ext:RecordField Name="ObjectId" Type="Int" />
                    <ext:RecordField Name="EntityName" Type="String" />
                    <ext:RecordField Name="Before" Type="Boolean" />
                    <ext:RecordField Name="After" Type="Boolean" />
                    <ext:RecordField Name="ExecutionOrder" Type="Int" />
                    <ext:RecordField Name="RunInUser" Type="Int" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="PluginMessageId" Direction="ASC" />
    </ext:Store>
    <ext:Panel runat="server" ID="panel1" Frame="false" Border="false">
        <Body>
            <ext:FormPanel runat="server" ID="fpnl1" Frame="false" Border="false" AutoWidth="true"
                Height="120" BodyStyle="padding:10px">
                <Body>
                    <ext:ColumnLayout ID="ColumnLayout1" runat="server" FitHeight="true">
                        <ext:LayoutColumn ColumnWidth=".5">
                            <ext:Panel ID="Panel2" runat="server" Frame="false" Border="false" LabelSeparator="">
                                <Body>
                                    <ext:FormLayout ID="FormLayout2" runat="server" LabelSeparator="">
                                        <ext:Anchor>
                                            <ext:ComboBox runat="server" ID="cmbmessagetype" FieldLabel="Mesaj Tipi" Width="150"
                                                MsgTarget="Side" AllowBlank="false" Editable="false" StoreID="messagetype" DisplayField="MessageName"
                                                ValueField="MessageTypeId" ListWidth="250">
                                            </ext:ComboBox>
                                        </ext:Anchor>
                                        <ext:Anchor>
                                            <ext:ComboBox runat="server" ID="Entity" FieldLabel="Entity" Width="150" Editable="false"
                                                MsgTarget="Side" AllowBlank="false" StoreID="entitystore" DisplayField="Label"
                                                ValueField="ObjectId" ListWidth="250">
                                            </ext:ComboBox>
                                        </ext:Anchor>
                                        <ext:Anchor>
                                            <ext:ComboBox runat="server" ID="RunInUser" Width="150" Editable="false" FieldLabel="RunInUser"
                                                MsgTarget="Side" AllowBlank="false">
                                                <Items>
                                                    <ext:ListItem Value="0" Text="Caling User" />
                                                    <ext:ListItem Value="1" Text="System Admin" />
                                                </Items>
                                            </ext:ComboBox>
                                        </ext:Anchor>
                                    </ext:FormLayout>
                                </Body>
                            </ext:Panel>
                        </ext:LayoutColumn>
                        <ext:LayoutColumn ColumnWidth=".5">
                            <ext:Panel ID="Panel3" runat="server" Frame="false" Border="false" LabelSeparator="">
                                <Body>
                                    <ext:FormLayout ID="FormLayout1" runat="server" LabelSeparator="">
                                        <ext:Anchor>
                                            <ext:Checkbox runat="server" ID="chkbefore" FieldLabel="Önce" Width="150">
                                            </ext:Checkbox>
                                        </ext:Anchor>
                                        <ext:Anchor>
                                            <ext:Checkbox runat="server" ID="chkafter" FieldLabel="Sonra" Width="150">
                                            </ext:Checkbox>
                                        </ext:Anchor>
                                        <ext:Anchor>
                                            <ext:NumberField runat="server" ID="ExecutionOrder" FieldLabel="ExecutionOrder" Width="150">
                                            </ext:NumberField>
                                        </ext:Anchor>
                                    </ext:FormLayout>
                                </Body>
                            </ext:Panel>
                        </ext:LayoutColumn>
                    </ext:ColumnLayout>
                </Body>
            </ext:FormPanel>
            <ext:Panel runat="server" ID="pnl2" Frame="false" Border="false" LabelSeparator="">
                <Body>
                    <ext:FitLayout ID="FitLayout1" runat="server">
                        <ext:GridPanel ID="_grdsma" runat="server" AutoWidth="true" StripeRows="true" StoreID="messagelist"
                            Height="210">
                            <ColumnModel ID="_columnModel2" runat="server">
                                <Columns>
                                    <ext:RowNumbererColumn />
                                    <ext:Column Header="PluginMessageId" DataIndex="PluginMessageId" Width="50" Hidden="true" />
                                    <ext:Column Header="MessageTypeId" DataIndex="MessageTypeId" Width="50" Hidden="true" />
                                    <ext:Column Header="PluginId" DataIndex="PluginId" Width="50" Hidden="true" />
                                    <ext:Column Header="ObjectId" DataIndex="ObjectId" Width="50" Hidden="true" />
                                    <ext:Column Header="EntityId" DataIndex="EntityId" Width="50" Hidden="true" />
                                    <ext:Column Header="EntityName" DataIndex="EntityName" Width="350" />
                                    <ext:CheckColumn Header="Before" DataIndex="Before" Width="50" />
                                    <ext:CheckColumn Header="After" DataIndex="After" Width="50" />
                                    <ext:Column Header="ExecutionOrder" DataIndex="ExecutionOrder" Width="50" Hidden="true" />
                                    <ext:Column Header="RunInUser" DataIndex="RunInUser" Width="50" Hidden="true" />
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
                        </ext:GridPanel>
                    </ext:FitLayout>
                </Body>
            </ext:Panel>
        </Body>
        <TopBar>
            <ext:Toolbar runat="server">
                <Items>
                    <ext:ToolbarButton runat="server" ID="New" Icon="New">
                        <AjaxEvents>
                            <Click OnEvent="NewOnEvent">
                            </Click>
                        </AjaxEvents>
                    </ext:ToolbarButton>
                    <ext:ToolbarButton runat="server" ID="Add" Icon="Add">
                        <AjaxEvents>
                            <Click OnEvent="AddOnEvent" Before="return fpnl1.isValid();">
                                <Confirmation Message="Bu Kaydı Tabloya Ekleme/Güncellemek İstiyor musunuz?" ConfirmRequest="true"
                                    Title="Uyarı" />
                            </Click>
                        </AjaxEvents>
                    </ext:ToolbarButton>
                    <ext:ToolbarButton runat="server" ID="Delete" Icon="Delete">
                        <AjaxEvents>
                            <Click OnEvent="DeleteOnEvent">
                                <Confirmation Message="Seçili Kaydı Tablodan Silmek İstiyor musunuz?" ConfirmRequest="true"
                                    Title="Uyarı" />
                            </Click>
                        </AjaxEvents>
                    </ext:ToolbarButton>
                </Items>
            </ext:Toolbar>
        </TopBar>
    </ext:Panel>
    </form>
</body>
</html>
