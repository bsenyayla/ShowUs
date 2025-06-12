<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ShowAccountBalances.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Operation.ShowAccountBalances" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR" />
    <div>
        <rx:PanelX ID="SearchPanel" runat="server" AutoHeight="Normal" Height="30" Title="Gelişmiş Sorgulama" ContainerPadding="true">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="15%">
                    <Rows>
                        <rx:RowLayout ID="R1" runat="server">
                            <Body>
                                <rx:TextField ID="tAccountNo" runat="server" FieldLabel="Hesap No" ContainerPadding="true">
                                </rx:TextField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="15%">
                    <Rows>
                        <rx:RowLayout ID="R2" runat="server">
                            <Body>
                                <rx:Button ID="bSearch" runat="server" Text="Sorgula" Icon="MagnifierZoomIn">
                                    <AjaxEvents>
                                        <Click OnEvent="SearchOnEvent">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:PanelX ID="pnlAccounts" runat="server" AutoHeight="Auto" AutoWidth="true" Title="Hesaplar">
            <Body>
                <rx:GridPanel runat="server" ID="gpAccounts" AutoWidth="true" Editable="false" Mode="Local" AutoLoad="false">
                    <DataContainer>
                        <DataSource OnEvent="AccountsOnLoad">
                        </DataSource>
                    </DataContainer>
                    <SelectionModel>
                        <rx:RowSelectionModel ID="rsmAccounts" runat="server">
                        </rx:RowSelectionModel>
                    </SelectionModel>
                    <ColumnModel>
                        <Columns>
                            <rx:GridColumns Header="HESAP TIPI" ColumnId="0" DataIndex="HESAP TIPI" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="HESAP NO" ColumnId="1" DataIndex="HESAP NO" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="HESAP ADI" ColumnId="2" DataIndex="HESAP ADI" Width="200"></rx:GridColumns>
                            <rx:GridColumns Header="KURUM ADI" ColumnId="3" DataIndex="KURUM ADI" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="OFIS ADI" ColumnId="4" DataIndex="OFIS ADI" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="DOVIZ CINSI" ColumnId="5" DataIndex="DOVIZ CINSI" Width="80"></rx:GridColumns>
                            <rx:GridColumns Header="BAKIYE" ColumnId="6" DataIndex="BAKIYE" Align="Right" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="BLOKE BAKIYE" ColumnId="7" DataIndex="BLOKE BAKIYE" Align="Right" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="LIMIT" ColumnId="8" DataIndex="LIMIT" Align="Right" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="KULLANILABILIR BAKIYE" ColumnId="9" DataIndex="KULLANILABILIR BAKIYE" Align="Right" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="BAKIYE SON GUNCELLEME" ColumnId="9" DataIndex="BAKIYE SON GUNCELLEME TARIHI" Width="150"></rx:GridColumns>
                        </Columns>
                    </ColumnModel>
                    <BottomBar>
                        <rx:PagingToolBar ID="ptbAccounts" runat="server" ControlId="gpAccounts">
                        </rx:PagingToolBar>
                    </BottomBar>
                </rx:GridPanel>
            </Body>
        </rx:PanelX>
    </div>
    </form>
</body>
</html>
