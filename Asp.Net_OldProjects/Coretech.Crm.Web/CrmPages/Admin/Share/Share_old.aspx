<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Share_Share"
    ValidateRequest="false" ViewStateMode="Enabled" EnableViewState="True" Codebehind="Share_old.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<%@ Register Assembly="Coretech.Crm.Web.UI" Namespace="Coretech.Crm.Web.UI.ExtPlugin"
    TagPrefix="plg" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ext:Hidden runat="server" ID="hdnObjectId">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnRecid">
        </ext:Hidden>
    </div>
    <ext:Store ID="StoreUser" runat="server" OnRefreshData="StoreUserOnRefreshData" RemoteSort="true"
        AutoLoad="false">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="SystemUserId">
                <Fields>
                    <ext:RecordField Name="SystemUserId" Type="String" />
                    <ext:RecordField Name="FullName" Type="String" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="FullName" Direction="ASC" />
    </ext:Store>
    <ext:Store ID="StoreTeam" runat="server" OnRefreshData="StoreTeamOnRefreshData" RemoteSort="true"
        AutoLoad="false">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="TeamId">
                <Fields>
                    <ext:RecordField Name="TeamId" Type="String" />
                    <ext:RecordField Name="TeamName" Type="String" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="SystemUserId" Direction="ASC" />
    </ext:Store>
    <ext:Store ID="Store1" runat="server" AutoLoad="true" OnRefreshData="Store1_Refresh">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="ShareId">
                <Fields>
                    <ext:RecordField Name="ShareId">
                    </ext:RecordField>
                    <ext:RecordField Name="IsTeam">
                    </ext:RecordField>
                    <ext:RecordField Name="TeamId">
                    </ext:RecordField>
                    <ext:RecordField Name="SystemUserId">
                    </ext:RecordField>
                    <ext:RecordField Name="Name">
                    </ext:RecordField>
                    <ext:RecordField Name="PrvRead">
                    </ext:RecordField>
                    <ext:RecordField Name="PrvWrite">
                    </ext:RecordField>
                    <ext:RecordField Name="PrvDelete">
                    </ext:RecordField>
                    <ext:RecordField Name="PrvAssign">
                    </ext:RecordField>
                    <ext:RecordField Name="PrvShare">
                    </ext:RecordField>
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="Name" Direction="ASC" />
    </ext:Store>
    <ext:ViewPort ID="ViewPort1" runat="server">
        <Body>
            <ext:FitLayout ID="FitLayout1" runat="server">
                <ext:GridPanel ID="GridPanel1" runat="server" StoreID="Store1" Width="700" Title="Share List"
                    TrackMouseOver="false" AutoWidth="true">
                    <ColumnModel ID="ColumnModel1" runat="server">
                        <Columns>
                            <ext:RowNumbererColumn />
                            <ext:Column ColumnID="TeamId" DataIndex="TeamId" Width="30" Sortable="false" MenuDisabled="true"
                                Hidden="true">
                            </ext:Column>
                            <ext:Column ColumnID="SystemUserId" DataIndex="SystemUserId" Width="20" Sortable="false"
                                MenuDisabled="true" Hidden="true">
                            </ext:Column>
                            <ext:Column ColumnID="ShareId" DataIndex="ShareId" Width="20" Sortable="false" MenuDisabled="true"
                                Hidden="true">
                            </ext:Column>
                            <ext:Column ColumnID="Tip" DataIndex="IsTeam" Width="30" Sortable="false" MenuDisabled="true">
                                <Renderer Handler="return TypeImage(record.data.IsTeam)" />
                            </ext:Column>
                            <ext:Column ColumnID="topic" Header="Name" DataIndex="Name" Width="200" Sortable="false"
                                MenuDisabled="true">
                            </ext:Column>
                            <ext:CheckColumn Header="Read" DataIndex="PrvRead" Width="100" Sortable="false"
                                MenuDisabled="true" Editable="true">
                            </ext:CheckColumn>
                            <ext:CheckColumn Header="Write" DataIndex="PrvWrite" Width="100" MenuDisabled="true"
                                Sortable="false" Editable="true">
                            </ext:CheckColumn>
                            <ext:CheckColumn Header="Delete" DataIndex="PrvDelete" Width="100" MenuDisabled="true"
                                Sortable="false" Editable="true">
                            </ext:CheckColumn>
                            <ext:CheckColumn Header="Assign" DataIndex="PrvAssign" Width="100" MenuDisabled="true"
                                Sortable="false" Editable="true">
                            </ext:CheckColumn>
                            <ext:CheckColumn Header="Share" DataIndex="PrvShare" Width="100" MenuDisabled="true"
                                Sortable="false" Editable="true">
                            </ext:CheckColumn>
                        </Columns>
                    </ColumnModel>
                    <SelectionModel>
                        <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" />
                    </SelectionModel>
                    <%-- <Plugins>
                        <plg:GridSearch runat="server" ID="gridsearch" Mode="local" Width="200">
                        </plg:GridSearch>
                        <ext:GridFilters ID="GridFilters1" runat="server" Local="true">
                            <Filters>
                                <ext:StringFilter DataIndex="Name" />
                            </Filters>
                        </ext:GridFilters>
                    </Plugins>--%>
                    <LoadMask ShowMask="true" Msg="Loading Data..." />
                    <TopBar>
                        <ext:Toolbar runat="server" ID="toolbar1">
                            <Items>
                                <ext:ToolbarButton runat="server" ID="btnSave" Text="Kaydet" Icon="PageSave">
                                    <AjaxEvents>
                                        <Click OnEvent="BtnSave_Click" Success="top.Ext.WindowMgr.getActive().close();">
                                            <EventMask ShowMask="true" />
                                            <ExtraParams>
                                                <ext:Parameter Name="Values" Value="Ext.encode(#{GridPanel1}.getRowsValues(false))"
                                                    Mode="Raw" />
                                            </ExtraParams>
                                        </Click>
                                    </AjaxEvents>
                                </ext:ToolbarButton>
                                <ext:ToolbarButton runat="server" ID="NewUser" Text="Kullanıcı Ekle" Icon="UserAdd">
                                    <Listeners>
                                        <Click Handler="#{WindowUser}.show();" />
                                    </Listeners>
                                </ext:ToolbarButton>
                                <ext:ToolbarButton runat="server" ID="NewTeam" Text="Takım Ekle" Icon="FolderUser">
                                    <Listeners>
                                        <Click Handler="#{WindowTeam}.show();" />
                                    </Listeners>
                                </ext:ToolbarButton>
                            </Items>
                        </ext:Toolbar>
                    </TopBar>
                </ext:GridPanel>
            </ext:FitLayout>
        </Body>
    </ext:ViewPort>
    <ext:Window ID="WindowUser" runat="server" Title="Add User" Height="100px" Width="450"
        Modal="True" Icon="ApplicationEdit" ShowOnLoad="false">
        <TopBar>
            <ext:Toolbar runat="server">
                <Items>
                    <ext:ToolbarButton ID="Add_User" runat="server" Icon="Add">
                        <Listeners>
                            <Click Handler="AddUser();" />
                        </Listeners>
                    </ext:ToolbarButton>
                </Items>
            </ext:Toolbar>
        </TopBar>
        <Body>
            <ext:FormPanel ID="FormPanel5" runat="server" Width="450" Frame="true" ButtonAlign="Center">
                <Body>
                    <ext:FormLayout ID="FormLayout8" runat="server">
                        <ext:Anchor>
                            <ext:ComboBox runat="server" ID="UserCmp" DisplayField="FullName" ValueField="SystemUserId"
                                StoreID="StoreUser" FieldLabel="SYSTEMUSER_USERNAME" Width="300" Mode="Remote">
                            </ext:ComboBox>
                        </ext:Anchor>
                    </ext:FormLayout>
                </Body>
            </ext:FormPanel>
        </Body>
    </ext:Window>
    <ext:Window ID="WindowTeam" runat="server" Title="Add User" Height="100px" Width="450"
        Modal="True" Icon="ApplicationEdit" ShowOnLoad="false">
        <TopBar>
            <ext:Toolbar ID="Toolbar2" runat="server">
                <Items>
                    <ext:ToolbarButton ID="Add_Team" runat="server" Icon="Add">
                        <Listeners>
                            <Click Handler="AddTeam();" />
                        </Listeners>
                    </ext:ToolbarButton>
                </Items>
            </ext:Toolbar>
        </TopBar>
        <Body>
            <ext:FormPanel ID="FormPanel1" runat="server" Width="450" Frame="true" ButtonAlign="Center">
                <Body>
                    <ext:FormLayout ID="FormLayout1" runat="server">
                        <ext:Anchor>
                            <ext:ComboBox runat="server" ID="TeamCmp" DisplayField="TeamName" ValueField="TeamId"
                                StoreID="StoreTeam" FieldLabel="Takım" Width="300" Mode="Remote">
                            </ext:ComboBox>
                        </ext:Anchor>
                    </ext:FormLayout>
                </Body>
            </ext:FormPanel>
        </Body>
    </ext:Window>
    </form>
