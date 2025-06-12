<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_WorkFlow_Reflex_EditReflex"
    ValidateRequest="false" EnableViewState="false" Codebehind="EditReflex.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="CrmUI" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/Wf.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <style type="text/css">
        #loading-mask
        {
            position: absolute;
            top: 0;
            left: 0;
            width: 99%;
            height: 99%;
            z-index: 70000;
            background: #c8cbd0;
            opacity: 10;
            -moz-opacity: 0.10;
            filter: alpha(opacity=10);
            border: 0;
            font-family: tahoma,arial,verdana,sans-serif;
            font-size: 11px;
            font-weight: bold;
        }
        
        #loading
        {
            position: absolute;
            top: 40%;
            left: 45%;
            z-index: 70001;
        }
        #loading SPAN
        {
            color: white;
            font-family: Arial;
            font-size: small;
            background: url('<%=GlobalConfig.Settings.ResourcePath%>/Themes/Slate/Images/loading.gif') no-repeat left center;
            padding: 5px 30px;
            display: block;
        }
        .fixed-toolbar
        {
            position: fixed !important;
            top: 0px;
            width: 96%;
            z-index: 8999;
        }
        .fixed-label
        {
            position: absolute;
            top: 0px;
        }
        .crm-field-yellow
        {
            background-color: #EDEDED !important;
        }
        SPAN.DataSlugStyle
        {
            tab-index: -1;
            background-color: #FFFF33;
            height: 17px;
            padding-top: 1px;
            padding-right: 2px;
            padding-left: 2px;
            overflow-y: hidden;
        }
        div.RadiusDiv
        {
            float: left;
            margin-top: 20px;
            margin-right: 40px;
            text-align: center;
            -webkit-border-radius: 15px;
            -moz-border-radius: 15px;
            border-radius: 15px;
        }
    </style>
