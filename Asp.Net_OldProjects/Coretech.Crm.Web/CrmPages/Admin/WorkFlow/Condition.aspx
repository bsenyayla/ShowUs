<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_WorkFlow_Condition"
ValidateRequest="false"
 Codebehind="Condition.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<%@ Register Src="ConditionBuilder.ascx" TagName="ConditionBuilder" TagPrefix="uc1" %>
<%@ Register Src="DynamicValue.ascx" TagName="DynamicValue" TagPrefix="uc2" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    
</head>
<body>
    <form id="form1" runat="server">
    <ext:Hidden ID="xmlTemplateId" runat="server"></ext:Hidden>
    <ext:Hidden ID="WorkFlowId" runat="server"></ext:Hidden>
    <ext:Panel runat="server">
        
        <Body>
            <ext:ViewPort ID="ViewPort1" runat="server">
                <Body>
                    <ext:BorderLayout ID="BorderLayout1" runat="server">
                        <Center>
                            <ext:Panel ID="Panel2" runat="server">
                                <Body>
                                    <ext:Panel runat="server"  >
                                        <TopBar>
                                            <ext:Toolbar ID="Toolbar1" runat="server">
                                                <Items>
                                                    <ext:Button ID="BtnSave" Icon="PageSave" runat="server">
                                                        <AjaxEvents>
                                                            <Click OnEvent="BtnSave_Click" Success="AddUpdateParentCondition()">
                                                            <ExtraParams >
                                                                <ext:Parameter Name="XmlValue" Mode="Raw" Value="getChildeXml(Get('WhereTree', 'C').root)"></ext:Parameter>
                                                            </ExtraParams>
                                                            </Click>

                                                        </AjaxEvents>
                                                        
                                                    </ext:Button>
                                                </Items>
                                            </ext:Toolbar>
                                        </TopBar>
                                        <Body>
                                            <ext:FormLayout ID="FormLayout1" runat="server" LabelAlign="Left">
                                                <ext:Anchor>
                                                    <ext:TextField ID="ConditionName" FieldLabel="Condition Name" Width="500" runat="server" />
                                                </ext:Anchor>
                                            </ext:FormLayout>
                                        </Body>
                                    </ext:Panel>
                                    <ext:Panel ID="Panel1" runat="server">
                                        <Body>
                                            <uc1:ConditionBuilder ID="CBuilder" runat="server" IsWorkFlow="true" />
                                        </Body>
                                    </ext:Panel>
                                </Body>
                            </ext:Panel>
                        </Center>
                        <East Collapsible="true" MinWidth="100" Split="true">
                            <ext:Panel ID="Panel3" runat="server" Width="200" Title="Dynamic Value" Collapsed="false"
                                Height="500" AutoScroll="true">
                                <Body>
                                    <uc2:DynamicValue ID="DV" runat="server" IsWorkFlow="true"/>
                                </Body>
                            </ext:Panel>
                        </East>
                    </ext:BorderLayout>
                </Body>
            </ext:ViewPort>
        </Body>
    </ext:Panel>
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


    function ClearTreeDynamic() {

    }
    function AddDynamicValue(t) {
        if (t.getSelectionModel().selNode != null) {
            var a = t.getSelectionModel().selNode;
            ActiveValue = new ValuePrototype();
            var BeforeAfter = Get("CmbBeforeAfter", "D").getValue();

            if (!Get("TxtAddDays", "D").hidden && BeforeAfter!="" ) {
                var BeforeAfterText = Get("CmbBeforeAfter", "D").getText();

                var Month   = Get("nmbrMonth", "D").getValue();
                var Day     = Get("nmbrDays", "D").getValue();
                var Hour    = Get("nmbrHours", "D").getValue();
                if (Month == "")
                    Month = 0;
                if (Day == "")
                    Day = 0;
                if (Hour == "")
                    Hour = 0;
                var valueString = "{0}:{1}:{2}:{3}:{4}"
                var TextString = "{0} :{1}: {2}:Months; {3}:Days; {4}:Hours";
                ActiveValue.Value = String.format(valueString, BeforeAfter, a.attributes.AttributePath, Month, Day, Hour);
                ActiveValue.Text = String.format(TextString, BeforeAfterText, a.attributes.ParentName, Month, Day, Hour);
                
                ActiveValue.Type = ConditionTypeDynamic;
                setLabelValue(ActiveValue.Text);

                Get("nmbrMonth", "D").setValue(null);
                Get("nmbrDays", "D").setValue(null);
                Get("nmbrHours", "D").setValue(null);
                Get("CmbBeforeAfter", "D").setValue(null);

            } else {
                ActiveValue.Value = a.attributes.AttributePath;
                ActiveValue.Text = a.attributes.ParentName;
                ActiveValue.Type = ConditionTypeDynamic;
                setLabelValue(a.attributes.ParentName);
            }
        }
    }
    function AddUpdateParentCondition() {
        
            _AddUpdateParentCondition (ConditionName.getValue(), xmlTemplateId.getValue(), laction, type)
         
        }
    
    
    
    function wonload() {
        var frame = null;
        if (window.top.frames[lframename] != null)
            frame = window.top.frames[lframename];
        else if (window.parent.name == lframename)
            frame = window.parent;
    }
</script>
<%--  <uc1:ConditionBuilder ID="CBuilder" runat="server" />--%>
<%--   <uc2:DynamicValue ID="DV" runat="server" />--%>
<%--<Click Handler="alert(getChildeXml(Get('WhereTree').root))" />--%>
<script src="Wf.js" type="text/javascript"></script>