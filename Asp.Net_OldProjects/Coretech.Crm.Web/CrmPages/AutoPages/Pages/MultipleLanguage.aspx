<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_AutoPages_Pages_MultipleLanguage" ValidateRequest="false" Codebehind="MultipleLanguage.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork"
    TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style>
     .trgclear
        {
            margin: 1px -1px 0 !important;
        }
        .trgclear span
        {
            cursor: pointer;
            background: url("<%=GlobalConfig.Settings.ResourcePath%>/Themes/Slate/Images/clear-trigger.gif");
            background-repeat: no-repeat;
            background-color: transparent;
            background-position: 0px -1px;
            border: 0 none;
            height: 17px !important;
            margin: 0 !important;
            padding: 0 !important;
            top: 1px !important;
            width: 16px !important;
            z-index: 2;
            border: 0 solid #B5B8C8;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR"/>
    <div style="display: none">
        <ajx:Hidden runat="server" ID="hdnObjectId">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnRecid">
        </ajx:Hidden>
    </div>
    <ajx:KeyMap runat="server" ID="KeyMap1">
        <ajx:KeyBinding StopEvent="true">
            <Keys>
                <ajx:Key Code="ESC">
                    <Listeners>
                        <Event Handler="" />
                    </Listeners>
                </ajx:Key>
            </Keys>
        </ajx:KeyBinding>
    </ajx:KeyMap>
    <ajx:ToolBar runat="server" ID="EditToolbar">
        <Items>
            <ajx:ToolbarButton runat="server" ID="btnSaveAndClose" Width="120" Text="Save And Close"
                Icon="DiskBlack">
                <AjaxEvents>
                    <Click OnEvent="BtnSaveClick">
                        <EventMask ShowMask="true" />
                        <ExtraParams>
                            <ajx:Parameter Name="Action" Value="3"></ajx:Parameter>
                        </ExtraParams>
                    </Click>
                </AjaxEvents>
            </ajx:ToolbarButton>
        </Items>
    </ajx:ToolBar>
    <ajx:PanelX runat="server" Title="Mu Language" runat="server" ID="PnlMain" AutoScroll="true">
        <Body>
        </Body>
    </ajx:PanelX>
    </form>
</body>
</html>
