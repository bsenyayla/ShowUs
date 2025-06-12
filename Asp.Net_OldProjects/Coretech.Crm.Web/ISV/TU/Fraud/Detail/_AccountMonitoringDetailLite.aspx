<%@ Page Language="C#" AutoEventWireup="true" Inherits="Fraud_Detail_AccountMonitoringDetailLite" Codebehind="_AccountMonitoringDetailLite.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="Js/AccountControl.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
    <rx:Hidden ID="hdnViewList" runat="server">
    </rx:Hidden>
    <rx:Hidden ID="hdnViewDefaultEditPage" runat="server">
    </rx:Hidden>
    <rx:RegisterResources runat="server" ID="RR" />
        <rx:GridPanel runat="server" ID="GridPanelAccountMonitoring" AutoWidth="true" AutoHeight="Auto"
        Height="150" Editable="false" Mode="remote" AutoLoad="false" Width="1200" AjaxPostable="true">
        <DataContainer>
            <DataSource OnEvent="ToolbarButtonFindClick">
            </DataSource>
            <Parameters>
                <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
            </Parameters>
        </DataContainer>
        <Tools>
            <Items>
                <rx:ToolButton runat="server" ID="ToolButton1" ToolTypeIcon="Maximize">
                    <Listeners>
                        <Click Handler="GridPanelAccountMonitoring.fullScreen();" />
                    </Listeners>
                </rx:ToolButton>
            </Items>
        </Tools>
        <SelectionModel>
            <rx:RowSelectionModel ID="GridPanelAccountMonitoringRowSelectionModel1" runat="server" ShowNumber="true">
                
            </rx:RowSelectionModel>
        </SelectionModel>
        <BottomBar>
            <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelAccountMonitoring">
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
<script language="javascript">
    setTimeout(function () {
        GridPanelAccountMonitoring.reload();;
    }, 1000);
</script>
