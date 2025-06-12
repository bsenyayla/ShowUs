<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reconciliation.Detail.Reconciliation_Detail_CorpCommissionReconcliation" ValidateRequest="false" CodeBehind="CorpCommissionReconcliation.aspx.cs" %>

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

        <rx:PanelX runat="server" ID="PanelSave" AutoHeight="Normal" Height="80" AutoWidth="true"
            Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="25%">
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
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="25%">
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
                <rx:ColumnLayout runat="server" ID="ColoumnLayout2" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_IntegrationChannelId" ObjectId="201300006" LookupViewUniqueName="IntegrationChannelComboView"
                                    UniqueName="new_IntegrationChannelId" FieldLabelWidth="100" Width="130" PageSize="50" RequirementLevel="BusinessRequired">
                                    <DataContainer>
                                        <DataSource OnEvent="new_IntegrationChannelLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="25%">
                    <Rows>

                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <rx:FileUpload ID="upload1" runat="server" FieldLabel="Dosya" RequirementLevel="BusinessRequired"></rx:FileUpload>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <rx:Button runat="server" ID="btnSave" Text="Mutabakat Dosyası Kaydet" Icon="Accept" Width="200">
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

        <rx:PanelX runat="server" ID="PanelXShow" AutoHeight="Normal" Height="80" AutoWidth="true"
            Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>
                                <cc1:CrmTextFieldComp ID="TuReferans" runat="server" ObjectId="201600016"
                                    UniqueName="TuReferans" FieldLabelWidth="110" Width="100" RequirementLevel="None">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_CorpReference" runat="server" ObjectId="201600016"
                                    UniqueName="new_CorpReference" FieldLabelWidth="110" Width="100" RequirementLevel="None">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout8">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_ReconciliationResult" ObjectId="201600016"
                                    UniqueName="new_ReconciliationResult" FieldLabelWidth="100" Width="130" PageSize="50" RequirementLevel="None">
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout11">
                            <Body>
                                <rx:Button runat="server" ID="btnShow" Text="Mutabakat Göster" Icon="Application" Width="200">
                                    <AjaxEvents>
                                        <Click OnEvent="ShowReConciliation">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>


        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="800" AutoWidth="true"
            Border="false">
            <Body>
                <rx:GridPanel runat="server" ID="GrdCorpReconciliation" Title="Kurum Komisyon Mutabakat Listesi" Height="700" AutoLoad="false"
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
                            <%-- <Listeners>
                                <RowDblClick Handler="ShowUptWindow(GrdReConciliation.selectedRecord.new_UptReference,GrdReConciliation.selectedRecord.BankTransactionNumber);" />
                            </Listeners>--%>
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
                        <rx:PagingToolBar runat="server" ID="PagingToolBar1" Enabled="true" ControlId="GrdCorpReconciliation">
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
