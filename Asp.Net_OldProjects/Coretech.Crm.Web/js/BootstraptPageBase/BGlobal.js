/*
 Bootstrapt Global Js--
 Ace Admin Template ile calisit istenilirse  ilgili Html Sayfasinin icerisine bask Templateler de eklenebilir o yuzden ozgur birakilmistir.
 Gelistirme Asamasinda Degisiklikler Gosterebilir,
 Author     :   Hasan,
 Version    :   0.0.0.1
 Created On :   25.08.2016
 */
BGlobal = {
    IdentityType: {
        Unqueidentifier: 1,
        Integer: 2
    },
    getData: function (url, data, success, isAsync) {
        isAsync = typeof isAsync !== 'undefined' ? isAsync : false;
        return $.ajax({
            type: "POST",
            dataType: "json",
            url: url,
            data: data,
            success: success,
            async: isAsync
        });
        //$.getJSON(url, data, success);
    },
    fillComboData: function (comboName, comboKey, idColumn, valueColumn, parameters, Options) {
        return this.getData(GetWebAppRoot + "/Handlers/GetData.ashx", {
            "key": comboKey,
            "Parameters": JSON.stringify(parameters),
            "Options": JSON.stringify(Options)
        }, function (data) {
            var options = '';
            for (var x = 0; x < data.Records.length; x++) {
                options += '<option value="' + data.Records[x][idColumn] + '">' + data.Records[x][valueColumn] + '</option>';
            }
            $('#' + comboName).html(options);
        });
    },
    fillAllComboData: function (comboNames, comboKey, idColumn, valueColumn, parameters, Options) {
        return this.getData(GetWebAppRoot + "/Handlers/GetData.ashx", {
            "key": comboKey,
            "Parameters": JSON.stringify(parameters),
            "Options": JSON.stringify(Options)
        }, function (data) {
            var options = '';
            for (var x = 0; x < data.Records.length; x++) {
                options += '<option value="' + data.Records[x][idColumn] + '">' + data.Records[x][valueColumn] + '</option>';
            }
            $.each(comboNames, function (key, val) {
                $('#' + val).html(options);
            });
        });
    },
    getRecords: function (comboKey, parameters, options, success) {
        return this.getData(GetWebAppRoot + "/Handlers/GetData.ashx", {
            "key": comboKey,
            "Parameters": JSON.stringify(parameters),
            "Options": JSON.stringify(options)
        }, success);
    },
    callMethod: function (method, parameters, success, isAsync) {
        return this.getData("", {
            "__Method": method,
            "__Parameters": JSON.stringify(parameters)
        }, function (data) {
            if (!jQuery.isEmptyObject(data)) {
                if (!!data.Script) {
                    jQuery.globalEval(data.Script);
                }
            };
            success(data);
        }, isAsync
        );
    },
    messageShow: function (message) {//BootBox Requared
        bootbox.alert(message);
    },
    navigate: function (url) {
        window.location = url;
    },
    setFullScreen: function (elem) {
        if ((document.fullScreenElement !== undefined && document.fullScreenElement === null) || (document.msFullscreenElement !== undefined && document.msFullscreenElement === null) || (document.mozFullScreen !== undefined && !document.mozFullScreen) || (document.webkitIsFullScreen !== undefined && !document.webkitIsFullScreen)) {
            if (elem.requestFullScreen) {
                elem.requestFullScreen();
            } else if (elem.mozRequestFullScreen) {
                elem.mozRequestFullScreen();
            } else if (elem.webkitRequestFullScreen) {
                elem.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT);
            } else if (elem.msRequestFullscreen) {
                elem.msRequestFullscreen();
            }
        } else {
            if (document.cancelFullScreen) {
                document.cancelFullScreen();
            } else if (document.mozCancelFullScreen) {
                document.mozCancelFullScreen();
            } else if (document.webkitCancelFullScreen) {
                document.webkitCancelFullScreen();
            } else if (document.msExitFullscreen) {
                document.msExitFullscreen();
            }
        }
    },
}
$(document).ready(function () {
    if (BootstraptBasePageInitialAction != null && BootstraptBasePageInitialAction.Script && BootstraptBasePageInitialAction.Script.length > 0) {
        jQuery.globalEval(BootstraptBasePageInitialAction.Script);
    }
});