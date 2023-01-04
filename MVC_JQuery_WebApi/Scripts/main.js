var oValidate = { rules: null, errorElement: null, errorClass: null, errorPlacement: null, errorMessage: null, focusInvalid: null, ignore: null, invalidHandler: null, highlight: null, unhighlight: null, success: null, submitHandler: null, pageContent: null };
var oPostJsonAction = { controller: null, action: null, json: null, modal: null, form: null, reloadAjax: null, options: null, svalue: null, data: null, ddname: null, ddselected: null, blockUI: null, fadeOut: null };

var myErrorFunction = function () {
    alert('error');
    Metronic.unblockUI('.page-content');
};

var myBlockUiFunction = function () {
    Metronic.blockUI({
        target: '.page-content',
        cenrerY: true,
        boxed: true
    });
}

//Функция делает валидацию формы
function formValidation(validOption) {
    var editForm = validOption.form;
    var erroreditForm = $('.alert-danger', editForm);

    var fOptions = oValidate;
    fOptions.rules = validOption.options;
    fOptions.errorElement = "span";
    fOptions.errorClass = 'help-block',
        fOptions.errorPlacement = function (error, element) { erroreditForm.appendTo(element.parents('.form-group')); };
    fOptions.focusInvalid = false;
    fOptions.ignore = "";
    fOptions.invalidHandler = function (event, validator) { ShowErrorToastr(validOption); }; //display error alert on form submit
    fOptions.highlight = function (element) { $(element).parents('.form-group').addClass('has-error'); }; // set error class to the control group
    fOptions.unhighlight = function (element) { $(element).parents('.form-group').removeClass('has-error'); }; // set error class to the control group
    fOptions.success = function (label) { label.parents('.form-group').removeClass('has-error'); };
    fOptions.submitHandler = function (form) {
        validOption.json = serializedForm(editForm);
        SentPostAfterSubbmit(validOption);
    };

    jQuery.extend(jQuery.validator.messages, { required: "*" });
    return editForm.validate(fOptions);
}

//отправляет json в контроллер для обработки
function SentPostAfterSubbmit(validOption) {
    $.post("/" + validOption.controller + "/" + validOption.action, { json: validOption.json }, function (data, status, jqxhr) {
        $('#' + validOption.modal).modal('hide');
        ReloadAjaxTable(validOption);
        validOption.errorMessage = jsTranslate('The_changes_were_successful_6223');
        ShowSuccessToastr(validOption);
    }, "json").error(function (jqXHR, textStatus, errorThrown) {
        validOption.errorMessage = jqXHR.responseText;
        ShowErrorToastr(validOption);
        //alert("Во время редактирования возникла ошибка: " + jqXHR.responseText);
        console.log("jqXHR: " + jqXHR);
        console.log("textStatus: " + textStatus);
        console.log("errorThrown: " + errorThrown);
    });
}

//Обновляем данные в таблице
function ReloadAjaxTable(validOption) {
    var table = $('#' + validOption.reloadAjax).dataTable();
    table.fnReloadAjax();
}

//Делаем сериализацию формы
function serializedForm(serializedFrom) {
    var sFrom = serializedFrom;

    sFrom.find(':disabled').removeAttr('disabled');

    var json;
    var serialized = sFrom.serializeArray();
    var s = '';
    var data = {};
    for (s in serialized) {
        console.log('name: ' + data[serialized[s]['name']]);
        console.log('value: ' + serialized[s]['value']);
        data[serialized[s]['name']] = serialized[s]['value']
    }
    json = JSON.stringify(data);

    console.log("json - " + json);

    return json;
}

//Отображаем сообщение о незаполненных поля (для валидации)
function ShowErrorToastr(validOption) {
    var error = validOption.form;
    error.show();
    toastr.options = {
        "closeButton": true,
        "debug": false,
        "positionClass": "toast-top-left",
        "onclick": null,
        "showDuration": "1000",
        "hideDuration": "3000",
        "timeOut": "5000",
        "extendedTimeOut": "1000",
        "showEasing": "swing",
        "hideEasing": "linear",
        "showMethod": "fadeIn",
        "hideMethod": "fadeOut"
    }
    if (validOption.errorMessage != "") {
        toastr.error(validOption.errorMessage, jsTranslate('Error_6613'));
    } else {
        toastr.error(jsTranslate('NotAllFieldsAreFilled'), jsTranslate('Error_6613'));
    }
}

