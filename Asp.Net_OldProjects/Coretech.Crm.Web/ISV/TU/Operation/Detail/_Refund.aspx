<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_Detail_Refund" Codebehind="_Refund.aspx.cs" %>


<%@ Import Namespace="Coretech.Crm.Factory" %>


<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:Hidden runat="server" ID="hdnObjectId">
    </rx:Hidden>
    <rx:Hidden runat="server" ID="hdnRecId">
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
            <rx:ToolbarButton runat="server" ID="ToolbarButtonRefund" Text="CRM.NEW_TRANSACTIONCONFIRM_REFUND" Icon="MoneyDelete"
                Width="100">
                <AjaxEvents>
                    <Click OnEvent="Refund">
                        <EventMask ShowMask="true" Msg="" />
                    </Click>
                </AjaxEvents>
            </rx:ToolbarButton>
        </Items>
    </rx:ToolBar>
    </form>
</body>
</html>
