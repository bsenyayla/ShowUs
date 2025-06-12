<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OtpControlForm.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.CustAccount.Pool.OtpControlForm" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="//code.jquery.com/jquery-1.10.2.js"></script>
    <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
    <%--<script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>--%>
    <script src="../Js/OtpControl.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script>
        $(document).ready(function () {
            var clickButton = document.getElementById("<%=btnSendOtp.ClientID%>");
            clickButton.style.display = "none";
            $("#pnllbl_pnlMain").after("<br/><span id='showtime' style='margin-left:40%;font-size: medium; color: red'> 03:00 </span>");
            var header = $(".x-unselectable")[0];
            header.style.height = "35px";
            SetElement(clickButton);
            setTimeout(CountdownFunction, 1000);
        });

        if (parent.document.getElementsByClassName("x-tool-close") != null && parent.document.getElementsByClassName("x-tool-close").length > 0) {
            var btncls = parent.document.getElementsByClassName("x-tool-close")[parent.document.getElementsByClassName("x-tool-close").length - 1];
            if (btncls != null) {
                btncls.style.display = "none";
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="hdnSenderId" runat="server"></rx:Hidden>
        <rx:Hidden ID="hdnSenderpersonId" runat="server"></rx:Hidden>
        <rx:Hidden ID="hdnSenderPhone" runat="server"></rx:Hidden>
        <rx:Hidden ID="hdnCustAccountType" runat="server"></rx:Hidden>
        <div>
            <rx:PanelX runat="server" ID="pnlMain" Title="Müşterinin cep telefonuna gönderilen 6 haneli doğrulama kodunu giriniz.">
                <Body>

                    <rx:PanelX ID="pnl2" runat="server" ContainerPadding="true" Padding="true" Border="false">
                        <Body>

                            <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="100%" BorderStyle="None">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout5" runat="server">
                                        <Body>
                                            <rx:TextField ID="senderOtpCode" runat="server" AutoWidth="true" FieldLabel="Otp Kodu">
                                            </rx:TextField>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                            <br />
                            <%--<div style="padding-left: 87%; font-size: large; color: red" id="showtime"></div>
                            <br />--%>
                        </Body>
                    </rx:PanelX>
                </Body>
                <Buttons>
                    <rx:Button ID="btnSendOtp" runat="server" Text="Yeniden Kod Gönder" Icon="ArrowRefresh">
                        <AjaxEvents>
                            <Click OnEvent="btnSendOtp_Click"></Click>
                        </AjaxEvents>
                    </rx:Button>
                    <rx:Button ID="BtnContinue" runat="server" Text="Devam" Icon="Accept">
                        <AjaxEvents>
                            <Click OnEvent="btnContinue_Click" Success="hide();" Before="CrmValidateForm(msg,e);"></Click>
                        </AjaxEvents>
                    </rx:Button>
                </Buttons>
            </rx:PanelX>
        </div>
    </form>
</body>
</html>
