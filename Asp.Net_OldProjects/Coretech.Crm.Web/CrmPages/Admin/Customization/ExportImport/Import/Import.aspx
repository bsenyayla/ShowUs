<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_ExportImport_Import_Import" Codebehind="Import.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div style="display: none">
        <rx:Hidden runat="server" ID="hdnImportId">
        </rx:Hidden>
    </div>
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:PanelX runat="server" ID="PnlMain" Frame="false" Border="false" Width="500" AutoHeight="Normal"
        AutoWidth="false" Height="30">
        <Body>
            <rx:ColumnLayout runat="server" ID="c1" ColumnWidth="75%">
                <Rows>
                    <rx:RowLayout ID="RowLayout2" runat="server">
                        <Body>
                            <rx:FileUpload FieldLabel="CRM_IMPORT_SELECT_FILE" runat="server" ID="ImportFile">
                            </rx:FileUpload>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="25%">
                <Rows>
                    <rx:RowLayout ID="RowLayout1" runat="server">
                        <Body>
                            <rx:Button runat="server" Icon="Add" ID="BtnUpload" Text="CRM_IMPORT_FILE_UPLOAD" Download="true">
                                <AjaxEvents>
                                    <Click OnEvent="BtnUploadClick">
                                    </Click>
                                </AjaxEvents>
                            </rx:Button>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
        </Body>
    </rx:PanelX>
    <rx:TreeGrid runat="server" ID="ImportList"  Width="500" Height="400"
        Mode="Remote" Checkable="true" AutoWidth="false" Collapsible="false">
        <BottomBar>
            <rx:ToolBar ID="tb1" runat="server">
                <Items>
                    <rx:ToolbarFill ID="ToolbarFill1" runat="server">
                    </rx:ToolbarFill>
                    <rx:Button ID="BtnImport" runat="server" Icon="AsteriskRed" Text="CRM_IMPORT_SCHEMA">
                        <AjaxEvents>
                            <Click OnEvent="BtnImportClick">
                            </Click>
                        </AjaxEvents>
                    </rx:Button>
                </Items>
            </rx:ToolBar>
        </BottomBar>
        <Columns>
            <rx:TreeGridColumn DataIndex="Name" Header="">
            </rx:TreeGridColumn>
        </Columns>
        <Root>
        </Root>
    </rx:TreeGrid>
    </form>
</body>
</html>
