<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Entity_Property_EntityProperty" Codebehind="EntityProperty.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ext:Store ID="smastore" runat="server" OnRefreshData="SmaOnRefreshData" RemoteSort="true"
        AutoLoad="true">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="SiteMapId">
                <Fields>
                    <ext:RecordField Name="Label" Type="String" />
                    <ext:RecordField Name="SiteMapId" Type="String" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="SiteMapId" Direction="ASC" />
    </ext:Store>
    <ext:Hidden runat="server" ID="entityid" />
    <ext:Hidden runat="server" ID="objectid" />
    <ext:ViewPort runat="server">
        <Body>
            <ext:BorderLayout ID="BorderLayout1" runat="server">
                <North>
                    <ext:Panel runat="server" ID="pnl1" Frame="false" Border="false" Height="220">
                        <Body>
                            <ext:FormPanel runat="server" ID="formpanel1" Frame="false" Border="false" BodyStyle="padding:5px;"
                                LabelSeparator="">
                                <Body>
                                    <ext:ColumnLayout ID="ColumnLayout1" runat="server">
                                        <ext:LayoutColumn ColumnWidth=".5">
                                            <ext:Panel ID="Panel1" runat="server" Frame="false" Border="false" LabelSeparator="">
                                                <Body>
                                                    <ext:FormLayout ID="FormLayout1" runat="server" LabelSeparator="">
                                                        <ext:Anchor>
                                                            <ext:TextField runat="server" ID="DisplayName" FieldLabel="Display Name" AllowBlank="false">
                                                                <Listeners>
                                                                    <Valid Handler="if (UniqueName.getValue == '') UniqueName.setValue(EscapeChr(DisplayName.getValue()));" />
                                                                </Listeners>
                                                            </ext:TextField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:TextField runat="server" ID="PrimaryDisplayName" FieldLabel="Primary Label"
                                                                AllowBlank="false">
                                                            </ext:TextField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:Checkbox runat="server" ID="EnableLogging" FieldLabel="EnableLogging">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:Checkbox runat="server" ID="IsDataExportable" FieldLabel="IsDataExportable">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:Checkbox runat="server" ID="NotShareable" FieldLabel="NotShareable">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                        
                                                        <ext:Anchor>
                                                            <ext:Checkbox runat="server" ID="IsHierarchicalModel" FieldLabel="IsHierarchicalModel">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                    </ext:FormLayout>
                                                </Body>
                                            </ext:Panel>
                                        </ext:LayoutColumn>
                                        <ext:LayoutColumn ColumnWidth=".5">
                                            <ext:Panel ID="Panel2" runat="server" Frame="false" Border="false" LabelSeparator="">
                                                <Body>
                                                    <ext:FormLayout ID="FormLayout2" runat="server" LabelSeparator="">
                                                        <ext:Anchor>
                                                            <ext:TextField runat="server" ID="UniqueName" FieldLabel="Unique Name" AllowBlank="false"
                                                                MaskRe="/[A-Za-z0-9_]/">
                                                            </ext:TextField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:TextField runat="server" ID="PrimaryName" FieldLabel="Primary Name" AllowBlank="false"
                                                                MaskRe="/[A-Za-z0-9_]/">
                                                            </ext:TextField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:Checkbox runat="server" ID="IsMultipleLanguage" FieldLabel="IsMultipleLanguage">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                    </ext:FormLayout>
                                                </Body>
                                            </ext:Panel>
                                        </ext:LayoutColumn>
                                    </ext:ColumnLayout>
                                </Body>
                            </ext:FormPanel>
                            <ext:Panel ID="Panel3" runat="server" Frame="false" Border="false" BodyStyle="padding:5px;" >
                                <Body>
                                    <ext:FormLayout runat="server">
                                        <ext:Anchor>
                                            <ext:textarea runat="server" ID="txtDescription"  Width="400" FieldLabel="Description" AllowBlank="false">
                                            </ext:textarea>
                                        </ext:Anchor>
                                    </ext:FormLayout>
                                </Body>
                            </ext:Panel>
                        </Body>
                        <TopBar>
                            <ext:Toolbar runat="server" ID="pt1">
                                <Items>
                                    <ext:ToolbarButton runat="server" ID="Save" Icon="PageSave" Text="Entity Kaydet">
                                        <AjaxEvents>
                                            <Click OnEvent="SaveOnEvent" Before="return formpanel1.isValid();">
                                                <EventMask ShowMask="true" />
                                            </Click>
                                        </AjaxEvents>
                                    </ext:ToolbarButton>
                                    <ext:ToolbarButton runat="server" ID="Delete" Icon="Delete" Text="Entity Sil">
                                        <AjaxEvents>
                                            <Click OnEvent="DeleteOnEvent">
                                                <EventMask ShowMask="true" />
                                                <Confirmation Message="Seçili Tabloyu Silmek İstiyor musunuz?" ConfirmRequest="true"
                                                    Title="Uyarı" />
                                            </Click>
                                        </AjaxEvents>
                                    </ext:ToolbarButton>
                                    <ext:ToolbarButton runat="server" ID="ToolbarButton1" Icon="TextAb" Text="Entity Labels">
                                        <Listeners>
                                            <Click Handler="NewWindow()" />
                                        </Listeners>
                                    </ext:ToolbarButton>
                                </Items>
                            </ext:Toolbar>
                        </TopBar>
                    </ext:Panel>
                </North>
                <Center>
                    <ext:Panel runat="server" ID="pnl2" Frame="false" Border="false" BodyStyle="padding:5px;"
                        LabelSeparator="">
                        <Body>
                            <ext:FitLayout runat="server">
                                <ext:GridPanel ID="_grdsma" runat="server" AutoWidth="true" StripeRows="true" StoreID="smastore"
                                    Height="200">
                                    <ColumnModel ID="_columnModel2" runat="server">
                                        <Columns>
                                            <ext:Column Header="SiteMapId" DataIndex="SiteMapId" Width="10" Hidden="true" />
                                            <ext:Column Header="Label" DataIndex="Label" Width="150" />
                                        </Columns>
                                    </ColumnModel>
                                    <LoadMask ShowMask="true" />
                                    <SelectionModel>
                                        <ext:CheckboxSelectionModel ID="CheckboxSelectionModel1" runat="server" />
                                    </SelectionModel>
                                </ext:GridPanel>
                            </ext:FitLayout>
                        </Body>
                    </ext:Panel>
                </Center>
            </ext:BorderLayout>
        </Body>
    </ext:ViewPort>
    <script type="text/javascript">
        function NewWindow() {
            var config = "Admin/Customization/Entity/Property/Labels.aspx?ObjectId=" + objectid.getValue();
            window.top.newWindow(config, { title: 'Entity Labels', width: 800, height: 600, resizable: true });
        }
        var sInvalidSchemaNameChars = "[^A-Za-z0-9_]";
        function EscapeChr(s) {
            var regExp = new RegExp(sInvalidSchemaNameChars, "g");
            return s.replace(regExp, "").substr(0, 100);
        }
    </script>
    </form>
</body>
</html>
