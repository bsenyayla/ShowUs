<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Reconciliation.Detail.Reconciliation_UptBankTotalCheck" Async="true" Codebehind="UptBankTotalCheck.aspx.cs" %>

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
        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="50" AutoWidth="true"
            Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="30%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmDateFieldComp ID="new_StartDate" runat="server" ObjectId="201300006"
                                    UniqueName="new_StartDate" FieldLabelWidth="110" Width="100" RequirementLevel="BusinessRequired">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="30%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout32">
                            <Body>
                                <cc1:CrmDateFieldComp ID="new_EndDate" runat="server" ObjectId="201300006"
                                    UniqueName="new_EndDate" FieldLabelWidth="110" Width="100" RequirementLevel="BusinessRequired">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="500" AutoWidth="true"
            Border="false">
            <Body>
                <rx:Fieldset runat="server" ID="PanelX3" AutoHeight="Normal" Height="500" AutoWidth="true"
                    CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false">
                    <Body>
                        <rx:GridPanel runat="server" ID="GrdTotalReConciliation" Title="UPT - Banka Mutabakat" Height="500"
                            AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                            <DataContainer>
                            </DataContainer>
                            <ColumnModel>
                                <Columns>
                                    <rx:GridColumns ColumnId="REFERANS" Width="120" Header="REFERANS" Sortable="false"
                                        MenuDisabled="true" DataIndex="REFERANS">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="BANKA_TOPLAMI" Width="120" Header="BANKA TOPLAMI" Sortable="false"
                                        MenuDisabled="true" DataIndex="BANKA_TOPLAMI">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="UPT_TOPLAMI" Width="120" Header="UPT TOPLAMI" Sortable="false"
                                        MenuDisabled="true" DataIndex="UPT_TOPLAMI">
                                    </rx:GridColumns> 
                                    <rx:GridColumns ColumnId="FARK" Width="120" Header="FARK" Sortable="false"
                                        MenuDisabled="true" DataIndex="FARK">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="KURUM" Width="300" Header="KURUM" Sortable="false"
                                        MenuDisabled="true" DataIndex="KURUM">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="UPT_ISLEM_TARIHI" Width="120" Header="UPT İŞLEM TARİHİ" Sortable="false"
                                        MenuDisabled="true" DataIndex="UPT_ISLEM_TARIHI">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="MUTABAKAT_TIPI_ACIKLAMA" Width="500" Header="MUTABAKATSIZLIK AÇIKLAMA" Sortable="false"
                                        MenuDisabled="true" DataIndex="MUTABAKAT_TIPI_ACIKLAMA">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="btnOk" Width="30" Header="AKSİYON" Sortable="false"
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
                                </Columns>
                            </ColumnModel>
                            <SelectionModel>
                                <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true" Width="50">
                                </rx:RowSelectionModel>
                            </SelectionModel>
                        </rx:GridPanel>
                    </Body>
                </rx:Fieldset>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="GetReConciliation" Text="Mutabakat Verilerini Getir (F9)" Icon="MagnifierZoomIn" Width="200">
                    <AjaxEvents>
                        <Click OnEvent="GetReConciliationClick">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                <rx:Button runat="server" ID="btnExportToExcel" Text="Sonuçları Excel'e Aktar" Width="200" Download="true">
                    <AjaxEvents>
                        <Click OnEvent="ExportToExcel">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
        <rx:Window ID="windowOpenReceipt" runat="server" Width="400" Height="300" Modal="true"
            Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false" ContainerPadding="true"
            Title="Serbest Fiş Kes">
            <Body>
                <rx:PanelX ID="PanelX2" runat="server" AutoHeight="Normal" Height="30" Width="400" ContainerPadding="true">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="100%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout8" runat="server">
                                    <Body>
                                        <strong><rx:Label ID="lblTransaction" runat="server"></rx:Label></strong>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <br />
                    </Body>
                </rx:PanelX>
                <rx:PanelX ID="PanelX4" runat="server" AutoHeight="Normal" Height="30" Width="300" ContainerPadding="true">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="100%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout2" runat="server">
                                    <Body>
                                        <rx:ComboField ID="cfAction" runat="server">
                                        </rx:ComboField>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <br />
                    </Body>
                </rx:PanelX>
            </Body>
        </rx:Window>
    </form>
    <p>
    </p>
</body>
</html>
