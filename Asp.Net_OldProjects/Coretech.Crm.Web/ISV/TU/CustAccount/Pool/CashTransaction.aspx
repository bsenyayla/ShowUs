<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_Pool_CashTransaction"
    ValidateRequest="false" Codebehind="CashTransaction.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<%@ Register TagPrefix="uc1" TagName="SenderFinde" Src="../Sender/SenderFinde.ascx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script src="../Js/Global.js"></script>
    <script src="../../Profession/Profession.js?<%=App.Params.AppVersion %>"></script>
     <script src="../Js/OtpControl.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <uc1:SenderFinde runat="server" ID="SenderFinde" SelectedFunction="SetUser();" />
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="new_OfficeId" />
        <rx:Hidden runat="server" ID="new_CorporationId" />
        <rx:Hidden runat="server" ID="new_CorporationCountryId" />
        <rx:Hidden runat="server" ID="new_CustAccountOperationTypeId" />
        <rx:Hidden ID="new_CalculatedExpenseAmountDefaultValue" runat="server" />
        <rx:Hidden ID="new_CalculatedExpenseCurrencyDefaultValue" runat="server" />
        <rx:Hidden ID="new_UserCostReductionRate" runat="server" />

        <rx:PanelX runat="server" ID="pnl_Screen1" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Müşteri ve Hesap Seçimi (3/1)">

            <Body>

                <cc1:CrmComboComp ID="new_CustAccountTypeId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountTypeId" RequirementLevel="BusinessRecommend"
                    FieldLabelWidth="150" Width="200" PageSize="50">
                    <Listeners>
                        <Change Handler="new_CustAccountTypeId_Change();"></Change>
                    </Listeners>
                </cc1:CrmComboComp>
                <rx:MultiField runat="server" ID="mfsender" FieldLabelShow="True" FieldLabelWidth="150" RequirementLevel="BusinessRecommend">
                    <Items>
                        <cc1:CrmComboComp ID="new_SenderId" runat="server" ObjectId="201500039" UniqueName="new_SenderId"
                            FieldLabelWidth="100" Width="200" PageSize="50" FieldLabelShow="False">
                            <Filters>
                                <cc1:ComboFilter FromObjectId="201500039" FromUniqueName="new_CustAccountTypeId" ToObjectId="201100052" ToUniqueName="new_CustAccountTypeId" />

                            </Filters>
                            <AjaxEvents>
                                <Change OnEvent="new_SenderId_OnChange">
                                </Change>
                            </AjaxEvents>
                        </cc1:CrmComboComp>
                        <rx:Button runat="server" ID="btnSenderFinde" Icon="Magnifier" Text="Gelişmiş Arama">
                            <Listeners>
                                <Click Handler="UptSenderSelector.Type='Sender'; UptSenderSelector.Show();"></Click>
                            </Listeners>
                        </rx:Button>

                    </Items>
                </rx:MultiField>
                <rx:MultiField runat="server" ID="mfCustAccount" FieldLabelShow="True" FieldLabelWidth="150" RequirementLevel="BusinessRecommend">
                    <Items>
                        <cc1:CrmComboComp ID="new_CustAccountId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountId" RequirementLevel="BusinessRecommend" LookupViewUniqueName="CUSTACCOUNTS_LOOKUP"
                            FieldLabelWidth="150" Width="200" PageSize="50">
                            <Filters>
                                <cc1:ComboFilter FromObjectId="201500039" FromUniqueName="new_SenderId" ToObjectId="201500042" ToUniqueName="new_SenderId" />
                            </Filters>
                            <AjaxEvents>
                                <Change OnEvent="new_CustAccountId_OnChange">
                                </Change>
                            </AjaxEvents>
                        </cc1:CrmComboComp>
                        <cc1:CrmComboComp runat="server" Disabled="True" FieldLabelShow="False" Width="50" ID="new_CustAccountCurrencyId" ObjectId="201500039" UniqueName="new_CustAccountCurrencyId" LookupViewUniqueName="CURRENCY_TR" RequirementLevel="BusinessRequired">
                        </cc1:CrmComboComp>
                        <rx:Label runat="server" ID="lblBalance" Text=" Kullanılabilir Bakiye:" Width="150" Disabled="True" />
                        <rx:TextField runat="server" ID="new_CustAccountBalance" Width="75" Disabled="True" />
                    </Items>
                </rx:MultiField>
                <cc1:CrmMoneyComp runat="server" FieldLabelShow="True" FieldLabelWidth="150" ID="new_PaymentAmount" UniqueName="new_PaymentAmount" ObjectId="201500039" RequirementLevel="BusinessRequired">
                    <DecimalChange OnEvent="new_PaymentAmount_OnChange">
                    </DecimalChange>
                </cc1:CrmMoneyComp>
                <rx:PanelX runat="server" ID="PanelX3" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
                    Border="true" Frame="False">

                    <Body>
                        <rx:PanelX runat="server" ID="CustAccountIdDetail" Height="100" Title="Hesap Detayı" AutoHeight="Normal" AutoWidth="True">
                            <AutoLoad Url="about:blank" ShowMask="true" />
                        </rx:PanelX>
                        <rx:PanelX runat="server" ID="SenderDetail" Height="400" Title="Müşteri Bilgileri" AutoHeight="Normal" AutoWidth="True">
                            <AutoLoad Url="about:blank" ShowMask="true" />
                        </rx:PanelX>
                    </Body>
                </rx:PanelX>

            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnNext_Screen1" Icon="PlayGreen" Text="Devam (2)"
                    Width="100">
                    <AjaxEvents>
                        <Click OnEvent="SenderProfessionCheck"></Click>
                    </AjaxEvents>
