<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ExternalAccountTransactionsUpdate.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.AccountTransactions.ExternalAccountTransactionsUpdate" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <rx:RegisterResources runat="server" ID="RR" />
    <form id="form1" runat="server">
        <div>
            <rx:PanelX runat="server" ID="pSearch" AutoHeight="Normal" Height="45" AutoWidth="true" Border="true" Frame="true" Title="Arama">
                <Body>
                    <rx:ColumnLayout runat="server" ID="cl1" ColumnWidth="40%">
                        <Rows>
                            <rx:RowLayout ID="rl1" runat="server">
                                <Body>
                                    <rx:TextField ID="tBankTranNumber" runat="server" FieldLabel="Banka İşlem Numarası"></rx:TextField>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout runat="server" ID="cl2" ColumnWidth="5%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="rl2">
                                <Body>
                                    <rx:Button ID="bSearch" runat="server" Text="Getir" Icon="Find">
                                        <AjaxEvents>
                                            <Click OnEvent="Search"></Click>
                                        </AjaxEvents>
                                    </rx:Button>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout runat="server" ID="cl4" ColumnWidth="5%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="rl4">
                                <Body>
                                    <rx:Button ID="bRefresh" runat="server" Text="Tekrar Aktarıma Aç" Icon="DatabaseSave">
                                        <AjaxEvents>
                                            <Click OnEvent="Refresh"></Click>
                                        </AjaxEvents>
                                    </rx:Button>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                </Body>
            </rx:PanelX>
            <rx:PanelX ID="pData" runat="server">
                <Body>
                    <rx:GridPanel runat="server" ID="gpItems" AutoWidth="true" Editable="false" Mode="Local" AutoLoad="false" AjaxPostable="true">
                        <TopBar>
                            <rx:ToolBar ID="toolBar1" runat="server" ContainerPadding="true">
                                <Items>
                                </Items>
                            </rx:ToolBar>
                        </TopBar>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="Id" ColumnId="0" DataIndex="ID" Width="80" Sortable="false" MenuDisabled="true" Hidden="true"></rx:GridColumns>
                                <rx:GridColumns Header="İşlem Referansı" ColumnId="1" DataIndex="REFERENCE" Width="100" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Banka İşlem No" ColumnId="2" DataIndex="BANK_TRANSACTION_NUMBER" Width="100" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Fiş No" ColumnId="3" DataIndex="RECEIPT_NUMBER" Width="100" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Hesap" ColumnId="4" DataIndex="ACCOUNT_NUMBER" Width="100" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Tutar" ColumnId="5" DataIndex="AMOUNT" Width="60" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Tutar Dövizi" ColumnId="6" DataIndex="AMOUNT_CURRENCY" Width="50" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Yön" ColumnId="7" DataIndex="TRANSACTION_DIRECTION" Width="30" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="İşlem Tarihi" ColumnId="8" DataIndex="TRANSACTION_DATE" Width="80" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Muhasebe Tarihi" ColumnId="9" DataIndex="ACCOUNTING_DATE" Width="80" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Açıklama" ColumnId="10" DataIndex="TRANSACTION_DESCRIPTION" Width="300" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Durum" ColumnId="11" DataIndex="TRANSACTION_STATUS_DESCRIPTION" Width="300" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                    </rx:GridPanel>
                </Body>
            </rx:PanelX>
        </div>
    </form>
</body>
</html>