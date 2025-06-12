<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Entity_Property_ViewEdit"
    ValidateRequest="false" Codebehind="ViewEdit.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<%@ Register Src="~/CrmPages/Admin/WorkFlow/ConditionBuilder.ascx" TagPrefix="uc1" TagName="ConditionBuilder" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style>
        .label {
            width: 300px;
            height: 15px;
            text-align: center;
            padding: 5px 0;
            border: 1px dotted #99bbe8;
            background: #dfe8f6;
            color: #15428b;
            cursor: default;
            margin: 10px;
            margin-left: 0px;
            font: bold 11px tahoma,arial,sans-serif;
        }

        .grid-row-insert-below {
            border-bottom: 1px solid #3366cc;
        }
        

        .grid-row-insert-above {
            border-top: 1px solid #3366cc;
        }
    </style>
    <script type="text/javascript">
        var AttributeSelector = {
            add: function (source, destination) {
                source = source || GridPanel1;
                destination = destination || GridPanel2;
                debugger;
                if (source.hasSelection()) {
                    destination.store.add(source.selModel.getSelections());
                    source.deleteSelected();
                }
            },
            addAll: function (source, destination) {
                source = source || GridPanel1;
                destination = destination || GridPanel2;
                destination.store.add(source.store.getRange());
                source.store.removeAll();
            },
            addByName: function (name) {
                if (!Ext.isEmpty(name)) {
                    var result = StoreViewAttribute.query("Name", name);
                    if (!Ext.isEmpty(result.items)) {
                        GridPanel2.store.add(result.items[0]);
                        GridPanel1.store.remove(result.items[0]);
                    }
                }
            },
            addByNames: function (name) {
                for (var i = 0; i < name.length; i++) {
                    this.addByName(name[i]);
                }
            },
            remove: function (source, destination) {
                this.add(destination, source);
            },
            removeAll: function (source, destination) {
                this.addAll(destination, source);
            }
        };
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <ext:Hidden runat="server" ID="hdnObjectId">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnId">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnFormEditType">
        </ext:Hidden>
        <ext:Store runat="server" ID="StoreEntityObjectAttributeList" AutoLoad="true">
            <SortInfo Field="Label" Direction="ASC" />
            <Reader>
                <ext:JsonReader ReaderID="AttributeId">
                    <Fields>
                        <ext:RecordField Name="AttributeId" />
                        <ext:RecordField Name="Label" />
                        <ext:RecordField Name="UniqueName" />
                        <ext:RecordField Name="ReferencedObjectId" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store runat="server" ID="StoreViewAttribute">
            <Reader>
                <ext:JsonReader >
                    <Fields>
                        <ext:RecordField Name="AttributeId" />
                        <ext:RecordField Name="Label" />
                        <ext:RecordField Name="UniqueName" />
                        <ext:RecordField Name="ReferencedObjectId" />
                        <ext:RecordField Name="ObjectAlias" Type="String" />
                        
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store runat="server" ID="StoreViewAttributeSelected" OnSubmitData="SubmitData">
            <Reader>
                <ext:JsonReader >
                    <Fields>
                        <ext:RecordField Name="AttributeId" />
                        <ext:RecordField Name="Label" />
                        <ext:RecordField Name="UniqueName" />
                        <ext:RecordField Name="Width" />
                        <ext:RecordField Name="IsSearchable" Type="Boolean" />
                        <ext:RecordField Name="IsHeaderSearchable" Type="Boolean" />
                        <ext:RecordField Name="IsLinked" Type="Boolean" />
                        <ext:RecordField Name="IsExtended" Type="Boolean" />
                        <ext:RecordField Name="IsIdColumn" Type="Boolean" />
                        <ext:RecordField Name="IsMultipleSelect" Type="Boolean" />
                        <ext:RecordField Name="IsSubTotal" Type="Boolean" />
                        <ext:RecordField Name="TargetViewUniqueName" Type="String" />
                        <ext:RecordField Name="ObjectAlias" Type="String" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store runat="server" ID="storeOrderBy">
            <Reader>
                <ext:JsonReader ReaderID="AttributeId">
                    <Fields>
                        <ext:RecordField Name="AttributeId" />
                        <ext:RecordField Name="Label" />
                        <ext:RecordField Name="Direction" />
                        <ext:RecordField Name="UniqueName" />
                        <ext:RecordField Name="DirectionLabel" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        
        <ext:Store runat="server" ID="StorecmbDefaultEditPage" AutoLoad="true" OnRefreshData="StorecmbDefaultEditPage_OnRefreshData">
            <Proxy>
                <ext:DataSourceProxy />
            </Proxy>
            <SortInfo Field="Name" Direction="ASC" />
            <Reader>
                <ext:JsonReader ReaderID="FormId">
                    <Fields>
                        <ext:RecordField Name="FormId" />
                        <ext:RecordField Name="Name" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store runat="server" ID="StoreGrdButtons">
            <SortInfo Field="Label" Direction="ASC" />
            <Reader>
                <ext:JsonReader ReaderID="ButtonId">
                    <Fields>
                        <ext:RecordField Name="ButtonId" />
                        <ext:RecordField Name="UniqueName" />
                        <ext:RecordField Name="Label" />
                        <ext:RecordField Type="Boolean" Name="IsHide" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store ID="StoreUser" runat="server" OnRefreshData="StoreUOnRefreshData" RemoteSort="true"
            AutoLoad="true">
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
            <SortInfo Field="FullName" Direction="ASC" />
        </ext:Store>
        <ext:Store ID="StoreBu" runat="server" OnRefreshData="StoreBuOnRefreshData" RemoteSort="true"
            AutoLoad="true">
            <Proxy>
                <ext:DataSourceProxy />
            </Proxy>
            <Reader>
                <ext:JsonReader ReaderID="BusinessUnitId">
                    <Fields>
                        <ext:RecordField Name="BusinessUnitId" Type="String" />
                        <ext:RecordField Name="Name" Type="String" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
            <SortInfo Field="Name" Direction="ASC" />
        </ext:Store>
        <ext:ViewPort runat="server" AutoWidth="true">
            <Body>
                <ext:FitLayout runat="server">
                    <ext:Panel runat="server" AutoWidth="true">
                        <TopBar>
                            <ext:Toolbar runat="server">
                                <Items>
                                    <ext:Button Icon="Disk" ID="BtnSave" Text="Save" runat="server">
                                        <Listeners>
                                            <Click Handler="
                                if(#{FormPanel1}.validate() && #{FormPanelAdministrations}.validate()){
                                GenerateXml(#{GridPanel2},#{WhereTree},#{GridPanel3},#{GrdButtons})
                                }
                                else{alert('Fill Requared fields')}" />
                                        </Listeners>
                                    </ext:Button>
                                    <ext:Button Icon="DatabaseCopy" ID="BtnCopyView" Text="Copy" runat="server">
                                        <AjaxEvents>
                                            <Click OnEvent="BtnCopyView_OnClikc">
                                                <EventMask ShowMask="true" />
                                            </Click>
                                        </AjaxEvents>
                                    </ext:Button>
                                </Items>
                            </ext:Toolbar>
                        </TopBar>
                        <Body>
                            <ext:TabPanel runat="server" AutoWidth="true">
                                <Tabs>
                                    <ext:Tab Title="Colums" AutoHeight="true" AutoWidth="true">
                                        <Body>
                                            <ext:TableLayout ID="TableLayout1" runat="server" Columns="3">
                                                <ext:Cell ColSpan="3">
                                                    <ext:FormPanel ID="FormPanel1" runat="server" BodyStyle="padding:5px;" ButtonAlign="Right">
                                                        <Body>
                                                            <ext:FormLayout ID="FormLayout1" runat="server">
                                                                <ext:Anchor>
                                                                    <ext:TextField runat="server" ID="NewViewName" FieldLabel="View Name" Width="600"
                                                                        AllowBlank="false">
                                                                    </ext:TextField>
                                                                </ext:Anchor>
                                                                <ext:Anchor Horizontal="100%">
                                                                    <ext:ComboBox ID="CmbViewLabel" FieldLabel="View Multiple Label"
                                                                        Editable="false" runat="server">
                                                                        <Items>
                                                                        </Items>
                                                                    </ext:ComboBox>
                                                                </ext:Anchor>

                                                            </ext:FormLayout>
                                                        </Body>
                                                    </ext:FormPanel>
                                                </ext:Cell>
                                                <ext:Cell>
                                                    <ext:Panel ID="Panel1" runat="server" Border="false" BodyStyle="height: 300px;">
                                                        <Body>
                                                            <ext:GridPanel runat="server" Height="300" Width="350" ID="GridPanel1" EnableDragDrop="true"
                                                                AutoExpandColumn="Attribute" StoreID="StoreViewAttribute" >
                                                                <ColumnModel ID="ColumnModel1" runat="server">
                                                                    <Columns>
                                                                        <ext:Column ColumnID="Attribute" Header="Available Column" DataIndex="Label" MenuDisabled="true" />
                                                                    </Columns>
                                                                </ColumnModel>
                                                                <SelectionModel>
                                                                    <ext:CheckboxSelectionModel ID="CheckboxSelectionModel1" runat="server" />
                                                                </SelectionModel>
                                                            </ext:GridPanel>
                                                        </Body>
                                                    </ext:Panel>
                                                </ext:Cell>
                                                <ext:Cell>
                                                    <ext:Panel runat="server" Width="35" BodyStyle="background-color: transparent;" Border="false">
                                                        <Body>
                                                            <ext:AnchorLayout ID="AnchorLayout1" runat="server">
                                                                <ext:Anchor Vertical="40%">
                                                                    <ext:Panel ID="Panel3" runat="server" Border="false" BodyStyle="background-color: transparent;" />
                                                                </ext:Anchor>
                                                                <ext:Anchor>
                                                                    <ext:Panel ID="Panel4" runat="server" Border="false" BodyStyle="padding:5px;background-color: transparent;">
                                                                        <Body>
                                                                            <ext:Button ID="Button1" runat="server" Icon="ResultsetNext" StyleSpec="margin-bottom:2px;">
                                                                                <Listeners>
                                                                                    <Click Handler="AttributeSelector.add();" />
                                                                                </Listeners>
                                                                                <ToolTips>
                                                                                    <ext:ToolTip ID="ToolTip1" runat="server" Title="Add" Html="Add Selected Rows" />
                                                                                </ToolTips>
                                                                            </ext:Button>
                                                                            <ext:Button ID="Button2" runat="server" Icon="ResultsetLast" StyleSpec="margin-bottom:2px;">
                                                                                <Listeners>
                                                                                    <Click Handler="AttributeSelector.addAll();" />
                                                                                </Listeners>
                                                                                <ToolTips>
                                                                                    <ext:ToolTip ID="ToolTip2" runat="server" Title="Add all" Html="Add All Rows" />
                                                                                </ToolTips>
                                                                            </ext:Button>
                                                                            <ext:Button ID="Button3" runat="server" Icon="ResultsetPrevious" StyleSpec="margin-bottom:2px;">
                                                                                <Listeners>
                                                                                    <Click Handler="AttributeSelector.remove(GridPanel1, GridPanel2);" />
                                                                                </Listeners>
                                                                                <ToolTips>
                                                                                    <ext:ToolTip ID="ToolTip3" runat="server" Title="Remove" Html="Remove Selected Rows" />
                                                                                </ToolTips>
                                                                            </ext:Button>
                                                                            <ext:Button ID="Button4" runat="server" Icon="ResultsetFirst" StyleSpec="margin-bottom:2px;">
                                                                                <Listeners>
                                                                                    <Click Handler="AttributeSelector.removeAll(GridPanel1, GridPanel2);" />
                                                                                </Listeners>
                                                                                <ToolTips>
                                                                                    <ext:ToolTip ID="ToolTip4" runat="server" Title="Remove all" Html="Remove All Rows" />
                                                                                </ToolTips>
                                                                            </ext:Button>
                                                                        </Body>
                                                                    </ext:Panel>
                                                                </ext:Anchor>
                                                            </ext:AnchorLayout>
                                                        </Body>
                                                    </ext:Panel>
                                                </ext:Cell>
                                                <ext:Cell>
                                                    <ext:Panel ID="Panel2" runat="server" Border="false" BodyStyle="height: 300px;">
                                                        <Body>
                                                            <ext:GridPanel runat="server" ID="GridPanel2" Height="300" Width="600" EnableDragDrop="false"
                                                                StoreID="StoreViewAttributeSelected">
                                                                <ColumnModel ID="ColumnModel2" runat="server">
                                                                    <Columns>
                                                                        <ext:Column ColumnID="Attribute" Header="Selected Column" DataIndex="Label" Sortable="false"
                                                                            MenuDisabled="true" Width="200" />
                                                                        <ext:Column ColumnID="Attribute1" Header="Width" DataIndex="Width" Sortable="false"
                                                                            MenuDisabled="true" Width="50">
                                                                            <Editor>
                                                                                <ext:NumberField ID="NumberField1" runat="server">
                                                                                </ext:NumberField>
                                                                            </Editor>
                                                                        </ext:Column>
                                                                        <ext:CheckColumn DataIndex="IsSearchable" Header="Search" Editable="true" MenuDisabled="true"
                                                                            Width="50">
                                                                        </ext:CheckColumn>
                                                                        <ext:CheckColumn DataIndex="IsHeaderSearchable" Header="Header Search" Editable="true"
                                                                            MenuDisabled="true" Width="50">
                                                                        </ext:CheckColumn>
                                                                        <ext:CheckColumn DataIndex="IsLinked" Header="Link" MenuDisabled="true" Editable="true"
                                                                            Width="50">
                                                                        </ext:CheckColumn>
                                                                        <ext:CheckColumn DataIndex="IsExtended" Header="Extended" MenuDisabled="true" Editable="true"
                                                                            Width="50">
                                                                        </ext:CheckColumn>
                                                                        <ext:CheckColumn DataIndex="IsIdColumn" Header="Id Column" MenuDisabled="true" Editable="true"
                                                                            Width="50">
                                                                        </ext:CheckColumn>
                                                                        <ext:CheckColumn DataIndex="IsMultipleSelect" Header="Multiple Select" MenuDisabled="true" Editable="true"
                                                                            Width="50">
                                                                        </ext:CheckColumn>
                                                                        <ext:CheckColumn DataIndex="IsSubTotal" Header="Sub Total" MenuDisabled="true" Editable="true"
                                                                            Width="50">
                                                                        </ext:CheckColumn>
                                                                        <ext:Column DataIndex="TargetViewUniqueName" Header="Target View Unique Name" MenuDisabled="true" 
                                                                            Width="200">
                                                                             <Editor>
                                                                                <ext:TextField  ID="txtFiedl1" runat="server">
                                                                                </ext:TextField>
                                                                            </Editor>
                                                                        </ext:Column>
                                                                    </Columns>
                                                                </ColumnModel>
                                                                <Plugins>
                                                                    <ext:GenericPlugin ID="GenericPlugin1" runat="server" InstanceOf="Ext.ux.dd.GridDragDropRowOrder">
                                                                        <CustomConfig>
                                                                            <ext:ConfigItem Name="scrollable" Value="true">
                                                                            </ext:ConfigItem>
                                                                        </CustomConfig>
                                                                    </ext:GenericPlugin>
                                                                </Plugins>
                                                                <SelectionModel>
                                                                    <ext:RowSelectionModel ID="RowSelectionModel2" runat="server" />
                                                                </SelectionModel>
                                                                <SaveMask ShowMask="true" />
                                                            </ext:GridPanel>
                                                        </Body>
                                                    </ext:Panel>
                                                </ext:Cell>
                                            </ext:TableLayout>
                                        </Body>
                                    </ext:Tab>
                                    <ext:Tab Title="Where" AutoHeight="true">
                                        <Body>
                                            <uc1:ConditionBuilder ID="CBuilder" runat="server" />
                                        </Body>
                                    </ext:Tab>
                                    <ext:Tab Title="Property" AutoHeight="true" runat="server">
                                        <Body>
                                            <ext:Panel runat="server">
                                                <Body>
                                                    <ext:FormLayout ID="FormLayout4" runat="server" AutoShow="false">
                                                        <ext:Anchor>
                                                            <ext:TextField runat="server" ID="UniqueName" FieldLabel="View Unique Name"
                                                                Width="300">
                                                            </ext:TextField>
                                                        </ext:Anchor>

                                                        <ext:Anchor>
                                                            <ext:NumberField runat="server" ID="txtDisplayOrder" FieldLabel="Display Order"
                                                                Width="100">
                                                            </ext:NumberField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:TextField runat="server" ID="txtUserControl" FieldLabel="User Control"
                                                                Width="300">
                                                            </ext:TextField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:Checkbox runat="server" FieldLabel="Default View" ID="DefaultView">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:Checkbox runat="server" FieldLabel="Use Nolock" ID="UseNolock">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>

                                                        <ext:Anchor>
                                                            <ext:ComboBox runat="server" AllowBlank="false" Resizable="false" ID="cmbDefaultEditPage"
                                                                StoreID="StorecmbDefaultEditPage" ValueField="FormId" DisplayField="Name" FieldLabel="Default Edit Page"
                                                                Width="200">
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:ComboBox runat="server" AllowBlank="false" Resizable="false" ID="ViewType" FieldLabel="Type"
                                                                Width="200">
                                                                <Items>
                                                                    <ext:ListItem Text="List" Value="0" />
                                                                    <ext:ListItem Text="Look Up" Value="2" />
                                                                    <ext:ListItem Text="Dashboard List" Value="3" />
                                                                    <ext:ListItem Text="Programmatical" Value="4" />
                                                                </Items>
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:ComboBox runat="server" AllowBlank="false" Resizable="false" ID="ExtenderType"
                                                                FieldLabel="Extender Type" Width="200">
                                                                <Items>
                                                                    <ext:ListItem Text="None" Value="0" />
                                                                    <ext:ListItem Text="Expanded" Value="1" />
                                                                    <ext:ListItem Text="Collapsed" Value="2" />
                                                                </Items>
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:GridPanel runat="server" ID="GrdButtons" Height="200" AutoWidth="false" StoreID="StoreGrdButtons">
                                                                <ColumnModel ID="ColumnModel4" runat="server">
                                                                    <Columns>
                                                                        <ext:Column DataIndex="ButtonId" Hidden="true" Header="ButtonId" MenuDisabled="true"
                                                                            Sortable="false">
                                                                        </ext:Column>
                                                                        <ext:Column DataIndex="UniqueName" Hidden="true" Header="UniqueName" MenuDisabled="true"
                                                                            Sortable="false">
                                                                        </ext:Column>
                                                                        <ext:Column DataIndex="Label" Hidden="false" Width="300" Header="Name" MenuDisabled="true"
                                                                            Sortable="false">
                                                                        </ext:Column>
                                                                        <ext:CheckColumn DataIndex="IsHide" Width="100" Header="Hide" MenuDisabled="true"
                                                                            Editable="true" Sortable="false">
                                                                        </ext:CheckColumn>
                                                                    </Columns>
                                                                </ColumnModel>
                                                                <SelectionModel>
                                                                    <ext:RowSelectionModel ID="RowSelectionModel3" runat="server" />
                                                                </SelectionModel>
                                                            </ext:GridPanel>
                                                        </ext:Anchor>
                                                    </ext:FormLayout>
                                                </Body>
                                            </ext:Panel>
                                        </Body>
                                    </ext:Tab>
                                    <ext:Tab Title="Order By" AutoHeight="true" runat="server" BodyStyle="padding:10px">
                                        <Body>
                                            <ext:Panel ID="Panel6" runat="server" Frame="false" Border="false">
                                                <Body>
                                                    <ext:FormLayout ID="FormLayout2" runat="server" AutoShow="true">
                                                        <ext:Anchor>
                                                            <ext:ComboBox runat="server" ID="OrderFields" Editable="false" FieldLabel="Fields"
                                                                StoreID="StoreViewAttributeSelected" ValueField="AttributeId" DisplayField="Label">
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:ComboBox runat="server" ID="Direction" Editable="false" FieldLabel="Direction">
                                                                <Items>
                                                                    <ext:ListItem Value="0" Text="ASC" />
                                                                    <ext:ListItem Value="1" Text="DESC" />
                                                                </Items>
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                    </ext:FormLayout>
                                                </Body>
                                                <BottomBar>
                                                    <ext:Toolbar runat="server">
                                                        <Items>
                                                            <ext:ToolbarButton runat="server" ID="OrderAdd" Icon="Add">
                                                                <Listeners>
                                                                    <Click Handler="OrderByAdd();" />
                                                                </Listeners>
                                                            </ext:ToolbarButton>
                                                            <ext:ToolbarButton runat="server" ID="ToolbarButton1" Icon="Delete">
                                                                <Listeners>
                                                                    <Click Handler="OrderByDelete();" />
                                                                </Listeners>
                                                            </ext:ToolbarButton>
                                                        </Items>
                                                    </ext:Toolbar>
                                                </BottomBar>
                                            </ext:Panel>
                                            <ext:Panel ID="Panel5" runat="server" Frame="false" Border="false">
                                                <Body>
                                                    <ext:FitLayout ID="FitLayout1" runat="server">
                                                        <ext:GridPanel runat="server" ID="GridPanel3" Height="230" AutoWidth="true" StoreID="storeOrderBy">
                                                            <ColumnModel ID="ColumnModel3" runat="server">
                                                                <Columns>
                                                                    <ext:RowNumbererColumn />
                                                                    <ext:Column ColumnID="AttributeId" DataIndex="AttributeId" Hidden="true" />
                                                                    <ext:Column ColumnID="Attribute" Header="Selected Column" DataIndex="Label" Sortable="false"
                                                                        Width="200" MenuDisabled="true" />
                                                                    <ext:Column DataIndex="Direction" Header="Direction" Hidden="true" />
                                                                    <ext:Column DataIndex="UniqueName" Header="UniqueName" Hidden="true" />
                                                                    <ext:Column DataIndex="DirectionLabel" Header="Direction" MenuDisabled="true" />
                                                                </Columns>
                                                            </ColumnModel>
                                                            <SelectionModel>
                                                                <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" />
                                                            </SelectionModel>
                                                        </ext:GridPanel>
                                                    </ext:FitLayout>
                                                </Body>
                                            </ext:Panel>
                                        </Body>
                                    </ext:Tab>
                                    <ext:Tab Title="Administrations">
                                        <Body>
                                            <ext:FormPanel ID="FormPanelAdministrations" runat="server" Width="600" Frame="true">
                                                <BottomBar>
                                                    <ext:Toolbar ID="Toolbar1" runat="server">
                                                        <Items>
                                                            <ext:Button Icon="PluginAdd" FieldLabel="Share" runat="server" ID="btnShare">
                                                                <Listeners>
                                                                    <Click Handler="Share()" />
                                                                </Listeners>
                                                            </ext:Button>
                                                        </Items>
                                                    </ext:Toolbar>
                                                </BottomBar>
                                                <Body>
                                                    <ext:ColumnLayout ID="ColumnLayout3" runat="server">
                                                        <ext:LayoutColumn ColumnWidth=".5">
                                                            <ext:Panel ID="Panel7" runat="server">
                                                                <Body>
                                                                    <ext:FormLayout ID="FormLayout10" runat="server" LabelAlign="Left">
                                                                        <Anchors>
                                                                            <ext:Anchor Horizontal="100%">
                                                                                <ext:ComboBox runat="server" ID="cmbOwningUser" DisplayField="FullName" ValueField="SystemUserId"
                                                                                    AllowBlank="true" StoreID="StoreUser" FieldLabel="OwningUser" Width="200" Mode="Remote">
                                                                                </ext:ComboBox>
                                                                            </ext:Anchor>
                                                                            <ext:Anchor Horizontal="100%">
                                                                                <ext:ComboBox runat="server" ID="cmbOwningBusinessUnit" DisplayField="Name" ValueField="BusinessUnitId"
                                                                                    AllowBlank="true" StoreID="StoreBu" FieldLabel="OwningBusinessUnit" Width="200"
                                                                                    Mode="Remote">
                                                                                </ext:ComboBox>
                                                                            </ext:Anchor>
                                                                        </Anchors>
                                                                    </ext:FormLayout>
                                                                </Body>
                                                            </ext:Panel>
                                                        </ext:LayoutColumn>
                                                    </ext:ColumnLayout>
                                                </Body>
                                            </ext:FormPanel>
                                        </Body>
                                    </ext:Tab>
                                </Tabs>
                            </ext:TabPanel>
                        </Body>
                    </ext:Panel>
                </ext:FitLayout>
            </Body>
        </ext:ViewPort>
    </form>
</body>
</html>
<script src="../../../../../js/GridOrdering.js" type="text/javascript"></script>
<script type="text/javascript" language="javascript">

    function OrderByAdd() {
        if (
        (!Ext.isEmpty(OrderFields.getValue())) &&
        (!Ext.isEmpty(Direction.getValue()))
        ) {
            var itemGuid = guid();
            var MyRecordType = Ext.data.Record.create(["AttributeId", "Label", "Direction", "DirectionLabel", "UniqueName"]);
            myrec = new MyRecordType({ "id": '' + itemGuid + '', "AttributeId": '' + OrderFields.getValue() + '', "Label": '' + OrderFields.getRawValue() + '', "Direction": '' + Direction.getValue() + '', "DirectionLabel": '' + Direction.getRawValue() + '', "UniqueName": '' + OrderFields.store.data.items[OrderFields.selectedIndex].data.UniqueName + '' });
            myrec.id = itemGuid;
            GridPanel3.store.insert(GridPanel3.store.data.length, myrec);
            OrderFields.clrValue();
            Direction.clrValue();
        }
    }

    function OrderByDelete() {
        if (GridPanel3.getRowsValues(true).length > 0) {
            GridPanel3.store.removeAt(GridPanel3.store.indexOfId(GridPanel3.getRowsValues(true)[0].AttributeId));
            GridPanel3.view.refresh();
        }
    }

    var _C_ClientId = null;
    var _D_ClientId = null;
    function Get(id, Type) {
        if (Type == "C") {
            if (!IsNull(_C_ClientId)) {
                return eval(_C_ClientId + "_" + id)
            }
            else {
                return eval(id)
            }
        }
        else if (Type == "D") {
            if (!IsNull(_D_ClientId)) {

                return eval(_D_ClientId + "_" + id)

            }
            else {
                return eval(id)
            }
        }
    }

    function GenerateXml(gp, tp, ord, btn) {
        var CntIsIdColumn = 0;
        var ObjItems = gp.getStore().data.items;
        var OrderByItems = ord.getStore().data.items;
        var ObjHideButton = btn.getStore().data.items;
        var defaulteditpage = "";
        if (cmbDefaultEditPage.getValue() != "")
            defaulteditpage = cmbDefaultEditPage.getValue();
        else {
            if (cmbDefaultEditPage.store.data.length > 0) {
                defaulteditpage = cmbDefaultEditPage.store.data.items[0].data.FormId;
            }
        }
        var gpXml, tpXml, btnXml;
        strXml = "";
        strXml += "<grid name='resultset' objectId='" + hdnObjectId.getValue() + "' displayorder='" + txtDisplayOrder.getValue() + "' ";
        strXml += " usercontrol='" + txtUserControl.getValue() + "' ";

        strXml += " defaulteditpage='{" + defaulteditpage + "}'";
        strXml += " >";
        strXml += "<row name='result'>";
        //alert(ObjItems.length);
        for (i = 0; i < ObjItems.length; i++) {
            var AttributeId = ObjItems[i].data.AttributeId;
            var UniqueName = ObjItems[i].data.UniqueName;
            var Width = "100";
            var IsSearchable = ObjItems[i].data.IsSearchable;
            var IsHeaderSearchable = ObjItems[i].data.IsHeaderSearchable;
            var IsExtended = ObjItems[i].data.IsExtended;

            var IsIdColumn = ObjItems[i].data.IsIdColumn;
            var IsLinked = ObjItems[i].data.IsLinked;
            var IsMultipleSelect = ObjItems[i].data.IsMultipleSelect;
            var IsSubTotal = ObjItems[i].data.IsSubTotal;
            var TargetViewUniqueName = ObjItems[i].data.TargetViewUniqueName;
            var ObjectAlias = ObjItems[i].data.ObjectAlias;
            if (IsIdColumn)
                CntIsIdColumn++;

            if (ObjItems[i].data.Width != null)
                Width = ObjItems[i].data.Width;

            var oNum = null;
            var oDirection = null;

            for (j = 0; j < OrderByItems.length; j++) {
                if (OrderByItems[j].data.AttributeId == AttributeId) {
                    oNum = j;
                    oDirection = OrderByItems[j].data.Direction;
                    break;
                }
            }

            strXml += "<cell name='" + UniqueName +
                "' id='{" + AttributeId + "}' width='" + Width +
                "' displayorder='" + i + "' issearchable='" + IsSearchable + "'" +
                " isheadersearchable='" + IsHeaderSearchable + "'" +
                " isextended='" + IsExtended + "'" +
                " isidcolumn='" + IsIdColumn + "'" +
                " islinked='" + IsLinked + "'" +
                " ismultipleselect='" + IsMultipleSelect + "'" +
                " issubtotal='" + IsSubTotal + "'" +
                " targetviewuniquename='" + TargetViewUniqueName + "'" +
                " objectalias='" + ObjectAlias + "'" +

                " direction='" + oDirection + "' ordernum='" + oNum + "'" +
                "/>";
        }

        strXml += " </row>";
        strXml += "</grid>";
        gpXml = strXml;

        strXml = "<filter >";
        strXml += getChildeXml(tp.root)
        strXml += "</filter >";
        tpXml = strXml;

        strXml = "";
        strXml += "<hidebutton>  ";
        for (i = 0; i < ObjHideButton.length; i++) {
            if (ObjHideButton[i].data.IsHide) {
                var ButtonId = ObjHideButton[i].data.ButtonId;
                var uniquename = ObjHideButton[i].data.UniqueName;
                strXml += "<button id='{" + ButtonId + "}' uniquename='" + uniquename + "'/>"
            }
        }
        strXml += "</hidebutton>  ";
        btnXml = strXml;

        if (CntIsIdColumn > 1) {
            alert("Attention ... more than one 'ID' column can not be selected");
            return;
        }

        Coolite.AjaxMethods.UpdateView(gpXml, tpXml, btnXml);
        window.location = window.location;
    }

    function Share() {

        var config = GetWebAppRoot + "/CrmPages/Admin/Share/Share.aspx?ObjectId=28&RecordId=" + hdnId.getValue()
    + "&rlistframename=" + window.name
        window.top.newWindow(config, { title: 'Share', width: 800, height: 300, resizable: false, modal: true });
    }

</script>