<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Report.aspx.cs" Inherits="Mobile_Report" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <rx:RegisterResources runat="server" ID="RR" />
            <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="50" AutoWidth="true"
                Border="false">
                <Body>
                    <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="25%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="RowLayout3">
                                <Body>
                                    <cc1:CrmComboComp runat="server" ID="new_CorporationId" ObjectId="201100097" UniqueName="new_CorporationId"
                                        FieldLabelWidth="100" Width="130" PageSize="50" RequirementLevel="BusinessRequired">
                                    </cc1:CrmComboComp>
                                </Body>
                            </rx:RowLayout>
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
                            <rx:RowLayout runat="server" ID="RowLayout4">
                                <Body>
                                    <cc1:CrmComboComp runat="server" ID="new_OfficeId" ObjectId="201100097" UniqueName="new_OfficeId"
                                        FieldLabelWidth="100" Width="130" PageSize="50">
                                        <Filters>
                                            <cc1:ComboFilter FromObjectId="201100097" FromUniqueName="new_CorporationId" ToObjectId="201100040"
                                                ToUniqueName="new_CorporationID" />
                                        </Filters>
                                    </cc1:CrmComboComp>
                                </Body>
                            </rx:RowLayout>
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

                                    <rx:ComboField runat="server" ID="OperationType" FieldLabel="Operasyon Tipi" EmptyText="Tümü">
                                        <Items>
                                            <rx:ListItem Text="Tümü" Value="-1" />
                                            <rx:ListItem Text="Gonderim" Value="1" />
                                            <rx:ListItem Text="Ödeme" Value="2" />
                                        </Items>
                                    </rx:ComboField>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout5">
                                <Body>
                                    <rx:RadioGroup runat="server" ID="IsDocument" FieldLabel="Döküman" EmptyText="Tümü" ToolTip="Toplamlar raporunda dikkate alınmaz.">
                                        <Items>
                                            <rx:RadioColumn Text="Tümü" Value="-1" Checked="true" />
                                            <rx:RadioColumn Text="Var" Value="1" />
                                            <rx:RadioColumn Text="Yok" Value="0" />
                                        </Items>
                                    </rx:RadioGroup>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout runat="server" ID="ColumnLayout15" ColumnWidth="7%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="RowLayout16">
                                <Body>
                                    <rx:Button runat="server" ID="BtnFilter" FieldLabel="Filtrele" Text="Döküman Analizi" Icon="ZoomIn">
                                        <AjaxEvents>
                                            <Click OnEvent="OperationType_Fill" Before="return CrmValidateForm(msg,e);">
                                            </Click>
                                        </AjaxEvents>
                                    </rx:Button>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="12%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="RowLayout6">
                                <Body>
                                    <rx:Button runat="server" ID="Button1" FieldLabel="Filtrele" Text="Döküman Analizi Toplamlar" Icon="ZoomIn">
                                        <AjaxEvents>
                                            <Click OnEvent="MobileDocumentReport_Fill" Before="return CrmValidateForm(msg,e);">
                                            </Click>
                                        </AjaxEvents>
                                    </rx:Button>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                </Body>
            </rx:PanelX>
            <rx:PanelX runat="server" ID="PanelX2" AutoHeight="Normal" Height="400" AutoWidth="true"
                Border="false">
                <Body>
                    <body>
                        <rx:GridPanel runat="server" ID="GrdTotalCount" Title="Döküman Analizi" Height="330"
                            AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                            <DataContainer>
                            </DataContainer>
                            <ColumnModel>
                                <Columns>

                                    <rx:GridColumns ColumnId="OfficeName" Width="250" Header="Ofis" Sortable="false"
                                        MenuDisabled="true" DataIndex="OfficeName">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="TransactionDate" Width="150" Header="İşlem Tarihi" Sortable="false"
                                        MenuDisabled="true" DataIndex="TransactionDate">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="OperationType" Width="100" Header="Operasyon Tipi" Sortable="false"
                                        MenuDisabled="true" DataIndex="OperationType">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="Reference" Width="100" Header="Referans" Sortable="false"
                                        MenuDisabled="true" DataIndex="Reference">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="Document" Width="100" Header="Döküman Durumu" Sortable="false"
                                        MenuDisabled="true" DataIndex="Document" ColumnType="Check">
                                    </rx:GridColumns>

                                </Columns>
                            </ColumnModel>
                            <SelectionModel>
                                <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                                </rx:RowSelectionModel>
                            </SelectionModel>
                            <BottomBar>
                                <rx:PagingToolBar ID="PagingToolBar1" ControlId="GrdTotalCount" runat="server">
                                    <Buttons>
                                        <rx:SmallButton ID="ExportExcel1" Download="true" Text="Excel'e Gönder" Icon="PageExcel">
                                            <AjaxEvents>
                                                <Click OnEvent="ExportExcelReport1" Before="alert('Dikkat! Excel Export belirtilen en son filtreleri dikkate alır.')">
                                                </Click>
                                            </AjaxEvents>
                                        </rx:SmallButton>
                                    </Buttons>
                                </rx:PagingToolBar>
                            </BottomBar>
                        </rx:GridPanel>
                    </body>
                </Body>
            </rx:PanelX>
            <rx:PanelX runat="server" ID="PanelX4" AutoHeight="Normal" Height="420" AutoWidth="true"
                Border="false">
                <Body>
                    <body>
                        <rx:GridPanel runat="server" ID="GridPanel1" Title="Döküman Analizi Toplamlar" Height="350"
                            AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                            <DataContainer>
                            </DataContainer>
                            <ColumnModel>
                                <Columns>

                                    <rx:GridColumns ColumnId="OfficeName" Width="250" Header="Ofis" Sortable="false"
                                        MenuDisabled="true" DataIndex="OfficeName">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="TransactionDate" Width="150" Header="İşlem Tarihi" Sortable="false"
                                        MenuDisabled="true" DataIndex="TransactionDate">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="OperationType" Width="100" Header="Operasyon Tipi" Sortable="false"
                                        MenuDisabled="true" DataIndex="OperationType">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="TransactionCount" Width="100" Header="İşlem Sayısı" Sortable="false"
                                        MenuDisabled="true" DataIndex="TransactionCount" ColumnType="Normal">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="DocumentCount" Width="100" Header="Döküman Sayısı" Sortable="false"
                                        MenuDisabled="true" DataIndex="DocumentCount" ColumnType="Normal">
                                    </rx:GridColumns>

                                </Columns>
                            </ColumnModel>
                            <SelectionModel>
                                <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                                </rx:RowSelectionModel>

                            </SelectionModel>
                            <BottomBar>
                                <rx:PagingToolBar ID="PagingToolBar2" ControlId="GridPanel1" runat="server">
                                    <Buttons>
                                        <rx:SmallButton ID="ExportExcel2" Download="true" Text="Excel'e Gönder" Icon="PageExcel">
                                            <AjaxEvents>
                                                <Click OnEvent="ExportExcelReport2" Before="alert('Dikkat! Excel Export belirtilen en son filtreleri dikkate alır.')">
                                                </Click>
                                            </AjaxEvents>
                                        </rx:SmallButton>
                                    </Buttons>
                                </rx:PagingToolBar>
                            </BottomBar>

                        </rx:GridPanel>
                    </body>
                </Body>
            </rx:PanelX>
        </div>
    </form>
</body>
</html>
