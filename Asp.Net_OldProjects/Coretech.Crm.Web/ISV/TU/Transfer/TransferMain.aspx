<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false"
    Inherits="Transfer_TransferMain" CodeBehind="TransferMain.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <style type="text/css">
        #lbl_new_SenderIdentificationCardNo {
            white-space: normal !important;
        }

        #lbl_new_AmountCurrency2 {
            white-space: normal !important;
        }

        #lbl_new_SenderIdentificationCardTypeID {
            white-space: normal !important;
        }

        #lbl_new_IdentityWasSeen {
            white-space: normal !important;
        }


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
            width: 500px;
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
    <title></title>
    <script src="JS/TransferMainFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script src="../Sender/Js/SenderFactory.js" type="text/ecmascript"></script>
    <script src="../Profession/Profession.js" type="text/javascript"></script>
    <script src="../CustAccount/Js/OtpControl.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script type="text/javascript">


        function setSwiftCode(comboEl) {

            if (new_BicBankBranch.value == '') {
                new_BicCode.setValue('');
            }
            else {
                new_BicCode.setValue(new_BicBankBranch.selectedRecord.new_BicCode);
            }

        }



    </script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="New_TransferId" runat="server" />
        <rx:Hidden ID="TransferTuRef" runat="server" />
        <rx:Hidden ID="IsPreAuthorized" runat="server" />
        <rx:Hidden ID="new_ReceivedPaymentAmountParity" runat="server" />
        <rx:Hidden ID="new_ReceivedPaymentOriginalAmountParity" runat="server" />
        <rx:Hidden ID="new_CustChargeAmount" runat="server" />
        <rx:Hidden ID="new_ReceivedPaymentAmountParityRateType" runat="server" />
        <rx:Hidden ID="new_CalculatedExpenseAmountDefaultValue" runat="server" />
        <rx:Hidden ID="new_CalculatedExpenseCurrencyDefaultValue" runat="server" />
        <rx:Hidden ID="new_UserCostReductionRate" runat="server" />
        <rx:Hidden ID="HdnStartTransactionForOtherCorp" runat="server" />
        <rx:Hidden ID="HdnOtherSerderCorporationUserId" runat="server" />
        <rx:Hidden ID="ExternalPreAuthorizeSenderId" runat="server" />
        <rx:Hidden ID="HdnIsPersonalSecuritySeen" runat="server" />
        <rx:Hidden ID="HdnIsOtpConfirmed" runat="server" />
        <rx:Hidden ID="HdnIntegrationSessionIdentity" runat="server" />
        <rx:Hidden ID="HdnPartnerExpense" runat="server" />
        <rx:Hidden ID="HdnPartnerExpenseCurrency" runat="server" />
        <rx:Hidden ID="HdnOwnOfficeCode" runat="server" />
        <rx:Hidden ID="HdnOfficeReferenceCode" runat="server" />
        <rx:Hidden ID="hdnRecipientAddressVisible" runat="server" />
        <rx:Hidden ID="MainCurrency" runat="server" />
        <rx:Hidden ID="TerraPayQuoteId" runat="server" />
        <%--<rx:PanelX runat="server" ID="Fieldset2" AutoHeight="Normal" Height="35" AutoWidth="true"
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
                <rx:ColumnLayout runat="server" ID="ColumnLayout13" ColumnWidth="5%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout16">
                            <Body>
                                <rx:Button ID="btnInformation" runat="server" Download="True" Icon="Information"
                                    Text="" Width="0">
                                    <AjaxEvents>
                                        <Click OnEvent="btnInformationOnEvent">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>--%>
        <rx:Fieldset runat="server" ID="FieldsetReason" AutoHeight="Normal" Height="20" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout12">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_ConfirmReasonId" ObjectId="201100072" UniqueName="new_ConfirmReasonId"
                                    Width="150" ReadOnly="true" Mode="Remote" LookupViewUniqueName="CONFIRM_REASON_LOOKUP">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout19">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_ConfirmReasonDescription" ObjectId="201100072"
                                    UniqueName="new_ConfirmReasonDescription" Width="150" PageSize="50" FieldLabel="200"
                                    ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="pnl1" AutoHeight="Normal" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="50%">
                    <Rows>

                        <rx:RowLayout runat="server" ID="RowOptionalCorporation">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_OptionalCorporationId" ObjectId="201100072"
                                    UniqueName="new_OptionalCorporationId" Width="150"
                                    PageSize="500" FieldLabel="200" LookupViewUniqueName="OPTIONAL_CORPORATION_VIEW" RequirementLevel="BusinessRequired"
                                    Mode="Remote">
                                    <DataContainer>
                                        <DataSource OnEvent="new_OptionalCountryLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientCountryID" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientCountryID" Width="150"
                                    PageSize="500" FieldLabel="200" LookupViewUniqueName="NAKIT_ODEMEYAPABILEN_ULKELER"
                                    Mode="Remote">
                                    <DataContainer>
                                        <DataSource OnEvent="new_RecipientCountryLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <Listeners>
                                        <Change Handler="new_TransactionTargetOptionID.clear(false,false);new_RecipientCorporationId.clear(false,false);NkolayCheckField.clear(false,false);" />
                                    </Listeners>
                                    <AjaxEvents>
                                        <Change OnEvent="new_RecipientIDChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_TransactionTargetOptionID" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_TransactionTargetOptionID"
                                    Width="150" PageSize="50" FieldLabel="150" Mode="Remote">
                                    <DataContainer>
                                        <DataSource OnEvent="new_TransactionTargetOptionIDOnEvent">
                                        </DataSource>
                                    </DataContainer>
                                    <Listeners>
                                        <Change Handler="new_AmountCurrency2.clear(false);new_RecipientID.clear(false);new_RecipientCorporationId.clear(false,false);" />
                                    </Listeners>
                                    <AjaxEvents>
                                        <Change OnEvent="TransactionTargetOptionChange">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout runat="server" ID="RowLayout111">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientRegionId" ObjectId="201100072" UniqueName="new_RecipientRegionId" Hidden="true"
                                    LookupViewUniqueName="REGION_LOOKUP_VIEW" Width="150" PageSize="50" FieldLabel="200">
                                    <DataContainer>
                                        <DataSource OnEvent="new_RecipientRegionLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_RegionChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout runat="server" ID="RowLayout21">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientCityId" ObjectId="201100072" UniqueName="new_RecipientCityId" Hidden="true"
                                    LookupViewUniqueName="CITY_LOOKUP_VIEW" Width="150" PageSize="50" FieldLabel="200">
                                    <DataContainer>
                                        <DataSource OnEvent="new_RecipientCityLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_CityChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout20">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_BrandId" ObjectId="201100072" UniqueName="new_BrandId" Hidden="true"
                                    LookupViewUniqueName="BRAND_LOOKUP_VIEW" Width="150" PageSize="50" FieldLabel="200">
                                    <DataContainer>
                                        <DataSource OnEvent="new_RecipientBrandLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_BrandChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout22">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientOfficeId" ObjectId="201100072" UniqueName="new_RecipientOfficeId" Hidden="true"
                                    LookupViewUniqueName="OFFICE_LOOKUP_VIEW_FOR_TRANSFER" Width="150" PageSize="50" FieldLabel="200">
                                    <DataContainer>
                                        <DataSource OnEvent="new_LocationLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_LocationChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>

                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_AmountCurrency2" ObjectId="201100072" UniqueName="new_AmountCurrency"
                                    RequirementLevel="BusinessRequired" LookupViewUniqueName="OFFICE_CURRENCY_LOOKUP_HEDEF"
                                    Width="150" PageSize="50" FieldLabel="150">
                                    <DataContainer>
                                        <DataSource OnEvent="new_AmountCurrency2OnEvent">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_AmountCurrencyOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderID" ObjectId="201100072" UniqueName="new_SenderID"
                                    RequirementLevel="BusinessRequired" Disabled="true" Width="150" PageSize="50"
                                    FieldLabel="150">
                                    <AjaxEvents>
                                        <Change OnEvent="CalculateOnEvent">
                                        </Change>

                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout45">
                            <Body>
                                <rx:CheckField ID="Is3rdBankAccount" runat="server" AutoWidth="true" FieldLabel="Ucuncu Banka Hesapları">
                                    <AjaxEvents>
                                        <Change OnEvent="Is3rdBankAccountOnEvent">
                                        </Change>
                                    </AjaxEvents>

                                </rx:CheckField>

                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SourceTransactionTypeID" ObjectId="201100072"
                                    UniqueName="new_SourceTransactionTypeID" Width="150" PageSize="50" FieldLabel="200"
                                    RequirementLevel="BusinessRequired" LookupViewUniqueName="OFFICE_OPERATION_TYPE_SOURCE">
                                    <DataContainer>
                                        <DataSource OnEvent="SourceTransactionTypeLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="SourceTransactionTypeIDOnEvent"></Change>
                                    </AjaxEvents>

                                    <%--<Filters>
                                        <cc1:ComboFilter FromObjectId="201100072" FromUniqueName="new_OfficeID" ToObjectId="201100043"
                                            ToUniqueName="new_OfficeID" />
                                    </Filters>--%>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout23">
                            <Body>
                                <rx:Hidden runat="server" ID="new_RecipientCorporationIdHidden"></rx:Hidden>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientCorporationId" ObjectId="201100072" UniqueName="new_RecipientCorporationId" Hidden="false"
                                    Width="150" PageSize="50" FieldLabel="200" RequirementLevel="BusinessRequired" LookupViewUniqueName="CorpComboView">
                                    <DataContainer>
                                        <DataSource OnEvent="new_RecipientCorporationLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_CorporationChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>


                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>
                                <rx:Button runat="server" ID="btnPaymentPoints" Icon="Money" Text="PaymentPoints"
                                    Width="150" Visible="true">
                                    <AjaxEvents>
                                        <Click OnEvent="new_RecipientCountryID_Click">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>

        <rx:Window ID="OfisPopup" runat="server" Width="900" Height="500" Modal="true"
            Border="false" Closable="true" Maximizable="false" Resizable="true" CloseAction="Hide"
            ShowOnLoad="false" Title="Offis" Url="~/ISV/TU/Payment/PaymentLocations.aspx">
        </rx:Window>



        <rx:Window ID="SenderPersonInfo" runat="server" Width="900" Height="500" Modal="true"
            Border="false" Closable="true" Maximizable="false" Resizable="true" CloseAction="Hide"
            ShowOnLoad="false">
            <Body>
                <rx:PanelX runat="server" ID="Panel_SenderPersonInformation" AutoHeight="Normal" Height="400" AutoWidth="true"
                    CustomCss="Section2" Title="Sender Person Information" Collapsed="false" Collapsible="true"
                    Border="false">
                    <AutoLoad Url="about:blank" />
                    <Body>
                    </Body>
                </rx:PanelX>
            </Body>
        </rx:Window>

        <rx:Window ID="wRecipient" runat="server" Width="800" Height="400" Modal="true" Maximized="false"
            CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="true"
            CloseAction="Hide" ShowOnLoad="false">
            <Body>
                <rx:PanelX runat="server" ID="pRecipient" Width="800" Height="370" AutoHeight="Normal" CustomCss="Section2" Title="" Collapsed="false" Collapsible="true"
                    Border="false">
                    <Body>
                        <rx:GridPanel runat="server" ID="grpSender" AutoWidth="true" AutoHeight="Normal"
                            Height="320" Editable="false" Mode="Local" AutoLoad="false" Width="1200" AjaxPostable="true">

                            <DataContainer>
                            </DataContainer>
                            <ColumnModel>
                                <Columns>

                                    <rx:GridColumns Header="Id" ColumnId="0" DataIndex="New_SenderId" Hidden="true"></rx:GridColumns>
                                    <rx:GridColumns Header="new_IdendificationCardTypeID" ColumnId="1" DataIndex="new_IdendificationCardTypeID" Hidden="true"></rx:GridColumns>
                                    <rx:GridColumns Header="Gönderici" ColumnId="2" DataIndex="Sender" Width="250"></rx:GridColumns>
                                    <rx:GridColumns Header="Vatandaşlık No" ColumnId="3" DataIndex="new_SenderIdendificationNumber1" Width="100"></rx:GridColumns>
                                    <rx:GridColumns Header="Kimlik Tipi" ColumnId="4" DataIndex="new_IdendificationCardTypeIDName" Width="250"></rx:GridColumns>
                                    <rx:GridColumns Header="Kimlik No" ColumnId="5" DataIndex="new_IdentityNo" Width="100"></rx:GridColumns>

                                    <rx:GridColumns Header="new_FatherName" ColumnId="6" DataIndex="new_FatherName" Hidden="true"></rx:GridColumns>
                                    <rx:GridColumns Header="new_MotherName" ColumnId="7" DataIndex="new_MotherName" Hidden="true"></rx:GridColumns>
                                    <rx:GridColumns Header="new_BirthDate" ColumnId="8" DataIndex="new_BirthDate" Hidden="true"></rx:GridColumns>
                                    <rx:GridColumns Header="new_GSMCountryId" ColumnId="9" DataIndex="new_GSMCountryId" Hidden="true"></rx:GridColumns>

                                    <rx:GridColumns Header="new_GSM" ColumnId="10" DataIndex="new_GSM" Hidden="true"></rx:GridColumns>
                                    <rx:GridColumns Header="new_HomeAdress" ColumnId="11" DataIndex="new_HomeAdress" Hidden="true"></rx:GridColumns>
                                    <rx:GridColumns Header="new_NationalityID" ColumnId="12" DataIndex="new_NationalityID" Hidden="true"></rx:GridColumns>
                                      <rx:GridColumns Header="new_CorporationOfIdentity" ColumnId="13" DataIndex="new_CorporationOfIdentity" Hidden="true"></rx:GridColumns>

                                </Columns>
                            </ColumnModel>
                            <SelectionModel>
                                <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                                    <AjaxEvents>
                                        <RowDblClick OnEvent="SelectCustomer" />
                                    </AjaxEvents>
                                </rx:RowSelectionModel>
                            </SelectionModel>
                            <BottomBar>
                                <rx:PagingToolBar runat="server" ID="PagingToolBar2" Enabled="true" ControlId="grpSender">
                                    <Buttons>
                                    </Buttons>
                                </rx:PagingToolBar>
                            </BottomBar>
                            <LoadMask ShowMask="true" />
                        </rx:GridPanel>
                    </Body>
                </rx:PanelX>
            </Body>
        </rx:Window>

        <%--  
          
          <rx:PanelX runat="server" ID="Panel_SenderInformation" AutoHeight="Normal" Height="200" AutoWidth="true"
            CustomCss="Section2" Title="Sender Information" Collapsed="false" Collapsible="true"
            Border="false">
            <AutoLoad Url="about:blank" />
            <Body>
            </Body>
        </rx:PanelX>--%>

        <rx:Fieldset ID="SenderInformationFieldSet" runat="server" Height="230">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="30%">

                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout40">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountId"
                                    FieldLabelWidth="250" Width="200" PageSize="50" Disabled="true" Hidden="true">
                                    <DataContainer>
                                        <DataSource OnEvent="new_CustAccountIdLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_CustAccountId_OnChange">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout15">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountTypeId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountTypeId"
                                    FieldLabelWidth="100" Width="200" PageSize="50" Hidden="true">
                                    <AjaxEvents>
                                        <Change OnEvent="CustAccountTypeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp ID="Sender" runat="server" ObjectId="201100052"
                                    UniqueName="Sender" FieldLabel="200">
                                    <Listeners>
                                        <Blur Handler="new_RecipientID.focus();" />
                                    </Listeners>
                                </cc1:CrmTextFieldComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout16">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderNumber" runat="server" FieldLabel="200" ObjectId="201100052"
                                    UniqueName="new_SenderNumber" Width="150">
                                    <Listeners>
                                        <Blur Handler="if(!R.isEmpty(new_SenderNumber.getValue())){new_RecipientID.focus();}" />
                                    </Listeners>
                                </cc1:CrmTextFieldComp>

                                <cc1:CrmComboComp runat="server" ID="CrmComboComp1" ObjectId="201100072" UniqueName="new_SenderPersonId" Hidden="true" LookupViewUniqueName="SENDER_PERSON_LOOKUP"
                                    Width="150" PageSize="50" FieldLabel="150">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100072" FromUniqueName="new_SenderID" ToObjectId="201100072" ToUniqueName="new_SenderID" />
                                    </Filters>
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout27">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_IdentityNo" runat="server" ObjectId="201100052"
                                    UniqueName="new_IdentityNo" FieldLabel="200">
                                    <Listeners>
                                        <Blur Handler="parent.window.new_RecipientID.focus();" />
                                    </Listeners>
                                </cc1:CrmTextFieldComp>


                                <%--  <rx:MultiField runat="server" ID="mfCustAccount" FieldLabelShow="True" FieldLabelWidth="100" RequirementLevel="BusinessRecommend">
                                    <Items>
                                        <cc1:CrmComboComp ID="CrmComboComp2" runat="server" ObjectId="201500039" LookupViewUniqueName="CUSTACCOUNTS_LOOKUP" UniqueName="new_CustAccountId" RequirementLevel="BusinessRecommend"
                                            FieldLabelWidth="123" Width="200" PageSize="50">
                                            <DataContainer>
                                                <DataSource OnEvent="new_CustAccountId_OnEvent">
                                                </DataSource>
                                            </DataContainer>
                                            <AjaxEvents>
                                                <Change OnEvent="new_CustAccountId_OnChange">
                                                </Change>
                                            </AjaxEvents>
                                        </cc1:CrmComboComp>
                                        <cc1:CrmComboComp runat="server" Disabled="True" FieldLabelShow="False" Width="50" ID="new_CustAccountCurrencyId" ObjectId="201500039" UniqueName="new_CustAccountCurrencyId" LookupViewUniqueName="CURRENCY_TR" RequirementLevel="BusinessRequired">
                                        </cc1:CrmComboComp>
                                        <rx:TextField runat="server" ID="new_CustAccountBalance" Width="50" Disabled="True" />
                                    </Items>
                                </rx:MultiField>--%>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout28">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderIdendificationNumber1" runat="server" ObjectId="201100052"
                                    UniqueName="new_SenderIdendificationNumber1" FieldLabel="200">
                                    <Listeners>
                                        <Blur Handler="new_RecipientID.focus();" />
                                    </Listeners>
                                </cc1:CrmTextFieldComp>

                                <cc1:CrmTextFieldComp runat="server" ID="new_SenderTaxNo" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_SenderTaxNo" FieldLabel="200">
                                </cc1:CrmTextFieldComp>



                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout29">
                            <Body>&nbsp;</Body>
                        </rx:RowLayout>




                        <rx:RowLayout runat="server" ID="RowLayout30">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="column1234" ColumnWidth="25%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="row1234">
                                            <Body>
                                             
                                                     <rx:Button runat="server" ID="ToolbarButtonFind" Text="(F9)" Icon="MagnifierZoomIn" Width="110">
                                                         <AjaxEvents>
                                                             <Click OnEvent="ToolbarButtonFindClick">
                                                                 <EventMask ShowMask="true" />
                                                             </Click>
                                                         </AjaxEvents>
                                                     </rx:Button>

                                                </buttons>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>

                                <rx:ColumnLayout runat="server" ID="ColumnLayout18" ColumnWidth="37%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout33">
                                            <Body>
                                    
                                         <rx:Button runat="server" ID="btnSenderEditUpdate" Icon="UserEdit" Text="SenderEditUpdate" Width="150">
                                             <AjaxEvents>
                                                 <Click OnEvent="btnSenderEditUpdate_Click">
                                                 </Click>
                                             </AjaxEvents>
                                         </rx:Button></buttons>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>

                                <rx:ColumnLayout runat="server" ID="ColumnLayout19" ColumnWidth="18%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout34">
                                            <Body>
                                                 <rx:Button runat="server" ID="ToolbarButtonClear" Text="(Ctrl+F9)" Icon="Erase" Width="75">
                                                     <AjaxEvents>
                                                         <Click OnEvent="ToolbarButtonClear_Clear">
                                                         </Click>
                                                     </AjaxEvents>
                                                 </rx:Button></buttons>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout22" ColumnWidth="20%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout44">
                                            <Body>
                                                 <rx:Button runat="server" ID="ToolbarButtonCustomerDocument" Text="(Ctrl+F9)" Icon="Folder" Width="100" Hidden="true">
                                                     <AjaxEvents>
                                                         <Click OnEvent="ToolbarButtonCustomerDocument_Click">
                                                         </Click>
                                                     </AjaxEvents>
                                                 </rx:Button></buttons>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>

                <rx:ColumnLayout runat="server" ID="ColumnLayout13" ColumnWidth="70%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout35">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout1311" ColumnWidth="50%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout38">
                                            <Body>

                                                <cc1:CrmComboComp runat="server" ID="new_GSMCountryId" ObjectId="201100052"
                                                    RequirementLevel="None" UniqueName="new_GSMCountryId" Width="150"
                                                    LookupViewUniqueName="COUNTRYTELEPHONELOOKUP" PageSize="50" FieldLabel="200" Disabled="true">
                                                </cc1:CrmComboComp>
                                                <cc1:CrmPhoneFieldComp runat="server" ID="new_GSM" ObjectId="201100052"
                                                    UniqueName="new_GSM" RequirementLevel="None" FieldLabel="200" Disabled="true"
                                                    HiddenCountryCode="false">
                                                </cc1:CrmPhoneFieldComp>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout39">
                                            <Body>
                                                <%--  <cc1:CrmTextAreaComp ID="new_HomeAdress" runat="server" FieldLabel="200" ObjectId="201100052" Disabled="true"
                                                    UniqueName="new_HomeAdress"  Width="150">
                                                </cc1:CrmTextAreaComp>--%>

                                                <cc1:CrmTextAreaComp runat="server" ID="new_HomeAdress" ObjectId="201100052" Disabled="true"
                                                    UniqueName="new_HomeAdress" FieldLabel="200">
                                                </cc1:CrmTextAreaComp>

                                                <cc1:CrmTextFieldComp runat="server" ID="new_SenderZipCode" ObjectId="201100072"
                                                    RequirementLevel="BusinessRequired" UniqueName="new_SenderZipCode" FieldLabel="200">
                                                </cc1:CrmTextFieldComp>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>






                                <rx:ColumnLayout runat="server" ID="ColumnLayout17" ColumnWidth="50%">

                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout25">
                                            <Body>
                                                <cc1:CrmComboComp ID="new_SenderPersonId" runat="server" ObjectId="201100072" UniqueName="new_SenderPersonId" LookupViewUniqueName="SENDER_PERSON_LOOKUP"
                                                    FieldLabel="200" Width="200" PageSize="50" Disabled="true" Hidden="true">
                                                    <Filters>
                                                        <cc1:ComboFilter FromObjectId="201100072" FromUniqueName="new_SenderID" ToObjectId="201100052" ToUniqueName="New_SenderId" />
                                                    </Filters>
                                                    <AjaxEvents>
                                                        <Change OnEvent="new_SenderPersonId_OnChange">
                                                        </Change>
                                                    </AjaxEvents>
                                                </cc1:CrmComboComp>
                                            </Body>
                                        </rx:RowLayout>

                                        <rx:RowLayout runat="server" ID="RowLayout41">
                                            <Body>

                                                <rx:ColumnLayout runat="server" ID="ColumnLayout20" ColumnWidth="30%">
                                                    <Rows>
                                                        <rx:RowLayout runat="server" ID="RowLayout42">
                                                            <Body>

                                                                <rx:Button runat="server" ID="BtnSenderPersonInfo" Icon="UserHome" Text="SenderPersonInfo" Hidden="true"
                                                                    Width="110" Visible="true">
                                                                    <AjaxEvents>
                                                                        <Click OnEvent="new_SenderPersonInformation_Click">
                                                                        </Click>
                                                                    </AjaxEvents>
                                                                </rx:Button>

                                                            </Body>
                                                        </rx:RowLayout>
                                                    </Rows>
                                                </rx:ColumnLayout>

                                                <rx:ColumnLayout runat="server" ID="ColumnLayout21" ColumnWidth="30%">
                                                    <Rows>
                                                        <rx:RowLayout runat="server" ID="RowLayout43">
                                                            <Body>

                                                                <rx:Button runat="server" ID="btnSenderPersonCreate" Icon="UserHome" Text="SenderPersonCreate" Hidden="true"
                                                                    Width="110" Visible="true">
                                                                    <AjaxEvents>
                                                                        <Click OnEvent="new_SenderPersonCreate_Click">
                                                                        </Click>
                                                                    </AjaxEvents>
                                                                </rx:Button>
                                                            </Body>
                                                        </rx:RowLayout>
                                                    </Rows>
                                                </rx:ColumnLayout>
                                            </Body>
                                        </rx:RowLayout>

                                        <rx:RowLayout runat="server" ID="RowLayout31">
                                            <Body>
                                                <cc1:CrmTextFieldComp ID="new_FatherName" runat="server" FieldLabel="200" ObjectId="201100052" Disabled="true"
                                                    UniqueName="new_FatherName" Width="150">
                                                </cc1:CrmTextFieldComp>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout32">
                                            <Body>
                                                <cc1:CrmTextFieldComp ID="new_MotherName" runat="server" FieldLabel="200" ObjectId="201100052" Disabled="true"
                                                    UniqueName="new_MotherName" Width="150">
                                                </cc1:CrmTextFieldComp>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout37">
                                            <Body>
                                                <cc1:CrmDateFieldComp ID="new_BirthDate" runat="server" ObjectId="201100052" Disabled="true"
                                                    UniqueName="new_BirthDate" FieldLabel="200">
                                                </cc1:CrmDateFieldComp>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout36">
                                            <Body>
                                                <cc1:CrmComboComp runat="server" ID="new_NationalityID" ObjectId="201100052" UniqueName="new_NationalityID"
                                                    RequirementLevel="None" Disabled="true" Width="150" PageSize="50"
                                                    FieldLabel="150">
                                                </cc1:CrmComboComp>

                                            </Body>

                                        </rx:RowLayout>

                                          <rx:RowLayout runat="server" ID="RowLayout47">
                                            <Body>    
                                <cc1:CrmPicklistComp runat="server" ID="new_CorporationOfIdentity" ObjectId="201100052"
                                    UniqueName="new_CorporationOfIdentity" FieldLabel="200" Hidden="true" Disabled="true">
                                </cc1:CrmPicklistComp>
