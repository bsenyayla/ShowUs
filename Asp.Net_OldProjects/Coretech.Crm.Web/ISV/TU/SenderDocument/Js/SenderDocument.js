var win = window.parent;
function UpdateDocumentReceivedFlg() {
    AjaxMethods.UpdateDocumentReceivedFlg(win.hdnRecid.getValue());
}

function PageLoad() {
    if (win.new_IsDocumentTypeReadOnly.value == true) {
        win.new_DocumentTypeID.setReadOnly(true);
    }
    win.IFRAME_AJAX.border = false;
    win.IFRAME_AJAX_Container.style.border = 0;
}