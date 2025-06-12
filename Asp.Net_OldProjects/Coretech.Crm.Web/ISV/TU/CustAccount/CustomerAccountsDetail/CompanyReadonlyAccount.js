var win = window.parent;

$R(document).ready(function () {
    $R("#Frame_YETKILI_LISTESI").load(function () {
        ClearRelatedList();
    });
});

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
    if (getParentParameterByName('defaulteditpageid') == CorpReadOnlyForm) {
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
    DisableToolbarIfCalledByTransferScreen();
    NationalID_onChange();
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