<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WindowsServices.aspx.cs" Inherits="Coretech.Crm.Web.CrmPages.Admin.Monitoring.WindowsServices" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR" />
    <div>
        <table style="width: 100%">
            <tr>
                <td>
                    <rx:PanelX runat="server" ID="panelHeader" AutoHeight="Normal" Height="25" AutoWidth="true"
                        Border="true" Frame="true">
                        <Body>
                            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="15%">
                                <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout1">
                                        <Body>
                                            <rx:Button ID="bRefresh" runat="server" Text="Refresh" Icon="Reload">
                                                <AjaxEvents>
                                                    <Click OnEvent="Refresh"></Click>
                                                </AjaxEvents>
                                            </rx:Button>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                             <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="15%">
                                <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout2">
                                        <Body>
                                            <rx:Button ID="btnStart" runat="server" Text="Start" Icon="ApplicationGo">
                                                <AjaxEvents>
                                                    <Click OnEvent="ServiceStart"></Click>
                                                </AjaxEvents>
                                            </rx:Button>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                             <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="15%">
                                <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout3">
                                        <Body>
                                            <rx:Button ID="Button2" runat="server" Text="Stop" Icon="Stop">
                                                <AjaxEvents>
                                                    <Click OnEvent="ServiceStop"></Click>
                                                </AjaxEvents>
                                            </rx:Button>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                        </Body>
                    </rx:PanelX>
                </td>
            </tr>
        </table>
        <rx:PanelX ID="pnlData" runat="server">
            <Body>
                <rx:GridPanel runat="server" ID="gridPanel" AutoWidth="true" Height="400" Editable="false" Mode="Local" AutoLoad="false" AjaxPostable="true">
                    <ColumnModel>
                        <Columns>
                            <rx:GridColumns Header="Service Name" ColumnId="1" DataIndex="ServiceName" Width="300"></rx:GridColumns>
                            <rx:GridColumns Header="Status" ColumnId="2" DataIndex="Status" Width="200"></rx:GridColumns>
                        </Columns>
                    </ColumnModel>
                    <SelectionModel>
                        <rx:RowSelectionModel ID="rowSelectionModel1" runat="server" ShowNumber="true" />
                    </SelectionModel>
                </rx:GridPanel>
            </Body>
        </rx:PanelX>
    </div>    
    </form>
</body>
</html>
