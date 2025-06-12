<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Share_ShareReflex" Codebehind="Share.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="CrmUI" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR" />
    <div style="display: none">
        <ajx:Hidden runat="server" ID="hdnRecid">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnObjectId">
        </ajx:Hidden>
    </div>
    <ajx:GridPanel runat="server" ID="GridShare" AutoWidth="true" AutoHeight="Auto" Height="100"
        Editable="false" Mode="Local" AutoLoad="false" Width="800" AjaxPostable="true"
        PostAllData="true">
        <DataContainer>
            <DataSource>
                <Columns>
                    <ajx:Column Name="TeamId" Title="TeamId" Hidden="true" DataType="String" />
                    <ajx:Column Name="SystemUserId" Title="SystemUserId" Hidden="true" DataType="String" />
                    <ajx:Column Name="RoleId" Title="RoleId" Hidden="true" DataType="String" />
                    <ajx:Column Name="ShareId" Title="ShareId" DataType="String" Hidden="true" />
                    <ajx:Column Name="RecType" Title="RecType" DataType="String" />
                    <ajx:Column Name="Name" Title="Name" Width="50" DataType="String" />
                    <ajx:Column Name="PrvRead" Title="Read" Width="50" DataType="Boolean" />
                    <ajx:Column Name="PrvWrite" Title="Write" Width="50" DataType="Boolean" />
                    <ajx:Column Name="PrvDelete" Title="Delete" Hidden="true" DataType="Boolean" />
                    <ajx:Column Name="PrvAssign" Title="Assign" Hidden="true" DataType="Boolean" />
                    <ajx:Column Name="PrvShare" Title="Share" Hidden="true" DataType="Boolean" />
                </Columns>
            </DataSource>
        </DataContainer>
        <ColumnModel>
            <Columns>
                <ajx:GridColumns ColumnId="RecType" DataIndex="RecType" Header="RecType" MenuDisabled="true"
                    Width="50">
                    <Renderer Handler="return Share.GetTypeImage(record.data.RecType);" />
                </ajx:GridColumns>
                <ajx:GridColumns ColumnId="Name" DataIndex="Name" Header="Name" Width="250" MenuDisabled="true" />
                <ajx:GridColumns ColumnId="PrvRead" DataIndex="PrvRead" Header="Read" Width="50"
                    ColumnType="Check" MenuDisabled="true" />
                <ajx:GridColumns ColumnId="PrvWrite" DataIndex="PrvWrite" Header="Write" Width="50"
                    ColumnType="Check" MenuDisabled="true" />
                <ajx:GridColumns ColumnId="PrvDelete" DataIndex="PrvDelete" Header="Delete" Width="50"
                    ColumnType="Check" MenuDisabled="true" />
                <ajx:GridColumns ColumnId="PrvAssign" DataIndex="PrvAssign" Header="Assign" Width="50"
                    ColumnType="Check" MenuDisabled="true" />
                <ajx:GridColumns ColumnId="PrvShare" DataIndex="PrvShare" Header="Share" Width="50"
                    ColumnType="Check" MenuDisabled="true" />
            </Columns>
        </ColumnModel>
        <Items>
        </Items>
        <SelectionModel>
            <ajx:RowSelectionModel ID="GridShareRowSelectionModel1" runat="server" ShowNumber="false">
                <Listeners>
                    <RowClick Handler="Share.ShareSelected()" />
                </Listeners>
            </ajx:RowSelectionModel>
        </SelectionModel>
        <TopBar>
            <ajx:ToolBar runat="server" ID="GridShareToolBar">
                <Items>
                    <ajx:ToolbarButton runat="server" ID="GridShareToolBar_AddUser" Icon="User" Text="Add User">
                        <Listeners>
                            <Click Handler="Share.ShowUsers();" />
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="GridShareToolBar_AddTeam" Icon="GroupAdd" Text="Add Group">
                        <Listeners>
                            <Click Handler="Share.ShowTeams();" />
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="GridShareToolBar_AddRole" Icon="FolderUser"
                        Text="Add Role">
                        <Listeners>
                            <Click Handler="Share.ShowRoles();" />
                        </Listeners>
                    </ajx:ToolbarButton>
                    <%--<ajx:ToolbarButton runat="server" ID="GridShareToolBar_Remove" Icon="Delete" Text="Remove">
                        <Listeners>
                            <Click Handler="Share.RemoveSelectedRow();" />
                        </Listeners>
                    </ajx:ToolbarButton>--%>
                </Items>
            </ajx:ToolBar>
        </TopBar>
        <BottomBar>
            <ajx:ToolBar ID="GridShareBottomBar" runat="server">
                <Items>
                    <ajx:ToolbarFill runat="server" ID="GridShareBottomBarFill">
                    </ajx:ToolbarFill>
                    <ajx:ToolbarButton runat="server" ID="GridShareBottomBar_Save" Icon="ScriptSave"
                        Text="Save Shared List ">
                        <AjaxEvents>
                            <Click OnEvent="BtnSave_Click" Success="Share.Close();">
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                </Items>
            </ajx:ToolBar>
        </BottomBar>
        <LoadMask ShowMask="true" />
    </ajx:GridPanel>
    <ajx:Window ID="WindowUser" runat="server" Title="User Window" Height="100" Border="false"
         Resizable="false" CloseAction="Hide" Width="400" Modal="true"
        Icon="User" ShowOnLoad="false" Maximizable="false"  WindowCenter="true"   >
        <Body>
            <CrmUI:CrmComboComp runat="server" ID="UserCmp" RequirementLevel="BusinessRequired"
                UniqueName="SystemUserId" Width="250" ObjectId="1" PageSize="50" FieldLabel="200"
                LookupViewUniqueName="User LookUp" Disabled="false">
            </CrmUI:CrmComboComp>
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowUserSave" Icon="ScriptSave" Text="Add User">
                <Listeners>
                    <Click Handler="Share.AddUser()" />
                </Listeners>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    <ajx:Window ID="WindowTeam" runat="server" Title="Team Window" Height="100" Border="false"
        Resizable="false" CloseAction="Hide" Width="400" Modal="true"
        Icon="Group" ShowOnLoad="false" Maximizable="false" WindowCenter="true" >
        <Body>
            <CrmUI:CrmComboComp runat="server" ID="TeamCmp" RequirementLevel="BusinessRequired"
                UniqueName="TeamId" Width="250" ObjectId="30" PageSize="50" FieldLabel="200"
                Disabled="false">
            </CrmUI:CrmComboComp>
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowTeamSave" Icon="ScriptSave" Text="Add Team">
                <Listeners>
                    <Click Handler="Share.AddTeam()" />
                </Listeners>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    <ajx:Window ID="WindowRole" runat="server" Title="Role Window" Height="100" Border="false"
        Resizable="false" CloseAction="Hide" Width="400" Modal="true"
        Icon="FolderUser" ShowOnLoad="false" Maximizable="false" WindowCenter="true" >
        <Body>
            <CrmUI:CrmComboComp runat="server" ID="RoleCmp" RequirementLevel="BusinessRequired"
                UniqueName="RoleId" Width="250" ObjectId="35" PageSize="50" FieldLabel="200"
                Disabled="false">
            </CrmUI:CrmComboComp>
        </Body>
        <Buttons>
            <ajx:Button runat="server" ID="WindowRoleSave" Icon="ScriptSave" Text="Add Role">
                <Listeners>
                    <Click Handler="Share.AddRole()" />
                </Listeners>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    </form>
