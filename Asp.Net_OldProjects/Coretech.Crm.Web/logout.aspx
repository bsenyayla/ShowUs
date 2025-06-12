<%@ Page Language="C#" AutoEventWireup="true" Inherits="logout" Codebehind="logout.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style>
        html, body, #wrapper
        {
            height: 100%;
            margin: 0;
            padding: 0;
            border: none;
            text-align: center;
        }
        #wrapper
        {
            margin: 0 auto;
            text-align: left;
            vertical-align: middle;
            width: 400px;
        }
    </style>
</head>
<body style="background-image: url(images/desktop.jpg)">
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <table id="wrapper">
        <tr>
            <td>
                <a href="Login.aspx?dologin=1">
                    <img src="images/login_key.png" />
                </a>
            </td>
        </tr>
    </table>
    </form>
</body>
</html>
