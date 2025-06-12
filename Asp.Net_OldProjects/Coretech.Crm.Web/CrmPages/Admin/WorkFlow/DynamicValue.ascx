<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_WorkFlow_DynamicValue" Codebehind="DynamicValue.ascx.cs" %>
<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<style type="text/css">
    .LabelMidle
    {
        font: 10px Tahoma;
        text-align: center;
        height: auto;
    }
</style>
<ext:Hidden runat="server" ID="hdnObjectId">
</ext:Hidden>
<div style="display: none">
    <ext:Label ID="Pin" Icon="PluginLink" runat="server"/>
    <ext:Label ID="Pin1" Icon="HouseLink" runat="server"/>
    
</div>
<ext:Menu runat="server" ID="mnuDynamicBuilder">
    <Items>
        <ext:MenuItem runat="server" ID="mnuAdd" Text="Add" Icon="Add">
            <Listeners>
                <Click Handler="AddDynamicValue(#{TreeDynamic})" />
            </Listeners>
        </ext:MenuItem>
    </Items>
</ext:Menu>
<ext:FormPanel runat="server">
    <Body>
        <ext:Panel runat="server">
            <Body>
                <ext:FormLayout runat="server" LabelAlign="Top">
                    <ext:Anchor>
                        <ext:MultiField ID="TxtAddDays" runat="server" FieldLabel="Months / Days / Hours">
                            <Fields>
                                <ext:ComboBox runat="server" ID="CmbBeforeAfter" Width="50">
                                    <Items>
                                        <ext:ListItem Text="After" Value="0" />
                                        <ext:ListItem Text="Before" Value="1" />
                                    </Items>
                                </ext:ComboBox>
                                <ext:NumberField ID="nmbrMonth" runat="server" Width="25" />
                                <ext:Label Text="M" runat="server" Cls="LabelMidle">
                                </ext:Label>
                                <ext:NumberField ID="nmbrDays" runat="server" Width="25" />
                                <ext:Label Text="D" runat="server" Cls="LabelMidle">
                                </ext:Label>
                                <ext:NumberField ID="nmbrHours" runat="server" Width="25" />
                                <ext:Label Text="H" runat="server" Cls="LabelMidle">
                                </ext:Label>
                            </Fields>
                        </ext:MultiField>
                    </ext:Anchor>
                </ext:FormLayout>
            </Body>
        </ext:Panel>
    </Body>
</ext:FormPanel>
<ext:TreePanel ID="TreeDynamic" runat="server" AutoHeight="true" Border="false" ContextMenuID="mnuDynamicBuilder">
    <TopBar>
        <ext:Toolbar runat="server">
            <Items>
                <ext:Button Text="Add" Icon="Add" runat="server">
                    <Listeners>
                        <Click Handler="AddDynamicValue(#{TreeDynamic})" />
                    </Listeners>
                </ext:Button>
            </Items>
        </ext:Toolbar>
    </TopBar>
    <Loader>
        <ext:PageTreeLoader OnNodeLoad="NodeLoad">
            <BaseParams>
                <ext:Parameter Name="ObjectId" Value="GetObjectId(node)" Mode="Raw" />
                <ext:Parameter Name="ActiveAttributeId" Value="GetAttributeId(node)" Mode="Raw" />
                <ext:Parameter Name="AttributePath" Value="GetAttributePath(node)" Mode="Raw" />
                <ext:Parameter Name="ParentName" Value="GetParentName(node)" Mode="Raw" />
            </BaseParams>
            <EventMask ShowMask="true" />
        </ext:PageTreeLoader>
    </Loader>
    <Root>
    </Root>
    <%--    <Listeners>
        <DblClick Fn="SelectedNodeDblClick" />
    </Listeners>
    --%></ext:TreePanel>
<script language="javascript">
    function GetObjectId(e) {
        return e.attributes.TargetObjectId;
    }
    function GetAttributeId(e) {
        return GetComboAttributeId();
    }
    function GetAttributePath(e) {
        return e.attributes.AttributePath;
    }
    function GetParentName(e) {
        return e.attributes.ParentName;
    }
</script>
