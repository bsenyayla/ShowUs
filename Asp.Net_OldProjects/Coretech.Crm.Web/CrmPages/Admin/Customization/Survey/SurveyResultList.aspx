<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Customization_Survey_SurveyResultList" Codebehind="SurveyResultList.aspx.cs" %>

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
    <ext:Hidden runat="server" ID="hdnHeaderId" />
    <ext:Store ID="store1" runat="server" OnRefreshData="StoreOnRefreshData" RemoteSort="true"
        GroupField="PartName" AutoLoad="true">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="AnswerId">
                <Fields>
                    <ext:RecordField Name="HeaderId" Type="String" />
                    <ext:RecordField Name="AnswerId" Type="String" />
                    <ext:RecordField Name="PartName" Type="String" />
                    <ext:RecordField Name="Question" Type="String" />
                    <ext:RecordField Name="Answer" Type="String" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <BaseParams>
            <ext:Parameter Name="start" Value="0" Mode="Raw">
            </ext:Parameter>
            <ext:Parameter Name="limit" Value="1000" Mode="Raw">
            </ext:Parameter>
        </BaseParams>
        <SortInfo Field="HeaderId" Direction="ASC" />
    </ext:Store>
    <ext:Menu runat="server" ID="mnuExport">
        <Items>
            <ext:MenuItem runat="server" ID="mnuExportExcelAll" Text="Export_To_Excel_(All_Page)"
                Icon="PageWhiteExcel">
                <Listeners>
                    <Click Handler="ExportExcelStore();" />
                </Listeners>
            </ext:MenuItem>
        </Items>
    </ext:Menu>
    <ext:ViewPort runat="server">
        <Body>
            <ext:FitLayout runat="server">
                <ext:GridPanel ID="_grdsma" runat="server" StripeRows="true" StoreID="store1" Width="320"
                    Height="490" AutoExpandColumn="Question" ContextMenuID="mnuExport">
                    <ColumnModel ID="_columnModel2" runat="server">
                        <Columns>
                            <ext:RowNumbererColumn />
                            <ext:Column ColumnID="HeaderId" Header="HeaderId" DataIndex="HeaderId" Width="50" Hidden="true" />
                            <ext:Column ColumnID="PartName" Header="PartName" DataIndex="PartName" Width="330" Groupable="true" Sortable="false" />
                            <ext:Column ColumnID="Question" Header="Question" DataIndex="Question" Width="500" Sortable="false" MenuDisabled="true" />
                            <ext:Column ColumnID="Answer" Header="Answer" DataIndex="Answer" Width="200" Sortable="false" MenuDisabled="true" />
                        </Columns>
                    </ColumnModel>
                    <LoadMask ShowMask="true" />
                    <SelectionModel>
                        <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" SingleSelect="true" />
                    </SelectionModel>
                    <View>
                        <ext:GroupingView ID="GroupingView1" runat="server" HideGroupedColumn="true" ShowGroupName="false">
                        </ext:GroupingView>
                    </View>
                    <BottomBar>
                        <ext:PagingToolbar runat="server">
                        </ext:PagingToolbar>
                    </BottomBar>
                </ext:GridPanel>
            </ext:FitLayout>
        </Body>
    </ext:ViewPort>
    </form>
</body>
</html>
