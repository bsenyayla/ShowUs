<%@ Page Language="C#" AutoEventWireup="true" Inherits="GsmWaybill_GsmPayment" ValidateRequest="false" Async="true" CodeBehind="GsmPayment.aspx.cs" %>


<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <%--<script  type="text/javascript" src="../../../js/Global.js"></script>--%>
    <%-- <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>--%>
    <%--<script src="JS/TransferFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>--%>
    <script type="text/javascript" src="Js/GsmPayment.js"></script>


</head>
<body>
    <form id="form1" runat="server">

        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="New_GsmPaymentId" runat="server" />
        <rx:Hidden ID="CorporationReference" runat="server" />
        <rx:Hidden ID="GsmTransactionReference" runat="server" />
        <rx:Hidden ID="GsmIntegratorCode" runat="server" />
        <rx:Hidden ID="hdnReportId" runat="server" />
        <rx:Hidden ID="hdnRecid" runat="server" />

        <rx:Hidden ID="ReceivedOptionEurAmount" runat="server" />
        <rx:Hidden ID="ReceivedOptionUsdAmount" runat="server" />

        <rx:Hidden ID="ReceivedExpenseOptionEurAmount" runat="server" />
        <rx:Hidden ID="ReceivedExpenseOptionUsdAmount" runat="server" />
        <rx:Hidden ID="ReceivedExpenseOptionTryAmount" runat="server" />


        <rx:Hidden ID="SelectedCollectionOption" runat="server" />
        <rx:PanelX runat="server" ID="PanelIframe" AutoHeight="Normal" Height="1" Border="false"
            Frame="true">
            <AutoLoad Url="about:blank" ShowMask="true" />
            <Body>
            </Body>
        </rx:PanelX>

        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Auto"
            Border="false" Title="Gsm Kontör Yükleme">
            <Body>

                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="100%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout99">
                            <Body>


                                <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="40%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout9">
                                            <Body>&nbsp;
                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout7">
                                            <Body>
                                                <cc1:CrmComboComp runat="server" ID="new_GsmCountryId" ObjectId="201500026"
                                                    RequirementLevel="BusinessRequired" UniqueName="new_GsmCountryId" Width="200"
                                                    LookupViewUniqueName="GsmCountryComboView" PageSize="50" FieldLabel="200" Mode="Remote">
                                                    <DataContainer>
                                                        <DataSource OnEvent="new_GsmCountryIdLoad">
                                                        </DataSource>
                                                    </DataContainer>
                                                    <AjaxEvents>
                                                        <Change OnEvent="new_GsmCountryIdChangeOnEvent">
                                                        </Change>
                                                    </AjaxEvents>

                                                </cc1:CrmComboComp>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout4">
                                            <Body>&nbsp;
                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout2">
                                            <Body>
                                                <cc1:CrmComboComp runat="server" ID="new_GsmOperatorId" ObjectId="201500026"
                                                    RequirementLevel="BusinessRequired" UniqueName="new_GsmOperatorId" Width="200"
                                                    LookupViewUniqueName="OperatorComboView" PageSize="50" FieldLabel="200">
                                                    <Filters>
                                                        <cc1:ComboFilter FromObjectId="201500026" FromUniqueName="new_GsmCountryId" ToObjectId="201500027"
                                                            ToUniqueName="new_GsmCountryId" />
                                                    </Filters>
                                                    <AjaxEvents>
                                                        <Change OnEvent="new_GsmOperatorIdChangeOnEvent">
                                                        </Change>
                                                    </AjaxEvents>
                                                </cc1:CrmComboComp>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout11">
                                            <Body>&nbsp;
                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout10">
                                            <Body>

                                                <cc1:CrmComboComp runat="server" ID="new_SenderId" ObjectId="201500026" UniqueName="new_SenderId"
                                                    RequirementLevel="BusinessRequired" Disabled="true" Width="150" PageSize="50"
                                                    FieldLabel="150">
                                                </cc1:CrmComboComp>
                                            </Body>
                                        </rx:RowLayout>




                                        <rx:RowLayout runat="server" ID="RowLayout12">
                                            <Body>&nbsp;
                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout13">
                                            <Body>

                                                <cc1:CrmTextFieldComp runat="server" ID="new_PackageName" ObjectId="201500026" UniqueName="new_PackageName"
                                                    Disabled="true" Width="150" PageSize="50"
                                                    FieldLabel="150">
                                                </cc1:CrmTextFieldComp>
                                            </Body>
                                        </rx:RowLayout>

                                        <rx:RowLayout runat="server" ID="RowLayout16">
                                            <Body>&nbsp;
                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout17">
                                            <Body>

                                                <cc1:CrmMoneyComp runat="server" ID="new_PackageAmountH" ObjectId="201500026" UniqueName="new_PackageAmount"
                                                    Disabled="true" Width="150" PageSize="50"
                                                    FieldLabel="150">
                                                </cc1:CrmMoneyComp>
                                            </Body>
                                        </rx:RowLayout>



                                        <rx:RowLayout runat="server" ID="RowLayout18">
                                            <Body>&nbsp;
                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout19">
                                            <Body>

                                                <cc1:CrmMoneyComp runat="server" ID="new_ExpenseAmountH" ObjectId="201500026" UniqueName="new_ExpenseAmount"
                                                    Disabled="true" Width="150" PageSize="50"
                                                    FieldLabel="150">
                                                </cc1:CrmMoneyComp>
                                            </Body>
                                        </rx:RowLayout>

                                        <rx:RowLayout runat="server" ID="RowLayout5">
                                            <Body>&nbsp;
                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout3">
                                            <Body>
                                                <cc1:CrmPhoneFieldComp runat="server" ID="new_GsmNumber" ObjectId="201500026"
                                                    UniqueName="new_GsmNumber" RequirementLevel="BusinessRequired" FieldLabel="200"
                                                    HiddenCountryCode="false">
                                                </cc1:CrmPhoneFieldComp>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout8">
                                            <Body>&nbsp;
                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout6">
                                            <Body>
                                                <rx:Button runat="server" ID="btnGetPackages" Icon="Money" Text="Paketler"
                                                    Width="150" Visible="true">
                                                    <AjaxEvents>
                                                        <Click OnEvent="btnGetPackages_Click">
                                                        </Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>

                                        <rx:RowLayout runat="server" ID="RowLayout14">
                                            <Body>&nbsp;
                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout15">
                                            <Body>
                                                <rx:Button runat="server" ID="btnGetReconcliationData" Icon="Money" Text="Kurum Detay Getir"
                                                    Width="150" Visible="true">
                                                    <AjaxEvents>
                                                        <Click OnEvent="btnGetReconcliationData_Click">
                                                        </Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout22">
                                            <Body>   &nbsp;</Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout20">
                                            <Body>
                                                <rx:Button runat="server" ID="btnCancel" Icon="Cancel" Text="İptal"
                                                    Width="150" Visible="true">
                                                    <AjaxEvents>
                                                        <Click OnEvent="btnCancel_Click" Before="return checkStatus();">
                                                            <EventMask ShowMask="true" Msg="Confirming..." />
                                                        </Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout21">
                                            <Body>
                                                <rx:Button runat="server" ID="btnConfirm" Icon="Accept" Text="Onayla"
                                                    Width="150" Visible="true">
                                                    <AjaxEvents>
                                                        <Click OnEvent="btnConfirm_Click" Before="return checkConfirmStatus();">
                                                            <EventMask ShowMask="true" Msg="Confirming..." />
                                                        </Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout25">
                                            <Body>   &nbsp;</Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout26">
                                            <Body>
                                                <rx:Button runat="server" ID="btnReject" Icon="ArrowUndo" Text="Reddet"
                                                    Width="150" Visible="true">
                                                    <AjaxEvents>
                                                        <Click OnEvent="btnReject_Click">
                                                            <EventMask ShowMask="true" Msg="Cancelling..." />
                                                        </Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>



                                        <rx:RowLayout runat="server" ID="RowLayout24">
                                            <Body>   &nbsp;</Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout23">
                                            <Body>
                                                <rx:Button runat="server" ID="btnPrint" Icon="Printer" Text="Dekont Bas"
                                                    Width="150" Visible="true">
                                                    <AjaxEvents>
                                                        <Click OnEvent="btnPrint_Click">
                                                            <EventMask ShowMask="true" Msg="Printing..." />
                                                        </Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="60%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout1">
                                            <Body>
                                                <rx:GridPanel runat="server" ID="GrdPackages" Title="Paket Listesi" Height="400"
                                                    AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Local" AjaxPostable="true">
                                                    <DataContainer>
                                                    </DataContainer>
                                                    <ColumnModel>
                                                        <Columns>
                                                            <rx:GridColumns ColumnId="PackageId" Width="0" Header="PackageId"
                                                                Sortable="false" MenuDisabled="true" Hidden="true" DataIndex="PackageId" />
                                                            <rx:GridColumns ColumnId="Name" Width="150" Header="Paket Adı" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="Name" />
                                                            <rx:GridColumns ColumnId="Code" Width="100" Header="Paket Kodu" Sortable="false"
                                                                MenuDisabled="true" Hidden="true" DataIndex="Code" />
                                                            <rx:GridColumns ColumnId="LocalPriceStr" Width="150" Header="Yerel Paket Tutarı" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="LocalPriceStr" />
                                                            <rx:GridColumns ColumnId="Price" Width="150" Header="Paket Tutarı" Sortable="false"
                                                                MenuDisabled="true" Hidden="true" DataIndex="Price" />
                                                            <rx:GridColumns ColumnId="WholeSalePrice" Width="150" Header="Toptan Fiyat" Sortable="false"
                                                                MenuDisabled="true" Hidden="true" DataIndex="Price" />
                                                            <rx:GridColumns ColumnId="PriceStr" Width="150" Header="Paket Tutarı" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="PriceStr" />
                                                            <rx:GridColumns ColumnId="ExpenseAmount" Width="150" Header="Masraf Tutarı" Sortable="false"
                                                                MenuDisabled="true" Hidden="true" DataIndex="ExpenseAmount" />
                                                            <rx:GridColumns ColumnId="ExpenseStr" Width="150" Header="Masraf Tutarı" Sortable="false"
                                                                MenuDisabled="true" Hidden="false" DataIndex="ExpenseStr" />
                                                            <rx:GridColumns ColumnId="ExParam1" Width="0" Header="OBJECT"
                                                                Sortable="false" MenuDisabled="true" Hidden="true" DataIndex="ExParam1" />
                                                            <rx:GridColumns ColumnId="ExParam2" Width="0" Header="Yukleme_Fiyat"
                                                                Sortable="false" MenuDisabled="true" Hidden="true" DataIndex="ExParam2" />

                                                            <rx:GridColumns ColumnId="Load" Width="50" Header="Yükle" Sortable="false"
                                                                MenuDisabled="true" DataIndex="Load">
                                                                <Commands>
                                                                    <rx:ImageCommand Icon="Add">
                                                                        <AjaxEvents>
                                                                            <Click OnEvent="LoadPackage">
                                                                            </Click>
                                                                        </AjaxEvents>
                                                                    </rx:ImageCommand>
                                                                </Commands>
                                                            </rx:GridColumns>
                                                        </Columns>
                                                    </ColumnModel>
                                                    <SelectionModel>
                                                        <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                                                        </rx:RowSelectionModel>
                                                    </SelectionModel>
                                                </rx:GridPanel>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="asdas" runat="server">
                            <Body>

                                <rx:PanelX runat="server" ID="Panel_SenderInformation" Height="300" AutoWidth="true"
                                    Title="Gönderici Bilgileri" Collapsed="false" Collapsible="true"
                                    Border="false">
                                    <AutoLoad Url="about:blank" />
                                    <Body>
                                    </Body>
                                </rx:PanelX>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <%-- <rx:ToolBar runat="server" ID="ToolBar3">
                    <Items>
                        <rx:ToolbarFill runat="server" ID="ToolbarFill3">
                        </rx:ToolbarFill>
                        <rx:ToolbarButton runat="server" ID="btnConfirm" Text="Onayla" Icon="Accept"
                            Width="100">
                            <AjaxEvents>
                                <Click OnEvent="btnConfirm_Click" Before="return checkConfirmStatus();">
                                    <EventMask ShowMask="true" Msg="Confirming..." />
                                </Click>
                            </AjaxEvents>
                        </rx:ToolbarButton>
                    </Items>
                </rx:ToolBar>--%>
            </Body>
        </rx:PanelX>
        <rx:ToolBar runat="server" ID="ToolBarMain">
            <Items>
                <rx:ToolbarFill runat="server" ID="tf1" />
                <rx:ToolbarButton runat="server" ID="ToolbarButtonMd" Text="CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING_DETAIL"
                    Icon="ControlBlank" Width="100">
                    <Listeners>
                        <Click Handler="ShowGsmPaymentHistory();" />
                    </Listeners>
                </rx:ToolbarButton>
            </Items>
        </rx:ToolBar>
    </form>
    <rx:Window ID="gsmTransactiomnDetail" runat="server" Width="1000" Height="500" Modal="true"
        Border="false" Closable="true" Maximizable="false" Resizable="true" CloseAction="Hide"
        ShowOnLoad="false" Title="Yükleme Ekranı">
        <Body>
            <rx:Fieldset runat="server" ID="Fieldset1" AutoHeight="Normal" Height="200" AutoWidth="true"
                Collapsed="false" Collapsible="false" Border="false" CustomCss="Section3" Title="Paket Bilgileri">
                <Body>
                    <table>
                        <%-- <tr>
                            <td style="height: 20px" colspan="3">&nbsp;</td>
                        </tr>--%>
                        <tr>
                            <td>
                                <rx:TextField runat="server" ID="txtPackageName" FieldLabel="Paket Adı:" Disabled="true" Width="200"></rx:TextField>
                            </td>
                            <td style="width: 100px;">&nbsp;</td>
                            <td>
                                <cc1:CrmMoneyComp runat="server" ID="new_PackageAmount" UniqueName="new_PackageAmount" ObjectId="201500026" Disabled="true">
                                </cc1:CrmMoneyComp>

                            </td>
                        </tr>
                        <tr>
                            <td>
                                <cc1:CrmTextFieldComp runat="server" ID="new_GsmNumberW" ObjectId="201500026" UniqueName="new_GsmNumber" FieldLabel="200" Width="200" Disabled="true">
                                </cc1:CrmTextFieldComp>


                            </td>
                            <td></td>
                            <td>
                                <cc1:CrmMoneyComp runat="server" ID="new_ExpenseAmount" UniqueName="new_ExpenseAmount" ObjectId="201500026" Disabled="true">
                                </cc1:CrmMoneyComp>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <cc1:CrmComboComp runat="server" ID="new_GsmOperatorIdW" ObjectId="201500026" UniqueName="new_GsmOperatorId" Width="200"
                                    LookupViewUniqueName="OperatorComboView" Disabled="true" PageSize="50" FieldLabel="200">
                                </cc1:CrmComboComp>
                            </td>
                            <td></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td colspan="3">&nbsp;</td>
                        </tr>
                        <tr>
                            <td colspan="3">&nbsp;</td>
                        </tr>
                    </table>
                </Body>
            </rx:Fieldset>
            <rx:Fieldset runat="server" ID="PanelX4" AutoHeight="Normal" Height="200" AutoWidth="true"
                Collapsed="false" Collapsible="false" Border="false" CustomCss="Section3" Title="Tahsilat Bilgileri">
                <Body>
                    <table>
                        <tr>
                            <td style="width: 30px">

                                <input type="radio" id="RadioEur" name="rdg1" onclick="ShowHideRadio(this.id)" /></td>
                            <td style="width: 280px">
                                <cc1:CrmMoneyComp runat="server" ID="ReceivedOptionEur_1" UniqueName="new_ReceivedAmount1" ObjectId="201500026">
                                    <DecimalChange OnEvent="ReceivedOptionEur_OnChange">
                                    </DecimalChange>
                                </cc1:CrmMoneyComp>
                            </td>
                            <td style="width: 180px">
                                <rx:NumericField Disabled="true" runat="server" ID="NumEurParity1" FieldLabel="Parite:" Mode="Decimal" DecimalPrecision="6" DecimalSeparator="," FieldLabelWidth="60" Width="80"></rx:NumericField>
                                <rx:NumericField Hidden="true" runat="server" ID="NumEurOriginalParity1" FieldLabel="Parite:" Mode="Decimal" DecimalPrecision="6" DecimalSeparator="," FieldLabelWidth="60" Width="80"></rx:NumericField>

                            </td>
                            <td style="width: 260px">
                                <cc1:CrmMoneyComp runat="server" ID="ReceivedOptionEur_2" UniqueName="new_ReceivedAmount2" ObjectId="201500026" Disabled="true">
                                </cc1:CrmMoneyComp>
                            </td>
                            <td style="width: 150px">
                                <rx:NumericField Disabled="true" runat="server" ID="NumEurParity2" FieldLabel="Parite:" Mode="Decimal" DecimalPrecision="6" DecimalSeparator="," FieldLabelWidth="60" Width="80"></rx:NumericField>
                                <rx:NumericField Hidden="true" runat="server" ID="NumEurOriginalParity2" FieldLabel="Parite:" Mode="Decimal" DecimalPrecision="6" DecimalSeparator="," FieldLabelWidth="60" Width="80"></rx:NumericField>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <input type="radio" id="RadioUsd" name="rdg1" onclick="ShowHideRadio(this.id)" /></td>
                            <td>
                                <cc1:CrmMoneyComp runat="server" ID="ReceivedOptionUsd_1" UniqueName="new_ReceivedAmount1" ObjectId="201500026">
                                    <DecimalChange OnEvent="ReceivedOptionUsd_OnChange">
                                    </DecimalChange>
                                </cc1:CrmMoneyComp>
                            </td>
                            <td>
                                <rx:NumericField Disabled="true" runat="server" ID="NumUsdParity1" FieldLabel="Parite:" Mode="Decimal" DecimalPrecision="6" DecimalSeparator="," FieldLabelWidth="60" Width="80"></rx:NumericField>
                                <rx:NumericField Hidden="true" runat="server" ID="NumUsdOriginalParity1" FieldLabel="Parite:" Mode="Decimal" DecimalPrecision="6" DecimalSeparator="," FieldLabelWidth="60" Width="80"></rx:NumericField>

                            </td>
                            <td>
                                <cc1:CrmMoneyComp runat="server" ID="ReceivedOptionUsd_2" UniqueName="new_ReceivedAmount2" Disabled="true" ObjectId="201500026">
                                </cc1:CrmMoneyComp>
                            </td>
                            <td>
                                <rx:NumericField Disabled="true" runat="server" ID="NumUsdParity2" FieldLabel="Parite:" Mode="Decimal" DecimalPrecision="6" DecimalSeparator="," FieldLabelWidth="60" Width="80"></rx:NumericField>
                                <rx:NumericField Hidden="true" runat="server" ID="NumUsdOriginalParity2" FieldLabel="Parite:" Mode="Decimal" DecimalPrecision="6" DecimalSeparator="," FieldLabelWidth="60" Width="80"></rx:NumericField>

                            </td>
                        </tr>
                        <tr>
                            <td>
                                <input type="radio" id="RadioTry" name="rdg1" onclick="ShowHideRadio(this.id)" /> </td>
                            <td>
                                <cc1:CrmMoneyComp runat="server" ID="ReceivedOptionTry" UniqueName="new_ReceivedAmount1" ObjectId="201500026">
                                 <DecimalChange OnEvent="ReceivedOptionTry_OnChange">
                                    </DecimalChange>
                                </cc1:CrmMoneyComp>
                            </td>
                            <td>
                                <rx:NumericField Disabled="true" runat="server" ID="NumTryParity1" FieldLabel="Parite:" Mode="Decimal" DecimalPrecision="6" DecimalSeparator="," FieldLabelWidth="60" Width="80"></rx:NumericField>
                                <rx:NumericField Hidden="true" runat="server" ID="NumTryOriginalParity1" FieldLabel="Parite:" Mode="Decimal" DecimalPrecision="6" DecimalSeparator="," FieldLabelWidth="60" Width="80"></rx:NumericField>

                            </td>
                            <td></td>
                        </tr>
                        <tr>
                            <td style="height: 50px" colspan="3">
                                <cc1:CrmMoneyComp runat="server" ID="new_KambiyoAmount" UniqueName="new_KambiyoAmount" ObjectId="201500026" Disabled="true" Hidden="True">
                                </cc1:CrmMoneyComp>
                            </td>
                        </tr>

                        <tr>
                            <td colspan="3">
                                <rx:Button runat="server" ID="btnTopup" Icon="Accept" Text="Yükle"
                                    Width="150" Visible="true">
                                    <AjaxEvents>
                                        <Click OnEvent="btnTopup_Click" Before="CheckValidationBeforeLoad(msg,e)">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </td>

                        </tr>

                    </table>
                </Body>
            </rx:Fieldset>

        </Body>
    </rx:Window>

    <rx:Window ID="gsmPaymentCorporationDetail" runat="server" Width="400" Height="200" Modal="true" WindowCenter="true"
        Border="false" Closable="true" Maximizable="false" Resizable="true" CloseAction="Hide"
        ShowOnLoad="false" Title="İşlem Kurum Detayı">
        <Body>
            <rx:Fieldset runat="server" ID="Fieldset2" AutoHeight="Normal" Height="120" AutoWidth="true"
                Collapsed="false" Collapsible="false" Border="false" CustomCss="Section3" Title="İşlem Bilgileri">
                <Body>
                    <table>
                        <tr>
                            <td>
                                <rx:TextField runat="server" ID="txtTransactionReference" FieldLabel="Upt Referans:" Disabled="true" Width="200"></rx:TextField>
                            </td>
                            </td>
                         
                        </tr>
                        <tr>
                            <td>
                                <rx:TextField runat="server" ID="txtCorporationReference" FieldLabel="Kurum Referans:" Disabled="true" Width="200"></rx:TextField>
                            </td>

                        </tr>
                        <tr>
                            <td>
                                <rx:TextField runat="server" ID="txtCorporationStatus" FieldLabel="Kurum Statü:" Disabled="true" Width="200"></rx:TextField>
                            </td>
                            </td>
                       
                        </tr>

                        <tr>
                            <td>
                                <rx:TextField runat="server" ID="txtOperatorName" FieldLabel="Operator adı:" Disabled="true" Width="200"></rx:TextField>
                            </td>
                            </td>
                            
                        </tr>
                        <tr>
                            <td>
                                <rx:TextField runat="server" ID="txtMsisdn" FieldLabel="Gsm No:" Disabled="true" Width="200"></rx:TextField>
                            </td>
                            </td>
                           
                        </tr>
                    </table>
                </Body>
            </rx:Fieldset>

        </Body>
    </rx:Window>



</body>
</html>

