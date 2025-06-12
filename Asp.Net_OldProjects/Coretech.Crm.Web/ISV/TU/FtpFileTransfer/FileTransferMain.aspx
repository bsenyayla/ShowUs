<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="FtpFileTransfer_FileTransferMain" Codebehind="FileTransferMain.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR" />
    <rx:TabPanel runat="server" ID="TabPanel1" AutoHeight="Auto" AutoWidth="true">
        <Tabs>
            <rx:Tab ID="FILETRANSFERINPUT" runat="server" Title="CRM.FILETRANSFERINPUT" TabMode="Frame"
                Enabled="true" Url="about:blank" Closable="false">
            </rx:Tab>
            <rx:Tab ID="FILETRANSFEROUTPUT" runat="server" Title="CRM.FILETRANSFERINPUT" TabMode="Frame"
                Enabled="true" Url="about:blank" Closable="false">
            </rx:Tab>
            <rx:Tab ID="FTPSENDTRANSFER" runat="server" Title="CRM.SENDTRASNFER" TabMode="Frame"
                Enabled="true" Url="about:blank" Closable="false">
            </rx:Tab>
        </Tabs>
    </rx:TabPanel>
    </form>
</body>
</html>
