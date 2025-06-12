<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Customization_Entity_EntityDictionaryImport" Codebehind="EntityDictionaryImport.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR" />
    <ajx:Hidden ID="hdnSequenceId" runat="server" />
    <ajx:GridPanel ID="GridPanel1" runat="server" Title="Dictionary List" AutoHeight="Auto"
        PostAllData="true" Mode="Remote" AutoLoad="true" AutoWidth="true">
        <TopBar>
            <ajx:ToolBar runat="server" ID="TopPanel1">
                <Items>
                    <ajx:PanelX runat="server" ID="PnlMain" Frame="false" Border="false" Width="800"
                        AutoHeight="Normal" AutoWidth="false" Height="30">
                        <Body>
                            <ajx:ColumnLayout runat="server" ID="c1" ColumnWidth="50%">
                                <Rows>
                                    <ajx:RowLayout ID="RowLayout2" runat="server">
                                        <Body>
                                            <ajx:FileUpload FieldLabel="CRM_IMPORT_SELECT_FILE" runat="server" ID="ImportFile">
                                            </ajx:FileUpload>
                                        </Body>
                                    </ajx:RowLayout>
                                </Rows>
                            </ajx:ColumnLayout>
                            <ajx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="25%">
                                <Rows>
                                    <ajx:RowLayout ID="RowLayout3" runat="server">
                                        <Body>
                                            <ajx:ComboField runat="server" ID="Language" DisplayField="RegionName" ValueField="LangId"
                                                Mode="Local" Width="200">
                                            </ajx:ComboField>
                                        </Body>
                                    </ajx:RowLayout>
                                </Rows>
                            </ajx:ColumnLayout>
                            <ajx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="25%">
                                <Rows>
                                    <ajx:RowLayout ID="RowLayout1" runat="server">
                                        <Body>
                                            <ajx:Button runat="server" Icon="Add" ID="BtnUpload" Text="CRM_IMPORT_FILE_UPLOAD">
                                                <AjaxEvents>
                                                    <Click OnEvent="BtnUploadClick">
                                                    </Click>
                                                </AjaxEvents>
                                            </ajx:Button>
                                        </Body>
                                    </ajx:RowLayout>
                                </Rows>
                            </ajx:ColumnLayout>
                        </Body>
                    </ajx:PanelX>
                </Items>
            </ajx:ToolBar>
        </TopBar>
        <DataContainer>
            <DataSource OnEvent="DataLoad">
                <Columns>
                    <ajx:Column Name="Value" />
                </Columns>
            </DataSource>
            <Parameters>
                <ajx:Parameter Mode="Value" Name="start" Value="1" />
                <ajx:Parameter Mode="Value" Name="limit" Value="500" />
            </Parameters>
        </DataContainer>
        <LoadMask ShowMask="false" Msg="Loading Data..." />
        <ColumnModel>
            <Columns>
                <ajx:GridColumns DataIndex="Value" Header="Value" Width="300" Sortable="false" MenuDisabled="true" />
            </Columns>
        </ColumnModel>
        <SelectionModel>
            <ajx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
            </ajx:RowSelectionModel>
        </SelectionModel>
        <BottomBar>
            <ajx:PagingToolBar ID="PagingToolBar2" runat="server" ControlId="GridPanel1">
                <Buttons>
                    <ajx:SmallButton Icon="Add" Text=" Dataları İçeri Aktar" ID="SmallButton1">
                        <AjaxEvents>
                            <Click OnEvent="GridPanel1AddUpdateLabelClick">
                            </Click>
                        </AjaxEvents>
                    </ajx:SmallButton>
                </Buttons>
            </ajx:PagingToolBar>
        </BottomBar>
    </ajx:GridPanel>
    </form>
</body>
</html>
