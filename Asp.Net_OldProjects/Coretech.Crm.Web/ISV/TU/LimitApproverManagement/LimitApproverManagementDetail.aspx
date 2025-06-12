<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LimitApproverManagementDetail.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.LimitApproverManagement.LimitApproverManagementDetail" ValidateRequest="false" %>

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

        function checkDelete() {
            var ret = confirm('Seçili kayıtlar silinecek, Emin misiniz?');
            return ret;
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
        if (islem == "kayitTamamla")
            mesaj = "Talebiniz alınarak onaya gönderilmiştir.";
        else if (islem == "islemTamamOnay")
            mesaj = "İşlem tamamlanmıştır.";
        else if (islem == "kayitTamamla")
            mesaj = "İşlem tamamlanmıştır.";


        if (islem!="")
        {
        %>
        function closeWindowAscx(mesaj) {
                if (mesaj!='')
                    alert(mesaj);

                window.top.R.WindowMng.getActiveWindow().hide();
                window.close();
        }
        closeWindowAscx('<%=mesaj%>');
        <%
        }
        %>

        //document.getElementsByClassName('x-grid3-hd-checker')[0].style.visibility = 'hidden';
        //document.getElementsByClassName('x-grid3-row-checker')[0].style.visibility = 'hidden';

    </script>


</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <div>
            <rx:Hidden ID="hdnTransactionTypeId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnTransactionType" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatus" runat="server"></rx:Hidden>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="150" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Limit ve Onaycı Tanımı">
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
                                    <cc1:CrmComboComp runat="server" ID="new_SenderId" ObjectId="202000027" UniqueName="new_SenderId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" LookupViewUniqueName="Kurumsal Gönderici Listesi_Mobile" RequirementLevel="None" AutoLoad="true" >
                                    <DataContainer>
                                        <DataSource OnEvent="newSenderLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                         <Change OnEvent="GrdLimitApproverList">
                                         </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>

                                   <cc1:CrmComboComp runat="server" ID="new_SenderPersonId" ObjectId="202000027" UniqueName="new_SenderPersonId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" LookupViewUniqueName="Yetkili Lookup" RequirementLevel="None" AutoLoad="true" >
                                    <DataContainer>
                                        <DataSource OnEvent="newSenderPersonLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>

<%--                               <cc1:CrmComboComp runat="server" id="new_SenderPersonId" objectid="202000027" uniquename="new_SenderPersonId"
                                    width="100" pagesize="50" fieldlabel="150" FieldLabelWidth="150">
                                                <Filters>
                                                    <cc1:ComboFilter FromObjectId="202000027" FromUniqueName="new_SenderId" ToObjectId="201500041"
                                                        ToUniqueName="new_SenderId" />
                                                </Filters>
                                 </cc1:CrmComboComp>--%>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                               <cc1:CrmComboComp runat="server" id="new_CurrencyId" objectid="202000027" uniquename="new_CurrencyId"
                                    width="100" pagesize="50" fieldlabel="150" FieldLabelWidth="150">
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                    <%--<rx:Label ID="lIsMaxAmountLimit" runat="server" Text="Güvenlik amacıyla tek seferde yapılabilecek max. işlem limiti tanımlamak istiyor musunuz?" />--%>
                                    <rx:CheckField ID="new_IsMaxAmountLimit" runat="server" Width="30" FieldLabelWidth="250" FieldLabel="Güvenlik amacıyla tek seferde yapılabilecek max. işlem limiti tanımlamak istiyor musunuz?">
                                    <AjaxEvents>
                                         <Change OnEvent="chcIsMaxAmountLimitChecked">
                                         </Change>
                                    </AjaxEvents>                                    
                                    </rx:CheckField>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                        <cc1:CrmDecimalComp ID="new_LimitAmount" runat="server" ObjectId="202000027" UniqueName="new_LimitAmount"
                                            FieldLabelWidth="150" Width="100" PageSize="50" FieldLabelShow="True" Disabled="true">
                                        </cc1:CrmDecimalComp>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="50%">
                <Rows>
                        <rx:RowLayout ID="RowLayout6" runat="server">
                            <Body>
                               <cc1:CrmPicklistComp runat="server" id="new_Status" objectid="202000027" uniquename="new_Status"
                                    width="100" pagesize="50" fieldlabel="150" FieldLabelWidth="150">
                                 </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout8" runat="server">
                            <Body>
                                        <cc1:CrmTextAreaComp ID="new_RejectDescription" runat="server" ObjectId="202000027" UniqueName="new_RejectDescription"
                                            FieldLabelWidth="150" Width="100" PageSize="50">
                                        </cc1:CrmTextAreaComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>




            <rx:PanelX runat="server" ID="pnlDataRow" AutoHeight="Normal" Height="50" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" >
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="100%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout5" runat="server">
                            <Body>
                                 <rx:MultiField runat="server" ID="mfCustAccount1" FieldLabelShow="True" FieldLabelWidth="50">
                                 <Items>
                                    <cc1:CrmComboComp runat="server" id="new_TransactionTypeId" objectid="202000028" uniquename="new_TransactionTypeId" LookupViewUniqueName="vMobileTransactionTypeList_Lookup"
                                    width="150" pagesize="50">
                                    </cc1:CrmComboComp>

                                     <rx:Label ID="lAmount" runat="server" Text="İşlem aralığı" />
                                     <cc1:CrmDecimalComp ID="new_FirstAmount" runat="server" ObjectId="202000028" UniqueName="new_FirstAmount"
                                            FieldLabelWidth="150" Width="50" PageSize="50" FieldLabelShow="false">
                                     </cc1:CrmDecimalComp>
                                     <cc1:CrmDecimalComp ID="new_SecondAmount" runat="server" ObjectId="202000028" UniqueName="new_SecondAmount"
                                            FieldLabelWidth="150" Width="50" PageSize="50" FieldLabelShow="false">
                                     </cc1:CrmDecimalComp>

                                        <rx:Label ID="Label1" runat="server" Text="1.Onaycı" Width="60"/>
                                       <cc1:CrmComboComp runat="server" id="new_FirstApproverId" objectid="202000028" uniquename="new_FirstApproverId"
                                            width="150" pagesize="50" FieldLabelShow="false">
                                                <Filters>
                                                    <cc1:ComboFilter FromObjectId="202000027" FromUniqueName="new_SenderId" ToObjectId="201500041"
                                                        ToUniqueName="new_SenderId" />
                                                </Filters>
                                         </cc1:CrmComboComp>

                                        <rx:Label ID="Label2" runat="server" Text="2.Onaycı" Width="60"/>
                                       <cc1:CrmComboComp runat="server" id="new_SecondApproverId" objectid="202000028" uniquename="new_SecondApproverId"
                                            width="150" pagesize="50" FieldLabelShow="false">
                                                <Filters>
                                                    <cc1:ComboFilter FromObjectId="202000027" FromUniqueName="new_SenderId" ToObjectId="201500041"
                                                        ToUniqueName="new_SenderId" />
                                                </Filters>
                                         </cc1:CrmComboComp>
                                        <rx:Button ID="BtnSave" runat="server" Text="Ekle" Icon="Disk" Visible="true" AutoPostBack="true">
                                            <AjaxEvents>
                                                <Click OnEvent="AddRows"></Click>
                                            </AjaxEvents>
                                        </rx:Button>
                                 </Items>
                                 </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentName" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnUploaded" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusId" runat="server"></rx:Hidden>
            <rx:GridPanel runat="server" ID="GridPanelSenderPerson" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
                Height="80" Width="1200" Mode="Remote" AjaxPostable="true" Editable="false" Visible="true">
                <DataContainer>
                    <DataSource OnEvent="GrdLimitApproverList">
                    </DataSource>
                </DataContainer>  
                <ColumnModel>
                    <Columns>
                        <rx:GridColumns ColumnId="Id" Width="100" Header="Id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="New_LimitApproverManagementDetailConfirmId" />
                        <rx:GridColumns ColumnId="new_TransactionTypeIdName" Width="100" Header="Işlem Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_TransactionTypeIdName" />
                        <rx:GridColumns ColumnId="new_FirstAmount" Width="100" Header="Tutar-1" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_FirstAmount" />
                        <rx:GridColumns ColumnId="new_SecondAmount" Width="100" Header="Tutar-2" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SecondAmount" />
                        <rx:GridColumns ColumnId="new_FirstApproverId" Width="100" Header="new_FirstApproverId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_FirstApproverId" />
                        <rx:GridColumns ColumnId="new_FirstApproverIdName" Width="100" Header="1.Onaycı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_FirstApproverIdName" />
                        <rx:GridColumns ColumnId="new_SecondApproverId" Width="100" Header="new_SecondApproverId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_SecondApproverId" />
                        <rx:GridColumns ColumnId="new_SecondApproverIdName" Width="100" Header="2.Onaycı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SecondApproverIdName" />
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
                <TopBar>
                    <rx:ToolBar ID="toolBar1" runat="server">
                        <Items>                          
                            <rx:ToolbarButton ID="BtnDelete" runat="server" Icon="Delete" Text="<b>Seçili Kayıtları Sil</b>">
                                <AjaxEvents>
                                    <Click OnEvent="DeleteDetail" Before="return checkDelete();">
                                        <EventMask ShowMask="true" Msg="Siliniyor..." />
                                    </Click>
                                </AjaxEvents>
                            </rx:ToolbarButton>
                        </Items>
                    </rx:ToolBar>
                </TopBar>
            </rx:GridPanel>

            <rx:PanelX runat="server" ID="PanelX2" AutoHeight="Normal" Height="0" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" >
            <Buttons>
                 <rx:Button ID="BtnAccept" runat="server" Text="Kaydı Tamamla" Icon="Accept" Visible="true" AutoPostBack="true">
                    <AjaxEvents>
                        <Click OnEvent="Complete"></Click>
                    </AjaxEvents>
                </rx:Button>

                 <rx:Button ID="BtnRecordUpdate" runat="server" Text="Güncelle" Icon="Accept" Visible="true" AutoPostBack="true">
                    <AjaxEvents>
                        <Click OnEvent="RecordUpdate"></Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
        </div>
    </form>
</body>
</html>
