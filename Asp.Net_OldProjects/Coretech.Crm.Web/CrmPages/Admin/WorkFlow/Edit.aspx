<script language="javascript">
    function ActionPrototype() {
        this.Create = "1";
        this.Update = "2"
    }
    function WItemsTypePrototype() {
        this.Check_Condition = "1";
        this.Wait_Condition = "2";
        this.Create_NewEntity = "3";
        this.Update_Entity = "4";
        this.Show_Message = "5";
        this.Dynamic_Url = "6";
        this.Stop_WorkFlow = "7";
        this.Batch_Script = "8";
        this.RedirectForm = "9";
        this.Plugin = "10";


    }
    function IconPrototype() {
        this.ConditionIf = "icon-arrowrotateanticlockwise";
        this.ConditionWait = "icon-time";
        this.folder = "icon-folder";
        this.AddNewEntity = "icon-applicationAdd";
        this.AddUpdateEntity = "icon-ApplicationEdit";
        this.ShowMessage = "icon-CommentAdd";
        this.DynamicUrl = "icon-LinkEdit";
        this.StopWorkflow = "icon-Stop";
        this.BatchScript = "icon-scriptgear";
        this.RedirectForm = "icon-Reload";
        this.Plugin = "icon-Plugin";
    }
    function UrlPrototype() {
        this.Condition = "/CrmPages/Admin/WorkFlow/Condition.aspx";
        this.AddUpdateRecord = "/CrmPages/Admin/WorkFlow/AddUpdateRecord.aspx"
        this.Message = "/CrmPages/Admin/WorkFlow/AddUpdateMessage.aspx"
        this.BatchScript = "/CrmPages/Admin/WorkFlow/AddUpdateBatchScript.aspx"

    }
</script>

