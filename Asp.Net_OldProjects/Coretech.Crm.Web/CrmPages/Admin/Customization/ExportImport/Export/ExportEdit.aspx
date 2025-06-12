<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_ExportImport_Export_ExportEdit" Codebehind="ExportEdit.aspx.cs" %>

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
    <rx:RegisterResources runat="server" ID="RR"/>
    <div style="display: none">
        
        <rx:Hidden runat="server" ID="RedirectType" Value="1">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnObjectId">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnEntityName">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnEntityId">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnRecid">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnRecidName">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnDefaultEditPageId">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnSavingMessage">
        </rx:Hidden>
        <rx:Hidden ID="FetchXML" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="UpdatedUrl" runat="server">
        </rx:Hidden>
    </div>
    <rx:KeyMap runat="server" ID="KeyMap1">
        <rx:KeyBinding StopEvent="true">
            <Keys>
                <rx:Key Code="ESC">
                    <Listeners>
                        <Event Handler="" />
                    </Listeners>
                </rx:Key>
            </Keys>
        </rx:KeyBinding>
    </rx:KeyMap>
    <div>
        <rx:ToolBar runat="server" ID="EditToolbar" CustomCss="fixed-toolbar">
            <Items>
                <rx:ToolbarButton runat="server" ID="btnSave" Width="70" Text="Save" Icon="Disk">
                    <AjaxEvents>
                        <Click OnEvent="BtnSaveClick">
                            <EventMask ShowMask="true" />
                            <ExtraParams>
                                <rx:Parameter Name="Action" Value="1"></rx:Parameter>
                            </ExtraParams>
                        </Click>
                    </AjaxEvents>
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="btnSaveAndClose" Width="120" Text="Save And Close"
                    Icon="DiskBlack">
                    <AjaxEvents>
                        <Click OnEvent="BtnSaveClick">
                            <EventMask ShowMask="true" />
                            <ExtraParams>
                                <rx:Parameter Name="Action" Value="3"></rx:Parameter>
                            </ExtraParams>
                        </Click>
                    </AjaxEvents>
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="btnExport" Width="70" Text="Export" Icon="Xhtml">
                    <Listeners>
                    <Click Handler="window.location='Download.aspx?recid='+hdnRecid.getValue();" />
                    </Listeners>
                    
                </rx:ToolbarButton>
                <rx:ToolbarButton runat="server" ID="btnDelete" Width="100" Text="Delete" Icon="Delete">
                    <Listeners>
                        <Click Handler="BtnDelete_Click()" />
                    </Listeners>
                </rx:ToolbarButton>
            </Items>
        </rx:ToolBar>
        <rx:PanelX runat="server" ID="PnlMain" Frame="false" Border="false" AutoHeight="Full"
            AutoWidth="true">
            <Body>
                <rx:ColumnLayout runat="server" ID="c1" ColumnWidth="75%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="PackageName" runat="server" ObjectId="41" UniqueName="PackageName"
                                    FieldLabelWidth="100" Width="130" CaseType="Normal">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <rx:TreeGrid runat="server" ID="ExportList" Title="ExportList" Width="900" Height="400"
                                    Mode="Remote" Checkable="true" AutoWidth="false" Collapsible="true">
                                    <Columns>
                                        <rx:TreeGridColumn DataIndex="Name" Width="230" Header="Name">
                                        </rx:TreeGridColumn>
                                    </Columns>
                                    <Root>
                                    </Root>
                                </rx:TreeGrid>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
    </div>
    </form>
</body>
</html>
<script >
    function BtnDelete_Click() {
        Myform = window;
        try {
            window.top.GlobalDelete(Myform, null, hdnObjectId.getValue())
        } catch (e) {
            if (confirm("Bu kaydı silmek istediğinizden emin misiniz ?")) {
                var result = AjaxMethods.GlobalDelete("", hdnRecid.getValue(), hdnObjectId.getValue())
                if (result.Result == "0") {
                    alert(result.ErrorMessage)
                } else {
                    RefreshParetnGrid(true)
                }
            }
        }
    }    
</script>