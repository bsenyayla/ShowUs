<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_LookUp"
    ValidateRequest="false" Codebehind="LookUp.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<%@ Register Assembly="Coretech.Crm.Web.UI" Namespace="Coretech.Crm.Web.UI.ExtPlugin"
    TagPrefix="plg" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <ext:ScriptContainer runat="server">
    </ext:ScriptContainer>
    <script type="text/javascript">

        var LookUpObject = null;
        var LookUpObjectId = null;
        function wonload() {
            if (FrameWorkType != "RefleX") {

                var frame = null;
                if (window.top.frames[lframename] != null)
                    frame = window.top.frames[lframename];
                else if (window.parent.name == lframename)
                    frame = window.parent;

                LookUpObject = frame.eval(lookup + "name");
                LookUpObjectId = frame.eval(lookup);
            }
            else {
                var win = window.top.R.WindowMng.getWindowById(awinid);
                LookUpObject = window.top.evalIframe(lframename, lookup + "name");
                LookUpObjectId = window.top.evalIframe(lframename, lookup);

            }
            FilterText.focus(true);
        }
        function SelectRecord(sender, arg) {
            var frame = null;
            if (window.top.frames[lframename] != null)
                frame = window.top.frames[lframename];
            else if (window.parent.name == lframename)
                frame = window.parent;
            if (type == "lookup") {

                LookUpObject.setValue(sender.getRowsValues()[0].VALUE);
                LookUpObjectId.setValue(sender.getRowsValues()[0].ID);
            } else if (type == "ntonlookup") {
                MultiSelectAdd_Selected(frame, LookUpObject, sender.getRowsValues()[0].ID, sender.getRowsValues()[0].VALUE)

            }
            if (FrameWorkType != "RefleX") {
                top.Ext.WindowMgr.getActive().close();
            } else {
                window.top.R.WindowMng.getActiveWindow().hide();
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ext:Store ID="StoreViewer" runat="server" AutoLoad="false" RemoteSort="true">
            <Reader>
                <ext:JsonReader ReaderID="RowNum" Root="Records" TotalProperty="totalCount">
                    <Fields>
                    </Fields>
                </ext:JsonReader>
            </Reader>
            <Proxy>
            </Proxy>
            <BaseParams>
                <ext:Parameter Name="start" Value="0" Mode="Raw">
                </ext:Parameter>
                <ext:Parameter Name="limit" Value="#{CmbPageSize}.getValue()" Mode="Raw">
                </ext:Parameter>
                <ext:Parameter Name="viewqueryid" Value="#{ViewQuery}.getValue()" Mode="Raw">
                </ext:Parameter>
                <ext:Parameter Name="query" Value="#{FilterText}.getValue()" Mode="Raw">
                </ext:Parameter>
                <ext:Parameter Name="feachxml" Value="#{FetchXML}.getValue()" Mode="Raw">
                </ext:Parameter>
            </BaseParams>
        </ext:Store>
        <ext:Hidden ID="ReferencedObjectId" runat="server">
        </ext:Hidden>
        <ext:Hidden ID="LookupTextId" runat="server">
        </ext:Hidden>
        <ext:Hidden ID="LookupValueId" runat="server">
        </ext:Hidden>
        <ext:Hidden ID="ViewQuery" runat="server">
        </ext:Hidden>
        <ext:Hidden ID="FetchXML" runat="server">
        </ext:Hidden>
    </div>
    <ext:ViewPort ID="ViewPort1" runat="server">
        <Body>
            <ext:FitLayout ID="FitLayout1" runat="server">
                <Items>
                    <ext:GridPanel ID="GridPanelViewer" runat="server" StoreID="StoreViewer" TrackMouseOver="false">
                        <TopBar>
                            <ext:Toolbar ID="Toolbar1" runat="server">
                                <Items>
                                    <ext:TriggerField ID="FilterText" EnableKeyEvents="true" runat="server" Width="200"
                                        EmptyText="Aranacak Kelimeyi Giriniz">
                                        <Triggers>
                                            <ext:FieldTrigger Icon="Search" />
                                        </Triggers>
                                        <Listeners>
                                            <KeyPress Handler="if(e.getKey()==Ext.EventObject.ENTER){#{StoreViewer}.load()}" />
                                            <TriggerClick Handler="#{StoreViewer}.load()" />
                                        </Listeners>
                                    </ext:TriggerField>
                                    <ext:ToolbarFill />
                                    <ext:ToolbarSeparator>
                                    </ext:ToolbarSeparator>
                                    <ext:Button ID="btnNew" runat="server" Text="Yeni Kayıt" Icon="Add">
                                    </ext:Button>
                                    <ext:ComboBox ID="CmbPageSize" runat="server" SelectedIndex="1" Width="100" Editable="false">
                                        <Items>
                                            <ext:ListItem Text="25" Value="25" />
                                            <ext:ListItem Text="50" Value="50" />
                                            <ext:ListItem Text="100" Value="100" />
                                            <ext:ListItem Text="250" Value="250" />
                                        </Items>
                                        <Listeners>
                                            <Select Handler="#{PagingToolBar1}.pageSize=parseInt(#{CmbPageSize}.getValue()); #{StoreViewer}.load()" />
                                        </Listeners>
                                    </ext:ComboBox>
                                </Items>
                            </ext:Toolbar>
                        </TopBar>
                        <ColumnModel ID="ColumnModelViewer" runat="server">
                            <Columns>
                                <ext:ImageCommandColumn ColumnID="Image1" DataIndex="ImageHref" Width="20" Sortable="false"
                                    MenuDisabled="true">
                                </ext:ImageCommandColumn>
                            </Columns>
                        </ColumnModel>
                        <Plugins>
                            <plg:GridSearch runat="server" SearchText="Ara" Width="200" ID="gridsearch">
                            </plg:GridSearch>
                        </Plugins>
                        <Listeners>
                            <CellDblClick Handler="SelectRecord(this,#{ReferencedObjectId}.getValue());" />
                        </Listeners>
                        <SelectionModel>
                            <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" />
                        </SelectionModel>
                        <BottomBar>
                            <ext:PagingToolbar ID="PagingToolBar1" runat="server" DisplayInfo="true" StoreID="StoreViewer"
                                PageSize="50">
                            </ext:PagingToolbar>
                        </BottomBar>
                        <LoadMask ShowMask="true" />
                    </ext:GridPanel>
                </Items>
            </ext:FitLayout>
        </Body>
    </ext:ViewPort>
    </form>
</body>
</html>
<script src="../../js/MultiSortGrid.js" type="text/javascript"></script>
