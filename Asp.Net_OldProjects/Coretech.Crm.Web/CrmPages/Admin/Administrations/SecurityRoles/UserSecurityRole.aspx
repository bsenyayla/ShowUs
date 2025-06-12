<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Administrations_SecurityRoles_UserSecurityRole" Codebehind="UserSecurityRole.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ext:Store ID="store1" runat="server" OnRefreshData="StoreOnRefreshData" RemoteSort="true"
        AutoLoad="true">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="RoleId">
                <Fields>
                    <ext:RecordField Name="RoleId" Type="String" />
                    <ext:RecordField Name="Name" Type="String" />
                    <ext:RecordField Name="Selected" Type="Boolean" />
                    <ext:RecordField Name="StartDate" Type="Date" />
                    <ext:RecordField Name="EndDate" Type="Date" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="Name" Direction="ASC" />
    </ext:Store>
    <ext:ViewPort runat="server">
        <Body>
            <ext:FitLayout runat="server">
                <ext:GridPanel ID="_grdsma" runat="server" AutoWidth="true" StripeRows="true" StoreID="store1"
                    Height="400" MemoryIDField="RoleId" SelectionMemory="Enabled">
                    <ColumnModel ID="_columnModel2" runat="server">
                        <Columns>
                            <ext:RowNumbererColumn />
                            <ext:Column Header="RoleId" DataIndex="RoleId" Width="50" Hidden="true" />
                            <ext:Column Header="Name" DataIndex="Name" Width="330" />
                            <ext:Column Header="StartDate" DataIndex="StartDate" Width="200">
                                <Renderer Fn="ToDate" />
                                <Editor>
                                    <ext:DateField runat="server">
                                    </ext:DateField>
                                </Editor>
                            </ext:Column>
                            <ext:Column Header="EndDate" DataIndex="EndDate" Width="200">
                                <Renderer Fn="ToDate" />
                                <Editor>
                                    <ext:DateField ID="dtE" runat="server">
                                    </ext:DateField>
                                </Editor>
                            </ext:Column>
                        </Columns>
                    </ColumnModel>
                    <LoadMask ShowMask="true" />
                    <SelectionModel>
                        <ext:CheckboxSelectionModel runat="server" ID="CheckboxSelectionModel1">
                        </ext:CheckboxSelectionModel>
                    </SelectionModel>
                    <TopBar>
                        <ext:Toolbar runat="server">
                            <Items>
                                <ext:ToolbarButton runat="server" Icon="UserTick" Text="RollAdd">
                                    <AjaxEvents>
                                        <Click OnEvent="RollAddOnEvent">
                                            <EventMask Msg="Roller Kayıt Ediliyor..." ShowMask="true" />
                                            <ExtraParams>
                                                <ext:Parameter Name="Values" Value="Ext.encode(#{_grdsma}.getRowsValues())" Mode="Raw" />
                                            </ExtraParams>
                                        </Click>
                                    </AjaxEvents>
                                </ext:ToolbarButton>
                            </Items>
                        </ext:Toolbar>
                    </TopBar>
                </ext:GridPanel>
            </ext:FitLayout>
        </Body>
    </ext:ViewPort>
    </form>
</body>
</html>
<script language="jscript">
    function ToDate(v) {
        if (v != null && v != "")
            return v.format("d.m.Y");
    }
</script>
