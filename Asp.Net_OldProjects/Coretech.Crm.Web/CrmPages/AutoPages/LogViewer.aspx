<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_LogViewer" Codebehind="LogViewer.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ext:ScriptManager ID="ScriptManager1" runat="server" HideInDesign="True" ScriptMode="Debug"
        AjaxViewStateMode="Default" SourceFormatting="true" Theme="Gray" Locale="tr"
        StateProvider="None" AutoDataBind="false">
    </ext:ScriptManager>
    <ext:Store ID="store1" runat="server" OnRefreshData="StoreOnRefreshData" RemoteSort="false"
        GroupOnSort="false" WarningOnDirty="false" AutoLoad="true" GroupField="CreatedOn">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="RowNum">
                <Fields>
                    <ext:RecordField Name="RowNum" Type="Int" />
                    <ext:RecordField Name="EntityLoggingHeaderId" Type="String" />
                    <ext:RecordField Name="EntityLoggingDetailId" Type="String" />
                    <ext:RecordField Name="CreatedByFullName" Type="String" />
                    <ext:RecordField Name="CreatedOn" Type="String" />
                    <ext:RecordField Name="AttributeLabel" Type="String" />
                    <ext:RecordField Name="OldValue" Type="String" />
                    <ext:RecordField Name="NewValue" Type="String" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <BaseParams>
            <ext:Parameter Name="start" Value="0" Mode="Raw">
            </ext:Parameter>
            <ext:Parameter Name="limit" Value="1000" Mode="Raw">
            </ext:Parameter>
        </BaseParams>
        <SortInfo Field="CreatedOn" Direction="DESC" />
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
    <ext:Panel runat="server" Frame="false" Border="false" BodyStyle="padding:10px">
        <Body>
            <ext:FitLayout ID="FitLayout1" runat="server">
                <ext:GridPanel ID="_grd" runat="server" AutoWidth="true" StripeRows="true" StoreID="store1"
                    ContextMenuID="mnuExport" Height="445">
                    <ColumnModel ID="_columnModel2" runat="server">
                        <Columns>
                            <ext:Column Header="Attribute" DataIndex="AttributeLabel" Width="150" Groupable="false"
                                Sortable="false" MenuDisabled="true" />
                            <ext:Column Header="CreatedOn" DataIndex="CreatedOn" Width="100" Groupable="false"
                                Sortable="false" MenuDisabled="true">
                            </ext:Column>
                            <ext:Column Header="CreatedBy" DataIndex="CreatedByFullName" Width="150" Groupable="false"
                                Sortable="false" MenuDisabled="true"/>
                            <ext:Column Header="OldValue" DataIndex="OldValue" Groupable="false" Sortable="false"
                                MenuDisabled="true" Hidden="false" />
                            <ext:Column Header="NewValue" DataIndex="NewValue" Groupable="false" Sortable="false"
                                MenuDisabled="true" Hidden="false" />
                        </Columns>
                    </ColumnModel>
                    <View>
                        <ext:GroupingView ID="_groupingView1" HideGroupedColumn="true" runat="server" ForceFit="true"
                            StartCollapsed="true" GroupTextTpl='<span id="{[values.rs[0].data.EntityLoggingHeaderId]}"></span>Değiştirme : {[values.rs[0].data.CreatedByFullName]} {[values.rs[0].data.CreatedOn]}  ({[values.rs.length]} {[values.rs.length > 1 ? "Adet" : "Adet"]})'
                            EnableRowBody="true">
                        </ext:GroupingView>
                    </View>
                    <LoadMask ShowMask="true" />
                    <Plugins>
                        <ext:RowExpander ID="_rowExpander1" runat="server" />
                    </Plugins>
                    <SelectionModel>
                        <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" SingleSelect="true">
                        </ext:RowSelectionModel>
                    </SelectionModel>
                </ext:GridPanel>
            </ext:FitLayout>
        </Body>
    </ext:Panel>
    </form>
</body>
</html>
