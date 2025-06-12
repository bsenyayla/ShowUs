<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="CustAccount_UPTCard_UptCardEditorController" CodeBehind="UptCardEditorController.ascx.cs" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<%@ Register Src="~/ISV/TU/SenderDocument/UptCardList.ascx" TagPrefix="uc1" TagName="UptCardList" %>

<rx:PanelX ID="startApplication" runat="server" AutoHeight="Normal" Height="0">
    <Body>
        <rx:Hidden runat="server" ID="hdnReportId">
        </rx:Hidden>
    </Body>
    <Buttons>
          <rx:Button ID="BtnGetBalance" runat="server" Text="Bakiye Sorgula" Icon="ApplicationGet">
            <AjaxEvents>
                <Click OnEvent="GetBalance" ></Click>
            </AjaxEvents>
        </rx:Button>

        <rx:Button ID="BtnConfirmHistory" runat="server" Text="Onaylanma Geçmişi" Icon="ReportGo">
            <AjaxEvents>
                <Click OnEvent="ConfirmHistory" Success="windowTotal.show();" ></Click>
            </AjaxEvents>
        </rx:Button>

        <rx:Button ID="btnShowDocument" runat="server" Text="Sözleşmeyi Görüntüle" Icon="ApplicationLink">
            <AjaxEvents>
                <Click OnEvent="ShowDocument"></Click>
            </AjaxEvents>
        </rx:Button>
        <rx:Button ID="btnCancel" runat="server" Text="İşlemi İptal Et" Icon="Cancel">
            <AjaxEvents>
                <Click OnEvent="CancelCard"></Click>
            </AjaxEvents>
        </rx:Button>
        <rx:Button ID="btnStart" runat="server" Text="İşlemi Başlat" Icon="ApplicationOsxStart">
            <AjaxEvents>
                <Click OnEvent="SaveUptCard"></Click>
            </AjaxEvents>
        </rx:Button>

        <rx:Button ID="btnFinish" runat="server" Text="İşlemi Tamamla" Icon="DatabaseSave">
            <AjaxEvents>
                <Click OnEvent="UploadDocuments" Before="CrmValidateForm(msg,e);"></Click>
            </AjaxEvents>
        </rx:Button>
        <rx:Button ID="btnUpdate" runat="server" Text="İşlemi Düzenle" Icon="DatabaseEdit" ValidateRequestMode="Disabled">
            <AjaxEvents>
                <Click OnEvent="UpdateCard"></Click>
            </AjaxEvents>
        </rx:Button>
    </Buttons>
