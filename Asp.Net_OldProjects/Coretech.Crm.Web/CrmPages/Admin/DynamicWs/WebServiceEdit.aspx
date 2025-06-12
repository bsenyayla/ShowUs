<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_DynamicWs_WebServiceEdit" Codebehind="WebServiceEdit.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ext:Hidden ID="WebServiceId" runat="server">
        </ext:Hidden>
        <ext:Store ID="Store1" runat="server" AutoLoad="true">
            <Reader>
                <ext:JsonReader ReaderID="MethodId">
                    <Fields>
                        <ext:RecordField Name="Name">
                        </ext:RecordField>
                        <ext:RecordField Name="ReturnType">
                        </ext:RecordField>
                        <ext:RecordField Name="ClassName">
                        </ext:RecordField>
                        <ext:RecordField Name="MethodId">
                        </ext:RecordField>
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Panel runat="server">
            <TopBar>
                <ext:Toolbar runat="server">
                    <Items>
                        <ext:Button ID="btnSave" runat="server" Icon="PageSave">
                            <AjaxEvents>
                                <Click OnEvent="BtnSave_Click">
                                <EventMask ShowMask=true />
                                    <ExtraParams>
                                        <ext:Parameter Name="Values" Value="Ext.encode(#{GridPanel1}.getRowsValues(false))"
                                            Mode="Raw" />
                                    </ExtraParams>
                                </Click>
                            </AjaxEvents>
                        </ext:Button>
                    </Items>
                </ext:Toolbar>
            </TopBar>
            <Body>
                <ext:Panel runat="server">
                    <Body>
                        <ext:FormLayout runat="server">
                            <Anchors>
                                <ext:Anchor Horizontal="100%">
                                    <ext:MultiField ID="MultiField1" runat="server" FieldLabel="Url">
                                        <Fields>
                                            <ext:TextField ID="txtUrl" runat="server" Width="300" />
                                            <ext:Button runat="server" Icon="ArrowRefresh" ID="btnRefreshList">
                                                <AjaxEvents>
                                                    <Click OnEvent="btnRefreshList_Click" Before="LoadPnlWsdlList(#{txtUrl}.getValue())">
                                                        <EventMask ShowMask="true" />
                                                    </Click>
                                                </AjaxEvents>
                                            </ext:Button>
                                        </Fields>
                                    </ext:MultiField>
                                </ext:Anchor>
                                <ext:Anchor Horizontal="80%">
                                        <ext:TextField ID="txtName" runat="server" FieldLabel="Name" />
                                </ext:Anchor>
                            </Anchors>
                        </ext:FormLayout>
                    </Body>
                </ext:Panel>
                <ext:TabPanel ID="TabPanel1" runat="server" Height="360" Border="false">
                    <Tabs>
                        <ext:Tab Title="Default" AutoScroll="true">
                            <Body>
                                <ext:Panel runat="server" ID="PnlWsdlList" Title="Viewer" Height="300" Collapsible="true"
                                    Collapsed="true" AnimCollapse="false">
                                    <AutoLoad Url="about:blank" Mode="IFrame" ShowMask="true">
                                    </AutoLoad>
                                    <Body>
                                    </Body>
                                </ext:Panel>
                                <ext:GridPanel ID="GridPanel1" Title="Function List" runat="server" StoreID="Store1"
                                    TrackMouseOver="false" Height="300">
                                    <TopBar>
                                        <ext:Toolbar ID="Toolbar1" runat="server">
                                            <Items>
                                                <ext:Button ID="btnDelete" Text="Remove From List" Icon="Delete" runat="server">
                                                    <Listeners>
                                                        <Click Handler="#{GridPanel1}.deleteSelected();" />
                                                    </Listeners>
                                                </ext:Button>
                                            </Items>
                                        </ext:Toolbar>
                                    </TopBar>
                                    <ColumnModel ID="ColumnModel1" runat="server">
                                        <Columns>
                                            <ext:ImageCommandColumn ColumnID="Image1" DataIndex="ImageHref" Width="20" Sortable="false"
                                                MenuDisabled="true">
                                            </ext:ImageCommandColumn>
                                            <ext:Column Header="Name" DataIndex="Name" MenuDisabled="true" Width="350" Hidden="false"
                                                Sortable="false">
                                            </ext:Column>
                                            <ext:Column Header="ReturnType" DataIndex="ReturnType" MenuDisabled="true" Hidden="false"
                                                Sortable="false">
                                            </ext:Column>
                                            <ext:Column Header="MethodId" DataIndex="MethodId" Width="100" Hidden="true" Sortable="false">
                                            </ext:Column>
                                            <ext:Column Header="ClassName" DataIndex="ClassName" Width="100" Hidden="true" Sortable="false">
                                            </ext:Column>
                                        </Columns>
                                    </ColumnModel>
                                    <SelectionModel>
                                        <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" />
                                    </SelectionModel>
                                    <LoadMask ShowMask="true" Msg="Loading Data..." />
                                </ext:GridPanel>
                            </Body>
                        </ext:Tab>
                        <ext:Tab Title="Properties">
                            <Body>
                                <ext:ColumnLayout ID="ColumnLayout1" runat="server">
                                    <ext:LayoutColumn ColumnWidth="1">
                                        <ext:Panel ID="Panel1" runat="server">
                                            <Body>
                                                <ext:FormLayout ID="FormLayout2" runat="server">
                                                    <Anchors>
                                                        <ext:Anchor Horizontal="90%">
                                                            <ext:TextField ID="txtUserName" runat="server" FieldLabel="UserName">
                                                            </ext:TextField>
                                                        </ext:Anchor>
                                                        <ext:Anchor Horizontal="90%">
                                                            <ext:TextField ID="txtPwd" runat="server" FieldLabel="Password">
                                                            </ext:TextField>
                                                        </ext:Anchor>
                                                        <ext:Anchor Horizontal="90%">
                                                            <ext:TextField ID="txtCerFile" runat="server" FieldLabel="CerFile">
                                                            </ext:TextField>
                                                        </ext:Anchor>
                                                    </Anchors>
                                                </ext:FormLayout>
                                            </Body>
                                        </ext:Panel>
                                    </ext:LayoutColumn>
                                    </ext:ColumnLayout>
                                   
                            </Body>
                        </ext:Tab>
                    </Tabs>
                </ext:TabPanel>
            </Body>
        </ext:Panel>
    </div>
    </form>
</body>
</html>
<script language="javascript">
    function LoadPnlWsdlList(x) {
        if (x.length > 0) {
            PnlWsdlList.setTitle(x);
            PnlWsdlList.load(x);
        }
    }
</script>