function ShowSuccessToastr(validOption) {
    var editForm = validOption.form;
    editForm.show();
    toastr.options = {
        "closeButton": true,
        "debug": false,
        "positionClass": "toast-top-left",
        "onclick": null,
        "showDuration": "1000",
        "hideDuration": "3000",
        "timeOut": "5000",
        "extendedTimeOut": "1000",
        "showEasing": "swing",
        "hideEasing": "linear",
        "showMethod": "fadeIn",
        "hideMethod": "fadeOut"
    }
    toastr.success("ОК!", validOption.errorMessage);
}

//Глабальная переменная, для удаления
function DeleteRowPost(validOption) {
    $.post("/" + validOption.controller + "/" + validOption.action, { value: validOption.svalue }, function (data) { }).done(function (data) {
        validOption.errorMessage = jsTranslate('DeletionSuccessfull');
        ShowSuccessToastr(validOption);

        if (validOption.fadeOut != null) {
            if (validOption.fadeOut.toString().toLowerCase() == 'true') { }
            else {
                var fd = validOption.form;
                fd.fadeOut('slow');
            }
        }
        else {
            var fd = validOption.form;
            fd.fadeOut('slow');
        }
    }).error(function (jqXHR, textStatus, errorThrown) {
        validOption.errorMessage = jqXHR.responseText;
        ShowErrorToastr(validOption);
        //alert("Во время редактирования возникла ошибка: " + jqXHR.responseText);
        console.log("jqXHR: " + jqXHR);
        console.log("textStatus: " + textStatus);
        console.log("errorThrown: " + errorThrown);
    });
}

function EditRowButtons(rowId) {
    return '<div class="btn-group"> ' +
        ' <button data-toggle="dropdown" type="button" class="btn blue btn-sm dropdown-toggle">' + jsTranslate('Act') + '<i class="icon-angle-down"></i></button> ' +
        ' <ul role="menu" class="dropdown-menu" style="text-align:left"> ' +
        '     <li><a href="#" onclick="GetModalWindowForEditandPopulate(' + rowId + ', this)" class="edit-button">' + jsTranslate('Edit') + '</a></li> ' +
        '     <li><a href="#" onclick="DeleteRow(' + rowId + ', this)" class="delete-button">' + jsTranslate('Delete') + '</a></li> ' +
        '  </ul> ' +
        '</div>';
}

function EditRowButtonsMS(rowId) {
    return '<div class="btn-group"> ' +
        ' <button data-toggle="dropdown" type="button" class="btn blue btn-sm dropdown-toggle">Дейтсвие<i class="icon-angle-down"></i></button> ' +
        ' <ul role="menu" class="dropdown-menu" style="text-align:left"> ' +
        '     <li><a href="#" onclick="GetModalWindowForEditandPopulate(' + rowId + ', this)" class="edit-button">' + jsTranslate('Edit') + '</a></li> ' +
        '     <li><a href="#" onclick="Confirm(' + rowId + ', this)" class="delete-button">' + jsTranslate('Confirm') + '</a></li> ' +
        '     <li><a href="#" onclick="DeleteRow(' + rowId + ', this)" class="delete-button">' + jsTranslate('Delete') + '</a></li> ' +
        '  </ul> ' +
        '</div>';
}

function getFormData($form) {
    var unindexed_array = $form.serializeArray();
    var indexed_array = {};
    var datePattern = /(\d{2})\.(\d{2})\.(\d{4})/;
    $.map(unindexed_array, function (n, i) {
        if (datePattern.test(n['value'])) {
            indexed_array[n['name']] = new Date(n['value'].replace(datePattern, '$3-$2-$1'));
        } else {
            indexed_array[n['name']] = n['value'];
        }
    });
    return indexed_array;
}
function convertJsonDate2(value) {
    var a;
    if (typeof value === 'string') {
        a = /\/Date\((\d*)\)\//.exec(value);
        if (a) {
            var dx = new Date(+a[1]);
            var dd = dx.getDate();
            var mm = dx.getMonth() + 1;
            var yy = dx.getFullYear();

            if (dd <= 9) {
                dd = "0" + dd;
            }
            if (mm <= 9) {
                mm = "0" + mm;
            }
            return dd + "." + mm + "." + yy;
        }
    }
    return value;
}

