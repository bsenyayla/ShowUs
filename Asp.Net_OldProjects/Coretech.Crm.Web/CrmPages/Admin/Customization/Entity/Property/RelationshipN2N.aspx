<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Customization_Entity_Property_RelationshipN2N" Codebehind="RelationshipN2N.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ext:Hidden runat="server" ID="hdnentityid">
    </ext:Hidden>
    <ext:Hidden runat="server" ID="hdnattributeid">
    </ext:Hidden>
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
    <ext:Store ID="store1" runat="server" OnRefreshData="StoreOnRefreshData" RemoteSort="true"
        AutoLoad="true">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader>
                <Fields>
                    <ext:RecordField Name="FromObjectId" Type="Int" />
                    <ext:RecordField Name="ToAttributeId" Type="String" />
                    <ext:RecordField Name="AttributeName" Type="String" />
                    <ext:RecordField Name="DisplayName" Type="String" />
                    <ext:RecordField Name="Name" Type="String" />
                    <ext:RecordField Name="Description" Type="String" />
                    
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="AttributeName" Direction="ASC" />
    </ext:Store>
    <ext:Panel runat="server" ID="tabpanel1" Height="390">
                <Body>
                    <ext:FormPanel runat="server" ID="fpnl1" Frame="false" Border="false" AutoWidth="true"
                        Height="120">
                        <Body>
                            <ext:ColumnLayout runat="server" FitHeight="true">
                                <ext:LayoutColumn ColumnWidth=".5">
                                    <ext:Panel ID="Panel1" runat="server" Frame="false" Border="false" LabelSeparator="">
                                        <Body>
                                            <ext:FormLayout ID="FormLayout2" runat="server" LabelSeparator="">
                                                <ext:Anchor>
                                                    <ext:TextField runat="server" ID="DisplayName" DataIndex="Label" FieldLabel="Display Name"
                                                        Width="150">
                                                    </ext:TextField>
                                                </ext:Anchor>
                                                <ext:Anchor>
                                                    <ext:ComboBox runat="server" ID="Entity" FieldLabel="Entity" Width="150" Editable="false"
                                                        StoreID="entitystore" DisplayField="Label" ValueField="ObjectId" ListWidth="250">
                                                    </ext:ComboBox>
                                                </ext:Anchor>
                                            </ext:FormLayout>
                                        </Body>
                                    </ext:Panel>
                                </ext:LayoutColumn>
                                <ext:LayoutColumn ColumnWidth=".5">
                                    <ext:Panel ID="Panel2" runat="server" Frame="false" Border="false" LabelSeparator="">
                                        <Body>
                                            <ext:FormLayout ID="FormLayout1" runat="server" LabelSeparator="">
                                                <ext:Anchor>
                                                    <ext:TextField runat="server" ID="Name" DataIndex="Name" FieldLabel="Name" Width="150"
                                                        MaskRe="/[A-Za-z0-9_]/">
                                                    </ext:TextField>
                                                </ext:Anchor>
                                            </ext:FormLayout>
                                        </Body>
                                    </ext:Panel>
                                </ext:LayoutColumn>
                            </ext:ColumnLayout>
                        </Body>
                        <TopBar>
                            <ext:Toolbar ID="Toolbar1" runat="server">
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
                                                <Confirmation Message="Bu Alanı Tabloya Ekleme/Güncellemek İstiyor musunuz?" ConfirmRequest="true"
                                                    Title="Uyarı" />
                                            </Click>
                                        </AjaxEvents>
                                    </ext:ToolbarButton>
                                    <ext:ToolbarButton runat="server" ID="Delete" Icon="Delete">
                                        <AjaxEvents>
                                            <Click OnEvent="DeleteOnEvent">
                                                <Confirmation Message="Seçili Alanı Tablodan Silmek İstiyor musunuz?" ConfirmRequest="true"
                                                    Title="Uyarı" />
                                            </Click>
                                        </AjaxEvents>
                                    </ext:ToolbarButton>
                                </Items>
                            </ext:Toolbar>
                        </TopBar>
                    </ext:FormPanel>
                    <ext:Panel ID="Panel3" runat="server" Frame="false" Border="false" BodyStyle="padding:5px;">
                        <Body>
                            <ext:FormLayout ID="FormLayout3" runat="server">
                                <ext:Anchor>
                                    <ext:TextArea runat="server" ID="txtDescription" Width="400" FieldLabel="Description"
                                        AllowBlank="false">
                                    </ext:TextArea>
                                </ext:Anchor>
                            </ext:FormLayout>
                        </Body>
                    </ext:Panel>
                    <ext:Panel runat="server" ID="pnl2" Frame="false" Border="false" LabelSeparator="">
                        <Body>
                            <ext:FitLayout ID="FitLayout1" runat="server">
                                <ext:GridPanel ID="_grdsma" runat="server" AutoWidth="true" StripeRows="true" StoreID="store1"
                                    Height="190">
                                    <ColumnModel ID="_columnModel2" runat="server">
                                        <Columns>
                                            <ext:Column Header="FromObjectId" DataIndex="FromObjectId" Width="150" Hidden="true" />
                                            <ext:Column Header="ToAttributeId" DataIndex="ToAttributeId" Width="150" Hidden="true" />
                                            <ext:Column Header="AttributeName" DataIndex="AttributeName" Width="150" />
                                            <ext:Column Header="DisplayName" DataIndex="DisplayName" Width="150" />
                                            <ext:Column Header="Name" DataIndex="Name" Width="150" />
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
    </ext:Panel>
    </form>
</body>
</html>
