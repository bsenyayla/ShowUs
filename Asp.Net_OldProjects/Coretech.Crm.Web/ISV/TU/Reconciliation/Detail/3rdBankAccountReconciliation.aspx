<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reconciliation.Detail.Reconciliation_3rdBankAccountReconciliation" ValidateRequest="false" CodeBehind="3rdBankAccountReconciliation.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="JS/_Corporation.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:KeyMap runat="server" ID="KeyMap1">
            <rx:KeyBinding>
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="GetReConciliation.click(e);" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
       
        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="150" AutoWidth="true"
            Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="40%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmDateFieldComp ID="new_StartDate" runat="server" ObjectId="201300006"
                                    UniqueName="new_StartDate" FieldLabelWidth="110" Width="100" RequirementLevel="BusinessRequired">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout32">
                            <Body>
                                <cc1:CrmDateFieldComp ID="new_EndDate" runat="server" ObjectId="201300006"
                                    UniqueName="new_EndDate" FieldLabelWidth="110" Width="100" RequirementLevel="BusinessRequired">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout19">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_FileTransactionNumber" ObjectId="201100072"
                                    UniqueName="new_FileTransactionNumber" FieldLabelWidth="70" Width="230" PageSize="50">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="TransferTuRef" ObjectId="201100072"
                                    UniqueName="TransferTuRef" FieldLabelWidth="70" Width="230" PageSize="50">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

                <rx:ColumnLayout runat="server" ID="ColoumnLayout2" ColumnWidth="40%">
                    <Rows>

                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_EftBank" ObjectId="201100072" UniqueName="new_EftBank"
                                    Width="150" PageSize="50" FieldLabel="200" LookupViewUniqueName="EFT_BANKS_LOOKUP">
                                    <DataContainer>
                                        <DataSource OnEvent="new_EftBankLoad" />
                                    </DataContainer>     
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <rx:ComboField ID="cmbCurrency" runat="server" FieldLabel="Döviz">
                                    <Items>
                                        <rx:ListItem Text="USD" Value="USD" />
                                        <rx:ListItem Text="EUR" Value="EUR" />
                                      
                                    </Items>
                                </rx:ComboField>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_ReconcliationStatus" ObjectId="202000037" UniqueName="new_ReconcliationStatus"
                                    Width="200" pagesize="50" FieldLabel="150" FieldLabelWidth="150">
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout3" ColumnWidth="20%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="Row1">
                            <Body>
                                <rx:Button runat="server" ID="btnGetReConciliation" Text="Mutabakat Verilerini Getir" Icon="MagnifierZoomIn"
                                    Width="200">
                                    <AjaxEvents>
                                        <Click OnEvent="SaveReConciliation">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout8">
                            <Body>
                                <rx:Button runat="server" ID="Button1" Text="Sorunlu işlemleri Lİstele" Icon="Report"
                                    Width="200">
                                  <AjaxEvents>
                                        <Click OnEvent="ToolbarButtonFindProblemTransactionClick">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                         <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <rx:Button runat="server" ID="btnGetReConciliationList" Text="Mutabakat Varilerini Listele" Icon="Report"
                                    Width="200">
                                  <AjaxEvents>
                                        <Click OnEvent="ToolbarButtonFindClick">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>

        

        <rx:PanelX runat="server" ID="pnl3" AutoHeight="Normal" Height="200" AutoWidth="true"
            Border="false">
            <Body>
                <rx:GridPanel runat="server" ID="GrdTotal" Title="Toplamlar" Height="100" AutoLoad="false"
                    AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Remote" AjaxPostable="true">
                    <DataContainer>
                        <DataSource OnEvent="ToolbarButtonTransactionTotalClick">
                        </DataSource>
                        <Parameters>
                            <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                            <rx:Parameter Name="limit" Value="20" Mode="Value"></rx:Parameter>
                        </Parameters>
                    </DataContainer>
                    <ColumnModel>
                            <Columns>
                                <rx:GridColumns ColumnId="new_EftBankIdName" Width="200" Header="Banka Adı" Sortable="false"
                                    MenuDisabled="true" DataIndex="new_EftBankIdName">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="BankUsdAmount" Width="100" Header="USD Toplam" Sortable="false"
                                    MenuDisabled="true" DataIndex="BankUsdAmount">
                                </rx:GridColumns>
                                  <rx:GridColumns ColumnId="UptUSDAmount" Width="100" Header="UPT USD Toplam" Sortable="false"
                                    MenuDisabled="true" DataIndex="UptUSDAmount">
                                </rx:GridColumns>
                                  <rx:GridColumns ColumnId="DiffUSDAmount" Width="100" Header="Fark" Sortable="false"
                                    MenuDisabled="true" DataIndex="DiffUSDAmount">
                                </rx:GridColumns>                         
                                <rx:GridColumns ColumnId="BankEurAmount" Width="100" Header="EUR Toplam" Sortable="false"
                                    MenuDisabled="true" DataIndex="BankEURAmount">
                                </rx:GridColumns>
                                  <rx:GridColumns ColumnId="UptEurAmount" Width="100" Header="UPT EUR Toplam" Sortable="false"
                                    MenuDisabled="true" DataIndex="UptEURAmount">
                                </rx:GridColumns>
                                  <rx:GridColumns ColumnId="DiffEurAmount" Width="100" Header="Fark" Sortable="false"
                                    MenuDisabled="true" DataIndex="DiffEURAmount">
                                </rx:GridColumns>

                            </Columns>
                        </ColumnModel>
                    <SelectionModel>
                        <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true"
                            SingleSelect="true">
                        </rx:RowSelectionModel>
                    </SelectionModel>
                    <BottomBar>
                        <rx:PagingToolBar runat="server" ID="PagingToolBar3" Enabled="true" ControlId="GrdTotal">
                            <Buttons>
                                <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload3">
                                    <AjaxEvents>
                                        <Click OnEvent="ToolbarButtonTransactionTotalClick">
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

            </Body>



        </rx:PanelX>

        <rx:PanelX runat="server" ID="pnl2" AutoHeight="Normal" Height="400" AutoWidth="true"
            Border="false">
            <Body>
                <rx:GridPanel runat="server" ID="GrdProblemReconciliation" Title="Sorunlu İşlemler Listesi" Height="300" AutoLoad="false"
                    AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Remote" AjaxPostable="true">
                    <DataContainer>
                        <DataSource OnEvent="ToolbarButtonFindProblemTransactionClick">
                        </DataSource>
                        <Parameters>
                            <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                            <rx:Parameter Name="limit" Value="20" Mode="Value"></rx:Parameter>
                        </Parameters>
                    </DataContainer>
                    <ColumnModel>
                    <Columns>
                        <rx:GridColumns ColumnId="Id" Width="100" Header="Id" Sortable="false"
                        MenuDisabled="true" Hidden="true" DataIndex="ID" />
                          <rx:GridColumns ColumnId="new_EftBankIdName" Width="150" Header="Banka" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_EftBankIdName" /> 
                         <rx:GridColumns ColumnId="VALUE" Width="100" Header="Partner Ref" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="VALUE" />              
                           <rx:GridColumns ColumnId="new_PartnerStatus" Width="100" Header="Partner Status" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_PartnerStatus" /> 
                             <rx:GridColumns ColumnId="new_TransferTuRef" Width="100" Header="Transfer Referans" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TransferTuRef" /> 
                           <rx:GridColumns ColumnId="new_Amount" Width="100" Header="Tutar" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_Amount" /> 
                              <rx:GridColumns ColumnId="new_CurrencyIdName" Width="100" Header="Döviz Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_CurrencyIdName" /> 
                        <rx:GridColumns ColumnId="new_TransferAmount" Width="100" Header="Partner Tutar" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TransferAmount" /> 
                              <rx:GridColumns ColumnId="new_TransferCurrencyIdName" Width="100" Header="Pertner Döviz Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TransferCurrencyIdName" />
                           <rx:GridColumns ColumnId="new_ReconcliationStatusName" Width="150" Header="Durum" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_ReconcliationStatusName" />
                    </Columns>
                </ColumnModel>
                    <SelectionModel>
                        <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true"
                            SingleSelect="true">
                        </rx:RowSelectionModel>
                    </SelectionModel>
                    <BottomBar>
                        <rx:PagingToolBar runat="server" ID="PagingToolBar2" Enabled="true" ControlId="GrdProblemReconciliation">
                            <Buttons>
                                <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload2">
                                    <AjaxEvents>
                                        <Click OnEvent="ToolbarButtonFindProblemTransactionClick">
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

            </Body>



        </rx:PanelX>

        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="400" AutoWidth="true"
            Border="false">
            <Body>
                <rx:GridPanel runat="server" ID="GrdReConciliation" Title="Mutabakat Listesi" Height="300" AutoLoad="false"
                    AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Remote" AjaxPostable="true">
                    <DataContainer>
                        <DataSource OnEvent="ToolbarButtonFindClick">
                        </DataSource>
                        <Parameters>
                            <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                            <rx:Parameter Name="limit" Value="20" Mode="Value"></rx:Parameter>
                        </Parameters>
                    </DataContainer>
                    <ColumnModel>
                    <Columns>
                        <rx:GridColumns ColumnId="Id" Width="100" Header="Id" Sortable="false"
                        MenuDisabled="true" Hidden="true" DataIndex="ID" />
                          <rx:GridColumns ColumnId="new_EftBankIdName" Width="150" Header="Banka" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_EftBankIdName" /> 
                         <rx:GridColumns ColumnId="VALUE" Width="100" Header="Partner Ref" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="VALUE" />              
                           <rx:GridColumns ColumnId="new_PartnerStatus" Width="100" Header="Partner Status" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_PartnerStatus" /> 
                             <rx:GridColumns ColumnId="new_TransferTuRef" Width="100" Header="Transfer Referans" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TransferTuRef" /> 
                           <rx:GridColumns ColumnId="new_Amount" Width="100" Header="Tutar" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_Amount" /> 
                              <rx:GridColumns ColumnId="new_CurrencyIdName" Width="100" Header="Döviz Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_CurrencyIdName" /> 
                        <rx:GridColumns ColumnId="new_TransferAmount" Width="100" Header="Partner Tutar" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TransferAmount" /> 
                              <rx:GridColumns ColumnId="new_TransferCurrencyIdName" Width="100" Header="Pertner Döviz Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TransferCurrencyIdName" />
                           <rx:GridColumns ColumnId="new_ReconcliationStatusName" Width="120" Header="Durum" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_ReconcliationStatusName" />
                    </Columns>
                </ColumnModel>
                    <SelectionModel>
                        <rx:RowSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server" ShowNumber="true"
                            SingleSelect="true">
                        </rx:RowSelectionModel>
                    </SelectionModel>
                    <BottomBar>
                        <rx:PagingToolBar runat="server" ID="PagingToolBar1" Enabled="true" ControlId="GrdReConciliation">
                            <Buttons>
                                <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload">
                                    <AjaxEvents>
                                        <Click OnEvent="ToolbarButtonFindClick">
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

            </Body>



        </rx:PanelX>
    </form>
</body>
</html>
