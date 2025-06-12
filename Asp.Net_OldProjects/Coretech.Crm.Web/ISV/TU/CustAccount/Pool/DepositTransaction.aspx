<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_Pool_DepositTransaction" ValidateRequest="false" Codebehind="DepositTransaction.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<%@ Register Src="../Sender/SenderFinde.ascx" TagPrefix="uc1" TagName="SenderFinde" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="../Js/global.js"></script>
    <script src="../../Profession/Profession.js?<%=App.Params.AppVersion %>"></script>
</head>
<body>
    <form id="form1" runat="server">
        <uc1:SenderFinde runat="server" ID="SenderFinde" SelectedFunction="SetUser();" />
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="new_OfficeId" />
        <rx:Hidden runat="server" ID="new_CorporationId" />
        <%--Bu alanlar Default Doluyor--%>
        <rx:Hidden ID="new_CalculatedExpenseAmountDefaultValue" runat="server" />
        <rx:Hidden ID="new_CalculatedExpenseCurrencyDefaultValue" runat="server" />
        <rx:Hidden ID="new_UserCostReductionRate" runat="server" />
        <rx:Hidden ID="new_CustAccountOperationTypeId" runat="server" />
        <rx:Hidden ID="new_CorporationCountryId" runat="server" />
        <%--Bu alanlar--%>
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
                            FieldLabelWidth="150" Width="200" PageSize="50" FieldLabelShow="False">
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
                        <rx:Button runat="server" ID="btnSenderEditUpdate" Icon="Add" Text="Yeni Müşteri">
                            <AjaxEvents>
                                <Click Before="UptSenderSelector.Type ='Sender';" OnEvent="btnSenderEditUpdate_Click">
                                </Click>
                            </AjaxEvents>
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
                        <rx:TextField runat="server" ID="new_CustAccountBalance" Width="50" Disabled="True" />
                    </Items>
                </rx:MultiField>

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
            Border="true" Frame="true" Title="Hesaba Nakit Yatırma (3/2)" Hidden="True">
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
                                        <rx:MultiField runat="server" ID="mfSenderType" FieldLabelShow="True" RequirementLevel="BusinessRequired">
                                            <Items>
                                                <cc1:CrmPicklistComp runat="server" ID="new_SenderType" FieldLabelShow="False" ObjectId="201500039" UniqueName="new_SenderType" RequirementLevel="BusinessRequired" Width="200">
                                                    <AjaxEvents>
                                                        <Change OnEvent="new_SenderTypeOnChange"></Change>
                                                    </AjaxEvents>
                                                    <Listeners>
                                                        <Change Handler="new_SenderType_OnChange();"></Change>
                                                    </Listeners>
                                                </cc1:CrmPicklistComp>

                                            </Items>
                                        </rx:MultiField>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>
                <rx:PanelX ID="pnl3rdSender" runat="server" Title="Farklı gönderici" AutoHeight="Normal" Height="30">
                    <Body>
                        <rx:MultiField runat="server" ID="mf3rdSender" FieldLabelShow="True" FieldLabelWidth="100" RequirementLevel="BusinessRequired">
                            <Items>
                                <cc1:CrmComboComp ID="new_3rdSenderId" runat="server" ObjectId="201500039" UniqueName="new_3rdSenderId"
                                    FieldLabelWidth="150" Width="200" PageSize="50" FieldLabelShow="True" RequirementLevel="BusinessRequired">
                                    <AjaxEvents>
                                        <Change Before="UptSenderSelector.Type ='3rdSender';" OnEvent="new_3rdSenderId_OnChange">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                                <rx:Button runat="server" ID="btn3rdSenderFinde" Icon="Magnifier" Text="Gelişmiş Arama">
                                    <Listeners>
                                        <Click Handler="UptSenderSelector.Type='3rdSender'; UptSenderSelector.Show();"></Click>
                                    </Listeners>
                                </rx:Button>
                                <rx:Button runat="server" ID="btn3rdSenderEditUpdate" Icon="Add" Text="Yeni Müşteri">
                                    <AjaxEvents>
                                        <Click OnEvent="btn3rdSenderEditUpdate_Click">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Items>
                        </rx:MultiField>

                    </Body>
                </rx:PanelX>
                <rx:PanelX ID="pnl3rdSenderFrame" runat="server" AutoHeight="Normal" Height="150">
                    <Body>
                        <rx:PanelX runat="server" ID="Sender3rdDetail" Height="140" AutoHeight="Normal">
                            <AutoLoad Url="about:blank" ShowMask="true" />
                        </rx:PanelX>
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
                <rx:PanelX runat="server" ID="PanelX4" AutoHeight="Normal" Height="95" AutoWidth="true" Title="Hesaba Yatırılacak Tutar."
                    Collapsed="false" Collapsible="false" Border="false" CustomCss="Section2">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout10" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout10">
                                    <Body>
                                        <rx:Hidden ID="new_AmountOld" runat="server">
                                        </rx:Hidden>
                                        <cc1:CrmMoneyComp runat="server" ID="new_Amount" UniqueName="new_Amount" ObjectId="201500039"
                                            RequirementLevel="BusinessRequired">
                                            <DecimalChange OnEvent="new_AmountOnChange">
                                            </DecimalChange>
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_CalculatedExpenseAmount" UniqueName="new_CalculatedExpenseAmount"
                                            ObjectId="201500039" RequirementLevel="BusinessRecommend" Disabled="true">
                                            <DecimalChange OnEvent="new_AmountOnChange">
                                            </DecimalChange>
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmTextAreaComp ID="new_OperationDescription" runat="server" UniqueName="new_OperationDescription" MaxLength ="80" ObjectId="201500039">
                                        </cc1:CrmTextAreaComp>
                                        <%-- <cc1:CrmMoneyComp runat="server" ID="new_ReceivedPaymentAmount" UniqueName="new_ReceivedPaymentAmount"
                                    ObjectId="201500039" Disabled="true">
                                    <Items>
                                        <rx:Label ID="Parity3" runat="server">
                                        </rx:Label>
                                    </Items>
                                </cc1:CrmMoneyComp>--%>
                                        <cc1:CrmMoneyComp runat="server" ID="new_ReceivedExpenseAmount" UniqueName="new_ReceivedExpenseAmount"
                                            ObjectId="201500039" Disabled="true" Hidden="true">
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_TotalReceivedAmount" UniqueName="new_TotalReceivedAmount"
                                            ObjectId="201500039" Disabled="true" Hidden="True">
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_ExpenseAmount" UniqueName="new_ExpenseAmount"
                                            Hidden="true" ObjectId="201500039">
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
                                        <cc1:CrmPicklistComp runat="server" ID="new_CollectionMethod" Width="168" UniqueName="new_CollectionMethod"
                                            ObjectId="201500039" RequirementLevel="BusinessRequired" FieldLabelShow="True">
                                            <AjaxEvents>
                                                <Change OnEvent="new_CollectionMethodOnChange">
                                                </Change>
                                            </AjaxEvents>
                                        </cc1:CrmPicklistComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_ReceivedAmount1" UniqueName="new_ReceivedAmount1"
                                            ObjectId="201500039" RequirementLevel="BusinessRequired" LookupViewUniqueName="CURRENCY_TR" Disabled="true">
                                            <%--<Filters>
                                                <cc1:ComboFilter FromObjectId="201500039" FromUniqueName="new_OfficeId" ToObjectId="201100043"
                                                    ToUniqueName="new_OfficeID" />
                                            </Filters>--%>
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
                                            ObjectId="201500039" RequirementLevel="BusinessRequired" LookupViewUniqueName="CURRENCY_TR"
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
                </rx:PanelX>
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
            <Buttons>
                <rx:Button runat="server" ID="btnPrew_Screen2" Icon="ReverseGreen" Text="Önceki (1)"
                    Width="100">
                    <Listeners>
                        <Click Handler="Screen2_Prev();"></Click>
                    </Listeners>
                </rx:Button>
                <rx:Button runat="server" ID="btnNext_Screen2" Icon="PlayGreen" Text="Devam (3)"
                    Width="100">
                    <Listeners>
                        <Click Handler="Screen2_Next();"></Click>
                    </Listeners>
                </rx:Button>

            </Buttons>
        </rx:PanelX>

        <rx:PanelX runat="server" ID="pnl_Screen3" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Hesaba Nakit Yatırma (3/3)" Hidden="True">
            <Body>
                <rx:PanelX runat="server" ID="pnlReadOnlyMasterValues4" AutoHeight="Normal" Height="100">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout3" runat="server" ColumnLayoutLabelWidth="200">
                                    <Body>
                                        <rx:TextField runat="server" ID="lblnew_CustAccountTypeId3" Disabled="True" />
                                        <rx:TextField runat="server" ID="lblnew_SenderId3" Disabled="True" />
                                        <rx:MultiField runat="server" ID="mlCustAccount3" FieldLabelShow="True" FieldLabelWidth="100">
                                            <Items>
                                                <rx:TextField runat="server" ID="lblnew_CustAccountId3" Width="200" Disabled="True" />
                                                <rx:TextField runat="server" ID="lblnew_CustAccountBalance3" Width="80" Disabled="True" />
                                            </Items>
                                        </rx:MultiField>
                                        <rx:TextField runat="server" ID="lblnew_SenderType3" Disabled="True" />
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>
                <rx:PanelX runat="server" ID="PanelX2" AutoHeight="Auto" Height="95" AutoWidth="true" Title="Hesap Bakiyesi"
                    Collapsed="false" Collapsible="false" Border="false" CustomCss="Section3">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout4">
                                    <Body>
                                        <cc1:CrmComboComp runat="server" ID="new_CustAccountCurrencyIdReadOnly" ObjectId="201500039" UniqueName="new_CustAccountCurrencyId" LookupViewUniqueName="CURRENCY_TR"
                                            Disabled="True">
                                        </cc1:CrmComboComp>

                                        <cc1:CrmComboComp ID="new_3rdSenderIdReadOnly" runat="server" ObjectId="201500039" UniqueName="new_3rdSenderId" Disabled="True">
                                        </cc1:CrmComboComp>
                                        <cc1:CrmComboComp runat="server" ID="new_SenderPersonIdReadOnly" ObjectId="201500039" UniqueName="new_SenderPersonId"
                                            Disabled="True">
                                        </cc1:CrmComboComp>

                                        <cc1:CrmMoneyComp runat="server" ID="new_AmountReadOnly" UniqueName="new_Amount" ObjectId="201500039"
                                            Disabled="True">
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_CalculatedExpenseAmountReadOnly" UniqueName="new_CalculatedExpenseAmount"
                                            ObjectId="201500039" Disabled="true">
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_ReceivedExpenseAmountReadOnly" UniqueName="new_ReceivedExpenseAmount"
                                            ObjectId="201500039" Disabled="true">
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_ExpenseAmountReadOnly" UniqueName="new_ExpenseAmount"
                                            Disabled="True" ObjectId="201500039">
                                        </cc1:CrmMoneyComp>

                                        <cc1:CrmMoneyComp runat="server" ID="new_ReceivedAmount1ReadOnly" UniqueName="new_ReceivedAmount1"
                                            ObjectId="201500039" Disabled="True">

                                            <Items>
                                                <rx:Label ID="Parity1ReadOnly" runat="server">
                                                </rx:Label>
                                            </Items>
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_ReceivedAmount2ReadOnly" UniqueName="new_ReceivedAmount2"
                                            ObjectId="201500039" Disabled="True">
                                            <Items>
                                                <rx:Label ID="Parity2ReadOnly" runat="server">
                                                </rx:Label>
                                            </Items>
                                        </cc1:CrmMoneyComp>
                                        <cc1:CrmMoneyComp runat="server" ID="new_TotalReceivedAmountReadOnly" UniqueName="new_TotalReceivedAmount"
                                            ObjectId="201500039" Disabled="true">
                                        </cc1:CrmMoneyComp>
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

    </form>