function convertJsonDate(date) {
    if (date == null)
        return "";
    var dx = new Date(date.match(/\d+/)[0] * 1);
    //Console.log();
    var dd = dx.getDate();
    var mm = dx.getMonth() + 1;
    var yy = dx.getFullYear();

    if (dd <= 9) {
        dd = "0" + dd;
    }
    if (mm <= 9) {
        mm = "0" + mm;
    }
    return dd + "." + mm + "." + yy;
}

jQuery(document).ready(function () {
    Metronic.init(); // init metronic core components
    // Layout.init(); // init current layout
});

jQuery.fn.populate = function (g, h) {
    function parseJSON(a, b) { b = b || ''; if (a == undefined) { } else if (a.constructor == Object) { for (var c in a) { var d = b + (b == '' ? c : '[' + c + ']'); parseJSON(a[c], d) } } else if (a.constructor == Array) { for (var i = 0; i < a.length; i++) { var e = h.useIndices ? i : ''; e = h.phpNaming ? '[' + e + ']' : e; var d = b + e; parseJSON(a[i], d) } } else { if (k[b] == undefined) { k[b] = a } else if (k[b].constructor != Array) { k[b] = [k[b], a] } else { k[b].push(a) } } }; function debug(a) { if (window.console && console.log) { console.log(a) } } function getElementName(a) { if (!h.phpNaming) { a = a.replace(/\[\]$/, '') } return a } function populateElement(a, b, c) { var d = h.identifier == 'id' ? '#' + b : '[' + h.identifier + '="' + b + '"]'; var e = jQuery(d, a); c = c.toString(); c = c == 'null' ? '' : c; e.html(c) } function populateFormElement(a, b, c) {
        var b = getElementName(b); var d = a[b]; if (d == undefined) { d = jQuery('#' + b, a); if (d) { d.html(c); return true } if (h.debug) { debug('No such element as ' + b) } return false } if (h.debug) { _populate.elements.push(d) } elements = d.type == undefined && d.length ? d : [d]; for (var e = 0; e < elements.length; e++) {
            var d = elements[e];
            if (!d || typeof d == 'undefined' || typeof d == 'function') { continue }

            switch (d.type || d.tagName) {
                case 'radio': d.checked = (d.value != '' && c.toString() == d.value);
                case 'checkbox': var f = c.constructor == Array ? c : [c]; for (var j = 0; j < f.length; j++) { d.checked |= d.value == f[j] } break;
                case 'select-multiple': var f = c.constructor == Array ? c : [c]; for (var i = 0; i < d.options.length; i++) { for (var j = 0; j < f.length; j++) { d.options[i].selected |= d.options[i].value == f[j] } } break;
                case 'select': case 'select-one':
                    {
                        d.value = c.toString() || c;

                        var str = $('#' + d.id);
                        if (str.attr("class") != null && str.attr("class") != "") {
                            //console.log(str.attr("class").indexOf('select2me'));
                            if (str.attr("class").indexOf('populate2') > 0) {
                                console.log(d.id + " / " + c.toString());
                                $('#' + d.id).select2("val", c.toString());
                            }

                        }
                    } break;
                case 'text': case 'button': case 'textarea': case 'submit': default: c = c == null ? '' : c;
                    //for date json  Sergey

                    if (typeof c === 'string' && /\/Date\((\d*)\)\//.test(c)) {
                        a = /\/Date\((\d*)\)\//.exec(c);
                        if (a) {
                            $(d).parent(".date-picker").datepicker("setDate", new Date(+a[1]));
                        }
                    } else {
                        d.value = c;
                    }
                //-----------------
            }
        }
    } if (g === undefined) { return this }; var h = jQuery.extend({ phpNaming: true, phpIndices: false, resetForm: true, identifier: 'id', debug: false }, h); if (h.phpIndices) { h.phpNaming = true } var k = []; parseJSON(g); if (h.debug) { _populate = { arr: k, obj: g, elements: [] } } this.each(function () { var a = this.tagName.toLowerCase(); var b = a == 'form' ? populateFormElement : populateElement; if (a == 'form' && h.resetForm) { this.reset() } for (var i in k) { b(this, i, k[i]) } }); return this
};

