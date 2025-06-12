<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Sender_SenderSegmentation" Codebehind="SenderSegmentation.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
    <rx:KeyMap runat="server" ID="KeyMap1">
        <rx:KeyBinding>
            <Keys>
                <rx:Key Code="F9">
                    <Listeners>
                        <Event Handler="ToolbarButtonFind.click(e);" />
                    </Listeners>
                </rx:Key>
            </Keys>
        </rx:KeyBinding>
    </rx:KeyMap>
    <rx:KeyMap runat="server" ID="KeyMap2">
        <rx:KeyBinding Ctrl="true">
            <Keys>
                <rx:Key Code="F9">
                    <Listeners>
                        <Event Handler="ToolbarButtonClear.click(e);" />
                    </Listeners>
                </rx:Key>
            </Keys>
        </rx:KeyBinding>
    </rx:KeyMap>
    <rx:Hidden ID="hdnViewList" runat="server">
    </rx:Hidden>
    <rx:Hidden ID="hdnViewListTotal" runat="server">
    </rx:Hidden>
    <rx:Hidden ID="hdnViewDefaultEditPage" runat="server">
    </rx:Hidden>
    <rx:Hidden ID="nHdnSelectedRowId" runat="server">
    </rx:Hidden>
    <rx:RegisterResources runat="server" ID="RR" />
    <table style="width: 100%">
        <tr>
            <td>
                <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="30" AutoWidth="true"
                    Border="true" Frame="true" Title="CRM.NEW_SENDERSEGMENTATIONUPDATE_SEARCH">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="30%">
                            <Rows>
                                <rx:RowLayout ID="RowLayout1" runat="server">
                                    <Body>
                                        <cc1:CrmComboComp ID="new_SenderId" runat="server" ObjectId="201200021" UniqueName="new_SenderId"
                                            FieldLabelWidth="100" Width="130" PageSize="50">
                                        </cc1:CrmComboComp>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="30%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout4">
                                    <Body>
                                        <cc1:CrmComboComp runat="server" ID="new_SenderSegmentationId" ObjectId="201200021"
                                            UniqueName="new_SenderSegmentationId" FieldLabelWidth="100" Width="130" PageSize="50">
                                        </cc1:CrmComboComp>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="30%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout2">
                                    <Body>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_SenderNumber" ObjectId="201200021" UniqueName="new_SenderNumber"
                                            FieldLabelWidth="100" Width="130" PageSize="50">
                                        </cc1:CrmTextFieldComp>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                    <Buttons>
                        <rx:Button runat="server" ID="ToolbarButtonFind" Text="(F9)" Icon="MagnifierZoomIn"
                            Width="100">
                            <Listeners>
                                <Click Handler="GridPanelMonitoring.reload();" />
                            </Listeners>
                        </rx:Button>
                        <rx:Button runat="server" ID="ToolbarButtonClear" Text="(Ctrl+F9)" Icon="Erase">
                            <Listeners>
                                <Click Handler="ToolbarButtonClearOnClik();" />
                            </Listeners>
                        </rx:Button>
                    </Buttons>
                </rx:PanelX>
            </td>
        </tr>
    </table>
    <rx:GridPanel runat="server" ID="GridPanelMonitoring" AutoWidth="true" AutoHeight="Auto"
        Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
        <Tools>
            <Items>
                <rx:ToolButton runat="server" ID="ToolButton1" ToolTypeIcon="Maximize">
                    <Listeners>
                        <Click Handler="GridPanelMonitoring.fullScreen();" />
                    </Listeners>
                </rx:ToolButton>
            </Items>
        </Tools>
        <DataContainer>
            <DataSource OnEvent="ToolbarButtonFindClick">
            </DataSource>
            <Parameters>
                <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                <rx:Parameter Name="limit" Value="20" Mode="Value"></rx:Parameter>
            </Parameters>
        </DataContainer>
        <SelectionModel>
            <rx:RowSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server" ShowNumber="true"
                SingleSelect="true">
                <Listeners>
                    <RowDblClick Handler="OpenEditWindow(GridPanelMonitoring.selectedRecord.ID,GridPanelMonitoring.selectedRecord.new_SenderId,GridPanelMonitoring.selectedRecord.new_SenderSegmentationId)" />
                </Listeners>
            </rx:RowSelectionModel>
        </SelectionModel>
        <BottomBar>
            <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelMonitoring">
                <Buttons>
                    <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload">
                        <AjaxEvents>
                            <Click OnEvent="ToolbarButtonFindClick">
                                <EventMask ShowMask="false" />
                                <ExtraParams>
                                    <rx:Parameter Name="Excel" Value="1" Mode="Value" />
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </rx:SmallButton>
                    <rx:SmallButton ID="BtnSb1" Icon="DatabaseAdd" Text="CRM.NEW_SENDERSEGMENTATIONUPDATE_FILE_UPLOAD">
                        <Listeners>
                            <Click Handler="windowImport.show();" />
                        </Listeners>
                    </rx:SmallButton>
                </Buttons>
            </rx:PagingToolBar>
        </BottomBar>
        <LoadMask ShowMask="true" />
    </rx:GridPanel>
    <rx:Window ID="WindowEdit" runat="server" Width="500" Height="150" Modal="true" Closable="true"
        Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false" Title="Edit">
        <Body>
            <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="80" AutoWidth="true"
                Border="true" Frame="true">
                <Body>
                    <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="100%">
                        <Rows>
                            <rx:RowLayout ID="RowLayout3" runat="server">
                                <Body>
                                    <cc1:CrmComboComp ID="nSender" runat="server" ObjectId="201200021" UniqueName="new_SenderId"
                                        FieldLabelWidth="100" Width="130" PageSize="50" ReadOnly="true">
                                    </cc1:CrmComboComp>
                                    <cc1:CrmComboComp runat="server" ID="nSenderSegmentationId" ObjectId="201200021"
                                        UniqueName="new_SenderSegmentationId" FieldLabelWidth="100" Width="130" PageSize="50">
                                    </cc1:CrmComboComp>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                </Body>
                <Buttons>
                    <rx:Button ID="btnSave" Text="BTN UPDATE " runat="server" Icon="Disk">
                        <AjaxEvents>
                            <Click OnEvent="btnUpdateClick" Success="WindowEdit.hide();">
                            </Click>
                        </AjaxEvents>
                    </rx:Button>
                </Buttons>
            </rx:PanelX>
        </Body>
    </rx:Window>
    <rx:Window ID="windowImport" runat="server" Width="500" Height="100" Modal="true"
        Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false"
        Title="Import">
        <Body>
            <rx:PanelX runat="server" ID="PanelX2" AutoHeight="Normal" Height="30" AutoWidth="true"
                Border="true" Frame="true">
                <Body>
                    <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="100%">
                        <Rows>
                            <rx:RowLayout ID="RowLayout5" runat="server">
                                <Body>
                                    <rx:FileUpload runat="server" ID="ExcelFileUpload" FieldLabel="TEST" AlwaysUpload="true">
                                    </rx:FileUpload>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                </Body>
            </rx:PanelX>
        </Body>
        <Buttons>
            <rx:Button Download="true" Icon="DiskDownload" ID="ButtonTemplate" Text="TEMPLATE">
                <Listeners>
                    <Click Handler="location='ImportSegmentTemplate.xls'" />
                </Listeners>
            </rx:Button>
            <rx:Button ID="btnUpload" Text="BTN UPDATE " Icon="DiskUpload">
                <AjaxEvents>
                    <Click OnEvent="btnUploadClick" Success="windowImport.hide();">
                    </Click>
                </AjaxEvents>
            </rx:Button>
        </Buttons>
    </rx:Window>
    </form>
</body>
</html>
<script language="javascript">
    function OpenEditWindow(Id, SenderId, SenderSegmentationId) {
        WindowEdit.show();
        nSender.setValue(SenderId);
        nHdnSelectedRowId.setValue(Id);
        nSenderSegmentationId.setValue(SenderSegmentationId);
    }
</script>
