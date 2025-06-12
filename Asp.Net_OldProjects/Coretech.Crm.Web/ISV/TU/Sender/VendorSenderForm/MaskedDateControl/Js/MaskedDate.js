function ItemDateTextFieldOnChange(e) {
    var element = e.currentTarget.id.substring(1, e.currentTarget.id.indexOf("_ItemTextField"));
    var objectTextField = eval(element + "_ItemTextField");
    var objectValueField = eval(element + "_ItemValueField");
    objectValueField.setValue(objectTextField.getValue(),true);
}

function ItemDateValueFieldOnChange(e) {
    var element = e.change.arguments[0].id.substring(0, e.change.arguments[0].id.indexOf("_ItemValueField"));
    var objectTextField = eval(element + "_ItemTextField");
    var objectValueField = eval(element + "_ItemValueField");
    objectTextField.setValue(MaskDate(objectValueField.getValue()));
}

function MaskDate(text) {
    var maskedName = "";
    if (text != "") {
        var count = text.length;
        var i = 0;
        while (i < count) {
            if (i % 2 == 0 || text.charAt(i) == ".") {
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