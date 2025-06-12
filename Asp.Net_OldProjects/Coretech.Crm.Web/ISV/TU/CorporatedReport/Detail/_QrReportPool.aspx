<%@ Page Language="C#" AutoEventWireup="true" Inherits="_QrReportPoolList" Codebehind="_QrReportPool.aspx.cs" ValidateRequest="false" %>
 
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>

 
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script type="text/javascript">

        function ActionTemplate(Value) {
            //if (TransferId == "" || Action == 0 || TuStatusCode == 'TR002A')
            //    return RefNumber;
            
            if (Value == 0)
                return "<img src='" + GetWebAppRoot + "/images/1495118945_error.png' width=12 height=12 />";
            else if (Value == 1)
                return "<img src='" + GetWebAppRoot + "/images/success.png' width=12 height=12 />";
            else
                return "<img src='" + GetWebAppRoot + "/images/ico_18_role_x.gif' width=12 height=12 />";
           

        }
    </script>
    <script src="../Js/global.js"></script>
        <style type="text/css">
        body .x-label
        {
            white-space: normal !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="90" AutoWidth="true" Collapsed="false" Collapsible="False"
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
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="40%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout101" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderId" ObjectId="202000027" UniqueName="new_SenderId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" LookupViewUniqueName="Kurumsal Gönderici Listesi_Mobile" RequirementLevel="None" AutoLoad="true" >
                                    <DataContainer>
                                        <DataSource OnEvent="newSenderLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                         <Change OnEvent="SenderOnChange">
                                         </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SendAmountCurrency" ObjectId="201900032" UniqueName="new_SendAmountCurrency"
                                    Width="150" PageSize="50" FieldLabel="150">
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientAmountCurrency" ObjectId="201900032" UniqueName="new_RecipientAmountCurrency"
                                    Width="150" PageSize="50" FieldLabel="150">
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
 

                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="60%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout11" runat="server">
                            <Body>
                                <rx:MultiField runat="server" ID="CreatedOnmf" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmDateFieldComp ID="CreatedOnS" runat="server" ObjectId="202000027" UniqueName="CreatedOn"
                                            FieldLabelShow="False" Width="82" PageSize="50">
                                        </cc1:CrmDateFieldComp>
                                        <cc1:CrmDateFieldComp ID="CreatedOnE" runat="server" ObjectId="202000027" UniqueName="CreatedOn"
                                            FieldLabelShow="False" Width="82" PageSize="50">
                                        </cc1:CrmDateFieldComp>
                                    </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnRefresh" Text="" Icon="Magnifier"
                    Width="100">
                    <Listeners>
                        <Click Handler="GridPanelCorporatedPreInfoList.reload();"></Click>
                    </Listeners>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
  
            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnTransactionType" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusId" runat="server"></rx:Hidden>
            <rx:GridPanel runat="server" ID="GridPanelCorporatedPreInfoList" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
                <DataContainer>
                    <DataSource OnEvent="GpCorporatedPreInfoListReload">
                    </DataSource>
                    <Parameters>
                        <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                        <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                    </Parameters>
                </DataContainer>  
                <ColumnModel>
                    <Columns>
                        
                            <rx:GridColumns ColumnId="SenderId" Width="100" Header="SenderId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="SenderId" />

                            <rx:GridColumns ColumnId="ReceiverId" Width="100" Header="ReceiverId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="ReceiverId" />

                            <rx:GridColumns ColumnId="TransactionRef" Width="100" Header="İşlem Referans No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TransactionRef" />

                            <rx:GridColumns ColumnId="CreatedOnUtcTime" Width="130" Header="İşlem Zamanı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="CreatedOnUtcTime" />

                            <rx:GridColumns ColumnId="SenderAccountType" Width="100" Header="Gönderen Müşteri Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SenderAccountType" />

                            <rx:GridColumns ColumnId="SenderAccountNumber" Width="150" Header="Gönderici Müş. Num." Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SenderAccountNumber" />

                            <rx:GridColumns ColumnId="SenderName" Width="150" Header="Gönderici" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SenderName" />

                            <rx:GridColumns ColumnId="SenderIban" Width="200" Header="Gönderici Iban" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SenderIban" />

                            <rx:GridColumns ColumnId="ReceiverAccountType" Width="100" Header="Alıcı Müşteri Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ReceiverAccountType" />

                            <rx:GridColumns ColumnId="ReceiverAccountNumber" Width="150" Header="Alıcı Müş. Num." Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ReceiverAccountNumber" />

                            <rx:GridColumns ColumnId="ReceiverName" Width="150" Header="Alıcı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ReceiverName" />

                            <rx:GridColumns ColumnId="ReceiverIban" Width="200" Header="Alıcı Iban" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ReceiverIban" />

                            <rx:GridColumns ColumnId="new_SendAmount" Width="100" Header="Gön. Tutar" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SendAmount" />

                            <rx:GridColumns ColumnId="new_SendAmountCurrencyName" Width="100" Header="Gön. Döviz" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SendAmountCurrencyName" />

                            <rx:GridColumns ColumnId="new_RecipientAmount" Width="100" Header="Alınan Tutar" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_RecipientAmount" />

                            <rx:GridColumns ColumnId="new_RecipientAmountCurrencyName" Width="100" Header="Alınan Döviz" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_RecipientAmountCurrencyName" />

                            <rx:GridColumns ColumnId="new_MarginParity" Width="100" Header="Marj. Parite" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_MarginParity" />

                            <rx:GridColumns ColumnId="new_OriginalParity" Width="100" Header="Uygulanan Parite" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_OriginalParity" />
                    </Columns>
                </ColumnModel>
                <SelectionModel>
                    <rx:RowSelectionModel ID="gpSenderDocumentRowSelectionModel" runat="server" ShowNumber="true"
                        SingleSelect="true">
                        <AjaxEvents>
                        </AjaxEvents>
                    </rx:RowSelectionModel>
                </SelectionModel>
                    <BottomBar>
                        <rx:PagingToolBar runat="server" ID="PagingToolBar1" Enabled="true" ControlId="GridPanelCorporatedPreInfoList">
                            <Buttons>
                                <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload">
                                    <AjaxEvents>
                                        <Click OnEvent="GpCorporatedPreInfoListReload">
                                            <EventMask ShowMask="false" />
                                            <ExtraParams>
                                                <rx:Parameter Name="Excel" Value="1" Mode="Value" />
                                            </ExtraParams>
                                        </Click>
                                    </AjaxEvents>
                                </rx:SmallButton>
                            </Buttons>
                        </rx:PagingToolBar>
                    </BottomBar>
                <LoadMask ShowMask="true" />


            </rx:GridPanel>



       

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