<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_WorkFlow_Edit"
    ValidateRequest="false" Codebehind="Edit.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<%@ Register Assembly="Coretech.Crm.Web.UI" Namespace="Coretech.Crm.Web.UI.AutoGenerate"
    TagPrefix="CrmUI" %>
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
        <ext:Hidden runat="server" ID="hdnEntityName">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnEntityId">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnRecid">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnDefaultEditPageId">
        </ext:Hidden>
        <ext:Hidden runat="server" ID="hdnSavingMessage">
        </ext:Hidden>
        <ext:Hidden ID="FetchXML" runat="server">
        </ext:Hidden>
        <ext:Store runat="server" ID="StoreGrdChangeAttribute">
            <SortInfo Field="Label" Direction="ASC" />
            <Reader>
                <ext:JsonReader ReaderID="AttributeId">
                    <Fields>
                        <ext:RecordField Name="AttributeId" />
                        <ext:RecordField Name="Label" />
                        <ext:RecordField Name="IsSelected" Type="Boolean" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
    </div>
    <ext:ViewPort runat="server">
        <Body>
            <ext:BorderLayout ID="BlMain" runat="server">
                <Center>
                    <ext:Panel runat="server" ID="PnlMain" AutoScroll="true">
                        <TopBar>
                            <ext:Toolbar ID="Toolbar1" runat="server">
                                <Items>
                                    <ext:Button runat="server" ID="btnSave" Text="Save" Icon="Disk">
                                        <AjaxEvents>
                                            <Click OnEvent="BtnSave_Click" Before="BtnSave_Before()" Success="RefreshParetnGrid();">
                                                <EventMask ShowMask="true" />
                                                <ExtraParams>
                                                    <ext:Parameter Name="Action" Value="1">
                                                    </ext:Parameter>
                                                    <ext:Parameter Name="WorkFlowItemsXml" Value="GetWorkFlowItemsXml(#{WItems}.root)"
                                                        Mode="Raw">
                                                    </ext:Parameter>
                                                </ExtraParams>
                                            </Click>
                                        </AjaxEvents>
                                    </ext:Button>
                                    <ext:Button runat="server" ID="btnSaveAndNew" Text="Save And New" Icon="DiskMultiple">
                                        <AjaxEvents>
                                            <Click OnEvent="BtnSave_Click" Success="RefreshParetnGrid();">
                                                <EventMask ShowMask="true" />
                                                <ExtraParams>
                                                    <ext:Parameter Name="Action" Value="2">
                                                    </ext:Parameter>
                                                    <ext:Parameter Name="WorkFlowItemsXml" Value="GetWorkFlowItemsXml(#{WItems}.root)"
                                                        Mode="Raw">
                                                    </ext:Parameter>
                                                </ExtraParams>
                                            </Click>
                                        </AjaxEvents>
                                    </ext:Button>
                                    <ext:Button runat="server" ID="btnSaveAndClose" Text="Save And Close" Icon="DiskBlack">
                                        <AjaxEvents>
                                            <Click OnEvent="BtnSave_Click" Success="RefreshParetnGrid(); top.Ext.WindowMgr.getActive().close();">
                                                <EventMask ShowMask="true" />
                                                <ExtraParams>
                                                    <ext:Parameter Name="Action" Value="3">
                                                    </ext:Parameter>
                                                    <ext:Parameter Name="WorkFlowItemsXml" Value="GetWorkFlowItemsXml(#{WItems}.root)"
                                                        Mode="Raw">
                                                    </ext:Parameter>
                                                </ExtraParams>
                                            </Click>
                                        </AjaxEvents>
                                    </ext:Button>
                                    <ext:Button runat="server" ID="btnAction" Text="Action">
                                        <Menu>
                                            <ext:Menu ID="Menu1" runat="server">
                                                <Items>
                                                    <ext:MenuItem>
                                                    </ext:MenuItem>
                                                </Items>
                                            </ext:Menu>
                                        </Menu>
                                    </ext:Button>
                                </Items>
                            </ext:Toolbar>
                        </TopBar>
                        <Body>
                            <ext:Panel runat="server" Title=".">
                                <Body>
                                    <ext:ColumnLayout runat="server">
                                        <ext:LayoutColumn ColumnWidth=".5">
                                            <ext:Panel runat="server" Border="false">
                                                <Body>
                                                    <ext:FormLayout runat="server" ID="Frm1" LabelWidth="100">
                                                        <ext:Anchor>
                                                            <CrmUI:CrmTextFieldComp ID="WorkflowName" runat="server" Width="450" ObjectId="10"
                                                                UniqueName="workflowname" />
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:ComboBox ID="EntityCrmLookupComp" runat="server" FieldLabel="CRM.ENTITY_ENTITYNAME">
                                                            </ext:ComboBox>
                                                        </ext:Anchor>
                                                    </ext:FormLayout>
                                                </Body>
                                            </ext:Panel>
                                        </ext:LayoutColumn>
                                        <ext:LayoutColumn ColumnWidth=".5">
                                            <ext:Panel ID="Panel1" runat="server" Border="false">
                                                <Body>
                                                    <ext:FormLayout ID="FormLayout1" runat="server" LabelWidth="100">
                                                        <ext:Anchor>
                                                            <CrmUI:CrmBooleanComp ID="StartCreate" runat="server" ObjectId="10" UniqueName="StartCreate" />
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <CrmUI:CrmBooleanComp ID="StartDelete" runat="server" ObjectId="10" UniqueName="StartDelete" />
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:MultiField runat="server" ID="Mf1">
                                                                <Fields>
                                                                    <CrmUI:CrmBooleanComp ID="StartChange" runat="server" ObjectId="10" UniqueName="StartChange">
                                                                        <Listeners>
                                                                            <Change Handler="StartChange_onChange()" />
                                                                        </Listeners>
                                                                    </CrmUI:CrmBooleanComp>
                                                                    <ext:Button ID="btnChangeItems" runat="server" Text="..." Disabled="false">
                                                                        <Listeners>
                                                                            <Click Handler="#{WindowChangeAttribute}.show()" />
                                                                        </Listeners>
                                                                    </ext:Button>
                                                                </Fields>
                                                            </ext:MultiField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <CrmUI:CrmPicklistComp runat="server" ID="RunInUser" ObjectId="10" UniqueName="RunInUser">
                                                            </CrmUI:CrmPicklistComp>
                                                        </ext:Anchor>
                                                    </ext:FormLayout>
                                                </Body>
                                            </ext:Panel>
                                        </ext:LayoutColumn>
                                    </ext:ColumnLayout>
                                </Body>
                            </ext:Panel>
                            <ext:Panel runat="server">
                                <Body>
                                    <ext:FormLayout ID="FormLayout2" runat="server" runat="server" LabelWidth="200">
                                        <ext:Anchor>
                                            <CrmUI:CrmBooleanComp ID="IsClientWorkflow" runat="server" ObjectId="10" UniqueName="IsClientWorkflow" />
                                        </ext:Anchor>
                                        <ext:Anchor>
                                            <CrmUI:CrmBooleanComp ID="IsOnDemandWorkflow" runat="server" ObjectId="10" UniqueName="IsOnDemandWorkflow" />
                                        </ext:Anchor>
                                    </ext:FormLayout>
                                </Body>
                            </ext:Panel>
                        </Body>
                    </ext:Panel>
                </Center>
                <South MinHeight="100" MaxHeight="400" Split="true" Collapsible="true" CollapseMode="Default">
                    <ext:Panel runat="server" Height="300" ID="PnlDetail">
                        <Body>
                            <ext:FitLayout runat="server">
                                <ext:TreePanel ID="WItems" runat="server" Icon="BookOpen" Title="Workflow Items"
                                    AutoScroll="true" EnableDD="true">
                                    <TopBar>
                                        <ext:Toolbar ID="ToolBar2" runat="server">
                                            <Items>
                                                <ext:Button ID="BtnDetailAction" runat="server" Text="Action">
                                                    <Menu>
                                                        <ext:Menu ID="BtnDetailActionMenu" runat="server">
                                                            <Items>
                                                                <ext:MenuItem ID="BtnAddNewCondition" Enabled="false" Icon="Add" Text="Add New If Condition">
                                                                    <Listeners>
                                                                        <Click Handler="BtnAddNewCondition_Click()" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <ext:MenuItem ID="BtnAddNewWaitCondition" Enabled="false" Icon="Add" Text="Add New Wait Condition">
                                                                    <Listeners>
                                                                        <Click Handler="BtnAddNewWaitCondition_Click()" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <ext:MenuItem ID="BtnAddNewRecord" Enabled="false" Icon="Add" Text="Add New Record">
                                                                    <Listeners>
                                                                        <Click Handler="BtnAddNewRecord_Click()" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <ext:MenuItem ID="BtnAddUpdateRecord" Enabled="false" Icon="Add" Text="Add Update Record">
                                                                    <Listeners>
                                                                        <Click Handler="BtnAddUpdateRecord_Click()" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <ext:MenuItem ID="BtnAddNewMessage" Enabled="false" Icon="Add" Text="Add Message ">
                                                                    <Listeners>
                                                                        <Click Handler="BtnAddNewMessage_Click()" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <ext:MenuItem ID="BtnAddDynamicLink" Enabled="false" Icon="Add" Text="Add Dynamic Link (Window) ">
                                                                    <Listeners>
                                                                        <Click Handler="BtnAddDynamicLink_Click()" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <ext:MenuItem ID="MenuItem1" Enabled="false" Icon="Add" Text="Redirect Form ">
                                                                    <Listeners>
                                                                        <Click Handler="BtnAddRedirectForm_Click()" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <ext:MenuItem Enabled="false" Icon="Add" Text="Add Batch Script">
                                                                    <Listeners>
                                                                        <Click Handler="BtnAddNewBatchScript_Click()" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <ext:MenuItem ID="MenuItem2" Enabled="false" Icon="Plugin" Text="Call Plugin ">
                                                                    <Listeners>
                                                                        <Click Handler="BtnCallPlugin_Click()" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <ext:MenuItem ID="BtnStopWorkFlow" Enabled="false" Icon="Stop" Text="Stop Workflow">
                                                                    <Listeners>
                                                                        <Click Handler="BtnStopWorkFlow_Click()" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                            </Items>
                                                        </ext:Menu>
                                                    </Menu>
                                                </ext:Button>
                                                <ext:Button ID="Button1" runat="server" Text="Delete Selected" Icon="Delete">
                                                    <Listeners>
                                                        <Click Handler="DeleteTree(#{WItems})" />
                                                    </Listeners>
                                                </ext:Button>
                                                <ext:Button runat="server" Text="Expand All">
                                                    <Listeners>
                                                        <Click Handler="#{WItems}.expandAll();" />
                                                    </Listeners>
                                                </ext:Button>
                                                <ext:Button runat="server" Text="Collapse All">
                                                    <Listeners>
                                                        <Click Handler="#{WItems}.collapseAll();" />
                                                    </Listeners>
                                                </ext:Button>
                                            </Items>
                                        </ext:Toolbar>
                                    </TopBar>
                                    <Root>
                                    </Root>
                                    <BottomBar>
                                        <ext:StatusBar ID="StatusBar1" runat="server" AutoClear="1500" />
                                    </BottomBar>
                                    <Listeners>
                                        <Click Handler="#{StatusBar1}.setStatus({text: 'Node Selected: <b>' + node.text + '</b>', clear: true});CheckButton();" />
                                        <ExpandNode Handler="#{StatusBar1}.setStatus({text: 'Node Expanded: <b>' + node.text + '</b>', clear: true});"
                                            Delay="30" />
                                        <CollapseNode Handler="#{StatusBar1}.setStatus({text: 'Node Collapsed: <b>' + node.text + '</b>', clear: true});" />
                                        <DblClick Fn="WItems_OnDblClick" />
                                    </Listeners>
                                </ext:TreePanel>
                            </ext:FitLayout>
                        </Body>
                    </ext:Panel>
                </South>
            </ext:BorderLayout>
        </Body>
    </ext:ViewPort>
    <ext:Window ID="WindowChangeAttribute" runat="server" Title="Section Attributes"
        Height="300px" Width="300px" Modal="True" Icon="ApplicationEdit" ShowOnLoad="false">
        <Body>
            <ext:FitLayout runat="server">
                <ext:GridPanel ID="GrdChangeAttribute" EnableHdMenu="false" runat="server" StoreID="StoreGrdChangeAttribute">
                    <ColumnModel>
                        <Columns>
                            <ext:Column DataIndex="AttributeId" Header="Column" Hidden="true" Sortable="false">
                            </ext:Column>
                            <ext:Column DataIndex="Label" Header="Column" Sortable="false" Width="200">
                            </ext:Column>
                        </Columns>
                    </ColumnModel>
                    <SelectionModel>
                        <ext:CheckboxSelectionModel runat="server" SelectedRecordID="AttributeId">
                        </ext:CheckboxSelectionModel>
                    </SelectionModel>
                    <BottomBar>
                        <ext:Toolbar runat="server">
                            <Items>
                                <ext:Button Text="Ok" runat="server">
                                    <Listeners>
                                        <Click Handler="#{WindowChangeAttribute}.hide()" />
                                    </Listeners>
                                </ext:Button>
                            </Items>
                        </ext:Toolbar>
                    </BottomBar>
                </ext:GridPanel>
            </ext:FitLayout>
        </Body>
    </ext:Window>
    <ext:Window ID="WindowDynamicLink" runat="server" Modal="true" ShowOnLoad="false"
        Icon="LinkEdit" Width="400" Height="150">
        <Body>
            <ext:Panel runat="server" Width="400" Height="100">
                <Body>
                    <ext:FormLayout ID="FormLayout3" runat="server" runat="server" LabelWidth="100">
                        <ext:Anchor>
                            <ext:ComboBox runat="server" ID="cmbDynamicUrl" FieldLabel="Dinamik Url" Width="200">
                            </ext:ComboBox>
                        </ext:Anchor>
                        <ext:Anchor>
                            <ext:Hidden runat="server" ID="hdncmbDynamicUrl">
                            </ext:Hidden>
                        </ext:Anchor>
                    </ext:FormLayout>
                </Body>
                <BottomBar>
                    <ext:Toolbar runat="server">
                        <Items>
                            <ext:Button Text="Ok" runat="server">
                                <Listeners>
                                    <Click Handler="WindowDynamicLink_AddUpdate();#{WindowDynamicLink}.hide()" />
                                </Listeners>
                            </ext:Button>
                        </Items>
                    </ext:Toolbar>
                </BottomBar>
            </ext:Panel>
        </Body>
    </ext:Window>
    <ext:Window ID="WindowRedirectForm" runat="server" Modal="true" ShowOnLoad="false"
        Icon="LinkEdit" Width="400" Height="150">
        <Body>
            <ext:Panel ID="Panel2" runat="server" Width="400" Height="100">
                <Body>
                    <ext:FormLayout ID="FormLayout4" runat="server" runat="server" LabelWidth="100">
                        <ext:Anchor>
                            <ext:ComboBox runat="server" ID="cmbRedirectForm" FieldLabel="Redirect Form" Width="200">
                            </ext:ComboBox>
                        </ext:Anchor>
                        <ext:Anchor>
                            <ext:Hidden runat="server" ID="hdncmbRedirectForm">
                            </ext:Hidden>
                        </ext:Anchor>
                    </ext:FormLayout>
                </Body>
                <BottomBar>
                    <ext:Toolbar ID="Toolbar3" runat="server">
                        <Items>
                            <ext:Button ID="Button2" Text="Ok" runat="server">
                                <Listeners>
                                    <Click Handler="WindowRedirectForm_AddUpdate();#{WindowRedirectForm}.hide()" />
                                </Listeners>
                            </ext:Button>
                        </Items>
                    </ext:Toolbar>
                </BottomBar>
            </ext:Panel>
        </Body>
    </ext:Window>
    <ext:Window ID="WindowCallPlugin" runat="server" Modal="true" ShowOnLoad="false"
        Icon="LinkEdit" Width="400" Height="150">
        <Body>
            <ext:Panel ID="Panel3" runat="server" Width="400" Height="100">
                <Body>
                    <ext:FormLayout ID="FormLayout5" runat="server" runat="server" LabelWidth="100">
                        <ext:Anchor>
                            <ext:ComboBox runat="server" ID="cmbcallPlugin" FieldLabel="Plugin List" Width="200">
                            </ext:ComboBox>
                        </ext:Anchor>
                        <ext:Anchor>
                            <ext:Hidden runat="server" ID="hdncmbcallPlugin">
                            </ext:Hidden>
                        </ext:Anchor>
                    </ext:FormLayout>
                </Body>
                <BottomBar>
                    <ext:Toolbar ID="Toolbar4" runat="server">
                        <Items>
                            <ext:Button ID="Button3" Text="Ok" runat="server">
                                <Listeners>
                                    <Click Handler="WindowCallPlugin_AddUpdate();#{WindowCallPlugin}.hide()" />
                                </Listeners>
                            </ext:Button>
                        </Items>
                    </ext:Toolbar>
                </BottomBar>
            </ext:Panel>
        </Body>
    </ext:Window>
    </form>
