<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false"
    Inherits="FtpFileTransfer__FileTransfer_FileTransferOutput" Codebehind="_FileTransferOutput.aspx.cs" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="FtpReadFileHeaderId">
        </rx:Hidden>
        <rx:PanelX ID="PanelX1" runat="server" AutoWidth="true" AutoHeight="Normal" Height="70"
            Padding="true">
            <Body>
                <rx:ColumnLayout ID="ColumnLayout3" runat="server" ColumnWidth="30">
                    <Rows>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="CrmComboComp1" ObjectId="201100125" UniqueName="new_CorporationId"
                                    FieldLabel="Kurum" FieldLabelWidth="80" Width="100" pagesize="50" RequirementLevel="BusinessRequired">

                                                                        <DataContainer>
                                        <DataSource OnEvent="new_CrmComboComp1Load">
                                        </DataSource>
                                    </DataContainer>

                                    <Listeners>
                                        <Change Handler="CrmComboComp2.clear();" />
                                    </Listeners>
                                </cc1:CrmComboComp>
                                <cc1:CrmDateFieldComp runat="server" ID="new_Date1" ObjectId="201100125" UniqueName="new_Date1"
                                    RequirementLevel="BusinessRecommend" FieldLabelWidth="100" Width="130">
                                </cc1:CrmDateFieldComp>
                                <cc1:CrmDateFieldComp runat="server" ID="new_PayDate1" ObjectId="201100125" UniqueName="new_PayDate1"
                                    RequirementLevel="BusinessRecommend" FieldLabelWidth="100" Width="130">
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
                                    Width="100" LookupViewUniqueName="FROM_FTP_IMPORT" pagesize="50">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100125" FromUniqueName="new_CorporationId" ToObjectId="201100125"
                                            ToUniqueName="new_CorporationId" ComponentId="CrmComboComp1" />
                                    </Filters>
                                </cc1:CrmComboComp>
                                <cc1:CrmDateFieldComp runat="server" ID="new_Date2" ObjectId="201100125" UniqueName="new_Date2"
                                    RequirementLevel="BusinessRecommend" FieldLabelWidth="100" Width="130" lookupviewuniquename="FROM_FTP_IMPORT">
                                </cc1:CrmDateFieldComp>
                                <cc1:CrmDateFieldComp runat="server" ID="new_PayDate2" ObjectId="201100125" UniqueName="new_PayDate2"
                                    RequirementLevel="BusinessRecommend" FieldLabelWidth="100" Width="130">
                                </cc1:CrmDateFieldComp>

                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout ID="ColumnLayout1" runat="server" ColumnWidth="30">
                    <Rows>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="CrmComboComp3" ObjectId="201100125" UniqueName="new_FtpReadFileHeaderId"
                                    RequirementLevel="BusinessRecommend" FieldLabel="FileHeader" FieldLabelWidth="80"
                                    Width="100" LookupViewUniqueName="FTPREADFILES" pagesize="50">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100125" FromUniqueName="new_FtpFileHeaderId" ToObjectId="201100123"
                                            ToUniqueName="new_FtpFileHeader" ComponentId="CrmComboComp2" />
                                    </Filters>
                                    <Listeners>
                                        <Blur Handler="fileControl();" />
                                    </Listeners>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:PanelX ID="PanelX2" runat="server" AutoWidth="true" AutoHeight="Normal" Height="30"
            Padding="true">
            <Body>
                <rx:ColumnLayout ID="ColumnLayout2" runat="server" ColumnWidth="30">
                    <Rows>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="FtpFileOutputHeaderId" ObjectId="201100125"
                                    UniqueName="new_FtpFileOutputHeaderId" RequirementLevel="BusinessRequired" FieldLabel="FileHeader"
                                    FieldLabelWidth="80" Width="100" LookupViewUniqueName="FTPFILEHEADEROUTPUT" pagesize="50">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100125" FromUniqueName="new_CorporationId" ToObjectId="201100125"
                                            ToUniqueName="new_CorporationId" ComponentId="CrmComboComp1" />
                                    </Filters>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
                <rx:Button ID="CreateFile" runat="server" Icon="ApplicationSideTree" Text="DOSYA_OLUSTUR"
                    Download="true">
                    <AjaxEvents>
                        <Click OnEvent="CreateFileOnEvent">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                <rx:Button ID="Button1" runat="server" Icon="Table" Text="DOSYA_LISTESI">
                    <Listeners>
                        <Click Handler="GridPanel1.reload();"></Click>
                    </Listeners>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
        <rx:GridPanel runat="server" ID="GridPanel1" AutoWidth="true" AutoHeight="Auto" Height="283"
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
                <rx:RowSelectionModel ID="FtpReadFileDetailGridPanelRowSelectionModel1" runat="server"
                    ShowNumber="true">
                </rx:RowSelectionModel>
            </SelectionModel>
            <BottomBar>
                <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanel1">
                </rx:PagingToolBar>
            </BottomBar>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>
        <script type="text/javascript">
            function fileControl() {
                new_Date1.clear();
                new_Date1.setReadOnly(!R.isEmpty(CrmComboComp3.getValue()));
                new_Date2.clear();
                new_Date2.setReadOnly(!R.isEmpty(CrmComboComp3.getValue()));
            }
        </script>
    </form>
</body>
</html>
