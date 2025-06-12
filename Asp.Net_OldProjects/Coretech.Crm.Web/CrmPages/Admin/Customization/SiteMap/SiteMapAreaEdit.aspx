<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Customization_SiteMap_SiteMapAreaEdit" Codebehind="SiteMapAreaEdit.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR" />
    <ajx:Hidden ID="SiteMapAreaId" runat="server">
    </ajx:Hidden>
    <ajx:PanelX ID="PanelX1" runat="server" Title="SiteMapEdit" AutoHeight="Normal" AutoWidth="true"
        Padding="true" Height="110">
        <Body>
            <ajx:ColumnLayout ID="ColumnLayout1" runat="server" ColumnWidth="50%">
                <Rows>
                    <ajx:RowLayout ID="RowLayout1" runat="server">
                        <Body>
                            <ajx:ComboField ID="SiteMap" runat="server" FieldLabel="SiteMap" ValueField="SiteMapId"
                                DisplayField="LabelValue" Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="GetSiteMapData">
                                        <Columns>
                                            <ajx:Column Name="SiteMapId" Hidden="true" />
                                            <ajx:Column Name="LabelValue" Width="200" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                                <Listeners>
                                    <Change Handler="ParentSiteMapArea.clear();" />
                                </Listeners>
                            </ajx:ComboField>
                            <ajx:TextField ID="SiteMapAreaLabelName" runat="server" FieldLabel="SiteMapAreaLabelName"
                                Regex="/[A-Za-z0-9_]/">
                            </ajx:TextField>
                            <ajx:TextField ID="SiteMapAreaHref" runat="server" FieldLabel="SiteMapAreaHref">
                            </ajx:TextField>
                            <ajx:TextField ID="SiteMapAreaDisplayOrder" runat="server" FieldLabel="SiteMapAreaDisplayOrder">
                            </ajx:TextField>
                        </Body>
                    </ajx:RowLayout>
                </Rows>
            </ajx:ColumnLayout>
            <ajx:ColumnLayout ID="ColumnLayout2" runat="server" ColumnWidth="50%">
                <Rows>
                    <ajx:RowLayout ID="RowLayout2" runat="server">
                        <Body>
                            <ajx:ComboField ID="ParentSiteMapArea" runat="server" FieldLabel="ParentSiteMapArea"
                                ValueField="SiteMapAreaId" DisplayField="IsvLabel" Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="GetParentSiteMapAreaData">
                                        <Columns>
                                            <ajx:Column Name="SiteMapAreaId" Hidden="true" />
                                            <ajx:Column Name="IsvLabel" Width="200" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </ajx:ComboField>
                            <ajx:ComboField ID="EntityList" runat="server" FieldLabel="Entity" ValueField="EntityId"
                                DisplayField="Label" Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="GetEntityListData">
                                        <Columns>
                                            <ajx:Column Name="EntityId" Hidden="true" />
                                            <ajx:Column Name="Label" Width="200" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </ajx:ComboField>
                            <ajx:ComboField ID="PriEntityList" runat="server" FieldLabel="PrivligeEntity" ValueField="EntityId"
                                DisplayField="Label" Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="GetPriEntityListData">
                                        <Columns>
                                            <ajx:Column Name="EntityId" Hidden="true" />
                                            <ajx:Column Name="Label" Width="200" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </ajx:ComboField>
                            <ajx:TextField ID="ImageHref" runat="server" FieldLabel="ImageHref">
                            </ajx:TextField>
                        </Body>
                    </ajx:RowLayout>
                </Rows>
            </ajx:ColumnLayout>
        </Body>
        <Buttons>
            <ajx:Button ID="New" runat="server" Icon="NewBlue" Text="NEW_SITEMAP">
                <AjaxEvents>
                    <Click OnEvent="NewOnEvent">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
            <ajx:Button ID="Save" runat="server" Icon="PageSave" Text="SAVE_SITEMAP">
                <AjaxEvents>
                    <Click OnEvent="SaveOnEvent">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
            <ajx:Button ID="Delete" runat="server" Icon="PageDelete" Text="DELETE_SITEMAP">
                <AjaxEvents>
                    <Click OnEvent="DeleteOnEvent">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
        </Buttons>
    </ajx:PanelX>
    <ajx:TreeGrid ID="TreeGrid1" runat="server" AutoHeight="Auto" AutoWidth="true" Mode="Remote"
        Width="700" Height="200">
        <Columns>
            <ajx:TreeGridColumn DataIndex="SiteMapTitle" Width="300" Header="SiteMapTitle">
            </ajx:TreeGridColumn>
            <ajx:TreeGridColumn DataIndex="IsvHref" Width="400" Align="Left" Header="IsvHref">
            </ajx:TreeGridColumn>
        </Columns>
        <Root>
            <AjaxEvents>
                <Click OnEvent="RowClickOnEvent">
                </Click>
            </AjaxEvents>
        </Root>
    </ajx:TreeGrid>
    </form>
</body>
</html>
