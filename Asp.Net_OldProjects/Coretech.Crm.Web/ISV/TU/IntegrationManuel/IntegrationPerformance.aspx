<%@ Page Language="C#" AutoEventWireup="true" Inherits="IntegrationManuel_IntegrationPerformance" ValidateRequest="false" Codebehind="IntegrationPerformance.aspx.cs" %>
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
                <td style="width:250px">Tarih</td>
                <td><asp:TextBox ID="tDate" runat="server" /></td>
            </tr>
            <tr>
                <td style="width:250px">Minimum Yanıt Süresi</td>
                <td><asp:TextBox ID="tTime" runat="server" Text="30" /></td>
            </tr>
        </table>
        <p>
            <asp:Button ID="bGetReport" runat="server" OnClick="GetReport" Text="Raporu Getir" />
            <asp:Button ID="bExportExcel" runat="server" OnClick="ExportToExcel" Text="Excel'e Çıkar" />
        </p>
        <asp:GridView ID="gvReport" runat="server" AllowPaging="true" PageSize="100">
        </asp:GridView>
    </div>
    </form>
</body>
</html>
