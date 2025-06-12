<%@ Page Language="C#" AutoEventWireup="true" Inherits="FreeAccounting_ManuelAbAccounting" Codebehind="ManuelAbAccounting.aspx.cs" %>


<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="JS/TransferFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="TransferId" runat="server" />
        <rx:Hidden ID="PaymentId" runat="server" />
        <rx:Hidden ID="RefundpaymentId" runat="server" />
        <rx:Hidden ID="TransferReference" runat="server" />
        <rx:Hidden ID="TransactionType" runat="server" />
        <rx:PanelX runat="server" ID="pnl1" Height="500" AutoWidth="true"
            Border="false" Title="BANK ACCOUNTING">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" AutoWidth="true" ColumnLayoutLabelWidth="40">
                    <Rows>
                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="20%" ColumnLayoutLabelWidth="10">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout1" runat="server">
                                            <Body>
                                                <cc1:CrmTextFieldComp runat="server" ID="TransferTuRef" ObjectId="201100072"
                                                    UniqueName="TransferTuRef" FieldLabelWidth="70" Width="150" PageSize="50">
                                                </cc1:CrmTextFieldComp>

                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="10%" ColumnLayoutLabelWidth="10">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout5" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Kontrol Et" ID="btnControl" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnControlClick"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout232" ColumnWidth="20%" ColumnLayoutLabelWidth="5">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout8">
                                            <Body>
                                                <rx:ComboField runat="server" ID="OperationType" FieldLabel="İşlem Tipi" EmptyText="Seçiniz...">
                                                    <Items>

                                                        <rx:ListItem Text="Gonderim" Value="1" />
                                                        <rx:ListItem Text="Ödeme" Value="2" />
                                                        <rx:ListItem Text="İade Ödeme" Value="3" />
                                                        <rx:ListItem Text="Gonderim İptal" Value="4" />
                                                        <rx:ListItem Text="Ödeme İptal" Value="5" />
                                                        <rx:ListItem Text="İade Ödeme İptal" Value="6" />
                                                    </Items>
                                                </rx:ComboField>

                                            </Body>
                                        </rx:RowLayout>

                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="10%" ColumnLayoutLabelWidth="10">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout9" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Fiş Kes" ID="Button1" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnAccountClick" Before="return confirm('Bu işlemiçin fiş oluşturmak istediğinizden emin misiniz?');"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout4232">
                            <Body> &nbsp;</Body>
                        </rx:RowLayout>

                        <rx:RowLayout ID="RowLayout7" runat="server">
                            <Body>

                                <rx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="60%" ColumnLayoutLabelWidth="200">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout3" runat="server">
                                            <Body>
                                                <rx:GridPanel runat="server" ID="GrdTransfer" Title="Gönderim" Height="100"
                                                    AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                                                    <SelectionModel>
                                                        <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                                                        </rx:RowSelectionModel>
                                                    </SelectionModel>
                                                    <ColumnModel>
                                                        <Columns>
                                                            <rx:GridColumns ColumnId="TuRef" Width="120" Header="Tu Referans no" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="TuRef" />
                                                            <rx:GridColumns ColumnId="FileTransactionNumber" Width="120" Header="Dosya Ref No" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="FileTransactionNumber" />
                                                            <rx:GridColumns ColumnId="ConfirmStatusName" Width="200" Header="Onay Durumu" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="ConfirmStatusName" />
                                                            <rx:GridColumns ColumnId="BankTransactionNumber" Width="150" Header="Banka İşlem No" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="BankTransactionNumber" />
                                                            <rx:GridColumns ColumnId="CorporationName" Width="200" Header="Kurum" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="CorporationName" />
                                                            <rx:GridColumns ColumnId="CreatedOn" Width="120" Header="İşlem Tarihi" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="CreatedOn" />

                                                        </Columns>
                                                    </ColumnModel>
                                                </rx:GridPanel>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout33">
                                            <Body> &nbsp;</Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout2" runat="server">
                                            <Body>
                                                <rx:GridPanel runat="server" ID="GrdPayment" Title="Ödeme" Height="100"
                                                    AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                                                    <SelectionModel>
                                                        <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                                                        </rx:RowSelectionModel>
                                                    </SelectionModel>
                                                    <ColumnModel>
                                                        <Columns>
                                                            <rx:GridColumns ColumnId="TuRef" Width="0" Header="Tu Referans no" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="TuRef" />
                                                            <rx:GridColumns ColumnId="FileTransactionNumber" Width="0" Header="Dosya Ref No" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="FileTransactionNumber" />
                                                            <rx:GridColumns ColumnId="ConfirmStatusName" Width="0" Header="Onay Durumu" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="ConfirmStatusName" />
                                                            <rx:GridColumns ColumnId="BankTransactionNumber" Width="0" Header="Banka İşlem No" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="BankTransactionNumber" />
                                                            <rx:GridColumns ColumnId="CorporationName" Width="0" Header="Kurum" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="CorporationName" />
                                                            <rx:GridColumns ColumnId="CreatedOn" Width="0" Header="İşlem Tarihi" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="CreatedOn" />

                                                        </Columns>
                                                    </ColumnModel>
                                                </rx:GridPanel>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout34">
                                            <Body> &nbsp;</Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout6" runat="server">
                                            <Body>
                                                <rx:GridPanel runat="server" ID="GrpRefundPayment" Title="İade Ödeme" Height="100"
                                                    AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                                                    <SelectionModel>
                                                        <rx:RowSelectionModel ID="RowSelectionModel3" runat="server" ShowNumber="true">
                                                        </rx:RowSelectionModel>
                                                    </SelectionModel>
                                                    <ColumnModel>
                                                        <Columns>
                                                            <rx:GridColumns ColumnId="TuRef" Width="0" Header="Tu Referans no" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="TuRef" />
                                                            <rx:GridColumns ColumnId="FileTransactionNumber" Width="0" Header="Dosya Ref No" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="FileTransactionNumber" />
                                                            <rx:GridColumns ColumnId="ConfirmStatusName" Width="0" Header="Onay Durumu" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="ConfirmStatusName" />
                                                            <rx:GridColumns ColumnId="BankTransactionNumber" Width="0" Header="Banka İşlem No" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="BankTransactionNumber" />
                                                            <rx:GridColumns ColumnId="CorporationName" Width="0" Header="Kurum" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="CorporationName" />
                                                            <rx:GridColumns ColumnId="CreatedOn" Width="0" Header="İşlem Tarihi" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="CreatedOn" />

                                                        </Columns>
                                                    </ColumnModel>
                                                </rx:GridPanel>
                                            </Body>
                                        </rx:RowLayout>

                                    </Rows>
                                </rx:ColumnLayout>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

            </Body>
        </rx:PanelX>
    </form>
    <p>
    </p>
</body>
</html>

