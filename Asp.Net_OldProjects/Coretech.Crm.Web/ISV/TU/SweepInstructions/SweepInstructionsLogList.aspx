<%@ Page Language="C#" AutoEventWireup="true" Inherits="SweepInstructionsLogList" Codebehind="SweepInstructionsLogList.aspx.cs" ValidateRequest="false" %>
 
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>

 
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>

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
        
  
            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnTransactionType" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusId" runat="server"></rx:Hidden>
            <rx:GridPanel runat="server" ID="GridPanelCloudAccountTransactionList" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="true" Width="1200" AjaxPostable="true">
                <DataContainer>
                    <DataSource OnEvent="GpCorporatedPreInfoListReload">
                    </DataSource>
                    <Sorts>
                        <rx:DataSorts Name="CreatedOnUtcTime" Direction="ASC" />
                    </Sorts>
                    <Parameters>
                        <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                        <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                    </Parameters>
                </DataContainer>  
                <ColumnModel>
                    <Columns>
                            <rx:GridColumns ColumnId="Id" Width="100" Header="Id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="Id" />


                            <rx:GridColumns ColumnId="new_SweepInstructionsId" Width="100" Header="new_SweepInstructionsId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_SweepInstructionsId" />

                            <rx:GridColumns ColumnId="new_SweepInstructionsTransactionId" Width="100" Header="new_SweepInstructionsTransactionId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_SweepInstructionsTransactionId" />

                        


                            <rx:GridColumns ColumnId="new_SweepInstructionsTransactionIdName" Width="150" Header="İşlem No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SweepInstructionsTransactionIdName" />

                            <rx:GridColumns ColumnId="new_TransactionCode" Width="75" Header="Hareket Kodu" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TransactionCode" />

                            <rx:GridColumns ColumnId="TransactionCodeLabel" Width="150" Header="Hareket Kodu" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TransactionCodeLabel" />
                        
                            <rx:GridColumns ColumnId="new_TransactionExplanation" Width="105" Header="Hareket Açıklama" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TransactionExplanation" />

                            <rx:GridColumns ColumnId="new_VirmanNo" Width="100" Header="Virman" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_VirmanNo" />

                            <rx:GridColumns ColumnId="new_ReferenceGuid" Width="100" Header="Banka Ref Guid" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_ReferenceGuid" />

                            <rx:GridColumns ColumnId="new_BankTransactionRefNo" Width="100" Header="Banka İşlem No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_BankTransactionRefNo" />


                            <rx:GridColumns ColumnId="CreatedOn" Width="90" Header="Oluşturma Zamanı" Sortable="true"
                            MenuDisabled="true" Hidden="false" DataIndex="CreatedOnUtcTime"/>

                            <rx:GridColumns ColumnId="ModifiedTime" Width="150" Header="Düzenlenme Zamanı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ModifiedTime" />
                    </Columns>
                </ColumnModel>
                <SelectionModel>
                    <rx:RowSelectionModel ID="gpSenderDocumentRowSelectionModel" runat="server" ShowNumber="true"
                        SingleSelect="true">
                        <Listeners>
                            <RowDblClick Handler="hdnRecId.setValue(GridPanelCloudAccountTransactionList.selectedRecord.Id);hdnStatusId.setValue(GridPanelCloudAccountTransactionList.selectedRecord.new_ErrorStatus);ShowDetail();"></RowDblClick>
                        </Listeners>
                        <AjaxEvents>
                        </AjaxEvents>
                    </rx:RowSelectionModel>
                </SelectionModel>
    
                <LoadMask ShowMask="true" />


            </rx:GridPanel>
      
    </form>
</body>
</html>
<script type="text/javascript">


    function SetUser() {
        //   debugger;

        if (UptSenderSelector.SelectedSender.length > 0)
            new_SenderId.setValue(UptSenderSelector.SelectedSender[0].Value, UptSenderSelector.SelectedSender[0].Key);
    }

</script>
