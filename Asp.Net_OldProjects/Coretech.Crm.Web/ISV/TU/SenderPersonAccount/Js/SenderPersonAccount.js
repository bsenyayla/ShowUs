var win = window.parent;

function SetCreatedSenderPerson() {
    var win = window.parent;
    var senderPersonId = win.hdnRecid.getValue();
    var win1 = null;
    if (window.top.IsvWindowContainer != null) {
        win1 = window.top.IsvWindowContainer
        win1.New_SenderPersonId.setValue(senderPersonId);
        win1.New_SenderPersonId.change();

        window.top.IsvWindowContainer = null;
        return;
    }
    else {
        win1 = window.top.R.WindowMng.getWindowById(win._pawinid);
        if (win1 != null) {
            frame = win1.getTab("Tabpanel1").getTabIFrame(win._tabframename);
            var new_SenderID = frame.eval("New_SenderPersonId");
            New_SenderPersonId.setValue(senderId);
            New_SenderPersonId.change();

        }
    }

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

function NationalID_onChange() {
    var element = win.document.getElementById("lbl_new_SenderIdendificationNumber1");
    if (win.new_NationalityID != null && win.new_NationalityID.getValue() != "" && win.new_NationalityID.getValue() != TurkeyID) {
        element.innerHTML = "<span id='reqspan_new_SenderIdendificationNumber1' class='x-label-req-2 ' >* </span>" + win.String.format(win.GetMessages(CRM_NEW_SENDER_FOREIGNIDENTIFICATIONID_LABEL), "YKN/VKN");
        win.new_MotherName_Container.hidden = true;
        win.new_MotherName.setDisabled(true);
        win.new_MotherName.requirementLevel = 0;
        win.new_FatherName_Container.hidden = true;
        win.new_FatherName.setDisabled(true);
        win.new_FatherName.requirementLevel = 0;
        win.BtnKpsApsCheck_Container.hidden = false;
    }
    else {
        element.innerHTML = "<span id='reqspan_new_SenderIdendificationNumber1' class='x-label-req-2 ' >* </span>" + win.String.format(win.GetMessages(CRM_NEW_SENDER_IDENTIFICATION_NUMBER), "Vatandaşlık No");
        win.new_MotherName_Container.hidden = false;
        win.new_MotherName.setDisabled(false);
        win.new_MotherName.requirementLevel = 2;
        win.new_FatherName_Container.hidden = false;
        win.new_FatherName.setDisabled(false);
        win.new_FatherName.requirementLevel = 2;
        win.BtnKpsApsCheck_Container.hidden = false;
    }
}

function DisableToolbar() {
    win.btnSave_Container.hidden = true;
    win.btnSaveAsCopy_Container.hidden = true;
    win.btnDDSave_Container.hidden = true;
    win.btnDelete_Container.hidden = true;
    win.btnPassive_Container.hidden = true;
    win.btnSaveAndNew_Container.hidden = true;
    win.ActionMenu_Container.hidden = true;
    win.ReportMenu_Container.hidden = true;
    win.btnAction_Container.hidden = true;
    win.btnRefresh_Container.hidden = true;
}

function IsValidEmail(o, e, email) {


    if (email == '')
        return true;



    // Get email parts
    var emailParts = email.split('@');

    // There must be exactly 2 parts
    if (emailParts.length !== 2) {
        alert(win.String.format(win.GetMessages("CRM_EMAIL_ADDRESS_NOT_CORRECT"), "Email"));
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
        alert(win.String.format(win.GetMessages("CRM_EMAIL_ADDRESS_NOT_CORRECT"), "Email"));
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }

    // Define valid chars
    var validChars = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '.', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '_', '-'];

    // emailName must only include valid chars
    for (var i = 0; i < emailName.length; i += 1) {
        if (validChars.indexOf(emailName.charAt(i)) < 0) {
            alert(win.String.format(win.GetMessages("CRM_EMAIL_ADDRESS_NOT_CORRECT"), "Email"));
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    // emailDomain must only include valid chars
    for (var j = 0; j < emailDomain.length; j += 1) {
        if (validChars.indexOf(emailDomain.charAt(j)) < 0) {
            alert(win.String.format(win.GetMessages("CRM_EMAIL_ADDRESS_NOT_CORRECT"), "Email"));
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }

    // Domain must include but not start with .
    if (emailDomain.indexOf('.') <= 0) {
        alert(win.String.format(win.GetMessages("CRM_EMAIL_ADDRESS_NOT_CORRECT"), "Email"));
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }

    // Domain's last . should be 2 chars or more from the end
    var emailDomainParts = emailDomain.split('.');
    if (emailDomainParts[emailDomainParts.length - 1].length < 2) {
        alert(win.String.format(win.GetMessages("CRM_EMAIL_ADDRESS_NOT_CORRECT"), "Email"));
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }

    return true;
}

function CheckIdentityNumber(o, e) {

    var nationality = win.new_NationalityID.selectedRecord.new_ExtCode;
    if (nationality == 'TR') {
        var IdentityNumber = win.new_SenderIdendificationNumber1.getValue();

        if (isNaN(IdentityNumber)) {
            alert(NEW_SENDER_IDENDITYNO_MUST_BE_NUMBER);
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
        if (IdentityNumber.length != 11) {
            alert(NEW_SENDER_IDENDITYNO_MUST_BE_ELEVEN_CHAR);
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }

    }
}

function SetKpsData() {
    var win = window.parent;
    win.R.mask("SetKpsData1", "Kps..?");
    setTimeout(new Function("SetKpsData1();"), 100);
}

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

function getParameterByNameUrl(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, '\\$&');
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
}


function SetKpsData1() {
    var win = window.parent;
    if (win.new_NationalityID.getValue() == "") {
        alert(win.String.format(win.GetMessages("CRM_FIELD_REQUIRED"), win.new_NationalityID.getFieldLabel()));
        win.R.unmask("SetKpsData1");
        return;
    } if (win.new_SenderIdendificationNumber1.getValue() == "") {
        alert(win.String.format(win.GetMessages("CRM_FIELD_REQUIRED"), win.new_SenderIdendificationNumber1.getFieldLabel()));
        win.R.unmask("SetKpsData1");
        return;
    }
    //    try {
    var ret = AjaxMethods.GetKpsData(win.new_SenderIdendificationNumber1.getValue(), win.new_NationalityID.getValue()).value;
    win.R.unmask("SetKpsData1");
    if (ret.new_cameFromKps) {
        win.new_Name.setValue(ret.new_Name);
        win.new_MiddleName.setValue(ret.new_MiddleName);
        win.new_LastName.setValue(ret.new_LastName);
        win.new_FatherName.setValue(ret.new_FatherName);
        win.new_MotherName.setValue(ret.new_MotherName);
        win.new_BirthPlace.setValue(ret.new_BirthPlace);
        try {
            win.new_CountryOfIdendity.setValue(ret.new_CountryOfIdendity);
        } catch (e) {

        }
        try {
            win.new_PlaceOfIdendity.setValue(ret.new_PlaceOfIdendity);
        } catch (e) {

        }


        try {
            win.new_DateOfIdendity.setValue(ret.new_DateOfIdendity);
        } catch (e) {

        }

        // try {

        win.new_BirthDate.setValue(ret.new_BirthDate);
        //} catch (e) {

        // }
        try {
            if (ret.new_GenderID != "")
                win.new_GenderID.setValue(ret.new_GenderID);
        } catch (e) {

        }

        win.new_CameFromKps.setValue(ret.new_cameFromKps);
        //    } catch (ex) {
        //        alert(ex);
        //    }
    } else {
        alert(NEW_SENDER_KPS_HATALI);
        win.new_CameFromKps.setValue(ret.new_cameFromKps);
        win.new_CameFromKps.setRequirementLevel(0);
    }
    SetKpsReadOnly();

    SetApsData();
}
function SetApsData() {
    var win = window.parent;
    var retax = AjaxMethods.GetApsData(win.new_SenderIdendificationNumber1.getValue(), win.new_NationalityID.getValue()).value;
    if (retax.new_cameFromAps) {
        win.new_HomeCity.setValue(retax.new_HomeCity);
        win.new_HomeCityId.setValue(retax.new_HomeCityId);
        win.new_HomeCountry.setValue(retax.new_HomeCountry);
        //win.new_HomeDistrict.setValue(retax.new_HomeDistrict);
        //win.new_HomeDistrictText.setValue(retax.new_HomeDistrictText);
        win.new_HomeAdress.setValue(retax.adres);
        win.new_cameFromAps.setValue(retax.new_cameFromAps);
    }
    SetApsReadOnly();
}

function tryReadonly(obj) {
    try {
        obj.setReadOnly(true);
    } catch (e) {

    }
}

SetApsReadOnly();
SetKpsReadOnly();

function SetApsReadOnly() {
    if (win.new_cameFromAps.getValue()) {
        tryReadonly(win.new_HomeCity);
        tryReadonly(win.new_HomeCityId);
        tryReadonly(win.new_HomeCountry);
        tryReadonly(win.new_HomeAdress);
        tryReadonly(win.new_cameFromAps);

    }
}
function SetKpsReadOnly() {
    if (win.new_CameFromKps.getValue()) {
        tryReadonly(win.new_Name);
        tryReadonly(win.new_MiddleName);
        tryReadonly(win.new_LastName);
        tryReadonly(win.new_FatherName);
        tryReadonly(win.new_MotherName);
        tryReadonly(win.new_BirthPlace);
        tryReadonly(win.new_CountryOfIdendity);
        tryReadonly(win.new_PlaceOfIdendity);
        tryReadonly(win.new_DateOfIdendity);
        tryReadonly(win.new_BirthDate);
        tryReadonly(win.new_GenderID);
        tryReadonly(win.new_NationalityID);
        tryReadonly(win.new_SenderIdendificationNumber1);
    }
}

function SetSenderID() {
    if (getParameterByName('SenderID') != null && getParameterByName('SenderID') != "") {
        alert(getParameterByName('SenderID'));
        win.new_SenderId.setValue(getParameterByName('SenderID'));
    }
}


function PutSenderId(url) {
    var senderId = getParameterByNameUrl('SenderID', url);
    var senderPersonId = win.hdnRecid.getValue();
    if (senderPersonId != '' && senderPersonId != null && senderId != '' && senderId != null) {
        AjaxMethods.UpdateSenderId(senderId, senderPersonId);
    }
}