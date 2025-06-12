<%@ Control Language="C#" AutoEventWireup="true" 
    CodeBehind="CourierMasterUC.ascx.cs" 
    Inherits="CourierMasterUC" %>


<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>


<rx:PanelX runat="server" ID="Fieldset2" AutoHeight="Normal" Height="38" AutoWidth="true"
    Collapsible="false" Border="true">
    <Body>    
        <table>
            <tr>
                <td>        <rx:Button ID="btnTakeDownAnnoucement" runat="server" Text="Kurye Adres Güncelle" Icon="ControlRemove">
            <AjaxEvents>
                <Click OnEvent="TakeDownAnnoucement"></Click>
            </AjaxEvents>
        </rx:Button></td>
                <td>                <rx:Button ID="btnCourierCancel" runat="server" Text="Kurye iptal" Icon="ControlRemove">
            <AjaxEvents>
                <Click OnEvent="CourierCancel"></Click>
            </AjaxEvents>
        </rx:Button></td>

            </tr></table>



    </Body>
</rx:PanelX>