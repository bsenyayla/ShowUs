<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_WorkFlow_AddUpdateMessage" ValidateRequest="false" Codebehind="AddUpdateMessage.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<%@ Register Src="~/CrmPages/Admin/WorkFlow/DynamicValue.ascx" TagName="DynamicValue"
    TagPrefix="uc2" %>
<%@ Register Assembly="Coretech.Crm.Web.UI" Namespace="Coretech.Crm.Web.UI.AutoGenerate"
    TagPrefix="CrmUI" %>
<html xmlns="http://www.w3.org/1999/xhtml">
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
    <div>
        <ext:Hidden ID="xmlTemplateId" runat="server">
        </ext:Hidden>
        <ext:Hidden ID="_WorkFlowId" runat="server">
        </ext:Hidden>
        <ext:Panel ID="p2" runat="server">
            <Body>
                <ext:Panel ID="p1" runat="server">
                    <TopBar>
                        <ext:Toolbar ID="t1" runat="server">
                            <Items>
                                <ext:Button ID="BtnSave" Icon="PageSave" runat="server">
                                    <AjaxEvents>
                                        <Click OnEvent="BtnSave_Click" Success="AddUpdateParentCondition()">
                                            <ExtraParams>
                                                <ext:Parameter Name="XmlValue" Mode="Raw" Value="getXml()">
                                                </ext:Parameter>
                                            </ExtraParams>
                                        </Click>
                                    </AjaxEvents>
                                </ext:Button>
                            </Items>
                        </ext:Toolbar>
                    </TopBar>
                    <Body>
                        <ext:ColumnLayout ID="ColumnLayout1" runat="server">
                            <ext:LayoutColumn ColumnWidth=".5">
                                <ext:Panel ID="p5" runat="server" Border="false">
                                    <Body>
                                        <ext:FormLayout ID="fl1" runat="server" LabelAlign="Left">
                                            <ext:Anchor Horizontal="90%">
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
                                            <ext:Anchor Horizontal="90%">
                                                <ext:ComboBox ID="MessageType" runat="server" Mode="Local" FieldLabel="Message Type">
                                                    <Items>
                                                        <ext:ListItem Text="MessageBox" Value="1" />
                                                        <ext:ListItem Text="Open New Window Url" Value="2" />
                                                        <ext:ListItem Text="Exec Script" Value="3" />
                                                        <ext:ListItem Text="Exec Sql Script" Value="4" />
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
                <ext:Panel ID="Panel1" runat="server">
                    <Body>
                        <ext:FitLayout ID="FitLayout1" runat="server">
                            <ext:Panel ID="Panel2" runat="server" Width="800" Height="450">
                                <Body>
                                    <ext:BorderLayout ID="BorderLayout1" runat="server">
                                        <Center>
                                            <ext:Panel ID="Panel3" runat="server">
                                                <Body>
                                                    <ext:Panel ID="Panel4" runat="server">
                                                        <Body>
                                                            <ext:FormLayout ID="FormLayout1" runat="server" LabelAlign="Left">
                                                                <ext:Anchor>
                                                                    <ext:HtmlEditor ID="WhereClauseDynamicEditor" FieldLabel="Dynamic Value" runat="server"
                                                                        Height="300" Width="500">
                                                                    </ext:HtmlEditor>
                                                                </ext:Anchor>
                                                            </ext:FormLayout>
                                                        </Body>
                                                    </ext:Panel>
                                                </Body>
                                            </ext:Panel>
                                        </Center>
                                        <East Collapsible="true" MinWidth="350" Split="true">
                                            <ext:Panel ID="Panel5" runat="server" Width="300" Title="Dynamic Value" Collapsed="false"
                                                Height="500" AutoScroll="true">
                                                <Body>
                                                    <uc2:DynamicValue ID="DV" runat="server" IsWorkFlow="true" />
                                                </Body>
                                            </ext:Panel>
                                        </East>
                                    </ext:BorderLayout>
                                </Body>
                            </ext:Panel>
                        </ext:FitLayout>
                    </Body>
                </ext:Panel>
            </Body>
        </ext:Panel>
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
            return lobjectid;
        } else {
            return e.attributes.TargetObjectId;
        }
    }

    function SelectedNodeDblClick() {

    }
    function DisableDays() {
        Get("TxtAddDays", "D").setVisible(false)
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
    function getXml() {
        return GenerateXml();
    }

    function GenerateXml() {
        //selamdur();
        var updateinsert = "<message name='" + encodeXml(txtName.getValue()) + "' objectattributeid='" + lobjectid + "' type='" + MessageType.getValue() + "' >";
        updateinsert += "<value><![CDATA[" + WhereClauseDynamicEditor.getValue() + "]]> </value>"
        updateinsert += "</message>";
        return updateinsert;
    }

    function AddUpdateParentCondition() {
        _AddUpdateParentCondition(txtName.getValue(), xmlTemplateId.getValue(), laction, type)

    }

    
</script>
<script src="Wf.js" type="text/javascript"></script>