<%--                    <Listeners>
                        <Click Handler=""></Click>
                    </Listeners>--%>
                </rx:Button>

            </Buttons>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="pnl_Screen2" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Hesaptan Nakit Çekim (3/2)" Hidden="True">
            <Body>

                <rx:PanelX runat="server" ID="pnlReadOnlyMasterValues2" AutoHeight="Normal" Height="100" Title="">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout2" runat="server" ColumnLayoutLabelWidth="150">
                                    <Body>
                                        <rx:TextField runat="server" ID="lblnew_CustAccountTypeId2" Disabled="True" />
                                        <rx:TextField runat="server" ID="lblnew_SenderId2" Disabled="True" />
                                        <rx:MultiField runat="server" ID="mlCustAccount2" FieldLabelShow="True" FieldLabelWidth="100">
                                            <Items>
                                                <rx:TextField runat="server" ID="lblnew_CustAccountId2" Width="200" Disabled="True" />
                                                <rx:TextField runat="server" ID="lblnew_CustAccountBalance2" Width="80" Disabled="True" />
                                            </Items>
                                        </rx:MultiField>
                                        <rx:TextField runat="server" ID="lblnew_PaymentAmount2" Width="200" Disabled="True" />
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>

                <rx:PanelX ID="pnlSenderPerson" runat="server" Title="Firma Anlık Müşteri Sorumlusu" AutoHeight="Normal" Height="30">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout5" runat="server" ColumnLayoutLabelWidth="150">
                                    <Body>
                                        <cc1:CrmComboComp runat="server" ID="new_SenderPersonId" ObjectId="201500039" UniqueName="new_SenderPersonId" RequirementLevel="BusinessRequired"  LookupViewUniqueName ="SENDER_PERSON_LOOKUP">
                                            <Filters>
                                                <cc1:ComboFilter FromObjectId="201500039" FromUniqueName="new_SenderId" ToObjectId="201500041"
                                                    ToUniqueName="new_SenderId" />
                                            </Filters>
                                            <AjaxEvents>
                                                <Change OnEvent="new_SenderPersonId_OnChange"></Change>
                                            </AjaxEvents>
                                        </cc1:CrmComboComp>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>
                <rx:PanelX ID="pnlSenderPersonFrame" runat="server" AutoHeight="Normal" Height="150">
                    <Body>
                        <rx:PanelX runat="server" ID="SenderPersonDetail" Height="140" AutoHeight="Normal">
                            <AutoLoad Url="about:blank" ShowMask="true" />
                        </rx:PanelX>
                    </Body>
                </rx:PanelX>
                <rx:PanelX runat="server" ID="PanelX4" AutoHeight="Normal" Height="170" AutoWidth="true" Title="Ödeme Yatırılacak Tutar."
                    Collapsed="false" Collapsible="false" Border="false" CustomCss="Section2">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="33%" ColumnLayoutLabelWidth="35">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout1">
                                    <Body>
                                        <%-- <cc1:CrmLabelField ID="new_TransferAmount" runat="server" ObjectId="201500039" Disabled="true"
                                    UniqueName="new_TransferAmount" />--%>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout4">
                                    <Body>
                                        <%-- <cc1:CrmLabelField ID="new_ExpenseAmount" runat="server" ObjectId="201500039" Disabled="true"
                                    UniqueName="new_ExpenseAmount" />--%>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout3">
                                    <Body>
                                        <cc1:CrmMoneyComp runat="server" ID="new_ReceivedExpenseAmount" UniqueName="new_ReceivedExpenseAmount"
                                            ObjectId="201500039" Disabled="true" Hidden="true">
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmLabelField ID="new_TotalPayableAmount" runat="server" ObjectId="201500039"
                                            Disabled="true" Hidden="true" UniqueName="new_TotalPayableAmount" />
                                        <cc1:CrmMoneyComp runat="server" ID="new_ExpenseAmount" UniqueName="new_ExpenseAmount"
                                            Hidden="true" ObjectId="201500039">
                                            <DecimalChange OnEvent="CalculateOnEvent">
                                            </DecimalChange>
                                        </cc1:CrmMoneyComp>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="60%" ColumnLayoutLabelWidth="35">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout6">
                                    <Body>
                                        <rx:MultiField ID="RxM" runat="server" Width="200" FieldLabel="." RequirementLevel="BusinessRequired">
                                            <Items>
                                                <cc1:CrmPicklistComp runat="server" ID="new_PaymentMethod" Width="168" UniqueName="new_PaymentMethod"
                                                    ObjectId="201500039" RequirementLevel="BusinessRequired" FieldLabelShow="false">
                                                    <AjaxEvents>
                                                        <Change OnEvent="new_PaymentMethodOnChange">
                                                        </Change>
                                                    </AjaxEvents>
                                                </cc1:CrmPicklistComp>
                                            </Items>
                                        </rx:MultiField>
                                        <cc1:CrmMoneyComp runat="server" ID="new_CalculatedExpenseAmount" UniqueName="new_CalculatedExpenseAmount"
                                    ObjectId="201500039" RequirementLevel="BusinessRecommend" Disabled="true">
                                    <DecimalChange OnEvent="CalculateOnEvent">
                                    </DecimalChange>
                                </cc1:CrmMoneyComp>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout12">
                                    <Body>
                                        <cc1:CrmTextAreaComp ID="new_OperationDescription" runat="server" UniqueName="new_OperationDescription" MaxLength ="80" ObjectId="201500039">
                                        </cc1:CrmTextAreaComp>
                                    </Body>
                                </rx:RowLayout>
                                

                                <rx:RowLayout runat="server" ID="RowLayout30">
                                    <Body>
                                        <cc1:CrmMoneyComp runat="server" ID="new_PaidAmount1" UniqueName="new_PaidAmount1" 
                                            ObjectId="201500039" RequirementLevel="BusinessRequired" LookupViewUniqueName="OFFICE_CURRENCY_LOOKUP_HEDEF" Disabled="true">
                                            <Filters>
                                                <cc1:ComboFilter FromObjectId="201500039" FromUniqueName="new_OfficeId" ToObjectId="201100043"
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
                                            ObjectId="201500039" RequirementLevel="BusinessRequired" LookupViewUniqueName="OFFICECURRENCYLOOKUPSOURCE">
                                            <Items>
                                                <rx:Label ID="Parity2" runat="server">
                                                </rx:Label>
                                            </Items>
                                        </cc1:CrmMoneyComp>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout7">
                                    <Body>
                                        <rx:Label runat="server" ID="l1" Text="&nbsp;">
                                        </rx:Label>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout8">
                                    <Body>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout ID="RowLayout9" runat="server">
                                    <Body>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>
                 <rx:PanelX ID="PanelX1" runat="server" Title="Kimlik Bilgileri" AutoHeight="Normal" Height="70">
                    <Body>

                   <rx:Fieldset runat="server" ID="Fieldset1" AutoHeight="Normal" Height="65" AutoWidth="true"
                    CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout15" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout17">
                                    <Body>
                                        <cc1:CrmComboComp runat="server" ID="new_SenderIdentificationCardTypeID" ObjectId="201500039"
                                            RequirementLevel="BusinessRequired" UniqueName="new_SenderIdentificationCardTypeID"
                                            LookupViewUniqueName="KIMLIKTIPILOOKUP_FILTERED" Width="400" PageSize="50" FieldLabel="400" ColumnLayoutLabelWidth="400">
                                            <DataContainer>
                                                <DataSource OnEvent="new_CountryIdentificationTypeLoad">
                                                </DataSource>
                                            </DataContainer>
                                        </cc1:CrmComboComp>
                                        <cc1:CrmBooleanComp runat="server" RequirementLevel="BusinessRequired" ObjectId="201500039"
                                            ID="new_IdentityWasSeen" UniqueName="new_IdentityWasSeen" />
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout16" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout18">
                                    <Body>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdentificationCardNo" ObjectId="201500039"
                                            RequirementLevel="BusinessRequired" UniqueName="new_SenderIdentificationCardNo"
                                            FieldLabel="200">
                                        </cc1:CrmTextFieldComp>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:Fieldset>
                </Body>
                     </rx:PanelX>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnPrew_Screen2" Icon="ReverseGreen" Text="Önceki (1)"
                    Width="60">
                    <Listeners>
                        <Click Handler="Screen2_Prev();"></Click>
                    </Listeners>
                </rx:Button>
                <rx:Button runat="server" ID="btnNext_Screen2" Icon="PlayGreen" Text="Devam (3)"
                    Width="100">
                   <%-- <Listeners>
                        <Click Handler="Screen2_Next();"></Click>
                    </Listeners>--%>
                       <AjaxEvents>
                        <Click OnEvent="SenderOtpCheck"></Click>
                    </AjaxEvents>
                </rx:Button>

            </Buttons>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="pnl_Screen3" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Hesaptan Nakit Çekim (3/3)" Hidden="True">
            <Body>
                  
                <rx:PanelX runat="server" ID="pnlReadOnlyMasterValues4" AutoHeight="Normal" Height="100">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout10" runat="server" ColumnLayoutLabelWidth="200">
                                    <Body>
                                        <rx:TextField runat="server" ID="lblnew_CustAccountTypeId3" Disabled="True" />
                                        <rx:TextField runat="server" ID="lblnew_SenderId3" Disabled="True" />
                                        <rx:MultiField runat="server" ID="mlCustAccount3" FieldLabelShow="True" FieldLabelWidth="100">
                                            <Items>
                                                <rx:TextField runat="server" ID="lblnew_CustAccountId3" Width="200" Disabled="True" />
                                                <rx:TextField runat="server" ID="lblnew_CustAccountBalance3" Width="80" Disabled="True" />
                                            </Items>
                                        </rx:MultiField>
                                        <rx:TextField runat="server" ID="lblnew_PaymentAmount3" Width="200" Disabled="True" />
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>
                <rx:PanelX runat="server" ID="PanelX2" AutoHeight="Auto" Height="95" AutoWidth="true" Title="Hesap Bakiyesi"
                    Collapsed="false" Collapsible="false" Border="false" CustomCss="Section3">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout11">
                                    <Body>
                                        <cc1:CrmComboComp runat="server" ID="new_CustAccountCurrencyIdReadOnly" ObjectId="201500039" UniqueName="new_CustAccountCurrencyId" LookupViewUniqueName="CURRENCY_TR"
                                            Disabled="True">
                                        </cc1:CrmComboComp>

                                        <%-- <cc1:CrmComboComp ID="new_3rdSenderIdReadOnly" runat="server" ObjectId="201500039" UniqueName="new_3rdSenderId" Disabled="True">
                                        </cc1:CrmComboComp>--%>
                                        <cc1:CrmComboComp runat="server" ID="new_SenderPersonIdReadOnly" ObjectId="201500039" UniqueName="new_SenderPersonId"
                                            Disabled="True">
                                        </cc1:CrmComboComp>

                                        <cc1:CrmMoneyComp runat="server" ID="new_PaymentAmountReadOnly" UniqueName="new_PaymentAmount" ObjectId="201500039"
                                            Disabled="True">
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" FieldLabelShow="True" FieldLabelWidth="100" ID="new_CustTotalPayAmount" UniqueName="new_CustTotalPayAmount" ObjectId="201500039" RequirementLevel="BusinessRequired" Disabled="true">
                                        </cc1:CrmMoneyComp>
                                        <%--<cc1:CrmMoneyComp runat="server" ID="new_CalculatedExpenseAmountReadOnly" UniqueName="new_CalculatedExpenseAmount"
                                            ObjectId="201500039" Disabled="true">
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_ReceivedExpenseAmountReadOnly" UniqueName="new_ReceivedExpenseAmount"
                                            ObjectId="201500039" Disabled="true">
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_ExpenseAmountReadOnly" UniqueName="new_ExpenseAmount"
                                            Disabled="True" ObjectId="201500039">
                                        </cc1:CrmMoneyComp>--%>
                                        <cc1:CrmMoneyComp runat="server" ID="new_CalculatedExpenseAmountReadOnly" UniqueName="new_CalculatedExpenseAmount"
                                            ObjectId="201500039" Disabled="true">
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_ReceivedExpenseAmountReadOnly" UniqueName="new_ReceivedExpenseAmount"
                                            ObjectId="201500039" Disabled="true">
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_ExpenseAmountReadOnly" UniqueName="new_ExpenseAmount"
                                            Disabled="True" ObjectId="201500039">
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_PaidAmount1ReadOnly" UniqueName="new_PaidAmount1"
                                            ObjectId="201500039" Disabled="True">

                                            <Items>
                                                <rx:Label ID="Parity1ReadOnly" runat="server">
                                                </rx:Label>
                                            </Items>
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_PaidAmount2ReadOnly" UniqueName="new_PaidAmount2"
                                            ObjectId="201500039" Disabled="True">
                                            <Items>
                                                <rx:Label ID="Parity2ReadOnly" runat="server">
                                                </rx:Label>
                                            </Items>
                                        </cc1:CrmMoneyComp>
                                         <cc1:CrmMoneyComp runat="server" ID="new_TotalPayedAmount" UniqueName="new_TotalPayedAmount"
                                            ObjectId="201500039" Disabled="True">
                                        </cc1:CrmMoneyComp>
                                        <%--<cc1:CrmMoneyComp runat="server" ID="new_TotalReceivedAmountReadOnly" UniqueName="new_TotalReceivedAmount"
                                            ObjectId="201500039" Disabled="true">
                                        </cc1:CrmMoneyComp>--%>
                                        <cc1:CrmTextAreaComp ID="new_OperationDescriptionReadOnly" runat="server" UniqueName="new_OperationDescription" ObjectId="201500039" Disabled="true">
                                        </cc1:CrmTextAreaComp>
                                        <cc1:CrmComboComp runat="server" ID="new_SenderIdentificationCardTypeIDReadOnly" ObjectId="201500039"
                                            UniqueName="new_SenderIdentificationCardTypeID"
                                            Width="400" PageSize="50" FieldLabel="400" ColumnLayoutLabelWidth="400" Disabled="True">
                                        </cc1:CrmComboComp>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdentificationCardNoReadOnly" ObjectId="201500039"
                                            UniqueName="new_SenderIdentificationCardNo" Disabled="True"
                                            FieldLabel="200">
                                        </cc1:CrmTextFieldComp>
                                        <rx:CheckField runat="server" Disabled="true" ReadOnly="true"
                                            ID="new_IdentityWasSeenReadOnly" />
                                         <rx:CheckField ID="new_IsOtpConfirm" runat="server" Width="30"  ReadOnly="true" FieldLabel="Otp Kontrolü"/>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>

                    </Body>
                </rx:PanelX>

            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnPrew_Screen4" Icon="ReverseGreen" Text="Önceki (2)"
                    Width="100">
                    <Listeners>
                        <Click Handler="Screen3_Prev();"></Click>
                    </Listeners>
                </rx:Button>
                <rx:Button runat="server" ID="btnFinis" Icon="Accept" Text="İşlemi Tamamla"
                    Width="100">
                    <AjaxEvents>
                        <Click OnEvent="btnFinishOnClickEvent">
                        </Click>
                    </AjaxEvents>
                </rx:Button>

            </Buttons>
        </rx:PanelX>
          <rx:Window ID="otpControlWindow" runat="server" Width="400" Height="400" Modal="true"
            Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false"
            Title="OTP Kontrol Formu">
            <Body>
                <rx:PanelX ID="pnlMain" runat="server" BorderStyle="None" Width="400" Height="200" AutoHeight="Auto">
                    <AutoLoad Url="about:blank" />                   
                   
                </rx:PanelX>
            </Body>
                 
        </rx:Window>
    </form>
