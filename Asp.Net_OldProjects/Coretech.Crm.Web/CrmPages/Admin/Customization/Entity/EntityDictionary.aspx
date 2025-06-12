<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Customization_Entity_EntityDictionary" Codebehind="EntityDictionary.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">

    <title></title>
    <script type="text/javascript">

        function ShowWindow() {
            var config = GetWebAppRoot + "/CrmPages/Admin/Customization/Entity/Property/LabelsReflex.aspx?ObjectId=" + GridPanel1.selectedRecord.ObjectId;
            window.top.newWindow(config, { title: 'EntityEdit', width: 800, height: 600, resizable: true });
        }
        function ShowWindowImport() {
            var config = GetWebAppRoot + "/CrmPages/Admin/Customization/Entity/EntityDictionaryImport.aspx";
            window.top.newWindow(config, { title: 'Import', width: 800, height: 600, resizable: true });
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR" />
    <ajx:GridPanel ID="GridPanel1" runat="server" Title="Dictionary List" AutoHeight="Auto"
        Mode="Remote" AutoLoad="true" AutoWidth="true">
        <DataContainer>
            <DataSource OnEvent="DataLoad">
                <Columns>
                    <ajx:Column Name="EntityId" />
                    <ajx:Column Name="ObjectId" />
                    <ajx:Column Name="Name" />
                    <ajx:Column Name="Label" />
                    <ajx:Column Name="UniqueName" />
                </Columns>
            </DataSource>
            <Parameters>
                <ajx:Parameter Mode="Value" Name="start" Value="1" />
                <ajx:Parameter Mode="Value" Name="limit" Value="500" />
            </Parameters>
            <Sorts>
                <ajx:DataSorts Name="Label" Direction="Asc" />
            </Sorts>
        </DataContainer>
        <LoadMask ShowMask="true" Msg="Loading Data..." />
        <SelectionModel>
            <ajx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                <Listeners>
                    <RowDblClick Handler="ShowWindow();" />
                </Listeners>
            </ajx:RowSelectionModel>
        </SelectionModel>
        <ColumnModel>
            <Columns>
                <ajx:GridColumns DataIndex="Label" Header="Entity Name" Width="600" Sortable="false"
                    MenuDisabled="true" />
            </Columns>
        </ColumnModel>
        <TopBar>
            <ajx:ToolBar ID="tbar1" runat="server">
                <Items>
                    <ajx:Button runat="server" ID="btImport" Text="IMPORT_LABEL">
                    <Listeners>
                    <Click  Handler="ShowWindowImport();"/>
                    </Listeners>
                    </ajx:Button>
                </Items>
            </ajx:ToolBar>
        </TopBar>
        <BottomBar>
            <ajx:PagingToolBar ID="PagingToolBar2" runat="server" ControlId="GridPanel1">
            </ajx:PagingToolBar>
        </BottomBar>
    </ajx:GridPanel>
    </form>
</body>
</html>
