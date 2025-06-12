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
            ret = Xnode.attributes.getNamedItem(AttributeName).nodeValue
        } catch (err) {

        }
        return ret;
    }
}
var WorkflowAction = { "New": "New", "Update": "Update" };
var WorkflowStepType = { "Root": "0", "IfCondition": "1", "WaitCondition": "2", "Create": "3", "Update": "4", "ShowMessage": "5", "DynamicUrl": "6", "StopWorkFlow": "7", "BatchScript": "8", "RedirectForm": "9", "Plugin": "10", "Workflow": "11" }
var valueConditiontype = { "IsTextField": "0", "IsLookupField": "1", "IsNumericField": "2", "IsDecimalField": "3", "IsDateField": "4", "IsPicklistField": "5" }

var WfBuilder = {
    ShowEdit: function (wAction, wsType) {
        mySingleAction = wAction;
        if (wAction == WorkflowAction.New) {
            switch (wsType) {
                case WorkflowStepType.IfCondition:

                    IFCondition.Show(String.format(crmXmlObject.EmptyIfXml, hdnObjectId.getValue()), "");
                    break;
                case WorkflowStepType.BatchScript:
                    BatchScript.Show(String.format(crmXmlObject.EmptyIfXml, hdnObjectId.getValue()), "");
                    break;
                case WorkflowStepType.Update:
                    UpdateRecord.Show(String.format(crmXmlObject.EmptyIfXml, hdnObjectId.getValue()), "");
                    break;
                case WorkflowStepType.Create:
                    CreateRecord.Show(String.format(crmXmlObject.EmptyIfXml, hdnObjectId.getValue()), "");
                    break;
                case WorkflowStepType.ShowMessage:
                    Message.Show(String.format(crmXmlObject.EmptyIfXml, hdnObjectId.getValue()), "");
                    break;
                case WorkflowStepType.DynamicUrl:
                    DynamicUrl.Show(String.format(crmXmlObject.EmptyIfXml, hdnObjectId.getValue()), "");
                    break;
                case WorkflowStepType.RedirectForm:
                    RedirectForm.Show(String.format(crmXmlObject.EmptyIfXml, hdnObjectId.getValue()), "");
                    break;
                case WorkflowStepType.Plugin:
                    PluginMessage.Show(String.format(crmXmlObject.EmptyIfXml, hdnObjectId.getValue()), "");
                    break;
                case WorkflowStepType.StopWorkFlow:
                    StopWf.Add();
                    break;
                case WorkflowStepType.Workflow:
                    SubWorkflow.Show(String.format(crmXmlObject.EmptyIfXml, hdnObjectId.getValue()), "");
                    break;
            }
        }
        else {
            var stype = this.SelectedItemType();
            switch (stype) {
                case WorkflowStepType.IfCondition:
                    IFCondition.Show(this.SelectedItemData(), this.SelectedItemText());
                    break;
                case WorkflowStepType.BatchScript:
                    BatchScript.Show(this.SelectedItemData(), this.SelectedItemText());
                    break;
                case WorkflowStepType.Update:
                    UpdateRecord.Show(this.SelectedItemData(), this.SelectedItemText());
                    break;
                case WorkflowStepType.Create:
                    CreateRecord.Show(this.SelectedItemData(), this.SelectedItemText());
                    break;
                case WorkflowStepType.ShowMessage:
                    Message.Show(this.SelectedItemData(), this.SelectedItemText());
                    break;
                case WorkflowStepType.DynamicUrl:
                    DynamicUrl.Show(this.SelectedItemData(), this.SelectedItemText());
                    break;
                case WorkflowStepType.RedirectForm:
                    RedirectForm.Show(this.SelectedItemData(), this.SelectedItemText());
                    break;
                case WorkflowStepType.Plugin:
                    PluginMessage.Show(this.SelectedItemData(), this.SelectedItemText());
                    break;

                case WorkflowStepType.Workflow:
                    SubWorkflow.Show(this.SelectedItemData(), this.SelectedItemText());
                    break;
                default:
                    break;
            }
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
            alert("[SELECTION_ERRROR]")
            return false;
        } else {
            return sn;
        }
    },
    EditUpdateNode: function (stepType, title, xml) {
        var sn = WItems.selectedNode;
        var _Leaf = false;
        switch (stepType) {
            case WorkflowStepType.IfCondition:
                _Leaf = false;
                break;
            case WorkflowStepType.WaitCondition:
                _Leaf = false;
                break;
            case WorkflowStepType.Create:
                _Leaf = true;
                break;
            case WorkflowStepType.Update:
                _Leaf = true;
                break;
            case WorkflowStepType.ShowMessage:
                _Leaf = true;
                break;
            case WorkflowStepType.DynamicUrl:
                _Leaf = true;
                break;
            case WorkflowStepType.StopWorkFlow:
                _Leaf = true;
                break;
            case WorkflowStepType.BatchScript:
                _Leaf = true;
                break;
            case WorkflowStepType.RedirectForm:
                _Leaf = true;
                break;
            case WorkflowStepType.Plugin:
                _Leaf = true;
                break;
            case WorkflowStepType.Workflow:
                _Leaf = true;
                break;
        }

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
            case WorkflowStepType.IfCondition:
                return "icon-arrowrotateanticlockwise";
                break;
            case WorkflowStepType.WaitCondition:
                return "icon-time";
                break;
            case WorkflowStepType.Create:
                return "icon-applicationadd";
                break;
            case WorkflowStepType.Update:
                return "icon-applicationedit";
                break;
            case WorkflowStepType.ShowMessage:
                return "icon-commentadd";
                break;
            case WorkflowStepType.DynamicUrl:
                return "icon-linkedit";
                break;
            case WorkflowStepType.StopWorkFlow:
                return "icon-stop";
                break;
            case WorkflowStepType.BatchScript:
                return "icon-scriptgear";
                break;
            case WorkflowStepType.RedirectForm:
                return "icon-reload";
                break;
            case WorkflowStepType.Plugin:
                return "icon-plugin";
                break;
            case WorkflowStepType.Workflow:
                return "icon-chartorganisation";
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
    Show: function (argxml, title) {
        WindowIfCondition.show();
        var xmlobj = crmXmlObject.str2xml(argxml)
        var root = [];
        root.push(this.AddTreeNodes(xmlobj.lastChild, 0));
        TreeIfConditions.fillNodes(root);
        IfConditionName.setValue(title);
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
        WfBuilder.EditUpdateNode(WorkflowStepType.IfCondition, IfConditionName.getValue(), xml);
        WindowIfCondition.hide();
    },
};

//#end region

var BatchScript = {
    Show: function (argxml, title) {
        this.CleartProperty();
        WindowBatchScript.show();
        var xmlobj = crmXmlObject.str2xml(argxml)
        BatchScriptName.setValue(title);
        BatchScriptHdnObjectId.setValue(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "ObjectId"));
        BatchScriptForm.setValue(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "FormId"));
        BatchScriptReset.setValue(eval(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "ResetDefault")));

        if (mySingleAction == WorkflowAction.Update) {
            BatchScriptForm.setDisabled(true);
        } else {
            BatchScriptForm.setDisabled(false);
        }

        this.fillFromXml(xmlobj.lastChild);
    },
    fillFromXml: function (xnode) {
        GridBatchScript.clear();
        GridBatchScript.clearData();
        for (var i = 0; i < xnode.childNodes.length; i++) {
            if (xnode.childNodes[i].nodeName == "BatchScriptDetail") {
                var snode = xnode.childNodes[i]
                for (var j = 0; j < snode.childNodes.length; j++) {

                    if (snode.childNodes[j].nodeName == "BatchScriptDetail") {
                        var nType = R.clone(this.dataTypeName);
                        var ssnode = snode.childNodes[j];
                        nType.Label = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.Label)
                        nType.UniqueNama = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.UniqueNama)
                        nType.AttributeId = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.AttributeId)
                        nType.ShowHideId = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ShowHideId)
                        nType.RequirementLevelId = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.RequirementLevelId)
                        nType.ReadOnlyLevelId = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ReadOnlyLevelId)
                        nType.DisableLevelId = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.DisableLevelId)
                        nType.ConditionType = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionType)
                        nType.ConditionValue = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionValue)
                        nType.ConditionValueXml = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionValueXml)
                        nType.ConditionSetValue = eval(crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionSetValue))
                        nType.ConditionSetNullValue = eval(crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionSetNullValue))
                        nType.ConditionText = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionText)
                        nType.Type = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.Type)
                        GridBatchScript.insertRow(nType)
                    }

                }
            }
            //
        }
    },
    FillRowHtml: function (ConditionText) {
        return ConditionText;
    },
    AddEmptyRow: function () {
        GridBatchScript.insertRow();
    },
    RemoveSelectedRow: function () {
        if (GridBatchScript.selectedRowId >= 0) {
            GridBatchScript.deleteRow();
            this.CleartProperty();
        }
    },
    CleartProperty: function () {
        BatchScriptPropertyFormElement.clear();
        BatchScriptPropertyShowHide.setValue(this.propertyData.None);
        BatchScriptPropertyRequirementLevel.setValue(this.propertyData.None);
        BatchScriptPropertyReadOnlyLevel.setValue(this.propertyData.None);
        BatchScriptPropertyDisableLevel.setValue(this.propertyData.None);
        BatchScriptPropertySetValue.setValue(false);
        BatchScriptPropertySetNullValue.setValue(false);
        BatchScriptPropertyValueLabel.innerHTML = "";
        BatchScriptPropertyValue.setValue("");
        BatchScriptPropertyConditionType.setValue("");

    },
    BatchScriptSelected: function () {
        //this.UpdateOldData();
        this.CleartProperty();
        var rec = GridBatchScript.selectedRecord;
        if (rec.AttributeId != "") {
            BatchScriptPropertyFormElement.setValue(rec.AttributeId, rec.Label);
            BatchScriptPropertyShowHide.setValue(rec.ShowHideId);
            BatchScriptPropertyRequirementLevel.setValue(rec.RequirementLevelId);
            BatchScriptPropertyReadOnlyLevel.setValue(rec.ReadOnlyLevelId);
            BatchScriptPropertyDisableLevel.setValue(rec.DisableLevelId);
            BatchScriptPropertySetValue.setValue(rec.ConditionSetValue);
            BatchScriptPropertySetNullValue.setValue(rec.ConditionSetNullValue);
            BatchScriptPropertyValueLabel.innerHTML = rec.ConditionText;
            BatchScriptPropertyValue.setValue(rec.ConditionValue);
            BatchScriptPropertyConditionType.setValue(rec.ConditionType);

        }
    },
    UpdateChangedData: function (obj) {
        var gRowId = GridBatchScript.selectedRowId;
        switch (obj.id) {
            case BatchScriptPropertyFormElement.id:
                GridBatchScript.updateColumn(gRowId, this.dataTypeName.Label, BatchScriptPropertyFormElement.getRawValue());
                GridBatchScript.updateColumn(gRowId, this.dataTypeName.AttributeId, BatchScriptPropertyFormElement.getValue());
                GridBatchScript.updateColumn(gRowId, this.dataTypeName.Type, BatchScriptPropertyFormElement.selectedRecord.Type);
                break;
            case BatchScriptPropertyShowHide.id:
                GridBatchScript.updateColumn(gRowId, this.dataTypeName.ShowHideId, BatchScriptPropertyShowHide.getValue());
                break;
            case BatchScriptPropertyRequirementLevel.id:
                GridBatchScript.updateColumn(gRowId, this.dataTypeName.RequirementLevelId, BatchScriptPropertyRequirementLevel.getValue());
                break;
            case BatchScriptPropertyReadOnlyLevel.id:
                GridBatchScript.updateColumn(gRowId, this.dataTypeName.ReadOnlyLevelId, BatchScriptPropertyReadOnlyLevel.getValue());
                break;
            case BatchScriptPropertyDisableLevel.id:
                GridBatchScript.updateColumn(gRowId, this.dataTypeName.DisableLevelId, BatchScriptPropertyDisableLevel.getValue());
                break;
            case BatchScriptPropertySetValue.id:
                GridBatchScript.updateColumn(gRowId, this.dataTypeName.ConditionSetValue, eval(BatchScriptPropertySetValue.getValue()));
                break;
            case BatchScriptPropertySetNullValue.id:
                GridBatchScript.updateColumn(gRowId, this.dataTypeName.ConditionSetNullValue, eval(BatchScriptPropertySetNullValue.getValue()));
                break;

            case BatchScriptPropertyValueLabel.id:
                GridBatchScript.updateColumn(gRowId, this.dataTypeName.ConditionText, BatchScriptPropertyValueLabel.innerHTML);
                break;
            case BatchScriptPropertyValue.id:
                GridBatchScript.updateColumn(gRowId, this.dataTypeName.ConditionValue, BatchScriptPropertyValue.getValue());
                break;
            case BatchScriptPropertyConditionType.id:
                GridBatchScript.updateColumn(gRowId, this.dataTypeName.ConditionType, BatchScriptPropertyConditionType.getValue());
                break;
        }
    },
    AddDynamicValue: function () {
        BatchScriptPropertyValueLabel.innerHTML = hdnValueSelectorTextField.getValue();
        BatchScriptPropertyValue.setValue(hdnValueSelectorValueField.getValue());
        BatchScriptPropertyConditionType.setValue(hdnValueSelectorValuType.getValue());
        this.UpdateChangedData(BatchScriptPropertyValueLabel);
        this.UpdateChangedData(BatchScriptPropertyValue);
        this.UpdateChangedData(BatchScriptPropertyConditionType);

    },
    PrepareValueSelector: function () {
        var rec = GridBatchScript.selectedRecord;
        var recid = GridBatchScript.selectedRowId;
        if (recid >= 0 && rec.AttributeId != "") {
            hdnValueSelectorAttributeId.setValue(rec.AttributeId);
            hdnValueSelectorValuType.setValue(rec.ConditionType);
            hdnValueSelectorTextField.setValue(rec.ConditionText);
            hdnValueSelectorValueField.setValue(rec.ConditionValue);
            hdnValueSelectorAfterScript.setValue("BatchScript.AddDynamicValue();");
            WindowValueSelectorShow.click();
        }
    },
    SaveData: function () {

    },
    dataType: { "Label": 0, "UniqueNama": 1, "AttributeId": 2, "ShowHideId": 3, "RequirementLevelId": 4, "ReadOnlyLevelId": 5, "DisableLevelId": 6, "ConditionType": 7, "ConditionValue": 8, "ConditionValueXml": 9, "ConditionSetValue": 10, "ConditionSetNullValue": 11, "ConditionText": 12, "Type": 13 },
    dataTypeName: { "Label": "Label", "UniqueNama": "UniqueNama", "AttributeId": "AttributeId", "ShowHideId": "ShowHideId", "RequirementLevelId": "RequirementLevelId", "ReadOnlyLevelId": "ReadOnlyLevelId", "DisableLevelId": "DisableLevelId", "ConditionType": "ConditionType", "ConditionValue": "ConditionValue", "ConditionValueXml": "ConditionValueXml", "ConditionSetValue": "ConditionSetValue", "ConditionSetNullValue": "ConditionSetNullValue", "ConditionText": "ConditionText", "Type": "Type" },
    propertyData: { "None": "None", "Show": "Show", "Hide": "Hide", "NoConstraint": "NoConstraint", "BussinessRecommend": "BussinessRecommend", "BussinessRequired": "BussinessRequired", "Enable": "Enable", "ReadOnly": "ReadOnly", "Disable": "Disable" },
    Save: function (xml) {
        WfBuilder.EditUpdateNode(WorkflowStepType.BatchScript, BatchScriptName.getValue(), xml);
        this.CleartProperty();
        WindowBatchScript.hide();
    },

};
var UpdateRecord = {
    Show: function (argxml, title) {
        this.CleartProperty();
        WindowUpdateRecord.show();
        var xmlobj = crmXmlObject.str2xml(argxml)
        UpdateRecordName.setValue(title);
        UpdateRecordHdnObjectId.setValue(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "ObjectId"));
        //alert(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "EntityObjectAttributeId"));
        UpdateRecordAttribute.setValue(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "EntityObjectAttributeId"));
        UpdateRecordOpenWindow.setValue(eval(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "OpenWindow")));
        UpdateRecordDisablePlugin.setValue(eval(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "DisablePlugin")));
        UpdateRecordDisableWf.setValue(eval(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "DisableWf")));


        if (mySingleAction == WorkflowAction.Update) {
            UpdateRecordAttribute.setDisabled(true);
        } else {
            UpdateRecordAttribute.setDisabled(false);
        }

        this.fillFromXml(xmlobj.lastChild);
    },
    fillFromXml: function (xnode) {
        GridUpdateRecord.clear();
        GridUpdateRecord.clearData();
        for (var i = 0; i < xnode.childNodes.length; i++) {
            if (xnode.childNodes[i].nodeName == "AddUpdateEntityList") {
                var snode = xnode.childNodes[i]
                for (var j = 0; j < snode.childNodes.length; j++) {

                    if (snode.childNodes[j].nodeName == "AddUpdateEntityList") {
                        var nType = R.clone(this.dataTypeName);
                        var ssnode = snode.childNodes[j];
                        nType.AttributeIdName = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.AttributeIdName)
                        nType.AttributeId = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.AttributeId)
                        nType.ConditionType = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionType)
                        nType.ConditionValue = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionValue)
                        nType.ConditionValueXml = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionValueXml)
                        nType.ConditionText = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionText)
                        GridUpdateRecord.insertRow(nType)
                    }

                }
            }
            //
        }
    },
    FillRowHtml: function (ConditionText) {
        return ConditionText;
    },
    AddEmptyRow: function () {
        GridUpdateRecord.insertRow();
    },
    RemoveSelectedRow: function () {
        if (GridUpdateRecord.selectedRowId >= 0) {
            GridUpdateRecord.deleteRow();
            this.CleartProperty();
        }
    },
    CleartProperty: function () {
        UpdateRecordPropertyFormElement.clear();
        UpdateRecordPropertyValueLabel.innerHTML = "";
        UpdateRecordPropertyValue.setValue("");
        UpdateRecordPropertyConditionType.setValue("");

    },
    UpdateRecordSelected: function () {
        //this.UpdateOldData();
        this.CleartProperty();
        var rec = GridUpdateRecord.selectedRecord;
        if (rec.AttributeId != "") {
            UpdateRecordPropertyFormElement.setValue(rec.AttributeId, rec.AttributeIdName);
            UpdateRecordPropertyValueLabel.innerHTML = rec.ConditionText;
            UpdateRecordPropertyValue.setValue(rec.ConditionValue);
            UpdateRecordPropertyConditionType.setValue(rec.ConditionType);

        }
    },
    UpdateChangedData: function (obj) {
        var gRowId = GridUpdateRecord.selectedRowId;

        switch (obj.id) {
            case UpdateRecordPropertyFormElement.id:
                GridUpdateRecord.updateColumn(gRowId, this.dataTypeName.AttributeIdName, UpdateRecordPropertyFormElement.getRawValue());
                GridUpdateRecord.updateColumn(gRowId, this.dataTypeName.AttributeId, UpdateRecordPropertyFormElement.getValue());
                break;
            case UpdateRecordPropertyValueLabel.id:
                GridUpdateRecord.updateColumn(gRowId, this.dataTypeName.ConditionText, UpdateRecordPropertyValueLabel.innerHTML);
                break;
            case UpdateRecordPropertyValue.id:
                GridUpdateRecord.updateColumn(gRowId, this.dataTypeName.ConditionValue, UpdateRecordPropertyValue.getValue());
                break;
            case UpdateRecordPropertyConditionType.id:
                GridUpdateRecord.updateColumn(gRowId, this.dataTypeName.ConditionType, UpdateRecordPropertyConditionType.getValue());
                break;
        }
    },
    AddDynamicValue: function () {
        UpdateRecordPropertyValueLabel.innerHTML = hdnValueSelectorTextField.getValue();
        UpdateRecordPropertyValue.setValue(hdnValueSelectorValueField.getValue());
        UpdateRecordPropertyConditionType.setValue(hdnValueSelectorValuType.getValue());
        this.UpdateChangedData(UpdateRecordPropertyValueLabel);
        this.UpdateChangedData(UpdateRecordPropertyValue);
        this.UpdateChangedData(UpdateRecordPropertyConditionType);

    },
    PrepareValueSelector: function () {
        var rec = GridUpdateRecord.selectedRecord;
        var recid = GridUpdateRecord.selectedRowId;
        if (recid >= 0 && rec.AttributeId != "") {
            hdnValueSelectorAttributeId.setValue(rec.AttributeId);
            hdnValueSelectorValuType.setValue(rec.ConditionType);
            hdnValueSelectorTextField.setValue(rec.ConditionText);
            hdnValueSelectorValueField.setValue(rec.ConditionValue);
            hdnValueSelectorAfterScript.setValue("UpdateRecord.AddDynamicValue();");
            WindowValueSelectorShow.click();
        }
    },
    SaveData: function () {

    },
    dataType: { "AttributeIdName": 0, "AttributeId": 1, "ConditionType": 2, "ConditionValue": 3, "ConditionValueXml": 4, "ConditionText": 5 },
    dataTypeName: { "AttributeIdName": "AttributeIdName", "AttributeId": "AttributeId", "ConditionType": "ConditionType", "ConditionValue": "ConditionValue", "ConditionValueXml": "ConditionValueXml", "ConditionText": "ConditionText" },
    Save: function (xml) {
        //alert(xml);
        WfBuilder.EditUpdateNode(WorkflowStepType.Update, UpdateRecordName.getValue(), xml);
        this.CleartProperty();
        WindowUpdateRecord.hide();
    },

};
var CreateRecord = {
    Show: function (argxml, title) {
        this.CleartProperty();
        WindowCreateRecord.show();
        var xmlobj = crmXmlObject.str2xml(argxml)
        CreateRecordName.setValue(title);
        CreateRecordHdnObjectId.setValue(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "ObjectId"));
        CreateRecordEntity.setValue(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "EntityObjectAttributeId"));
        CreateRecordOpenWindow.setValue(eval(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "OpenWindow")));
        CreateRecordDisablePlugin.setValue(eval(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "DisablePlugin")));
        CreateRecordDisableWf.setValue(eval(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "DisableWf")));


        if (mySingleAction == WorkflowAction.Update) {
            CreateRecordEntity.setDisabled(true);
        } else {
            CreateRecordEntity.setDisabled(false);
        }

        this.fillFromXml(xmlobj.lastChild);
    },
    fillFromXml: function (xnode) {
        GridCreateRecord.clear();
        GridCreateRecord.clearData();
        for (var i = 0; i < xnode.childNodes.length; i++) {
            if (xnode.childNodes[i].nodeName == "AddUpdateEntityList") {
                var snode = xnode.childNodes[i]
                for (var j = 0; j < snode.childNodes.length; j++) {

                    if (snode.childNodes[j].nodeName == "AddUpdateEntityList") {
                        var nType = R.clone(this.dataTypeName);
                        var ssnode = snode.childNodes[j];
                        nType.AttributeIdName = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.AttributeIdName)
                        nType.AttributeId = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.AttributeId)
                        nType.ConditionType = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionType)
                        nType.ConditionValue = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionValue)
                        nType.ConditionValueXml = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionValueXml)
                        nType.ConditionText = crmXmlObject.getSubNodeValue(ssnode, this.dataTypeName.ConditionText)
                        GridCreateRecord.insertRow(nType)
                    }

                }
            }
            //
        }
    },
    FillRowHtml: function (ConditionText) {
        return ConditionText;
    },
    AddEmptyRow: function () {
        GridCreateRecord.insertRow();
    },
    RemoveSelectedRow: function () {
        if (GridCreateRecord.selectedRowId >= 0) {
            GridCreateRecord.deleteRow();
            this.CleartProperty();
        }
    },
    CleartProperty: function () {
        CreateRecordPropertyFormElement.clear();
        CreateRecordPropertyValueLabel.innerHTML = "";
        CreateRecordPropertyValue.setValue("");
        CreateRecordPropertyConditionType.setValue("");

    },
    CreateRecordSelected: function () {
        //this.UpdateOldData();
        this.CleartProperty();
        var rec = GridCreateRecord.selectedRecord;
        if (rec.AttributeId != "") {
            CreateRecordPropertyFormElement.setValue(rec.AttributeId, rec.AttributeIdName);
            CreateRecordPropertyValueLabel.innerHTML = rec.ConditionText;
            CreateRecordPropertyValue.setValue(rec.ConditionValue);
            CreateRecordPropertyConditionType.setValue(rec.ConditionType);

        }
    },
    UpdateChangedData: function (obj) {
        var gRowId = GridCreateRecord.selectedRowId;

        switch (obj.id) {
            case CreateRecordPropertyFormElement.id:
                GridCreateRecord.updateColumn(gRowId, this.dataTypeName.AttributeIdName, CreateRecordPropertyFormElement.getRawValue());
                GridCreateRecord.updateColumn(gRowId, this.dataTypeName.AttributeId, CreateRecordPropertyFormElement.getValue());
                break;
            case CreateRecordPropertyValueLabel.id:
                GridCreateRecord.updateColumn(gRowId, this.dataTypeName.ConditionText, CreateRecordPropertyValueLabel.innerHTML);
                break;
            case CreateRecordPropertyValue.id:
                GridCreateRecord.updateColumn(gRowId, this.dataTypeName.ConditionValue, CreateRecordPropertyValue.getValue());
                break;
            case CreateRecordPropertyConditionType.id:
                GridCreateRecord.updateColumn(gRowId, this.dataTypeName.ConditionType, CreateRecordPropertyConditionType.getValue());
                break;
        }
    },
    AddDynamicValue: function () {
        CreateRecordPropertyValueLabel.innerHTML = hdnValueSelectorTextField.getValue();
        CreateRecordPropertyValue.setValue(hdnValueSelectorValueField.getValue());
        CreateRecordPropertyConditionType.setValue(hdnValueSelectorValuType.getValue());
        this.UpdateChangedData(CreateRecordPropertyValueLabel);
        this.UpdateChangedData(CreateRecordPropertyValue);
        this.UpdateChangedData(CreateRecordPropertyConditionType);

    },
    PrepareValueSelector: function () {
        var rec = GridCreateRecord.selectedRecord;
        var recid = GridCreateRecord.selectedRowId;
        if (recid >= 0 && rec.AttributeId != "") {
            hdnValueSelectorAttributeId.setValue(rec.AttributeId);
            hdnValueSelectorValuType.setValue(rec.ConditionType);
            hdnValueSelectorTextField.setValue(rec.ConditionText);
            hdnValueSelectorValueField.setValue(rec.ConditionValue);
            hdnValueSelectorAfterScript.setValue("CreateRecord.AddDynamicValue();");
            WindowValueSelectorShow.click();
        }
    },
    SaveData: function () {

    },
    dataType: { "AttributeIdName": 0, "AttributeId": 1, "ConditionType": 2, "ConditionValue": 3, "ConditionValueXml": 4, "ConditionText": 5 },
    dataTypeName: { "AttributeIdName": "AttributeIdName", "AttributeId": "AttributeId", "ConditionType": "ConditionType", "ConditionValue": "ConditionValue", "ConditionValueXml": "ConditionValueXml", "ConditionText": "ConditionText" },
    Save: function (xml) {
        //alert(xml);
        WfBuilder.EditUpdateNode(WorkflowStepType.Create, CreateRecordName.getValue(), xml);
        this.CleartProperty();
        WindowCreateRecord.hide();
    },

};
var Message = {
    Show: function (argxml, title) {
        this.CleartProperty();
        WindowMessage.show();

        var xmlobj = crmXmlObject.str2xml(argxml)
        MessageName.setValue(title);
        MessageType.setValue(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "MessageType"))
        MessageBody.setValue(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "HtmlValue"));

    },
    CleartProperty: function () {
        MessageName.clear();
        MessageType.clear();
        MessageBody.clear();
    },
    PrepareValueSelector: function () {

        hdnValueSelectorAttributeId.setValue("");
        hdnValueSelectorValuType.setValue(ValueSelector.conditionType.Dynamic);
        hdnValueSelectorTextField.setValue("");
        hdnValueSelectorValueField.setValue("");
        hdnValueSelectorAfterScript.setValue("Message.AddDynamicValue();");
        WindowValueSelectorShow.click();

    },
    AddDynamicValue: function () {
        MessageBody.appendValue(hdnValueSelectorValueField.getValue())

    },
    Save: function (xml) {
        //alert(xml);
        WfBuilder.EditUpdateNode(WorkflowStepType.ShowMessage, MessageName.getValue(), xml);
        this.CleartProperty();
        WindowMessage.hide();
    },

};
var DynamicUrl = {
    Show: function (argxml, title) {
        this.CleartProperty();
        WindowDynamicUrl.show();

        var xmlobj = crmXmlObject.str2xml(argxml)
        DynamicUrlId.setValue(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "DynamicUrlId"));

    },
    CleartProperty: function () {
        DynamicUrlId.clear();
    },
    Save: function (xml) {
        WfBuilder.EditUpdateNode(WorkflowStepType.DynamicUrl, DynamicUrlId.getRawValue(), xml);
        this.CleartProperty();
        WindowDynamicUrl.hide();
    },
};
var RedirectForm = {
    Show: function (argxml, title) {
        this.CleartProperty();
        WindowRedirectForm.show();

        var xmlobj = crmXmlObject.str2xml(argxml)
        RedirectFormId.setValue(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "RedirectFormId"));

    },
    CleartProperty: function () {
        RedirectFormId.clear();
    },
    Save: function (xml) {
        WfBuilder.EditUpdateNode(WorkflowStepType.RedirectForm, RedirectFormId.getRawValue(), xml);
        this.CleartProperty();
        WindowRedirectForm.hide();
    },
};
var PluginMessage = {
    Show: function (argxml, title) {
        this.CleartProperty();
        WindowPluginMessage.show();

        var xmlobj = crmXmlObject.str2xml(argxml)
        PluginMessageId.setValue(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "PluginMessageId"));

    },
    CleartProperty: function () {
        PluginMessageId.clear();
    },
    Save: function (xml) {
        WfBuilder.EditUpdateNode(WorkflowStepType.Plugin, PluginMessageId.getRawValue(), xml);
        this.CleartProperty();
        WindowPluginMessage.hide();
    },
};
var ValueSelector = {
    strText: "<SPAN class=\"DataSlugStyle\" contentEditable=\"false\" style=\"DISPLAY: inline;tab-index: -1;background-color: #FFFF33;height: 17px;padding-top: 1px;padding-right: 2px;padding-left: 2px;overflow-y: hidden; version:01012013; \" tabIndex=\"-1\" value=\"<slugelement type=slug><slug type=dynamic value=\'{0}\'/></slugelement>\">{1}</SPAN>",
    AddConditionToClipboard: function () {
        var text = ValueSelectorTreeGrid.selectedNode[DynamicValues.dataType.ParentName].Value;
        var value = ValueSelectorTreeGrid.selectedNode[DynamicValues.dataType.AttributePath].Value
        slugValue = "{!" + value + "!}";
        //this.CopyToClipboard( String.format(this.strText, slugValue, text));
        //alert("Data Copied to clipboard")
    },
    AddConditionDyanicValue: function () {
        var text = ValueSelectorTreeGrid.selectedNode[DynamicValues.dataType.ParentName].Value;
        var value = ValueSelectorTreeGrid.selectedNode[DynamicValues.dataType.AttributePath].Value
        slugValue = "{!" + value + "!}";
        alert(String.format(this.strText, slugValue, text));
        ValueSelectorDynamicTextField.appendValue(String.format(this.strText, slugValue, text))
    },
    CopyToClipboard: function (s) {
        if (window.clipboardData && clipboardData.setData) {
            clipboardData.setData("Text", s);
        }
        else {
            // You have to sign the code to enable this or allow the action in about:config by changing
            user_pref("signed.applets.codebase_principal_support", true);
            netscape.security.PrivilegeManager.enablePrivilege('UniversalXPConnect');
            var clip = Components.classes['@mozilla.org/widget/clipboard;[[[[1]]]]'].createInstance(Components.interfaces.nsIClipboard);
            if (!clip) return;
            // create a transferable
            var trans = Components.classes['@mozilla.org/widget/transferable;[[[[1]]]]'].createInstance(Components.interfaces.nsITransferable);
            if (!trans) return;
            // specify the data we wish to handle. Plaintext in this case.
            trans.addDataFlavor('text/unicode');

            // To get the data from the transferable we need two new objects
            var str = new Object();
            var len = new Object();

            var str = Components.classes["@mozilla.org/supports-string;[[[[1]]]]"].createInstance(Components.interfaces.nsISupportsString);

            var copytext = meintext;

            str.data = copytext;

            trans.setTransferData("text/unicode", str, copytext.length * [[[[2]]]]);

            var clipid = Components.interfaces.nsIClipboard;

            if (!clip) return false;

            clip.setData(trans, null, clipid.kGlobalClipboard);
        }
    },
    conditionType: { "Dynamic": "Dynamic", "Default": "Default", "None": "None" },
};