</body>
</html>

<script>
    function pageLoad() {
        pnlSenderPerson.hide();
        pnlSenderPersonFrame.hide();
        R.reSize();
    }
    var CustAccountType =
    {
        GERCEK: function () { return CustAccountType_001 === new_CustAccountTypeId.getValue() },
        TUZEL: function () { return CustAccountType_002 === new_CustAccountTypeId.getValue() }
    }



    function new_CustAccountTypeId_Change() {
        new_SenderId.clear();
        new_CustAccountCurrencyId.clear();
        new_CustAccountBalance.clear();
        new_CustAccountId.clear();
        Frame_SenderDetail.location = "about:blank";
        Frame_CustAccountIdDetail.location = "about:blank";
        R.reSize();
    }
    function OpenNewSender() {

    }
    function Screen1_Next() {
        ObjReq = [];
        ObjReq.push(new_CustAccountTypeId);
        ObjReq.push(new_SenderId);
        ObjReq.push(new_CustAccountId);
        ObjReq.push(new_PaymentAmount);
        if (!CheckBefore())
            return;
        pnl_Screen2.show();
        pnl_Screen1.hide();
        R.reSize();
        //debugger;
        lblnew_CustAccountId2.setValue(new_CustAccountCurrencyId.selectedRecord.VALUE + ' - ' + new_CustAccountId.selectedRecord.VALUE);
        lblnew_CustAccountId3.setValue(new_CustAccountCurrencyId.selectedRecord.VALUE + ' - ' + new_CustAccountId.selectedRecord.VALUE);

        lblnew_CustAccountBalance2.setValue(new_CustAccountBalance.getValue() + "-" + new_CustAccountCurrencyId.selectedRecord.VALUE);
        lblnew_CustAccountBalance3.setValue(new_CustAccountBalance.getValue() + "-" + new_CustAccountCurrencyId.selectedRecord.VALUE);

        lblnew_CustAccountTypeId2.setValue(new_CustAccountTypeId.selectedRecord.VALUE);
        lblnew_SenderId2.setValue(new_SenderId.selectedRecord.VALUE);
        lblnew_CustAccountTypeId3.setValue(new_CustAccountTypeId.selectedRecord.VALUE);
        lblnew_SenderId3.setValue(new_SenderId.selectedRecord.VALUE);

        lblnew_PaymentAmount2.setValue(new_PaymentAmount.getValue() + "-" + new_PaymentAmountCurrency.selectedRecord.VALUE);
        lblnew_PaymentAmount3.setValue(new_PaymentAmount.getValue() + "-" + new_PaymentAmountCurrency.selectedRecord.VALUE);

        if (CustAccountType.GERCEK()) {
            new_SenderPersonId.clear();
            new_SenderPersonId.hide();
            pnlSenderPerson.hide();
            pnlSenderPersonFrame.hide();
        }
        if (CustAccountType.TUZEL()) {
            new_SenderPersonId.show();
            pnlSenderPerson.show();
            pnlSenderPerson.show();
            pnlSenderPersonFrame.show();
        }
        R.reSize();
    }
    function Screen2_Prev() {
        pnl_Screen2.hide();
        pnl_Screen1.show();
        R.reSize();
    }

    function Screen2_Next() {
        ObjReq = [];
        ObjReq.push(new_PaymentAmount);
        ObjReq.push(new_PaidAmount1);
        if (CustAccountType.GERCEK()) {
            new_SenderPersonId.clear();
            new_SenderPersonIdReadOnly.hide();
        }
        if (CustAccountType.TUZEL()) {
            ObjReq.push(new_SenderPersonId);
            new_SenderPersonIdReadOnly.show();
        }
        ObjReq.push(new_SenderIdentificationCardTypeID);
        ObjReq.push(new_SenderIdentificationCardNo);
        ObjReq.push(new_IdentityWasSeen);





        /*Radonly fields filled*/
        fillLookup(new_CustAccountCurrencyIdReadOnly, new_CustAccountCurrencyId);
        fillLookup(new_SenderPersonIdReadOnly, new_SenderPersonId);
        //fillLookup(new_3rdSenderIdReadOnly, new_3rdSenderId);
        fillMoney(new_PaymentAmountReadOnly, new_PaymentAmount);
        fillMoney(new_CalculatedExpenseAmountReadOnly, new_CalculatedExpenseAmount);
        fillMoney(new_ReceivedExpenseAmountReadOnly, new_ReceivedExpenseAmount);
        //fillMoney(new_TotalReceivedAmountReadOnly, new_TotalReceivedAmount);
        fillMoney(new_ExpenseAmountReadOnly, new_ExpenseAmount);
        fillMoney(new_PaidAmount1ReadOnly, new_PaidAmount1);
        fillLabel(Parity1ReadOnly, Parity1);

        if (typeof (new_PaidAmount2) !== 'undefined')
            fillMoney(new_PaidAmount2ReadOnly, new_PaidAmount2);
        if (typeof (Parity2) !== 'undefined')
            fillLabel(Parity2ReadOnly, Parity2);
        fillValue(new_OperationDescriptionReadOnly, new_OperationDescription);
        fillLookup(new_SenderIdentificationCardTypeIDReadOnly, new_SenderIdentificationCardTypeID);
        fillValue(new_SenderIdentificationCardNoReadOnly, new_SenderIdentificationCardNo);
        fillValue(new_IdentityWasSeenReadOnly, new_IdentityWasSeen);

        if (!CheckBefore())
            return;
        pnl_Screen2.hide();
        pnl_Screen3.show();
        R.reSize();
    }
    function Screen3_Prev() {
        pnl_Screen3.hide();
        pnl_Screen2.show();
        R.reSize();

    }



    function SetUser(id, senderName) {
        //   debugger;
        if (id != null && id !== "") {
            if (UptSenderSelector.Type === "Sender") {
                new_SenderId.clear();
                new_SenderId.setValue(id, senderName);
                new_SenderId.change();

                new_CustAccountId.clear();
                new_CustAccountCurrencyId.clear();
                new_CustAccountBalance.clear();
            }
            R.reSize();
        }
        if (UptSenderSelector.SelectedSender.length > 0) {
            if (UptSenderSelector.Type === "Sender") {
                new_SenderId.clear();
                new_SenderId.setValue(UptSenderSelector.SelectedSender[0].Value, UptSenderSelector.SelectedSender[0].Key);
                new_SenderId.change();

                new_CustAccountId.clear();
                new_CustAccountCurrencyId.clear();
                new_CustAccountBalance.clear();
            }

            R.reSize();

        }
    }

</script>
