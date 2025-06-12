<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reconciliation.Detail.Reconciliation_Detail_AccountExtract" Codebehind="AccountExtract.aspx.cs" %>

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
        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="140" AutoWidth="true"
            Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout1_1">
                            <Body>
                            Kurum:
                            <rx:ComboField runat="server" ID="cfCorporation" Mode="Remote" DisplayField="CorporationName"  ValueField="New_CorporationId" RequirementLevel="BusinessRequired">
                                <DataContainer>
                                    <DataSource OnEvent="CorporationLoad">
                                        <Columns>
                                            <rx:Column Name="new_CorporationCode" Width="100" />
                                            <rx:Column Name="CorporationName" Width="300" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </rx:ComboField>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout1_2">
                            <Body>
                                <rx:CheckField ID="chCheckAmount" runat="server" Value="true" FieldLabel="Tutar kontrolü yap." />
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout2_1">
                            <Body>
                                <rx:FileUpload ID="upExtract1" runat="server" Width="100" FieldLabel="Banka Hesap Hareketleri Dosyası - 1">
                                </rx:FileUpload>
                            </Body>  
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2_2">
                            <Body>
                                <rx:FileUpload ID="upExtract2" runat="server" Width="100" FieldLabel="Banka Hesap Hareketleri Dosyası - 2">
                                </rx:FileUpload>
                            </Body>  
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2_3">
                            <Body>
                                <rx:FileUpload ID="upExtract3" runat="server" Width="100" FieldLabel="Banka Hesap Hareketleri Dosyası - 3">
                                </rx:FileUpload>
                            </Body>  
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2_4">
                            <Body>
                                <rx:FileUpload ID="upExtract4" runat="server" Width="100" FieldLabel="Banka Hesap Hareketleri Dosyası - 4">
                                </rx:FileUpload>
                            </Body>  
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2_5">
                            <Body>
                                <rx:FileUpload ID="upExtract5" runat="server" Width="100" FieldLabel="Banka Hesap Hareketleri Dosyası - 5">
                                </rx:FileUpload>
                            </Body>  
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2_6">
                            <Body>
                                <rx:FileUpload ID="upExtract6" runat="server" Width="100" FieldLabel="Banka Hesap Hareketleri Dosyası - 6">
                                </rx:FileUpload>
                            </Body>  
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="600" AutoWidth="true"
            Border="false">
            <Body>
                <rx:GridPanel runat="server" ID="GrdReConciliation" Title="ReConciliation List" Height="600"
                    AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                    <ColumnModel>
                        <Columns>
                            <rx:GridColumns ColumnId="Source" Width="180" Header="Mutabakatsızlık Kaynağı" MenuDisabled="true"
                                Sortable="false" DataIndex="Source" />
                            <rx:GridColumns ColumnId="TransactionReference" Width="120" Header="Referans" MenuDisabled="true"
                                Sortable="false" DataIndex="TransactionReference" />
                            <rx:GridColumns ColumnId="OperationType" Width="120" Header="İşlem Tipi" MenuDisabled="true"
                                Sortable="false" DataIndex="OperationType" />
                            <rx:GridColumns ColumnId="BankTransactionNumber" Width="120" Header="Banka İşlem No" MenuDisabled="true"
                                Sortable="false" DataIndex="BankTransactionNumber" />
                            <rx:GridColumns ColumnId="Date" Width="120" Header="Tarih" MenuDisabled="true"
                                Sortable="false" DataIndex="Date" />
                            <rx:GridColumns ColumnId="Amount" Width="120" Header="Tutar" MenuDisabled="true"
                                Sortable="false" DataIndex="Amount" />
                            <rx:GridColumns ColumnId="Status" Width="400" Header="Mutabakat Açıklaması"
                                Sortable="false" MenuDisabled="true" DataIndex="Status" />
                            <rx:GridColumns ColumnId="StatusDetail" Width="700" Header="Detay"
                                Sortable="false" MenuDisabled="true" DataIndex="StatusDetail" />
                        </Columns>
                    </ColumnModel>
                    <SelectionModel>
                        <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                        </rx:RowSelectionModel>
                    </SelectionModel>
                </rx:GridPanel>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnGetReConciliation" Text="Mutabakat Verilerini Getir (F9)" Icon="MagnifierZoomIn"
                    Width="200">
                    <AjaxEvents>
                        <Click OnEvent="GetReConciliationClick" Before="CrmValidateForm(msg,e);">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                <rx:Button runat="server" ID="btnExportToExcel" Text="Sonuçları Excel'e Aktar"
                    Width="200">
                    <AjaxEvents>
                        <Click OnEvent="ExportToExcel" Before="CrmValidateForm(msg,e);">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                <rx:Button runat="server" ID="btnReset" Text="Yenile"
                    Width="200">
                    <AjaxEvents>
                        <Click OnEvent="Reset" Before="CrmValidateForm(msg,e);">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
    </form>
</body>
</html>
