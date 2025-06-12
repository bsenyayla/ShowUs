<%@ Page Language="C#" AutoEventWireup="true" Inherits="Transfer_Marketing" CodeBehind="Marketing.aspx.cs" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />

        <rx:Fieldset runat="server" Title="İleti Yönetim Sistemi İzin Durumu" ID="fieldsetMarketing">
            <Body>
                <rx:ColumnLayout ID="column111" runat="server">
                    <Rows>
                        <rx:RowLayout ID="RowLayout9" runat="server">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout31" ColumnWidth="25%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout10" runat="server">
                                            <Body>
                                                <rx:CheckField ID="checkMesaj" runat="server" FieldLabel="MESAJ"></rx:CheckField>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>

                                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="30%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout11" runat="server">
                                            <Body>
                                                <rx:CheckField ID="checkArama" runat="server" FieldLabel="ARAMA"></rx:CheckField>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="30%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout12" runat="server">
                                            <Body>
                                                <rx:CheckField ID="checkEposta" runat="server" FieldLabel="E-POSTA"></rx:CheckField>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="15%">
                                    <Rows>
                                        <rx:RowLayout ID="row123" runat="server">
                                            <Body>
                                                <rx:Button ID="BtnContinue" runat="server" Text="Onayla" Icon="Accept">
                                                    <AjaxEvents>
                                                        <Click OnEvent="btnMarketingPermission"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>


    </form>
</body>
</html>

