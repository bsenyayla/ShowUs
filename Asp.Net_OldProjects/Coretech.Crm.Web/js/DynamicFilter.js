

function ChangeFilter(cmb, filterObject) {
    var val = cmb.getValue();
    var Action = val.split("|");
    var id = filterObject.id;
    FilterhideAll(id);
    if (Action.length > 1) {
        if (Action[1].length > 0) {
            var obj = null;
            if (Action[2] == "True") {
                obj = FilterCreateObject(id + "_B_" + Action[1])

            }
            else
                obj = FilterCreateObject(id + Action[1])

            obj.show();
        }
    }
}
function FilterGetValue(id) {
    var object = FilterCreateObject(id);

    if (object && object.xType == "ComboField" && object.multiSelect && object.selectedRecords.length > 0) {
        var val = "";
        for (var i = 0; i < object.selectedRecords.length; i++) {
            val += object.selectedRecords[i].ID + ";";
        }
        return val;
    } else if (object)
        return object.getValue();
}
function FilterGetText(id) {
    var object = FilterCreateObject(id);

    if (object && object.xType == "ComboField" && object.multiSelect && object.selectedRecords.length > 0) {
        var val = "";
        for (var i = 0; i < object.selectedRecords.length; i++) {
            val += object.selectedRecords[i].VALUE + ";";
        }
        return val;
    } else if (object.xType == "ComboField")
        return object.getRawValue();
    else if (object) {
        return object.getValue();
    }
}

function FilterhideAll(id) {
    var _TextField = FilterCreateObject(id + "TextField");
    FilterSetClearAndHide(_TextField, false);

    var _PicklistField = FilterCreateObject(id + "PicklistField");
    FilterSetClearAndHide(_PicklistField, false);

    var _NumericField = FilterCreateObject(id + "NumericField");
    FilterSetClearAndHide(_NumericField, false);

    var _LookupField = FilterCreateObject(id + "LookupField");
    FilterSetClearAndHide(_LookupField, false);

    var _DecimalField = FilterCreateObject(id + "DecimalField");
    FilterSetClearAndHide(_DecimalField, false);

    var _DateField = FilterCreateObject(id + "DateField");
    FilterSetClearAndHide(_DateField, false);

    var _MDateField = FilterCreateObject(id + "_B_DateField");
    FilterSetClearAndHide(_MDateField, true);

    var _MDecimalField = FilterCreateObject(id + "_B_DecimalField");
    FilterSetClearAndHide(_MDecimalField, true);

    var _MNumericField = FilterCreateObject(id + "_B_NumericField");
    FilterSetClearAndHide(_MNumericField, true);

}
function FilterSetClearAndHide(object, IsMultiField) {
    if (object) {
        if (!IsMultiField) {
            object.clear();
            object.hide();
        } else {
            var obj1 = FilterCreateObject(object.id.replace("_B_", "_1_"));
            var obj2 = FilterCreateObject(object.id.replace("_B_", "_2_"));
            obj1.clear();
            obj2.clear();
            object.hide();
        }
    }
}
function FilterCreateObject(id) {
    try {
        return eval(id);
    } catch (e) {
        return false;
    }
}
var FilterQueryObjects = new Array();
var FilterQueryObjectAlias = new Array();

function FilterGetQuery() {
    var ObjectId = hdnObjectId.getValue();
    var strXml = ""
    strXml += "<Entity" + ObjectId + " id='" + ObjectId + "' objectid='" + ObjectId + "' text='' attributeid='' leftjoin='false'  type='0'>";

    strXml += "</Entity" + ObjectId + ">";

    var xObject = XmlCreater.str2xml(strXml);
    var _titleText = "";
    for (var i = 0; i < FilterQueryObjects.length; i++) {
        var Object = FilterQueryObjects[i]
        var fcObject = FilterCreateObject(Object.id + "_Condition");
        var filterVal = fcObject.getValue();

        if (filterVal == "")
            continue;

        var ClauseValue = "";
        var ClauseValue2 = "";
        var ClauseText = "";
        var filterAction = filterVal.split("|");
        if (filterAction[1] != "") {
            if (filterAction[2] == "True") {

                ClauseValue = FilterGetValue((Object.id + "_1_" + filterAction[1]))
                ClauseValue2 = FilterGetValue((Object.id + "_2_" + filterAction[1]))

                if (ClauseValue == "" || ClauseValue2 == "") {
                    ClauseValue = ""; ClauseValue2 = "";
                    FilterSetClearAndHide(FilterCreateObject(Object.id + "_B_" + filterAction[1]), true)
                }
            }
            else
                ClauseValue = FilterGetValue(Object.id + filterAction[1]);
            ClauseText = FilterGetText(Object.id + filterAction[1]);
        }
        if (ClauseValue == "" && filterAction[1] != "")
            continue;

        var AttributeId = Object.AttributeId
        var id = "";
        var text = "";
        var Type = "Attribute";
        var EntityObjectId = ObjectId;
        var ConditionValue = filterAction[0];

        var LeftJoin = false
        var ConditionType = "1";

        var attr = xObject.createElement("Attribute");
        attr.setAttribute("attributeid", AttributeId);
        attr.setAttribute("id", id);
        attr.setAttribute("objectId", ObjectId);
        attr.setAttribute("text", text);
        attr.setAttribute("type", Type);
        attr.setAttribute("entityobjectid", EntityObjectId);
        attr.setAttribute("conditionvalue", ConditionValue);
        attr.setAttribute("clausevalue", ClauseValue);
        attr.setAttribute("clausetext", ClauseText);
        attr.setAttribute("conditiontype", ConditionType);
        attr.setAttribute("clausevalue2", ClauseValue2);
        attr.setAttribute("objectAlias", FilterQueryObjectAlias[i]);
        xObject.childNodes[0].appendChild(attr);
        var _and = "";

        if (_titleText != "")
            _and = " <span class='clsFilterAnd'> & </span>";

        _titleText += _and + "( ";
        _titleText += "<span class='clsFilterObject'>" + Object.getFieldLabel() + "</span>" + " "
            + "<span class='clsFilterCondition'>" + fcObject.selectedRecord.Text + " </span>";
        var _vlaue = "";
        if (ClauseValue != "" && ClauseValue2 == "")
            _vlaue += "" + ClauseText;
        if (ClauseValue2 != "")
            _vlaue += (ClauseValue + "-" + ClauseValue2) + ""
        if (_vlaue != "") {
            _vlaue = _vlaue.replace(/[<>]/g, "");
            _titleText += "<span class='clsFilterValue'>\"" + _vlaue + "\" </span>";
        }

        _titleText += ") ";
    }

    try {
        var sqlDiv = null;
        if (!$("sqlDiv")) {
            sqlDiv = document.createElement("span");
            sqlDiv.id = "sqlDiv";
            sqlDiv.style.position = "absolute";
            sqlDiv.style.width = "90%";
            sqlDiv.style.left = "5px";
            sqlDiv.style.textAlign = "left";

            $("_BtnClear_Container").parentNode.insertBefore(sqlDiv, $("_BtnClear_Container"));
        }
        else {
            sqlDiv = $("sqlDiv");
        }
        sqlDiv.innerHTML = _titleText;

    } catch (e) {

    }

    return XmlCreater.xml2string(xObject);
    return strXml;
}
function ClearFilter() {
    for (var i = 0; i < FilterQueryObjects.length; i++) {
        var Object = FilterQueryObjects[i]
        var fcObject = FilterCreateObject(Object.id + "_Condition");
        FilterhideAll(Object.id);
        fcObject.clear();
    }
}