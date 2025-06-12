<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_DynamicUrl_DynamicUrlEdit"
    ValidateRequest="false" Codebehind="DynamicUrlEditReflex.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Src="~/CrmPages/Admin/WorkFlow/DynamicValue.ascx" TagName="DynamicValue"
    TagPrefix="uc2" %>
<%@ Register Assembly="Coretech.Crm.Web.UI" Namespace="Coretech.Crm.Web.UI.AutoGenerate"
    TagPrefix="CrmUI" %>
<%--<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style>
        .hide-toolbar .x-html-editor-tb
        {
            display: none !important;
        }
        SPAN.DataSlugStyle
        {
            tab-index: -1;
            background-color: #FFFF33;
            height: 17px;
            padding-top: 1px;
            padding-right: 2px;
            padding-left: 2px;
            overflow-y: hidden;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
       <rx:RegisterResources runat="server" ID="RR"/>
    <div>
        <ext:Hidden ID="hdnDynamicUrlId" runat="server" />
        <ext:Store ID="strGrdDefault" runat="server">
            <Reader>
                <ext:JsonReader ReaderID="DynamicUrlParameterId">
                    <Fields>
                        <ext:RecordField Name="DynamicUrlParameterId" />
                        <ext:RecordField Name="ParameterName" />
                        <ext:RecordField Name="Value" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Store runat="server" ID="StoreEntityObjectAttributeList" AutoLoad="true">
            <SortInfo Field="Label" Direction="ASC" />
            <Reader>
                <ext:JsonReader ReaderID="AttributeId">
                    <Fields>
                        <ext:RecordField Name="ObjectId" />
                        <ext:RecordField Name="AttributeId" />
                        <ext:RecordField Name="Label" />
                        <ext:RecordField Name="UniqueName" />
                        <ext:RecordField Name="ReferencedObjectId" />
                    </Fields>
                </ext:JsonReader>
            </Reader>
        </ext:Store>
        <ext:Panel ID="p2" runat="server">
            <Body>
                <ext:Panel ID="p1" runat="server">
                    <TopBar>
                        <ext:Toolbar ID="t1" runat="server">
                            <Items>
                                <ext:Button ID="BtnSave" Icon="PageSave" runat="server">
                                    <AjaxEvents>
                                        <Click OnEvent="BtnSave_Click" Success="
                                        Ext.MessageBox.show({
			msg: 'Success',
            buttons: Ext.MessageBox.OK,
			width:300
            });
                               
                                        ">
                                            <ExtraParams>
                                                <ext:Parameter Name="Values" Value="Ext.encode(#{GrdDefault}.getRowsValues(false))"
                                                    Mode="Raw" />
                                            </ExtraParams>
                                        </Click>
                                    </AjaxEvents>
                                </ext:Button>
                            </Items>
                        </ext:Toolbar>
                    </TopBar>
                    <Body>
                        <ext:Panel ID="Panel7" runat="server" Border="false">
                            <Body>
                                <ext:ColumnLayout ID="ColumnLayout1" runat="server">
                                    <ext:LayoutColumn ColumnWidth=".5">
                                        <ext:Panel ID="p5" runat="server" Border="false">
                                            <Body>
                                                <ext:FormLayout ID="fl1" runat="server" LabelAlign="Left" LabelWidth="50">
                                                    <ext:Anchor Horizontal="100%">
                                                        <ext:TextField ID="txtName" FieldLabel="Name " runat="server" />
                                                    </ext:Anchor>
                                                </ext:FormLayout>
                                            </Body>
                                        </ext:Panel>
                                    </ext:LayoutColumn>
                                    <ext:LayoutColumn ColumnWidth=".5">
                                        <ext:Panel ID="p4" runat="server" Border="false">
                                            <Body>
                                                <ext:FormLayout ID="FormLayout2" runat="server" LabelAlign="Left" LabelWidth="50">
                                                    <ext:Anchor>
                                                        <ext:ComboBox runat="server" AllowBlank="false" ID="EntityObjectAttributeList" StoreID="StoreEntityObjectAttributeList"
                                                            ValueField="AttributeId" DisplayField="Label" Width="200">
                                                        </ext:ComboBox>
                                                    </ext:Anchor>
                                                </ext:FormLayout>
                                            </Body>
                                        </ext:Panel>
                                    </ext:LayoutColumn>
                                </ext:ColumnLayout>
                            </Body>
                        </ext:Panel>
                        <ext:Panel ID="Panel6" runat="server" Border="false">
                            <Body>
                                <ext:FormLayout runat="server" LabelAlign="Left" LabelWidth="50">
                                    <ext:Anchor Horizontal="90%">
                                        <ext:TextField ID="txtUrl" FieldLabel="Url " runat="server" />
                                    </ext:Anchor>
                                </ext:FormLayout>
                            </Body>
                        </ext:Panel>
                        <ext:Panel ID="Panel9" runat="server" Border="false">
                            <Body>
                                <ext:FormLayout ID="FormLayout6" runat="server" LabelAlign="Left" LabelWidth="50">
                                    <ext:Anchor Horizontal="90%">
                                        <ext:ComboBox ID="cmbCustomControlList" FieldLabel="Custom Control List" runat="server" />
                                    </ext:Anchor>
                                </ext:FormLayout>
                            </Body>
                        </ext:Panel>
                        <ext:Panel ID="Panel8" runat="server" Border="false">
                            <Body>
                                <ext:ColumnLayout ID="ColumnLayout2" runat="server">
                                    <ext:LayoutColumn ColumnWidth=".3">
                                        <ext:Panel runat="server" Border="false">
                                            <Body>
                                                <ext:FormLayout ID="FormLayout3" runat="server" LabelAlign="Left" LabelWidth="50">
                                                    <ext:Anchor>
                                                        <ext:NumberField ID="txtWidth" FieldLabel="Width" Width="100" runat="server" />
                                                    </ext:Anchor>
                                                </ext:FormLayout>
                                            </Body>
                                        </ext:Panel>
                                    </ext:LayoutColumn>
                                    <ext:LayoutColumn ColumnWidth=".3">
                                        <ext:Panel runat="server" Border="false">
                                            <Body>
                                                <ext:FormLayout ID="FormLayout4" runat="server" LabelAlign="Left" LabelWidth="50">
                                                    <ext:Anchor>
                                                        <ext:NumberField ID="txtHeight" FieldLabel="Height" Width="100" runat="server" />
                                                    </ext:Anchor>
                                                </ext:FormLayout>
                                            </Body>
                                        </ext:Panel>
                                    </ext:LayoutColumn>
                                    <ext:LayoutColumn ColumnWidth=".3">
                                        <ext:Panel runat="server" Border="false">
                                            <Body>
                                                <ext:FormLayout ID="FormLayout5" runat="server" LabelAlign="Left" LabelWidth="50">
                                                    <ext:Anchor>
                                                        <ext:ComboBox FieldLabel="Style"  runat="server" ID="cmbOpenStyle" Width="100" >
                                                            <Items>
                                                                <ext:ListItem Text="New Window" Value="1" />
                                                                <ext:ListItem Text="Internal Window" Value="2" />
                                                            </Items>
                                                        </ext:ComboBox>
                                                    </ext:Anchor>
                                                </ext:FormLayout>
                                            </Body>
                                        </ext:Panel>
                                    </ext:LayoutColumn>
                                </ext:ColumnLayout>
                            </Body>
                        </ext:Panel>
                    </Body>
                </ext:Panel>
                <ext:Panel ID="Panel1" runat="server">
                    <Body>
                        <ext:GridPanel runat="server" ID="GrdDefault" StoreID="strGrdDefault" Height="300">
                            <TopBar>
                                <ext:Toolbar ID="Toolbar1" runat="server">
                                    <Items>
                                        <ext:Button runat="server" ID="BtnAdd" Icon="Add" Text="Yeni Alan ekle">
                                            <Listeners>
                                                <Click Handler="AddNewAttribute()" />
                                            </Listeners>
                                        </ext:Button>
                                        <ext:Button ID="Button1" runat="server" Text="Delete" Icon="Delete">
                                            <Listeners>
                                                <Click Handler="#{GrdDefault}.deleteSelected();" />
                                            </Listeners>
                                        </ext:Button>
                                    </Items>
                                </ext:Toolbar>
                            </TopBar>
                            <ColumnModel>
                                <Listeners>
                                </Listeners>
                                <Columns>
                                    <ext:Column Header="DynamicUrlParameterId" Hidden="true" DataIndex="DynamicUrlParameterId"
                                        MenuDisabled="true" Sortable="false">
                                    </ext:Column>
                                    <ext:Column Header="Kolon Adı" MenuDisabled="true" DataIndex="ParameterName" Sortable="false"
                                        Width="300">
                                    </ext:Column>
                                    <ext:Column Header="ConditionValue" MenuDisabled="true" DataIndex="Value" Hidden="false"
                                        Sortable="false" Width="400">
                                    </ext:Column>
                                </Columns>
                            </ColumnModel>
                            <SelectionModel>
                                <ext:RowSelectionModel>
                                </ext:RowSelectionModel>
                            </SelectionModel>
                            <Listeners>
                                <CellDblClick Fn="GrdDefault_DblClick" />
                            </Listeners>
                        </ext:GridPanel>
                    </Body>
                </ext:Panel>
            </Body>
        </ext:Panel>
        <ext:Window runat="server" ID="WindowProperty" Modal="true" ShowOnLoad="false" Width="550"
            Height="350">
            <Body>
                <ext:FitLayout ID="FitLayout1" runat="server">
                    <ext:Panel ID="Panel2" runat="server">
                        <Body>
                            <ext:BorderLayout ID="BorderLayout1" runat="server">
                                <Center>
                                    <ext:Panel ID="Panel3" runat="server">
                                        <Body>
                                            <ext:Panel ID="Panel4" runat="server">
                                                <Body>
                                                    <ext:FormLayout ID="FormLayout1" runat="server" LabelAlign="Left">
                                                        <ext:Anchor Horizontal="90%">
                                                            <ext:TextField runat="server" ID="txtParamName">
                                                            </ext:TextField>
                                                        </ext:Anchor>
                                                        <ext:Anchor>
                                                            <ext:HtmlEditor ID="WhereClauseDynamicEditor" FieldLabel="Dynamic Value" runat="server"
                                                                CtCls="hide-toolbar" Height="150" Width="200">
                                                            </ext:HtmlEditor>
                                                        </ext:Anchor>
                                                    </ext:FormLayout>
                                                </Body>
                                            </ext:Panel>
                                        </Body>
                                    </ext:Panel>
                                </Center>
                                <East Collapsible="true" MinWidth="100" Split="true">
                                    <ext:Panel ID="Panel5" runat="server" Width="200" Title="Dynamic Value" Collapsed="false"
                                        Height="500" AutoScroll="true">
                                        <Body>
                                            <uc2:DynamicValue ID="DV" runat="server" />
                                        </Body>
                                    </ext:Panel>
                                </East>
                            </ext:BorderLayout>
                        </Body>
                    </ext:Panel>
                </ext:FitLayout>
            </Body>
            <TopBar>
                <ext:Toolbar ID="Toolbar2" runat="server">
                    <Items>
                        <ext:Button ID="btnSaveProperty" runat="server" Icon="Add" Text="ADD_UPDATE_RECORD">
                            <Listeners>
                                <Click Handler="addList()" />
                            </Listeners>
                        </ext:Button>
                    </Items>
                </ext:Toolbar>
            </TopBar>
        </ext:Window>
    </div>
    </form>
</body>
</html>
<script language="javascript">
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
    /*Prottype*/
    function ValuePrototype() {
        this.ValueObject = null;
        this.Value = null;
        this.Text = "";
        this.Type = null;

        this.ParameterName = null;
    }
    var ActiveValue = new ValuePrototype();
    var ConditionTypeDefault = "1";
    var ConditionTypeDynamic = "2";

    /*Prottype*/

    function GetObjectId(e) {
        if (e.attributes.TargetObjectId == "") {
            var Combo = EntityObjectAttributeList;
            var aId = Combo.getSelectedItem().value
            var Stores = Combo.store.getById(aId)
            return Stores.data.ObjectId;
        } else {
            return e.attributes.TargetObjectId;
        }
    }
    function SelectedNodeDblClick() {

    }
    function AddNewAttribute() {
        Get("TxtAddDays", "D").setVisible(false)
        SetNullValueWhereClose();
        ActiveValue = new ValuePrototype();
        WindowProperty.show();

    }

    function GetComboAttributeId() {
        return "";
    }
    function GetComboAttributeIdName() {
        return WhereEntityAttributeList.getText();
    }


    function GetAttributeType() {
        return 'nvarchar';
    }
    function ClearDynamicTree() {
        try {
            Get("TreeDynamic", "D").root.removeChildren()
            Get("TreeDynamic", "D").root.leaf = false;
            Get("TreeDynamic", "D").root.loaded = false;
            Get("TreeDynamic", "D").root.iconCls = "icon-folder"


        } catch (xx) { }
    }

    function SetNullValueWhereClose() {

        eval("WhereClauseDynamicEditor").setValue("");

    }



    function AddDynamicValue(t) {
        var obj = WhereClauseDynamicEditor;
        if (t.getSelectionModel().selNode != null) {
            var a = t.getSelectionModel().selNode;
            ActiveValue.Value = a.attributes.AttributePath;
            ActiveValue.Text = a.attributes.ParentName;
            ActiveValue.Type = ConditionTypeDynamic;
            setDynamicValue(obj, ActiveValue);
        }

        function setDynamicValue(obj, Val) {
            // var strStyle = "<style>SPAN.DataSlugStyle{tab-index: -1;background-color: #FFFF33;height: 17px;padding-top: 1px;padding-right: 2px;padding-left: 2px;overflow-y: hidden;}</style>";
            var strText = "<SPAN class='DataSlugStyle' contentEditable='false' style='DISPLAY: inline' tabIndex='-1'value='<slugelement type=\"slug\"><slug type=\"dynamic\" value=\"{0}\"/></slugelement>'>{1}</SPAN>";
            slugValue = "{!" + Val.Value + "!}";


            obj.insertAtCursor(String.format(strText, slugValue, Val.Text))
            ActiveValue.ValueObject = obj;

        }
    }

    function GetSelectedValue() {
        if (!IsNull(ActiveValue.Value)) {
            return ActiveValue.Value;
        }
        return "";
    }

    function addList() {
        ActiveValue.ValueObject = WhereClauseDynamicEditor;
        ActiveValueSetValue();
        var ParameterName = ActiveValue.ParameterName;
        var Value = ActiveValue.Value;
        var itemGuid = guid();
        if (!IsNull(GrdDefault.store.getById(ActiveValue.DynamicUrlParameterId))) {
            var item = GrdDefault.store.getById(ActiveValue.DynamicUrlParameterId)
            GrdDefault.store.remove(item);
            itemGuid = ActiveValue.DynamicUrlParameterId;
        }
        var MyRecordType = Ext.data.Record.create(['id', 'DynamicUrlParameterId', 'ParameterName', 'Value']);
        myrec = new MyRecordType(
                    { "id": itemGuid, "DynamicUrlParameterId": itemGuid, "ParameterName": ParameterName, "Value": Value }
                , itemGuid);
        GrdDefault.store.insert(GrdDefault.store.data.length, myrec);

        txtParamName.setValue(null);
        ClearDynamicTree()
        WindowProperty.hide();
    }
    function ActiveValueSetValue() {

        ActiveValue.Text = ActiveValue.ValueObject.getValue();
        ActiveValue.Value = ActiveValue.ValueObject.getValue();
        ActiveValue.ParameterName = txtParamName.getValue();
    }

    function GrdDefault_DblClick(a, b, c) {
        Get("TxtAddDays", "D").setVisible(false)
        var data = a.getRowsValues()[0];


        ActiveValue.ValueObject = WhereClauseDynamicEditor;
        ClearDynamicTree();
        ActiveValue.ParameterName = data.ParameterName;
        ActiveValue.Value = data.Value;
        ActiveValue.DynamicUrlParameterId = data.DynamicUrlParameterId;
        txtParamName.setValue(data.ParameterName);

        ActiveValue.ValueObject.setValue(ActiveValue.Value)
        WindowProperty.show();
    }

   
   
</script>
--%>