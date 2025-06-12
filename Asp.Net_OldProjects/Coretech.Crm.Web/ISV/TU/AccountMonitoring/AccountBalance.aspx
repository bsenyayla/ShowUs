<%@ Page Language="C#" AutoEventWireup="true" Inherits="AccountMonitoring_AccountBalance" ValidateRequest="false" Codebehind="AccountBalance.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:PanelX ID="PanelX1" runat="server" AutoWidth="true" AutoHeight="Normal" Height="250"
            Padding="true">
            <Body>
            <rx:GridPanel runat="server" ID="GridPanelMainAccount" AutoWidth="true" Editable="false" Mode="Remote" AutoLoad="True" AjaxPostable="False">
            <DataContainer>
                <DataSource OnEvent="GridPanelMainAccountOnEvent">
                </DataSource>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="GridPanelPaymentsRowSelectionModel1" runat="server" ShowNumber="true">
                </rx:RowSelectionModel>
            </SelectionModel>
            <ColumnModel>
                <Columns>
                    <rx:GridColumns Header="Account No" ColumnId="0" DataIndex="AccountNumber" Align="Left" Width="70"></rx:GridColumns>
                    <rx:GridColumns Header="Account Name" ColumnId="1" DataIndex="AccountName" Align="Left" Width="200"></rx:GridColumns>
                    <rx:GridColumns Header="AccountType" ColumnId="2" DataIndex="AccountType" Align="Left" Width="100"></rx:GridColumns>
                    <rx:GridColumns Header="Currency" ColumnId="3" DataIndex="Currency" Align="Left" Width="100"></rx:GridColumns>
                    <rx:GridColumns Header="Current Balance" ColumnId="4" DataIndex="CurrentBalance" Align="Left" Width="100"></rx:GridColumns>
                    <rx:GridColumns Header="Blocked Balance" ColumnId="5" DataIndex="BlockedBalance" Align="Left" Width="100"></rx:GridColumns>
                    <rx:GridColumns Header="Available Balance" ColumnId="6" DataIndex="AvailableBalance" Align="Left" Width="100"></rx:GridColumns>
                    
                </Columns>
            </ColumnModel>
            <BottomBar>
                <rx:PagingToolBar ID="PagingToolBar1" runat="server" ControlId="GridPanelMainAccount">
                </rx:PagingToolBar>
            </BottomBar>
        </rx:GridPanel>
            </Body>
        </rx:PanelX>
    </form>
</body>
</html>
