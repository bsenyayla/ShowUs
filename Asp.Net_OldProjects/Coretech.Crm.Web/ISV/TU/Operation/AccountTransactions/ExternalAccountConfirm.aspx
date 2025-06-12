<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false" Inherits="Operation_External_Account_Confirm" CodeBehind="ExternalAccountConfirm.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="hdnReportId" />
        <rx:Hidden runat="server" ID="hdnRecId" />
        <rx:Fieldset runat="server" ID="PanelX3" AutoHeight="Normal" Height="160" AutoWidth="true"
            CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false" Title="Sorunlu Hesap Hareketi Aktarımı">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="80%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_ActionType" ObjectId="201400029" UniqueName="new_ActionType" RequirementLevel="BusinessRequired"
                                    Width="150">
                                    <AjaxEvents>
                                        <Change OnEvent="ComboField_ActionTypeChange">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RefNo" ObjectId="201400029" UniqueName="new_VirementNo" RequirementLevel="None"></cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout> 
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderAccountId" ObjectId="201400029" UniqueName="new_SenderAccountId" RequirementLevel="None"
                                    LookupViewUniqueName="AccountLookupView" Width="150">
                                    <DataContainer>
                                        <DataSource OnEvent="SenderAccountLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
            
                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientAccountId" ObjectId="201400029" UniqueName="new_RecipientAccountId" RequirementLevel="None"
                                    LookupViewUniqueName="AccountLookupView" Width="150">
                                    <AjaxEvents>
                                        <Change OnEvent="AccountChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                    <DataContainer>
                                        <DataSource OnEvent="RecipientAccountLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_AccountTransactionTypeId" ObjectId="201400028" UniqueName="new_AccountTransactionTypeId" Hidden="true"
                                    Width="150" PageSize="50" FieldLabel="200" RequirementLevel="None">

                                    <DataContainer>
                                        <DataSource OnEvent="AccountTransactionTypeLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                          <rx:RowLayout runat="server" ID="RowLayout8">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_Explanation" ObjectId="201400028" UniqueName="new_Explanation" RequirementLevel="None" Hidden="true"></cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>&nbsp;</Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <rx:Button ID="btnSave" runat="server" Icon="Accept" Text="Onayla"
                                    Width="60">
                                    <AjaxEvents>
                                        <Click OnEvent="ButtonConfirmClick" Before="CrmValidateForm(msg,e);">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout66">
                            <Body>
                                <rx:Label ID="lblError" runat="server" Visible="false">
                                </rx:Label>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
    </form>
</body>
</html>
