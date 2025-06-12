<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_Detail_Receipt" Async="true" CodeBehind="_Receipt.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script src="Js/_Receipt.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script type="text/javascript">
        function ShowTransferDocument() {
            var config = "../ISV/TU/Transfer/TransferDocument.aspx?ObjectId=" + hdnObjectId.getValue() + "&RecordId=" + hdnRecid.getValue();
            window.top.newWindow(config, { title: 'Mobile Document', width: 800, height: 500, resizable: false });
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="hdnOnayMessage" />
        <rx:Hidden runat="server" ID="hdnEntityId">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnObjectId">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnRecid">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnReportId">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdndoReceipt">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdndoReceiptEdit">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnpoolId">
        </rx:Hidden>
        <rx:PanelX runat="server" ID="PanelIframe" AutoHeight="Normal" Height="530" Border="false"
            Frame="true">
            <AutoLoad Url="about:blank" ShowMask="true" />
            <Body>
            </Body>
        </rx:PanelX>
        <rx:ToolBar runat="server" ID="ToolBarMain">
            <Items>
                <rx:ToolbarFill runat="server" ID="tf1" />

                <rx:ToolbarButton runat="server" ID="Btn3rdDetail" Text="CRM_GET3RD_STATUS" Icon="Connect"
                    Width="100">
                    <Listeners>
                        <Click Handler="Transfer3rdDetail();" />
                    </Listeners>
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="ToolbarButtonRefund" Text="CRM.NEW_TRANSACTIONCONFIRM_REFUND" Icon="MoneyDelete" Hidden="true"
                    Width="100">
                    <AjaxEvents>
                        <Click OnEvent="Refund">
                            <EventMask ShowMask="true" Msg="" />
                        </Click>
                    </AjaxEvents>
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="ToolbarButtonEditMessage3rd" Text="CRM.NEW_TRANSFER_EDITMESESSAGE3RD"
                    Icon="MoneyDelete" Width="100">
                    <AjaxEvents>
                        <Click OnEvent="ReceiptEditMessage3rd">
                        </Click>
                    </AjaxEvents>
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="ToolbarButtonBtnRefund" Text="CRM.NEW_REFUNDTRANSFER_IADESINEBASLA"
                    Icon="MoneyDelete" Width="100">
                    <AjaxEvents>
                        <Click OnEvent="BtnRefundClick" />
                    </AjaxEvents>
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="ToolbarButtonCancel" Text="CRM.MENU.LOG" Icon="Cancel"
                    Width="100">
                    <AjaxEvents>
                        <Click OnEvent="CancelRequest" />
                    </AjaxEvents>
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="ToolbarButtonLog" Text="CRM.MENU.LOG" Icon="Zoom"
                    Width="100">
                    <Listeners>
                        <Click Handler="LogWindow();" />
                    </Listeners>
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="BtnTransferDocumentShow" Text="Mobil Döküman" Icon="Zoom"
                    Width="100">
                    <Listeners>
                        <Click Handler="ShowTransferDocument();" />
                    </Listeners>
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="ToolbarButtonMd" Text="CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING_DETAIL"
                    Icon="ControlBlank" Width="100">
                    <Listeners>
                        <Click Handler="ShowMonitoringDetailLite();" />
                    </Listeners>
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="ToolbarButtonEdit" Text="CRM.NEW_TRANSACTIONCONFIRM_RECEIPT_EDIT"
                    Icon="PageEdit" Width="100">
                    <AjaxEvents>
                        <Click OnEvent="ReceiptEdit">
                            <EventMask ShowMask="true" Msg="printing..." />
                        </Click>
                    </AjaxEvents>
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="ToolbarButtonReceipt" Text="CRM.NEW_TRANSACTIONCONFIRM_RECEIPT_PRINTING"
                    Icon="PrinterStart" Width="100">
                    <AjaxEvents>
                        <Click OnEvent="PrintReceipt">
                            <EventMask ShowMask="true" Msg="printing..." />
                        </Click>
                    </AjaxEvents>
                </rx:ToolbarButton>

            </Items>
        </rx:ToolBar>
    </form>
</body>
</html>
