<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Administrations_SecurityRoles_RoleUsersRefleX" Codebehind="RoleUsersRefleX.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR" />
    <ajx:Hidden runat="server" ID="hdnRoleId" />
    <ajx:GridPanel runat="server" ID="GridPanelUsers" AutoWidth="true" AutoHeight="Auto"
        Height="150" Editable="false" Mode="Remote" AutoLoad="true" Width="1200" AjaxPostable="true">
        <DataContainer>
            <DataSource OnEvent="ToolbarButtonFindClick">
            </DataSource>
            <Parameters>
                <ajx:Parameter Name="start" Value="1" Mode="Value"></ajx:Parameter>
                <ajx:Parameter Name="limit" Value="50" Mode="Value"></ajx:Parameter>
            </Parameters>
        </DataContainer>
        <SelectionModel>
            <ajx:RowSelectionModel ID="GridPanelUsersRowSelectionModel1" runat="server" ShowNumber="true">
            </ajx:RowSelectionModel>
        </SelectionModel>
        <BottomBar>
            <ajx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelUsers">
                <Buttons>
                    <ajx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload">
                        <AjaxEvents>
                            <Click OnEvent="ToolbarButtonFindClick">
                                <EventMask ShowMask="false" />
                                <ExtraParams>
                                    <ajx:Parameter Name="Excel" Value="1" Mode="Value" />
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ajx:SmallButton>
                </Buttons>
            </ajx:PagingToolBar>
        </BottomBar>
        <LoadMask ShowMask="true" />
    </ajx:GridPanel>
    </form>
</body>
</html>
