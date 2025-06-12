<%@ Page Language="C#" AutoEventWireup="true" Inherits="CloudVirmanTransactionList" Codebehind="CloudVirmanTransactionList.aspx.cs" ValidateRequest="false" %>
 
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

            
            var config = "/ISV/TU/AccountTransactions/Virman.aspx?defaulteditpageid=599431b5-0752-4ad0-bae0-d994d5131d4f&ObjectId=201400028&mode=1&rlistframename=Frame_PnlCenter&gridpanelid=GridPanelViewer&rnd=" + hdnRecId.getValue() + "&pframename=&recid=" + hdnRecId.getValue()
            var title = "Bulut Talimatlı İşlem Detayı";
            window.top.newWindow(config, { title: title, width: 1000, height: 600, resizable: false });
            
        }

        function ActionTemplateStatusIcon(Value) {
            //if (TransferId == "" || Action == 0 || TuStatusCode == 'TR002A')
            //    return RefNumber;
            
            if (Value >= "1")
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
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="ReferenceNo" ObjectId="202000035" UniqueName="Reference" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout5" runat="server">
                            <Body>
      
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout4" runat="server">
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
                        <rx:RowLayout ID="RowLayout11" runat="server">
                            <Body>


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
                        

<%--                            <rx:GridColumns ColumnId="HataIcon" Width="30" Header="#" Sortable="false"
                                MenuDisabled="true" Hidden="false" DataIndex="new_ErrorStatus">
                                <Renderer Handler="return ActionTemplateStatusIcon(record.data.new_ErrorStatus)" />
                            </rx:GridColumns>--%>
 

                            <rx:GridColumns ColumnId="ReferenceNo" Width="100" Header="Referans Numarası" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ReferenceNo" />

                           <rx:GridColumns ColumnId="new_BankTransactionNumber" Width="100" Header="Banka Referans No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_BankTransactionNumber" />

                            <rx:GridColumns ColumnId="new_VirementTypeName" Width="100" Header="İşlem Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_VirementTypeName" />

                        
                            <rx:GridColumns ColumnId="new_SenderAccountIdName" Width="100" Header="Gönderen Hesap" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SenderAccountIdName" />

                            <rx:GridColumns ColumnId="new_RecipientAccountIdName" Width="100" Header="Alıcı Hesap" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_RecipientAccountIdName" />

                            <rx:GridColumns ColumnId="new_RecipientSwiftAccountNo" Width="100" Header="Alıcı Hesap (Diğer)" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_RecipientSwiftAccountNo" />                        

                            <rx:GridColumns ColumnId="new_RecipientSwiftAccountNo" Width="100" Header="Alıcı Hesap (Diğer)" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_RecipientSwiftAccountNo" /> 

                            <rx:GridColumns ColumnId="new_Amount" Width="100" Header="Tutar" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_Amount" />

                            <rx:GridColumns ColumnId="new_SenderAccountCurrencyIdName" Width="100" Header="Gönderen Hesap Dövizi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SenderAccountCurrencyIdName" />
                        

                            <rx:GridColumns ColumnId="new_TransferedAmount" Width="100" Header="Tutar Karşılığı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TransferedAmount" />

                            <rx:GridColumns ColumnId="new_RecipientAccountCurrencyIdName" Width="100" Header="Alıcı Hesap Dövizi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_RecipientAccountCurrencyIdName" />

                            <rx:GridColumns ColumnId="new_TransactionRate" Width="100" Header="İşlem Kuru" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TransactionRate" />

                            <rx:GridColumns ColumnId="new_SpreadRate" Width="100" Header="Spread Oranı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SpreadRate" />

                            <rx:GridColumns ColumnId="new_SpreadParity" Width="100" Header="Marjlı Kur" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SpreadParity" />

                            <rx:GridColumns ColumnId="new_SpreadAmount" Width="100" Header="Marjlı Tutar" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SpreadAmount" />

                            <rx:GridColumns ColumnId="new_StatusDescription" Width="100" Header="İşlem Durum Açıklaması" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_StatusDescription" />

                            <rx:GridColumns ColumnId="CreatedOn" Width="90" Header="Oluşturma Zamanı" Sortable="true"
                            MenuDisabled="true" Hidden="false" DataIndex="CreatedOn"/>

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
