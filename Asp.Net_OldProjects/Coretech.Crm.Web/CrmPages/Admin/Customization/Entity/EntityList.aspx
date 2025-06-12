<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Entity_EntityList" Codebehind="EntityList.aspx.cs" %>

<%@ Register Assembly="Coretech.Crm.Web.UI" Namespace="Coretech.Crm.Web.UI.ExtPlugin"
    TagPrefix="plg" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script type="text/javascript">
        function NewWindow() {
            var config = GetWebAppRoot+"/CrmPages/Admin/Customization/Entity/EntityEditReflex.aspx?ObjectId=";
            window.top.newWindowRefleX(config, { title: 'EntityEdit', width: 740, height: 500, resizable: true });
        }
        function ShowWindow() {
            if (!R.isEmpty(TreeGridEntity.selectedNode) && TreeGridEntity.selectedNode[0].Value != "0") {
                PnlOp.load(GetWebAppRoot + "/CrmPages/Admin/Customization/Entity/EntityEditReflex.aspx?ObjectId=" + TreeGridEntity.selectedNode[0].Value);
            }
        }
        var template = function (value, metadata, record, rowIndex, colIndex, store) {
            return String.format(
                '<b><a href="EntityAttribute.aspx?ObjectId={1}" target="_blank">{0}</a></b>',
                record.data.Label, record.data.ObjectId);
        };
        //        function initialCap() {
        //            FilterText.setValue(FilterText.getValue().toCapitalFirstLetter());
        //        }

        function Navigate() {
            var url = "";
            if (!R.isEmpty(TreeGridEntity.selectedNode) && TreeGridEntity.selectedNode[0].Value != "0") {
                var nodeType = TreeGridEntity.selectedNode[2].Value
                if (nodeType == 1 || nodeType == 2 || nodeType == 3 || nodeType == 4 || nodeType == 5 || nodeType == 6 || nodeType == 7 || nodeType == 8 || nodeType == 9) {
                    PnlOp.setTitle(TreeGridEntity.selectedNode[1].Value);
                    var ObjectId = "&ObjectId=" + TreeGridEntity.selectedNode[0].Value;
                    switch (nodeType) {
                        case "1": url = "Property/EntityPropertyReflex.aspx?Time=" + Date();
                            break;
                        case "2": url = "Property/EntityPropertyReflex.aspx?Time=" + Date();
                            break;
                        case "4": url = "Property/FormListReflex.aspx?Time=" + Date();
                            break;
                        case "3": url = "Property/UiElementsReflex.aspx?Time=" + Date();
                            break;
                        case "9": url = "Property/AttributeListReflex.aspx?Time=" + Date();
                            break;
                        case "6": url = "Property/AttributeListReflex.aspx?Time=" + Date();
                            break;
                        case "7": url = "Property/RelationshipListReflex.aspx?Time=" + Date() + "&reelationType=1";
                            break;
                        case "8": url = "Property/RelationshipN2NReflex.aspx?Time=" + Date() + "&reelationType=2";
                            break;
                        case "5": url = "Property/LabelsReflex.aspx?Time=" + Date();
                            break;

                    }
                    PnlOp.load(url + ObjectId);

                }
            }
        }
        function FilterbyText(e) {
            if (e.keyCode == VKeyCode.VK_RETURN) {
                TreeGridEntity.createRoot();
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:Hidden runat="server" ID="hdnRecid">
    </rx:Hidden>
    <rx:Hidden runat="server" ID="hdnObjectId">
    </rx:Hidden>
    <rx:Hidden runat="server" ID="hdnDefaultEditPage">
    </rx:Hidden>
    <rx:Hidden runat="server" ID="hdnViewQueryId">
    </rx:Hidden>
    <rx:PanelX runat="server" ID="pnlMain">
        <Body>
            <rx:ToolBar runat="server" ID="toolbar2">
                <Items>
                    <rx:ToolbarButton ID="btnNew" Icon="Add" Text="Yeni Entity Ekle" runat="server">
                        <Listeners>
                            <Click Handler="NewWindow();" />
                        </Listeners>
                    </rx:ToolbarButton>
                    <rx:ToolbarSeparator ID="ToolbarSeparator1" runat="server" />
                    <rx:TextField ID="FilterText" runat="server" Width="200" EmptyText="--Aranacak Kelimeyi Giriniz--">
                        <Listeners>
                            <KeyUp Handler="FilterbyText(e);" />
                        </Listeners>
                    </rx:TextField>
                    <rx:ToolbarSeparator ID="btnExportSeparator" runat="server" />
                    <rx:ToolbarFill ID="toolbarfill_1" runat="server" />
                    <rx:Button Text="Publish All" runat="server" ID="PublishAll" Icon="ApplicationGo">
                        <AjaxEvents>
                            <Click OnEvent="PublishAll_Click">
                                <EventMask ShowMask="true" />
                            </Click>
                        </AjaxEvents>
                    </rx:Button>
                </Items>
            </rx:ToolBar>
            <rx:ColumnLayout runat="server" ID="c1" ColumnWidth="25%">
                <Rows>
                    <rx:RowLayout ID="RowLayout2" runat="server">
                        <Body>
                            <rx:TreeGrid runat="server" ID="TreeGridEntity" Title=" " Height="200" StickObj="pnlMain"
                                AutoHeight="Auto" Mode="Remote" Checkable="true" AutoWidth="true" Width="300"
                                Collapsible="true">
                                <Columns>
                                    <rx:TreeGridColumn DataIndex="Label" Width="314" Header="Name">
                                    </rx:TreeGridColumn>
                                </Columns>
                                <Root>
                                </Root>
                                <LoadMask ShowMask="true" Msg="Loading Data..." />
                            </rx:TreeGrid>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="75%">
                <Rows>
                    <rx:RowLayout ID="RowLayout1" runat="server">
                        <Body>
                            <rx:PanelX runat="server" ID="PnlOp" Title=" " AutoWidth="true" AutoHeight="Auto"
                                Frame="true">
                                <AutoLoad Url="" ShowMask="true" />
                            </rx:PanelX>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
        </Body>
    </rx:PanelX>
    </form>
</body>
</html>
