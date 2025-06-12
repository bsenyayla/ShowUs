<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BankDepositEft.aspx.cs" Inherits="BankDepositEft" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .crm-field-valid {
            margin-top: 3px !important;
        }

        .x-window-body {
            background-color: white !important;
        }

        .Crm-ColumnLayout {
            margin-left: 12px !important;
        }
    </style>
    <script type="text/javascript">
        function ShowLogHistory() {
            var config = "../ISV/TU/BankDepositEft/BankDepositEftLog.aspx?LogId=" + hdnRecordId.getValue();
            window.top.newWindow(config, { title: 'Kurum Eft Entegrasyon Log', width: 800, height: 500, resizable: false });
        }
    </script>
</head>
<body>

    <form id="form1" runat="server">
        <div>
            <rx:RegisterResources runat="server" ID="RR" />
            <rx:Hidden ID="hdnSelectedId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnRecordId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnJobId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnTransferId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatus" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnCorrespondent" runat="server"></rx:Hidden>
            <rx:Hidden ID="RecordId" runat="server"></rx:Hidden>
            <rx:PanelX ID="wrapper" runat="server" Border="false">
                <Body>

                    <rx:GridPanel runat="server" ID="gpBankDepositEft" AutoWidth="true" AutoHeight="Full"
                        Height="500" AutoLoad="true" Mode="Remote">
                        <DataContainer>
                            <DataSource OnEvent="GetData">
                            </DataSource>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns ColumnId="BankDepositId" Width="100" Header="BankDepositId" Sortable="false"
                                    MenuDisabled="true" Hidden="true" DataIndex="BankDepositId" />
                                <rx:GridColumns ColumnId="new_TransferId" Width="0" Header="new_TransferId" Sortable="false"
                                    MenuDisabled="true" Hidden="true" DataIndex="new_TransferId" />
                                <rx:GridColumns ColumnId="new_Pin" Width="100" Header="Kurum Referans" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_Pin" />
                                <rx:GridColumns ColumnId="TransferTuRef" Width="100" Header="UPT Referans" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="TransferTuRef" />
                                <rx:GridColumns ColumnId="new_ConfirmStatusName" Width="200" Header="Gönderim Statüsü" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_ConfirmStatusName" />
                                <rx:GridColumns ColumnId="new_Status" Width="100" Header="Statü" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_Status" />
                                <rx:GridColumns ColumnId="new_CorrespondentRef" Width="100" Header="Kurum Fiş No" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_CorrespondentRef" />
                                <rx:GridColumns ColumnId="CreatedOn" Width="100" Header="İşlem Tarihi" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="CreatedOn" />
                                <rx:GridColumns ColumnId="new_SenderName" Width="100" Header="Gönderen Adı" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_SenderName" />
                                <rx:GridColumns ColumnId="new_SenderSurname" Width="100" Header="Gönderen Soyadı" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_SenderSurname" />
                                <rx:GridColumns ColumnId="new_SenderCountryCode" Width="100" Header="Gönderen Ülke" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_SenderCountryCode" />
                                <rx:GridColumns ColumnId="new_SenderIdNo" Width="100" Header="Gönderen Kimlik No" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_SenderIdNo" />
                                <rx:GridColumns ColumnId="new_BeneficiaryName" Width="100" Header="Alıcı Adı" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_BeneficiaryName" />
                                <rx:GridColumns ColumnId="new_BeneficiarySurname" Width="100" Header="Alıcı Soyadı" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_BeneficiarySurname" />
                                <rx:GridColumns ColumnId="new_BeneficiaryIban" Width="100" Header="Alıcı Iban" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_BeneficiaryIban" />
                                <rx:GridColumns ColumnId="new_BeneficiaryCountryCode" Width="100" Header="Alıcı Ülke Kodu" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_BeneficiaryCountryCode" />
                                <rx:GridColumns ColumnId="new_Amount" Width="100" Header="İşlem Tutarı" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_Amount" Align="Right" />
                                <rx:GridColumns ColumnId="new_AmountCurrencyName" Width="75" Header="Döviz" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="new_AmountCurrencyName" />
                                <rx:GridColumns ColumnId="new_Message" Width="100" Header="Hata Mesajı" Sortable="false"
                                    MenuDisabled="true" Hidden="true" DataIndex="new_Message" />
                                <rx:GridColumns ColumnId="new_JobId" Width="100" Header="Job Id" Sortable="false"
                                    MenuDisabled="true" Hidden="true" DataIndex="new_JobId" />
                            </Columns>
                        </ColumnModel>
                        <SpecialSettings>
                            <rx:RowExpander Template="<br/><br/><span style='color:red'>{new_Message}</span>"
                                Collapsed="true" />
                        </SpecialSettings>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="GridPanelPaymentsRowSelectionModel1" runat="server" ShowNumber="true">
                                <Listeners>
                                    <RowClick Handler="hdnStatus.clear();hdnStatus.setValue(gpBankDepositEft.selectedRecord.new_Status);hdnTransferId.clear();hdnTransferId.setValue(gpBankDepositEft.selectedRecord.new_TransferId);hdnJobId.clear();hdnJobId.setValue(gpBankDepositEft.selectedRecord.new_JobId);hdnCorrespondent.clear();hdnCorrespondent.setValue(gpBankDepositEft.selectedRecord.new_CorrespondentRef);hdnRecordId.clear();hdnRecordId.setValue(gpBankDepositEft.selectedRecord.BankDepositId);hdnSelectedId.clear();hdnSelectedId.setValue(gpBankDepositEft.selectedRecord.TransferTuRef);if(hdnSelectedId.value) document.getElementById('label3').innerHTML ='<b>İşlem Detay (&nbsp;' + hdnSelectedId.value +'&nbsp;)</b>'; else document.getElementById('label3').innerHTML ='<b>İşlem Detay</b>';"></RowClick>
                                </Listeners>
                                <AjaxEvents>

                                    <RowDblClick OnEvent="RowDoubleClickOnEvent">
                                    </RowDblClick>
                                </AjaxEvents>
                            </rx:RowSelectionModel>
                        </SelectionModel>
                        <BottomBar>
                            <rx:PagingToolBar ID="pagingToolBar" runat="server" ControlId="gpBankDepositEft">
                            </rx:PagingToolBar>
                        </BottomBar>
                        <TopBar>
                            <rx:ToolBar ID="toolBar1" runat="server">
                                <Items>
                                    <rx:Label ID="label1" runat="server" ImageUrl="../../../images/database-export.png" ImageHeight="36" ImageWidth="36" Width="40">
                                    </rx:Label>
                                    <rx:ToolbarSeparator ID="ToolbarSeparator7" runat="server"></rx:ToolbarSeparator>
