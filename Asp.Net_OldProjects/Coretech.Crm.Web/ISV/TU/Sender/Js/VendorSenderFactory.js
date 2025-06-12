

function UpdateIsDomesticValue() {
    new_IsDomestic.setValue(AjaxMethods.UpdateIsDomesticValue().value);
}

function UpdateChannelAndCorp() {
    var sender = hdnRecid.getValue();
    var channelCorp = AjaxMethods.GetChannelCorpValues(sender).value;
    new_ChannelCreated.setValue(channelCorp.channelCreated);
    new_CorporationCreated.setValue(channelCorp.corpCreated);
    new_ChannelModified.setValue(channelCorp.channelModified);
    new_CorporationModified.setValue(channelCorp.corpModified);
}

function GsmCountryOnChange() {
    document.getElementById('_new_GSM').value = new_GSMCountryId.selectedRecord.new_TelephoneCode;
}

function SetKpsData() {
    var win = window.parent;
    R.mask("SetKpsData1", "Kps..?");
    setTimeout(new Function("SetKpsData1();"), 100);
}

function SetKpsData1() {
    var win = window.parent;
    if (new_NationalityID.getValue() == "") {
        alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_NationalityID.getFieldLabel()));
        R.unmask("SetKpsData1");
        return;
    } if (new_SenderIdendificationNumber1.getValue() == "") {
        alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_SenderIdendificationNumber1.getFieldLabel()));
        R.unmask("SetKpsData1");
        return;
    }
    //    try {
    var ret = AjaxMethods.GetKpsData(new_SenderIdendificationNumber1.getValue(), new_NationalityID.getValue()).value;
    R.unmask("SetKpsData1");
    if (ret.new_cameFromKps) {
        setValueWithEvent(new_Name_ItemValueField, ret.new_Name);
        setValueWithEvent(new_MiddleName_ItemValueField,ret.new_MiddleName);
        setValueWithEvent(new_LastName_ItemValueField,ret.new_LastName);
        setValueWithEvent(new_FatherName_ItemValueField,ret.new_FatherName);
        setValueWithEvent(new_MotherName_ItemValueField,ret.new_MotherName);
        setValueWithEvent(new_BirthPlace_ItemValueField,ret.new_BirthPlace);
        try {
            new_CountryOfIdendity.setValue(ret.new_CountryOfIdendity);
        } catch (e) {

        }
        try {
            setValueWithEvent(new_PlaceOfIdendity_ItemValueField,ret.new_PlaceOfIdendity);
        } catch (e) {

        }


        try {
            new_DateOfIdendity.setValue(ret.new_DateOfIdendity);
        } catch (e) {

        }

        // try {

        new_BirthDate_ItemValueField.setValue(ret.new_BirthDate);
        //} catch (e) {

        // }
        try {
            if (ret.new_GenderID != "")
                new_GenderID.setValue(ret.new_GenderID);
        } catch (e) {

        }

        new_CameFromKps.setValue(ret.new_cameFromKps);
        //    } catch (ex) {
        //        alert(ex);
        //    }
    } else {
        alert(NEW_SENDER_KPS_HATALI);
        new_CameFromKps.setValue(ret.new_cameFromKps);
        new_CameFromKps.setRequirementLevel(0);
    }
    SetKpsReadOnly();
    SetApsData();
}

function SetApsData() {
    var win = window.parent;
    var retax = AjaxMethods.GetApsData(new_SenderIdendificationNumber1.getValue(), new_NationalityID.getValue()).value;
    if (retax.new_cameFromAps) {
        new_HomeCity.setValue(retax.new_HomeCity);
        new_HomeCityId.setValue(retax.new_HomeCityId);
        new_HomeCountry.setValue(retax.new_HomeCountry);
        //new_HomeDistrict.setValue(retax.new_HomeDistrict);
        //new_HomeDistrictText.setValue(retax.new_HomeDistrictText);
        new_HomeAdress.setValue(retax.adres);
        new_cameFromAps.setValue(retax.new_cameFromAps);
    }
    SetApsReadOnly();
}

