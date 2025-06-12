<%@ Control Language="C#" AutoEventWireup="true" Inherits="CustAccount_CustomerAccountsDetail_UPTCardAdd" Codebehind="UPTCardAdd.ascx.cs" %>
<script>

    function redirectToPage(urlParam) {
        window.top.newWindowRefleX(window.top.GetWebAppRoot + '/CrmPages/AutoPages/EditReflex.aspx' + urlParam, { maximized: false, width: 1100, height: 400, resizable: false, modal: true, maximizable: true });
    }
</script>