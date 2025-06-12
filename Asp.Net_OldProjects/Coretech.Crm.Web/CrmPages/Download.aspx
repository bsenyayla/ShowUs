<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Download" Codebehind="Download.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body onload="load();">
    <form id="form1" runat="server">
    <div style="display: none">
        <asp:TextBox runat="server" ID="xfile"></asp:TextBox>
    </div>
    </form>
    <script>
        function load() {
            document.location.href = document.getElementById("xfile").value;
        }
    </script>
</body>
</html>
