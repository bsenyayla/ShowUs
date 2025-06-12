<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ApprovalRoleManager.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.CustomApproval.ApprovalRoleManager" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        body
        {
            font-family: Calibri;
        }

        table
        {
            border-spacing: 0px;
        }

        caption {
          text-align: left;
          color: silver;
          font-weight: bold;
          text-transform: uppercase;
          padding: 5px;
        }

        thead {
          background: SteelBlue;
          color: white;
        }

        th,
        td {
          padding: 5px 10px;
          border-bottom: 1px solid SteelBlue;
        }

        tbody tr:nth-child(even) {
          background: WhiteSmoke;
        }

        thead tr th:nth-child(2),
        thead tr th:nth-child(3),
        tbody tr td:nth-child(2),
        tbody tr td:nth-child(3) {
          text-align: right;
        }

        tfoot {
          background: SeaGreen;
          color: white;
          text-align: right;
        }

        tfoot tr th:last-child {
          font-family: monospace;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <p>
                <strong>Onay Tipi:</strong>
                <asp:DropDownList ID="cfApprovalTypes" runat="server" Width="400" AutoPostBack="true" OnSelectedIndexChanged="GetRoles" />
                <asp:Button ID="bSetRoles" runat="server" Text="Rol Ata" OnClick="SetRoles" Width="150" Visible="false" />
                <asp:Literal ID="lResult" runat="server" Visible="false" />            
            </p>
            <asp:Repeater ID="rpRoles" runat="server" OnItemDataBound="RolesDataBound">
                <HeaderTemplate>
                    <table>
                        <thead>
                            <tr>
                                <th style="width: 400px">Rol</th>
                                <th style="width: 70px">Girişçi&nbsp;</th>
                                <th style="width: 70px">Onaycı&nbsp;</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td>
                            <asp:HiddenField ID="hRoleId" runat="server" />
                            <asp:Literal ID="lRoleName" runat="server" />
                        </td>
                        <td>
                            <asp:CheckBox ID="cbMaker" runat="server" />
                        </td>
                        <td>
                            <asp:CheckBox ID="cbChecker" runat="server" />
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </form>
</body>
</html>