</Body>
                                              </rx:RowLayout>

                                    </Rows>
                                </rx:ColumnLayout>
                                <!-- Group Box Buttons -->
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>




        <rx:Fieldset ID="PersonalSecurityFieldSet" runat="server">
            <Body>
                <rx:CheckField ID="new_IsPersonalSecurity" runat="server" Width="30" />
                <rx:Label ID="lIsPersonalSecurity" runat="server" Text="Kişisel Verilerin Korunması Kanunu Aydınlatma ve Açık Rıza Metni ve Muvafakatnamesi alındı." />
                <rx:Button ID="bPersonalSecurity" runat="server" Text="Kişisel Verilerin Korunması Kanunu Aydınlatma ve Açık Rıza Metni ve Muvafakatnamesi formunun çıktısını almak için tıklayınız">
                    <AjaxEvents>
                        <Click OnEvent="OpenCustomerDataProtectionApplicationForm" />
                    </AjaxEvents>
                </rx:Button>
            </Body>
        </rx:Fieldset>

        <rx:Window ID="wPersonalSecurity" runat="server" Width="800" Height="600" Modal="true" Maximized="false"
            CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
            CloseAction="Hide" ShowOnLoad="false">
            <Body>
                <rx:PanelX runat="server" ID="pPersonalSecurity" Width="800" Height="600" AutoHeight="Normal"
                    CustomCss="Section2" Title="" Collapsed="false" Collapsible="true"
                    Border="false">
                    <AutoLoad Url="about:blank" />
                    <Body>
                    </Body>
                </rx:PanelX>
            </Body>
        </rx:Window>

      



        <rx:Fieldset runat="server" ID="PanelX3" AutoHeight="Normal" Height="280" AutoWidth="true"
            CustomCss="Section3" Collapsed="false" Collapsible="false" border="false">
            <Body>

                <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                

                                <rx:Hidden ID="isEFTHiddenField" runat="server" Value="false">
                                </rx:Hidden>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientID" ObjectId="201100072" UniqueName="new_RecipientID"
                                    Width="150" PageSize="50" FieldLabel="200">
                                    <DataContainer>
                                        <DataSource OnEvent="new_RecipientID2OnEvent">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change Success="if(!R.isEmpty(new_RecipientID.getValue())){if(!new_TestQuestionID.visible){ new_Amount.focus();}else{new_TestQuestionID.focus();}}"
                                            OnEvent="new_RecipientIDChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                                <cc1:CrmBooleanComp ID="new_IbanisNotKnown" runat="server" ObjectId="201100072" UniqueName="new_IbanisNotKnown">
                                    <AjaxEvents>
                                        <Click OnEvent="new_IbanisNotKnownOnEvent">
                                        </Click>
                                    </AjaxEvents>
                                </cc1:CrmBooleanComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientIBAN" ObjectId="201100072"
                                    UniqueName="new_RecipientIBAN" FieldLabel="200">
                                    <AjaxEvents>
                                        <Blur OnEvent="new_RecipientIBANOnChange">
                                        </Blur>
                                    </AjaxEvents>
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientBicIBAN" ObjectId="201100072"
                                    UniqueName="new_RecipientBicIBAN" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <rx:Hidden ID="new_BicBankHidden" runat="server"></rx:Hidden>
                                <cc1:CrmComboComp runat="server" ID="new_BicBank" ObjectId="201100072" UniqueName="new_BicBank"
                                    Width="150" PageSize="50" FieldLabel="200" LookupViewUniqueName="SWIFT_BANKS_LOOKUP">
                                    <DataContainer>
                                        <DataSource OnEvent="new_BicBankLoad" />
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="BicBankChanged"></Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                                <cc1:CrmComboComp runat="server" ID="new_BicBankCity" ObjectId="201100072" UniqueName="new_BicBankCity"
                                    Width="150" PageSize="50" FieldLabel="200" LookupViewUniqueName="SWIFT_BANK_CITIES_LOOKUP">
                                    <DataContainer>
                                        <DataSource OnEvent="new_BicBankCityLoad" />
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="BicBankCityChanged"></Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                               
                                <cc1:CrmComboComp runat="server" ID="new_BicBankBranch" ObjectId="201100072" UniqueName="new_BicBankBranch"
                                    Width="150" PageSize="50" FieldLabel="200" LookupViewUniqueName="SWIFT_BANK_BRANCHES_LOOKUP">
                                    <DataContainer>
                                        <DataSource OnEvent="new_BicBankBranchLoad" />
                                    </DataContainer>
                                    <Listeners>
                                        <Change Handler="setSwiftCode(el); " />
                                    </Listeners>
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_BicCode" ObjectId="201100072" UniqueName="new_BicCode"
                                    FieldLabel="200">
                                    <AjaxEvents>
                                        <Change OnEvent="new_BicCodeChanged" />
                                    </AjaxEvents>
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientBICCode" ObjectId="201100072" UniqueName="new_RecipientBICCode"
                                    FieldLabel="200">
                                    <AjaxEvents>
                                        <%--  <Change OnEvent="new_RecipentBicCodeChanged" />--%>
                                    </AjaxEvents>
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmComboComp runat="server" ID="new_EftBank" ObjectId="201100072" UniqueName="new_EftBank"
                                    Width="150" PageSize="50" FieldLabel="200" LookupViewUniqueName="EFT_BANKS_LOOKUP">
                                    <DataContainer>
                                        <DataSource OnEvent="new_EftBankLoad" />
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_RecipienNickNameOnEvent">
                                            <ExtraParams>
                                                <rx:Parameter Mode="Raw" Name="BankName" Value="new_EftBank.getRawValue()" />
                                                <rx:Parameter Mode="Raw" Name="Currency" Value="new_AmountCurrency2.getRawValue()" />
                                            </ExtraParams>
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                                <cc1:CrmComboComp runat="server" ID="new_EftCity" ObjectId="201100072" UniqueName="new_EftCity"
                                    Width="150" PageSize="50" FieldLabel="200" LookupViewUniqueName="EFT_BRACH_CITY"
                                    ParentRequired="true">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100072" FromUniqueName="new_EftBank" ToObjectId="201100089"
                                            ToUniqueName="new_EftBankID" />
                                    </Filters>
                                </cc1:CrmComboComp>
                                <cc1:CrmComboComp runat="server" ID="new_EftBranch" ObjectId="201100072" UniqueName="new_EftBranch"
                                    Width="150" PageSize="50" FieldLabel="200">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100072" FromUniqueName="new_EftBank" ToObjectId="201100089"
                                            ToUniqueName="new_EftBankID" />
                                        <cc1:ComboFilter FromObjectId="201100072" FromUniqueName="new_EftCity" ToObjectId="201100089"
                                            ToUniqueName="new_CityID" />
                                    </Filters>
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientAccountName" ObjectId="201100072"
                                    UniqueName="new_RecipientAccountName" FieldLabel="200" Hidden="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientAccountType" ObjectId="201100072" UniqueName="new_RecipientAccountType"
                                    Width="150" PageSize="50" FieldLabel="200" LookupViewUniqueName="INTEGRATION_INPUT_VALUE_LOOKUP" Hidden="true">
                                    <DataContainer>
                                        <DataSource OnEvent="RecipientAccountTypeLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientABACode" ObjectId="201100072"
                                    UniqueName="new_RecipientABACode" FieldLabel="200" Hidden="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmPicklistComp runat="server" ID="new_IntegrationRecipientType" ObjectId="201100072"
                                    UniqueName="new_IntegrationRecipientType" FieldLabel="200" Hidden="true">
                                </cc1:CrmPicklistComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientSortCode" ObjectId="201100072"
                                    UniqueName="new_RecipientSortCode" FieldLabel="200" Hidden="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientAccountNumber" ObjectId="201100072"
                                    UniqueName="new_RecipientAccountNumber" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientBicAccountNumber" ObjectId="201100072"
                                    UniqueName="new_RecipientAccountNumber" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_IntegrationRecipientRussianBicCode" ObjectId="201100072"
                                    UniqueName="new_IntegrationRecipientRussianBicCode" FieldLabel="200" Hidden="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_CorpSendAccountNumber" ObjectId="201100072"
                                    UniqueName="new_CorpSendAccountNumber" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientCardNumber" ObjectId="201100072"
                                    UniqueName="new_RecipientCardNumber" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_IntegrationRecipientTaxNumber" ObjectId="201100072"
                                    UniqueName="new_IntegrationRecipientTaxNumber" FieldLabel="200" Hidden="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_IntegrationRecipientRegistrationReasonCode" ObjectId="201100072"
                                    UniqueName="new_IntegrationRecipientRegistrationReasonCode" FieldLabel="200" Hidden="true">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmComboComp runat="server" ID="new_EftPaymentMethodID" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_EftPaymentMethodID" Width="150"
                                    PageSize="50" FieldLabel="200">
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientName" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientName" FieldLabel="200">
                                    <AjaxEvents>
                                        <Blur Before="if(new_RecipientName.oldValue!=new_RecipientName.getValue()) return true;else return false;"
                                            OnEvent="new_RecipienNickNameOnEvent">
                                            <ExtraParams>
                                                <rx:Parameter Mode="Raw" Name="BankName" Value="new_EftBank.getRawValue()" />
                                                <rx:Parameter Mode="Raw" Name="Currency" Value="new_AmountCurrency2.getRawValue()" />
                                            </ExtraParams>
                                        </Blur>
                                    </AjaxEvents>
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientMiddleName" ObjectId="201100072"
                                    RequirementLevel="None" UniqueName="new_RecipientMiddleName" FieldLabel="200">
                                    <AjaxEvents>
                                        <Blur Before="if(new_RecipientMiddleName.oldValue != new_RecipientMiddleName.getValue()) return true; else return false;"
                                            OnEvent="new_RecipienNickNameOnEvent">
                                            <ExtraParams>
                                                <rx:Parameter Mode="Raw" Name="BankName" Value="new_EftBank.getRawValue()" />
                                                <rx:Parameter Mode="Raw" Name="Currency" Value="new_AmountCurrency2.getRawValue()" />
                                            </ExtraParams>
                                        </Blur>
                                    </AjaxEvents>
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientLastName" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientLastName" FieldLabel="200">
                                    <AjaxEvents>
                                        <Blur Before="if(new_RecipientLastName.oldValue!=new_RecipientLastName.getValue()) return true;else return false;"
                                            OnEvent="new_RecipienNickNameOnEvent">
                                            <ExtraParams>
                                                <rx:Parameter Mode="Raw" Name="BankName" Value="new_EftBank.getRawValue()" />
                                                <rx:Parameter Mode="Raw" Name="Currency" Value="new_AmountCurrency2.getRawValue()" />
                                            </ExtraParams>
                                        </Blur>
                                    </AjaxEvents>
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientZipCode" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientZipCode" FieldLabel="200" Hidden="true">
                                </cc1:CrmTextFieldComp>
                                <rx:Button runat="server" ID="btnGetIbanInfo" Icon="Information" Text="GetIbanInfo" Hidden="true" Width="110" Visible="true">
                                    <AjaxEvents>
                                        <Click OnEvent="GetIbanInfo_Click">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout8">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientMotherName" ObjectId="201100072"
                                    RequirementLevel="None" UniqueName="new_RecipientMotherName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientFatherName" ObjectId="201100072"
                                    RequirementLevel="None" UniqueName="new_RecipientFatherName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>                        

                                  <cc1:CrmComboComp runat="server" ID="new_WallatOperatorId" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_WallatOperatorId" Width="150" Hidden="true"
                                    PageSize="50" FieldLabel="200">
                                        <DataContainer>
                                        <DataSource OnEvent="WallatOperatorLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>

                                <cc1:CrmComboComp runat="server" ID="new_RecipientGSMCountryId" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientGSMCountryId" Width="150"
                                    LookupViewUniqueName="COUNTRYTELEPHONELOOKUP" PageSize="50" FieldLabel="200">
                                </cc1:CrmComboComp>
                                <cc1:CrmPhoneFieldComp runat="server" ID="new_RecipientGSM" ObjectId="201100072"
                                    UniqueName="new_RecipientGSM" RequirementLevel="BusinessRequired" FieldLabel="200"
                                    HiddenCountryCode="false">
                                </cc1:CrmPhoneFieldComp>
                                <cc1:CrmDateFieldComp ID="new_RecipientBirthDate" runat="server" ObjectId="201100072"
                                    Hidden="true" UniqueName="new_RecipientBirthDate" FieldLabel="200">
                                </cc1:CrmDateFieldComp>
                                <cc1:CrmTextAreaComp runat="server" ID="new_RecipientAddress" ObjectId="201100072"
                                    Hidden="true" Height="80" UniqueName="new_RecipientAddress" FieldLabel="200">
                                </cc1:CrmTextAreaComp>

                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientCity" ObjectId="201100072"
                                    Hidden="true" UniqueName="new_RecipientCity" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientIdentificationCardNo" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientIdentificationCardNo" FieldLabel="200" Hidden="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout9">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipienNickName" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipienNickName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientEmail" ObjectId="201100072"
                                    UniqueName="new_RecipientEmail" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmComboComp runat="server" ID="new_TestQuestionID" ObjectId="201100072" Hidden="true"
                                    RequirementLevel="BusinessRequired" UniqueName="new_TestQuestionID" Width="150"
                                    LookupViewUniqueName="TESTSORUSULOOKUP" PageSize="50" FieldLabel="200">
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_TestQuestionReply" ObjectId="201100072"
                                    Hidden="true" RequirementLevel="BusinessRequired" UniqueName="new_TestQuestionReply"
                                    FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextAreaComp runat="server" ID="new_Explanation" ObjectId="201100072" UniqueName="new_Explanation" MaxLength="140"
                                    Height="80" FieldLabel="200">
                                </cc1:CrmTextAreaComp>

                                <cc1:CrmComboComp runat="server" ID="new_RecipientIdentificationCardTypeID" Hidden="true" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientIdentificationCardTypeID"
                                    LookupViewUniqueName="KIMLIKTIPILOOKUP_FILTERED" Width="400" PageSize="50" FieldLabel="400" ColumnLayoutLabelWidth="400">
                                    <DataContainer>
                                        <DataSource OnEvent="new_CountryRecipientIdentificationTypeLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>




            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="PanelX4" AutoHeight="Normal" Height="125" AutoWidth="true"
            Collapsed="false" Collapsible="false" border="false" CustomCss="Section3">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout10" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout10">
                            <Body>
                                <rx:Hidden ID="new_AmountOld" runat="server">
                                </rx:Hidden>
                                <cc1:CrmMoneyComp runat="server" ID="new_Amount" UniqueName="new_Amount" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired">

                                    <DecimalChange OnEvent="new_AmountOnChange">
                                    </DecimalChange>
                                </cc1:CrmMoneyComp>
                                <cc1:CrmMoneyComp runat="server" ID="new_CalculatedExpenseAmount" UniqueName="new_CalculatedExpenseAmount"
                                    ObjectId="201100072" RequirementLevel="BusinessRequired" Disabled="true">
                                    <DecimalChange OnEvent="new_AmountOnChange">
                                    </DecimalChange>
                                </cc1:CrmMoneyComp>
                                <cc1:CrmMoneyComp runat="server" ID="new_KambiyoAmount" UniqueName="new_KambiyoAmount"
                                    ObjectId="201100072" Disabled="true" Hidden="True">
                                </cc1:CrmMoneyComp>
                                <cc1:CrmMoneyComp runat="server" ID="new_ReceivedPaymentAmount" UniqueName="new_ReceivedPaymentAmount"
                                    ObjectId="201100072" Disabled="false">
                                      <DecimalChange OnEvent="new_ReceivedPaymentAmountOnChange">
                                    </DecimalChange>
                                    <Items>
                                    <%--    <rx:Button ID="btnReceivedPaymentAmountCalc" Text="Yerel Döviz Gir" runat="server">
                                            <AjaxEvents>
                                                <Click OnEvent="ReceivedPaymentAmountCalcOnEvent"></Click>
                                            </AjaxEvents>
                                        </rx:Button>--%>
                                        <rx:Label ID="Parity3" runat="server">
                                        </rx:Label>
                                    </Items>
                                </cc1:CrmMoneyComp>
                                <cc1:CrmMoneyComp runat="server" ID="new_ReceivedPaymentOriginalAmount" UniqueName="new_ReceivedPaymentOriginalAmount"
                                    ObjectId="201100072" Hidden="true">
                                    <Items>
                                        <rx:Label ID="Label1" runat="server">
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
                                    <DecimalChange OnEvent="CalculateOnEvent">
                                    </DecimalChange>
                                </cc1:CrmMoneyComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout11" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout11">
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
      
        
          <rx:Fieldset ID="SenderOtpFieldSet" runat="server">
            <Body>
                <rx:CheckField ID="new_IsOtpConfirm" runat="server" Width="30" />
                <rx:Button ID="btnSenderOtp" runat="server" Text="Otp Kontrolü İçin Tıklayınız">
                    <AjaxEvents>
                        <Click OnEvent="SenderOtpCheck" />
                    </AjaxEvents>
                </rx:Button>
            </Body>
        </rx:Fieldset>

        <rx:Window ID="otpControlWindow" runat="server" Width="400" Height="400" Modal="true"
            Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false"
            Title="OTP Kontrol Formu">
            <Body>
                <rx:PanelX ID="PanelX2" runat="server" BorderStyle="None" Width="400" Height="200" AutoHeight="Auto">
                    <AutoLoad Url="about:blank" />

                </rx:PanelX>
            </Body>

        </rx:Window>
        
        <rx:Fieldset runat="server" ID="Fieldset1" AutoHeight="Normal" Height="85" AutoWidth="true"
            CustomCss="Section3" Collapsed="false" Collapsible="false" border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout15" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout17">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderIdentificationCardTypeID" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_SenderIdentificationCardTypeID"
                                    LookupViewUniqueName="KIMLIKTIPILOOKUP_FILTERED" Width="400" PageSize="50" FieldLabel="400" ColumnLayoutLabelWidth="400">
                                    <%--                                    <Listeners>
                                        <Change Handler="SetIdentificationValidDate();" />
                                    </Listeners>--%>
                                    <DataContainer>
                                        <DataSource OnEvent="new_CountrySenderIdentificationTypeLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>

                                <br />
                                <br />

                                <cc1:CrmBooleanComp runat="server" RequirementLevel="BusinessRequired" ObjectId="201100075"
                                    ID="new_IdentityWasSeen" UniqueName="new_IdentityWasSeen" />



                                <cc1:CrmComboComp runat="server" ID="new_MoneySourceID" ObjectId="201100072" UniqueName="new_MoneySourceID"
                                    RequirementLevel="BusinessRequired" LookupViewUniqueName="PARANINKAYNAGILOOKUP"
                                    Editable="false" Width="150" PageSize="50" FieldLabel="200">
                                    <Listeners>
                                        <Blur Handler="var r = (new_MoneySourceID.selectedRecord.new_ExtCode == '0');new_MoneySourceOther.clear();new_MoneySourceOther.hide();new_MoneySourceOther.setRequirementLevel(0);if(r){new_MoneySourceOther.show();new_MoneySourceOther.setRequirementLevel(2);new_MoneySourceOther.focus();}" />
                                    </Listeners>
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_MoneySourceOther" ObjectId="201100072"
                                    RequirementLevel="None" UniqueName="new_MoneySourceOther" Hidden="true" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
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
                                    FieldLabelWidth="250" Width="200" CssClass="CustomLabel">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmComboComp runat="server" ID="new_TransferReasonID" ObjectId="201100072" UniqueName="new_TransferReasonID"
                                    RequirementLevel="BusinessRequired" Width="150" PageSize="50" FieldLabel="200"
                                    LookupViewUniqueName="GONDERIMNEDENILOOKUP">
                                    <DataContainer>
                                        <DataSource OnEvent="new_TransferReasonLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <Listeners>
                                        <Blur Handler="var r = (new_TransferReasonID.selectedRecord.new_ExtCode == '0000');new_TransferReasonOther.clear();new_TransferReasonOther.hide();if(r){new_TransferReasonOther.show();new_TransferReasonOther.focus();}" />
                                    </Listeners>
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_TransferReasonOther" ObjectId="201100072"
                                    RequirementLevel="None" UniqueName="new_TransferReasonOther" Hidden="true" FieldLabel="200">
                                </cc1:CrmTextFieldComp>

                                <cc1:CrmTextFieldComp runat="server" ID="hdnnew_NationalityID" ObjectId="201100052" UniqueName="new_NationalityID"
                                    RequirementLevel="None" Hidden="true" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                          
                               
                     
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>


                <rx:ColumnLayout runat="server" ID="ColumnLayout14" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout26">
                            <Body>
                                <cc1:CrmDateFieldComp runat="server" ID="new_ValidDateOfSenderIdentificationCard"
                                    UniqueName="new_ValidDateOfSenderIdentificationCard" ObjectId="201100072" RequirementLevel="BusinessRequired" />
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout24">
                            <Body>
                                <cc1:CrmDateFieldComp runat="server" ID="new_DateOfIdendity"
                                    UniqueName="new_DateOfIdendity" ObjectId="201100072" RequirementLevel="BusinessRequired" />
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout46">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_SenderRecipientRelationship" ObjectId="201100072"
                                    UniqueName="new_SenderRecipientRelationship" FieldLabel="200" Hidden="true">
                                </cc1:CrmPicklistComp>
                                <cc1:CrmPicklistComp runat="server" ID="new_SenderSourceFunds" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" Hidden="true" UniqueName="new_SenderSourceFunds" FieldLabel="200">
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                       
                         
                    </Rows>
                </rx:ColumnLayout>

            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="PanelX5" AutoHeight="Normal" Height="40" AutoWidth="true"
            Hidden="True" CustomCss="Section3" Collapsed="false" Collapsible="false" border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout13">
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
                <rx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout14">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_CorporationID" UniqueName="new_CorporationID"
                                    ObjectId="201100072" ReadOnly="true" />
                                <cc1:CrmComboComp runat="server" ID="new_TargetTransactionTypeID" ReadOnly="true"
                                    UniqueName="new_TargetTransactionTypeID" ObjectId="201100072" LookupViewUniqueName="TRANSACTIONTYPELOOKUP" />
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="0" AutoWidth="true"
            customcss="Section3" Collapsed="false" Collapsible="false" Border="false" Frame="false">
            <Buttons>
                <rx:Button ID="btnSave" runat="server" Icon="Disk" Text="Kaydet" Width="100">
                    <AjaxEvents>
                        <Click OnEvent="btnSaveOnEvent" Before="ValidateBeforeSave(msg,e);var email = document.getElementById('_new_RecipientEmail').value;IsValidEmail(msg,e,email);">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>

        <rx:Window ID="ProfessionWindow" runat="server" Width="400" Height="400" Modal="true"
            Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false"
            Title="Meslek Kontrol Formu">
            <Body>
                <rx:PanelX ID="pnlMain" runat="server" BorderStyle="None" Width="400" Height="400" AutoHeight="Auto">
                    <AutoLoad Url="about:blank" />

                </rx:PanelX>
            </Body>
        </rx:Window>
        
        
    </form>
</body>
</html>
