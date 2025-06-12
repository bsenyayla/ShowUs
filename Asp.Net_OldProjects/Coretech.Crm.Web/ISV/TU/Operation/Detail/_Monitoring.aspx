<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_Detail_Monitoring" ValidateRequest="false" CodeBehind="_Monitoring.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript">
    

    </script>
    <style type="text/css">
        .auto-style1 {
            width: 100%;
        }

        .auto-style2 {
            width: 38px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <rx:KeyMap runat="server" ID="KeyMap1">
            <rx:KeyBinding>
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="ToolbarButtonFind.click(e);" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:KeyMap runat="server" ID="KeyMap2">
            <rx:KeyBinding Ctrl="true">
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="ToolbarButtonClear.click(e);" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:Hidden ID="hdnEntityId" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnRecid" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnViewList" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnViewListTotal" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnViewDefaultEditPage" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnPoolId" runat="server" Value="1">
        </rx:Hidden>
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Button ID="btnInfo" runat="server" Download="True" Hidden="True">
            <AjaxEvents>
                <Click OnEvent="btnInformationOnEvent">
                </Click>
            </AjaxEvents>
        </rx:Button>
        <table style="width: 100%">
            <tr>
                <td>
                    <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="190" AutoWidth="true"
                        Title="SEARCH">

                        <Body>
                            <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="40%">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout1" runat="server">
                                        <Body>
                                            <%--<cc1:CrmComboComp ID="new_SenderCountryID" runat="server" ObjectId="201100097" UniqueName="new_SenderCountryID"
                                                FieldLabelWidth="100" Width="130" PageSize="50" >
                                            </cc1:CrmComboComp>--%>
                                            <cc1:CrmComboComp runat="server" ID="new_SenderCountryID" ObjectId="201100097"
                                                UniqueName="new_SenderCountryID" Width="50" FieldLabelWidth="500" ColumnLayoutLabelWidth="500"
                                                PageSize="500" Mode="Remote">
                                                <DataContainer>
                                                    <DataSource OnEvent="new_CountryLoad">
                                                    </DataSource>
                                                </DataContainer>
                                                <Listeners>
                                                </Listeners>
                                                <AjaxEvents>
                                                </AjaxEvents>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout4">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_CorporationId" ObjectId="201100097" UniqueName="new_CorporationId"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                                <Filters>
                                                    <cc1:ComboFilter FromObjectId="201100097" FromUniqueName="new_SenderCountryID" ToObjectId="201100034"
                                                        ToUniqueName="new_SenderCountryID" />
                                                </Filters>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_OfficeId" ObjectId="201100097" UniqueName="new_OfficeId"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                                <Filters>
                                                    <cc1:ComboFilter FromObjectId="201100097" FromUniqueName="new_CorporationId" ToObjectId="201100040"
                                                        ToUniqueName="new_CorporationID" />
                                                </Filters>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout16">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_PayingCorporationId" ObjectId="201100097" UniqueName="new_PayingCorporationId"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout20">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_PayingOfficeId" ObjectId="201100097" UniqueName="new_PayingOfficeId"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                                <Filters>
                                                    <cc1:ComboFilter FromObjectId="201100097" FromUniqueName="new_PayingCorporationId" ToObjectId="201100040"
                                                        ToUniqueName="new_CorporationID" />
                                                </Filters>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout9">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_FormConfirmStatusId" ObjectId="201100097"
                                                UniqueName="new_FormConfirmStatusId" FieldLabelWidth="70" Width="230" PageSize="50"
                                                LookupViewUniqueName="CONFIRM_STATUS_LOOKUP">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>

                                    <rx:RowLayout runat="server" ID="RowLayout19">
                                        <Body>
                                            <cc1:CrmTextFieldComp runat="server" ID="new_FileTransactionNumber" ObjectId="201100097"
                                                UniqueName="new_FileTransactionNumber" FieldLabelWidth="70" Width="230" PageSize="50">
                                            </cc1:CrmTextFieldComp>
                                        </Body>
                                    </rx:RowLayout>

                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout runat="server" ID="ColoumnLayout2" ColumnWidth="33%">
                                <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout2">
                                        <Body>
                                            <rx:MultiField ID="RxM" runat="server">
                                                <Items>
                                                    <cc1:CrmDateFieldComp ID="new_FormTransactionDate1" runat="server" ObjectId="201100097"
                                                        UniqueName="new_FormTransactionDate1" FieldLabelWidth="160" Width="100">
                                                    </cc1:CrmDateFieldComp>
                                                    <rx:Label runat="server" Text="  " ID="lbl1" Width="10">
                                                    </rx:Label>
                                                    <cc1:CrmDateFieldComp ID="new_FormTransactionDate2" runat="server" ObjectId="201100097"
                                                        FieldLabelShow="false" UniqueName="new_FormTransactionDate2" FieldLabelWidth="100"
                                                        Width="100">
                                                    </cc1:CrmDateFieldComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout3">
                                        <Body>
                                            <rx:MultiField ID="MultiField1" runat="server">
                                                <Items>
                                                    <cc1:CrmDecimalComp ID="new_FormAmount1" runat="server" ObjectId="201100097" UniqueName="new_FormAmount1"
                                                        FieldLabelWidth="160" Width="100">
                                                    </cc1:CrmDecimalComp>
                                                    <rx:Label runat="server" Text="  " ID="Label1" Width="10">
                                                    </rx:Label>
                                                    <cc1:CrmDecimalComp ID="new_FormAmount2" runat="server" ObjectId="201100097" FieldLabelShow="false"
                                                        UniqueName="new_FormAmount2" FieldLabelWidth="160" Width="100">
                                                    </cc1:CrmDecimalComp>
                                                    <rx:Label runat="server" Text="  " ID="Label3" Width="10" />

                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>

                                    <rx:RowLayout runat="server" ID="RowLayout5">
                                        <Body>
                                            <rx:MultiField ID="MultiField4" runat="server">
                                                <Items>
                                                    <cc1:CrmComboComp runat="server" ID="new_FormTransactionAmountCurrency" ObjectId="201100097"
                                                        UniqueName="new_FormTransactionAmountCurrency" FieldLabelWidth="160" Width="70"
                                                        PageSize="50" FieldLabelShow="true">
                                                    </cc1:CrmComboComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>

                                    <rx:RowLayout runat="server" ID="RowLayout12">
                                        <Body>
                                            <rx:MultiField ID="MultiField12" runat="server">
                                                <Items>
                                                    <cc1:CrmTextFieldComp ID="ProcessMonitoring" runat="server" ObjectId="201100097"
                                                        UniqueName="ProcessMonitoring" FieldLabelWidth="160" Width="230">
                                                    </cc1:CrmTextFieldComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>
                                    <%--                                    <rx:RowLayout runat="server" ID="RowLayout21">
                                        <Body>
                                            <rx:MultiField ID="MultiField6" runat="server">
                                                <Items>
                                                    <cc1:CrmTextFieldComp ID="new_SerialNumber" runat="server" ObjectId="201100097"
                                                        UniqueName="new_SerialNumber" FieldLabelWidth="110" Width="230">
                                                    </cc1:CrmTextFieldComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>--%>
                                    <rx:RowLayout runat="server" ID="RowLayout10">
                                        <Body>
                                            <rx:MultiField ID="MultiField2" runat="server">
                                                <Items>
                                                    <cc1:CrmPicklistComp runat="server" ID="new_OperationType" ObjectId="201100097" UniqueName="new_OperationType"
                                                        FieldLabelWidth="160" Width="230">
                                                    </cc1:CrmPicklistComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout22">
                                        <Body>
                                            <rx:MultiField ID="MultiField3" runat="server">
                                                <Items>
                                                    <cc1:CrmDateFieldComp ID="new_PaymentDate2" runat="server" DateMode="Date" ObjectId="201100097"
                                                        UniqueName="new_PaymentDate2" FieldLabelWidth="160" Width="100" MaxLength="300">
                                                    </cc1:CrmDateFieldComp>
                                                    <rx:Label runat="server" Text="  " ID="Label2" Width="10">
                                                    </rx:Label>
                                                    <cc1:CrmDateFieldComp ID="new_PaymentDate3" runat="server" ObjectId="201100097" FieldLabelShow="false"
                                                        UniqueName="new_PaymentDate2" FieldLabelWidth="100" Width="100">
                                                    </cc1:CrmDateFieldComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>
                                    <%--                                    <rx:RowLayout runat="server" ID="RowLayout14">
                                        <Body>
                                            <rx:MultiField ID="MultiField4" runat="server">
                                                <Items>
                                                    <cc1:CrmDateFieldComp ID="new_CancelDate1" runat="server" DateMode="Date" ObjectId="201100097"
                                                        UniqueName="new_CancelDate" FieldLabelWidth="110" Width="100" MaxLength="300">
                                                    </cc1:CrmDateFieldComp>
                                                    <rx:Label runat="server" Text="  " ID="Label4" Width="10">
                                                    </rx:Label>
                                                    <cc1:CrmDateFieldComp ID="new_CancelDate2" runat="server" DateMode="Date" ObjectId="201100097"
                                                        FieldLabelShow="false" UniqueName="new_CancelDate" FieldLabelWidth="100" Width="100">
                                                    </cc1:CrmDateFieldComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>--%>
                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="28%">
                                <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout6">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_FormTransactionTypeID" ObjectId="201100097"
                                                LookupViewUniqueName="TRANSACTIONTYPE_GONDERIM" UniqueName="new_FormTransactionTypeID"
                                                FieldLabelWidth="100" Width="100" PageSize="50">
                                                <Listeners>
                                                    <Change Handler=" if(new_FormTransactionTypeID.getValue() == '0bfc8af2-a014-4030-abfd-037d6cd39161')
                                                                        {
                                                                            new_FormTransactionTypeEft.show();
                                                                            new_FormTransactionTypeEft.setValue(2);
                                                                        }
                                                                        else
                                                                        {
                                                                            new_FormTransactionTypeEft.hide();
                                                                            new_FormTransactionTypeEft.clear(true,true);
                                                                        } " />
                                                </Listeners>
                                            </cc1:CrmComboComp>

                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout17">
                                        <Body>
                                            <rx:MultiField ID="MultiField5" runat="server">
                                                <Items>
                                                    <cc1:CrmPicklistComp runat="server" ID="new_FormTransactionTypeEft" ObjectId="201100097" UniqueName="new_FormTransactionTypeEft"
                                                        FieldLabelWidth="111" Width="150">
                                                    </cc1:CrmPicklistComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>
                                    <%--                                    <rx:RowLayout runat="server" ID="RowLayout13">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_FormSourceTransactionTypeID" ObjectId="201100097"
                                                LookupViewUniqueName="TRANSACTIONTYPE_TAHSILAT" UniqueName="new_FormSourceTransactionTypeID"
                                                FieldLabelWidth="100" Width="100" PageSize="50">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>--%>
                                    <rx:RowLayout runat="server" ID="RowLayout7">
                                        <Body>
                                            <%--<cc1:CrmComboComp runat="server" ID="new_FormReceiverCountryId" ObjectId="201100097"
                                                UniqueName="new_FormReceiverCountryId" FieldLabelWidth="100" Width="100" PageSize="50">
                                            </cc1:CrmComboComp>--%>
                                            <cc1:CrmComboComp runat="server" ID="new_FormReceiverCountryId" ObjectId="201100097"
                                                UniqueName="new_FormReceiverCountryId" Width="150"
                                                PageSize="500" FieldLabel="200" Mode="Remote">
                                                <DataContainer>
                                                    <DataSource OnEvent="new_CountryLoad">
                                                    </DataSource>
                                                </DataContainer>
                                                <Listeners>
                                                </Listeners>
                                                <AjaxEvents>
                                                </AjaxEvents>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <%--                                    <rx:RowLayout runat="server" ID="RowLayout5">
                                        <Body>
                                            <cc1:CrmTextFieldComp runat="server" ID="new_FormCustomerNumber" ObjectId="201100097"
                                                UniqueName="new_FormCustomerNumber" FieldLabelWidth="100" Width="100">
                                            </cc1:CrmTextFieldComp>
                                        </Body>
                                    </rx:RowLayout>--%>
                                    <rx:RowLayout runat="server" ID="RowLayout8">
                                        <Body>
                                            <cc1:CrmTextFieldComp runat="server" ID="new_SenderId" ObjectId="201100097" UniqueName="new_SenderId"
                                                FieldLabelWidth="100" Width="100">
                                            </cc1:CrmTextFieldComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout11">
                                        <Body>
                                            <cc1:CrmTextFieldComp runat="server" ID="new_RecipientFullName" ObjectId="201100097"
                                                UniqueName="new_RecipientFullName" FieldLabelWidth="100" Width="100" PageSize="50">
                                            </cc1:CrmTextFieldComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout15">
                                        <Body>
                                            <%--                                            <cc1:CrmComboComp runat="server" ID="new_RecipientCorporationId" ObjectId="201100097" UniqueName="new_RecipientCorporationId"
                                                FieldLabelWidth="70" Width="230" PageSize="50">
                                            </cc1:CrmComboComp>--%>

                                            <cc1:CrmComboComp runat="server" ID="new_RecipientCorporationId" ObjectId="201100097"
                                                UniqueName="new_RecipientCorporationId" Width="150"
                                                PageSize="500" FieldLabel="200" Mode="Remote">
                                                <DataContainer>
                                                    <DataSource OnEvent="new_RecipientCorporationLoad">
                                                    </DataSource>
                                                </DataContainer>
                                                <Listeners>
                                                </Listeners>
                                                <AjaxEvents>
                                                </AjaxEvents>
                                            </cc1:CrmComboComp>

                                        </Body>
                                    </rx:RowLayout>
                                    <%--                                    <rx:RowLayout runat="server" ID="RowLayout18">
                                        <Body>
                                            <cc1:CrmPicklistComp runat="server" ID="new_Channel" ObjectId="201100097" UniqueName="new_Channel"
                                                FieldLabelWidth="70" Width="230" PageSize="50">
                                            </cc1:CrmPicklistComp>
                                        </Body>
                                    </rx:RowLayout>--%>
                                      <rx:RowLayout runat="server" ID="RowLayout23">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_InstructionStartCorporationId" ObjectId="201100097" UniqueName="new_InstructionStartCorporationId"
                                                FieldLabelWidth="70" Width="230" PageSize="50">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                        </Body>
                        <Buttons>
                            <rx:Button runat="server" ID="UserPoolMap" Text="Alan Listesi" Icon="ApplicationViewList" Width="100">
                                <Listeners>
                                    <Click Handler="ShowUserPoolMap(hdnPoolId.getValue(),hdnViewList.getValue());" />
                                </Listeners>
                            </rx:Button>
                            <rx:Button runat="server" ID="ToolbarButtonLog" Text="(F9)" Icon="Book"
                                Width="100">
                                <Listeners>
                                    <Click Handler="LogWindow();" />
                                </Listeners>
                            </rx:Button>
                            <rx:Button runat="server" ID="ToolbarButtonFind" Text="(F9)" Icon="MagnifierZoomIn"
                                Width="100">
                                <Listeners>
                                    <Click Handler="GridPanelMonitoring.reload();" />
                                </Listeners>
                            </rx:Button>
                            <rx:Button runat="server" ID="ToolbarButtonClear" Text="(Ctrl+F9)" Icon="Erase">
                                <Listeners>
                                    <Click Handler="ToolbarButtonClearOnClik();" />
                                </Listeners>
                            </rx:Button>
                            <%--<rx:Button runat="server" ID="ToolbarButtonTransfer" Text="NEW_TRANSFER_RECORD"
                                    Icon="MoneyAdd" Width="100">
                                    <AjaxEvents>
                                        <Click OnEvent="ToolbarButtonTransferClick">
                                            <EventMask ShowMask="true" Msg="....." />
                                        </Click>
                                    </AjaxEvents>
                                    <Listeners>
                                        <Click Handler="" />
                                    </Listeners>
                                </rx:Button>
                                <rx:Button runat="server" ID="ToolbarButtonPayment" Text="NEW_PAYMENT_RECORD"
                                    Icon="MoneyDelete" Width="100">
                                    <AjaxEvents>
                                        <Click OnEvent="ToolbarButtonPaymentClick">
                                            <EventMask ShowMask="true" Msg="....." />
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>--%>
                        </Buttons>
                    </rx:PanelX>
                </td>
            </tr>
        </table>
        <rx:GridPanel runat="server" ID="GridPanelMonitoring" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
            <Tools>
                <Items>
                    <rx:ToolButton runat="server" ID="ToolButton1" ToolTypeIcon="Maximize">
                        <Listeners>
                            <Click Handler="GridPanelMonitoring.fullScreen();" />
                        </Listeners>
                    </rx:ToolButton>
                </Items>
            </Tools>
            <DataContainer>
                <DataSource OnEvent="ToolbarButtonFindClick">
                </DataSource>
                <Parameters>
                    <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                    <rx:Parameter Name="limit" Value="20" Mode="Value"></rx:Parameter>
                </Parameters>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server" ShowNumber="true"
                    SingleSelect="true">
                    <Listeners>
                        <RowDblClick Handler="ShowWindow(GridPanelMonitoring.id,GridPanelMonitoring.selectedRecord.ID,GridPanelMonitoring.selectedRecord.ObjectId,4);" />

                    </Listeners>
                </rx:RowSelectionModel>
            </SelectionModel>
            <BottomBar>
                <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelMonitoring">
                    <Buttons>
                        <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload">
                            <AjaxEvents>
                                <Click OnEvent="ToolbarButtonFindClick">
                                    <EventMask ShowMask="false" />
                                    <ExtraParams>
                                        <rx:Parameter Name="Excel" Value="1" Mode="Value" />
                                    </ExtraParams>
                                </Click>
                            </AjaxEvents>
                        </rx:SmallButton>
                        <rx:SmallButton ID="BtnSb1" Icon="Database" Text="CRM.NEW_PROCESSMONITORING_LIST_TOTAL">
                            <AjaxEvents>
                                <Click OnEvent="ToolbarButtonTotal" Success="windowTotal.show();">
                                </Click>
                            </AjaxEvents>
                        </rx:SmallButton>
                    </Buttons>
                    <%-- <Buttons>
                    <rx:SmallButton ID="btnHold" Text=".." Icon="ControlPause">
                        <AjaxEvents>
                            <Click OnEvent="BtnHoldClick">
                                <EventMask ShowMask="true" Msg="..." />
                            </Click>
                        </AjaxEvents>
                    </rx:SmallButton>
                    <rx:SmallButton ID="btnResume" Text="..." Icon="ControlRewind">
                        <AjaxEvents>
                            <Click OnEvent="BtnResumeClick">
                                <EventMask ShowMask="true" Msg="..." />
                            </Click>
                        </AjaxEvents>
                    </rx:SmallButton>
                </Buttons>--%>
                </rx:PagingToolBar>
            </BottomBar>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>
        <rx:Window ID="windowTotal" runat="server" Width="500" Height="200" Modal="true"
            Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false"
            Title="CRM.NEW_PROCESSMONITORING_LIST_TOTAL">
            <Body>
                <rx:GridPanel runat="server" ID="GridPanelTotal" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
                    Height="150" Editable="false" Mode="local" AutoLoad="false" Width="1200" AjaxPostable="true">
                    <SelectionModel>
                        <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true" SingleSelect="true">
                        </rx:RowSelectionModel>
                    </SelectionModel>
                    <LoadMask ShowMask="true" />
                </rx:GridPanel>
            </Body>
        </rx:Window>
    </form>
</body>
</html>
