<%@ Page Language="C#" AutoEventWireup="true" Inherits="Transfer_PreAuthorizedTransfer" ValidateRequest="false" Codebehind="PreAuthorizedTransfer.aspx.cs" %>


<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="JS/TransferFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script src="../Profession/Profession.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="New_TransferId" runat="server" />
        <rx:Hidden ID="new_ReceivedPaymentAmountParity" runat="server" />
        <rx:Hidden ID="new_ReceivedPaymentAmountParityRateType" runat="server" />
        <rx:Hidden ID="new_CalculatedExpenseAmountDefaultValue" runat="server" />
        <rx:Hidden ID="new_CalculatedExpenseCurrencyDefaultValue" runat="server" />
        <rx:PanelX runat="server" ID="pnl1" Height="50" AutoWidth="false" AutoHeight="Normal"
            Border="false" Title="Ön Onaylı Transfer Arama">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" AutoWidth="true" ColumnLayoutLabelWidth="40">
                    <Rows>
                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="30%" ColumnLayoutLabelWidth="20">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout1" runat="server">
                                            <Body>
                                                <cc1:CrmTextFieldComp runat="server" ID="TransferTuRef" ObjectId="201100072"
                                                    UniqueName="TransferTuRef" FieldLabelWidth="70" Width="230">
                                                </cc1:CrmTextFieldComp>

                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="20%" ColumnLayoutLabelWidth="40">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout2" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Gönderim Ara" ID="btnGetPreAuthorizedTransfer">
                                                    <AjaxEvents>
                                                        <Click OnEvent="GetPreAuthorizedTransfer"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="20%" ColumnLayoutLabelWidth="40">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout9" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Temizle" ID="btnClearAll">
                                                    <AjaxEvents>
                                                        <Click OnEvent="ClearAll"></Click>
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
        </rx:PanelX>
        <rx:Fieldset runat="server" ID="Fieldset1" AutoHeight="Normal" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientCountryID" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientCountryID" Width="150"
                                    PageSize="500" FieldLabel="200" LookupViewUniqueName="NAKIT_ODEMEYAPABILEN_ULKELER"
                                    Mode="Remote" ReadOnly="true">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout23">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientCorporationId" ObjectId="201100072" UniqueName="new_RecipientCorporationId" Hidden="false"
                                    Width="150" PageSize="50" FieldLabel="200" RequirementLevel="BusinessRequired" LookupViewUniqueName="CorpComboView" ReadOnly="true">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout111">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientRegionId" ObjectId="201100072" UniqueName="new_RecipientRegionId" Hidden="true"
                                    LookupViewUniqueName="REGION_LOOKUP_VIEW" Width="150" PageSize="50" FieldLabel="200" ReadOnly="true">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout runat="server" ID="RowLayout21">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientCityId" ObjectId="201100072" UniqueName="new_RecipientCityId" Hidden="true"
                                    LookupViewUniqueName="CITY_LOOKUP_VIEW" Width="150" PageSize="50" FieldLabel="200" ReadOnly="true">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout20">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_BrandId" ObjectId="201100072" UniqueName="new_BrandId" Hidden="true"
                                    LookupViewUniqueName="BRAND_LOOKUP_VIEW" Width="150" PageSize="50" FieldLabel="200" ReadOnly="true">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout22">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientOfficeId" ObjectId="201100072" UniqueName="new_RecipientOfficeId" Hidden="true"
                                    LookupViewUniqueName="OFFICE_LOOKUP_VIEW_FOR_TRANSFER" Width="150" PageSize="50" FieldLabel="200" ReadOnly="true">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_TransactionTargetOptionID" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_TransactionTargetOptionID"
                                    Width="150" PageSize="50" FieldLabel="150" Mode="Remote" ReadOnly="true">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout8">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SourceTransactionTypeID" ObjectId="201100072"
                                    UniqueName="new_SourceTransactionTypeID" Width="150" PageSize="50" FieldLabel="200"
                                    RequirementLevel="BusinessRequired" LookupViewUniqueName="OFFICE_OPERATION_TYPE_SOURCE" ReadOnly="true">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_AmountCurrency2" ObjectId="201100072" UniqueName="new_AmountCurrency"
                                    RequirementLevel="BusinessRequired" LookupViewUniqueName="OFFICE_CURRENCY_LOOKUP_HEDEF"
                                    Width="150" PageSize="50" FieldLabel="150" ReadOnly="true">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderID" ObjectId="201100072" UniqueName="new_SenderID"
                                    RequirementLevel="BusinessRequired" Disabled="true" Width="150" PageSize="50"
                                    FieldLabel="150">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>


        <rx:Fieldset runat="server" ID="Fieldset3" AutoHeight="Normal" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout13" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout24" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_SenderName" ObjectId="201100072"
                                    UniqueName="new_SenderName" FieldLabelWidth="70" Width="230" ReadOnly="true">
                                </cc1:CrmTextFieldComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout26" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_SenderMiddleName" ObjectId="201100072"
                                    UniqueName="new_SenderMiddleName" FieldLabelWidth="70" Width="230" ReadOnly="true">
                                </cc1:CrmTextFieldComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout27" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_SenderLastName" ObjectId="201100072"
                                    UniqueName="new_SenderLastName" FieldLabelWidth="70" Width="230" ReadOnly="true">
                                </cc1:CrmTextFieldComp>

                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout14" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout28" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_FatherName" ObjectId="201100052"
                                    UniqueName="new_FatherName" FieldLabelWidth="70" Width="230" ReadOnly="true">
                                </cc1:CrmTextFieldComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout29" runat="server">
                            <Body>
                                <cc1:CrmDateFieldComp runat="server" ID="new_BirthDate" ObjectId="201100052"
                                    UniqueName="new_BirthDate" FieldLabelWidth="70" Width="230" ReadOnly="true">
                                </cc1:CrmDateFieldComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout19">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderNationalityId" ObjectId="201100072"
                                    UniqueName="new_SenderNationalityId" Width="150"
                                    PageSize="500" FieldLabel="200" LookupViewUniqueName=""
                                    Mode="Remote" ReadOnly="true">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout17" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout31" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_SenderNumber" ObjectId="201100052"
                                    UniqueName="new_SenderNumber" FieldLabelWidth="70" Width="230" ReadOnly="true">
                                </cc1:CrmTextFieldComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout32" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdendificationNumber1" ObjectId="201100072"
                                    UniqueName="new_SenderIdendificationNumber1" FieldLabelWidth="70" Width="230" ReadOnly="true">
                                </cc1:CrmTextFieldComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout25">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderGSMCountryId" ObjectId="201100072" UniqueName="new_SenderGSMCountryId"
                                    RequirementLevel="BusinessRequired" Disabled="true" Width="150" PageSize="50"
                                    FieldLabel="150">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout30">
                            <Body>
                                <cc1:CrmPhoneFieldComp runat="server" ID="new_SenderGSM" ObjectId="201100072" UniqueName="new_SenderGSM"
                                    RequirementLevel="BusinessRequired" Disabled="true" Width="150" PageSize="50"
                                    FieldLabel="150">
                                </cc1:CrmPhoneFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>





        <rx:Fieldset runat="server" ID="PanelX3" AutoHeight="Normal" Height="200" AutoWidth="true"
            CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout10">
                            <Body>
                                <rx:Hidden ID="isEFTHiddenField" runat="server" Value="false">
                                </rx:Hidden>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientID" ObjectId="201100072" UniqueName="new_RecipientID"
                                    Width="150" PageSize="50" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientIBAN" ObjectId="201100072"
                                    UniqueName="new_RecipientIBAN" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientBicIBAN" ObjectId="201100072"
                                    UniqueName="new_RecipientBicIBAN" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmComboComp runat="server" ID="new_BicBank" ObjectId="201100072" UniqueName="new_BicBank"
                                    Width="150" PageSize="50" FieldLabel="200" LookupViewUniqueName="SWIFT_BANKS_LOOKUP" ReadOnly="true">
                                </cc1:CrmComboComp>
                                <%--  <cc1:CrmComboComp runat="server" ID="new_BicBankCity" ObjectId="201100072" UniqueName="new_BicBankCity"
                                    Width="150" PageSize="50" FieldLabel="200" LookupViewUniqueName="SWIFT_BANK_CITIES_LOOKUP">
                                </cc1:CrmComboComp>--%>
                                <cc1:CrmComboComp runat="server" ID="new_BicBankBranch" ObjectId="201100072" UniqueName="new_BicBankBranch"
                                    Width="150" PageSize="50" FieldLabel="200" LookupViewUniqueName="SWIFT_BANK_BRANCHES_LOOKUP" ReadOnly="true">
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_BicCode" ObjectId="201100072" UniqueName="new_BicCode"
                                    FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmComboComp runat="server" ID="new_EftBank" ObjectId="201100072" UniqueName="new_EftBank"
                                    Width="150" PageSize="50" FieldLabel="200" ReadOnly="true">
                                </cc1:CrmComboComp>
                                <%--<cc1:CrmComboComp runat="server" ID="new_EftCity" ObjectId="201100072" UniqueName="new_EftCity"
                                    Width="150" PageSize="50" FieldLabel="200" LookupViewUniqueName="EFT_BRACH_CITY"
                                    ParentRequired="true">
                                </cc1:CrmComboComp>--%>
                                <cc1:CrmComboComp runat="server" ID="new_EftBranch" ObjectId="201100072" UniqueName="new_EftBranch"
                                    Width="150" PageSize="50" FieldLabel="200" ReadOnly="true">
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientAccountNumber" ObjectId="201100072"
                                    UniqueName="new_RecipientAccountNumber" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientBicAccountNumber" ObjectId="201100072"
                                    UniqueName="new_RecipientAccountNumber" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_CorpSendAccountNumber" ObjectId="201100072"
                                    UniqueName="new_CorpSendAccountNumber" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientCardNumber" ObjectId="201100072"
                                    UniqueName="new_RecipientCardNumber" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmComboComp runat="server" ID="new_EftPaymentMethodID" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_EftPaymentMethodID" Width="150"
                                    PageSize="50" FieldLabel="200" ReadOnly="true">
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientName" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientName" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientMiddleName" ObjectId="201100072"
                                    RequirementLevel="None" UniqueName="new_RecipientMiddleName" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientLastName" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientLastName" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout11">
                            <Body>
                                <%--<cc1:CrmTextFieldComp runat="server" ID="new_RecipientMotherName" ObjectId="201100072"
                                    RequirementLevel="None" UniqueName="new_RecipientMotherName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientFatherName" ObjectId="201100072"
                                    RequirementLevel="None" UniqueName="new_RecipientFatherName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>--%>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientGSMCountryId" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientGSMCountryId" Width="150"
                                    LookupViewUniqueName="COUNTRYTELEPHONELOOKUP" PageSize="50" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmComboComp>
                                <cc1:CrmPhoneFieldComp runat="server" ID="new_RecipientGSM" ObjectId="201100072"
                                    UniqueName="new_RecipientGSM" RequirementLevel="BusinessRequired" FieldLabel="200"
                                    HiddenCountryCode="false" ReadOnly="true" Disabled="true">
                                </cc1:CrmPhoneFieldComp>
                                <cc1:CrmDateFieldComp ID="new_RecipientBirthDate" runat="server" ObjectId="201100072"
                                    Hidden="true" UniqueName="new_RecipientBirthDate" FieldLabel="200" ReadOnly="true">
                                </cc1:CrmDateFieldComp>
                                <cc1:CrmTextAreaComp runat="server" ID="new_RecipientAddress" ObjectId="201100072"
                                    Hidden="true" Height="80" UniqueName="new_RecipientAddress" FieldLabel="200" ReadOnly="true">
                                </cc1:CrmTextAreaComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout12">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipienNickName" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipienNickName" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientEmail" ObjectId="201100072"
                                    UniqueName="new_RecipientEmail" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmComboComp runat="server" ID="new_TestQuestionID" ObjectId="201100072" Hidden="true"
                                    RequirementLevel="BusinessRequired" UniqueName="new_TestQuestionID" Width="150"
                                    LookupViewUniqueName="TESTSORUSULOOKUP" PageSize="50" FieldLabel="200" ReadOnly="true">
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_TestQuestionReply" ObjectId="201100072"
                                    Hidden="true" RequirementLevel="BusinessRequired" UniqueName="new_TestQuestionReply"
                                    FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextAreaComp runat="server" ID="new_Explanation" ObjectId="201100072" UniqueName="new_Explanation"
                                    Height="80" FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextAreaComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="PanelX4" AutoHeight="Normal" Height="75" AutoWidth="true"
            Collapsed="false" Collapsible="false" Border="false" CustomCss="Section3">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout10" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout13">
                            <Body>
                                <rx:Hidden ID="new_AmountOld" runat="server">
                                </rx:Hidden>
                                <cc1:CrmMoneyComp runat="server" ID="new_Amount" UniqueName="new_Amount" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" Disabled="true">
                                    <DecimalChange OnEvent="new_AmountOnChange">
                                    </DecimalChange>
                                </cc1:CrmMoneyComp>
                                <cc1:CrmMoneyComp runat="server" ID="new_CalculatedExpenseAmount" UniqueName="new_CalculatedExpenseAmount"
                                    ObjectId="201100072" Disabled="true">
                                </cc1:CrmMoneyComp>
                                <cc1:CrmMoneyComp runat="server" ID="new_ReceivedPaymentAmount" UniqueName="new_ReceivedPaymentAmount"
                                    ObjectId="201100072" Disabled="true">
                                    <Items>
                                        <rx:Label ID="Parity3" runat="server">
                                        </rx:Label>
                                    </Items>
                                </cc1:CrmMoneyComp>
                                <cc1:CrmMoneyComp runat="server" ID="new_ReceivedExpenseAmount" UniqueName="new_ReceivedExpenseAmount"
                                    ObjectId="201100072" Disabled="true" Hidden="true">
                                </cc1:CrmMoneyComp>
                                <cc1:CrmMoneyComp runat="server" ID="new_TotalReceivedAmount" UniqueName="new_TotalReceivedAmount"
                                    ObjectId="201100072" Disabled="true" Hidden="True">
                                </cc1:CrmMoneyComp>
                                <cc1:CrmMoneyComp runat="server" ID="new_ExpenseAmount" UniqueName="new_ExpenseAmount"
                                    Hidden="true" ObjectId="201100072">
                                </cc1:CrmMoneyComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout11" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout14">
                            <Body>
                                <rx:MultiField ID="RxM" runat="server" Width="200" FieldLabel="" RequirementLevel="BusinessRequired">
                                    <Items>
                                        <cc1:CrmPicklistComp runat="server" ID="new_CollectionMethod" Width="168" UniqueName="new_CollectionMethod"
                                            ObjectId="201100072" RequirementLevel="BusinessRequired" FieldLabelShow="false">
                                            <AjaxEvents>
                                                <Change OnEvent="new_CollectionMethodOnChange">
                                                </Change>
                                            </AjaxEvents>
                                        </cc1:CrmPicklistComp>
                                    </Items>
                                </rx:MultiField>
                                <cc1:CrmMoneyComp runat="server" ID="new_ReceivedAmount1" UniqueName="new_ReceivedAmount1"
                                    ObjectId="201100072" RequirementLevel="BusinessRequired" LookupViewUniqueName="OFFICECURRENCYLOOKUPSOURCE">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100072" FromUniqueName="new_OfficeID" ToObjectId="201100043"
                                            ToUniqueName="new_OfficeID" />
                                    </Filters>
                                    <DecimalChange OnEvent="CalculateOnEvent">
                                    </DecimalChange>
                                    <ComboChange OnEvent="new_ReceivedAmount1CurrencyOnChange">
                                    </ComboChange>
                                    <Items>
                                        <rx:Label ID="Parity1" runat="server">
                                        </rx:Label>
                                    </Items>
                                </cc1:CrmMoneyComp>
                                <cc1:CrmMoneyComp runat="server" ID="new_ReceivedAmount2" UniqueName="new_ReceivedAmount2"
                                    ObjectId="201100072" RequirementLevel="BusinessRequired" LookupViewUniqueName="OFFICECURRENCYLOOKUPSOURCE"
                                    Disabled="True">
                                    <Items>
                                        <rx:Label ID="Parity2" runat="server">
                                        </rx:Label>
                                    </Items>
                                </cc1:CrmMoneyComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="Fieldset2" AutoHeight="Normal" Height="65" AutoWidth="true"
            CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout15" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout17">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderIdentificationCardTypeID" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_SenderIdentificationCardTypeID"
                                    LookupViewUniqueName="KIMLIKTIPILOOKUP_FILTERED" Width="150" PageSize="50" FieldLabel="200" ReadOnly="true">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100072" FromUniqueName="new_CorporationCountryId"
                                            ToObjectId="201100049" ToUniqueName="new_CountryID" />
                                    </Filters>

                                </cc1:CrmComboComp>
                                <cc1:CrmBooleanComp runat="server" RequirementLevel="BusinessRequired" ObjectId="201100075"
                                    ID="new_IdentityWasSeen" UniqueName="new_IdentityWasSeen" />

                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout16" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout18">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdentificationCardNo" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_SenderIdentificationCardNo"
                                    FieldLabel="200" ReadOnly="true" Disabled="true">
                                </cc1:CrmTextFieldComp>

                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <%--<rx:ColumnLayout runat="server" ID="ColumnLayout14" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout26">
                            <Body>
                                <cc1:CrmDateFieldComp runat="server" ID="new_ValidDateOfSenderIdentificationCard"
                                    UniqueName="new_ValidDateOfSenderIdentificationCard" ObjectId="201100072" RequirementLevel="BusinessRequired" />
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>--%>
            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="PanelX5" AutoHeight="Normal" Height="40" AutoWidth="true"
            Hidden="True" CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout15">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_CorporationCountryId" UniqueName="new_CorporationCountryId"
                                    ObjectId="201100072" ReadOnly="true" />
                                <cc1:CrmComboComp runat="server" ID="new_OfficeID" ReadOnly="true" UniqueName="new_OfficeID"
                                    ObjectId="201100072" />
                                <cc1:CrmComboComp runat="server" ID="new_SenderCountryID" ReadOnly="true" UniqueName="new_SenderCountryID"
                                    ObjectId="201100072" />
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout16">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_CorporationID" UniqueName="new_CorporationID"
                                    ObjectId="201100072" ReadOnly="true" />
                                <cc1:CrmComboComp runat="server" ID="CreatedBy" UniqueName="CreatedBy"
                                    ObjectId="201100072" ReadOnly="true" Hidden="true" />
                                <cc1:CrmNumberComp runat="server" ID="new_Channel" UniqueName="new_Channel"
                                    ObjectId="201100072" ReadOnly="true" Hidden="true" />
                                <cc1:CrmComboComp runat="server" ID="new_TargetTransactionTypeID" ReadOnly="true"
                                    UniqueName="new_TargetTransactionTypeID" ObjectId="201100072" LookupViewUniqueName="TRANSACTIONTYPELOOKUP" />
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="0" AutoWidth="true"
            CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false" Frame="false">
            <Buttons>
                <rx:Button ID="btnSave" runat="server" Icon="Disk" Text="Kaydet" Width="100">
                    <AjaxEvents>
                        <Click OnEvent="btnSaveOnEvent">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                <rx:Button ID="btnBack" runat="server" Icon="PageEdit" Text="Düzenle" Width="100">
                    <AjaxEvents>
                        <Click OnEvent="btnBackOnEvent">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
    </form>
</body>
</html>

