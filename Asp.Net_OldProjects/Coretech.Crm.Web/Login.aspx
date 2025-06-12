<%@ Page Language="C#" AutoEventWireup="true" Inherits="Coretech_Login" CodeBehind="Login.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .x-label-icon-rev .x-label-icon {
            height: 11px;
        }

        .xlogo-right {
            padding-left: 170px !important;
        }
    </style>
    <script src="js/IeVersion.js?<%=App.Params.AppVersion %>"></script>
</head>
<body style="background-image: url(images/desktop.jpg?v1); background-size:cover;">
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
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
        <rx:Window runat="server" Width="485" Height="295" ID="PnlWindow" Closable="false" MinLeft="1000"
            Shadow="false" Animate="true" Maximizable="false" 
            Dragable="true">
            <Body>
                <rx:PanelX runat="server" ID="pnlx" AutoWidth="true" AutoHeight="Auto" Height="210"
                    Frame="false" Border="false">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="100%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout1" RowStyle="margin-right:3px;">
                                    <Body>
                                        <rx:Label ID="CompanyLogo" ImageWidth="120" ImageHeight="80" runat="server" ImageUrl="images/Company/upt.png?v1" >
                                        </rx:Label>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout7">
                                    <Body>
                                        <rx:Label ID="Label2" runat="server" Text="">

                                        </rx:Label>
                                        <br />
                                        <br />
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout2" RowStyle="margin-left:5px;">
                                    <Body>
                                        <rx:TextField FieldLabel="Kullanıcı Adı" runat="server" ID="txtUsername" Width="100">
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
                                        <br />
                                        <br />
                                        <br />
                                    </Body>
                                </rx:RowLayout>
                                <%--                                <rx:RowLayout runat="server" ID="RowLayout4" Align="Right" RowStyle="margin:0px 5px;">
                                    <Body>
                                        <rx:Button ID="btnLogin" runat="server" Text="Giriş" Icon="Accept" Width="100">
                                            <AjaxEvents>
                                                <Click OnEvent="BtnLoginClick">
                                                    <EventMask ShowMask="true" Msg="Kontrol Ediliyor..." />
                                                </Click>
                                            </AjaxEvents>
                                        </rx:Button>
                                    </Body>
                                </rx:RowLayout>--%>
                            </Rows>
                        </rx:ColumnLayout>

                        <rx:ToolBar ID="toolBar1" runat="server">
                            <Items>
                                <rx:Button ID="BtnReminder" runat="server" Icon="UserTick" Text="Şifremi Unuttum">
                                    <Listeners>
                                        <Click Handler="RWindow.setUrl('ResetPassword.aspx?ID='+txtUsername.getValue()); RWindow.show();" />
                                    </Listeners>
                                </rx:Button>
                                <rx:ToolbarFill ID="ToolbarFill" runat="server"></rx:ToolbarFill>
                                <rx:Button ID="btnLogin" runat="server" Text="Giriş" Icon="Accept">
                                    <AjaxEvents>
                                        <Click OnEvent="BtnLoginClick" >
                                            <EventMask ShowMask="true" Msg="Kontrol Ediliyor..." />
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Items>
                        </rx:ToolBar>
                    </Body>
                </rx:PanelX>
            </Body>
        </rx:Window>
        <rx:Window runat="server" Width="430" Height="250" ID="RWindow" Title="" CloseEsc="true"
            Modal="true" ShowOnLoad="false" Dragable="false" CloseAction="Hide" Minimizable="false"
            Maximizable="false" Closable="true" CenterOnLoad="true" Icon="UserTick" WindowMode="Frame"
            Url="about:blank">
        </rx:Window>
    </form>
</body>
</html>

<script language="javascript">
    document.onload = checkVersion();
</script>
