<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Coretech.Crm.Web.CrmPages.Admin.Administrations.User.Dashboard" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../../../ISV/TU/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ISV/TU/fonts/css/font-awesome.css" rel="stylesheet" />
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/r/bs-3.3.5/jq-2.1.4,dt-1.10.8/datatables.min.css" />
    <script src="../../../../js/jquery.min.js"></script>
    <script src="../../../../ISV/TU/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/r/bs-3.3.5/jqc-1.11.3,dt-1.10.8/datatables.min.js"></script>
    <script type='text/javascript'>

        function NewWindow() {
            $body = $("body");
            $body.addClass("loading");
            var config = "/isv/tu/transfer/TransferMain.aspx";
            window.top.newWindowRefleX(config, { maximized: true, title: 'Gönderim İşlemleri', width: 1200, height: 750, resizable: false });
            $body.removeClass("loading");
        }

        $(function () {
            $.ajax({
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json',
                url: 'Dashboard.aspx/GetHomePageParameters',
                data: '{}',
                success: function (response) {
                    debugger;
                    var res = response.d.split(";");
                    //document.getElementById("FREQUENTLY_USED_TRANSACTIONS").innerHTML = res[0];
                    //document.getElementById("DAILY_UPT_CHARTS").innerHTML = res[6];
                    var input = document.getElementById("txtTransferTuRef");
                    input.placeholder = res[3];
                    document.getElementById("btnExternalPoolFind").innerHTML = res[4];
                    document.getElementById("btnPaymentProcess").innerHTML = res[5];
                    document.getElementById("BtnTransferText").innerHTML = res[1];
                    document.getElementById("BtnPaymentText").innerHTML = res[2];
                },
            });
        })

        function ShowPayment(paymentId, refundPaymentId) {


            var New_Payment = '201100075';
            var New_RefundPayment = '201200025';

            var objectId = New_Payment;

            var pId = paymentId;
            var rId = refundPaymentId;
            if (pId !== "00000000-0000-0000-0000-000000000000" || rId !== "00000000-0000-0000-0000-000000000000") {
                var w = null;
                if (top.R.WindowMng.getActiveWindow() != 0)
                    w = top.R.WindowMng.getActiveWindow();
                if (rId !== "00000000-0000-0000-0000-000000000000") {
                    objectId = New_RefundPayment;
                    Qstring = "/ISV/TU/Refund/RefundPayment/RefundPaymentMain.aspx?defaulteditpageid="
                        + "&ObjectId=" + objectId
                        + "&mode=1"
                        + "&rlistframename=" + window.name
                        + "&PoolId=7"
                        + "&recid=" + rId;

                    window.top.newWindowRefleX(Qstring, { maximized: false, width: 1000, height: 600, resizable: true, modal: true, maximizable: true });
                }

                if (pId !== "00000000-0000-0000-0000-000000000000") {
                    window.top.ShowEditWindow(null, pId, null, objectId);
                }

                if (w != null)
                    w.hide();
            }
        }

        function DisplayPaymentTool() {
            document.getElementById("BtnPayment").style.display = "none";
            document.getElementById("txtTransferTuRef").style.display = "block";
            document.getElementById("btnPaymentProcess").style.display = "block";
            document.getElementById("btnExternalPoolFind").style.display = "block";
        }

        function PaymentExternalPoolCheck() {
            var referance = document.getElementById("txtTransferTuRef").value;
            if (referance == "") {
                // Backend-e göndermem gerekiyordu. JQuery de mesajları translate etmek gerekiyor.
                referance = 0;
            }

            $body = $("body");
            var params = '{referenceNumber:' + referance + '}';
            $(function () {
                $body.addClass("loading");
                $.ajax({
                    type: 'POST',
                    dataType: 'json',
                    contentType: 'application/json',
                    url: 'Dashboard.aspx/PaymentExternalPoolCheck',
                    data: params,
                    success: function (response) {
                        $body.removeClass("loading");
                        var message = response.d.replace('<br />', '\n').replace('<br />', '\n');
                        alert(message);
                    },
                    error: function () {
                        $body.removeClass("loading");

                    }
                });
            })
        }

        function CreatePayment() {

            $body = $("body");
            var referance = document.getElementById("txtTransferTuRef").value;
            if (referance == "") {
                // Backend-e göndermem gerekiyordu. JQuery de mesajları translate etmek gerekiyor.
                referance = 0;
            }
            var params = '{referenceNumber:"' + referance + '", isUsedSecurityQuestion:true}';
            $(function () {
                $body.addClass("loading");
                $.ajax({
                    type: 'POST',
                    dataType: 'json',
                    contentType: 'application/json',
                    url: 'Dashboard.aspx/CreatePayment',
                    data: params,
                    success: function (response) {

                        if (response.d.IsSuccess) {
                            $body.removeClass("loading");
                            ShowPayment(response.d.PaymentId, response.d.RefundPaymentId)
                        }
                        else {
                            $body.removeClass("loading");
                            alert(response.d.Message.replace('<br />', '\n').replace('<br />', '\n'));
                            //$body.removeClass("loading");
                            //document.getElementById("modalHeader").className = "modal-header bg-danger";

                            //$("#myModal").modal();

                        }
                    },

                    error: function () {
                        $body.removeClass("loading");

                    }
                });
            })
        }

        function AnnouncementDetail(announcementId) {

            //var objectId = "202000053";

            var rId = announcementId;

            if (top.R.WindowMng.getActiveWindow() != 0)
                w = top.R.WindowMng.getActiveWindow();

            if (rId !== "00000000-0000-0000-0000-000000000000") {

                Qstring = "/ISV/TU/Announcement/AnnouncementDetailForm.aspx?"
                    //+ "&ObjectId=" + objectId
                    //+ "&mode=1"
                    + "recid=" + rId;

                window.top.newWindowRefleX(Qstring, { maximized: false, width: 1200, height: 800, resizable: true, modal: true, maximizable: true });
            }
        }

        $(document).ready(function () {
            $('#example').DataTable({
                "paging": true,
                "ordering": false,
                "language": {
                    "search": "Filter"
                },
                "lengthMenu": [[5, 10, 20, -1], [5, 10, 20, "All"]],
                "pagingType": "full_numbers"
            });
        });

    </script>
    <style>
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            top: 0;
            left: 0;
            height: 100%;
            width: 100%;
            background: rgba( 255, 255, 255, .8 ) url('../../../../images/Dashboard/loader.gif') 50% 50% no-repeat;
        }

        /* When the body has the loading class, we turn
   the scrollbar off with overflow:hidden */
        body.loading .modal {
            overflow: hidden;
        }

        /* Anytime the body has the loading class, our
   modal element will be visible */
        body.loading .modal {
            display: block;
        }

        .centered {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 28px;
        }

        .buttonText {
            position: relative;
            text-align: center;
            color: white;
        }
    </style>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnEntityId" runat="server" />
        <asp:HiddenField ID="hdnRecid" runat="server" />
        <asp:HiddenField ID="hdnTransferId" runat="server" />
        <asp:HiddenField ID="hdnPaymentId" runat="server" />
        <asp:HiddenField ID="hdnrefundPaymentId" runat="server" />
        <asp:HiddenField ID="new_IsUsedSecurityQuestion" runat="server" />
        <asp:HiddenField ID="hdnViewList" runat="server" />
        <asp:HiddenField ID="hdnViewDefaultEditPage" runat="server" />

        <div id="MainAnnouncement" class="container text-center" runat="server"></div>
        <br />

        <div class="text-center container">



            <div class="row">
                <div class="col-md-6">
                    <img src="../../../../images/Dashboard/GondermeImage.png" style="height: 200px; width: 250px; margin-bottom: 10px" onclick="NewWindow();" />
                    <div class="buttonText">
                        <img class="btn" src="../../../../images/Dashboard/GodermeButton.png" onclick="NewWindow();" />
                        <div id="BtnTransferText" class="centered" onclick="NewWindow();">Gönderme İşlemleri</div>
                    </div>
                </div>
                <div class="col-md-6">
                    <img src="../../../../images/Dashboard/OdemeImage.png" style="margin-top: 20px; margin-bottom: 25px" />
                    <div class="buttonText">
                        <img id="BtnPayment" class="btn " src="../../../../images/Dashboard/OdemeButton.png" onclick="DisplayPaymentTool();" />
                        <div id="BtnPaymentText" class="centered" onclick="DisplayPaymentTool();">Ödeme İşlemleri</div>
                    </div>
                    <input id="txtTransferTuRef" type="text" autocomplete="off" autofocus style="text-align: center; margin-bottom: 10px; margin-top: 15px; font-size: x-large; border-radius: 25px; display: none" class="form-control" id="usr" placeholder="işlem numarası giriniz..">

                    <div class="row">
                        <div class="col-md-8">
                            <button id="btnExternalPoolFind" type="button" onclick="PaymentExternalPoolCheck();" class="btn btn-danger" style="display: none; width: 360px; border-radius: 25px">Kurum Havuzunda Ara</button>

                        </div>

                        <div class="col-md-4">
                            <button id="btnPaymentProcess" onclick="CreatePayment();" type="button" class="btn btn-success" style="display: none; width: 165px; border-radius: 25px">İşlemi Öde</button>
                        </div>
                    </div>
                </div>
            </div>


        </div>
        <br />
        <div class="container">

            <div id="Grid" runat="server" class="right_col" role="main">
            </div>
        </div>

        <div class="modal" id="loading"></div>

        <!-- Modal -->
        <div class="modal fade" id="myModal" role="dialog">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div id="modalHeader" class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">Ödeme İşlemleri</h4>
                    </div>
                    <div class="modal-body">
                        <p id="ModalBodyMessage"></p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Kapat</button>
                    </div>
                </div>
            </div>
        </div>
    </form>

</body>

</html>
