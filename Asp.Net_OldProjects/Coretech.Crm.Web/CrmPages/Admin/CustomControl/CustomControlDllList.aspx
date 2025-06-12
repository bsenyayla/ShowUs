<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_CustomControl_CustomControlDllList" Codebehind="CustomControlDllList.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:GridPanel ID="GridPanel1" runat="server" TrackMouseOver="false" AutoWidth="true"
        PostAllData="true" Mode="Remote" AutoHeight="Auto" AutoLoad="true" Width="800"
        AjaxPostable="true" Height="500">
        <TopBar>
            <rx:ToolBar runat="server" ID="toolbar1">
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
                    <rx:Column Name="CustomControlDllId">
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
                <rx:GridColumns Header="Name" DataIndex="Name" MenuDisabled="true" Width="350" Hidden="false"
                    Sortable="false">
                </rx:GridColumns>
                <rx:GridColumns Header="Location" DataIndex="Location" MenuDisabled="true" Hidden="false"
                    Sortable="false">
                </rx:GridColumns>
                <rx:GridColumns Header="FilePath " DataIndex="FilePath " MenuDisabled="true" Hidden="false"
                    Sortable="false">
                </rx:GridColumns>
                <rx:GridColumns Header="CustomControlDllId" DataIndex="CustomControlDllId" Width="100"
                    Hidden="true" Sortable="false">
                </rx:GridColumns>
            </Columns>
        </ColumnModel>
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
        var guid = GridPanel1.getRowsValues()[0].CustomControlDllId;
        var config = "Admin/CustomControl/CustomControlListReflex.aspx?CustomControlDllId=" + guid;
        window.top.newWindowRefleX(config, { title: 'CustomControl', width: 800, height: 600, resizable: true });
    }
    function ShowWindow(sender, arg) {

        var config = GetWebAppRoot + "/CrmPages/Admin/CustomControl/CustomControlDllEditReflex.aspx";
        if (arg == 0) {
            config = config + "?CustomControlDllId=";
        }
        else {
            config = config + "?CustomControlDllId=" + GridPanel1.getRowsValues()[0].CustomControlDllId;
        }
        window.top.newWindowRefleX(config, { title: 'CustomControlDllEdit', width: 520, height: 150, resizable: false });

    }
</script>
