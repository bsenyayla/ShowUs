<style type="text/css">
    .editable
    {
        font: 12px Tahoma;
        padding: 3px 5px;
        margin-bottom: 20px;
        background-color: #aac;
    }
    .editable-over
    {
        background-color: #ffc;
    }
</style>
<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_WorkFlow_ConditionBuilder" Codebehind="ConditionBuilder.ascx.cs" %>
<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<%@ Register Assembly="Coretech.Crm.Web.UI" Namespace="Coretech.Crm.Web.UI.AutoGenerate"
    TagPrefix="CrmUI" %>
<ext:Hidden runat="server" ID="hdnObjectId">
</ext:Hidden>
<ext:Hidden runat="server" ID="hdnClientId">
</ext:Hidden>
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
<ext:Store runat="server" ID="StoreEntityObjectAttributeList" AutoLoad="true">
    <SortInfo Field="Label" Direction="ASC" />
    <Reader>
        <ext:JsonReader ReaderID="AttributeId">
            <Fields>
                <ext:RecordField Name="AttributeId" />
                <ext:RecordField Name="Label" />
                <ext:RecordField Name="UniqueName" />
                <ext:RecordField Name="ReferencedObjectId" />
            </Fields>
        </ext:JsonReader>
    </Reader>
</ext:Store>
<ext:Store runat="server" ID="WhereClauseComboStore" AutoLoad="false" OnRefreshData="WhereClauseComboStore_Refresh">
    <Proxy>
        <ext:DataSourceProxy />
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
<ext:Panel runat="server">
    <Body>
        <ext:Panel ID="Panel2" runat="server">
            <Body>
                <ext:Panel ID="Panel3" runat="server" Title="Attribute List" Height="130">
                    <Body>
                        <ext:FormLayout ID="FormLayout1" runat="server" LabelAlign="Left">
                            <ext:Anchor>
                                <ext:ComboBox runat="server" AllowBlank="false" ID="WhereEntityAttributeList" StoreID="StoreWhereAttribute"
                                    ValueField="AttributeId" DisplayField="Label" FieldLabel="Attributes">
                                    <Listeners>
                                        <Select Handler="WhereClauseSetStore(#{WhereEntityAttributeList},#{WhereClause});" />
                                    </Listeners>
                                </ext:ComboBox>
                            </ext:Anchor>
                            <ext:Anchor>
                                <ext:ComboBox runat="server" ID="WhereClause" AllowBlank="false" ValueField="AttributeConditionId"
                                    DisplayField="Description" FieldLabel="Condition">
                                    <Listeners>
                                        <Select Handler="SwitchAttributeEntry(#{WhereClause})" />
                                    </Listeners>
                                </ext:ComboBox>
                            </ext:Anchor>
                            <ext:Anchor>
                                <ext:MultiField FieldLabel="Values" runat="server" Width="300">
                                    <Fields>
                                        <ext:Button Text="..." runat="server">
                                            <Listeners>
                                                <Click Handler="ShowWhereClause(#{WindowWhereClause})" />
                                            </Listeners>
                                        </ext:Button>
                                        <ext:Label ID="LblWhereClauseValue" runat="server" Cls="editable" OverCls="editable-over"
                                            Width="300" Html="" Icon="TagRed" IconAlign="Right">
                                        </ext:Label>
                                    </Fields>
                                </ext:MultiField>
                            </ext:Anchor>
                        </ext:FormLayout>
                    </Body>
                    <BottomBar>
                        <ext:Toolbar ID="Toolbar2" runat="server">
                            <Items>
                                <ext:Button ID="WherePanelAdd" runat="server" Icon="Add" Text="Add Condition">
                                    <Listeners>
                                        <Click CausesValidation="true" Handler="AddUpdateTreeChilde(#{WhereTree},#{WhereClause},#{WhereEntityAttributeList})" />
                                    </Listeners>
                                </ext:Button>
                                <ext:ToolbarFill>
                                </ext:ToolbarFill>
                                <ext:Button ID="WherePanelAnd" runat="server" Text="And" Icon="Add">
                                    <Listeners>
                                        <Click CausesValidation="true" Handler="AddAndOr(#{WhereTree},And)" />
                                    </Listeners>
                                </ext:Button>
                                <ext:Button ID="WherePanelOr" runat="server" Text="Or" Icon="Add">
                                    <Listeners>
                                        <Click CausesValidation="true" Handler="AddAndOr(#{WhereTree},Or)" />
                                    </Listeners>
                                </ext:Button>
                            </Items>
                        </ext:Toolbar>
                    </BottomBar>
                </ext:Panel>
                <ext:Panel ID="Panel5" runat="server" Title="Releated Entity">
                    <Body>
                        <ext:FormLayout ID="FormLayout3" runat="server">
                            <ext:Anchor>
                                <ext:MultiField ID="MultiField2" runat="server" FieldLabel="Releated Fields" HideLabel="false">
                                    <Fields>
                                        <ext:ComboBox runat="server" AllowBlank="false" ID="WhereEntityObjectAttributeList"
                                            StoreID="StoreEntityObjectAttributeList" ValueField="AttributeId" DisplayField="Label">
                                        </ext:ComboBox>
                                    </Fields>
                                </ext:MultiField>
                            </ext:Anchor>
                            <ext:Anchor>
                                <ext:Checkbox runat="server" ID="WhereEntityObjectLeftJoin" FieldLabel="Left Join">
                                </ext:Checkbox>
                            </ext:Anchor>
                            <ext:Anchor>
                                <ext:TextField runat="server" ID="WhereEntityObjectAlias" FieldLabel="Alias" AllowBlank="false" MaxLength="4">
                                </ext:TextField>
                            </ext:Anchor>
                            <ext:Anchor>
                                <ext:Checkbox runat="server" ID="WhereEntityUnSecure" FieldLabel="UnSecure">
                                </ext:Checkbox>
                            </ext:Anchor>
                        </ext:FormLayout>
                    </Body>
                    <BottomBar>
                        <ext:Toolbar ID="Toolbar3" runat="server">
                            <Items>
                                <ext:Button ID="Button7" runat="server" Icon="Add" Text="Add Releated List">
                                    <Listeners>
                                        <Click ValidationGroup="vg1" CausesValidation="true" Handler="
                                                if(#{WhereEntityObjectAttributeList}.validate() && #{WhereEntityObjectAlias}.validate())
                                            {
                                                AddUpdateTreeHeader(#{WhereTree});
                                            }
                                                else{alert('Enter ')}
                                              " />
                                    </Listeners>
                                </ext:Button>
                            </Items>
                        </ext:Toolbar>
                    </BottomBar>
                </ext:Panel>
            </Body>
        </ext:Panel>
        <ext:TreePanel ID="WhereTree" runat="server" Icon="NoteEdit" Height="450" AutoScroll="true" EnableDD="true">
            <TopBar>
                <ext:Toolbar ID="Toolbar1" runat="server">
                    <Items>
                        <ext:Button ID="Button5" runat="server" Text="Expand All" Icon="ArrowDown">
                            <Listeners>
                                <Click Handler="#{WhereTree}.expandAll();" />
                            </Listeners>
                        </ext:Button>
                        <ext:Button ID="Button6" runat="server" Text="Collapse All" Icon="ArrowUp">
                            <Listeners>
                                <Click Handler="#{WhereTree}.collapseAll();" />
                            </Listeners>
                        </ext:Button>
                        <ext:Button ID="Button8" runat="server" Text="Delete Selected" Icon="Delete">
                            <Listeners>
                                <Click Handler="DeleteTree(#{WhereTree})" />
                            </Listeners>
                        </ext:Button>
                    </Items>
                </ext:Toolbar>
            </TopBar>
            <Root>
            </Root>
            <AjaxEvents>
                <Click Before="WhereClauseEntityObjectAttributeListSetStore(#{WhereTree}.getSelectionModel().selNode,#{WhereEntityAttributeList})"
                    OnEvent="WhereTree_OnClick" Success="UpdateWhereClause(#{WhereTree}.getSelectionModel().selNode,#{WhereClause},#{WhereEntityAttributeList});">
                    <EventMask ShowMask="true" CustomTarget="EntityAttributeList" />
                    <ExtraParams>
                        <ext:Parameter Name="Type" Value="node.attributes.Type" Mode="Raw">
                        </ext:Parameter>
                        <ext:Parameter Name="ObjectId" Value="node.attributes.ObjectId" Mode="Raw">
                        </ext:Parameter>
                        <ext:Parameter Name="AttributeId" Value="node.attributes.AttributeId" Mode="Raw">
                        </ext:Parameter>
                    </ExtraParams>
                </Click>
            </AjaxEvents>
        </ext:TreePanel>
    </Body>
</ext:Panel>
<ext:Window ID="WindowWhereClause" runat="server" Modal="True" Icon="ApplicationEdit"
    Width="300" ShowOnLoad="false">
    <Body>
        <ext:FormLayout runat="server" LabelAlign="Top">
            <ext:Anchor>
                <CrmUI:CrmLookupComp ID="WhereClauseLookup" runat="server" ObjectId="10" UniqueName="workflowId"
                    Width="260" LookupViewId="" FieldLabel="Look Up Selecter" Style="padding-left: 105px;">
                </CrmUI:CrmLookupComp>
            </ext:Anchor>
            <ext:Anchor>
                <ext:TextField ID="WhereClauseText" Hidden="true" AllowBlank="false" runat="server"
                    Width="260" FieldLabel="Text Value" MaxLength="100">
                </ext:TextField>
            </ext:Anchor>
            <ext:Anchor>
                <ext:NumberField ID="WhereClauseNumber" Hidden="true" AllowBlank="false" runat="server"
                    Width="260" FieldLabel="Number Value" AllowDecimals="false">
                </ext:NumberField>
            </ext:Anchor>
            <ext:Anchor>
                <ext:NumberField ID="WhereClauseDecimal" Hidden="true" AllowBlank="false" runat="server"
                    Width="260" FieldLabel="Decimal Value" AllowDecimals="true">
                </ext:NumberField>
            </ext:Anchor>
            <ext:Anchor>
                <ext:DateField ID="WhereClauseDateField" Hidden="true" AllowBlank="false" runat="server"
                    Width="260" FieldLabel="Date Value">
                </ext:DateField>
            </ext:Anchor>
            <ext:Anchor>
                <ext:ComboBox ID="WhereClauseCombo" TypeAhead="true" Mode="Local" TriggerAction="All"
                    Width="260" ValueField="Value" FieldLabel="Combo Value" DisplayField="Label"
                    runat="server" StoreID="WhereClauseComboStore" Hidden="false">
                </ext:ComboBox>
            </ext:Anchor>
        </ext:FormLayout>
    </Body>
    <BottomBar>
        <ext:Toolbar runat="server">
            <Items>
                <ext:Button Text="Ok" runat="server">
                    <Listeners>
                        <Click Handler="SetWhereClauseValue(#{WindowWhereClause},#{LblWhereClauseValue},#{WhereClause})" />
                    </Listeners>
                </ext:Button>
                <ext:Button Text="Cancel" runat="server">
                    <Listeners>
                        <Click Handler="#{WindowWhereClause}.hide();" />
                    </Listeners>
                </ext:Button>
            </Items>
        </ext:Toolbar>
    </BottomBar>
</ext:Window>
<script language="javascript" type="text/javascript">
    function ValuePrototype() {
        this.Value = null;
        this.Text = "";
        this.Type = null;
    }
    var ActiveValue = new ValuePrototype();

    var Ent = "Entity";
    var Attr = "Attribute";
    var And = "And";
    var Or = "Or";
    var ConditionTypeDefault = "1";
    var ConditionTypeDynamic = "2";


    function SetWhereCloses(WCItem) {
        ActiveValue = new ValuePrototype();
        ActiveValue.Type = ConditionTypeDefault;
        var WhereClauseValue = null, WhereClauseValueText = "", WhereCloseConditionText = "";
        var WhereClauseObject = null;
        var aId = WCItem.getSelectedItem().value
        var Stores = WCItem.store.getById(aId)

        if (Stores != null) {

            if (Stores.data.IsTextField) {
                WhereClauseObject = Get("WhereClauseText", "C");
            }
            if (Stores.data.IsLookupField) {
                WhereClauseObject = Get("workflowIdname", "C");
            }
            if (Stores.data.IsNumericField) {

                WhereClauseObject = Get("WhereClauseNumber", "C");
            }
            if (Stores.data.IsDecimalField) {
                WhereClauseObject = Get("WhereClauseDecimal", "C");
            }
            if (Stores.data.IsDateField) {
                WhereClauseObject = Get("WhereClauseDateField", "C");
            }
            if (Stores.data.IsPicklistField) {
                WhereClauseObject = Get("WhereClauseCombo", "C");
            }
            if (WhereClauseObject != null) {
                switch (WhereClauseObject.xtype) {
                    case "textfield":
                    case "numberfield":
                        ActiveValue.Text = WhereClauseObject.getValue();
                        ActiveValue.Value = WhereClauseObject.getValue();
                        break;
                    case "datefield":
                        ActiveValue.Text = WhereClauseObject.value;
                        ActiveValue.Value = WhereClauseObject.value;
                        break;
                    case "coolitetriggercombo":
                        ActiveValue.Text = WhereClauseObject.getText();
                        ActiveValue.Value = WhereClauseObject.getValue();
                        break;
                    case "coolitetrigger":
                        ActiveValue.Text = WhereClauseObject.getValue();
                        ActiveValue.Value = Get("workflowId", "C").getValue();
                        break;
                }
            }
        }
    }


    function AddUpdateTreeChilde(TreeItem, WCItem, WcEaL) {
        if (WCItem.validate() && WcEaL.validate()) {
            var WhereClauseObject = null;
            var aId = WCItem.getSelectedItem().value
            var Stores = WCItem.store.getById(aId)

            if (Stores != null) {
                WhereCloseConditionValue = Stores.id;
                WhereCloseConditionText = WCItem.getSelectedItem().text;
                var aId = WcEaL.getSelectedItem().value
                var aValue = WcEaL.getSelectedItem().text
                strText = aValue + ' ' + WhereCloseConditionText + ' ' + ActiveValue.Text;
                if (TreeItem.getSelectionModel().selNode.attributes.Type != Attr) {/*Insert Mode*/
                    selNode = TreeItem.getSelectionModel().selNode;

                    var newNode = new Ext.tree.TreeNode({
                        id: guid(),
                        text: strText,
                        leaf: false,
                        AttributeId: aId,
                        Type: Attr,
                        EntityObjectId: selNode.attributes.ObjectId,
                        ObjectId: selNode.attributes.ObjectId,
                        iconCls: "icon-add",
                        ClauseValue: ActiveValue.Value,
                        ClauseText: ActiveValue.Text,
                        ConditionValue: WhereCloseConditionValue,
                        ConditionType: ActiveValue.Type
                    }
			);
                    selNode.appendChild(newNode);
                    selNode.expand();
                } else {
                    /*Update*/
                    selNode = TreeItem.getSelectionModel().selNode;
                    selNode.setText(strText);
                    selNode.attributes.AttributeId = aId;
                    selNode.attributes.ClauseValue = ActiveValue.Value;
                    selNode.attributes.ClauseText = ActiveValue.Text;
                    selNode.attributes.ConditionType = ActiveValue.Type
                    selNode.attributes.ConditionValue = WhereCloseConditionValue;
                }
            }
        }
        ActiveValue = new ValuePrototype();
    }


    function AddAndOr(TreeItem, AndOr) {
        selNode = TreeItem.getSelectionModel().selNode;
        if (TreeItem.getSelectionModel().selNode.attributes.Type == Attr) {
            if (selNode.parentNode != null)
                selNode = selNode.parentNode;
            else
                return;
        }
        var aValue = AndOr
        var newNode = new Ext.tree.TreeNode({
            id: guid(),
            text: aValue, leaf: false,
            AttributeId: "", Type: AndOr,
            EntityObjectId: selNode.attributes.ObjectId,
            ObjectId: selNode.attributes.ObjectId,
            LeftJoin: "",
            ObjectAlias: "",
            UnSecure: "",
            iconCls: "icon-folder"
        });
        selNode.appendChild(newNode);
        selNode.expand();
    }
    function AddUpdateTreeHeader(TreeItem) {
        selNode = TreeItem.getSelectionModel().selNode;
        var MyNode = TreeItem.getSelectionModel().selNode;
        while (true) {
            if (MyNode.attributes.Type == Ent) {
                selNode = MyNode;
                break;
            }
            else if (!IsNull(MyNode.parentNode))
                MyNode = MyNode.parentNode
            else
                return;
        }
        var aId = Get("WhereEntityObjectAttributeList", "C").getSelectedItem().value
        var Stores = Get("WhereEntityObjectAttributeList", "C").store.getById(aId)
        var aValue = Get("WhereEntityObjectAttributeList", "C").getSelectedItem().text
        if (Get("WhereEntityObjectLeftJoin", "C").getValue()) {
            aValue += "--> Left Join";
        }
        if (Get("WhereEntityUnSecure", "C").getValue()) {
            aValue += "-->UnSecure";
        }

        var alias = Get("WhereEntityObjectAlias", "C").getValue();
        if (alias != "") {
            aValue += "(" + alias + ")";
        }
        var newNode = new Ext.tree.TreeNode({
            id: guid(),
            text: aValue, leaf: false,
            AttributeId: aId, Type: Ent,
            EntityObjectId: selNode.attributes.ObjectId,
            ObjectId: Stores.data.ReferencedObjectId,
            LeftJoin: Get("WhereEntityObjectLeftJoin", "C").getValue(),
            iconCls: "icon-folder",
            ObjectAlias: alias,
            UnSecure: Get("WhereEntityUnSecure", "C").getValue(),
        });
        Get("WhereEntityObjectLeftJoin", "C").setValue(null);
        Get("WhereEntityObjectAlias", "C").setValue(null);
        Get("WhereEntityObjectAttributeList", "C").setValue(null);
        Get("WhereEntityUnSecure", "C").setValue(null);
        
        selNode.appendChild(newNode);
        selNode.expand();
    }

    function DeleteTree(Object) {
        if (Get("WhereTree", "C").getSelectionModel().selNode != null) {
            if (Get("WhereTree", "C").getSelectionModel().selNode.parentNode != null) {
                Get("WhereTree", "C").getSelectionModel().selNode.remove()
            }
        }
    }
    function SwitchAttributeEntry(obj) {
        var aId = obj.getSelectedItem().value
        var Stores = obj.store.getById(aId)

        if (Stores != null) {

            Get("WhereClauseText", "C").hide()
            Get("WhereClauseNumber", "C").hide()
            Get("WhereClauseDecimal", "C").hide()
            Get("WhereClauseDateField", "C").hide()
            Get("WhereClauseCombo", "C").hide();
            Get("workflowIdname", "C").hide();

            Get("WhereClauseText", "C").setValue("")
            Get("WhereClauseNumber", "C").setValue("")
            Get("WhereClauseDecimal", "C").setValue("")
            Get("WhereClauseDateField", "C").setValue("")
            Get("WhereClauseCombo", "C").clearValue();
            Get("WhereClauseCombo", "C").setValue("");


            Get("workflowId", "C").setValue("");
            Get("workflowIdname", "C").setValue("");


            if (Stores.data.IsTextField) {
                Get("WhereClauseText", "C").show();
                return Get("WhereClauseText", "C");
            }
            if (Stores.data.IsLookupField) {
                Get("workflowId", "C").show()
                Get("workflowIdname", "C").show()
                return Get("workflowIdname", "C")
            }
            if (Stores.data.IsNumericField) {
                Get("WhereClauseNumber", "C").show()
                return Get("WhereClauseNumber", "C");
            }
            if (Stores.data.IsDecimalField) {
                Get("WhereClauseDecimal", "C").show()
                return Get("WhereClauseDecimal", "C");
            }
            if (Stores.data.IsDateField) {
                Get("WhereClauseDateField", "C").show();
                return Get("WhereClauseDateField", "C");
            }
            if (Stores.data.IsPicklistField) {
                Get("WhereClauseCombo", "C").show();
                return Get("WhereClauseCombo", "C");
            }
        }
        return null;
    }

    var selectedTreeNodeValue = null;
    function GetSelectedValue() {
        if (!IsNull(selectedTreeNodeValue)) {
            return selectedTreeNodeValue;
        }
        return "";
    }
    function UpdateWhereClause(TreeNode, WCItem, WcEaL) {
        var i = 0;
        while (WCItem.store == null) {
        }
        while (WcEaL.store == null) {
        }
        setLabelValue("");
        if (TreeNode.attributes.Type == Attr) {

            selectedTreeNodeValue = TreeNode.attributes.ClauseValue;
            WcEaL.setValueAndFireSelect(TreeNode.attributes.AttributeId)
            WCItem.setValueAndFireSelect(TreeNode.attributes.ConditionValue)

            var WhereClauseObject = SwitchAttributeEntry(WCItem)
            setLabelValue(TreeNode.attributes.ClauseText);

            if (WhereClauseObject != null && TreeNode.attributes.ConditionType == ConditionTypeDefault) {
                if (WhereClauseObject.xtype == "coolitetriggercombo") {
                    WhereClauseObject.clearValue("");
                    WhereClauseObject.store.reload();
                }
                else if (WhereClauseObject.xtype == "coolitetrigger") {
                    Get("workflowId", "C").setValue(TreeNode.attributes.ClauseValue);
                    WhereClauseObject.setValue(TreeNode.attributes.ClauseText);
                }
                else {
                    WhereClauseObject.setValue(TreeNode.attributes.ClauseValue);
                }
            }
        }
        selectedTreeNodeValue = null;
    }
    function WhereClauseEntityObjectAttributeListSetStore(TreeNode, WcEaL) {
        WcEaL.clearValue();

        Get("WhereClauseText", "C").hide()
        Get("WhereClauseNumber", "C").hide()
        Get("WhereClauseDecimal", "C").hide()
        Get("WhereClauseDateField", "C").hide()
        Get("WhereClauseCombo", "C").hide();
        Get("workflowIdname", "C").hide();
        WcEaL.bindStore(Get("Store_" + TreeNode.attributes.ObjectId, "C").id);
    }
    function WhereClauseSetStore(WcEaL, WCItem) {
        var aId = WcEaL.getSelectedItem().value
        var Stores = WcEaL.store.getById(aId)
        if (Stores.data.AttributeTypeDescription != null) {
            WCItem.clearValue();

            WCItem.bindStore(Get("Store_" + Stores.data.AttributeTypeDescription, "C").id);
        }

        Get("WhereClauseComboStore", "C").reload();
        try {
            Get("TreeDynamic", "D").root.removeChildren()
            Get("TreeDynamic", "D").root.leaf = false;
            Get("TreeDynamic", "D").root.loaded = false;
            Get("TreeDynamic", "D").root.iconCls = "icon-folder"
            if (Stores.data.AttributeTypeDescription == "datetime" || Stores.data.AttributeTypeDescription == "smalldatetime") {
                Get("TxtAddDays", "D").setVisible(true)
            } else {
                Get("TxtAddDays", "D").setVisible(false)
            }
        } catch (xx) { }
    }
    function GetComboAttributeId() {
        return Get("WhereEntityAttributeList", "C").getValue();
    }

    function GetLookUpObjectId() {

        var aId = Get("WhereEntityAttributeList", "C").getSelectedItem().value
        var Stores = Get("WhereEntityAttributeList", "C").store.getById(aId)

        return Stores.data.ReferencedObjectId;
    }

    function getChildeXml(TreeNode) {
        var strXml = ""
        debugger;
        if (TreeNode.attributes != null) {
            var AttributeId = TreeNode.attributes.AttributeId;
            var id = TreeNode.attributes.id;
            var ObjectId = TreeNode.attributes.ObjectId;
            var text = TreeNode.attributes.text;
            var Type = TreeNode.attributes.Type;
            var EntityObjectId = TreeNode.attributes.EntityObjectId;
            var ConditionValue = TreeNode.attributes.ConditionValue;
            var ClauseText = TreeNode.attributes.ClauseText;
            var ClauseValue = TreeNode.attributes.ClauseValue;
            var LeftJoin = TreeNode.attributes.LeftJoin;
            var ObjectAlias = TreeNode.attributes.ObjectAlias;
            var UnSecure = TreeNode.attributes.UnSecure;

            var ConditionType = TreeNode.attributes.ConditionType;
            if (Type != Attr) {
                strXml += "<Entity" + id
                    + " id='" + id
                    + "' objectid='" + ObjectId
                    + "' attributeid='{" + AttributeId
                    + "}' leftjoin='" + LeftJoin
                    + "' objectAlias='" + ObjectAlias
                    + "'  type='" + Type + "'" +
                    "    unsecure='" + UnSecure + "' >";
                strXml += "<text><![CDATA[" + text + "]]> </text>"
                for (var i = 0; i < TreeNode.childNodes.length; i++) {
                    strXml += getChildeXml(TreeNode.childNodes[i])
                }
                strXml += "</Entity" + id + ">";
            } else {
                strXml += "<Attribute attributeid='{" + AttributeId + "}' id='{" + id + "}' objectId='"
                    + ObjectId + "'  type='"
                    + Type + "' entityobjectid='"
                    + EntityObjectId + "' conditionvalue='{" + ConditionValue + "}'  conditiontype='" + ConditionType + "' >";

                strXml += "<text><![CDATA[" + text + "]]> </text>";
                strXml += "<clausevalue><![CDATA[" + ClauseValue + "]]> </clausevalue>";
                strXml += "<clausetext><![CDATA[" + ClauseText + "]]> </clausetext>";
                strXml += "</Attribute>";
            }
        }
        return strXml;
    }
    function ShowWhereClause(e) {
        e.show();
    }
    function SetWhereClauseValue(e, l, WCItem) {
        SetWhereCloses(WCItem)
        setLabelValue(ActiveValue.Text)
        e.hide();
    }
    function setLabelValue(txt) {
        Get("LblWhereClauseValue", "C").setText(String.format("{0}", txt), false)
    }
</script>
