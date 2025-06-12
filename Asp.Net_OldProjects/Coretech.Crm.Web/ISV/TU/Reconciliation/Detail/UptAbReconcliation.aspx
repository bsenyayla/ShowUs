<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reconciliation.Detail.Reconciliation_Detail_UptAbReconcliation" ValidateRequest="false" CodeBehind="UptAbReconcliation.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style type="text/css">
        body .x-label {
            white-space: normal !important;
        }
    </style>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script type="text/javascript">

        function ShowUptWindow(UptReference, BankTransactionNumber) {
            var url = window.top.GetWebAppRoot + "/ISV/TU/Reconciliation/Detail/UptAbReconcliationDetail.aspx?UptReference=" + UptReference + "&BankTransactionNumber=" + BankTransactionNumber;

            if (window != null) {
                url += "&tabframename=" + window.name;
                url += "&rlistframename=" + window.name
            }
            if (window.parent != null) {
                url += "&pawinid=" + window.parent.name;
                url += "&pframename=" + window.parent.name;
            }

            window.top.newWindowRefleX(url, { maximized: false, width: 900, height: 600, resizable: true, modal: true, maximizable: false });
        }
        //function ActionTemplate(TransferId, Action, RefNumber) {
        //    if (TransferId == "" || Action == 0)
        //        return RefNumber;
        //    return String.format(
        //            "<a href=javascript:Integrate('{0}','{1}') ><img src='" + GetWebAppRoot + "/images/bullet.png' width=12 height=12 />{2}<div  class='cell-imagecommand icon-button '></div></a>",
        //            TransferId, Action, RefNumber);
        //}

        //function Integrate(id, Action) {
        //    HdnChTransferId.setValue(id);
        //    HdnActionId.setValue(Action);
        //    BtnAction.click();
        //}
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

        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="70" AutoWidth="true" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="30%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout1_1">
                            <Body>
                                <rx:DateField ID="dStartDate" runat="server" FieldLabel="Başlangıç Tarihi">
                                </rx:DateField>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout1_2">
                            <Body>
                                <rx:DateField ID="dEndDate" runat="server" FieldLabel="Bitiş Tarihi">
                                </rx:DateField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="70%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <rx:Button runat="server" ID="btnSave" Text="Mutabakat Çalıştır" Icon="Accept" Width="200">
                                    <AjaxEvents>
                                        <Click OnEvent="SaveReConciliation" Before="CrmValidateForm(msg,e);">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>

        <rx:PanelX runat="server" ID="PanelX4" AutoHeight="Normal" Height="80" AutoWidth="true" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <rx:TextField ID="txtUptReference" runat="server" FieldLabel="Upt Referans" FieldLabelWidth="100"></rx:TextField>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <rx:TextField ID="txtBankTransactionNumber" runat="server" FieldLabel="Banka İşlem No"></rx:TextField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <rx:ComboField ID="cmbCurrency" runat="server" FieldLabel="Döviz">
                                    <Items>
                                        <rx:ListItem Text="USD" Value="USD" />
                                        <rx:ListItem Text="EUR" Value="EUR" />
                                        <rx:ListItem Text="TRY" Value="TRY" />
                                    </Items>
                                </rx:ComboField>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <rx:ComboField ID="cmbDirection" runat="server" FieldLabel="Yön">
                                    <Items>
                                        <rx:ListItem Text="Alacak" Value="A" />
                                        <rx:ListItem Text="Borç" Value="B" />
                                    </Items>
                                </rx:ComboField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_ReconcliationStatus" ObjectId="201600022" UniqueName="new_ReconcliationStatus"
                                    FieldLabelWidth="70" Width="230" PageSize="50">
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

                <rx:ColumnLayout runat="server" ID="ColoumnLayout3" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="Row1">
                            <Body>
                                <rx:Button runat="server" ID="btnGetReConciliation" Text="Mutabakat Verilerini Getir (F9)" Icon="MagnifierZoomIn"
                                    Width="200">
                                    <Listeners>
                                        <Click Handler="GrdReConciliation.reload();" />
                                    </Listeners>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout8">
                            <Body>
                                <rx:Button runat="server" ID="Button1" Text="Sorunlu işlemleri  Getir" Icon="MagnifierZoomIn"
                                    Width="200">
                                    <Listeners>
                                        <Click Handler="GrdProblemReconciliations.reload();" />
                                    </Listeners>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

            </Body>
        </rx:PanelX>

        <rx:PanelX runat="server" ID="PanelX2" AutoHeight="Normal" Height="120" AutoWidth="true"
            Border="false">
            <Body>
                <body>
                    <rx:GridPanel runat="server" ID="GrdTotalReConciliationTotal1" Title="UPT Mutabakat total" Height="100"
                        AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                        <DataContainer>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns ColumnId="CTYPE" Width="100" Header="Kaynak" Sortable="false"
                                    MenuDisabled="true" DataIndex="CTYPE">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="TRY" Width="100" Header="TL Toplam" Sortable="false"
                                    MenuDisabled="true" DataIndex="TRY">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="USD" Width="150" Header="USD Toplam" Sortable="false"
                                    MenuDisabled="true" DataIndex="USD">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="EUR" Width="100" Header="Euro Toplam" Sortable="false"
                                    MenuDisabled="true" DataIndex="EUR">
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="GBP" Width="100" Header="Gbp Toplam" Sortable="false"
                                    MenuDisabled="true" DataIndex="GBP">
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

        <rx:PanelX runat="server" ID="PanelX3" AutoHeight="Normal" Height="300" AutoWidth="true"
            Border="false">
            <Body>
                <body>
                    <rx:GridPanel runat="server" ID="GrdProblemReconciliations" Title="UPT Mutabakat Sorunlu İşlemler" Height="250"
                        AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Remote" AjaxPostable="true">
                        <DataContainer>
                            <DataSource OnEvent="ToolbarButtonFindProblemTransactionClick">
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
                            <rx:PagingToolBar runat="server" ID="PagingToolBar2" Enabled="true" ControlId="GrdProblemReconciliations">
                                <Buttons>
                                    <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload2">
                                        <AjaxEvents>
                                            <Click OnEvent="ToolbarButtonFindProblemTransactionClick">
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
                        <LoadMask ShowMask="true" />
                    </rx:GridPanel>
                </body>
            </Body>
        </rx:PanelX>


        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="800" AutoWidth="true"
            Border="false">
            <Body>
                <rx:GridPanel runat="server" ID="GrdReConciliation" Title="Upt Mutabakat Listesi" Height="700" AutoLoad="false"
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
                        <rx:RowSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server" ShowNumber="true"
                            SingleSelect="true">
                            <Listeners>
                                <RowDblClick Handler="ShowUptWindow(GrdReConciliation.selectedRecord.new_UptReference,GrdReConciliation.selectedRecord.BankTransactionNumber);" />
                            </Listeners>
                            <%--    <AjaxEvents>
                                <RowDblClick OnEvent="OpenPopWindow">
                                    <ExtraParams>
                                        <rx:Parameter Value="GrdReConciliation.selectedRecord.VALUE" Name="BankTransactionNumber" />
                                        <rx:Parameter Value="GrdReConciliation.selectedRecord.new_UptReference" Name="UptReference" />
                                    </ExtraParams>
                                </RowDblClick>
                            </AjaxEvents>--%>
                        </rx:RowSelectionModel>
                    </SelectionModel>
                    <BottomBar>
                        <rx:PagingToolBar runat="server" ID="PagingToolBar1" Enabled="true" ControlId="GrdReConciliation">
                            <Buttons>
                                <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload">
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
                    <LoadMask ShowMask="true" />
                </rx:GridPanel>

            </Body>



        </rx:PanelX>
    </form>
</body>
</html>
