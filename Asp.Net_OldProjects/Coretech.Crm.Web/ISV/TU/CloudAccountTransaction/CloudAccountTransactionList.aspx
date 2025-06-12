<%@ Page Language="C#" AutoEventWireup="true" Inherits="CloudAccountTransactionList" Codebehind="CloudAccountTransactionList.aspx.cs" ValidateRequest="false" %>
 
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
            var config = "/ISV/TU/CloudAccountTransaction/CloudAccountTransactionDetail.aspx?RecordId=" + hdnRecId.getValue();
            var title = "Bulut Tahsilat Hareketi";
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
                                   <cc1:CrmComboComp runat="server" ID="new_OfficeId" ObjectId="202000035" UniqueName="new_OfficeId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" LookupViewUniqueName="CloudAccountTransactionOfficeLookup2" >
                                    <DataContainer>
                                        <DataSource OnEvent="newOfficeLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout5" runat="server">
                            <Body>
                                   <cc1:CrmTextFieldComp runat="server" ID="new_SenderFullName" ObjectId="202000035" UniqueName="new_SenderFullName" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" >
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                   <cc1:CrmTextFieldComp runat="server" ID="new_SenderIban" ObjectId="202000035" UniqueName="new_SenderIban" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" >
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="30%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                   <cc1:CrmTextFieldComp runat="server" ID="ReferenceNo" ObjectId="202000035" UniqueName="Reference" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout11" runat="server">
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
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                    <rx:CheckField ID="new_ErrorStatus" runat="server" Width="30" FieldLabelWidth="250" FieldLabel="Hatalı kayıtlar ">                                   
                                    </rx:CheckField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

                 <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="30%">
                      <Rows>
                        <rx:RowLayout ID="RowLayout6" runat="server">
                            <Body>
                                    <rx:CheckField ID="new_IsNkolayRepresentative" runat="server" Width="30" FieldLabelWidth="250" FieldLabel="NKolay Temsilci ">                                   
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
                        <rx:DataSorts Name="CloudPaymentDateUtcTime" Direction="Desc" />
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
                        
                            <rx:GridColumns ColumnId="new_CloudPaymentId" Width="100" Header="new_CloudPaymentId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_CloudPaymentId" />

                            <rx:GridColumns ColumnId="OfficeId" Width="100" Header="OfficeId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="OfficeId" />

                            <rx:GridColumns ColumnId="CorporationID" Width="100" Header="CorporationID" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_CorporationID" />

                            <rx:GridColumns ColumnId="HataIcon" Width="30" Header="#" Sortable="false"
                                MenuDisabled="true" Hidden="false" DataIndex="new_ErrorStatus">
                                <Renderer Handler="return ActionTemplateStatusIcon(record.data.new_ErrorStatus)" />
                            </rx:GridColumns>

                            <rx:GridColumns ColumnId="new_ErrorStatus" Width="100" Header="new_ErrorStatus" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_ErrorStatus" />

                            <rx:GridColumns ColumnId="ErrorStatusLabel" Width="170" Header="Hata" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ErrorStatusLabel" />

                            <rx:GridColumns ColumnId="new_ErrorExplanation" Width="200" Header="Hata Açıklama" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_ErrorExplanation" />

                            <rx:GridColumns ColumnId="StatusLabel" Width="100" Header="Durum" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="StatusLabel" />

                            <rx:GridColumns ColumnId="new_CorporationIDName" Width="100" Header="Kurum" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_CorporationIDName" />

                            <rx:GridColumns ColumnId="new_OfficeIdName" Width="200" Header="Ofis" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_OfficeIdName" />

                            <rx:GridColumns ColumnId="ReferenceNo" Width="200" Header="Referans No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ReferenceNo" />

                            <rx:GridColumns ColumnId="CloudPaymentDateUtcTime" Width="100" Header="Bulut Ödeme Tarihi" Sortable="true"
                            MenuDisabled="true" Hidden="false" DataIndex="CloudPaymentDateUtcTime" />

                            <rx:GridColumns ColumnId="Amount" Width="100" Header="Tutar" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="Amount" />

                            <rx:GridColumns ColumnId="new_CurrencyCode" Width="70" Header="Döviz" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_CurrencyCode" />

                            <rx:GridColumns ColumnId="new_PaymentExpCode" Width="100" Header="Cari Kodu" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_PaymentExpCode" />

                            <rx:GridColumns ColumnId="new_Explanation" Width="250" Header="Açıklama" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_Explanation" />

                            <rx:GridColumns ColumnId="new_SenderFullName" Width="100" Header="Gönderici" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SenderFullName" />

                            <rx:GridColumns ColumnId="new_SenderIdentityNo" Width="100" Header="Gönderici Kimlik No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SenderIdentityNo" />

                            <rx:GridColumns ColumnId="new_SenderIban" Width="180" Header="Gönderici IBAN" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SenderIban" />

                            <rx:GridColumns ColumnId="new_RecipientIban" Width="180" Header="Alıcı IBAN" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_RecipientIban" />

                            <rx:GridColumns ColumnId="new_RecipentBankName" Width="180" Header="Alıcı Banka" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_RecipentBankName" />

                            <rx:GridColumns ColumnId="new_TaxNo" Width="100" Header="Vergi No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TaxNo" />

                            <rx:GridColumns ColumnId="new_ReferenceGuid" Width="100" Header="Banka Referans Id" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_ReferenceGuid" />

                            <rx:GridColumns ColumnId="new_BankTransactionRefNo" Width="100" Header="Banka Referans No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_BankTransactionRefNo" />

                            <rx:GridColumns ColumnId="VirmanReferenceNo" Width="100" Header="Virman Referans No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="VirmanReferenceNo" />

                            <rx:GridColumns ColumnId="new_IsNkolayRepresentative" Width="100" Header="NKolay Temsilci Mi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_IsNkolayRepresentative" />

                            <rx:GridColumns ColumnId="new_NKolayAccountTransferCompleted" Width="100" Header="NKolay Hesabına Geçti Mi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_NKolayAccountTransferCompleted" />

                            <rx:GridColumns ColumnId="new_IsNKolayLimitCreate" Width="100" Header="NKolay Limit Oluştu Mu" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_IsNKolayLimitCreate" />

                            <rx:GridColumns ColumnId="new_NKolayLimitRefNo" Width="100" Header="NKolay Limit Ref No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_NKolayLimitRefNo" />

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