</body>
</html>
<script language="javascript">
    var WItemsAction = new ActionPrototype();
    var WItemsType_Root = "0";
    var WItemsType = new WItemsTypePrototype();
    var WItemsIcon = new IconPrototype();
    var Url = new UrlPrototype();

    function StartChange_onChange() {
        btnChangeItems.setVisible(StartChange.getValue())
    }
    function WItems_OnDblClick(a, e) {
        if (!IsNull(a.attributes.ClauseText)) {
            var _Url = "";
            switch (a.attributes.Type) {
                case WItemsType.Wait_Condition:
                case WItemsType.Check_Condition:
                    _Url = Url.Condition;
                    break;
                case WItemsType.Create_NewEntity:
                case WItemsType.Update_Entity:
                    _Url = Url.AddUpdateRecord;
                    break;
                case WItemsType.Dynamic_Url:
                    hdncmbDynamicUrl.setValue(WItemsAction.Update);
                    cmbDynamicUrl.setValue(a.attributes.ClauseValue);
                    WindowDynamicLink.show();
                    return;
                    break;
                case WItemsType.Stop_WorkFlow:
                    return;
                    break;
                case WItemsType.Show_Message:
                    _Url = Url.Message;
                    break;
                case WItemsType.Batch_Script:
                    _Url = Url.BatchScript;
                    break;
                case WItemsType.RedirectForm:
                    hdncmbRedirectForm.setValue(WItemsAction.Update);
                    cmbRedirectForm.setValue(a.attributes.ClauseValue);
                    WindowRedirectForm.show();
                    return;
                    break;
                case WItemsType.Plugin:
                    hdncmbcallPlugin.setValue(WItemsAction.Update);
                    cmbcallPlugin.setValue(a.attributes.ClauseValue);
                    WindowCallPlugin.show();
                    return;
                    break;

            }
            ShowWorkFlowSubEditWindows(_Url, hdnObjectId.getValue(), a.attributes.ClauseText, a.attributes.ClauseValue, WItemsAction.Update, a.attributes.Type);
        }
    }


    function BtnAddNewCondition_Click() {
        ShowWorkFlowSubEditWindows(Url.Condition, hdnObjectId.getValue(), '', '', WItemsAction.Create, WItemsType.Check_Condition);
    }
    function BtnAddNewWaitCondition_Click() {

        ShowWorkFlowSubEditWindows(Url.Condition, hdnObjectId.getValue(), '', '', WItemsAction.Create, WItemsType.Wait_Condition);
    }
    function BtnAddNewRecord_Click() {

        ShowWorkFlowSubEditWindows(Url.AddUpdateRecord, hdnObjectId.getValue(), '', '', WItemsAction.Create, WItemsType.Create_NewEntity)
    }
    function BtnAddNewMessage_Click() {
        ShowWorkFlowSubEditWindows(Url.Message, hdnObjectId.getValue(), '', '', WItemsAction.Create, WItemsType.Show_Message);
    }
    function BtnAddNewBatchScript_Click() {
        ShowWorkFlowSubEditWindows(Url.BatchScript, hdnObjectId.getValue(), '', '', WItemsAction.Create, WItemsType.Batch_Script);
    }

    function BtnAddUpdateRecord_Click() {

        ShowWorkFlowSubEditWindows(Url.AddUpdateRecord, hdnObjectId.getValue(), '', '', WItemsAction.Create, WItemsType.Update_Entity)
    }
    function BtnStopWorkFlow_Click() {
        AddUpdateCondition("Stop Workflow", "", WItemsAction.Create, WItemsType.Stop_WorkFlow)
    }
    function DeleteTree(Object) {
        if (Object.getSelectionModel().selNode != null) {
            if (Object.getSelectionModel().selNode.parentNode != null) {
                Object.getSelectionModel().selNode.remove()
            }
        }
    }

    function BtnAddDynamicLink_Click() {
        hdncmbDynamicUrl.setValue(WItemsAction.Create);
        WindowDynamicLink.show();
    }
    function BtnAddRedirectForm_Click() {

        hdncmbRedirectForm.setValue(WItemsAction.Create);
        WindowRedirectForm.show();
    }

    function WindowRedirectForm_AddUpdate() {
        var urlText = "Redirect " + cmbRedirectForm.getText();
        var urlValue = cmbRedirectForm.getValue();

        AddUpdateCondition(urlText, urlValue, hdncmbRedirectForm.getValue(), WItemsType.RedirectForm);
        WindowDynamicLink.hide();
    }
    function WindowDynamicLink_AddUpdate() {
        var urlText = "Dynamic Link" + cmbDynamicUrl.getText();
        var urlValue = cmbDynamicUrl.getValue();

        AddUpdateCondition(urlText, urlValue, hdncmbDynamicUrl.getValue(), WItemsType.Dynamic_Url);
        WindowDynamicLink.hide();
    }

    function BtnCallPlugin_Click() {

        hdncmbcallPlugin.setValue(WItemsAction.Create);
        WindowCallPlugin.show();
    }

    function WindowCallPlugin_AddUpdate() {
        var urlText = "Call Plugin " + cmbcallPlugin.getText();
        var urlValue = cmbcallPlugin.getValue();

        AddUpdateCondition(urlText, urlValue, hdncmbcallPlugin.getValue(), WItemsType.Plugin);
        WindowCallPlugin.hide();
    }
    function AddUpdateCondition(ClauseText, ClauseValue, Action, Type) {
        if (WItems.getSelectionModel().selNode == null)
            return;
        var _Icon
        if (Type == WItemsType.Check_Condition)
            _Icon = WItemsIcon.ConditionIf
        if (Type == WItemsType.Wait_Condition)
            _Icon = WItemsIcon.ConditionWait
        if (Type == WItemsType.Update_Entity)
            _Icon = WItemsIcon.AddUpdateEntity
        if (Type == WItemsType.Create_NewEntity)
            _Icon = WItemsIcon.AddNewEntity
        if (Type == WItemsType.Dynamic_Url)
            _Icon = WItemsIcon.DynamicUrl;
        if (Type == WItemsType.RedirectForm)
            _Icon = WItemsIcon.RedirectForm;
        if (Type == WItemsType.Stop_WorkFlow)
            _Icon = WItemsIcon.StopWorkflow
        if (Type == WItemsType.Show_Message)
            _Icon = WItemsIcon.ShowMessage
        if (Type == WItemsType.Batch_Script)
            _Icon = WItemsIcon.BatchScript
        if (Type == WItemsType.Plugin)
            _Icon = WItemsIcon.Plugin

        if (Action == 1) {/*Insert Mode*/
            selNode = WItems.getSelectionModel().selNode;
            var newNode = new Ext.tree.TreeNode({
                id: guid(),
                text: ClauseText,
                leaf: false,
                Type: Type,
                iconCls: _Icon,
                ClauseValue: ClauseValue,
                ClauseText: ClauseText
            }
            );
            selNode.appendChild(newNode);
            selNode.expand();
        } else {
            /*Update*/
            selNode = WItems.getSelectionModel().selNode;
            selNode.setText(ClauseText);
            selNode.attributes.ClauseValue = ClauseValue;
            selNode.attributes.ClauseText = ClauseText;
            selNode.attributes.Type = Type;
        }

    }

    function CheckButton() {
        if (WItems.getSelectionModel().selNode == null) {
            BtnAddNewCondition.setDisabled(true)
            BtnAddNewRecord.setDisabled(true)
            BtnAddUpdateRecord.setDisabled(true)
        }
        else {
            selNode = WItems.getSelectionModel().selNode;
            BtnAddNewCondition.setDisabled(false)
            BtnAddNewRecord.setDisabled(false)
            BtnAddUpdateRecord.setDisabled(false)
        }
    }

    function ShowWorkFlowSubEditWindows(Url, ObjectId, Text, xmlTemplateId, Action, Type) {
        var Qstring = GetWebAppRoot + Url + "?ObjectId=" + ObjectId
    + "&framename=" + window.name
    + "&action=" + Action
        if (window.parent != null)
            Qstring += "&pframename=" + window.parent.name;
        if (xmlTemplateId != null && xmlTemplateId != "")
            Qstring += "&xmlTemplateId=" + xmlTemplateId;
        if (Text != null && Text != "")
            Qstring += "&Text=" + Text;
        if (Type != null && Type != "")
            Qstring += "&Type=" + Type;

        if (FrameWorkType != "RefleX") {
            window.top.newWindow(Qstring, { title: 'Condition', width: 900, height: 600, resizable: true, modal: true, maximizable: true });
        }
        else {
            Qstring += "&pawinid=" + window.top.R.WindowMng.getActiveWindow().id;
            window.top.newWindowRefleX(Qstring, { title: 'Condition', width: 900, height: 600, resizable: true, modal: true, maximizable: true });
        }
    }

    function GetWorkFlowItemsXml(TreeNode) {
        //Type: WItemsType_Condition,
        var strXml = ""
        if (TreeNode.attributes != null) {
            var id = TreeNode.attributes.id
            var text = TreeNode.attributes.text
            var Type = TreeNode.attributes.Type
            var ClauseText = TreeNode.attributes.ClauseText
            var ClauseValue = TreeNode.attributes.ClauseValue
            strXml += "<item" + id + " id='" + id + "' text='" + text + "' type='" + Type + "' clausetext='" + ClauseText + "' clausevalueid='" + ClauseValue + "'    >";
            for (var i = 0; i < TreeNode.childNodes.length; i++) {
                //selamdur();
                strXml += GetWorkFlowItemsXml(TreeNode.childNodes[i])

            }
            strXml += "</item" + id + ">";
        }
        return strXml;
    }
    function BtnSave_Before() {
        /*var ObjItems = GrdChangeAttribute.getStore().data.items;
        for (i = 0; i < ObjItems.length; i++) {
        if (ObjItems[i].data.IsSelected);
        GrdChangeAttribute.setselect(i);
        }
        GrdChangeAttribute.datastore.items;
        */
    }
</script>
