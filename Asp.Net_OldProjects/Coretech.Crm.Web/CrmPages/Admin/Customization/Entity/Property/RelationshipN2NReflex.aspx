<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Customization_Entity_Property_RelationshipN2NReflex" Codebehind="RelationshipN2NReflex.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:Hidden runat="server" ID="hdnentityid">
    </rx:Hidden>
    <rx:Hidden runat="server" ID="hdnattributeid">
    </rx:Hidden>
    <rx:Hidden runat="server" ID="objectid">
    </rx:Hidden>
    <table style="width: 100%">
        <tr>
            <td>
                <rx:ToolBar ID="toolbar2" runat="server">
                    <Items>
                        <rx:ToolbarButton runat="server" ID="btnNew" Icon="Page" Text="New">
                            <AjaxEvents>
                                <Click OnEvent="NewOnEvent">
                                    <EventMask ShowMask="true" />
                                </Click>
                            </AjaxEvents>
                        </rx:ToolbarButton>
                        <rx:ToolbarButton runat="server" ID="btnAdd" Icon="PageAdd" Text="Add">
                            <AjaxEvents>
                                <Click OnEvent="AddOnEvent">
                                    <EventMask ShowMask="true" />
                                </Click>
                            </AjaxEvents>
                        </rx:ToolbarButton>
                        <rx:ToolbarButton runat="server" ID="btnDelete" Icon="PageDelete" Text="Delete">
                            <AjaxEvents>
                                <Click OnEvent="DeleteOnEvent">
                                    <EventMask ShowMask="true" />
                                </Click>
                            </AjaxEvents>
                        </rx:ToolbarButton>
                    </Items>
                </rx:ToolBar>
            </td>
        </tr>
        <tr>
            <td>
                <rx:PanelX runat="server" ID="tabpanel1" AutoHeight="Normal" Height="165" Border="false">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout2" runat="server">
                                    <Body>
                                        <rx:TextField runat="server" ID="DisplayName" dataindex="Label" FieldLabel="Display Name"
                                            Width="150">
                                        </rx:TextField>
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
                                <rx:RowLayout runat="server" ID="RowLayout6">
                                    <Body>
                                        <rx:TextField runat="server" ID="Name" FieldLabel="Name" allowblank="false" maskre="/[A-Za-z0-9_]/">
                                        </rx:TextField>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>
            </td>
        </tr>
    </table>
    <rx:GridPanel ID="_grdsma" runat="server" AutoWidth="true" StripeRows="true" Height="190"
        Mode="Remote" AutoHeight="Auto" AutoLoad="true">
        <DataContainer>
            <DataSource OnEvent="StoreOnRefreshData">
                <Columns>
                    <rx:Column Name="FromObjectId">
                    </rx:Column>
                    <rx:Column Name="ToAttributeId">
                    </rx:Column>
                    <rx:Column Name="AttributeName">
                    </rx:Column>
                    <rx:Column Name="DisplayName">
                    </rx:Column>
                    <rx:Column Name="Name">
                    </rx:Column>
                    <rx:Column Name="Description">
                    </rx:Column>
                </Columns>
            </DataSource>
        </DataContainer>
        <ColumnModel>
            <Columns>
                <rx:GridColumns Header="FromObjectId" DataIndex="FromObjectId" Width="150" Hidden="true" />
                <rx:GridColumns Header="ToAttributeId" DataIndex="ToAttributeId" Width="150" Hidden="true" />
                <rx:GridColumns Header="AttributeName" DataIndex="AttributeName" Width="150" />
                <rx:GridColumns Header="DisplayName" DataIndex="DisplayName" Width="150" />
                <rx:GridColumns Header="Name" DataIndex="Name" Width="150" />
            </Columns>
        </ColumnModel>
        <LoadMask ShowMask="true" />
        <SelectionModel>
            <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" SingleSelect="true">
            </rx:RowSelectionModel>
        </SelectionModel>
    </rx:GridPanel>
    </form>
</body>
</html>
