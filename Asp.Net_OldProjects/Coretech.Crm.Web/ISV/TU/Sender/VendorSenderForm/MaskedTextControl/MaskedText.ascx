<%@ Control Language="C#" AutoEventWireup="true" Inherits="Sender_VendorSenderForm_MaskedTextControl_MaskedText" Codebehind="MaskedText.ascx.cs" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>

<rx:TextField ID="ItemValueField" Hidden="true" runat="server">
    <Listeners>
        <Change Handler ="ItemValueFieldOnChange(e);" />
    </Listeners>
</rx:TextField>
<cc1:CrmTextFieldComp ID="ItemTextField" runat="server">
    <Listeners>
        <Blur Handler="ItemTextFieldOnChange(e);"/>
    </Listeners>
</cc1:CrmTextFieldComp>
<script src="MaskedTextControl/Js/MaskedText.js?<%=Coretech.Crm.Factory.App.Params.AppVersion %>" type="text/javascript"></script>
