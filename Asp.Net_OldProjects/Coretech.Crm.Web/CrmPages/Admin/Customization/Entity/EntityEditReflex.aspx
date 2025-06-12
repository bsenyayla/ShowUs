<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Entity_EntityEditReflex" Codebehind="EntityEditReflex.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">

    <div>
    
        <ext:Hidden ID="hdnObjectId" runat="server">
        </ext:Hidden>
        <ext:ViewPort ID="ViewPort1" runat="server">
            <Body>
                <ext:FitLayout ID="FitLayout1" runat="server">
                    <Items>
                        <ext:Panel ID="Window1" runat="server" Border="false" Closable="false" Plain="true">
                            <TopBar>
                                <ext:Toolbar ID="Toolbar1" runat="server">
                                    <Items>
                                        <ext:Button ID="Button1" runat="server" Text="Actions">
                                            <Menu>
                                                <ext:Menu runat="server" ID="New_menu" AllowOtherMenus="true">
                                                    <Items>
                                                        <ext:MenuItem ID="mnPublish" runat="server" Text="Publish">
                                                            <AjaxEvents>
                                                                <Click OnEvent="mnPublish_OnClikc">
                                                                    <EventMask ShowMask="true" />
                                                                </Click>
                                                            </AjaxEvents>
                                                        </ext:MenuItem>
                                                    </Items>
                                                </ext:Menu>
                                            </Menu>
                                        </ext:Button>
                                    </Items>
                                </ext:Toolbar>
                            </TopBar>
                            <Body>
                                <ext:BorderLayout ID="BorderLayout1" runat="server">
                                    <West Collapsible="true" MinWidth="175" Split="true">
                                        <ext:Panel ID="Panel1" runat="server" Width="175" CtCls="west-panel" Collapsed="false">
                                            <Body>
                                                <ext:FitLayout runat="server" ID="F1">
                                                    <ext:MenuPanel ID="MenuPanel1" runat="server" Title="Özellikler" SaveSelection="false">
                                                        <Menu runat="server">
                                                            <Items>
                                                                <ext:MenuItem ID="LeftCommandItem1" runat="server" Text="Genel Özellikler" Icon="Application">
                                                                    <Listeners>
                                                                        <Click Handler="Navigate(1,this)" />
                                                                        <Show Handler="Navigate(1,this)" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <ext:MenuItem ID="LeftCommandItem2" runat="server" Text="Formlar" Icon="ApplicationForm">
                                                                    <Listeners>
                                                                        <Click Handler="Navigate(2,this)" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <ext:MenuItem ID="LeftCommandItem3" runat="server" Text="Ön Görünümler" Icon="ApplicationViewList">
                                                                    <Listeners>
                                                                        <Click Handler="Navigate(3,this)" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <ext:MenuItem ID="LeftCommandItem4" runat="server" Text="Alanlar" Icon="ApplicationFormEdit">
                                                                    <Listeners>
                                                                        <Click Handler="Navigate(4,this)" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <ext:MenuItem ID="LeftCommandItem5" runat="server" Text="N:1 İlişkiler" Icon="ChartOrganisation">
                                                                    <Listeners>
                                                                        <Click Handler="Navigate(5,this)" />
                                                                    </Listeners>
                                                                </ext:MenuItem>
                                                                <%--<ext:MenuItem ID="LeftCommandItem6" runat="server" Text="N:1 İlişkiler" Icon="ChartOrgInverted">
                                                                    <Listeners>
                                                                        <Click Handler="Navigate(6,this)" />
                                                                    </Listeners>
                                                                </ext:MenuItem>--%>
                                                                <ext:MenuItem ID="LeftCommandItem7" runat="server" Text="N:N İlişkiler" Icon="ChartLineLink">
                                                                    <Listeners>
                                                                        <Click Handler="Navigate(7,this)" />
                                                                    </Listeners>
                                                                </ext:MenuItem>

                                                            </Items>
                                                        </Menu>
                                                    </ext:MenuPanel>
                                                </ext:FitLayout>
                                            </Body>
                                        </ext:Panel>
                                    </West>
                                    <Center>
                                        <ext:Panel ID="Panel2" runat="server" Title="Genel Özellikler">
                                            <AutoLoad Mode="IFrame" ShowMask="true"/>
                                        </ext:Panel>
                                    </Center>
                                </ext:BorderLayout>
                            </Body>
                        </ext:Panel>
                    </Items>
                </ext:FitLayout>
            </Body>
        </ext:ViewPort>
    </div>
    </form>
</body>
</html>
<script>
    function Navigate(action, value) {

        if (value != "") {
            Panel2.setTitle(value.text);
            var ObjectId = "&ObjectId=" + hdnObjectId.value;
            switch (action) {
                case 1: url = "Property/EntityProperty.aspx?Time=" + Date();
                    break;
                case 2: url = "Property/FormListReflex.aspx?Time=" + Date();
                    break;
                case 3: url = "Property/UiElementsReflex.aspx?Time=" + Date();
                    break;
                case 4: url = "Property/AttributeListReflex.aspx?Time=" + Date();
                    break;
                case 5: url = "Property/RelationshipList.aspx?Time=" + Date() + "&reelationType=0";
                    break;
                case 6: url = "Property/RelationshipList.aspx?Time=" + Date() + "&reelationType=1";
                    break;
                case 7: url = "Property/RelationshipN2N.aspx?Time=" + Date() + "&reelationType=2";
                    break;
              

            }
            Panel2.load(url + ObjectId);
        }
    }

</script>
