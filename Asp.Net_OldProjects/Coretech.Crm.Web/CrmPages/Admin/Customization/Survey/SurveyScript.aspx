<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Survey_SurveyScript" Codebehind="SurveyScript.aspx.cs" %>

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
    <ext:Hidden runat="server" ID="hdnanswerid">
    </ext:Hidden>
    <ext:Store ID="store1" runat="server" OnRefreshData="StoreOnRefreshData" RemoteSort="true"
        GroupField="ServeyPartName" AutoLoad="true">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="SpqAnswerId">
                <Fields>
                    <ext:RecordField Name="SurveyId" Type="String" />
                    <ext:RecordField Name="SPartId" Type="String" />
                    <ext:RecordField Name="SpQuestionId" Type="String" />
                    <ext:RecordField Name="SpqAnswerId" Type="String" />
                    <ext:RecordField Name="ServeyPartName" Type="String" />
                    <ext:RecordField Name="QuestionAnswer" Type="String" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="ServeyPartName" Direction="ASC" />
    </ext:Store>
    <ext:Store ID="store2" runat="server" OnRefreshData="Store2OnRefreshData" RemoteSort="true"
        WarningOnDirty="false" AutoLoad="false">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="SurveyScriptId">
                <Fields>
                    <ext:RecordField Name="SurveyScriptId" Type="String" />
                    <ext:RecordField Name="SurveyId" Type="String" />
                    <ext:RecordField Name="SPartId" Type="String" />
                    <ext:RecordField Name="SpQuestionId" Type="String" />
                    <ext:RecordField Name="Tanim" Type="String" />
                    <ext:RecordField Name="Show" Type="Boolean" />
                    <ext:RecordField Name="Hide" Type="Boolean" />
                    <ext:RecordField Name="Level" Type="Int" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="SurveyScriptId" Direction="ASC" />
    </ext:Store>
    <ext:Panel runat="server" ID="panel3" Frame="false" Border="false" BodyStyle="padding:10px">
        <Body>
            <ext:TableLayout runat="server" Columns="2">
                <ext:Cell>
                    <ext:Panel runat="server" ID="panel1" AutoWidth="true" Frame="false" Border="false"
                        BodyStyle="padding:10px">
                        <Body>
                            <ext:FitLayout ID="FitLayout1" runat="server">
                                <ext:GridPanel ID="_grdsma" runat="server" StripeRows="true" StoreID="store1" Width="320"
                                    Height="490">
                                    <ColumnModel ID="_columnModel2" runat="server">
                                        <Columns>
                                            <ext:RowNumbererColumn />
                                            <ext:Column Header="SurveyId" DataIndex="SurveyId" Width="50" Hidden="true" />
                                            <ext:Column Header="SPartId" DataIndex="SPartId" Width="50" Hidden="true" />
                                            <ext:Column Header="SpQuestionId" DataIndex="SpQuestionId" Width="50" Hidden="true" />
                                            <ext:Column Header="SpqAnswerId" DataIndex="SpqAnswerId" Width="50" Hidden="true" />
                                            <ext:Column Header="ServeyPartName" DataIndex="ServeyPartName" Width="330" Groupable="true"
                                                Sortable="false" />
                                            <ext:Column Header="QuestionAnswer" DataIndex="QuestionAnswer" Width="270" Sortable="false"
                                                MenuDisabled="true" />
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
                                    <View>
                                        <ext:GroupingView ID="GroupingView1" runat="server" HideGroupedColumn="true" ShowGroupName="false">
                                        </ext:GroupingView>
                                    </View>
                                </ext:GridPanel>
                            </ext:FitLayout>
                        </Body>
                    </ext:Panel>
                </ext:Cell>
                <ext:Cell>
                    <ext:Panel runat="server" ID="panel2" AutoWidth="true" Frame="false" Border="false"
                        BodyStyle="padding:10px">
                        <Body>
                            <ext:FitLayout ID="FitLayout2" runat="server">
                                <ext:GridPanel ID="GridPanel1" runat="server" StripeRows="true" StoreID="store2"
                                    Width="400" Height="490">
                                    <ColumnModel ID="ColumnModel1" runat="server">
                                        <Columns>
                                            <ext:RowNumbererColumn />
                                            <ext:Column Header="SurveyScriptId" DataIndex="SurveyScriptId" Width="50" Hidden="true" />
                                            <ext:Column Header="SurveyId" DataIndex="SurveyId" Width="50" Hidden="true" />
                                            <ext:Column Header="SPartId" DataIndex="SPartId" Width="50" Hidden="true" />
                                            <ext:Column Header="SpQuestionId" DataIndex="SpQuestionId" Width="50" Hidden="true" />
                                            <ext:Column Header="Tanim" DataIndex="Tanim" Width="250" Sortable="false" MenuDisabled="true">
                                                <Renderer Fn="change" />
                                            </ext:Column>
                                            <ext:CheckColumn ColumnID="chkShow" Header="Show" DataIndex="Show" Width="50" Sortable="false"
                                                MenuDisabled="true" />
                                            <ext:CheckColumn ColumnID="chkHide" Header="Hide" DataIndex="Hide" Width="50" Sortable="false"
                                                MenuDisabled="true" />
                                            <ext:Column Header="Level" DataIndex="Level" Width="50" Hidden="true" />
                                        </Columns>
                                    </ColumnModel>
                                    <LoadMask ShowMask="true" />
                                    <SelectionModel>
                                        <ext:CellSelectionModel runat="server" ID="CellSelectionModel1">
                                        </ext:CellSelectionModel>
                                    </SelectionModel>
                                    <Listeners>
                                        <CellClick Fn="cellClick" />
                                    </Listeners>
                                </ext:GridPanel>
                            </ext:FitLayout>
                        </Body>
                    </ext:Panel>
                </ext:Cell>
            </ext:TableLayout>
        </Body>
        <TopBar>
            <ext:Toolbar runat="server">
                <Items>
                    <ext:ToolbarButton runat="server" ID="btnScriptSave" Icon="ScriptSave" Text="Değişiklikleri Kaydet"
                        Disabled="true">
                        <AjaxEvents>
                            <Click OnEvent="ScriptSave">
                                <ExtraParams>
                                    <ext:Parameter Name="Values" Value="Ext.encode(#{GridPanel1}.getRowsValues(false))"
                                        Mode="Raw" />
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ext:ToolbarButton>
                </Items>
            </ext:Toolbar>
        </TopBar>
    </ext:Panel>
    <script type="text/javascript">
        var template = '<span style="{0};">{1}</span>';

        var change = function (value, a, b, c) {
            return String.format(template, (b.data.Level == 0) ? 'font-weight:bold;color:green' : '', value);
        }

        var cellClick = function (grid, rowIndex, columnIndex, e) {
            var t = e.getTarget();
            var record = grid.getStore().getAt(rowIndex);  // Get the Record
            var columnId = grid.getColumnModel().getColumnId(columnIndex); // Get column id
            if (columnIndex == 6) {
                var v = record.data[record.fields.items[columnIndex - 1].name];
                if (v) {
                    record.set('Show', false);
                }
                else {
                    record.set('Show', true);
                }
            }
            if (columnIndex == 7) {
                var v = record.data[record.fields.items[columnIndex - 1].name];
                if (v) {
                    record.set('Hide', false);
                }
                else {
                    record.set('Hide', true);
                }
            }
        }
    </script>
    </form>
</body>
</html>
