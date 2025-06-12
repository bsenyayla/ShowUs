<%@ Page Language="C#" AutoEventWireup="true" Inherits="AccountTransactions_CashAccountTransaction" ValidateRequest="false" Codebehind="CashAccountTransaction.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script src="Js/_Virman.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>

</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="new_CashAccountTransactionId" runat="server" />

        <rx:Hidden runat="server" ID="hdnRecid">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnReportId">
        </rx:Hidden>

        <rx:PanelX runat="server" ID="pnl1" AutoWidth="false" AutoHeight="Normal" Border="false" Title="Kasa Hesabı İşlemleri">
        </rx:PanelX>

        <rx:Fieldset runat="server" ID="Fieldset1" AutoHeight="Normal" AutoWidth="true" CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_TransactionType" ObjectId="201500024"
                                    RequirementLevel="BusinessRequired" UniqueName="new_TransactionType" Width="150"
                                    PageSize="500" FieldLabel="200" Mode="Remote">
                                    <AjaxEvents>
                                        <Change OnEvent="TransactionTypeChange">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout runat="server" ID="RowLayout9">
                            <Body>
                                <cc1:CrmMoneyComp runat="server" ID="new_Amount" ObjectId="201500024" UniqueName="new_Amount" Width="150" PageSize="50" FieldLabel="200">
                                </cc1:CrmMoneyComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <%--<rx:Button ID="btnSave" runat="server" Icon="Disk" Text="Kaydet"
                                    Width="60">
                                    <AjaxEvents>
                                        <Click OnEvent="btnSaveOnEvent" Before="CrmValidateForm(msg,e);">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>--%>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_ReferenceNumber" ObjectId="201500024" UniqueName="new_ReferenceNumber"
                                    Width="150" PageSize="50" FieldLabel="200" RequirementLevel="None">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>


    </form>
</body>
</html>

