<%@ Page Language="C#" AutoEventWireup="true" Inherits="IntegrationManuel_ManuelIntegration" Codebehind="ManuelIntegration.aspx.cs" %>


<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">  
<head id="Head1" runat="server">
    <title></title>
    <script src="JS/TransferFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:PanelX runat="server" ID="pnl1" Height="500" AutoWidth="true"
            Border="false" Title="SEARCH">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" AutoWidth="true" ColumnLayoutLabelWidth="40">
                    <Rows>
                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="30%" ColumnLayoutLabelWidth="20">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout1" runat="server">
                                            <Body>
                                                <cc1:CrmTextFieldComp runat="server" ID="TransferTuRef" ObjectId="201100072"
                                                    UniqueName="TransferTuRef" FieldLabelWidth="70" Width="230" PageSize="50">
                                                </cc1:CrmTextFieldComp>

                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="20%" ColumnLayoutLabelWidth="40">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout5" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Kontrol Et" ID="btnControl" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnControlClick"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="20%" ColumnLayoutLabelWidth="40">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout6" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Transfer Request" ID="btnRequestIntegration" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnRequestClick"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout13" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout2" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Transfer Confirm" ID="btnCheckIntegration" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnConfirmClick"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout30" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout31" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Kurumdan detay getir (Toplu)" ID="Button10" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnGetTotalDetail"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout12" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout7" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Payment Request" ID="Button1" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnPaymentRequestClick"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout11" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout8" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Payment Confirm" ID="Button2" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnPaymentConfirmClick"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout10" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout9" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Payment Cancel" ID="Button3" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnPaymentCancelClick"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout15" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout16" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Kurumdan Sorgula" ID="Button4" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnCheckCorporation"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout14" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout18" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Kurumdan İptal Et" ID="Button5" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnCancelCorporation"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                         <rx:RowLayout ID="RowLayout26" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout27" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Kurum Ödeme Confirm" ID="Button8" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnConfirmPaymentCorporation"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout19" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout20" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Ria ofis datası iste" ID="RiaLocation" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnGetLocationCatalogByFTP"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout23" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout22" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Ria Requirements datası iste" ID="Button6" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnGetRequirements"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                          <rx:RowLayout ID="RowLayout24" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout25" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Kurları iste" ID="Button7" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnGetRates"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout21" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                         <rx:RowLayout ID="RowLayout28" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Ria local Kurları iste" ID="Button9" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnGetLocalRates"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout29" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                          <rx:RowLayout ID="RowLayout32" runat="server">
                                            <Body>
                                                <rx:Button runat="server" Text="Sanal Iban Update" ID="Button11" Style="margin-left: 10px;">
                                                    <AjaxEvents>
                                                        <Click OnEvent="BtnVirtualIbanUpdate"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout33" runat="server">
                                            <Body>&nbsp;
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="20%" ColumnLayoutLabelWidth="40">
                                    <Rows>
                                    </Rows>
                                </rx:ColumnLayout>

                                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="20%" ColumnLayoutLabelWidth="40">
                                    <Rows>
                                    </Rows>
                                </rx:ColumnLayout>

                                <rx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="20%" ColumnLayoutLabelWidth="40">
                                    <Rows>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="20%" ColumnLayoutLabelWidth="40">
                                    <Rows>
                                    </Rows>
                                </rx:ColumnLayout>




                                <rx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="100%" ColumnLayoutLabelWidth="200">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout3" runat="server">
                                            <Body>
                                                <rx:GridPanel runat="server" ID="GrdTransfer" Title="Transfer" Height="100"
                                                    AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                                                    <SelectionModel>
                                                        <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                                                        </rx:RowSelectionModel>
                                                    </SelectionModel>
                                                    <ColumnModel>
                                                        <Columns>
                                                            <rx:GridColumns ColumnId="TuRef" Width="0" Header="Tu Referans no" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="VALUE" />
                                                            <rx:GridColumns ColumnId="FileTransactionNumber" Width="0" Header="Dosya Ref No" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="new_FileTransactionNumber" />
                                                            <rx:GridColumns ColumnId="ConfirmStatusName" Width="0" Header="Onay Durumu" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="new_ConfirmStatusName" />
                                                            <rx:GridColumns ColumnId="IntegrationStatus" Width="0" Header="Durum" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="IntegrationStatus" />
                                                            <rx:GridColumns ColumnId="IntegrationChannelName" Width="0" Header="Entegrasyon Kanalı" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="new_IntegrationChannelName" />
                                                            <rx:GridColumns ColumnId="CreatedOn" Width="0" Header="İşlem Tarihi" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="CreatedOn" />



                                                        </Columns>
                                                    </ColumnModel>
                                                </rx:GridPanel>
                                            </Body>
                                        </rx:RowLayout>

                                        <rx:RowLayout ID="RowLayout17" runat="server">
                                            <Body>
                                                <rx:GridPanel runat="server" ID="GridPanel1" Title="Kurum İşlemleri" Height="400"
                                                    AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                                                    <SelectionModel>
                                                        <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                                                        </rx:RowSelectionModel>
                                                    </SelectionModel>
                                                    <ColumnModel>
                                                        <Columns>
                                                            <rx:GridColumns ColumnId="TransferTuRef" Width="0" Header="Tu Referans no" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="TransferTuRef" />
                                                            <rx:GridColumns ColumnId="State" Width="0" Header="Durum" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="State" />     
                                                             <rx:GridColumns ColumnId="Kurum" Width="0" Header="Durum" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="Kurum" />    
                                                        </Columns>
                                                    </ColumnModel>
                                                </rx:GridPanel>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

            </Body>
        </rx:PanelX>
    </form>
    <p>
    </p>
</body>
</html>

