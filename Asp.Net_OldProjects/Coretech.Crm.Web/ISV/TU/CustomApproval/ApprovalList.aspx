<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ApprovalList.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.CustomApproval.ApprovalList" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" TagPrefix="cc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <rx:RegisterResources runat="server" ID="RR" />
            <rx:PanelX runat="server" ID="pnlSearch" Height="100" AutoHeight="Normal" AutoWidth="true" Border="true">
                <Body>
                    <rx:ColumnLayout runat="server" ID="cl1" ColumnWidth="40%">
                        <Rows>
                            <rx:RowLayout ID="rl1" runat="server">
                                <Body>
                                    <rx:DateField ID="dfStartDate" runat="server" FieldLabel="Başlangıç Tarihi"></rx:DateField>
                                    <rx:TextField ID="tfKey" runat="server" FieldLabel="Referans"></rx:TextField>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout runat="server" ID="cl2" ColumnWidth="30%">
                        <Rows>
                            <rx:RowLayout ID="rl2" runat="server">
                                <Body>
                                    <rx:DateField ID="dfEndDate" runat="server" FieldLabel="Bitiş Tarihi"></rx:DateField>
                                    <rx:CheckField ID="cfStatus" FieldLabelWidth="500" Width="50" runat="server" Checked="true" FieldLabel="Yalnızca onay <br/> bekleyen kayıtları göster."></rx:CheckField>

                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="30%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="RowLayout4">
                                <Body>
                                    <rx:Button ID="btnList" runat="server" Text="Getir" Icon="Find">
                                        <AjaxEvents>
                                            <Click OnEvent="GetApprovalList"></Click>
                                        </AjaxEvents>
                                    </rx:Button>
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
            <rx:PanelX ID="Pnl1" runat="server">
                <Body>
                    <rx:GridPanel runat="server" ID="gpApproval" AutoWidth="true" Editable="false" Mode="Local" AutoLoad="false" AjaxPostable="true">
                        <TopBar>
                            <rx:ToolBar ID="toolBar1" runat="server" ContainerPadding="true">
                                <Items>
                                </Items>
                            </rx:ToolBar>
                        </TopBar>
                        <DataContainer>
                            <DataSource OnEvent="ApprovalDataLoad">
                            </DataSource>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="Id" ColumnId="0" DataIndex="ApprovalId" Hidden="true" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Referans" ColumnId="1" DataIndex="ApprovalDescription" Width="250" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Onay Tipi" ColumnId="2" DataIndex="ApprovalType" Width="350" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="İşlemi Yapan Kullanıcı" ColumnId="3" DataIndex="CreateUserFullName" Width="250" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Durum" ColumnId="4" DataIndex="ApprovalStatus" Width="150" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Tarih" ColumnId="5" DataIndex="CreateDate" Width="150" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Açıklama" ColumnId="5" DataIndex="ApprovalExplanation" Width="150" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Url" ColumnId="6" DataIndex="ApprovalUrl" Hidden="true" Sortable="false" MenuDisabled="true"></rx:GridColumns>
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
                                <rx:GridColumns Header="Tarihçe" ColumnId="8" Width="50" Sortable="false" MenuDisabled="true">
                                    <Commands>
                                        <rx:ImageCommand Icon="Book">
                                            <AjaxEvents>
                                                <Click OnEvent="ShowHistory">
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
                </Body>
            </rx:PanelX>
            <rx:Window ID="windowDetail" runat="server" Width="1000" Height="600" Modal="true"
                CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="true" Resizable="false"
                CloseAction="Hide" ShowOnLoad="false">
                <Body>
                    <rx:PanelX runat="server" ID="pnlDetail" AutoHeight="Normal" Height="570" AutoWidth="true"
                        CustomCss="Section2" Title="Onaylama" Collapsed="false" Collapsible="true" AutoScroll="true"
                        Border="false">
                        <AutoLoad Url="about:blank" />
                        <Body>
                        </Body>
                    </rx:PanelX>
                </Body>
            </rx:Window>
            <rx:Window ID="windowHistory" runat="server" Width="600" Height="300" Modal="true"
                CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="true" Resizable="false"
                CloseAction="Hide" ShowOnLoad="false">
                <Body>
                    <rx:GridPanel runat="server" ID="gpHistory" AutoHeight="Normal" Height="300" Editable="false" Mode="Local" AutoLoad="false"
                        AjaxPostable="true">
                        <DataContainer>
                            <DataSource OnEvent="ApprovalHistoryDataLoad">
                            </DataSource>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="Durum" ColumnId="0" DataIndex="ApprovalStatus" Width="150"></rx:GridColumns>
                                <rx:GridColumns Header="Onay Kullanıcısı" ColumnId="1" DataIndex="ApprovalUserFullName" Width="200"></rx:GridColumns>
                                <rx:GridColumns Header="Tarih" ColumnId="2" DataIndex="CreateDate" Width="200"></rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                    </rx:GridPanel>
                </Body>
            </rx:Window>
        </div>
    </form>
</body>
</html>
