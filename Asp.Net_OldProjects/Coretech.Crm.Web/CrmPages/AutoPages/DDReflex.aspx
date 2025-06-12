<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_DDReflex" Codebehind="DDReflex.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript" src="../../js/DuplicateDetection.js"></script>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:Hidden ID="duplicateDetectionRuleId" runat="server">
    </rx:Hidden>
    <rx:Hidden ID="duplicateDetectionResultId" runat="server">
    </rx:Hidden>
    <rx:Hidden ID="ParentAction" runat="server">
    </rx:Hidden>
    <rx:GridPanel runat="server" ID="GridPanelMonitoring" AutoWidth="true" AutoHeight="Auto"
         Height="150" Editable="false" Mode="Remote" Title="..." AutoLoad="true" Width="1200"
        AjaxPostable="true">
       <%-- <TopBar>
            <rx:ToolBar runat="server" ID="toolbar1">
                <Items>
                    <rx:Label runat="server" ID="GridPanelMonitoringLabel">
                    </rx:Label>
                </Items>
            </rx:ToolBar>
        </TopBar>--%>
        <%--<Tools>
            <Items>
                <rx:ToolButton runat="server" ID="ToolButton1" ToolTypeIcon="Maximize">
                    <Listeners>
                        <Click Handler="GridPanelMonitoring.fullScreen();" />
                    </Listeners>
                </rx:ToolButton>
            </Items>
        </Tools>--%>
        <DataContainer>
            <DataSource OnEvent="ToolbarButtonFindClick">
            </DataSource>
            <Parameters>
                <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
            </Parameters>
        </DataContainer>
        <SelectionModel>
            <rx:RowSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server" ShowNumber="true"
                SingleSelect="true">
            </rx:RowSelectionModel>
        </SelectionModel>
        <BottomBar>
            <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelMonitoring">
                <Buttons>
                    <rx:SmallButton ID="btnSaveNewRecord" Icon="Add" Text="CRM_DD_CONTINUE_SAVERECORD">
                        <Listeners>
                            <Click Handler="btnSaveNewRecord_Click();" />
                        </Listeners>
                    </rx:SmallButton>
                    <rx:SmallButton ID="btnSaveSelectedRecord" Icon="Disk" Text="CRM_DD_UPDATE_SELECTED_RECORD">
                        <Listeners>
                            <Click Handler="btnSaveSelectedRecord_Click();" />
                        </Listeners>
                    </rx:SmallButton>
                </Buttons>
            </rx:PagingToolBar>
        </BottomBar>
        <LoadMask ShowMask="true" />
    </rx:GridPanel>
    </form>
</body>
</html>
