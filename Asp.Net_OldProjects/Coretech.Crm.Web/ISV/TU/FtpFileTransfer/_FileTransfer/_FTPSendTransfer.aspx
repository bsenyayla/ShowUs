<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false"
    Inherits="FtpFileTransfer__FileTransfer_FTPSendTransfer" Codebehind="_FTPSendTransfer.aspx.cs" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script type="text/javascript">
        function ErrorRender() {
            for (var i = 0; i < FtpReadFileDetailGridPanel.data.Records.length; i++) {
                if (!R.isEmpty(FtpReadFileDetailGridPanel.data.Records[i].new_ConfirmErrorLogText)) {
                    $("trtblrow" + (i) + "FtpReadFileDetailGridPanel").style.backgroundColor = "#FF9494";
                }
            }
        }
        function DrawError() {
            if (GridFtpRead.data)
                for (var i = 0; i < GridFtpRead.data.Records.length; i++) {
                    if (GridFtpRead.data.Records[i].ErrorCount > 0) {
                        $("trtblrow" + (i) + "GridFtpRead").style.backgroundColor = "#FF9494";
                    }
                }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <div style="display: none">
            <rx:TextField runat="server" ID="PageSessionId" />
        </div>
        <rx:PanelX ID="PanelX1" runat="server" AutoWidth="true" AutoHeight="Normal" Height="30"
            Padding="true">
            <Body>
                <rx:ColumnLayout ID="ColumnLayout3" runat="server" ColumnWidth="30">
                    <Rows>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="CrmComboComp1" ObjectId="201100125" UniqueName="new_CorporationId"
                                    FieldLabel="Kurum" FieldLabelWidth="80" Width="100" pagesize="50" RequirementLevel="BusinessRequired"
                                    LookupViewUniqueName="CorporationLookup" >
                                    <%--                                    <DataContainer>
                                        <DataSource OnEvent="new_CrmComboComp1Load">
                                        </DataSource>
                                    </DataContainer>--%>
                                    <DataContainer>
                                        <DataSource OnEvent="new_CrmComboComp1Load">
                                        </DataSource>
                                    </DataContainer>
                                    <Listeners>
                                        <Change Handler="CrmComboComp2.clear();" />
                                    </Listeners>
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout ID="ColumnLayout4" runat="server" ColumnWidth="30">
                    <Rows>
                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="CrmComboComp2" ObjectId="201100125" UniqueName="new_FtpFileHeaderId"
                                    RequirementLevel="BusinessRequired" FieldLabel="FileHeader" FieldLabelWidth="80"
                                    Width="100" LookupViewUniqueName="FTPFILEHEADEROUTPUT" pagesize="50">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100125" FromUniqueName="new_CorporationId" ToObjectId="201100125"
                                            ToUniqueName="new_CorporationId" ComponentId="CrmComboComp1" />
                                        <cc1:ComboFilter ToObjectId="201100120" ToUniqueName="new_FtpType" />
                                    </Filters>

                                    <AjaxEvents>
                                        <Change OnEvent="CreateCriteriaGroupsToTransfer"></Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout ID="ColumnLayout1" runat="server" ColumnWidth="30">
                    <Rows>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
                <rx:Button ID="btnShowWindow" runat="server" Icon="Page" Text="CRM.NEW_FTPWELCOMESCREEN_SHOW_TRANSFER_LIST"
                    Download="true">
                    <AjaxEvents>
                        <Click OnEvent="btnShowWindowOnEvent">
                            <EventMask ShowMask="True" />
                        </Click>
                    </AjaxEvents>


                </rx:Button>
                <%--<rx:Button ID="CreateFile" runat="server" Icon="ApplicationSideTree" Text="DOSYA_OLUSTUR"
                    Download="true">
                    <AjaxEvents>
                        <Click OnEvent="CreateFileOnEvent">
                            <EventMask ShowMask="True" />

                        </Click>
                    </AjaxEvents>
                </rx:Button>--%>
                <rx:Button ID="Button1" runat="server" Icon="Table" Text="DOSYA_LISTESI">
                    <Listeners>
                        <Click Handler="GridPanel1.reload();"></Click>
                    </Listeners>
                </rx:Button>
            </Buttons>
        </rx:PanelX>

        <rx:GridPanel runat="server" ID="GridPanel1" AutoWidth="true" AutoHeight="Auto" Height="150"
            Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
            <DataContainer>
                <DataSource OnEvent="GridPanelOnload">
                </DataSource>
                <Parameters>
                    <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                    <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                </Parameters>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="FtpReadFileDetailGridPanelRowSelectionModel11" runat="server"
                    ShowNumber="true">

                    <AjaxEvents>
                        <RowDblClick OnEvent="RowSelect">
                        </RowDblClick>
                    </AjaxEvents>

                </rx:RowSelectionModel>
            </SelectionModel>
            <BottomBar>
                <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanel1">
                </rx:PagingToolBar>
            </BottomBar>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>
        <rx:Hidden runat="server" ID="FtpReadFileHeaderId">
        </rx:Hidden>

        <rx:Window ID="FtpReadFileDetailPopup" runat="server" Width="900" Height="500" Modal="true"
            Border="false" Closable="true" Maximizable="false" Resizable="true" CloseAction="Hide"
            ShowOnLoad="false" Title="Dosya Listesi">
            <Body>
                <rx:GridPanel runat="server" ID="FtpReadFileDetailGridPanel" AutoWidth="true" AutoHeight="Normal"
                    Height="283" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
                    <DataContainer>
                        <DataSource OnEvent="FtpReadFileDetailGridPanelOnload">
                        </DataSource>
                        <Parameters>
                            <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                            <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                        </Parameters>
                    </DataContainer>

                    <SelectionModel>
                        <rx:RowSelectionModel ID="FtpReadFileDetailGridPanelRowSelectionModel1" runat="server"
                            ShowNumber="true">
                        </rx:RowSelectionModel>
                    </SelectionModel>

                    <%--<SpecialSettings>
                    <rx:RowExpander Template="<br/><br/><span style='color:red'>{new_ConfirmErrorCode} : {new_ConfirmErrorLogText}</span><br/><br/><span>Kullanıcı Açıklaması : </span><span>{new_UserDescription}</span>"
                        Collapsed="true" />
                </SpecialSettings>
                <Listeners>
                    <LoadComplete Handler="ErrorRender();" />
                </Listeners>--%>

                    <LoadMask ShowMask="true" />
                </rx:GridPanel>
            </Body>
        </rx:Window>

        <rx:Window ID="TransferWindowList" runat="server" Width="900" Height="500" Modal="true"
            Border="false" Closable="true" Maximizable="false" Resizable="true" CloseAction="Hide"
            ShowOnLoad="false" Title="Records">
            <Body>

                <body>
                    <rx:PanelX runat="server" ID="pnlRecords" Height="40" AutoWidth="True" AutoHeight="Normal">
                        <Body>
                            <rx:ColumnLayout ID="ColumnLayout2" runat="server" ColumnWidth="50">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout2" runat="server">
                                        <Body>

                                            <rx:MultiField runat="server" FieldLabel="" ID="mlNew_TransferId">
                                                <Items>
                                                    <cc1:CrmComboComp runat="server" ID="New_TransferId" LookupViewUniqueName="TRASNFER_RECORD_LOOKUP" ObjectId="201100072" Width="200" UniqueName="New_TransferId" Visible="false">
                                                    </cc1:CrmComboComp>
                                                    <rx:Button ID="CreateFile" runat="server" Icon="ApplicationSideTree" Text="Aktar"
                                                        Download="true">
                                                        <AjaxEvents>
                                                            <Click OnEvent="CreateFileOnEvent">
                                                                <EventMask ShowMask="True" />

                                                            </Click>
                                                        </AjaxEvents>
                                                    </rx:Button>
                                                    <rx:Button runat="server" ID="btnAdd" Icon="Add" Text="Ekle" Visible="false">
                                                        <AjaxEvents>
                                                            <Click OnEvent="btnAddClick">
                                                            </Click>
                                                        </AjaxEvents>
                                                    </rx:Button>
                                                    <rx:Button runat="server" ID="Button2" Icon="Delete" Text="Çıkar" Visible="false">
                                                        <AjaxEvents>
                                                            <Click OnEvent="BtnRemoveClick">
                                                                <EventMask ShowMask="false" />
                                                            </Click>
                                                        </AjaxEvents>
                                                    </rx:Button>



                                                </Items>

                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                            <%-- <rx:ColumnLayout ID="ColumnLayout5" runat="server" ColumnWidth="50">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout5" runat="server">
                                        <Body>
                                            <rx:Button ID="CreateFile" runat="server" Icon="ApplicationSideTree" Text="Aktar"
                                                Download="true">
                                                <AjaxEvents>
                                                    <Click OnEvent="CreateFileOnEvent">
                                                        <EventMask ShowMask="True" />

                                                    </Click>
                                                </AjaxEvents>
                                            </rx:Button>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>--%>
                        </Body>

                    </rx:PanelX>
                    <rx:GridPanel runat="server" ID="GridPanelMonitoring" AutoWidth="true" AutoHeight="Auto"
                        Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
                        <DataContainer>
                            <DataSource OnEvent="ToolbarButtonFindClick">
                            </DataSource>
                            <Parameters>
                                <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                                <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                            </Parameters>
                        </DataContainer>
                        <SelectionModel>
                            <rx:CheckSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server"
                                ShowNumber="true">
                                <Listeners>
                                    <RowDblClick Handler="ShowWindow(GridPanelMonitoring.id,GridPanelMonitoring.selectedRecord.ID,GridPanelMonitoring.selectedRecord.ObjectId,1);" />
                                </Listeners>
                            </rx:CheckSelectionModel>
                        </SelectionModel>
                        <BottomBar>
                            <rx:PagingToolBar runat="server" ID="PagingToolBar2" ControlId="GridPanelMonitoring">
                                <Buttons>
                                    <rx:SmallButton ID="BtnDelete" Icon="Delete">
                                        <AjaxEvents>
                                            <Click OnEvent="BtnRemoveClick">
                                                <EventMask ShowMask="false" />
                                            </Click>
                                        </AjaxEvents>

                                    </rx:SmallButton>
                                    <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload">
                                        <AjaxEvents>
                                            <Click OnEvent="ToolbarButtonFindClick">
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
                        <LoadMask ShowMask="true" />
                    </rx:GridPanel>
                </body>
            </Body>

        </rx:Window>
    </form>
</body>
</html>
<script type="text/javascript">
    function fileControl() {
        new_Date1.clear();
        new_Date1.setReadOnly(!R.isEmpty(CrmComboComp3.getValue()));
        new_Date2.clear();
        new_Date2.setReadOnly(!R.isEmpty(CrmComboComp3.getValue()));
    }
</script>
