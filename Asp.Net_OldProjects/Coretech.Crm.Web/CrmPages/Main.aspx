<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Main"
    ValidateRequest="false" ViewStateMode="Enabled" EnableViewState="True" Codebehind="Main.aspx.cs" %>

<%@ Register Assembly="Coretech.Crm.Web.UI" Namespace="Coretech.Crm.Web.UI.ExtPlugin"
    TagPrefix="plg" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork"
    TagPrefix="ajx" %>
<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script src="../js/globalDelete.js" type="text/javascript"></script>
    <script src="../js/globalAssign.js" type="text/javascript"></script>
    <style type="text/css">
        loading-mask
        {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            z-index: 20000;
            background-color: white;
        }
        .status
        {
            color: #555;
        }
        .x-progress-wrap.left-align .x-progress-text
        {
            text-align: left;
        }
        .x-progress-wrap.custom
        {
            height: 17px;
            border: 1px solid #686868;
            overflow: hidden;
            padding: 0 2px;
        }
        .ext-ie .x-progress-wrap.custom
        {
            height: 19px;
        }
        .custom .x-progress-inner
        {
            height: 17px;
            background: #fff;
        }
        
        .maintitle .x-label-value
        {
            font-weight: bold !important;
            color: #fafafa;
            font-size: 12px;
            font-family: tahoma, arial, verdana, sans-serif;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR"/>
    <ext:ViewPort ID="ViewPort1" runat="server">
        <Body>
            <ext:FitLayout ID="FitLayout1" runat="server">
                <Items>
                    <ext:Panel ID="Window1" runat="server" Border="false" Closable="false" Plain="true">
                        <TopBar>
                            <ext:Toolbar runat="server">
                                <Items>
                                    <ext:Label runat="server" ID="MainTitle" Cls="maintitle">
                                    </ext:Label>
                                    <ext:ToolbarFill />
                                    <ext:ToolbarButton runat="server" ID="Welcome" Icon="User">
                                        <Menu>
                                            <ext:Menu>
                                                <Items>
                                                    <ext:MenuItem runat="server" ID="pchange" Text="Şifre Değiştir">
                                                        <Listeners>
                                                            <Click Handler="PnlCenter.load('Admin/Administrations/User/UserPassWord.aspx');" />
                                                        </Listeners>
                                                    </ext:MenuItem>
                                                </Items>
                                            </ext:Menu>
                                        </Menu>
                                    </ext:ToolbarButton>
                                    <ext:ToolbarSeparator>
                                    </ext:ToolbarSeparator>
                                    <ext:Button runat="server" ID="btnLogout" Text="Logout" Icon="Disconnect">
                                        <Listeners>
                                            <Click Handler="document.location.href = '../Login.aspx';" />
                                        </Listeners>
                                    </ext:Button>
                                </Items>
                            </ext:Toolbar>
                        </TopBar>
                        <Body>
                            <ext:BorderLayout ID="BorderLayout1" runat="server">
                                <West Collapsible="true" MinWidth="175" Split="true">
                                    <ext:Panel ID="PnlWest" runat="server" Width="175" CtCls="west-panel" Title="Navigation"
                                        Collapsed="false" BodyStyle="padding:0px;">
                                        <AutoLoad Url="root/_Left.aspx" Mode="IFrame" />
                                    </ext:Panel>
                                </West>
                                <Center>
                                    <ext:Panel ID="PnlCenter" runat="server" Title="Center region">
                                        <AutoLoad Url="root/_Center.aspx" Mode="IFrame" ShowMask="true" />
                                    </ext:Panel>
                                </Center>
                            </ext:BorderLayout>
                        </Body>
                    </ext:Panel>
                </Items>
            </ext:FitLayout>
        </Body>
    </ext:ViewPort>
    <ext:Window ID="WindowDeleteList" runat="server" Title="CRM_DLETELIST" Height="250px"
        Width="400px" Modal="True" Icon="Delete" ShowOnLoad="false">
        <Body>
            <ext:Store ID="WindowDeleteListStore" runat="server">
                <AjaxEventConfig>
                    <EventMask ShowMask="true" />
                </AjaxEventConfig>
                <Reader>
                    <ext:JsonReader>
                        <Fields>
                            <ext:RecordField Name="ID" />
                            <ext:RecordField Name="NAME" />
                            <ext:RecordField Name="OBJECTID" />
                        </Fields>
                    </ext:JsonReader>
                </Reader>
            </ext:Store>
            <ext:FitLayout ID="FitLayout2" runat="server">
                <ext:GridPanel runat="server" ID="WindowDeleteListGrid" StoreID="WindowDeleteListStore">
                    <ColumnModel>
                        <Columns>
                            <ext:Column Sortable="false" MenuDisabled="true" DataIndex="ID" Hidden="true">
                            </ext:Column>
                            <ext:Column Sortable="false" MenuDisabled="true" DataIndex="OBJECTID" Hidden="true">
                            </ext:Column>
                            <ext:Column Width="25" Sortable="false" MenuDisabled="true">
                                <Renderer Fn="DeleteTemplate" />
                            </ext:Column>
                            <ext:Column Header="....." Width="330" Sortable="false" MenuDisabled="true" DataIndex="NAME">
                            </ext:Column>
                        </Columns>
                    </ColumnModel>
                    <SelectionModel>
                        <ext:RowSelectionModel ID="RowSelectionModel3" runat="server" />
                    </SelectionModel>
                    <BottomBar>
                        <ext:Toolbar ID="Toolbar5" runat="server">
                            <Items>
                                <ext:Button ID="BtnDeleteOk" Icon="Delete" MinWidth="80" runat="server" Text="CRM_DELETE">
                                    <Listeners>
                                        <Click Handler="window.top.GlobalDeleteAllList(this)" />
                                    </Listeners>
                                </ext:Button>
                                <ext:ProgressBar runat="server" ID="WindowDeleteListProgress" Width="300" Cls="custom">
                                </ext:ProgressBar>
                            </Items>
                        </ext:Toolbar>
                    </BottomBar>
                </ext:GridPanel>
            </ext:FitLayout>
        </Body>
    </ext:Window>
    <ext:Window ID="WindowAssignList" runat="server" Title="CRM_ASSIGN" Height="250px"
        Width="400px" Modal="True" Icon="Attach" ShowOnLoad="false">
        <Body>
            <ext:Store ID="StoreUser" runat="server" OnRefreshData="StoreOnRefreshData" RemoteSort="true"
                AutoLoad="true">
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
                <SortInfo Field="SystemUserId" Direction="ASC" />
            </ext:Store>
            <ext:Store ID="WindowAssignListStore" runat="server">
                <AjaxEventConfig>
                    <EventMask ShowMask="true" />
                </AjaxEventConfig>
                <Reader>
                    <ext:JsonReader>
                        <Fields>
                            <ext:RecordField Name="ID" />
                            <ext:RecordField Name="NAME" />
                            <ext:RecordField Name="OBJECTID" />
                        </Fields>
                    </ext:JsonReader>
                </Reader>
            </ext:Store>
            <ext:FitLayout ID="FitLayout3" runat="server">
                <ext:GridPanel runat="server" ID="WindowAssignListGrid" StoreID="WindowAssignListStore">
                    <TopBar>
                        <ext:Toolbar runat="server">
                            <Items>
                                <ext:FormPanel ID="FormPanel1" runat="server" Frame="false" Border="false" BodyStyle="padding:10px">
                                    <Body>
                                        <ext:FormLayout ID="FormLayout1" runat="server" LabelSeparator="" LabelWidth="150">
                                            <ext:Anchor>
                                                <ext:ComboBox runat="server" ID="UserCmp" DisplayField="FullName" ValueField="SystemUserId"
                                                    StoreID="StoreUser" FieldLabel="SYSTEMUSER_USERNAME" Width="200" Mode="Remote">
                                                </ext:ComboBox>
                                            </ext:Anchor>
                                        </ext:FormLayout>
                                    </Body>
                                </ext:FormPanel>
                            </Items>
                        </ext:Toolbar>
                    </TopBar>
                    <ColumnModel>
                        <Columns>
                            <ext:Column Sortable="false" MenuDisabled="true" DataIndex="ID" Hidden="true">
                            </ext:Column>
                            <ext:Column Sortable="false" MenuDisabled="true" DataIndex="OBJECTID" Hidden="true">
                            </ext:Column>
                            <ext:Column Width="25" Sortable="false" MenuDisabled="true">
                                <Renderer Fn="AssignTemplate" />
                            </ext:Column>
                            <ext:Column Header="NAME" Width="330" Sortable="false" MenuDisabled="true" DataIndex="NAME">
                            </ext:Column>
                        </Columns>
                    </ColumnModel>
                    <SelectionModel>
                        <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" />
                    </SelectionModel>
                    <BottomBar>
                        <ext:Toolbar ID="Toolbar1" runat="server">
                            <Items>
                                <ext:Button ID="BtnAssignOk" Icon="Attach" MinWidth="80" runat="server" Text="CRM_ASSIGN">
                                    <Listeners>
                                        <Click Handler="window.top.GlobalAssignAllList(this)" />
                                    </Listeners>
                                </ext:Button>
                                <ext:ProgressBar runat="server" ID="WindowAssignListProgress" Width="300" Cls="custom">
                                </ext:ProgressBar>
                            </Items>
                        </ext:Toolbar>
                    </BottomBar>
                </ext:GridPanel>
            </ext:FitLayout>
        </Body>
    </ext:Window>
    </form>
</body>
</html>
<script type="text/javascript">
    Ext.onReady(function () {
        Ext.override(Ext.menu.Menu, {
            // See http://extjs.com/forum/showthread.php?t=33475&page=2
            showAt: function (xy, parentMenu, /* private: */_e) {
                this.parentMenu = parentMenu;
                if (!this.el) {
                    this.render();
                }
                if (_e !== false) {
                    this.fireEvent("beforeshow", this);
                    xy = this.el.adjustForConstraints(xy);
                }
                this.el.setXY(xy);

                // Start of extra logic to what is in Ext source code...
                // See http://www.extjs.com/deploy/ext/docs/output/Menu.jss.html
                // get max height from body height minus y cordinate from this.el
                var maxHeight = Ext.getBody().getHeight() - xy[1];
                if (this.el.getHeight() > maxHeight) {
                    // set element with max height and apply vertical scrollbar
                    this.el.setHeight(maxHeight);
                    this.el.applyStyles('overflow-y: auto;');
                }
                // .. end of extra logic to what is in Ext source code

                this.el.show();
                this.hidden = false;
                this.focus();
                this.fireEvent("show", this);
            }
        });
    });
</script>
