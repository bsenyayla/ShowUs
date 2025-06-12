<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_Detail_Confirm" Async="true" Codebehind="_Confirm.aspx.cs" %>

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
    <rx:Button ID="btnInfo" runat="server" Download="True" Hidden="True">
        <AjaxEvents>
            <Click OnEvent="btnInformationOnEvent">
            </Click>
        </AjaxEvents>
    </rx:Button>
    <rx:Hidden runat="server" ID="hdnObjectId">
    </rx:Hidden>
    <rx:Hidden runat="server" ID="hdnRecId">
    </rx:Hidden>
    <rx:Hidden runat="server" ID="hiddenUrl">
    </rx:Hidden>
    <rx:PanelX runat="server" ID="PanelIframe" AutoHeight="Normal" Height="520" Border="false"
        Frame="true">
        <AutoLoad Url="about:blank" ShowMask="true" />
        <Body>
        </Body>
        <Buttons>
            <rx:Button ID="btnTransfer" runat="server" Text="ShowTransfer">
                <Listeners>
                    <Click Handler="OpenTransfer();" />
                </Listeners>
            </rx:Button>
        </Buttons>
    </rx:PanelX>
    <rx:ToolBar runat="server" ID="ToolBarMain">
        <Items>
            <rx:ToolbarButton runat="server" ID="ToolbarButtonConfirm" Text="CONFIRM" Icon="Tick"
                Width="100">
                <AjaxEvents>
                    <Click OnEvent="Confirm">
                        <EventMask ShowMask="true" Msg="Confirming..." />
                    </Click>
                </AjaxEvents>
            </rx:ToolbarButton>
            <rx:ToolbarButton runat="server" ID="ToolbarButtonReturn" Text="RETURN" Icon="TagBlueDelete"
                Width="100">
                <Listeners>
                    <Click Handler="windowReturn.show();" />
                </Listeners>
            </rx:ToolbarButton>
            <rx:ToolbarButton runat="server" ID="ToolbarButtonReject" Text="REJECT" Icon="Cancel"
                Width="100">
                <Listeners>
                    <Click Handler="windowReject.show();" />
                </Listeners>
            </rx:ToolbarButton>
            <rx:ToolbarFill runat="server" ID="tf1">
            </rx:ToolbarFill>
        </Items>
    </rx:ToolBar>
    <rx:Window ID="windowReturn" runat="server" Width="500" Height="200" Modal="true"
        CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
        CloseAction="Hide" ShowOnLoad="false">
        <Body>
            <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="100%">
                <Rows>
                    <rx:RowLayout ID="RowLayout1" runat="server">
                        <Body>
                            <cc1:CrmComboComp runat="server" ID="new_ConfirmReasonId" ObjectId="201100097" LookupViewUniqueName="CONFIRM_REASON_LOOKUP"
                                UniqueName="new_ConfirmReasonId" FieldLabelWidth="120" Width="130" PageSize="50"
                                RequirementLevel="BusinessRequired">
                                <Listeners>
                                    <Change Handler="" />
                                </Listeners>
                            </cc1:CrmComboComp>
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout runat="server" ID="RowLayout2">
                        <Body>
                            <cc1:CrmTextAreaComp ID="new_ConfirmReasonDescription" runat="server" ObjectId="201100097"
                                UniqueName="new_ConfirmReasonDescription" FieldLabelWidth="120" Width="130" CaseType="UpperCase"
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
                    <rx:ToolbarButton runat="server" ID="ToolbarButtonReturn1" Text="RETURN" Icon="TagBlueDelete"
                        Width="100">
                        <AjaxEvents>
                            <Click OnEvent="Return" Before="return CheckConfirmReason(msg,e);">
                                <EventMask ShowMask="true" Msg="Confirming..." />
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                </Items>
            </rx:ToolBar>
        </Body>
    </rx:Window>
    <rx:Window ID="windowReject" runat="server" Width="500" Height="200" Modal="true"
        CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
        CloseAction="Hide" ShowOnLoad="false">
        <Body>
            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="100%">
                <Rows>
                    <rx:RowLayout ID="RowLayout3" runat="server">
                        <Body>
                            <cc1:CrmComboComp runat="server" ID="new_RejectmReasonId" ObjectId="201100097" LookupViewUniqueName="CONFIRM_REASON_LOOKUP"
                                UniqueName="new_ConfirmReasonId" FieldLabelWidth="120" Width="130" PageSize="50"
                                RequirementLevel="BusinessRequired">
                            </cc1:CrmComboComp>
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout runat="server" ID="RowLayout4">
                        <Body>
                            <cc1:CrmTextAreaComp ID="new_RejectReasonDescription" runat="server" ObjectId="201100097"
                                UniqueName="new_ConfirmReasonDescription" FieldLabelWidth="120" Width="130" CaseType="UpperCase"
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
                    <rx:ToolbarButton runat="server" ID="ToolbarButtonReject1" Text="Reject" Icon="Cancel"
                        Width="100">
                        <AjaxEvents>
                            <Click OnEvent="Reject" Before="return CheckRejectReason(msg,e);">
                                <EventMask ShowMask="true" Msg="waiting..." />
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                </Items>
            </rx:ToolBar>
        </Body>
    </rx:Window>
    <rx:Window ID="windowRefundExpenseConfirm" runat="server" Width="500" Height="215" Modal="true"
        CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
        CloseAction="Hide" ShowOnLoad="false">
        <Body>
            <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="100%">
                <%--<Rows>
                    <rx:RowLayout ID="RowLayout5" runat="server">
                        <Body>
                                                        
                        </Body>
                    </rx:RowLayout>
                </Rows>--%>
                <Rows>
                    <rx:RowLayout ID="RowLayout6" runat="server">
                        <Body>
                            <cc1:CrmBooleanComp runat="server" ID="new_RefundExpense" ObjectId="201200024" UniqueName="new_RefundExpense">
                                <Listeners>
                                    <Change Handler="if(!new_RefundExpense.getValue()) {
                                                                                            new_RefundExpenseReason.setValue(''); 
                                                                                            new_RefundExpenseReasonDesc.setValue(''); }" />
                                </Listeners>
                            </cc1:CrmBooleanComp>
                            <cc1:CrmComboComp runat="server" ID="new_RefundExpenseReason" LookupViewUniqueName="REFUND_EXPENSE_REASON_LOOKUP_VIEW"
                                ObjectId="201200024" UniqueName="new_RefundExpenseReason" FieldLabelWidth="120" Width="130"
                                PageSize="50" RequirementLevel="BusinessRequired">
                            </cc1:CrmComboComp>
                            <cc1:CrmTextAreaComp ID="new_RefundExpenseReasonDesc" runat="server" ObjectId="201200024"
                                UniqueName="new_RefundExpenseReasonDesc" FieldLabelWidth="120" Width="130" CaseType="UpperCase"
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
                    <rx:ToolbarButton runat="server" ID="ToolbarButtonRefundExpenseConfirm" Text="CONFIRM" Icon="Tick"
                        Width="100">
                        <AjaxEvents>
                            <Click OnEvent="Confirm" Before="return CheckRefundExpenseReason(msg,e);">
                                <EventMask ShowMask="true" Msg="Confirming..." />
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
<script language="javascript" type="text/javascript">
    function OpenTransfer() {
        window.open(hiddenUrl.getValue(), "", "menubar = 1, resizable = 1, width = 800, height = 600");
    }
    function CheckConfirmReason() {
        if (new_ConfirmReasonId.getValue() == "") {
            var win = window.top;
            alert(win.String.format(win.GetMessages("CRM_FIELD_REQUIRED"), new_ConfirmReasonId.getFieldLabel()));
            return false;
        }
    } function CheckRejectReason() {
        if (new_RejectmReasonId.getValue() == "") {
            var win = window.top;
            alert(win.String.format(win.GetMessages("CRM_FIELD_REQUIRED"), new_RejectmReasonId.getFieldLabel()));
            return false;
        }
    }
    function CheckRefundExpenseReason() {
        var ret = true;
        var err = "";
        if (new_RefundExpense.getValue() && new_RefundExpenseReason.getValue() == "") {
            var win = window.top;
            if (err != "") {
                err += "\n";
            }
            err += win.String.format(win.GetMessages("CRM_FIELD_REQUIRED"), new_RefundExpenseReason.getFieldLabel());
            ret = false;
        }

        if (ret == false) {
            alert(err);
        }
        return ret;
    } 
</script>

</script>
