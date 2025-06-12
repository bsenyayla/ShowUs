<%@ Page Language="C#" AutoEventWireup="true" Inherits="AccountMonitoring_AccountActivity" ValidateRequest="false" Codebehind="AccountActivity.aspx.cs" %>

<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
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
        <rx:Hidden ID="New_CorporationId" runat="server" />
        <rx:PanelX ID="PanelX1" runat="server" AutoWidth="true" AutoHeight="Normal" Height="70"
            Padding="true">
            <Body>
                <rx:ColumnLayout ID="ColumnLayout1" runat="server" ColumnWidth="25">
                    <Rows>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmDateFieldComp runat="server" ID="new_StartDate" ObjectId="201600023" UniqueName="new_StartDate"
                                    RequirementLevel="BusinessRequired" FieldLabelWidth="40" Width="40">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_ActivityType" ObjectId="201600023" UniqueName="new_ActivityType" RequirementLevel="BusinessRequired" Width="40">
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout ID="ColumnLayout2" runat="server" ColumnWidth="25">
                    <Rows>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmDateFieldComp runat="server" ID="new_EndDate" ObjectId="201600023" UniqueName="new_EndDate"
                                    RequirementLevel="BusinessRequired" FieldLabelWidth="40" Width="40">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_AccountId" ObjectId="201600023" UniqueName="new_AccountId" Mode="Remote"
                                    FieldLabel="Hesaplar" FieldLabelWidth="80" Width="100" PageSize="50" RequirementLevel="BusinessRequired" LookupViewUniqueName="AccountForCorpAccountMonitoring">
                                    <DataContainer>
                                        <DataSource OnEvent="LoadAccounts">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server">
                            <Body>
                                <rx:Button ID="BtnSearch" runat="server" Text="Search">
                                    <AjaxEvents>
                                        <Click OnEvent="SearchOnEvent">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

            </Body>
        </rx:PanelX>
        <rx:GridPanel runat="server" ID="GridPanelMainAccount" AutoWidth="true" Editable="false" Mode="Remote" AutoLoad="false" AjaxPostable="true">
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
                    <rx:GridColumns Header="Account Name" ColumnId="0" DataIndex="AccountName" Align="Left" Width="200"></rx:GridColumns>
                    <rx:GridColumns Header="AccountType" ColumnId="1" DataIndex="AccountType" Align="Left" Width="100"></rx:GridColumns>
                    <rx:GridColumns Header="Currency" ColumnId="2" DataIndex="Currency" Align="Left" Width="50"></rx:GridColumns>
                    <rx:GridColumns Header="Date" ColumnId="3" DataIndex="ActivityDate" Align="Left" Width="100"></rx:GridColumns>
                    <rx:GridColumns Header="Activity Type" ColumnId="4" DataIndex="ActivityType" Align="Left" Width="100"></rx:GridColumns>
                    <rx:GridColumns Header="Amount" ColumnId="5" DataIndex="Amount" Align="Left" Width="100"></rx:GridColumns>
                    <rx:GridColumns Header="Balance" ColumnId="6" DataIndex="Balance" Align="Left" Width="100"></rx:GridColumns>
                    <rx:GridColumns Header="Description" ColumnId="7" DataIndex="ActivityDescription" Align="Left" Width="600"></rx:GridColumns>
                </Columns>
            </ColumnModel>
            <BottomBar>
                <rx:PagingToolBar ID="PagingToolBar1" runat="server" ControlId="GridPanelMainAccount">
                </rx:PagingToolBar>
            </BottomBar>
        </rx:GridPanel>
    </form>
</body>
</html>
