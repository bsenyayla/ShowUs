<%@ Control Language="C#" AutoEventWireup="true" Inherits="Announcement_AnnouncementControl" Codebehind="AnnouncementControl.ascx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>


<rx:PanelX runat="server" ID="Fieldset2" AutoHeight="Normal" Height="50" AutoWidth="true"
    Collapsible="false" Border="false">
    <Body>    
        <rx:Button ID="btnTakeDownAnnoucement" runat="server" Text="Yayından Kaldır" Icon="ControlRemove">
            <AjaxEvents>
                <Click OnEvent="TakeDownAnnoucement"></Click>
            </AjaxEvents>
        </rx:Button>
    </Body>
</rx:PanelX>