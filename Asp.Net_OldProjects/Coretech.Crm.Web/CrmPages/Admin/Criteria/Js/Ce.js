var WorkflowAction = { "New": "New", "Update": "Update" };
var WorkflowStepType = { "Root": "0", "Add": "1", "Remove": "2" }
var valueConditiontype = { "IsTextField": "0", "IsLookupField": "1", "IsNumericField": "2", "IsDecimalField": "3", "IsDateField": "4", "IsPicklistField": "5" }

var mySingleAction = "";
var crmXmlObject = {
    EmptyIfXml: "<?xml version=\"1.0\" encoding=\"utf-16\"?>"
        + "<FilterEntity>"
        + "<id>00000000-0000-0000-0000-000000000000</id>"
        + "<objectid >{0}</objectid>"
        + "<text>Root</text>"
        + "<attributeid >00000000-0000-0000-0000-000000000000</attributeid>"
        + "<leftjoin >false</leftjoin>"
        + "<type >Entity</type>"
        + "</FilterEntity>"
    ,
    str2xml: function (strXML) {
        if (window.ActiveXObject) {
            var doc = new ActiveXObject("Microsoft.XMLDOM");
            doc.async = "false";
            doc.loadXML(strXML);
        }
            // code for Mozilla, Firefox, Opera, etc. 
        else {
            var parser = new DOMParser();
            var doc = parser.parseFromString(strXML, "text/xml");
        } // documentElement always represents the root node 
        return doc;
    },
    xml2string: function (xmlDom) {
        var strs = null;
        var doc = xmlDom.documentElement;
        if (doc.xml == undefined) {
            strs = (new XMLSerializer()).serializeToString(xmlDom);
        } else strs = doc.xml;
        return strs;
    },
    getSubNodeValue: function (Xnode, AttributeName) {
        var ret = "";

        for (var i = 0; i < Xnode.childNodes.length; i++) {
            snode = Xnode.childNodes[i];
            if (snode.nodeName == AttributeName)
                if (snode.childNodes.length > 0) {
                    return snode.firstChild.nodeValue;
                } else {
                    return snode.nodeValue;
                }
        }
        ret = "";
        return ret;
    },
    getNodeValue: function (Xnode, AttributeName) {
        var ret = "";
        try {
            ret = Xnode.attributes.getNamedItem(AttributeName).nodeValue;
        } catch (err) {

        }
        return ret;
    }
}

var WfBuilder = {
    ShowEdit: function (wAction, wsType) {
        mySingleAction = wAction;
        if (wAction == WorkflowAction.New) {

            IFCondition.Show(WorkflowStepType.Add, String.format(crmXmlObject.EmptyIfXml, hdnObjectId.getValue()), "");

        }
        else {

            IFCondition.Show(this.SelectedItemType(),  this.SelectedItemData(), this.SelectedItemText());

        }

    },
    SelectedItemData: function () {
        var selected = this.GetSelectedItemData()
        if (selected) {
            return selected[this.dataType.data].Value;
        }
    },
    SelectedItemType: function () {
        var selected = this.GetSelectedItemData()
        if (selected) {
            return selected[this.dataType.Type].Value;
        }
    },
    SelectedItemText: function () {
        var selected = this.GetSelectedItemData()
        if (selected) {
            return selected[this.dataType.text].Value;
        }
    },
    GetSelectedItemData: function () {
        var sn = WItems.selectedNode;
        if (!sn[0]) {
            alert("[SELECTION_ERRROR]");
            return false;
        } else {
            return sn;
        }
    },
    EditUpdateNode: function (stepType, title, xml) {
        var sn = WItems.selectedNode;
        var _Leaf = true;
        stepType = stepType;
        treeNode = {
            Text: title,
            Expanded: true,
            Leaf: _Leaf,
            ConfigItems: [
                { Name: "text", Value: title, Mode: "Value" },
                { Name: "id", Value: "", Mode: "Value" },
                { Name: "Type", Value: stepType, Mode: "Value" },
                { Name: "ClauseValue", Value: "", Mode: "Value" },
                { Name: "ClauseText", Value: title, Mode: "Value" },
                { Name: "data", Value: xml, Mode: "Value" },
            ],
            Nodes: [],
            Icon: this.GetTypeIcon(stepType),
            Checked: null
        };

        if (mySingleAction == WorkflowAction.Update) {
            WItems.updateSelectedNode(treeNode)
        } else {

            WItems.addTreeNode(treeNode)
        }
    },
    GetTypeIcon: function (stepType) {
        switch (stepType) {
            case WorkflowStepType.Add:
                return "icon-add";
                break;
            case WorkflowStepType.Remove:
                return "icon-delete";
                break;
            case WorkflowStepType.Root:
                return "icon-folder";
                break;
        }
    },
    RemoveNode: function () {
        if (WItems.selectedNodeClass)
            WItems.removeNode(WItems.selectedNodeClass, true);
    },

    dataType: { "text": 0, "id": 1, "Type": 2, "ClauseValue": 3, "ClauseText": 4, "data": 5 }
};
//#region IFcondition
var DynamicValues = {
    dataType: { "NodeName": 0, "AttributeId": 1, "TargetObjectId": 2, "AttributePath": 3, "ParentName": 4, "CurrentObjectId": 5 }
};