<%--                                    <rx:ToolbarButton ID="ToolbarButton4" runat="server" Icon="ApplicationEdit" Text="<b>Düzenle</b>">
                                        <AjaxEvents>
                                            <Click OnEvent="GridRowClickOnEvent"></Click>
                                        </AjaxEvents>
                                    </rx:ToolbarButton>--%>
                                    <rx:ToolbarButton ID="btnRefresh" runat="server" Icon="ArrowRefresh" Text="<b>Yenile</b>">
                                        <Listeners>
                                            <Click Handler="gpBankDepositEft.reload();" />
                                        </Listeners>
                                    </rx:ToolbarButton>
                                    <rx:DateField ID="StartDate" runat="server"></rx:DateField>
                                    <rx:ToolbarSeparator ID="sep4" runat="server"></rx:ToolbarSeparator>
                                    <rx:DateField ID="EndDate" runat="server"></rx:DateField>
                                    <rx:ToolbarSeparator ID="sep1" runat="server"></rx:ToolbarSeparator>
                                    <rx:TextField ID="txtTransferTuRef" runat="server" EmptyText="UPT Referans Giriniz">
                                    </rx:TextField>
                                    <rx:ToolbarSeparator ID="sep2" runat="server"></rx:ToolbarSeparator>
                                    <rx:TextField ID="txtCorrespondentRef" runat="server" EmptyText="Kurum Ref veya Fiş No Giriniz">
                                    </rx:TextField>
                                    <rx:ToolbarSeparator ID="sep3" runat="server"></rx:ToolbarSeparator>
                                    <rx:ToolbarButton ID="ToolbarButton1" runat="server" Icon="ZoomIn" Text="<b>Bul</b>">
                                        <Listeners>
                                            <Click Handler="gpBankDepositEft.reload();" />
                                        </Listeners>
                                    </rx:ToolbarButton>

                                    <rx:ToolbarFill ID="fill1" runat="server"></rx:ToolbarFill>
                                    <rx:ToolbarButton ID="btnNew" runat="server" Icon="ArrowRefresh" Text="<b>Tekrar Dene</b>">
                                        <AjaxEvents>
                                            <Click OnEvent="Retry"></Click>
                                        </AjaxEvents>
                                    </rx:ToolbarButton>
                                </Items>
                            </rx:ToolBar>
                        </TopBar>
                        <BottomBar>

                            <rx:PagingToolBar runat="server" ID="PagingToolBar2" Enabled="true" ControlId="gpBankDepositEft">
                                <Buttons>
                                    <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload" Text="Excel'e Aktar">
                                        <AjaxEvents>
                                            <Click OnEvent="ExcelExport">
                                            </Click>
                                        </AjaxEvents>
                                    </rx:SmallButton>
                                </Buttons>
                            </rx:PagingToolBar>

                        </BottomBar>
                    </rx:GridPanel>

                </Body>

            </rx:PanelX>

            <rx:Window ID="DetailPage" runat="server" Width="600" Height="570" Modal="true"
                CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
                CloseAction="Hide" ShowOnLoad="false" Border="false"
                Title="&nbsp;&nbsp;Detay" ContainerPadding="true">
                <Body>
                    <rx:ToolBar ID="toolBar2" runat="server">
                        <Items>
                            <rx:Label ID="label2" runat="server" ImageUrl="../../../images/database-export.png" ImageHeight="36" ImageWidth="36" Width="40" Text="">
                            </rx:Label>
                            <rx:Label ID="label3" runat="server" Text="<b>İşlem Detay</b>" Style="color: black; font-size: xx-large; font-weight: bold">
                            </rx:Label>
                            <rx:ToolbarFill ID="toolBarFill1" runat="server"></rx:ToolbarFill>
                            <rx:Button ID="BtnHistory" runat="server" Text="Geçmiş" Icon="Clock">
                                <Listeners>
                                    <Click Handler="ShowLogHistory();"></Click>
                                </Listeners>
                            </rx:Button>
                            <rx:Button ID="BtnClose" runat="server" Text="Kapat" Icon="ApplicationDelete">
                                <Listeners>
                                    <Click Handler="DetailPage.hide();" />
                                </Listeners>
                            </rx:Button>
                        </Items>
                    </rx:ToolBar>
                    <rx:ColumnLayout ID="col1" runat="server" ColumnWidth="100%">
                        <Rows>
                            <rx:RowLayout ID="RowLayout15" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_Pin" ObjectId="201800012" UniqueName="new_Pin"
                                        ReadOnly="true" Disabled="true" Width="50" FieldLabelWidth="300">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="row1" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_CorrespondentRef" ObjectId="201800012" UniqueName="new_CorrespondentRef"
                                        ReadOnly="true" Disabled="true" Width="50" FieldLabelWidth="300">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout3" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_SenderName" ObjectId="201800012" UniqueName="new_SenderName"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout6" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_SenderSurname" ObjectId="201800012" UniqueName="new_SenderSurname"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout7" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdType" ObjectId="201800012" UniqueName="new_SenderIdType"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout8" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdNo" ObjectId="201800012" UniqueName="new_SenderIdNo"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout9" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_SenderCountryCode" ObjectId="201800012" UniqueName="new_SenderCountryCode"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout10" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_SenderNationality" ObjectId="201800012" UniqueName="new_SenderNationality"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout11" runat="server">
                                <Body>
                                    <cc1:CrmDateFieldComp runat="server" ID="new_SenderBirthdate" ObjectId="201800012" UniqueName="new_SenderBirthdate"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmDateFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout12" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_Message" ObjectId="201800012" UniqueName="new_Message"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout1" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_BeneficiaryName" ObjectId="201800012" UniqueName="new_BeneficiaryName"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout2" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_BeneficiarySurname" ObjectId="201800012" UniqueName="new_BeneficiarySurname"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout4" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_BeneficiaryCountryCode" ObjectId="201800012" UniqueName="new_BeneficiaryCountryCode"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout5" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_BeneficiaryIban" ObjectId="201800012" UniqueName="new_BeneficiaryIban"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout13" runat="server">
                                <Body>
                                    <cc1:CrmMoneyComp runat="server" ID="new_Amount" ObjectId="201800012" UniqueName="new_Amount"
                                        ReadOnly="true" Disabled="true">
                                    </cc1:CrmMoneyComp>

                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout14" runat="server">
                                <Body>
                                    <cc1:CrmTextFieldComp runat="server" ID="new_Status" ObjectId="201800012" UniqueName="new_Status"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmTextFieldComp>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout16" runat="server">
                                <Body>
                                    <cc1:CrmComboComp runat="server" ID="new_TransferStatusId" ObjectId="201800012" UniqueName="new_TransferStatusId"
                                        ReadOnly="true" Disabled="true" Width="50">
                                    </cc1:CrmComboComp>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                </Body>
            </rx:Window>

        </div>
    </form>
</body>
</html>
