<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Refund_RefundTransfer_Operation_Detail_CancelRequest" Async="true" ValidateRequest="false" Codebehind="_RefundTransferRequest.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="hdnObjectId">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnRecId">
        </rx:Hidden>
        <rx:PanelX runat="server" ID="PanelIframe" AutoHeight="Normal" Height="415" Border="true"
            Frame="true">
            <AutoLoad Url="about:blank" ShowMask="true" />
            <Body>
            </Body>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="PanelRefundTransferReason" AutoHeight="Normal" Height="100" Border="true" Title="CRM.NEW_REFUNDTRANSFER_PANEL_BASLIK">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="45%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RefundReasonId" LookupViewUniqueName="REFUND_REASON_LOOKUP"
                                    ObjectId="201200024" UniqueName="new_RefundReasonId" FieldLabelWidth="120" Width="130"
                                    PageSize="50" RequirementLevel="BusinessRequired">
                                    <Listeners>
                                        <Change Handler="" />
                                    </Listeners>
                                    <AjaxEvents>
                                        <Change OnEvent="new_RefundReasonIdOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout5" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RefundSubReasonId" LookupViewUniqueName="RefundSubReasonView" Hidden="true"
                                    ObjectId="201200024" UniqueName="new_RefundSubReasonId" FieldLabelWidth="120" Width="130"
                                    PageSize="50" RequirementLevel="None">
                                    <Listeners>
                                        <Change Handler="" />
                                    </Listeners>
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201200024" FromUniqueName="new_RefundReasonId" ToObjectId="201500020"
                                            ToUniqueName="new_RefundReasonId" />
                                    </Filters>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="45%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmTextAreaComp ID="new_RefundReasonDescription" runat="server" ObjectId="201200024"
                                    UniqueName="new_RefundReasonDescription" FieldLabelWidth="120" Width="130" CaseType="UpperCase"
                                    MaxLength="100" RequirementLevel="BusinessRecommend">
                                </cc1:CrmTextAreaComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="PanelRefundExpenseReason" AutoHeight="Normal" Height="100">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="45%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <cc1:CrmBooleanComp runat="server" ID="new_RefundExpense" ObjectId="201200024" UniqueName="new_RefundExpense">
                                    <AjaxEvents>
                                        <Change OnEvent="CalculateAmountWithExpense" />
                                    </AjaxEvents>
                                    <Listeners>
                                        <Change Handler="if(!new_RefundExpense.getValue()) {    RefundExpenseReasonColumnLayout.hide(); 
                                                                                            new_RefundExpenseReason.setValue(''); 
                                                                                            new_RefundExpenseReasonDesc.setValue(''); }  
                                                    else { RefundExpenseReasonColumnLayout.show(); }" />
                                    </Listeners>
                                </cc1:CrmBooleanComp>
                                <%--<rx:Label runat="server" ID="lAmountWithExpense" />--%>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="RefundExpenseReasonColumnLayout" ColumnWidth="45%" Hidden="true">
                    <Rows>
                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RefundExpenseReason" LookupViewUniqueName="REFUND_EXPENSE_REASON_LOOKUP_VIEW"
                                    ObjectId="201200024" UniqueName="new_RefundExpenseReason" FieldLabelWidth="120" Width="130"
                                    PageSize="50" RequirementLevel="BusinessRequired">
                                    <Listeners>
                                        <Change Handler="" />
                                    </Listeners>
                                </cc1:CrmComboComp>
                                <cc1:CrmTextAreaComp ID="new_RefundExpenseReasonDesc" runat="server" ObjectId="201200024"
                                    UniqueName="new_RefundExpenseReasonDesc" FieldLabelWidth="120" Width="130" CaseType="UpperCase"
                                    MaxLength="100" RequirementLevel="BusinessRecommend">
                                </cc1:CrmTextAreaComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:ToolBar runat="server" ID="ToolBarMain">
            <Items>
                <rx:ToolbarButton runat="server" ID="ToolbarButtonBtnRefund" Text="CONFIRM" Icon="MoneyDelete"
                    Width="100">
                    <AjaxEvents>
                        <Click OnEvent="RefundIt" Before="return CheckRefundReason(msg,e);">
                            <EventMask ShowMask="true" Msg="Confirming..." />
                        </Click>
                    </AjaxEvents>
                </rx:ToolbarButton>
                <rx:ToolbarFill runat="server" ID="tf1">
                </rx:ToolbarFill>
            </Items>
        </rx:ToolBar>
    </form>
</body>
</html>
<script type="text/javascript">
    function CheckRefundReason() {
        var ret = true;
        var err = "";
        if (new_RefundReasonId.getValue() == "") {
            var win = window.top;
            err = win.String.format(win.GetMessages("CRM_FIELD_REQUIRED"), new_RefundReasonId.getFieldLabel());
            ret = false;
        }
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
