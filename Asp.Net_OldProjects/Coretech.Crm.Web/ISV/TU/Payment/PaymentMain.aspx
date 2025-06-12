<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false" Inherits="Payment_PaymentMain" CodeBehind="PaymentMain.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
    <script src="JS/PaymentPageFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script type="text/javascript">

</script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="New_PaymentId" runat="server" />
        <rx:Hidden ID="PaymentTuRef" runat="server" />
        <rx:Hidden ID="new_PaidByOffice" runat="server" />
        <rx:Hidden ID="new_CountryId" runat="server" />
        <rx:Hidden ID="new_PaidByCorporation" runat="server" />

        <rx:Hidden ID="hdnRecipientName" runat="server" />
        <rx:Hidden ID="hdnRecipientLastName" runat="server" />
        <rx:Hidden ID="hdnRecipientIdentificationCardNumber" runat="server" />
        <rx:Hidden ID="hdnMobilePhone" runat="server" />
        <rx:Hidden ID="hdnRecipientFullName" runat="server"></rx:Hidden>
        <rx:Hidden ID="HdnIsPersonalSecuritySeen" runat="server" />
        <rx:Hidden ID="hdnIsPersonelSecurityControl" runat="server" />

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
                <rx:ColumnLayout runat="server" ID="ColumnLayout13" ColumnWidth="5%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout16">
                            <Body>
                                <rx:Button ID="btnInformation" runat="server" Icon="Information" Text="" Width="0">
                                </rx:Button>
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
                                <cc1:CrmLabelField ID="new_SenderId" runat="server" ObjectId="201100075" Disabled="true"
                                    UniqueName="new_SenderId" Width="300" />
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="pnlPayment" AutoHeight="Normal" Height="120" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout29">
                            <Body>
                                <cc1:CrmLabelField ID="new_SenderCountryId" runat="server" ObjectId="201100075" UniqueName="new_SenderCountryId"
                                    Disabled="true" />
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmLabelField ID="new_TransferAmount" runat="server" ObjectId="201100075" Disabled="true"
                                    UniqueName="new_TransferAmount" />
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <cc1:CrmLabelField ID="new_ExpenseAmount" runat="server" ObjectId="201100075" Disabled="true"
                                    UniqueName="new_ExpenseAmount" />
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmLabelField ID="new_TotalPayableAmount" runat="server" ObjectId="201100075"
                                    Disabled="true" Hidden="true" UniqueName="new_TotalPayableAmount" />
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
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="60%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <cc1:CrmLabelField ID="new_TransferID" runat="server" ObjectId="201100075" UniqueName="new_TransferID"
                                    Disabled="true" />
                                <rx:MultiField ID="RxM" runat="server" Width="200" FieldLabel="." RequirementLevel="BusinessRequired">
                                    <Items>
                                        <cc1:CrmPicklistComp runat="server" ID="new_PaymentMethod" Width="168" UniqueName="new_PaymentMethod"
                                            ObjectId="201100075" RequirementLevel="BusinessRequired" FieldLabelShow="false">
                                            <AjaxEvents>
                                                <Change OnEvent="new_PaymentMethodOnChange">
                                                </Change>
                                            </AjaxEvents>
                                        </cc1:CrmPicklistComp>
                                    </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout30">
                            <Body>
                                <cc1:CrmMoneyComp runat="server" ID="new_PaidAmount1" UniqueName="new_PaidAmount1"
                                    ObjectId="201100075" RequirementLevel="BusinessRequired" LookupViewUniqueName="OFFICE_CURRENCY_LOOKUP_PAYMENT">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100075" FromUniqueName="new_PaidByOffice" ToObjectId="201100043"
                                            ToUniqueName="new_OfficeID" />
                                    </Filters>
                                    <DecimalChange OnEvent="CalculateOnEvent">
                                    </DecimalChange>
                                    <ComboChange OnEvent="new_PaidAmount1CurrencyOnChange">
                                    </ComboChange>
                                    <Items>
                                        <rx:Label ID="Parity1" runat="server">
                                        </rx:Label>
                                    </Items>
                                </cc1:CrmMoneyComp>
                                <cc1:CrmMoneyComp runat="server" ID="new_PaidAmount2" UniqueName="new_PaidAmount2"
                                    ObjectId="201100075" RequirementLevel="BusinessRequired" LookupViewUniqueName="OFFICECURRENCYLOOKUPSOURCE">
                                    <Items>
                                        <rx:Label ID="Parity2" runat="server">
                                        </rx:Label>
                                    </Items>
                                </cc1:CrmMoneyComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <rx:Label runat="server" ID="l1" Text="&nbsp;">
                                </rx:Label>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server">
                            <Body>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="fsRecipientFullname" AutoHeight="Normal" AutoWidth="true" CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="fsRecipientFullname_cl1" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="fsRecipientFullname_rl11">
                            <Body>
                                <cc1:CrmLabelField ID="new_ReceipentFullname" runat="server" ObjectId="201100075"
                                    Disabled="true" UniqueName="new_ReceipentFullname" />
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="fsRecipientSearch" AutoHeight="Normal" AutoWidth="true" CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="fsRecipientSearch_cl1" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="fsRecipientSearch_rl11">
                            <Body>
                                <rx:Hidden runat="server" ID="hfRecipient" />
                                <rx:TextField runat="server" ID="tfRecipient" Width="100" FieldLabel="Alıcı" />
                                <rx:Label ID="lCustomerSearchInfo" runat="server" />
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="fsRecipientSearch_cl2" ColumnWidth="7%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="fsRecipientSearch_rl21">
                            <Body>
                                <rx:Button runat="server" ID="bRecipientSearch" Icon="Magnifier" Width="70">
                                    <AjaxEvents>
                                        <Click OnEvent="SearchCustomer" />
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="fsRecipientSearch_cl3" ColumnWidth="25%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="fsRecipientSearch_rl31">
                            <Body>
                                <rx:Button runat="server" ID="bNewCustomer" Text="Yeni Alıcı Oluştur" Icon="UserAdd" Width="150">
                                    <AjaxEvents>
                                        <Click OnEvent="NewCustomer" />
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>

        <rx:Window ID="wRecipient" runat="server" Width="800" Height="400" Modal="true" Maximized="false"
            CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
            CloseAction="Hide" ShowOnLoad="false">
            <Body>
                <rx:PanelX runat="server" ID="pRecipient" Width="800" Height="370" AutoHeight="Normal" CustomCss="Section2" Title="" Collapsed="false" Collapsible="true"
                    Border="false">
                    <Body>
                        <rx:GridPanel runat="server" ID="gpRecipients" AutoWidth="true" Editable="false" Mode="Local" AutoLoad="false" AjaxPostable="true">
                            <ColumnModel>
                                <Columns>
                                    <rx:GridColumns Header="Id" ColumnId="0" DataIndex="CustomerId" Hidden="true"></rx:GridColumns>
                                    <rx:GridColumns Header="AD SOYAD" ColumnId="1" DataIndex="Fullname" Width="250"></rx:GridColumns>
                                    <rx:GridColumns Header="UYRUK" ColumnId="2" DataIndex="Nationality" Width="125"></rx:GridColumns>
                                    <rx:GridColumns Header="VATANDAŞLIK NO" ColumnId="3" DataIndex="CitizenshipNumber" Width="100"></rx:GridColumns>
                                    <rx:GridColumns Header="KİMLİK TİPİ" ColumnId="4" DataIndex="IdentityCardType" Width="125"></rx:GridColumns>
                                    <rx:GridColumns Header="KİMLİK NO" ColumnId="5" DataIndex="IdentityNumber" Width="100"></rx:GridColumns>
                                </Columns>
                            </ColumnModel>
                            <SelectionModel>
                                <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                                    <AjaxEvents>
                                        <RowDblClick OnEvent="SelectCustomer" />
                                    </AjaxEvents>
                                </rx:RowSelectionModel>
                            </SelectionModel>
                        </rx:GridPanel>
                    </Body>
                </rx:PanelX>
            </Body>
        </rx:Window>


        <rx:Fieldset runat="server" ID="pnlAlici" AutoHeight="Normal" Height="185" AutoWidth="true" CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout11">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_NationalityID" ObjectId="201100075" RequirementLevel="BusinessRequired"
                                    UniqueName="new_NationalityID" LookupViewUniqueName="NATIONALITY_LOOKUP" Width="150"
                                    PageSize="50" FieldLabel="200">
                                    <Listeners>
                                        <Change Handler="SetNationality();" />
                                    </Listeners>
                                     <AjaxEvents>
                                                <Change OnEvent="new_NationalityIDOnChange">
                                                </Change>
                                            </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout12">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientIdentificationCardNumber" ObjectId="201100075"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientIdentificationCardNumber"
                                    FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout20">
                            <Body>
                                <rx:Button ID="btnKpsAps" runat="server" Icon="Accept" Text="KpsAps" Width="100">
                                    <Listeners>
                                        <Click Handler="SetKpsData();" />
                                    </Listeners>
                                    <%--<AjaxEvents>
                                    <Click OnEvent="btnKpsApsOnEvent">
                                    </Click>
                                </AjaxEvents>--%>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout22">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientName" ObjectId="201100075"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientMiddleName" ObjectId="201100075"
                                    RequirementLevel="None" UniqueName="new_RecipientMiddleName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout24">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientLastName" ObjectId="201100075"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientLastName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout13">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_FatherName" ObjectId="201100075"
                                    RequirementLevel="None" UniqueName="new_FatherName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout14">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_BirthPlace" ObjectId="201100075" RequirementLevel="BusinessRequired"
                                    UniqueName="new_BirthPlace" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout17">
                            <Body>
                                <cc1:CrmDateFieldComp runat="server" ID="new_Birthdate" ObjectId="201100075" UniqueName="new_Birthdate"
                                    RequirementLevel="BusinessRequired" />
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout21">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_GSMCountryId" ObjectId="201100075" RequirementLevel="BusinessRequired"
                                    UniqueName="new_GSMCountryId" Width="150" LookupViewUniqueName="COUNTRYTELEPHONELOOKUP"
                                    PageSize="50" FieldLabel="200">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout23">
                            <Body>
                                <cc1:CrmPhoneFieldComp runat="server" ID="new_MobilePhone" ObjectId="201100075" RequirementLevel="BusinessRequired"
                                    UniqueName="new_MobilePhone" Width="150" PageSize="50" FieldLabel="200" HiddenCountryCode="false">
                                </cc1:CrmPhoneFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout8" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_ProfessionID" runat="server" ObjectId="201100075" UniqueName="new_ProfessionId"
                                    FieldLabelWidth="100" Width="50" PageSize="50">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout18">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_MotherName" runat="server" ObjectId="201100075" UniqueName="new_MotherName" />
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout19">
                            <Body>
                                <cc1:CrmTextAreaComp runat="server" ID="new_Address" ObjectId="201100075" UniqueName="new_Address"
                                    FieldLabel="200" RequirementLevel="BusinessRequired">
                                </cc1:CrmTextAreaComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="pnlKimlik" AutoHeight="Normal" Height="60" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="33%" ColumnLayoutLabelWidth="40">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout25">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_IdentificatonCardTypeId" ObjectId="201100075"
                                    RequirementLevel="BusinessRequired" UniqueName="new_IdentificatonCardTypeId"
                                    LookupViewUniqueName="KIMLIKTIPILOOKUP_FILTERED" Width="150" PageSize="50" FieldLabel="200">
                                    <%--                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100075" FromUniqueName="new_CountryId" ToObjectId="201100049"
                                            ToUniqueName="new_CountryID" />
                                    </Filters>--%>
                                    <Listeners>
                                        <Change Handler="SetIdentificationValidDate();" />
                                    </Listeners>
                                    <DataContainer>
                                        <DataSource OnEvent="new_CountryIdentificationTypeLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                                <cc1:CrmBooleanComp runat="server" RequirementLevel="BusinessRequired" ObjectId="201100075"
                                    ID="new_IdentityWasSeen" UniqueName="new_IdentityWasSeen" />
                                <cc1:CrmBooleanComp runat="server" ID="new_CameFromKps" Hidden="True" ObjectId="201100075"
                                    UniqueName="new_CameFromKps" />
                                <cc1:CrmBooleanComp runat="server" ID="new_cameFromAps" Hidden="True" ObjectId="201100075"
                                    UniqueName="new_cameFromAps" />
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout27">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ObjectId="201100075" ID="new_IdentificatonCardTypeNo"
                                    RequirementLevel="BusinessRequired" UniqueName="new_IdentificatonCardTypeNo" />
                            </Body>
                        </rx:RowLayout>
                          <rx:RowLayout runat="server" ID="RowLayout26">
                            <Body>
                                <cc1:CrmDateFieldComp runat="server" ID="new_ValidDateOfIdendity" UniqueName="new_ValidDateOfIdendity"
                                    ObjectId="201100075" RequirementLevel="BusinessRequired" />
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
         
                 <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                    <Rows>
                         <rx:RowLayout runat="server" ID="RowLayout10">
                            <Body>
                                <cc1:CrmDateFieldComp runat="server" ID="new_DateOfIdentity" UniqueName="new_DateOfIdentity"
                                    ObjectId="201100075"/>
                            </Body>
                        </rx:RowLayout>
                               <rx:RowLayout runat="server" ID="RowLayout47">
                                            <Body>    
                                <cc1:CrmPicklistComp runat="server" ID="new_CorporationOfIdentity" ObjectId="201100075"
                                    UniqueName="new_CorporationOfIdentity">
                                </cc1:CrmPicklistComp>
