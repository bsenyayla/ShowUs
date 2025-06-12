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


function CheckAllControls() {

    SetIdentificationValidDate();
}


function SetIdentificationValidDate() {


    new_ValidDateOfSenderIdentificationCard.hide();
    var retax = AjaxMethods.IsIdentificationValidDate(new_SenderIdentificationCardTypeID.getValue()).value;

    if (retax) {
        new_ValidDateOfSenderIdentificationCard.show();
    } else {
        new_ValidDateOfSenderIdentificationCard.hide();
    }
}

function ValidateBeforeSave(msg, e) {
    var recipientGsmCountryCode = document.getElementById("_new_RecipientGSM").value;
    var recipientGsmArea = document.getElementById("__new_RecipientGSM").value;

    var ret = CrmValidateForm(msg, e)
    if (!ret)
        return;

    var retGsm = validateGsmCountryCode(recipientGsmCountryCode, recipientGsmArea);

    if (!retGsm) {
        alert(MULTIPLE_PHONE_CODE_INVALID);
        window.returnValue = false;
        e.returnValue = false;
        return;
    }


    if (new_RecipientName.getValue() != '') {
        ret = IsValidRecepientGsm(e);
        if (!ret)
            return;
    }

    if (new_ValidDateOfSenderIdentificationCard.visible) {
        var date1 = new_ValidDateOfSenderIdentificationCard.getDateValue();
        if (date1 < (new Date())) {
            alert(NEW_SENDER_VALIDDATEOFIDENDITY_NOT_VALID);
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }

    if (document.getElementById('_new_RecipientName') != null) {
        var recipientName = document.getElementById('_new_RecipientName').value;
        if (!IsValidCharacter(recipientName, 'Alıcı Adı')) {
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }



    if (document.getElementById('_new_RecipientMiddleName') != null) {
        var recipientMiddleName = document.getElementById('_new_RecipientMiddleName').value;
        if (!IsValidCharacter(recipientMiddleName, 'Alıcı Orta Ad')) {
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }


    if (document.getElementById('_new_RecipientLastName') != null) {
        var recipientLastName = document.getElementById('_new_RecipientLastName').value;
        if (!IsValidCharacter(recipientLastName, 'ALıcı Soyadı')) {
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }

}

function validateGsmCountryCode(recipientGsmCountryCode, recipientGsmArea) {
    var result = false;
    var founded = false;

    for (var i = 0; i < multiplePhoneCodeCountries["countries"].length; i++) {
        var countryCode = multiplePhoneCodeCountries["countries"][i];
        var phoneNumber = recipientGsmCountryCode + recipientGsmArea;

        var newPhoneCountryCode = recipientGsmCountryCode.indexOf('0') == 0 ? recipientGsmCountryCode.substring(1) : recipientGsmCountryCode;
        var newPhoneGsmArea = recipientGsmArea.indexOf('0') == 0 ? recipientGsmArea.substring(1) : recipientGsmArea;

        var phoneNumber = newPhoneCountryCode + newPhoneGsmArea;

        //    var phoneNumber = string.Format("{0}{1}", countryCode.Replace("0", string.Empty), gsmPrefix.Replace("0", string.Empty));
        if (countryCode["country"] == selectedCountryPhoneCode) {
            founded = true;
            if (selectedCountryPhoneCode == newPhoneCountryCode) {
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




function IsValidRecepientGsm(e) {
    var gsmArea = document.getElementById('__new_RecipientGSM').value;
    var gsm = document.getElementById('___new_RecipientGSM').value;
    if (gsmArea == '' || gsmArea.length <= 1 || gsm == '' || gsm <= 3) {
        alert(InvalidGsm);
        document.getElementById('__new_RecipientGSM').focus();
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }
    return true;
}


if (new_CollectionMethod.getValue() == 1) {
    new_ReceivedAmount2field.hide();
    new_TransferPaymentCurrencyParity2.hide();
}
if (new_RecipientCityId.getValue() == '') {
    new_RecipientCityId.hide();
}
if (new_RecipientRegionId.getValue() == '') {
    new_RecipientRegionId.hide();
}
if (new_BrandId.getValue() == '') {
    new_BrandId.hide();
}
if (new_RecipientOfficeId.getValue() == '') {
    new_RecipientOfficeId.hide();
}


function CreditMovement() {
    var credit = AjaxMethods.GetCreditInfo(getParameterByName("creditDataID")).value;
    new_TransactionTargetOptionID.setValue(AKTIFBANK_ODEME_ID, "Aktifbank Ödemesi");
    new_AmountCurrency2.setValue(TL_CURRENCY_ID, "TL")
    //new_Amount.setValue(credit.TUTAR);
    //new_Amount.change();
    //DisableFields();
}

function SetReceipentCountryID() {
    new_RecipientCountryID.setValue(TURKEY_COUNTRY_ID, "Türkiye");
}

function CloseSenderCreateScreen() {
    var w = window.top.R.WindowMng.getWindowById(window.parent.parent.frames[1].window.name.replace("Frame_", ""));
    w.hide();
}

function SetTransactionTargetOptionID() {
    new_TransactionTargetOptionID.setValue(AKTIFBANK_ODEME_ID, null, null, true)
}

function SetTargetTransactionTypeID() {
    new_TargetTransactionTypeID.setValue(AKTIFBANK_ODEMESI, "Aktifbank Ödemesi");
}

function SetAmountCurrency2() {
    new_AmountCurrency2.setValue(TL_CURRENCY_ID, "TL", null, true)
}

function ChangeAmount() {
    new_Amount.change();
}

function FillReceipent(firstName, lastName, middleName, moteherName, fatherName, IBAN, gsm) {
    new_RecipientIBAN.setValue(IBAN);
    new_RecipientGSMCountryId.setValue(TURKEY_COUNTRY_ID);
    if (gsm == '') {
        new_RecipientGSM.setValue('0090');
    }
    else {
        new_RecipientGSM.setValue(gsm);
    }
    //new_RecipientGSMCountryId.change();
    new_EftPaymentMethodID.setValue(CREDIT_EFT_PAYMENT_METHOD_ID);
    new_RecipientName.setValue(firstName);
    new_RecipientName.oldValue = "";
    new_RecipientLastName.setValue(lastName);
    new_RecipientMiddleName.setValue(middleName);
    new_RecipientFatherName.setValue(fatherName);
    new_RecipientMotherName.setValue(moteherName);
    var newEvent = document.createEvent("UIEvents");
    newEvent.initEvent("blue", true, false);
    new_RecipientName.blur(newEvent);
}

function DisableFields() {
    btnPaymentPoints.hide();
    new_RecipientCountryID.setDisabled(true);
    new_RecipientGSMCountryId.setDisabled(true);
    new_AmountCurrency2.setDisabled(true);
    new_ReceivedAmount1.setDisabled(true);
    new_Amount.setDisabled(true);
    new_CalculatedExpenseAmount.setDisabled(true);
    new_TransactionTargetOptionID.setDisabled(true);
    new_RecipientIBAN.setDisabled(true);
    new_RecipientID.setDisabled(true);
    new_RecipientName.setDisabled(true);
    new_RecipientMiddleName.setDisabled(true);
    new_RecipientLastName.setDisabled(true);
    new_RecipientMotherName.setDisabled(true);
    new_RecipientFatherName.setDisabled(true);
    new_RecipienNickName.setDisabled(true);
    new_SourceTransactionTypeID.setDisabled(true);
    new_RecipientCorporationId.setDisabled(true);
    new_EftPaymentMethodID.setDisabled(true);
    new_IbanisNotKnown.setDisabled(true);
    new_RecipientID.hide();
}

function DisableSenderInfo() {
    Panel_SenderInformation.hide();
}

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}


function IsValidCharacter(deger, field) {


    if (deger == '')
        return true;


    // Define valid chars
    var validChars = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'Ç', 'Ğ', 'Ü', 'İ', 'Ö', '.', '/', '-', ',', ' '];

    // emailName must only include valid chars
    for (var i = 0; i < deger.length; i += 1) {

        if (validChars.indexOf(deger.charAt(i)) < 0) {
            alert('Invalid Character. Field : ' + field + ' Character : ' + deger);
            window.returnValue = false;

            return false;
        }
    }

    return true;
}