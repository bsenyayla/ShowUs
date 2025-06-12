<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TransferMaster.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Transfer.TransferMaster" %>

<!DOCTYPE html>
<meta name="viewport" content="width=device-width">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">

    <title></title>
    <link href="../../../../ISV/TU/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ISV/TU/fonts/css/font-awesome.css" rel="stylesheet" />
    <script src="//code.jquery.com/jquery-1.11.1.min.js"></script>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.js"></script>


    <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/css/select2.min.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/js/select2.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {

            var navListItems = $('div.setup-panel div a'),
                    allWells = $('.setup-content'),
                    allNextBtn = $('.nextBtn');

            allWells.hide();

            navListItems.click(function (e) {
                e.preventDefault();
                var $target = $($(this).attr('href')),
                        $item = $(this);

                if (!$item.hasClass('disabled')) {
                    navListItems.removeClass('btn-primary').addClass('btn-default');
                    $item.addClass('btn-primary');
                    allWells.hide();
                    $target.show();
                    $target.find('input:eq(0)').focus();
                }
            });

            allNextBtn.click(function () {
                var curStep = $(this).closest(".setup-content"),
                    curStepBtn = curStep.attr("id"),
                    nextStepWizard = $('div.setup-panel div a[href="#' + curStepBtn + '"]').parent().next().children("a"),
                    curInputs = curStep.find("input[type='text'],input[type='url']"),
                    isValid = true;

                $(".form-group").removeClass("has-error");
                for (var i = 0; i < curInputs.length; i++) {
                    if (!curInputs[i].validity.valid) {
                        isValid = false;
                        $(curInputs[i]).closest(".form-group").addClass("has-error");
                    }
                }

                if (isValid)
                    nextStepWizard.removeAttr('disabled').trigger('click');
            });

            $('div.setup-panel div a.btn-primary').trigger('click');
        });
    </script>
    <style>
        body {
            margin-top: 40px;
            font-family: "Averta","Avenir W02","Avenir",Helvetica,Arial,sans-serif;
            font-size: 15px;
            line-height: 24px;
            color: #5d7079;
            background-color: #fff;
            position: relative;
        }


        .stepwizard-step p {
            margin-top: 10px;
        }

        .stepwizard-row {
            display: table-row;
        }

        .stepwizard {
            display: table;
            width: 100%;
            position: relative;
        }

        .stepwizard-step button[disabled] {
            opacity: 1 !important;
            filter: alpha(opacity=100) !important;
        }

        .stepwizard-row:before {
            top: 14px;
            bottom: 0;
            position: absolute;
            content: " ";
            width: 100%;
            height: 1px;
            background-color: #ccc;
            z-order: 0;
        }

        .stepwizard-step {
            display: table-cell;
            text-align: center;
            position: relative;
        }

        .btn-circle {
            width: 30px;
            height: 30px;
            text-align: center;
            padding: 6px 0;
            font-size: 12px;
            line-height: 1.428571429;
            border-radius: 15px;
        }





        .wrapper {
            padding-bottom: 0;
        }

        .currency-selector {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            padding-left: .5rem;
            border: 0;
            background: transparent;
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
            background: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='1024' height='640'><path d='M1017 68L541 626q-11 12-26 12t-26-12L13 68Q-3 49 6 24.5T39 0h952q24 0 33 24.5t-7 43.5z'></path></svg>") 90%/12px 6px no-repeat;
            font-family: inherit;
            color: inherit;
        }

        .currency-amount {
            text-align: right;
        }

        .currency-addon {
            width: 6em;
            text-align: left;
            position: relative;
        }

        .card-counter {
            border: solid 1px #CCCCCC;
            margin: 5px;
            padding: 0px 10px;
            background-color: #fff;
            height: 100px;
            border-radius: 5px;
            transition: .3s linear all;
        }

        .card-title {
            color: #A0A0A0;
        }
    </style>
