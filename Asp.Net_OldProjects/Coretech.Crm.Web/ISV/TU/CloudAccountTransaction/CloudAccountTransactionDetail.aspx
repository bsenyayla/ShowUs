<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CloudAccountTransactionDetail.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.CloudAccountTransaction.CloudAccountTransactionDetail" ValidateRequest="false" %>

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
        if (islem == "islemTamam")
            mesaj = "Ofis kaydı güncellenmiştir.";
        if (islem == "islemOnay")
            mesaj = "İşlem onay beklemektedir.";
        if (islem == "islemTamamOnay")
            mesaj = "İşlem onaylanmıştır.";
        
        if (islem=="islemOnay")
        {
        %>
        function closeWindowAscx(mesaj) {
                if (mesaj!='')
                    alert(mesaj);
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
            <rx:Hidden ID="hdnTransactionTypeId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnTransactionType" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatus" runat="server"></rx:Hidden>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="600" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Bulut Tahsilat Hareketi">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="90%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout5" runat="server">
                            <Body>
                                   <%--<cc1:CrmComboComp runat="server" ID="new_OfficeId" ObjectId="202000035" UniqueName="new_OfficeId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" LookupViewUniqueName="CloudAccountTransactionOfficeLookup2" ReadOnly="true">
                                    </cc1:CrmComboComp>--%>


                                
                                   <cc1:CrmComboComp runat="server" ID="new_OfficeId" ObjectId="202000035" UniqueName="new_OfficeId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" LookupViewUniqueName="CloudAccountTransactionOfficeLookup2" RequirementLevel="None" AutoLoad="true" >
                                    <DataContainer>
                                        <DataSource OnEvent="newOfficeLoad">
                                        </DataSource>
                                    </DataContainer>
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout6" runat="server">
                            <Body>
                                <cc1:CrmDateFieldComp ID="cloudPaymentDateS" runat="server" ObjectId="202000035" UniqueName="new_CloudPaymentDate"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout21" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_CloudPaymentId" runat="server" ObjectId="202000035" UniqueName="new_CloudPaymentId"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout7" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="Reference" runat="server" ObjectId="202000035" UniqueName="Reference"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout8" runat="server">
                            <Body>
                                <cc1:CrmDecimalComp ID="new_Amount" runat="server" ObjectId="202000035" UniqueName="new_Amount"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmDecimalComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout9" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_CurrencyCode" runat="server" ObjectId="202000035" UniqueName="new_CurrencyCode"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout10" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_PaymentExpCode" runat="server" ObjectId="202000035" UniqueName="new_PaymentExpCode"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout11" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderFullName" runat="server" ObjectId="202000035" UniqueName="new_SenderFullName"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout12" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderIdentityNo" runat="server" ObjectId="202000035" UniqueName="new_SenderIdentityNo"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout13" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderIban" runat="server" ObjectId="202000035" UniqueName="new_SenderIban"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout14" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_RecipientIban" runat="server" ObjectId="202000035" UniqueName="new_RecipientIban"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_RecipentBankName" runat="server" ObjectId="202000035" UniqueName="new_RecipentBankName"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout15" runat="server">
                            <Body>
                                <cc1:CrmTextAreaComp ID="new_Explanation" runat="server" ObjectId="202000035" UniqueName="new_Explanation"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextAreaComp>
                            </Body>
                        </rx:RowLayout>
                         <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_ErrorStatus" ObjectId="202000035" UniqueName="new_ErrorStatus" Hidden="false"
                                            Width="10" PageSize="50" FieldLabel="150" RequirementLevel="None" AutoLoad="true" ReadOnly="true" Disabled="true" >
                               </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                      <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_ErrorExplanation" runat="server" ObjectId="202000035" UniqueName="new_ErrorExplanation"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        
                        <rx:RowLayout ID="RowLayout17" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_VirmanIdName" runat="server" ObjectId="202000035" UniqueName="new_VirmanIdName"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_BankTransactionRefNo" runat="server" ObjectId="202000035" UniqueName="new_BankTransactionRefNo"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>



                        <rx:RowLayout ID="RowLayout18" runat="server">
                            <Body>
                                    <cc1:CrmBooleanComp ID="new_IsNkolayRepresentative" runat="server" ObjectId="202000035" UniqueName="new_IsNkolayRepresentative"
                                                FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                            </cc1:CrmBooleanComp>
                         </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout20" runat="server">
                            <Body>
                                    <cc1:CrmBooleanComp ID="new_NKolayAccountTransferCompleted" runat="server" ObjectId="202000035" UniqueName="new_NKolayAccountTransferCompleted"
                                                FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                            </cc1:CrmBooleanComp>
                         </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout19" runat="server">
                            <Body>
                                    <cc1:CrmBooleanComp ID="new_IsNKolayLimitCreate" runat="server" ObjectId="202000035" UniqueName="new_IsNKolayLimitCreate"
                                                FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                            </cc1:CrmBooleanComp>
                         </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout16" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_NKolayLimitRefNo" runat="server" ObjectId="202000035" UniqueName="new_NKolayLimitRefNo"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>

                 <rx:Button ID="BtnCancel" runat="server" Text="Iptal Et" Icon="Cancel" Visible="true" AutoPostBack="true">
                    <AjaxEvents>
                        <Click OnEvent="CancelOnEvent"></Click>
                    </AjaxEvents>
                </rx:Button>

                 <rx:Button ID="BtnSave" runat="server" Text="Kaydet" Icon="BookEdit" Visible="true" AutoPostBack="true">
                    <AjaxEvents>
                        <Click OnEvent="SaveOnEvent"></Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>

            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnCloudStatusId" runat="server"></rx:Hidden>

         


        <rx:Window ID="windowReject" runat="server" Width="400" Height="200" Modal="true"
                CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
                CloseAction="Hide" ShowOnLoad="false">
                <Body>
                    <table width="100%" style="padding: 10px">
                        <tr>
                            <td style="padding-left: 10px">Açıklama :</td>
                            <td style="padding-left: 10px">
                               
                               <cc1:CrmTextAreaComp runat="server" id="new_RejectDescription" objectid="202000027" uniquename="new_RejectDescription"
                                    width="200" pagesize="50" fieldlabel="150" FieldLabelWidth="150" FieldLabelShow ="false">
                                 </cc1:CrmTextAreaComp>                                                           
                             </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="height: 10px"></td>
                        </tr>
                        <tr>
                            <td colspan="2" style="padding-left: 10px;">
                                 <rx:Button ID="BtnRejectedWindows" runat="server" Text="Reddet" Icon="BookEdit" Visible="true" AutoPostBack="true">
                                    <AjaxEvents>
                                        <Click OnEvent="Rejected"></Click>
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
