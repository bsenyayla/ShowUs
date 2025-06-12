<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reconciliation.Detail.Reconciliation_Detail_UptCashActivityReconcliation" ValidateRequest="false" CodeBehind="UptCashActivityReconcliation.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script type="text/javascript">

      

    </script>
</head>
<body>
    <form id="form1" runat="server">

        <rx:KeyMap runat="server" ID="KeyMap1">
            <rx:KeyBinding>
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="ToolbarButtonFind.click(e);" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:KeyMap runat="server" ID="KeyMap2">
            <rx:KeyBinding Ctrl="true">
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="ToolbarButtonClear.click(e);" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
        <rx:Hidden ID="hdnViewList" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnViewDefaultEditPage" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnViewDefaultEditPage2" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnPoolId" runat="server" Value="1">
        </rx:Hidden>
        <rx:Hidden ID="hdnViewListTotal" runat="server">
        </rx:Hidden>
        <rx:RegisterResources runat="server" ID="RR" />

        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="80" AutoWidth="true"
            Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="100%">
                    <Rows>


                        <rx:RowLayout runat="server">
                            <Body>&nbsp;</Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>

                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="20%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="Row2">
                                            <Body>
                                                <cc1:CrmComboComp runat="server" ID="new_CorporationId" ObjectId="201100097" UniqueName="new_CorporationId"
                                                    FieldLabelWidth="100" Width="130" PageSize="50" RequirementLevel="BusinessRequired">
                                                </cc1:CrmComboComp>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>

                                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="20%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout2">
                                            <Body>
                                                <cc1:CrmComboComp runat="server" ID="new_OfficeId" ObjectId="201100097" UniqueName="new_OfficeId"
                                                    FieldLabelWidth="100" Width="130" PageSize="50" RequirementLevel="BusinessRequired">
                                                    <Filters>
                                                        <cc1:ComboFilter FromObjectId="201100097" FromUniqueName="new_CorporationId" ToObjectId="201100040"
                                                            ToUniqueName="new_CorporationID" />
                                                    </Filters>
                                                </cc1:CrmComboComp>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="15%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout4">
                                            <Body>
                                                <cc1:CrmComboComp runat="server" ID="new_CashNameID" ObjectId="201300002" UniqueName="new_CashNameID"
                                                    FieldLabelWidth="100" Width="130" PageSize="50" LookupViewUniqueName="CashLookup">
                                                    <DataContainer>
                                                        <DataSource OnEvent="new_CashIdLoadEvent">
                                                        </DataSource>
                                                    </DataContainer>
                                                </cc1:CrmComboComp>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="10%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout5">
                                            <Body>
                                                <rx:ComboField ID="cmbCurrency" runat="server" FieldLabel="Döviz">
                                                    <Items>
                                                        <rx:ListItem Text="USD" Value="USD" />
                                                        <rx:ListItem Text="EUR" Value="EUR" />
                                                        <rx:ListItem Text="TL" Value="TL" />
                                                    </Items>
                                                </rx:ComboField>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout333" ColumnWidth="15%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout1_1">
                                            <Body>
                                                <rx:DateField ID="dStartDate" runat="server" FieldLabel="Başlangıç Tarihi" RequirementLevel="BusinessRequired">
                                                </rx:DateField>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColoumnLayout3" ColumnWidth="10%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="Row1">
                                            <Body>
                                                <rx:Button runat="server" ID="btnGetReConciliation" Text="Mutabakat Verilerini Getir (F9)" Icon="MagnifierZoomIn"
                                                    Width="200">
                                                    <AjaxEvents>
                                                        <Click OnEvent="GetOfficeTotals" Before="CrmValidateForm(msg,e);">
                                                        </Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="10%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout3">
                                            <Body>

                                                <rx:Button runat="server" ID="Button2" Text="Kasa hareketlerini Getir" Icon="MagnifierZoomIn"
                                                    Width="200">
                                                    <Listeners>
                                                        <Click Handler="GrdCashTransactions.reload();" />
                                                    </Listeners>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server">
                            <Body>&nbsp;</Body>
                        </rx:RowLayout>
                    </Rows>

                </rx:ColumnLayout>

            </Body>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="PanelX2" AutoHeight="Normal" Height="120" AutoWidth="true"
            Border="false">
            <Body>
                <body>
                    <rx:GridPanel runat="server" ID="GrdTotalCount" Title="Upt İşlem Adetleri" Height="100"
                        AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                        <DataContainer>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns ColumnId="Currency" Width="100" Header="Döviz" Sortable="false"
                                    MenuDisabled="true" DataIndex="Currency">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="CashDepositActivity" Width="100" Header="Nakit Yatırma Aktivite" Sortable="false"
                                    MenuDisabled="true" DataIndex="CashDepositActivity">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="CashDrawActivity" Width="100" Header="Nakit Çekme Aktivite" Sortable="false"
                                    MenuDisabled="true" DataIndex="CashDrawActivity">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="TransferActivity" Width="100" Header="Gönderim Aktivite" Sortable="false"
                                    MenuDisabled="true" DataIndex="TransferActivity">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="PaymentActivity" Width="150" Header="Ödeme Aktivite" Sortable="false"
                                    MenuDisabled="true" DataIndex="PaymentActivity">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="CancelActivity" Width="100" Header="İptal Aktivite" Sortable="false"
                                    MenuDisabled="true" DataIndex="CancelActivity">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="RefundActivity" Width="100" Header="İade Aktivite" Sortable="false"
                                    MenuDisabled="true" DataIndex="RefundActivity">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="TransferPool" Width="100" Header="Gönderim Havuz" Sortable="false"
                                    MenuDisabled="true" DataIndex="TransferPool">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="PaymentPool" Width="150" Header="Ödeme Havuz" Sortable="false"
                                    MenuDisabled="true" DataIndex="PaymentPool">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="CancelPool" Width="100" Header="İptal Havuz" Sortable="false"
                                    MenuDisabled="true" DataIndex="CancelPool">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="RefundPool" Width="100" Header="İade Havuz" Sortable="false"
                                    MenuDisabled="true" DataIndex="RefundPool">
                                </rx:GridColumns>

                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                    </rx:GridPanel>
                </body>
            </Body>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="PanelX4" AutoHeight="Normal" Height="120" AutoWidth="true"
            Border="false">
            <Body>
                <body>
                    <rx:GridPanel runat="server" ID="GrdTotalAmount" Title="Upt İşlem Tutarları" Height="100"
                        AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                        <DataContainer>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns ColumnId="Currency" Width="100" Header="Döviz" Sortable="false"
                                    MenuDisabled="true" DataIndex="Currency">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="MainCashStartBalance" Width="100" Header="Kasa Açılış Bakiye" Sortable="false"
                                    MenuDisabled="true" DataIndex="MainCashStartBalance">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="CashRequest" Width="150" Header="Para Talebi" Sortable="false"
                                    MenuDisabled="true" DataIndex="CashRequest">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="CashExit" Width="100" Header="Para Çıkışı" Sortable="false"
                                    MenuDisabled="true" DataIndex="CashExit">
                                </rx:GridColumns>
                                 <rx:GridColumns ColumnId="CashDeposit" Width="100" Header="Nakit Yatırma" Sortable="false"
                                    MenuDisabled="true" DataIndex="CashDeposit">
                                </rx:GridColumns>
                                 <rx:GridColumns ColumnId="CashDraw" Width="100" Header="Nakit Çekme" Sortable="false"
                                    MenuDisabled="true" DataIndex="CashDraw">
                                </rx:GridColumns> 
                                <rx:GridColumns ColumnId="Transfer" Width="100" Header="Gönderim" Sortable="false"
                                    MenuDisabled="true" DataIndex="Transfer">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="Payment" Width="100" Header="Ödeme" Sortable="false"
                                    MenuDisabled="true" DataIndex="Payment">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="Cancel" Width="150" Header="İptal" Sortable="false"
                                    MenuDisabled="true" DataIndex="Cancel">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="Refund" Width="100" Header="İade" Sortable="false"
                                    MenuDisabled="true" DataIndex="Refund">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="MainCashEndBalance" Width="100" Header="Kasa kapanış bakiye" Sortable="false"
                                    MenuDisabled="true" DataIndex="MainCashEndBalance">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="Formul" Width="100" Header="Formul sonucu kasa" Sortable="false"
                                    MenuDisabled="true" DataIndex="Formul">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="Difference" Width="100" Header="Fark" Sortable="false"
                                    MenuDisabled="true" DataIndex="Difference">
                                </rx:GridColumns>

                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel3" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                    </rx:GridPanel>
                </body>
            </Body>
        </rx:PanelX>





        <rx:PanelX runat="server" ID="PanelX3" AutoHeight="Normal" Height="300" AutoWidth="true"
            Border="false">
            <Body>
                <body>
                    <rx:GridPanel runat="server" ID="GrdCashTransactions" Title="UPT kasa işlemleri" Height="250"
                        AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Remote" AjaxPostable="true">
                        <DataContainer>
                            <DataSource OnEvent="ToolbarButtonFindClick">
                            </DataSource>
                            <Parameters>
                                <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                                <rx:Parameter Name="limit" Value="20" Mode="Value"></rx:Parameter>
                            </Parameters>
                        </DataContainer>

                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                        <BottomBar>
                            <rx:PagingToolBar runat="server" ID="PagingToolBar2" Enabled="true" ControlId="GrdCashTransactions">
                                <Buttons>
                                    <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload2">
                                        <AjaxEvents>
                                            <Click OnEvent="ToolbarButtonFindClick">
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
                        <%--  <LoadMask ShowMask="true" />--%>
                    </rx:GridPanel>
                </body>
            </Body>
        </rx:PanelX>
    </form>
</body>
</html>
