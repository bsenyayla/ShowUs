<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false"
    Inherits="FtpFileTransfer_FileTransfer._FileTransferInput" CodeBehind="_FileTransferInput.aspx.cs" Async="true" %>

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
                if (R.isEmpty(FtpReadFileDetailGridPanel.data.Records[i].new_TransferIdName)) {
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
        <rx:Hidden runat="server" ID="FtpReadFileHeaderId"></rx:Hidden>
        <rx:Hidden runat="server" ID="hdnFtpTransferLogId"></rx:Hidden>

        <rx:PanelX ID="PanelX1" runat="server" AutoWidth="true" AutoHeight="Normal" Height="30"
            Padding="true">
            <Body>
                <rx:ColumnLayout ID="ColumnLayout1" runat="server" ColumnWidth="25">
                    <Rows>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_CorporationId" ObjectId="201100125" UniqueName="new_CorporationId"
                                    FieldLabel="Kurum" FieldLabelWidth="80" Width="100" PageSize="50" RequirementLevel="BusinessRequired">

                                    <DataContainer>
                                        <DataSource OnEvent="new_CorporationLoad">
                                        </DataSource>
                                    </DataContainer>

                                    <Listeners>
                                        <Change Handler="new_FtpFileHeaderId.clear();" />
                                    </Listeners>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout ID="ColumnLayout2" runat="server" ColumnWidth="25">
                    <Rows>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_FtpFileHeaderId" ObjectId="201100125" UniqueName="new_FtpFileHeaderId"
                                    RequirementLevel="BusinessRequired" FieldLabel="FileHeader" FieldLabelWidth="80"
                                    Width="100" LookupViewUniqueName="FROM_FTP_IMPORT" PageSize="50">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100125" FromUniqueName="new_CorporationId" ToObjectId="201100125"
                                            ToUniqueName="new_CorporationId" />
                                    </Filters>
                                    <Listeners>
                                        <Change Handler="if(new_FtpFileHeaderId.selectedRecord.new_UseFTP==undefined){FileUpload1.hide();GetList.show();return;}if(new_FtpFileHeaderId.selectedRecord.new_UseFTP){FileUpload1.hide();GetList.show();}else{FileUpload1.show();GetList.hide();}" />
                                    </Listeners>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout ID="ColumnLayout7" runat="server" ColumnWidth="25">
                    <Rows>
                        <rx:RowLayout ID="RowLayout7" runat="server">
                            <Body>
                                <rx:CheckField ID="AllFiles" runat="server" FieldLabel="AllFiles">
                                </rx:CheckField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout ID="ColumnLayout6" runat="server" ColumnWidth="25">
                    <Rows>
                        <rx:RowLayout ID="RowLayout6" runat="server">
                            <Body>
                                <rx:Button ID="GetList" runat="server" Icon="ApplicationSideTree" Text="CRM_GETFILELIST">
                                    <AjaxEvents>
                                        <Click OnEvent="GetListOnEvent">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:GridPanel ID="FtpList" runat="server" AutoHeight="Normal" AutoWidth="true" DisableSelection="true"
            Height="200" Mode="Local">
            <DataContainer>
                <DataSource>
                    <Columns>
                        <rx:Column Name="Name" />
                        <rx:Column Name="Downloaded" DataType="Boolean" />
                        <rx:Column Name="Size" DataType="Decimal" />
                        <rx:Column Name="Modified" />
                    </Columns>
                </DataSource>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" SingleSelect="true"
                    ShowNumber="true">
                </rx:RowSelectionModel>
            </SelectionModel>
            <ColumnModel>
                <Columns>
                    <rx:GridColumns DataIndex="Downloaded" Width="80" Header="Downloaded" ColumnType="Check"
                        Editable="false">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="Name" Width="300" Header="FileName">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="Size" Width="200" Header="FileSize (Kb)" Align="Right">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="Modified" Width="200" Header="Modified">
                    </rx:GridColumns>
                </Columns>
            </ColumnModel>
            <BottomBar>
                <rx:ToolBar ID="ToolBar1" runat="server">
                    <Items>
                        <rx:Button ID="SelectedFileDownload" runat="server" Download="true" Text="Orjinal Dosyayı Göster" Icon="ApplicationGo">
                            <AjaxEvents>
                                <Click OnEvent="Process">
                                </Click>
                            </AjaxEvents>
                        </rx:Button>
                        <rx:ToolbarFill ID="ToolbarFill1" runat="server">
                        </rx:ToolbarFill>
                        <rx:FileUpload ID="FileUpload1" runat="server" Hidden="true">
                        </rx:FileUpload>
                        <rx:ToolbarSeparator ID="ToolbarSeparator1" runat="server">
                        </rx:ToolbarSeparator>
                        <rx:ToolbarButton ID="DownloadFile" runat="server" Icon="DiskUpload" Text="FTP_FILE_DOWNLOAD">
                            <AjaxEvents>
                                <Click OnEvent="DownloadFileOnEvent">
                                </Click>
                            </AjaxEvents>
                        </rx:ToolbarButton>
                    </Items>
                </rx:ToolBar>
            </BottomBar>
        </rx:GridPanel>
        <rx:PanelX ID="PanelX2" runat="server" AutoWidth="true" AutoHeight="Normal" Height="50"
            Padding="true">
            <Body>
                <rx:ColumnLayout ID="ColumnLayout3" runat="server" ColumnWidth="30">
                    <Rows>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="CrmComboComp1" ObjectId="201100125" UniqueName="new_CorporationId"
                                    FieldLabel="Kurum" FieldLabelWidth="80" Width="100" PageSize="50" RequirementLevel="BusinessRequired">

                                    <DataContainer>
                                        <DataSource OnEvent="new_CrmComboComp1Load">
                                        </DataSource>
                                    </DataContainer>

                                    <Listeners>
                                        <Change Handler="CrmComboComp2.clear();" />
                                    </Listeners>
                                </cc1:CrmComboComp>
                                <cc1:CrmDateFieldComp runat="server" ID="new_Date1" ObjectId="201100125" UniqueName="new_Date1"
                                    RequirementLevel="BusinessRequired" FieldLabelWidth="100" Width="130">
                                </cc1:CrmDateFieldComp>
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
                                    Width="100" LookupViewUniqueName="FROM_FTP_IMPORT" PageSize="50">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100125" FromUniqueName="new_CorporationId" ToObjectId="201100125"
                                            ToUniqueName="new_CorporationId" ComponentId="CrmComboComp1" />
                                    </Filters>
                                </cc1:CrmComboComp>
                                <cc1:CrmDateFieldComp runat="server" ID="new_Date2" ObjectId="201100125" UniqueName="new_Date2"
                                    RequirementLevel="BusinessRequired" FieldLabelWidth="100" Width="130" LookupViewUniqueName="FROM_FTP_IMPORT">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout ID="ColumnLayout5" runat="server" ColumnWidth="30">
                    <Rows>
                        <rx:RowLayout ID="RowLayout5" runat="server">
                            <Body>
                                <rx:Button ID="btnFind" runat="server" Icon="ApplicationSideTree" Text="CRM_FIND">
                                    <AjaxEvents>
                                        <Click OnEvent="GetFtpReadFile">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:GridPanel ID="GridFtpRead" runat="server" AutoHeight="Auto" AutoWidth="true"
            DisableSelection="true" Mode="Local">
            <DataContainer>
                <DataSource>
                    <Columns>
                        <rx:Column Name="FtpType" />
                        <rx:Column Name="FtpTypeName" />
                        <rx:Column Name="FileName" />
                        <rx:Column Name="FilePath" />
                        <rx:Column Name="FilePathDownload" />
                        <rx:Column Name="FtpReadFileHeaderId" />
                        <rx:Column Name="CorporationName" />
                        <rx:Column Name="FileDirectionName" />
                        <rx:Column Name="TotalCount" DataType="Int" />
                        <rx:Column Name="DownloadCount" DataType="Int" />
                        <rx:Column Name="NotErrorCount" DataType="Int" />
                        <rx:Column Name="ErrorCount" DataType="Int" />
                        <rx:Column Name="Aktar" DataType="Boolean" />
                        <rx:Column Name="Onay" DataType="Boolean" />
                        <rx:Column Name="TransferDate" />
                        <rx:Column Name="Currency" />
                        <rx:Column Name="TransferStatusName" />
                    </Columns>
                </DataSource>
                <Sorts>
                    <rx:DataSorts Name="TransferDate" Direction="Desc" />
                </Sorts>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="RowSelectionModel2" runat="server">
                    <AjaxEvents>
                        <RowDblClick OnEvent="RowSelect">
                        </RowDblClick>
                    </AjaxEvents>
                </rx:RowSelectionModel>
            </SelectionModel>
            <Listeners>
                <LoadComplete Handler="DrawError();" />
            </Listeners>
            <ColumnModel>
                <Columns>
                    <rx:GridColumns DataIndex="Aktar" Width="70" MenuDisabled="true" Sortable="false"
                        ColumnType="Check" Editable="false">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="Onay" Width="115" MenuDisabled="true" Sortable="false"
                        ColumnType="Check" Editable="false">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="TransferStatusName" Width="200" Header="TransferStatusName" MenuDisabled="true"
                        Sortable="false">
                    </rx:GridColumns>



                    <rx:GridColumns DataIndex="TransferDate" Width="100" Header="TransferDate" MenuDisabled="true"
                        Sortable="true">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="FtpTypeName" Width="80" Header="FtpTypeName" MenuDisabled="true"
                        Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="FileDirectionName" Width="80" Header="FileDirectionName"
                        MenuDisabled="true" Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="FileName" Width="250" Header="Dosya Adı" MenuDisabled="true" Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="FilePath" Width="350" Header="Fiziksel Yol" MenuDisabled="true" Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="CorporationName" Width="130" Header="CorporationName"
                        MenuDisabled="true" Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="TotalCount" Width="80" Header="TotalCount" MenuDisabled="true"
                        Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="DownloadCount" Width="80" Header="DownloadCount" MenuDisabled="true"
                        Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="NotErrorCount" Width="80" Header="NotErrorCount" MenuDisabled="true"
                        Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="ErrorCount" Width="80" Header="ErrorCount" MenuDisabled="true"
                        Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="Currency" Width="200" Header="Currency" MenuDisabled="true"
                        Sortable="false">
                    </rx:GridColumns>
                    <rx:GridColumns DataIndex="FtpReadFileHeaderId" Width="300" Header="FtpReadFileHeaderId"
                        MenuDisabled="true" Sortable="false" Hidden="true">
                    </rx:GridColumns>
                </Columns>
            </ColumnModel>
        </rx:GridPanel>
        <rx:Container ID="SelectedFileDownloadPanel" runat="server">
        </rx:Container>
    </form>
    <rx:Window ID="FtpReadFileDetail" runat="server" Width="900" Height="500" Modal="true"
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
                <SpecialSettings>
                    <rx:RowExpander Template="<br/><br/><span style='color:red'>{new_ConfirmErrorCode} : {new_ConfirmErrorLogText}</span><br/><br/><span>Kullanıcı Açıklaması : </span><span>{new_UserDescription}</span>"
                        Collapsed="true" />
                </SpecialSettings>
                <Listeners>
                    <LoadComplete Handler="ErrorRender();" />
                </Listeners>
                <BottomBar>
                    <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="FtpReadFileDetailGridPanel">
                        <Buttons>
                            <rx:SmallButton Icon="Transmit" ID="btnTransfer" Text="CRM_TRANSFER">
                                <AjaxEvents>
                                    <Click OnEvent="btnTransferOnEvent">
                                    </Click>
                                </AjaxEvents>
                            </rx:SmallButton>
                            <rx:SmallButton Icon="Accept" ID="btnApproved" Text="CRM_APPROVED">
                                <AjaxEvents>
                                    <Click OnEvent="btnApprovedOnEvent">
                                    </Click>
                                </AjaxEvents>
                            </rx:SmallButton>
                            <rx:SmallButton Icon="TransmitError" ID="btnTransmitError" Text="CRM_TRANSFERGETERROR"
                                Download="true">
                                <AjaxEvents>
                                    <Click OnEvent="btnTransferErrorOnEvent">
                                        <EventMask ShowMask="true" />
                                    </Click>
                                </AjaxEvents>
                            </rx:SmallButton>
                            <rx:SmallButton Icon="NoteEdit" ID="NoteEdit" Text="CRM_NOTEEDIT">
                                <AjaxEvents>
                                    <Click OnEvent="btnNoteEdit">
                                        <EventMask ShowMask="true" />
                                    </Click>
                                </AjaxEvents>
                            </rx:SmallButton>
                            <rx:SmallButton Icon="Book" ID="btnGetFtpTransferLog" Text="Aktarım Logları">
                                <AjaxEvents>
                                    <Click OnEvent="btnFtpTransferLogOnEvent">
                                    </Click>
                                </AjaxEvents>
                            </rx:SmallButton>
                            <rx:SmallButton Icon="Book" ID="btnUpdateStatus" Text="Tekrar Başlat">
                                <AjaxEvents>
                                    <Click OnEvent="btnFtpUpdateStatusBack">
                                    </Click>
                                </AjaxEvents>
                            </rx:SmallButton>
                            <%--  <rx:SmallButton Icon="NoteError" ID="AkbFromCorp" Text="CRM_AKBFROMCORP">
                                <AjaxEvents>
                                    <Click OnEvent="btnAkbFromCorp">
                                        <EventMask ShowMask="true" />
                                    </Click>
                                </AjaxEvents>
                            </rx:SmallButton>--%>
                        </Buttons>
                    </rx:PagingToolBar>
                </BottomBar>
                <LoadMask ShowMask="true" />
            </rx:GridPanel>
            <rx:GridPanel runat="server" ID="TotalGrid" AutoWidth="true" AutoHeight="Normal"
                Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
                <DataContainer>
                    <DataSource OnEvent="TotalGridDataSource">
                        <Columns>
                            <rx:Column Name="Quantity" DataType="Int">
                            </rx:Column>
                            <rx:Column Name="TotalAmount" DataType="Decimal">
                            </rx:Column>
                            <rx:Column Name="Currency" DataType="String">
                            </rx:Column>
                        </Columns>
                    </DataSource>
                    <Parameters>
                        <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                        <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                    </Parameters>
                </DataContainer>
                <ColumnModel>
                    <Columns>
                        <rx:GridColumns Align="Right" Width="100" DataIndex="Quantity" Header="Quantity">
                        </rx:GridColumns>
                        <rx:GridColumns Align="Right" Width="100" DataIndex="TotalAmount" Header="TotalAmount">
                        </rx:GridColumns>
                        <rx:GridColumns DataIndex="Currency" Width="100" Header="Currency">
                        </rx:GridColumns>
                    </Columns>
                </ColumnModel>
                <SelectionModel>
                    <rx:RowSelectionModel ID="RowSelectionModel3" runat="server" ShowNumber="true">
                    </rx:RowSelectionModel>
                </SelectionModel>
                <LoadMask ShowMask="true" />
            </rx:GridPanel>
        </Body>
    </rx:Window>
    <rx:Window ID="Window1" runat="server" Width="600" Height="100" Modal="true" Border="false"
        Closable="true" Maximizable="false" Resizable="true" CloseAction="Hide" ShowOnLoad="false"
        Title="CRM_NOTE" Icon="NoteEdit">
        <Body>
            <cc1:CrmTextFieldComp ID="new_UserNote" runat="server" ObjectId="201100124"
                UniqueName="new_UserNote" FieldLabelWidth="100" Width="450">
            </cc1:CrmTextFieldComp>
        </Body>
        <Buttons>
            <rx:Button ID="btnUpdate" runat="server" Icon="NoteEdit" Text="CRM_NOTEUPDATE">
                <AjaxEvents>
                    <Click OnEvent="btnUpdateOnEvent">
                    </Click>
                </AjaxEvents>
            </rx:Button>
            <rx:Button ID="btnCancel" runat="server" Icon="Cancel" Text="CRM_NOTECANCEL">
                <Listeners>
                    <Click Handler="Window1.hide();"></Click>
                </Listeners>
            </rx:Button>
        </Buttons>
    </rx:Window>
    <rx:Window ID="Window2" runat="server" Width="600" Height="400" Modal="true" Border="false"
        Closable="true" Maximizable="false" Resizable="true" CloseAction="Hide" ShowOnLoad="false"
        Icon="NoteEdit">
        <Body>
            <rx:TextAreaField ID="FileContent" runat="server" Height="350" Width="600">
            </rx:TextAreaField>
        </Body>
        <Buttons>
            <rx:Button ID="Button2" runat="server" Icon="Cancel" Text="CRM.NEW_TRANSFER_BTN_CLOSE">
                <Listeners>
                    <Click Handler="Window2.hide();"></Click>
                </Listeners>
            </rx:Button>
        </Buttons>
    </rx:Window>
    <rx:Window ID="wFptTransferLog" runat="server" Width="900" Height="680" Modal="true"
        Border="false" Closable="true" Maximizable="false" Resizable="true" CloseAction="Hide"
        ShowOnLoad="false" Title="Ftp Dosya Aktarım Log">
        <Body>
            <rx:PanelX ID="pnl123" runat="server" Height="200" AutoHeight="Normal">
                <Body>
                    <rx:Fieldset ID="field1" runat="server" Height="50" Title="Aktarım Logları">
                        <Body>
                            <rx:ColumnLayout ID="column11" runat="server" ColumnWidth="50%">
                                <Rows>
                                    <rx:RowLayout ID="row123" runat="server">
                                        <Body>
                                            <rx:Label ID="lblFtpReadFileHeaderName" runat="server" Font-Bold="true" Font-Size="Medium"></rx:Label>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout ID="ColumnLayout8" runat="server" ColumnWidth="20%">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout8" runat="server">
                                        <Body>
                                            <rx:Label ID="lblCorporatioNamen" runat="server" Font-Bold="true" Font-Size="Medium"></rx:Label>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout ID="ColumnLayout9" runat="server" ColumnWidth="13%">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout9" runat="server">
                                        <Body>
                                            <rx:Button runat="server" ID="btnExcelTotal" Text="Tümünü Listele">
                                                <AjaxEvents>
                                                    <Click OnEvent="FptTransferLogDetailGridPanelOnLoad">
                                                        <ExtraParams>
                                                            <rx:Parameter Name="FullList" Value="1" Mode="Value" />
                                                        </ExtraParams>
                                                    </Click>
                                                </AjaxEvents>
                                            </rx:Button>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                             <rx:ColumnLayout ID="ColumnLayout13" runat="server" ColumnWidth="10%">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout13" runat="server">
                                        <Body>
                                            <rx:Button Download="true" Icon="PageWhiteExcel" runat="server" ID="btnPartialFullList" Text="Parçalı Dosyaları Listele">
                                                <AjaxEvents>
                                                    <Click OnEvent="FptTransferAllPartialLogDetailGridPanelOnLoad">
                                                        <ExtraParams>
                                                            <rx:Parameter Name="PartialFullList" Value="1" Mode="Value" />
                                                        </ExtraParams>
                                                    </Click>
                                                </AjaxEvents>
                                            </rx:Button>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>

                        </Body>
                    </rx:Fieldset>
                    <rx:GridPanel runat="server" ID="FptTransferLogGridPanel" AutoWidth="true" AutoHeight="Normal"
                        Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
                        <DataContainer>
                            <DataSource OnEvent="FptTransferLogGridPanelOnLoad">
                            </DataSource>
                            <Parameters>
                                <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                                <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                            </Parameters>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Width="200" DataIndex="CreatedOn" Header="Aktarma Tarihi">
                                </rx:GridColumns>
                                <rx:GridColumns Width="200" DataIndex="CreatedByName" Header="Aktaran Kullanıcı">
                                </rx:GridColumns>
                                <rx:GridColumns Width="150" DataIndex="TransferedCount" Header="Aktarılan Adet">
                                </rx:GridColumns>
                                <rx:GridColumns Width="150" DataIndex="ErrorCount" Header="Hata alan adet">
                                </rx:GridColumns>
                                <rx:GridColumns DataIndex="ID" Width="100" Header="ID" Hidden="true">
                                </rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel6" runat="server">
                                <AjaxEvents>
                                    <RowDblClick OnEvent="FtpTransferLogSelect">
                                    </RowDblClick>
                                </AjaxEvents>
                            </rx:RowSelectionModel>
                        </SelectionModel>

                        <LoadMask ShowMask="true" />
                    </rx:GridPanel>
                </Body>
            </rx:PanelX>
            <rx:PanelX ID="PanelX3" runat="server" Height="450" AutoHeight="Normal">
                <Body>
                    <rx:Fieldset ID="Fieldset1" runat="server" Height="50" Title="Aktarım Log Detayı">
                        <Body>
                            <rx:ColumnLayout ID="ColumnLayout10" runat="server" ColumnWidth="30">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout10" runat="server">
                                        <Body>
                                            <rx:CheckField runat="server" ID="chckSuccess" Checked="true" FieldLabel="Başarılı">
                                                <AjaxEvents>
                                                    <Change OnEvent="FptTransferLogDetailGridPanelOnLoad">
                                                        <EventMask ShowMask="false" />

                                                    </Change>
                                                </AjaxEvents>
                                            </rx:CheckField>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout ID="ColumnLayout11" runat="server" ColumnWidth="30">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout11" runat="server">
                                        <Body>
                                            <rx:CheckField runat="server" ID="chckError" Checked="true" FieldLabel="Başarısız">
                                                <AjaxEvents>
                                                    <Change OnEvent="FptTransferLogDetailGridPanelOnLoad">
                                                        <EventMask ShowMask="false" />

                                                    </Change>
                                                </AjaxEvents>
                                            </rx:CheckField>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout ID="ColumnLayout12" runat="server" ColumnWidth="30">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout12" runat="server">
                                        <Body>
                                            
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>

                        </Body>
                    </rx:Fieldset>
                    <rx:GridPanel runat="server" ID="fptTransferLogDetailGridPanel" AutoWidth="true" AutoHeight="Normal"
                        Height="320" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
                        <DataContainer>
                            <DataSource OnEvent="FptTransferLogDetailGridPanelOnLoad">
                            </DataSource>
                            <Parameters>
                                <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                                <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                            </Parameters>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Width="200" DataIndex="CreatedOn" Header="Aktarma Tarihi">
                                </rx:GridColumns>
                                <rx:GridColumns Width="200" DataIndex="CreatedByName" Header="Aktaran Kullanıcı">
                                </rx:GridColumns>
                                <rx:GridColumns Width="150" DataIndex="TransferedCount" Header="Aktarılan Adet">
                                </rx:GridColumns>
                                <rx:GridColumns Width="150" DataIndex="ErrorCount" Header="Hata alan adet">
                                </rx:GridColumns>
                                <rx:GridColumns DataIndex="ID" Width="100" Header="ID" Hidden="true">
                                </rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel4" runat="server">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                        <BottomBar>
                            <rx:PagingToolBar runat="server" ID="PagingToolBar2" Enabled="true" ControlId="fptTransferLogDetailGridPanel">
                                <Buttons>
                                    <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload">
                                        <AjaxEvents>
                                            <Click OnEvent="FptTransferLogDetailGridPanelOnLoad">
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
                </Body>
            </rx:PanelX>
        </Body>
    </rx:Window>

</body>

</html>
