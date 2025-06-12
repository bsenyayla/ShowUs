<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_EditRefleX" Async="true"
    ValidateRequest="false" Codebehind="EditRefleX.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>

<%@ Import Namespace="Coretech.Crm.Utility.Util" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../js/DuplicateDetection.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <style type="text/css">
        #loading-mask
        {
            position: absolute;
            top: 0;
            left: 0;
            width: 99%;
            height: 99%;
            z-index: 70000;
            background: #c8cbd0;
            opacity: <%=Otheropacity%>;
            -moz-opacity: <%=Otheropacity%>;
            filter: alpha(opacity=<%=Ieopacity%>);
            border: 0;
            font-family: tahoma,arial,verdana,sans-serif;
            font-size: 11px;
            font-weight: bold;
        }
        #loading
        {
            position: absolute;
            top: 40%;
            left: 45%;
            z-index: 70001;
        }
        #loading SPAN
        {
            color: white;
            font-family: Arial;
            font-size: small;
            background: url('<%=GlobalConfig.Settings.ResourcePath%>/Themes/Slate/Images/loading.gif') no-repeat left center;
            padding: 5px 30px;
            display: block;
        }
        .fixed-toolbar
        {
            position: fixed !important;
            top: 0px;
            width: 96%;
            z-index: 8999;
        }
        .fixed-label
        {
            position: absolute;
            top: 0px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="display: none" runat="server" id="ScriptIframe">
        </div>
        <div id="loading-mask">
            <div id="loading">
                <span id="loading-message"></span>
            </div>
        </div>
        <ajx:RegisterResources runat="server" ID="RR" />
        <ajx:TabPanel runat="server" ID="Tabpanel1" AutoHeight="Auto" AutoWidth="true">
            <Tabs>
                <ajx:Tab runat="server" ID="FirstTab" TabMode="Div" Url="" Title="..." Closeable="false">
                    <Body>
                    </Body>
                </ajx:Tab>
            </Tabs>
            <Listeners>
                <TabClose Handler="return TabCloseControl(el,e);" />
            </Listeners>
        </ajx:TabPanel>
        <div style="display: none">
            <ajx:Hidden runat="server" ID="RedirectType" Value="1">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnObjectId">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnEntityName">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnEntityId">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnRecid">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnApprovalRecordId">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnRecidName">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnDefaultEditPageId">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnSavingMessage">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="FetchXML">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="UpdatedUrl">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnDDAction">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnDDParentAction">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnTitle">
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
        <ajx:KeyMap runat="server" ID="KeyMap2">
            <ajx:KeyBinding StopEvent="false">
                <Keys>
                    <ajx:Key Code="BACKSPACE">
                        <Listeners>
                            <Event Handler="stopRKey(e);" />
                        </Listeners>
                    </ajx:Key>
                </Keys>
            </ajx:KeyBinding>
        </ajx:KeyMap>
        <ajx:KeyMap runat="server" ID="KeyMap3">
            <ajx:KeyBinding StopEvent="false">
                <Keys>
                    <ajx:Key Code="ENTER">
                        <Listeners>
                            <Event Handler="stopRKey(e);" />
                        </Listeners>
                    </ajx:Key>
                </Keys>
            </ajx:KeyBinding>
        </ajx:KeyMap>
        <div runat="server" id="Container" class="Crm-container ">
            <ajx:ToolBar runat="server" ID="EditToolbar" CustomCss="fixed-toolbar">
                <Items>
                    <ajx:ToolbarButton runat="server" ID="btnActive" Width="100" Text="Active" Icon="PlayGreen">
                        <AjaxEvents>
                            <Click OnEvent="BtnActiveClick">
                                <EventMask ShowMask="true" />
                                <ExtraParams>
                                    <ajx:Parameter Name="Action" Value="hdnDDAction.getValue();" Mode="Raw"></ajx:Parameter>
                                    <ajx:Parameter Name="ParentAction" Value="hdnDDParentAction.getValue();" Mode="Raw"></ajx:Parameter>
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                    <ajx:Label runat="server" Text="" ID="lblError" Icon="Information" Width="200" ForeColor="WhiteSmoke">
                    </ajx:Label>
                    <ajx:ToolbarButton runat="server" ID="btnMlValues" Width="0" Text="OpenMultipleLanguage"
                        Icon="FlagTr">
                        <Listeners>
                            <Click Handler="OpenMultipleLanguage()" />
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="btnSave" Width="70" Text="Save" Icon="Disk">
                        <AjaxEvents>
                            <Click OnEvent="BtnSaveClick">
                                <EventMask ShowMask="true" />
                                <ExtraParams>
                                    <ajx:Parameter Name="Action" Value="1"></ajx:Parameter>
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="btnSaveAndNew" Width="120" Text="Save And New"
                        Icon="DiskMultiple">
                        <AjaxEvents>
                            <Click OnEvent="BtnSaveClick">
                                <EventMask ShowMask="true" />
                                <ExtraParams>
                                    <ajx:Parameter Name="Action" Value="2"></ajx:Parameter>
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
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
                    <ajx:ToolbarButton runat="server" ID="btnSaveAsCopy" Width="120" Text="Save As Copy"
                        Icon="PageCopy">
                        <AjaxEvents>
                            <Click OnEvent="BtnSaveClick">
                                <EventMask ShowMask="true" />
                                <ExtraParams>
                                    <ajx:Parameter Name="Action" Value="4"></ajx:Parameter>
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="btnDDSave" Width="120" Text="Save As Copy"
                        Hidden="true" Icon="PageCopy">
                        <AjaxEvents>
                            <Click OnEvent="BtnSaveClick">
                                <EventMask ShowMask="true" />
                                <ExtraParams>
                                    <ajx:Parameter Name="Action" Value="hdnDDAction.getValue();" Mode="Raw"></ajx:Parameter>
                                    <ajx:Parameter Name="ParentAction" Value="hdnDDParentAction.getValue();" Mode="Raw"></ajx:Parameter>
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="btnDelete" Width="100" Text="Delete" Icon="Delete">
                        <Listeners>
                            <Click Handler="BtnDelete_Click()" />
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="btnPassive" Width="100" Text="Passive" Icon="PauseBlue">
                        <AjaxEvents>
                            <Click OnEvent="BtnPassiveClick">
                                <EventMask ShowMask="true" />
                                <ExtraParams>
                                    <ajx:Parameter Name="Action" Value="hdnDDAction.getValue();" Mode="Raw"></ajx:Parameter>
                                    <ajx:Parameter Name="ParentAction" Value="hdnDDParentAction.getValue();" Mode="Raw"></ajx:Parameter>
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                    <ajx:Menu ID="ReportMenu" runat="server">
                        <Items>
                        </Items>
                    </ajx:Menu>
                    <ajx:Menu ID="ActionMenu" runat="server">
                        <Items>
                        </Items>
                    </ajx:Menu>
                    <ajx:ToolbarFill runat="server" ID="ToolbarFill1">
                    </ajx:ToolbarFill>
                    <ajx:ToolbarButton runat="server" ID="btnReport" minwidth="70" Icon="ArrowDown" Text="Report"
                        MenuId="ReportMenu">
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="btnAction" minwidth="70" Icon="ArrowDown" Text="Action"
                        MenuClickType="Full" MenuId="ActionMenu">
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" Icon="ArrowRefresh" Width="100" ID="btnRefresh"
                        Text="Refresh">
                        <Listeners>
                            <Click Handler="location.reload(true);" />
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:Label ID="lblInfo" runat="server" Icon="Information" Width="20">
                        <Listeners>
                            <Click Handler="ShowPageInfo();" />
                        </Listeners>
                    </ajx:Label>
                </Items>
            </ajx:ToolBar>
            <div runat="server" id="MessageBar" style="display:none">
            </div>
            <ajx:PanelX runat="server" ID="PnlMain" Frame="false" Border="false" AutoHeight="Full"
                AutoWidth="true">
            </ajx:PanelX>
            <div runat="server" id="Related" class="Crm-container ">
            </div>
        </div>
    </form>
</body>
<script language="javascript" type="text/javascript">
    function OpenServerSideWindow(e, u, type) {
        var _a = eval(e);
        var _ret = eval(u).getValue();
        var _type = eval(type).getValue();
        if (_type == "0") {
            window.open(_ret);
        }
        else if (_type == "1") {

            window.top.newWindowRefleX(GetWebAppRoot + _ret
            , { maximized: false, width: 500, height: 300, resizable: false, modal: true, maximizable: false });
        }
        else if (_type == "2") {

            window.top.newWindowRefleX(GetWebAppRoot + _ret
            , { maximized: false, width: 800, height: 400, resizable: false, modal: true, maximizable: false });
        }
    }
    function BtnDelete_Click() {
        Myform = window;
        try {
            window.top.GlobalDelete(Myform, null, hdnObjectId.getValue());
        } catch (e) {
            if (confirm(GetMessages("CRM_RECORD_WILL_DELETE_ARE_YOU_SURE"))) {
                var result = AjaxMethods.GlobalDelete("", hdnRecid.getValue(), hdnObjectId.getValue()).value
                if (result.Result == "0") {
                    alert(result.ErrorMessage);
                } else {
                    RefreshParetnGrid(true);
                }
            }
        }
    }
</script>
</html>