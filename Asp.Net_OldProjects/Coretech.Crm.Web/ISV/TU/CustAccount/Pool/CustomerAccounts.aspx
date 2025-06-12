<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_Pool_CustomerAccounts" CodeBehind="CustomerAccounts.aspx.cs" %>

<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<%@ Register Src="../Sender/SenderFinde.ascx" TagPrefix="uc1" TagName="SenderFinde" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="../Js/global.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="hdnSenderID"></rx:Hidden>
        <rx:Hidden runat="server" ID="hdnAccountTypeID"></rx:Hidden>
        <rx:Hidden runat="server" ID="hdnCddStatus"></rx:Hidden>
        <rx:KeyMap runat="server" ID="KeyMap1">
            <rx:KeyBinding>
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="gpCustAccounts.reload();" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="110" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Listele">
            <Tools>
                <Items>
                    <rx:ToolButton ToolTypeIcon="Refresh" runat="server" ID="btnInformation">
                        <Listeners>
                            <Click Handler="ClearAll();" />
                        </Listeners>
                    </rx:ToolButton>
                </Items>
            </Tools>
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout101" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="Sender" runat="server" ObjectId="201100052" UniqueName="Sender"
                                    PageSize="50" FieldLabelWidth="100" Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_NationalityID" runat="server" ObjectId="201100052"
                                    UniqueName="new_NationalityID" FieldLabelWidth="100" Width="150"
                                    PageSize="50">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderNumber" runat="server" ObjectId="201100052" UniqueName="new_SenderNumber"
                                    PageSize="50" FieldLabelWidth="100" Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout18" runat="server">
                            <Body>
                                <rx:CheckField ID="cfShowMobileCustomer" runat="server" FieldLabel="Mobil Müşterileri Göster"
                                    PageSize="50" FieldLabelWidth="300" Width="150" Checked="true">
                                </rx:CheckField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout8" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountTypeId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountTypeId"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                    <AjaxEvents>
                                        <Change OnEvent="new_CustAccountTypeChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout17">
                            <Body>
                                <cc1:CrmPicklistComp ID="new_CorporatedConfirmStatus" runat="server" ObjectId="201100052" UniqueName="new_CorporatedConfirmStatus"
                                    FieldLabelWidth="100" Width="150" PageSize="50">
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderIdendificationNumber1" runat="server" ObjectId="201100052" UniqueName="new_SenderIdendificationNumber1"
                                    PageSize="50" FieldLabelWidth="100" Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout7" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_SenderSegmentationID" runat="server" ObjectId="201100052" UniqueName="new_SenderSegmentationID"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <cc1:CrmTextFieldComp ID="CardNumber" runat="server" ObjectId="201600019" UniqueName="CardNumber"
                                    PageSize="50" FieldLabelWidth="100" Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountCurrencyId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountCurrencyId"
                                    FieldLabelWidth="100" Width="150" PageSize="50" LookupViewUniqueName="CURRENCY_TR">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout13">
                            <Body>
                                <cc1:CrmPicklistComp ID="new_FraudStatus" runat="server" ObjectId="201100052" UniqueName="new_FraudStatus"
                                    FieldLabelWidth="100" Width="150" PageSize="50">
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>

                <rx:Button runat="server" ID="btnRefresh" Text="" Icon="Magnifier"
                    Width="120">
                    <Listeners>
                        <Click Handler="gpCustAccounts.reload();"></Click>
                    </Listeners>
                </rx:Button>
                <rx:Button runat="server" ID="btnSenderEditUpdate" Icon="Add" Text="Yeni Gerçek Müşteri">
                    <Listeners>
                        <Click Handler="windowTotal.show();" />
                    </Listeners>
                </rx:Button>
                <rx:Button runat="server" ID="btnCorporatedCustomerCreate" Icon="Add" Text="Yeni Tüzel Müşteri">
                    <AjaxEvents>
                        <Click OnEvent="btnTuzelSenderEditUpdate_Click"></Click>
                    </AjaxEvents>

                    <%-- <Listeners>
                        <Click Handler="windowTuzel.show();" />
                    </Listeners>--%>
                </rx:Button>
                <rx:Button ID="btnCreateIOMCustomer" runat="server" Text="IOM Müşteri" Icon="BookmarkGo">
                    <AjaxEvents>
                        <Click OnEvent="btnIOM_Customer_Click"></Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>

        </rx:PanelX>
        <rx:GridPanel runat="server" ID="gpCustAccounts" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
            <Tools>
                <Items>
                    <rx:ToolButton runat="server" ID="ToolButton1" ToolTypeIcon="Maximize">
                        <Listeners>
                            <Click Handler="gpCustAccounts.fullScreen();" />
                        </Listeners>
                    </rx:ToolButton>
                </Items>
            </Tools>
            <DataContainer>
                <DataSource OnEvent="GpCustAccountsReload">
                </DataSource>
                <Parameters>
                    <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                    <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                </Parameters>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="gpCustAccountsRowSelectionModel1" runat="server" ShowNumber="true"
                    SingleSelect="true">
                    <AjaxEvents>
                        <RowDblClick Before="hdnSenderID.setValue(gpCustAccounts.selectedRecord.ID);hdnAccountTypeID.setValue(gpCustAccounts.selectedRecord.new_CustAccountTypeId);hdnCddStatus.setValue(gpCustAccounts.selectedRecord.new_CorporatedConfirmStatus);"
                            OnEvent="RowDblClickOnEvent">
                        </RowDblClick>
                    </AjaxEvents>
                </rx:RowSelectionModel>
            </SelectionModel>
            <BottomBar>
                <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="gpCustAccounts">
                    <Buttons>
                        <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnExportToExcel">
                            <AjaxEvents>
                                <Click OnEvent="GpCustAccountsReload">
                                    <ExtraParams>
                                        <rx:Parameter Name="Excel" Value="1" Mode="Value" />
                                    </ExtraParams>
                                    <EventMask ShowMask="false" />
                                </Click>
                            </AjaxEvents>
                        </rx:SmallButton>
                    </Buttons>
                </rx:PagingToolBar>
            </BottomBar>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>
        <rx:Window ID="windowTotal" runat="server" Width="500" Height="200" Modal="true"
            Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false"
            Title="Gerçek Müşteri Oluşturma İşlemleri">

            <Body>
                <rx:PanelX ID="pnl2" runat="server" ContainerPadding="true" Padding="true" Border="false">
                    <Body>

                        <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="100%" BorderStyle="None">
                            <Rows>
                                <rx:RowLayout ID="RowLayout9" runat="server">
                                    <Body>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout31" ColumnWidth="33%">
                                            <Rows>
                                                <rx:RowLayout ID="RowLayout10" runat="server">
                                                    <Body>
                                                        <rx:CheckField FieldLabelWidth="50" ID="checkEur" runat="server" FieldLabel="EURO"></rx:CheckField>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="33%">
                                            <Rows>
                                                <rx:RowLayout ID="RowLayout11" runat="server">
                                                    <Body>
                                                        <rx:CheckField ID="checkUsd" runat="server" FieldLabel="USD"></rx:CheckField>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="33%">
                                            <Rows>
                                                <rx:RowLayout ID="RowLayout12" runat="server">
                                                    <Body>
                                                        <rx:CheckField ID="checkTry" runat="server" FieldLabel="TRY"></rx:CheckField>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>

                </rx:PanelX>
            </Body>
            <Buttons>
                <rx:Button ID="BtnContinue" runat="server" Text="CRM.NEW_FRAUDLOG_BTN_CONTINUE" Icon="BookmarkGo">
                    <AjaxEvents>
                        <Click OnEvent="btnSenderEditUpdate_Click" Success="windowTotal.hide();"></Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:Window>
        <rx:Window ID="windowTuzel" runat="server" Width="350" Height="200" Modal="true"
            Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false"
            Title="Tüzel Müşteri Oluşturma İşlemleri">

            <Body>
                <rx:PanelX ID="PanelX1" runat="server" ContainerPadding="true" Padding="true" Border="false">
                    <Body>

                        <rx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="100%" BorderStyle="None">
                            <Rows>
                                <rx:RowLayout ID="RowLayout5" runat="server">
                                    <Body>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="33%">
                                            <Rows>
                                                <rx:RowLayout ID="RowLayout14" runat="server">
                                                    <Body>
                                                        <rx:CheckField FieldLabelWidth="50" ID="checkTEur" runat="server" FieldLabel="EURO"></rx:CheckField>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="33%">
                                            <Rows>
                                                <rx:RowLayout ID="RowLayout15" runat="server">
                                                    <Body>
                                                        <rx:CheckField ID="checkTUsd" runat="server" FieldLabel="USD"></rx:CheckField>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="33%">
                                            <Rows>
                                                <rx:RowLayout ID="RowLayout16" runat="server">
                                                    <Body>
                                                        <rx:CheckField ID="checkTTry" runat="server" FieldLabel="TRY"></rx:CheckField>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>

                </rx:PanelX>
            </Body>
            <Buttons>
                <rx:Button ID="Button2" runat="server" Text="CRM.NEW_FRAUDLOG_BTN_CONTINUE" Icon="BookmarkGo">
                    <AjaxEvents>
                        <Click OnEvent="btnTuzelSenderEditUpdate_Click" Success="windowTuzel.hide();"></Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:Window>
    </form>
