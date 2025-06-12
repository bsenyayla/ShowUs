<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_Pool_DeleteCustAccountWizard" ValidateRequest="false" Codebehind="DeleteCustAccountWizard.aspx.cs" %>


<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<%@ Register TagPrefix="uc1" TagName="SenderFinde" Src="../Sender/SenderFinde.ascx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../Js/Global.js"></script>
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

        <rx:PanelX runat="server" ID="pnl_Screen1" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Müşteri ve Hesap Seçimi (3/1)">

            <Body>

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
                                <Click Handler="UptSenderSelector.Type='Sender'; UptSenderSelector.Show();"></Click>
                            </Listeners>
                        </rx:Button>

                    </Items>
                </rx:MultiField>
                <rx:MultiField runat="server" ID="mfCustAccount" FieldLabelShow="True" FieldLabelWidth="100" RequirementLevel="BusinessRequired">
                    <Items>
                        <cc1:CrmComboComp ID="new_CustAccountId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountId" RequirementLevel="BusinessRequired" LookupViewUniqueName="CUSTACCOUNTS_LOOKUP"
                            FieldLabelWidth="100" Width="200" PageSize="50">
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
                <rx:Button runat="server" ID="btnNext_Screen1" Icon="PlayGreen" Text="(2)"
                    Width="60">
                    <Listeners>
                        <Click Handler="Screen1_Next();"></Click>
                    </Listeners>
                </rx:Button>

            </Buttons>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="pnl_Screen2" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Hesap Kapatma (3/2)" Hidden="True">
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
                                                <rx:TextField runat="server" ID="lblnew_CustAccountBalance2" Width="50" Disabled="True" />
                                            </Items>
                                        </rx:MultiField>

                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:PanelX>

                <rx:PanelX ID="pnlSenderPerson" runat="server" Title="Tüzel müşteri sorumlusu" AutoHeight="Normal" Height="30">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="50%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout5" runat="server" ColumnLayoutLabelWidth="150">
                                    <Body>
                                        <cc1:CrmComboComp runat="server" ID="new_SenderPersonId" ObjectId="201500039" UniqueName="new_SenderPersonId" RequirementLevel="BusinessRequired">
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

                <rx:Fieldset runat="server" ID="Fieldset1" AutoHeight="Normal" Height="65" AutoWidth="true"
                    CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout15" ColumnWidth="33%">
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
                        <rx:ColumnLayout runat="server" ID="ColumnLayout16" ColumnWidth="33%">
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
            Border="true" Frame="true" Title="Hesap Kapatma (3/3)" Hidden="True">
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
                                                <rx:TextField runat="server" ID="lblnew_CustAccountBalance3" Width="50" Disabled="True" />
                                            </Items>
                                        </rx:MultiField>

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

                                       <
<cc1:CrmComboComp runat="server" ID="new_SenderPersonIdReadOnly" ObjectId="201500039" UniqueName="new_SenderPersonId"
                                           Disabled="True">
                                       </cc1:CrmComboComp>

                                        
                                        
                                        <cc1:CrmComboComp runat="server" ID="new_SenderIdentificationCardTypeIDReadOnly" ObjectId="201500039"
                                            UniqueName="new_SenderIdentificationCardTypeID"
                                            Width="400" PageSize="50" FieldLabel="400" ColumnLayoutLabelWidth="400" Disabled="True">
                                        </cc1:CrmComboComp>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdentificationCardNoReadOnly" ObjectId="201500039"
                                            UniqueName="new_SenderIdentificationCardNo" Disabled="True"
                                            FieldLabel="200">
                                        </cc1:CrmTextFieldComp>
                                        <rx:CheckField runat="server" Disabled="true" ReadOnly="true" 
                                            ID="new_IdentityWasSeenReadOnly"  />
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>

                    </Body>
                </rx:PanelX>

            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnPrew_Screen4" Icon="ReverseGreen" Text="(2)"
                    Width="60">
                    <Listeners>
                        <Click Handler="Screen3_Prev();"></Click>
                    </Listeners>
                </rx:Button>
                <rx:Button runat="server" ID="btnFinis" Icon="Accept" Text="İşlemi Tamamla"
                    Width="120">
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
