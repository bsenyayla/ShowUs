<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Entity_ExportImport_ExportImport" Codebehind="ExportImport.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ajx:RegisterResources runat="server" ID="RR"/>
        <ajx:PanelX runat="server" ID="PanelX1" Frame="false" Border="false">
            <Body>
                <ajx:TreeGrid runat="server" ID="ExportList" Title="Deneme TreeGrid" Width="900"
                    Height="300" Mode="Remote" Checkable="true" AutoWidth="false" Collapsible="true">
                    <Columns>
                        <ajx:TreeGridColumn DataIndex="Name" Width="230" Header="Name">
                        </ajx:TreeGridColumn>
                    </Columns>
                    <Root>
                        
                    </Root>
                </ajx:TreeGrid>
            </Body>
        </ajx:PanelX>
    </div>
    </form>
</body>
</html>
