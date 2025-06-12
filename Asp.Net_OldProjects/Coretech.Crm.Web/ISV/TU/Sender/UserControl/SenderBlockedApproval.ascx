<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="Sender_UserControl_SenderBlockedApproval" CodeBehind="SenderBlockedApproval.ascx.cs" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>

<rx:PanelX ID="startApplication" runat="server" AutoHeight="Normal" Height="0">
    <Body>
      
    </Body>
    <Buttons>
          <rx:Button ID="BtnAccept" runat="server" Text="Onayla" Icon="Accept" Visible="false" AutoPostBack="true">
<%--            <AjaxEvents>
                <Click OnEvent="Confirm" Success="alert('test');window.top.R.WindowMng.getActiveWindow().hide();" ></Click>
            </AjaxEvents>--%>
            <AjaxEvents>
                <Click OnEvent="Confirm"></Click>
            </AjaxEvents>
        </rx:Button>
           <rx:Button ID="BtnReject" runat="server" Text="Reddet" Icon="BookEdit" Visible="false" AutoPostBack="true">
            <AjaxEvents>
                <Click OnEvent="Reject" ></Click>
            </AjaxEvents>
        </rx:Button>
    </Buttons>
</rx:PanelX>


    <script type="text/javascript">

    function closeWindowAscx()
    {
        alert('İlgili işlem onaylandı.');
        window.top.R.WindowMng.getActiveWindow().hide();
    }
    </script>







