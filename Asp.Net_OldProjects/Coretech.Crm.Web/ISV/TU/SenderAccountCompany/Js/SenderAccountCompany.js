var win = window.parent;
function SetCreatedSender() {
    var win = window.parent;
    var senderId = win.hdnRecid.getValue();
    var win1 = null;
    if (window.top.IsvWindowContainer != null) {
        win1 = window.top.IsvWindowContainer
        win1.new_SenderID.setValue(senderId);
        win1.new_SenderID.change();

        window.top.IsvWindowContainer = null;
        return;
    }
    else {
        win1 = window.top.R.WindowMng.getWindowById(win._pawinid);
        if (win1 != null) {
            frame = win1.getTab("Tabpanel1").getTabIFrame(win._tabframename);
            var new_SenderID = frame.eval("new_SenderID");
            new_SenderID.setValue(senderId);
            new_SenderID.change();

        }
    }

}

function IsValidGsm(e, gsmArea,gsm) {
    if (gsmArea == '' || gsmArea.length <= 1 || gsm == '' || gsm <=3) {
        alert(InvalidGsm);
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }
    return true;
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


function CheckSingularity(msg, e) {
    var win = window.parent;
    if (win.hdnRecid.value == null) {
        var ret = AjaxMethods.CheckSenderCompanySingularity(win.new_MersisNo.getValue(),
                            win.new_TaxNo.getValue(),
                            win.new_CompanyName.getValue()).value;
        if (ret != null && !ret.result) {
            if (window.confirm(CRM_NEW_SENDER_SINGULARITY_CONFIRM)) {
                win.location = win.location + "&recid=" + ret.SenderID;
            }
            else {
                window.top.R.WindowMng.getActiveWindow().hide();
            }
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    return true;
}

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

function getParentParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(window.parent.location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

function NationalID_onChange() {
    var element = win.document.getElementById("lbl_new_SenderIdendificationNumber1");
    if ((win.new_NationalityID != null && win.new_NationalityID.getValue() == "") || (win.new_NationalityID != null && win.new_NationalityID.getValue() != "" && win.new_NationalityID.getValue() == TurkeyID)) {
        element.innerHTML = "<span id='reqspan_new_SenderIdendificationNumber1' class='x-label-req-2 ' >* </span>" + win.String.format(win.GetMessages(CRM_NEW_SENDER_VKN_LABEL), "VKN");
        win.new_SenderIdendificationNumber1_Container.hidden = false;
        win.new_SenderIdendificationNumber1.setDisabled(false);
        win.new_SenderIdendificationNumber1.requirementLevel = 2;
    }
    else {
        win.new_SenderIdendificationNumber1_Container.hidden = true;
        win.new_SenderIdendificationNumber1.setDisabled(true);
        win.new_SenderIdendificationNumber1.requirementLevel = 0;
    }

    //Corp ekranı için readonly ise disabled olmalı.
    if(getParentParameterByName('defaulteditpageid') == CorpReadOnlyForm)
    {
        win.new_SenderIdendificationNumber1.setDisabled(true);
    }
}

function InsertSenderDocuments() {
    var senderId = win.hdnRecid.getValue();
    if (senderId != null && senderId != "") {
        AjaxMethods.InsertSenderDocumentsIfNecessary(senderId, win.new_CustAccountTypeId.getValue(), win.new_NationalityID.getValue());
        win.Frame_GONDERICI_DOCUMENT_LISTESI.location.reload(true);
    }
}

function LoadCompanyAccountScreen() {
    win.new_IdendificationCardTypeID.value = IdentificationType;
    DisableToolbarIfCalledByTransferScreen();
    NationalID_onChange();
    //var element = win.document.getElementById("lbl_new_Name");
    //element.innerHTML = "<span id='reqspan_new_Name' class='x-label-req-2 ' >* </span>" + win.String.format(win.GetMessages(CRM_NEW_SENDER_COMPANYNAME_LABEL), "Firma Adı");
    var element = win.document.getElementById("lbl_new_NationalityID");
    element.innerHTML = "<span id='reqspan_new_Name' class='x-label-req-2 ' >* </span>" + win.String.format(win.GetMessages(CRM_NEW_SENDER_COMPANYCOUNTRY_LABEL), "Ülke");
}

function DisableToolbarIfCalledByTransferScreen() {
    if (getParentParameterByName('defaulteditpageid') == CorpReadOnlyForm)
        return;
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

function CustomerAccountScreenSetSenderID() {
    if (getParentParameterByName('defaulteditpageid') == CorpReadOnlyForm)
        return;
    var sender = win.hdnRecid.getValue();
    var sender = win.hdnRecid.getValue();
    var senderName = win.hdnRecidName.getValue();
    win.MessageBar.style.marginTop = "22px";
    win.MessageBar.style.display = "block";
    if (sender != null && sender != "") {

        win.parent.parent.frames[1].SetUser(sender, senderName);
    }
}

function SetCorpCustomerAccountType() {
    win.new_CustAccountTypeId.setValue(CorpCustType);
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