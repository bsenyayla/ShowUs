<%@ Page Language="C#" AutoEventWireup="true" Inherits="Sender_CustAccountAuthApproveList" ValidateRequest="false" CodeBehind="CustAccountAuthApproveList.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../Js/global.js"></script>

</head>

<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="hdnCustAccountAuthApproveID"></rx:Hidden>
        <rx:KeyMap runat="server" ID="KeyMap1">
            <rx:KeyBinding>
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="GpCustAccountsAuthApprove.reload();" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>

        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="110" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Listele">

            <Body>

                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="60%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout9">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderId" ObjectId="201500041" UniqueName="new_SenderId" RequirementLevel="BusinessRequired"
                                    LookupViewUniqueName="CORPORATED_SENDER_LIST" Width="150" PageSize="50"
                                    FieldLabel="150">
                                    <AjaxEvents>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout25">
                            <Body>
                                <cc1:CrmComboComp ID="new_SenderPersonId" runat="server" ObjectId="202000029" UniqueName="new_SenderPersonId" RequirementLevel="BusinessRequired"
                                     LookupViewUniqueName="SENDER_PERSON_LOOKUP"  FieldLabel="200" Width="200" PageSize="50">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="202000029" FromUniqueName="new_SenderId" ToObjectId="201500041" ToUniqueName="new_SenderId" />
                                    </Filters>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountId" runat="server" ObjectId="202000029" UniqueName="new_CustAccountId" LookupViewUniqueName="CUSTACCOUNTS_LOOKUP" RequirementLevel="BusinessRequired"
                                    FieldLabelWidth="150" Width="200" PageSize="50">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="202000029" FromUniqueName="new_SenderId" ToObjectId="201500042" ToUniqueName="new_SenderId" />
                                    </Filters>

                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout11">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="UserName" ObjectId="1" UniqueName="UserName"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>              
                <rx:Button runat="server" ID="btnRefresh" Text="" Icon="Magnifier"
                    Width="30">
                    <Listeners>
                        <Click Handler="GpCustAccountsAuthApprove.reload();"></Click>
                    </Listeners>
                </rx:Button>
            </Buttons>

        </rx:PanelX>
        <rx:GridPanel runat="server" ID="GpCustAccountsAuthApprove" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
            <DataContainer>
                <DataSource OnEvent="GpCustAccountsAuthApproveReload">
                </DataSource>
                <Parameters>
                    <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                    <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                </Parameters>
            </DataContainer>
            <ColumnModel>
                <Columns>
                    <rx:GridColumns ColumnId="Id" Width="100" Header="Id" Sortable="false"
                        MenuDisabled="true" Hidden="true" DataIndex="ID" />
                    <rx:GridColumns ColumnId="VALUE" Width="100" Header="Ad" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="VALUE" />
                    <rx:GridColumns ColumnId="new_IBAN" Width="100" Header="Iban" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="new_IBAN" />
                    <rx:GridColumns ColumnId="CustAccountNumber" Width="100" Header="Hesap No" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="CustAccountNumber" />
                    <rx:GridColumns ColumnId="new_AuthType" Width="100" Header="Yetki Tipi" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="new_AuthType" />
                     <rx:GridColumns ColumnId="UserName" Width="100" Header="Kullanıcı Adı" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="UserName" />
                      <rx:GridColumns ColumnId="new_ActionType" Width="100" Header="Yapılan İşlem" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="new_ActionType" />
                </Columns>
            </ColumnModel>
            <SelectionModel>
                <rx:RowSelectionModel ID="GpCustAccountsAuthApproveRowSelectionModel" runat="server" ShowNumber="true"
                    SingleSelect="true">
                    <AjaxEvents>
                        <RowDblClick Before="hdnCustAccountAuthApproveID.setValue(GpCustAccountsAuthApprove.selectedRecord.ID);"
                            OnEvent="RowDblClickOnEvent">
                        </RowDblClick>
                    </AjaxEvents>
                </rx:RowSelectionModel>
            </SelectionModel>
            <BottomBar>
                <rx:PagingToolBar runat="server" ID="PagingToolBar2" ControlId="GpCustAccountsAuthApprove">
                </rx:PagingToolBar>
            </BottomBar>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>

    </form>
</body>
</html>
