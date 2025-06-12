<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Entity_Property_FormEdit"
    ValidateRequest="false" Codebehind="FormEdit.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div style="display: none">
        <ext:Hidden runat="server" ID="hdnObjectId">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnFormId">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnFormEditType">
        </ext:Hidden>
        <ext:Hidden ID="SelectedSectionId" runat="server">
        </ext:Hidden>
        <ext:Store runat="server" ID="StoreViewAttribute">
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
        <ext:Store runat="server" ID="StoreViewAttributeDeleted" AutoLoad="true">
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
        <ext:Store runat="server" ID="storeSectionList" AutoLoad="true">
            <Reader>
                <ext:JsonReader ReaderID="id">
                    <Fields>
                        <ext:RecordField Name="id" />
                        <ext:RecordField Name="value" />
                        <ext:RecordField Name="text" />
                        <ext:RecordField Name="sectionid" />
                        <ext:RecordField Name="type" />
                        <ext:RecordField Name="showheader" />
                        <ext:RecordField Name="useborder" />
                        <ext:RecordField Name="sectionlabel" />
                        <ext:RecordField Name="labelwidth" />
                        <ext:RecordField Name="xmlvalue" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store runat="server" ID="StoreViewerList" AutoLoad="false" OnRefreshData="StoreViewerList_OnRefreshData">
            <AjaxEventConfig>
                <EventMask ShowMask="true" />
            </AjaxEventConfig>
            <Proxy>
                <ext:DataSourceProxy>
                </ext:DataSourceProxy>
            </Proxy>
            <Reader>
                <ext:JsonReader ReaderID="ViewQueryId">
                    <Fields>
                        <ext:RecordField Name="ViewQueryId" />
                        <ext:RecordField Name="Name" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
            <BaseParams>
                <ext:Parameter Name="attributeId" Value="_ActivePortlet.uniqueid" Mode="Raw">
                </ext:Parameter>
            </BaseParams>
            <Listeners>
                <Load Handler="StoreViewerListSetValue()" />
            </Listeners>
        </ext:Store>
        <ext:Store runat="server" ID="StoreParentChildGrid">
            <AjaxEventConfig>
                <EventMask ShowMask="true" />
            </AjaxEventConfig>
            <Reader>
                <ext:JsonReader>
                    <Fields>
                        <ext:RecordField Name="FromAttributeId" />
                        <ext:RecordField Name="FromAttributeIdName" />
                        <ext:RecordField Name="ToAttributeId" />
                        <ext:RecordField Name="ToAttributeIdName" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store runat="server" ID="StoreMapPathGrid">
            <AjaxEventConfig>
                <EventMask ShowMask="true" />
            </AjaxEventConfig>
            <Reader>
                <ext:JsonReader>
                    <Fields>
                        <ext:RecordField Name="FromAttributeId" />
                        <ext:RecordField Name="FromAttributeIdName" />
                        <ext:RecordField Name="ToAttributeId" />
                        <ext:RecordField Name="ToAttributeIdName" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
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
        <ext:Store runat="server" ID="StoreToAttribute" OnRefreshData="StoreToAttribute_OnRefreshData"
            AutoLoad="false">
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
            <BaseParams>
                <ext:Parameter Name="EaId" Value="_ActivePortlet.uniqueid" Mode="Raw">
                </ext:Parameter>
                <ext:Parameter Name="ViewId" Value="LookupViewList.getValue()" Mode="Raw">
                </ext:Parameter>
            </BaseParams>
        </ext:Store>
        <ext:Store runat="server" ID="StoreMappathToAttribute" OnRefreshData="StoreMappathToAttribute_OnRefreshData"
            AutoLoad="false">
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
            <BaseParams>
                <ext:Parameter Name="ViewId" Value="_activeReleatedList.ViewQueryId" Mode="Raw">
                </ext:Parameter>
            </BaseParams>
        </ext:Store>
        <ext:Store runat="server" ID="StoreGridReleatedList" AutoLoad="true">
            <Reader>
                <ext:JsonReader ReaderID="ReleatedListId">
                    <Fields>
                        <ext:RecordField Name="ReleatedListId" />
                        <ext:RecordField Name="EntityRelationShipId" />
                        <ext:RecordField Name="Label" />
                        <ext:RecordField Name="LabelMessageId" />
                        <ext:RecordField Name="LabelMessageIdName" />
                        <ext:RecordField Name="ViewQueryId" />
                        <ext:RecordField Name="ViewQueryIdName" />
                        <ext:RecordField Name="SortAttributeId" />
                        <ext:RecordField Name="SortAttributeName" />
                        <ext:RecordField Name="IsEntity" Type="Boolean" />
                        <ext:RecordField Name="Url" />
                        <ext:RecordField Name="Name" />
                        <ext:RecordField Name="FilterListXml" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store runat="server" ID="StoreReleatedList" AutoLoad="false">
            <Reader>
                <ext:JsonReader ReaderID="ViewQueryId">
                    <Fields>
                        <ext:RecordField Name="ViewQueryId" />
                        <ext:RecordField Name="EntityRelationShipId" />
                        <ext:RecordField Name="Name" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store runat="server" ID="StoreCmbSort" OnRefreshData="StoreCmbSort_OnRefreshData"
            AutoLoad="false">
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
            <BaseParams>
                <ext:Parameter Name="ViewQueryId" Value="ReleatedViewQuery.getValue()" Mode="Raw">
                </ext:Parameter>
            </BaseParams>
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
    </div>
    <ext:ViewPort runat="server">
        <Body>
            <ext:RowLayout ID="RowLayout1" runat="server">
                <ext:LayoutRow>
                    <ext:Panel runat="server">
                        <TopBar>
                            <ext:Toolbar runat="server">
                                <Items>
                                    <ext:Button Icon="Disk" ID="BtnSave" runat="server">
                                        <Listeners>
                                            <Click Handler="
                                if(#{txtFormName}.validate() && #{FormPanelAdministrations}.validate()){
                                btn_Save_Click()
                                }
                                else{alert('Fill Requared fields')}" />
                                        </Listeners>
                                    </ext:Button>
                                    <ext:Button Icon="DatabaseCopy" ID="BtnCopyForm" Text="Copy" runat="server">
                                        <AjaxEvents>
                                            <Click OnEvent="BtnCopyForm_OnClikc">
                                                <EventMask ShowMask="true" />
                                            </Click>
                                        </AjaxEvents>
                                    </ext:Button>
                                    <ext:Button ID="btnPublish" runat="server" Text="Publish" Icon="ApplicationGet">
                                        <AjaxEvents>
                                            <Click OnEvent="btnPublish_OnClikc">
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
                                    <ext:Panel runat="server" Border="false" Header="false">
                                        <Body>
                                            <ext:FormLayout ID="FormLayoutName" runat="server" LabelAlign="Left">
                                                <Anchors>
                                                    <ext:Anchor Horizontal="95%">
                                                        <ext:TextField ID="txtFormName" runat="server" FieldLabel="Form Name" LabelStyle="color:blue;"
                                                            AllowBlank="false" />
                                                    </ext:Anchor>
                                                </Anchors>
                                            </ext:FormLayout>
                                        </Body>
                                    </ext:Panel>
                                </ext:LayoutColumn>
                                <ext:LayoutColumn ColumnWidth=".5">
                                    <ext:Panel ID="Panel4" runat="server" Border="false" Header="false">
                                        <Body>
                                            <ext:FormLayout ID="FormLayout1" runat="server" LabelAlign="Left">
                                                <Anchors>
                                                    <ext:Anchor Horizontal="95%">
                                                        <ext:Checkbox ID="chkIsDefaultEditForm" runat="server" FieldLabel="Default Edit Form"
                                                            LabelStyle="color:blue;" />
                                                    </ext:Anchor>
                                                </Anchors>
                                            </ext:FormLayout>
                                        </Body>
                                    </ext:Panel>
                                </ext:LayoutColumn>
                            </ext:ColumnLayout>
                        </Body>
                    </ext:Panel>
                </ext:LayoutRow>
                <ext:LayoutRow RowHeight=".90">
                    <ext:Panel runat="server">
                        <Body>
                            <ext:FitLayout runat="server">
                                <ext:Panel runat="server">
                                    <Body>
                                        <ext:BorderLayout ID="BorderLayout1" runat="server">
                                            <West Collapsible="true" Split="true">
                                                <ext:Panel ID="Panel1" runat="server" Title="Sections" Width="175">
                                                    <TopBar>
                                                        <ext:Toolbar ID="Toolbar2" runat="server">
                                                            <Items>
                                                                <ext:Button ID="btnNewSection" runat="server" Icon="Add" Text="Add Section">
                                                                    <Listeners>
                                                                        <Click Handler="AddNewPortal(#{SectionViewer})" />
                                                                    </Listeners>
                                                                </ext:Button>
                                                                <ext:Button ID="btnDeleteSection" runat="server" Icon="Delete" Text="Delete">
                                                                    <Listeners>
                                                                        <Click Handler="DeleteSection(#{SectionViewer})" />
                                                                    </Listeners>
                                                                </ext:Button>
                                                            </Items>
                                                        </ext:Toolbar>
                                                    </TopBar>
                                                    <Body>
                                                        <ext:Panel runat="server" Height="150">
                                                            <Body>
                                                                <ext:FitLayout ID="FitLayout1" runat="server">
                                                                    <ext:MultiSelect ID="lstSectionList" StoreID="storeSectionList" runat="server" DragGroup="grp1"
                                                                        DropGroup="grp1" MultiSelect="false" DisplayField="text" ValueField="value">
                                                                        <Items>
                                                                        </Items>
                                                                        <Listeners>
                                                                            <Click Handler="lstSectionList_Click(#{lstSectionList}.getValue())" />
                                                                            <DblClick Handler="lstSectionList_DblClick(#{lstSectionList}.getValue())" />
                                                                        </Listeners>
                                                                    </ext:MultiSelect>
                                                                </ext:FitLayout>
                                                            </Body>
                                                        </ext:Panel>
                                                    </Body>
                                                </ext:Panel>
                                            </West>
                                            <Center>
                                                <ext:TabPanel ID="TabPanel1" runat="server" AutoScroll="true">
                                                    <Tabs>
                                                        <ext:Tab Title="General">
                                                            <Body>
                                                                <ext:Panel ID="Panel2" runat="server" AutoWidth="true" Height="480" AutoScroll="true">
                                                                    <TopBar>
                                                                        <ext:Toolbar ID="Toolbar1" runat="server">
                                                                            <Items>
                                                                                <ext:Button ID="Button1" runat="server" Icon="Add" Text="Add Attribute">
                                                                                    <Listeners>
                                                                                        <Click Handler="ShowWindowAttributeList(#{WindowAttributeList})" />
                                                                                    </Listeners>
                                                                                </ext:Button>
                                                                                <ext:Button runat="server" Icon="Add" Text="Add Iframe">
                                                                                    <Listeners>
                                                                                        <Click Handler="ShowWindowIframeList(#{WindowIframe});_ActivePortlet =null" />
                                                                                    </Listeners>
                                                                                </ext:Button>
                                                                                <ext:Button runat="server" Icon="Add" Text="Add Button">
                                                                                    <Listeners>
                                                                                        <Click Handler="ShowWindowButtonList(#{WindowButton});_ActivePortlet =null" />
                                                                                    </Listeners>
                                                                                </ext:Button>
                                                                                <ext:Button ID="Button16" runat="server" Icon="Add" Text="Add Label">
                                                                                    <Listeners>
                                                                                        <Click Handler="ShowWindowLabelList(#{WindowLabel});_ActivePortlet =null" />
                                                                                    </Listeners>
                                                                                </ext:Button>
                                                                                <ext:Button ID="Button17" runat="server" Icon="Add" Text="Add Web Control">
                                                                                    <Listeners>
                                                                                        <Click Handler="ShowWindowWebControl(#{WindowWebControl});_ActivePortlet =null" />
                                                                                    </Listeners>
                                                                                </ext:Button>
                                                                                
                                                                            </Items>
                                                                        </ext:Toolbar>
                                                                    </TopBar>
                                                                    <Body>
                                                                        <ext:Portal ID="SectionViewer" runat="server" Title="Section Name" Border="false">
                                                                            <Body>
                                                                            </Body>
                                                                        </ext:Portal>
                                                                    </Body>
                                                                </ext:Panel>
                                                            </Body>
                                                        </ext:Tab>
                                                        <ext:Tab Title="Page Property">
                                                            <Body>
                                                                <ext:Panel runat="server" Title="Page Property">
                                                                    <Body>
                                                                        <ext:Panel runat="server">
                                                                            <Body>
                                                                                <ext:FormLayout runat="server" LabelWidth="150">
                                                                                    <Anchors>
                                                                                        <ext:Anchor Horizontal="100%">
                                                                                            <ext:TextField ID="txrCustomEditForm" runat="server" FieldLabel="Custom Edit Form"
                                                                                                Width="500" />
                                                                                        </ext:Anchor>
                                                                                        <ext:Anchor Horizontal="100%">
                                                                                            <ext:Checkbox ID="ChkDisableToolbar" runat="server" FieldLabel="Disable ToolBar"
                                                                                                Width="500" />
                                                                                        </ext:Anchor>
                                                                                        <ext:Anchor Horizontal="100%">
                                                                                            <ext:ComboBox ID="cmbActivityType" runat="server" FieldLabel="Select ActivityType"
                                                                                                Width="500" />
                                                                                        </ext:Anchor>
                                                                                        <ext:Anchor Horizontal="100%">
                                                                                            <ext:ComboBox ID="CmbFormLabel" AllowBlank="false" FieldLabel="Form Multiple Label"
                                                                                                Editable="false" runat="server" Width="500">
                                                                                                <Items>
                                                                                                </Items>
                                                                                            </ext:ComboBox>
                                                                                        </ext:Anchor>
                                                                                    </Anchors>
                                                                                </ext:FormLayout>
                                                                            </Body>
                                                                        </ext:Panel>
                                                                        <ext:Panel ID="Panel5" runat="server">
                                                                            <Body>
                                                                                <ext:FormLayout ID="FormLayout6" runat="server" LabelWidth="150">
                                                                                    <Anchors>
                                                                                        <ext:Anchor Horizontal="100%">
                                                                                            <ext:NumberField ID="nmbReleatedListHeigth" runat="server" FieldLabel="Releated List Height"
                                                                                                Width="50" />
                                                                                        </ext:Anchor>
                                                                                    </Anchors>
                                                                                </ext:FormLayout>
                                                                            </Body>
                                                                        </ext:Panel>
                                                                    </Body>
                                                                </ext:Panel>
                                                                <ext:FormPanel runat="server" ID="fpnl1" Frame="false" Border="false" Title="Releated View"
                                                                    Width="800">
                                                                    <Body>
                                                                        <ext:ColumnLayout ID="ColumnLayout4" runat="server">
                                                                            <ext:LayoutColumn ColumnWidth=".5">
                                                                                <ext:Panel ID="Panel3" runat="server" Frame="false" Border="false" LabelSeparator="">
                                                                                    <Body>
                                                                                        <ext:FormLayout ID="FormLayout5" runat="server" LabelSeparator="" LabelWidth="80">
                                                                                            <ext:Anchor Horizontal="95%">
                                                                                                <ext:TextField runat="server" FieldLabel="Label" ID="ReleatedListLabel">
                                                                                                </ext:TextField>
                                                                                            </ext:Anchor>
                                                                                            <ext:Anchor Horizontal="95%">
                                                                                                <ext:Hidden runat="server" FieldLabel="ReleatedListId" ID="ReleatedListId">
                                                                                                </ext:Hidden>
                                                                                            </ext:Anchor>
                                                                                            <ext:Anchor Horizontal="95%">
                                                                                                <ext:TextField runat="server" FieldLabel="Name" ID="ReleatedListName" MaskRe="/[A-Za-z0-9_]/">
                                                                                                </ext:TextField>
                                                                                            </ext:Anchor>
                                                                                            <ext:Anchor Horizontal="95%">
                                                                                                <ext:ComboBox runat="server" ID="ReleatedViewQuery" ValueField="ViewQueryId" DisplayField="Name"
                                                                                                    StoreID="StoreReleatedList" FieldLabel="Releated View">
                                                                                                    <Listeners>
                                                                                                        <Change Handler="CmbSort.store.reload()" />
                                                                                                    </Listeners>
                                                                                                </ext:ComboBox>
                                                                                            </ext:Anchor>
                                                                                            <ext:Anchor Horizontal="95%">
                                                                                                <ext:Checkbox runat="server" ID="ChkIsEntity" Checked="true" FieldLabel="Is Entity">
                                                                                                    <Listeners>
                                                                                                        <Check Handler="
                                                                                
                                                                                #{ReleatedViewQuery}.setDisabled(!this.getValue());
                                                                                #{txtUrl}.setDisabled(this.getValue());
                                                                                
                                                                                if(this.getValue())
                                                                                {
                                                                                    #{txtUrl}.setValue(null);
                                                                                }else{
                                                                                    #{ReleatedViewQuery}.setValue(null);
                                                                                };
                                                                                
                                                                                " />
                                                                                                    </Listeners>
                                                                                                </ext:Checkbox>
                                                                                            </ext:Anchor>
                                                                                        </ext:FormLayout>
                                                                                    </Body>
                                                                                </ext:Panel>
                                                                            </ext:LayoutColumn>
                                                                            <ext:LayoutColumn ColumnWidth=".5">
                                                                                <ext:Panel ID="Panel8" runat="server" Frame="false" Border="false">
                                                                                    <Body>
                                                                                        <ext:FormLayout ID="FormLayout11" runat="server" LabelSeparator="" LabelWidth="80">
                                                                                            <ext:Anchor Horizontal="95%">
                                                                                                <ext:ComboBox ID="CmbReleatedViewLabel" AllowBlank="false" FieldLabel="Label Message"
                                                                                                    Editable="false" runat="server">
                                                                                                    <Items>
                                                                                                    </Items>
                                                                                                </ext:ComboBox>
                                                                                            </ext:Anchor>
                                                                                            <ext:Anchor Horizontal="95%">
                                                                                                <ext:ComboBox runat="server" ID="CmbSort" FieldLabel="Save Sort" ValueField="AttributeId"
                                                                                                    DisplayField="Label" StoreID="StoreCmbSort">
                                                                                                </ext:ComboBox>
                                                                                            </ext:Anchor>
                                                                                            <ext:Anchor Horizontal="95%">
                                                                                                <ext:TextField runat="server" FieldLabel="Url" ID="txtUrl" Disabled="true">
                                                                                                </ext:TextField>
                                                                                            </ext:Anchor>
                                                                                        </ext:FormLayout>
                                                                                    </Body>
                                                                                </ext:Panel>
                                                                            </ext:LayoutColumn>
                                                                        </ext:ColumnLayout>
                                                                    </Body>
                                                                    <TopBar>
                                                                        <ext:Toolbar ID="Toolbar3" runat="server">
                                                                            <Items>
                                                                                <ext:Button ID="Button15" runat="server" Text="New" Icon="New">
                                                                                    <Listeners>
                                                                                        <Click Handler="GridReleatedList_New();" />
                                                                                    </Listeners>
                                                                                </ext:Button>
                                                                                <ext:Button ID="Button6" runat="server" Text="Add" Icon="Add">
                                                                                    <Listeners>
                                                                                        <Click Handler="GridReleatedList_AddRecord(#{GridReleatedList})" />
                                                                                    </Listeners>
                                                                                </ext:Button>
                                                                                <ext:Button ID="Button7" runat="server" Text="Delete" Icon="Delete">
                                                                                    <Listeners>
                                                                                        <Click Handler="#{GridReleatedList}.deleteSelected();" />
                                                                                    </Listeners>
                                                                                </ext:Button>
                                                                            </Items>
                                                                        </ext:Toolbar>
                                                                    </TopBar>
                                                                </ext:FormPanel>
                                                                <ext:GridPanel runat="server" ID="GridReleatedList" Height="170" Width="800" StoreID="StoreGridReleatedList"
                                                                    AutoScroll="true">
                                                                    <TopBar>
                                                                    </TopBar>
                                                                    <ColumnModel>
                                                                        <Columns>
                                                                            <ext:Column Width="0" Hidden="true" Sortable="false" MenuDisabled="true" DataIndex="ReleatedListId">
                                                                            </ext:Column>
                                                                            <ext:Column Width="0" Hidden="true" Sortable="false" MenuDisabled="true" DataIndex="EntityRelationShipId">
                                                                            </ext:Column>
                                                                            <ext:Column Width="0" Hidden="true" Sortable="false" MenuDisabled="true" DataIndex="ViewQueryId">
                                                                            </ext:Column>
                                                                            <ext:Column Width="0" Hidden="true" Sortable="false" MenuDisabled="true" DataIndex="SortAttributeId">
                                                                            </ext:Column>
                                                                            <ext:Column Width="0" Hidden="true" Sortable="false" MenuDisabled="true" DataIndex="FilterListXml">
                                                                            </ext:Column>
                                                                            <ext:Column Width="0" Hidden="true" Sortable="false" MenuDisabled="true" DataIndex="LabelMessageId">
                                                                            </ext:Column>
                                                                            <ext:Column Header="Name" Width="100" Sortable="false" MenuDisabled="true" DataIndex="Name" />
                                                                            <ext:Column Header="Panel Label" Width="100" Sortable="false" MenuDisabled="true"
                                                                                DataIndex="Label" />
                                                                            <ext:Column Header="List Name" Width="100" Sortable="false" MenuDisabled="true" DataIndex="ViewQueryIdName" />
                                                                            <ext:Column Header="Sort Attribute Name" Width="100" Sortable="false" MenuDisabled="true"
                                                                                DataIndex="SortAttributeName" />
                                                                            <ext:CheckColumn Header="Entity" Width="100" Sortable="false" MenuDisabled="true"
                                                                                DataIndex="IsEntity" />
                                                                            <ext:Column Header="Url" Width="250" Sortable="false" MenuDisabled="true" DataIndex="Url" />
                                                                            <ext:Column Header="Label Message " Width="250" Sortable="false" MenuDisabled="true"
                                                                                DataIndex="LabelMessageIdName" />
                                                                            <ext:CommandColumn Width="60">
                                                                                <Commands>
                                                                                    <ext:GridCommand Icon="MapLink" CommandName="Map">
                                                                                    </ext:GridCommand>
                                                                                </Commands>
                                                                            </ext:CommandColumn>
                                                                        </Columns>
                                                                        <Listeners>
                                                                        </Listeners>
                                                                    </ColumnModel>
                                                                    <SelectionModel>
                                                                        <ext:RowSelectionModel ID="GridReleatedListSelmodel" runat="server">
                                                                            <Listeners>
                                                                                <RowSelect Handler="UpdateGridReleatedList(GridReleatedListSelmodel.selections.items[0].data);" />
                                                                            </Listeners>
                                                                        </ext:RowSelectionModel>
                                                                    </SelectionModel>
                                                                    <Listeners>
                                                                        <Command Handler="ShowMapList(command, record.data);" />
                                                                    </Listeners>
                                                                    <Plugins>
                                                                        <ext:GenericPlugin ID="GenericPlugin1" runat="server" InstanceOf="Ext.ux.dd.GridDragDropRowOrder">
                                                                            <CustomConfig>
                                                                                <ext:ConfigItem Name="scrollable" Value="true">
                                                                                </ext:ConfigItem>
                                                                            </CustomConfig>
                                                                        </ext:GenericPlugin>
                                                                    </Plugins>
                                                                </ext:GridPanel>
                                                            </Body>
                                                        </ext:Tab>
                                                        <ext:Tab Title="Scripts">
                                                            <Body>
                                                                <ext:FormPanel ID="FormPanel4" runat="server" Width="600" Frame="true">
                                                                    <Body>
                                                                        <ext:ColumnLayout ID="ColumnLayout2" runat="server">
                                                                            <ext:LayoutColumn ColumnWidth=".5">
                                                                                <ext:Panel ID="Panel7" runat="server">
                                                                                    <Body>
                                                                                        <ext:FormLayout ID="FormLayout9" runat="server" LabelAlign="Left">
                                                                                            <Anchors>
                                                                                                <ext:Anchor Horizontal="33%">
                                                                                                    <ext:Checkbox ID="chkUseIframeScript" runat="server" FieldLabel="Iframe Script" />
                                                                                                </ext:Anchor>
                                                                                                <ext:Anchor Horizontal="100%">
                                                                                                    <ext:TextField ID="txtIframeScriptUrl" runat="server" FieldLabel="Script" />
                                                                                                </ext:Anchor>
                                                                                                <ext:Anchor Horizontal="100%">
                                                                                                    <ext:ComboBox runat="server" ID="OnloadClientWorkflow" FieldLabel="Onload Client Workflow">
                                                                                                    </ext:ComboBox>
                                                                                                </ext:Anchor>
                                                                                                <ext:Anchor Horizontal="33%">
                                                                                                    <ext:Checkbox ID="chkOnLoadScript" runat="server" FieldLabel="On Load" />
                                                                                                </ext:Anchor>
                                                                                                <ext:Anchor Horizontal="100%">
                                                                                                    <ext:TextArea ID="txtOnLoadScript" runat="server" FieldLabel="Script" />
                                                                                                </ext:Anchor>
                                                                                                <ext:Anchor Horizontal="100%">
                                                                                                    <ext:ComboBox runat="server" ID="BeforeSaveClientWorkflow" FieldLabel="Before Save Client Workflow">
                                                                                                    </ext:ComboBox>
                                                                                                </ext:Anchor>
                                                                                                <ext:Anchor Horizontal="33%">
                                                                                                    <ext:Checkbox ID="chkBeforeSave" runat="server" FieldLabel="Before Save" />
                                                                                                </ext:Anchor>
                                                                                                <ext:Anchor Horizontal="100%">
                                                                                                    <ext:TextArea ID="txtBeforeSaveScript" runat="server" FieldLabel="Script" />
                                                                                                </ext:Anchor>
                                                                                                <ext:Anchor Horizontal="100%">
                                                                                                    <ext:ComboBox runat="server" ID="AfterSaveClientWorkflow" FieldLabel="After Save Client Workflow">
                                                                                                    </ext:ComboBox>
                                                                                                </ext:Anchor>
                                                                                                <ext:Anchor Horizontal="33%">
                                                                                                    <ext:Checkbox ID="chkAfterSave" runat="server" FieldLabel="After Save" />
                                                                                                </ext:Anchor>
                                                                                                <ext:Anchor Horizontal="100%">
                                                                                                    <ext:TextArea ID="txtAfterSaveScript" runat="server" FieldLabel="Script" />
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
                                                        <ext:Tab Title="Administrations">
                                                            <Body>
                                                                <ext:FormPanel ID="FormPanelAdministrations" runat="server" Width="600" Frame="true">
                                                                    <BottomBar>
                                                                        <ext:Toolbar runat="server">
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
                                                                                <ext:Panel ID="Panel6" runat="server">
                                                                                    <Body>
                                                                                        <ext:FormLayout ID="FormLayout10" runat="server" LabelAlign="Left">
                                                                                            <Anchors>
                                                                                                <ext:Anchor Horizontal="100%">
                                                                                                    <ext:ComboBox runat="server" ID="cmbOwningUser" DisplayField="FullName" ValueField="SystemUserId"
                                                                                                        StoreID="StoreUser" FieldLabel="OwningUser" Width="200" Mode="Remote">
                                                                                                    </ext:ComboBox>
                                                                                                </ext:Anchor>
                                                                                                <ext:Anchor Horizontal="100%">
                                                                                                    <ext:ComboBox runat="server" ID="cmbOwningBusinessUnit" DisplayField="Name" ValueField="BusinessUnitId"
                                                                                                         StoreID="StoreBu" FieldLabel="OwningBusinessUnit" Width="200"
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
                                            </Center>
                                        </ext:BorderLayout>
                                    </Body>
                                </ext:Panel>
                            </ext:FitLayout>
                        </Body>
                    </ext:Panel>
                </ext:LayoutRow>
            </ext:RowLayout>
            <ext:Window ID="WindowSelectSectionStyle" runat="server" Title="Section Style" Height="280px"
                Width="500px" Modal="True" Icon="ApplicationEdit" ShowOnLoad="false">
                <Body>
                    <ext:FormPanel ID="FormPanelSectionStyle" runat="server" Width="490" Frame="true"
                        ButtonAlign="Center">
                        <Body>
                            <ext:FormLayout ID="FormLayoutSectionStyle" runat="server" LabelWidth="200">
                                <Anchors>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:TextField ID="txtSectionId" runat="server" FieldLabel="Section Id Name" AllowBlank="false" />
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:TextField ID="txtSectionName" runat="server" FieldLabel="Section Name" AllowBlank="false" />
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:ComboBox ID="CmbSectionLabel" FieldLabel="Section Label" Editable="false" runat="server">
                                            <Items>
                                            </Items>
                                        </ext:ComboBox>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:Checkbox ID="chkShowHeader" runat="server" FieldLabel="Show Header" />
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:Checkbox ID="chkUseBorder" runat="server" FieldLabel="Use Border" />
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:ComboBox ID="CmbSectionStyle" AllowBlank="false" FieldLabel="Section Style"
                                            Editable="false" runat="server">
                                            <Items>
                                                <ext:ListItem Value="1" Text="1:0" />
                                                <ext:ListItem Value=".50:.50" Text="1:1" />
                                                <ext:ListItem Value=".25:.25:.50" Text="2:1" />
                                                <ext:ListItem Value=".50:.25:.25" Text="1:2" />
                                                <ext:ListItem Value=".25:.25:.25:.25" Text="2:2" />
                                                <ext:ListItem Value=".33:.33:.33" Text="3:0" />
                                                <ext:ListItem Value=".12:.12:.12:.12:.12:.12:.12:.16" Text="4:4" />
                                            </Items>
                                        </ext:ComboBox>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:NumberField ID="nmbLabelWidth" runat="server" FieldLabel="Section Label Width(%)"
                                            MaxValue="98" MinValue="0" />
                                    </ext:Anchor>
                                </Anchors>
                            </ext:FormLayout>
                        </Body>
                        <Buttons>
                            <ext:Button ID="btnUpdate" runat="server" Text="Update">
                                <Listeners>
                                    <Click Handler="UpdateSection()" />
                                </Listeners>
                            </ext:Button>
                            <ext:Button ID="btnOk" runat="server" Text="Ok">
                                <Listeners>
                                    <Click Handler="AddEditSection(#{SectionViewer})" />
                                </Listeners>
                            </ext:Button>
                            <ext:Button ID="btnCancel" runat="server" Text="Cancel">
                                <Listeners>
                                    <Click Handler="#{WindowSelectSectionStyle}.hide();" />
                                </Listeners>
                            </ext:Button>
                        </Buttons>
                    </ext:FormPanel>
                </Body>
            </ext:Window>
            <ext:Window ID="WindowLabel" runat="server" Title="Section Label" Height="350" Width="510px"
                Modal="True" Icon="ApplicationEdit" ShowOnLoad="false">
                <Body>
                    <ext:FormPanel ID="FormPanel6" runat="server" Width="500" Frame="true" Height="310">
                        <Body>
                            <ext:FormLayout ID="FormLayout12" runat="server">
                                <Anchors>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:TextField ID="txtLabelName" FieldLabel="Label Name" runat="server" MaskRe="/[A-Za-z0-9_]/">
                                        </ext:TextField>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:TextField ID="txtLabelCaption" FieldLabel="Caption" runat="server">
                                        </ext:TextField>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:ComboBox ID="cmbLabelLabel" FieldLabel="Multiple Label" Editable="false" runat="server">
                                        </ext:ComboBox>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:Checkbox ID="labelHidden" FieldLabel="Hide " runat="server">
                                        </ext:Checkbox>
                                    </ext:Anchor>
                                    <ext:Anchor>
                                        <ext:ComboBox runat="server" ID="cmbLabelImage" FieldLabel="Image">
                                        </ext:ComboBox>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:Checkbox ID="lblUseScript" FieldLabel="Use Script" runat="server">
                                        </ext:Checkbox>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:TextArea ID="lblScript" runat="server" FieldLabel="Script" Height="100">
                                        </ext:TextArea>
                                    </ext:Anchor>
                                </Anchors>
                            </ext:FormLayout>
                        </Body>
                        <Buttons>
                            <ext:Button ID="Label13" runat="server" Text="Ok">
                                <Listeners>
                                    <Click Handler="AddLabelItem(#{SectionViewer})" />
                                </Listeners>
                            </ext:Button>
                            <ext:Button ID="Label14" runat="server" Text="Cancel">
                                <Listeners>
                                    <Click Handler="#{WindowLabel}.hide();" />
                                </Listeners>
                            </ext:Button>
                        </Buttons>
                    </ext:FormPanel>
                </Body>
            </ext:Window>
            <ext:Window ID="WindowButton" runat="server" Title="Section Button" Height="475"
                Width="510px" Modal="True" Icon="ApplicationEdit" ShowOnLoad="false">
                <Body>
                    <ext:FormPanel ID="FormPanel5" runat="server" Width="500" Frame="true" ButtonAlign="Center"
                        Height="450">
                        <Body>
                            <ext:FormLayout ID="FormLayout8" runat="server">
                                <Anchors>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:TextField ID="txtButtonName" FieldLabel="Button Name" runat="server" MaskRe="/[A-Za-z0-9_]/">
                                        </ext:TextField>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:TextField ID="txtButtonCaption" FieldLabel="Caption" runat="server">
                                        </ext:TextField>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:ComboBox ID="cmbButtonLabel" FieldLabel="Multiple Label" Editable="false" runat="server">
                                        </ext:ComboBox>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:Checkbox ID="btnHidden" FieldLabel="Hide " runat="server">
                                        </ext:Checkbox>
                                    </ext:Anchor>
                                    <ext:Anchor>
                                        <ext:ComboBox runat="server" ID="cmbButtonImage" FieldLabel="Image">
                                        </ext:ComboBox>
                                    </ext:Anchor>
                                    <ext:Anchor>
                                        <ext:ComboBox runat="server" ID="cmbButtonUrl" FieldLabel="Dinamik Url">
                                        </ext:ComboBox>
                                    </ext:Anchor>
                                    <ext:Anchor>
                                        <ext:ComboBox runat="server" ID="cmbButtonWebService" FieldLabel="Dinamik WebService">
                                        </ext:ComboBox>
                                    </ext:Anchor>
                                    <ext:Anchor>
                                        <ext:ComboBox runat="server" ID="cmbButtonOnDemandWorkflow" FieldLabel="OnDemand Workflow">
                                        </ext:ComboBox>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:TextArea runat="server" ID="beforeAjax" FieldLabel="Before Ajax Event" Height="100">
                                        </ext:TextArea>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:Checkbox ID="btnUseScript" FieldLabel="Use Script" runat="server">
                                        </ext:Checkbox>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:TextArea ID="btnScript" runat="server" FieldLabel="Script" Height="100">
                                        </ext:TextArea>
                                    </ext:Anchor>
                                </Anchors>
                            </ext:FormLayout>
                        </Body>
                        <Buttons>
                            <ext:Button ID="Button13" runat="server" Text="Ok">
                                <Listeners>
                                    <Click Handler="AddButtonItem(#{SectionViewer})" />
                                </Listeners>
                            </ext:Button>
                            <ext:Button ID="Button14" runat="server" Text="Cancel">
                                <Listeners>
                                    <Click Handler="#{WindowButton}.hide();" />
                                </Listeners>
                            </ext:Button>
                        </Buttons>
                    </ext:FormPanel>
                </Body>
            </ext:Window>
            <ext:Window ID="WindowIframe" runat="server" Title="Section Iframe" Height="250px"
                Width="370px" Modal="True" Icon="ApplicationEdit" ShowOnLoad="false">
                <Body>
                    <ext:FormPanel ID="FormPanel3" runat="server" Width="350" Frame="true" ButtonAlign="Center">
                        <Body>
                            <ext:FormLayout ID="FormLayout7" runat="server">
                                <Anchors>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:TextField ID="txtIframeName" FieldLabel="Iframe Name" runat="server" MaskRe="/[A-Za-z0-9_]/">
                                        </ext:TextField>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:Checkbox ID="iframeHidden" FieldLabel="Hide " runat="server">
                                        </ext:Checkbox>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:TextField ID="txtIframeUrl" FieldLabel="Iframe Url" runat="server">
                                        </ext:TextField>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:NumberField ID="nmbIframeHeigth" MaxLength="3" FieldLabel="Iframe Heigth" runat="server">
                                        </ext:NumberField>
                                    </ext:Anchor>
                                    <ext:Anchor>
                                        <ext:ComboBox runat="server" ID="cmbDynamicUrl" FieldLabel="Dinamik Url">
                                        </ext:ComboBox>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:Checkbox ID="chkPassQuery" FieldLabel="Pass Query" runat="server">
                                        </ext:Checkbox>
                                    </ext:Anchor>
                                </Anchors>
                            </ext:FormLayout>
                        </Body>
                        <Buttons>
                            <ext:Button ID="BtnAddIframeItem" runat="server" Text="Ok">
                                <Listeners>
                                    <Click Handler="AddIframeItem(#{SectionViewer})" />
                                </Listeners>
                            </ext:Button>
                            <ext:Button ID="Button9" runat="server" Text="Cancel">
                                <Listeners>
                                    <Click Handler="#{WindowIframe}.hide();" />
                                </Listeners>
                            </ext:Button>
                        </Buttons>
                    </ext:FormPanel>
                </Body>
            </ext:Window>
            <ext:Window ID="WindowAttributeList" runat="server" Title="Section Attributes" Height="310px"
                Width="370px" Modal="True" Icon="ApplicationEdit" ShowOnLoad="false">
                <Body>
                    <ext:FormPanel ID="FormPanel1" runat="server" Width="350" Frame="true" ButtonAlign="Center">
                        <Body>
                            <ext:FormLayout ID="FormLayout2" runat="server">
                                <%-- <Anchors>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:ComboBox ID="CmbFieldsAttribute" StoreID="StoreViewAttribute" ValueField="AttributeId"
                                            DisplayField="Label" runat="server" FieldLabel="Attribute Name" AllowBlank="false"
                                            Mode="Local">
                                        </ext:ComboBox>
                                    </ext:Anchor>
                                </Anchors>--%>
                                <Anchors>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:GridPanel runat="server" Height="230" Width="350" ID="GrdFieldsAttribute" EnableDragDrop="true"
                                            AutoExpandColumn="Attribute" StoreID="StoreViewAttribute">
                                            <ColumnModel ID="ColumnModel1" runat="server">
                                                <Columns>
                                                    <ext:Column ColumnID="Attribute" Header="Attribute Name" DataIndex="Label" MenuDisabled="true" />
                                                </Columns>
                                            </ColumnModel>
                                            <SelectionModel>
                                                <ext:CheckboxSelectionModel ID="CheckboxSelectionModel1" runat="server" />
                                            </SelectionModel>
                                        </ext:GridPanel>
                                    </ext:Anchor>
                                </Anchors>
                            </ext:FormLayout>
                        </Body>
                        <Buttons>
                            <ext:Button ID="Button2" runat="server" Text="Ok">
                                <Listeners>
                                    <Click Handler="AddAttributeItem(#{SectionViewer})" />
                                </Listeners>
                            </ext:Button>
                            <ext:Button ID="Button3" runat="server" Text="Cancel">
                                <Listeners>
                                    <Click Handler="#{WindowAttributeList}.hide();" />
                                </Listeners>
                            </ext:Button>
                        </Buttons>
                    </ext:FormPanel>
                </Body>
            </ext:Window>
            <ext:Window ID="WindowAttributeProperty" runat="server" Title="Section Attributes"
                Height="470px" Width="620px" Modal="True" Icon="ApplicationEdit" ShowOnLoad="false">
                <Body>
                    <ext:FitLayout runat="server">
                        <ext:TabPanel runat="server">
                            <Tabs>
                                <ext:Tab runat="server" ID="ScriptPanel" Title="Script">
                                    <Body>
                                        <ext:FormPanel ID="FormPanel2" runat="server" Width="600" Frame="true">
                                            <Body>
                                                <ext:FormLayout ID="FormLayout3" runat="server" LabelWidth="200">
                                                    <Anchors>
                                                        <ext:Anchor Horizontal="100%">
                                                            <ext:Checkbox ID="chkReadOnly" FieldLabel="Read Only " runat="server">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                        <ext:Anchor Horizontal="100%">
                                                            <ext:Checkbox ID="chkDisable" FieldLabel="Disabled " runat="server">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                        <ext:Anchor Horizontal="100%">
                                                            <ext:Checkbox ID="chkHide" FieldLabel="Hide " runat="server">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                        <ext:Anchor Horizontal="100%">
                                                            <ext:Checkbox ID="chkLabelField" FieldLabel="Label Field" runat="server" >
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                        <ext:Anchor Horizontal="100%">
                                                            <ext:Checkbox ID="chkProgrammaticalField" FieldLabel="Programmatical Field (for User Control)" runat="server">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:ComboBox runat="server" ID="rLevel" FieldLabel="Level" Editable="false">
                                                                <Items>
                                                                    <ext:ListItem Value="0" Text="No Constraint" />
                                                                    <ext:ListItem Value="1" Text="Business Recommend" />
                                                                    <ext:ListItem Value="2" Text="Business Required" />
                                                                </Items>
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:ComboBox runat="server" ID="cmbClientWorkflow" FieldLabel="OnDemand Workflow">
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor Horizontal="100%">
                                                            <ext:TextArea runat="server" ID="cmbBeforeAjax" FieldLabel="Before Ajax Event" Height="120">
                                                            </ext:TextArea>
                                                        </ext:Anchor>
                                                        <ext:Anchor Horizontal="100%">
                                                            <ext:Checkbox ID="chkUseScript" FieldLabel="Use Script" runat="server">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                        <ext:Anchor Horizontal="100%">
                                                            <ext:TextArea ID="ScriptArea" runat="server" FieldLabel="Script" Height="120">
                                                            </ext:TextArea>
                                                        </ext:Anchor>
                                                    </Anchors>
                                                </ext:FormLayout>
                                            </Body>
                                        </ext:FormPanel>
                                    </Body>
                                </ext:Tab>
                                <ext:Tab runat="server" ID="Property" Title="Property">
                                    <Body>
                                        <ext:FormPanel runat="server" Width="600" Frame="true">
                                            <Body>
                                                <ext:FormLayout ID="FormLayout4" runat="server">
                                                    <Anchors>
                                                        <ext:Anchor Horizontal="100%">
                                                            <ext:ComboBox runat="server" ID="LookupViewList" FieldLabel="LookupView List" ValueField="ViewQueryId"
                                                                DisplayField="Name" StoreID="StoreViewerList" TypeAhead="true" Mode="Local" TriggerAction="All">
                                                                <Listeners>
                                                                    <Change Handler="StoreToAttribute.reload();" />
                                                                </Listeners>
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                        <ext:Anchor Horizontal="100%">
                                                            <ext:Checkbox ID="chkOpenLookup" FieldLabel="Open Lookup" runat="server">
                                                            </ext:Checkbox>
                                                        </ext:Anchor>
                                                        <ext:Anchor Horizontal="100%">
                                                            <ext:NumberField ID="NumSearchCnt" FieldLabel="Search Count" runat="server">
                                                            </ext:NumberField>
                                                        </ext:Anchor>
                                                    </Anchors>
                                                </ext:FormLayout>
                                            </Body>
                                        </ext:FormPanel>
                                        <ext:GridPanel runat="server" ID="GridParentChild" Height="170" StoreID="StoreParentChildGrid"
                                            Title="Parent Child Attribute">
                                            <TopBar>
                                                <ext:Toolbar runat="server">
                                                    <Items>
                                                        <ext:ComboBox runat="server" ID="FromAttribute" StoreID="StoreFromAttribute" DisplayField="Label"
                                                            ValueField="AttributeId">
                                                        </ext:ComboBox>
                                                        <ext:ComboBox runat="server" ID="ToAttribute" StoreID="StoreToAttribute" DisplayField="Label"
                                                            ValueField="AttributeId">
                                                        </ext:ComboBox>
                                                        <ext:Button runat="server" Text="Add" Icon="Add">
                                                            <Listeners>
                                                                <Click Handler="GridParentChild_AddRecord(#{GridParentChild})" />
                                                            </Listeners>
                                                        </ext:Button>
                                                        <ext:Button runat="server" Text="Delete" Icon="Delete">
                                                            <Listeners>
                                                                <Click Handler="#{GridParentChild}.deleteSelected();" />
                                                            </Listeners>
                                                        </ext:Button>
                                                    </Items>
                                                </ext:Toolbar>
                                            </TopBar>
                                            <ColumnModel>
                                                <Columns>
                                                    <ext:Column Width="0" Hidden="true" Sortable="false" MenuDisabled="true" DataIndex="FromAttributeId">
                                                    </ext:Column>
                                                    <ext:Column Width="0" Hidden="true" Sortable="false" MenuDisabled="true" DataIndex="ToAttributeId">
                                                    </ext:Column>
                                                    <ext:Column Header="This Entity" Width="250" Sortable="false" MenuDisabled="true"
                                                        DataIndex="FromAttributeIdName">
                                                    </ext:Column>
                                                    <ext:Column Header="Target Entity" Width="250" Sortable="false" MenuDisabled="true"
                                                        DataIndex="ToAttributeIdName">
                                                    </ext:Column>
                                                </Columns>
                                            </ColumnModel>
                                            <SelectionModel>
                                                <ext:RowSelectionModel ID="RowSelectionModel1" runat="server" />
                                            </SelectionModel>
                                        </ext:GridPanel>
                                    </Body>
                                </ext:Tab>
                            </Tabs>
                            <BottomBar>
                                <ext:Toolbar runat="server">
                                    <Items>
                                        <ext:Button ID="Button4" runat="server" Text="Ok">
                                            <Listeners>
                                                <Click Handler="AddAttributeProperty(#{WindowAttributeProperty})" />
                                            </Listeners>
                                        </ext:Button>
                                        <ext:Button ID="Button5" runat="server" Text="Cancel">
                                            <Listeners>
                                                <Click Handler="#{WindowAttributeProperty}.hide();" />
                                            </Listeners>
                                        </ext:Button>
                                    </Items>
                                </ext:Toolbar>
                            </BottomBar>
                        </ext:TabPanel>
                    </ext:FitLayout>
                </Body>
            </ext:Window>
            <ext:Window ID="WindowMapPath" runat="server" Title="Map Path" Height="250px" Width="550px"
                Modal="True" Icon="ApplicationEdit" ShowOnLoad="false">
                <Body>
                    <ext:FitLayout ID="FitLayout2" runat="server">
                        <ext:Panel runat="server">
                            <Body>
                                <ext:GridPanel runat="server" ID="MapPathGrid" Height="170" StoreID="StoreMapPathGrid">
                                    <TopBar>
                                        <ext:Toolbar ID="Toolbar4" runat="server">
                                            <Items>
                                                <ext:ComboBox runat="server" ID="MapPathFromAttribute" StoreID="StoreFromAttribute"
                                                    DisplayField="Label" ValueField="AttributeId">
                                                </ext:ComboBox>
                                                <ext:ComboBox runat="server" ID="MapPathToAttribute" StoreID="StoreMappathToAttribute"
                                                    DisplayField="Label" ValueField="AttributeId">
                                                </ext:ComboBox>
                                                <ext:Button ID="Button8" runat="server" Text="Add" Icon="Add">
                                                    <Listeners>
                                                        <Click Handler="MapPathGrid_AddRecord(#{MapPathGrid})" />
                                                    </Listeners>
                                                </ext:Button>
                                                <ext:Button ID="Button10" runat="server" Text="Delete" Icon="Delete">
                                                    <Listeners>
                                                        <Click Handler="#{MapPathGrid}.deleteSelected();" />
                                                    </Listeners>
                                                </ext:Button>
                                            </Items>
                                        </ext:Toolbar>
                                    </TopBar>
                                    <ColumnModel>
                                        <Columns>
                                            <ext:Column Width="0" Hidden="true" Sortable="false" MenuDisabled="true" DataIndex="FromAttributeId">
                                            </ext:Column>
                                            <ext:Column Width="0" Hidden="true" Sortable="false" MenuDisabled="true" DataIndex="ToAttributeId">
                                            </ext:Column>
                                            <ext:Column Header="This Entity" Width="250" Sortable="false" MenuDisabled="true"
                                                DataIndex="FromAttributeIdName">
                                            </ext:Column>
                                            <ext:Column Header="Target Entity" Width="250" Sortable="false" MenuDisabled="true"
                                                DataIndex="ToAttributeIdName">
                                            </ext:Column>
                                        </Columns>
                                    </ColumnModel>
                                    <SelectionModel>
                                        <ext:RowSelectionModel ID="RowSelectionModel3" runat="server" />
                                    </SelectionModel>
                                </ext:GridPanel>
                            </Body>
                            <BottomBar>
                                <ext:Toolbar ID="Toolbar5" runat="server">
                                    <Items>
                                        <ext:Button ID="Button11" runat="server" Text="Ok">
                                            <Listeners>
                                                <Click Handler="AddMapPathProperty(#{GridReleatedList},#{MapPathGrid},#{WindowMapPath})" />
                                            </Listeners>
                                        </ext:Button>
                                        <ext:Button ID="Button12" runat="server" Text="Cancel">
                                            <Listeners>
                                                <Click Handler="#{WindowMapPath}.hide();" />
                                            </Listeners>
                                        </ext:Button>
                                    </Items>
                                </ext:Toolbar>
                            </BottomBar>
                        </ext:Panel>
                    </ext:FitLayout>
                </Body>
            </ext:Window>
            <ext:Window ID="WindowWebControl" runat="server" Title="Section WebControl" Height="250px"
                Width="370px" Modal="True" Icon="ApplicationEdit" ShowOnLoad="false">
                <Body>
                    <ext:FormPanel ID="FormPanel7" runat="server" Width="350" Frame="true" ButtonAlign="Center">
                        <Body>
                            <ext:FormLayout ID="FormLayout13" runat="server">
                                <Anchors>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:TextField ID="txtWebControlName" FieldLabel="WebControl Name" runat="server" MaskRe="/[A-Za-z0-9_]/">
                                        </ext:TextField>
                                    </ext:Anchor>
                                    <ext:Anchor Horizontal="100%">
                                        <ext:TextField ID="txtWebControlUrl" FieldLabel="WebControl Url" runat="server">
                                        </ext:TextField>
                                    </ext:Anchor>
                                </Anchors>
                            </ext:FormLayout>
                        </Body>
                        <Buttons>
                            <ext:Button ID="BtnAddWebControlItem" runat="server" Text="Ok">
                                <Listeners>
                                    <Click Handler="AddWebControlItem(#{SectionViewer})" />
                                </Listeners>
                            </ext:Button>
                            <ext:Button ID="Button18" runat="server" Text="Cancel">
                                <Listeners>
                                    <Click Handler="#{WindowWebControl}.hide();" />
                                </Listeners>
                            </ext:Button>
                        </Buttons>
                    </ext:FormPanel>
                </Body>
            </ext:Window>
        </Body>
    </ext:ViewPort>
    </form>
