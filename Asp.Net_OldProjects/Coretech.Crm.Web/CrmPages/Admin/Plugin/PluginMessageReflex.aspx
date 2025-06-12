<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Plugin_PluginMessageReflex" Codebehind="PluginMessageReflex.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:Hidden runat="server" ID="hdnPluginId" />
    <rx:Hidden runat="server" ID="hdnPluginMessageId" />
    
    <table style="width: 100%">
<tr>
<td>
            <rx:ToolBar runat="server" ID="toolbar1">
                <Items>
                    <rx:ToolbarButton runat="server" ID="New" Icon="Page" Text="New">
                        <AjaxEvents>
                            <Click OnEvent="NewOnEvent">
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                    <rx:ToolbarButton runat="server" ID="Add" Icon="PageAdd" Text="Add">
                        <AjaxEvents>
                            <Click OnEvent="AddOnEvent">
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                    <rx:ToolbarButton runat="server" ID="Delete" Icon="PageDelete" Text="Delete">
                        <AjaxEvents>
                            <Click OnEvent="DeleteOnEvent">
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                </Items>
            </rx:ToolBar>
            <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="50%">
                <Rows>
                    <rx:RowLayout ID="RowLayout2" runat="server">
                        <Body>
                            <rx:ComboField runat="server" ID="cmbmessagetype" FieldLabel="Mesaj Tipi" Width="150"
                                Editable="false" DisplayField="MessageName" Mode="Remote"
                                ValueField="MessageTypeId">
                                <DataContainer>
                                    <DataSource OnEvent="MessageTypeStoreOnRefreshData">
                                        <Columns>
                                            <rx:Column Name="MessageTypeId" Hidden="true">
                                            </rx:Column>
                                            <rx:Column Name="MessageName">
                                            </rx:Column>
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </rx:ComboField>
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout ID="RowLayout3" runat="server">
                        <Body>



                                         <rx:ComboField runat="server" ID="Entity" FieldLabel="Entity" Width="150" Editable="false"
                                            DisplayField="Label" ValueField="ObjectId" AutoLoad="true" Mode="Remote">
                                            <DataContainer>
                                                <DataSource OnEvent="EntityStoreOnRefreshData">
                                                    <Columns>
                                                        <rx:Column Name="ObjectId" Width="80">
                                                        </rx:Column>
                                                        <rx:Column Name="Label" Width="250">
                                                        </rx:Column>
                                                    </Columns>
                                                </DataSource>
                                            </DataContainer>
                                        </rx:ComboField>
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout runat="server" ID="RowLayout5">
                        <Body>
                            <rx:ComboField runat="server" ID="RunInUser" Width="150" Editable="false" FieldLabel="RunInUser" 
                            DisplayField="Label" ValueField="ObjectId" AutoLoad="true" Mode="Local">
                                <Items>
                                    <rx:ListItem Value="0" Text="Caling User" />
                                    <rx:ListItem Value="1" Text="System Admin" />
                                </Items>
                            </rx:ComboField>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ColumnLayout runat="server" ID="ColoumnLayout2" ColumnWidth="50%">
                <Rows>
                    <rx:RowLayout runat="server" ID="RowLayout6">
                        <Body>
                            <rx:CheckField runat="server" ID="chkbefore" FieldLabel="Önce" Width="150" AjaxPostable="true">
                            </rx:CheckField>
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout runat="server" ID="RowLayout1">
                        <Body>
                            <rx:CheckField runat="server" ID="chkafter" FieldLabel="Sonra" Width="150">
                            </rx:CheckField>
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout runat="server" ID="RowLayout4">
                        <Body>
                            <rx:NumericField runat="server" ID="ExecutionOrder" FieldLabel="ExecutionOrder" Width="150">
                            </rx:NumericField>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
      
    
</td>
</tr>

        </table>

    <rx:GridPanel ID="_grdsma" runat="server" TrackMouseOver="false" AutoWidth="true"
        PostAllData="true" Mode="Remote" AutoHeight="Auto" AutoLoad="true" Width="610"
        AjaxPostable="true" Height="210">
        <DataContainer>
            <DataSource OnEvent="MessageListStoreOnRefreshData">
                <Columns>
                    <rx:Column Name="PluginMessageId">
                    </rx:Column>
                    <rx:Column Name="MessageTypeId">
                    </rx:Column>
                    <rx:Column Name="PluginId">
                    </rx:Column>
                    <rx:Column Name="EntityId">
                    </rx:Column>
                    <rx:Column Name="ObjectId">
                    </rx:Column>
                    <rx:Column Name="EntityName">
                    </rx:Column>
                    <rx:Column Name="Before">
                    </rx:Column>
                    <rx:Column Name="After">
                    </rx:Column>
                    <rx:Column Name="ExecutionOrder">
                    </rx:Column>
                    <rx:Column Name="RunInUser">
                    </rx:Column>
                </Columns>
            </DataSource>
        </DataContainer>
        <ColumnModel>
            <Columns>
                <rx:GridColumns Header="PluginMessageId" DataIndex="PluginMessageId" Hidden="true" />
                <rx:GridColumns Header="MessageTypeId" DataIndex="MessageTypeId" Hidden="true" />
                <rx:GridColumns Header="PluginId" DataIndex="PluginId" Hidden="true" />
                <rx:GridColumns Header="ObjectId" DataIndex="ObjectId" Hidden="true" />
                <rx:GridColumns Header="EntityId" DataIndex="EntityId" Hidden="true" />
                <rx:GridColumns Header="EntityName" DataIndex="EntityName" />
               
                <rx:GridColumns ColumnType="Check" Header="Before" DataIndex="Before">
                </rx:GridColumns>
                <rx:GridColumns ColumnType="Check" Header="After" DataIndex="After">
                </rx:GridColumns>
                <rx:GridColumns Header="ExecutionOrder" DataIndex="ExecutionOrder" Width="50" Hidden="true" />
                <rx:GridColumns Header="RunInUser" DataIndex="RunInUser" Width="50" Hidden="true" />
            </Columns>
        </ColumnModel>
        <LoadMask ShowMask="true" />
        <SelectionModel>
            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" SingleSelect="true">
                <AjaxEvents>
                    <RowClick OnEvent="RowSelectOnEvent">
                    </RowClick>
                </AjaxEvents>
            </rx:RowSelectionModel>
        </SelectionModel>
    </rx:GridPanel>
    </form>
</body>
</html>
