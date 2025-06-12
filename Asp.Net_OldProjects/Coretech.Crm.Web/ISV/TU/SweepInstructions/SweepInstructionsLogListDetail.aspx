<%@ Page Language="C#" AutoEventWireup="true" Inherits="SweepInstructionsLogListDetail" Codebehind="SweepInstructionsLogListDetail.aspx.cs" ValidateRequest="false" %>
 
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
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="New_SweepInstructionsId" ObjectId="202000056" UniqueName="New_SweepInstructionsId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="BusinessRequired" AutoLoad="true" >
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="New_SweepInstructionsTransactionIdText" ObjectId="202000057"
                                    UniqueName="New_SweepInstructionsTransactionId" FieldLabelWidth="70" Width="230" PageSize="50">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout22" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_TransactionCode" ObjectId="202000060" UniqueName="new_TransactionCode" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" >
                                 </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="30%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <rx:MultiField runat="server" ID="CreatedOnmf" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmDateFieldComp ID="cloudPaymentDateS" runat="server" ObjectId="202000057" UniqueName="CreatedOn"
                                            FieldLabelShow="False" Width="150" PageSize="50" >
                                        </cc1:CrmDateFieldComp>
                                        <cc1:CrmDateFieldComp ID="cloudPaymentDateE" runat="server" ObjectId="202000057" UniqueName="CreatedOn"
                                            FieldLabelShow="False" Width="150" PageSize="50" >
                                        </cc1:CrmDateFieldComp>
                                    </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                    <%--<rx:CheckField ID="new_ErrorStatus" runat="server" Width="30" FieldLabelWidth="250" FieldLabel="Hatalı kayıtlar ">                                   
                                    </rx:CheckField>--%>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

                 <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="30%">
                      <Rows>
                        <rx:RowLayout ID="RowLayout6" runat="server">
                            <Body>
                                    <%--<rx:CheckField ID="new_IsNkolayRepresentative" runat="server" Width="30" FieldLabelWidth="250" FieldLabel="NKolay Temsilci ">                                   
                                    </rx:CheckField>--%>
                            </Body>
                        </rx:RowLayout>
                       </Rows>
                 </rx:ColumnLayout>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnRefresh" Text="" Icon="Magnifier"
                    Width="100">
                    <Listeners>
                        <Click Handler="GridPanelCloudAccountTransactionList.reload();"></Click>
                    </Listeners>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
  
            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnTransactionType" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusId" runat="server"></rx:Hidden>
            <rx:GridPanel runat="server" ID="GridPanelCloudAccountTransactionList" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
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

                            <rx:GridColumns ColumnId="new_SweepInstructionsId" Width="100" Header="new_SweepInstructionsId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_SweepInstructionsId" />

                            <rx:GridColumns ColumnId="new_SweepInstructionsTransactionId" Width="100" Header="new_SweepInstructionsTransactionId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_SweepInstructionsTransactionId" />

                            <rx:GridColumns ColumnId="new_SweepInstructionsIdName" Width="250" Header="Süpürme Talimatı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SweepInstructionsIdName" />

                            <rx:GridColumns ColumnId="new_SweepInstructionsTransactionIdName" Width="120" Header="İşlem No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SweepInstructionsTransactionIdName" />

                            <rx:GridColumns ColumnId="new_TransactionCode" Width="100" Header="Hareket Kodu" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TransactionCode" />

                            <rx:GridColumns ColumnId="TransactionCodeLabel" Width="200" Header="Hareket Kodu Açıklaması" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TransactionCodeLabel" />
                        
                            <rx:GridColumns ColumnId="new_TransactionExplanation" Width="250" Header="Hareket Açıklama" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TransactionExplanation" />

                            <rx:GridColumns ColumnId="VirmanNo" Width="120" Header="Virman" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="VirmanNo" />

                            <rx:GridColumns ColumnId="new_ReferenceGuid" Width="100" Header="Banka Ref Guid" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_ReferenceGuid" />

                            <rx:GridColumns ColumnId="new_BankTransactionRefNo" Width="100" Header="Banka İşlem No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_BankTransactionRefNo" />


                            <rx:GridColumns ColumnId="CreatedOn" Width="90" Header="Oluşturma Zamanı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="CreatedOnUtcTime"/>                           
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
