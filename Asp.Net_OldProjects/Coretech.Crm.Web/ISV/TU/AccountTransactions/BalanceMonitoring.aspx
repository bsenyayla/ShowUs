<%@ Page Language="C#" AutoEventWireup="true" Inherits="Account_Monitoring" ValidateRequest="false" CodeBehind="BalanceMonitoring.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript">
        var Currency2dpRender = function (value) {return value.toFixed(2);}; 
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="MainGridSelectedRow" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="DetailGridSelectedRow" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="MainGridSelectedRowAccountNumber" runat="server">
        </rx:Hidden>
        <rx:KeyMap runat="server" ID="KeyMap1">
            <rx:KeyBinding>
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="BtnSearch.click(e);" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>


        <rx:PanelX ID="pnlMainAccounts" runat="server" AutoHeight="Normal" Height="200" AutoWidth="true" Title="Ana Hesaplar">
            <Body>
                <rx:GridPanel runat="server" ID="GridPanelMainAccount" AutoWidth="true" Editable="false" Mode="Remote" AutoLoad="true" AjaxPostable="true">
                    <DataContainer>
                        <DataSource OnEvent="GridPanelMainAccountOnEvent">
                        </DataSource>
                        <Parameters>
                            <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                            <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                        </Parameters>
                    </DataContainer>
                    <SelectionModel>
                        <rx:RowSelectionModel ID="GridPanelPaymentsRowSelectionModel1" runat="server" ShowNumber="true">
                            <Listeners>
                                <RowClick Handler="MainGridSelectedRow.clear();MainGridSelectedRow.setValue(GridPanelMainAccount.selectedRecord.new_AccountId);
                                    lblAccountNo.clear();lblAccountNo.setValue(GridPanelMainAccount.selectedRecord.new_AccountNumber);"></RowClick>
                            </Listeners>
                            <AjaxEvents>
                                <RowDblClick OnEvent="RowClickOnEvent">
                                </RowDblClick>
                            </AjaxEvents>
                        </rx:RowSelectionModel>
                    </SelectionModel>
                    <ColumnModel>
                        <Columns>
                            <rx:GridColumns Header="Hesap ID" ColumnId="0" DataIndex="new_AccountId" Align="Right" Width="100" Hidden="true"></rx:GridColumns>
                            <rx:GridColumns Header="Hesap No" ColumnId="1" DataIndex="new_AccountNo" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="Döviz Cinsi" ColumnId="2" DataIndex="new_CurrencyIdName" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="Hesap Açıklama" ColumnId="5" DataIndex="new_AccountNumber" Width="300"></rx:GridColumns>
                            <%--  <rx:GridColumns Header="Bakiye" ColumnId="6" DataIndex="new_Balance" Align="Right" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="Bloke Bakiye" ColumnId="6" DataIndex="new_MinimumBalance" Align="Right" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="Limit Bakiye" ColumnId="6" DataIndex="new_Limit" Align="Right" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="Kullanılabilir Bakiye" ColumnId="6" DataIndex="new_UsableBalance" Align="Right" Width="150"></rx:GridColumns>--%>
                            <rx:GridColumns Header="Toplam Bakiye" ColumnId="6" DataIndex="new_TotalBalance" Align="Right" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="Toplam Bloke Bakiye" ColumnId="6" DataIndex="new_TotalMinimumBalance" Align="Right" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="Toplam Limit Bakiye" ColumnId="6" DataIndex="new_TotalLimit" Align="Right" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="Toplam Kullanılabilir Bakiye" ColumnId="6" DataIndex="new_TotalUsableBalance" Align="Right" Width="150"></rx:GridColumns>
                        </Columns>
                    </ColumnModel>
                    <BottomBar>
                        <rx:PagingToolBar ID="PagingToolBar1" runat="server" ControlId="GridPanelMainAccount">
                        </rx:PagingToolBar>
                    </BottomBar>
                </rx:GridPanel>
            </Body>
        </rx:PanelX>
        <rx:PanelX ID="SearchPanel" runat="server" AutoHeight="Normal" Height="50" Title="Gelişmiş Sorgulama" ContainerPadding="true">
            <Body>
                <br />
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="10%">
                    <Rows>
                        <rx:RowLayout ID="R1" runat="server">
                            <Body>
                                <rx:TextField ID="AccountNo" runat="server" FieldLabel="Hesap No" ContainerPadding="true">
                                    <AjaxEvents>
                                        <Change OnEvent="CorporationChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </rx:TextField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="15%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_CorporationId" ObjectId="201500021" UniqueName="new_CorporationId"
                                    Width="150" Mode="Remote" LookupViewUniqueName="CorpComboView">
                                    <DataContainer>
                                        <DataSource OnEvent="CorporationLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="CorporationChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <%--   <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="5%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <rx:Button ID="BtnSearch" runat="server" Text="Fitrele {F9}" Icon="MagnifierZoomIn">
                                    <AjaxEvents>
                                        <Click OnEvent="SearchOnEvent">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>--%>
                <%-- <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="5%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <rx:Button ID="Button1" runat="server" Text="Geçmiş Hesap Bakiyelerini Getir" Icon="Report">
                                    <Listeners>
                                        <Click Handler="windowTotal.show(); GridPanelAccountBalanceHistory.reload();" />
                                    </Listeners>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>--%>
                <br />
            </Body>
        </rx:PanelX>
        <rx:PanelX ID="PanelX1" runat="server" AutoHeight="Auto" Height="360" AutoWidth="true" Title="Alt Hesaplar">
            <Body>
                <rx:GridPanel runat="server" ID="GridPanelMainAccountDetail" AutoWidth="true" Editable="false" Mode="Remote" AutoLoad="false" AjaxPostable="true">
                    <DataContainer>
                        <DataSource OnEvent="GridPanelMainAccountDetailOnEvent">
                        </DataSource>
                        <Parameters>
                            <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                            <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                        </Parameters>
                    </DataContainer>
                    <SelectionModel>

                        <rx:RowSelectionModel ID="RowSelectionModel3" runat="server" ShowNumber="true">
                            <Listeners>
                                <RowClick Handler="DetailGridSelectedRow.clear();DetailGridSelectedRow.setValue(GridPanelMainAccountDetail.selectedRecord.new_AccountId);
                                    lblAccountNo.clear();lblAccountNo.setValue(GridPanelMainAccountDetail.selectedRecord.new_AccountNo);"></RowClick>
                                <RowDblClick Handler="windowTotal.show();GridPanelAccountBalanceHistory.clear();" />
                            </Listeners>
                           <%-- <AjaxEvents>
                                <RowDblClick OnEvent="GridPanelAccountBalanceHistoryOnEvent">
                                </RowDblClick>
                            </AjaxEvents>--%>
                        </rx:RowSelectionModel>

                    </SelectionModel>
                    <ColumnModel>
                        <Columns>
                            <rx:GridColumns Header="Hesap ID" ColumnId="0" DataIndex="new_AccountId" Align="Right" Width="100" Hidden="true"></rx:GridColumns>
                            <rx:GridColumns Header="Hesap No" ColumnId="1" DataIndex="new_AccountNo" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="Döviz Cinsi" ColumnId="2" DataIndex="new_CurrencyIdName" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="CorporationId" ColumnId="3" DataIndex="new_CorporationId" Width="100" Hidden="true"></rx:GridColumns>
                            <rx:GridColumns Header="Kurum Adı" ColumnId="4" DataIndex="new_CorporationIdName" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="Hesap Açıklama" ColumnId="5" DataIndex="new_AccountNumber" Width="300"></rx:GridColumns>
                            <rx:GridColumns Header="Bakiye" ColumnId="6" DataIndex="new_Balance" Align="Right" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="Bloke Bakiye" ColumnId="7" DataIndex="new_MinimumBalance" Align="Right" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="Limit Bakiye" ColumnId="8" DataIndex="new_Limit" Align="Right" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="Kullanılabilir Bakiye" ColumnId="9" DataIndex="new_UsableBalance" Align="Right" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="Bakiye Son Güncelleme" ColumnId="9" DataIndex="new_LastBalanceUpdateTime" Align="Right" Width="150"></rx:GridColumns>
                        </Columns>
                    </ColumnModel>
                    <BottomBar>
                        <rx:PagingToolBar ID="ptb" runat="server" ControlId="GridPanelMainAccountDetail">
                            <Buttons>
                                <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload2">
                                    <AjaxEvents>
                                        <Click OnEvent="GridPanelMainAccountDetailOnEvent">
                                            <EventMask ShowMask="false" />
                                            <ExtraParams>
                                                <rx:Parameter Name="Excel" Value="1" Mode="Value" />
                                            </ExtraParams>
                                        </Click>
                                    </AjaxEvents>
                                </rx:SmallButton>
                            </Buttons>
                        </rx:PagingToolBar>
                    </BottomBar>
                </rx:GridPanel>

            </Body>
        </rx:PanelX>
        <rx:Window ID="windowTotal" runat="server" Width="800" Height="400" Modal="true"
            Closable="true" Maximizable="false" Resizable="true" CloseAction="Hide" ShowOnLoad="false" ContainerPadding="true"
            Title="Hesap Bakiye İzleme - (Geçmiş)">
            <Body>
                <rx:PanelX ID="PanelX2" runat="server" AutoHeight="Normal" Height="50" ContainerPadding="true">
                    <Body>
                        <rx:Label ID="lblAccountNo" runat="server"></rx:Label>
                        <br />
                        <br />
                        <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="25%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout8" runat="server">
                                    <Body>
                                        <rx:DateField ID="AccountTransactionDate1" runat="server" FieldLabel="Baş. Tarihi">
                                        </rx:DateField>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="25%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout1" runat="server">
                                    <Body>
                                        <rx:DateField ID="AccountTransactionDate2" runat="server" FieldLabel="Bitiş Tarihi ">
                                        </rx:DateField>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="15%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout9" runat="server">
                                    <Body>

                                        <rx:Button ID="Button3" runat="server" Text="Getir" Icon="MagnifierZoomIn">
                                            <AjaxEvents>
                                                <Click OnEvent="GridPanelAccountBalanceHistoryOnEvent">
                                                </Click>
                                            </AjaxEvents>
                                        </rx:Button>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <br />
                    </Body>
                </rx:PanelX>
                <rx:GridPanel runat="server" ID="GridPanelAccountBalanceHistory" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
                    Height="150" Editable="false" Mode="local" AutoLoad="true" Width="1200" AjaxPostable="true">
                    <DataContainer>
                        <DataSource OnEvent="GridPanelAccountBalanceHistoryOnEvent">
                        </DataSource>
                    </DataContainer>
                    <ColumnModel>
                        <Columns>
                             <rx:GridColumns Header="İşlem Referans" ColumnId="1" DataIndex="TransactionReference" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="Hesap No" ColumnId="2" DataIndex="AccountNo" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="Döviz Cinsi" ColumnId="3" DataIndex="CurrencyCode" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="Hesap Açıklama" ColumnId="4" DataIndex="Description" Width="300"></rx:GridColumns>
                            <rx:GridColumns Header="Logo Hesap" ColumnId="5" DataIndex="LogoAccount" Width="300"></rx:GridColumns>
                            <rx:GridColumns Header="Hareket Tipi" ColumnId="6" DataIndex="TransactionType" Width="300"></rx:GridColumns>
                            <rx:GridColumns Header="Tutar" ColumnId="7" DataIndex="Amount" Align="Right" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="Son Bakiye" ColumnId="8" DataIndex="Balance" Align="Right" Width="150"></rx:GridColumns>
                            <rx:GridColumns Header="Yön" ColumnId="9" DataIndex="Direction" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="Logo Yön" ColumnId="10" DataIndex="LogoDirection" Width="100"></rx:GridColumns>
                            <rx:GridColumns Header="Oluşturan" ColumnId="11" DataIndex="CreatedByName" Width="300"></rx:GridColumns>
                            <rx:GridColumns Header="Oluşturma Tarihi" ColumnId="12" DataIndex="CreatedOn" Width="300"></rx:GridColumns>

                        </Columns>
                    </ColumnModel>
                    <BottomBar>
                        <rx:PagingToolBar ID="PagingToolBar2" runat="server" ControlId="GridPanelAccountBalanceHistory">
                            <Buttons>
                                <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload23">
                                    <AjaxEvents>
                                        <Click OnEvent="GridPanelAccountBalanceHistoryOnEvent">
                                            <EventMask ShowMask="false" />
                                            <ExtraParams>
                                                <rx:Parameter Name="Excel" Value="1" Mode="Value" />
                                            </ExtraParams>
                                        </Click>
                                    </AjaxEvents>
                                </rx:SmallButton>
                            </Buttons>
                        </rx:PagingToolBar>
                    </BottomBar>
                    <SelectionModel>
                        <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true" SingleSelect="true">
                        </rx:RowSelectionModel>
                    </SelectionModel>
                    <LoadMask ShowMask="true" />
                </rx:GridPanel>
            </Body>
        </rx:Window>
    </form>
</body>
</html>
