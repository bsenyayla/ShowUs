<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CorporatedPreInfoNewRegistrationControl.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Corporated.CorporatedPreInfoNewRegistrationControl" %>

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

            if (documentName.getValue() == "")
                return;
            
            lblDocumentName.setValue("");
            lblDocumentName.setValue(documentName.getValue());
            windowFileUpload.show();
            
           /*
            var config = "../ISV/TU/Corporated/CorporatedPreInfoNewRegistrationFileUpload.aspx?RecordId=" + hdnRecId.getValue() + "&MersisNo=" + new_CorparateCentralRegistryServiceNumber.getValue() + '&DocumentId=' + documentId.getValue() + '&DocumentName=' + documentName.getValue();
            var title = "Dosya Yükleme Ekranı";
            window.top.newWindow(config, { title: title, width: 400, height: 270, resizable: false });
            */
            
        }

        function checkDelete() {
            var ret = confirm('Seçili kayıt silinecek, Emin misiniz?');
            return ret;
        }

        <%
        string islem = QueryHelper.GetString("islem");
        string  mesajVer  = QueryHelper.GetString("mesajver");
        string mesaj = QueryHelper.GetString("mesaj");
        if (islem == "islemTamam")
            mesaj = "İşlem tamamlandı.";


        if (!String.IsNullOrEmpty(islem))
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

        <%
        if (!String.IsNullOrEmpty(mesajVer))
        {
        %>
        
            alert('<%=mesaj%>');
        <%
        }
        %>
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <div>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="200" AutoWidth="true" Collapsed="false" Collapsible="False"
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
                                <cc1:CrmComboComp runat="server" id="new_New_CorporatedType" objectid="201900030" uniquename="new_New_CorporatedType"
                                    width="200" pagesize="50" fieldlabel="150" FieldLabelWidth="150">
                                            </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:crmpicklistcomp runat="server" id="new_StatusId" objectid="201900030" uniquename="new_StatusId"
                                    width="200" pagesize="50" fieldlabel="150" FieldLabelWidth="150">
                                 </cc1:crmpicklistcomp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <rx:MultiField runat="server" ID="mfsender" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmTextFieldComp ID="new_CorparateCentralRegistryServiceNumber" runat="server" ObjectId="201900030" UniqueName="new_CorparateCentralRegistryServiceNumber"
                                            FieldLabelWidth="150" Width="200" PageSize="50" FieldLabelShow="True">
                                        </cc1:CrmTextFieldComp>
                                    </Items>
                                </rx:MultiField> 
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout6" runat="server">
                            <Body>
                                <rx:MultiField runat="server" ID="MultiField5" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmTextFieldComp ID="new_CorparateCentralRegistryServiceQueryRefNumber" runat="server" ObjectId="201900030" UniqueName="new_CorparateCentralRegistryServiceQueryRefNumber"
                                            FieldLabelWidth="150" Width="200" PageSize="50" FieldLabelShow="True">
                                        </cc1:CrmTextFieldComp>
                                    </Items>
                                </rx:MultiField> 
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout10">
                            <Body>
                                <rx:MultiField runat="server" ID="MultiField1" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmTextFieldComp ID="new_CorparateName" runat="server" ObjectId="201900030" UniqueName="new_CorparateName"
                                            FieldLabelWidth="150" Width="200" PageSize="50" FieldLabelShow="True">
                                        </cc1:CrmTextFieldComp>
                                    </Items>
                                </rx:MultiField>                                
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
               <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="50%">
               <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <rx:MultiField runat="server" ID="MultiField4" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmTextFieldComp ID="new_CorparateTaxNo" runat="server" ObjectId="201900030" UniqueName="new_CorparateTaxNo"
                                            FieldLabelWidth="150" Width="200" PageSize="50" FieldLabelShow="True">
                                        </cc1:CrmTextFieldComp>
                                    </Items>
                                </rx:MultiField>                                
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <rx:MultiField runat="server" ID="MultiField2" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmTextFieldComp ID="new_MobilePhone" runat="server" ObjectId="201900030" UniqueName="new_MobilePhone"
                                            FieldLabelWidth="150" Width="200" PageSize="50" FieldLabelShow="True">
                                        </cc1:CrmTextFieldComp>
                                    </Items>
                                </rx:MultiField>                                
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <rx:MultiField runat="server" ID="MultiField3" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmTextFieldComp ID="new_EMail" runat="server" ObjectId="201900030" UniqueName="new_EMail"
                                            FieldLabelWidth="150" Width="200" PageSize="50" FieldLabelShow="True">
                                        </cc1:CrmTextFieldComp>
                                    </Items>
                                </rx:MultiField>                                
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <rx:MultiField runat="server" ID="MultiField6" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmComboComp ID="new_NationalityId" runat="server" ObjectId="201900030" UniqueName="new_NationalityId"
                                            FieldLabelWidth="150" Width="200" PageSize="50" FieldLabelShow="True">
                                        </cc1:CrmComboComp>
                                    </Items>
                                </rx:MultiField>                                
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout runat="server" ID="RowLayout8">
                            <Body>
                                <rx:MultiField runat="server" ID="MultiField7" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmComboComp ID="new_HomeCountryId" runat="server" ObjectId="201900030" UniqueName="new_HomeCountryId"
                                            FieldLabelWidth="150" Width="200" PageSize="50" FieldLabelShow="True">
                                        </cc1:CrmComboComp>
                                        
                                    </Items>
                                </rx:MultiField>                                
                            </Body>
                        </rx:RowLayout>
               </Rows>
               </rx:ColumnLayout>
            </Body>
            <Buttons>
                <rx:Button ID="BtnUpload" runat="server" Text="Güncelle" Icon="Add" Visible="true" AutoPostBack="true">
                    <AjaxEvents>
                        <Click OnEvent="RecordUpdate"></Click>
                    </AjaxEvents>
                </rx:Button>
                <rx:Button ID="btnAccept" runat="server" Text="Tamamla" Icon="Accept" Visible="true" AutoPostBack="true">
                    <AjaxEvents>
                        <Click Before="return confirm('Firma için gerekli tüm evraklar tamamlanmıştır. Firmaya ÖHS imzalaması için kurye yönlendirilecektir.Onaylıyor musunuz?')" OnEvent="RecordAccept"></Click>
                    </AjaxEvents>
                </rx:Button>


            </Buttons>
        </rx:PanelX>

            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentName" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnUploaded" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusId" runat="server"></rx:Hidden>
            <rx:GridPanel runat="server" ID="GridPanelConfirmHistory" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
                Height="500" AutoLoad="true" Width="1200" Mode="Remote" AjaxPostable="true">
                <DataContainer>
                    <DataSource OnEvent="GrdCorporatedPreInfoDocument">
                    </DataSource>
                </DataContainer>  
                <ColumnModel>
                    <Columns>
                        <rx:GridColumns ColumnId="Id" Width="100" Header="Id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="Id" />

                        <rx:GridColumns ColumnId="DocumentId" Width="150" Header="Döküman Id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="DocumentId" />
                        <rx:GridColumns ColumnId="CorporateTypeName" Width="100" Header="Döküman Firma Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="CorporateTypeName" Editable="false">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="DocumentName" Width="150" Header="Döküman" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="DocumentName" />
                        <rx:GridColumns ColumnId="DocumentTypeId" Width="150" Header="Döküman Tip Id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="DocumentTypeId" />
                        <rx:GridColumns ColumnId="DocumentTypeName" Width="150" Header="Döküman Tip" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="DocumentTypeName" />
                        <rx:GridColumns ColumnId="FullPath" Width="350" Header="Dosya Yolu" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="FullPath">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="Requirement" Width="100" Header="Zorunluluk" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="Requirement" Editable="false">
                        </rx:GridColumns> 
                        <rx:GridColumns ColumnType="Check" ColumnId="Uploaded" Width="100" Header="Yüklendi Mi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="Uploaded" Editable="false">
                        </rx:GridColumns> 
                        <rx:GridColumns ColumnId="UploadDate" Width="100" Header="Yüklenme Tarih" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="UploadDate" />
                    </Columns>
                </ColumnModel>
                <SelectionModel>
                    <rx:RowSelectionModel ID="GridPanelConfirmHistoryRowSelectionModel" runat="server" ShowNumber="true"
                        SingleSelect="true">
                        <Listeners>
                            <RowClick Handler="SetValueHidden();"></RowClick>
                            <RowDblClick Handler="SetValueHidden();ShowUploadDetail();"></RowDblClick>
                        </Listeners>
                        <AjaxEvents>
                        </AjaxEvents>
                    </rx:RowSelectionModel>
                </SelectionModel>
                <LoadMask ShowMask="true" />
                <TopBar>
                    <rx:ToolBar ID="toolBar1" runat="server">
                        <Items>
