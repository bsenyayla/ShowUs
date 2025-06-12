<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EventList.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.DistributedEvents.EventList" %>
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
            <rx:PanelX runat="server" ID="pSearch" AutoHeight="Normal" Height="25" AutoWidth="true" Border="true" Frame="true" Title="Dağıtık İşlemler">
                <Body>
                    <rx:ColumnLayout runat="server" ID="cl1" ColumnWidth="13%">
                        <Rows>
                            <rx:RowLayout ID="rl1" runat="server">
                                <Body>
                                    <rx:DateField ID="dfStartDate" runat="server" FieldLabel="Başlangıç Tarihi"></rx:DateField>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout runat="server" ID="cl2" ColumnWidth="13%">
                        <Rows>
                            <rx:RowLayout ID="rl2" runat="server">
                                <Body>
                                    <rx:DateField ID="dfEndDate" runat="server" FieldLabel="Bitiş Tarihi"></rx:DateField>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout runat="server" ID="cl3" ColumnWidth="13%">
                        <Rows>
                            <rx:RowLayout ID="rl3" runat="server">
                                <Body>
                                    <rx:ComboField ID="cfEventTypes" runat="server" FieldLabel="Olay Tipi"></rx:ComboField>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout runat="server" ID="cl4" ColumnWidth="14%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="rl4">
                                <Body>
                                    <rx:Button ID="btnSearch" runat="server" Text="Getir" Icon="Find">
                                        <AjaxEvents>
                                            <Click OnEvent="Search"></Click>
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
                    <rx:GridPanel runat="server" ID="gpEvents" AutoWidth="true" Editable="false" Mode="Local" AutoLoad="false" AjaxPostable="true">
                        <TopBar>
                            <rx:ToolBar ID="toolBar1" runat="server" ContainerPadding="true">
                                <Items>
                                </Items>
                            </rx:ToolBar>
                        </TopBar>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="Id" ColumnId="0" DataIndex="EventId" Hidden="true" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Olay" ColumnId="1" DataIndex="EventTypeDesc" Width="300" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Oluşturan" ColumnId="2" DataIndex="CreateUserFullname" Width="200" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Tarih" ColumnId="3" DataIndex="CreateDate" Width="125" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Durum" ColumnId="4" DataIndex="EventStatus" Width="250" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Detay" ColumnId="7" Width="50" Sortable="false" MenuDisabled="true" Align="Center">
                                    <Commands>
                                        <rx:ImageCommand Icon="ApplicationGo">
                                            <AjaxEvents>
                                                <Click OnEvent="ShowDetail">
                                                </Click>
                                            </AjaxEvents>
                                        </rx:ImageCommand>
                                    </Commands>
                                </rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                    </rx:GridPanel>
                    <rx:Window ID="windowClients" runat="server" Width="400" Height="300" Modal="true"
                        CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
                        CloseAction="Hide" ShowOnLoad="false">
                        <Body>
                            <rx:GridPanel runat="server" ID="gpClients" AutoHeight="Normal" Height="270" Editable="false" Mode="Local" AutoLoad="false" 
                                AjaxPostable="true">
                                <ColumnModel>
                                    <Columns>
                                        <rx:GridColumns Header="İstemci" ColumnId="0" DataIndex="HOSTNAME" Width="200"></rx:GridColumns>
                                        <rx:GridColumns Header="Durum" ColumnId="1" DataIndex="PROCESS_STATUS" Width="150"></rx:GridColumns>
                                    </Columns>
                                </ColumnModel>
                                <SelectionModel>
                                    <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                                    </rx:RowSelectionModel>
                                </SelectionModel>
                            </rx:GridPanel>
                        </Body>
                    </rx:Window>
                </Body>
            </rx:PanelX>
        </div>
    </form>
</body>
</html>