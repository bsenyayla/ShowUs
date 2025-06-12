<%@ Page Language="C#" AutoEventWireup="true" Inherits="IntegrationLocation" Codebehind="IntegrationLocation.aspx.cs" %>

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
                                <rx:FileUpload ID="fuLocation" runat="server" FieldLabel="Bölgesel Dosya" MaxLength="2147483647"></rx:FileUpload>

                            </Body>
                        </rx:RowLayout>


                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
                <rx:Button ID="btnLogin" runat="server" Text="Bölgesel Aktar" Icon="Accept" Width="100" ClearFloat="true">
                    <AjaxEvents>
                        <Click OnEvent="BtnEnterClick">
                            <EventMask ShowMask="true" Msg="Kontrol Ediliyor..." />
                        </Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
    </form>
</body>
</html>
