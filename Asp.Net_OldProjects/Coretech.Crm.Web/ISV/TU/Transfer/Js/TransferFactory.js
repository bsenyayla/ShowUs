var isRunable = false;
var win = window.parent;
var recId = !win.hdnRecid ? "" : win.hdnRecid.getValue();

function CalculateForm(money, currency) {
    var ret = AjaxMethods.CalculateData(recId, money.id, money.getValue(), currency.getValue()).value;
    if (ret.Message != "")
        alert(ret.Message);

    win.new_ExpenseAmount.setValue(ret.ExpenseAmount);
    win.new_ExpenseAmountCurrency.setValue(ret.ExpenseAmountCurrency);
    win.new_ReceivedAmount1.setValue(ret.ReceivedAmount1);
    win.new_ReceivedAmount1Currency.setValue(ret.ReceivedAmount1Currency);
    win.new_ReceivedAmount2.setValue(ret.ReceivedAmount2);
    win.new_ReceivedAmount2Currency.setValue(ret.ReceivedAmount2Currency);

    win.new_PayableAmountToRecipient.setValue(ret.PayableAmountToRecipient);
    win.new_PayableAmountToRecipientCurrency.setValue(ret.PayableAmountToRecipientCurrency);

    win.new_TotalReceivedAmount.setValue(ret.TotalReceivedAmount);
    win.new_TotalReceivedAmountCurrency.setValue(ret.TotalReceivedAmountCurrency);
    win.new_TotalReceivableAmount.setValue(ret.TotalReceivableAmount);
    win.new_TotalReceivableAmountCurrency.setValue(ret.TotalReceivableAmountCurrency);

    win.new_ReceivedExpenseAmount.setValue(ret.ReceivedExpenseAmount);
    win.new_ReceivedExpenseAmountCurrency.setValue(ret.ReceivedExpenseAmountCurrency);

}
function FindeSenderbyIdentificationNumber() {
    var ret = AjaxMethods.FindeSenderbyIdentificationNumber(win.new_SenderCheckCardNo.getValue()).value;
    var new_SenderID = win.new_SenderID;
    if (ret.SenderId != win.EmtyGuid) {
        new_SenderID.setValue(ret.SenderId);
        new_SenderID.change();

        for (var i = 0; i < 100; i++) {
            win.status = i;
        }
        win.R.AjaxMethods.GetDynamicUrl("5fdb2e2a-5e5f-443e-ac61-eab733ea3848", ResultDynamicUrl);

    }
}

function ResultDynamicUrl(result) {

    var r = win.JSON.decode(result);
    var IframeSender = win.Iframe_Sender;
    IframeSender.load(r);


}

function SetCreditSender() {
    new_SenderID.setValue(getParameterByName("senderID"));
    ToolbarButtonFind.click();
}

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

function UpdateRecipientNickName() {
    if (win.new_RecipientID.getValue() == "")
        win.new_RecipienNickName.setValue(win.new_RecipientName.getValue() + ' ' + win.new_RecipientLastName.getValue());
}
function ToolbarButtonClear_Clear() {
    if (win.new_SenderID == undefined) {
        win.new_SenderId.clear();
        win.new_SenderId.setValue(null);
        win.new_SenderId.change();
        window.location = window.location;
    }
    else {
        win.new_SenderID.clear();
        win.new_SenderID.setValue(null);
        win.new_SenderID.change();
        window.location = window.location;
    }
    
}