</body>
</html>
<script language="javascript" type="text/javascript">
    function AddUser() {
        var Id = UserCmp.getValue();
        var Name = UserCmp.getText();
        addList(0, Id, Name)
        WindowUser.hide();
    }

    function AddTeam() {
        var Id = TeamCmp.getValue();
        var Name = TeamCmp.getText();
        addList(1, Id, Name)
        WindowTeam.hide();
    }

    function addList(IsTeam, Id, Name) {
        var itemGuid = guid();
        var MyRecordType = Ext.data.Record.create(["ShareId", "IsTeam", "TeamId", "SystemUserId", "Name", "PrvRead", "PrvWrite", "PrvDelete", "PrvAssign", "PrvShare"]);
        var TeamId = '', SystemUserId = '';
        if (IsTeam == 1)
            TeamId = Id
        else
            SystemUserId = Id

        for (var i = 0; i < GridPanel1.store.data.length; i++) {
            if (IsTeam == 1) {
                if (GridPanel1.store.data.items[i].data.TeamId == Id)
                    return;
            } else {
                if (GridPanel1.store.data.items[i].data.SystemUserId == Id)
                    return;
            }
        }
        myrec = new MyRecordType({ "id": '' + itemGuid + '', "IsTeam": '' + IsTeam + '', "ShareId": '' + itemGuid + '', "TeamId": '' + TeamId + '', "SystemUserId": '' + SystemUserId + '', "Name": '' + Name + '',
            "PrvRead": 0, "PrvWrite": 0, "PrvDelete": 0, "PrvAssign": 0, "PrvShare": 0
        });
        myrec.id = itemGuid;
        GridPanel1.store.insert(GridPanel1.store.data.length, myrec);
        TeamCmp.clrValue();
        UserCmp.clrValue();
    }
    function TypeImage(b) {
        var className = "";
        if (b==true)
            className = "icon-folderuser";
        else
            className = "icon-useradd";

        return '<div  class="' + className + '"  style="overflow-x: hidden; overflow-y: hidden; width: 16px; overflow: hidden;" />';
    }
</script>
