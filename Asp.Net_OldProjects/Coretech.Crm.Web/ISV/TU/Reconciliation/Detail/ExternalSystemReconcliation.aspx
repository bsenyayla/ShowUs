<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false"
    Inherits="Reconciliation.Detail.ExternalSystemReconcliation" Async="true" CodeBehind="ExternalSystemReconcliation.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" TagPrefix="cc1" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js" type="text/javascript"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="JS/_Corporation.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script type="text/javascript">

        function imgRendererDetail(record, rowIndex, colIndex, store) {
            if (record == 0) {
                return "<img style='width:16px;height:16px;' src='../../images/if_Remove_32542.png' />";
            }
            else if (record == 1) {
                return "<img style='width:16px;height:16px;' src='../../images/if_Add_32431.png' />";
            }
        }

        function setdata(data) {
            document.getElementById("cb").innerHTML = data;
        }


    </script>
</head>
<body>

    <form id="form1" runat="server">

        <rx:Hidden ID="hdnSelectedId" runat="server"></rx:Hidden>
        <rx:RegisterResources runat="server" ID="RR" />

        <rx:PanelX ID="pnl1" runat="server" Border="false" AutoHeight="Normal" Height="25" Padding="false" ContainerPadding="false">
            <Body>
                
                    <strong></i><b>Dikkat!</b></strong> Mutabakat işlemi bittiğinde <b>[Tamamla]</b> butonu ile işlemi tamamlayınız..
                
            </Body>
        </rx:PanelX>

        <rx:ToolBar ID="toolBar1" runat="server">
            <Items>
                <rx:Label ID="label1" runat="server" ImageUrl="../../images/if_extension_79880.png" ImageHeight="36" ImageWidth="36" Width="40">
                </rx:Label>
                <rx:ToolbarSeparator ID="ToolbarSeparator2" runat="server">
                </rx:ToolbarSeparator>

                <rx:Label ID="StartDate" Text="<b>İşlem Tarihi</b>" ForeColor="Black" runat="server"></rx:Label>
                <cc1:CrmDateFieldComp ID="new_StartDate" runat="server" ObjectId="201300006" FieldLabel="ddd"
                    UniqueName="new_StartDate" FieldLabelWidth="10" Width="100" RequirementLevel="BusinessRequired">
                </cc1:CrmDateFieldComp>
                <rx:ToolbarSeparator ID="ToolbarSeparator3" runat="server">
                </rx:ToolbarSeparator>
                <rx:ToolbarSeparator ID="ToolbarSeparator4" runat="server">
                </rx:ToolbarSeparator>
                <rx:Label ID="Label2" Text="<b>Mutabakat Kurumu</b>" ForeColor="Black" Width="120" runat="server"></rx:Label>
                <cc1:CrmComboComp runat="server" ID="new_OptionalCorporationId" ObjectId="201100072" LookupViewUniqueName="OPTIONAL_CORPORATION_VIEW"
                    UniqueName="new_OptionalCorporationId" FieldLabelWidth="10" Width="250" PageSize="50" RequirementLevel="BusinessRequired">
                    <DataContainer>
                        <DataSource OnEvent="new_OptionalCountryLoad"></DataSource>
                    </DataContainer>
                </cc1:CrmComboComp>

                <rx:ToolbarSeparator ID="sep1" runat="server">
                </rx:ToolbarSeparator>


                <rx:ToolbarButton ID="ToolbarButton4" runat="server" Icon="PlayBlue" Text="<b>Başlat</b>">
                    <AjaxEvents>

                        <Click OnEvent="RunReconcliation" Before="CrmValidateForm(msg,e);">
                            <EventMask Msg="Mutabakat Datası Hazırlanıyor..." />
                        </Click>
                    </AjaxEvents>
                </rx:ToolbarButton>
                <rx:ToolbarSeparator ID="ToolbarSeparator1" runat="server">
                </rx:ToolbarSeparator>

                <rx:ToolbarButton ID="ToolbarButton1" runat="server" Icon="Accept" Text="<b>Mutabakat Kapat</b>">
                    <AjaxEvents>

                        <Click OnEvent="RunReconcliationClose" Before="CrmValidateForm(msg,e);">
                        </Click>
                    </AjaxEvents>
                </rx:ToolbarButton>
            </Items>
        </rx:ToolBar>

        <rx:Window ID="messagePanel" runat="server" Width="600" Height="300" Modal="true"
            CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
            CloseAction="Hide" ShowOnLoad="false" Border="false"
            Title="&nbsp;&nbsp;Dış Sistem Mutabakat" ContainerPadding="true">
            <Body>
                <rx:PanelX ID="pnl" runat="server" Height="300" AutoHeight="Normal" Width="600">
                    <Body>
                        <rx:Label ID="lbl1" runat="server" Text="&nbsp;&nbsp;Seçilen gün için mutabakat daha önceden yapılmış. Devam etmek istiyor musunuz ?">
                        </rx:Label>
                        <rx:ColumnLayout ID="cl1" runat="server" ColumnWidth="%50">
                            <Rows>
                                <rx:RowLayout ID="rl1" runat="server">
                                    <Body>
                                        <rx:Button ID="BtnContinue" runat="server" Icon="ApplicationGo" Text="Devam Et">
                                            <AjaxEvents>
                                                <Click OnEvent="Continue">
                                                </Click>
                                            </AjaxEvents>
                                        </rx:Button>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <rx:ColumnLayout ID="ColumnLayout1" runat="server" ColumnWidth="%50">
                            <Rows>
                                <rx:RowLayout ID="RowLayout1" runat="server">
                                    <Body>
                                        <rx:Button ID="Button1" runat="server" Icon="Cancel" Text="Vazgeç">
                                            <Listeners>
                                                <Click Handler="messagePanel.hide();" />
                                            </Listeners>
                                        </rx:Button>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>

                    </Body>
                </rx:PanelX>
            </Body>
        </rx:Window>

        <rx:GridPanel runat="server" ID="gpReconclationData" AutoScroll="true"
            AutoWidth="true" AutoHeight="Auto" Collapsible="false" Mode="Local" AjaxPostable="true" Height="500">
            <DataContainer>
            </DataContainer>
            <ColumnModel>
                <Columns>
                    <rx:GridColumns ColumnId="ExternalSystemCashTransactionId" Width="100" Header="ISLEM ID" Sortable="false"
                        MenuDisabled="true" Hidden="true" DataIndex="ExternalSystemCashTransactionId" />

                    <rx:GridColumns ColumnId="RowNumber" Width="50" Header="<b>No</b>" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="RowNumber">
                    </rx:GridColumns>

                    <rx:GridColumns ColumnId="RecordId" Width="100" Header="Transfer Id" Sortable="false"
                        MenuDisabled="true" Hidden="true" DataIndex="RecordId" />

                    <rx:GridColumns ColumnId="TransferIdName" Width="150" Header="<b>Referans Numarası</b>" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="TransferIdName">
                    </rx:GridColumns>

                    <rx:GridColumns ColumnId="CreatedOn" Width="150" Header="<b>İşlem Tarihi (ZA)</b>" Sortable="false" Align="Left"
                        MenuDisabled="true" Hidden="false" DataIndex="CreatedOn">
                    </rx:GridColumns>

                    <rx:GridColumns ColumnId="TransactionTypeCode" Width="100" Header="<b>İşlem Tipi</b>" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="TransactionTypeCode" />

                    <rx:GridColumns ColumnId="CustomerAmountDirection" Width="50" Header="<b>Yön</b>" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="CustomerAmountDirection">
                        <Renderer Handler="return imgRendererDetail(record.data.CustomerAmountDirection);" />
                    </rx:GridColumns>

                    <rx:GridColumns ColumnId="CustomerAmount" Width="200" Header="<b>İşlem Tutarı 1</b>" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="CustomerAmount" />

                    <rx:GridColumns ColumnId="CustomerAmountCurrency" Width="50" Header="<b>İşlem Dövizi 1</b>" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="CustomerAmountCurrency" />

                    <rx:GridColumns ColumnId="ExternalCode1" Width="75" Header="<b>Kod 1</b>" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="ExternalCode1" />

                    <rx:GridColumns ColumnId="CustomerAmount2" Width="200" Header="<b>İşlem Tutarı 2</b>" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="CustomerAmount2" />

                    <rx:GridColumns ColumnId="CustomerAmount2Currency" Width="50" Header="<b>İşlem Dövizi 2</b>" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="CustomerAmount2Currency" />

                    <rx:GridColumns ColumnId="ExternalCode2" Width="75" Header="<b>Kod 2</b>" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="ExternalCode2" />

                    <rx:GridColumns ColumnId="MethodName" Width="250" Header="<b>Metod Adı</b>" Sortable="false" Align="Left"
                        MenuDisabled="true" Hidden="true" DataIndex="MethodName">
                    </rx:GridColumns>

                    <rx:GridColumns ColumnId="Comment" Width="250" Header="<b>Açıklama</b>" Sortable="false" Align="Left"
                        MenuDisabled="true" Hidden="true" DataIndex="Comment" Groupable="true">
                    </rx:GridColumns>

                    <rx:GridColumns ColumnId="Action" Width="55" Header="<b>...</b>" Sortable="false" Align="Center"
                        MenuDisabled="true" Hidden="false" DataIndex="Action" Groupable="true">
                        <Commands>
                            <rx:ImageCommand Icon="PlayGreen" Text="Çalıştır">
                                <AjaxEvents>
                                    <Click OnEvent="Process" Success="this.hide();">
                                    </Click>
                                </AjaxEvents>
                            </rx:ImageCommand>
                        </Commands>
                    </rx:GridColumns>
                    <rx:GridColumns ColumnId="Action" Width="55" Header="<b>...</b>" Sortable="false" Align="Center"
                        MenuDisabled="true" Hidden="false" DataIndex="Action" Groupable="true">
                        <Commands>
                            <rx:ImageCommand Icon="Delete" Text="Kaldır">
                                <AjaxEvents>
                                    <Click OnEvent="Delete" Before="return confirm('İşlem listeden kontrolünüz dahilinde kaldırılacak. Emin misniz ?');">
                                    </Click>
                                </AjaxEvents>
                            </rx:ImageCommand>
                        </Commands>
                    </rx:GridColumns>
                </Columns>
            </ColumnModel>
            <SpecialSettings>
                <rx:RowExpander Template="<div class='alert alert-danger'><strong></i><b>DETAY,</b></strong> {Comment}<br /> İşlemi düzeltmek için listeden <b>RUN</b> butonuna tıklayınız.<hr /></div>"
                    Collapsed="true" />
            </SpecialSettings>
            <SelectionModel>
                <rx:RowSelectionModel ID="GridPanelPaymentsRowSelectionModel1" runat="server" ShowNumber="true">
                    <Listeners>
                        <RowClick Handler="hdnSelectedId.clear();hdnSelectedId.setValue(gpReconclationData.selectedRecord.ID);"></RowClick>
                    </Listeners>
                    <%--                    <AjaxEvents>
                        <RowDblClick OnEvent="GetDataDetail">
                        </RowDblClick>
                    </AjaxEvents>--%>
                </rx:RowSelectionModel>
            </SelectionModel>

            <BottomBar>
                <rx:PagingToolBar ID="pagingToolBar" runat="server" ControlId="gpReconclationData">
                </rx:PagingToolBar>
            </BottomBar>

        </rx:GridPanel>



    </form>
    <script type="text/javascript">

    </script>
</body>

</html>
