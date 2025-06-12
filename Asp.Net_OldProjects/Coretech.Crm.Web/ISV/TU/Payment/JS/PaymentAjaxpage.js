var isRunable = false;
var win = window.parent;
var recId = win.hdnRecid.getValue();

function CalculateForm(money, currency) {
    var ret = AjaxMethods.CalculateData(recId, money.id, money.getValue(), currency.getValue()).value;
    if (ret.Message != "")
        alert(ret.Message);


    win.new_PaidAmount1.setValue(ret.PaidAmount1);
    win.new_PaidAmount1Currency.setValue(ret.PaidAmount1Currency);
    win.new_TransferPaidParity1.setValue(ret.TransferPaidParity1);
    //    win.new_TotalPayableAmount.setValue(ret.TotalPayableAmount);
    //    win.new_TotalPayableAmountCurrency.setValue(ret.TotalPayableAmountCurrency);

    win.new_ExpenseAmount.setValue(ret.ExpenseAmount);
    win.new_ExpenseAmountCurrency.setValue(ret.ExpenseAmountCurrency);

}
function SetKpsData() {
    var win = window.parent;
    win.R.mask("SetKpsData1", "Kps..?");
    setTimeout(new Function("SetKpsData1();"), 100);
}

function SetKpsData1() {

    var win = window.parent;
    if (win.new_NationalityID.getValue() == "") {
        alert(win.String.format(win.GetMessages("CRM_FIELD_REQUIRED"), win.new_NationalityID.getFieldLabel()));
        return;
    }
    //    try {
    var ret = AjaxMethods.GetKpsData(win.new_RecipientIdentificationCardNumber.getValue(), win.new_NationalityID.getValue()).value;
    win.R.unmask("SetKpsData1");
    if (ret.new_cameFromKps) {
        win.new_RecipientName.setValue(ret.new_Name);
        win.new_RecipientLastName.setValue(ret.new_LastName);
        win.new_FatherName.setValue(ret.new_FatherName);
        win.new_BirthPlace.setValue(ret.new_BirthPlace);
        win.new_MotherName.setValue(ret.new_MotherName);
        win.new_Birthdate.setValue(ret.new_BirthDate);

        try {
            if (ret.new_GenderID != "")
                win.new_GenderID.setValue(ret.new_GenderID);
        } catch (e) {

        }

        win.new_CameFromKps.setValue(ret.new_cameFromKps);

    }
    else {

        alert(NEW_RECIPIENT_KPS_HATALI);
        win.new_CameFromKps.setValue(ret.new_cameFromKps);
        win.new_CameFromKps.setRequirementLevel(0);
        return;
    }
    SetKpsReadOnly();
    SetApsData();
}
function SetApsData() {
    var win = window.parent;
    var retax = AjaxMethods.GetApsData(win.new_RecipientIdentificationCardNumber.getValue(), win.new_NationalityID.getValue()).value;
    if (retax.new_cameFromAps) {
        win.new_Address.setValue(retax.adres);
        win.new_cameFromAps.setValue(retax.new_cameFromAps);
    }
    SetApsReadOnly();
}

function SetApsReadOnly() {
    if (win.new_cameFromAps.getValue()) {
        tryReadonly(win.new_Address);
    }
}

function SetIdentificationValidDate() {
    var win = window.parent;
    win.new_ValidDateOfIdendity.hide();
    var retax = AjaxMethods.IsIdentificationValidDate(win.new_IdentificatonCardTypeId.getValue()).value;
    if (retax) {
        win.new_ValidDateOfIdendity.show();
    } else {
        win.new_ValidDateOfIdendity.hide();
    }
}

function SetNationality() {
    return;
    a = win.new_NationalityID.getValue();

    var ret = false;
    try {
        ret = AjaxMethods.GetRequaredNationality(a).value;
    } catch (e) {
        win.btnKpsAps.setDisabled(true);
    }
    win.btnKpsAps.setDisabled(!ret);
    if (ret) {
        win.new_CameFromKps.setRequirementLevel(2);
        win.new_cameFromAps.setRequirementLevel(2);
    } else {
        win.new_CameFromKps.setRequirementLevel(0);
        win.new_cameFromAps.setRequirementLevel(0);

    }
}
/*Her Load isleminde Kontrol et.*/
setTimeout(function () { SetNationality(); SetKpsReadOnly(); SetIdentificationValidDate(); }, 500);



function ValidateBeforeSave(msg, e) {
    var ret = win.CrmValidateForm(msg, e)
    if (!ret)
        return;

    if (win.new_ValidDateOfIdendity.visible) {
        var date1 = win.new_ValidDateOfIdendity.getDateValue();
        if (date1 < (new Date())) {
            alert(NEW_RECIPIENT_VALIDDATEOFIDENDITY_NOT_VALID);
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }

    if (win.new_CameFromKps.requirementLevel == 2 && !win.new_CameFromKps.getValue()) {
        alert(NEW_RECIPIENT_KPS_ZORUNLU);
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }

    var Birthdate = win.new_Birthdate.getValue();
    ret = AjaxMethods.GetRecipientBirthdate(Birthdate).value;
    if (ret != "") {
        alert(ret);
        window.returnValue = false;
        e.returnValue = false;
        return false;
    }



}

function SetKpsReadOnly() {
    var win = window.parent;
    if (win.new_CameFromKps.getValue()) {
        tryReadonly(win.new_RecipientName);
        tryReadonly(win.new_RecipientLastName);
        //tryReadonly(win.new_FatherName);
        tryReadonly(win.new_BirthPlace);
        tryReadonly(win.new_MotherName);
        tryReadonly(win.new_Birthdate);
        tryReadonly(win.new_GenderID);

    }
}

function tryReadonly(obj) {

    try {
        obj.setReadOnly(true);
    } catch (e) {

    }
}