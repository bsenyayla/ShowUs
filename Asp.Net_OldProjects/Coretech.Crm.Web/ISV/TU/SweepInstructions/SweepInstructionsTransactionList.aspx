<%@ Page Language="C#" AutoEventWireup="true" Inherits="SweepInstructionsTransactionList" Codebehind="SweepInstructionsTransactionList.aspx.cs" ValidateRequest="false" %>
 
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
            var config = "/ISV/TU/SweepInstructions/SweepInstructionsTransactionDetail.aspx?RecordId=" + hdnRecId.getValue();
            //var config = "/CrmPages/AutoPages/EditReflex.aspx?defaulteditpageid=106668F6-DAA1-4EA8-B3DB-0512D1E8EE9A&ObjectId=202000057&mode=1&recid=" + hdnRecId.getValue();
            var title = "Süpürme Hareketi";
            window.top.newWindow(config, { title: title, width: 1000, height: 700, resizable: false });
            
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
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="100" AutoWidth="true" Collapsed="false" Collapsible="False"
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
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="BusinessRequired" AutoLoad="true" LookupViewUniqueName="vSweepInstructionsMainLookup" >
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                   <cc1:CrmTextFieldComp runat="server" ID="ReferenceNo" ObjectId="202000035" UniqueName="Reference" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_CorporationId" ObjectId="202000056" UniqueName="new_CorporationId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="BusinessRequired" AutoLoad="true" >
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="30%">
                    <Rows>

                        <rx:RowLayout ID="RowLayout7" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderAccountId" ObjectId="202000056" UniqueName="new_SenderAccountId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" LookupViewUniqueName="AccountWithBalanceLookupView" RequirementLevel="None" AutoLoad="true" >
                                    <DataContainer>
                                        <DataSource OnEvent="newSenderUptAccountLoad">
                                        </DataSource>
                                    </DataContainer>
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientInstructionsCorpAccountId" ObjectId="202000057" UniqueName="new_RecipientInstructionsCorpAccountId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" LookupViewUniqueName="AccountWithBalanceLookupView" RequirementLevel="None" AutoLoad="true" >
                                    <DataContainer>
                                        <DataSource OnEvent="newRecipientCorpAccountLoad">
                                        </DataSource>
                                    </DataContainer>
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout22" runat="server">
                            <Body>
                                <rx:MultiField runat="server" ID="CreatedOnmf" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmDateFieldComp ID="cloudPaymentDateS" runat="server" ObjectId="202000035" UniqueName="new_CloudPaymentDate"
                                            FieldLabelShow="False" Width="82" PageSize="50">
                                        </cc1:CrmDateFieldComp>
                                        <cc1:CrmDateFieldComp ID="cloudPaymentDateE" runat="server" ObjectId="202000035" UniqueName="new_CloudPaymentDate"
                                            FieldLabelShow="False" Width="82" PageSize="50">
                                        </cc1:CrmDateFieldComp>
                                    </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

                 <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="30%">
                      <Rows>
                        <rx:RowLayout ID="RowLayout6" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp ID="new_TransactionStatus" runat="server" ObjectId="202000057" UniqueName="new_TransactionStatus"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout5" runat="server">
                            <Body>
                                    <rx:CheckField ID="new_ErrorStatus" runat="server" Width="30" FieldLabelWidth="250" FieldLabel="Hatalı kayıtlar ">                                   
                                    </rx:CheckField>
                            </Body>
                        </rx:RowLayout>

                       </Rows>
                 </rx:ColumnLayout>
            </Body>
            <Buttons>