</rx:PanelX>
<rx:PanelX ID="pnlDocuments" runat="server" AutoHeight="Normal" Title="Ekstre Oluştur" Height="120">
    <Body>
        <%-- <uc1:UptCardList runat="server" ID="UptCardList" />--%>
        <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="50%">
            <Rows>
                <rx:RowLayout ID="RowLayout101" runat="server">
                    <Body>
                        <cc1:CrmDateFieldComp ID="cmbStatementDateStart" runat="server" ObjectId="201600005"
                            Width="100" RequirementLevel="BusinessRequired" UniqueName="new_StartDate">
                        </cc1:CrmDateFieldComp>
                    </Body>
                </rx:RowLayout>
                <rx:RowLayout ID="RowLayout2" runat="server">
                    <Body>
                      <%--  <cc1:CrmDecimalComp ID="crmMinAmount" runat="server" ObjectId="201600007"
                            Width="100"   UniqueName="new_MinimumAmount">
                        </cc1:CrmDecimalComp>--%>
                         <rx:NumericField ID="numMinAmount" runat="server" FieldLabel="Minimum Tutar"></rx:NumericField>
                    </Body>
                </rx:RowLayout>
                <rx:RowLayout ID="CommandButton" runat="server">
                    <Body>
                        <rx:Button ID="btnPdfWatch" Download="true" runat="server" Icon="DiskDownload" Text="Excel Aktar" Width="100">
                            <AjaxEvents>
                                <Click OnEvent="btnPdfWatch_OnClick">
                                </Click>
                            </AjaxEvents>
                        </rx:Button>
                    </Body>
                </rx:RowLayout>
                <rx:RowLayout ID="RowLayout3" runat="server">
                    <Body>
                        <rx:Label ID="emptyLbl" runat="server"></rx:Label>
                    </Body>
                </rx:RowLayout>
                <%-- <rx:RowLayout ID="RowLayout4" runat="server">
                    <Body>
                        <rx:Button ID="btnPdfMail" runat="server" Icon="Email" Text="Pdf E-Mail Gönder" Width="120" Download="true">
                            <AjaxEvents>
                                <Click OnEvent="btnPdfMail_OnClick" Before="IsValidEmail(e, txtEmail.getValue());">
                                    <EventMask ShowMask="true" />
                                </Click>
                            </AjaxEvents>
                        </rx:Button>
                    </Body>
                </rx:RowLayout>--%>
            </Rows>
        </rx:ColumnLayout>
        <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="50%">
            <Rows>
                <rx:RowLayout ID="RowLayout1" runat="server">
                    <Body>
                        <cc1:CrmDateFieldComp ID="cmbStatementDateEnd" runat="server" ObjectId="201600005"
                            UniqueName="new_EndDate" FieldLabelWidth="100" RequirementLevel="BusinessRequired"
                            Width="100">
                        </cc1:CrmDateFieldComp>
                    </Body>
                </rx:RowLayout>
                <rx:RowLayout ID="RowLayout4" runat="server">
                    <Body>
                        <rx:NumericField ID="numMaxAmount" runat="server" FieldLabel="Maksimum Tutar"></rx:NumericField>

                        <%--<cc1:CrmDecimalComp ID="crmMaxAmount" runat="server" ObjectId="201600007"
                            Width="100"  UniqueName="new_MinimumAmount"  >
                        </cc1:CrmDecimalComp>--%>
                    </Body>
                </rx:RowLayout>
            </Rows>
        </rx:ColumnLayout>


    </Body>
</rx:PanelX>

<rx:Window ID="windowTotal" runat="server" Width="500" Height="200" Modal="true"
    Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false" WindowCenter="true"
    Title="Onay Geçmişi">
    <Body>
        <rx:GridPanel runat="server" ID="GridPanelConfirmHistory" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
            Height="150" Editable="false" Mode="local" AutoLoad="false" Width="1200" AjaxPostable="true">
            <DataContainer>
                <DataSource OnEvent="ConfirmHistory">
                </DataSource>
            </DataContainer>
            <ColumnModel>
                <Columns>
                    <rx:GridColumns ColumnId="CreatedOn" Width="150" Header="Tarih" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="CreatedOn" />
                    <rx:GridColumns ColumnId="Description" Width="200" Header="Açıklama" Sortable="false"
                        MenuDisabled="true" Hidden="false" DataIndex="Description" />
                </Columns>
            </ColumnModel>
            <SelectionModel>
                <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true" SingleSelect="true">
                </rx:RowSelectionModel>
            </SelectionModel>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>
    </Body>
</rx:Window>
<script type="text/javascript">



    function closePage() {


        window.top.R.WindowMng.getWindowById(window.top.R.WindowMng.windows[2].id).setActiveWindow();

        if (window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].tabs.tabs[1]) {

            var e = e ? e : window.event;

            var tabId = window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].tabs.tabs[1].id;

            window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame("Frame_" + tabId).btnSaveAndClose.click(e);

            window.top.R.WindowMng.getActiveWindow().getIFrame().location.reload(true);
        }
        else {
            RefreshParetnGridForCashTransaction(true);
        }
    }

    function ShowProfession(senderId, pageTitle) {
        var config = GetWebAppRoot + "/ISV/TU/Profession/Profession.aspx?senderId=" + senderId;
        window.top.newWindow(config, {
            title: pageTitle,
            width: 450,
            height: 300,
            draggable: false,
            resizable: false,
            modal: true
        });
    }

</script>

