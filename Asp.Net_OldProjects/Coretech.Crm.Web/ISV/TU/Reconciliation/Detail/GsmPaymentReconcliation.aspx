<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reconciliation.Detail.Reconciliation_GsmPaymentReconcliation" Codebehind="GsmPaymentReconcliation.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="JS/_Corporation.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
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
        <rx:Hidden ID="HdnChTransferId" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="HdnActionId" runat="server">
        </rx:Hidden>
        <rx:Label Icon="Button" runat="server" ID="hiddenLabel" Hidden="true">
        </rx:Label>
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
                <rx:ColumnLayout runat="server" ID="ColoumnLayout2" ColumnWidth="30%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="New_GsmEntegrationChannelId" ObjectId="201500028" LookupViewUniqueName="GsmEntegratorView"
                                    UniqueName="New_GsmEntegrationChannelId" FieldLabelWidth="100" Width="130" PageSize="50" RequirementLevel="BusinessRequired">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="500" AutoWidth="true"
            Border="false">
            <Body>
                <rx:GridPanel runat="server" ID="GrdReConciliation" Title="ReConciliation List" Height="400"
                    AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                    <DataContainer>
                    </DataContainer>
                    <ColumnModel>
                        <Columns>
                            <rx:GridColumns ColumnId="CHRECONCILIATIONOPERATIONHISTORYID" Width="0" Header="CHRECONCILIATIONOPERATIONHISTORYID"
                                Sortable="false" MenuDisabled="true" Hidden="true" DataIndex="TRANSFERID" />
                            <rx:GridColumns ColumnId="CorporationTransactionNumber" Width="0" Header="Kurum referans" Sortable="false"
                                MenuDisabled="true" Hidden="false" DataIndex="CorporationTransactionNumber" />
                            <rx:GridColumns ColumnId="TransactionReference" Width="0" Header="Upt Referans" Hidden="true" Sortable="false"
                                DataIndex="TransactionReference" MenuDisabled="true" />
                            <rx:GridColumns ColumnId="CorporationStatusDesc" Width="150" Header="Kurum Statü" Sortable="false"
                                MenuDisabled="true" DataIndex="CorporationStatusDesc">
                            </rx:GridColumns>

                        </Columns>
                    </ColumnModel>
                    <SelectionModel>
                        <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                        </rx:RowSelectionModel>
                    </SelectionModel>
                </rx:GridPanel>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="GetReConciliation" Text="(F9)" Icon="MagnifierZoomIn"
                    Width="200">
                    <AjaxEvents>
                        <Click OnEvent="GetReConciliationClick" Before="CrmValidateForm(msg,e);">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                <rx:Button runat="server" ID="BtnAction" Text="Action" Icon="MagnifierZoomIn" Width="200"
                    Hidden="true">
                    <AjaxEvents>
                        <Click OnEvent="BtnActionClick">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
    </form>
</body>
</html>
