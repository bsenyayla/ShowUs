<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Reconciliation.Detail.Reconciliation_Ab" Async="true" Codebehind="_Ab.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
    <rx:Hidden ID="HdnReConciliationId" runat="server">
    </rx:Hidden>
    <rx:Hidden ID="HdnReportId" runat="server">
    </rx:Hidden>
    <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="500" AutoWidth="true"
        Border="false">
        <Body>
            <rx:GridPanel runat="server" ID="GrdReConciliation" Title="ReConciliation List" Height="400"
                AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                <DataContainer>
                </DataContainer>
                <ColumnModel>
                    <Columns>
                        <rx:GridColumns ColumnId="RECONCILIATIONOPERATIONHISTORYID" Width="0" Header="RECONCILIATIONOPERATIONHISTORYID"
                            Sortable="false" MenuDisabled="true" Hidden="true" DataIndex="TRANSFERID" />
                        <rx:GridColumns ColumnId="TRANSFERID" Width="0" Header="TRANSFERID" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="TRANSFERID" />
                        <rx:GridColumns ColumnId="PAYMENTID" Width="0" Header="PAYMENTID" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="PAYMENTID" />
                        <rx:GridColumns ColumnId="REFUNDPAYMENTID" Width="0" Header="REFUNDPAYMENTID" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="REFUNDPAYMENTID" />
                        <rx:GridColumns ColumnId="TU_ISLEMTURU" Width="0" Header="TU_ISLEMTURU" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="TU_ISLEMTURU" />
                        <rx:GridColumns ColumnId="TU_DURUM" Width="0" Header="TU_DURUM" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="TU_DURUM" />
                        <rx:GridColumns ColumnId="PROCESSID" Width="0" Header="Servis" Hidden="true" Sortable="false"
                            DataIndex="PROCESSID" MenuDisabled="true" />
                        <rx:GridColumns ColumnId="TRANSFER_TU_REF" Width="150" Header="UPT Referans" Sortable="false"
                            MenuDisabled="true" DataIndex="TRANSFER_TU_REF">
                            <Commands>
                                <rx:ImageCommand Icon="Button">
                                    <AjaxEvents>
                                        <Click OnEvent="Process">
                                        </Click>
                                    </AjaxEvents>
                                </rx:ImageCommand>
                            </Commands>
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="ISLEM_TARIHI" Width="80" Header="İşlem Tarihi" MenuDisabled="true"
                            Sortable="false" DataIndex="ISLEM_TARIHI" />
                        <rx:GridColumns ColumnId="TU_TARGETTRANSTYPE_NAME" Width="150" Header="Gönderim Türü"
                            Sortable="false" MenuDisabled="true" DataIndex="TU_TARGETTRANSTYPE_NAME" />
                        <rx:GridColumns ColumnId="BANKA_ISLEM_NO" Width="100" Header="Banka İşlem Numarası"
                            Sortable="false" MenuDisabled="true" DataIndex="BANKA_ISLEM_NO" />
                        <%--<rx:GridColumns ColumnId="TU_REF" Width="80" Header="TU_REF" Sortable="false" Hidden="false"
                            MenuDisabled="true" DataIndex="TU_REF" />--%>
                        <rx:GridColumns ColumnId="ISLEM_TIPI" Width="100" Header="İşlem Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ISLEM_TIPI" />
                        <rx:GridColumns ColumnId="AB_STATUS" Width="300" Header="Ab Status" Sortable="false"
                            MenuDisabled="true" DataIndex="AB_STATUS" />
                        <rx:GridColumns ColumnId="TU_STATUS" Width="200" Header="UPT Status" Sortable="false"
                            MenuDisabled="true" DataIndex="TU_STATUS" />
                        <rx:GridColumns ColumnId="AB_TUTAR" Width="150" Header="Ab Tutar" Sortable="false"
                            MenuDisabled="true" DataIndex="AB_TUTAR" Align="Right" />
                        <rx:GridColumns ColumnId="AB_DOVIZ" Width="100" Header="Ab Döviz" Sortable="false"
                            MenuDisabled="true" DataIndex="AB_DOVIZ" />
                        <rx:GridColumns ColumnId="AB_MASRAF_TUTAR" Width="100" Header="Ab Masraf Tutar" Sortable="false"
                            MenuDisabled="true" DataIndex="AB_MASRAF_TUTAR" Align="Right" />
                        <rx:GridColumns ColumnId="AB_MASRAF_DOVIZ" Width="100" Header="Ab Masraf Döviz" Sortable="false"
                            MenuDisabled="true" DataIndex="AB_MASRAF_DOVIZ" />
                        <rx:GridColumns ColumnId="TU_TUTAR" Width="150" Header="UPT Tutar" Sortable="false"
                            MenuDisabled="true" DataIndex="TU_TUTAR" />
                        <rx:GridColumns ColumnId="TU_DOVIZ" Width="100" Header="UPT Döviz" Sortable="false"
                            MenuDisabled="true" DataIndex="TU_DOVIZ">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="TU_MASRAF_TUTAR" Width="150" Header="UPT Masraf Tutar" Sortable="false"
                            MenuDisabled="true" DataIndex="TU_MASRAF_TUTAR">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="TU_MASRAF_DOVIZ" Width="100" Header="UPT Masraf Döviz" Sortable="false"
                            MenuDisabled="true" DataIndex="TU_MASRAF_DOVIZ">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="TU_KURUM" Width="200" Header="UPT Kurum" Sortable="false"
                            MenuDisabled="true" DataIndex="TU_KURUM">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="TU_OFIS" Width="200" Header="UPT Ofis" Sortable="false"
                            MenuDisabled="true" DataIndex="TU_OFIS">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="TU_GISECI" Width="200" Header="UPT Gişeci" Sortable="false"
                            MenuDisabled="true" DataIndex="TU_GISECI">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="RECONCILIATIONOPERATIONHISTORYCOMMAND" Width="100" Header="Bir daha Gösterme"
                            Sortable="false" MenuDisabled="true" DataIndex="">
                            <Commands>
                                <rx:ImageCommand Icon="Delete">
                                    <AjaxEvents>
                                        <Click OnEvent="DeleteProcess">
                                        </Click>
                                    </AjaxEvents>
                                </rx:ImageCommand>
                            </Commands>
                        </rx:GridColumns>
                    </Columns>
                </ColumnModel>
                <SelectionModel>
                    <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                    </rx:RowSelectionModel>
                </SelectionModel>
            </rx:GridPanel>
        </Body>
        <Buttons>
            <rx:Button runat="server" ID="GetReConciliation" Text="(F9)" Icon="MagnifierZoomIn"
                Width="200">
                <AjaxEvents>
                    <Click OnEvent="GetReConciliationClick">
                    </Click>
                </AjaxEvents>
            </rx:Button>
            <rx:Button runat="server" ID="Button2" Text="Settlement Raporu" Icon="ChartBar" Width="200">
                <Listeners>
                    <Click Handler="window.top.ShowEditWindow('', '0bfc8b56-0a2d-475e-905d-63c449cd226c', '', 201100118, '', false) " />
                </Listeners>
            </rx:Button>
            <rx:Button runat="server" ID="Button1" Text="Mutabakat Raporu" Icon="ChartBar" Width="200">
                <Listeners>
                    <Click Handler="window.top.ShowReport(HdnReportId.getValue(),'')" />
                </Listeners>
            </rx:Button>
        </Buttons>
    </rx:PanelX>
    </form>
</body>
</html>
