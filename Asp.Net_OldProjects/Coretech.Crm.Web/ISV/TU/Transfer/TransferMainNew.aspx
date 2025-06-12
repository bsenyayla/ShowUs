<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false"
    Inherits="Transfer_TransferMainNew" CodeBehind="TransferMainNew.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">

    <title></title>

    <script src="../Js/Global.js"></script>
    <script src="JS/TransferMainFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script src="../Sender/Js/SenderFactory.js"></script>
    <script type="text/javascript">

        window.onload = function () {
            document.getElementById("_new_RecipientGSM").disabled = true;
            prepare_screen();
            
        }

        function prepare_screen() {
            Step1.show();
            Step2.hide();
            Step3.hide();
            Step4.hide();
            R.reSize();
        }

        function screen2() {
            Step1.hide();
            Step2.show();
            Step3.hide();
            Step4.hide();
            R.reSize();
        }

        function screen3() {
            Step1.hide();
            Step2.hide();
            Step3.show();
            Step4.hide();
            R.reSize();
        }

        function screen4() {
            Step1.hide();
            Step2.hide();
            Step3.hide();
            Step4.show();
            R.reSize();
        }

        function setSwiftCode(comboEl) {

            if (new_BicBankBranch.value == '') {
                new_BicCode.setValue('');
            }
            else {
                new_BicCode.setValue(new_BicBankBranch.selectedRecord.new_BicCode);
            }

        }

    </script>

    <style type="text/css">
    </style>

