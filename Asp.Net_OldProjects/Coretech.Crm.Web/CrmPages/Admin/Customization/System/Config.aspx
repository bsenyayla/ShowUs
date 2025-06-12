<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Config" Codebehind="Config.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR"/>
    <ajx:Button runat="server" ID="BtnEncrypt" Text="EncryptFile">
        <AjaxEvents>
            <Click OnEvent="BtnEncryptClickOnEvent">
            </Click>
        </AjaxEvents>
    </ajx:Button>
    <ajx:Button runat="server" ID="BtnDecrypt" Text="DecryptFile">
        <AjaxEvents>
            <Click OnEvent="BtnDecryptClickOnEvent">
            </Click>
        </AjaxEvents>
    </ajx:Button>
    </form>
</body>
</html>
