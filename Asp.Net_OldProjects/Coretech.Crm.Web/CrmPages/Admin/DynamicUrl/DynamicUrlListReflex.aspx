<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_DynamicUrl_DynamicUrlListReflex" Codebehind="DynamicUrlListReflex.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR" Theme="Slate" />
    <div>
        <rx:GridPanel ID="GridPanel1" runat="server" TrackMouseOver="false" AutoWidth="true"
            PostAllData="true" Mode="Remote" AutoHeight="Auto" AutoLoad="true" Width="800"
            AjaxPostable="true" Height="500">
            <TopBar>
                <rx:ToolBar runat="server" ID="toolbar1">
                    <Items>
                        <rx:Button ID="btnNew" Icon="Page" runat="server">
                            <Listeners>
                                <Click Handler="ShowWindow(this,0);" />
                            </Listeners>
                        </rx:Button>
                        <rx:Button ID="Delete" Icon="PageDelete" runat="server" Text="Sil">
                            <AjaxEvents>
                                <Click OnEvent="DeleteDynamicUrl">
                                    <EventMask ShowMask="true" />
                                </Click>
                            </AjaxEvents>
                        </rx:Button>
                    </Items>
                </rx:ToolBar>
            </TopBar>
            <DataContainer>
                <DataSource OnEvent="Store1_Refresh">
                    <Columns>
                        <rx:Column Name="Name">
                        </rx:Column>
                        <rx:Column Name="Url">
                        </rx:Column>
                        <rx:Column Name="DynamicUrlId">
                        </rx:Column>
                    </Columns>
                </DataSource>
            </DataContainer>
            <ColumnModel>
                <Columns>
                    <rx:GridColumns Header="Name" DataIndex="Name" MenuDisabled="true" Width="200" Hidden="false"
                        Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns Header="Url" DataIndex="Url" MenuDisabled="true" Hidden="false" Width="450"
                        Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns Header="DynamicUrlId" DataIndex="DynamicUrlId" Width="100" Hidden="true"
                        Sortable="false">
                    </rx:GridColumns>
                </Columns>
            </ColumnModel>
            <SelectionModel>
                <rx:RowSelectionModel ID="rsm1" runat="server">
                    <Listeners>
                        <RowDblClick Handler="ShowWindow(this,1);" />
                        </Listeners>
                </rx:RowSelectionModel>
            </SelectionModel>
            <LoadMask ShowMask="true" Msg="Loading Data..." />
        </rx:GridPanel>
    </div>
    </form>
</body>
</html>
<script type="text/javascript" language="javascript">
    //    function EditWindow(a, b, c) {
    //        var guid = a.getRowsValues()[0].DynamicUrlId;
    //        var config = "Admin/DynamicWs/DynamicUrlEdit.aspx?DynamicUrlId=" + guid;
    //        window.top.newWindow(config, { title: 'Plugin', width: 800, height: 600, resizable: true });
    //    }
    function ShowWindow(sender, arg) {

        var config = GetWebAppRoot + "/CrmPages/Admin/DynamicUrl/DynamicUrlEditReflex.aspx";
        if (arg == 0) {
            config = config + "?DynamicUrlId=";
        }
        else {
            config = config + "?DynamicUrlId=" + GridPanel1.getRowsValues()[0].DynamicUrlId;
        }
        window.top.newWindowRefleX(config, { title: 'Dynamic Url Edit', width: 600, height: 480, resizable: true });

    }
</script>
