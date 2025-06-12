<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPasswordConfirm.aspx.cs" Inherits="Coretech.Crm.Web.ResetPasswordConfirm" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <rx:RegisterResources runat="server" ID="RR" />
            <rx:PanelX runat="server" ID="pnlx" AutoWidth="true" AutoHeight="Auto" Height="210"
                Padding="true" Frame="false" Border="false">
                <Body>
                    <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="100%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="RowLayout2" RowStyle="margin-right:3px;">
                                <Body>
                                    <rx:Label ID="lblInformation" runat="server"></rx:Label>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout4" RowStyle="margin-right:3px;">
                                <Body>
                                    <br />
                                    <br />
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout3" RowStyle="margin-left:5px;">
                                <Body>
                                    <rx:TextField FieldLabel="Kullanıcı Adı" runat="server" ID="txtUsername" Width="100" Disabled="true">
                                    </rx:TextField>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout1" RowStyle="margin-right:3px;">
                                <Body>
                                    <rx:TextField FieldLabel="Aktivasyon Kodu" runat="server" ID="txtActivationCode" Width="200">
                                    </rx:TextField>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout6" RowStyle="margin-right:3px;">
                                <Body>
                                    <br />
                                    <br />
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout5" RowStyle="margin-right:3px;">
                                <Body>
                                    <rx:ToolBar ID="toolBar1" runat="server">
                                        <Items>
                                            <rx:ToolbarFill ID="ToolbarFill" runat="server"></rx:ToolbarFill>
                                            <rx:Button ID="btnFinish" runat="server" Text="İşlemi Onayla" Icon="Accept" Width="100" ClearFloat="true">
                                                <AjaxEvents>
                                                    <Click OnEvent="BtnFinishClick">
                                                        <EventMask ShowMask="true" Msg="Kontrol Ediliyor..." />
                                                    </Click>
                                                </AjaxEvents>
                                            </rx:Button>
                                        </Items>
                                    </rx:ToolBar>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                </Body>
            </rx:PanelX>
        </div>
    </form>
</body>
</html>