</head>
<body style="background-color: #F0F3F5">
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
        <rx:Hidden ID="HdnIntegrationSessionIdentity" runat="server" />
        <rx:Hidden ID="HdnPartnerExpense" runat="server" />
        <rx:Hidden ID="HdnPartnerExpenseCurrency" runat="server" />
        <rx:Hidden ID="HdnOwnOfficeCode" runat="server" />
        <rx:Hidden ID="HdnOfficeReferenceCode" runat="server" />
        <rx:Hidden ID="hdnRecipientAddressVisible" runat="server" />

        <rx:PanelX ID="Step1" runat="server" Hidden="false" Title="Kurum, Ülke, Döviz ve Tahsilat Tipi Tanımları" AutoHeight="Normal" Height="350" Padding="true" ContainerPadding="true">
            <Body>
                <rx:PanelX runat="server" ID="Fieldset2" AutoHeight="Normal" Height="50" AutoWidth="true"
                    CustomCss="" Collapsible="true" Border="false">
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
                </rx:PanelX>
                <rx:Fieldset runat="server" ID="FieldsetReason" AutoHeight="Normal" Height="50" AutoWidth="true"
                    CustomCss="Section1" Collapsible="false" Border="false">
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
                <rx:PanelX runat="server" ID="pnl" Height="300" AutoHeight="Normal" Border="false">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="100%">
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
                                                <Change Handler="new_TransactionTargetOptionID.clear(false,false);new_RecipientCorporationId.clear(false,false);" />
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
                                <rx:RowLayout runat="server" ID="RowLayout25">
                                    <Body>
                                        <rx:MultiField runat="server" ID="mfCustAccount1" FieldLabelShow="True" FieldLabelWidth="100">
                                            <Items>

                                                <cc1:CrmComboComp ID="new_CustAccountId" runat="server" ObjectId="201100072" UniqueName="new_CustAccountId"
                                                    FieldLabelWidth="250" Width="200" PageSize="50" Disabled="true" Hidden="true">

                                                    <%--                                    <AjaxEvents>
                                                        <Change OnEvent="new_CustAccountId_OnChange">
                                                        </Change>
                                                    </AjaxEvents>--%>
                                                </cc1:CrmComboComp>



                                                <cc1:CrmComboComp ID="new_SenderPersonId" runat="server" ObjectId="201100072" UniqueName="new_SenderPersonId"
                                                    FieldLabelWidth="130" Width="200" PageSize="50" Disabled="true" Hidden="true">

                                                    <%--                                    <AjaxEvents>
                                                        <Change OnEvent="new_CustAccountId_OnChange">
                                                        </Change>
                                                    </AjaxEvents>--%>
                                                </cc1:CrmComboComp>

                                                <rx:Button runat="server" ID="BtnSenderPersonInfo" Icon="UserHome" Text="SenderPersonInfo" Hidden="true"
                                                    Width="75" Visible="true">
                                                    <AjaxEvents>
                                                        <Click OnEvent="new_SenderPersonInformation_Click">
                                                        </Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Items>
                                        </rx:MultiField>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>
                <rx:Window ID="OfisPopup" runat="server" Width="900" Height="500" Modal="true"
                    Border="false" Closable="true" Maximizable="false" Resizable="true" CloseAction="Hide"
                    ShowOnLoad="false" Title="Offis" Url="~/ISV/TU/Payment/PaymentLocations.aspx">
                </rx:Window>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="NextSender" Icon="PlayGreen" Text="Gönderici İşlemlerine Git">
                    <Listeners>
                        <Click Handler="screen2();"></Click>
                    </Listeners>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
        <rx:PanelX ID="Step2" runat="server" Hidden="true" Title="Gönderici Tanımları" AutoHeight="Normal" Height="600">
            <Body>
                <rx:Window ID="SenderPersonInfo" runat="server" Width="900" Height="700" Modal="true"
                    Border="false" Closable="true" Maximizable="false" Resizable="true" CloseAction="Hide"
                    ShowOnLoad="false">
                    <Body>
                        <rx:PanelX runat="server" ID="Panel_SenderPersonInformation" AutoHeight="Normal" Height="600" AutoWidth="true"
                            CustomCss="Section2" Title="Sender Person Information" Collapsed="false" Collapsible="true"
                            Border="false">
                            <AutoLoad Url="about:blank" />
                            <Body>
                            </Body>
                        </rx:PanelX>
                    </Body>
                </rx:Window>

                <rx:PanelX runat="server" ID="Panel_SenderInformation" AutoHeight="Normal" Height="360" AutoWidth="true"
                    CustomCss="Section2" Title="Sender Information" Collapsed="false" Collapsible="true"
                    Border="false">
                    <AutoLoad Url="about:blank" />
                    <Body>
                    </Body>
                </rx:PanelX>

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

                <rx:Fieldset runat="server" ID="Fieldset1" AutoHeight="Normal" Height="130" AutoWidth="true"
                     Collapsed="false" Collapsible="false" Border="false">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout15" ColumnWidth="100%" Height="130">
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
                                                <DataSource OnEvent="new_CountryIdentificationTypeLoad">
                                                </DataSource>
                                            </DataContainer>
                                        </cc1:CrmComboComp>

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

                                <rx:RowLayout runat="server" ID="RowLayout18">
                                    <Body>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdentificationCardNo" ObjectId="201100072"
                                            RequirementLevel="BusinessRequired" UniqueName="new_SenderIdentificationCardNo"
                                            FieldLabel="200">
                                        </cc1:CrmTextFieldComp>
                                        <cc1:CrmComboComp runat="server" ID="new_TransferReasonID" ObjectId="201100072" UniqueName="new_TransferReasonID"
                                            RequirementLevel="BusinessRequired" Width="150" PageSize="50" FieldLabel="200"
                                            LookupViewUniqueName="GONDERIMNEDENILOOKUP">
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

                                <rx:RowLayout runat="server" ID="RowLayout27">
                                    <Body>
                                        <cc1:CrmBooleanComp runat="server" RequirementLevel="BusinessRequired" ObjectId="201100075" FieldLabelWidth="100"
                                            ID="new_IdentityWasSeen" UniqueName="new_IdentityWasSeen" />
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>




                    </Body>
                </rx:Fieldset>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="BtnFirstPage" Icon="PreviousGreen" Text="Kurum, Ülke, Döviz ve Tahsilat Tipi Tanımlarına Dön">
                    <Listeners>
                        <Click Handler="prepare_screen();"></Click>
                    </Listeners>
                </rx:Button>
                <rx:Button runat="server" ID="NextRecipient" Icon="PlayGreen" Text="Alıcı Bilgileri ve Diğer İşlemlere Git">
                    <Listeners>
                        <Click Handler="screen3();"></Click>
                    </Listeners>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
        <rx:PanelX ID="Step3" runat="server" Hidden="true" Title="Alıcı Bilgileri ve Diğer Tanımlar" AutoHeight="Normal" Height="600">
            <Body>
                <rx:Fieldset runat="server" ID="PanelX3" AutoHeight="Normal" Height="550" AutoWidth="true"
                    CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="100%">
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
                                        <cc1:CrmComboComp runat="server" ID="new_EftBank" ObjectId="201100072" UniqueName="new_EftBank"
                                            Width="150" PageSize="50" FieldLabel="200">
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
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout8">
                                    <Body>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_RecipientMotherName" ObjectId="201100072"
                                            RequirementLevel="None" UniqueName="new_RecipientMotherName" FieldLabel="200">
                                        </cc1:CrmTextFieldComp>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_RecipientFatherName" ObjectId="201100072"
                                            RequirementLevel="None" UniqueName="new_RecipientFatherName" FieldLabel="200">
                                        </cc1:CrmTextFieldComp>
                                        <%--<cc1:CrmTextFieldComp runat="server" ID="new_RecipientHomeTelephone" ObjectId="201100072"
                                                                  UniqueName="new_RecipientHomeTelephone" FieldLabel="200">
                                        </cc1:CrmTextFieldComp>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_RecipientWorkTelephone" ObjectId="201100072"
                                                              UniqueName="new_RecipientWorkTelephone" FieldLabel="200">
                                        </cc1:CrmTextFieldComp>--%>
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
                                    </Body>
                                </rx:RowLayout>
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
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="0%">
                            <Rows>
                                
                            </Rows>
                        </rx:ColumnLayout>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="0%">
                            <Rows>
                                
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:Fieldset>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="Button1" Icon="PreviousGreen" Text="Alıcı Bilgileri ve Diğer İşlemlere Geri Dön">
                    <Listeners>
                        <Click Handler="screen2();"></Click>
                    </Listeners>
                </rx:Button>
                <rx:Button runat="server" ID="NextMoney" Icon="PlayGreen" Text="Parasal İşlemlere Git">
                    <Listeners>
                        <Click Handler="screen4();"></Click>
                    </Listeners>
                </rx:Button>
            </Buttons>




        </rx:PanelX>
        <rx:PanelX ID="Step4" runat="server" Hidden="true" Title="Parasal İşlemler" AutoHeight="Normal" Height="130">
            <Body>
                <rx:Fieldset runat="server" ID="PanelX4" AutoHeight="Normal" Height="120" AutoWidth="true"
                    Collapsed="false" Collapsible="false" Border="false" CustomCss="Section3">
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
                                        <cc1:CrmMoneyComp runat="server" ID="new_ReceivedPaymentAmount" UniqueName="new_ReceivedPaymentAmount"
                                            ObjectId="201100072" Disabled="true">
                                            <Items>
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
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="Button2" Icon="PreviousGreen" Text="Parasal İşlemlere Geri Dön">
                    <Listeners>
                        <Click Handler="screen3();"></Click>
                    </Listeners>
                </rx:Button>
                <rx:Button ID="btnSave" runat="server" Icon="Disk" Text="Kaydet" Width="100" CssClass="btn btn-danger">
                    <AjaxEvents>

                        <Click OnEvent="btnSaveOnEvent" Before="ValidateBeforeSave(msg,e);var email = document.getElementById('_new_RecipientEmail').value;
IsValidEmail(msg,e,email);">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>


        <rx:Window ID="wPersonalSecurity" runat="server" Width="1000" Height="700" Modal="true" Maximized="false"
            CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
            CloseAction="Hide" ShowOnLoad="false">
            <Body>
                <rx:PanelX runat="server" ID="pPersonalSecurity" Width="1000" Height="700" AutoHeight="Normal"
                    CustomCss="Section2" Title="" Collapsed="false" Collapsible="true"
                    Border="false">
                    <AutoLoad Url="about:blank" />
                    <Body>
                    </Body>
                </rx:PanelX>
            </Body>
        </rx:Window>

        <rx:Fieldset runat="server" ID="PanelX5" AutoHeight="Normal" Height="40" AutoWidth="true"
            Hidden="True" CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false">
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
