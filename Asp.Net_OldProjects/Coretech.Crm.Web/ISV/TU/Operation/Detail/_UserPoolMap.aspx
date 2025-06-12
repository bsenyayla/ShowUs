<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_Detail_UserPoolMap" ValidateRequest="false" Codebehind="_UserPoolMap.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form2" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:GridPanel runat="server" ID="GridPanelMonitoring" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="true" Width="1200" AjaxPostable="true">
            <Tools>
                <Items>
                    <rx:ToolButton runat="server" ID="ToolButton1" ToolTypeIcon="Maximize">
                        <Listeners>
                            <Click Handler="GridPanelMonitoring.fullScreen();" />
                        </Listeners>
                    </rx:ToolButton>
                </Items>
            </Tools>
            <ColumnModel>
                <Columns>
                    <rx:GridColumns ColumnId="AttributeId" Header="AttributeId" ColumnType="Normal" DataIndex="AttributeId" Width="100" Hidden="true"></rx:GridColumns>
                    <rx:GridColumns ColumnId="AttributeName" Header="Alan Adı" ColumnType="Normal" DataIndex="AttributeName" Width="200"></rx:GridColumns>
                    <rx:GridColumns ColumnId="Hide" Header="Gizle" ColumnType="Check" DataIndex="Hide" Editable="true"></rx:GridColumns>
                </Columns>
            </ColumnModel>
            <DataContainer>
                <DataSource OnEvent="ToolbarButtonFindClick">
                </DataSource>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server" ShowNumber="true"
                    SingleSelect="true">
                    <AjaxEvents>
                        <RowClick OnEvent="RowClickOnEvent">
                        </RowClick>
                    </AjaxEvents>
                </rx:RowSelectionModel>
            </SelectionModel>
        </rx:GridPanel>
    </form>
</body>
</html>
