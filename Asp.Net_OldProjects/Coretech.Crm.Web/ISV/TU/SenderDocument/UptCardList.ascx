<%@ Control Language="C#" AutoEventWireup="true" Inherits="SenderDocument_UptCardList" CodeBehind="UptCardList.ascx.cs" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>


<rx:GridPanel ID="gpUptCard" runat="server" AutoHeight="Normal" Height="95"
    AutoWidth="true"
    FieldLabelShow="true" Mode="Remote">

    <ColumnModel>
        <Columns>
        </Columns>
    </ColumnModel>
    <SelectionModel>
        <rx:RowSelectionModel ID="gpUptCardRowSelection" runat="server" ShowNumber="True">
            <Listeners>
                <RowDblClick Handler="gpUptCardRowDblClick(gpUptCard.selectedRecord.ID);"></RowDblClick>
            </Listeners>
        </rx:RowSelectionModel>
    </SelectionModel>
    <DataContainer>
        <DataSource OnEvent="gpUptCardReload"></DataSource>
        <Parameters>
            <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
            <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
        </Parameters>
    </DataContainer>
    <BottomBar>
        <rx:PagingToolBar ID="gpSenderSelectorPagingToolBar2" runat="server" ControlId="gpUptCard">
            <Buttons>
                <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="gpSenderSelectorPagingToolBar2SmallButton2" ToolTip="Export">
                    <AjaxEvents>
                        <Click OnEvent="gpUptCardReload">
                            <EventMask ShowMask="false" />
                            <ExtraParams>
                                <rx:Parameter Name="Excel" Value="1" Mode="Value" />
                            </ExtraParams>
                        </Click>
                    </AjaxEvents>
                </rx:SmallButton>
            </Buttons>
        </rx:PagingToolBar>
    </BottomBar>
</rx:GridPanel>
<script>
    function gpUptCardRowDblClick(recId) {
        var url = window.top.GetWebAppRoot;
        url += "/CrmPages/AutoPages/EditReflex.aspx";
        url += "?defaulteditpageid=" + senderDocumentFormID;
        url += "&recid=" + recId;
        url += "&ObjectId=201100056&mode=1"
        url += "&rlistframename=Frame_DocumentList&gridpanelid=GridPanelViewer";
        window.top.newWindowRefleX(url, { maximized: true, width: 600, height: 400, resizable: true, modal: true, maximizable: true });
    }
</script>
