<%@ Page Language="C#" AutoEventWireup="true" Inherits="Sender_SenderCDDRejectDescription" CodeBehind="SenderCDDRejectDescription.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title></title>

</head>
<body>
    <form id="form1" runat="server">

        <rx:RegisterResources runat="server" ID="RR" />

        <rx:Fieldset runat="server" ID="FieldsetSenderInfo" AutoHeight="Normal" Height="150" AutoWidth="true"
            Collapsible="false" Border="false" Title="" CustomCss="Section1">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="100%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout12">
                            <Body>
                                <cc1:CrmTextAreaComp runat="server" ID="new_Description" ObjectId="202000007" UniqueName="new_Description" Height="60" Width="200"></cc1:CrmTextAreaComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout20">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="30%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout3">
                                            <Body>
 
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="30%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout1">
                                            <Body>
                                                <rx:Button runat="server" ID="btnReject" Text="Reddet" Icon="Decline" Width="110">
                                                    <AjaxEvents>
                                                        <Click OnEvent="btnRejectClick">
                                                        </Click>
                                                    </AjaxEvents>
                                                </rx:Button>

                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>

                                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="30%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout2">
                                            <Body>
                                                <rx:Button runat="server" ID="btnApprove" Text="Onayla" Icon="Accept" Width="110">
                                                    <AjaxEvents>
                                                        <Click OnEvent="btnAcceptClick">
                                                        </Click>
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
