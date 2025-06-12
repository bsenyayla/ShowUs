
function ItemTextFieldOnChange(e) {
    var element = e.currentTarget.id.substring(1, e.currentTarget.id.indexOf("_ItemTextField"));
    var objectTextField = eval(element + "_ItemTextField");
    var objectValueField = eval(element + "_ItemValueField");
    var str = objectTextField.getValue();
    if (str.indexOf("*") == -1 && str != "")
        objectValueField.setValue(objectTextField.getValue());
}

function ItemValueFieldOnChange(objectId)
{
    var element = objectId.substring(0, objectId.indexOf("_ItemValueField"));
    var objectTextField = eval(element + "_ItemTextField");
    var objectValueField = eval(element + "_ItemValueField");
    objectTextField.setValue(MaskName(objectValueField.getValue()));
}

function MaskName(text) {
    var maskedName = "";
    if (text != "") {
        var count = text.length;
        var i = 0;
        while (i < count) {
            if (i % 2 == 0 || text.charAt(i) == " ") {
                maskedName += text.charAt(i);
            }
            else {
                maskedName += "*";
            }
            i++;
        }
        return maskedName;
    }
    else {
        return "";
    }
}
