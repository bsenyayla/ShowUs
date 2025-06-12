<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_WorkFlow_AddUpdateRecord" ValidateRequest="false" Codebehind="AddUpdateRecord.aspx.cs" %>

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
                        <ext:RecordField Name="AttributeId" />
                        <ext:RecordField Name="AttributeIdName" />
                        <ext:RecordField Name="ConditionType" />
                        <ext:RecordField Name="ConditionText" />
                        <ext:RecordField Name="ConditionValue" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store runat="server" ID="StoreEntityObjectAttributeList" AutoLoad="true">
            <SortInfo Field="Label" Direction="ASC" />
            <Reader>
                <ext:JsonReader ReaderID="AttributeId">
                    <Fields>
                        <ext:RecordField Name="ObjectId" />
                        <ext:RecordField Name="AttributeId" />
                        <ext:RecordField Name="Label" />
                        <ext:RecordField Name="UniqueName" />
                        <ext:RecordField Name="ReferencedObjectId" />
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
                        <ext:RecordField Name="UniqueName" />
                        <ext:RecordField Name="AttributeTypeDescription" />
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
                                                <ext:TextField ID="CreateUpdateName" FieldLabel="Name" Width="300" runat="server" />
                                            </ext:Anchor>
                                            <ext:Anchor>
                                                <ext:Checkbox ID="OpenWindow" FieldLabel="OpenWindow" runat="server" />
                                            </ext:Anchor>
                                             <ext:Anchor>
                                                <ext:Checkbox ID="DisablePlugin" FieldLabel="Disable Plugin" runat="server" />
                                            </ext:Anchor>
                                             <ext:Anchor>
                                                <ext:Checkbox ID="DisableWf" FieldLabel="Disable Wf" runat="server" />
                                            </ext:Anchor>

                                        </ext:FormLayout>
                                    </Body>
                                </ext:Panel>
                            </ext:LayoutColumn>
                            <ext:LayoutColumn ColumnWidth=".5">
                                <ext:Panel ID="Panel4" runat="server" Border="false">
                                    <Body>
                                        <ext:FormLayout ID="FormLayout2" runat="server" LabelAlign="Left" LabelWidth="50">
                                            <ext:Anchor>
                                                <ext:ComboBox runat="server" AllowBlank="false" ID="EntityObjectAttributeList" StoreID="StoreEntityObjectAttributeList"
                                                    ValueField="AttributeId" DisplayField="Label" Width="300">
                                                    <Listeners>
                                                        <Select Handler="WhereClauseEntityObjectAttributeListSetStore(#{EntityObjectAttributeList},#{WhereEntityAttributeList})" />
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
                                    <ext:Column Header="Değeri" MenuDisabled="true" DataIndex="ConditionText" Sortable="false"
                                        Width="300">
                                    </ext:Column>
                                    <ext:Column Header="ConditionType" MenuDisabled="true" DataIndex="ConditionType"
                                        Hidden="true" Sortable="false" Width="100">
                                    </ext:Column>
                                    <ext:Column Header="ConditionValue" MenuDisabled="true" DataIndex="ConditionValue"
                                        Hidden="true" Sortable="false" Width="300">
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
        <ext:Window runat="server" ID="WindowProperty" Modal="true" ShowOnLoad="false" Width="650"
            Height="350">
            <Body>
                <ext:FitLayout runat="server">
                    <ext:Panel runat="server">
                        <Body>
                            <ext:BorderLayout ID="BorderLayout1" runat="server">
                                <Center>
                                    <ext:Panel runat="server">
                                        <Body>
                                            <ext:Panel runat="server">
                                                <Body>
                                                    <ext:FormLayout runat="server" LabelAlign="Left">
                                                        <ext:Anchor>
                                                            <ext:ComboBox runat="server" AllowBlank="false" ID="WhereEntityAttributeList" StoreID="StoreWhereAttribute"
                                                                ValueField="AttributeId" DisplayField="Label" FieldLabel="Attributes" Width="300">
                                                                <Listeners>
                                                                    <Select Handler="WhereEntityAttributeList_Select(#{WhereEntityAttributeList})" />
                                                                </Listeners>
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <CrmUI:CrmLookupComp ID="WhereClauseLookup" runat="server" ObjectId="10" UniqueName="workflowId"
                                                                LookupViewId="" FieldLabel="Look Up Selecter" Style="padding-left: 105px;" Width="300">
                                                            </CrmUI:CrmLookupComp>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:TextField ID="WhereClauseText" AllowBlank="false" runat="server" FieldLabel="Text Value"
                                                                MaxLength="100" Width="300">
                                                            </ext:TextField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:NumberField ID="WhereClauseNumber" AllowBlank="false" runat="server" FieldLabel="Number Value"
                                                                AllowDecimals="false" Width="300">
                                                            </ext:NumberField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:NumberField ID="WhereClauseDecimal" AllowBlank="false" runat="server" FieldLabel="Decimal Value"
                                                                AllowDecimals="true" Width="300">
                                                            </ext:NumberField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:DateField ID="WhereClauseDateField" AllowBlank="false" runat="server" FieldLabel="Date Value"
                                                                Width="300">
                                                            </ext:DateField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:ComboBox ID="WhereClauseCombo" TypeAhead="true" Mode="Remote" MinChars="1" ValueField="Value"
                                                                FieldLabel="Combo Value" DisplayField="Label" runat="server" StoreID="WhereClauseComboStore"
                                                                Width="300">
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:HtmlEditor ID="WhereClauseDynamicEditor" FieldLabel="Dynamic Value" runat="server"
                                                                CtCls="hide-toolbar" Height="150" Width="300">
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
                                    <ext:Panel ID="Panel3" runat="server" Width="200" Title="Dynamic Value" Collapsed="false"
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
        this.AttributeId = null;
        this.AttributeIdName = null;
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
        ActiveValue = new ValuePrototype();
        WindowProperty.show();

    }

    function GetComboAttributeId() {
        return eval("WhereEntityAttributeList").getValue();
    }
    function GetComboAttributeIdName() {
        return eval("WhereEntityAttributeList").getText();
    }

    function WhereClauseEntityObjectAttributeListSetStore(Combo, WcEaL) {
        WcEaL.clearValue();

        var aId = Combo.getSelectedItem().value
        var Stores = Combo.store.getById(aId)
        HideAllWhereClose();

        if (Stores.data.ObjectId != null) {
            WcEaL.bindStore(eval("Store_" + Stores.data.ObjectId).id);

        }
    }
    function WhereEntityAttributeList_Select(Combo) {
        var aId = Combo.getSelectedItem().value
        var Stores = Combo.store.getById(aId)
        ActiveValue.AttributeId = GetComboAttributeId();
        ActiveValue.AttributeIdName = GetComboAttributeIdName();
        ActiveValue.Type = ConditionTypeDefault;
        ActiveValue.ValueObject = SwitchAttributeEntry(true)
        ActiveValue.Text = "";
        ActiveValue.Value = "";

        ClearDynamicTree(Stores.data.AttributeTypeDescription);
        if (Stores.data.AttributeTypeDescription == "picklist") {
            WhereClauseComboStore.reload()
        }
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

        try {
            eval("WhereClauseDynamicEditor").hide()
            eval("WhereClauseDynamicEditor").hideFieldLabel()
        } catch (exc) { }
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
    }
    function SwitchAttributeEntry(remove) {
        obj = GetAttributeType();
        HideAllWhereClose();
        
        if (remove) {
            SetNullValueWhereClose();
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
        if (obj == "decimal" || obj == "float" || obj == "money" | obj == "uom") {
            eval("WhereClauseDecimal").show()
            return eval("WhereClauseDecimal");
        }
        if (obj == "datetime" || obj == "date" || obj == "smalldatetime") {
            eval("WhereClauseDateField").show();
            return eval("WhereClauseDateField");
        }
        if (obj == "picklist") {
            eval("WhereClauseCombo").show();
            return eval("WhereClauseCombo");
        }

        return null;
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
                ActiveValue.Type = ConditionTypeDynamic;


                setDynamicValue(obj, ActiveValue);

                Get("nmbrMonth", "D").setValue(null);
                Get("nmbrDays", "D").setValue(null);
                Get("nmbrHours", "D").setValue(null);
                Get("CmbBeforeAfter", "D").setValue(null);

            } else {
                ActiveValue.Value = a.attributes.AttributePath;
                ActiveValue.Text = a.attributes.ParentName;
                ActiveValue.Type = ConditionTypeDynamic;
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
    function addList() {
        ActiveValueSetValue();
        var AttributeId = ActiveValue.AttributeId;
        var ConditionType = ActiveValue.Type;
        var ConditionText = ActiveValue.Text;
        var AttributeIdName = ActiveValue.AttributeIdName;
        var ConditionValue = ActiveValue.Value;
        var itemGuid = guid();


        if (!IsNull(GrdDefault.store.getById(ActiveValue.AttributeId))) {
            var item = GrdDefault.store.getById(ActiveValue.AttributeId)
            GrdDefault.store.remove(item);
        }


        var MyRecordType = Ext.data.Record.create(['id', 'AttributeId', 'AttributeIdName', 'ConditionType', 'ConditionText', 'ConditionValue']);
        myrec = new MyRecordType(
                    { "id": AttributeId, "AttributeId": AttributeId, "AttributeIdName": AttributeIdName, "ConditionType": ConditionType, "ConditionText": ConditionText, "ConditionValue": ConditionValue }
                , AttributeId);
        GrdDefault.store.insert(GrdDefault.store.data.length, myrec);



        eval("WhereEntityAttributeList").setValue(null);
        ClearDynamicTree()
        WindowProperty.hide();
    }
    function ActiveValueSetValue() {
        if (ActiveValue.ValueObject != null && ActiveValue.ValueObject.id != "WhereClauseHtmlEditor") {
            switch (ActiveValue.ValueObject.xtype) {
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
    }

    function GrdDefault_DblClick(a, b, c) {
        var data = a.getRowsValues()[0];
        ActiveValue.AttributeId = data.AttributeId;
        HideAllWhereClose();
        WhereEntityAttributeList.setValue(ActiveValue.AttributeId);
        ActiveValue.ValueObject = SwitchAttributeEntry(true)

        var Stores = WhereEntityAttributeList.store.getById(ActiveValue.AttributeId)
        ClearDynamicTree(Stores.data.AttributeTypeDescription);

        ActiveValue.AttributeIdName = data.AttributeIdName;
        ActiveValue.Text = data.ConditionText;
        ActiveValue.Type = data.ConditionType;
        ActiveValue.Value = data.ConditionValue;


        if (ActiveValue.Type == ConditionTypeDynamic) {
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

        WindowProperty.show();
    }

    function getXml() {
        return GenerateXml();
    }

    function GenerateXml() {
        //selamdur();
        var updateinsert = "<updateinsert name='" + encodeXml(CreateUpdateName.getValue()) + "' objectattributeid='" + EntityObjectAttributeList.getValue() + "' openwindow='" + OpenWindow.getValue() + "' disableplugin='" + DisablePlugin.getValue() + "' disablewf='" + DisableWf.getValue() + "' >";
        for (i = 0; i < GrdDefault.store.data.items.length; i++) {
            data = GrdDefault.store.data.items[i].data;
            updateinsert += "<item" + data.AttributeId + "> ";
            updateinsert += " <attributeid><![CDATA[" + data.AttributeId + "]]> </attributeid>";
            updateinsert += " <attributeidname><![CDATA[" + data.AttributeIdName + "]]> </attributeidname>";
            updateinsert += " <conditiontype><![CDATA[" + data.ConditionType + "]]> </conditiontype>";
            updateinsert += " <conditiontext><![CDATA[" + data.ConditionText + "]]> </conditiontext>";
            updateinsert += " <conditionvalue><![CDATA[" + data.ConditionValue + "]]> </conditionvalue>";
            updateinsert += "</item" + data.AttributeId + ">"
        }
        updateinsert += "</updateinsert>";
        return updateinsert;
    }

    function AddUpdateParentCondition() {
        _AddUpdateParentCondition(CreateUpdateName.getValue(), xmlTemplateId.getValue(), laction, type)
        
    }
</script>
<script src="Wf.js" type="text/javascript"></script>