<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Entity_Property_LabelsReflex" Codebehind="LabelsReflex.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:Hidden runat="server" ID="objectid" />
    <rx:PanelX runat="server" ID="panel1" Frame="false" Border="false" BodyStyle="padding:10px">
        <Body>
            <rx:ToolBar ID="toolbar1" runat="server">
                <Items>
                    <rx:ToolbarButton runat="server" ID="Save" Icon="PageSave" Text="Label Kaydet">
                        <AjaxEvents>
                            <Click OnEvent="SaveOnEvent">
                                <EventMask ShowMask="true" />
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                    <rx:ToolbarButton runat="server" ID="BtnDelete" Icon="PageDelete" Text="Label Sil">
                        <AjaxEvents>
                            <Click OnEvent="DeleteOnEvent">
                                <EventMask ShowMask="true" />
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                    <rx:ToolbarButton runat="server" ID="BtnNew" Icon="PageAdd" Text="Label Ekle">
                        <Listeners>
                            <Click Handler="winLabelMessage.show()" />
                        </Listeners>
                    </rx:ToolbarButton>
                    <rx:ToolbarSeparator ID="btnExportSeparator" runat="server" />
                   
                    <rx:Label ID="Label1" Text="Language" runat="server" Width="80" ForeColor="White">
                    </rx:Label>
                    <rx:ComboField runat="server" ID="Language" DisplayField="RegionName" ValueField="LangId"
                        Mode="Local" Width="200">
                        <AjaxEvents>
                            <Change OnEvent="LanguageOnEvent">
                            </Change>
                        </AjaxEvents>
                    </rx:ComboField>
                    <rx:ToolbarFill runat="server" ID ="fill1"/>
                    <rx:Button Text="Publish All" runat="server" ID="PublishAll" Icon="ApplicationGo">
                        <AjaxEvents>
                            <Click OnEvent="PublishAll_Click">
                                <EventMask ShowMask="true" />
                            </Click>
                        </AjaxEvents>
                    </rx:Button>
                </Items>
            </rx:ToolBar>
            <rx:GridPanel ID="_grdsma" runat="server" Title="Mesaj Tablosu" AutoWidth="true"
                PostAllData="true" DisableSelection="true" StripeRows="true" ClicksToEdit="1"
                Mode="Remote" AutoHeight="Auto" AutoLoad="true" Width="800" AjaxPostable="true"
                Height="500">
                <DataContainer>
                    <DataSource OnEvent="Store2RefreshData">
                        <Columns>
                            <rx:Column Name="ObjectName">
                            </rx:Column>
                            <rx:Column Name="ObjectId">
                            </rx:Column>
                            <rx:Column Name="LabelId">
                            </rx:Column>
                            <rx:Column Name="Value">
                            </rx:Column>
                            <rx:Column Name="LangId">
                            </rx:Column>
                            <rx:Column Name="Type">
                            </rx:Column>
                            <rx:Column Name="PicklistValue">
                            </rx:Column>
                        </Columns>
                    </DataSource>
                    <Parameters>
                        <rx:Parameter Mode="Raw" Name="lng" Value="Language.getValue()" />
                    </Parameters>
                </DataContainer>
                <ColumnModel>
                    <Columns>
                        <rx:GridColumns Header="LabelId" DataIndex="LabelId" Width="10" Hidden="true">
                        </rx:GridColumns>
                        <rx:GridColumns Header="ObjectId" DataIndex="ObjectId" Width="200" Hidden="true">
                        </rx:GridColumns>
                        <rx:GridColumns Header="ObjectName" DataIndex="ObjectName" Width="200" Sortable="true">
                        </rx:GridColumns>
                        <rx:GridColumns Header="Type" DataIndex="Type" Width="150">
                        </rx:GridColumns>
                        <rx:GridColumns Header="Value" DataIndex="Value" Width="400">
                            <Editor>
                                <Component>
                                    <rx:TextField runat="server" ID="txtfieldTest" MaxLength="200">
                                    </rx:TextField>
                                </Component>
                            </Editor>
                        </rx:GridColumns>
                    </Columns>
                </ColumnModel>
                <LoadMask ShowMask="true" />
                <SelectionModel>
                    <rx:RowSelectionModel runat="server">
                    </rx:RowSelectionModel>
                </SelectionModel>
            </rx:GridPanel>
        </Body>
    </rx:PanelX>
    <rx:Window runat="server" ID="winLabelMessage" Title="Insert Label Message" Width="400"
        Maximizable="false" Resizable="false" BodyStyle="padding:5px;padding-top:10px;"
        frame="false" Border="false" Height="80" CenterOnLoad="true" ShowOnLoad="false"
        CloseAction="Hide">
        <Body>
            <table style="width: 100%">
                <tr>
                    <td>
                        <rx:Label runat="server" Text="Label Message" ID="lblMessage" Width="100">
                        </rx:Label>
                    </td>
                    <td>
                        <rx:TextField runat="server" ID="LMessage" Width="180">
                        </rx:TextField>
                    </td>
                    <td>
                        <rx:Button runat="server" Icon="PageSave" Text="Save" ID="btnMessageSaveOnEvent">
                            <AjaxEvents>
                                <Click OnEvent="LMessageSaveOnEvent" Success="winLabelMessage.Hidden='true'">
                                </Click>
                            </AjaxEvents>
                        </rx:Button>
                    </td>
                </tr>
            </table>
        </Body>
    </rx:Window>
    </form>
</body>
</html>
