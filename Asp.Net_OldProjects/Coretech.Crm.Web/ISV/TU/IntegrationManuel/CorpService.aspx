<%@ Page Language="C#" AutoEventWireup="true" Inherits="IntegrationManuel_CorpService" ValidateRequest="false" Codebehind="CorpService.aspx.cs" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        body
        {
            font-family: Verdana;
            font-size: 10px;
        }
        
        input 
        {
            font-family: Verdana;
            font-size: 10px;
        }
        
        label
        {
            width: 200px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <table>
            <tr>
                <td style="width:250px">Kullanıcı</td>
                <td><asp:TextBox ID="tUserName" runat="server" Text="epos" />
                <asp:Button ID="bSetCurrentUser" runat="server" OnClick="SetCurrentUser" Text="Sistem Kullanıcısını Ata" /></td>
            </tr>
            <tr>
                <td>Versiyon</td>
                <td>
                    <asp:DropDownList ID="ddlVersions" runat="server" OnSelectedIndexChanged="VersionChanged" AutoPostBack="true">
                        <asp:ListItem Text="1.0" Value="TuFactory.WebService.CorpService, TuFactory" Selected="True" />
                        <asp:ListItem Text="1.1" Value="TuFactory.WebService.CorpIntegration.v1_1.CorpService, TuFactory" />
                        <asp:ListItem Text="1.2" Value="TuFactory.WebService.CorpIntegration.v1_2.CorpService, TuFactory" />
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td>Metot</td>
                <td><asp:DropDownList ID="ddlMethods" runat="server" OnSelectedIndexChanged="MethodChanged" AutoPostBack="true"></asp:DropDownList></td>
            </tr>
        </table>
        <asp:Repeater ID="rpParams" runat="server" OnItemDataBound="ParametersItemDataBound">
            <HeaderTemplate>
                <table>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td style="width:250px"><asp:Literal ID="lParamName" runat="server" /></td>
                    <td><asp:TextBox ID="tParamValue" runat="server" /></td>
                </tr>
            </ItemTemplate>
            <FooterTemplate>
                </table>
            </FooterTemplate>
        </asp:Repeater>
        <p><asp:Button ID="bRequest" runat="server" OnClick="DoRequest" Text="Çağır" /></p>
        <p><asp:TextBox ID="tResult" runat="server" TextMode="MultiLine" Width="100%" Rows="12" Visible="false" /></p>
    </div>
    </form>
</body>
</html>
