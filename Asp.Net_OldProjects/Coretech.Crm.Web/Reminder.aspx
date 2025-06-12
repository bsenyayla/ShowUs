<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reminder" Codebehind="Reminder.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:PanelX runat="server" ID="pnlx" AutoWidth="true" AutoHeight="Auto" Height="210"
            Padding="true" Frame="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="100%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout1" RowStyle="margin-right:3px;">
                            <Body>
                                <rx:TextField FieldLabel="Kullanıcı Adı" runat="server" ID="txtUsername" Width="200">
                                </rx:TextField>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2" RowStyle="margin-right:3px;">
                            <Body>
                                <rx:TextField FieldLabel="Güvenlik Sorusu" runat="server" ID="txtQuestion" Width="200"
                                    ReadOnly="true">
                                </rx:TextField>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout3" RowStyle="margin-right:3px;">
                            <Body>
                                <rx:TextField FieldLabel="Güvenlik Cevabı" runat="server" ID="txtAnswer" Width="200" CaseType="UpperCaseAlphabetic"
                                    ReadOnly="false">
                                </rx:TextField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
                <rx:Button ID="btnLogin" runat="server" Text="Giriş" Icon="Accept" Width="100" ClearFloat="true">
                    <AjaxEvents>
                        <Click OnEvent="BtnLoginClick">
                            <EventMask ShowMask="true" Msg="Kontrol Ediliyor..." />
                        </Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
    </form>
</body>
</html>
