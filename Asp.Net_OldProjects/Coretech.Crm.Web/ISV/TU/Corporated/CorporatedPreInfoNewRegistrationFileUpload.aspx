<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CorporatedPreInfoNewRegistrationFileUpload.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Corporated.CorporatedPreInfoNewRegistrationFileUpload" %>

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

        function ShowUploadDetail() {
            //var config = "../ISV/TU/Transfer/TransferDocument.aspx?ObjectId=" + operationTypeId.getValue() + "&RecordId=" + transferId.getValue();
            var defaulteditpageid = "";       
            
            var config = "../ISV/TU/Corporated/CorporatedPreInfoNewRegistrationFileUpload.aspx?RecordId=" + hdnRecId.getValue();
            var title = "Dosya Yükleme Ekranı";


            //var config = "/CrmPages/AutoPages/EditReflex.aspx?ObjectId=201900037&recId=" + hdnRecId.getValue() + "&defaulteditpageid=" + defaulteditpageid + "&SourceFormType=NormList";

            window.top.newWindow(config, { title: title, width: 900, height: 600, resizable: false });
        }

        function checkDelete() {
            var ret = confirm('Seçili kayıt silinecek, Emin misiniz?');
            return ret;
        }

        <%
        string islem = QueryHelper.GetString("islem");
        string mesaj="";
        if (islem == "dosyaYuklendi")
            mesaj = "Dosya yüklendi";
        
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
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <div>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="100" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Dosya Yükleme">
             <Body>
                    <rx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="100%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="RowLayout1">
                                <Body>

                                    <rx:Label runat="server" Text="" ID="lblDocumentName" Width="10"></rx:Label>

                                </Body>
                                </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout5">
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
                    <rx:Button ID="BtnAccept" runat="server" Text="Yükle" Icon="ArrowUp" Visible="true" AutoPostBack="true">
                        <AjaxEvents>
                            <Click OnEvent="FileUpload"></Click>
                        </AjaxEvents>
                    </rx:Button>
                </Buttons>
        </rx:PanelX>

            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnMersisNo" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnDocumentId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnDocumentName" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusId" runat="server"></rx:Hidden>
          
        </div>
    </form>
</body>
</html>
