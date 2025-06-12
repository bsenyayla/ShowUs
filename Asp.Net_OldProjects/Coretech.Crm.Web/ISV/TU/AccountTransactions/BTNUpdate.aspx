<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BTNUpdate.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.AccountTransactions.BTNUpdate" %>
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
            <rx:PanelX runat="server" ID="pSearch" AutoHeight="Normal" Height="25" AutoWidth="true" Border="true" Frame="true" Title="Arama">
                <Body>
                    <rx:ColumnLayout runat="server" ID="cl1" ColumnWidth="23%">
                        <Rows>
                            <rx:RowLayout ID="rl1" runat="server">
                                <Body>
                                    <rx:TextField ID="tTranNumber" runat="server" FieldLabel="İşlem Numarası"></rx:TextField>
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
                    <rx:ColumnLayout runat="server" ID="cl3" ColumnWidth="33%">
                        <Rows>
                            <rx:RowLayout ID="rl3" runat="server">
                                <Body>
                                    <rx:TextField ID="tBTN" runat="server" FieldLabel="Banka İşlem Numarası"></rx:TextField>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout runat="server" ID="cl4" ColumnWidth="5%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="rl4">
                                <Body>
                                    <rx:Button ID="bSave" runat="server" Text="Kaydet" Icon="DatabaseSave">
                                        <AjaxEvents>
                                            <Click OnEvent="Save"></Click>
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
                                <rx:GridColumns Header="Referans" ColumnId="0" DataIndex="Referans" Width="80" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="İşlem Numarası" ColumnId="1" DataIndex="İşlem Numarası" Width="100" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Banka İşlem No" ColumnId="2" DataIndex="Banka İşlem No" Width="100" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="İşlem Tipi" ColumnId="3" DataIndex="İşlem Tipi" Width="100" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Tarih" ColumnId="4" DataIndex="Tarih" Width="120" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Hesap Hareket Tipi" ColumnId="5" DataIndex="Hesap Hareket Tipi" Width="230" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Tutar" ColumnId="6" DataIndex="Tutar" Width="70" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Tutar Dövizi" ColumnId="7" DataIndex="Tutar Dövizi" Width="50" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Hesap" ColumnId="8" DataIndex="Hesap" Width="200" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Yön" ColumnId="9" DataIndex="Yön" Width="20" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="LOGO Hesap" ColumnId="10" DataIndex="LOGO Hesap" Width="200" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="LOGO Yön" ColumnId="11" DataIndex="LOGO Yön" Width="30" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="TL Kuru" ColumnId="12" DataIndex="TL Kuru" Width="30" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Oluşturan" ColumnId="13" DataIndex="Oluşturan" Width="130" Sortable="false" MenuDisabled="true"></rx:GridColumns>
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