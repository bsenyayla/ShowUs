<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_ExcelImport_Import" Codebehind="Import.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR" />
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
    <rx:PanelX runat="server" ID="PnlMain" Frame="false" Border="false" AutoHeight="Full"
        AutoWidth="true">
        <Body>
            <rx:ColumnLayout runat="server" ID="c1" ColumnWidth="45%">
                <Rows>
                    <rx:RowLayout ID="RowLayout2" runat="server">
                        <Body>
                            <rx:ComboField RequirementLevel="BusinessRequired" ID="ImportDefinationId" FieldLabel="CRM.IMPORTDEFINATION_IMPORT_SHEMA"
                                runat="server" FieldLabelWidth="100" Width="130">
                            </rx:ComboField>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ColumnLayout runat="server" ID="c2" ColumnWidth="45%">
                <Rows>
                    <rx:RowLayout ID="RowLayout1" runat="server">
                        <Body>
                            <rx:FileUpload RequirementLevel="BusinessRequired" ID="ExcelFileUpload" FieldLabel="CRM.IMPORTDEFINATION_IMPORT_FILE"
                                runat="server" FieldLabelWidth="100" Width="130">
                            </rx:FileUpload>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="10%">
                <Rows>
                    <rx:RowLayout ID="RowLayout3" runat="server">
                        <Body>
                            <rx:Button ID="btnRefresh" runat="server" Icon="PageRefresh">
                            <Listeners>
                            <Click  Handler="location.reload(true);"/>
                            </Listeners>
                            </rx:Button>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
        </Body>
        <Buttons>
            <rx:Button ID="BtnTemplate" runat="server" Text="CRM.IMPORTDEFINATION_TEMPLATE" Icon="DiskDownload"
                Animate="false"  >
                <AjaxEvents >
                    <Click OnEvent="BtnTemplateClick">
                    </Click>
                </AjaxEvents>
            </rx:Button>
            <rx:Button ID="BtnUpload" runat="server" Text="CRM.IMPORTDEFINATION_UPLOAD" Icon="DiskUpload">
                <AjaxEvents>
                    <Click OnEvent="BtnUploadClick" Before="R.mask(this.id, 'File Uploading...', null, $R(this.id));" Success="R.unmask(this.id);"
                        >
                        <EventMask Msg="Excel Yükleniyor..." ShowMask="true" />
                    </Click>
                </AjaxEvents>
            </rx:Button>
        </Buttons>
    </rx:PanelX>
    <rx:GridPanel runat="server" ID="GridPanelMonitoring" AutoHeight="Auto" AutoWidth="true"
        DisableSelection="true" Mode="Local">
        <Tools>
            <Items>
                <rx:ToolButton runat="server" ID="ToolButton1" ToolTypeIcon="Maximize">
                    <Listeners>
                        <Click Handler="GridPanelMonitoring.fullScreen();" />
                    </Listeners>
                </rx:ToolButton>
            </Items>
        </Tools>
        <DataContainer>
            <DataSource>
                <Columns>
                    <rx:Column Name="ErrorDescription" />
                </Columns>
            </DataSource>
        </DataContainer>
        <%--<SpecialSettings>
            <rx:RowExpander Template="{ErrorDescription}"
                Collapsed="true" />
        </SpecialSettings>--%>
        <ColumnModel>
            <Columns>
                <rx:GridColumns DataIndex="ErrorDescription" Width="800">
                </rx:GridColumns>
            </Columns>
        </ColumnModel>
        <SelectionModel>
            <rx:RowSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server" ShowNumber="true"
                SingleSelect="true">
                <Listeners>
                    <RowDblClick Handler="alert(GridPanelMonitoring.selectedRecord.ErrorDescription);" />
                </Listeners>
            </rx:RowSelectionModel>
        </SelectionModel>
        <LoadMask ShowMask="true" />
    </rx:GridPanel>
    </form>
</body>
</html>
