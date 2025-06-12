<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reconciliation.Detail.Reconciliation_CorporationCommission" CodeBehind="_CorporationCommission.aspx.cs" %>

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
                                <cc1:CrmComboComp runat="server" ID="new_Corporation" ObjectId="201200010" LookupViewUniqueName="CorpComboView"
                                    UniqueName="new_Corporation" FieldLabelWidth="100" Width="130" PageSize="50" RequirementLevel="BusinessRequired">
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
                <rx:GridPanel runat="server" ID="GrdCorpComissionReport" Title="Kurum Komisyon" Height="400"
                    AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                    <DataContainer>
                    </DataContainer>
                    <ColumnModel>
                        <Columns>

                            <rx:GridColumns ColumnId="Referans" Width="150" Header="UPT Referans" Sortable="false"
                                MenuDisabled="true" DataIndex="Referans">
                            </rx:GridColumns>
                            <rx:GridColumns ColumnId="FileTransactionNumber" Width="150" Header="Dosya İşlem No" Sortable="false"
                                MenuDisabled="true" DataIndex="FileTransactionNumber">
                            </rx:GridColumns>
                            <rx:GridColumns ColumnId="islem" Width="150" Header="İşlem Tipi" Sortable="false"
                                MenuDisabled="true" DataIndex="islem">
                            </rx:GridColumns>
                            <rx:GridColumns ColumnId="Statü" Width="150" Header="Durum" Sortable="false"
                                MenuDisabled="true" DataIndex="Statü">
                            </rx:GridColumns>


                            <rx:GridColumns ColumnId="SendCorporation" Width="150" Header="Gönderen Kurum" Sortable="false"
                                MenuDisabled="true" DataIndex="SendCorporation">
                            </rx:GridColumns>
                            <rx:GridColumns ColumnId="CreatedOn" Width="80" Header="İşlem Tarihi" MenuDisabled="true"
                                Sortable="false" DataIndex="CreatedOn" />
                            <rx:GridColumns ColumnId="PaidCorporation" Width="150" Header="Ödeyen Kurum" Sortable="false"
                                MenuDisabled="true" DataIndex="PaidCorporation">
                            </rx:GridColumns>
                            <rx:GridColumns ColumnId="PaidDate" Width="150" Header="Ödeme Tarihi" Sortable="false"
                                MenuDisabled="true" DataIndex="PaidDate">
                            </rx:GridColumns>

                            <rx:GridColumns ColumnId="Tutar" Width="150" Header="Tutar"
                                Sortable="false" MenuDisabled="true" DataIndex="Tutar" />

                            <rx:GridColumns ColumnId="Doviz" Width="100" Header="Döviz"
                                Sortable="false" MenuDisabled="true" DataIndex="Doviz" />
                               <rx:GridColumns ColumnId="MastarTutar" Width="150" Header="Upt komisyon"
                                Sortable="false" MenuDisabled="true" DataIndex="MastarTutar" />

                            <rx:GridColumns ColumnId="MastarTutarDoviz" Width="100" Header="Upt Komisyon Dövizi"
                                Sortable="false" MenuDisabled="true" DataIndex="MastarTutarDoviz" />

                            <rx:GridColumns ColumnId="GonKomisyon" Width="100" Header="Gönderim Komisyon Tutar" Sortable="false"
                                MenuDisabled="true" Hidden="false" DataIndex="GonKomisyon" />

                            <rx:GridColumns ColumnId="GonKomisyonDoviz" Width="100" Header="Gönderim Komisyon Dövizi" Sortable="false"
                                MenuDisabled="true" Hidden="false" DataIndex="GonKomisyonDoviz" />

                            <rx:GridColumns ColumnId="OdemeKomisyon" Width="100" Header="Ödeme Komisyon Tutar" Sortable="false"
                                MenuDisabled="true" Hidden="false" DataIndex="OdemeKomisyon" />

                            <rx:GridColumns ColumnId="OdemeKomisyonDoviz" Width="100" Header="Ödeme Komisyon Dövizi" Sortable="false"
                                MenuDisabled="true" Hidden="false" DataIndex="OdemeKomisyonDoviz" />


                        </Columns>
                    </ColumnModel>
                    <SelectionModel>
                        <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                        </rx:RowSelectionModel>
                    </SelectionModel>
                     <BottomBar>
                            <rx:PagingToolBar runat="server" ID="PagingToolBar2" Enabled="true" ControlId="GrdCorpComissionReport">
                                <Buttons>
                                    <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload2">
                                        <AjaxEvents>
                                            <Click OnEvent="ToolbarButtonFind2Click">
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
            <Buttons>
                <rx:Button runat="server" ID="GetReConciliation" Text="Listele" Icon="MagnifierZoomIn"
                    Width="200">
                    <AjaxEvents>
                        <Click OnEvent="GetReConciliationClick" Before="CrmValidateForm(msg,e);">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
               <%-- <rx:Button runat="server" ID="btnExcel" Text="Excele Aktar" Icon="Attach"
                    Width="200">
                    <AjaxEvents>
                        <Click OnEvent="TransportExcelClick" Before="CrmValidateForm(msg,e);">
                        </Click>
                    </AjaxEvents>
                </rx:Button>--%>

            </Buttons>
        </rx:PanelX>
    </form>
</body>
</html>