</body>
</html>

<script type="text/javascript">
    function RedirectToWindow(GridId, accountTypeID, senderID) {
        var url = window.top.GetWebAppRoot;

    }

    function ClearAll() {
        var objArr = new Array();

        if (typeof (new_CustAccountTypeId) != "undefined")
            objArr.push(new_CustAccountTypeId);
        if (typeof (Sender) != "undefined")
            objArr.push(Sender);
        if (typeof (new_SenderId) != "undefined")
            objArr.push(new_SenderId);
        if (typeof (new_CustAccountCurrencyId) != "undefined")
            objArr.push(new_CustAccountCurrencyId);
        if (typeof (new_NationalityID) != "undefined")
            objArr.push(new_NationalityID);
        if (typeof (new_SenderNumber) != "undefined")
            objArr.push(new_SenderNumber);
        if (typeof (new_SenderIdendificationNumber1) != "undefined")
            objArr.push(new_SenderIdendificationNumber1);
        if (typeof (new_SenderIdendificationNumber1Vkn) != "undefined")
            objArr.push(new_SenderIdendificationNumber1Vkn);
        if (typeof (CardNumber) != "undefined")
            objArr.push(CardNumber);
        if (typeof (new_CorporatedConfirmStatus) != "undefined")
            objArr.push(new_CorporatedConfirmStatus);

        for (var i = 0; i < objArr.length; i++) {
            objArr[i].clear();
            objArr[i].focus();
        }
    }
</script>