</body>
</html>
<script language="javascript">

    var Share = {
        dataType: { "TeamId": "", "SystemUserId": "", "RoleId": "", "ShareId": "", "RecType": 0, "Name": "", "PrvRead": false, "PrvWrite": false, "PrvDelete": false, "PrvAssign": false, "PrvShare": false },
        GetTypeImage: function (b) {
            var className = "";
            switch (b) {
                case 1:
                    className = "icon-user";
                    break;
                case 2:
                    className = "icon-groupadd";
                    break;
                case 3:
                    className = "icon-folderuser";
                    break;
            }
            return '<div  class="' + className + '"  style="overflow-x: hidden; overflow-y: hidden; height: 16px;width: 16px; overflow: hidden;" />';
        }
        ,
        RemoveSelectedRow: function () {
            if (GridShare.selectedRowId >= 0) {
                GridShare.deleteRow();
            }
        },
        ShowUsers: function () {
            WindowUser.show();
        },
        AddUser: function () {
            WindowUser.hide();
            this.CreateRecord(1);
            UserCmp.clear();
        },
        ShowTeams: function () {
            WindowTeam.show();
        },
        AddTeam: function () {
            WindowTeam.hide();
            this.CreateRecord(2);
            TeamCmp.clear();
        },
        ShowRoles: function () {
            WindowRole.show();
        },
        AddRole: function () {
            WindowRole.hide();
            this.CreateRecord(3);
            RoleCmp.clear();
        },
        CreateRecord: function (type) {

            var rec = this.dataType.clone();
            if (type == 1) {
                rec.SystemUserId = UserCmp.getValue();
                rec.Name = UserCmp.getRawValue();
            }
            else if (type == 2) {
                rec.TeamId = TeamCmp.getValue();
                rec.Name = TeamCmp.getRawValue();
            }
            else if (type == 3) {
                rec.RoleId = RoleCmp.getValue();
                rec.Name = RoleCmp.getRawValue();
            }
            rec.RecType = type;
            GridShare.insertRow(rec);
        },
        Close: function () {
            if (top.R.WindowMng.getActiveWindow() != 0) {
                R.clearDirty();
                top.R.WindowMng.getActiveWindow().hide();
            }
        }
    }
</script>
