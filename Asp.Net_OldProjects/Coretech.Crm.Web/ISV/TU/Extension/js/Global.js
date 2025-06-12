/// <reference path="../Pool/InsertCustAccountWizard.aspx" />
/// <reference path="../Pool/InsertCustAccountWizard.aspx" /> 
function SelectAll(el) {
    setTimeout(new Function("try{$('" + el.input.id + "')" + ".select();}catch(e){}"), 100);
}
var ObjReq = [];
function CheckBefore() {
    for (var i = 0; i < ObjReq.length; i++) {
        if (ObjReq[i] != null) {
            var exType = ObjReq[i].xType;
            if ((exType == "CheckField")) {
                if (ObjReq[i].getValue() != true) {
                    alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), ObjReq[i].getFieldLabel()));
                    ObjReq[i].focus();
                    return false;
                } 
            }
            else if (R.isEmpty(ObjReq[i].getValue())) {
                alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), ObjReq[i].getFieldLabel()));
                ObjReq[i].focus();
                e.returnValue = false;
                return false;
            }
        }
    }
    return true;
}

var UptSenderSelector = {
    Type: "Sender",
    SelectedSender: [],
    Clear: function () {
        this.SelectedSender = [];
    },
    Add: function (key, value) {
        this.SelectedSender.push(
            { "Key": key, "Value": value }
            );
    },
    Show: function () {
        windowSenderSelector.show();
        R.reSize();
        //new_SinglebrandId.clear();
        //new_SenderGroupId.clear();
        //gpSenderSelector.reload();
    },
    Hide: function () {
        windowSenderSelector.hide();
    },
    Select: function () {
        this.Clear();
        var selected = gpSenderSelector.selectedRecord;
        this.Add(selected.VALUE, selected.ID);
        this.Hide();

    }
}
var Upt =
    {
        CustOperation: {
            Insert: 1,
            Delete: 2,
            Deposit: 3,
            Cash: 4,
            ReadOnly: 99
        },
        MessageType:
            {
                Information: 0,
                Question: 1,
                Warning: 2,
                Error: 3
            },
        alert: function (message, messageType, fnOk) {
            var fnfnct = "";
            if (fnOk != "" && fnOk.length > 0) {
                fnfnct = "if (btn == 1) { " + fnOk + " }";
            } else {
                fnfnct = "if (btn == 1) { }";
            }
            var fn = new Function("btn", fnfnct);
            //var fn = function (btn) { if (btn = 1) { } }

            top.R.MessageBox("Dikkat",
                message, "",
                true,
                messageType,
                R.ButtonType.OK, fn,
                true,
                420,
                150);
        },
        confirm: function (message, messageType, fnYes, fnNo) {
            var fnfnct = "";

            if (fnYes != "" && fnYes.length > 0) {
                fnfnct = "if (btn == 2) { " + fnYes + " }";
            }
            if (fnNo != "" && fnNo.length > 0) {
                fnfnct += "if(btn==4){" + fnNo + "}";
            }
            var fn = new Function("btn", fnfnct);
            top.R.MessageBox("Dikkat",
                message, "",
                true,
                messageType,
                R.ButtonType.YES + R.ButtonType.NO,
                fn,
                true,
                420,
                150);
        }
    }

function ShowRequestWindow(GridId, custoperation, id) {

    var url = window.top.GetWebAppRoot;

    if (custoperation === Upt.CustOperation.Insert)
        url += "/ISV/TU/CustAccount/Pool/InsertCustAccountWizard.aspx";
    if (custoperation === Upt.CustOperation.Delete)
        url += "/ISV/TU/CustAccount/Pool/DeleteCustAccountWizard.aspx";
    if (custoperation === Upt.CustOperation.Deposit)
        url += "/ISV/TU/CustAccount/Pool/DepositTransaction.aspx";
    if (custoperation === Upt.CustOperation.Cash)
        url += "/ISV/TU/CustAccount/Pool/CashTransaction.aspx";
    if (custoperation === Upt.CustOperation.TransferToUptCard)
        url += "/ISV/TU/CustAccount/Pool/TransferToUptCard.aspx";
    if (custoperation === Upt.CustOperation.ReadOnly)
        url += "/ISV/TU/CustAccount/Pool/CustAccountRouter.aspx";
    url += "?gridpanelid=" + GridId;

    if (custoperation === Upt.CustOperation.ReadOnly)
        url += "&recid=" + id;

    if (window != null) {
        url += "&tabframename=" + window.name;
        url += "&rlistframename=" + window.name;
    }
    if (window.parent != null) {
        url += "&pawinid=" + window.parent.name;
        url += "&pframename=" + window.parent.name;
    }

    window.top.newWindowRefleX(url, { maximized: false, width: 1024, height: 670, resizable: true, modal: true, maximizable: true });
}


//http://krazydad.com/tutorials/makecolors.php
function makeColorGradient(frequency1, frequency2, frequency3,
                           phase1, phase2, phase3,
                           center, width, i) {
    if (center == undefined) center = 128;
    if (width == undefined) width = 127;



    var red = Math.sin(frequency1 * i + phase1) * width + center;
    var grn = Math.sin(frequency2 * i + phase2) * width + center;
    var blu = Math.sin(frequency3 * i + phase3) * width + center;
    return RGB2Color(red, grn, blu);

}
function RGB2Color(r, g, b) {
    return '#' + byte2Hex(r) + byte2Hex(g) + byte2Hex(b);
}
function byte2Hex(n) {
    var nybHexString = "0123456789ABCDEF";
    return String(nybHexString.substr((n >> 4) & 0x0F, 1)) + nybHexString.substr(n & 0x0F, 1);
}

function fillLookup(a, b) {
    a.setValue(b.getValue(), b.getRawValue());
}
function fillValue(a, b) {
    a.setValue(b.getValue());
}
function fillLabel(a, b) {
    a.src.innerHTML = b.src.innerHTML;
}
function fillMoney(a, b) {
    fillValue(a, b);
    fillLookup(eval(a.id + "Currency"), eval(b.id + "Currency"));
}

function comboViewHideBalance() {
    var columns = new_CustAccountId.dataContainer.columns;
    columns.forEach(function (column) {
        if (column.name == "new_Balance") {
            column.hidden = true;
        }
    });
}