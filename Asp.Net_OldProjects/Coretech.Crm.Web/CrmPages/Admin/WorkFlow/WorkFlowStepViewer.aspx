<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_WorkFlow_WorkFlowStepViewer" ValidateRequest="false" Codebehind="WorkFlowStepViewer.aspx.cs" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork"
    TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <rx:Hidden ID="hdnViewList" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnWorkFlowId" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnWorkFlowDefaultEditPage" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnRecordId" runat="server">
        </rx:Hidden>

        <rx:RegisterResources runat="server" ID="RR"/>
        <rx:PanelX runat="server" ID="pnl1" AutoWidth="true" AutoHeight="Auto">
            <Body>
                <rx:ColumnLayout runat="server" ID="cl1">
                    <Rows>
                        <rx:RowLayout runat="server" ID="rl1">
                            <Body>
                                <rx:GridPanel runat="server" ID="GridPanelWorkFlowViewer" AutoWidth="true" AutoHeight="Auto"
                                Editable="false" Mode="Remote" AutoLoad="true">
                                    <Tools>
                                        <Items>
                                            <rx:ToolButton runat="server" ID="ToolButton1" ToolTypeIcon="Maximize">
                                                <Listeners>
                                                    <Click Handler="GridPanelWorkFlowViewer.fullScreen();" />
                                                </Listeners>
                                            </rx:ToolButton>
                                        </Items>
                                    </Tools>
                                    <DataContainer>
                                        <Parameters>
                                            <rx:Parameter Name="start" Value="0" Mode="Value"></rx:Parameter>
                                            <rx:Parameter Name="limit" Value="20" Mode="Value"></rx:Parameter>
                                            <rx:Parameter Name="viewqueryid" Value="hdnViewList.getValue()" Mode="Raw"></rx:Parameter>
                                            <rx:Parameter Name="query" Value="" Mode="Value"></rx:Parameter>
                                            <rx:Parameter Name="feachxml" Value="getLookupXml()" Mode="Raw"></rx:Parameter>
                                        </Parameters>
                                    </DataContainer>
                                    <SelectionModel>
                                        <rx:RowSelectionModel ID="GridPanelWorkFlowViewerRowSelectionModel1" runat="server">
                                            <Listeners>
                                                
                                                <RowDblClick Handler="ShowEditWindow(GridPanelWorkFlowViewer.id,GridPanelWorkFlowViewer.selectedRecord.ID,hdnWorkFlowDefaultEditPage.getValue(),'12');" />
                                            </Listeners>
                                        </rx:RowSelectionModel>
                                    </SelectionModel>
                                    <BottomBar>
                                        <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelWorkFlowViewer">
                                        </rx:PagingToolBar>
                                    </BottomBar>
                                    <LoadMask ShowMask="true" />
                                </rx:GridPanel>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
    </div>
    </form>
</body>
</html>
<script language="javascript">
    var farrItem = new Array();
    function getLookupXml() {
        farrItem[0] = { AttributeIdName: 'hdnRecordId', ToAttributeId: '56450B40-AF71-4EBE-BC1A-66C92CB250FA' }
        return CreateLookupXml(12, '', '', hdnRecordId, window, farrItem);
    }
</script>