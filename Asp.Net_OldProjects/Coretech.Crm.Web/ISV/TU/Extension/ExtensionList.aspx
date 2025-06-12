<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ExtensionList.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Extension.ExtensionList" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        function ShowExtension(recordId) {
            var config = GetWebAppRoot + "/ISV/TU/Extension/Extension.aspx?recordId=" + recordId;
            window.top.newWindowRefleX(config, {
                width: 800, height: 500, resizable: true, modal: true, maximizable: true, listeners:
                       {
                           close: function (el, e) {
                               gpExtensionMapping.reload();

                               return true;
                           }
                       }
            });
        }
    </script>
</head>
<body>
    <rx:RegisterResources runat="server" ID="RR" />
    <form id="form1" runat="server">
        <div>
            <rx:KeyMap runat="server" ID="KeyMap1">
                <rx:KeyBinding>
                    <Keys>
                        <rx:Key Code="F9">
                            <Listeners>
                                <Event Handler="filter();" />
                            </Listeners>
                        </rx:Key>
                    </Keys>
                </rx:KeyBinding>
            </rx:KeyMap>
            <rx:Hidden ID="hdnSelectedId" runat="server"></rx:Hidden>
            <rx:PanelX ID="wrapper" runat="server" Border="false">
                <Body>
                    <rx:GridPanel runat="server" ID="gpExtensionMapping" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
                        Height="250" AutoLoad="true" Mode="Remote">
                        <DataContainer>
                            <DataSource OnEvent="GetData">
                            </DataSource>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns ColumnId="ID" Width="25" Header="ID" Sortable="false"
                                    MenuDisabled="true" Hidden="true" DataIndex="ID" />
                                <rx:GridColumns ColumnId="NAME" Width="150" Header="NAME" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="NAME" />
                                <rx:GridColumns ColumnId="GROUPNAME" Width="75" Header="GROUP" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="GROUPNAME" />
                                <rx:GridColumns ColumnId="CORPORATIONNAME" Width="250" Header="CORPORATION" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="CORPORATIONNAME" />
                                <rx:GridColumns ColumnId="ASYNC" Width="50" Header="ASYNC" Sortable="false" ColumnType="Check"
                                    MenuDisabled="true" Hidden="false" DataIndex="ASYNC" />
                                <rx:GridColumns ColumnId="ISCASH" Width="50" Header="CASH" Sortable="false" ColumnType="Check"
                                    MenuDisabled="true" Hidden="false" DataIndex="ISCASH" />
                                <rx:GridColumns ColumnId="URL" Width="350" Header="URL" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="URL" />
                                <rx:GridColumns ColumnId="HTTPMETHOD" Width="75" Header="HTTP" Sortable="false"
                                    MenuDisabled="true" Hidden="false" DataIndex="HTTPMETHOD">
                                </rx:GridColumns>
                            </Columns>
                        </ColumnModel>

                        <SelectionModel>
                            <rx:RowSelectionModel ID="GridPanelPaymentsRowSelectionModel1" runat="server" ShowNumber="true">
                                <Listeners>
                                    <RowClick Handler="hdnSelectedId.clear();hdnSelectedId.setValue(gpExtensionMapping.selectedRecord.ID);"></RowClick>
                                </Listeners>
                                <%--                                <AjaxEvents>
                                    <RowDblClick OnEvent="GetDataDetail">
                                    </RowDblClick>
                                </AjaxEvents>--%>
                            </rx:RowSelectionModel>
                        </SelectionModel>
                        <BottomBar>
                            <rx:PagingToolBar ID="pagingToolBar" runat="server" ControlId="gpExtensionMapping">
                            </rx:PagingToolBar>
                        </BottomBar>
                        <TopBar>
                            <rx:ToolBar ID="toolBar1" runat="server">
                                <Items>
                                    <rx:Label ID="label1" runat="server" ImageUrl="../images/if_extension_79880.png" ImageHeight="36" ImageWidth="36" Width="40">
                                    </rx:Label>
                                    <rx:Label ID="FrmInfo" runat="server" Text="<b>&nbsp;&nbsp;Extension Mapping List</b>" Width="130" ForeColor="White"></rx:Label>
                                    <rx:ToolbarSeparator ID="ToolbarSeparator7" runat="server"></rx:ToolbarSeparator>
                                    <rx:ToolbarButton ID="btnNew" runat="server" Icon="Add" Text="<b>New</b>">
                                        <Listeners>
                                            <Click Handler="ShowExtension(0);" />
                                        </Listeners>
                                    </rx:ToolbarButton>
                                    <rx:ToolbarButton ID="btnEdit" runat="server" Icon="DatabaseEdit" Text="<b>Edit</b>">
                                        <Listeners>
                                            <Click Handler="ShowExtension(hdnSelectedId.value);" />
                                        </Listeners>
                                    </rx:ToolbarButton>
                                    <rx:ToolbarButton ID="btnDelete" runat="server" Icon="Delete" Text="<b>Delete</b>">
                                        <AjaxEvents>
                                            <Click OnEvent="ExtensionMappingDelete" Before="return confirm('İşlemi silmek istediğinizden emin misiniz?');">
                                            </Click>
                                        </AjaxEvents>
                                    </rx:ToolbarButton>
                                    <rx:ToolbarSeparator ID="separator1" runat="server"></rx:ToolbarSeparator>
                                    <rx:ToolbarButton ID="btnRefresh" runat="server" Icon="ArrowRefresh" Text="<b>Refresh</b>">
                                        <Listeners>
                                            <Click Handler="gpExtensionMapping.reload();" />
                                        </Listeners>
                                    </rx:ToolbarButton>
                                    <rx:ToolbarButton ID="ToolbarButton1" runat="server" Icon="Delete" Text="<b>Token</b>">
                                        <AjaxEvents>
                                            <Click OnEvent="GetToken" Before="return confirm('İşlemi silmek istediğinizden emin misiniz?');">
                                            </Click>
                                        </AjaxEvents>
                                    </rx:ToolbarButton>
                                </Items>
                            </rx:ToolBar>
                        </TopBar>
                    </rx:GridPanel>

                </Body>

            </rx:PanelX>


        </div>
    </form>
</body>
</html>