</head>
<body>
    <%--<div id="loading-mask">
        <div id="loading">
            <span id="loading-message"></span>
        </div>
    </div>--%>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR" />
    <div style="display: none">
        <ajx:Hidden runat="server" ID="hdnObjectId">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnEntityName">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnEntityId">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnRecid">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnDefaultEditPageId">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnSavingMessage">
        </ajx:Hidden>
        <ajx:Hidden ID="FetchXML" runat="server">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="UpdatedUrl">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnDDAction">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnDDParentAction">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="RedirectType" Value="1">
        </ajx:Hidden>
    </div>
    <ajx:Window ID="WindowChancedColumns" runat="server" Title="Set Value" Height="600"
        Border="false" Resizable="false" CloseAction="Hide" Width="400" Modal="true"
        Icon="ArrowRotateAnticlockwise" ShowOnLoad="false" Maximizable="false">
        <Body>
            <ajx:PanelX runat="server" ID="WindowChancedColumnsPnl" Height="500" AutoHeight="Normal">
                <Body>
                    <ajx:GridPanel runat="server" ID="GridChangedColumns" AutoWidth="true" AutoHeight="Normal" 
                        Height="500" Editable="false" Mode="Local" AutoLoad="false" Width="1200" AjaxPostable="true">
                        <DataContainer>
                            <DataSource>
                                <Columns>
                                    <ajx:Column Name="Label" Title="Column Name" Hidden="true" DataType="String" />
                                    <ajx:Column Name="AttributeId" Title="AttributeId" DataType="String" />
                                </Columns>
                            </DataSource>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <ajx:GridColumns ColumnId="Label" DataIndex="Label" Header="Column Name" Width="300"
                                    MenuDisabled="true" />
                            </Columns>
                        </ColumnModel>
                        <Items>
                        </Items>
                        <SelectionModel>
                            <ajx:CheckSelectionModel ID="GridChangedColumnsCheckSelectionModel" runat="server"
                                ShowNumber="false">
                            </ajx:CheckSelectionModel>
                        </SelectionModel>
                        <LoadMask ShowMask="true" />
                    </ajx:GridPanel>
                </Body>
            </ajx:PanelX>
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowChancedColumnsSave" Icon="ScriptSave" Text="Ok">
                <Listeners>
                    <Click Handler="WindowChancedColumns.hide();" />
                </Listeners>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    <ajx:PanelX runat="server" ID="PanelX2" Height="20" AutoHeight="Normal">
        <Body>
            <ajx:ToolBar runat="server" ID="EditToolbar" CustomCss="fixed-toolbar">
                <Items>
                    <ajx:ToolbarButton runat="server" ID="btnSave" Width="70" Text="Save" Icon="Disk">
                        <AjaxEvents>
                            <Click OnEvent="BtnSaveClick">
                                <EventMask ShowMask="true" />
                                <ExtraParams>
                                    <ajx:Parameter Name="Action" Value="1"></ajx:Parameter>
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="btnSaveAndNew" Width="120" Text="Save And New"
                        Icon="DiskMultiple">
                        <AjaxEvents>
                            <Click OnEvent="BtnSaveClick">
                                <EventMask ShowMask="true" />
                                <ExtraParams>
                                    <ajx:Parameter Name="Action" Value="2"></ajx:Parameter>
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="btnSaveAndClose" Width="120" Text="Save And Close"
                        Icon="DiskBlack">
                        <AjaxEvents>
                            <Click OnEvent="BtnSaveClick">
                                <EventMask ShowMask="true" />
                                <ExtraParams>
                                    <ajx:Parameter Name="Action" Value="3"></ajx:Parameter>
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="btnSaveAsCopy" Width="120" Text="Save As Copy"
                        Icon="PageCopy">
                        <AjaxEvents>
                            <Click OnEvent="BtnSaveClick">
                                <EventMask ShowMask="true" />
                                <ExtraParams>
                                    <ajx:Parameter Name="Action" Value="4"></ajx:Parameter>
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="btnDDSave" Width="120" Text="Save As Copy"
                        Hidden="true" Icon="PageCopy">
                        <AjaxEvents>
                            <Click OnEvent="BtnSaveClick">
                                <EventMask ShowMask="true" />
                                <ExtraParams>
                                    <ajx:Parameter Name="Action" Value="hdnDDAction.getValue();" Mode="Raw"></ajx:Parameter>
                                    <ajx:Parameter Name="ParentAction" Value="hdnDDParentAction.getValue();" Mode="Raw">
                                    </ajx:Parameter>
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="btnDelete" Width="100" Text="Delete" Icon="Delete">
                        <Listeners>
                            <Click Handler="BtnDelete_Click()" />
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarFill runat="server" ID="ToolbarFill1">
                    </ajx:ToolbarFill>
                    <ajx:ToolbarButton runat="server" ID="btnPublish" minwidth="70" Icon="Plugin" Text="Publish">
                        <AjaxEvents>
                            <Click OnEvent="btnPublishClickOnEvent">
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" Icon="ArrowRefresh" Width="100" ID="btnRefresh"
                        Text="Refresh">
                        <Listeners>
                            <Click Handler="location.reload(true);" />
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:Label ID="lblInfo" runat="server" Icon="Information" Width="20">
                        <Listeners>
                            <Click Handler="ShowPageInfo();" />
                        </Listeners>
                    </ajx:Label>
                </Items>
            </ajx:ToolBar>
        </Body>
    </ajx:PanelX>
    <ajx:Fieldset runat="server" Title="_" ID="pnl1" Height="80" AutoHeight="Normal">
        <Body>
            <ajx:ColumnLayout runat="server" ID="cl0" ColumnWidth="50%">
                <Rows>
                    <ajx:RowLayout runat="server">
                        <Body>
                            <CrmUI:CrmTextFieldComp ID="WorkflowName" runat="server" Width="450" ObjectId="10"
                                UniqueName="workflowname" />
                        </Body>
                    </ajx:RowLayout>
                    <ajx:RowLayout runat="server">
                        <Body>
                            <CrmUI:CrmComboComp ID="EntityCrmLookupComp" RequirementLevel="BusinessRequired"
                                ObjectId="10" UniqueName="Entity" runat="server" FieldLabel="CRM.ENTITY_ENTITYNAME">
                            </CrmUI:CrmComboComp>
                        </Body>
                    </ajx:RowLayout>
                </Rows>
            </ajx:ColumnLayout>
            <ajx:ColumnLayout ID="ColumnLayout1" runat="server" ColumnWidth="50%">
                <Rows>
                    <ajx:RowLayout runat="server" ID="rl1">
                        <Body>
                            <CrmUI:CrmBooleanComp ID="StartCreate" runat="server" ObjectId="10" UniqueName="StartCreate" />
                        </Body>
                    </ajx:RowLayout>
                    <ajx:RowLayout runat="server">
                        <Body>
                            <CrmUI:CrmBooleanComp ID="StartDelete" runat="server" ObjectId="10" UniqueName="StartDelete" />
                        </Body>
                    </ajx:RowLayout>
                    <ajx:RowLayout ID="RowLayout1" runat="server">
                        <Body>
                            <CrmUI:CrmMultiFieldComp runat="server" ID="m1" UniqueName="StartChange" ObjectId="10">
                                <Items>
                                    <CrmUI:CrmBooleanComp ID="StartChange" runat="server" ObjectId="10" FieldLabelShow="false"
                                        UniqueName="StartChange">
                                        <Listeners>
                                            <Change Handler="StartChange_onChange()" />
                                        </Listeners>
                                    </CrmUI:CrmBooleanComp>
                                    <ajx:Button ID="btnChangeItems" runat="server" Text="..." Icon="Add" Disabled="false">
                                        <listeners>
                                            <Click Handler="WindowChancedColumns.show();" />
                                        </listeners>
                                    </ajx:Button>
                                </Items>
                            </CrmUI:CrmMultiFieldComp>
                        </Body>
                    </ajx:RowLayout>
                </Rows>
            </ajx:ColumnLayout>
        </Body>
    </ajx:Fieldset>
    <ajx:Fieldset ID="pnlConfig" runat="server" Title="_">
        <Body>
            <ajx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="50%">
                <Rows>
                    <ajx:RowLayout ID="RowLayout2" runat="server">
                        <Body>
                            <CrmUI:CrmBooleanComp ID="IsClientWorkflow" runat="server" ObjectId="10" UniqueName="IsClientWorkflow" />
                        </Body>
                    </ajx:RowLayout>
                    <ajx:RowLayout ID="RowLayout3" runat="server">
                        <Body>
                            <CrmUI:CrmBooleanComp ID="IsOnDemandWorkflow" runat="server" ObjectId="10" UniqueName="IsOnDemandWorkflow" />
                        </Body>
                    </ajx:RowLayout>
                </Rows>
            </ajx:ColumnLayout>
            <ajx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="50%">
                <Rows>
                    <ajx:RowLayout ID="RowLayout4" runat="server">
                        <Body>
                            <CrmUI:CrmPicklistComp runat="server" ID="RunInUser" ObjectId="10" UniqueName="RunInUser">
                            </CrmUI:CrmPicklistComp>
                        </Body>
                    </ajx:RowLayout>
                </Rows>
            </ajx:ColumnLayout>
        </Body>
    </ajx:Fieldset>
    <ajx:TreeGrid runat="server" ID="WItems" Title="Wf List" Width="800" Height="600"
        Mode="Local" Checkable="false" AutoWidth="true" AutoHeight="Auto" Collapsible="false"
        Draggable="true">
        <TopBar>
            <ajx:ToolBar ID="ToolBar2" runat="server">
                <Items>
                    <ajx:ToolbarButton ID="BtnDetailAction" MenuClickType="Full" runat="server" Text="Action">
                        <Menu>
                            <ajx:Menu ID="BtnDetailActionMenu" runat="server">
                                <Items>
                                    <ajx:MenuItem ID="BtnAddNewCondition" Enabled="false" Icon="Add" Text="Add New If Condition"
                                        runat="server">
                                        <Listeners>
                                            <Click Handler="NewActions.Show(WorkflowStepType.IfCondition);" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                    <ajx:MenuItem ID="BtnAddNewWaitCondition" Enabled="false" Icon="Add" Text="Add New Wait Condition"
                                        runat="server">
                                        <Listeners>
                                            <Click Handler="BtnAddNewWaitCondition_Click()" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                    <ajx:MenuItem ID="BtnAddNewRecord" Enabled="false" Icon="Add" Text="Add New Record"
                                        runat="server">
                                        <Listeners>
                                            <Click Handler="NewActions.Show(WorkflowStepType.Create);" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                    <ajx:MenuItem ID="BtnAddUpdateRecord" Enabled="false" Icon="Add" Text="Add Update Record"
                                        runat="server">
                                        <Listeners>
                                            <Click Handler="NewActions.Show(WorkflowStepType.Update);" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                    <ajx:MenuItem ID="BtnAddNewMessage" Enabled="false" Icon="Add" Text="Add Message "
                                        runat="server">
                                        <Listeners>
                                            <Click Handler="NewActions.Show(WorkflowStepType.ShowMessage);" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                    <ajx:MenuItem ID="BtnAddDynamicLink" Enabled="false" Icon="Add" Text="Add Dynamic Link (Window) "
                                        runat="server">
                                        <Listeners>
                                            <Click Handler="NewActions.Show(WorkflowStepType.DynamicUrl);" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                    <ajx:MenuItem ID="MenuItem1" Enabled="false" Icon="Add" Text="Redirect Form " runat="server">
                                        <Listeners>
                                            <Click Handler="NewActions.Show(WorkflowStepType.RedirectForm);" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                    <ajx:MenuItem Enabled="false" Icon="Add" Text="Add Batch Script" runat="server">
                                        <Listeners>
                                            <Click Handler="NewActions.Show(WorkflowStepType.BatchScript);" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                    <ajx:MenuItem ID="MenuItem2" Enabled="false" Icon="Plugin" Text="Call Plugin " runat="server">
                                        <Listeners>
                                            <Click Handler="NewActions.Show(WorkflowStepType.Plugin);" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                    <ajx:MenuItem ID="MenuItem3" Enabled="false" Icon="ChartOrganisation" Text="Call Sub Workflow " runat="server">
                                        <Listeners>
                                            <Click Handler="NewActions.Show(WorkflowStepType.Workflow);" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                    
                                    <ajx:MenuItem ID="BtnStopWorkFlow" Enabled="false" Icon="Stop" Text="Stop Workflow"
                                        runat="server">
                                        <Listeners>
                                            <Click Handler="NewActions.Show(WorkflowStepType.StopWorkFlow);" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                </Items>
                            </ajx:Menu>
                        </Menu>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" Text="Expand All" ID="BExpand">
                        <Listeners>
                            <%--<Click Handler="#{WItems}.expandAll();" />--%>
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" Text="Collapse All" ID="BCollapse">
                        <Listeners>
                            <%--<Click Handler="#{WItems}.collapseAll();" />--%>
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton ID="BDelete" runat="server" Text="Delete Selected" Icon="Delete">
                        <Listeners>
                            <Click Handler="WfBuilder.RemoveNode();" />
                        </Listeners>
                    </ajx:ToolbarButton>
                </Items>
            </ajx:ToolBar>
        </TopBar>
        <Columns>
            <ajx:TreeGridColumn DataIndex="text" Width="230" Header="Workflows" />
            <ajx:TreeGridColumn DataIndex="id" Width="230" Hidden="true" />
            <ajx:TreeGridColumn DataIndex="Type" Width="230" Hidden="true" />
            <ajx:TreeGridColumn DataIndex="ClauseValue" Width="230" Hidden="true" />
            <ajx:TreeGridColumn DataIndex="ClauseText" Width="230" Hidden="true" />
            <ajx:TreeGridColumn DataIndex="data" Width="230" Hidden="true" />
        </Columns>
        <Root>
            <Nodes>
            </Nodes>
            <Listeners>
                <DblClick Handler="WfBuilder.ShowEdit(WorkflowAction.Update,'');" />
            </Listeners>
        </Root>
    </ajx:TreeGrid>
    <ajx:Window ID="WindowIfCondition" runat="server" Title="IF Contition" Height="600"
        Border="false" Resizable="false" CloseAction="Hide" Width="800" Modal="true"
        Icon="ArrowRotateAnticlockwise" ShowOnLoad="false" Maximizable="false">
        <Body>
            <ajx:PanelX runat="server" ID="PanelIfConditionName" Height="20" AutoHeight="Normal">
                <Body>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="100%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout5" runat="server">
                                <Body>
                                    <ajx:TextField ID="IfConditionName" runat="server" Width="450" ObjectId="10" FieldLabel="Condition Name"
                                        RequirementLevel="BusinessRequired" />
                                    <ajx:Hidden runat="server" ID="IfconditionHdnObjectId">
                                    </ajx:Hidden>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                </Body>
            </ajx:PanelX>
            <ajx:PanelX runat="server" ID="pnlIfAttributes" Title="Attributes" Height="100" AutoHeight="Normal">
                <Buttons>
                    <ajx:Button ID="btnIfConditionAdd" runat="server" Icon="ArrowDown" Text="Add Condition">
                        <%--<Listeners>
                            <Click Handler="IFCondition.AddCondition();" />
                        </Listeners>--%>
                        <AjaxEvents>
                            <Click OnEvent="btnIfConditionAddClick_OnEvent">
                            </Click>
                        </AjaxEvents>
                        <Menu>
                            <ajx:Menu runat="server" ID="btnIfConditionAddMenu">
                                <Items>
                                    <ajx:MenuItem ID="btnIfAttributesAddAnd" Enabled="false" Icon="Folder" Text="And"
                                        runat="server">
                                        <Listeners>
                                            <Click Handler="IFCondition.AddAnd()" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                    <ajx:MenuItem ID="btnIfAttributesAddAOr" Enabled="false" Icon="Folder" Text="OR"
                                        runat="server">
                                        <Listeners>
                                            <Click Handler="IFCondition.AddOr()" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                </Items>
                            </ajx:Menu>
                        </Menu>
                    </ajx:Button>
                </Buttons>
                <Body>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="100%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout6" runat="server">
                                <Body>
                                    <ajx:ComboField runat="server" ID="CmbIfAttribute" Mode="Remote" ValueField="Id"
                                        FieldLabel="Attribute" DisplayField="Name">
                                        <DataContainer>
                                            <DataSource OnEvent="CmbIfAttribute_OnEvent">
                                                <Columns>
                                                    <ajx:Column Name="Name" Title="Column Name">
                                                    </ajx:Column>
                                                    <ajx:Column Name="Id" Hidden="true">
                                                    </ajx:Column>
                                                </Columns>
                                            </DataSource>
                                        </DataContainer>
                                    </ajx:ComboField>
                                    <ajx:ComboField runat="server" ID="CmbIfCondition" Mode="Remote" ValueField="AttributeConditionId"
                                        FieldLabel="Condition" DisplayField="Description">
                                        <DataContainer>
                                            <DataSource OnEvent="CmbIfCondition_OnEvent">
                                                <Columns>
                                                    <ajx:Column Name="Description" Width="200" />
                                                    <ajx:Column Name="AttributeConditionId" Title="AttributeConditionId" Hidden="true" />
                                                    <ajx:Column Name="IsTextField" Hidden="true" Width="0" />
                                                    <ajx:Column Name="IsLookupField" Hidden="true" Width="0" />
                                                    <ajx:Column Name="IsNumericField" Hidden="true" Width="0" />
                                                    <ajx:Column Name="IsDecimalField" Hidden="true" Width="0" />
                                                    <ajx:Column Name="IsDateField" Hidden="true" Width="0" />
                                                    <ajx:Column Name="IsPicklistField" Hidden="true" Width="0" />
                                                    <ajx:Column Name="Value" Hidden="true" Width="0" />
                                                    <ajx:Column Name="Type" Hidden="true" Width="0" />
                                                </Columns>
                                            </DataSource>
                                        </DataContainer>
                                        <Listeners>
                                            <Change Handler="IFCondition.ConditionChanged()" />
                                        </Listeners>
                                    </ajx:ComboField>
                                    <ajx:MultiField runat="server" ID="mf1" FieldLabel="Value">
                                        <Items>
                                            <ajx:Button runat="server" ID="btnIfConditionValues" Text="....">
                                                <Listeners>
                                                    <Click Handler="IFCondition.ShowConditionValue();" />
                                                </Listeners>
                                            </ajx:Button>
                                            <ajx:TextAreaField runat="server" ID="LblIfConditionClausetext" Width="493" ReadOnly="true"
                                                CustomCss="crm-field-yellow" Height="30" />
                                            <ajx:Hidden runat="server" ID="IfConditionClauseValue" />
                                            <ajx:Hidden runat="server" ID="IfConditionConditionType" />
                                        </Items>
                                    </ajx:MultiField>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                </Body>
            </ajx:PanelX>
            <ajx:PanelX runat="server" ID="pnlIfJoin" Title="Add Releated Entity" Height="30"
                AutoHeight="Normal">
                <Buttons>
                    <ajx:Button ID="btnIfAddEntity" runat="server" Text="Add Entity" Width="50">
                        <Listeners>
                            <Click Handler="IFCondition.AddEntity()" />
                        </Listeners>
                    </ajx:Button>
                </Buttons>
                <Body>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="100%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout7" runat="server">
                                <Body>
                                    <ajx:MultiField runat="server" ID="MultiField1">
                                        <Items>
                                            <ajx:CheckField runat="server" ID="chkIfLeftJoin" FieldLabel="Left Join">
                                            </ajx:CheckField>
                                            <ajx:ComboField runat="server" ID="CmbIfReleatedEntity" Mode="Remote" ValueField="Id"
                                                FieldLabel="Entity" DisplayField="Name">
                                                <DataContainer>
                                                    <DataSource OnEvent="CmbIfReleatedEntity_OnEvent">
                                                        <Columns>
                                                            <ajx:Column Name="Name" Title="Column Name">
                                                            </ajx:Column>
                                                            <ajx:Column Name="Id" Hidden="true">
                                                            </ajx:Column>
                                                            <ajx:Column Name="ObjectId" Hidden="true">
                                                            </ajx:Column>
                                                        </Columns>
                                                    </DataSource>
                                                </DataContainer>
                                            </ajx:ComboField>
                                        </Items>
                                    </ajx:MultiField>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                </Body>
            </ajx:PanelX>
            <ajx:TreeGrid runat="server" ID="TreeIfConditions" Title="If Conditions" Width="800"
                Height="200" Mode="Local" Checkable="false" AutoWidth="true" AutoHeight="Normal"
                Collapsible="false">
                <TopBar>
                    <ajx:ToolBar runat="server" ID="TreeIfConditionsToolBar">
                        <Items>
                            <ajx:ToolbarButton runat="server" ID="TreeIfConditionsToolBarDelete" Icon="Delete">
                                <Listeners>
                                    <Click Handler="IFCondition.RemoveCondition();" />
                                </Listeners>
                            </ajx:ToolbarButton>
                        </Items>
                    </ajx:ToolBar>
                </TopBar>
                <Columns>
                    <ajx:TreeGridColumn DataIndex="text" Width="230" Hidden="false" />
                    <ajx:TreeGridColumn DataIndex="id" Width="100" Hidden="true" />
                    <ajx:TreeGridColumn DataIndex="objectid" Width="100" Hidden="true" />
                    <ajx:TreeGridColumn DataIndex="objectId" Width="100" Hidden="true" />
                    <ajx:TreeGridColumn DataIndex="leftjoin" Width="100" Hidden="true" />
                    <ajx:TreeGridColumn DataIndex="type" Width="100" Hidden="true" />
                    <ajx:TreeGridColumn DataIndex="attributeid" Width="100" Hidden="true" />
                    <ajx:TreeGridColumn DataIndex="entityobjectid" Width="100" Hidden="true" />
                    <ajx:TreeGridColumn DataIndex="conditionvalue" Width="100" Hidden="true" />
                    <ajx:TreeGridColumn DataIndex="clausevalue" Width="100" Hidden="true" />
                    <ajx:TreeGridColumn DataIndex="clausetext" Width="100" Hidden="true" />
                    <ajx:TreeGridColumn DataIndex="conditiontype" Width="100" Hidden="true" />
                    <ajx:TreeGridColumn DataIndex="clausevalue2" Width="100" Hidden="true" />
                </Columns>
                <Root>
                    <Nodes>
                    </Nodes>
                    <Listeners>
                        <Click Handler="IFCondition.RowSelected();" />
                    </Listeners>
                </Root>
            </ajx:TreeGrid>
        </Body>
        <Buttons>
            <ajx:Button Icon="ScriptSave" runat="server" ID="IfConditionSave" Text="Save">
                <AjaxEvents>
                    <Click OnEvent="IfConditionSave_OnClickEvent" Before="TreeIfConditions.allNodesPost=true;"
                        Success="TreeIfConditions.allNodesPost=false;">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
            <ajx:Button Hidden="true" runat="server" ID="IfConditionGetAttributeData">
                <AjaxEvents>
                    <Click OnEvent="IfConditionGetAttributeData_OnEvent">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
            <ajx:Button Hidden="true" runat="server" ID="IfConditionValuesEdit">
                <AjaxEvents>
                    <Click OnEvent="IfConditionValuesEdit_OnEvent">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
        </Buttons>
        <Body>
        </Body>
    </ajx:Window>
    <ajx:Window ID="WindowIfcValues" runat="server" Title="Set Value" Height="600" Border="false"
        Resizable="false" CloseAction="Hide" Width="400" Modal="true" Icon="ArrowRotateAnticlockwise"
        ShowOnLoad="false" Maximizable="false">
        <Body>
            <ajx:PanelX runat="server" ID="WindowIfcValuespnl" Height="600" AutoHeight="Normal">
                <Body>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="100%" ColumnLayoutLabelWidth="50">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout8" runat="server">
                                <Body>
                                    <ajx:ComboField ID="IfcValuesConditionType" runat="server" FieldLabelShow="true"
                                        FieldLabel="ConditionType">
                                        <AjaxEvents>
                                            <Change OnEvent="IfcValuesConditionTypeChange_OnEvent">
                                            </Change>
                                        </AjaxEvents>
                                        <Items>
                                            <ajx:ListItem Text="Dynamic" Value="Dynamic" />
                                            <ajx:ListItem Text="Default" Value="Default" />
                                            <ajx:ListItem Text="None" Value="None" />
                                        </Items>
                                    </ajx:ComboField>
                                    <ajx:TextAreaField ID="IfcValuesTextField" runat="server" FieldLabelShow="true" FieldLabel="..."
                                        MaxLength="100" />
                                    <ajx:NumericField ID="IfcValuesNumericField" runat="server" FieldLabelShow="true"
                                        FieldLabel="..." />
                                    <ajx:NumericField ID="IfcValuesDecimalField" runat="server" FieldLabelShow="true"
                                        FieldLabel="..." />
                                    <ajx:DateField ID="IfcValuesDateField" runat="server" FieldLabelShow="true" FieldLabel="..." />
                                    <CrmUI:CrmComboComp ID="IfcValuesLookupField" ObjectId="10" UniqueName="Entity" runat="server"
                                        FieldLabel="CRM.ENTITY_ENTITYNAME">
                                    </CrmUI:CrmComboComp>
                                    <ajx:ComboField ID="IfcValuesPicklistField" runat="server" FieldLabel="..." ValueField="Value"
                                        DisplayField="Label" Mode="Remote">
                                        <DataContainer>
                                            <DataSource OnEvent="IfcValuesPicklistField_OnEvent">
                                                <Columns>
                                                    <ajx:Column Name="Label" Title="Column Name">
                                                    </ajx:Column>
                                                    <ajx:Column Name="Value" Hidden="true">
                                                    </ajx:Column>
                                                </Columns>
                                            </DataSource>
                                        </DataContainer>
                                    </ajx:ComboField>
                                    <ajx:TextAreaField ID="IfcDynamicValuesTextField" runat="server" FieldLabelShow="true"
                                        ReadOnly="true" CustomCss="crm-field-yellow" FieldLabel="..." />
                                    <ajx:Hidden ID="IfcDynamicValuesHiddenField" runat="server" FieldLabelShow="true"
                                        FieldLabel="..." />
                                </Body>
                            </ajx:RowLayout>
                            <ajx:RowLayout ID="RowLayout9" runat="server">
                                <Body>
                                    <ajx:TreeGrid runat="server" ID="TreeGridDynamicValue" Title="DynamicValue" Width="600"
                                        Height="350" Mode="Remote" Checkable="false" AutoWidth="true" AutoHeight="Normal"
                                        Collapsible="false">
                                        <Columns>
                                            <ajx:TreeGridColumn DataIndex="NodeName" Width="230" Header="Node" />
                                            <ajx:TreeGridColumn DataIndex="AttributeId" Width="230" Hidden="true" />
                                            <ajx:TreeGridColumn DataIndex="TargetObjectId" Width="230" Hidden="true" />
                                            <ajx:TreeGridColumn DataIndex="AttributePath" Width="230" Hidden="true" />
                                            <ajx:TreeGridColumn DataIndex="ParentName" Width="230" Hidden="true" />
                                            <ajx:TreeGridColumn DataIndex="CurrentObjectId" Width="230" Hidden="true" />
                                        </Columns>
                                        <Root AsyncLoadNode="true" OnNodeLoad="DynamicValue_NodeLoad">
                                            <Nodes>
                                            </Nodes>
                                            <Listeners>
                                                <DblClick Handler="IFCondition.AddConditionDyanicValue();" />
                                            </Listeners>
                                        </Root>
                                        <TopBar>
                                            <ajx:ToolBar ID="TblTreeGridDynamicValue" runat="server">
                                                <Items>
                                                    <ajx:Button ID="btnTreeGridDynamicValue" Text="Add" Icon="Add" runat="server">
                                                        <Listeners>
                                                            <Click Handler="IFCondition.AddConditionDyanicValue();" />
                                                        </Listeners>
                                                    </ajx:Button>
                                                </Items>
                                            </ajx:ToolBar>
                                        </TopBar>
                                    </ajx:TreeGrid>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                </Body>
            </ajx:PanelX>
            <ajx:Hidden runat="server" ID="hdnWindowIfcValuType" />
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowIfcValueSave" Icon="ScriptSave" Text="Add Condition">
                <Listeners>
                    <Click Handler="IFCondition.SetConditionValue()" />
                </Listeners>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    <ajx:Window ID="WindowBatchScript" runat="server" Title="Batch Script" Height="600"
        Border="false" Resizable="false" CloseAction="Hide" Width="1000" Modal="true"
        Icon="Script" ShowOnLoad="false" Maximizable="false">
        <Body>
            <ajx:PanelX runat="server" ID="PanelBatchScriptName" Height="20" AutoHeight="Normal">
                <Body>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="40%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout10" runat="server">
                                <Body>
                                    <ajx:TextField ID="BatchScriptName" runat="server" Width="450" ObjectId="10" FieldLabel="Batch Script Name"
                                        RequirementLevel="BusinessRequired" />
                                    <ajx:Hidden runat="server" ID="BatchScriptHdnObjectId">
                                    </ajx:Hidden>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="40%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout11" runat="server">
                                <Body>
                                    <ajx:ComboField ID="BatchScriptForm" runat="server" Width="450" ObjectId="10" FieldLabel="Form"
                                        RequirementLevel="BusinessRequired" Mode="Local">
                                    </ajx:ComboField>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="20%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout14" runat="server">
                                <Body>
                                    <ajx:CheckField ID="BatchScriptReset" runat="server" Width="450" ObjectId="10" FieldLabel="Reset Default" />
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                </Body>
            </ajx:PanelX>
            <ajx:PanelX runat="server" ID="PanelX3" Height="600" AutoHeight="Normal">
                <Body>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout10" ColumnWidth="70%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout12" runat="server">
                                <Body>
                                    <ajx:GridPanel runat="server" ID="GridBatchScript" AutoWidth="true" AutoHeight="Auto"
                                        Height="300" Editable="false" Mode="Local" AutoLoad="false" Width="1200" AjaxPostable="true">
                                        <DataContainer>
                                            <DataSource>
                                                <Columns>
                                                    <ajx:Column Name="Label" Title="Column Name" Hidden="true" DataType="String" />
                                                    <ajx:Column Name="UniqueNama" Title="Column Name" Hidden="true" DataType="String" />
                                                    <ajx:Column Name="AttributeId" Title="AttributeId" DataType="String" />
                                                    <ajx:Column Name="ShowHideId" Title="Show Hide" DataType="String" />
                                                    <ajx:Column Name="RequirementLevelId" Title="Requirement Level" Width="50" DataType="String" />
                                                    <ajx:Column Name="ReadOnlyLevelId" Title="ReadOnly Level" Width="50" DataType="String" />
                                                    <ajx:Column Name="DisableLevelId" Title="Disable Level" Width="50" DataType="String" />
                                                    <ajx:Column Name="ConditionType" Title="ConditionType" Hidden="true" DataType="String" />
                                                    <ajx:Column Name="ConditionValue" Title="ConditionValue" Hidden="true" DataType="String" />
                                                    <ajx:Column Name="ConditionValueXml" Title="ConditionValueXml" Hidden="true" DataType="String" />
                                                    <ajx:Column Name="ConditionSetValue" Title="Set Value Level" Width="50" DataType="Boolean" />
                                                    <ajx:Column Name="ConditionSetNullValue" Title="Set Null Value" Width="50" DataType="Boolean" />
                                                    <ajx:Column Name="ConditionText" Title="Condition" Width="100" DataType="String" />
                                                    <ajx:Column Name="Type" Title="type" Hidden="true" DataType="String" />
                                                </Columns>
                                            </DataSource>
                                        </DataContainer>
                                        <ColumnModel>
                                            <Columns>
                                                <ajx:GridColumns ColumnId="Label" DataIndex="Label" Header="Column Name" Width="120" Resizeable="true"
                                                    MenuDisabled="true" />
                                                <ajx:GridColumns ColumnId="ShowHideId" DataIndex="ShowHideId" Header="Show Hide"
                                                    Width="50" MenuDisabled="true" />
                                                <ajx:GridColumns ColumnId="RequirementLevelId" DataIndex="RequirementLevelId" Header="Requirement Level"
                                                    Width="50" MenuDisabled="true" />
                                                <ajx:GridColumns ColumnId="ReadOnlyLevelId" DataIndex="ReadOnlyLevelId" Header="ReadOnly Level"
                                                    Width="50" MenuDisabled="true" />
                                                <ajx:GridColumns ColumnId="DisableLevelId" DataIndex="DisableLevelId" Header="Disable Level"
                                                    Width="50" MenuDisabled="true" />
                                                <ajx:GridColumns ColumnId="ConditionSetValue" DataIndex="ConditionSetValue" Header="Set Value"
                                                    Width="50" MenuDisabled="true" />
                                                <ajx:GridColumns ColumnId="ConditionSetNullValue" DataIndex="ConditionSetNullValue"
                                                    Header="Set Null Value" Width="50" MenuDisabled="true" />
                                                <ajx:GridColumns ColumnId="ConditionText" DataIndex="ConditionText" Header="Value"
                                                    Width="200" MenuDisabled="true">
                                                    <Renderer Handler="return BatchScript.FillRowHtml(record.data.ConditionText);" />
                                                </ajx:GridColumns>
                                            </Columns>
                                        </ColumnModel>
                                        <Items>
                                        </Items>
                                        <SelectionModel>
                                            <ajx:RowSelectionModel ID="GridBatchScriptRowSelectionModel1" runat="server" ShowNumber="false">
                                                <Listeners>
                                                    <RowClick Handler="BatchScript.BatchScriptSelected()" />
                                                </Listeners>
                                            </ajx:RowSelectionModel>
                                        </SelectionModel>
                                        <TopBar>
                                            <ajx:ToolBar runat="server" ID="GridBatchScriptToolBar">
                                                <Items>
                                                    <ajx:ToolbarButton runat="server" ID="GridBatchScriptToolBar_Add" Icon="Add" Text="Add New">
                                                        <Listeners>
                                                            <Click Handler="BatchScript.AddEmptyRow();" />
                                                        </Listeners>
                                                    </ajx:ToolbarButton>
                                                    <ajx:ToolbarButton runat="server" ID="GridBatchScriptToolBar_Remove" Icon="Delete"
                                                        Text="Remove">
                                                        <Listeners>
                                                            <Click Handler="BatchScript.RemoveSelectedRow();" />
                                                        </Listeners>
                                                    </ajx:ToolbarButton>
                                                </Items>
                                            </ajx:ToolBar>
                                        </TopBar>
                                        <LoadMask ShowMask="true" />
                                    </ajx:GridPanel>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout11" ColumnWidth="30%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout13" runat="server">
                                <Body>
                                    <ajx:PanelX runat="server" ID="BatchScriptPropertyPanel" Title="Prpoerty">
                                        <Body>
                                            <ajx:ColumnLayout runat="server" ID="ColumnLayout13" ColumnWidth="100%">
                                                <Rows>
                                                    <ajx:RowLayout ID="RowLayout15" runat="server">
                                                        <Body>
                                                            <ajx:ComboField ID="BatchScriptPropertyFormElement" runat="server" Width="450" ObjectId="10"
                                                                FieldLabel="Form Element" RequirementLevel="BusinessRequired" Mode="Remote" ValueField="AttributeId"
                                                                DisplayField="Label">
                                                                <DataContainer>
                                                                    <DataSource OnEvent="BatchScriptPropertyFormElementOnEvent">
                                                                        <Columns>
                                                                            <ajx:Column Name="AttributeId" Hidden="true">
                                                                            </ajx:Column>
                                                                            <ajx:Column Name="Label" Title="Label" Width="200">
                                                                            </ajx:Column>
                                                                            <ajx:Column Name="Type" Title="Type">
                                                                            </ajx:Column>
                                                                            <ajx:Column Name="UniqueName" Hidden="True">
                                                                            </ajx:Column>
                                                                        </Columns>
                                                                    </DataSource>
                                                                </DataContainer>
                                                                <Listeners>
                                                                    <Change Handler="BatchScript.UpdateChangedData(BatchScriptPropertyFormElement)" />
                                                                </Listeners>
                                                            </ajx:ComboField>
                                                            <ajx:ComboField ID="BatchScriptPropertyShowHide" runat="server" Width="450" FieldLabel="Show"
                                                                Mode="Local">
                                                                <Items>
                                                                    <ajx:ListItem Text="None" Value="None" />
                                                                    <ajx:ListItem Text="Show" Value="Show" />
                                                                    <ajx:ListItem Text="Hide" Value="Hide" />
                                                                </Items>
                                                                <Listeners>
                                                                    <Change Handler="BatchScript.UpdateChangedData(BatchScriptPropertyShowHide)" />
                                                                </Listeners>
                                                            </ajx:ComboField>
                                                            <ajx:ComboField ID="BatchScriptPropertyRequirementLevel" runat="server" Width="450"
                                                                FieldLabel="Requirement Level" Mode="Local">
                                                                <Items>
                                                                    <ajx:ListItem Text="None" Value="None" />
                                                                    <ajx:ListItem Text="NoConstraint" Value="NoConstraint" />
                                                                    <ajx:ListItem Text="BussinessRecommend" Value="BussinessRecommend" />
                                                                    <ajx:ListItem Text="BussinessRequired" Value="BussinessRequired" />
                                                                </Items>
                                                                <Listeners>
                                                                    <Change Handler="BatchScript.UpdateChangedData(BatchScriptPropertyRequirementLevel)" />
                                                                </Listeners>
                                                            </ajx:ComboField>
                                                            <ajx:ComboField ID="BatchScriptPropertyReadOnlyLevel" runat="server" Width="450"
                                                                FieldLabel="ReadOnly Level" Mode="Local">
                                                                <Items>
                                                                    <ajx:ListItem Text="None" Value="None" />
                                                                    <ajx:ListItem Text="Enable" Value="Enable" />
                                                                    <ajx:ListItem Text="ReadOnly" Value="ReadOnly" />
                                                                </Items>
                                                                <Listeners>
                                                                    <Change Handler="BatchScript.UpdateChangedData(BatchScriptPropertyReadOnlyLevel)" />
                                                                </Listeners>
                                                            </ajx:ComboField>
                                                            <ajx:ComboField ID="BatchScriptPropertyDisableLevel" runat="server" Width="450" FieldLabel="Disable Level"
                                                                Mode="Local">
                                                                <Items>
                                                                    <ajx:ListItem Text="None" Value="None" />
                                                                    <ajx:ListItem Text="Enable" Value="Enable" />
                                                                    <ajx:ListItem Text="Disable" Value="Disable" />
                                                                </Items>
                                                                <Listeners>
                                                                    <Change Handler="BatchScript.UpdateChangedData(BatchScriptPropertyDisableLevel)" />
                                                                </Listeners>
                                                            </ajx:ComboField>
                                                            <ajx:CheckField ID="BatchScriptPropertySetValue" runat="server" FieldLabel="Change Value">
                                                                <Listeners>
                                                                    <Change Handler="BatchScript.UpdateChangedData(BatchScriptPropertySetValue)" />
                                                                </Listeners>
                                                            </ajx:CheckField>
                                                            <ajx:CheckField ID="BatchScriptPropertySetNullValue" runat="server" FieldLabel="Set Null Value">
                                                                <Listeners>
                                                                    <Change Handler="BatchScript.UpdateChangedData(BatchScriptPropertySetNullValue)" />
                                                                </Listeners>
                                                            </ajx:CheckField>
                                                            <div class="RadiusDiv" style="background-color: #F2FFE1; height: 250px; width: 250px;
                                                                border: 1px solid black;">
                                                                <div id="BatchScriptPropertyValueLabel" style="margin-top: 3px; margin-left: 3px;
                                                                    margin-right: 3px">
                                                                </div>
                                                            </div>
                                                            <ajx:Hidden ID="BatchScriptPropertyConditionType" runat="server" FieldLabelShow="true"
                                                                FieldLabel="..." />
                                                            <ajx:Hidden ID="BatchScriptPropertyValue" runat="server" FieldLabelShow="true" FieldLabel="..." />
                                                            <ajx:Hidden ID="BatchScriptPropertyType" runat="server" FieldLabelShow="true" FieldLabel="..." />
                                                            <ajx:Button ID="BatchScriptPropertyChangeValue" runat="server" Icon="PageEdit" Text="Edit">
                                                                <Listeners>
                                                                    <Click Handler="BatchScript.PrepareValueSelector();" />
                                                                </Listeners>
                                                            </ajx:Button>
                                                        </Body>
                                                    </ajx:RowLayout>
                                                </Rows>
                                            </ajx:ColumnLayout>
                                        </Body>
                                    </ajx:PanelX>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                </Body>
            </ajx:PanelX>
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowBatchScriptSave" Icon="ScriptSave" Text="Add BatchScript">
                <AjaxEvents>
                    <Click OnEvent="BatchScriptSave_OnClickEvent" Before="GridBatchScript.postAllData=true;"
                        Success="GridBatchScript.postAllData=false;">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    <ajx:Window ID="WindowValueSelector" runat="server" Title="Set Value" Height="600"
        Border="false" Resizable="false" CloseAction="Hide" Width="600" Modal="true"
        Icon="ArrowRotateAnticlockwise" ShowOnLoad="false" Maximizable="false">
        <Body>
            <ajx:PanelX runat="server" ID="WindowValueSelectorPnl" Height="500" AutoHeight="Normal">
                <Body>
                    <ajx:Button ID="WindowValueSelectorShow" runat="server" Icon="PageEdit" Hidden="true"
                        Text="Edit">
                        <AjaxEvents>
                            <Click OnEvent="WindowValueSelectorShow_ClickOnEvent">
                            </Click>
                        </AjaxEvents>
                    </ajx:Button>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout14" ColumnWidth="100%" ColumnLayoutLabelWidth="50">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout16" runat="server">
                                <Body>
                                    <ajx:ComboField ID="ValueSelectorValueType" runat="server" FieldLabelShow="true"
                                        FieldLabel="Value Type">
                                        <AjaxEvents>
                                            <Change OnEvent="ValueSelectorValueTypeChange_OnEvent">
                                            </Change>
                                        </AjaxEvents>
                                        <Items>
                                            <ajx:ListItem Text="Dynamic" Value="Dynamic" />
                                            <ajx:ListItem Text="Default" Value="Default" />
                                            <ajx:ListItem Text="None" Value="None" />
                                        </Items>
                                    </ajx:ComboField>
                                    <ajx:TextAreaField ID="ValueSelectorTextField" runat="server" FieldLabelShow="true"
                                        FieldLabel="..." MaxLength="10000" />
                                    <ajx:NumericField ID="ValueSelectorNumericField" runat="server" FieldLabelShow="true"
                                        FieldLabel="..." />
                                    <ajx:NumericField ID="ValueSelectorDecimalField" runat="server" FieldLabelShow="true"
                                        FieldLabel="..." />
                                    <ajx:DateField ID="ValueSelectorDateField" runat="server" FieldLabelShow="true" FieldLabel="..." />
                                    <CrmUI:CrmComboComp ID="ValueSelectorLookupField" ObjectId="10" UniqueName="Entity"
                                        runat="server" FieldLabel="CRM.ENTITY_ENTITYNAME">
                                    </CrmUI:CrmComboComp>
                                    <ajx:ComboField ID="ValueSelectorPicklistField" runat="server" FieldLabel="..." ValueField="Value"
                                        DisplayField="Label" Mode="Remote">
                                        <DataContainer>
                                            <DataSource OnEvent="ValueSelectorPicklistField_OnEvent">
                                                <Columns>
                                                    <ajx:Column Name="Label" Title="Column Name">
                                                    </ajx:Column>
                                                    <ajx:Column Name="Value" Hidden="true">
                                                    </ajx:Column>
                                                </Columns>
                                            </DataSource>
                                        </DataContainer>
                                    </ajx:ComboField>
                                    <ajx:HtmlEditor ID="ValueSelectorDynamicTextField" runat="server" FieldLabelShow="true"
                                        Height="300" CustomCss="crm-field-yellow" FieldLabel="..." ToolBarActive="false">
                                    </ajx:HtmlEditor>
                                    <ajx:Hidden ID="hdnValueSelectorTextField" runat="server" FieldLabelShow="true" FieldLabel="..." />
                                    <ajx:Hidden ID="hdnValueSelectorValueField" runat="server" FieldLabelShow="true"
                                        FieldLabel="..." />
                                </Body>
                            </ajx:RowLayout>
                            <ajx:RowLayout ID="RowLayout17" runat="server">
                                <Body>
                                    <ajx:TreeGrid runat="server" ID="ValueSelectorTreeGrid" Title="DynamicValue" Width="600"
                                        Height="200" Mode="Remote" Checkable="false" AutoWidth="true" AutoHeight="Normal"
                                        Collapsible="false">
                                        <Columns>
                                            <ajx:TreeGridColumn DataIndex="NodeName" Width="230" Header="Node" />
                                            <ajx:TreeGridColumn DataIndex="AttributeId" Width="230" Hidden="true" />
                                            <ajx:TreeGridColumn DataIndex="TargetObjectId" Width="230" Hidden="true" />
                                            <ajx:TreeGridColumn DataIndex="AttributePath" Width="230" Hidden="true" />
                                            <ajx:TreeGridColumn DataIndex="ParentName" Width="230" Hidden="true" />
                                            <ajx:TreeGridColumn DataIndex="CurrentObjectId" Width="230" Hidden="true" />
                                        </Columns>
                                        <Root AsyncLoadNode="true" OnNodeLoad="ValueSelectorTreeGrid_NodeLoad">
                                            <Nodes>
                                            </Nodes>
                                            <Listeners>
                                                <DblClick Handler="ValueSelector.AddConditionDyanicValue();" />
                                            </Listeners>
                                        </Root>
                                    </ajx:TreeGrid>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                </Body>
            </ajx:PanelX>
            <ajx:Hidden runat="server" ID="hdnValueSelectorValuType" />
            <ajx:Hidden runat="server" ID="hdnValueSelectorAttributeId" />
            <ajx:Hidden runat="server" ID="hdnValueSelectorAfterScript" />
            <ajx:Hidden runat="server" ID="hdnValueSelectorConditionValueXml" />
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowValueSelectorSave" Icon="ScriptSave" Text="Add Condition">
                <AjaxEvents>
                    <Click OnEvent="WindowValueSelectorSave_ClickOnEvent">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    <ajx:Window ID="WindowUpdateRecord" runat="server" Title="Update Record" Height="600"
        Border="false" Resizable="false" CloseAction="Hide" Width="1000" Modal="true"
        Icon="ApplicationEdit" ShowOnLoad="false" Maximizable="false">
        <Body>
            <ajx:PanelX runat="server" ID="PanelUpdateRecordName" Height="50" AutoHeight="Normal">
                <Body>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout15" ColumnWidth="40%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout18" runat="server">
                                <Body>
                                    <ajx:TextField ID="UpdateRecordName" runat="server" Width="450" ObjectId="10" FieldLabel="Update Record Name"
                                        RequirementLevel="BusinessRequired" />
                                    <ajx:Hidden runat="server" ID="UpdateRecordHdnObjectId">
                                    </ajx:Hidden>
                                    <ajx:CheckField ID="UpdateRecordOpenWindow" runat="server" Width="450" ObjectId="10"
                                        FieldLabel="Open Window" />
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout16" ColumnWidth="40%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout19" runat="server">
                                <Body>
                                    <ajx:ComboField ID="UpdateRecordAttribute" runat="server" Width="450" ObjectId="10"
                                        FieldLabel="Attribute" RequirementLevel="BusinessRequired" Mode="Local">
                                    </ajx:ComboField>
                                    <ajx:CheckField ID="UpdateRecordDisablePlugin" runat="server" Width="450" ObjectId="10"
                                        FieldLabel="Disable Plugin" />
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout17" ColumnWidth="20%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout20" runat="server">
                                <Body>
                                    <ajx:CheckField ID="UpdateRecordDisableWf" runat="server" Width="450" ObjectId="10"
                                        FieldLabel="Disable Wf" />
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                </Body>
            </ajx:PanelX>
            <ajx:PanelX runat="server" ID="PanelX4" Height="600" AutoHeight="Normal">
                <Body>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout18" ColumnWidth="70%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout21" runat="server">
                                <Body>
                                    <ajx:GridPanel runat="server" ID="GridUpdateRecord" AutoWidth="true" AutoHeight="Auto"
                                        Height="300" Editable="false" Mode="Local" AutoLoad="false" Width="1200" AjaxPostable="true">
                                        <DataContainer>
                                            <DataSource>
                                                <Columns>
                                                    <ajx:Column Name="AttributeIdName" Title="Column Name" Hidden="true" DataType="String" />
                                                    <ajx:Column Name="AttributeId" Title="AttributeId" DataType="String" />
                                                    <ajx:Column Name="ConditionType" Title="ConditionType" Hidden="true" DataType="String" />
                                                    <ajx:Column Name="ConditionValue" Title="ConditionValue" Hidden="true" DataType="String" />
                                                    <ajx:Column Name="ConditionValueXml" Title="ConditionValueXml" Hidden="true" DataType="String" />
                                                    <ajx:Column Name="ConditionText" Title="Condition" Width="100" DataType="String" />
                                                </Columns>
                                            </DataSource>
                                        </DataContainer>
                                        <ColumnModel>
                                            <Columns>
                                                <ajx:GridColumns ColumnId="AttributeIdName" DataIndex="AttributeIdName" Header="Column Name"
                                                    Width="120" MenuDisabled="true" />
                                                <ajx:GridColumns ColumnId="ConditionText" DataIndex="ConditionText" Header="Value"
                                                    Width="200" MenuDisabled="true">
                                                    <Renderer Handler="return UpdateRecord.FillRowHtml(record.data.ConditionText);" />
                                                </ajx:GridColumns>
                                            </Columns>
                                        </ColumnModel>
                                        <Items>
                                        </Items>
                                        <SelectionModel>
                                            <ajx:RowSelectionModel ID="GridUpdateRecordRowSelectionModel1" runat="server" ShowNumber="false">
                                                <Listeners>
                                                    <RowClick Handler="UpdateRecord.UpdateRecordSelected()" />
                                                </Listeners>
                                            </ajx:RowSelectionModel>
                                        </SelectionModel>
                                        <TopBar>
                                            <ajx:ToolBar runat="server" ID="GridUpdateRecordToolBar">
                                                <Items>
                                                    <ajx:ToolbarButton runat="server" ID="GridUpdateRecordToolBar_Add" Icon="Add" Text="Add New">
                                                        <Listeners>
                                                            <Click Handler="UpdateRecord.AddEmptyRow();" />
                                                        </Listeners>
                                                    </ajx:ToolbarButton>
                                                    <ajx:ToolbarButton runat="server" ID="GridUpdateRecordToolBar_Remove" Icon="Delete"
                                                        Text="Remove">
                                                        <Listeners>
                                                            <Click Handler="UpdateRecord.RemoveSelectedRow();" />
                                                        </Listeners>
                                                    </ajx:ToolbarButton>
                                                </Items>
                                            </ajx:ToolBar>
                                        </TopBar>
                                        <LoadMask ShowMask="true" />
                                    </ajx:GridPanel>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout19" ColumnWidth="30%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout22" runat="server">
                                <Body>
                                    <ajx:PanelX runat="server" ID="UpdateRecordPropertyPanel" Title="Prpoerty">
                                        <Body>
                                            <ajx:ColumnLayout runat="server" ID="ColumnLayout20" ColumnWidth="100%">
                                                <Rows>
                                                    <ajx:RowLayout ID="RowLayout23" runat="server">
                                                        <Body>
                                                            <ajx:ComboField ID="UpdateRecordPropertyFormElement" runat="server" Width="450" ObjectId="10"
                                                                FieldLabel="Form Element" RequirementLevel="BusinessRequired" Mode="Remote" ValueField="AttributeId"
                                                                DisplayField="Label">
                                                                <DataContainer>
                                                                    <DataSource OnEvent="UpdateRecordPropertyFormElementOnEvent">
                                                                        <Columns>
                                                                            <ajx:Column Name="AttributeId" Hidden="true">
                                                                            </ajx:Column>
                                                                            <ajx:Column Name="Label" Title="Label">
                                                                            </ajx:Column>
                                                                        </Columns>
                                                                    </DataSource>
                                                                </DataContainer>
                                                                <Listeners>
                                                                    <Change Handler="UpdateRecord.UpdateChangedData(UpdateRecordPropertyFormElement)" />
                                                                </Listeners>
                                                            </ajx:ComboField>
                                                            <div class="RadiusDiv" style="background-color: #F2FFE1; height: 250px; width: 250px;
                                                                border: 1px solid black;">
                                                                <div id="UpdateRecordPropertyValueLabel" style="margin-top: 3px; margin-left: 3px;
                                                                    margin-right: 3px">
                                                                </div>
                                                            </div>
                                                            <ajx:Hidden ID="UpdateRecordPropertyConditionType" runat="server" FieldLabelShow="true"
                                                                FieldLabel="..." />
                                                            <ajx:Hidden ID="UpdateRecordPropertyValue" runat="server" FieldLabelShow="true" FieldLabel="..." />
                                                            <ajx:Hidden ID="UpdateRecordPropertyType" runat="server" FieldLabelShow="true" FieldLabel="..." />
                                                            <ajx:Button ID="UpdateRecordPropertyChangeValue" runat="server" Icon="PageEdit" Text="Edit">
                                                                <Listeners>
                                                                    <Click Handler="UpdateRecord.PrepareValueSelector();" />
                                                                </Listeners>
                                                            </ajx:Button>
                                                        </Body>
                                                    </ajx:RowLayout>
                                                </Rows>
                                            </ajx:ColumnLayout>
                                        </Body>
                                    </ajx:PanelX>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                </Body>
            </ajx:PanelX>
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowUpdateRecordSave" Icon="ScriptSave" Text="Add UpdateRecord">
                <AjaxEvents>
                    <Click OnEvent="UpdateRecordSave_OnClickEvent" Before="GridUpdateRecord.postAllData=true;"
                        Success="GridUpdateRecord.postAllData=false;">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    <ajx:Window ID="WindowCreateRecord" runat="server" Title="Create New Record" Height="600"
        Border="false" Resizable="false" CloseAction="Hide" Width="1000" Modal="true"
        Icon="ApplicationAdd" ShowOnLoad="false" Maximizable="false">
        <Body>
            <ajx:PanelX runat="server" ID="PanelCreateRecordName" Height="50" AutoHeight="Normal">
                <Body>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout21" ColumnWidth="40%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout24" runat="server">
                                <Body>
                                    <ajx:TextField ID="CreateRecordName" runat="server" Width="450" ObjectId="10" FieldLabel="Create Record Name"
                                        RequirementLevel="BusinessRequired" />
                                    <ajx:Hidden runat="server" ID="CreateRecordHdnObjectId">
                                    </ajx:Hidden>
                                    <ajx:CheckField ID="CreateRecordOpenWindow" runat="server" Width="450" ObjectId="10"
                                        FieldLabel="Open Window" />
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout22" ColumnWidth="40%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout25" runat="server">
                                <Body>
                                    <ajx:ComboField ID="CreateRecordEntity" runat="server" Width="450" ObjectId="10"
                                        FieldLabel="Attribute" RequirementLevel="BusinessRequired" Mode="Local">
                                    </ajx:ComboField>
                                    <ajx:CheckField ID="CreateRecordDisablePlugin" runat="server" Width="450" ObjectId="10"
                                        FieldLabel="Disable Plugin" />
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout23" ColumnWidth="20%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout26" runat="server">
                                <Body>
                                    <ajx:CheckField ID="CreateRecordDisableWf" runat="server" Width="450" ObjectId="10"
                                        FieldLabel="Disable Wf" />
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                </Body>
            </ajx:PanelX>
            <ajx:PanelX runat="server" ID="PanelX5" Height="600" AutoHeight="Normal">
                <Body>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout24" ColumnWidth="70%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout27" runat="server">
                                <Body>
                                    <ajx:GridPanel runat="server" ID="GridCreateRecord" AutoWidth="true" AutoHeight="Auto"
                                        Height="300" Editable="false" Mode="Local" AutoLoad="false" Width="1200" AjaxPostable="true">
                                        <DataContainer>
                                            <DataSource>
                                                <Columns>
                                                    <ajx:Column Name="AttributeIdName" Title="Column Name" Hidden="true" DataType="String" />
                                                    <ajx:Column Name="AttributeId" Title="AttributeId" DataType="String" />
                                                    <ajx:Column Name="ConditionType" Title="ConditionType" Hidden="true" DataType="String" />
                                                    <ajx:Column Name="ConditionValue" Title="ConditionValue" Hidden="true" DataType="String" />
                                                    <ajx:Column Name="ConditionValueXml" Title="ConditionValueXml" Hidden="true" DataType="String" />
                                                    <ajx:Column Name="ConditionText" Title="Condition" Width="100" DataType="String" />
                                                </Columns>
                                            </DataSource>
                                        </DataContainer>
                                        <ColumnModel>
                                            <Columns>
                                                <ajx:GridColumns ColumnId="AttributeIdName" DataIndex="AttributeIdName" Header="Column Name"
                                                    Width="120" MenuDisabled="true" />
                                                <ajx:GridColumns ColumnId="ConditionText" DataIndex="ConditionText" Header="Value"
                                                    Width="200" MenuDisabled="true">
                                                    <Renderer Handler="return CreateRecord.FillRowHtml(record.data.ConditionText);" />
                                                </ajx:GridColumns>
                                            </Columns>
                                        </ColumnModel>
                                        <Items>
                                        </Items>
                                        <SelectionModel>
                                            <ajx:RowSelectionModel ID="GridCreateRecordRowSelectionModel1" runat="server" ShowNumber="false">
                                                <Listeners>
                                                    <RowClick Handler="CreateRecord.CreateRecordSelected()" />
                                                </Listeners>
                                            </ajx:RowSelectionModel>
                                        </SelectionModel>
                                        <TopBar>
                                            <ajx:ToolBar runat="server" ID="GridCreateRecordToolBar">
                                                <Items>
                                                    <ajx:ToolbarButton runat="server" ID="GridCreateRecordToolBar_Add" Icon="Add" Text="Add New">
                                                        <Listeners>
                                                            <Click Handler="CreateRecord.AddEmptyRow();" />
                                                        </Listeners>
                                                    </ajx:ToolbarButton>
                                                    <ajx:ToolbarButton runat="server" ID="GridCreateRecordToolBar_Remove" Icon="Delete"
                                                        Text="Remove">
                                                        <Listeners>
                                                            <Click Handler="CreateRecord.RemoveSelectedRow();" />
                                                        </Listeners>
                                                    </ajx:ToolbarButton>
                                                </Items>
                                            </ajx:ToolBar>
                                        </TopBar>
                                        <LoadMask ShowMask="true" />
                                    </ajx:GridPanel>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout25" ColumnWidth="30%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout28" runat="server">
                                <Body>
                                    <ajx:PanelX runat="server" ID="CreateRecordPropertyPanel" Title="Prpoerty">
                                        <Body>
                                            <ajx:ColumnLayout runat="server" ID="ColumnLayout26" ColumnWidth="100%">
                                                <Rows>
                                                    <ajx:RowLayout ID="RowLayout29" runat="server">
                                                        <Body>
                                                            <ajx:ComboField ID="CreateRecordPropertyFormElement" runat="server" Width="450" ObjectId="10"
                                                                FieldLabel="Form Element" RequirementLevel="BusinessRequired" Mode="Remote" ValueField="AttributeId"
                                                                DisplayField="Label">
                                                                <DataContainer>
                                                                    <DataSource OnEvent="CreateRecordPropertyFormElementOnEvent">
                                                                        <Columns>
                                                                            <ajx:Column Name="ObjectId" Hidden="true">
                                                                            </ajx:Column>
                                                                            <ajx:Column Name="Label" Title="Label">
                                                                            </ajx:Column>
                                                                        </Columns>
                                                                    </DataSource>
                                                                </DataContainer>
                                                                <Listeners>
                                                                    <Change Handler="CreateRecord.UpdateChangedData(CreateRecordPropertyFormElement)" />
                                                                </Listeners>
                                                            </ajx:ComboField>
                                                            <div class="RadiusDiv" style="background-color: #F2FFE1; height: 250px; width: 250px;
                                                                border: 1px solid black;">
                                                                <div id="CreateRecordPropertyValueLabel" style="margin-top: 3px; margin-left: 3px;
                                                                    margin-right: 3px">
                                                                </div>
                                                            </div>
                                                            <ajx:Hidden ID="CreateRecordPropertyConditionType" runat="server" FieldLabelShow="true"
                                                                FieldLabel="..." />
                                                            <ajx:Hidden ID="CreateRecordPropertyValue" runat="server" FieldLabelShow="true" FieldLabel="..." />
                                                            <ajx:Hidden ID="CreateRecordPropertyType" runat="server" FieldLabelShow="true" FieldLabel="..." />
                                                            <ajx:Button ID="CreateRecordPropertyChangeValue" runat="server" Icon="PageEdit" Text="Edit">
                                                                <Listeners>
                                                                    <Click Handler="CreateRecord.PrepareValueSelector();" />
                                                                </Listeners>
                                                            </ajx:Button>
                                                        </Body>
                                                    </ajx:RowLayout>
                                                </Rows>
                                            </ajx:ColumnLayout>
                                        </Body>
                                    </ajx:PanelX>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                </Body>
            </ajx:PanelX>
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowCreateRecordSave" Icon="ApplicationAdd" Text="Add CreateRecord">
                <AjaxEvents>
                    <Click OnEvent="CreateRecordSave_OnClickEvent" Before="GridCreateRecord.postAllData=true;"
                        Success="GridCreateRecord.postAllData=false;">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    <ajx:Window ID="WindowMessage" runat="server" Title="Message Window" Height="600"
        Border="false" Resizable="false" CloseAction="Hide" Width="1000" Modal="true"
        Icon="CommentAdd" ShowOnLoad="false" Maximizable="false">
        <Body>
            <ajx:PanelX runat="server" ID="PanelMessageName" Height="50" AutoHeight="Normal">
                <Body>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout27" ColumnWidth="60%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout30" runat="server">
                                <Body>
                                    <ajx:TextField ID="MessageName" runat="server" Width="450" ObjectId="10" FieldLabel="Message Name"
                                        RequirementLevel="BusinessRequired" />
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout28" ColumnWidth="40%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout31" runat="server">
                                <Body>
                                    <ajx:ComboField ID="MessageType" runat="server" Width="450" ObjectId="10" FieldLabel="Message Type"
                                        RequirementLevel="BusinessRequired" Mode="Local">
                                        <Items>
                                            <ajx:ListItem Text="MessageBox" Value="MessageBox" />
                                            <ajx:ListItem Text="Url" Value="Url" />
                                            <ajx:ListItem Text="Script" Value="Script" />
                                            <ajx:ListItem Text="Sql" Value="Sql" />
                                            <ajx:ListItem Text="CrmException" Value="CrmException" />
                                        </Items>
                                    </ajx:ComboField>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                </Body>
            </ajx:PanelX>
            <ajx:PanelX runat="server" ID="PanelX6" Height="400" AutoHeight="Normal">
                <Body>
                    <ajx:Button ID="MessageShowDynamicValue" runat="server" Text="Show Dynamic Value ">
                        <Listeners>
                            <Click Handler="Message.PrepareValueSelector();" />
                        </Listeners>
                    </ajx:Button>
                    <ajx:HtmlEditor runat="server" ID="MessageBody" AutoWidth="true" Height="370" />
                </Body>
            </ajx:PanelX>
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowMessageSave" Icon="CommentAdd" Text="Add Message">
                <AjaxEvents>
                    <Click OnEvent="MessageSave_OnClickEvent">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    <ajx:Window ID="WindowDynamicUrl" runat="server" Title="DynamicUrl Window" Height="300"
        Border="false" Resizable="false" CloseAction="Hide" Width="300" Modal="true"
        Icon="LinkEdit" ShowOnLoad="false" Maximizable="false">
        <Body>
            <ajx:ComboField ID="DynamicUrlId" runat="server" Width="200" ObjectId="10" FieldLabel="DynamicUrl"
                RequirementLevel="BusinessRequired" Mode="Local">
            </ajx:ComboField>
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowDynamicUrlSave" Icon="LinkEdit" Text="Add DynamicUrl">
                <AjaxEvents>
                    <Click OnEvent="DynamicUrlSave_OnClickEvent">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    <ajx:Window ID="WindowRedirectForm" runat="server" Title="RedirectForm Window" Height="300"
        Border="false" Resizable="false" CloseAction="Hide" Width="300" Modal="true"
        Icon="Reload" ShowOnLoad="false" Maximizable="false">
        <Body>
            <ajx:ComboField ID="RedirectFormId" runat="server" Width="200" ObjectId="10" FieldLabel="RedirectForm"
                RequirementLevel="BusinessRequired" Mode="Local">
            </ajx:ComboField>
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowRedirectFormSave" Icon="Reload" Text="Add RedirectForm">
                <AjaxEvents>
                    <Click OnEvent="RedirectFormSave_OnClickEvent">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    <ajx:Window ID="WindowPluginMessage" runat="server" Title="PluginMessage Window"
        Height="300" Border="false" Resizable="false" CloseAction="Hide" Width="300"
        Modal="true" Icon="Plugin" ShowOnLoad="false" Maximizable="false">
        <Body>
            <ajx:ComboField ID="PluginMessageId" runat="server" Width="200" ObjectId="10" FieldLabel="PluginMessage"
                RequirementLevel="BusinessRequired" Mode="Local">
            </ajx:ComboField>
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowPluginMessageSave" Icon="Plugin" Text="Add PluginMessage">
                <AjaxEvents>
                    <Click OnEvent="PluginMessageSave_OnClickEvent">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
        </Buttons>
    </ajx:Window>

        <ajx:Window ID="WindowWorkFlow" runat="server" Title="WorkFlow Window"
        Height="300" Border="false" Resizable="false" CloseAction="Hide" Width="300"
        Modal="true" Icon="Plugin" ShowOnLoad="false" Maximizable="false">
        <Body>
            <ajx:ComboField ID="WorkflowId" runat="server" Width="200" ObjectId="10" FieldLabel="WorkFlow"
                RequirementLevel="BusinessRequired" Mode="Local">
            </ajx:ComboField>
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowWorkFlowSave" Icon="Plugin" Text="Add WorkFlow">
                <AjaxEvents>
                    <Click OnEvent="WorkFlowSave_OnClickEvent">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    </form>
</body>
</html>
<script type="text/javascript">
    var NewActions = {
        Show: function (workflowStepType) {
            if (this.GetSelectedNode())
                WfBuilder.ShowEdit(WorkflowAction.New, workflowStepType);
        },
        GetSelectedNode: function () {
            var sn = WItems.selectedNode;

            if (!sn[0] || WItems.selectedNodeClass.Leaf) {
                alert("Lütfen Bir Node Seçiniz.")
                return false;
            } else {
                return sn;
            }
        }

    }
    
</script>
