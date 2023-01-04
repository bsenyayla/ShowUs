var myDropzone = new Dropzone("#modal_UploadDialog_file-dropzone", {
    url: "/AJAX/Upload?documentId=0&typeId=1035"
});
myDropzone.autoDiscover = false;
myDropzone.on("addedfile", function (file) {
    // alert(this.files[this.files.length-1].fileName);
    //if (this.files[1] != null) {
    //    this.removeFile(this.files[0]);
    //}
});
myDropzone.on("success", function (file, responseText) {
    if (ShowUploadDialog_type == 1) {
        $(".UploadDefectList_" + ShowUploadDialog_documentId).removeClass("UploadEmpty");
    } else if (ShowUploadDialog_type == 6) {
        $(".UploadMachineShopForm_" + ShowUploadDialog_documentId).removeClass("UploadEmpty");
    } else if (ShowUploadDialog_type == 2) {
        $(".UploadDefectList_" + ShowUploadDialog_documentId).removeClass("UploadEmpty");
    } else if (ShowUploadDialog_type == 7) {
        $(".UploadPhoto_" + ShowUploadDialog_documentId).removeClass("UploadEmpty");
    } else if (ShowUploadDialog_type == 99) {
        $(".UploadPhoto_" + ShowUploadDialog_documentId).removeClass("UploadEmpty");
    }
});

function RemovedFile(uploadId) {
    $.ajax({
        type: "POST",
        url: "/AJAX/RemoveUpload",
        data: { uploadId: uploadId },
        success: function (data) {
            $(this).parent().remove();
            if (data.status == "ok" && data.count == 0) {
                if (data.typeId == 1) {
                    $(".UploadDefectList_" + data.documentId).addClass("UploadEmpty");
                } else if (data.typeId == 6) {
                    $(".UploadMachineShopForm_" + data.documentId).addClass("UploadEmpty");
                } else if (data.typeId == 2) {
                    $(".UploadDefectList_" + data.documentId).addClass("UploadEmpty");
                } else if (data.typeId == 7) {
                    $(".UploadPhoto_" + data.documentId).addClass("UploadEmpty");
                } else if (data.typeId == 99) {
                    $(".UploadPricing_" + data.documentId).addClass("UploadEmpty");
                }
            }
        },
        error: myErrorFunction
    });
}

var ShowUploadDialog_documentId = 0;
var ShowUploadDialog_type = 0;
function ShowUploadDialog(documentId, type) {
    ShowUploadDialog_documentId = documentId;
    ShowUploadDialog_type = type;
    var title = "";
    if (ShowUploadDialog_type == 1) {
        title = jsTranslate('Defective_sheet');
    } else if (ShowUploadDialog_type == 2) {
        title = jsTranslate('Repair_Report');
    } else if (ShowUploadDialog_type == 6) {
        title = jsTranslate('Component_Recovery_Workshop_Documentation');
    } else if (ShowUploadDialog_type == 7) {
        title = jsTranslate('Photo');
    } else if (ShowUploadDialog_type == 17) {
        title = jsTranslate('Quotation');
    } else if (ShowUploadDialog_type == 99) {
        title = jsTranslate('Pricing');
    }
    $("#modal_UploadDialog_title").html(title);
    $("#modal_UploadDialog").modal();
    myDropzone.removeAllFiles(true);
    myDropzone.options.url = '/AJAX/Upload?documentId=' + ShowUploadDialog_documentId + "&typeId=" + ShowUploadDialog_type;
    myDropzone.options.uploadMultiple = true;
    myDropzone.options.parallelUploads= 10,
    $.ajax({
        type: "POST",
        url: "/AJAX/GetUploadsList",
        data: { documentId: ShowUploadDialog_documentId, typeId: ShowUploadDialog_type },
        success: function (data) {
            $('#UploadsList').html(data);
            cdomsPermissionCheck();
        },
        error: myErrorFunction
    });
}
function modal_UploadDialog_notApplicable() {
    var item = null;
    if (ShowUploadDialog_type == 1) {
        item = $(".UploadDefectList_" + ShowUploadDialog_documentId);
    } else if (ShowUploadDialog_type == 6) {
        item = $(".UploadMachineShopForm_" + ShowUploadDialog_documentId);
    } else if (ShowUploadDialog_type == 2) {
        item = $(".UploadDefectList_" + ShowUploadDialog_documentId);
    } else if (ShowUploadDialog_type == 7) {
        item = $(".UploadPhoto_" + ShowUploadDialog_documentId);
    } else if (ShowUploadDialog_type == 99) {
        item = $(".UploadPricing_" + ShowUploadDialog_documentId);
    }
    item.removeClass("UploadEmpty");
    item.addClass("NotApplicable");

    $.ajax({
        type: "POST",
        url: "/AJAX/UploadNotApplicable",
        data: { documentId: ShowUploadDialog_documentId, typeId: ShowUploadDialog_type },
        success: function (data) {
        },
        error: myErrorFunction
    });
}
function GetDivUpload(type, data, isUpload, isDownloadOneClick) {
    var uploadItem = null;
    var uploadName = "";
    if (type == 1) {
        uploadItem = data.UploadDefectList;
        uploadName = "UploadDefectList";
    } else if (type == 2) {
        uploadItem = data.UploadTechnicalReport;
        uploadName = "UploadTechnicalReport";
    } else if (type == 6) {
        uploadItem = data.UploadMachineShopForm;
        uploadName = "UploadMachineShopForm";
    } else if (type == 7) {
        uploadItem = data.UploadPhoto;
        uploadName = "UploadPhoto";
    } else if (type == 99) {
        uploadItem = data.UploadPricing;
        uploadName = "UploadPricing";
    }
    var title = "";
    if (uploadItem != null) {
        title = uploadItem.Name + (uploadItem.DateUpload != null ? " (" + jsTranslate('Date') + ": " + convertJsonDate2(uploadItem.DateUpload.toString()) + ")" : "") + (uploadItem.UserName != null ? " (" + jsTranslate('Added_by') + ": " + uploadItem.UserName + ") " : ")");
    }
    return "<div cdoms_perm='COUNTER_CABINET_RW' title='" + title + "' type='" + type + "' uploadId='" + (uploadItem != null ? uploadItem.UploadId : "") + "' class='UploadItem " + (isDownloadOneClick ? "UploadDownloadOneClick" : "") + " " + uploadName + "_" + data.DocumentId + " "
        + (uploadItem != null ? (uploadItem.Name == 'NotApplicable' ? "NotApplicable" : "")
            : (" UploadEmpty " + (isUpload ? "UploadNot" : "")))
        + "' documentId='" + data.DocumentId + "'></div>";
}
function SetEventUploadItemClick(woHistoryUrl) {
    $(".UploadItem").click(function () {
        var documentId = $(this).attr("documentId");
        var type = $(this).attr("type");
        if ($(this).hasClass("UploadDownloadOneClick") && !$(this).hasClass("UploadNot") && !$(this).hasClass("UploadEmpty")) {
            window.location = woHistoryUrl + "/Home/DownloadFile?uploadId=" + $(this).attr("uploadId");
        }
        //else if ($(this).hasClass("NotApplicable") || $(this).hasClass("UploadNot")) {
        //    return;
        //}
        else {
            ShowUploadDialog(documentId, type);
        }
    });
}