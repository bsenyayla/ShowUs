<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_Pool_CustAccountReceipt" Codebehind="CustAccountReceipt.aspx.cs" %>

<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<%@ Register TagPrefix="uc1" TagName="SenderFinde" Src="../Sender/SenderFinde.ascx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../Js/Receipt.js"></script>
    <script src="../Js/Global.js"></script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
         <rx:RegisterResources runat="server" ID="RR" />
         <rx:Hidden runat="server" ID="hdnReportId">
        </rx:Hidden>
         <rx:Hidden runat="server" ID="hdnRecid">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdndoReceipt">
        </rx:Hidden>
      
        <rx:PanelX runat="server" ID="PanelX3" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="False">

            <Body>
                <rx:PanelX runat="server" ID="CustAccountOperationsDetail"  Title="İşlem Detayı" AutoHeight="Auto" AutoWidth="True">
                    <AutoLoad Url="about:blank" ShowMask="true" />
                </rx:PanelX>
            </Body>
             <Buttons>
                <rx:Button runat="server" ID="btnPrint"   Icon="Printer" Text="CRM.NEW_CUSTACCOUNTOPERATIONS_RECEIPT" 
                    Width="100">
                    <AjaxEvents>
                        <Click OnEvent="btnPrintOnClickEvent">
                        </Click>
                    </AjaxEvents>
                </rx:Button>

            </Buttons>
        </rx:PanelX>
    </form>
</body>
</html>