function OpenIfCondition(Data, isNew) {
    if (isNew) {
        IFCondition.Show(String.format(crmXmlObject.EmptyIfXml, hdnObjectId.getValue()), "");
    }
    else {

    }
}
var IFCondition = {
    ClearValues: function () {
        CmbIfReleatedEntity.clear();
        chkIfLeftJoin.clear();
        CmbIfAttribute.clear();
        CmbIfCondition.clear();
        IfConditionClauseValue.clear();
        IfConditionConditionType.clear();
        LblIfConditionClausetext.clear();
        IfcValuesConditionType.setValue(this.conditionType.Default);
    },
    Show: function (type,argxml, title) {
        WindowIfCondition.show();
        var xmlobj = crmXmlObject.str2xml(argxml)
        var root = [];
        root.push(this.AddTreeNodes(xmlobj.lastChild, 0));
        TreeIfConditions.fillNodes(root);
        IfConditionName.setValue(title);
        IfConditionType.setValue(type);
        IfconditionHdnObjectId.setValue(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "objectid"));
        this.ClearValues();

    },
    ConditionChanged: function (showFromServer) {
        var se = CmbIfCondition.selectedRecord;
        if (
                (CmbIfCondition.getValue() != "" && (se.IsTextField || se.IsNumericField || se.IsDecimalField || se.IsDateField || se.IsLookupField || se.IsPicklistField))
                || showFromServer
        ) {
            btnIfConditionValues.show();
            LblIfConditionClausetext.show();
        } else {
            btnIfConditionValues.hide();
            LblIfConditionClausetext.hide();
        }
    },
    SetConditionValue: function () {

        var lbltext = ""; //Only text isn't operational
        var realvalue = ""; //its only operational it hasn't any meaning;
        if (IfcValuesConditionType.getValue() == this.conditionType.Dynamic) {
            lbltext = IfcDynamicValuesTextField.getValue();
            realvalue = IfcDynamicValuesHiddenField.getValue();
        }
        else {
            switch (hdnWindowIfcValuType.getValue()) {
                case valueConditiontype.IsTextField:
                    lbltext = IfcValuesTextField.getValue();
                    realvalue = lbltext;
                    break;
                case valueConditiontype.IsLookupField:
                    lbltext = IfcValuesLookupField.selectedRecord.VALUE;
                    realvalue = IfcValuesLookupField.selectedRecord.ID;
                    break;
                case valueConditiontype.IsNumericField:
                    lbltext = IfcValuesNumericField.getValue();
                    realvalue = lbltext;
                    break;
                case valueConditiontype.IsDecimalField:
                    lbltext = IfcValuesDecimalField.getValue();
                    realvalue = lbltext;
                    break;
                case valueConditiontype.IsDateField:
                    lbltext = IfcValuesDateField.getValue();
                    realvalue = lbltext;
                    break;
                case valueConditiontype.IsPicklistField:
                    lbltext = IfcValuesPicklistField.getRawValue();
                    realvalue = IfcValuesPicklistField.getValue();

                    break;
                default:
                    break;
            }
        }
        LblIfConditionClausetext.setValue(lbltext);
        IfConditionClauseValue.setValue(realvalue);
        IfConditionConditionType.setValue(IfcValuesConditionType.getValue())
        WindowIfcValues.hide();
    },
    ShowConditionValue: function () {
        IfConditionValuesEdit.click();
        WindowIfcValues.show();
        TreeGridDynamicValue.emptyNodes();
    },
    AddCondition: function () {
        var data = this.GetSelectedItemData();
        var dataType = data[this.dataType.type];
        //fds();
        switch (dataType.Value) { // if the selected object is on of the following types , we must create new item
            case this.dataTypeValue.Entity:
            case this.dataTypeValue.And:
            case this.dataTypeValue.Or:

                break;
            case this.dataTypeValue.Attribute: //we must update selected item
                data[this.dataType.text].Value = CmbIfAttribute.getRawValue() + " " + CmbIfCondition.getRawValue() + " " + LblIfConditionClausetext.getValue();
                TreeIfConditions.updateSelectedNode(data);
                break;
            default:
                break;
        }
    },
    AddEntity: function () {
        if (TreeIfConditions.selectedNode) {
            var Treetype = TreeIfConditions.selectedNode[this.dataType.type].Value;

            if (Treetype == this.dataTypeValue.And || Treetype == this.dataTypeValue.Or || Treetype == this.dataTypeValue.Entity) {
                treeNode = {
                    Text: this.dataTypeValue.Entity,
                    Expanded: true,
                    Leaf: false,
                    ConfigItems: [
                { Name: "text", Value: CmbIfReleatedEntity.getRawValue() + ((chkIfLeftJoin.getValue()) ? "-->Left Join" : ""), Mode: "Value" },
                { Name: "id", Value: "", Mode: "Value" },
                { Name: "objectid", Value: CmbIfReleatedEntity.selectedRecord.ObjectId, Mode: "Value" },
                { Name: "objectId", Value: CmbIfReleatedEntity.selectedRecord.ObjectId, Mode: "Value" },
                { Name: "leftjoin", Value: (chkIfLeftJoin.getValue()) ? "true" : "false", Mode: "Value" },
                { Name: "type", Value: this.dataTypeValue.Entity, Mode: "Value" },
                { Name: "attributeid", Value: CmbIfReleatedEntity.getValue(), Mode: "Value" },
                { Name: "entityobjectid", Value: CmbIfReleatedEntity.selectedRecord.ObjectId, Mode: "Value" },
                { Name: "conditionvalue", Value: "", Mode: "Value" },
                { Name: "clausevalue", Value: "", Mode: "Value" },
                { Name: "clausetext", Value: "", Mode: "Value" },
                { Name: "conditiontype", Value: "", Mode: "Value" },
                { Name: "clausevalue2", Value: "", Mode: "Value" }
                    ],
                    Nodes: [],
                    Icon: this.GetTypeIcon(this.dataTypeValue.Entity),
                    Checked: null
                };
                TreeIfConditions.addTreeNode(treeNode);
                this.ClearValues();
            }
        }
    },
    AddAnd: function () {

        if (TreeIfConditions.selectedNode) {
            var Treetype = TreeIfConditions.selectedNode[this.dataType.type].Value;
            if (Treetype == this.dataTypeValue.And || Treetype == this.dataTypeValue.Or || Treetype == this.dataTypeValue.Entity) {
                treeNode = {
                    Text: "And",
                    Expanded: true,
                    Leaf: false,
                    ConfigItems: [
                { Name: "text", Value: this.dataTypeValue.And, Mode: "Value" },
                { Name: "id", Value: "", Mode: "Value" },
                { Name: "objectid", Value: TreeIfConditions.selectedNode[this.dataType.objectid].Value, Mode: "Value" },
                { Name: "objectId", Value: TreeIfConditions.selectedNode[this.dataType.objectId].Value, Mode: "Value" },
                { Name: "leftjoin", Value: "", Mode: "Value" },
                { Name: "type", Value: this.dataTypeValue.And, Mode: "Value" },
                { Name: "attributeid", Value: "", Mode: "Value" },
                { Name: "entityobjectid", Value: TreeIfConditions.selectedNode[this.dataType.entityobjectid].Value, Mode: "Value" },
                { Name: "conditionvalue", Value: "", Mode: "Value" },
                { Name: "clausevalue", Value: "", Mode: "Value" },
                { Name: "clausetext", Value: "", Mode: "Value" },
                { Name: "conditiontype", Value: "", Mode: "Value" },
                { Name: "clausevalue2", Value: "", Mode: "Value" }
                    ],
                    Nodes: [],
                    Icon: this.GetTypeIcon(this.dataTypeValue.And),
                    Checked: null
                };
                TreeIfConditions.addTreeNode(treeNode);
                this.ClearValues();
            }
        }
    },
    AddOr: function () {
        if (TreeIfConditions.selectedNode) {
            var Treetype = TreeIfConditions.selectedNode[this.dataType.type].Value;
            if (Treetype == this.dataTypeValue.And || Treetype == this.dataTypeValue.Or || Treetype == this.dataTypeValue.Entity) {
                treeNode = {
                    Text: this.dataTypeValue.Or,
                    Expanded: true,
                    Leaf: false,
                    ConfigItems: [
                { Name: "text", Value: this.dataTypeValue.Or, Mode: "Value" },
                { Name: "id", Value: "", Mode: "Value" },
                { Name: "objectid", Value: TreeIfConditions.selectedNode[this.dataType.objectid].Value, Mode: "Value" },
                { Name: "objectId", Value: TreeIfConditions.selectedNode[this.dataType.objectId].Value, Mode: "Value" },
                { Name: "leftjoin", Value: "", Mode: "Value" },
                { Name: "type", Value: this.dataTypeValue.Or, Mode: "Value" },
                { Name: "attributeid", Value: "", Mode: "Value" },
                { Name: "entityobjectid", Value: TreeIfConditions.selectedNode[this.dataType.entityobjectid].Value, Mode: "Value" },
                { Name: "conditionvalue", Value: "", Mode: "Value" },
                { Name: "clausevalue", Value: "", Mode: "Value" },
                { Name: "clausetext", Value: "", Mode: "Value" },
                { Name: "conditiontype", Value: "", Mode: "Value" },
                { Name: "clausevalue2", Value: "", Mode: "Value" }
                    ],
                    Nodes: [],
                    Icon: this.GetTypeIcon(this.dataTypeValue.Or),
                    Checked: null
                };
                TreeIfConditions.addTreeNode(treeNode);
                this.ClearValues();
            }
        }
    },
    AddConditionDyanicValue: function () {

        if (TreeGridDynamicValue.selectedNode) {
            var text = TreeGridDynamicValue.selectedNode[DynamicValues.dataType.ParentName].Value;
            var value = TreeGridDynamicValue.selectedNode[DynamicValues.dataType.AttributePath].Value

            IfcValuesTextField.hide();
            IfcValuesNumericField.hide();
            IfcValuesDecimalField.hide();
            IfcValuesDateField.hide();
            IfcValuesLookupField.hide();
            IfcValuesPicklistField.hide();

            IfcDynamicValuesTextField.setValue(text);
            IfcDynamicValuesHiddenField.setValue(value);
        }


    },
    GetTypeIcon: function (strType) {
        switch (strType) {
            case this.dataTypeValue.Entity:
                return "icon-application";
                break;
            case this.dataTypeValue.Attribute:
                return "icon-bulletorange";
                break;
            case this.dataTypeValue.And:
                return "icon-arrowjoin";
                break;
            case this.dataTypeValue.Or:
                return "icon-arrowswitch";
                break;
            default:
                break;
        }
    },
    RemoveCondition: function () {
        if (TreeIfConditions.selectedNodeClass)
            TreeIfConditions.removeNode(TreeIfConditions.selectedNodeClass, true);

    },
    RowSelected: function () {
        this.ClearValues();
        var data = this.GetSelectedItemData();
        var dataType = data[this.dataType.type]
        switch (dataType.Value) {
            case this.dataTypeValue.Entity:

                IfconditionHdnObjectId.setValue(data[this.dataType.objectid].Value);
                break;
            case this.dataTypeValue.Attribute:
                IfConditionGetAttributeData.click();
                break;
            case this.dataTypeValue.And:

                IfconditionHdnObjectId.setValue(data[this.dataType.objectid].Value);

                break;
            case this.dataTypeValue.Or:


                IfconditionHdnObjectId.setValue(data[this.dataType.objectid].Value);
                break;
            default:
                break;
        }
    },
    GetTreeNodeFromxNode: function (xnode) {
        treeNode = {
            Text: crmXmlObject.getSubNodeValue(xnode, "text"),
            Expanded: true,
            Leaf: (crmXmlObject.getSubNodeValue(xnode, "type") == this.dataTypeValue.Attribute) ? true : false,
            ConfigItems: [
                { Name: "text", Value: crmXmlObject.getSubNodeValue(xnode, "text"), Mode: "Value" },
                { Name: "id", Value: crmXmlObject.getSubNodeValue(xnode, "id"), Mode: "Value" },
                { Name: "objectid", Value: crmXmlObject.getSubNodeValue(xnode, "objectid"), Mode: "Value" },
                { Name: "objectId", Value: crmXmlObject.getSubNodeValue(xnode, "objectId"), Mode: "Value" },
                { Name: "leftjoin", Value: crmXmlObject.getSubNodeValue(xnode, "leftjoin"), Mode: "Value" },
                { Name: "type", Value: crmXmlObject.getSubNodeValue(xnode, "type"), Mode: "Value" },
                { Name: "attributeid", Value: crmXmlObject.getSubNodeValue(xnode, "attributeid"), Mode: "Value" },
                { Name: "entityobjectid", Value: crmXmlObject.getSubNodeValue(xnode, "entityobjectid"), Mode: "Value" },
                { Name: "conditionvalue", Value: crmXmlObject.getSubNodeValue(xnode, "conditionvalue"), Mode: "Value" },
                { Name: "clausevalue", Value: crmXmlObject.getSubNodeValue(xnode, "clausevalue"), Mode: "Value" },
                { Name: "clausetext", Value: crmXmlObject.getSubNodeValue(xnode, "clausetext"), Mode: "Value" },
                { Name: "conditiontype", Value: crmXmlObject.getSubNodeValue(xnode, "conditiontype"), Mode: "Value" },
                { Name: "clausevalue2", Value: crmXmlObject.getSubNodeValue(xnode, "clausevalue2"), Mode: "Value" }
            ],
            Nodes: [],
            Icon: this.GetTypeIcon(crmXmlObject.getSubNodeValue(xnode, "type")),
            Checked: null
        };
        return treeNode;
    },
    AddTreeNodes: function (xnode, level) {
        var RootTreeNode = null;
        if (xnode.nodeName == "FilterEntity" || xnode.nodeName == "FilterAttribute") {
            RootTreeNode = this.GetTreeNodeFromxNode(xnode);
        }
        for (var i = 0; i < xnode.childNodes.length; i++) {
            var snode = xnode.childNodes[i]
            if (snode.nodeName == "FilterEntityList" || snode.nodeName == "FilterAttributeList") {
                for (var j = 0; j < snode.childNodes.length; j++) {
                    var snode2 = snode.childNodes[j];
                    if (snode2.nodeName == "FilterEntity" || snode2.nodeName == "FilterAttribute") {
                        RootTreeNode.Nodes.push(this.AddTreeNodes(snode2, ++level));
                    }
                }
            }
        }
        return RootTreeNode;
    },
    SelectedData: function (dataname) {
        var selected = this.GetSelectedItemData()
        if (selected) {
            return selected[dataname].Value;
        }
    },
    GetSelectedItemData: function () {
        var sn = TreeIfConditions.selectedNode;
        if (!sn[0]) {
            alert("[SELECTION_ERRROR]")
            return false;
        } else {
            return sn;
        }
    },
    dataType: { "text": 0, "id": 1, "objectid": 2, "objectId": 3, "leftjoin": 4, "type": 5, "attributeid": 6, "entityobjectid": 7, "conditionvalue": 8, "clausevalue": 9, "clausetext": 10, "conditiontype": 11, "clausevalue2": 12 },
    dataTypeValue: { "And": "And", "Or": "Or", "Attribute": "Attribute", "Entity": "Entity" },
    conditionType: { "Dynamic": "Dynamic", "Default": "Default", "None": "None" },
    Save: function (xml) {
        WfBuilder.EditUpdateNode(IfConditionType.getValue(), IfConditionName.getValue(), xml);
        alert(IfConditionType.getValue())
        WindowIfCondition.hide();
    },
};
function ValidateBeforeForm(msg, e) {
    if (EntityId.getValue() == null || EntityId.getValue() == "") {
        alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), EntityId.getFieldLabel()));
        EntityId.focus();
        e.returnValue = false;
        return false;
    }
    if (AttributeId.getValue() == null || AttributeId.getValue() == "") {
        alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), AttributeId.getFieldLabel()));
        AttributeId.focus();
        e.returnValue = false;
        return false;
    }

}
//#end region