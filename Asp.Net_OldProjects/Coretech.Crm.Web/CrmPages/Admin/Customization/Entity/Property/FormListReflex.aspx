<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Entity_Property_FormListReflex"
    ValidateRequest="false" Codebehind="FormListReflex.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script language="javascript">
        function ShowWindow(sender, arg) {
            var config = GetWebAppRoot + "/CrmPages/Admin/Customization/Entity/Property/FormEdit.aspx?objectid=" + hdnObjectReflexId.value;
            if (arg == 0) {
                config = config + "&FormId=";
            }
            else {
                config = config + "&FormId=" + GridPanelReflex1.selectedRecord.FormId;
            }
            //object.load(config)
            //object[0].id
            //show(animateTarget, cb, scope)	Variant
            window.top.newWindowRefleX(config, { title: 'FormEdit', width: 1000, height: 600, resizable: true, modal: true });
            //object.show(parent.parent.Panel2, parent.parent.Panel2, parent.parent.Panel2);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR" />
    <rx:Hidden runat="server" ID="hdnObjectReflexId">
    </rx:Hidden>
    <rx:GridPanel ID="GridPanelReflex1" Title="Form List" Editable="false" runat="server" Collapsible="true"
        Mode="Remote" AutoWidth="true" AutoHeight="Auto" AutoLoad="true" Width="800"
        AjaxPostable="true">
        <TopBar>
            <rx:ToolBar runat="server" ID="toolbar1">
                <Items>
                    <rx:ToolbarButton Icon="PageAdd" runat="server" ID="btnNew" Text="Add">
                        <Listeners>
                            <Click Handler="ShowWindow(this,0);" />
                        </Listeners>
                    </rx:ToolbarButton>
                    <rx:ToolbarButton ID="DeleteButton" Icon="PageDelete" runat="server" Text="Delete">
                        <AjaxEvents>
                            <Click Before="return ConfirmDeletion();" OnEvent="DeleteForm">
                                <EventMask ShowMask="true" />
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                </Items>
            </rx:ToolBar>
        </TopBar>
        <DataContainer>
            <DataSource OnEvent="Store1_Refresh">
                <Columns>
                    <rx:Column Name="ImageHref">
                    </rx:Column>
                    <rx:Column Name="Name">
                    </rx:Column>
                    <rx:Column Name="Description">
                    </rx:Column>
                    <rx:Column Name="FormId">
                    </rx:Column>
                </Columns>
            </DataSource>
        </DataContainer>
        <ColumnModel>
            <Columns>
                <rx:GridColumns ColumnId="Image1" Header=".." DataIndex="ImageHref" Width="20" Sortable="false"
                    MenuDisabled="true">
                </rx:GridColumns>
                <rx:GridColumns Header="Name" DataIndex="Name" MenuDisabled="true" Width="300" Hidden="false"
                    Sortable="false">
                </rx:GridColumns>
                <rx:GridColumns Header="Description" DataIndex="Description" MenuDisabled="true"
                    Hidden="false" Sortable="false">
                </rx:GridColumns>
                <rx:GridColumns Header="FormId" DataIndex="FormId" Width="100" Hidden="true" Sortable="false">
                </rx:GridColumns>
            </Columns>
        </ColumnModel>
        <SelectionModel>
            <rx:RowSelectionModel ID="RowSelectionModelReflex1" runat="server">
                <Listeners>
                    <RowDblClick Handler="ShowWindow(this,1);" />
                </Listeners>
            </rx:RowSelectionModel>
        </SelectionModel>
        <BottomBar>
            <rx:PagingToolBar runat="server" ID="PagingToolBarReflex1" ControlId="GridPanelReflex1">
            </rx:PagingToolBar>
        </BottomBar>
        <LoadMask ShowMask="true" Msg="Loading Data..." />
    </rx:GridPanel>
    </form>
</body>
</html>
<script language="javascript">
    function ConfirmDeletion() {
        var deleteMessage = GetMessage("CRM_FORM_ISDELETE", "Silinsinmi???");
        if (confirm(deleteMessage)) {
            return true;
        }
        return false;
    }
</script>