<%--                            <rx:Label ID="label1" runat="server" ImageUrl="../../../images/if_phone_transfer_32587.png" ImageHeight="36" ImageWidth="36" Width="40">
                            </rx:Label>--%>
                            
                          <rx:ToolbarButton ID="ToolbarButton1" runat="server" Icon="ArrowUp" Text="<b>Dosya Yükle</b>">
                                <Listeners>
                                    <Click Handler="ShowUploadDetail();"></Click>
                                </Listeners>
                            </rx:ToolbarButton>
                            <rx:ToolbarSeparator ID="ToolbarSeparator7" runat="server"></rx:ToolbarSeparator>
                            <rx:ToolbarButton ID="ToolbarButton4" runat="server" Icon="TimeGo" Text="<b>Dosyayı İndir</b>" Download="true">
                                <AjaxEvents>
                                    <Click OnEvent="Process"></Click>
                                </AjaxEvents>
                            </rx:ToolbarButton>
  
                            <%--
                            <rx:ToolbarButton ID="BtnDelete" runat="server" Icon="Delete" Text="<b>Seçili Dökümanı Sil</b>">
                                <AjaxEvents>
                                    <Click OnEvent="DeleteDocument" Before="return checkDelete();">
                                        <EventMask ShowMask="true" Msg="Siliniyor..." />
                                    </Click>
                                </AjaxEvents>
                            </rx:ToolbarButton>
                            --%>
                        </Items>
                    </rx:ToolBar>
                </TopBar>

            </rx:GridPanel>


           

        <rx:Window ID="windowFileUpload" runat="server" Width="400" Height="200" Modal="true"
                CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
                CloseAction="Hide" ShowOnLoad="false">
                <Body>
                    <table width="100%" style="padding: 10px">
                        <tr>
                            <td style="padding-left: 10px"><b>Döküman Adı</b></td>
                            <td style="padding-left: 10px">
                               <rx:Label runat="server" Text="" ID="lblDocumentName" Width="10"></rx:Label>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-left: 10px">Dosya</td>
                            <td style="padding-left: 10px">
                                        <rx:FileUpload ID="senderDocumentFile" runat="server" AutoWidth="true" FieldLabelShow ="false">
                                        </rx:FileUpload>                               
                             </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="height: 10px"></td>
                        </tr>
                        <tr>
                            <td colspan="2" style="padding-left: 10px;">
                                <rx:Button ID="btnSaveRecord" runat="server" Text="Yükle" Icon="ArrowUp">
                                    <AjaxEvents>
                                        <Click OnEvent="FileUpload"></Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </td>
                        </tr>
                    </table>
                </Body>
            </rx:Window>

        </div>
    </form>

     

     
</body>
</html>