jQuery.fn.dataTableExt.oApi.fnReloadAjax = function (oSettings, sNewSource, fnCallback, bStandingRedraw) {
    // DataTables 1.10 compatibility - if 1.10 then `versionCheck` exists.
    // 1.10's API has ajax reloading built in, so we use those abilities
    // directly.
    if (jQuery.fn.dataTable.versionCheck) {
        var api = new jQuery.fn.dataTable.Api(oSettings);

        if (sNewSource) {
            api.ajax.url(sNewSource).load(fnCallback, !bStandingRedraw);
        }
        else {
            api.ajax.reload(fnCallback, !bStandingRedraw);
        }
        return;
    }

    if (sNewSource !== undefined && sNewSource !== null) {
        oSettings.sAjaxSource = sNewSource;
    }

    // Server-side processing should just call fnDraw
    if (oSettings.oFeatures.bServerSide) {
        this.fnDraw();
        return;
    }

    this.oApi._fnProcessingDisplay(oSettings, true);
    var that = this;
    var iStart = oSettings._iDisplayStart;
    var aData = [];

    this.oApi._fnServerParams(oSettings, aData);

    oSettings.fnServerData.call(oSettings.oInstance, oSettings.sAjaxSource, aData, function (json) {
        /* Clear the old information from the table */
        that.oApi._fnClearTable(oSettings);

        /* Got the data - add it to the table */
        var aData = (oSettings.sAjaxDataProp !== "") ?
            that.oApi._fnGetObjectDataFn(oSettings.sAjaxDataProp)(json) : json;

        for (var i = 0; i < aData.length; i++) {
            that.oApi._fnAddData(oSettings, aData[i]);
        }

        oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();

        that.fnDraw();

        if (bStandingRedraw === true) {
            oSettings._iDisplayStart = iStart;
            that.oApi._fnCalculateEnd(oSettings);
            that.fnDraw(false);
        }

        that.oApi._fnProcessingDisplay(oSettings, false);

        /* Callback user function - for event handlers etc */
        if (typeof fnCallback == 'function' && fnCallback !== null) {
            fnCallback(oSettings);
        }
    }, oSettings);
};

/////////////////////////////////////////////////////////////
function SetSelect2(oname, val, text, path, minlen, allowClear, multiple, searchResult) {
    $("#" + oname).append('<option value="' + val + '" selected>' + text + '</option>');

    $("#" + oname).select2({
        dropdownCssClass: 'bigdrop',
        ajax: {
            url: path,
            dataType: 'json',
            delay: 250,
            data: function (params) {
                return {
                    name: params.term, // search term
                    searchId: searchResult != null ? searchResult.searchId : null
                };
            },
            processResults: function (data, params) {
                return {
                    results: data
                };
            },
            cache: true
        },
        placeholder: '',
        allowClear: allowClear,
        multiple: multiple,
        escapeMarkup: function (markup) { return markup; }, // let our custom formatter work
        minimumInputLength: minlen,
        templateResult: formatRepo,
        templateSelection: formatRepoSelection
    });

    $("#select2-" + oname + "-container").html(text);
}
function selectFormatResult(data) {


    return '<table><tr><td><p style="padding-bottom:0px; margin:0px;">' + data.UserName + '</p><p style="color:#A7B6C0; font-size:10px;">' + data.Title + '</p></td></tr></table>';
}
function formatRepo(item) {
    if (item.loading) {
        return jsTranslate('Loading_6554');
    }
    var markup = "<div class='select2-result-repository clearfix'>" + item.name + "</div>";
    return markup;
}

function formatRepoSelection(item) {
    return item.name;
}

function OpenCommentModal(urlSaveComment, documentId) {

    $("#EditDialogComment_DocumentId").val(documentId);
    $("#EditDialogComment_Url").val(urlSaveComment);

    $("#EditDialogComment_Comment").val($(".EditComment_" + documentId).html());
    $("#EditDialogComment_Comment").focus();
    $("#modal_EditDialogComment").modal();

}

function SaveCommentModal() {

    var documentId = $("#EditDialogComment_DocumentId").val();
    var url = $("#EditDialogComment_Url").val();
    var commentText = $("#EditDialogComment_Comment").val();

    $.ajax({
        url: url,
        type: 'POST',
        contentType: 'application/json;',
        data: JSON.stringify({ documentId: documentId, comment: commentText }),
        success: function (data) {
            $("#modal_EditDialogComment").modal("hide");
            $(".EditComment_" + documentId).html(commentText);
        },
        error: function () {
        }
    });

}

var delay = (function () {
    var timer = 0;
    return function (callback, ms) {
        clearTimeout(timer);
        timer = setTimeout(callback, ms);
    };
})();

function convertToFloat(value) {
    try {
        return parseFloat(value.replace(new RegExp(',', 'g'), '.'));
    }
    catch (err) {
        return 0;
    }

}