<%@ Page Language="C#" AutoEventWireup="true"
    ValidateRequest="false" Inherits="Cash_CashTransaction" CodeBehind="CashTransaction.aspx.cs" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="New_CashTransactionHeaderId" runat="server" />
        <rx:Hidden runat="server" ID="hdnReportId" />
        <rx:Hidden runat="server" ID="hdnRecId" />
        <rx:Fieldset runat="server" ID="PanelX3" AutoHeight="Normal" Height="300" AutoWidth="true"
            CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false" Title="Devir İşlemleri">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout15">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="CashTransactionRefNo" ObjectId="201300002"
                                    UniqueName="CashTransactionRefNo" Width="150" PageSize="50" FieldLabel="200"
                                    ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_TransactionType" ObjectId="201300002"
                                    UniqueName="new_TransactionType" Width="150" Mode="Remote" RequirementLevel="BusinessRequired">
                                    <AjaxEvents>
                                        <Change OnEvent="new_TransactionTypeChange">
                                            <ExtraParams>
                                                <rx:Parameter Mode="Value" Value="1" Name="Mode" />
                                            </ExtraParams>
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_CashNameID" ObjectId="201300002" UniqueName="new_CashNameID"
                                    LookupViewUniqueName="CashComboView" Width="150">
                                    <DataContainer>
                                        <DataSource OnEvent="new_CashNameIDonEvent">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_TransactionTypeChange">
                                            <ExtraParams>
                                                <rx:Parameter Mode="Value" Value="2" Name="Mode" />
                                            </ExtraParams>
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout13" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <cc1:CrmTextAreaComp runat="server" ID="new_Description" ObjectId="201300002" Hidden="false"
                                    Height="60" UniqueName="new_Description" FieldLabel="200">
                                </cc1:CrmTextAreaComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:PanelX runat="server" ID="Fieldset2" AutoHeight="Normal" Height="130" AutoWidth="true"
            Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="50%">
                    <Rows>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="50%">
                    <Rows>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
                <rx:Button ID="btnSave" runat="server" Icon="Disk" Text="CRM.NEW_CASHTRANSACTION_SAVE"
                    Width="60">
                    <AjaxEvents>
                        <Click OnEvent="btnSaveOnEvent" Before="CrmValidateForm(msg,e);">
                            <ExtraParams>
                                <rx:Parameter Name="Kupurler" Mode="Raw" Value="JSON.encode(Kupur)" />
                            </ExtraParams>
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                <rx:Button ID="btnConfirm" runat="server" Icon="Accept" Text="CRM.NEW_CASHTRANSACTION_ACCEPT"
                    Width="60">
                    <AjaxEvents>
                        <Click OnEvent="btnConfirmOnEvent">
                            <ExtraParams>
                                <rx:Parameter Name="Kupurler" Mode="Raw" Value="JSON.encode(Kupur)" />
                            </ExtraParams>
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                <rx:Button ID="btnRed" runat="server" Icon="Cancel" Text="CRM.NEW_CASHTRANSACTION_CANCEL"
                    Width="60">
                    <AjaxEvents>
                        <Click OnEvent="btnRedOnEvent">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                <rx:Button ID="btnDekont" runat="server" Icon="Printer" Text="CRM.NEW_CASHTRANSACTION_DEKONT"
                    Width="60" Hidden="True">
                    <Listeners>
                        <Click Handler="DekontBas();"></Click>
                    </Listeners>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
    </form>
    <script type="text/javascript">
        function KupurAc(id, w) {
            if (document.getElementById('_new_TransactionType').value == '') {
                alert('İşlem tipi seçmelisiniz!');
            }
            else {
                w.show();
            }

        }

        function KupurEkle(w) {
            w.hide();
        }


        function Topla(detail, o) {
            var toplam = 0;
            for (var i = 0; i < detail.length; i++) {
                toplam += parseFloat(detail[i].Carpan) * parseFloat(detail[i].Adet);
            }
            o.setValue(toplam);
        }

        function DekontBas() {
            if (hdnReportId.getValue() != "") {
                window.top.ShowReport(hdnReportId.getValue(), hdnRecId.getValue(), "&doExport=1&OpenInWindow=1", false);
            }

        }
    </script>
</body>
</html>
