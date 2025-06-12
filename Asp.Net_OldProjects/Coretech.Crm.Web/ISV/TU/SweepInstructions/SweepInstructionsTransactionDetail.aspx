<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SweepInstructionsTransactionDetail.aspx.cs" Inherits="SweepInstructionsTransactionDetail" ValidateRequest="false" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Import Namespace="Coretech.Crm.Utility.Util" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <div>
            <rx:Hidden ID="hdnTransactionTypeId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnTransactionType" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatus" runat="server"></rx:Hidden>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="600" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Süpürme Talimat Hareketi">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="90%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout22" runat="server">
                            <Body>
                                   <cc1:CrmTextFieldComp runat="server" ID="Reference" ObjectId="202000057" UniqueName="Reference" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" ReadOnly="true">
                                    </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
 
                        <rx:RowLayout ID="RowLayout6" runat="server">
                            <Body>
                                <cc1:CrmDateFieldComp ID="CreatedOn" runat="server" ObjectId="202000057" UniqueName="CreatedOn"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout ID="RowLayout5" runat="server">
                            <Body>
                                   <cc1:CrmComboComp runat="server" ID="new_SweepInstructionsId" ObjectId="202000057" UniqueName="new_SweepInstructionsId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" ReadOnly="true">
                                    </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout ID="RowLayout23" runat="server">
                            <Body>
                                   <cc1:CrmComboComp runat="server" ID="new_CorporationId" ObjectId="202000057" UniqueName="new_CorporationId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" ReadOnly="true">
                                    </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout ID="RowLayout24" runat="server">
                            <Body>
                                   <cc1:CrmComboComp runat="server" ID="new_SenderAccountId" ObjectId="202000057" UniqueName="new_SenderAccountId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" ReadOnly="true">
                                    </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout ID="RowLayout25" runat="server">
                            <Body>
                                   <cc1:CrmComboComp runat="server" ID="new_RecipientInstructionsCorpAccountId" ObjectId="202000057" UniqueName="new_RecipientInstructionsCorpAccountId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" ReadOnly="true">
                                    </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>


                        <rx:RowLayout ID="RowLayout21" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_RecipientInstructionsAccountNo" runat="server" ObjectId="202000057" UniqueName="new_RecipientInstructionsAccountNo"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout7" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_RecipientInstructionsAccountIBAN" runat="server" ObjectId="202000057" UniqueName="new_RecipientInstructionsAccountIBAN"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout8" runat="server">
                            <Body>
                                <cc1:CrmDecimalComp ID="new_Amount" runat="server" ObjectId="202000057" UniqueName="new_Amount"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmDecimalComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout9" runat="server">
                            <Body>
                                   <cc1:CrmComboComp runat="server" ID="new_AmountCurrency" ObjectId="202000057" UniqueName="new_AmountCurrency" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" ReadOnly="true">
                                    </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout10" runat="server">
                            <Body>
                                   <cc1:CrmComboComp runat="server" ID="new_VirmanId" ObjectId="202000057" UniqueName="new_VirmanId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" ReadOnly="true">
                                    </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout11" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_BankReferenceGuid" runat="server" ObjectId="202000057" UniqueName="new_BankReferenceGuid"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout12" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_BankTransactionRefNo" runat="server" ObjectId="202000057" UniqueName="new_BankTransactionRefNo"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout13" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_ErrorStatus" ObjectId="202000057" UniqueName="new_ErrorStatus" Hidden="false"
                                            Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" ReadOnly="true" Disabled="true" >
                               </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout14" runat="server">
                            <Body>
                                <cc1:CrmTextAreaComp ID="new_ErrorExplanation" runat="server" ObjectId="202000057" UniqueName="new_ErrorExplanation"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextAreaComp>
                            </Body>
                        </rx:RowLayout>
 
                        <rx:RowLayout ID="RowLayout15" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_TransactionStatus" ObjectId="202000057" UniqueName="new_TransactionStatus" Hidden="false"
                                            Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" ReadOnly="true" Disabled="true" >
                               </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
            </Buttons>
        </rx:PanelX>

            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentName" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnUploaded" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusId" runat="server"></rx:Hidden>

        
        </div>
    </form>
</body>
</html>