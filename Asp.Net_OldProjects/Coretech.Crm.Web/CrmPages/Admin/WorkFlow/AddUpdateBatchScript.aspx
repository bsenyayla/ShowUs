<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_WorkFlow_AddUpdateBatchScript" ValidateRequest="false" Codebehind="AddUpdateBatchScript.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<%@ Register Src="DynamicValue.ascx" TagName="DynamicValue" TagPrefix="uc2" %>
<%@ Register Assembly="Coretech.Crm.Web.UI" Namespace="Coretech.Crm.Web.UI.AutoGenerate"
    TagPrefix="CrmUI" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style>
        .hide-toolbar .x-html-editor-tb
        {
            display: none !important;
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
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <ext:Hidden ID="xmlTemplateId" runat="server">
    </ext:Hidden>
    <ext:Hidden ID="_WorkFlowId" runat="server">
    </ext:Hidden>
    <div>
        <ext:Store ID="strGrdDefault" runat="server">
            <Reader>
                <ext:JsonReader ReaderID="AttributeId">
                    <Fields>
                        <ext:RecordField Name="UniqueName" />
                        <ext:RecordField Name="Type" />
                        <ext:RecordField Name="AttributeId" />
                        <ext:RecordField Name="AttributeIdName" />
                        <ext:RecordField Name="ShowHideId" />
                        <ext:RecordField Name="ShowHideIdName" />
                        <ext:RecordField Name="RequirementLevelId" />
                        <ext:RecordField Name="RequirementLevelIdName" />
                        <ext:RecordField Name="ReadOnlyLevelId" />
                        <ext:RecordField Name="ReadOnlyLevelIdName" />
                        <ext:RecordField Name="DisableLevelId" />
                        <ext:RecordField Name="DisableLevelIdName" />
                        <ext:RecordField Name="ConditionType" />
                        <ext:RecordField Name="ConditionText" />
                        <ext:RecordField Name="ConditionValue" />
                        <ext:RecordField Name="ConditionSetValue" Type="Boolean" />
                        <ext:RecordField Name="ConditionSetNullValue" Type="Boolean" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store runat="server" ID="StoreWhereAttribute">
            <SortInfo Field="Label" Direction="ASC" />
            <Reader>
                <ext:JsonReader ReaderID="AttributeId">
                    <Fields>
                        <ext:RecordField Name="AttributeId" />
                        <ext:RecordField Name="Label" />
                        <ext:RecordField Name="Type" />
                        <ext:RecordField Name="UniqueName" />
                        <ext:RecordField Name="AttributeTypeDescription" />
                        <ext:RecordField Name="ReferencedObjectId" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store runat="server" ID="WhereClauseComboStore" AutoLoad="false" OnRefreshData="WhereClauseComboStore_Refresh">
            <Proxy>
                <ext:DataSourceProxy>
                </ext:DataSourceProxy>
            </Proxy>
            <Reader>
                <ext:JsonReader ReaderID="Value">
                    <Fields>
                        <ext:RecordField Name="Label" />
                        <ext:RecordField Name="Value" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
            <BaseParams>
                <ext:Parameter Name="AttributeId" Mode="Raw" Value="GetComboAttributeId()">
                </ext:Parameter>
                <ext:Parameter Name="SelectedValue" Mode="Raw" Value="GetSelectedValue()">
                </ext:Parameter>
            </BaseParams>
        </ext:Store>
        <ext:Panel ID="Panel2" runat="server">
            <Body>
                <ext:Panel ID="Panel1" runat="server">
                    <TopBar>
                        <ext:Toolbar ID="Toolbar1" runat="server">
                            <Items>
                                <ext:Button ID="BtnSave" Icon="PageSave" runat="server">
                                    <AjaxEvents>
                                        <Click OnEvent="BtnSave_Click" Success="AddUpdateParentCondition()">
                                            <ExtraParams>
                                                <ext:Parameter Name="XmlValue" Mode="Raw" Value="getXml()">
                                                </ext:Parameter>
                                            </ExtraParams>
                                        </Click>
                                    </AjaxEvents>
                                </ext:Button>
                            </Items>
                        </ext:Toolbar>
                    </TopBar>
                    <Body>
                        <ext:ColumnLayout ID="ColumnLayout1" runat="server">
                            <ext:LayoutColumn ColumnWidth=".5">
                                <ext:Panel ID="Panel5" runat="server" Border="false">
                                    <Body>
                                        <ext:FormLayout ID="FormLayout1" runat="server" LabelAlign="Left">
                                            <ext:Anchor>
                                                <ext:TextField ID="BatchScriptName" FieldLabel="Name" Width="340" runat="server" />
                                            </ext:Anchor>
                                            <ext:Anchor>
                                                <ext:Checkbox ID="ResetDefault" FieldLabel="ResetDefault" runat="server" />
                                            </ext:Anchor>
                                        </ext:FormLayout>
                                    </Body>
                                </ext:Panel>
                            </ext:LayoutColumn>
                            <ext:LayoutColumn ColumnWidth=".5">
                                <ext:Panel runat="server" Border="false">
                                    <Body>
                                        <ext:FormLayout ID="FormLayout3" runat="server" LabelAlign="Left">
                                            <ext:Anchor>
                                                <ext:ComboBox ID="CmbFormList" runat="server" FieldLabel="Forms" Width="300">
                                                    <Listeners>
                                                        <Select Handler="CmbFormList_OnChange(#{WhereEntityAttributeList});" />
                                                    </Listeners>
                                                </ext:ComboBox>
                                            </ext:Anchor>
                                        </ext:FormLayout>
                                    </Body>
                                </ext:Panel>
                            </ext:LayoutColumn>
                        </ext:ColumnLayout>
                    </Body>
                </ext:Panel>
                <ext:Panel runat="server">
                    <Body>
                        <ext:GridPanel runat="server" ID="GrdDefault" StoreID="strGrdDefault" Height="350">
                            <TopBar>
                                <ext:Toolbar runat="server">
                                    <Items>
                                        <ext:Button runat="server" ID="BtnAdd" Icon="Add" Text="Yeni Alan ekle">
                                            <Listeners>
                                                <Click Handler="AddNewAttribute()" />
                                            </Listeners>
                                        </ext:Button>
                                        <ext:Button ID="Button1" runat="server" Text="Delete" Icon="Delete">
                                            <Listeners>
                                                <Click Handler="#{GrdDefault}.deleteSelected();" />
                                            </Listeners>
                                        </ext:Button>
                                    </Items>
                                </ext:Toolbar>
                            </TopBar>
                            <ColumnModel>
                                <Listeners>
                                </Listeners>
                                <Columns>
                                    <ext:Column Header="AttributeId" Hidden="true" DataIndex="AttributeId" MenuDisabled="true"
                                        Sortable="false">
                                    </ext:Column>
                                    <ext:Column Header="Kolon Adı" MenuDisabled="true" DataIndex="AttributeIdName" Sortable="false"
                                        Width="300">
                                    </ext:Column>
                                    <ext:Column Header="Show / Hide" MenuDisabled="true" DataIndex="ShowHideIdName" Sortable="false"
                                        Width="100">
                                    </ext:Column>
                                    <ext:Column MenuDisabled="true" DataIndex="ShowHideId" Sortable="false" Hidden="true"
                                        Width="100">
                                    </ext:Column>
                                    <ext:Column MenuDisabled="true" Header="Requirement Level" DataIndex="RequirementLevelIdName"
                                        Sortable="false" Width="100">
                                    </ext:Column>
                                    <ext:Column MenuDisabled="true" DataIndex="RequirementLevelId" Sortable="false" Hidden="true"
                                        Width="100">
                                    </ext:Column>
                                    <ext:Column MenuDisabled="true" DataIndex="ReadOnlyLevelId" Sortable="false" Hidden="true"
                                        Width="100">
                                    </ext:Column>
                                    <ext:Column MenuDisabled="true" Header="ReadOnly Level" DataIndex="ReadOnlyLevelIdName"
                                        Sortable="false" Width="100">
                                    </ext:Column>
                                     <ext:Column MenuDisabled="true" DataIndex="DisableLevelId" Sortable="false" Hidden="true"
                                        Width="100">
                                    </ext:Column>
                                    <ext:Column MenuDisabled="true" Header="Disable Level" DataIndex="DisableLevelIdName"
                                        Sortable="false" Width="100">
                                    </ext:Column>
                                    <ext:CheckColumn Header="Change" MenuDisabled="true" DataIndex="ConditionSetValue"
                                        Sortable="false" Width="50">
                                    </ext:CheckColumn>
                                    <ext:CheckColumn Header="Null" MenuDisabled="true" DataIndex="ConditionSetNullValue"
                                        Sortable="false" Width="50">
                                    </ext:CheckColumn>
                                    <ext:Column Header="Değeri" MenuDisabled="true" DataIndex="ConditionText" Sortable="false"
                                        Width="350">
                                    </ext:Column>
                                    <ext:Column Header="ConditionType" MenuDisabled="true" DataIndex="ConditionType"
                                        Hidden="true" Sortable="false" Width="100">
                                    </ext:Column>
                                    <ext:Column Header="ConditionValue" MenuDisabled="true" DataIndex="ConditionValue"
                                        Hidden="true" Sortable="false">
                                    </ext:Column>
                                </Columns>
                            </ColumnModel>
                            <SelectionModel>
                                <ext:RowSelectionModel>
                                </ext:RowSelectionModel>
                            </SelectionModel>
                            <Listeners>
                                <CellDblClick Fn="GrdDefault_DblClick" />
                            </Listeners>
                        </ext:GridPanel>
                    </Body>
                </ext:Panel>
            </Body>
        </ext:Panel>
        <ext:Window runat="server" ID="WindowProperty" Modal="true" ShowOnLoad="false" Width="800"
            Height="500">
            <Body>
                <ext:FitLayout ID="FitLayout1" runat="server">
                    <ext:Panel ID="Panel6" runat="server">
                        <Body>
                            <ext:BorderLayout ID="BorderLayout1" runat="server">
                                <Center>
                                    <ext:Panel ID="Panel7" runat="server">
                                        <Body>
                                            <ext:Panel ID="Panel8" runat="server">
                                                <Body>
                                                    <ext:FormLayout ID="FormLayout4" runat="server" LabelAlign="Left">
                                                        <ext:Anchor>
                                                            <ext:ComboBox runat="server" AllowBlank="false" ID="WhereEntityAttributeList" StoreID="StoreWhereAttribute"
                                                                ValueField="AttributeId" DisplayField="Label" FieldLabel="Attributes" Width="400">
                                                                <Listeners>
                                                                    <Select Handler="WhereEntityAttributeList_Select(#{WhereEntityAttributeList})" />
                                                                </Listeners>
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:ComboBox runat="server" ID="ShowHide" FieldLabel="Show Hide" Width="400">
                                                                <Items>
                                                                    <ext:ListItem Text="None" Value="-1" />
                                                                    <ext:ListItem Text="Show" Value="1" />
                                                                    <ext:ListItem Text="Hide" Value="2" />
                                                                </Items>
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:ComboBox runat="server" ID="RequirementLevel" FieldLabel="Requirement Level"
                                                                Width="400">
                                                                <Items>
                                                                    <ext:ListItem Text="None" Value="-1" />
                                                                    <ext:ListItem Text="NoConstraint" Value="0" />
                                                                    <ext:ListItem Text="BussinessRecommend" Value="1" />
                                                                    <ext:ListItem Text="BussinessRequired" Value="2" />
                                                                </Items>
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:ComboBox runat="server" ID="ReadOnlyLevel" FieldLabel="ReadOnly Level" Width="400">
                                                                <Items>
                                                                    <ext:ListItem Text="None" Value="-1" />
                                                                    <ext:ListItem Text="Enable" Value="0" />
                                                                    <ext:ListItem Text="ReadOnly" Value="1" />
                                                                </Items>
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                          <ext:Anchor>
                                                            <ext:ComboBox runat="server" ID="DisableLevel" FieldLabel="Disable Level" Width="400">
                                                                <Items>
                                                                    <ext:ListItem Text="None" Value="-1" />
                                                                    <ext:ListItem Text="Enable" Value="0" />
                                                                    <ext:ListItem Text="Disable" Value="1" />
                                                                </Items>
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:Checkbox ID="ChkConditionSetValue" runat="server" FieldLabel="Change Value">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:Checkbox ID="ChkConditionSetNullValue" runat="server" FieldLabel="Set Null Value">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <CrmUI:CrmLookupComp ID="WhereClauseLookup" runat="server" ObjectId="10" UniqueName="workflowId"
                                                                LookupViewId="" FieldLabel="Look Up Selecter" Style="padding-left: 105px;" Width="400">
                                                            </CrmUI:CrmLookupComp>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:TextField ID="WhereClauseText" AllowBlank="false" runat="server" FieldLabel="Text Value"
                                                                MaxLength="100" Width="400">
                                                            </ext:TextField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:NumberField ID="WhereClauseNumber" AllowBlank="false" runat="server" FieldLabel="Number Value"
                                                                AllowDecimals="false" Width="400">
                                                            </ext:NumberField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:NumberField ID="WhereClauseDecimal" AllowBlank="false" runat="server" FieldLabel="Decimal Value"
                                                                AllowDecimals="true" Width="400">
                                                            </ext:NumberField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:DateField ID="WhereClauseDateField" AllowBlank="false" runat="server" FieldLabel="Date Value"
                                                                Width="400">
                                                            </ext:DateField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:ComboBox ID="WhereClauseCombo" TypeAhead="true" Mode="Remote" MinChars="1" ValueField="Value"
                                                                FieldLabel="Combo Value" DisplayField="Label" runat="server" StoreID="WhereClauseComboStore"
                                                                Width="400">
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:HtmlEditor ID="WhereClauseDynamicEditor" FieldLabel="Dynamic Value" runat="server"
                                                                CtCls="hide-toolbar" Height="150" Width="400">
                                                            </ext:HtmlEditor>
                                                        </ext:Anchor>
                                                    </ext:FormLayout>
                                                </Body>
                                            </ext:Panel>
                                            <ext:HtmlEditor ID="WhereClauseHtmlEditor" runat="server" Hidden="true" />
                                        </Body>
                                    </ext:Panel>
                                </Center>
                                <East Collapsible="true" MinWidth="100" Split="true">
                                    <ext:Panel ID="Panel9" runat="server" Width="200" Title="Dynamic Value" Collapsed="false"
                                        Height="500" AutoScroll="true">
                                        <Body>
                                            <uc2:DynamicValue ID="DV" runat="server" IsWorkFlow="true" />
                                        </Body>
                                    </ext:Panel>
                                </East>
                            </ext:BorderLayout>
                        </Body>
                    </ext:Panel>
                </ext:FitLayout>
            </Body>
            <TopBar>
                <ext:Toolbar runat="server">
                    <Items>
                        <ext:Button ID="btnSaveProperty" runat="server" Icon="Add" Text="ADD_UPDATE_RECORD">
                            <Listeners>
                                <Click Handler="addList()" />
                            </Listeners>
                        </ext:Button>
                    </Items>
                </ext:Toolbar>
            </TopBar>
        </ext:Window>
    </div>
    </form>
</body>
</html>
<script language="javascript">

    var _C_ClientId = null;
    var _D_ClientId = null;
    function Get(id, Type) {
        if (Type == "C") {
            if (!IsNull(_C_ClientId)) {
                return eval(_C_ClientId + "_" + id)
            }
            else {
                return eval(id)
            }
        }
        else if (Type == "D") {
            if (!IsNull(_D_ClientId)) {

                return eval(_D_ClientId + "_" + id)

            }
            else {
                return eval(id)
            }
        }
    }
    /*Prottype*/
    function ValuePrototype() {
        this.ValueObject = null;
        this.Value = null;
        this.Text = "";
        this.Type = null;

        this.ShowHideId = null;
        this.ShowHideIdName = null;
        this.RequirementLevelId = null;
        this.RequirementLevelIdName = null;
        this.ReadOnlyLevelId = null;
        this.ReadOnlyLevelIdName = null;
        this.DisableLevelId = null;
        this.DisableLevelIdName = null;
        
        this.AttributeId = null;
        this.AttributeIdName = null;
        this.UniqueName = null;
        this.ConditionType = null;
        this.Label = null;
        this.ConditionSetValue = null;
        this.ConditionSetNullValue = null;

    }
    var ActiveValue = new ValuePrototype();
    var ConditionTypeDefault = "1";
    var ConditionTypeDynamic = "2";


    /*Prottype*/

    function GetObjectId(e) {
        if (e.attributes.TargetObjectId == "") {
            var Combo = EntityObjectAttributeList;
            var aId = Combo.getSelectedItem().value
            var Stores = Combo.store.getById(aId)
            return Stores.data.ObjectId;
        } else {
            return e.attributes.TargetObjectId;
        }
    }
    function SelectedNodeDblClick() {

    }
    function AddNewAttribute() {
        HideAllWhereClose();
        SetNullValueWhereClose();
        SetNullValues();
        ActiveValue = new ValuePrototype();
        WindowProperty.show();

    }

    function GetComboAttributeId() {
        alert(eval("WhereEntityAttributeList").getValue());
        return eval("WhereEntityAttributeList").getValue();
    }
    function GetComboAttributeIdName() {
        return eval("WhereEntityAttributeList").getText();
    }


    function WhereEntityAttributeList_Select(Combo) {

        var aId = GetComboAttributeId();
        var Stores = Combo.store.getById(aId)

        ActiveValue.AttributeId = GetComboAttributeId();
        ActiveValue.AttributeIdName = GetComboAttributeIdName();
        var storeData = Combo.store.getById(ActiveValue.AttributeId).data;

        ActiveValue.ShowHideId = null;
        ActiveValue.ShowHideIdName = null;
        ActiveValue.RequirementLevelId = null;
        ActiveValue.RequirementLevelIdName = null;
        ActiveValue.ReadOnlyLevelId = null;
        ActiveValue.ReadOnlyLevelIdName = null;
        ActiveValue.DisableLevelId = null;
        ActiveValue.DisableLevelIdName = null;

        ActiveValue.UniqueName = storeData.UniqueName;
        ActiveValue.Type = storeData.Type;

        ActiveValue.ConditionType = ConditionTypeDefault;
        ActiveValue.ValueObject = SwitchAttributeEntry(true)
        ActiveValue.ConditionSetValue = null;
        ActiveValue.ConditionSetNullValue = null;
        ActiveValue.Text = "";
        ActiveValue.Value = "";


        ClearDynamicTree(Stores.data.AttributeTypeDescription);
        if (Stores.data.AttributeTypeDescription == "picklist") {
            WhereClauseComboStore.reload()
        }
        //alert(storeData.UniqueName);

    }
    function GetAttributeType() {

        var Combo = WhereEntityAttributeList;
        var aId = Combo.getSelectedItem().value
        var Stores = Combo.store.getById(aId)
        var obj = Stores.data.AttributeTypeDescription;

        return obj;
    }
    function ClearDynamicTree(AttributeTypeDescription) {
        try {
            Get("TreeDynamic", "D").root.removeChildren()
            Get("TreeDynamic", "D").root.leaf = false;
            Get("TreeDynamic", "D").root.loaded = false;
            Get("TreeDynamic", "D").root.iconCls = "icon-folder"

            if (AttributeTypeDescription == "datetime" || AttributeTypeDescription == "smalldatetime") {
                Get("TxtAddDays", "D").setVisible(true)
            } else {
                Get("TxtAddDays", "D").setVisible(false)
            }

        } catch (xx) { }
    }
    function HideAllWhereClose() {
        eval("WhereClauseText").hide()
        eval("WhereClauseNumber").hide()
        eval("WhereClauseDecimal").hide()
        eval("WhereClauseDateField").hide()
        eval("WhereClauseCombo").hide();
        eval("workflowIdname").hide();
        eval("WhereClauseHtmlEditor").hide();
        eval("ChkConditionSetValue").hide();
        eval("ChkConditionSetNullValue").hide();

        try {
            eval("WhereClauseDynamicEditor").hide()
            eval("WhereClauseDynamicEditor").hideFieldLabel()
        } catch (exc) { }
    }
    function SetNullValues() {
        eval("ShowHide").setValue(null)
        eval("RequirementLevel").setValue(null)
        eval("WhereEntityAttributeList").setValue(null)
    }
    function SetNullValueWhereClose() {
        eval("WhereClauseText").setValue("")
        eval("WhereClauseNumber").setValue("")
        eval("WhereClauseDecimal").setValue("")
        eval("WhereClauseDateField").setValue("")
        eval("WhereClauseCombo").clearValue();
        eval("WhereClauseCombo").setValue("");
        eval("WhereClauseDynamicEditor").setValue("");
        eval("WhereClauseHtmlEditor").setValue("");
        eval("workflowId").setValue("");
        eval("workflowIdname").setValue("");
        eval("ChkConditionSetValue").setValue(false);
        eval("ChkConditionSetNullValue").setValue(false);

    }


    function SwitchAttributeEntry(remove) {
        obj = GetAttributeType();
        HideAllWhereClose();

        if (remove) {
            SetNullValueWhereClose();
        }

        if (obj && obj != "" && obj.length > 0) {
            eval("ChkConditionSetValue").show();
            eval("ChkConditionSetNullValue").show();
        }
        if (obj == "html") {
            eval("WhereClauseHtmlEditor").show();
            return eval("WhereClauseHtmlEditor");
        }
        if (obj == "nvarchar") {
            eval("WhereClauseText").show();
            return eval("WhereClauseText");
        }
        if (obj == "lookup" || obj == "owner" || obj == "key") {
            eval("workflowId").show()
            eval("workflowIdname").show()
            return eval("workflowIdname")
        }
        if (obj == "number" || obj == "int") {
            eval("WhereClauseNumber").show()
            return eval("WhereClauseNumber");
        }
        if (obj == "decimal" || obj == "float" || obj == "money" || obj == "uom") {
            eval("WhereClauseDecimal").show()
            return eval("WhereClauseDecimal");
        }
        if (obj == "datetime" || obj == "date" || obj == "smalldatetime") {
            eval("WhereClauseDateField").show();
            return eval("WhereClauseDateField");
        }
        if (obj == "picklist" || obj == "bit") {
            eval("WhereClauseCombo").show();
            return eval("WhereClauseCombo");
        }


        return null;
    }

    function addList() {
        ActiveValueSetValue();
        var AttributeId = ActiveValue.AttributeId;
        var AttributeIdName = ActiveValue.AttributeIdName;
        var ShowHideId = ActiveValue.ShowHideId;
        var ShowHideIdName = ActiveValue.ShowHideIdName;
        var RequirementLevelId = ActiveValue.RequirementLevelId;
        var RequirementLevelIdName = ActiveValue.RequirementLevelIdName;
        var ReadOnlyLevelId = ActiveValue.ReadOnlyLevelId;
        var ReadOnlyLevelIdName = ActiveValue.ReadOnlyLevelIdName;

        var DisableLevelId = ActiveValue.DisableLevelId;
        var DisableLevelIdName = ActiveValue.DisableLevelIdName;
        
        var UniqueName = ActiveValue.UniqueName;
        var Type = ActiveValue.Type;
        var ConditionType = ActiveValue.ConditionType;
        var ConditionText = ActiveValue.Text;
        var ConditionValue = ActiveValue.Value;
        var itemGuid = guid();
        var ConditionSetValue = ActiveValue.ConditionSetValue;
        var ConditionSetNullValue = ActiveValue.ConditionSetNullValue;

        if (!IsNull(GrdDefault.store.getById(ActiveValue.AttributeId))) {
            var item = GrdDefault.store.getById(ActiveValue.AttributeId)
            GrdDefault.store.remove(item);
        }


        var MyRecordType = Ext.data.Record.create(['id', 'AttributeId', 'AttributeIdName', 'ShowHideId', 'ShowHideIdName', 'RequirementLevelId', 'RequirementLevelIdName', 'ReadOnlyLevelId', 'ReadOnlyLevelIdName', 'DisableLevelId', 'DisableLevelIdName', 'UniqueName', 'Type', 'ConditionType', 'ConditionText', 'ConditionValue', 'ConditionSetValue', 'ConditionSetNullValue']);
        myrec = new MyRecordType(
                    { "id": AttributeId, "AttributeId": AttributeId, "AttributeIdName": AttributeIdName, "ShowHideId": ShowHideId, "ShowHideIdName": ShowHideIdName, "RequirementLevelId": RequirementLevelId, "RequirementLevelIdName": RequirementLevelIdName, "ReadOnlyLevelId": ReadOnlyLevelId, "ReadOnlyLevelIdName": ReadOnlyLevelIdName, "DisableLevelId": DisableLevelId, "DisableLevelIdName": DisableLevelIdName, "UniqueName": UniqueName,
                        "Type": Type, "ConditionType": ConditionType, "ConditionText": ConditionText, "ConditionValue": ConditionValue,
                        "ConditionSetValue": ConditionSetValue, "ConditionSetNullValue": ConditionSetNullValue
                    }
                , AttributeId);
        GrdDefault.store.insert(GrdDefault.store.data.length, myrec);

        eval("WhereEntityAttributeList").setValue(null);

        WindowProperty.hide();
    }

    function AddDynamicValue(t) {
        var obj = SwitchAttributeEntry(false);

        if (t.getSelectionModel().selNode != null) {
            var a = t.getSelectionModel().selNode;
            var BeforeAfter = Get("CmbBeforeAfter", "D").getValue();

            if (!Get("TxtAddDays", "D").hidden && BeforeAfter != "") {
                var BeforeAfterText = Get("CmbBeforeAfter", "D").getText();

                var Month = Get("nmbrMonth", "D").getValue();
                var Day = Get("nmbrDays", "D").getValue();
                var Hour = Get("nmbrHours", "D").getValue();
                if (Month == "")
                    Month = 0;
                if (Day == "")
                    Day = 0;
                if (Hour == "")
                    Hour = 0;
                var valueString = "{0}:{1}:{2}:{3}:{4}";
                var TextString = "{0} :{1}: {2}:Months; {3}:Days; {4}:Hours";
                ActiveValue.Value = String.format(valueString, BeforeAfter, a.attributes.AttributePath, Month, Day, Hour);
                ActiveValue.Text = String.format(valueString, BeforeAfterText, a.attributes.ParentName, Month, Day, Hour);
                ActiveValue.ConditionType = ConditionTypeDynamic;


                setDynamicValue(obj, ActiveValue);

                Get("nmbrMonth", "D").setValue(null);
                Get("nmbrDays", "D").setValue(null);
                Get("nmbrHours", "D").setValue(null);
                Get("CmbBeforeAfter", "D").setValue(null);

            } else {
                ActiveValue.Value = a.attributes.AttributePath;
                ActiveValue.Text = a.attributes.ParentName;
                ActiveValue.ConditionType = ConditionTypeDynamic;
                setDynamicValue(obj, ActiveValue);
            }
        }


        function setDynamicValue(obj, Val) {
            // var strStyle = "<style>SPAN.DataSlugStyle{tab-index: -1;background-color: #FFFF33;height: 17px;padding-top: 1px;padding-right: 2px;padding-left: 2px;overflow-y: hidden;}</style>";
            var strText = "<SPAN class='DataSlugStyle' contentEditable='false' style='DISPLAY: inline' tabIndex='-1'value='<slugelement type=\"slug\"><slug type=\"dynamic\" value=\"{0}\"/></slugelement>'>{1}</SPAN>";
            slugValue = "{!" + Val.Value + "!}";
            if (obj.id != "WhereClauseHtmlEditor") {
                obj.hide();
                ActiveValue.ValueObject = WhereClauseDynamicEditor;
                eval("WhereClauseDynamicEditor").show();
                eval("WhereClauseDynamicEditor").showFieldLabel();
                if (GetAttributeType() == "nvarchar") {
                    WhereClauseDynamicEditor.insertAtCursor(String.format(strText, slugValue, Val.Text))
                    WhereClauseDynamicEditor.setReadOnly(false);

                }
                else {
                    WhereClauseDynamicEditor.setValue(String.format(strText, slugValue, Val.Text))
                    WhereClauseDynamicEditor.setReadOnly(true);
                }
            } else {
                WhereClauseDynamicEditor.setReadOnly(false);
                obj.insertAtCursor(String.format(strText, slugValue, Val.Text))
                ActiveValue.ValueObject = obj;
            }
        }
    }

    function GetLookUpObjectId() {
        var aId = eval("WhereEntityAttributeList").getSelectedItem().value
        var Stores = eval("WhereEntityAttributeList").store.getById(aId)
        return Stores.data.ReferencedObjectId;
    }
    function GetComboAttributeId() {
        return eval("WhereEntityAttributeList").getValue();
    }
    function GetSelectedValue() {
        if (!IsNull(ActiveValue.Value)) {
            return ActiveValue.Value;
        }
        return "";
    }
    function ActiveValueSetValue() {

        if (ActiveValue.ValueObject != null && ActiveValue.ValueObject.id != "WhereClauseHtmlEditor") {
            switch (ActiveValue.ValueObject && ActiveValue.ValueObject.xtype) {
                case "textfield":
                case "numberfield":
                    ActiveValue.Text = ActiveValue.ValueObject.getValue();
                    ActiveValue.Value = ActiveValue.ValueObject.getValue();
                    break;
                case "datefield":
                    ActiveValue.Text = ActiveValue.ValueObject.value;
                    ActiveValue.Value = ActiveValue.ValueObject.value;
                    break;
                case "coolitetriggercombo":
                    ActiveValue.Text = ActiveValue.ValueObject.getText();
                    ActiveValue.Value = ActiveValue.ValueObject.getValue();
                    break;
                case "coolitetrigger":
                    ActiveValue.Text = ActiveValue.ValueObject.getValue();
                    ActiveValue.Value = eval("workflowId").getValue();
                    break;
                case "htmleditor":
                    ActiveValue.Text = ActiveValue.ValueObject.getValue();
                    ActiveValue.Value = ActiveValue.ValueObject.getValue();
                    break;
            }

        }
        else if (ActiveValue.ValueObject != null && ActiveValue.ValueObject.id == "WhereClauseHtmlEditor") {
            ActiveValue.Text = ActiveValue.ValueObject.getValue();
            ActiveValue.Value = ActiveValue.ValueObject.getValue();
        }

        ActiveValue.AttributeId = GetComboAttributeId();
        ActiveValue.AttributeIdName = GetComboAttributeIdName();
        ActiveValue.ShowHideId = ShowHide.getValue();
        ActiveValue.ShowHideIdName = ShowHide.getText();

        ActiveValue.RequirementLevelId = RequirementLevel.getValue();
        ActiveValue.RequirementLevelIdName = RequirementLevel.getText();

        ActiveValue.ReadOnlyLevelId = ReadOnlyLevel.getValue();
        ActiveValue.ReadOnlyLevelIdName = ReadOnlyLevel.getText();

        ActiveValue.DisableLevelId = DisableLevel.getValue();
        ActiveValue.DisableLevelIdName = DisableLevel.getText();

        ActiveValue.ConditionSetNullValue = ChkConditionSetNullValue.getValue();
        ActiveValue.ConditionSetValue = ChkConditionSetValue.getValue();
    }

    function GrdDefault_DblClick(a, b, c) {
        var data = a.getRowsValues()[0];
        ActiveValue.AttributeId = data.AttributeId;
        WhereEntityAttributeList.setValue(ActiveValue.AttributeId);

        ActiveValue.ShowHideId = data.ShowHideId;
        ShowHide.setValue(ActiveValue.ShowHideId);

        ActiveValue.RequirementLevelId = data.RequirementLevelId;
        RequirementLevel.setValue(ActiveValue.RequirementLevelId);

        ActiveValue.ReadOnlyLevelId = data.ReadOnlyLevelId;
        ReadOnlyLevel.setValue(ActiveValue.ReadOnlyLevelId);

        ActiveValue.DisableLevelId = data.DisableLevelId;
        DisableLevel.setValue(ActiveValue.DisableLevelId);

        HideAllWhereClose();
        WhereEntityAttributeList.setValue(ActiveValue.AttributeId);
        ActiveValue.ValueObject = SwitchAttributeEntry(true)

        var Stores = WhereEntityAttributeList.store.getById(ActiveValue.AttributeId)
        ClearDynamicTree(Stores.data.AttributeTypeDescription);

        ActiveValue.AttributeIdName = data.AttributeIdName;
        ActiveValue.Text = data.ConditionText;
        ActiveValue.ConditionType = data.ConditionType;
        ActiveValue.Value = data.ConditionValue;
        ActiveValue.UniqueName = data.UniqueName;
        ActiveValue.ConditionSetNullValue = data.ConditionSetNullValue;
        ActiveValue.ConditionSetValue = data.ConditionSetValue;
        ChkConditionSetNullValue.setValue(data.ConditionSetNullValue);
        ChkConditionSetValue.setValue(data.ConditionSetValue);
        if (ActiveValue.ValueObject != null) {
            if (ActiveValue.ConditionType == ConditionTypeDynamic) {
                var obj = ActiveValue.ValueObject;

                if (obj.id != "WhereClauseHtmlEditor") {
                    obj.hide();
                    ActiveValue.ValueObject = WhereClauseDynamicEditor;
                    eval("WhereClauseDynamicEditor").show();
                    eval("WhereClauseDynamicEditor").showFieldLabel();
                    if (GetAttributeType() == "nvarchar") {
                        WhereClauseDynamicEditor.setValue(ActiveValue.Value)
                        WhereClauseDynamicEditor.setReadOnly(false);
                    }
                    else {
                        WhereClauseDynamicEditor.setValue(ActiveValue.Value)
                        WhereClauseDynamicEditor.setReadOnly(true);
                    }
                } else {
                    WhereClauseDynamicEditor.setReadOnly(false);
                    obj.setValue(ActiveValue.Value)
                    ActiveValue.ValueObject = obj;
                }
            } else {

                switch (ActiveValue.ValueObject.xtype) {
                    case "textfield":
                    case "numberfield":
                        ActiveValue.ValueObject.setValue(ActiveValue.Value);
                        break;
                    case "datefield":
                        ActiveValue.ValueObject.setValue(ActiveValue.Value);
                        break;
                    case "coolitetriggercombo":
                        ActiveValue.ValueObject.store.removeAll();
                        ActiveValue.ValueObject.setValue(ActiveValue.Value);

                        break;
                    case "coolitetrigger":
                        ActiveValue.ValueObject.setValue(ActiveValue.Text);
                        eval("workflowId").setValue(ActiveValue.Value);
                        break;
                    case "htmleditor":
                        ActiveValue.ValueObject.setValue(ActiveValue.Value);
                        break;
                }
            }
        }
        WindowProperty.show();
    }

    function getXml() {
        return GenerateXml();
    }

    function GenerateXml() {

        var updateinsert = "<batchscript name='" + encodeXml(BatchScriptName.getValue()) + "' objectid='" + lobjectid + "' resetdefault='" + ResetDefault.getValue() + "' formid='" + CmbFormList.getValue() + "' >";
        for (i = 0; i < GrdDefault.store.data.items.length; i++) {
            data = GrdDefault.store.data.items[i].data;
            updateinsert += "<item" + sIsNull(data.AttributeId) + "> ";
            updateinsert += " <attributeid><![CDATA[" + sIsNull(data.AttributeId) + "]]> </attributeid>";
            updateinsert += " <uniquename><![CDATA[" + sIsNull(data.UniqueName) + "]]> </uniquename>";
            updateinsert += " <type><![CDATA[" + sIsNull(data.Type) + "]]> </type>";

            updateinsert += " <attributeidname><![CDATA[" + sIsNull(data.AttributeIdName) + "]]> </attributeidname>";
            updateinsert += " <showhideid><![CDATA[" + sIsNull(data.ShowHideId) + "]]> </showhideid>";
            updateinsert += " <showhideidname><![CDATA[" + sIsNull(data.ShowHideIdName) + "]]> </showhideidname>";
            updateinsert += " <requirementlevelid><![CDATA[" + sIsNull(data.RequirementLevelId) + "]]> </requirementlevelid>";
            updateinsert += " <requirementlevelidname><![CDATA[" + sIsNull(data.RequirementLevelIdName) + "]]> </requirementlevelidname>";
            updateinsert += " <readonlylevelid><![CDATA[" + sIsNull(data.ReadOnlyLevelId) + "]]> </readonlylevelid>";
            updateinsert += " <readonlylevelidname><![CDATA[" + sIsNull(data.ReadOnlyLevelIdName) + "]]> </readonlylevelidname>";

            updateinsert += " <disablelevelid><![CDATA[" + sIsNull(data.DisableLevelId) + "]]> </disablelevelid>";
            updateinsert += " <disablelevelidname><![CDATA[" + sIsNull(data.DisableLevelIdName) + "]]> </disablelevelidname>";

            updateinsert += " <conditiontype><![CDATA[" + sIsNull(data.ConditionType) + "]]> </conditiontype>";
            updateinsert += " <conditiontext><![CDATA[" + sIsNull(data.ConditionText) + "]]> </conditiontext>";
            updateinsert += " <conditionvalue><![CDATA[" + sIsNull(data.ConditionValue) + "]]> </conditionvalue>";
            updateinsert += " <conditionsetvalue><![CDATA[" + sIsNull(data.ConditionSetValue) + "]]> </conditionsetvalue>";
            updateinsert += " <conditionsetnullvalue><![CDATA[" + sIsNull(data.ConditionSetNullValue) + "]]> </conditionsetnullvalue>";
            updateinsert += "</item" + sIsNull(data.AttributeId) + ">"
        }
        updateinsert += "</batchscript>";
        return updateinsert;
    }
    function AddUpdateParentCondition() {
        _AddUpdateParentCondition(BatchScriptName.getValue(), xmlTemplateId.getValue(), laction, type)

    }

    function CmbFormList_OnChange(WEA) {
        SetNullValueWhereClose();
        SetNullValues();
        var selectedId = CmbFormList.getValue();
        if (selectedId.length > 0) {
            WEA.clearValue();
            selectedId = CmbFormList.getValue().ReplaceAll("-", "");
            WEA.bindStore(eval("Store_" + selectedId).id);
        }
    }
</script>
<script src="Wf.js" type="text/javascript"></script>
