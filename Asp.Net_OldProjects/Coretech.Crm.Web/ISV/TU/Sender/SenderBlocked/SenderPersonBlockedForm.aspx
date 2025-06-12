<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SenderPersonBlockedForm.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Sender.SenderBlocked.SenderPersonBlockedForm" ValidateRequest="false" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Import Namespace="Coretech.Crm.Utility.Util" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">


        function SetValueHidden()
        {
            documentId.setValue(GridPanelConfirmHistory.selectedRecord.DocumentId);
            documentName.setValue(GridPanelConfirmHistory.selectedRecord.DocumentName);
            hdnUploaded.setValue(GridPanelConfirmHistory.selectedRecord.Uploaded);
        }


        function ShowUploadDetail() {
            //var config = "../ISV/TU/Transfer/TransferDocument.aspx?ObjectId=" + operationTypeId.getValue() + "&RecordId=" + transferId.getValue();
            var defaulteditpageid = "";       
            
            if (hdnUploaded.getValue() == true)
                return;

            if (hdnRecId.getValue() == null || hdnRecId.getValue() == 'undefined' || hdnRecId.getValue() == '' || hdnRecId.getValue() == '<%=Guid.Empty%>')
                return;

            var config = "../ISV/TU/Corporated/CorporatedPreInfoNewRegistrationFileUpload.aspx?RecordId=" + hdnRecId.getValue() + "&MersisNo=" + new_CorparateCentralRegistryServiceNumber.getValue() + '&DocumentId=' + documentId.getValue() + '&DocumentName=' + documentName.getValue();
            var title = "Dosya Yükleme Ekranı";


            //var config = "/CrmPages/AutoPages/EditReflex.aspx?ObjectId=201900037&recId=" + hdnRecId.getValue() + "&defaulteditpageid=" + defaulteditpageid + "&SourceFormType=NormList";

            window.top.newWindow(config, { title: title, width: 400, height: 270, resizable: false });
        }

        function checkDelete() {
            var ret = confirm('Seçili kayıt silinecek, Emin misiniz?');
            return ret;
        }

        <%
        string islem = QueryHelper.GetString("islem");
        string mesaj="";
        if (islem == "islemTamam")
            mesaj = "Talebiniz alınarak onaya gönderilmiştir.";
        if (islem == "islemTamamOnay")
            mesaj = "İşlem tamamlanmıştır.";
        
        if (islem=="islemTamamOnay")
        {
        %>
            function closeWindowAscx(islem) {
                alert(islem);
                window.top.R.WindowMng.getActiveWindow().hide();
            }
            closeWindowAscx('<%=mesaj%>');
        <%
        }
        %>

        //document.getElementsByClassName('x-grid3-hd-checker')[0].style.visibility = 'hidden';
        //document.getElementsByClassName('x-grid3-row-checker')[0].style.visibility = 'hidden';

    </script>

        <%
        string recId = QueryHelper.GetString("RecordId");
               
        if (!String.IsNullOrEmpty(recId))
        {
        %>
            <style type="text/css">
            .x-grid3-hd-checker ,.x-grid3-row-checker,.x-grid3-row-checker-on{
                display: none !important;
            }
        <%
        }
        %>
        
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <div>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="120" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Tüzel Müşteri Tanımı">
            <Tools>
                <Items>
                    <rx:ToolButton ToolTypeIcon="Refresh" runat="server" ID="btnInformation">
                        <Listeners>
                            <Click Handler="ClearAll();" />
                        </Listeners>
                    </rx:ToolButton>
                </Items>
            </Tools>
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout101" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_TransactionType" ObjectId="201900037" UniqueName="new_TransactionType"
                                    Width="150" PageSize="50" FieldLabel="150">
                                 </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                    <cc1:CrmComboComp runat="server" ID="new_SenderId" ObjectId="201900037" UniqueName="new_SenderId" Hidden="false"
                                    Width="150" PageSize="50" FieldLabel="150" LookupViewUniqueName="Kurumsal Gönderici Listesi_Mobile" RequirementLevel="None" AutoLoad="true" >
                                    <DataContainer>
                                        <DataSource OnEvent="newSenderLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                         <Change OnEvent="GrdSenderPersonList">
                                         </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" id="new_CorporatedBlockedReasonId" objectid="201900037" uniquename="new_CorporatedBlockedReasonId"
                                    width="200" pagesize="50" fieldlabel="150" FieldLabelWidth="150">
                                 </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                        <cc1:CrmTextFieldComp ID="new_Description" runat="server" ObjectId="201900037" UniqueName="new_Description"
                                            FieldLabelWidth="150" Width="150" PageSize="50" FieldLabelShow="True">
                                        </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
                <rx:Button ID="BtnSave" runat="server" Text="Kaydet" Icon="Disk" Visible="true" AutoPostBack="true">
                    <AjaxEvents>
                        <Click OnEvent="AddRecord"></Click>
                    </AjaxEvents>
                </rx:Button>
                 <rx:Button ID="BtnAccept" runat="server" Text="Onayla" Icon="Accept" Visible="true" AutoPostBack="true">
                    <AjaxEvents>
                        <Click OnEvent="Confirm"></Click>
                    </AjaxEvents>
                </rx:Button>
           </Buttons>
        </rx:PanelX>

            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentName" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnUploaded" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusId" runat="server"></rx:Hidden>
            <rx:GridPanel runat="server" ID="GridPanelSenderPerson" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
                Height="500" Width="1200" Mode="Remote" AjaxPostable="true" Editable="false">
                <DataContainer>
                    <DataSource OnEvent="GrdSenderPersonList">
                    </DataSource>
                </DataContainer>  
                <ColumnModel>
                    <Columns>
                        <rx:GridColumns ColumnId="Id" Width="100" Header="Id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="ID" />
                        <rx:GridColumns ColumnId="FullName" Width="100" Header="Isim" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="FullName" />
                        <rx:GridColumns ColumnId="UserName" Width="100" Header="Kullanıcı Adı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="UserName" />
                        <rx:GridColumns ColumnId="new_FatherName" Width="100" Header="Baba Adı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_FatherName" />
                        <rx:GridColumns ColumnId="new_MotherName" Width="100" Header="Anne Adı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_MotherName" />
                        <rx:GridColumns ColumnId="new_NationalityIDName" Width="100" Header="Uyruk" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_NationalityIDName" />
                        <rx:GridColumns ColumnId="new_IdendificationCardTypeID" Width="100" Header="Kimlik Tip Id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_IdendificationCardTypeID" />
                        <rx:GridColumns ColumnId="new_IdendificationCardTypeIDName" Width="100" Header="Kimlik Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_IdendificationCardTypeIDName" />
                        <rx:GridColumns ColumnId="new_E_Mail" Width="100" Header="Mail Adresi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_E_Mail" />
                    </Columns>
                </ColumnModel>
                <SelectionModel>
                <rx:CheckSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server"
                    ShowNumber="true">
                    <%--<Listeners>
                        <RowDblClick Handler="ShowWindow(GridPanelMonitoring.id,GridPanelMonitoring.selectedRecord.ID,GridPanelMonitoring.selectedRecord.ObjectId,1);" />
                    </Listeners>--%>
                </rx:CheckSelectionModel>
                </SelectionModel>
                <BottomBar>
                    <rx:PagingToolBar runat="server" ID="PagingToolBar2" ControlId="GridPanelSenderPerson">
                    </rx:PagingToolBar>
                </BottomBar>
                <LoadMask ShowMask="true" />
            </rx:GridPanel>
        </div>
    </form>
</body>
</html>
