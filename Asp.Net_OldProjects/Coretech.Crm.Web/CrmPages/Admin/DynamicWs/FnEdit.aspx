<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_DynamicWs_FnEdit" Codebehind="FnEdit.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <ext:Hidden ID="hdnMethodId" runat="server"> </ext:Hidden>
    <ext:Store ID="entitystore" runat="server" OnRefreshData="EntityStoreOnRefreshData"
        WarningOnDirty="false" RemoteSort="true" AutoLoad="true">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader>
                <Fields>
                    <ext:RecordField Name="ObjectId" Type="Int" />
                    <ext:RecordField Name="EntityId" Type="String" />
                    <ext:RecordField Name="Label" Type="String" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="ObjectId" Direction="ASC" />
    </ext:Store>
        <ext:Panel runat="server">
            <TopBar>
                <ext:Toolbar ID="Toolbar1" runat="server">
                    <Items>
                        <ext:Button ID="btnSave" runat="server" Icon="PageSave">
                            <AjaxEvents>
                                <Click OnEvent="BtnSave_Click">
                                    <EventMask ShowMask="true" />
                                </Click>
                            </AjaxEvents>
                        </ext:Button>
                    </Items>
                </ext:Toolbar>
            </TopBar>
            <Body>
                <ext:ColumnLayout ID="ColumnLayout1" runat="server">
                    <ext:LayoutColumn ColumnWidth=".5">
                        <ext:Panel ID="Panel1" runat="server">
                            <Body>
                                <ext:FormLayout ID="FormLayout2" runat="server">
                                    <Anchors>
                                        <ext:Anchor Horizontal="90%">
                                            <ext:TextField ID="txtName" runat="server" FieldLabel="Name" ReadOnly="true">
                                            </ext:TextField>
                                        </ext:Anchor>
                                        <ext:Anchor Horizontal="90%">
                                            <ext:TextField ID="txtClassName" runat="server" FieldLabel="ClassName" ReadOnly="true">
                                            </ext:TextField>
                                        </ext:Anchor>
                                        <ext:Anchor Horizontal="90%">
                                            <ext:TextField ID="txtReturnType" runat="server" FieldLabel="ReturnType" ReadOnly="true">
                                            </ext:TextField>
                                        </ext:Anchor>
                                    </Anchors>
                                </ext:FormLayout>
                            </Body>
                        </ext:Panel>
                    </ext:LayoutColumn>
                    <ext:LayoutColumn ColumnWidth=".5">
                    <ext:Panel ID="Panel2" runat="server">
                            <Body>
                                <ext:FormLayout ID="FormLayout1" runat="server">
                                    <Anchors>
                                        <ext:Anchor Horizontal="90%">
                                              <ext:ComboBox runat="server" ID="cmbEntityId" FieldLabel="Target Entity"  
                                                        StoreID="entitystore" DisplayField="Label" ValueField="EntityId" ListWidth="350">
                                                    </ext:ComboBox>
                                            
                                        </ext:Anchor>
                                        <ext:Anchor Horizontal="90%">
                                            <ext:NumberField ID="nmbTimeOutMs" runat="server" FieldLabel="Timeout(Ms)">
                                            </ext:NumberField>
                                        </ext:Anchor>
                                        
                                    </Anchors>
                                </ext:FormLayout>
                            </Body>
                        </ext:Panel>
                    </ext:LayoutColumn>
                </ext:ColumnLayout>
            </Body>
        </ext:Panel>
    </div>
    </form>
</body>
</html>
