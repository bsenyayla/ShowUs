/*Her Load isleminde Kontrol et.*/
function CheckAllControls() {

}
//setTimeout(function () { SetNationality(); SetKpsReadOnly(); SetIdentificationValidDate(); }, 500);



function ValidateBeforeSave(msg, e) {

    var ret = CrmValidateForm(msg, e)
    if (!ret)
        return;

    if (!new_IdentityChecked.getValue()) {
        alert(isIdentityShowMessage.getValue());
        //alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), dugmemesaj));
        e.returnValue = false;
        return false;
    }

}
