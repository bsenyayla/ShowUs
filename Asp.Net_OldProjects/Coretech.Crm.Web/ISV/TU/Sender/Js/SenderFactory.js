var win = window.parent;
function SetCreatedSender() {
    var win = window.parent;
    var senderId = win.hdnRecid.getValue();
    var win1 = null;
    if (window.top.IsvWindowContainer != null) {
        win1 = window.top.IsvWindowContainer
        win1.new_SenderID.setValue(senderId);
        //win1.new_SenderID.change();

        window.top.IsvWindowContainer = null;
        return;
    }
    else {
        win1 = window.top.R.WindowMng.getWindowById(win._pawinid);
        if (win1 != null) {
            frame = win1.getTab("Tabpanel1").getTabIFrame(win._tabframename);
            var new_SenderID = frame.eval("new_SenderID");
            new_SenderID.setValue(senderId);
            //new_SenderID.change();

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

function CheckValidDateOfIdendity(o, e) {
    var date1 = win.new_ValidDateOfIdendity.getDateValue();
    if (date1 == "") { return true; }
    if (date1 < (new Date())) {
        alert(NEW_TRANSFER_SENDER_VALIDDATEOFIDENDITY_NOT_VALID);
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }
}

function CheckIdentificationCardNo(o, e) {

    var IdentificationCardNo = win.new_IdentityNo.getValue();
    var result = AjaxMethods.CheckIdentificationCardNo(IdentificationCardNo).value;
    if (result != '') {
        alert(result);
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }
}


function CheckSenderPhoneSingularity(o, e) {

    var senderGsm = win.new_GSM.getValues();

    var senderId = win.hdnRecid.getValue();

    try {
        var result = AjaxMethods.CheckGsmSingularity(senderGsm, senderId).value;
        if (result != '') {
            alert(result);
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    } catch (e) {

    }


}


function CheckIdentityNumber(o, e) {
    if (!ControlTCNumeric)
        return;
    var nationality = win.new_NationalityID.selectedRecord.new_ExtCode;
    var isCurrentUserForeign = AjaxMethods.IsCurrentUserForeign().value;
    if (nationality == 'TR' && !isCurrentUserForeign) {
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

function CheckNationality(o, e) {
 
    var nationality = win.new_NationalityID.selectedRecord.new_ExtCode;
   
    if (nationality == 'KZ') {
        var IdentityNumber = win.new_CorporationOfIdentity.getValue();

        if (isNaN(IdentityNumber)) {
            alert(NEW_SENDER_CORPORATION_OF_IDENTITY_REQUIRED);
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    
}



//    if (win.new_CameFromKps.requirementLevel == 2 && !win.new_CameFromKps.getValue()) {
//        alert(NEW_SENDER_KPSZORUNLU);
//        window.returnValue = false;
//        e.returnValue = false;
//        return false;
//    }


SetApsReadOnly();
SetKpsReadOnly();

function tryReadonly(obj) {
    try {
        obj.setReadOnly(true);
    } catch (e) {

    }
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

function IsValidGsm(e, gsmArea, gsm) {

    if (gsmArea == '' || gsmArea.length <= 1 || gsm == '' || gsm <= 3) {
        alert(InvalidGsm);
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }
    return true;
}


function IsValidIOMGsm(e, gsmArea, gsm) {

    if (gsmArea == '' || gsmArea.length <= 1 || gsm == '' || gsm <= 3) {
        alert(InvalidGsm);
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }

    if (!gsmArea.startsWith('5')) {
        alert('Geçerli bir cep telefonu girin!');
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }
    return true;
}

function IsValidGsmCountry(e, GsmCountry, GsmArea) {
    var result = false;
    var founded = false;

    var activeWindowId = top.R.WindowMng.getActiveWindow().id;

    var transferMainWindow = null;

    //find transfermain window
    for (var i = 0; i < top.R.WindowMng.windows.length; i++) {
        var wind = top.R.WindowMng.windows[i];
        if (!wind.active && wind.id != activeWindowId && wind.id.indexOf("R_") !== -1) {
            transferMainWindow = wind;
        }
    }

    var multiplePhoneCodeCountryList = null;
    var gsmErrorMessage = null;

    if (transferMainWindow) {
        multiplePhoneCodeCountryList = transferMainWindow.frame.contentWindow.multiplePhoneCodeCountries;
        gsmErrorMessage = transferMainWindow.frame.contentWindow.MULTIPLE_PHONE_CODE_INVALID;


        //validate gsm country code for multiplephonecodecountries like Kosova
        for (var i = 0; i < multiplePhoneCodeCountryList["countries"].length; i++) {
            var countryCode = multiplePhoneCodeCountryList["countries"][i];

            var newPhoneCountryCode = GsmCountry.indexOf('0') == 0 ? GsmCountry.substring(1) : GsmCountry;
            var newPhoneGsmArea = GsmArea.indexOf('0') == 0 ? GsmArea.substring(1) : GsmArea;

            var phoneNumber = newPhoneCountryCode + newPhoneGsmArea;

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
    }

    if (founded == false) {
        result = true;
    }

    if (!result) {
        alert(gsmErrorMessage);
        window.returnValue = false;
        e.returnValue = false;
    }

    return result;
}


function CheckSingularity(msg, e) {
    var win = window.parent;
    if (win.hdnRecid.value == null) {

        var ret = AjaxMethods.CheckSenderSingularity(win.new_NationalityID.getValue(),
            win.new_SenderIdendificationNumber1.getValue(),
            win.new_IdendificationCardTypeID.getValue(),
            win.new_IdentityNo.getValue(), win.new_CameFromKps.getValue(),
            win.new_Name.getValue(), win.new_MiddleName.getValue(), win.new_LastName.getValue(), win.new_BirthDate.getValue()).value;
        //Türkler için 1 adet gönderici gelir.
        if (ret != null && !ret.result) {
            if (ret.count == 1) {
                //KPS yapılmış bir gönderici kaydediliyorsa ve içeride aynı göndericinin KPS yapılmamış satırları varsa en üsttekini şimdiki ile güncelle.
                if (ret.isUpdate) {
                    win.hdnRecid.setValue(ret.SenderID);
                    window.returnValue = true;
                    e.returnValue = true;
                    return true;
                }
                else {
                    if (window.confirm(CRM_NEW_SENDER_SINGULARITY_CONFIRM)) {
                        win.location = win.location + "&recid=" + ret.SenderID;
                    }
                    else {
                        if (getParameterByName('fromTransferScreen') != null && getParameterByName('fromTransferScreen') != "" && getParameterByName('fromTransferScreen') == "1") {
                            //window.parent.parent.frames[1].Frame_Panel_SenderInformation.new_SenderID.clear();
                            window.top.R.WindowMng.getActiveWindow().hide();
                        }
                    }
                }
            }
            //Yabancılar için birden fazla gönderici gelebilir.
            else if (ret != null && !ret.result && ret.count > 1) {
                if (window.confirm(CRM_NEW_SENDER_MULTIPLESINGULARITY_CONFIRM)) {
                    var url = AjaxMethods.GetMultipleSingularityWindowUrlParams(win.new_NationalityID.getValue(),
                        win.new_SenderIdendificationNumber1.getValue(),
                        win.new_IdendificationCardTypeID.getValue(),
                        win.new_IdentityNo.getValue(),
                        win.new_Name.getValue(), win.new_MiddleName.getValue(), win.new_LastName.getValue()
                    ).value;
                    window.top.newWindowRefleX(window.top.GetWebAppRoot + '/ISV/TU/Sender/SenderMultipleSingularityResult.aspx' + url, { maximized: false, width: 1100, height: 400, resizable: true, modal: true, maximizable: false });
                }
                else {
                    if (getParameterByName('fromTransferScreen') != null && getParameterByName('fromTransferScreen') != "" && getParameterByName('fromTransferScreen') == "1") {
                        //window.parent.parent.frames[1].Frame_Panel_SenderInformation.new_SenderID.clear();
                        window.top.R.WindowMng.getActiveWindow().hide();
                    }
                }
            }
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    return true;
}


function IOM_ () {
    var element = win.document.getElementById("lbl_new_SenderIdendificationNumber1");
    if (win.new_NationalityID != null && win.new_NationalityID.getValue() != "" && win.new_NationalityID.getValue() != TurkeyID) {
        element.innerHTML = "<span id='reqspan_new_SenderIdendificationNumber1' class='x-label-req-2 ' >* </span>" + win.String.format(win.GetMessages(CRM_NEW_SENDER_FOREIGNIDENTIFICATIONID_LABEL), "YKN/VKN");
        win.BtnKpsApsCheck_Container.hidden = false;
    }
    else {
        element.innerHTML = "<span id='reqspan_new_SenderIdendificationNumber1' class='x-label-req-2 ' >* </span>" + win.String.format(win.GetMessages(CRM_NEW_SENDER_IDENTIFICATION_NUMBER), "Vatandaşlık No");
        win.BtnKpsApsCheck_Container.hidden = false;
    }
}



function NationalID_onChange() {
    var element = win.document.getElementById("lbl_new_SenderIdendificationNumber1");
    if (win.new_NationalityID != null && win.new_NationalityID.getValue() != "" && win.new_NationalityID.getValue() != TurkeyID) {
        element.innerHTML = "<span id='reqspan_new_SenderIdendificationNumber1' class='x-label-req-2 ' >* </span>" + win.String.format(win.GetMessages(CRM_NEW_SENDER_FOREIGNIDENTIFICATIONID_LABEL), "YKN/VKN");
        win.BtnKpsApsCheck_Container.hidden = false;
    }
    else {
        element.innerHTML = "<span id='reqspan_new_SenderIdendificationNumber1' class='x-label-req-2 ' >* </span>" + win.String.format(win.GetMessages(CRM_NEW_SENDER_IDENTIFICATION_NUMBER), "Vatandaşlık No");
        win.BtnKpsApsCheck_Container.hidden = false;
    }

    var nationality = win.new_NationalityID.selectedRecord.new_ExtCode;
    if (nationality == 'KZ') {
        win.new_CorporationOfIdentity.setRequirementLevel(2);
    }
    else {
        win.new_CorporationOfIdentity.setRequirementLevel(0);
    }
}


function UpdateIsDomesticValue() {
    win.new_IsDomestic.setValue(AjaxMethods.UpdateIsDomesticValue().value);
}

function UpdateChannelAndCorp() {
    var sender = win.hdnRecid.getValue();
    var channelCorp = AjaxMethods.GetChannelCorpValues(sender).value;
    win.new_ChannelCreated.setValue(channelCorp.channelCreated);
    win.new_CorporationCreated.setValue(channelCorp.corpCreated);
    win.new_ChannelModified.setValue(channelCorp.channelModified);
    win.new_CorporationModified.setValue(channelCorp.corpModified);
}

function DisableToolbarIfCalledByTransferScreen() {
    if ((getParameterByName('fromTransferScreen') != null && getParameterByName('fromTransferScreen') != "" && getParameterByName('fromTransferScreen') == "1")
        || (getParameterByName('fromCustomerAccountScreen') != null && getParameterByName('fromCustomerAccountScreen') != "" && getParameterByName('fromCustomerAccountScreen') == "1")
        || (getParameterByName('fromCustomerAccount3rdPerson') != null && getParameterByName('fromCustomerAccount3rdPerson') != "" && getParameterByName('fromCustomerAccount3rdPerson') == "1")
        || (getParameterByName('fromCheckCredit') != null && getParameterByName('fromCheckCredit') != "" && getParameterByName('fromCheckCredit') == "1")) {
        //win.EditToolbar_Container.hidden = true;
        //win.parent.parent.btnSenderSave = win.parent.btnSave;
        //win.parent.parent.btnSenderSave_Container.hidden = true;
        win.btnSaveAndClose_Container.hidden = true;
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
}

function TransferScreenSetSenderValues() {
    var sender = win.hdnRecid.getValue();
    var senderName = win.hdnRecidName.getValue();
    if (sender != "" && getParameterByName('fromTransferScreen') != null && getParameterByName('fromTransferScreen') != "" && getParameterByName('fromTransferScreen') == "1") {
        //window.parent.parent.frames[1].Frame_Panel_SenderInformation.new_SenderID.setValue(sender);
        //window.parent.parent.frames[1].Frame_Panel_SenderInformation.ToolbarButtonFind.click();
        window.parent.parent.frames[1].Sender.setValue(senderName);
        window.parent.parent.frames[1].new_SenderID.setValue(sender);
        //alert('TransferScreenSetSenderValues');
        window.parent.parent.frames[1].ToolbarButtonFind.click();
    }
}

function CustomerAccountScreenSetSenderID() {
    var sender = win.hdnRecid.getValue();
    var senderName = win.hdnRecidName.getValue();
    win.MessageBar.style.marginTop = "22px";
    win.MessageBar.style.display = "block";
    if (sender != null && sender != "" && (getParameterByName('fromCustomerAccountScreen') != null && getParameterByName('fromCustomerAccountScreen') != "" && getParameterByName('fromCustomerAccountScreen') == "1")) {

        win.parent.frames[1].SetUser(sender, senderName);
    }
    else if (sender != null && sender != "" && (getParameterByName('fromCustomerAccount3rdPerson') != null && getParameterByName('fromCustomerAccount3rdPerson') != "" && getParameterByName('fromCustomerAccount3rdPerson') == "1")) {
        win.parent.frames[1].UptSenderSelector.Type = '3rdSender';
        win.parent.frames[1].SetUser(sender, senderName);
    }
}

function TransferScreenSetSenderID() {
    var sender = win.hdnRecid.getValue();
    var senderName = win.hdnRecidName.getValue();
    if (sender != "" && getParameterByName('fromTransferScreen') != null && getParameterByName('fromTransferScreen') != "" && getParameterByName('fromTransferScreen') == "1") {


        window.parent.parent.frames[1].new_SenderID.setValue(sender);
        window.parent.parent.frames[1].Sender.setValue(senderName);
        //alert('TransferScreenSetSenderID');
        //window.parent.parent.frames[1].ToolbarButtonFind.click();

        //window.parent.parent.frames[1].Frame_Panel_SenderInformation.new_SenderID.setValue(sender);
        //window.parent.parent.frames[1].Frame_Panel_SenderInformation.ToolbarButtonFind.click();
        //win.parent.parent.new_SenderID.setValue(sender);
    }
}

function SetRealCustomerAccountType() {
    win.new_CustAccountTypeId.setValue(RealCustType);
}

function InsertSenderDocuments() {
    var senderId = win.hdnRecid.getValue();
    if (senderId != null && senderId != "") {
        AjaxMethods.InsertSenderDocumentsIfNecessary(senderId, win.new_CustAccountTypeId.getValue(), win.new_NationalityID.getValue());
        win.Frame_GONDERICI_DOCUMENT_LISTESI.location.reload(true);
    }
}

function DirectToCreditPayment() {
    var win = window.parent;
    var senderId = win.hdnRecid.getValue();
    var url = AjaxMethods.DirectToCreditPayment(senderId, getParameterByName('creditDataID')).value;
    window.top.newWindowRefleX(window.top.GetWebAppRoot + url, { maximized: true, resizable: false, modal: true });
}

function FillNationIdAndSenderIdentification(senderIdentificationNum, nationID) {
    win.labelInfo.setValue(CRM_NEW_SENDER_CREDIT_CREATE_SENDER_INFO);
    win.new_SenderIdendificationNumber1.setValue(senderIdentificationNum);
    win.new_NationalityID.setValue(nationID);
    win.new_NationalityID.setDisabled(true);
    win.new_SenderIdendificationNumber1.setDisabled(true);
}



function UpdateSenderType() {
    var win = window.parent;
    if (win.hdnRecid.value == null) {
        var ret = AjaxMethods.GetSenderType(win.new_NationalityID.getValue(),
            win.new_SenderIdendificationNumber1.getValue(),
            win.new_IdendificationCardTypeID.getValue(),
            win.new_IdentityNo.getValue(), win.new_Name.getValue(), win.new_MiddleName.getValue(), win.new_LastName.getValue(), win.new_BirthDate.getValue()).value;
        win.new_SenderType.setValue(ret);
    }
}


function UpdateCustAccountType() {
    var win = window.parent;
    if (win.hdnRecid.value == null) {
        var ret = AjaxMethods.GetCustAccountType().value;
        win.new_CustAccountTypeId.setValue(ret);
    }
}

function UpdateCorporatedCustAccountType() {
    var win = window.parent;
    if (win.hdnRecid.value == null) {
        var ret = AjaxMethods.GetCorporatedCustAccountType().value;
        win.new_CustAccountTypeId.setValue(ret);
    }
}



function IOMCustomerAutomation() {
    var win = window.parent;
    var senderId = win.hdnRecid.getValue();

    var ret = AjaxMethods.IOMCustomerAutomation(senderId, win.new_NationalityID.getValue(), win.new_CardNumber.getValue()).value;
    if (ret != undefined) {

        if (ret == 'ok') {
            alert('Müşteri hesabı ve Kartı açıldı.');
            var win = window.parent;
            var senderId = win.hdnRecid.getValue();
            var senderCurrentPage = top.R.WindowMng.getActiveWindow();
            window.parent.top.newWindowRefleX(window.top.GetWebAppRoot + '/CrmPages/AutoPages/EditReflex.aspx?defaulteditpageid=AC1D3BAE-F995-E611-A984-54442FE8720D&ObjectId=201100052&mode=1&recid=' + senderId, { maximized: false, resizable: true, modal: true, height: 600, width: 800 });

            senderCurrentPage.hide();
        }
        else {
            alert(ret);
        }
    }
}