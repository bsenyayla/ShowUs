<%@ Page Language="C#" AutoEventWireup="true" Inherits="Payment_WelcomePayment" CodeBehind="WelcomePayment.aspx.cs" %>

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
        .trgclear {
            margin: 1px -5px 0 !important;
        }

            .trgclear span {
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
        <rx:Hidden ID="hdnEntityId" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnRecid" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnTransferId" runat="server" />
        <rx:Hidden ID="hdnPaymentId" runat="server" />
        <rx:Hidden ID="hdnrefundPaymentId" runat="server" />
        <rx:Hidden ID="new_IsUsedSecurityQuestion" runat="server" />
        <rx:Hidden ID="hdnViewList" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnViewDefaultEditPage" runat="server">
        </rx:Hidden>
        <rx:RegisterResources runat="server" ID="RR" />
        <table style="width: 100%">
            <tr>
                <td>
                    <rx:PanelX runat="server" ID="pnlSEARCHGeneral" AutoHeight="Normal" Height="86" AutoWidth="true"
                        Border="false" Title="SEARCH">
                        <Body>
                            <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="40%" ColumnLayoutLabelWidth="40">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout2" runat="server">
                                        <Body>
                                          &nbsp;
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout ID="RowLayout1" runat="server">
                                        <Body>
                                            <cc1:CrmTextFieldComp ID="new_RefNumber" runat="server" ObjectId="201100096" UniqueName="new_RefNumber"
                                                FieldLabelWidth="10" Width="100" CaseType="UpperCase" RequirementLevel="BusinessRecommend">
                                            </cc1:CrmTextFieldComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout ID="RowLayout3" runat="server">
                                        <Body>
                                          &nbsp;
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout runat="server" ID="ColoumnLayout2" ColumnWidth="40%">
                                <%-- <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout4">
                                        <Body>
                                            <cc1:CrmTextFieldComp ID="new_Name" runat="server" ObjectId="201100096" UniqueName="new_Name"
                                                Value="" FieldLabelWidth="100" Width="130" CaseType="UpperCase" RequirementLevel="BusinessRecommend">
                                            </cc1:CrmTextFieldComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout">
                                        <Body>
                                            <cc1:CrmTextFieldComp ID="new_MiddleName" runat="server" ObjectId="201100096" UniqueName="new_MiddleName"
                                                Value="" FieldLabelWidth="100" Width="130" CaseType="UpperCase" RequirementLevel="BusinessRecommend">
                                            </cc1:CrmTextFieldComp>
                                        </Body>
                                    </rx:RowLayout>

                                    <rx:RowLayout runat="server" ID="RowLayout3">
                                        <Body>
                                            <cc1:CrmTextFieldComp ID="new_LastName" runat="server" ObjectId="201100096" UniqueName="new_LastName"
                                                Value="" FieldLabelWidth="100" Width="130" CaseType="UpperCase" RequirementLevel="BusinessRecommend">
                                            </cc1:CrmTextFieldComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout2">
                                        <Body>
                                            <cc1:CrmComboComp ID="new_SenderCountry" runat="server" ObjectId="201100096" UniqueName="new_SenderCountry"
                                                Value="" FieldLabelWidth="100" Width="130" LookupViewUniqueName="COUNTRY_LOOKUP"
                                                RequirementLevel="BusinessRecommend">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>--%>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="20%">
                                <%--<Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout5">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_SenderId" ObjectId="201100096" UniqueName="new_SenderId"
                                                Width="150" PageSize="50" FieldLabel="150" LookupViewUniqueName="FINDE_SENDER_LOOKUP"
                                                ComboSearchCharCount="5">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>--%>
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
                                    <rx:ToolbarButton runat="server" ID="ToolbarButtonClear" Text="Temizle (Ctrl+F9) LBL "
                                        Icon="UserCross">
                                        <Listeners>
                                            <Click Handler="ToolbarButtonClearOnClik();" />
                                        </Listeners>
                                    </rx:ToolbarButton>
                                    <rx:ToolbarButton runat="server" ID="ToolbarButtonCheck" Text="Kurum Havuzunda Ara" Icon="User"
                                        Width="100">
                                        <AjaxEvents>
                                            <Click OnEvent="ToolbarButtonCheckOnClick" />
                                        </AjaxEvents>
                                    </rx:ToolbarButton>
                                    <rx:ToolbarButton runat="server" ID="ToolbarButtonLog" Text="(F9)" Icon="Book"
                                        Width="100">
                                        <Listeners>
                                            <Click Handler="LogWindow();" />
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
                    <Listeners>
                        <RowClick Handler="hdnTransferId.setValue(GridPanelPayments.selectedRecord.ID);"></RowClick>
                    </Listeners>
                    <AjaxEvents>
                        <RowDblClick OnEvent="RowDblClickOnEvent">
                        </RowDblClick>
                    </AjaxEvents>
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
