<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Customization_Entity_Property_EntityPropertyReflex" Codebehind="EntityPropertyReflex.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:Hidden runat="server" ID="entityid" />
    <rx:Hidden runat="server" ID="objectid" />
    <table style="width: 100%">
        <tr>
            <td>
                <rx:ToolBar ID="toolbar1" runat="server">
                    <Items>
                        <rx:ToolbarButton runat="server" ID="Save" Icon="PageSave" Text="Entity Kaydet">
                            <AjaxEvents>
                                <Click OnEvent="SaveOnEvent">
                                    <EventMask ShowMask="true" />
                                </Click>
                            </AjaxEvents>
                        </rx:ToolbarButton>
                        <rx:ToolbarButton runat="server" ID="Delete" Icon="PageDelete" Text="Entity Sil">
                            <AjaxEvents>
                                <Click OnEvent="DeleteOnEvent">
                                    <EventMask ShowMask="true" />
                                </Click>
                            </AjaxEvents>
                        </rx:ToolbarButton>
                        <rx:ToolbarSeparator ID="btnExportSeparator" runat="server" />
                        <rx:ToolbarFill ID="toolbarfill_1" runat="server" />
                        <rx:Button Text="Publish Entity" runat="server" ID="tbbPublish" Icon="ApplicationGo">
                            <AjaxEvents>
                                <Click OnEvent="tbbPublish_OnClikc">
                                    <EventMask ShowMask="true" />
                                </Click>
                            </AjaxEvents>
                        </rx:Button>
                    </Items>
                </rx:ToolBar>
            </td>
        </tr>
        <tr>
            <td>
                <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="205" Border="false">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout1" runat="server">
                                    <Body>
                                        <rx:TextField runat="server" ID="DisplayName" FieldLabel="Display Name">
                                        </rx:TextField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout2" runat="server">
                                    <Body>
                                        <rx:TextField runat="server" ID="PrimaryDisplayName" FieldLabel="Primary Label">
                                        </rx:TextField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout3" runat="server">
                                    <Body>
                                        <rx:CheckField runat="server" ID="EnableLogging" FieldLabel="EnableLogging">
                                        </rx:CheckField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout4" runat="server">
                                    <Body>
                                        <rx:CheckField runat="server" ID="IsHierarchicalModel" FieldLabel="IsHierarchicalModel">
                                        </rx:CheckField>
                                    </Body>
                                </rx:RowLayout>
                                
                                <rx:RowLayout runat="server" ID="RowLayout8">
                                    <Body>
                                        <rx:TextAreaField runat="server" ID="txtDescription" FieldLabel="Description" MaxLength="500">
                                        </rx:TextAreaField>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <rx:ColumnLayout runat="server" ID="ColoumnLayout2" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout5">
                                    <Body>
                                        <rx:TextField runat="server" ID="UniqueName" FieldLabel="Unique Name" allowblank="false"
                                            maskre="/[A-Za-z0-9_]/">
                                        </rx:TextField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout6" runat="server">
                                    <Body>
                                        <rx:TextField runat="server" ID="PrimaryName" FieldLabel="Primary Name" allowblank="false"
                                            maskre="/[A-Za-z0-9_]/">
                                        </rx:TextField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout7" runat="server">
                                    <Body>
                                        <rx:CheckField runat="server" ID="IsMultipleLanguage" FieldLabel="IsMultipleLanguage">
                                        </rx:CheckField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout9" runat="server">
                                    <Body>
                                        <rx:CheckField runat="server" ID="IsDataExportable" FieldLabel="IsDataExportable">
                                        </rx:CheckField>
                                    </Body>
                                </rx:RowLayout>
                                
                                <rx:RowLayout ID="RowLayout10" runat="server">
                                    <Body>
                                        <rx:CheckField runat="server" ID="NotShareable" FieldLabel="NotShareable">
                                        </rx:CheckField>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>
            </td>
        </tr>
    </table>
    <rx:GridPanel ID="_grdsma" runat="server" AutoWidth="true" StripeRows="true" StoreID="smastore"
        Height="200" AutoLoad="false" Mode="Local" AutoHeight="Auto" Collapsible="true"
        Width="600">
        <DataContainer>
            <DataSource>
                <Columns>
                    <rx:Column Name="Label">
                    </rx:Column>
                    <rx:Column Name="SiteMapId">
                    </rx:Column>
                </Columns>
            </DataSource>
        </DataContainer>
        <ColumnModel>
            <Columns>
                <rx:GridColumns Header="SiteMapId" DataIndex="SiteMapId" Width="200" Sortable="true"
                    Hidden="true">
                </rx:GridColumns>
                <rx:GridColumns Header="Label" DataIndex="Label" Width="200" Sortable="true">
                </rx:GridColumns>
            </Columns>
        </ColumnModel>
        <LoadMask ShowMask="true" />
        <SelectionModel>
            <rx:CheckSelectionModel ID="CheckboxSelectionModel1" runat="server">
            </rx:CheckSelectionModel>
        </SelectionModel>
    </rx:GridPanel>
    <script type="text/javascript">
        function NewWindow() {
            var config = "Admin/Customization/Entity/Property/Labels.aspx?ObjectId=" + objectid.getValue();
            window.top.newWindowReflex(config, { title: 'Entity Labels', width: 800, height: 600, resizable: true });
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
