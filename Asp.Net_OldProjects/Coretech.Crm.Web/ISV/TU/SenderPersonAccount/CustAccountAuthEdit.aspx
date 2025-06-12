<%@ Page Language="C#" AutoEventWireup="true" Inherits="Sender_CustAccountAuthEdit" ValidateRequest="false" CodeBehind="CustAccountAuthEdit.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="hdnCustAccountAuthID"></rx:Hidden>
        <rx:Hidden runat="server" ID="hdnConfirmStatus"></rx:Hidden>
        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="560" AutoWidth="true" Title="Kullanıcı Hesap Yetki Yönetimi"
            customcss="Section3" Collapsed="false" Collapsible="false" Border="false" Frame="false">
            <Body>
                <rx:Fieldset runat="server" ID="FieldsetButtons" AutoHeight="Normal" Height="35" AutoWidth="true" CustomCss="Section1" Collapsible="false" Border="false">
                    <Body>

                        <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="10%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout12">
                                    <Body>
                                        <rx:Button ID="btnNew" runat="server" Text="Yeni" Icon="Page">
                                            <AjaxEvents>
                                                <Click OnEvent="btnNew_Click"></Click>
                                            </AjaxEvents>
                                        </rx:Button>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>

                        <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="10%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout13">
                                    <Body>

                                        <rx:Button ID="btnSave" runat="server" Text="Kaydet" Icon="PageAdd">
                                            <AjaxEvents>
                                                <Click OnEvent="btnSave_Click"></Click>
                                            </AjaxEvents>
                                        </rx:Button>

                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>

                        <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="10%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout1">
                                    <Body>

                                        <rx:Button ID="Button1" runat="server" Text="Sil" Icon="PageDelete">
                                            <AjaxEvents>
                                                <Click OnEvent="btnDelete_Click"></Click>
                                            </AjaxEvents>
                                        </rx:Button>

                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>

                </rx:Fieldset>
                <rx:Fieldset runat="server" ID="FieldsetSenderInfo" AutoHeight="Normal" Height="150" AutoWidth="true"
                    CustomCss="Section1" Collapsible="false" Border="false">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="60%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout9">
                                    <Body>
                                        <cc1:CrmComboComp runat="server" ID="new_SenderId" ObjectId="201500041" UniqueName="new_SenderId" Disabled="true"
                                            LookupViewUniqueName="CORPORATED_SENDER_LIST" RequirementLevel="BusinessRequired" Width="150" PageSize="50"
                                            FieldLabel="150">
                                            <AjaxEvents>
                                            </AjaxEvents>
                                        </cc1:CrmComboComp>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout25">
                                    <Body>
                                        <cc1:CrmComboComp ID="new_SenderPersonId" runat="server" ObjectId="202000029" UniqueName="new_SenderPersonId" RequirementLevel="BusinessRequired" LookupViewUniqueName="SENDER_PERSON_LOOKUP" Disabled="true"
                                            FieldLabel="200" Width="200" PageSize="50">
                                            <Filters>
                                                <cc1:ComboFilter FromObjectId="202000029" FromUniqueName="new_SenderId" ToObjectId="201500041" ToUniqueName="new_SenderId" />
                                            </Filters>
                                        </cc1:CrmComboComp>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout2">
                                    <Body>
                                        <cc1:CrmComboComp ID="new_CustAccountId" runat="server" ObjectId="202000029" UniqueName="new_CustAccountId" RequirementLevel="BusinessRequired" LookupViewUniqueName="CUSTACCOUNTS_LOOKUP" Disabled="true"
                                            FieldLabelWidth="150" Width="200" PageSize="50">
                                            <Filters>
                                                <cc1:ComboFilter FromObjectId="202000029" FromUniqueName="new_SenderId" ToObjectId="201500042" ToUniqueName="new_SenderId" />
                                            </Filters>

                                        </cc1:CrmComboComp>
                                    </Body>
                                </rx:RowLayout>

                                <rx:RowLayout runat="server" ID="RowLayout3">
                                    <Body>
                                        <cc1:CrmPicklistComp runat="server" ID="new_AuthType" ObjectId="202000029" RequirementLevel="BusinessRequired"
                                            UniqueName="new_AuthType" Width="200"
                                            PageSize="500" FieldLabel="200" Mode="Remote">
                                            <AjaxEvents>
                                                <Change OnEvent="AuthTypeChange">
                                                </Change>
                                            </AjaxEvents>
                                        </cc1:CrmPicklistComp>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout4">
                                    <Body>
                                        <rx:Button ID="btnAddTransactionType" runat="server" Text="İşlem Tİpleri Ekle" Icon="Add">
                                            <AjaxEvents>
                                                <Click OnEvent="btnAddTransactionType_OnClick"></Click>
                                            </AjaxEvents>
                                        </rx:Button>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>

                    </Body>
                </rx:Fieldset>
                <rx:Fieldset runat="server" ID="Fieldset1" AutoHeight="Normal" Height="200" AutoWidth="true"
                    CustomCss="Section1" Collapsible="false" Border="false">
                    <Body>
                        <rx:GridPanel runat="server" ID="GridPanelTransactionType" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
                            Height="150" Width="500" Mode="Remote" AjaxPostable="true" Editable="false" AutoLoad="true">
                            <DataContainer>
                                <DataSource OnEvent="GrdTransactionTypeList">
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
                                    <rx:GridColumns ColumnId="VALUE" Width="300" Header="Mobil İşlem Tipi" Sortable="false"
                                        MenuDisabled="true" Hidden="false" DataIndex="VALUE" />
                                    <rx:GridColumns ColumnId="TransactionType" Width="300" Header="İşlem Tipi" Sortable="false"
                                        MenuDisabled="true" Hidden="false" DataIndex="TransactionType" />
                                </Columns>
                            </ColumnModel>
                            <SelectionModel>
                                <rx:RowSelectionModel ID="GridPanelTransactionTypelRowSelectionModel" runat="server" ShowNumber="true"
                                    SingleSelect="true">
                                </rx:RowSelectionModel>
                            </SelectionModel>
                            <BottomBar>
                                <rx:PagingToolBar runat="server" ID="PagingToolBar2" ControlId="GridPanelTransactionType">
                                </rx:PagingToolBar>
                            </BottomBar>
                            <LoadMask ShowMask="true" />
                        </rx:GridPanel>
                    </Body>
                </rx:Fieldset>

            </Body>

        </rx:PanelX>

        <rx:Window ID="windowTransactionsInfo" runat="server" Width="600" Height="400" Modal="true" WindowCenter="true"
            Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false"
            Title="İşlem Tipleri">
            <Body>
                <rx:PanelX ID="PanelX2" runat="server" ContainerPadding="true" Padding="true" Border="false">
                    <Body>
                        <rx:GridPanel runat="server" ID="GridPanelAllTransactionTypes" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
                            Height="300" Width="800" Mode="Remote" AjaxPostable="true" Editable="false" AutoLoad="true">
                            <DataContainer>
                                <DataSource OnEvent="GrdTransactionAllTypeList">
                                </DataSource>
                            </DataContainer>
                            <ColumnModel>
                                <Columns>
                                    <rx:GridColumns ColumnId="Id" Width="100" Header="Id" Sortable="false"
                                        MenuDisabled="true" Hidden="true" DataIndex="ID" />
                                    <rx:GridColumns ColumnId="VALUE" Width="300" Header="Mobil İşlem Tipi" Sortable="false"
                                        MenuDisabled="true" Hidden="false" DataIndex="VALUE" />
                                    <rx:GridColumns ColumnId="TransactionType" Width="300" Header="İşlem Tipi" Sortable="false"
                                        MenuDisabled="true" Hidden="false" DataIndex="TransactionType" />
                                </Columns>
                            </ColumnModel>
                            <SelectionModel>
                                <rx:CheckSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true"
                                    SingleSelect="true">
                                </rx:CheckSelectionModel>
                            </SelectionModel>
                            <BottomBar>
                                <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelAllTransactionTypes">
                                </rx:PagingToolBar>
                            </BottomBar>
                            <LoadMask ShowMask="true" />
                        </rx:GridPanel>
                    </Body>

                </rx:PanelX>
            </Body>
            <Buttons>
                <rx:Button ID="btnInsertCustAccountDetails" runat="server" Text="İşlem Tİpleri Ekle" Icon="BookAdd">
                    <AjaxEvents>
                        <Click OnEvent="btnInsertCustAccountDetails_Click" Success="windowTransactionsInfo.hide();"></Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:Window>
    </form>
</body>
</html>
