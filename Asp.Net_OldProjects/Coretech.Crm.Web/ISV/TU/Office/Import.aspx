<%@ Page Language="C#" AutoEventWireup="true" Inherits="Office_Import" EnableViewState="true" Codebehind="Import.aspx.cs" %>

<!DOCTYPE html>

<html lang="en">

<head runat="server">
    <title></title>

    <link href="../css/bootstrap.min.css" rel="stylesheet" />
    <link href="../fonts/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../css/custom.css" rel="stylesheet" />
    <script type="text/javascript">
        function BeginProcess() {
            var iframe = document.createElement("iframe");
            iframe.src = "LongRunningProcess.aspx?Path=" + hdnPath.value;
            iframe.style.display = "none";
            document.body.appendChild(iframe);
        }
        function UpdateProgress(PercentComplete, Message, errorMessage) {
            document.getElementById('trigger').value = PercentComplete + Message;

            if (errorMessage != '') {
                $("#ErrorList").append(errorMessage);
            }

            if (Message.indexOf("Ofis Bitti") >= 0) {
                $('#ErrorListPanel').show();
                document.getElementById('trigger').value = "Ofis Bitti"
            }

            if (Message.indexOf("Kullanıcılar Bitti") >= 0) {
                $('#ErrorListPanel').show();
                document.getElementById('trigger').value = "Kullanıcılar Bitti"
            }

            if (Message.indexOf("Hesaplar Bitti") >= 0) {
                $('#ErrorListPanel').show();
                document.getElementById('trigger').value = "Hesaplar Bitti"
            }

            if (Message.indexOf("Islem Tipi Bitti") >= 0) {
                $('#ErrorListPanel').show();
                document.getElementById('trigger').value = "İslem Tipi Bitti"
            }

            if (Message.indexOf("Rapor Bitti") >= 0) {
                $('#ErrorListPanel').show();
                document.getElementById('trigger').value = "Rapor Bitti"
            }
        }

        function MessagePanel(message) {
            $('#popupForm').modal('toggle');
            $('#MessagePanelText').html(message);

        }
    </script>
    <style>
        .btn-file {
            position: relative;
            overflow: hidden;
        }

            .btn-file input[type=file] {
                position: absolute;
                top: 0;
                right: 0;
                min-width: 100%;
                min-height: 100%;
                font-size: 100px;
                text-align: right;
                filter: alpha(opacity=0);
                opacity: 0;
                outline: none;
                background: white;
                cursor: inherit;
                display: block;
            }

        table {
            border: 1px solid #ddd;
            border-collapse: collapse;
            width: 100%;
        }

        th, td {
            text-align: left;
            padding: 8px;
        }



        th {
            background-color: #4CAF50;
            color: white;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="row">
            <div class="center">
                <div class="container body">
                    <div class="main_container">
                        <div id="popupForm" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="gridSystemModalLabel">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                                        <h4 class="modal-title" id="gridSystemModalLabel"><i class="fa fa-envelope"></i>1 Adet Bildirim Var</h4>
                                    </div>
                                    <div id="MessagePanelText" class="modal-body">
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-default" data-dismiss="modal">Kapat</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="">
                            <div class="row">
                                <div class="col-md-12 col-sm-12 col-xs-12">
                                    <div class="x_panel">
                                        <div class="x_content">
                                            <div class="x_title h4"><b><i class="fa fa-cubes"></i>&nbsp;Bayi Data Aktarım Ekranı</b></div>
                                            <br />
                                            <div id="wizard" class="form_wizard wizard_horizontal">
                                                <ul class="wizard_steps">
                                                    <li>
                                                        <a href="#step-1">
                                                            <span class="step_no">1</span>
                                                            <span class="step_descr"><i class="fa fa-upload"></i>&nbsp;Yükle<br />
                                                                <small>Seçili dosyayı yükleyiniz</small>
                                                            </span>
                                                        </a>
                                                    </li>
                                                    <li>
                                                        <a href="#step-2">
                                                            <span class="step_no">2</span>
                                                            <span class="step_descr"><i class="fa fa-bolt"></i>&nbsp;Aktarım<br />
                                                                <small>Yüklenmiş olan datayı aktarınız</small>
                                                            </span>
                                                        </a>
                                                    </li>
                                                </ul>
                                                <br />
                                                <br />
                                                <div id="step-1">
                                                    <div id="wrapperStep1" style="vertical-align: middle; text-align: center;">
                                                        <div style="display: inline-block; width: 30%">
                                                            <p id="Step2Info" runat="server" />
                                                            <asp:HiddenField ID="hdnPath" runat="server" />
                                                            Yükleme işlemine başlamak için<br>
                                                            Lütfen önce <b>Dosya Seç</b> me işlemini gerçekleştiriniz ve ardından <b>Seçili Dosyayı Yükle</b> butonuna basınız.
                                                            <br />
                                                            <br />
                                                            <br />
                                                            <br />
                                                            <div class="editor-label">
                                                                <div class="input-group">
                                                                    <span class="input-group-btn">
                                                                        <span class="btn btn-primary btn-file"><i class="fa fa-folder-open"></i>Dosya Seç
                                                                            <input type="file" id="FileUpload1">
                                                                        </span>
                                                                    </span>

                                                                    <input type="text" id="valdfil" class="form-control" />
                                                                </div>
                                                            </div>
                                                            <br />
                                                            <br />
                                                            <asp:Button ID="Button1" class="btn btn-group-sm btn-success" runat="server" Text="Seçili Dosyayı Yükle" />
                                                        </div>
                                                    </div>
                                                </div>
                                                <div id="step-2">
                                                    <div id="Div1" style="vertical-align: middle; text-align: center;">
                                                        <div style="display: inline-block; width: 30%">
                                                            Yüklemiş olduğunuz dosya <b id="filePath"></b>aktarımı tamamlamak için <i class="fa fa-bolt"></i>&nbsp; <b>[Aktar]</b> butonuna basınız.
                                                            <br />
                                                            <br />
                                                            <input type="submit" class="btn btn-group-sm btn-success" value="Aktar"
                                                                id="trigger" onclick="BeginProcess(); return false;"
                                                                style="width: 250px;" />
                                                        </div>
                                                    </div>
                                                    <br />
                                                    <br />
                                                </div>
                                            </div>
                                            <div id="ErrorListPanel" class="x_panel">
                                                <div class="x_title">
                                                    <h2>Aktarım Hataları <small></small></h2>
                                                    <ul class="nav navbar-right panel_toolbox">
                                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                                        </li>
                                                        <li class="dropdown">
                                                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><i class="fa fa-wrench"></i></a>
                                                        </li>
                                                        <li><a class="close-link"><i class="fa fa-close"></i></a>
                                                        </li>
                                                    </ul>
                                                    <div class="clearfix"></div>
                                                </div>
                                                <div class="x_content" style="display: none">
                                                    <ul id="ErrorList" class="list-unstyled timeline">
                                                    </ul>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <script src="../js/jquery-2.0.0.js"></script>
                        <script src="../js/bootstrap.min.js"></script>
                        <script src="../js/nicescroll/jquery.nicescroll.min.js"></script>
                        <script src="../js/custom.js"></script>
                        <script src="../js/wizard/jquery.smartWizard.js"></script>
                        <script type="text/javascript">
                            $(document).ready(function () {
                                $("#Button1").click(function (evt) {
                                    MessagePanel('<strong>Tebrikler <br /><br /><i class="fa fa-check"></i> Dosya Başarıyla Yüklendi.<strong/>');
                                    document.getElementById('Button1').disabled = true;
                                    document.getElementById('Button1').blur();

                                    var fileUpload = $("#FileUpload1").get(0);
                                    var files = fileUpload.files;

                                    var data = new FormData();
                                    for (var i = 0; i < files.length; i++) {
                                        data.append(files[i].name, files[i]);
                                    }

                                    var options = {};
                                    options.url = "Handler/FileUpload.ashx";
                                    options.type = "POST";
                                    options.data = data;
                                    options.contentType = false;
                                    options.processData = false;
                                    options.success = function (result) {
                                        hdnPath.value = result;
                                    };
                                    options.error = function (err) { alert(err.statusText); };

                                    $.ajax(options);

                                    evt.preventDefault();
                                });
                            });

                            $(document).ready(function () {
                                $('#ErrorListPanel').hide();
                                $('#successAlert').hide();
                                // Smart Wizard         
                                $('#wizard').smartWizard({
                                    onLeaveStep: leaveAStepCallback,
                                    onFinish: onFinishCallback,
                                    labelNext: 'İleri',
                                    labelPrevious: 'Geri',
                                    labelFinish: 'Tamamla',
                                });
                                function leaveAStepCallback(obj, context) {

                                    return validateSteps(context.fromStep); // return false to stay on step and true to continue navigation 
                                }
                                function onFinishCallback(objs, context) {
                                    if (validateAllSteps()) {
                                        $('form').submit();
                                    }
                                }
                                function validateSteps(stepnumber) {
                                    var isStepValid = true;
                                    if (stepnumber == 1) {
                                        $("#filePath").html(hdnPath.value);
                                        return isStepValid;
                                    }
                                    if (stepnumber == 2) {
                                        isStepValid = true;
                                        return isStepValid;
                                    }
                                    if (stepnumber == 3) {
                                        isStepValid = true;
                                        return isStepValid;
                                    }
                                }
                                function validateAllSteps() {
                                    var isStepValid = true;
                                    return isStepValid;
                                }
                                function disableNextButton() {
                                    var $actionBar = $('.actionBar');
                                    $('.buttonNext', $actionBar).addClass('buttonDisabled').off("click");
                                }
                                function enableNextButton() {
                                    var $actionBar = $('.actionBar');
                                    $('.buttonNext', $actionBar).removeClass('buttonDisabled');
                                }
                            });
                            $(document).ready(function () {
                                $('#wizard').smartWizard();

                                function onFinishCallback() {
                                    $('#wizard').smartWizard('showMessage', 'Finish Clicked');
                                    alert('Finish Clicked');
                                }
                            });
                        </script>
                        <script type="text/javascript">
                            $(document).ready(function () {
                                $(document).on('change', '.btn-file :file', function () {
                                    var input = $(this),
                                        numFiles = input.get(0).files ? input.get(0).files.length : 1,
                                        label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
                                    input.trigger('fileselect', [numFiles, label]);
                                });
                                $('.btn-file :file').on('fileselect', function (event, numFiles, label) {
                                    console.log(numFiles);
                                    console.log(label);
                                    $("#valdfil").val(label);
                                });
                            });
                        </script>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
