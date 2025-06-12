<%@ Page Language="C#" AutoEventWireup="true" Inherits="Sender_SenderMultipleSingularityResult" Codebehind="SenderMultipleSingularityResult.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/SenderMultipleSingularity.js?<%=App.Params.AppVersion %>"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="20" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="100%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout7" runat="server">
                            <Body>
                                <rx:Label ID="lblTwiceMessage" runat="server"></rx:Label>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:GridPanel runat="server" ID="gpMultipleSingularityHeader" AutoWidth="true" AutoHeight="Auto"
            Height="330" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
            <DataContainer>
                <DataSource OnEvent="GpMultipleSingularityLoad">
                </DataSource>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="gpMultipleSingularityRowSelectionModel1" runat="server" ShowNumber="true"
                    SingleSelect="true">
                    <Listeners>
                        <RowDblClick Handler="ShowWindow(gpMultipleSingularityHeader.selectedRecord.ID);" />
                    </Listeners>
                </rx:RowSelectionModel>
            </SelectionModel>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>
    </form>
</body>
</html>
