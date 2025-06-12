<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_Edit"
    ValidateRequest="false" ViewStateMode="Enabled" EnableViewState="True" Codebehind="Edit.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .x-form-Lookup
        {
            padding-top: 2px; /* FF won't center the text vertically */
            padding-bottom: 0;
            cursor: hand;
        }
        div.botright
        {
            display: block;
            position: absolute;
            bottom: 0;
            right: 0;
            width: 105px;
            height: 105px;
            background: #eee;
            border: 1px solid #ddd;
        }
        
        HTML, BODY
        {
            height: 100%;
        }
        #loading-mask
        {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: #000000;
            z-index: 1;
        }
        #loading
        {
            position: absolute;
            top: 40%;
            left: 45%;
            z-index: 2;
        }
        #loading SPAN
        {
            color: white;
            font-family: Arial;
            font-size: small;
            background: url('../../images/loader.gif') no-repeat left center;
            padding: 5px 30px;
            display: block;
        }
        .x-form-ellipsis-trigger
        {
            background-image: url("../../images/elp-trigger.gif") !important;
            cursor: pointer;
        }
        .CrmLabel
        {
            overflow: hidden;
            -o-text-overflow: ellipsis;
            text-overflow: ellipsis;
            padding: 3px 3px 3px 5px;
            white-space: nowrap;
            font:11px arial, tahoma, helvetica, sans-serif;
        }
    </style>
    <script language="javascript" type="text/javascript">
        var vyukseklik = 0;
        var pyukseklik = 0;
        var Oran = 0;
        var ReleatedTabPanel = null;
        var EditFormListNames = new Array();
        function CheckListName() {
            //alert(EditFormListNames.length)
            for (var i = 0; i < EditFormListNames.length; i++) {
                var L = eval(EditFormListNames[i] + "name");
                var T = eval(EditFormListNames[i] + "values");
                if (L.getValues().length != "")
                    T.setValue(Ext.encode(L.getValues()));
            }
        }

        function fsetSize() {
            if (ReleatedTabPanel == null)
                return;
            if (vyukseklik != 0 && pyukseklik != 0) {
                Oran = vyukseklik / pyukseklik;
                if (vyukseklik != VPort.getSize().height) {
                    ReleatedTabPanel.setHeight(VPort.getSize().height / Oran);
                    PnlMain.setHeight(VPort.getSize().height - ReleatedTabPanel.getHeight());
                    ReleatedTabPanel.setPosition(0, VPort.getSize().height - ReleatedTabPanel.getHeight());
                }
            }
            vyukseklik = VPort.getSize().height;
            pyukseklik = ReleatedTabPanel.getHeight();
        }
        function BtnDelete_Click() {
            Myform = window;
            window.top.GlobalDelete(Myform, null, hdnObjectId.getValue())
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div id="loading-mask">
    </div>
    <div id="loading">
        <span id="loading-message">Yükleniyor. Lütfen Bekleyiniz...</span>
    </div>
    <div style="display: none">
        <ext:Hidden runat="server" ID="hdnObjectId">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnEntityName">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnEntityId">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnRecid">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnRecidName">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnDefaultEditPageId">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnSavingMessage">
        </ext:Hidden>
        <ext:Hidden ID="FetchXML" runat="server">
        </ext:Hidden>
        <ext:Hidden ID="UpdatedUrl" runat="server">
        </ext:Hidden>
    </div>
    <ext:KeyMap ID="KeyMap1" runat="server" Target="={Ext.getDoc()}">
        <ext:KeyBinding StopEvent="true" Ctrl="true">
            <Keys>
                <ext:Key Code="S" />
            </Keys>
            <Listeners>
                <Event Handler="#{btnSave}.fireEvent('click');" />
            </Listeners>
        </ext:KeyBinding>
        <ext:KeyBinding StopEvent="true" Ctrl="true">
            <Keys>
                <ext:Key Code="N" />
            </Keys>
            <Listeners>
                <Event Handler="#{btnSaveAndNew}.fireEvent('click');" />
            </Listeners>
        </ext:KeyBinding>
        <ext:KeyBinding StopEvent="true" Ctrl="true">
            <Keys>
                <ext:Key Code="Q" />
            </Keys>
            <Listeners>
                <Event Handler="#{btnSaveAndClose}.fireEvent('click');" />
            </Listeners>
        </ext:KeyBinding>
    </ext:KeyMap>
    <ext:ViewPort runat="server" HideBorders="true" ID="VPort">
        <Body>
            <ext:BorderLayout ID="BlMain" runat="server">
                <Center>
                    <ext:Panel runat="server" ID="PnlMain" AutoScroll="true">
                        <TopBar>
                            <ext:Toolbar ID="EditToolbar" runat="server">
                                <Items>
                                    <ext:Button runat="server" ID="btnSave" MinWidth="70" Text="Save" Icon="Disk">
                                        <AjaxEvents>
                                            <Click OnEvent="BtnSave_Click">
                                                <EventMask ShowMask="true" />
                                                <ExtraParams>
                                                    <ext:Parameter Name="Action" Value="1">
                                                    </ext:Parameter>
                                                </ExtraParams>
                                            </Click>
                                        </AjaxEvents>
                                    </ext:Button>
                                    <ext:ToolbarSeparator>
                                    </ext:ToolbarSeparator>
                                    <ext:Button runat="server" ID="btnSaveAndNew" MinWidth="70" Text="Save And New" Icon="DiskMultiple">
                                        <AjaxEvents>
                                            <Click OnEvent="BtnSave_Click">
                                                <EventMask ShowMask="true" />
                                                <ExtraParams>
                                                    <ext:Parameter Name="Action" Value="2">
                                                    </ext:Parameter>
                                                </ExtraParams>
                                            </Click>
                                        </AjaxEvents>
                                    </ext:Button>
                                    <ext:ToolbarSeparator>
                                    </ext:ToolbarSeparator>
                                    <ext:Button runat="server" ID="btnSaveAndClose" MinWidth="70" Text="Save And Close"
                                        Icon="DiskBlack">
                                        <AjaxEvents>
                                            <Click OnEvent="BtnSave_Click">
                                                <EventMask ShowMask="true" />
                                                <ExtraParams>
                                                    <ext:Parameter Name="Action" Value="3">
                                                    </ext:Parameter>
                                                </ExtraParams>
                                            </Click>
                                        </AjaxEvents>
                                    </ext:Button>
                                    <ext:ToolbarSeparator>
                                    </ext:ToolbarSeparator>
                                    <ext:Button runat="server" ID="btnDelete" MinWidth="70" Text="Delete" Icon="Delete">
                                        <Listeners>
                                            <Click Handler="BtnDelete_Click()" />
                                        </Listeners>
                                    </ext:Button>
                                    <ext:ToolbarSeparator>
                                    </ext:ToolbarSeparator>
                                    <ext:Button runat="server" ID="btnAction" MinWidth="70" Icon="ArrowDown" Text="Action">
                                        <Menu>
                                            <ext:Menu ID="ActionMenu" runat="server">
                                                <Items>
                                                </Items>
                                            </ext:Menu>
                                        </Menu>
                                    </ext:Button>
                                    <ext:ToolbarFill />
                                    <ext:Button runat="server" Icon="ArrowRefresh" MinWidth="70" ID="btnRefresh" Text="Refresh">
                                        <Listeners>
                                            <Click Handler="location.reload(true);" />
                                        </Listeners>
                                    </ext:Button>
                                </Items>
                            </ext:Toolbar>
                        </TopBar>
                        <Body>
                        </Body>
                        <Listeners>
                            <Resize Handler="fsetSize();" />
                        </Listeners>
                    </ext:Panel>
                </Center>
                <South MinHeight="100" MaxHeight="900" Split="true" Collapsible="true"  CollapseMode="Default">
                </South>
            </ext:BorderLayout>
        </Body>
    </ext:ViewPort>
    </form>
</body>
</html>

<script language=javascript>
    function OpenServerSideWindow(e, u, type) {
        var _a = eval(e);
        var _ret = eval(u).getValue();
        var _type = eval(type).getValue();
        if (_type == "0") {
            window.open(_ret); 
        }
        else if (_type == "1") {
          
            window.top.newWindow(GetWebAppRoot + _ret
            , { maximized: false, width: 500, height: 300, resizable: false, modal: true, maximizable: false });
        }
        else if (_type == "2") {

            window.top.newWindow(GetWebAppRoot + _ret
            , { maximized: false, width: 800, height: 400, resizable: false, modal: true, maximizable: false });
        }
    }
    
</script>
