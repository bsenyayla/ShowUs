<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Criteria_CriteriaEditReflex"
    ValidateRequest="false" EnableViewState="false" Codebehind="CriteriaEditReflex.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="CrmUI" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/Ce.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
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
        div.Scrool{
        overflow-y: scroll;
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
                                        <ajx:Parameter Name="ParentAction" Value="hdnDDParentAction.getValue();" Mode="Raw"></ajx:Parameter>
                                    </ExtraParams>
                                </Click>
                            </AjaxEvents>
                        </ajx:ToolbarButton>
                        <ajx:ToolbarButton runat="server" ID="btnDelete" Width="100" Text="Delete" Icon="Delete">
                            <Listeners>
                                <Click Handler="BtnDelete_Click()" />
                            </Listeners>
                        </ajx:ToolbarButton>
                        <ajx:ToolbarButton runat="server" ID="btnRun" Width="100" Text="Execute" Icon="ArrowRight">
                            <AjaxEvents>
                                <Click OnEvent="BtnRunClick">
                                    <EventMask ShowMask="true" />

                                </Click>
                            </AjaxEvents>
                        </ajx:ToolbarButton>

                        <ajx:ToolbarFill runat="server" ID="ToolbarFill1">
                        </ajx:ToolbarFill>

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
                        <ajx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <CrmUI:CrmTextFieldComp ID="GroupName" runat="server" Width="450" ObjectId="55"
                                    UniqueName="GroupName" />
                            </Body>
                        </ajx:RowLayout>
                        <ajx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <CrmUI:CrmComboComp ID="EntityId" RequirementLevel="BusinessRequired"
                                    ObjectId="55" UniqueName="EntityId" runat="server" FieldLabel="CRM.ENTITY_ENTITYNAME">
                                </CrmUI:CrmComboComp>
                            </Body>
                        </ajx:RowLayout>
                        
                        <ajx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <CrmUI:CrmComboComp ID="AttributeId" RequirementLevel="BusinessRequired"
                                    ObjectId="55" UniqueName="AttributeId" runat="server"  LookupViewUniqueName="ENTITYATTRIBUTE_ONLY_LOOKUP">
                                    <Filters>
                                    <CrmUI:ComboFilter FromObjectId="55" FromUniqueName="EntityId" ToObjectId="44"
                                        ToUniqueName="EntityId" />
                                </Filters>
                                </CrmUI:CrmComboComp>
                            </Body>
                        </ajx:RowLayout>
                    </Rows>
                </ajx:ColumnLayout>

            </Body>
        </ajx:Fieldset>

        <ajx:TreeGrid runat="server" ID="WItems" Title="TreeGrid" Width="800" Height="600"
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

                                    </Items>
                                </ajx:Menu>
                            </Menu>
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
                <ajx:TreeGridColumn DataIndex="text" Width="230" Header="Group" />
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
                        <ajx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="45%">
                            <Rows>
                                <ajx:RowLayout ID="RowLayout8" runat="server">
                                    <Body>
                                        <ajx:TextField ID="IfConditionName" runat="server" Width="450" ObjectId="55" FieldLabel="Condition Name"
                                            RequirementLevel="BusinessRequired" />
                                        <ajx:Hidden runat="server" ID="IfconditionHdnObjectId">
                                        </ajx:Hidden>
                                    </Body>
                                </ajx:RowLayout>
                            </Rows>
                        </ajx:ColumnLayout>
                        <ajx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="45%">
                            <Rows>
                                <ajx:RowLayout ID="RowLayout3" runat="server">
                                    <Body>
                                        <ajx:ComboField ID="IfConditionType" runat="server" FieldLabelShow="true"
                                            FieldLabel="Type">

                                            <Items>
                                                <ajx:ListItem Text="Add" Value="1" />
                                                <ajx:ListItem Text="Remove" Value="2" />

                                            </Items>
                                        </ajx:ComboField>

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
                                <ajx:RowLayout ID="RowLayout9" runat="server">
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
                                <ajx:RowLayout ID="RowLayout10" runat="server">
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
                    Height="200" Mode="Local" Checkable="false" AutoWidth="true" AutoHeight="Normal"  StickObj="WindowIfCondition"
                    >
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
                                <ajx:RowLayout ID="RowLayout11" runat="server">
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
                                        <CrmUI:CrmComboComp ID="IfcValuesLookupField" ObjectId="55" UniqueName="EntityId" runat="server"
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
                                <ajx:RowLayout ID="RowLayout12" runat="server">
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
