<%@ Page Language="C#" AutoEventWireup="true" Inherits="SweepInstructionsHistoryList" Codebehind="SweepInstructionsHistoryList.aspx.cs" ValidateRequest="false" %>
 
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>

 
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>

    <script type="text/javascript">

        function ShowDetail() {
            //var config = "../ISV/TU/Transfer/TransferDocument.aspx?ObjectId=" + operationTypeId.getValue() + "&RecordId=" + transferId.getValue();
            
            /*
            if (hdnStatusId.getValue() < 2)
                return;
                */
            var config = "/ISV/TU/SweepInstructions/SweepInstructionsListDetail.aspx?RecordId=" + hdnRecId.getValue();
            var title = "Süpürme Talimatı Tanımı";
            window.top.newWindow(config, { title: title, width: 800, height: 550, resizable: false });
            
        }

        function ActionTemplateStatusIcon(Value) {
            //if (TransferId == "" || Action == 0 || TuStatusCode == 'TR002A')
            //    return RefNumber;
            
            if (Value > "1")
                return "<img src='" + GetWebAppRoot + "/images/1495118945_error.png' width=12 height=12 />";
            else
                return "<img src='" + GetWebAppRoot + "/images/success.png' width=12 height=12 />";
           

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
        
  
            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnTransactionType" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusId" runat="server"></rx:Hidden>
            <rx:GridPanel runat="server" ID="GridPanelCloudAccountTransactionList" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="true" Width="1200" AjaxPostable="true">
                <DataContainer>
                    <DataSource OnEvent="GpCorporatedPreInfoListReload">
                    </DataSource>
                    <Sorts>
                        <rx:DataSorts Name="CreatedOnUtcTime" Direction="Desc" />
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


                            <rx:GridColumns ColumnId="new_SenderAccountId" Width="100" Header="new_SenderAccountId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_SenderAccountId" />

                            <rx:GridColumns ColumnId="new_RecipientAccountId" Width="100" Header="new_RecipientAccountId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_RecipientAccountId" />

                            
                            <rx:GridColumns ColumnId="HistoryLabel" Width="120" Header="İşlem Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="HistoryLabel" />

                            <rx:GridColumns ColumnId="Name" Width="100" Header="Tanım" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="Name" />

                            <rx:GridColumns ColumnId="CorporationName" Width="150" Header="Kurum" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="CorporationName" />

                            <rx:GridColumns ColumnId="new_SenderParentAccountIdName" Width="150" Header="Gönderen Ana Hesap" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SenderParentAccountIdName" />

                            <rx:GridColumns ColumnId="new_SenderAccountIdName" Width="150" Header="Gönderen Hesap" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SenderAccountIdName" />

                            <rx:GridColumns ColumnId="new_RecipientCorparationAccountIdName" Width="150" Header="Alıcı Hesap" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_RecipientCorparationAccountIdName" />

                            <rx:GridColumns ColumnId="SweepBalanceLabel" Width="100" Header="Süpürülecek Bakiye" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SweepBalanceLabel" />

                            <rx:GridColumns ColumnId="new_SweepLevelAmount" Width="100" Header="Süpürme Tutar Seviye" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SweepLevelAmount" />

                            <rx:GridColumns ColumnId="new_SweepAmount" Width="100" Header="Süpürülecek Tutar" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SweepAmount" />

                            <rx:GridColumns ColumnId="SweepTypeLabel" Width="100" Header="Süpürme Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SweepTypeLabel" />

                            <rx:GridColumns ColumnId="TransferTimeLabel" Width="100" Header="Aktarım Zamanı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TransferTimeLabel" />

                            <rx:GridColumns ColumnId="new_ScheduledTime" Width="100" Header="Belirlenen Çalışma Zamanı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_ScheduledTime" />

                            <rx:GridColumns ColumnId="new_LastTime" Width="100" Header="Son Çalışma Zamanı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_LastTime" />

                            <rx:GridColumns ColumnId="new_NextTime" Width="100" Header="Gelecek Çalışma Zamanı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_NextTime" />

                            <rx:GridColumns ColumnId="ConfirmStatusLabel" Width="100" Header="Onay Durumu" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ConfirmStatusLabel" />

                            <rx:GridColumns ColumnId="Amount" Width="100" Header="Tutar" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="Amount" />

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
                            <RowDblClick Handler="hdnRecId.setValue(GridPanelCloudAccountTransactionList.selectedRecord.Id);hdnStatusId.setValue(GridPanelCloudAccountTransactionList.selectedRecord.new_ErrorStatus);"></RowDblClick>
                        </Listeners>
                        <AjaxEvents>
                        </AjaxEvents>
                    </rx:RowSelectionModel>
                </SelectionModel>
                    <BottomBar>
                        <rx:PagingToolBar runat="server" ID="PagingToolBar1" Enabled="true" ControlId="GridPanelCloudAccountTransactionList">
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


    function SetUser() {
        //   debugger;

        if (UptSenderSelector.SelectedSender.length > 0)
            new_SenderId.setValue(UptSenderSelector.SelectedSender[0].Value, UptSenderSelector.SelectedSender[0].Key);
    }

</script>
