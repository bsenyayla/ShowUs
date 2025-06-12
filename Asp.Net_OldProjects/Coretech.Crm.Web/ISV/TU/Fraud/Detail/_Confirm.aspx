<%@ Page Language="C#" AutoEventWireup="true" Inherits="Detail_Detail_Confirm" Async="true" Codebehind="_Confirm.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR" />
    <rx:Hidden runat="server" ID="hdnRecId">
    </rx:Hidden>
    <rx:Hidden runat="server" ID="hiddenUrl">
    </rx:Hidden>
     <rx:Hidden runat="server" ID="hdnEntityId">
    </rx:Hidden>
    <rx:PanelX runat="server" ID="PanelIframe" AutoHeight="Normal" Height="520" Border="false"
        Frame="true">
        <AutoLoad Url="about:blank" ShowMask="true" />
        <Body>
        </Body>
    </rx:PanelX>
    <rx:ToolBar runat="server" ID="ToolBarMain">
        <Items>
            <rx:ToolbarButton runat="server" ID="ToolbarButtonContinue" Text="CRM.NEW_FRAUDLOG_BTN_CONTINUE"
                Icon="Tick" Width="100">
                <Listeners>
                    <Click Handler="windowContinue.show();" />
                </Listeners>
            </rx:ToolbarButton>
            <rx:ToolbarButton runat="server" ID="ToolbarButtonCancel" Text="CRM.NEW_FRAUDLOG_BTN_INTERRUPT"
                Icon="Cancel" Width="100">
                <Listeners>
                    <Click Handler="windowCancel.show();" />
                </Listeners>
            </rx:ToolbarButton>
            <rx:ToolbarButton runat="server" ID="ToolbarButtonConfirm" Text="CRM.NEW_FRAUDLOG_BTN_CONFIRM"
                Icon="Tick" Width="100">
                <AjaxEvents>
                    <Click OnEvent="Confirm">
                    </Click>
                </AjaxEvents>
            </rx:ToolbarButton>
            <rx:ToolbarButton runat="server" ID="ToolbarButtonReturn" Text="CRM.NEW_FRAUDLOG_BTN_RETURN"
                Icon="Cancel" Width="100">
                <Listeners>
                    <Click Handler="windowReturn.show();" />
                </Listeners>
            </rx:ToolbarButton>
            <rx:ToolbarFill runat="server" ID="tf1">
            </rx:ToolbarFill>
            <rx:ToolbarButton runat="server" ID="ToolbarButtonMd" Text="CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING_DETAIL"
                Icon="ControlBlank" Width="100">
                <Listeners>
                    <Click Handler="ShowMonitoringDetailLite();" />
                </Listeners>
            </rx:ToolbarButton>
        </Items>
    </rx:ToolBar>
    <rx:Window ID="windowContinue" runat="server" Width="600" Height="200" Modal="true"
        CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
        CloseAction="Hide" ShowOnLoad="false">
        <Body>
            <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="100%">
                <Rows>
                    <rx:RowLayout ID="RowLayout1" runat="server">
                        <Body>
                            <cc1:CrmComboComp runat="server" ID="new_FraudContinueReasonId" ObjectId="201100105"
                                UniqueName="new_FraudContinueReasonId" FieldLabelWidth="120" Width="130" PageSize="50"
                                RequirementLevel="BusinessRequired" LookupViewUniqueName="FRAUD_DEVAMETTIRME">
                            </cc1:CrmComboComp>
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout runat="server" ID="RowLayout2">
                        <Body>
                            <cc1:CrmTextAreaComp ID="new_FraudContinueReason" runat="server" ObjectId="201100105"
                                UniqueName="new_FraudContinueReason" FieldLabelWidth="120" Width="130" CaseType="UpperCase"
                                MaxLength="100" RequirementLevel="BusinessRecommend">
                            </cc1:CrmTextAreaComp>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ToolBar runat="server" ID="ToolBar1">
                <Items>
                    <rx:ToolbarFill runat="server" ID="ToolbarFill1">
                    </rx:ToolbarFill>
                    <rx:ToolbarButton runat="server" ID="ToolbarButtonContinue1" Text="CRM.NEW_FRAUDLOG_BTN_CONTINUE"
                        Icon="Tick" Width="100">
                        <AjaxEvents>
                            <Click OnEvent="Continue" Before="return CheckContinueReason(msg,e);">
                                <EventMask ShowMask="true" Msg="Continueing..." />
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                </Items>
            </rx:ToolBar>
        </Body>
    </rx:Window>
    <rx:Window ID="windowCancel" runat="server" Width="600" Height="200" Modal="true" 
        CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
        CloseAction="Hide" ShowOnLoad="false">
        <Body>
            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="100%">
                <Rows>
                    <rx:RowLayout ID="RowLayout3" runat="server">
                        <Body>
                            <cc1:CrmComboComp runat="server" ID="new_FraudCancelReasonId" ObjectId="201100105"
                                UniqueName="new_FraudCancelReasonId" FieldLabelWidth="120" Width="130" PageSize="50"
                                RequirementLevel="BusinessRequired" LookupViewUniqueName="FRAUD_KESME">
                            </cc1:CrmComboComp>
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout runat="server" ID="RowLayout4">
                        <Body>
                            <cc1:CrmTextAreaComp ID="new_FraudCancelReason" runat="server" ObjectId="201100105"
                                UniqueName="new_FraudCancelReason" FieldLabelWidth="120" Width="130" CaseType="UpperCase"
                                MaxLength="100" RequirementLevel="BusinessRecommend">
                            </cc1:CrmTextAreaComp>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ToolBar runat="server" ID="ToolBar2">
                <Items>
                    <rx:ToolbarFill runat="server" ID="ToolbarFill2">
                    </rx:ToolbarFill>
                    <rx:ToolbarButton runat="server" ID="ToolbarButtonCancel1" Text="CRM.NEW_FRAUDLOG_BTN_INTERRUPT"
                        Icon="Cancel" Width="100">
                        <AjaxEvents>
                            <Click OnEvent="Cancel" Before="return CheckCancelReason(msg,e);">
                                <EventMask ShowMask="true" Msg="Canceling..." />
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                </Items>
            </rx:ToolBar>
        </Body>
    </rx:Window>
    <rx:Window ID="windowReturn" runat="server" Width="600" Height="200" Modal="true"
        CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
        CloseAction="Hide" ShowOnLoad="false">
        <Body>
            <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="100%">
                <Rows>
                    <rx:RowLayout ID="RowLayout5" runat="server">
                        <Body>
                            <cc1:CrmComboComp runat="server" ID="new_FraudConfirmCancelReasonId" ObjectId="201100105"
                                UniqueName="new_FraudConfirmCancelReasonId" FieldLabelWidth="120" Width="130"
                                PageSize="50" RequirementLevel="BusinessRequired" LookupViewUniqueName="FRAUD_ONAYCI_KESME">
                            </cc1:CrmComboComp>
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout runat="server" ID="RowLayout6">
                        <Body>
                            <cc1:CrmTextAreaComp ID="new_FraudConfirmCancelReason" runat="server" ObjectId="201100105"
                                UniqueName="new_FraudConfirmCancelReason" FieldLabelWidth="120" Width="130" CaseType="UpperCase"
                                MaxLength="100" RequirementLevel="BusinessRecommend">
                            </cc1:CrmTextAreaComp>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ToolBar runat="server" ID="ToolBar3">
                <Items>
                    <rx:ToolbarFill runat="server" ID="ToolbarFill3">
                    </rx:ToolbarFill>
                    <rx:ToolbarButton runat="server" ID="ToolbarButtonReturn1" Text="CRM.NEW_FRAUDLOG_BTN_RETURN"
                        Icon="Cancel" Width="100">
                        <AjaxEvents>
                            <Click OnEvent="ConfirmCancel" Before="return CheckConfirmCancelReason(msg,e);">
                                <EventMask ShowMask="true" Msg="Returning..." />
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                </Items>
            </rx:ToolBar>
        </Body>
    </rx:Window>
    </form>
</body>
</html>
<script language="javascript">
    function CheckConfirmCancelReason(msg, e) {

        if (new_FraudConfirmCancelReasonId.getValue() == "") {
            var win = window.top;
            alert(win.String.format(win.GetMessages("CRM_FIELD_REQUIRED"), new_FraudConfirmCancelReasonId.getFieldLabel()));
            return false;
        }
    }
    function CheckContinueReason(msg, e) {

        if (new_FraudContinueReasonId.getValue() == "") {
            var win = window.top;
            alert(win.String.format(win.GetMessages("CRM_FIELD_REQUIRED"), new_FraudContinueReasonId.getFieldLabel()));
            return false;
        }
    }
    function CheckCancelReason(msg, e) {

        if (new_FraudCancelReasonId.getValue() == "") {
            var win = window.top;
            alert(win.String.format(win.GetMessages("CRM_FIELD_REQUIRED"), new_FraudCancelReasonId.getFieldLabel()));
            return false;
        }
    }

</script>
