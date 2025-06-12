<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Reconciliation.Detail.Reconciliation_LogoTotal" Async="true" Codebehind="LogoTotal.aspx.cs" %>

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
        <rx:Hidden ID="hdnStartDate" runat="server"></rx:Hidden>
        <rx:Hidden ID="hdnEndDate" runat="server"></rx:Hidden>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="800" AutoWidth="true"
            Border="false">
            <Body>
                <rx:Fieldset runat="server" ID="PanelX3" AutoHeight="Normal" Height="800" AutoWidth="true"
                    CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false">
                    <Body>
                        <rx:GridPanel runat="server" ID="GrdTotalReConciliation" Title="UPT - Logo Mutabakat" Height="800"
                            AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                            <DataContainer>
                            </DataContainer>
                            <ColumnModel>
                                <Columns>
                                    <rx:GridColumns ColumnId="ISLEM_TIPI_KOD" Width="250" Header="İşlem Tipi" Sortable="false"
                                        MenuDisabled="true" DataIndex="ISLEM_TIPI_KOD">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="TOPLAM_TIPI" Width="100" Header="Adet / Tutar" Sortable="false"
                                        MenuDisabled="true" DataIndex="TOPLAM_TIPI">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="DOVIZ_TIPI" Width="100" Header="Döviz Cinsi" Sortable="false"
                                        MenuDisabled="true" DataIndex="DOVIZ_TIPI">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="UPT_TOPLAM" Width="100" Header="UPT Toplam" Sortable="false"
                                        MenuDisabled="true" DataIndex="UPT_TOPLAM">
                                    </rx:GridColumns> 
                                    <rx:GridColumns ColumnId="LOGO_TOPLAM" Width="100" Header="Logo Toplam" Sortable="false"
                                        MenuDisabled="true" DataIndex="LOGO_TOPLAM">
                                    </rx:GridColumns>                                  
                                </Columns>
                            </ColumnModel>
                            <SelectionModel>
                                <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                                </rx:RowSelectionModel>
                            </SelectionModel>
                        </rx:GridPanel>
                    </Body>
                </rx:Fieldset>
            </Body>
            <%--<Buttons>
                <rx:Button runat="server" ID="GetReConciliation" Text="(F9)" Icon="MagnifierZoomIn"
                    Width="200">
                    <AjaxEvents>
                        <Click OnEvent="GetReConciliationClick">
                        </Click>
                    </AjaxEvents>
                </rx:Button>

            </Buttons>--%>
        </rx:PanelX>
    </form>
    <p>
    </p>
</body>
</html>