</body>
</html>
<script language="javascript" type="text/javascript">
    var FirstShowAttribute = true;
    function wonload() {

        if (FirstShowAttribute) {
            for (i = 0; i < StoreViewAttributeDeleted.data.items.length; i++) {
                var obj = StoreViewAttribute.getById(StoreViewAttributeDeleted.data.items[i].id)

                if (obj != undefined && obj != null) {
                    StoreViewAttribute.remove(obj);
                }
            }
            FirstShowAttribute = false
        }
    }
</script>
<script type="text/javascript">

    function addGridReleatedListRecord(grp, RLId, Name, Label, LabelMessageId, LabelMessageIdName, ERSId, SAId, SANAME, VQId, VQIdName, IsEntity, url) {
        /*Not Update islemi yapilmadi sonra ypilacak */
        var MyRecordType = Ext.data.Record.create(['id', 'ReleatedListId', 'EntityRelationShipId', 'SortAttributeId', 'SortAttributeName', 'Name', 'Label', 'LabelMessageId', 'LabelMessageIdName', 'ViewQueryId', 'ViewQueryIdName', 'IsEntity', 'Url', 'FilterListXml']);
        var itemGuid = guid();

        myrec = new MyRecordType
       ({ "id": RLId, "ReleatedListId": RLId, "EntityRelationShipId": ERSId,
           "SortAttributeId": SAId,
           "SortAttributeName": SANAME,
           "Name": Name,
           "Label": Label,
           "LabelMessageId": LabelMessageId,
           "LabelMessageIdName": LabelMessageIdName,
           "ViewQueryId": VQId, "ViewQueryIdName": VQIdName, "IsEntity": IsEntity, "Url": url, "FilterListXml": ""
       });

        for (var i = 0; i < grp.store.data.length; i++) {
            if (grp.store.data.items[i].data.ReleatedListId == RLId) {
                myrec.data.FilterListXml = grp.store.data.items[i].data.FilterListXml;
                grp.store.data.items[i].override(myrec);
                
                //                grp.store.data.items[i].data.EntityRelationShipId = myrec.EntityRelationShipId;
                //                grp.store.data.items[i].data.SortAttributeId = myrec.SortAttributeId;
                //                grp.store.data.items[i].data.SortAttributeName = myrec.SortAttributeName;
                //                grp.store.data.items[i].data.Name = myrec.Name;
                //                grp.store.data.items[i].data.Label = myrec.Label;
                //                grp.store.data.items[i].data.LabelMessageId = myrec.LabelMessageId;
                //                grp.store.data.items[i].data.ViewQueryId = myrec.ViewQueryId;
                //                grp.store.data.items[i].data.ViewQueryIdName = myrec.ViewQueryIdName;
                //                grp.store.data.items[i].data.IsEntity = myrec.IsEntity;
                //                grp.store.data.items[i].data.Url = myrec.Url;

                grp.store.commitChanges();
                return;
            }
        }
        grp.store.insert(grp.store.data.length, myrec);
        grp.store.commitChanges()


    }
    function GridReleatedList_New() {
        ReleatedListLabel.setValue(null);
        ReleatedListId.setValue(null)
        ReleatedListName.setValue(null);
        ReleatedViewQuery.setValue(null)
        ChkIsEntity.setValue(true);
        txtUrl.setValue(null);
        ReleatedViewQuery.setValue(null);
        CmbReleatedViewLabel.setValue(null);

    }
    function UpdateGridReleatedList(item) {
        
        ReleatedListLabel.setValue(item.Label)
        ReleatedListId.setValue(item.ReleatedListId)
        ReleatedListName.setValue(item.Name)
        ReleatedViewQuery.setValue(item.ViewQueryId)
        ChkIsEntity.setValue(item.IsEntity)
        CmbReleatedViewLabel.setValue(item.LabelMessageId)
        CmbSort.setValue(item.SortAttributeId)
        txtUrl.setValue(item.Url)
    }
    function GridReleatedList_AddRecord(grp) {

        var RLId = guid()
        if (ReleatedListId.getValue() != "")
            RLId = ReleatedListId.getValue();
        
        var Label = ReleatedListLabel.getValue();
        var Name = ReleatedListName.getValue();
        
        var IsEntity = ChkIsEntity.getValue();
        var LabelMessageId = CmbReleatedViewLabel.getValue();
        var LabelMessageIdName = CmbReleatedViewLabel.getText();
        var ERSId = "";
        var VQId = "";
        var VQIdName = "";
        var SAId = "";
        var SANAME = "";
        if (IsEntity) {

            ERSId = ReleatedViewQuery.store.getById(ReleatedViewQuery.value).data.EntityRelationShipId
            VQId = ReleatedViewQuery.store.getById(ReleatedViewQuery.value).data.ViewQueryId
            VQIdName = ReleatedViewQuery.store.getById(ReleatedViewQuery.value).data.Name
            if (CmbSort.value != "" && CmbSort.value != undefined) {
                SAId = CmbSort.store.getById(CmbSort.value).data.AttributeId;
                SANAME = CmbSort.store.getById(CmbSort.value).data.Label;
            }
        }
        var url = txtUrl.getValue();
        addGridReleatedListRecord(grp, RLId, Name, Label, LabelMessageId, LabelMessageIdName, ERSId, SAId, SANAME, VQId, VQIdName, IsEntity, url)
        GridReleatedList_New();

    }
    function addGridPanelRecord(grp, fid, fname, tid, tname) {

        var MyRecordType = Ext.data.Record.create(['id', 'FromAttributeId', 'FromAttributeIdName', 'ToAttributeId', 'ToAttributeIdName']);
        var itemGuid = guid();
        myrec = new MyRecordType
       ({ "id": itemGuid, "FromAttributeId": fid, "FromAttributeIdName": fname, "ToAttributeId": tid, "ToAttributeIdName": tname });
        grp.store.insert(grp.store.data.length, myrec);
        grp.store.commitChanges()


    }
    function GridParentChild_AddRecord(grp) {
        var fid = FromAttribute.getValue();
        var fname = FromAttribute.getText();
        var tid = ToAttribute.getValue();
        var tname = ToAttribute.getText();
        addGridPanelRecord(grp, fid, fname, tid, tname);
    }
    var _ActivePortlet = null;
    var tools = [{
        id: 'gear',
        handler: function (e, target, panel) {

            WindowAttributePropertyOpen(panel);
        }
    }, {
        id: 'close',
        handler: function (e, target, panel) {
            panel.ownerCt.remove(panel, true);
            removePortlet(panel, true);

        }
    }];


    function AddAttributeProperty(w) {
        _ActivePortlet.clientworkflow = cmbClientWorkflow.getValue();
        _ActivePortlet.onchangescript = ScriptArea.getValue();
        _ActivePortlet.onbeforeajaxscript = cmbBeforeAjax.getValue();
        _ActivePortlet.isusescript = chkUseScript.getValue();
        _ActivePortlet.lookupview = LookupViewList.getValue();
        _ActivePortlet.isreadonlyfield = chkReadOnly.getValue();
        _ActivePortlet.isdisabledfield = chkDisable.getValue();
        _ActivePortlet.islabelfield = chkLabelField.getValue();
        _ActivePortlet.isprogrammaticalfield = chkProgrammaticalField.getValue();
        _ActivePortlet.ishide = chkHide.getValue();

        _ActivePortlet.openlookup = chkOpenLookup.getValue();
        _ActivePortlet.lookupsearchcount = NumSearchCnt.getValue();
        _ActivePortlet.rlevel = rLevel.getValue();
        _ActivePortlet.filter = GenerateFeachXml(GridParentChild);

        GridParentChild.clear();
        GenerateXml();
        w.hide();
    }
    function GenerateFeachXml(gbp) {
        var strfxml = "<fxml>"
        for (i = 0; i < gbp.store.data.length; i++) {
            var data = gbp.store.data.items[i].data;
            var fattribute = "<filterattribute ";
            fattribute += " fromattributeid ='" + data.FromAttributeId + "'";
            fattribute += " fromattributeidname='" + data.FromAttributeIdName + "'";
            fattribute += " toattributeid='" + data.ToAttributeId + "'";
            fattribute += " toattributeidname='" + data.ToAttributeIdName + "'";
            fattribute += " />";
            strfxml += fattribute;
        }
        strfxml += "</fxml>"
        if (IsNull(strfxml))
            strfxml = "<fxml></fxml>";
        return strfxml;
    }
    //GridParentChild
    function loadFeachXml(xmlvalue, gp) {
        var XObject = ReadXml(xmlvalue);
        gp.clear();
        for (var i = 0; i < XObject.childNodes.length; i++) {
            for (j = 0; j < XObject.childNodes[i].childNodes.length; j++) {
                var Xnode = XObject.childNodes[i].childNodes[j];
                var fid = getNodeValue(Xnode, "fromattributeid")
                var fname = getNodeValue(Xnode, "fromattributeidname")
                var tid = getNodeValue(Xnode, "toattributeid")
                var tname = getNodeValue(Xnode, "toattributeidname")
                addGridPanelRecord(gp, fid, fname, tid, tname)
            }
        }

    }

    function StoreViewerListSetValue() {
        ScriptArea.setValue(_ActivePortlet.onchangescript);
        cmbBeforeAjax.setValue(_ActivePortlet.onbeforeajaxscript)
        chkUseScript.setValue(_ActivePortlet.isusescript);
        cmbClientWorkflow.setValue(_ActivePortlet.clientworkflow);
        LookupViewList.setValue(_ActivePortlet.lookupview);
        chkOpenLookup.setValue(_ActivePortlet.openlookup);
        NumSearchCnt.setValue(_ActivePortlet.lookupsearchcount);
        chkReadOnly.setValue(_ActivePortlet.isreadonlyfield);
        chkDisable.setValue(_ActivePortlet.isdisabledfield);
        chkLabelField.setValue(_ActivePortlet.islabelfield);
        chkProgrammaticalField.setValue(_ActivePortlet.isprogrammaticalfield);
        chkHide.setValue(_ActivePortlet.ishide);

        rLevel.setValue(_ActivePortlet.rlevel);

        StoreToAttribute.reload();
    }

    function WindowAttributePropertyOpen(panel) {
        _ActivePortlet = panel;
        if (panel.crmtype == "attribute" || panel.crmtype == "") {
            StoreViewerList.reload();
            StoreToAttribute.reload();
            loadFeachXml(_ActivePortlet.filter, GridParentChild);
            WindowAttributeProperty.show();
        } else if (panel.crmtype == "iframe") {
            txtIframeName.setValue(panel.title);
            txtIframeUrl.setValue(panel.iframeurl);
            iframeHidden.setValue(panel.ishide);

            nmbIframeHeigth.setValue(panel.iframeheigth);
            chkPassQuery.setValue(panel.iframepassquery);
            cmbDynamicUrl.setValue(panel.iframedynamicurl);
            WindowIframe.show(panel.iframeheigth);
        }else if (panel.crmtype == "webcontrol") {
            txtWebControlName.setValue(panel.title);
            txtWebControlUrl.setValue(panel.webcontrolurl);
            WindowWebControl.show();
        }
        else if (panel.crmtype == "label") {
            txtLabelName.setValue(panel.title);
            txtLabelCaption.setValue(panel.labelcaption);
            labelHidden.setValue(panel.ishide);
            cmbLabelImage.setValue(panel.labelimage);
            cmbLabelLabel.setValue(panel.labellabel);
            lblUseScript.setValue(panel.isusescript);
            lblScript.setValue(panel.onchangescript);

            WindowLabel.show(panel.iframeheigth);
        } else if (panel.crmtype == "button") {
            txtButtonName.setValue(panel.title);
            txtButtonCaption.setValue(panel.buttoncaption);
            btnHidden.setValue(panel.ishide);

            cmbButtonUrl.setValue(panel.buttonurl);
            cmbButtonImage.setValue(panel.buttonimage);
            cmbButtonLabel.setValue(panel.buttonlabel);
            cmbButtonWebService.setValue(panel.buttonwebservice);
            cmbButtonOnDemandWorkflow.setValue(panel.buttonworkflowid);
            beforeAjax.setValue(panel.onbeforeajaxscript);
            WindowButton.show(panel.iframeheigth);
            btnUseScript.setValue(panel.isusescript);
            btnScript.setValue(panel.onchangescript);
        }

    }
    function removePortlet(panel, runGenerateXml) {
        var store = StoreViewAttribute;
        for (var i = 0; i < store.deleted.length; i++) {
            if (store.deleted[i].data.AttributeId == panel.uniqueid) {
                store.add(store.deleted[i]);
                store.deleted.remove(store.deleted[i]);

                if (runGenerateXml)
                    GenerateXml();
                return;
            }
        }
    }
    function AddLabelItem(object) {
        var itemGuid = guid();
        if (_ActivePortlet != null) {
            _ActivePortlet.title = '' + txtLabelName.getValue() + '';
            _ActivePortlet.labelcaption = '' + txtLabelCaption.getValue() + '';
            _ActivePortlet.ishide = '' + labelHidden.getValue() + '';
            _ActivePortlet.labelimage = '' + cmbLabelImage.getValue() + '';
            _ActivePortlet.labellabel = '' + cmbLabelLabel.getValue() + '';
            _ActivePortlet.isusescript = '' + lblUseScript.getValue() + '';
            _ActivePortlet.onchangescript = '' + lblScript.getValue() + '';

            WindowLabel.hide();
            GenerateXml();
            _ActivePortlet = null;
            return;
        }


        if (PortalColumn0 != null) {
            newPortlet = new Ext.ux.Portlet({
                xtype: 'portlet',
                title: '' + txtLabelName.getValue() + '',
                anchor: "100%",
                tools: tools,
                crmtype: 'label',
                iframeurl: "",
                iframeheigth: "",
                iframepassquery: "",
                iframedynamicurl: "",
                webcontrolurl: '',
                buttoncaption: "",
                buttonurl: "",
                buttonimage: "",
                buttonlabel: "",
                buttonwebservice: "",
                buttonworkflowid: "",
                labelcaption: '' + txtLabelCaption.getValue() + '',
                labelimage: '' + cmbLabelImage.getValue() + '',
                labellabel: '' + cmbLabelLabel.getValue() + '',
                onbeforeajaxscript: "",
                uniqueid: itemGuid,
                onchangescript: '' + lblScript.getValue() + '',
                isusescript: '' + lblUseScript.getValue() + '',
                clientworkflow: "",
                isreadonlyfield: false,
                isdisabledfield: false,
                ishide: '' + labelHidden.getValue() + '',
                islabelfield: false,
                isprogrammaticalfield: false,
                rlevel: "0",
                lookupview: "",
                openlookup: false,
                lookupsearchcount: 0,
                filter: "",
                collapsed: true,
                html: '' + txtLabelName.getValue() + '',
                draggable: { endDrag: function (e) { GenerateXml(); } }

            })
            PortalColumn0.add(eval(newPortlet));
            PortalColumn0.doLayout();
            WindowLabel.hide();
            GenerateXml();

        }
    }
    function AddButtonItem(object) {
        var itemGuid = guid();
        if (_ActivePortlet != null) {
            _ActivePortlet.title = '' + txtButtonName.getValue() + '';
            _ActivePortlet.buttoncaption = '' + txtButtonCaption.getValue() + '';
            _ActivePortlet.ishide = '' + btnHidden.getValue() + '';
            _ActivePortlet.buttonurl = '' + cmbButtonUrl.getValue() + '';
            _ActivePortlet.buttonimage = '' + cmbButtonImage.getValue() + '';
            _ActivePortlet.buttonlabel = '' + cmbButtonLabel.getValue() + '';
            _ActivePortlet.buttonwebservice = '' + cmbButtonWebService.getValue() + '';
            _ActivePortlet.buttonworkflowid = '' + cmbButtonOnDemandWorkflow.getValue() + '';
            _ActivePortlet.onbeforeajaxscript = '' + beforeAjax.getValue() + '';
            _ActivePortlet.isusescript = '' + btnUseScript.getValue() + '';
            _ActivePortlet.onchangescript = '' + btnScript.getValue() + '';

            WindowButton.hide();
            GenerateXml();
            _ActivePortlet = null;
            return;
        }


        if (PortalColumn0 != null) {
            newPortlet = new Ext.ux.Portlet({
                xtype: 'portlet',
                title: '' + txtButtonName.getValue() + '',
                anchor: "100%",
                tools: tools,
                crmtype: 'button',
                iframeurl: "",
                iframeheigth: "",
                iframepassquery: "",
                iframedynamicurl: "",
                webcontrolurl: '',
                buttoncaption: txtButtonCaption.getValue(),
                buttonurl: cmbButtonUrl.getValue(),
                buttonimage: cmbButtonImage.getValue(),
                buttonlabel: cmbButtonLabel.getValue(),
                buttonwebservice: cmbButtonWebService.getValue(),
                buttonworkflowid: cmbButtonOnDemandWorkflow.getValue(),
                labelcaption: '',
                labelimage: '',
                labellabel: '',
                onbeforeajaxscript: beforeAjax.getValue() ? beforeAjax.getValue() : "",
                uniqueid: itemGuid,
                onchangescript: btnScript.getValue() ? btnScript.getValue() : "",
                isusescript: btnUseScript.getValue(),
                clientworkflow: "",
                isreadonlyfield: false,
                isdisabledfield: false,
                ishide: '' + btnHidden.getValue() + '',
                islabelfield: false,
                isprogrammaticalfield: false,
                rlevel: "0",
                lookupview: "",
                openlookup: false,
                lookupsearchcount: 0,
                filter: "",
                collapsed: true,
                html: '' + txtButtonName.getValue() + '',
                draggable: { endDrag: function (e) { GenerateXml(); } }

            })
            PortalColumn0.add(eval(newPortlet));
            PortalColumn0.doLayout();
            WindowButton.hide();
            GenerateXml();

        }
    }

    function AddAttributeItem(object) {
        selNode = GrdFieldsAttribute.getSelectionModel()
        var store = StoreViewAttribute;
        for (var i = 0; i < selNode.selections.items.length; i++) {
            var Item = selNode.selections.items[i];
            if (PortalColumn0 != null) {
                newPortlet = new Ext.ux.Portlet({
                    xtype: 'portlet',
                    title: '' + Item.data.Label + '',
                    anchor: "100%",
                    tools: tools,
                    crmtype: 'attribute',
                    iframeurl: '',
                    iframeheigth: 0,
                    iframepassquery: false,
                    iframedynamicurl: '',
                    webcontrolurl: '',
                    buttoncaption: '',
                    buttonurl: '',
                    buttonimage: '',
                    buttonlabel: '',
                    buttonwebservice: '',
                    buttonworkflowid: '',
                    labelcaption: '',
                    labelimage: '',
                    labellabel: '',
                    uniqueid: Item.data.AttributeId,
                    onchangescript: "",
                    onbeforeajaxscript: "",
                    isusescript: false,
                    clientworkflow: "",
                    isreadonlyfield: false,
                    isdisabledfield: false,
                    ishide: false,
                    islabelfield: false,
                    isprogrammaticalfield: false,
                    rlevel: "0",
                    lookupview: "",
                    openlookup: false,
                    lookupsearchcount: 3,
                    filter: "",
                    collapsed: true,
                    html: '' + Item.data.UniqueName + '',
                    draggable: { endDrag: function (e) { GenerateXml(); } }

                })
                PortalColumn0.add(eval(newPortlet));
                PortalColumn0.doLayout();
            }
        }
        /*Eklediklerini listeden kaldir.*/
        for (var i = 0; i < selNode.selections.items.length; i++) {
            var Item = selNode.selections.items[i];
            store.remove(store.getById(Item.data.AttributeId));
        }
        WindowAttributeList.hide();
        GenerateXml();
    }

    function AddWebControlItem(object) {
        var itemGuid = guid();
        if (_ActivePortlet != null) {
            _ActivePortlet.title = '' + txtWebControlName.getValue() + '';
            _ActivePortlet.webcontrolurl = '' + txtWebControlUrl.getValue() + '';

            WindowWebControl.hide();
            GenerateXml();
            _ActivePortlet = null;
            return;
        }

        if (PortalColumn0 != null) {
            newPortlet = new Ext.ux.Portlet({
                xtype: 'portlet',
                title: '' + txtWebControlName.getValue() + '',
                anchor: "100%",
                tools: tools,
                crmtype: 'webcontrol',
                iframeurl: '',
                iframeheigth: 0,
                iframepassquery: false,
                iframedynamicurl: '',
                webcontrolurl: '' + txtWebControlUrl.getValue() + '',
                buttoncaption: '',
                buttonurl: '',
                buttonimage: '',
                buttonlabel: '',
                buttonwebservice: '',
                buttonworkflowid: '',
                labelcaption: '',
                labelimage: '',
                labellabel: '',
                uniqueid: itemGuid,
                onchangescript: "",
                onbeforeajaxscript: "",
                isusescript: false,
                clientworkflow: "",
                isreadonlyfield: false,
                isdisabledfield: false,
                islabelfield: false,
                isprogrammaticalfield: false,
                ishide: false,
                rlevel: "0",
                lookupview: "",
                openlookup: false,
                lookupsearchcount: 3,
                filter: "",
                collapsed: true,
                html: '' ,
                draggable: { endDrag: function (e) { GenerateXml(); } }

            })
            PortalColumn0.add(eval(newPortlet));
            PortalColumn0.doLayout();
            WindowWebControl.hide();
            GenerateXml();
        }
    }
    function AddIframeItem(object) {
        var itemGuid = guid();
        if (_ActivePortlet != null) {
            _ActivePortlet.title = '' + txtIframeName.getValue() + '';
            _ActivePortlet.iframeurl = '' + txtIframeUrl.getValue() + '';
            _ActivePortlet.ishide = '' + iframeHidden.getValue() + '';

            _ActivePortlet.iframeheigth = '' + nmbIframeHeigth.getValue() + '';
            _ActivePortlet.iframepassquery = '' + chkPassQuery.getValue() + '';
            _ActivePortlet.iframedynamicurl = '' + cmbDynamicUrl.getValue() + '';

            WindowIframe.hide();
            GenerateXml();
            _ActivePortlet = null;
            return;
        }

        if (PortalColumn0 != null) {
            newPortlet = new Ext.ux.Portlet({
                xtype: 'portlet',
                title: '' + txtIframeName.getValue() + '',
                anchor: "100%",
                tools: tools,
                crmtype: 'iframe',
                iframeurl: '' + txtIframeUrl.getValue() + '',
                iframeheigth: nmbIframeHeigth.getValue(),
                iframepassquery: chkPassQuery.getValue(),
                iframedynamicurl: cmbDynamicUrl.getValue(),
                buttoncaption: '',
                buttonurl: '',
                buttonimage: '',
                buttonlabel: '',
                buttonwebservice: '',
                buttonworkflowid: '',
                labelcaption: '',
                labelimage: '',
                labellabel: '',
                uniqueid: itemGuid,
                onchangescript: "",
                onbeforeajaxscript: "",
                isusescript: false,
                clientworkflow: "",
                isreadonlyfield: false,
                isdisabledfield: false,
                islabelfield: false,
                isprogrammaticalfield: false,
                ishide: '' + iframeHidden.getValue() + '',
                rlevel: "0",
                lookupview: "",
                openlookup: false,
                lookupsearchcount: 3,
                filter: "",
                collapsed: true,
                html: '' + txtIframeUrl.getValue() + '',
                draggable: { endDrag: function (e) { GenerateXml(); } }

            })
            PortalColumn0.add(eval(newPortlet));
            PortalColumn0.doLayout();
            WindowIframe.hide();
            GenerateXml();
        }
    }
    function DeleteSection(object) {
        var selectedValue = lstSectionList.getValue();
        if (selectedValue != "") {
            for (var i = 0; i < SectionViewer.items.items.length; i++) {
                var PortalColumnObject = SectionViewer.items.items[i].items.items;

                for (var j = 0; j < PortalColumnObject.length; j++) {
                    PortalColumnObject[j].destroy();
                    removePortlet(PortalColumnObject[j], false);
                }
                SectionViewer.items.items[i].destroy();
            }
        }
        lstSectionList.store.remove(lstSectionList.store.getById(selectedValue));
    }

    function AddNewPortal(object) {

        txtSectionName.setValue(null);
        txtSectionId.setValue(null);
        chkShowHeader.setValue(null);
        chkUseBorder.setValue(null);
        CmbSectionStyle.setValue(null);
        btnUpdate.setVisible(false)
        btnOk.setVisible(true)
        nmbLabelWidth.setValue(null);
        CmbSectionLabel.setValue(null);

        CmbSectionStyle.setEditable(false)
        WindowSelectSectionStyle.show();

    }
    function UpdateSection(object) {

        var selectedValue = lstSectionList.getValue();
        var Stores = lstSectionList.store.getById(selectedValue)
        Stores.data.text = txtSectionName.getValue();
        Stores.data.sectionid = txtSectionId.getValue();
        Stores.data.showheader = chkShowHeader.getValue();
        Stores.data.useborder = chkUseBorder.getValue();
        Stores.data.labelwidth = nmbLabelWidth.getValue();
        Stores.data.sectionlabel = CmbSectionLabel.getValue();

        SectionViewer.sectionname = txtSectionName.getValue();
        SectionViewer.sectionid = txtSectionId.getValue();
        SectionViewer.showheader = chkShowHeader.getValue();
        SectionViewer.useborder = chkUseBorder.getValue();
        SectionViewer.labelwidth = nmbLabelWidth.getValue();
        SectionViewer.sectionlabel = CmbSectionLabel.getValue();
        //        if (SectionViewer.styleid != CmbSectionStyle.value)
        //            ReConfigurePortalColumn(SectionViewer.styleid, CmbSectionStyle.value)
        //        SectionViewer.styleid = CmbSectionStyle.value;
        GenerateXml();
        WindowSelectSectionStyle.hide();
    }


    function AddEditSection(object) {
        if (FormPanelSectionStyle.validate()) {
            if (CmbSectionStyle.value != "") {
                object.removeAll()
                var styleId = CmbSectionStyle.value;
                var sW = styleId.split(':');
                for (i = 0; i < sW.length; i++) {
                    var p1 = new Ext.Panel
                    ({ id: "PortalColumn" + i, xtype: "portalcolumn", style: "padding:10px 0 10px 10px", columnWidth: sW[i], layout: "cooliteanchor" })
                    object.add(p1);
                }
                object.setTitle(txtSectionName.getValue())
                object.doLayout();

                var itemGuid = guid();
                var MyRecordType = Ext.data.Record.create(['id', 'value', 'text', 'type', 'showheader', 'useborder', 'labelwidth', 'sectionlabel', 'xmlvalue']);

                myrec = new MyRecordType(
                    { "id": itemGuid, "value": itemGuid, "text": txtSectionName.getValue(), "sectionid": txtSectionId.getValue(), "type": styleId, "showheader": chkShowHeader.getValue(), "useborder": chkUseBorder.getValue(), "labelwidth": nmbLabelWidth.getValue(), "sectionlabel": CmbSectionLabel.getValue(), "xmlvalue": "" }
                , itemGuid);
                lstSectionList.store.insert(lstSectionList.store.data.length, myrec);

                lstSectionList.setValue(itemGuid, false);

                WindowSelectSectionStyle.hide();
                object.uniqueid = itemGuid;
                object.sectionname = txtSectionName.getValue();
                object.sectionid = txtSectionId.getValue();
                object.showheader = chkShowHeader.getValue();
                object.useborder = chkUseBorder.getValue();
                object.labelwidth = nmbLabelWidth.getValue();
                object.sectionlabel = CmbSectionLabel.getValue();
                object.styleid = styleId

                GenerateXml();

            }
        }
    }

    function ShowWindowButtonList(object) {
        object.show();
    }

    function ShowWindowIframeList(object) {
        object.show();
    }
    function ShowWindowWebControl(object) {
        object.show();
    }

    function ShowWindowLabelList(object) {
        object.show();
    }
    function ShowWindowAttributeList(object) {
        wonload();

        object.show();
    }


    function GenerateXml() {

        var strXml = "<viewer "
        + "uniqueid='" + SectionViewer.uniqueid + "'"
        + " sectionname='" + SectionViewer.sectionname + "'"
        + " sectionid='" + SectionViewer.sectionid + "'"
        
        + " showheader='" + SectionViewer.showheader + "'"
        + " useborder='" + SectionViewer.useborder + "'"
        + " labelwidth='" + SectionViewer.labelwidth + "'"
        + " sectionlabel='" + SectionViewer.sectionlabel + "'"
        + " styleid='" + SectionViewer.styleid + "'"
        + ">";
        for (var i = 0; i < SectionViewer.items.items.length; i++) {
            strXml += getPortalColumnXml(SectionViewer.items.items[i]);
        }
        strXml += "</viewer>";
        selectedValue = lstSectionList.getValue();
        var Stores = lstSectionList.store.getById(selectedValue);
        var isFound = false;
        Stores.data.xmlvalue = strXml;
    }
    function getPortalColumnXml(PortalColumnObject) {
        var strXml = "<portalcolumn id='" + PortalColumnObject.id + "' columnwidth='" + PortalColumnObject.columnWidth + "'>";
        for (var i = 0; i < PortalColumnObject.items.items.length; i++) {
            strXml += getPortletXml(PortalColumnObject.items.items[i]);
        }
        strXml += "</portalcolumn>";
        return strXml;
    }
    function getPortletXml(PortletObject) {
        var strXml = "<portlet uniqueid='" + PortletObject.uniqueid + "' " +
        " title='" + PortletObject.title + "' " +
        " isusescript='" + PortletObject.isusescript + "' " +
        " clientworkflow='" + PortletObject.clientworkflow + "' " +
        " isreadonlyfield='" + PortletObject.isreadonlyfield + "' " +
        " isdisabledfield='" + PortletObject.isdisabledfield + "' " +
        " islabelfield='" + PortletObject.islabelfield + "' " +
        " isprogrammaticalfield='" + PortletObject.isprogrammaticalfield + "' " +
        " ishide='" + PortletObject.ishide + "' " +
        " rlevel='" + PortletObject.rlevel + "' " +
        " lookupview='" + PortletObject.lookupview + "' " +
        " openlookup='" + PortletObject.openlookup + "' " +
        " lookupsearchcount='" + PortletObject.lookupsearchcount + "' " +

        " iframeurl='" + PortletObject.iframeurl + "' " +
        " iframeheigth='" + PortletObject.iframeheigth + "' " +
        " iframepassquery='" + PortletObject.iframepassquery + "' " +
        " iframedynamicurl='" + PortletObject.iframedynamicurl + "' " +
        " webcontrolurl='" + PortletObject.webcontrolurl + "' " +
        " buttoncaption='" + PortletObject.buttoncaption + "' " +
        " buttonurl='" + PortletObject.buttonurl + "' " +
        " buttonimage='" + PortletObject.buttonimage + "' " +
        " buttonlabel='" + PortletObject.buttonlabel + "' " +
        " buttonwebservice='" + PortletObject.buttonwebservice + "' " +
        " buttonworkflowid='" + PortletObject.buttonworkflowid + "' " +
        " labelcaption='" + PortletObject.labelcaption + "' " +
        " labelimage='" + PortletObject.labelimage + "' " +
        " labellabel='" + PortletObject.labellabel + "' " +

        " crmtype='" + PortletObject.crmtype + "' " +
        ">";
        strXml += "<onchangescript><![CDATA[" + PortletObject.onchangescript + "]]> </onchangescript>";
        strXml += "<filter><![CDATA[" + PortletObject.filter + "]]> </filter>";
        strXml += "<onbeforeajaxscript><![CDATA[" + PortletObject.onbeforeajaxscript + "]]> </onbeforeajaxscript>";

        strXml += "</portlet>";
        return strXml;
    }


    function lstSectionList_DblClick(selectedValue) {

        if (selectedValue == "")
            return;
        var Stores = lstSectionList.store.getById(selectedValue);
        txtSectionName.setValue(Stores.data.text);
        txtSectionId.setValue(Stores.data.sectionid);
        nmbLabelWidth.setValue(Stores.data.labelwidth);
        CmbSectionLabel.setValue(Stores.data.sectionlabel);
        chkShowHeader.setValue(false);
        chkUseBorder.setValue(false);
        if (Stores.data.showheader == true || Stores.data.showheader == "true" || Stores.data.showheader == "True")
            chkShowHeader.setValue(true);
        if (Stores.data.useborder == true || Stores.data.useborder == "true" || Stores.data.useborder == "True")
            chkUseBorder.setValue(true);

        CmbSectionStyle.setValue(Stores.data.type);

        btnUpdate.setVisible(true)
        btnOk.setVisible(false)
        CmbSectionStyle.setEditable(true)

        WindowSelectSectionStyle.show();
        //selectedValue
        //selectedValue
    }
    function lstSectionList_Click(selectedValue) {

        if (selectedValue != "") {
            var Stores = lstSectionList.store.getById(selectedValue);
            SectionViewer.setTitle(Stores.data.text);
            XmlAddSection(SectionViewer, Stores.data)
            if (Stores.data.xmlvalue != "") {
                var XObject = ReadXml(Stores.data.xmlvalue);
                //XObject.selam();
                if (getNodeValue(XObject.childNodes[0], "uniqueid") == selectedValue) {
                    loadXmlDocument(XObject.childNodes[0])
                }
            }
        }
    }
    function loadXmlDocument(Xnode) {
        for (var i = 0; i < Xnode.childNodes.length; i++) {
            for (j = 0; j < Xnode.childNodes[i].childNodes.length; j++)
                AddXmlAttributeItem(i, Xnode.childNodes[i].childNodes[j]);
        }

    }
    function AddXmlAttributeItem(portletid, Xnode) {

        var uniqueid = getNodeValue(Xnode, "uniqueid")
        var title = getNodeValue(Xnode, "title")
        var isusescript = getNodeValue(Xnode, "isusescript")
        var clientworkflow = getNodeValue(Xnode, "clientworkflow")
        var isreadonlyfield = getNodeValue(Xnode, "isreadonlyfield")
        var isdisabledfield = getNodeValue(Xnode, "isdisabledfield")
        var islabelfield = getNodeValue(Xnode, "islabelfield")
        var isprogrammaticalfield = getNodeValue(Xnode, "isprogrammaticalfield")
        var ishide = getNodeValue(Xnode, "ishide")
        var rlevel = getNodeValue(Xnode, "rlevel")

        var lookupview = getNodeValue(Xnode, "lookupview")
        var openlookup = getNodeValue(Xnode, "openlookup")
        var lookupsearchcount = getNodeValue(Xnode, "lookupsearchcount")

        var iframeheigth = getNodeValue(Xnode, "iframeheigth")
        var iframepassquery = getNodeValue(Xnode, "iframepassquery")
        var iframedynamicurl = getNodeValue(Xnode, "iframedynamicurl")
        var webcontrolurl = getNodeValue(Xnode, "webcontrolurl")
        var buttoncaption = getNodeValue(Xnode, "buttoncaption")
        var buttonurl = getNodeValue(Xnode, "buttonurl")
        var buttonimage = getNodeValue(Xnode, "buttonimage")
        var buttonlabel = getNodeValue(Xnode, "buttonlabel")
        var buttonwebservice = getNodeValue(Xnode, "buttonwebservice")
        var buttonworkflowid = getNodeValue(Xnode, "buttonworkflowid")

        var labelcaption = getNodeValue(Xnode, "labelcaption")
        var labelimage = getNodeValue(Xnode, "labelimage")
        var labellabel = getNodeValue(Xnode, "labellabel")

        var iframeurl = getNodeValue(Xnode, "iframeurl")
        var regExp = new RegExp("&amp;", "g");
        iframeurl = iframeurl.replace(regExp, "&");
        var regExp1 = new RegExp("&", "g");
        iframeurl = iframeurl.replace(regExp1, "&amp;");

        var crmtype = getNodeValue(Xnode, "crmtype")
        var filter = "";
        var onchangescript = "";
        var onbeforeajaxscript = "";
        //alert(Xnode.childNodes.length);
        if (Xnode.childNodes.length > 0) {
            onchangescript = Xnode.childNodes[0].firstChild.nodeValue;
            //alert(onchangescript);
            if (Xnode.childNodes.length >= 2) {
                filter = Xnode.childNodes[1].firstChild.nodeValue;
                //alert(filter);
            }
            if (Xnode.childNodes.length >= 3) {
                onbeforeajaxscript = Xnode.childNodes[2].firstChild.nodeValue;
                //alert(filter);
            }
        }



        if (PortalColumn0 != null) {
            newPortlet = new Ext.ux.Portlet({
                xtype: 'portlet',
                title: '' + title + '',
                anchor: "100%",
                tools: tools,
                uniqueid: uniqueid,
                collapsed: true,
                html: '' + title + '',
                iframeheigth: iframeheigth,
                iframepassquery: iframepassquery,
                iframeurl: iframeurl,
                iframedynamicurl: iframedynamicurl,
                webcontrolurl: webcontrolurl,
                buttoncaption: buttoncaption,
                buttonurl: buttonurl,
                buttonimage: buttonimage,
                buttonlabel: buttonlabel,
                buttonwebservice: buttonwebservice,
                buttonworkflowid: buttonworkflowid,
                labelcaption: labelcaption,
                labelimage: labelimage,
                labellabel: labellabel,
                crmtype: crmtype,
                onchangescript: '' + onchangescript + '',
                onbeforeajaxscript: '' + onbeforeajaxscript + '',
                isusescript: isusescript,
                clientworkflow: clientworkflow,
                isreadonlyfield: isreadonlyfield,
                isdisabledfield: isdisabledfield,
                islabelfield: islabelfield,
                isprogrammaticalfield: isprogrammaticalfield,
                ishide: ishide,
                rlevel: rlevel,
                lookupview: lookupview,
                openlookup: openlookup,
                lookupsearchcount: lookupsearchcount,
                filter: filter,
                draggable: { endDrag: function (e) { GenerateXml(); } }

            })
            eval("PortalColumn" + portletid).add(eval(newPortlet));
            eval("PortalColumn" + portletid).doLayout();

            try {

                var r = StoreViewAttribute.find("AttributeId", uniqueid);
                if (r >= 0) {
                    StoreViewAttribute.removeAt(r);
                }

            } catch (exc) {
            }
            GenerateXml();
        }
    }
    function XmlAddSection(object, data) {
        object.removeAll()
        var styleId = data.type;
        var sW = styleId.split(':');
        for (i = 0; i < sW.length; i++) {
            var p1 = new Ext.Panel
                    ({ id: "PortalColumn" + i, xtype: "portalcolumn", style: "padding:10px 0 10px 10px", columnWidth: sW[i], layout: "cooliteanchor" })
            object.add(p1);
        }
        object.setTitle(data.text)
        object.doLayout();
        object.uniqueid = data.value;
        object.showheader = data.showheader
        object.useborder = data.useborder
        object.sectionname = data.text
        object.sectionid = data.sectionid
        object.labelwidth = data.labelwidth
        object.sectionlabel = data.sectionlabel
        object.styleid = data.type;
    }
    function btn_Save_Click() {
        var strLayoutXml =
        "<strlayoutxml>";
        for (i = 0; i < lstSectionList.store.data.items.length; i++)
            strLayoutXml += lstSectionList.store.data.items[i].data.xmlvalue

        strLayoutXml += GenerateSubPanelXml();
        strLayoutXml += GenerateScriptXml();
        strLayoutXml += "</strlayoutxml>";
        Coolite.AjaxMethods.UpdateFormEdit(strLayoutXml);
    }
    function GenerateSubPanelXml() {
        var strSubPanelXml = "<strsubpanelxml>";

        for (i = 0; i < GridReleatedList.store.data.items.length; i++) {
            data = GridReleatedList.store.data.items[i].data;

            strSubPanelXml += "<releatedpanel ";
            strSubPanelXml += " releatedlistid='" + data.ReleatedListId + "'";
            strSubPanelXml += " entityrelationshipid='" + data.EntityRelationShipId + "'";
            strSubPanelXml += " name='" + data.Name + "'";
            strSubPanelXml += " label='" + data.Label + "'";
            strSubPanelXml += " viewqueryid='" + data.ViewQueryId + "'";
            strSubPanelXml += " viewqueryidname='" + data.ViewQueryIdName + "'";
            strSubPanelXml += " isentity='" + data.IsEntity + "'";
            strSubPanelXml += " sortattributeid='" + data.SortAttributeId + "'";
            strSubPanelXml += " sortattributename='" + data.SortAttributeName + "'";
            strSubPanelXml += " labelmessageid='" + data.LabelMessageId + "'";
            strSubPanelXml += " labelmessageidname='" + data.LabelMessageIdName + "'";
            strSubPanelXml += " url='" + data.Url + "'>";
            strSubPanelXml += "<filterlistxml><![CDATA[" + data.FilterListXml + "]]> </filterlistxml>";
            strSubPanelXml += "</releatedpanel>";
        }
        strSubPanelXml += "</strsubpanelxml>";
        return strSubPanelXml;
    }
    function GenerateScriptXml() {
        var strScriptXml = "<scriptxml useiframescript='" + chkUseIframeScript.getValue() + "' iframescripturl='" + txtIframeScriptUrl.getValue() + "' >";

        strScriptXml += "<fscript type='onload' usescript='" + chkOnLoadScript.getValue() + "' workflowid='" + OnloadClientWorkflow.getValue() + "'>";
        strScriptXml += "<fscriptsource><![CDATA[" + txtOnLoadScript.getValue() + "]]> </fscriptsource>";
        strScriptXml += "</fscript>";

        strScriptXml += "<fscript type='beforesave' usescript='" + chkBeforeSave.getValue() + "' workflowid='" + BeforeSaveClientWorkflow.getValue() + "'>";
        strScriptXml += "<fscriptsource><![CDATA[" + txtBeforeSaveScript.getValue() + "]]> </fscriptsource>";
        strScriptXml += "</fscript>";

        strScriptXml += "<fscript type='aftersave' usescript='" + chkAfterSave.getValue() + "' workflowid='" + AfterSaveClientWorkflow.getValue() + "'>";
        strScriptXml += "<fscriptsource><![CDATA[" + txtAfterSaveScript.getValue() + "]]> </fscriptsource>";
        strScriptXml += "</fscript>";

        strScriptXml += "</scriptxml>";
        return strScriptXml;
    }
    var _activeReleatedList = null;
    function ReleatedListPrototype() {
        this.ViewQueryId;
        this.ReleatedListId;
        this.FilterListXml;
    }
    function ShowMapList(c, Data) {
        _activeReleatedList = new ReleatedListPrototype();
        _activeReleatedList.ViewQueryId = Data.ViewQueryId;
        _activeReleatedList.ReleatedListId = Data.ReleatedListId;
        _activeReleatedList.FilterListXml = Data.FilterListXml;

        if (_activeReleatedList.FilterListXml != null)
            loadFeachXml(_activeReleatedList.FilterListXml, MapPathGrid);

        StoreMappathToAttribute.reload();
        WindowMapPath.show(); // (ReleatedListId);
    }
    function MapPathGrid_AddRecord(grp) {
        var fid = MapPathFromAttribute.getValue();
        var fname = MapPathFromAttribute.getText();
        var tid = MapPathToAttribute.getValue();
        var tname = MapPathToAttribute.getText();
        addGridPanelRecord(grp, fid, fname, tid, tname);
    }
    function AddMapPathProperty(pgrid, grid, grp) {
        pgrid.store.getById(_activeReleatedList.ReleatedListId).data.FilterListXml = GenerateFeachXml(grid)
        grid.clear();
        grp.hide()
    }
    function Share() {

        var config = GetWebAppRoot + "/CrmPages/Admin/Share/Share.aspx?ObjectId=32&RecordId=" + hdnFormId.getValue()
    + "&rlistframename=" + window.name
        window.top.newWindow(config, { title: 'Share', width: 800, height: 300, resizable: false, modal: true });
    }
</script>
<script type="text/javascript">

    function FromParentChildLookupCombo_Change(cmb, grid) {

        cmb.record.FromAttributeId = cmb.getValue();

    }
    
</script>
<script src="../../../../../js/GridOrdering.js" type="text/javascript"></script>