function SetKpsReadOnly() {
    if (new_CameFromKps.getValue()) {
        tryReadonly(new_Name_ItemTextField);
        tryReadonly(new_MiddleName_ItemTextField);
        tryReadonly(new_LastName_ItemTextField);
        tryReadonly(new_FatherName_ItemTextField);
        tryReadonly(new_MotherName_ItemTextField);
        tryReadonly(new_BirthPlace_ItemTextField);
        tryReadonly(new_CountryOfIdendity);
        tryReadonly(new_PlaceOfIdendity_ItemTextField);
        tryReadonly(new_DateOfIdendity);
        tryReadonly(new_BirthDate_ItemTextField);
        tryReadonly(new_GenderID);
        tryReadonly(new_NationalityID);
        tryReadonly(new_SenderIdendificationNumber1);
    }
}

function SetApsReadOnly() {
    if (new_cameFromAps.getValue()) {
        tryReadonly(new_HomeCity);
        tryReadonly(new_HomeCityId);
        tryReadonly(new_HomeCountry);
        tryReadonly(new_HomeAdress);
        tryReadonly(new_cameFromAps);

    }
}

function tryReadonly(obj) {
    try {
        obj.setDisabled(true);
        obj.setReadOnly(true);
    } catch (e) {

    }
}


function setValueWithEvent(obj, value) {
    obj.setValue(value);
    obj.change(obj.id);
}

function ControlIfRequiredFieldsAreSet(e) {
    if (new_SenderIdendificationNumber1.requirementLevel == 2) {
        if (new_SenderIdendificationNumber1.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_SenderIdendificationNumber1.getFieldLabel()));
            new_SenderIdendificationNumber1.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_NationalityID.requirementLevel == 2) {
        if (new_NationalityID.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_NationalityID.getFieldLabel()));
            new_NationalityID.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_IdendificationCardTypeID.requirementLevel == 2) {
        if (new_IdendificationCardTypeID.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_IdendificationCardTypeID.getFieldLabel()));
            new_IdendificationCardTypeID.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_IdentityNo_ItemValueField.requirementLevel == 2) {
        if (new_IdentityNo_ItemValueField.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_IdentityNo_ItemValueField.getFieldLabel()));
            new_IdentityNo_ItemTextField.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_Name_ItemValueField.requirementLevel == 2) {
        if (new_Name_ItemValueField.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_Name_ItemTextField.getFieldLabel()));
            new_Name_ItemTextField.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_MiddleName_ItemValueField.requirementLevel == 2) {
        if (new_MiddleName_ItemValueField.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_MiddleName_ItemTextField.getFieldLabel()));
            new_MiddleName_ItemTextField.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_LastName_ItemValueField.requirementLevel == 2) {
        if (new_LastName_ItemValueField.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_LastName_ItemTextField.getFieldLabel()));
            new_LastName_ItemTextField.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_BirthPlace_ItemValueField.requirementLevel == 2) {
        if (new_BirthPlace_ItemValueField.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_BirthPlace_ItemTextField.getFieldLabel()));
            new_BirthPlace_ItemTextField.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_BirthDate_ItemValueField.requirementLevel == 2) {
        if (new_BirthDate_ItemValueField.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_BirthDate_ItemTextField.getFieldLabel()));
            new_BirthDate_ItemTextField.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_MotherName_ItemValueField.requirementLevel == 2) {
        if (new_MotherName_ItemValueField.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_MotherName_ItemTextField.getFieldLabel()));
            new_MotherName_ItemTextField.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_FatherName_ItemValueField.requirementLevel == 2) {
        if (new_FatherName_ItemValueField.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_FatherName_ItemTextField.getFieldLabel()));
            new_FatherName_ItemTextField.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_PlaceOfIdendity_ItemValueField.requirementLevel == 2) {
        if (new_PlaceOfIdendity_ItemValueField.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_PlaceOfIdendity_ItemTextField.getFieldLabel()));
            new_PlaceOfIdendity_ItemTextField.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_DateOfIdendity.requirementLevel == 2) {
        if (new_DateOfIdendity.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_DateOfIdendity.getFieldLabel()));
            new_DateOfIdendity.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_ValidDateOfIdendity.requirementLevel == 2) {
        if (new_ValidDateOfIdendity.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_ValidDateOfIdendity.getFieldLabel()));
            new_ValidDateOfIdendity.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_HomeCountry.requirementLevel == 2) {
        if (new_HomeCountry.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_HomeCountry.getFieldLabel()));
            new_HomeCountry.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_HomeCity.requirementLevel == 2) {
        if (new_HomeCity.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_HomeCity.getFieldLabel()));
            new_HomeCity.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_HomeZipCode.requirementLevel == 2) {
        if (new_HomeZipCode.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_HomeZipCode.getFieldLabel()));
            new_HomeZipCode.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_GSMCountryId.requirementLevel == 2) {
        if (new_GSMCountryId.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_GSMCountryId.getFieldLabel()));
            new_GSMCountryId.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_GSM.requirementLevel == 2) {
        var GsmArea = document.getElementById('__new_GSM').value;
        var Gsm = document.getElementById('___new_GSM').value;
        if (GsmArea == '' || GsmArea.length <= 1 || Gsm == '' || Gsm <= 3) {
            alert(InvalidGsm);
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_HomeAdress.requirementLevel == 2) {
        if (new_HomeAdress.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_HomeAdress.getFieldLabel()));
            new_HomeAdress.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_SenderSegmentationID.requirementLevel == 2) {
        if (new_SenderSegmentationID.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_SenderSegmentationID.getFieldLabel()));
            new_SenderSegmentationID.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_E_Mail.requirementLevel == 2) {
        if (new_E_Mail.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_E_Mail.getFieldLabel()));
            new_E_Mail.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (new_HomeCityId.requirementLevel == 2) {
        if (new_HomeCityId.getValue() == "") {
            alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), new_HomeCityId.getFieldLabel()));
            new_HomeCityId.focus();
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    if (!IsValidEmail(e, new_E_Mail.getValue())) {
        return false;
    }
}

