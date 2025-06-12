<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Payment_WelcomeTestQuestion" Codebehind="WelcomeTestQuestion.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script src="JS/WelcomeTestQuestion.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <title></title>
    <style>
        .trgclear
        {
            margin: 1px -5px 0 !important;
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
    <rx:RegisterResources runat="server" ID="RR" />
    <rx:Hidden ID="hdnTransferId" runat="server" />
    <rx:Hidden ID="hdnUseTestQuestion" runat="server" />
    <rx:Hidden ID="hdnPaymentId" runat="server" />
    <rx:Hidden ID="hdnrefundPaymentId" runat="server" />
    
    <rx:PanelX runat="server" ID="TEST_SORUSU" AutoHeight="Normal" Height="60" Border="false"
        Title="TEST_SORUSU">
        <Body>
            <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="50%">
                <Rows>
                    <rx:RowLayout ID="RowLayout1" runat="server">
                        <Body>
                            <cc1:CrmComboComp runat="server" ID="new_TestQuestion" ObjectId="201100096" UniqueName="new_TestQuestion"
                                ReadOnly="true" FieldLabelWidth="100" Width="130" PageSize="50">
                                <Listeners>
                                    <Change Handler="" />
                                </Listeners>
                            </cc1:CrmComboComp>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ColumnLayout runat="server" ID="ColoumnLayout2" ColumnWidth="50%">
                <Rows>
                    <rx:RowLayout runat="server" ID="RowLayout2">
                        <Body>
                            <cc1:CrmTextFieldComp ID="new_TestAnswer" runat="server" ObjectId="201100096" UniqueName="new_TestAnswer"
                                FieldLabelWidth="100" Width="130" CaseType="UpperCase">
                            </cc1:CrmTextFieldComp>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
        </Body>
    </rx:PanelX>
    <rx:PanelX runat="server" ID="PanelIframe" AutoHeight="Normal" Height="200" Border="false">
        <Body>
            <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="50%">
                <Rows>
                    <rx:RowLayout ID="RowLayout5" runat="server">
                        <Body>
                            <cc1:CrmTextFieldComp runat="server" ID="new_RecipientName" ObjectId="201100072"
                                UniqueName="new_RecipientName" ReadOnly="true" FieldLabelWidth="100" Width="130"
                                Disabled="true">
                            </cc1:CrmTextFieldComp>

                            <cc1:CrmTextFieldComp runat="server" ID="new_SenderID" ObjectId="201100072"
                                UniqueName="new_SenderID" ReadOnly="true" FieldLabelWidth="100" Width="130"
                                Disabled="true">
                            </cc1:CrmTextFieldComp>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="50%">
                <Rows>
                    <rx:RowLayout runat="server" ID="RowLayout6">
                        <Body>
                            <cc1:CrmTextFieldComp ID="new_RecipientLastName" runat="server" ObjectId="201100072"
                                UniqueName="new_RecipientLastName" FieldLabelWidth="100" Width="130" CaseType="UpperCase" Disabled="true">
                            </cc1:CrmTextFieldComp>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
        </Body>
    </rx:PanelX>
    <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="60" Border="false">
        <Body>
            <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="90%">
                <Rows>
                    <rx:RowLayout ID="RowLayout4" runat="server">
                        <Body>
                           &nbsp;
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="10%">
                <Rows>
                    <rx:RowLayout ID="RowLayout3" runat="server">
                        <Body>
                            <rx:Button runat="server" ID="btnSaveNext" Icon="NextGreen">
                                <AjaxEvents>
                                    <Click OnEvent="BtnSaveNextOnClick" Success="ShowPayment();">
                                        <EventMask ShowMask="true" />
                                    </Click>
                                </AjaxEvents>
                            </rx:Button>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
        </Body>
    </rx:PanelX>
    </form>
</body>
</html>
