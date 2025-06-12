<%@ Control Language="C#" AutoEventWireup="true" Inherits="CustAccount_CustomerAccountsDetail_CustAccountAdd" CodeBehind="CustAccountAdd.ascx.cs" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<script>

    function redirectToPage(urlParam) {
        window.top.newWindowRefleX(window.top.GetWebAppRoot + '/CrmPages/AutoPages/EditReflex.aspx' + urlParam, { maximized: false, width: 1100, height: 400, resizable: false, modal: true, maximizable: true });
    }
</script>