var StopWf = {
    Add: function () {
        WfBuilder.EditUpdateNode(WorkflowStepType.StopWorkFlow, "Stop Wf", "");
    }
}
var SubWorkflow = {
    Show: function (argxml, title) {
        this.CleartProperty();
        WindowWorkFlow.show();

        var xmlobj = crmXmlObject.str2xml(argxml)
        WorkflowId.setValue(crmXmlObject.getSubNodeValue(xmlobj.lastChild, "WorkflowId"));

    },
    CleartProperty: function () {
        WorkflowId.clear();
    },
    Save: function (xml) {
        WfBuilder.EditUpdateNode(WorkflowStepType.Workflow, WorkflowId.getRawValue(), xml);
        this.CleartProperty();
        WindowWorkFlow.hide();
    },
};
function ValidateBeforeForm(msg, e) {
    if (EntityCrmLookupComp.getValue() == null || EntityCrmLookupComp.getValue() == "") {
        alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), EntityCrmLookupComp.getFieldLabel()));
        EntityCrmLookupComp.focus();
        e.returnValue = false;
        return false;
    }
    if (RunInUser.getValue() == null || RunInUser.getValue() == "") {
        alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), RunInUser.getFieldLabel()));
        RunInUser.focus();
        e.returnValue = false;
        return false;
    }
}