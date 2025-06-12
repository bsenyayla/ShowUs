window.onload = function () {
    document.getElementById("_new_RecipientGSM").disabled = true;

    document.getElementById("_new_RecipientName").onkeypress = changeToUpperCaseNew;
    document.getElementById("_new_RecipientMiddleName").onkeypress = changeToUpperCaseNew;
    document.getElementById("_new_RecipientLastName").onkeypress = changeToUpperCaseNew;
}

function changeToUpperCaseNew(event) {
    var obj = this;
    var letters = { "i": "I", "İ": "I", "I": "I", "Ş": "S", "Ğ": "G", "Ü": "U", "Ö": "O", "Ç": "C" };
    var a = "";
    var b = "";
    var position = -1;
    var positionEnd = -1;

    /*
	    textboxta seçili karakter varsa, seçili olanlar silinerek, yeni karakter yazılır.
        
        çalışma öncesi  çalışmıyordu.seçili olan varsa bu değeri silip,yeni değeri sona atıyordu.
	*/
    var selectedText = window.getSelection().toString();
    if (selectedText != "") {
        a = obj.value;
        b = "";
        position = obj.selectionStart;
        positionEnd = position + selectedText.length;

        obj.value = [a.slice(0, position), b, a.slice(positionEnd)].join('');
        obj.setSelectionRange(position, position);
    }


    var charValue = (document.all) ? event.keyCode : event.which;

    if ((charValue >= 48 && charValue <= 57) || charValue == "42" || (charValue >= 48 && charValue <= 57)) {
        return false;
    }


    var regex = /^[A-Za-zşŞçÇğĞüÜiİıIöÖ.,\-\/ ]*$/;
    var isValid = regex.test(String.fromCharCode(charValue).toUpperCase());

    if (isValid == false)
        return false;

    a = obj.value;
    b = String.fromCharCode(charValue).toUpperCase();
    position = obj.selectionStart;

    if (charValue != "8" && charValue != "0" && charValue != "27") {
        
        if (obj.value.length == 0) {
            obj.value += String.fromCharCode(charValue).toUpperCase();
        } else {
            obj.value = [a.slice(0, position), b, a.slice(position)].join('');

        }

        obj.value = obj.value.replace(/(([işİIŞĞÜÇÖ]))/g, function (letter) { return letters[letter]; })

        obj.setSelectionRange(position + 1, position + 1);

        return false;
    } else {
        return true;
    }



}