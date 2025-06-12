<%@ Page Language="C#" AutoEventWireup="true" Inherits="SenderDocument_SenderDocumentList" CodeBehind="SenderDocumentList.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="hdnSenderDocumentID"></rx:Hidden>

<%--        <rx:Button runat="server" ID="btnDownload" Icon="Page" Text="Dosya Görüntüle">
            <AjaxEvents>
                
            </AjaxEvents>
        </rx:Button>--%>

        <rx:GridPanel runat="server" ID="gpSenderDocument" AutoWidth="true" AutoHeight="Auto"
            Height="300" Editable="false" Mode="Remote" AutoLoad="true" Width="800" AjaxPostable="true">
            <Tools>
                <Items>
                    <rx:ToolButton runat="server" ID="ToolButton1" ToolTypeIcon="Maximize">
                        <Listeners>
                            <Click Handler="gpSenderDocument.fullScreen();" />
                        </Listeners>
                    </rx:ToolButton>
                </Items>
            </Tools>
            <DataContainer>
                <DataSource OnEvent="gpSenderDocumentReload">
                </DataSource>
                <Parameters>
                    <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                    <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                </Parameters>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="gpSenderDocumentRowSelectionModel" runat="server" ShowNumber="true"
                    SingleSelect="true">
                    <Listeners>
                        <RowClick Handler="hdnSenderDocumentID.setValue(gpSenderDocument.selectedRecord.ID);"></RowClick>
                    </Listeners>
                    <AjaxEvents>
                        <RowDblClick OnEvent="btnDownload_OnClick">
                           </RowDblClick>
                    </AjaxEvents>
                </rx:RowSelectionModel>
            </SelectionModel>
            <BottomBar>
                <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="gpSenderDocument">
                </rx:PagingToolBar>
            </BottomBar>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>
         <rx:Window ID="wSenderDocument" runat="server" Width="800" Height="600" Modal="true" Maximized="false"
            CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
            CloseAction="Hide" ShowOnLoad="false">
            <Body>
                <rx:PanelX runat="server" ID="pSenderDocument" Width="800" Height="600" AutoHeight="Normal"
                    CustomCss="Section2" Title="" Collapsed="false" Collapsible="true"
                    Border="false">
                    <AutoLoad Url="about:blank" />
                    <Body>
                    </Body>
                </rx:PanelX>
            </Body>
        </rx:Window>
    </form>
</body>
</html>
