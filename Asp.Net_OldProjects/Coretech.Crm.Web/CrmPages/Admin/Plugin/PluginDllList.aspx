<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Plugin_PluginDllList" Codebehind="PluginDllList.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:GridPanel ID="_grdsma" runat="server" TrackMouseOver="false" AutoWidth="true"
        PostAllData="true" Mode="Remote" AutoHeight="Auto" AutoLoad="true" Width="800"
        AjaxPostable="true" Height="500">
        <TopBar>
            <rx:ToolBar runat="server" ID="gridtoolbar">
                <Items>
                    <rx:Button ID="Button1" Icon="Page" runat="server">
                        <Listeners>
                            <Click Handler="ShowWindow(this,0);" />
                        </Listeners>
                    </rx:Button>
                </Items>
            </rx:ToolBar>
        </TopBar>
        <DataContainer>
            <DataSource OnEvent="Store1_Refresh">
                <Columns>
                    <rx:Column Name="Name">
                    </rx:Column>
                    <rx:Column Name="Location">
                    </rx:Column>
                    <rx:Column Name="FilePath">
                    </rx:Column>
                    <rx:Column Name="PluginDllId">
                    </rx:Column>
                </Columns>
            </DataSource>
        </DataContainer>
        <ColumnModel>
            <Columns>
                <rx:GridColumns ColumnId="Image1" DataIndex="ImageHref" Width="40" Sortable="false"
                    MenuDisabled="true">
                    <Commands>
                        <rx:ImageCommand Icon="NoteEdit" Text="Edit">
                            <Listeners>
                                <Click Handler="ShowWindow(this,1)" />
                            </Listeners>
                        </rx:ImageCommand>
                    </Commands>
                </rx:GridColumns>
                <rx:GridColumns ColumnId="Name" Header="Name" DataIndex="Name" MenuDisabled="true"
                    Width="350" Hidden="false" Sortable="false">
                </rx:GridColumns>
                <rx:GridColumns ColumnId="Location" Header="Location" DataIndex="Location" MenuDisabled="true"
                    Hidden="false" Sortable="false">
                </rx:GridColumns>
                <rx:GridColumns ColumnId="FilePath" Header="FilePath" DataIndex="FilePath " MenuDisabled="true"
                    Hidden="false" Sortable="false">
                </rx:GridColumns>
                <rx:GridColumns ColumnId="PluginDllId" Header="PluginDllId" DataIndex="PluginDllId"
                    Width="100" Hidden="true" Sortable="false">
                </rx:GridColumns>
                <rx:GridColumns>
                </rx:GridColumns>
            </Columns>
        </ColumnModel>
        <Listeners>
        </Listeners>
        <SelectionModel>
            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server">
                <Listeners>
                    <RowDblClick Handler="EditWindow(this,1)" />
                </Listeners>
            </rx:RowSelectionModel>
        </SelectionModel>
        <LoadMask ShowMask="true" Msg="Loading Data..." />
    </rx:GridPanel>
    </form>
</body>
</html>
<script type="text/javascript" language="javascript">
    function EditWindow(b, c) {
        var guid = _grdsma.getRowsValues()[0].PluginDllId;
        var config = GetWebAppRoot + "/CrmPages/Admin/Plugin/PluginListReflex.aspx?PluginDllId=" + guid;
        window.top.newWindowRefleX(config, { title: 'Plugin', width: 800, height: 600, resizable: true });
    }
    function ShowWindow(sender, arg) {

        var config = GetWebAppRoot + "/CrmPages/Admin/Plugin/PluginDllEditReflex.aspx";
        if (arg == 0) {
            config = config + "?PluginDllId=";
        }
        else {
            config = config + "?PluginDllId=" + _grdsma.getRowsValues()[0].PluginDllId;
        }
        window.top.newWindowRefleX(config, { title: 'PluginDllEdit', width: 520, height: 150, resizable: false });

    }
</script>
