<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reconciliation.Detail.Reconciliation_Corporation" ValidateRequest="false" CodeBehind="_Corporation.aspx.cs" %>

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
                            <rx:GridColumns ColumnId="TRANSFERID" Width="0" Header="TRANSFERID" Sortable="false"
                                MenuDisabled="true" Hidden="true" DataIndex="TRANSFERID" />
                            <rx:GridColumns ColumnId="PAYMENTID" Width="0" Header="PAYMENTID" Sortable="false"
                                MenuDisabled="true" Hidden="true" DataIndex="PAYMENTID" />
                            <rx:GridColumns ColumnId="REFUNDPAYMENTID" Width="0" Header="REFUNDPAYMENTID" Sortable="false"
                                MenuDisabled="true" Hidden="true" DataIndex="REFUNDPAYMENTID" />
                            <rx:GridColumns ColumnId="PROCESSID" Width="0" Header="Servis" Hidden="true" Sortable="false"
                                DataIndex="PROCESSID" MenuDisabled="true" />
                            <rx:GridColumns ColumnId="TRANSFER_TU_REF" Width="150" Header="UPT Referans" Sortable="false"
                                MenuDisabled="true" DataIndex="TRANSFER_TU_REF">
                                <Renderer Handler="return ActionTemplate(record.data.TRANSFERID,record.data.PROCESSID,record.data.TRANSFER_TU_REF,record.data.TU_STATUS_CODE)" />
                                <%-- <Commands>
                                <rx:ImageCommand Icon="Button">
                                    <AjaxEvents>
                                        <Click OnEvent="Process">
                                        </Click>
                                    </AjaxEvents>
                                </rx:ImageCommand>
                            </Commands>--%>
                            </rx:GridColumns>
                            <rx:GridColumns ColumnId="ISLEM_TARIHI" Width="80" Header="İşlem Tarihi" MenuDisabled="true"
                                Sortable="false" DataIndex="ISLEM_TARIHI" />
                            <rx:GridColumns ColumnId="TU_TARGETTRANSTYPE_NAME" Width="150" Header="Gönderim Türü"
                                Sortable="false" MenuDisabled="true" DataIndex="TU_TARGETTRANSTYPE_NAME" />
                            <rx:GridColumns ColumnId="PARTNER_ISLEM_NO" Width="100" Header="Kurum İşlem Numarası"
                                Sortable="false" MenuDisabled="true" DataIndex="PARTNER_ISLEM_NO" />
                            <%--<rx:GridColumns ColumnId="TU_REF" Width="80" Header="TU_REF" Sortable="false" Hidden="false"
                            MenuDisabled="true" DataIndex="TU_REF" />--%>
                            <rx:GridColumns ColumnId="ISLEM_TIPI" Width="100" Header="İşlem Tipi" Sortable="false"
                                MenuDisabled="true" Hidden="false" DataIndex="ISLEM_TIPI" />
                            <rx:GridColumns ColumnId="TU_STATUS" Width="100" Header="Upt Status" Sortable="false"
                                MenuDisabled="true" Hidden="false" DataIndex="TU_STATUS" />

                            <rx:GridColumns ColumnId="PARTNER_ACTION" Width="300" Header="Kurum Aksiyon" Sortable="false"
                                MenuDisabled="true" DataIndex="PARTNER_ACTION" />
                            <rx:GridColumns ColumnId="PARTNER_STATUS" Width="200" Header="Kurum Status" Sortable="false"
                                MenuDisabled="true" DataIndex="PARTNER_STATUS" />
                            <rx:GridColumns ColumnId="PARTNER_TUTAR" Width="150" Header="Kurum Tutar" Sortable="false"
                                MenuDisabled="true" DataIndex="PARTNER_TUTAR" Align="Right" />
                            <rx:GridColumns ColumnId="PARTNER_DOVIZ" Width="100" Header="Kurum Döviz" Sortable="false"
                                MenuDisabled="true" DataIndex="PARTNER_DOVIZ" />
                            <rx:GridColumns ColumnId="TU_TUTAR" Width="150" Header="UPT Tutar" Sortable="false"
                                MenuDisabled="true" DataIndex="TU_TUTAR" />
                            <rx:GridColumns ColumnId="TU_DOVIZ" Width="100" Header="UPT Döviz" Sortable="false"
                                MenuDisabled="true" DataIndex="TU_DOVIZ">
                            </rx:GridColumns>
                            <rx:GridColumns ColumnId="TU_MASRAF_TUTAR" Width="150" Header="UPT Masraf Tutar"
                                Sortable="false" MenuDisabled="true" DataIndex="TU_MASRAF_TUTAR">
                            </rx:GridColumns>
                            <rx:GridColumns ColumnId="TU_MASRAF_DOVIZ" Width="100" Header="UPT Masraf Döviz"
                                Sortable="false" MenuDisabled="true" DataIndex="TU_MASRAF_DOVIZ">
                            </rx:GridColumns>
                            <rx:GridColumns ColumnId="TU_KURUM" Width="200" Header="UPT Kurum" Sortable="false"
                                MenuDisabled="true" DataIndex="TU_KURUM">
                            </rx:GridColumns>
                            <rx:GridColumns ColumnId="TU_OFIS" Width="200" Header="UPT Ofis" Sortable="false"
                                MenuDisabled="true" DataIndex="TU_OFIS">
                            </rx:GridColumns>
                            <rx:GridColumns ColumnId="TU_GISECI" Width="200" Header="UPT Gişeci" Sortable="false"
                                MenuDisabled="true" DataIndex="TU_GISECI">
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
                <rx:Button runat="server" ID="btnGetBatchReconciliation" Text="(F9)" Icon="MagnifierZoomIn"
                    Width="200">
                    <AjaxEvents>
                        <Click OnEvent="GetBatchData" Before="CrmValidateForm(msg,e);">
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
