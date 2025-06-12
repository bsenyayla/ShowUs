<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Administrations_SecurityRoles_UserSecurityRoleRefleX" Codebehind="UserSecurityRoleRefleX.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR"/>
    <ajx:GridPanel runat="server" ID="_grdsma" AutoHeight="Auto" AutoWidth="true" DisableSelection="true" AutoLoad="true"
        Mode="Remote">
        <TopBar>
            <ajx:ToolBar ID="Toolbar1" runat="server">
                <Items>
                    <ajx:ToolbarButton ID="RollAdd" runat="server" Icon="UserTick" Text="RollAdd">
                        <AjaxEvents>
                            <Click OnEvent="RollAddOnEvent">
                                <EventMask Msg="Roller Kayıt Ediliyor..." ShowMask="true" />
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                </Items>
            </ajx:ToolBar>
        </TopBar>
        <DataContainer>
            <DataSource OnEvent="StoreOnRefreshData">
                <Columns>
                    <ajx:Column Name="RoleId" />
                    <ajx:Column Name="Name" />
                    <ajx:Column Name="Selected"  />
                    <ajx:Column Name="StartDate" DataType="Date" />
                    <ajx:Column Name="EndDate"  DataType="Date"/>
                </Columns>
            </DataSource>
            <Sorts>
                <ajx:DataSorts Name="Name" Direction="Asc" />
            </Sorts>
        </DataContainer>
        <ColumnModel>
            <Columns>
                <ajx:GridColumns DataIndex="Name" Header="Name" Width="430">
                </ajx:GridColumns>
                <ajx:GridColumns DataIndex="StartDate" Header="StartDate" Width="140">
                    <Editor>
                        <Component>
                            <ajx:DateField ID="DateField1" runat="server" />
                        </Component>
                    </Editor>
                </ajx:GridColumns>
                <ajx:GridColumns DataIndex="EndDate" Header="EndDate" Width="140">
                    <Editor>
                        <Component>
                            <ajx:DateField ID="DateField2" runat="server" />
                        </Component>
                    </Editor>
                </ajx:GridColumns>
            </Columns>
        </ColumnModel>
        <LoadMask ShowMask="true" />
        <SelectionModel>
            <ajx:CheckSelectionModel ID="CheckSelectionModel1" runat="server" />
        </SelectionModel>
    </ajx:GridPanel>
    </form>
</body>
</html>
