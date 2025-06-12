<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_Pool_AccountTransfer" CodeBehind="AccountTransfer.aspx.cs" %>

<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<%@ Register Src="../Sender/SenderFinde.ascx" TagPrefix="uc1" TagName="SenderFinde" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="../Js/global.js"></script>
    <style type="text/css">
        body .x-label {
            white-space: normal !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
         <rx:Hidden ID="RecId" runat="server" />
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="150" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Gönderen Hesap">

            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="65%">
                    <Rows>
                         <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="CustAccountOperationsHeaderRef" runat="server" ObjectId="201900032" UniqueName="CustAccountOperationsHeaderRef"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                </cc1:CrmTextFieldComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout101" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_SenderCustAccountOperationsId" runat="server" ObjectId="201900032" UniqueName="new_SenderCustAccountOperationsId"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                         <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="SSenderId" runat="server" ObjectId="201500042" UniqueName="new_SenderId"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                      
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout2" ColumnWidth="35%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout8" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_SenderAccountId" runat="server" ObjectId="201900032" UniqueName="new_SenderAccountId"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                          <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <cc1:CrmMoneyComp ID="new_SendAmount" runat="server" ObjectId="201900032" UniqueName="new_SendAmount"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                </cc1:CrmMoneyComp>

                            </Body>
                        </rx:RowLayout>
                      
                    </Rows>
                </rx:ColumnLayout>

                
            </Body>
           
        </rx:PanelX>

         <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="150" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Alıcı Hesap Hesap">

            <Body>
                  <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="50%">
                    <Rows>
                      
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_ReceiverCustAccountOperationsId" runat="server" ObjectId="201900032" UniqueName="new_ReceiverCustAccountOperationsId"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                          <rx:RowLayout ID="RowLayout7" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="RSenderId" runat="server" ObjectId="201500042" UniqueName="new_SenderId"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                      
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout5" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_ReceiverAccountId" runat="server" ObjectId="201900032" UniqueName="new_ReceiverAccountId"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                          <rx:RowLayout ID="RowLayout6" runat="server">
                            <Body>
                                <cc1:CrmMoneyComp ID="new_RecipientAmount" runat="server" ObjectId="201900032" UniqueName="new_RecipientAmount"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                </cc1:CrmMoneyComp>

                            </Body>
                        </rx:RowLayout>
                      
                    </Rows>
                </rx:ColumnLayout>
                
            </Body>
           
        </rx:PanelX>
        


    </form>
</body>
</html>
<script type="text/javascript">

    function Confirm() {
        Conti.confirm(
            DasMessages.NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM,
            Conti.MessageType.Question,
            "btnConfirm_Hidden.click();",
            ""
        );
    }
    function Reject() {
        Conti.confirm(
            DasMessages.NEW_CUSTACCOUNTOPERATION_SURE_REJECT,
            Conti.MessageType.Question,
            "btnReject_Hidden.click();",
            ""
        );
    }

    function SetUser() {
        //   debugger;

        if (UptSenderSelector.SelectedSender.length > 0)
            new_SenderId.setValue(UptSenderSelector.SelectedSender[0].Value, UptSenderSelector.SelectedSender[0].Key);
    }

    function ClearAll() {
        var objArr = new Array();

        if (typeof (new_CustAccountOperationTypeId) != "undefined")
            objArr.push(new_CustAccountOperationTypeId);
        if (typeof (new_CustAccountTypeId) != "undefined")
            objArr.push(new_CustAccountTypeId);
        if (typeof (new_SenderId) != "undefined")
            objArr.push(new_SenderId);
        if (typeof (new_CustAccountCurrencyId) != "undefined")
            objArr.push(new_CustAccountCurrencyId);
        if (typeof (new_CorporationId) != "undefined")
            objArr.push(new_CorporationId);
        if (typeof (new_OfficeId) != "undefined")
            objArr.push(new_OfficeId);
        if (typeof (CreatedOnS) != "undefined")
            objArr.push(CreatedOnS);
        if (typeof (CreatedOnE) != "undefined")
            objArr.push(CreatedOnE);

        for (var i = 0; i < objArr.length; i++) {
            objArr[i].clear();
            objArr[i].focus();
        }
    }

</script>
