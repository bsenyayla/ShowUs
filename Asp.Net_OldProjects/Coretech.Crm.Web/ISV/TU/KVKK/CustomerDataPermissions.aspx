﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerDataPermissions.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.KVKK.CustomerDataPermissions" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .smart-green {
            margin-left:auto;
            margin-right:auto;
            max-width: 500px;
            padding: 20px;
            font: 12px Arial, Helvetica, sans-serif;
            color: #666;
            border-radius: 5px;
            -webkit-border-radius: 5px;
            -moz-border-radius: 5px;
        }
        .smart-green label {
            display: block;
            margin: 0px 0px 5px;
        }
        .smart-green label>span {
            float: left;
            margin-top: 10px;
            color: #5E5E5E;
        }
        .smart-green input[type="text"], .smart-green input[type="email"], .smart-green textarea, .smart-green select {
            color: #555;
            height: 30px;
            line-height:15px;
            width: 100%;
            padding: 0px 0px 0px 10px;
            margin-top: 2px;
            border: 1px solid #E5E5E5;
            background: #FBFBFB;
            outline: 0;
            -webkit-box-shadow: inset 1px 1px 2px rgba(238, 238, 238, 0.2);
            box-shadow: inset 1px 1px 2px rgba(238, 238, 238, 0.2);
            font: normal 14px/14px Arial, Helvetica, sans-serif;
        }
        .smart-green textarea{
            height:100px;
            padding-top: 10px;
        }
        .smart-green select {
            background: url('down-arrow.png') no-repeat right, -moz-linear-gradient(top, #FBFBFB 0%, #E9E9E9 100%);
            background: url('down-arrow.png') no-repeat right, -webkit-gradient(linear, left top, left bottom, color-stop(0%,#FBFBFB), color-stop(100%,#E9E9E9));
           appearance:none;
            -webkit-appearance:none; 
           -moz-appearance: none;
            text-indent: 0.01px;
            text-overflow: '';
            width:100%;
            height:30px;
        }
        .smart-green .button {
            background-color: #9DC45F;
            border-radius: 5px;
            -webkit-border-radius: 5px;
            -moz-border-border-radius: 5px;
            border: none;
            padding: 10px 25px 10px 25px;
            color: #FFF;
            text-shadow: 1px 1px 1px #949494;
        }
        .smart-green .button:hover {
            background-color:#80A24A;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="smart-green">
            <asp:HiddenField ID="hOldPermissions" runat="server" />
            <asp:HiddenField ID="hDataUsagePermissionsGiven" runat="server" />
            <p><strong><asp:Literal ID="lCustomerCode" runat="server" /> - <asp:Literal ID="lCustomerName" runat="server" /></strong></p>
            <asp:Repeater ID="rpPermissions" runat="server" OnItemDataBound="PermissionItemDataBound">
                <HeaderTemplate>
                    <table>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><asp:CheckBox ID="cfIsAllowed" runat="server" /></td>
                        <td><asp:Label ID="lPermissionName" runat="server" /></td>
                        <td><asp:HiddenField ID="hPermission" runat="server" /></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
            <p>&nbsp;</p>
            <p>
                <asp:Button ID="bSavePermissions" runat="server" Text="İzinleri Kaydet" OnClick="SavePermissions" CssClass="button" />
            </p>
            <p><asp:Label ID="lResult" runat="server" /></p>
        </div>
    </form>
</body>
</html>