﻿<%@ Page Language="C#" AutoEventWireup="true" Inherits="Transfer_Transfer" Codebehind="Transfer.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<title></title>
   <script src="JS/TransferFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script> 
</head>
<body>
    <form id="form1" runat="server">
   <rx:RegisterResources runat="server" ID="RR"/>
    </form>
</body>
</html>
