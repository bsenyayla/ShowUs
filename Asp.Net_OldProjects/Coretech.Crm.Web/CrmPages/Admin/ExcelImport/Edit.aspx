<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_ExcelImport_Edit" Codebehind="Edit.aspx.cs" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<script type="text/javascript">
    function ImportListInsert() {
        ImportList.insertRow();
    }
    function ImportListDelete() {
        if (!R.isEmpty(ImportList.selectedRecord.length > 0)) {
            ImportList.deleteRow();
        }
    }
</script>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:Menu ID="Menu1" runat="server">
        <Items>
            <rx:MenuItem ID="MenuItem1" runat="server" Text="Insert Record" Icon="Add">
                <Listeners>
                    <Click Handler="ImportListInsert();" />
                </Listeners>
            </rx:MenuItem>
            <rx:MenuItem ID="MenuItem2" runat="server" Text="Delete Record" Icon="Delete">
                <Listeners>
                    <Click Handler="ImportListDelete();" />
                </Listeners>
            </rx:MenuItem>
            <%--<rx:MenuSeparator ID="MenuSeparator1" runat="server">
            </rx:MenuSeparator>
            <rx:MenuItem ID="MenuItem3" runat="server" Text="Disable Row Drag" Icon="ArrowBranch">
                <Listeners>
                    <Click Handler="ImportList.disableRowDragable = true;bitlist.disableRowDragable = true;" />
                </Listeners>
            </rx:MenuItem>
            <rx:MenuItem ID="MenuItem4" runat="server" Text="Enable Row Drag" Icon="ArrowOut">
                <Listeners>
                    <Click Handler="ImportList.disableRowDragable = false;bitlist.disableRowDragable = false;" />
                </Listeners>
            </rx:MenuItem>--%>
        </Items>
    </rx:Menu>
    <div style="display: none">
        <rx:Hidden runat="server" ID="RedirectType" Value="1">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnObjectId">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnEntityName">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnEntityId">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnRecid">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnRecidName">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnDefaultEditPageId">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnSavingMessage">
        </rx:Hidden>
        <rx:Hidden ID="FetchXML" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="UpdatedUrl" runat="server">
        </rx:Hidden>
    </div>
    <rx:KeyMap runat="server" ID="KeyMap1">
        <rx:KeyBinding StopEvent="true">
            <Keys>
                <rx:Key Code="ESC">
                    <Listeners>
                        <Event Handler="" />
                    </Listeners>
                </rx:Key>
            </Keys>
        </rx:KeyBinding>
    </rx:KeyMap>
    <rx:ToolBar runat="server" ID="EditToolbar" CustomCss="fixed-toolbar">
        <Items>
            <rx:ToolbarButton runat="server" ID="btnSave" Width="70" Text="Save" Icon="Disk">
                <AjaxEvents>
                    <Click OnEvent="BtnSaveClick">
                        <EventMask ShowMask="true" />
                        <ExtraParams>
                            <rx:Parameter Name="Action" Value="1"></rx:Parameter>
                        </ExtraParams>
                    </Click>
                </AjaxEvents>
            </rx:ToolbarButton>
            <rx:ToolbarButton runat="server" ID="btnSaveAndClose" Width="120" Text="Save And Close"
                Icon="DiskBlack">
                <AjaxEvents>
                    <Click OnEvent="BtnSaveClick">
                        <EventMask ShowMask="true" />
                        <ExtraParams>
                            <rx:Parameter Name="Action" Value="3"></rx:Parameter>
                        </ExtraParams>
                    </Click>
                </AjaxEvents>
            </rx:ToolbarButton>
            <rx:ToolbarButton runat="server" ID="btnDelete" Width="100" Text="Delete" Icon="Delete">
                <Listeners>
                    <Click Handler="BtnDelete_Click()" />
                </Listeners>
            </rx:ToolbarButton>
        </Items>
    </rx:ToolBar>
    <rx:PanelX runat="server" ID="PnlMain" Frame="false" Border="false" AutoHeight="Full"
        AutoWidth="true">
        <Body>
            <rx:ColumnLayout runat="server" ID="c1" ColumnWidth="50%">
                <Rows>
                    <rx:RowLayout ID="RowLayout2" runat="server">
                        <Body>
                            <cc1:CrmTextFieldComp RequirementLevel="BusinessRequired" ID="ImportDefinationName"
                                runat="server" ObjectId="48" UniqueName="ImportDefinationName" FieldLabelWidth="100"
                                Width="130" CaseType="Normal">
                            </cc1:CrmTextFieldComp>
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout ID="RowLayout3" runat="server">
                        <Body>
                            <cc1:CrmComboComp ID="EntityId" RequirementLevel="BusinessRequired" runat="server"
                                ObjectId="48" UniqueName="EntityId" FieldLabelWidth="100" Width="130">
                            </cc1:CrmComboComp>
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout ID="RowLayout4" runat="server">
                        <Body>
                            <cc1:CrmPicklistComp RequirementLevel="BusinessRequired" ID="TransactionRollbackType" 
                                runat="server" ObjectId="48" UniqueName="TransactionRollbackType" FieldLabelWidth="100" 
                                Width="130">
                            </cc1:CrmPicklistComp>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="50%">
                <Rows>
                    <rx:RowLayout ID="RowLayout5" runat="server">
                        <Body>
                            <cc1:CrmComboComp RequirementLevel="BusinessRequired" ID="RecordOwner" runat="server"
                                ObjectId="48" UniqueName="RecordOwner" FieldLabelWidth="100" Width="130">
                            </cc1:CrmComboComp>
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout ID="RowLayout1" runat="server">
                        <Body>
                            <cc1:CrmTextFieldComp  ID="Template" runat="server"
                                ObjectId="48" UniqueName="Template" FieldLabelWidth="100" Width="130">
                            </cc1:CrmTextFieldComp>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
        </Body>
    </rx:PanelX>
    
    <rx:GridPanel ID="ImportList" runat="server" Width="200" Height="200" Mode="Local"
        PostAllData="true" ContextMenuId="Menu1" Editable="true" DisableSelection="true"
        AutoLoad="true">
        
        <DataContainer>
            <DataSource>
                <Columns>
                    <rx:Column Name="ExcelColumnName">
                    </rx:Column>
                    <rx:Column Name="TargetAtrributeId">
                    </rx:Column>
                    <rx:Column Name="TargetAtrributeIdName">
                    </rx:Column>
                    <rx:Column Name="CustomMapAtrributeId">
                    </rx:Column>
                    <rx:Column Name="CustomMapAtrributeIdName">
                    </rx:Column>
                    <rx:Column Name="IsNotNullable">
                    </rx:Column>

                </Columns>
            </DataSource>
        </DataContainer>
        <ColumnModel>
            <Columns>
                <rx:GridColumns ColumnId="ExcelColumnName" DataIndex="ExcelColumnName" Header="ExcelColumnName"
                    Width="300" Sortable="false" MenuDisabled="true">
                    <Editor>
                        <Component>
                            <rx:TextField runat="server" ID="EditExcelColumnName">
                            </rx:TextField>
                        </Component>
                    </Editor>
                </rx:GridColumns>
                <rx:GridColumns Header="TargetAtrributeIdName" DataIndex="TargetAtrributeIdName"
                    MenuDisabled="true" Width="300" Hidden="false" Sortable="false">
                    <Editor DisplayDataIndex="TargetAtrributeIdName" ValueDataIndex="TargetAtrributeId">
                        <Component>
                            <rx:ComboField runat="server" ID="EditTargetAtrributeId" Width="150" Editable="false"
                                DisplayField="EditTargetAtrributeIdName" ValueField="EditTargetAtrributeId" AutoLoad="true"
                                Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="EditTargetAtrributeIdOnRefreshData">
                                        <Columns>
                                            <rx:Column Name="EditTargetAtrributeId" Hidden="true">
                                            </rx:Column>
                                            <rx:Column Name="EditTargetAtrributeIdName">
                                            </rx:Column>
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </rx:ComboField>
                        </Component>
                    </Editor>
                </rx:GridColumns>
                <rx:GridColumns Header="CustomMapAtrributeIdName" DataIndex="CustomMapAtrributeIdName"
                    Width="300" Hidden="false" Sortable="false">
                    <Editor DisplayDataIndex="CustomMapAtrributeIdName" ValueDataIndex="CustomMapAtrributeId">
                        <Component>
                            <rx:ComboField runat="server" ID="EditCustomMapAtrributeId" Width="150" Editable="false"
                                DisplayField="EditCustomMapAtrributeIdName" ValueField="EditCustomMapAtrributeId"
                                AutoLoad="true" Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="EditCustomMapAtrributeIdOnRefreshData">
                                        <Columns>
                                            <rx:Column Name="EditCustomMapAtrributeId" Hidden="true">
                                            </rx:Column>
                                            <rx:Column Name="EditCustomMapAtrributeIdName">
                                            </rx:Column>
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </rx:ComboField>
                        </Component>
                    </Editor>
                </rx:GridColumns>
                <rx:GridColumns Header="IsNotNullable" DataIndex="IsNotNullable"
                    Width="100" Hidden="false" Sortable="false" ColumnType="Check" Editable="True">
                   
                </rx:GridColumns>
            </Columns>
        </ColumnModel>
        <SelectionModel>
            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server">
            </rx:RowSelectionModel>
        </SelectionModel>
    </rx:GridPanel>
    </form>
</body>
</html>
<script>
    function BtnDelete_Click() {
        Myform = window;
        alert(hdnObjectId.getValue());
        try {
            window.top.GlobalDelete(Myform, null, hdnObjectId.getValue())
        } catch (e) {
            if (confirm(GetMessages("CRM_RECORD_WILL_DELETE_ARE_YOU_SURE"))) {
                var result = AjaxMethods.GlobalDelete("", hdnRecid.getValue(), hdnObjectId.getValue()).value
                if (result.Result == "0") {
                    alert(result.ErrorMessage)
                } else {
                    RefreshParetnGrid(true)
                }
            }
        }
    }   
</script>
