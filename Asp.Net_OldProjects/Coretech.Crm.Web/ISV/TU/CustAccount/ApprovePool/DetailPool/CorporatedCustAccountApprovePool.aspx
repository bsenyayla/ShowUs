<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CorporatedCustAccountApprovePool.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.CustAccount.ApprovePool.DetailPool.CorporatedCustAccountApprovePool" %>

<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<%--<%@ Register Src="../Sender/SenderFinde.ascx" TagPrefix="uc1" TagName="SenderFinde" %>--%>

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
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="85" AutoWidth="true" Collapsed="false" Collapsible="False"
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
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="33%">
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
                      
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="33%">
                    <Rows>
                     
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderIdendificationNumber1" runat="server" ObjectId="201100052" UniqueName="new_SenderIdendificationNumber1"
                                    PageSize="50" FieldLabelWidth="100" Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                          <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderNumber" runat="server" ObjectId="201100052" UniqueName="new_SenderNumber"
                                    PageSize="50" FieldLabelWidth="100" Width="150">
                                </cc1:CrmTextFieldComp>
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
                </rx:PagingToolBar>
            </BottomBar>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>
        <rx:Window ID="windowTotal" runat="server" Width="350" Height="200" Modal="true"
            Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false"
            Title="Çerçek Müşteri Oluşturma İşlemleri">

            <Body>
                <rx:PanelX ID="pnl2" runat="server" ContainerPadding="true" Padding="true" Border="false">
                    <Body>               

                        <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="100%" BorderStyle="None">
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
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="33%">
                                            <Rows>
                                                <rx:RowLayout ID="RowLayout11" runat="server">
                                                    <Body>
                                                        <rx:CheckField ID="checkUsd" runat="server" FieldLabel="USD"></rx:CheckField>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="33%">
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

                        <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="100%" BorderStyle="None">
                            <Rows>                               
                                <rx:RowLayout ID="RowLayout5" runat="server">
                                    <Body>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="33%">
                                            <Rows>
                                                <rx:RowLayout ID="RowLayout14" runat="server">
                                                    <Body>
                                                        <rx:CheckField FieldLabelWidth="50" ID="checkTEur" runat="server" FieldLabel="EURO"></rx:CheckField>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="33%">
                                            <Rows>
                                                <rx:RowLayout ID="RowLayout15" runat="server">
                                                    <Body>
                                                        <rx:CheckField ID="checkTUsd" runat="server" FieldLabel="USD"></rx:CheckField>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout10" ColumnWidth="33%">
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

    document.getElementById('lbl_Sender').textContent = 'Firma Unvanı';


    function ClearAll() {
        var objArr = new Array();

        if (typeof (new_CustAccountTypeId) != "undefined")
            objArr.push(new_CustAccountTypeId);
        if (typeof (Sender) != "undefined")
            objArr.push(Sender);
        if (typeof (new_NationalityID) != "undefined")
            objArr.push(new_NationalityID);
        if (typeof (new_SenderNumber) != "undefined")
            objArr.push(new_SenderNumber);
        if (typeof (new_SenderIdendificationNumber1) != "undefined")
            objArr.push(new_SenderIdendificationNumber1);

        for (var i = 0; i < objArr.length; i++) {
            objArr[i].clear();
            objArr[i].focus();
        }
    }
</script>
