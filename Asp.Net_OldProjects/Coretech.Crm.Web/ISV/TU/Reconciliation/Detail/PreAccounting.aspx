<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reconciliation.Detail.Reconciliation_Detail_PreAccounting" CodeBehind="PreAccounting.aspx.cs" %>
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
        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="50" AutoWidth="true"
            Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                            Başlangıç Tarihi:
                            <rx:DateField ID="dStartDate" runat="server" Width="100" RequirementLevel="BusinessRequired">
                            </rx:DateField>
                        </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                            Bitiş Tarihi:
                            <rx:DateField ID="dEndDate" runat="server" Width="100" RequirementLevel="BusinessRequired">
                            </rx:DateField>
                        </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="500" AutoWidth="true"
            Border="false">
            <Body>
                <rx:GridPanel runat="server" ID="GrdReConciliation" Title="ReConciliation List" Height="400"
                    AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                    <ColumnModel>
                        <Columns>
                            <rx:GridColumns ColumnId="Reference" Width="120" Header="İşlem Referansı" MenuDisabled="true"
                                Sortable="false" DataIndex="Reference" />
                            <rx:GridColumns ColumnId="Date" Width="120" Header="Tarih" MenuDisabled="true"
                                Sortable="false" DataIndex="Date" />
                            <rx:GridColumns ColumnId="TransactionType" Width="160" Header="İşlem Durumu" MenuDisabled="true"
                                Sortable="false" DataIndex="TransactionType" />
                            <rx:GridColumns ColumnId="StatusDescription" Width="250" Header="Mutabakat Açıklaması"
                                Sortable="false" MenuDisabled="true" DataIndex="StatusDescription" />
                            <rx:GridColumns ColumnId="StatusDescriptionDetail" Width="800" Header="Mutabakat Açıklaması Detayı"
                                Sortable="false" MenuDisabled="true" DataIndex="StatusDescriptionDetail" />
                            <rx:GridColumns ColumnId="btnDetail" Width="30" Header="Detay" Sortable="false"
                                MenuDisabled="true">
                                <Commands>
                                    <rx:ImageCommand Icon="Information">
                                        <AjaxEvents>
                                            <Click OnEvent="ShowDetail">
                                            </Click>
                                        </AjaxEvents>
                                    </rx:ImageCommand>
                                </Commands>
                            </rx:GridColumns>
                            <rx:GridColumns ColumnId="btnOk" Width="30" Header="Mutabakat" Sortable="false"
                                MenuDisabled="true">
                                <Commands>
                                    <rx:ImageCommand Icon="Button">
                                        <AjaxEvents>
                                            <Click OnEvent="Process">
                                            </Click>
                                        </AjaxEvents>
                                    </rx:ImageCommand>
                                </Commands>
                            </rx:GridColumns>
                            <%--<rx:GridColumns ColumnId="btnDontShow" Width="30" Header="Birdaha Gösterme" Sortable="false"
                                MenuDisabled="true">
                                <Commands>
                                    <rx:ImageCommand Icon="Delete">
                                        <AjaxEvents>
                                            <Click OnEvent="DontShowAgain">
                                            </Click>
                                        </AjaxEvents>
                                    </rx:ImageCommand>
                                </Commands>
                            </rx:GridColumns>--%>
                        </Columns>
                    </ColumnModel>
                    <SelectionModel>
                        <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                        </rx:RowSelectionModel>
                    </SelectionModel>
                </rx:GridPanel>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="GetReConciliation" Text="Mutabakat Verilerini Getir (F9)" Icon="MagnifierZoomIn"
                    Width="200">
                    <AjaxEvents>
                        <Click OnEvent="GetReConciliationClick" Before="CrmValidateForm(msg,e);">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                <rx:Button runat="server" ID="Button1" Text="Serbest Fiş Hareketlerini Getir"
                    Width="200">
                    <AjaxEvents>
                        <Click OnEvent="GetReConciliationClick" Before="CrmValidateForm(msg,e);">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
        <rx:Window ID="windowOpenReceipt" runat="server" Width="1000" Height="600" Modal="true"
            Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false" ContainerPadding="true"
            Title="Manuel Fiş Kesme">
            <Body>
                <rx:PanelX runat="server" ID="pnlDetail" AutoHeight="Normal" Height="600" AutoWidth="true"
                    CustomCss="Section2" Title="" Collapsed="false" Collapsible="true"
                    Border="false">
                    <AutoLoad Url="about:blank" />
                    <Body>
                    </Body>
                </rx:PanelX>
            </Body>
        </rx:Window>
    </form>
</body>
</html>
