<%@ Page Language="C#" AutoEventWireup="true" Inherits="BankingChannel_BankingChannelTransaction" Codebehind="BankingChannelTransaction.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="MainGridSelectedRow" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="SelectedCommittedTypeCode" runat="server">
        </rx:Hidden>

        <rx:Hidden ID="RowId" runat="server">
        </rx:Hidden>


        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="800" AutoWidth="true"
            Border="false">

            <Body>
                <rx:PanelX ID="SearchPanel" runat="server" AutoHeight="Normal" Height="80" ContainerPadding="true" BackColor="White" Title="Fitre Paneli">
                    <Body>
                        <br />
                        <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="30%">
                            <Rows>
                                <rx:RowLayout ID="R1" runat="server">
                                    <Body>
                                        <rx:TextField ID="SwiftNo" runat="server" FieldLabel="Swift No" ContainerPadding="true">
                                        </rx:TextField>
                                                                                <cc1:CrmDateFieldComp runat="server" ID="new_StartDate" ObjectId="201100011"
                                            UniqueName="new_StartDate" Width="250" FieldLabelWidth="100"
                                            PageSize="500" FieldLabel="250" Mode="Remote">
                                        </cc1:CrmDateFieldComp>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="30%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout2" runat="server">
                                    <Body>
                                        <rx:TextField ID="TransferTuRef" runat="server" FieldLabel="UPT Referans" ContainerPadding="true">
                                        </rx:TextField>
                                                                                <cc1:CrmDateFieldComp runat="server" ID="new_EndDate" ObjectId="201100011"
                                            UniqueName="new_EndDate" Width="250"
                                            PageSize="500" FieldLabel="250" FieldLabelWidth="100" Mode="Remote">
                                        </cc1:CrmDateFieldComp>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>

                        <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="30%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout4" runat="server">
                                    <Body>

                                        <cc1:CrmPicklistComp runat="server" ID="new_IsCommitted" ObjectId="201600011"
                                            UniqueName="new_IsCommitted" Width="150"
                                            PageSize="500" FieldLabel="200" Mode="Remote">
                                        </cc1:CrmPicklistComp>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>


                        <rx:ColumnLayout runat="server" ID="CL2" ColumnWidth="10%">
                            <Rows>
                                <rx:RowLayout ID="RL1" runat="server">
                                    <Body>


                                        <rx:Button runat="server" ID="GetReConciliation" Text="BUL" Icon="MagnifierZoomIn"
                                            Width="150">
                                            <AjaxEvents>
                                                <Click OnEvent="GetBankingChannelTransaction">
                                                </Click>
                                            </AjaxEvents>
                                        </rx:Button>

                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <br />
                    </Body>
                </rx:PanelX>
                <rx:PanelX ID="pnlMainAccounts" runat="server" AutoHeight="Normal" Height="450" AutoWidth="true">
                    <Body>
                        <rx:GridPanel runat="server" ID="GrdBankingChannelTransaction" Title="Banka Kanalı Swift İşlemleri" Height="400"
                            AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                            <DataContainer>
                            </DataContainer>
                            <ColumnModel>
                                <Columns>
                                    <rx:GridColumns ColumnId="New_BankingChannelTransactionId" Width="0" Header="New_BankingChannelTransactionId"
                                        Sortable="false" MenuDisabled="true" Hidden="true" DataIndex="New_BankingChannelTransactionId" />
                                    <rx:GridColumns ColumnId="SWIFT_ID" Width="150" Header="Swift No" Sortable="false"
                                        MenuDisabled="true" DataIndex="SWIFT_ID">
                                        <Commands>
                                            <rx:ImageCommand Icon="Button">
                                                <AjaxEvents>
                                                    <Click OnEvent="Process">
                                                    </Click>
                                                </AjaxEvents>
                                            </rx:ImageCommand>

                                        </Commands>
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="CreatedOn" Width="150" Header="İşlem Tarihi" MenuDisabled="true"
                                        Sortable="false" DataIndex="CreatedOn" />
                                    <rx:GridColumns ColumnId="new_IsCommitted" Width="150" Header="Durum" Sortable="false" MenuDisabled="true" DataIndex="new_IsCommitted" />
                                    <rx:GridColumns ColumnId="new_TransferIdName" Width="100" Header="UPT Referans" Sortable="false" MenuDisabled="true" DataIndex="new_TransferIdName" />
                                    <rx:GridColumns ColumnId="Channel" Width="100" Header="Kanal" Sortable="false" MenuDisabled="true" DataIndex="Channel" />
                                    <rx:GridColumns ColumnId="CreatedByName" Width="100" Header="Kayıt Sahibi" Sortable="false" MenuDisabled="true" DataIndex="CreatedByName" />
                                    <rx:GridColumns ColumnId="new_GBANKA_REFERANS" Width="100" Header="G.Banka Referans" Sortable="false" MenuDisabled="true" DataIndex="new_GBANKA_REFERANS" />
                                    <rx:GridColumns ColumnId="new_TUTAR" Width="100" Header="Tutar" Sortable="false" MenuDisabled="true" DataIndex="new_TUTAR" />
                                    <rx:GridColumns ColumnId="new_DOVIZ_KODU" Width="100" Header="Döviz Cinsi" Sortable="false" MenuDisabled="true" DataIndex="new_DOVIZ_KODU" />
                                    <%--<rx:GridColumns ColumnId="new_GONDEREN_IBAN_NO" Width="150" Header="Gönderen Iban No" Sortable="false" MenuDisabled="true" DataIndex="new_GONDEREN_IBAN_NO" />--%>
                                    <%--<rx:GridColumns ColumnId="new_GONDEREN_BIC_KODU" Width="150" Header="Gönderen Bic Kodu" Sortable="false" MenuDisabled="true" DataIndex="new_GONDEREN_BIC_KODU" />--%>
                                    <rx:GridColumns ColumnId="new_GONDEREN_BILGI" Width="150" Header="Gönderen Bilgi" Sortable="false" MenuDisabled="true" DataIndex="new_GONDEREN_BILGI" />
                                    <rx:GridColumns ColumnId="new_GONDEREN_ADI" Width="150" Header="Gönderen Adı" Sortable="false" MenuDisabled="true" DataIndex="new_GONDEREN_ADI" />
                                    <rx:GridColumns ColumnId="new_ALICI_ADI" Width="150" Header="Alıcı Adı" Sortable="false" MenuDisabled="true" DataIndex="new_ALICI_ADI" />
                                    <rx:GridColumns ColumnId="new_ALICI_BILGI" Width="150" Header="Alıcı Bilgi" Sortable="false" MenuDisabled="true" DataIndex="new_ALICI_BILGI" />
                                    <rx:GridColumns ColumnId="new_TRANSACTIONRESULT" Width="250" Header="İşlem Açıklaması" Sortable="false" MenuDisabled="true" DataIndex="new_TRANSACTIONRESULT" Hidden="true" />
                                </Columns>
                            </ColumnModel>
                            <BottomBar>
                                <rx:PagingToolBar ID="ptb" runat="server" ControlId="GrdBankingChannelTransaction">
                                </rx:PagingToolBar>
                            </BottomBar>
                            <SelectionModel>
                                <rx:RowSelectionModel ID="GridPanelPaymentsRowSelectionModel1" runat="server" ShowNumber="true">
                                    <Listeners>
                                        <RowClick Handler="MainGridSelectedRow.clear();MainGridSelectedRow.setValue(GrdBankingChannelTransaction.selectedRecord.SWIFT_ID);
                                    SelectedCommittedTypeCode.clear();SelectedCommittedTypeCode.setValue(GrdBankingChannelTransaction.selectedRecord.new_CommittedValue);
                                    RowId.clear();RowId.setValue(GrdBankingChannelTransaction.selectedRecord.New_BankingChannelTransactionId);"></RowClick>

                                    </Listeners>
                                    <AjaxEvents>
                                        <RowDblClick OnEvent="GetBankingChannelTransactionHistory">
                                        </RowDblClick>
                                    </AjaxEvents>
                                </rx:RowSelectionModel>
                            </SelectionModel>
                            <SpecialSettings>
                                <rx:RowExpander Template="<br/><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>İşlem Açıklaması : </b></span><span style='color:red'><b>{new_TRANSACTIONRESULT}</b></span><br/><br/>"
                                    Collapsed="true" />

                            </SpecialSettings>
                        </rx:GridPanel>
                    </Body>
                </rx:PanelX>
                <rx:PanelX ID="PanelX1" runat="server" AutoHeight="Normal" Height="360" AutoWidth="true">
                    <Body>
                        <rx:GridPanel runat="server" ID="GrdBankingChannelTransactionHistory" Title="Banka Kanalı Swift İşlemleri Geçmişi" Height="400"
                            AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AutoLoad="true">
                            <DataContainer>
                                <DataSource OnEvent="GetBankingChannelTransactionHistory">
                                </DataSource>
                            </DataContainer>
                            <ColumnModel>
                                <Columns>
                                    <rx:GridColumns ColumnId="CreatedOn" Width="200" Header="İşlem Tarihi" Sortable="false" MenuDisabled="true" DataIndex="CreatedOn" />
                                    <rx:GridColumns ColumnId="CreatedByName" Width="200" Header="Kayıt Sahibi" Sortable="false" MenuDisabled="true" DataIndex="CreatedByName" />
                                    <rx:GridColumns ColumnId="Channel" Width="200" Header="Kanal" Sortable="false" MenuDisabled="true" DataIndex="Channel" />
                                    <rx:GridColumns ColumnId="new_TransactionResult" Width="250" Header="İşlem Açıklaması" Sortable="false" MenuDisabled="true" DataIndex="new_TransactionResult" Hidden="true" />
                                </Columns>
                            </ColumnModel>
                            <SelectionModel>
                                <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                                </rx:RowSelectionModel>
                            </SelectionModel>
                            <SpecialSettings>
                                <rx:RowExpander Template="<br/><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>İşlem Açıklaması : </b></span><span style='color:red'><b>{new_TransactionResult}</b></span><br/><br/>"
                                    Collapsed="true" />
                            </SpecialSettings>
                        </rx:GridPanel>
                    </Body>
                </rx:PanelX>
            </Body>
        </rx:PanelX>
    </form>
</body>

</html>
