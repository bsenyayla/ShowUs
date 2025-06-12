<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_ApprovePool_CustAccountMainPool" Codebehind="CustAccountMainPool.aspx.cs" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:TabPanel runat="server" ID="TabPanel1" AutoWidth="true" AjaxPostable="true">
        <Tabs>
             <%--<rx:Tab ID="TabCustAccountOpenCloseOperation" runat="server" Title="CRM.NEW_CUSTACCOUNTOPERATIONS_ACCOUNT_OPEN_CLOSE_APPROVEPOOL" TabMode="Frame"
                Url="DetailPool/CustAccountOpenCloseApprovePool.aspx" Closeable="false" Hidden="true" TabIndex="1">
            </rx:Tab>
            
            <rx:Tab ID="TabCustAccountCashDrawCashDepositOperation" runat="server" Title="CRM.NEW_CUSTACCOUNTOPERATIONS_CASH_DRAW_DEPOSIT_APPROVEPOOL" TabMode="Frame"
                Url="DetailPool/CustAccountDrawDepositApprovePool.aspx" Closeable="false" Hidden="true" TabIndex="2">
            </rx:Tab>

             <rx:Tab ID="TabCustAccountBlockedOperation" runat="server" Title="CRM.NEW_CUSTACCOUNTOPERATIONS_BLOCKEDACCOUNTS_APPROVEPOOL" TabMode="Frame"
                Url="DetailPool/CustAccountBlockApprove.aspx" Closeable="false" Hidden="true" TabIndex="3">
            </rx:Tab>--%>
        </Tabs>
    </rx:TabPanel>
    </form>
</body>
</html>
<%--<script type="text/javascript" charset="utf-8">
    
        TabPanel1.setactiveTab(tabID);
        TabPanel1.loadit($("tablbl_"+ tabID));
    
</script>--%>