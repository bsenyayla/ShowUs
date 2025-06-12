<%@ Page Language="C#" AutoEventWireup="true" Inherits="Login" Codebehind="Login.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style type="text/css">
        .x-label-icon-rev .x-label-icon
        {
            height: 11px;
        }
        .xlogo-right
        {
            padding-left: 350px !important;
        }
    </style>
</head>
<body style="background-image: url(images/desktop.jpg)">
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:Hidden ID="lblMessage" runat="server" />
    <rx:Hidden ID="question" Value="Şifre Değiştirilecektir. Emin misiniz?" runat="server" />
    <rx:KeyMap runat="server" ID="KeyMap1">
        <rx:KeyBinding>
            <Keys>
                <rx:Key Code="ENTER">
                    <Listeners>
                        <Event Handler="btnLogin.click(e);" />
                    </Listeners>
                </rx:Key>
            </Keys>
        </rx:KeyBinding>
    </rx:KeyMap>
    <div runat="server" id="Flags">
        <table style="width: 100%">
            <tr>
                <td align="center">
                    <table>
                        <tr runat="server" id="FlagsTr">
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
    <rx:Window runat="server" Width="500" Height="295" ID="PnlWindow" Closable="false"
        Shadow="false" Animate="true" CenterOnResize="true" Maximizable="false" CenterOnLoad="true"
        Dragable="false" Resizable="false">
        <Body>
            <rx:PanelX runat="server" ID="pnlx" AutoWidth="true" AutoHeight="Auto" Height="210"
                Frame="false" Border="false">
                <Body>
                    <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="100%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="RowLayout1" RowStyle="margin-right:3px;">
                                <Body>
                                    <rx:Label ID="CompanyLogo" ImageWidth="200" ImageHeight="200" runat="server" CustomCss="xlogo-right">
                                    </rx:Label>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout7">
                                <Body>
                                    <rx:Label ID="Label2" runat="server">
                                    </rx:Label>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout2" RowStyle="margin-left:5px;">
                                <Body>
                                    <rx:TextField FieldLabel="Kullanıcı Adı" runat="server" ID="txtUsername" Width="100" RequirementLevel="BusinessRequired">
                                    </rx:TextField>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout3" RowStyle="margin-left:5px;">
                                <Body>
                                    <rx:TextField FType="Password" FieldLabel="Şifre" runat="server" ID="txtPassword"
                                        Width="100" />
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout9" RowStyle="margin-left:5px;">
                                <Body>
                                    <rx:Label runat="server" ID="Reminder" Icon="UserTick" Text="Şifremi Unuttum!">
                                        <Listeners>
                                            <Click Handler="RWindow.setUrl('ResetPassword.aspx?ID='+txtUsername.getValue()); RWindow.show();" />
                                        </Listeners>
                                    </rx:Label>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout4" Align="Right" RowStyle="margin:0px 5px;">
                                <Body>
                                    <rx:Button ID="btnLogin" runat="server" Text="Giriş" Icon="Accept" Width="100">
                                        <AjaxEvents>
                                            <Click OnEvent="BtnLoginClick">
                                                <EventMask ShowMask="true" Msg="Kontrol Ediliyor..." />
                                            </Click>
                                        </AjaxEvents>
                                    </rx:Button>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                </Body>
            </rx:PanelX>
        </Body>
    </rx:Window>
    <rx:Window runat="server" Width="430" Height="160" ID="RWindow" Title="" CloseEsc="true" Modal="true"
        ShowOnLoad="false" Dragable="false" CloseAction="Hide" Minimizable="false" Maximizable="false"
        Closable="true" CenterOnLoad="true" Icon="UserTick" WindowMode="Frame" Url="about:blank">
    </rx:Window>
    </form>
</body>
</html>

<script language="javascript">
    document.onload = checkVersion();
    function getInternetExplorerVersion() {
        var rv = -1; // Return value assumes failure.
        if (navigator.appName == 'Microsoft Internet Explorer') {
            var ua = navigator.userAgent;
            var re = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
            if (re.exec(ua) != null)
                rv = parseFloat(RegExp.$1);
        }
        return rv;
    }
    function checkVersion() {
        var msg = "";
        var ver = getInternetExplorerVersion();
        if (ver > -1) {
            if (ver >= 8.0) {
                var dmode = parseFloat(document.documentMode);

                if (parseInt(dmode) != parseInt(ver)) {
                    msg = "You should use same Explorer Document Mode and Explorer version. Please check documentation.";
                }
            }
            else {
                var ua = navigator.userAgent;
                var re = new RegExp("Trident");
                if (re.exec(ua) == null) {
                    msg = "You should upgrade your copy of Internet Explorer to 8 or higher.";
                }
            }
        }
        if (msg != "") {
            alert(msg);
            window.document.location = GetWebAppRoot + "/Isv/Tu/Helps/helpLogin.aspx";
        }
    }
</script>