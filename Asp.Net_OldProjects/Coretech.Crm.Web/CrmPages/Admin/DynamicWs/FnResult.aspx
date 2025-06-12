<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_DynamicWs_FnResult" Codebehind="FnResult.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ext:Hidden ID="hdnMethodId" runat="server">
        </ext:Hidden>
        <ext:Store runat="server" ID="StoreFromAttribute" AutoLoad="True">
            <SortInfo Field="Label" Direction="ASC" />
            <Reader>
                <ext:JsonReader ReaderID="AttributeId">
                    <Fields>
                        <ext:RecordField Name="AttributeId" />
                        <ext:RecordField Name="Label" />
                        <ext:RecordField Name="UniqueName" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store ID="Store1" runat="server" AutoLoad="true" >
            <Reader>
                <ext:JsonReader ReaderID="ResultId">
                    <Fields>
                        <ext:RecordField Name="AttributeId">
                        </ext:RecordField>
                        <ext:RecordField Name="AttributeIdName">
                        </ext:RecordField>
                        <ext:RecordField Name="Description">
                        </ext:RecordField>
                        <ext:RecordField Name="ColumnName">
                        </ext:RecordField>
                        <ext:RecordField Name="DefaultValue">
                        </ext:RecordField>
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:ViewPort ID="ViewPort1" runat="server">
            <Body>
                <ext:Panel runat="server">
                    <TopBar>
                        <ext:Toolbar ID="Toolbar1" runat="server">
                            <Items>
                                <ext:Button ID="btnSave" runat="server" Icon="PageSave">
                                    <AjaxEvents>
                                        <Click OnEvent="BtnSave_Click">
                                            <EventMask ShowMask="true" />
                                            <ExtraParams>
                                                <ext:Parameter Name="Values" Value="Ext.encode(#{ResultList}.getRowsValues(false))"
                                                    Mode="Raw" />
                                            </ExtraParams>
                                        </Click>
                                    </AjaxEvents>
                                </ext:Button>
                            </Items>
                        </ext:Toolbar>
                    </TopBar>
                    <Body>
                        <ext:FitLayout ID="FitLayout1" runat="server">
                            <ext:GridPanel ID="ResultList" runat="server" StoreID="Store1" TrackMouseOver="false" Height="340">
                                <TopBar>
                                    <ext:Toolbar ID="Toolbar4" runat="server">
                                        <Items>
                                            <ext:ComboBox runat="server" ID="FromAttribute" StoreID="StoreFromAttribute" DisplayField="Label"
                                                ValueField="AttributeId" Width="250">
                                            </ext:ComboBox>
                                            <ext:Label runat="server" Text="ColumnName">
                                            </ext:Label>
                                            <ext:TextField ID="txtColumnName" Width="100" runat="server">
                                            </ext:TextField>
                                            <ext:Label Text="DefaultValue" runat="server">
                                            </ext:Label>
                                            <ext:TextField ID="txtDefaultValue" Width="100" runat="server">
                                            </ext:TextField>
                                            <ext:Label Text="Desc" runat="server">
                                            </ext:Label>
                                            <ext:TextField ID="txtDescription" runat="server" Width="100">
                                            </ext:TextField>
                                            <ext:Button ID="Button8" runat="server" Text="Add" Icon="Add">
                                                <Listeners>
                                                    <Click Handler="AddRecord(#{ResultList})" />
                                                </Listeners>
                                            </ext:Button>
                                            <ext:Button ID="Button10" runat="server" Text="Delete" Icon="Delete">
                                                <Listeners>
                                                    <Click Handler="#{ResultList}.deleteSelected();" />
                                                </Listeners>
                                            </ext:Button>
                                        </Items>
                                    </ext:Toolbar>
                                </TopBar>
                                <ColumnModel ID="ColumnModel1" runat="server">
                                    <Columns>
                                        <ext:Column Header="ClassName" DataIndex="AttributeId" Hidden="true" MenuDisabled="true"
                                            Width="250" Sortable="false">
                                        </ext:Column>
                                        <ext:Column Header="AttributeId Name" DataIndex="AttributeIdName" MenuDisabled="true" Width="250"
                                            Hidden="false" Sortable="false">
                                        </ext:Column>
                                        <ext:Column Header="ColumnName" DataIndex="ColumnName" MenuDisabled="true" Hidden="false"
                                            Width="200" Sortable="false">
                                        </ext:Column>
                                        <ext:Column Header="DefaultValue" DataIndex="DefaultValue" MenuDisabled="true" Hidden="false"
                                            Width="100" Sortable="false">
                                        </ext:Column>
                                        <ext:Column Header="Description" DataIndex="Description" MenuDisabled="true" Hidden="false"
                                            Width="100" Sortable="false">
                                        </ext:Column>
                                        <ext:Column Header="ResultId" DataIndex="ResultId" Width="100" Hidden="true" Sortable="false">
                                        </ext:Column>
                                    </Columns>
                                </ColumnModel>
                                <SelectionModel>
                                    <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" />
                                </SelectionModel>
                                <BottomBar>
                                    <ext:PagingToolbar ID="PagingToolBar1" runat="server" StoreID="Store1" DisplayInfo="true"
                                        DisplayMsg="Entity Listesi {0} - {1} Arası   -Toplam  {2} Kayıt" EmptyMsg="No employees to display" />
                                </BottomBar>
                                <LoadMask ShowMask="true" Msg="Loading Data..." />
                            </ext:GridPanel>
                        </ext:FitLayout>
                    </Body>
                </ext:Panel>
            </Body>
        </ext:ViewPort>
    </div>
    </form>
</body>
</html>
<script language="javascript">
    function AddRecord(grp) {
        var fid = FromAttribute.getValue();
        var fname = FromAttribute.getText();
        var tColumnName = txtColumnName.getValue();
        var tDefaultValue = txtDefaultValue.getValue();
        var tDescription = txtDescription.getValue();
        addGridPanelRecord(grp, fid, fname, tDescription, tColumnName, tDefaultValue);
    }

    function addGridPanelRecord(grp, fid, fname, tDescription, tColumnName, tDefaultValue) {

        var MyRecordType = Ext.data.Record.create(['id', 'ResultId', 'AttributeId', 'AttributeIdName', 'Description', 'ColumnName', 'DefaultValue']);
        var itemGuid = guid();
        myrec = new MyRecordType
       ({ "id": itemGuid, "ResultId": itemGuid, "AttributeId": fid, 'AttributeIdName': fname, "Description": tDescription, "ColumnName": tColumnName, "DefaultValue": tDefaultValue });
        grp.store.insert(grp.store.data.length, myrec);
        grp.store.commitChanges()
    }
    
    
</script>