</Body>
                                              </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
      
        <rx:Fieldset ID="PersonalSecurityFieldSet" runat="server">
            <Body>
                <rx:CheckField ID="new_IsPersonalSecurity" runat="server" Width="30" AutoWidth="true" FieldLabelWidth="10" FieldLabel="Müşteri, 6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında, veri sorumlusu UPT Ödeme Hizmetleri A.Ş.’ne verilerinin işlenmesi için Açık Rıza veriyor mu?" />
                <rx:Label ID="lIsPersonalSecurity" runat="server" Text="Kişisel Verilerin Korunması Kanunu Aydınlatma ve Açık Rıza Metni ve Muvafakatnamesi alındı." />
                <rx:Button ID="bPersonalSecurity" runat="server" Text="Kişisel Verilerin Korunması Kanunu Aydınlatma ve Açık Rıza Metni ve Muvafakatnamesi formunun çıktısını almak için tıklayınız">
                    <AjaxEvents>
                        <Click OnEvent="OpenCustomerDataProtectionApplicationForm" Before="ValidateBeforeSave(msg,e);" />
                    </AjaxEvents>
                </rx:Button>
            </Body>
        </rx:Fieldset>

        <%--        <rx:Fieldset ID="PersonalSecurityFieldSet" runat="server">
            <Body>
                <rx:CheckField ID="new_IsPersonalSecurity" runat="server" AutoWidth="true" FieldLabelWidth="800" FieldLabel="Müşteri, 6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında, veri sorumlusu UPT Ödeme Hizmetleri A.Ş.’ne verilerinin işlenmesi için Açık Rıza veriyor mu?">
                    <AjaxEvents>
                        <Change OnEvent="IsPersonalSecurityChanged" Before="new_IsPersonalSecurity.setValue(CrmValidateForm(msg, e));" />
                    </AjaxEvents>
                </rx:CheckField>
            </Body>
        </rx:Fieldset>--%>
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

        <rx:ToolBar runat="server" ID="ToolBar1">
            <Items>
                <rx:ToolbarFill runat="server" ID="ToolbarFill1">
                </rx:ToolbarFill>
                <rx:ToolbarButton runat="server" ID="btnSave" Text="save" Icon="Disk" Width="100">
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
