<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CustAccount_Pool_InsertCustAccountWizard" ValidateRequest="false" CodeBehind="InsertCustAccountWizard.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<%@ Register Src="../Sender/SenderFinde.ascx" TagPrefix="uc1" TagName="SenderFinde" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
            Border="true" Frame="true" Title="Müşteri Seçimi (4/1)">



            <Body>
                <rx:Label Icon="Information" runat="server" ID="lblInfoDocumentOneStar" Text="" Hidden="true"></rx:Label>
                <rx:Label Icon="Information" runat="server" ID="lblInfoDocumentTwoStar" Text="" Hidden="true"></rx:Label>
                <cc1:CrmComboComp ID="new_CustAccountTypeId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountTypeId" RequirementLevel="BusinessRequired"
                    FieldLabelWidth="100" Width="200" PageSize="50">
                    <Listeners>
                        <Change Handler="new_CustAccountTypeId_Change();"></Change>
                    </Listeners>
                </cc1:CrmComboComp>

                <rx:MultiField runat="server" ID="mfsender" FieldLabelShow="True" FieldLabelWidth="100" RequirementLevel="BusinessRequired">
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
                                <Click Handler="UptSenderSelector.Show();"></Click>
                            </Listeners>
                        </rx:Button>
                        <rx:Button runat="server" ID="btnSenderEditUpdate" Icon="Add" Text="Yeni Müşteri">
                            <AjaxEvents>
                                <Click OnEvent="btnSenderEditUpdate_Click">
                                </Click>
                            </AjaxEvents>
                        </rx:Button>
                    </Items>
                </rx:MultiField>

                <rx:PanelX runat="server" ID="SenderDetail" Height="150" AutoWidth="true">
                    <AutoLoad Url="about:blank" ShowMask="true" />
                </rx:PanelX>

            </Body>

            <Buttons>
                <rx:Button runat="server" ID="btnNext_Screen1" Icon="PlayGreen" Text="(2)"
                    Width="60">
                    <AjaxEvents>
                        <Click OnEvent="SenderProfessionCheck"></Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="pnl_Screen2" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Hesap Açma (4/2)" Hidden="True">

            <Body>
                <rx:PanelX runat="server" ID="pnlReadOnlyMasterValues" AutoHeight="Normal" Height="100" Title="Müşteri Bilgileri">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout7" runat="server" ColumnLayoutLabelWidth="200">
                                    <Body>
                                        <rx:TextField runat="server" ID="lblnew_CustAccountTypeId2" Disabled="True" />
                                        <rx:TextField runat="server" ID="lblnew_SenderId2" Disabled="True" />
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>
                <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="300" Title="Hesap Bilgileri">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout1" runat="server" ColumnLayoutLabelWidth="200">
                                    <Body>
                                        <cc1:CrmComboComp runat="server" ID="new_CustAccountCurrencyId" ObjectId="201500039" UniqueName="new_CustAccountCurrencyId" LookupViewUniqueName="CURRENCY_TR" RequirementLevel="BusinessRequired">
                                            <AjaxEvents>
                                                <Change OnEvent="new_CustAccountCurrencyIdOnEvent">
                                                </Change>
                                            </AjaxEvents>
                                        </cc1:CrmComboComp>
                                        <cc1:CrmComboComp runat="server" ID="new_CustAccountRestrictionId" ObjectId="201500039" UniqueName="new_CustAccountRestrictionId" />
                                        <cc1:CrmTextAreaComp runat="server" ID="new_CustAccountRestrictionDescription" ObjectId="201500039" UniqueName="new_CustAccountRestrictionDescription" />
                                        <cc1:CrmComboComp runat="server" ID="new_SenderPersonId" ObjectId="201500039" UniqueName="new_SenderPersonId" RequirementLevel="BusinessRequired">
                                            <Filters>
                                                <cc1:ComboFilter FromObjectId="201500039" FromUniqueName="new_SenderId" ToObjectId="201500041"
                                                    ToUniqueName="new_SenderId" />

                                            </Filters>
                                        </cc1:CrmComboComp>


                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnPrew_Screen2" Icon="ReverseGreen" Text="(1)"
                    Width="60">
                    <Listeners>
                        <Click Handler="Screen2_Prev();"></Click>
                    </Listeners>
                </rx:Button>
                <rx:Button runat="server" ID="btnNext_Screen2" Icon="PlayGreen" Text="(3)"
                    Width="60">
                    <Listeners>
                        <Click Handler="Screen2_Next();"></Click>
                    </Listeners>
                </rx:Button>

            </Buttons>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="pnl_Screen3" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Hesap Açma (4/3)" Hidden="True">
            <Body>
                <rx:PanelX runat="server" ID="pnlReadOnlyMasterValues3" AutoHeight="Normal" Height="100" Title="Müşteri Bilgileri">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout2" runat="server" ColumnLayoutLabelWidth="200">
                                    <Body>
                                        <rx:TextField runat="server" ID="lblnew_CustAccountTypeId3" Disabled="True" />
                                        <rx:TextField runat="server" ID="lblnew_SenderId3" Disabled="True" />
                                    </Body>
                                </rx:RowLayout>

                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>
                <rx:PanelX runat="server" ID="PanelX4" AutoHeight="Normal" Height="95" AutoWidth="true" Title="Hesap Bakiyesi"
                    Collapsed="false" Collapsible="false" Border="false" CustomCss="Section3">
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
                                        <cc1:CrmTextAreaComp ID="new_OperationDescription" runat="server" MaxLength="80" Width="80" UniqueName="new_OperationDescription" ObjectId="201500039">
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
                                            ObjectId="201500039" RequirementLevel="BusinessRequired" LookupViewUniqueName="CURRENCY_TR">
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
                <rx:Button runat="server" ID="btnPrew_Screen3" Icon="ReverseGreen" Text="(2)"
                    Width="60">
                    <Listeners>
                        <Click Handler="Screen3_Prev();"></Click>
                    </Listeners>
                </rx:Button>
                <rx:Button runat="server" ID="btnNext_Screen3" Icon="PlayGreen" Text="(4)"
                    Width="60">
                    <Listeners>
                        <Click Handler="Screen3_Next();"></Click>
                    </Listeners>
                </rx:Button>

            </Buttons>
        </rx:PanelX>

        <rx:PanelX runat="server" ID="pnl_Screen4" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Hesap Açma (4/4)" Hidden="True">
            <Body>
                <rx:PanelX runat="server" ID="pnlReadOnlyMasterValues4" AutoHeight="Normal" Height="100" Title="Müşteri Bilgileri">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout3" runat="server" ColumnLayoutLabelWidth="200">
                                    <Body>
                                        <rx:TextField runat="server" ID="lblnew_CustAccountTypeId4" Disabled="True" />
                                        <rx:TextField runat="server" ID="lblnew_SenderId4" Disabled="True" />
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
                                        <cc1:CrmComboComp runat="server" ID="new_CustAccountRestrictionIdReadOnly" ObjectId="201500039" UniqueName="new_CustAccountRestrictionId"
                                            Disabled="True" />
                                        <cc1:CrmTextAreaComp runat="server" ID="new_CustAccountRestrictionDescriptionReadOnly" ObjectId="201500039" UniqueName="new_CustAccountRestrictionDescription"
                                            Disabled="True" />
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
                <rx:Button runat="server" ID="btnPrew_Screen4" Icon="ReverseGreen" Text="(3)"
                    Width="60">
                    <Listeners>
                        <Click Handler="Screen4_Prev();"></Click>
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
    var CustAccountType =
    {
        GERCEK: function () { return CustAccountType_001 === new_CustAccountTypeId.getValue() },
        TUZEL: function () { return CustAccountType_002 === new_CustAccountTypeId.getValue() }
    }

    function new_CustAccountTypeId_Change() {
        new_SenderId.clear();
        new_SenderId.change();
        Frame_SenderDetail.location = "about:blank";
        R.reSize();

    }
    function OpenNewSender() {

    }
    function PrepareDocumentInfoLabel() {
        $('pnl_Screen1_Container_Buttons_Left').innerHTML = "<table><tr><td>" + $("lblInfoDocumentOneStar_Container").innerHTML + "</td></tr><tr><td>" + $("lblInfoDocumentTwoStar").innerHTML + "</td></tr></table>";
    }
    function Screen1_Next() {
        ObjReq = [];
        ObjReq.push(new_CustAccountTypeId);
        ObjReq.push(new_SenderId);

        if (!CheckBefore())
            return;
        var DocMessage = AjaxMethods.IsSenderDocumentNecessaryComplete(new_SenderId.getValue(), new_CustAccountTypeId.getValue()).value
        if (!DocMessage.Ret) {
            alert(documentNotComplete + "\n" + DocMessage.Message);
            return;
        }
        pnl_Screen2.show();
        pnl_Screen1.hide();
        R.reSize();
        //debugger;
        lblnew_CustAccountTypeId2.setValue(new_CustAccountTypeId.selectedRecord.VALUE);
        lblnew_SenderId2.setValue(new_SenderId.selectedRecord.VALUE);
        lblnew_CustAccountTypeId3.setValue(new_CustAccountTypeId.selectedRecord.VALUE);
        lblnew_SenderId3.setValue(new_SenderId.selectedRecord.VALUE);
        lblnew_CustAccountTypeId4.setValue(new_CustAccountTypeId.selectedRecord.VALUE);
        lblnew_SenderId4.setValue(new_SenderId.selectedRecord.VALUE);
        if (CustAccountType.TUZEL()) {
            ObjReq.push(new_SenderPersonId);
            new_SenderPersonId.show();
        }
        else {
            ObjReq.push(new_SenderPersonId);
            new_SenderPersonId.hide();
        }
    }
    function Screen2_Prev() {
        pnl_Screen2.hide();
        pnl_Screen1.show();

        R.reSize();
    }

    function Screen2_Next() {
        ObjReq = [];
        ObjReq.push(new_CustAccountCurrencyId);
        if (CustAccountType.TUZEL()) {
            ObjReq.push(new_SenderPersonId);
        }
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

    function Screen3_Next() {
        ObjReq = [];
        ObjReq.push(new_Amount);
        ObjReq.push(new_ReceivedAmount1);
        ObjReq.push(new_SenderIdentificationCardTypeID);
        ObjReq.push(new_SenderIdentificationCardNo);
        ObjReq.push(new_IdentityWasSeen);
        /*Radonly fields filled*/
        fillLookup(new_CustAccountCurrencyIdReadOnly, new_CustAccountCurrencyId);
        fillLookup(new_CustAccountRestrictionIdReadOnly, new_CustAccountRestrictionId);
        fillValue(new_CustAccountRestrictionDescriptionReadOnly, new_CustAccountRestrictionDescription);
        fillValue(new_OperationDescriptionReadOnly, new_OperationDescription);
        fillLookup(new_SenderPersonIdReadOnly, new_SenderPersonId);
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
        pnl_Screen3.hide();

        pnl_Screen4.show();
        R.reSize();
    }
    function Screen4_Prev() {
        pnl_Screen4.hide();
        pnl_Screen3.show();
        R.reSize();
    }

    function SetUser(id, senderName) {
        //   debugger;
        if (id != null && id != "") {
            new_SenderId.clear();
            new_SenderId.setValue(id, senderName);
            new_SenderId.change();
            R.reSize();
        }
        if (UptSenderSelector.SelectedSender.length > 0) {
            new_SenderId.clear();
            new_SenderId.setValue(UptSenderSelector.SelectedSender[0].Value, UptSenderSelector.SelectedSender[0].Key);
            new_SenderId.change();
            R.reSize();

        }
    }
    function fillLookup(a, b) {
        a.setValue(b.getValue(), b.getRawValue());
    }
    function fillValue(a, b) {
        a.setValue(b.getValue());
    }
    function fillLabel(a, b) {
        a.src.innerHTML = b.src.innerHTML;
    }
    function fillMoney(a, b) {
        fillValue(a, b);
        fillLookup(eval(a.id + "Currency"), eval(b.id + "Currency"));
    }
</script>
