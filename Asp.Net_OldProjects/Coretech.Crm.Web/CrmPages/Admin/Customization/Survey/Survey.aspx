<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Survey_Survey" Codebehind="Survey.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ext:Hidden runat="server" ID="hdnSurveyId">
    </ext:Hidden>
    <ext:Store ID="store1" runat="server" OnRefreshData="StoreOnRefreshData" RemoteSort="true"
        WarningOnDirty="false" AutoLoad="true">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="SurveyId">
                <Fields>
                    <ext:RecordField Name="SurveyId" Type="String" />
                    <ext:RecordField Name="SurveyId" Type="String" />
                    <ext:RecordField Name="SurveyName" Type="String" />
                    <ext:RecordField Name="SurveyDescription" Type="String" />
                    <ext:RecordField Name="Publish" Type="Boolean" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="SurveyId" Direction="ASC" />
    </ext:Store>
    <ext:ViewPort runat="server">
        <Body>
            <ext:FitLayout runat="server">
                <ext:Panel runat="server" ID="panel1" AutoWidth="true" Frame="false" Border="false">
                    <Body>
                        <ext:FitLayout ID="FitLayout1" runat="server">
                            <ext:GridPanel ID="_grdsma" runat="server" AutoWidth="true" StripeRows="true" StoreID="store1"
                                Height="400">
                                <ColumnModel ID="_columnModel2" runat="server">
                                    <Columns>
                                        <ext:RowNumbererColumn />
                                        <ext:CheckColumn Header="Publish" DataIndex="Publish" Width="50" Hidden="false" />
                                        <ext:Column Header="SurveyId" DataIndex="SurveyId" Width="50" Hidden="true" />
                                        <ext:Column Header="SurveyName" DataIndex="SurveyName" Width="330">
                                            <Commands>
                                                <ext:ImageCommand CommandName="Preview" Icon="ScriptStart" Text="Önizleme">
                                                    <ToolTip Text="Önizleme" />
                                                </ext:ImageCommand>
                                            </Commands>
                                        </ext:Column>
                                        <ext:Column Header="SurveyDescription" DataIndex="SurveyDescription" Width="330" />
                                    </Columns>
                                </ColumnModel>
                                <LoadMask ShowMask="true" />
                                <SelectionModel>
                                    <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" SingleSelect="true">
                                        <AjaxEvents>
                                            <RowSelect OnEvent="RowSelectOnEvent">
                                                <ExtraParams>
                                                    <ext:Parameter Name="Values" Value="Ext.encode(#{_grdsma}.getRowsValues())" Mode="Raw" />
                                                </ExtraParams>
                                            </RowSelect>
                                        </AjaxEvents>
                                    </ext:RowSelectionModel>
                                </SelectionModel>
                                <Listeners>
                                    <Command Handler="PreviewWindow(record.data.SurveyId);" />
                                    <DblClick Handler="NewWindow();" />
                                    <CellClick Fn="cellClick" />
                                </Listeners>
                            </ext:GridPanel>
                        </ext:FitLayout>
                    </Body>
                    <TopBar>
                        <ext:Toolbar ID="Toolbar1" runat="server">
                            <Items>
                                <ext:ToolbarButton ID="ToolbarButton1" runat="server" Icon="ApplicationOsxStart"
                                    Text="Yayınla">
                                    <AjaxEvents>
                                        <Click OnEvent="Publishing">
                                            <ExtraParams>
                                                <ext:Parameter Name="Values" Value="Ext.encode(#{_grdsma}.getRowsValues(false))"
                                                    Mode="Raw" />
                                            </ExtraParams>
                                        </Click>
                                    </AjaxEvents>
                                </ext:ToolbarButton>
                            </Items>
                        </ext:Toolbar>
                    </TopBar>
                </ext:Panel>
            </ext:FitLayout>
        </Body>
    </ext:ViewPort>
    <script type="text/javascript">
        function NewWindow() {
            var config = "Admin/Customization/Survey/SurveyScript.aspx?SurveyId=" + hdnSurveyId.getValue();
            window.top.newWindow(config, { title: 'SurveyScript', width: 800, height: 600, resizable: true });
        }
        function PreviewWindow(guid) {
            var config = "Admin/Customization/Survey/SurveyPreview.aspx?SurveyId=" + guid;
            window.top.newWindow(config, { title: 'Survey Preview', width: 800, height: 600, resizable: true });
        }

        var cellClick = function (grid, rowIndex, columnIndex, e) {
            var t = e.getTarget();
            var record = grid.getStore().getAt(rowIndex);  // Get the Record
            var columnId = grid.getColumnModel().getColumnId(columnIndex); // Get column id
            if (columnIndex == 1) {
                var v = record.data["Publish"];
                if (v) {
                    record.set('Publish', false);
                }
                else {
                    record.set('Publish', true);
                }

            }
        }
    </script>
    </form>
</body>
</html>
