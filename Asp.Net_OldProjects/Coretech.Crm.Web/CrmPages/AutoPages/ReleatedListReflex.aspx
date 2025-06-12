<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_AutoPages_ReleatedListReflex" ValidateRequest="false" Codebehind="ReleatedListReflex.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR"/>
    <ajx:Hidden ID="ViewQuery" runat="server">
    </ajx:Hidden>
    <ajx:Hidden ID="FetchXML" runat="server">
    </ajx:Hidden>
    <ajx:Hidden ID="MapXML" runat="server">
    </ajx:Hidden>
    <ajx:Hidden ID="hdnDefaultEditPage" runat="server">
    </ajx:Hidden>
    <ajx:Hidden ID="hdnObjectId" runat="server">
    </ajx:Hidden>
    <ajx:KeyMap runat="server" ID="KeyMap2">
        <ajx:KeyBinding StopEvent="false">
            <Keys>
                <ajx:Key Code="BACKSPACE">
                    <Listeners>
                        <Event Handler="stopRKey(e);" />
                    </Listeners>
                </ajx:Key>
            </Keys>
        </ajx:KeyBinding>
    </ajx:KeyMap>
    <ajx:GridPanel runat="server" ID="GridPanelViewer" Width="900" AutoLoad="true" AutoWidth="true"
        AutoHeight="Auto" Mode="Remote" Height="258">
        <TopBar>
            <ajx:ToolBar runat="server" ID="toptoolbar">
                <Items>
                    <ajx:ToolbarButton ID="btnNew" Icon="Add" Text="New" runat="server" Width="50">
                        <Listeners>
                            <Click Handler="ShowEditTab(GridPanelViewer.id,'',hdnDefaultEditPage.getValue(),hdnObjectId.getValue(), GetMapXMLValue(MapXML.getValue()) );" />
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton runat="server" ID="btnExport" Icon="PageWhiteExcel">
                        <Menu>
                            <ajx:Menu runat="server" ID="mnuExport1">
                                <Items>
                                    <ajx:MenuItem ID="btnExportCurrentPage" runat="server" Text="Export_to_Excel" Icon="PageWhiteExcel">
                                        <Listeners>
                                            <Click Handler="ExportExcel(0);" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                    <ajx:MenuItem ID="btnExportAllPage" runat="server" Text="Export_To_Excel_(All_Page)"
                                        Icon="PageWhiteExcel">
                                        <Listeners>
                                            <Click Handler="ExportExcel(1);" />
                                        </Listeners>
                                    </ajx:MenuItem>
                                </Items>
                            </ajx:Menu>
                        </Menu>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarSeparator ID="btnExportSeparator" runat="server" />
                    <ajx:ToolbarButton ID="btnAssign" Icon="PackageGo" Text="Assign" runat="server">
                        <Listeners>
                            <Click Handler="window.top.GlobalAssign(GridPanelViewer,hdnObjectId.getValue());" />
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarSeparator ID="btnAssignSeparator" runat="server" />
                    <ajx:ToolbarButton ID="btnDelete" Icon="Delete" Text="Delete" runat="server" Width="50">
                        <Listeners>
                            <Click Handler="btnDeleteOnclick();" />
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarSeparator ID="btnDeleteSeparator" runat="server" />
                    <ajx:TextField ID="FilterText" runat="server" Width="200" EmptyText="Aranacak Kelimeyi Giriniz">
                        <Listeners>
                            <KeyPress Handler="if(e.keyCode == VKeyCode.VK_RETURN){GridPanelViewer.reload();R.StopKeyEvent(e);  return false;}" />
                        </Listeners>
                    </ajx:TextField>
                    <ajx:ToolbarSeparator ID="ToolbarSeparator1" runat="server" />
                    
                    <ajx:ToolbarButton ID="TextField1Search" runat="server" Icon="Magnifier">
                        <Listeners>
                            <Click Handler="GridPanelViewer.reload();" />
                        </Listeners>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarButton Text="Sıralamayı Kaydet" Width="110" ID="btnSaveSort" runat="server"
                        Icon="ShapeUngroup">
                        <AjaxEvents>
                            <Click OnEvent="SaveSorting">
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarFill runat="server" ID="ToolbarFill1">
                    </ajx:ToolbarFill>
                    <ajx:Label ID="lblInfo" runat="server" Icon="Information" Width="20">
                        <Listeners>
                            <Click Handler="ShowPageInfo();" />
                        </Listeners>
                    </ajx:Label>
                </Items>
            </ajx:ToolBar>
        </TopBar>
        <LoadMask ShowMask="true" />
        <DataContainer>
            <Parameters>
                <ajx:Parameter Name="start" Value="0" Mode="Value"></ajx:Parameter>
                <ajx:Parameter Name="limit" Value="50" Mode="Value"></ajx:Parameter>
                <ajx:Parameter Name="viewqueryid" Value="ViewQuery.getValue()" Mode="Raw"></ajx:Parameter>
                <ajx:Parameter Name="query" Value="FilterText.getValue()" Mode="Raw"></ajx:Parameter>
                <ajx:Parameter Name="feachxml" Value="FetchXML.getValue()" Mode="Raw"></ajx:Parameter>
            </Parameters>
        </DataContainer>
        <SelectionModel>
            <ajx:RowSelectionModel ID="RowSelectionModel1" runat="server" RowDragable="true">
                <Listeners>
                    <RowDblClick Handler="ShowEditTab(GridPanelViewer.id,GridPanelViewer.selectedRecord.ID,hdnDefaultEditPage.getValue(),hdnObjectId.getValue(),GetMapXMLValue(MapXML.getValue()));" />
                </Listeners>
            </ajx:RowSelectionModel>
        </SelectionModel>
        <BottomBar>
            <ajx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelViewer">
            </ajx:PagingToolBar>
        </BottomBar>
    </ajx:GridPanel>
    </form>
</body>
</html>
<script>
    function deleteSuccess(result) {
        var r = JSON.decode(result);
        alert(r.Result);
        if (r.Result == "0") {
            alert(r.ErrorMessage)
        }
        
    }
    function btnDeleteOnclick() {
        try {
            window.top.GlobalDelete(null, GridPanelViewer, hdnObjectId.getValue());
        } catch (e) {
            if (confirm(GetMessages("CRM_RECORD_WILL_DELETE_ARE_YOU_SURE"))) {
                var errcnt = 0;
                var Gbp = GridPanelViewer;
                for (var i = 0; i < Gbp.selectedRecords.length; i++) {
                    R.AjaxMethods.GlobalDelete("", Gbp.selectedRecords[i].ID, hdnObjectId.getValue(), deleteSuccess, false);
                }
                 
                Gbp.reload();
            }
        }
    }

    //    function stopRKey(evt) {
    //        var evt = (evt) ? evt : ((event) ? event : null);
    //        var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);
    //        if ((evt.keyCode == 13) && (node.type == "text")) { return false; }
    //    }
    //    document.onkeypress = stopRKey
    
</script>
