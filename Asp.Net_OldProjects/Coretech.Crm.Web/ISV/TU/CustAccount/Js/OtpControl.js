function ShowOtpContolPanel(senderId, senderPersonId, custAccountTypeId, pageTitle) {
    var config = GetWebAppRoot + "/ISV/TU/CustAccount/Pool/OtpControlForm.aspx?senderId=" + senderId + "&senderPersonId=" + senderPersonId + "&custAccountTypeId=" + custAccountTypeId;
    window.top.newWindow(config, {
        title: pageTitle,
        width: 500,
        height: 250,
        draggable: false,
        resizable: false,
        modal: true
    });
}

var tim;
var clickButton;
var min = 2;
var sec = 59;
var f = new Date();

function RepeatFunction() {
    min = 2;
    sec = 59;    
    clickButton.style.display = "none";
    CountdownFunction();
}


function CountdownFunction() {
    if (parseInt(sec) > 0) {
        sec = parseInt(sec) - 1;
        document.getElementById("showtime").innerHTML = min + ":" + sec;
        tim = setTimeout(CountdownFunction, 1000);
    }
    else {
        if (parseInt(sec) == 0) {
            min = parseInt(min) - 1;
            if (parseInt(min) < 0) {
                clearTimeout(tim);
                document.getElementById("showtime").innerHTML = "";
                clickButton.style.display = "block";
            }
            else {
                sec = 59;
                document.getElementById("showtime").innerHTML = min + ":" + sec;
                tim = setTimeout(CountdownFunction, 1000);
            }
        }

    }
}

function SetElement(element) {
    clickButton = element;
}