<%@ Page Language="C#" AutoEventWireup="true" EnableViewState="true" ViewStateMode="Enabled" CodeBehind="InsertAccountTransactionRecord.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.AccountTransactions.InsertAccountTransactionRecord" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <rx:RegisterResources runat="server" ID="RR" />
    <form id="form1" runat="server">
        <div>
            <table style="width: 100%">
                <tr>
                    <td>
                        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="42" AutoWidth="true"
                            Border="true" Frame="true" Title="Ön Muhasebe Fişi Oluşturma Ekranı">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="15%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout1">
                                            <Body>
                                                <rx:Button ID="btnAddAccountTranRow" runat="server" Text="Hesap Hareketi Satırı Ekle" Icon="TableRowInsert">
                                                    <AjaxEvents>
                                                        <Click OnEvent="AddAccountTranRow"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="15%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout2">
                                            <Body>
                                                <rx:Button ID="btnDeleteAccountTranRow" runat="server" Text="Hesap Hareketi Satırını Sil" Icon="TableRowDelete">
                                                    <AjaxEvents>
                                                        <Click OnEvent="DeleteAccountTranRow"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="15%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout3">
                                            <Body>
                                                <rx:Button ID="btnShowRecordWindow" runat="server" Text="Ön Muhasebe Fişini Kaydet" Icon="ScriptSave">
                                                    <AjaxEvents>
                                                        <Click OnEvent="ShowRecordWindow"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="15%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout4">
                                            <Body>
                                                <rx:Button ID="btnExportToExcel" runat="server" Download="true" Icon="PageWhiteExcel" Text="Export">
                                                    <AjaxEvents>
                                                        <Click OnEvent="ExportToExcel"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                            </Body>
                        </rx:PanelX>
                    </td>
                </tr>
            </table>
            <rx:PanelX ID="Pnl1" runat="server">
                <Body>
                    <rx:GridPanel runat="server" ID="gridPanel" AutoWidth="true" AutoHeight="Normal" Editable="false" Mode="Local" AutoLoad="false" AjaxPostable="true">
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="ID" ColumnId="1" DataIndex="RowId" Width="100" Hidden="true"></rx:GridColumns>
                                <rx:GridColumns Header="TİP" ColumnId="2" DataIndex="TypeName" Width="200"></rx:GridColumns>
                                <rx:GridColumns Header="HESAP" ColumnId="3" DataIndex="AccountDesc" Width="250"></rx:GridColumns>
                                <rx:GridColumns Header="LOGO HESAP" ColumnId="4" DataIndex="LogoAccountDesc" Width="250"></rx:GridColumns>
                                <rx:GridColumns Header="TUTAR" ColumnId="5" DataIndex="Amount" Width="100"></rx:GridColumns>
                                <rx:GridColumns Header="DÖVİZ CİNSİ" ColumnId="6" DataIndex="Currency" Width="100"></rx:GridColumns>
                                <rx:GridColumns Header="YÖN" ColumnId="7" DataIndex="Direction" Width="100"></rx:GridColumns>
                                <rx:GridColumns Header="LOGO YÖN" ColumnId="8" DataIndex="LogoDirection" Width="100"></rx:GridColumns>
                                <rx:GridColumns Header="KUR" ColumnId="9" DataIndex="Rate" Width="100"></rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="rowSelectionModel1" runat="server" ShowNumber="true">
                                <AjaxEvents>
                                    <RowDblClick OnEvent="ShowRowWindowForUpdate">
                                    </RowDblClick>
                                </AjaxEvents>
                            </rx:RowSelectionModel>
                        </SelectionModel>
                     
                    </rx:GridPanel>
                </Body>
            </rx:PanelX>
        </div>
        <div>
            <rx:Window ID="windowRow" runat="server" Width="400" Height="300" Modal="true"
                CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
                CloseAction="Hide" ShowOnLoad="false">
                <Body>
                    <rx:Hidden ID="hdnRowId" runat="server" />
                    <table width="100%" style="padding: 10px">
                        <tr>
                            <td style="padding-left: 10px">Hesap</td>
                            <td style="padding-left: 10px">
                                <rx:TextField ID="tAccount" runat="server" RequirementLevel="BusinessRequired" Width="200">
                                </rx:TextField>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-left: 10px">Logo Hesap</td>
                            <td style="padding-left: 10px">
                                <rx:TextField ID="tLogoAccount" runat="server" RequirementLevel="BusinessRequired" Width="200">
                                </rx:TextField>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-left: 10px">Tutar (Örn: 123,45)</td>
                            <td style="padding-left: 10px">
                                <rx:TextField ID="tAmount" runat="server" RequirementLevel="BusinessRequired" Width="200">
                                </rx:TextField>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-left: 10px">Döviz Cinsi (TRY/USD/EUR)</td>
                            <td style="padding-left: 10px">
                                <rx:TextField ID="tCurrency" runat="server" RequirementLevel="BusinessRequired" Width="200">
                                </rx:TextField>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-left: 10px">Yön (A/B)</td>
                            <td style="padding-left: 10px">
                                <rx:TextField ID="tDirection" runat="server" RequirementLevel="BusinessRequired" Width="200">
                                </rx:TextField>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-left: 10px">Logo Yön (A/B)</td>
                            <td style="padding-left: 10px">
                                <rx:TextField ID="tLogoDirection" runat="server" RequirementLevel="BusinessRequired" Width="200">
                                </rx:TextField>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-left: 10px">TRY Kur (Örn: 3,1234)</td>
                            <td style="padding-left: 10px">
                                <rx:TextField ID="tRate" runat="server" RequirementLevel="BusinessRequired" Width="200">
                                </rx:TextField>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="height: 10px"></td>
                        </tr>
                        <tr>
                            <td colspan="2" style="padding-left: 10px">
                                <rx:Button ID="btnSaveAccountTranRow" runat="server" Text="Hesap Hareketi Satırını Kaydet" Icon="TableSave">
                                    <AjaxEvents>
                                        <Click OnEvent="SaveAccountTranRow"></Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </td>
                        </tr>
                    </table>
                </Body>
            </rx:Window>
            <rx:Window ID="windowRecord" runat="server" Width="400" Height="200" Modal="true"
                CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
                CloseAction="Hide" ShowOnLoad="false">
                <Body>
                    <rx:Hidden ID="Hidden1" runat="server" />
                    <table width="100%" style="padding: 10px">
                        <tr>
                            <td style="padding-left: 10px">Tarih (Örn: 2017-07-31)</td>
                            <td style="padding-left: 10px">
                                <rx:TextField ID="tDate" runat="server" RequirementLevel="BusinessRequired" Width="200">
                                </rx:TextField>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-left: 10px">Açıklama</td>
                            <td style="padding-left: 10px">
                                <rx:TextField ID="tExplanation" runat="server" RequirementLevel="BusinessRequired" Width="200">
                                </rx:TextField>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="height: 10px"></td>
                        </tr>
                        <tr>
                            <td colspan="2" style="padding-left: 10px;">
                                <rx:Button ID="btnSaveRecord" runat="server" Text="Ön Muhasebe Fişini Kaydet" Icon="ScriptSave">
                                    <AjaxEvents>
                                        <Click OnEvent="SaveRecord"></Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </td>
                        </tr>
                    </table>
                </Body>
            </rx:Window>
        </div>
    </form>
</body>
</html>
