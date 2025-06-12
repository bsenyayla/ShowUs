<%@ Control Language="C#" AutoEventWireup="true" Inherits="Sender_VendorSenderForm_MaskedDateControl_MaskedDate" Codebehind="MaskedDate.ascx.cs" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>

<rx:DateField ID="ItemValueField" Hidden="true" runat="server">
    <Listeners>
        <Change Handler ="ItemDateValueFieldOnChange(this);" />
    </Listeners>
</rx:DateField>
<cc1:CrmDateFieldComp ID="ItemTextField" runat="server">
    <Listeners>
        <Blur Handler="ItemDateTextFieldOnChange(e);"/>
    </Listeners>
</cc1:CrmDateFieldComp>
<script src="MaskedDateControl/Js/MaskedDate.js?<%=Coretech.Crm.Factory.App.Params.AppVersion %>" type="text/javascript"></script>