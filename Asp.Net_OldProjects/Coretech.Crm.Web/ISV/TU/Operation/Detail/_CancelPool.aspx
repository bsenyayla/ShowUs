<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_Detail_CancelPool" ValidateRequest="false" Codebehind="_CancelPool.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
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
        <rx:Hidden ID="hdnViewDefaultEditPage" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnPoolId" runat="server" Value="4">
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
                    <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="188" AutoWidth="true"
                        Border="true" Frame="true" Title="SEARCH">
                        <Tools>
                            <Items>
                                <rx:ToolButton IconCls="icon-information" runat="server" ID="btnInformation">
                                    <Listeners>
                                        <Click Handler="OpenHelp(1)" />
                                    </Listeners>
                                </rx:ToolButton>
                            </Items>
                        </Tools>
                        <Body>
                            <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="40%">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout1" runat="server">
                                        <Body>
                                            <%--<cc1:CrmComboComp ID="new_SenderCountryID" runat="server" ObjectId="201100097" UniqueName="new_SenderCountryID"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                            </cc1:CrmComboComp>--%>
                                            <cc1:CrmComboComp runat="server" ID="new_SenderCountryID" ObjectId="201100097"
                                                UniqueName="new_SenderCountryID" Width="150"
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
                                    <rx:RowLayout ID="Rl1" runat="server">
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
                                    <rx:RowLayout ID="RowLayout9" runat="server">
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
                                                        UniqueName="new_FormAmount2" FieldLabelWidth="110" Width="100">
                                                    </cc1:CrmDecimalComp>
                                                    <rx:Label runat="server" Text="  " ID="Label3" Width="10" />
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout10">
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
                                    <rx:RowLayout runat="server" ID="RowLayout21">
                                        <Body>
                                            <rx:MultiField ID="MultiField6" runat="server">
                                                <Items>
                                                    <cc1:CrmTextFieldComp ID="new_SerialNumber" runat="server" ObjectId="201100097"
                                                        UniqueName="new_SerialNumber" FieldLabelWidth="160" Width="230">
                                                    </cc1:CrmTextFieldComp>
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
                                                        UniqueName="new_PaymentDate2" FieldLabelWidth="110" Width="100">
                                                    </cc1:CrmDateFieldComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="28%">
                                <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout6">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_FormTransactionTypeID" ObjectId="201100097"
                                                LookupViewUniqueName="TRANSACTIONTYPE_GONDERIM" UniqueName="new_FormTransactionTypeID"
                                                FieldLabelWidth="160" Width="100" PageSize="50">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout13">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_FormSourceTransactionTypeID" ObjectId="201100097"
                                                LookupViewUniqueName="TRANSACTIONTYPE_TAHSILAT" UniqueName="new_FormSourceTransactionTypeID"
                                                FieldLabelWidth="160" Width="100" PageSize="50">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout7">
                                        <Body>
                                            <%--<cc1:CrmComboComp runat="server" ID="new_FormReceiverCountryId" ObjectId="201100097"
                                                UniqueName="new_FormReceiverCountryId" FieldLabelWidth="100" Width="100" PageSize="50">
                                            </cc1:CrmComboComp>--%>
                                            <cc1:CrmComboComp runat="server" ID="new_FormReceiverCountryId" ObjectId="201100097"
                                                UniqueName="new_FormReceiverCountryId" Width="150"
                                                PageSize="500" FieldLabelWidth="160" Mode="Remote">
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
                                    <rx:RowLayout runat="server" ID="RowLayout5">
                                        <Body>
                                            <cc1:CrmTextFieldComp runat="server" ID="new_FormCustomerNumber" ObjectId="201100097"
                                                UniqueName="new_FormCustomerNumber" FieldLabelWidth="160" Width="100">
                                            </cc1:CrmTextFieldComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout8">
                                        <Body>
                                            <cc1:CrmTextFieldComp runat="server" ID="new_SenderId" ObjectId="201100097" UniqueName="new_SenderId"
                                                FieldLabelWidth="160" Width="150">
                                            </cc1:CrmTextFieldComp>
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
                    <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                </Parameters>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server" ShowNumber="true"
                    SingleSelect="true">
                    <Listeners>
                        <RowDblClick Handler="ShowWindow(GridPanelMonitoring.id,GridPanelMonitoring.selectedRecord.ID,GridPanelMonitoring.selectedRecord.ObjectId,3);" />
                    </Listeners>
                </rx:RowSelectionModel>
            </SelectionModel>
            <BottomBar>
                <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelMonitoring">
                </rx:PagingToolBar>
            </BottomBar>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>
    </form>
</body>
</html>
