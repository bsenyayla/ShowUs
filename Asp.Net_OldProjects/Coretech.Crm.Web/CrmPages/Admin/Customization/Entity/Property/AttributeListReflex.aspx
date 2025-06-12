<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Customization_Entity_Property_AttributeListReflex" Codebehind="AttributeListReflex.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script type="text/javascript">
        function PickListInsert() {
            picklist.insertRow();
        }
        function PickListDelete() {
            if (!R.isEmpty(picklist.selectedRecord.length > 0)) {
                picklist.deleteRow();
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR" />
    <rx:Hidden runat="server" ID="hdnentityid">
    </rx:Hidden>
    <rx:Hidden runat="server" ID="hdnattributeid">
    </rx:Hidden>
    <table style="width: 100%">
        <tr>
            <td>
                <rx:ToolBar ID="Toolxbar2" runat="server" AutoWidth="true">
                    <Items>
                        <rx:ToolbarButton runat="server" ID="btnNew" Icon="Page" Text="New">
                            <AjaxEvents>
                                <Click OnEvent="NewOnEvent">
                                </Click>
                            </AjaxEvents>
                        </rx:ToolbarButton>
                        <rx:ToolbarButton runat="server" ID="btnAdd" Icon="PageAdd" Text="Add">
                            <AjaxEvents>
                                <Click OnEvent="AddOnEvent">
                                </Click>
                            </AjaxEvents>
                        </rx:ToolbarButton>
                        <rx:ToolbarButton runat="server" ID="btnDelete" Icon="PageDelete" Text="Delete">
                            <AjaxEvents>
                                <Click OnEvent="DeleteOnEvent">
                                </Click>
                            </AjaxEvents>
                        </rx:ToolbarButton>
                    </Items>
                </rx:ToolBar>
                <rx:PanelX ID="PanelX1" runat="server" AutoWidth="true" AutoHeight="Normal" Height="210">
                    <Body>
                        <rx:ColumnLayout ID="ColumnLayout1" runat="server" ColumnWidth="45%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout1" runat="server">
                                    <Body>
                                        <rx:TextField runat="server" ID="DisplayName" FieldLabel="Display Name" Width="150">
                                        </rx:TextField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout3" runat="server">
                                    <Body>
                                        <rx:TextField runat="server" ID="Name" FieldLabel="Name" Width="150">
                                        </rx:TextField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout4" runat="server">
                                    <Body>
                                        <rx:ComboField runat="server" ID="Level" FieldLabel="Level" Width="150" Editable="false"
                                            Mode="Local">
                                            <Items>
                                                <rx:ListItem Value="0" Text="No Constraint" />
                                                <rx:ListItem Value="1" Text="Business Recommend" />
                                                <rx:ListItem Value="2" Text="Business Required" />
                                            </Items>
                                        </rx:ComboField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout5" runat="server">
                                    <Body>
                                        <rx:TextAreaField runat="server" ID="txtDescription" Width="400" FieldLabel="Description"
                                            MaxLength="500" AllowBlank="false">
                                        </rx:TextAreaField>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <rx:ColumnLayout ID="ColumnLayout2" runat="server" ColumnWidth="45%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout2" runat="server">
                                    <Body>
                                        <rx:ComboField runat="server" ID="Type" FieldLabel="Type" Width="150" Editable="false">
                                            <AjaxEvents>
                                                <Change OnEvent="TypeOnChangeEvent">
                                                </Change>
                                            </AjaxEvents>
                                        </rx:ComboField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout6" runat="server">
                                    <Body>
                                        <rx:ComboField runat="server" ID="Format" FieldLabel="Format" Width="150" Editable="false">
                                        </rx:ComboField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout7" runat="server">
                                    <Body>
                                        <rx:NumericField runat="server" ID="MaxLength" FieldLabel="Max Length" Width="150">
                                        </rx:NumericField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout13" runat="server">
                                    <Body>
                                        <rx:ComboField runat="server" ID="DefaultValue" FieldLabel="Default Value" Width="150"
                                            Editable="false">
                                        </rx:ComboField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout12" runat="server">
                                    <Body>
                                        <rx:GridPanel ID="picklist" runat="server" Width="200" Height="200" Mode="Remote"
                                            PostAllData="true" ContextMenuId="Menu1" Editable="true" DisableSelection="true"
                                            FieldLabel="Pick List Values" AutoLoad="true">
                                            <DataContainer>
                                                <DataSource OnEvent="PicklistStoreOnRefreshData">
                                                    <Columns>
                                                        <rx:Column Name="PickValue" />
                                                        <rx:Column Name="PickLabel" />
                                                    </Columns>
                                                </DataSource>
                                            </DataContainer>
                                            <SelectionModel>
                                                <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" RowDragable="true" SingleSelect="true">
                                                </rx:RowSelectionModel>
                                            </SelectionModel>
                                            <ColumnModel>
                                                <Columns>
                                                    <rx:GridColumns Header="Value" DataIndex="PickValue" Width="50" MenuDisabled="true"
                                                        Sortable="false">
                                                        <Editor>
                                                            <Component>
                                                                <rx:NumericField ID="EPValue" runat="server">
                                                                </rx:NumericField>
                                                            </Component>
                                                        </Editor>
                                                    </rx:GridColumns>
                                                    <rx:GridColumns Header="Label" DataIndex="PickLabel" Width="200" MenuDisabled="true"
                                                        Sortable="false">
                                                        <Editor>
                                                            <Component>
                                                                <rx:TextField ID="EPLabel" runat="server">
                                                                </rx:TextField>
                                                            </Component>
                                                        </Editor>
                                                    </rx:GridColumns>
                                                </Columns>
                                            </ColumnModel>
                                            <AjaxEvents>
                                                <UpdateCellAfter OnEvent="PicklistDefault">
                                                    <EventMask ShowMask="false" />
                                                </UpdateCellAfter>
                                            </AjaxEvents>
                                        </rx:GridPanel>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout14" runat="server">
                                    <Body>
                                        <rx:GridPanel ID="bitlist" runat="server" Width="200" Height="150" Mode="Remote"
                                            PostAllData="true" ContextMenuId="Menu1" Editable="true" DisableSelection="true"
                                            FieldLabel="Bit List Values" AutoLoad="true">
                                            <DataContainer>
                                                <DataSource OnEvent="BitStoreOnRefreshData">
                                                    <Columns>
                                                        <rx:Column Name="BitValue" />
                                                        <rx:Column Name="BitLabel" />
                                                    </Columns>
                                                </DataSource>
                                            </DataContainer>
                                            <SelectionModel>
                                                <rx:RowSelectionModel ID="RowSelectionModel3" runat="server" RowDragable="true" SingleSelect="true">
                                                </rx:RowSelectionModel>
                                            </SelectionModel>
                                            <ColumnModel>
                                                <Columns>
                                                    <rx:GridColumns Header="Value" DataIndex="BitValue" Width="50" MenuDisabled="true"
                                                        Sortable="false">
                                                        <Editor>
                                                            <Component>
                                                                <rx:NumericField ID="NumericField1" runat="server">
                                                                </rx:NumericField>
                                                            </Component>
                                                        </Editor>
                                                    </rx:GridColumns>
                                                    <rx:GridColumns Header="Label" DataIndex="BitLabel" Width="300" MenuDisabled="true"
                                                        Sortable="false">
                                                        <Editor>
                                                            <Component>
                                                                <rx:TextField ID="TextField1" runat="server">
                                                                </rx:TextField>
                                                            </Component>
                                                        </Editor>
                                                    </rx:GridColumns>
                                                </Columns>
                                            </ColumnModel>
                                        </rx:GridPanel>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout8" runat="server">
                                    <Body>
                                        <rx:NumericField runat="server" ID="Precision" FieldLabel="Precision" Width="150">
                                        </rx:NumericField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout9" runat="server">
                                    <Body>
                                        <rx:NumericField runat="server" ID="MinValue" FieldLabel="Min Value" Width="150"
                                            AllowDecimals="true" MaxLength="38">
                                        </rx:NumericField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout10" runat="server">
                                    <Body>
                                        <rx:NumericField runat="server" ID="MaxValue" FieldLabel="Max Value" Width="150"
                                            DecimalPrecision="0" AllowDecimals="true" MaxLength="38">
                                        </rx:NumericField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout11" runat="server">
                                    <Body>
                                        <rx:ComboField runat="server" ID="CaseMode" FieldLabel="CaseMode" Width="150" Editable="false">
                                            <Listeners>
                                                <Blur Handler="if(CaseMode.getValue()=='8'){AllowKeys.show();}else{AllowKeys.clear();AllowKeys.hide();}" />
                                            </Listeners>
                                        </rx:ComboField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout16" runat="server">
                                    <Body>
                                        <rx:CheckField runat="server" ID="IsLoggable" FieldLabel="IsLoggable"></rx:CheckField>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout15" runat="server">
                                    <Body>
                                        <rx:ComboField runat="server" ID="AllowKeys" FieldLabel="AllowKeys" Width="150" Editable="false"
                                            Hidden="true" ValueField="CustomTextModeId" DisplayField="CustomTextModeName" AutoLoad="true" Mode="Remote">
                                            <DataContainer>
                                                <DataSource OnEvent="AllowKeysOnEvent">
                                                    <Columns>
                                                        <rx:Column Name="CustomTextModeId" Hidden="true" />
                                                        <rx:Column Name="CustomTextModeName" />
                                                    </Columns>
                                                </DataSource>
                                            </DataContainer>
                                        </rx:ComboField>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>
            </td>
        </tr>
    </table>
    <rx:Menu ID="Menu1" runat="server">
        <Items>
            <rx:MenuItem ID="MenuItem1" runat="server" Text="Insert Record" Icon="Add">
                <Listeners>
                    <Click Handler="PickListInsert();" />
                </Listeners>
            </rx:MenuItem>
            <rx:MenuItem ID="MenuItem2" runat="server" Text="Delete Record" Icon="Delete">
                <Listeners>
                    <Click Handler="PickListDelete();" />
                </Listeners>
            </rx:MenuItem>
            <rx:MenuSeparator ID="MenuSeparator1" runat="server">
            </rx:MenuSeparator>
            <rx:MenuItem ID="MenuItem3" runat="server" Text="Disable Row Drag" Icon="ArrowBranch">
                <Listeners>
                    <Click Handler="picklist.disableRowDragable = true;bitlist.disableRowDragable = true;" />
                </Listeners>
            </rx:MenuItem>
            <rx:MenuItem ID="MenuItem4" runat="server" Text="Enable Row Drag" Icon="ArrowOut">
                <Listeners>
                    <Click Handler="picklist.disableRowDragable = false;bitlist.disableRowDragable = false;" />
                </Listeners>
            </rx:MenuItem>
        </Items>
    </rx:Menu>
    <rx:GridPanel ID="_grdsma" runat="server" AutoWidth="true" AutoHeight="Auto" Mode="Remote"
        DisableSelection="true" AutoLoad="true">
        <DataContainer>
            <DataSource OnEvent="StoreOnRefreshData">
                <Columns>
                    <rx:Column Name="AttributeId" DataType="String" />
                    <rx:Column Name="AttributeTypeIdname" DataType="String" />
                    <rx:Column Name="Label" DataType="String" />
                    <rx:Column Name="Name" DataType="String" />
                    <rx:Column Name="Length" DataType="Int" />
                    <rx:Column Name="CaseModeValue" DataType="Int" />
                    <rx:Column Name="AllowKeys" DataType="String" />
                    <rx:Column Name="FormatType" DataType="Int" />
                    <rx:Column Name="MaxLength" DataType="Decimal" />
                    <rx:Column Name="Precision" DataType="Decimal" />
                    <rx:Column Name="MinValue" DataType="Decimal" />
                    <rx:Column Name="MaxValue" DataType="Decimal" />
                    <rx:Column Name="DefaultValue" DataType="String" />
                    <rx:Column Name="IsSortAttribute" DataType="String" />
                    <rx:Column Name="AttributeTypeId" DataType="String" />
                    <rx:Column Name="RequirementLevel" DataType="String" />
                    <rx:Column Name="Description" DataType="String" />
                    <rx:Column Name="IsLoggable" DataType="Boolean" />
                </Columns>
            </DataSource>
        </DataContainer>
        <ColumnModel>
            <Columns>
                <rx:GridColumns Header="Name" DataIndex="Name" Width="250" MenuDisabled="true" Sortable="false" />
                <rx:GridColumns Header="Label" DataIndex="Label" Width="250" MenuDisabled="true"
                    Sortable="false" />
                <rx:GridColumns Header="AttributeTypeIdname" DataIndex="AttributeTypeIdname" Width="80"
                    MenuDisabled="true" Sortable="false" />
                <rx:GridColumns Header="MaxLength" DataIndex="MaxLength" Width="80" MenuDisabled="true"
                    Sortable="false" />
                <rx:GridColumns Header="DefaultValue" DataIndex="DefaultValue" Width="80" MenuDisabled="true"
                    Sortable="false" />
                <rx:GridColumns Header="MaxValue" DataIndex="MaxValue" Width="150" MenuDisabled="true"
                    Sortable="false" />
                <rx:GridColumns Header="IsLoggable" DataIndex="IsLoggable" Width="150" MenuDisabled="true"
                    Sortable="false" />
            </Columns>
        </ColumnModel>
        <LoadMask ShowMask="true" />
        <SelectionModel>
            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" SingleSelect="true">
                <Listeners>
                    <RowClick Handler="picklist.setHeight(150);" />
                </Listeners>
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
