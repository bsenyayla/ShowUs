<%@ Page Language="C#" AutoEventWireup="true" Inherits="AccountTransactions_Virman" ValidateRequest="false" CodeBehind="Virman.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script src="Js/_Virman.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>

</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="new_VirmanId" runat="server" />
        <rx:Hidden ID="TransactionTypeId" runat="server" />
        <rx:Hidden ID="TransactionTypeCode" runat="server" />
        <rx:Hidden ID="TransactionTypeIdName" runat="server" />
        <rx:Hidden ID="TransactionTypePrefixCode" runat="server" />
        <rx:Hidden ID="new_SenderAccountCurrencyId" runat="server" />
        <rx:Hidden ID="new_RecipientAccountCurrencyId" runat="server" />
        <rx:Hidden runat="server" ID="hdnRecid">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnReportId">
        </rx:Hidden>

        <rx:PanelX runat="server" ID="pnl1" AutoWidth="false" AutoHeight="Normal" Border="false" Title="Talimatlı İşlemler">
        </rx:PanelX>

        <rx:Fieldset runat="server" ID="Fieldset1" AutoHeight="Normal" AutoWidth="true" CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_VirementType" ObjectId="201400028"
                                    RequirementLevel="BusinessRequired" UniqueName="new_VirementType" Width="150"
                                    PageSize="500" FieldLabel="200" Mode="Remote">
                                    <AjaxEvents>
                                        <Change OnEvent="VirementTypeChange">
                                        </Change>
                                    </AjaxEvents>
                                    <DataContainer>
                                        <DataSource OnEvent="VirementTypeLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderAccountId" ObjectId="201400028"
                                    RequirementLevel="BusinessRequired" UniqueName="new_SenderAccountId" Width="150" LookupViewUniqueName="AccountWithBalanceLookupView"
                                    PageSize="500" FieldLabel="200" Mode="Remote">
                                    <AjaxEvents>
                                        <Change OnEvent="AccountChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                    <DataContainer>
                                        <DataSource OnEvent="SenderAccountLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout9">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_CustAccountsId" ObjectId="201400028"
                                    RequirementLevel="BusinessRequired" UniqueName="new_CustAccountsId" Width="150" LookupViewUniqueName="CustAccountLookupWithoutBalance"
                                    PageSize="500" FieldLabel="200" Mode="Remote">
                                    <DataContainer>
                                        <DataSource OnEvent="CustAccountLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout23">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientAccountId" ObjectId="201400028" UniqueName="new_RecipientAccountId" Hidden="false"
                                    Width="150" PageSize="50" FieldLabel="200" RequirementLevel="BusinessRequired" LookupViewUniqueName="AccountWithBalanceLookupView">
                                    <AjaxEvents>
                                        <Change OnEvent="AccountChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                    <DataContainer>
                                        <DataSource OnEvent="RecipientAccountLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_AccountTransactionTypeId" ObjectId="201400028" UniqueName="new_AccountTransactionTypeId" Hidden="false"
                                    Width="150" PageSize="50" FieldLabel="200" RequirementLevel="None">

                                    <DataContainer>
                                        <DataSource OnEvent="AccountTransactionTypeLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>


                     <rx:RowLayout runat="server" ID="RowLayout8">
                            <Body>
                             
                                <cc1:CrmComboComp runat="server" ID="new_CorporationSwiftInfo" ObjectId="202000004" UniqueName="RecipientSwiftAccountNo" Hidden="true"
                                    Width="500" PageSize="50" FieldLabel="200" LookupViewUniqueName="CorporationSwiftInfoList_Lookup" RequirementLevel="None"  >
                                    <DataContainer>
                                        <DataSource OnEvent="CorporationSwiftInfoLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                         <Change OnEvent="CorporationSwiftInfoChangeOnEvent">
                                         </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                             
                         </Body>
                        </rx:RowLayout>


                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientSwiftAccountNo" ObjectId="201400028" UniqueName="new_RecipientSwiftAccountNo" Hidden="true"
                                    Width="150" PageSize="50" FieldLabel="200" RequirementLevel="BusinessRequired">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <cc1:CrmTextAreaComp runat="server" ID="new_Explanation" ObjectId="201400028" Hidden="true"
                                    Width="150" PageSize="50"  UniqueName="new_Explanation" FieldLabel="200">
                                </cc1:CrmTextAreaComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout4">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>
                                <br />
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>

        <rx:Fieldset runat="server" ID="Fieldset3" AutoHeight="Normal" AutoWidth="true" CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout13">
                    <Rows>
                        <rx:RowLayout ID="RowLayout27" runat="server">
                            <Body>
                                <rx:MultiField ID="RxM" runat="server" AutoWidth="true">
                                    <Items>
                                        <cc1:CrmDecimalComp runat="server" ID="new_Amount" ObjectId="201400028" RequirementLevel="BusinessRequired"
                                            UniqueName="new_Amount" FieldLabelWidth="498" Width="100">
                                            <AjaxEvents>
                                                <Change OnEvent="AmountChangeOnEvent">
                                                </Change>
                                            </AjaxEvents>
                                        </cc1:CrmDecimalComp>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_SenderAccountCurrencyIdName" ObjectId="201400028" UniqueName="new_SenderAccountCurrencyIdName"
                                            ReadOnly="true" Width="50" FieldLabelShow="false">
                                            <AjaxEvents>
                                                <Change OnEvent="SenderAccountCurrencyChange">
                                                </Change>
                                            </AjaxEvents>
                                        </cc1:CrmTextFieldComp>
                                    </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout14">
                    <Rows>
                        <rx:RowLayout ID="RowLayout2" runat="server" ColSpan="2">
                            <Body>
                                <rx:MultiField ID="MultiField1" runat="server" AutoWidth="true">
                                    <Items>
                                        <cc1:CrmDecimalComp runat="server" ID="new_TransferedAmount" ObjectId="201400028" RequirementLevel="BusinessRequired"
                                            UniqueName="new_TransferedAmount" FieldLabelWidth="498" Width="100" ReadOnly="true">
                                        </cc1:CrmDecimalComp>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_RecipientAccountCurrencyIdName" ObjectId="201400028" UniqueName="new_RecipientAccountCurrencyIdName"
                                            ReadOnly="true" Width="50" FieldLabelShow="false">
                                        </cc1:CrmTextFieldComp>
                                    </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1">
                    <Rows>
                        <rx:RowLayout ID="RowLayout26" runat="server">
                            <Body>
                                <rx:MultiField ID="MultiField2" runat="server" AutoWidth="true">
                                    <Items>
                                        <cc1:CrmDecimalComp runat="server" ID="new_TransactionRate" ObjectId="201400028" RequirementLevel="BusinessRequired"
                                            UniqueName="new_TransactionRate" FieldLabelWidth="498" Width="157" ReadOnly="false">
                                            <AjaxEvents>
                                                <Change OnEvent="AmountChangeOnEvent">
                                                </Change>
                                            </AjaxEvents>
                                        </cc1:CrmDecimalComp>
                                    </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <%--<rx:ColumnLayout runat="server" ID="ColumnLayout33">
                    <Rows>
                        <rx:RowLayout ID="RowLayout134" runat="server">
                            <Body>
                                <rx:MultiField ID="MultiField3" runat="server" AutoWidth="true">
                                    <Items>
                                        <cc1:CrmDecimalComp runat="server" ID="new_TransactionCancelRate" ObjectId="201400028" RequirementLevel="BusinessRequired"
                                            UniqueName="new_TransactionCancelRate" FieldLabelWidth="498" Width="157" ReadOnly="false" Hidden="true">
                                        </cc1:CrmDecimalComp>
                                    </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>--%>
            </Body>
        </rx:Fieldset>

        <%-- Eft alanları --%>
        <rx:PanelX runat="server" ID="PanelEftDetail" AutoHeight="Full" AutoWidth="true" CustomCss="Section3" Collapsed="false" Collapsible="false" Border="true" Frame="true" Title="Talimat Bilgileri">
            <Body>
                <table width="100%">
                    <tr>
                        <td>
                            <rx:PanelX runat="server" ID="PanelEftSender" AutoHeight="Full" AutoWidth="true" CustomCss="Section3" Collapsed="false" Collapsible="false" Border="true" Frame="false" Title="Gönderene Ait Bilgiler">
                                <Body>
                                    <table width="100%">
                                        <tr>
                                            <td style="padding-left: 10px">
                                                <cc1:CrmTextFieldComp ID="new_EftSenderName" UniqueName="new_EftSenderName" runat="server" ObjectId="201400038" RequirementLevel="BusinessRequired" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmTextFieldComp>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 10px">
                                                <cc1:CrmTextFieldComp ID="new_EftSenderTCKN" UniqueName="new_EftSenderTCKN" runat="server" ObjectId="201400038" RequirementLevel="BusinessRequired" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmTextFieldComp>
                                            </td>
                                        </tr>
                                        <%--<tr>
                                            <td style="padding-left: 10px">
                                                <cc1:CrmPhoneFieldComp ID="new_EftSenderTelephone" UniqueName="new_EftSenderTelephone" runat="server" ObjectId="201400038" RequirementLevel="BusinessRequired" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmPhoneFieldComp>
                                            </td>
                                        </tr>--%>
                                    </table>
                                </Body>
                            </rx:PanelX>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <rx:PanelX runat="server" ID="PanelEftRecipient" AutoHeight="Full" AutoWidth="true" CustomCss="Section3" Collapsed="false" Collapsible="false" Border="true" Frame="false" Title="Alıcıya Ait Bilgiler">
                                <Body>
                                    <table width="100%">
                                        <tr>
                                            <td style="padding-left: 10px">
                                                <cc1:CrmTextFieldComp ID="new_EftRecipientName" UniqueName="new_EftRecipientName" runat="server" ObjectId="201400038" RequirementLevel="BusinessRequired" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmTextFieldComp>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 10px">
                                                <cc1:CrmComboComp ID="new_EftBank" ObjectId="201400038" RequirementLevel="BusinessRequired"
                                                    UniqueName="new_EftBank" runat="server" FieldLabel="200" FieldLabelWidth="498" Width="400" PageSize="50">
                                                    <AjaxEvents>
                                                        <Change OnEvent="EftBank2CityBranchReset"></Change>
                                                    </AjaxEvents>
                                                </cc1:CrmComboComp>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 10px">
                                                <cc1:CrmComboComp runat="server" ID="new_EftCityId" ObjectId="201400038" RequirementLevel="BusinessRequired" UniqueName="new_EftCityId"
                                                    FieldLabel="200" Width="400" FieldLabelWidth="498" PageSize="50" LookupViewUniqueName="EFT_BRACH_CITY"
                                                    ParentRequired="true">
                                                    <Filters>
                                                        <cc1:ComboFilter FromObjectId="201400038" FromUniqueName="new_EftBank" ToObjectId="201100089"
                                                            ToUniqueName="new_EftBankID" />
                                                    </Filters>
                                                    <AjaxEvents>
                                                        <Change OnEvent="EftCity2BranchReset"></Change>
                                                    </AjaxEvents>
                                                </cc1:CrmComboComp>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 10px">
                                                <cc1:CrmComboComp runat="server" ID="new_EftBranch" ObjectId="201400038" RequirementLevel="BusinessRequired" UniqueName="new_EftBranch"
                                                    FieldLabel="200" Width="400" FieldLabelWidth="498" PageSize="50">
                                                    <Filters>
                                                        <cc1:ComboFilter FromObjectId="201400038" FromUniqueName="new_EftBank" ToObjectId="201100089"
                                                            ToUniqueName="new_EftBankID" />
                                                        <cc1:ComboFilter FromObjectId="201400038" FromUniqueName="new_EftCityId" ToObjectId="201100089"
                                                            ToUniqueName="new_CityID" />
                                                    </Filters>
                                                </cc1:CrmComboComp>
                                            </td>
                                        </tr>
                                        <%--<tr>
                                            <td style="padding-left: 10px">
                                                <cc1:CrmTextFieldComp ID="new_EftRecipientFatherName" UniqueName="new_EftRecipientFatherName" runat="server" ObjectId="201400038" RequirementLevel="None" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmTextFieldComp>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 10px">
                                                <cc1:CrmDateFieldComp ID="new_EftRecipientBirth" UniqueName="new_EftRecipientBirth" runat="server" ObjectId="201400038" DateFormat="dd.MM.yyyy" RequirementLevel="None" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmDateFieldComp>
                                            </td>
                                        </tr>--%>
                                        <tr>
                                            <td style="padding-left: 10px">
                                                <cc1:CrmTextAreaComp ID="new_EftRecipientAdres" UniqueName="new_EftRecipientAdres" runat="server" ObjectId="201400038" RequirementLevel="None" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmTextAreaComp>
                                            </td>
                                        </tr>
                                        <%--<tr>
                                            <td style="padding-left: 10px">
                                                <cc1:CrmPhoneFieldComp runat="server" ID="new_EftRecipientTelephone" ObjectId="201400038" UniqueName="new_EftRecipientTelephone" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmPhoneFieldComp>
                                            </td>
                                        </tr>--%>
                                        <tr>
                                            <td style="padding-left: 10px">
                                                <cc1:CrmComboComp ID="new_EftPaymentType" ObjectId="201400038" RequirementLevel="BusinessRequired" UniqueName="new_EftPaymentType" runat="server" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmComboComp>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 10px">
                                                <cc1:CrmTextFieldComp ID="new_EftAmountText" runat="server" ObjectId="201400038" UniqueName="new_EftAmountText" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmTextFieldComp>
                                            </td>
                                        </tr>
                                    </table>
                                </Body>
                            </rx:PanelX>
                        </td>
                    </tr>
                </table>
            </Body>
        </rx:PanelX>

        <%--Swift Alanları--%>
        <rx:PanelX runat="server" ID="PanelSwiftDetail" AutoHeight="Full" AutoWidth="true" CustomCss="Section3" Collapsed="false" Collapsible="false" Border="true" Frame="true" Title="Talimat Bilgileri">
            <Body>
                <table width="100%">
                    <tr>
                        <td>
                            <rx:PanelX runat="server" ID="PanelX3" AutoHeight="Full" AutoWidth="true" CustomCss="Section3" Collapsed="false" Collapsible="false" Border="true" Frame="false" Title="Gönderene Ait Bilgiler">
                                <Body>
                                    <table width="100%">
                                        <tr>
                                            <td>
                                                <cc1:CrmTextFieldComp ID="new_SwfSenderName" runat="server" ObjectId="201400038" UniqueName="new_SwfSenderName" FieldLabel="200" FieldLabelWidth="498" Width="400" RequirementLevel="BusinessRequired">
                                                </cc1:CrmTextFieldComp>

                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <cc1:CrmTextFieldComp ID="new_SwfSenderAdres" runat="server" ObjectId="201400038" UniqueName="new_SwfSenderAdres" FieldLabel="200" FieldLabelWidth="498" Width="400" RequirementLevel="BusinessRequired">
                                                </cc1:CrmTextFieldComp>
                                            </td>
                                        </tr>
                                        <%--<tr>
                                            <td>
                                                <cc1:CrmTextFieldComp ID="new_SwfSenderTelephone" runat="server" ObjectId="201400038" UniqueName="new_SwfSenderTelephone" FieldLabel="200" FieldLabelWidth="498" Width="400" RequirementLevel="BusinessRequired">
                                                </cc1:CrmTextFieldComp>

                                            </td>
                                        </tr>--%>
                                        <tr>
                                            <td>
                                                <cc1:CrmTextFieldComp ID="new_SwfAmountText" runat="server" ObjectId="201400038" UniqueName="new_SwfAmountText" FieldLabel="200" FieldLabelWidth="498" Width="400" RequirementLevel="BusinessRequired">
                                                </cc1:CrmTextFieldComp>

                                            </td>
                                        </tr>
                                    </table>
                                </Body>
                            </rx:PanelX>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <rx:PanelX runat="server" ID="PanelX4" AutoHeight="Full" AutoWidth="true" CustomCss="Section3" Collapsed="false" Collapsible="false" Border="true" Frame="false" Title="Alıcıya Ait Bilgiler">
                                <Body>
                                    <table width="100%">
                                        <tr>
                                            <td>
                                                <cc1:CrmTextFieldComp ID="new_SwfRecipientName" runat="server" ObjectId="201400038" UniqueName="new_SwfRecipientName" FieldLabel="200" FieldLabelWidth="498" Width="400" RequirementLevel="BusinessRequired">
                                                </cc1:CrmTextFieldComp>

                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <cc1:CrmTextFieldComp ID="new_SwfRecipientAdres" runat="server" ObjectId="201400038" UniqueName="new_SwfRecipientAdres" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmTextFieldComp>

                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <cc1:CrmComboComp runat="server" ID="new_SwfBicCountry" ObjectId="201400038" UniqueName="new_SwfBicCountry"
                                                    PageSize="500" FieldLabel="200" FieldLabelWidth="498" Width="400" LookupViewUniqueName="NAKIT_ODEMEYAPABILEN_ULKELER"
                                                    Mode="Remote" RequirementLevel="BusinessRequired">
                                                    <AjaxEvents>
                                                        <Change OnEvent="SwfBicCountryOnChange"></Change>
                                                    </AjaxEvents>
                                                </cc1:CrmComboComp>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <rx:Hidden ID="new_BicBankHidden" runat="server"></rx:Hidden>
                                                <cc1:CrmComboComp runat="server" ID="new_SwfBicBank" ObjectId="201400038" UniqueName="new_SwfBicBank"
                                                    PageSize="50" FieldLabel="200" FieldLabelWidth="498" Width="400" LookupViewUniqueName="SWIFT_BANKS_LOOKUP"
                                                    RequirementLevel="BusinessRequired">
                                                    <Filters>
                                                        <cc1:ComboFilter FromObjectId="201400038" FromUniqueName="new_SwfBicCountry" ToObjectId="201300023"
                                                            ToUniqueName="new_Country" />
                                                    </Filters>
                                                    <AjaxEvents>
                                                        <Change OnEvent="SwfBicBankOnChange"></Change>
                                                    </AjaxEvents>
                                                </cc1:CrmComboComp>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <cc1:CrmComboComp runat="server" ID="new_SwfBicBankCity" ObjectId="201400038" UniqueName="new_SwfBicBankCity"
                                                    PageSize="50" FieldLabel="200" FieldLabelWidth="498" Width="400" LookupViewUniqueName="SWIFT_BANK_CITIES_LOOKUP"
                                                    RequirementLevel="BusinessRequired">
                                                    <Filters>
                                                        <cc1:ComboFilter FromObjectId="201400038" FromUniqueName="new_SwfBicCountry" ToObjectId="201300024"
                                                            ToUniqueName="new_Country" />
                                                        <cc1:ComboFilter FromObjectId="201400038" FromUniqueName="new_SwfBicBank" ToObjectId="201300024"
                                                            ToUniqueName="new_BicBank" />
                                                    </Filters>
                                                </cc1:CrmComboComp>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <rx:Hidden ID="new_SwfRecipientBranch" runat="server"></rx:Hidden>
                                                <%--<cc1:CrmComboComp runat="server" ID="new_SwfRecipientBranch" ObjectId="201400038" UniqueName="new_SwfRecipientBranch"
                                                    PageSize="50" FieldLabel="200" FieldLabelWidth="498" Width="400" LookupViewUniqueName="SWIFT_BANK_BRANCHES_LOOKUP">
                                                    <Filters>
                                                        <cc1:ComboFilter FromObjectId="201400038" FromUniqueName="new_SwfBicCountry" ToObjectId="201300022"
                                                            ToUniqueName="new_Country" />
                                                        <cc1:ComboFilter FromObjectId="201400038" FromUniqueName="new_SwfBicBank" ToObjectId="201300023"
                                                            ToUniqueName="new_BicBank" />
                                                        <cc1:ComboFilter FromObjectId="201400038" FromUniqueName="new_SwfBicBankCity" ToObjectId="201300022"
                                                            ToUniqueName="new_BicBankCity" />
                                                    </Filters>
                                                </cc1:CrmComboComp>--%>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <cc1:CrmTextFieldComp runat="server" ID="new_SwfBicCode" ObjectId="201400038" UniqueName="new_SwfBicCode" FieldLabel="200" FieldLabelWidth="498" Width="400" RequirementLevel="BusinessRequired">
                                                </cc1:CrmTextFieldComp>
                                            </td>
                                        </tr>
                                    </table>
                                </Body>
                            </rx:PanelX>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <rx:PanelX runat="server" ID="PanelX2" AutoHeight="Full" AutoWidth="true" CustomCss="Section3" Collapsed="false" Collapsible="false" Border="true" Frame="false" Title="Muhabir Banka Masrafları">
                                <Body>
                                    <table width="60%">
                                        <tr>
                                            <td>
                                                <cc1:CrmBooleanComp ID="new_IsSwfExpenseSender" runat="server" ObjectId="201400038" UniqueName="new_IsSwfExpenseSender" FieldLabel="200" FieldLabelWidth="200" RequirementLevel="BusinessRequired">
                                                    <AjaxEvents>
                                                        <Change OnEvent="SwfExpenseSenderOnChange"></Change>
                                                    </AjaxEvents>
                                                </cc1:CrmBooleanComp>
                                            </td>
                                            <td>
                                                <cc1:CrmBooleanComp ID="new_SwfExpenseRecipient" runat="server" ObjectId="201400038" UniqueName="new_SwfExpenseRecipient" FieldLabel="200" FieldLabelWidth="200">
                                                    <AjaxEvents>
                                                        <Change OnEvent="SwfExpenseRecipientOnChange"></Change>
                                                    </AjaxEvents>
                                                </cc1:CrmBooleanComp>
                                            </td>
                                        </tr>
                                    </table>
                                </Body>
                            </rx:PanelX>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <rx:PanelX runat="server" ID="PanelX5" AutoHeight="Full" AutoWidth="true" CustomCss="Section3" Collapsed="false" Collapsible="false" Border="true" Frame="false" Title="Açıklama">
                                <Body>
                                    <table width="60%">
                                        <tr>
                                            <td>
                                                <cc1:CrmBooleanComp ID="new_IsSwfGorunmeyenKalemTransfer" runat="server" ObjectId="201400038" UniqueName="new_IsSwfGorunmeyenKalemTransfer" FieldLabel="200" FieldLabelWidth="200" RequirementLevel="BusinessRequired"></cc1:CrmBooleanComp>
                                            </td>
                                            <td>
                                                <cc1:CrmBooleanComp ID="new_IsSwfCashImport" runat="server" ObjectId="201400038" UniqueName="new_IsSwfCashImport" FieldLabel="200" FieldLabelWidth="200"></cc1:CrmBooleanComp>
                                            </td>
                                        </tr>
                                    </table>
                                    <table width="100%">
                                        <tr>
                                            <td>
                                                <cc1:CrmTextFieldComp ID="new_SwfReference" runat="server" ObjectId="201400038" UniqueName="new_SwfReference" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmTextFieldComp>

                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <cc1:CrmDateFieldComp ID="new_SwfInvoiceDate" runat="server" ObjectId="201400038" UniqueName="new_SwfInvoiceDate" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmDateFieldComp>

                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <cc1:CrmTextFieldComp ID="new_SwfInvoiceNo" runat="server" ObjectId="201400038" UniqueName="new_SwfInvoiceNo" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmTextFieldComp>

                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <cc1:CrmTextFieldComp ID="new_SwfAttachments" runat="server" ObjectId="201400038" UniqueName="new_SwfAttachments" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                                </cc1:CrmTextFieldComp>

                                            </td>
                                        </tr>
                                    </table>
                                </Body>
                            </rx:PanelX>
                        </td>
                    </tr>
                </table>
            </Body>
        </rx:PanelX>

        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="0" AutoWidth="true"
            CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false" Frame="false">
            <Buttons>
                <rx:Button ID="btnSave" runat="server" Icon="Disk" Text="Kaydet" Width="100">
                    <AjaxEvents>
                        <Click OnEvent="btnSaveOnEvent">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                <%-- <rx:Button ID="btnVirementCancelRequest" runat="server" Icon="ArrowUndo" Text="Talimatı Geri Al" Width="150">
                    <AjaxEvents>
                        <Click OnEvent="VirementCancelRequestEvent">
                        </Click>
                    </AjaxEvents>
                </rx:Button>--%>
                <rx:Button ID="btnVirementCancel" runat="server" Icon="ArrowUndo" Text="Talimatı Geri Al" Width="150" Hidden="true">
                    <AjaxEvents>
                        <Click OnEvent="VirementCancelEvent" Before="return confirm('İşlemi iptal etmek istediğinizden emin misiniz?');">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                <rx:Button ID="btnVirementCancelConfirm" runat="server" Icon="Accept" Text="Talimatı İptalini Onayla" Width="150">
                    <AjaxEvents>
                        <Click OnEvent="VirementCancelConfirmEvent" Before="return confirm('İptal işlemini tamamlamak istediğinize emin misiniz?');">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                <rx:Button ID="btnVirementCancelUndo" runat="server" Icon="Decline" Text="Talimatı İptalini Reddet" Width="150">
                    <AjaxEvents>
                        <Click OnEvent="VirementCancelUndoEvent" Before="return confirm('İptal işlemini reddetmek istediğinize emin misiniz?');">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
    </form>
</body>
</html>

