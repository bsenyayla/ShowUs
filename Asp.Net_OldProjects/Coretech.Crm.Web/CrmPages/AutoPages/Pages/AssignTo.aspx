<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_Pages_AssignTo" Codebehind="AssignTo.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ext:Hidden runat="server" ID="hdnObjectId">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnRecid">
        </ext:Hidden>
    <ext:Store ID="StoreUser" runat="server" OnRefreshData="StoreOnRefreshData" RemoteSort="true"
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
        <SortInfo Field="SystemUserId" Direction="ASC" />
    </ext:Store>
    <ext:ViewPort runat="server">
        <Body>
            <ext:FitLayout runat="server">
                <ext:FormPanel ID="FormPanel1" runat="server" Frame="false" Border="false" BodyStyle="padding:10px">
                    <Body>
                        <ext:FormLayout ID="FormLayout1" runat="server" LabelSeparator="" LabelWidth="150">
                            <ext:Anchor>
                                <ext:ComboBox runat="server" ID="UserCmp" DisplayField="FullName" ValueField="SystemUserId"
                                    StoreID="StoreUser" FieldLabel="UserName" Width="200">
                                </ext:ComboBox>
                            </ext:Anchor>
                        </ext:FormLayout>
                    </Body>
                    <TopBar>
                        <ext:Toolbar runat="server">
                            <Items>
                                <ext:ToolbarButton ID="ToolbarButton1" runat="server" Text="CRM_ASSIGN" Icon="Attach">
                                    <AjaxEvents>
                                        <Click OnEvent="ClickOnEvent" Success="RefreshParetnGrid();top.Ext.WindowMgr.getActive().close();">
                                            <EventMask ShowMask="true" Msg="ASSIGNING..."  />
                                        </Click>
                                    </AjaxEvents>
                                </ext:ToolbarButton>
                            </Items>
                        </ext:Toolbar>
                    </TopBar>
                </ext:FormPanel>
            </ext:FitLayout>
        </Body>
    </ext:ViewPort>
    </form>
</body>
</html>
