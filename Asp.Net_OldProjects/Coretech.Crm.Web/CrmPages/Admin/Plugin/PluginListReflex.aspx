<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Plugin_PluginListReflex" Codebehind="PluginListReflex.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:Hidden ID="hPluginDllId" runat="server">
    </rx:Hidden>
    <rx:GridPanel ID="_grdsma" runat="server" TrackMouseOver="false" AutoWidth="true"
        PostAllData="true" Mode="Remote" AutoHeight="Auto" AutoLoad="true" Width="600"
        AjaxPostable="true" Height="400">
        <DataContainer>
            <DataSource OnEvent="Store1_Refresh">
                <Columns>
                    <rx:Column Name="Name">
                    </rx:Column>
                    <rx:Column Name="ClassName">
                    </rx:Column>
                    <rx:Column Name="PluginId">
                    </rx:Column>
                </Columns>
            </DataSource>
        </DataContainer>
        <ColumnModel>
            <Columns>
                <rx:GridColumns Header="Name" DataIndex="Name" MenuDisabled="true" Width="200" Hidden="false"
                    Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns Header="ClassName" DataIndex="ClassName" Width="400" MenuDisabled="true"
                        Hidden="false" Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns Header="PluginId" DataIndex="PluginId" Width="100" Hidden="true"
                        Sortable="false">
                    </rx:GridColumns>
            </Columns>
        </ColumnModel>
        <SelectionModel>
            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server">
                <Listeners>
                    <RowDblClick Handler="ShowWindow(this,0)" />
                </Listeners>
            </rx:RowSelectionModel>
        </SelectionModel>
        <LoadMask ShowMask="true" Msg="Loading Data..." />
    </rx:GridPanel>
    </form>
</body>
</html>
<script type="text/javascript" language="javascript">
    function ShowWindow(b, c) {
        var guid = _grdsma.getRowsValues()[0].PluginId;
        var config = GetWebAppRoot + "/CrmPages/Admin/Plugin/PluginMessageReflex.aspx?PluginId=" + guid;
        window.top.newWindowRefleX(config, { title: 'Plugin', width: 900, height: 400, resizable: true, modal: true });
    }
</script>
