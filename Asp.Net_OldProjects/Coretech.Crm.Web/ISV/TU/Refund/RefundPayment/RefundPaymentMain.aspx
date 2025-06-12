<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="true"
    Inherits="Refund_RefundPaymentMain" CodeBehind="RefundPaymentMain.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style>
        .trgclear {
            margin: 1px -5px 0 !important;
        }

            .trgclear span {
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

        .Section1 {
            margin-bottom: 2px !important;
            overflow: hidden !important;
        }

        .Section2 {
            margin-bottom: 2px !important;
            padding: 1px !important;
            overflow: hidden !important;
        }

        .Section3 {
            margin-bottom: 2px !important;
            padding: 5px !important;
            overflow: hidden !important;
        }
    </style>
    <script src="../JS/RefundPaymentFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="New_RefundPaymentId" runat="server" />
        <rx:Hidden ID="isIdentityShowMessage" runat="server" />
        <rx:Hidden ID="PaymentTuRef" runat="server" />
        <rx:Hidden ID="new_RefundByOffice" runat="server" />
        <rx:Hidden ID="new_CountryId" runat="server" />
        <rx:Hidden ID="new_RefundByCorporation" runat="server" />
        <rx:PanelX runat="server" ID="Fieldset2" AutoHeight="Normal" Height="35" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="95%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout15">
                            <Body>
                                <rx:Label runat="server" ID="TuLabelMessage">
                                </rx:Label>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:Fieldset runat="server" ID="PanelX1" AutoHeight="Normal" Height="25" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout10" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout28">
                            <Body>
                                <cc1:CrmLabelField ID="new_SenderId" runat="server" ObjectId="201200025" Disabled="true"
                                    UniqueName="new_SenderId" Width="300" />
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="pnlPayment" AutoHeight="Normal" Height="90" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" Border="false" Title="CRM.NEW_REFUNDPAYMENT_ODEMEBILGILERI">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmMoneyComp ID="new_RefundAmount" runat="server" ObjectId="201200025" Disabled="true"
                                    UniqueName="new_RefundAmount" />
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <cc1:CrmLabelField ID="new_TransferId" runat="server" ObjectId="201200025" UniqueName="new_TransferId"
                                    Disabled="true" />
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <cc1:CrmMoneyComp runat="server" ID="new_RefundPaymentAmount" UniqueName="new_RefundPaymentAmount"
                                    ObjectId="201200025" RequirementLevel="BusinessRequired" LookupViewUniqueName="OFFICE_CURRENCY_LOOKUP_PAYMENT">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201200025" FromUniqueName="new_RefundByOffice" ToObjectId="201100043"
                                            ToUniqueName="new_OfficeID" />
                                    </Filters>
                                    <DecimalChange OnEvent="CalculateOnEvent">
                                    </DecimalChange>
                                    <ComboChange OnEvent="new_RefundPaymentAmountCurrencyOnChange">
                                    </ComboChange>
                                </cc1:CrmMoneyComp>
                                <rx:Label ID="Parity1" runat="server">
                                </rx:Label>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout11">
                            <Body>
                                <cc1:CrmMoneyComp ID="new_RefundExpenseAmount" runat="server" ObjectId="201200025" Disabled="true"
                                    UniqueName="new_RefundExpenseAmount" />
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <rx:MultiField ID="RxM" runat="server" Width="200" FieldLabel="." RequirementLevel="BusinessRequired">
                                    <Items>
                                        <cc1:CrmPicklistComp runat="server" ID="new_RefundMethod" Width="168" UniqueName="new_RefundMethod"
                                            ObjectId="201200025" RequirementLevel="None" FieldLabelShow="false">
                                            <AjaxEvents>
                                                <Change OnEvent="new_RefundMethodOnChange">
                                                </Change>
                                            </AjaxEvents>
                                        </cc1:CrmPicklistComp>
                                    </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout12">
                            <Body>
                                <cc1:CrmMoneyComp runat="server" ID="new_RefundPaymentAmount2" UniqueName="new_RefundPaymentAmount2"
                                    ObjectId="201200025" RequirementLevel="BusinessRequired" LookupViewUniqueName="OFFICECURRENCYLOOKUPSOURCE">
                                </cc1:CrmMoneyComp>
                                <rx:Label ID="Parity2" runat="server">
                                </rx:Label>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmMoneyComp ID="new_RefundCost" runat="server" ObjectId="201200025" Disabled="true"
                                    UniqueName="new_RefundCost" />
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout runat="server" ID="RowLayout9">
                            <Body>
                                <cc1:CrmMoneyComp runat="server" ID="new_KambiyoAmount" UniqueName="new_KambiyoAmount"
                                    ObjectId="201100075" Disabled="true" Hidden="True">
                                </cc1:CrmMoneyComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="IFRAME_SENDER" AutoHeight="Normal" Height="100" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" Border="false" Title="CRM.NEW_REFUNDPAYMENT_GONDERICIBILGILERI">
            <AutoLoad ShowMask="true" Url="about:blank" />
            <Body>
            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="pnlKimlik" AutoHeight="Normal" Height="50" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" Border="false" Title="CRM.NEW_REFUNDPAYMENT_GONDERICIKIMLIK">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout25">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderIdentificationCardTypeID" ObjectId="201200025"
                                    UniqueName="new_SenderIdentificationCardTypeID" LookupViewUniqueName="KIMLIKTIPILOOKUP_FILTERED"
                                    Width="150" PageSize="50" FieldLabel="200" Disabled="true">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout27">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ObjectId="201200025" ID="new_SenderIdentificationCardNo"
                                    UniqueName="new_SenderIdentificationCardNo" Disabled="true" />
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout26">
                            <Body>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="PnlAlici" AutoHeight="Normal" Height="50" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" Border="false" Title="CRM.NEW_REFUNDPAYMENT_ALICI">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout11" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout16">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RrecipientName" ObjectId="201200025"
                                    UniqueName="new_RrecipientName" FieldLabel="200" Disabled="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmBooleanComp runat="server" ID="new_IdentityChecked" ObjectId="201200025"
                                    RequirementLevel="BusinessRequired" UniqueName="new_IdentityChecked" FieldLabel="200">
                                </cc1:CrmBooleanComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout13" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout29">
                            <Body>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout14" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout30">
                            <Body>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:ToolBar runat="server" ID="ToolBar1">
            <Items>
                <rx:ToolbarFill runat="server" ID="ToolbarFill1">
                </rx:ToolbarFill>
                <rx:ToolbarButton runat="server" ID="btnSave" Text="CRM.NEW_REFUNDPAYMENT_ISLEMI_TAMAMLA"
                    Icon="Disk" Width="100">
                    <AjaxEvents>
                        <Click OnEvent="SaveOnClick" Before="ValidateBeforeSave(msg, e)">
                            <EventMask ShowMask="true" Msg="saving..." />
                        </Click>
                    </AjaxEvents>
                </rx:ToolbarButton>
            </Items>
        </rx:ToolBar>
    </form>
</body>
</html>
