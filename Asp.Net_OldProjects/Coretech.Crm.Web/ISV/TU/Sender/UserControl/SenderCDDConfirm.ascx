<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="Sender_UserControl_SenderCDDConfirm" CodeBehind="SenderCDDConfirm.ascx.cs" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>

<rx:PanelX ID="startApplication" runat="server" AutoHeight="Normal" Height="0">
    <Body>
    </Body>
    <Buttons>
        <rx:Button ID="BtnSenderUpdate" runat="server" Text="Güncelle" Icon="BookEdit" Visible="false">
            <AjaxEvents>
                <Click OnEvent="UpdateSenderType"></Click>
            </AjaxEvents>
        </rx:Button>
        <rx:Button ID="btnCreateDocuments" runat="server" Text="Dokümanları Oluştur" Icon="PageAdd" Visible="true">
            <AjaxEvents>
                <Click OnEvent="SenderDocumentCerate"></Click>
            </AjaxEvents>
        </rx:Button>
        <rx:Button ID="BtnCDDSendToConfirm" runat="server" Text="CDD Onay Gönder" Icon="Accept" Visible="false">
            <AjaxEvents>
                <Click OnEvent="SenderCDDSendToConfirm"></Click>
            </AjaxEvents>
        </rx:Button>
        <rx:Button ID="BtnUpdateFromService" runat="server" Text="Servisten Güncelle" Icon="BookEdit" Visible="false">
            <AjaxEvents>
                <Click OnEvent="UpdateSenderFromService"></Click>
            </AjaxEvents>
        </rx:Button>
    </Buttons>
</rx:PanelX>
<script type="text/javascript">
</script>