<%--                <rx:Button runat="server" ID="btnNewRecord" Text="Yeni" Icon="Add"
                    Width="100">
                  <AjaxEvents>
                      <Click OnEvent="btnNewRecord_Click" ></Click>
                  </AjaxEvents>
                </rx:Button>--%>
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

                            <rx:GridColumns ColumnId="New_SweepInstructionsTransactionId" Width="100" Header="New_SweepInstructionsTransactionId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="New_SweepInstructionsTransactionId" />
                            
                            <rx:GridColumns ColumnId="new_SenderAccountId" Width="100" Header="new_SenderAccountId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_SenderAccountId" />

                            <rx:GridColumns ColumnId="new_RecipientAccountId" Width="100" Header="new_RecipientAccountId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_RecipientAccountId" />


                            <rx:GridColumns ColumnId="new_VirmanId" Width="100" Header="new_VirmanId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_VirmanId" />

                            <rx:GridColumns ColumnId="CorporationID" Width="100" Header="CorporationID" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="CorporationId" />

                            <rx:GridColumns ColumnId="HataIcon" Width="30" Header="#" Sortable="false"
                                MenuDisabled="true" Hidden="false" DataIndex="new_ErrorStatus">
                                <Renderer Handler="return ActionTemplateStatusIcon(record.data.new_ErrorStatus)" />
                            </rx:GridColumns>

                            <rx:GridColumns ColumnId="new_ErrorStatus" Width="100" Header="new_ErrorStatus" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_ErrorStatus" />

                            <rx:GridColumns ColumnId="new_TransactionStatus" Width="100" Header="new_TransactionStatus" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_TransactionStatus" />

                            <rx:GridColumns ColumnId="Reference" Width="100" Header="Referans No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="Reference" />

                            <rx:GridColumns ColumnId="TransactionStatusLabel" Width="100" Header="Durum" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TransactionStatusLabel" />
                            
                            <rx:GridColumns ColumnId="new_SweepInstructionsIdName" Width="200" Header="Talimat" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SweepInstructionsIdName" />

                            <rx:GridColumns ColumnId="new_SenderParentAccountIdName" Width="200" Header="Gönderen Ana Hesap" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SenderParentAccountIdName" />

                            <rx:GridColumns ColumnId="new_SenderAccountIdName" Width="200" Header="Gönderen Hesap" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SenderAccountIdName" />

                            <rx:GridColumns ColumnId="new_RecipientInstructionsCorpAccountIdName" Width="200" Header="Alıcı Hesap" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_RecipientInstructionsCorpAccountIdName" />

                            <rx:GridColumns ColumnId="new_RecipientInstructionsAccountNo" Width="150" Header="Alıcı Talimat Hesap No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_RecipientInstructionsAccountNo" />

                            <rx:GridColumns ColumnId="new_RecipientInstructionsAccountIBAN" Width="150" Header="Alıcı IBAN" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_RecipientInstructionsAccountIBAN" />

                            <rx:GridColumns ColumnId="CorporationName" Width="100" Header="Kurum" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="CorporationName" />

                            <rx:GridColumns ColumnId="new_Amount" Width="80" Header="Tutar" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_Amount" />

                            <rx:GridColumns ColumnId="new_AmountCurrencyName" Width="70" Header="Döviz" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_AmountCurrencyName" />

                            <rx:GridColumns ColumnId="new_BankReferenceGuid" Width="130" Header="Banka Referans Id" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_BankReferenceGuid" />

                            <rx:GridColumns ColumnId="new_BankTransactionRefNo" Width="100" Header="Banka Referans No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_BankTransactionRefNo" />

                            <rx:GridColumns ColumnId="new_VirmanIdName" Width="100" Header="Virman Referans No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_VirmanIdName" />
                            
                            <rx:GridColumns ColumnId="ErrorStatusLabel" Width="200" Header="Hata" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ErrorStatusLabel" />

                            <rx:GridColumns ColumnId="new_ErrorExplanation" Width="250" Header="Hata Açıklama" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_ErrorExplanation" />

                            <rx:GridColumns ColumnId="CreatedOnUtcTime" Width="110" Header="Oluşma Zamanı" Sortable="true"
                            MenuDisabled="true" Hidden="false" DataIndex="CreatedOnUtcTime" />

                            <rx:GridColumns ColumnId="new_WorkingTime" Width="110" Header="Çalışma Zamanı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_WorkingTime" />

                            <rx:GridColumns ColumnId="new_CompletionTime" Width="110" Header="Tamamlanma Zamanı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_CompletionTime" />

<%--                            <rx:GridColumns ColumnId="CreatedOn" Width="90" Header="Oluşturma Zamanı" Sortable="true"
                            MenuDisabled="true" Hidden="false" DataIndex="CreatedOnUtcTime"/>

                            <rx:GridColumns ColumnId="ModifiedTime" Width="150" Header="Düzenlenme Zamanı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ModifiedTime" />--%>
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
