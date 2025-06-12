<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false"
    Inherits="Accounting_OfficeAccounts" Codebehind="OfficeAccounts.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="JS/WelcomePayment.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <style>
        .trgclear
        {
            margin: 1px -5px 0 !important;
        }
        .trgclear span
        {
            cursor: pointer;
            background: url("<%=GlobalConfig.Settings.ResourcePath%>/Themes/Slate/Images/clear-trigger.gif");
            background-repeat: no-repeat;
            background-color: transparent;
            background-position: 0px -1px;
            border: 0 none;
            height: 17px !important;
            margin: 0 !important;
            padding: 0 !important;
            top: 1px !important;
            width: 16px !important;
            z-index: 2;
            border: 0 solid #B5B8C8;
        }
    </style>
</head>
<body style="overflow: auto!important;">
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
        <rx:Hidden ID="hdnViewList" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnViewDefaultEditPage" runat="server">
        </rx:Hidden>
        <rx:RegisterResources runat="server" ID="RR" />
        <table style="width: 100%">
            <tr>
                <td>
                    <rx:PanelX runat="server" ID="pnlSEARCHGeneral" AutoHeight="Normal" Height="26" AutoWidth="true"
                        Border="false" Title="SEARCH">
                        <Body>
                            <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="33%" ColumnLayoutLabelWidth="40">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout11" runat="server">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="New_OfficeId" ObjectId="201100040" UniqueName="New_OfficeId"
                                                Width="150" PageSize="50" FieldLabel="200" RequirementLevel="BusinessRequired" ComboSearchCharCount="3" Mode="Local"
                                                LookupViewUniqueName="OFFICE_LOOKUP2">
                                                <DataContainer>
                                                    <DataSource OnEvent="OfficeLoad">
                                                    </DataSource>
                                                </DataContainer>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                        </Body>
                    </rx:PanelX>
                </td>
            </tr>
            <tr>
                <td>
                    <rx:PanelX ID="PnlSearch" runat="server" AutoHeight="Normal" Frame="false" Border="false"
                        AutoWidth="true" Height="26">
                        <Body>
                            <rx:ToolBar runat="server" ID="ToolBarMain">
                                <Items>
                                    <rx:ToolbarButton runat="server" ID="ToolbarButtonFind" Text="Ara (F9) LBL" Icon="User"
                                        Width="100">
                                        <Listeners>
                                            <Click Handler="GridPanelPayments.reload();" />
                                        </Listeners>
                                    </rx:ToolbarButton>
                                    <rx:ToolbarFill runat="server" ID="tf1">
                                    </rx:ToolbarFill>
                                </Items>
                            </rx:ToolBar>
                        </Body>
                    </rx:PanelX>
                </td>
            </tr>
        </table>
        <rx:GridPanel runat="server" ID="GridPanelPayments" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
            <Tools>
                <Items>
                    <rx:ToolButton runat="server" ID="ToolButton1" ToolTypeIcon="Maximize">
                        <Listeners>
                            <Click Handler="GridPanelPayments.fullScreen();" />
                        </Listeners>
                    </rx:ToolButton>
                </Items>
            </Tools>
            <DataContainer>
                <DataSource OnEvent="BtnAraClick">
                </DataSource>
                <Parameters>
                    <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                    <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                </Parameters>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="GridPanelPaymentsRowSelectionModel1" runat="server" ShowNumber="true">
                </rx:RowSelectionModel>
            </SelectionModel>
            <BottomBar>
                <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelPayments">
                </rx:PagingToolBar>
            </BottomBar>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>
    </form>
</body>
</html>
