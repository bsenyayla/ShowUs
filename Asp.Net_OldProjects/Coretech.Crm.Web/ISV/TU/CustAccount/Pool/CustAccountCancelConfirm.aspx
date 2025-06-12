<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_Pool_CustAccountCancelConfirm" Codebehind="CustAccountCancelConfirm.aspx.cs" %>

<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<%@ Register TagPrefix="uc1" TagName="SenderFinde" Src="../Sender/SenderFinde.ascx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../Js/Global.js"></script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
         <rx:RegisterResources runat="server" ID="RR" />
        <rx:PanelX runat="server" ID="PanelX3" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="False">

            <Body>
                <rx:PanelX runat="server" ID="CustAccountOperationsDetail"  Title="İşlem Detayı" AutoHeight="Auto" AutoWidth="True">
                    <AutoLoad Url="about:blank" ShowMask="true" />
                </rx:PanelX>
            </Body>
             <Buttons>
                <rx:Button runat="server" ID="btnClose"   Icon="Cancel" Text="CRM.NEW_CUSTACCOUNTOPERATIONS_CLOSEACCOUNT" 
                    Width="120">
                    <AjaxEvents>
                        <Click OnEvent="btnDeleteOnClick">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                 <rx:Button runat="server" ID="btnCancel"   Icon="Add" Text="CRM.NEW_CUSTACCOUNTOPERATIONS_CLOSE_CANCEL_ACCOUNT" 
                    Width="120">
                    <AjaxEvents>
                        <Click OnEvent="btnCancelOnClick">
                        </Click>
                    </AjaxEvents>
                </rx:Button>

            </Buttons>
        </rx:PanelX>
    </form>
</body>
</html>
