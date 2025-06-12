<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Administrations_User_OnlineUserList" Codebehind="OnlineUserList.aspx.cs" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
       
</head>
<body>
    
    <form id="form1" runat="server">
        <div style="display: none">
        <rx:Hidden runat="server" ID="hdnObjectId">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnRecid">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnDefaultEditPage">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnViewQueryId">
        </rx:Hidden>
    </div>
         <rx:RegisterResources runat="server" ID="RR"/>
    <rx:KeyMap runat="server" ID="KeyMap1">
        <rx:KeyBinding>
            <Keys>
                <rx:Key Code="F9">
                    <Listeners>
                        <Event Handler="GridPanelMonitoring.reload();" />
                    </Listeners>
                </rx:Key>
            </Keys>
        </rx:KeyBinding>
    </rx:KeyMap>
   <rx:GridPanel runat="server" ID="GridPanelMonitoring" AutoWidth="true" AutoHeight="Auto"
        Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
        <DataContainer>
            <DataSource OnEvent="ToolbarButtonFindClick">
            </DataSource>
            <Parameters>
                <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
            </Parameters>
        </DataContainer>
        <SelectionModel>
            <rx:RowSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server"
                ShowNumber="true">
                <Listeners>
                    
                    <RowDblClick Handler="ShowEditWindow(GridPanelMonitoring.id,GridPanelMonitoring.selectedRecord.ID,'','1');" />
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
                </Buttons>
            </rx:PagingToolBar>
        </BottomBar>
        <LoadMask ShowMask="true" />
    </rx:GridPanel>
    </form>
</body>
</html>
