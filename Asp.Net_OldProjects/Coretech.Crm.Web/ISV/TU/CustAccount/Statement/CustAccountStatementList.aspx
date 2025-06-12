<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_Statement_CustAccountStatementList" Codebehind="CustAccountStatementList.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:PanelX ID="SearchPanel" runat="server" AutoHeight="Normal" Height="80" Title="Gelişmiş Sorgulama" ContainerPadding="true" Collapsible="true" Collapsed="true">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout101" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountTypeId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountTypeId" RequirementLevel="BusinessRecommend"
                                    FieldLabelWidth="100" Width="200" PageSize="50">
                                    <Listeners>
                                        <Change Handler="new_CustAccountTypeId_Change();"></Change>
                                    </Listeners>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="R1" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_SenderId" runat="server" ObjectId="201500039" UniqueName="new_SenderId"
                                    FieldLabelWidth="100" Width="200" PageSize="50" FieldLabelShow="True" RequirementLevel="BusinessRecommend">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201500039" FromUniqueName="new_CustAccountTypeId" ToObjectId="201100052" ToUniqueName="new_CustAccountTypeId" />
                                    </Filters>
                                    <AjaxEvents>
                                        <Change OnEvent="new_SenderId_OnChange">
                                        </Change>
                                    </AjaxEvents>
                                    <Listeners>
                                        <Change Handler="new_SenderId_Change();"></Change>
                                    </Listeners>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountId" RequirementLevel="BusinessRecommend"
                                    FieldLabelWidth="100" Width="200" PageSize="50" FieldLabelShow="true">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201500039" FromUniqueName="new_SenderId" ToObjectId="201500042" ToUniqueName="new_SenderId" />
                                    </Filters>
                                    <AjaxEvents>
                                        <Change OnEvent="new_CustAccountId_OnChange">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout4" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <rx:MultiField ID="mfStatementDate" runat="server">
                                    <Items>
                                        <cc1:CrmDateFieldComp ID="cmbStatementDateStart" runat="server" ObjectId="201600005"
                                            UniqueName="CreatedOn" FieldLabelShow="false" Width="100">
                                        </cc1:CrmDateFieldComp>
                                        <rx:Label runat="server" Text="  " ID="lbl1" Width="10">
                                        </rx:Label>
                                        <cc1:CrmDateFieldComp ID="cmbStatementDateEnd" runat="server" ObjectId="201600005"
                                            FieldLabelShow="false" UniqueName="CreatedOn" FieldLabelWidth="100"
                                            Width="100">
                                        </cc1:CrmDateFieldComp>
                                    </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="ToolbarButtonFind" Icon="Magnifier">
                    <Listeners>
                        <Click Handler="ExtractList.reload();return false;" />
                    </Listeners>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
        <rx:GridPanel runat="server" ID="ExtractList" AutoWidth="true" AutoHeight="Auto" PostAllData="true"
            Height="150" Editable="false" Mode="Remote" AutoLoad="true" Width="1500" AjaxPostable="true" Title="Ekstre Listesi">
            <TopBar>
                <rx:ToolBar ID="pnl1toolbar" runat="server">
                    <Items>
                        <rx:ToolbarButton ID="btnNew" runat="server" Icon="Add" Text="Yeni">
                            <Listeners>
                                <Click Handler="StatementPopup();" />
                            </Listeners>
                        </rx:ToolbarButton>
                        <rx:ToolbarFill ID="tbf" runat="server">
                        </rx:ToolbarFill>
                        <rx:ToolbarButton ID="btnDownloadFile" runat="server" Icon="Attach" Text="Dosya İndir" Download="true">
                            <AjaxEvents>
                                <Click OnEvent="FileDownloadEvent_Click">
                                    <EventMask ShowMask="false" />
                                </Click>
                            </AjaxEvents>
                        </rx:ToolbarButton>
                    </Items>
                </rx:ToolBar>
            </TopBar>
            <Tools>
                <Items>
                    <rx:ToolButton runat="server" ID="ToolButton1" ToolTypeIcon="Maximize">
                        <Listeners>
                            <Click Handler="ExtractList.fullScreen();" />
                        </Listeners>
                    </rx:ToolButton>
                </Items>
            </Tools>
            <SelectionModel>
                <rx:RowSelectionModel ID="ExtractListRowSelectionModel1" runat="server" ShowNumber="false">
                </rx:RowSelectionModel>
            </SelectionModel>
            <DataContainer>
                <DataSource OnEvent="ExtractListOnDataList">
                </DataSource>
                <Parameters>
                    <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                    <rx:Parameter Name="limit" Value="25" Mode="Value"></rx:Parameter>
                </Parameters>
            </DataContainer>
            <BottomBar>
                <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="ExtractList">
                    <Buttons>
                        <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload">
                            <AjaxEvents>
                                <Click OnEvent="ExtractListOnDataList">
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
<script>
    function new_CustAccountTypeId_Change() {
        new_SenderId.clear();
        //new_SenderId.change();
        new_CustAccountId.clear();
    }
    function new_SenderId_Change() {
        new_CustAccountId.clear();
    }
    function StatementPopup() {
        window.top.newWindowRefleX(window.top.GetWebAppRoot + '/ISV/TU/CustAccount/Statement/CustAccountStatement.aspx', { maximized: false, width: 1000, height: 400, resizable: true, modal: true, maximizable: false });
    }
</script>