</body>
</html>
<script>
    var SenderTypeList = null;
    var SenderTypeListForTuzel = { Records: [] };
    var SenderTypeListForGercek = { Records: [] };
    function pageLoad() {
        pnl3rdSender.hide();
        pnl3rdSenderFrame.hide();
        pnlSenderPerson.hide();
        pnlSenderPersonFrame.hide();
        SenderTypeList = new_SenderType.data.Records.clone();
        for (var i = 0; i < SenderTypeList.length; i++) {

            if (SenderTypeList[i].Value !== "1")
                SenderTypeListForTuzel.Records.push(SenderTypeList[i]);
            if (SenderTypeList[i].Value !== "3")
                SenderTypeListForGercek.Records.push(SenderTypeList[i]);
        }
        R.reSize();
    }
    var CustAccountType =
    {
        GERCEK: function () { return CustAccountType_001 === new_CustAccountTypeId.getValue() },
        TUZEL: function () { return CustAccountType_002 === new_CustAccountTypeId.getValue() }
    }
    var SenderType = {
        Same: function () { return "1" === new_SenderType.getValue() },
        Sender3rd: function () { return "2" === new_SenderType.getValue() },
        SenderPerson: function () { return "3" === new_SenderType.getValue() }
    }
    function Prepare_new_SenderType() {
        new_SenderType.clear();
        if (CustAccountType.GERCEK()) {
            new_SenderType.listitems = SenderTypeListForGercek;
            //new_SenderType.fillList(new_SenderType);
        } else if (CustAccountType.TUZEL()) {
            new_SenderType.listitems = SenderTypeListForTuzel;
            // new_SenderType.fillList(new_SenderType);
        }
        new_SenderType.change();
    }
    function new_SenderType_OnChange() {

        if (SenderType.Same()) {
            pnl3rdSender.hide();
            pnl3rdSenderFrame.hide();
            pnlSenderPerson.hide();
            pnlSenderPersonFrame.hide();
        }
        if (SenderType.Sender3rd()) {
            pnl3rdSender.show();
            pnl3rdSenderFrame.show();
            pnlSenderPerson.hide();
            pnlSenderPersonFrame.hide();
        }
        if (SenderType.SenderPerson()) {
            pnl3rdSender.hide();
            pnl3rdSenderFrame.hide();
            pnlSenderPerson.show();
            pnlSenderPersonFrame.show();
        }
        R.reSize();
    }

    function new_CustAccountTypeId_Change() {
        new_SenderId.clear();
        //new_SenderId.change();
        new_CustAccountId.clear();
        new_CustAccountCurrencyId.clear();
        new_CustAccountBalance.clear();
        Frame_SenderDetail.location = "about:blank";
        Frame_CustAccountIdDetail.location = "about:blank";
        Prepare_new_SenderType();
        R.reSize();
    }
    function OpenNewSender() {

    }
    function Screen1_Next() {
        ObjReq = [];
        ObjReq.push(new_CustAccountTypeId);
        ObjReq.push(new_SenderId);
        ObjReq.push(new_CustAccountId);

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

    }
    function Screen2_Prev() {
        pnl_Screen2.hide();
        pnl_Screen1.show();
        R.reSize();
    }

    function Screen2_Next() {
        ObjReq = [];
        ObjReq.push(new_Amount);
        ObjReq.push(new_ReceivedAmount1);
        ObjReq.push(new_SenderIdentificationCardTypeID);
        ObjReq.push(new_SenderIdentificationCardNo);
        ObjReq.push(new_IdentityWasSeen);
        ObjReq.push(new_SenderType);

        if (SenderType.Same()) {
            new_3rdSenderId.clear();
            new_SenderPersonId.clear();

            new_3rdSenderIdReadOnly.hide();
            new_SenderPersonIdReadOnly.hide();
        }
        if (SenderType.Sender3rd()) {
            new_SenderPersonId.clear();
            ObjReq.push(new_3rdSenderId);
            new_3rdSenderIdReadOnly.show();
            new_SenderPersonIdReadOnly.hide();
        }
        if (SenderType.SenderPerson()) {
            new_3rdSenderId.clear();
            ObjReq.push(new_SenderPersonId);
            new_3rdSenderIdReadOnly.hide();
            new_SenderPersonIdReadOnly.show();
        }
        //debugger;
        lblnew_SenderType3.setValue(new_SenderType.getRawValue());

        /*Radonly fields filled*/
        fillLookup(new_CustAccountCurrencyIdReadOnly, new_CustAccountCurrencyId);
        fillValue(new_OperationDescriptionReadOnly, new_OperationDescription);
        fillLookup(new_SenderPersonIdReadOnly, new_SenderPersonId);
        fillLookup(new_3rdSenderIdReadOnly, new_3rdSenderId);
        fillMoney(new_AmountReadOnly, new_Amount);
        fillMoney(new_CalculatedExpenseAmountReadOnly, new_CalculatedExpenseAmount);
        fillMoney(new_ReceivedExpenseAmountReadOnly, new_ReceivedExpenseAmount);
        fillMoney(new_TotalReceivedAmountReadOnly, new_TotalReceivedAmount);
        fillMoney(new_ExpenseAmountReadOnly, new_ExpenseAmount);
        fillMoney(new_ReceivedAmount1ReadOnly, new_ReceivedAmount1);
        fillLabel(Parity1ReadOnly, Parity1);

        if (typeof (new_ReceivedAmount2) !== 'undefined')
            fillMoney(new_ReceivedAmount2ReadOnly, new_ReceivedAmount2);
        if (typeof (Parity2) !== 'undefined')
            fillLabel(Parity2ReadOnly, Parity2);
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
            if (UptSenderSelector.Type === "3rdSender") {
                new_3rdSenderId.clear();
                new_3rdSenderId.setValue(id, senderName);
                new_3rdSenderId.change();
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
            if (UptSenderSelector.Type === "3rdSender") {
                new_3rdSenderId.clear();
                new_3rdSenderId.setValue(UptSenderSelector.SelectedSender[0].Value, UptSenderSelector.SelectedSender[0].Key);
                new_3rdSenderId.change();
            }
            R.reSize();

        }
    }

</script>