</head>
<body>

    <div class="container">

        <div class="stepwizard">
            <div class="stepwizard-row setup-panel">
                <div class="stepwizard-step">
                    <a href="#step-1" type="button" class="btn btn-primary btn-circle">1</a>
                    <p>İşlem Bilgileri</p>
                </div>
                <div class="stepwizard-step">
                    <a href="#step-2" type="button" class="btn btn-default btn-circle" disabled="disabled">2</a>
                    <p>Gönderici Bilgileri</p>
                </div>
                <div class="stepwizard-step">
                    <a href="#step-3" type="button" class="btn btn-default btn-circle" disabled="disabled">3</a>
                    <p>Alıcı Bilgileri</p>
                </div>
            </div>
        </div>
        <form role="form" id="form1" runat="server">


            <div class="row setup-content" id="step-1">
                <div class="col-xs-12">
                    <h3>İşlem Bilgileri</h3>
                    <hr />
                    <div class="col-md-6">

                        <div class="form-group">


                            <label class="control-label">Alıcı Ülke</label>

                            <select id="mySelect" class="form-control" data-live-search="true" data-size="5">
                                <option>Rusya</option>
                                <option>Ukrayna</option>
                            </select>


                        </div>

                        <div class="form-group">
                            <label class="control-label">Gönderim Türü</label>
                            <select id="mySelect4" class="form-control" data-live-search="true" data-size="5">
                                <option>İsme Gönderim</option>
                                <option>Hesaba Gönderim</option>
                                <option>Aktifbank Ödemesi</option>


                            </select>

                        </div>

                        <div class="form-group">


                            <label class="control-label">İşlem Tutarı</label>

                            <div class="wrapper">
                                <form class="form-inline">
                                    <label class="sr-only" for="inlineFormInputGroup">Amount</label>
                                    <div class="input-group mb-2 mr-sm-2 mb-sm-0">
                                        <div class="input-group-addon currency-symbol">$</div>
                                        <input type="text" class="form-control currency-amount" id="inlineFormInputGroup" placeholder="0.00" size="8">
                                        <div class="input-group-addon currency-addon">

                                            <select class="currency-selector">
                                                <option data-symbol="$" data-placeholder="0.00" selected>USD</option>
                                                <option data-symbol="€" data-placeholder="0.00">EUR</option>
                                                <option data-symbol="£" data-placeholder="0.00">GBP</option>
                                                <option data-symbol="¥" data-placeholder="0">JPY</option>
                                                <option data-symbol="$" data-placeholder="0.00">CAD</option>
                                                <option data-symbol="$" data-placeholder="0.00">AUD</option>
                                            </select>

                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>






                    </div>
                    <div class="col-md-6">
                        <div class="form-group">


                            <label class="control-label">Alıcı Kurum</label>

                            <select id="mySelect3" class="form-control" data-live-search="true" data-size="5">
                                <option>Golden Crown</option>
                                <option>Intel Express</option>
                                <option>Moneytrans</option>
                                <option>Tranglo</option>
                                <option>Xpress Money</option>

                            </select>

                        </div>

                        <div class="form-group">


                            <label class="control-label">Tahsilat Türü</label>

                            <select id="mySelect5" class="form-control" data-live-search="true" data-size="5">
                                <option>Hesaptan Gönderim</option>
                                <option>Nakit Tahsilat</option>

                            </select>

                        </div>


                    </div>




                </div>
                <div class="col-xs-12">
                                        <div class="form-group">

                        <button id="BtnPaymentPoint" class="btn btn-success">Ödeme Noktaları</button>
                    </div>
                    </div>
                <button class="btn btn-primary nextBtn  pull-right" type="button">Sonraki</button>
            </div>
            <div class="row setup-content" id="step-2">
                <div class="col-xs-12">
                    <h3>Gönderici Bilgileri</h3>
                    <hr />
                    <div class="col-md-6">

                        <div class="form-group">
                            <label class="control-label">Gönderici</label>
                            <select id="mySelect6" class="form-control" data-live-search="true" data-size="5">
                                <option>Eda Selçuk Apaydın</option>
                                <option>Akif Selcuk Kenger</option>
                            </select>
                        </div>


                    </div>
                    <div class="col-md-6">
                    </div>
                </div>

                <button class="btn btn-primary nextBtn btn-lg pull-right" type="button">Next</button>
            </div>
            <div class="row setup-content" id="step-3">
                <div class="col-xs-12">
                    <div class="col-md-12">
                        <h3>Step 3</h3>
                        <button class="btn btn-success btn-lg pull-right" type="submit">Finish!</button>
                    </div>
                </div>
            </div>


        </form>
    </div>
    <script type="text/javascript">
        //$("#mySelect").select2();
        //$("#mySelect2").select2();

        function updateSymbol(e) {
            var selected = $(".currency-selector option:selected");
            $(".currency-symbol").text(selected.data("symbol"))
            $(".currency-amount").prop("placeholder", selected.data("placeholder"))
            $('.currency-addon-fixed').text(selected.text())
        }

        $(".currency-selector").on("change", updateSymbol)

        //updateSymbol()
    </script>
</body>
</html>
