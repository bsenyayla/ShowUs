function ShowPayment() {
    var New_Payment = '201100075';
    var New_RefundPayment = '201200025';

    var objectId = New_Payment;

    var pId = hdnPaymentId.getValue();
    var rId = hdnrefundPaymentId.getValue();
    if (pId != "" || rId != "") {
        var w = null;
        if (top.R.WindowMng.getActiveWindow() != 0)
            w = top.R.WindowMng.getActiveWindow()
        if (rId != "") {
            objectId = New_RefundPayment;
            Qstring = GetWebAppRoot + "/ISV/TU/Refund/RefundPayment/RefundPaymentMain.aspx?defaulteditpageid="
                + "&ObjectId=" + objectId
                + "&mode=1"
                + "&rlistframename=" + window.name
                + "&PoolId=7"
                + "&recid=" + rId;

            window.top.newWindowRefleX(Qstring, { maximized: false, width: 1000, height: 600, resizable: true, modal: true, maximizable: true });
        }

        if (pId != "") {
            window.top.ShowEditWindow(null, pId, null, objectId);
        }

        hdnPaymentId.setValue("");
        hdnrefundPaymentId.setValue("");
        if (w != null)
            w.hide();
    }
}