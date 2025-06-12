<%@ Page Language="C#" AutoEventWireup="true" Inherits="TransferResult" Codebehind="TransferResult.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="hdnReportId">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnRecId">
        </rx:Hidden>
        <rx:Button ID="btnInstruction" runat="server">
            <AjaxEvents>
                <Click OnEvent="BtnInstructionOnEvent"></Click>
            </AjaxEvents>
        </rx:Button>
    </form>
</body>
</html>
<script language="javascript">
    function OpenInstruction() {
        btnInstruction.click();
    }
    function ShowInstruction() {
        if (hdnReportId.getValue() != "")
            window.top.ShowReport(hdnReportId.getValue(), hdnRecId.getValue(), "&doExport=1&OpenInWindow=1", false);
    }
</script>
