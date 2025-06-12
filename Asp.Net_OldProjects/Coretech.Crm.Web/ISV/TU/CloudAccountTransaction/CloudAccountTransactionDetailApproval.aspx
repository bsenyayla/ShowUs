<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CloudAccountTransactionDetailApproval.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.AccountTransactions.CloudAccountTransactionDetailApproval" %>
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
    <rx:RegisterResources runat="server" ID="RR" />
    <form id="form1" runat="server">
        <div>
           

            <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="670" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Bulut Tahsilat Hareketi">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="90%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout22" runat="server">
                            <Body>
                                <rx:Label ID="lCancelTransaction" runat="server" Text="Bulut Tahsilat İşlemi İptal Onayı." ForeColor="Red" Font-Bold="true" />
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout5" runat="server">
                            <Body>
                                   <cc1:CrmComboComp runat="server" ID="new_OfficeId" ObjectId="202000035" UniqueName="new_OfficeId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" LookupViewUniqueName="CloudAccountTransactionOfficeLookup2" ReadOnly="true">
                                    </cc1:CrmComboComp>


                                
                                   <%--<cc1:CrmComboComp runat="server" ID="new_OfficeId" ObjectId="202000035" UniqueName="new_OfficeId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" LookupViewUniqueName="OfficeLookup" RequirementLevel="None" AutoLoad="true" >
                                    <DataContainer>
                                        <DataSource OnEvent="newOfficeLoad">
                                        </DataSource>
                                    </DataContainer>
                                 </cc1:CrmComboComp>--%>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout6" runat="server">
                            <Body>
                                <cc1:CrmDateFieldComp ID="cloudPaymentDateS" runat="server" ObjectId="202000035" UniqueName="new_CloudPaymentDate"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout21" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_CloudPaymentId" runat="server" ObjectId="202000035" UniqueName="new_CloudPaymentId"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout7" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="Reference" runat="server" ObjectId="202000035" UniqueName="Reference"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout8" runat="server">
                            <Body>
                                <cc1:CrmDecimalComp ID="new_Amount" runat="server" ObjectId="202000035" UniqueName="new_Amount"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmDecimalComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout9" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_CurrencyCode" runat="server" ObjectId="202000035" UniqueName="new_CurrencyCode"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout10" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_PaymentExpCode" runat="server" ObjectId="202000035" UniqueName="new_PaymentExpCode"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout11" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderFullName" runat="server" ObjectId="202000035" UniqueName="new_SenderFullName"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout12" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderIdentityNo" runat="server" ObjectId="202000035" UniqueName="new_SenderIdentityNo"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout13" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderIban" runat="server" ObjectId="202000035" UniqueName="new_SenderIban"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout14" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_RecipientIban" runat="server" ObjectId="202000035" UniqueName="new_RecipientIban"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_RecipentBankName" runat="server" ObjectId="202000035" UniqueName="new_RecipentBankName"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout15" runat="server">
                            <Body>
                                <cc1:CrmTextAreaComp ID="new_Explanation" runat="server" ObjectId="202000035" UniqueName="new_Explanation"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextAreaComp>
                            </Body>
                        </rx:RowLayout>
                         <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_ErrorStatus" ObjectId="202000035" UniqueName="new_ErrorStatus" Hidden="false"
                                            Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" ReadOnly="true" Disabled="true" >
                               </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                      <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_ErrorExplanation" runat="server" ObjectId="202000035" UniqueName="new_ErrorExplanation"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        
                        <rx:RowLayout ID="RowLayout17" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_VirmanIdName" runat="server" ObjectId="202000035" UniqueName="new_VirmanIdName"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_BankTransactionRefNo" runat="server" ObjectId="202000035" UniqueName="new_BankTransactionRefNo"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout18" runat="server">
                            <Body>
                                    <cc1:CrmBooleanComp ID="new_IsNkolayRepresentative" runat="server" ObjectId="202000035" UniqueName="new_IsNkolayRepresentative"
                                                FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                            </cc1:CrmBooleanComp>
                         </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout20" runat="server">
                            <Body>
                                    <cc1:CrmBooleanComp ID="new_NKolayAccountTransferCompleted" runat="server" ObjectId="202000035" UniqueName="new_NKolayAccountTransferCompleted"
                                                FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                            </cc1:CrmBooleanComp>
                         </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout19" runat="server">
                            <Body>
                                    <cc1:CrmBooleanComp ID="new_IsNKolayLimitCreate" runat="server" ObjectId="202000035" UniqueName="new_IsNKolayLimitCreate"
                                                FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                            </cc1:CrmBooleanComp>
                         </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout16" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_NKolayLimitRefNo" runat="server" ObjectId="202000035" UniqueName="new_NKolayLimitRefNo"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
                 <%--<rx:Button ID="BtnSave" runat="server" Text="Kaydet" Icon="BookEdit" Visible="true" AutoPostBack="true">
                    <AjaxEvents>
                        <Click OnEvent="SaveOnEvent"></Click>
                    </AjaxEvents>
                </rx:Button>--%>
            </Buttons>
        </rx:PanelX>

            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentName" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnUploaded" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusId" runat="server"></rx:Hidden>
            <rx:Hidden ID="txtRecId" runat="server" FieldLabel="KayıtId"></rx:Hidden>
           
        </div>
    </form>
</body>
</html>