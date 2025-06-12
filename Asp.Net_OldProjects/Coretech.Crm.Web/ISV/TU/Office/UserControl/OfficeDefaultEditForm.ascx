<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="OfficeDefaultEditForm.ascx.cs" Inherits="Office_UserControl_OfficeDefaultEditForm" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>


    <Buttons>
          <rx:Button ID="BtnGetFromService" runat="server" Text="VergiNo Sorgula" Icon="ApplicationGet" Visible="true">
            <AjaxEvents>
                <Click OnEvent="BtnGetFromService_OnClick" ></Click>
            </AjaxEvents>
        </rx:Button> 
    </Buttons>


<script type="text/javascript">
</script>
