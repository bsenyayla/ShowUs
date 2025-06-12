<%@ Control Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Schedule_SchedulePlugin" Codebehind="SchedulePluginReflex.ascx.cs" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<rx:PanelX runat="server" ID="pnnlx" AutoHeight="Normal" Height="40" BorderStyle="NotSet"  >
    <Body>
        <rx:ColumnLayout ID="cl001" runat="server" ColumnWidth="33">
            <Rows>
                <rx:RowLayout ID="RowLayout1" runat="server">
                    <Body>
                        <cc1:CrmComboComp runat="server" ID="PluginId" FieldLabelWidth="75" DisplayField="VALUE" ValueField="ID" UniqueName="PluginId" ObjectId="58">
                            <DataContainer>
                                <DataSource OnEvent="PluginListOnRefreshData">
                                    <Columns>
                                        <rx:Column Name="ID" Hidden="true"></rx:Column>
                                        <rx:Column Name="VALUE"></rx:Column>
                                    </Columns>
                                </DataSource>
                            </DataContainer>
                        </cc1:CrmComboComp>

                    </Body>
                </rx:RowLayout>
            </Rows>
        </rx:ColumnLayout>
        <rx:ColumnLayout ID="ColumnLayout1" runat="server" ColumnWidth="33">
            <Rows>
                <rx:RowLayout ID="RowLayout2" runat="server">
                    <Body>
                    </Body>
                </rx:RowLayout>
            </Rows>
        </rx:ColumnLayout>
                <rx:ColumnLayout ID="ColumnLayout2" runat="server" ColumnWidth="33">
            <Rows>
                <rx:RowLayout ID="RowLayout3" runat="server">
                    <Body>
                    </Body>
                </rx:RowLayout>
            </Rows>
        </rx:ColumnLayout>
    </Body>

</rx:PanelX>
