//function CalculateForm(money, currency) {
//    var recId = New_PaymentId.getValue();
//    var ret = AjaxMethods.CalculateData(recId, money.id, money.getValue(), currency.getValue()).value;
//    if (ret.Message != "")
//        alert(ret.Message);

//    new_PaidAmount1.setValue(ret.PaidAmount1);
//    new_PaidAmount1Currency.setValue(ret.PaidAmount1Currency);
//    new_TransferPaidParity1.setValue(ret.TransferPaidParity1);
//    new_ExpenseAmount.setValue(ret.ExpenseAmount);
//    new_ExpenseAmountCurrency.setValue(ret.ExpenseAmountCurrency);
//}

window.onload = function () {
    document.getElementById("_new_MobilePhone").disabled = true;

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



function SetKpsData() {

    R.mask("SetKpsData1", "Kps..?");
    setTimeout(new Function("SetKpsData1();"), 100);
}

function SetKpsData1() {


    if (new_NationalityID.getValue() == "") {
        R.unmask("SetKpsData1");
        alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_NationalityID.getFieldLabel()));
        return;
    }
    //    try {
    var ret = AjaxMethods.GetKpsData(new_RecipientIdentificationCardNumber.getValue(), new_NationalityID.getValue()).value;
    R.unmask("SetKpsData1");
    if (ret.new_cameFromKps) {
        new_RecipientName.setValue(ret.new_Name);
        new_RecipientMiddleName.setValue(ret.new_MiddleName);
        new_RecipientLastName.setValue(ret.new_LastName);
        new_FatherName.setValue(ret.new_FatherName);
        new_BirthPlace.setValue(ret.new_BirthPlace);
        new_MotherName.setValue(ret.new_MotherName);
        new_Birthdate.setValue(ret.new_BirthDate);

        try {
            if (ret.new_GenderID != "")
                new_GenderID.setValue(ret.new_GenderID);
        } catch (e) {

        }

        new_CameFromKps.setValue(ret.new_cameFromKps);

    }
    else {

        alert(NEW_RECIPIENT_KPS_HATALI);
        new_CameFromKps.setValue(ret.new_cameFromKps);
        new_CameFromKps.setRequirementLevel(0);
        return;
    }
    SetKpsReadOnly();
    SetApsData();
}
function SetApsData() {

    var retax = AjaxMethods.GetApsData(new_RecipientIdentificationCardNumber.getValue(), new_NationalityID.getValue()).value;
    if (retax.new_cameFromAps) {
        new_Address.setValue(retax.adres);
        new_cameFromAps.setValue(retax.new_cameFromAps);
    }
    SetApsReadOnly();
}

function SetApsReadOnly() {
    if (new_cameFromAps.getValue()) {
        tryReadonly(new_Address);
    }
}

function SetIdentificationValidDate() {

    new_ValidDateOfIdendity.hide();
    var retax = AjaxMethods.IsIdentificationValidDate(new_IdentificatonCardTypeId.getValue()).value;
    var nation = AjaxMethods.IsNationalityKZ(new_NationalityID.getValue()).value;

    if (retax || nation) {
        new_ValidDateOfIdendity.show();
    }
    else {
        new_ValidDateOfIdendity.hide();
    }

    
}

function SetNationality() {
    return;
    a = new_NationalityID.getValue();

    var ret = false;
    try {
        ret = AjaxMethods.GetRequaredNationality(a).value;
    } catch (e) {
        btnKpsAps.setDisabled(true);
    }
    btnKpsAps.setDisabled(!ret);
    if (ret) {
        new_CameFromKps.setRequirementLevel(2);
        new_cameFromAps.setRequirementLevel(2);
    } else {
        new_CameFromKps.setRequirementLevel(0);
        new_cameFromAps.setRequirementLevel(0);

    }
}
/*Her Load isleminde Kontrol et.*/
function CheckAllControls() {
    SetNationality();
    SetKpsReadOnly(); 
    SetIdentificationValidDate();
}
//setTimeout(function () { SetNationality(); SetKpsReadOnly(); SetIdentificationValidDate(); }, 500);



function ValidateBeforeSave(msg, e) {
    var recipientGsmCountryCode = document.getElementById("_new_MobilePhone").value;
    var recipientGsmArea = document.getElementById("__new_MobilePhone").value;

    var ret = CrmValidateForm(msg, e)
    if (!ret)
        return;

    if (new_IdentityWasSeen.getValue() == false) {

        alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_IdentityWasSeen.getFieldLabel()));
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }

    if (new_ValidDateOfIdendity.visible) {
        var date1 = new_ValidDateOfIdendity.getDateValue();
        if (date1 < (new Date())) {
            alert(NEW_RECIPIENT_VALIDDATEOFIDENDITY_NOT_VALID);
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }

    if (new_CameFromKps.requirementLevel == 2 && !new_CameFromKps.getValue()) {
        alert(NEW_RECIPIENT_KPS_ZORUNLU);
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }

    var Birthdate = new_Birthdate.getValue();
    ret = AjaxMethods.GetRecipientBirthdate(Birthdate).value;
    if (ret != "") {
        alert(ret);
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }

    var retGsm = validateGsmCountryCode(recipientGsmCountryCode, recipientGsmArea);

    if (!retGsm) {
        alert(MULTIPLE_PHONE_CODE_INVALID);
        window.returnValue = false;
        e.returnValue = false;
        return;
    }



}

function validateGsmCountryCode(recipientGsmCountryCode, recipientGsmArea) {
    var result = false;
    var founded = false;

    for (var i = 0; i < multiplePhoneCodeCountries["countries"].length; i++) {
        var countryCode = multiplePhoneCodeCountries["countries"][i];
        var phoneNumber = recipientGsmCountryCode + recipientGsmArea;
        if (countryCode["country"] == selectedCountryPhoneCode) {
            founded = true;
            if (selectedCountryPhoneCode == recipientGsmCountryCode) {
                result = true;
                break;
            }
            else {

                for (var j = 0; j < countryCode["codes"].length; j++) {
                    var code = countryCode["codes"][j];

                    if (code["code"] == phoneNumber) {
                        result = true;
                        break;
                    }

                }
            }
        }
    }
    if (founded == false) {
        result = true;
    }

    return result;
}

function SetKpsReadOnly() {

    if (new_CameFromKps.getValue()) {
        tryReadonly(new_RecipientName);
        tryReadonly(new_RecipientMiddleName);
        tryReadonly(new_RecipientLastName);
        tryReadonly(new_FatherName);
        tryReadonly(new_BirthPlace);
        tryReadonly(new_MotherName);
        tryReadonly(new_Birthdate);
        //tryReadonly(new_GenderID);

    }
}

function tryReadonly(obj) {

    try {
        obj.setReadOnly(true);
    } catch (e) {

    }
}