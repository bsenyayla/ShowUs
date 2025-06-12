<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CorporatedPreInfoStepCargo.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Corporated.CorporatedPreInfoStepCargo" %>

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
        string mesaj= QueryHelper.GetString("mesaj");

        if (islem == "islemTamam")
            mesaj = "İşlem tamamlandı.";
        
        if (islem!="")
        {
        %>
        function closeWindowAscx(islem) 
        {
            if(mesaj!="")
            {
                alert(islem);
            }
            window.top.R.WindowMng.getActiveWindow().hide();
        }
        closeWindowAscx('<%=mesaj%>');
        <%
        }
        %>
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <div>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="170" AutoWidth="true" Collapsed="false" Collapsible="False"
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
            
        </rx:PanelX>

            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentName" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnUploaded" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusId" runat="server"></rx:Hidden>

            <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="50"  AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true">
                <Body>
                    <rx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="100%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="RowLayout9">
                                <Body>

                                    <rx:Label runat="server" Text="Ödeme Hizmetleri Sözleşmesi" ID="lblDocumentName" Width="10"></rx:Label>

                                </Body>
                                </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout11">
                                <Body>

                                    <rx:MultiField ID="mfFileSys" FieldLabel="Dosya" runat="server">
                                        <Items>
                                            <rx:FileUpload ID="senderDocumentFile" runat="server" AutoWidth="true" FieldLabelShow ="false">
                                            </rx:FileUpload>
                                            <rx:Label runat="server" Text="  " ID="lbl1" Width="10"></rx:Label>
                                            <%--<rx:Button runat="server" ID="btnDownload" Icon="DiskDownload" Text="İndir" Download="true">
                                                <AjaxEvents>
                                                    <Click OnEvent="btnDownload_OnClick"></Click>
                                                </AjaxEvents>
                                            </rx:Button>--%>

                                        </Items>
                                    </rx:MultiField>

                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                </Body>
                        <Buttons>
                            <rx:Button ID="BtnUpload" runat="server" Text="Kapat" Icon="BinClosed" Visible="true" AutoPostBack="true">
                                <AjaxEvents>
                                    <Click OnEvent="FormClose"></Click>
                                </AjaxEvents>
                            </rx:Button>
                            <rx:Button ID="btnAccept" runat="server" Text="Tamamla" Icon="Accept" Visible="true" AutoPostBack="true">
                                <AjaxEvents>
                                    <Click OnEvent="FileUpload"></Click>
                                </AjaxEvents>
                            </rx:Button>
                        </Buttons>
            </rx:PanelX>

        </div>
    </form>
</body>
</html>
