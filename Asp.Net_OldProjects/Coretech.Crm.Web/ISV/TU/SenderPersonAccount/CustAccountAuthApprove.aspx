<%@ Page Language="C#" AutoEventWireup="true" Inherits="Sender_CustAccountAuthApprove" ValidateRequest="false" CodeBehind="CustAccountAuthApprove.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

</head>

<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="hdnCustAccountAuthApproveId" runat="server" />
        <rx:Hidden ID="hdnCustAccountAuthId" runat="server" />
        <rx:Hidden ID="hdnConfirmStatus" runat="server" />
        <rx:Hidden ID="hdnActionType" runat="server" />
        <rx:Hidden ID="CreatedBy" runat="server" />
        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="560" AutoWidth="true" Title="Kullanıcı Hesap Yetki Onayı"
            customcss="Section3" Collapsed="false" Collapsible="false" Border="false" Frame="false">
            <Body>
                <rx:Fieldset runat="server" ID="FieldsetSenderInfo" AutoHeight="Normal" Height="130" AutoWidth="true"
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
                                        <cc1:CrmPicklistComp runat="server" ID="new_AuthType" ObjectId="202000029" RequirementLevel="BusinessRequired" Disabled="true"
                                            UniqueName="new_AuthType" Width="200"
                                            PageSize="500" FieldLabel="200" Mode="Remote">
                                        </cc1:CrmPicklistComp>
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
                <rx:Fieldset runat="server" ID="FieldsetApprove" AutoHeight="Normal" Height="30" Collapsible="false" Border="false">
                    <Body>

                        <rx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="10%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout15">
                                    <Body>
                                        <rx:Button ID="btnApprove" runat="server" Text="Onayla" Icon="Accept" Visible="true">
                                            <AjaxEvents>
                                                <Click OnEvent="btnApprove_Click"></Click>
                                            </AjaxEvents>
                                        </rx:Button>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>

                        <rx:ColumnLayout runat="server" ID="ColumnLayout10" ColumnWidth="10%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout17">
                                    <Body>

                                        <rx:Button ID="btnReject" runat="server" Text="Reddet" Icon="Decline" Visible="true">
                                            <AjaxEvents>
                                                <Click OnEvent="btnReject_Click"></Click>
                                            </AjaxEvents>
                                        </rx:Button>

                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>

                    </Body>

                </rx:Fieldset>
            </Body>

        </rx:PanelX>




    </form>
</body>
</html>

