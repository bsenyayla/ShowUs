<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_Detail_Transfer3rdErrorContinue" Codebehind="_Transfer3rdErrorContinue.aspx.cs" %>

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
                <rx:ToolbarButton runat="server" ID="ToolbarButtonLog" Text="CRM.MENU.LOG" Icon="Zoom"
                    Width="100">
                    <Listeners>
                        <Click Handler="LogWindow();" />
                    </Listeners>
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="ToolbarButtonMd" Text="CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING_DETAIL"
                    Icon="ControlBlank" Width="100">
                    <Listeners>
                        <Click Handler="ShowMonitoringDetailLite();" />
                    </Listeners>
                </rx:ToolbarButton>
                 <rx:ToolbarButton runat="server" ID="ToolbarButtonTalimat" Text="CRM.NEW_TRANSFER_TALIMAT_FORMU"
                    Icon="Printer" Width="100">
                    <Listeners>
                        <Click Handler="ShowInstruction();" />
                    </Listeners>
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="ToolbarButtonSend" Text="CRM.NEW_TRANSFER_SENDTOCONFIRM"
                    Icon="Accept" Width="100">
                    <AjaxEvents>
                        <Click OnEvent="ToolbarButtonSendOnEvent">
                            <EventMask ShowMask="true" Msg="Confirming..." />
                        </Click>
                    </AjaxEvents>
                </rx:ToolbarButton>
            </Items>
        </rx:ToolBar>
    </form>
</body>
</html>
<script language="javascript">
    function ShowInstruction() {
        if (hdnReportId.getValue() != "")
            window.top.ShowReport(hdnReportId.getValue(), hdnRecid.getValue(), "&doExport=1&OpenInWindow=1", false);
    }

</script>