function IsValidEmail(e, email) {


    if (email == '')
        return true;



    // Get email parts
    var emailParts = email.split('@');

    // There must be exactly 2 parts
    if (emailParts.length !== 2) {
        alert(String.format(GetMessages("CRM_EMAIL_ADDRESS_NOT_CORRECT"), "Email"));
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }

    // Name the parts
    var emailName = emailParts[0];
    var emailDomain = emailParts[1];

    // === Validate the parts === \\

    // Must be at least one char before @ and 3 chars after
    if (emailName.length < 1 || emailDomain.length < 3) {
        alert(String.format(GetMessages("CRM_EMAIL_ADDRESS_NOT_CORRECT"), "Email"));
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }

    // Define valid chars
    var validChars = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '.', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '_', '-'];

    // emailName must only include valid chars
    for (var i = 0; i < emailName.length; i += 1) {
        if (validChars.indexOf(emailName.charAt(i)) < 0) {
            alert(String.format(GetMessages("CRM_EMAIL_ADDRESS_NOT_CORRECT"), "Email"));
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    // emailDomain must only include valid chars
    for (var j = 0; j < emailDomain.length; j += 1) {
        if (validChars.indexOf(emailDomain.charAt(j)) < 0) {
            alert(String.format(GetMessages("CRM_EMAIL_ADDRESS_NOT_CORRECT"), "Email"));
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }

    // Domain must include but not start with .
    if (emailDomain.indexOf('.') <= 0) {
        alert(String.format(GetMessages("CRM_EMAIL_ADDRESS_NOT_CORRECT"), "Email"));
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }

    // Domain's last . should be 2 chars or more from the end
    var emailDomainParts = emailDomain.split('.');
    if (emailDomainParts[emailDomainParts.length - 1].length < 2) {
        alert(String.format(GetMessages("CRM_EMAIL_ADDRESS_NOT_CORRECT"), "Email"));
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }

    return true;
}

function IsValidGsm(e, gsmArea, gsm) {
    if (gsmArea == '' || gsmArea.length <= 1 || gsm == '' || gsm <= 3) {
        alert(InvalidGsm);
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }
    return true;
}