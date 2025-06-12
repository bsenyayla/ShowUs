<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_Detail_GsmTransactionPool" ValidateRequest="false" CodeBehind="_GsmTransactionPool.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script type="text/javascript">

        function ShowDetailWindow(UptReference, TransferId) {
            var url = window.top.GetWebAppRoot + "/ISV/TU/Operation/Detail/ProblemTransactionDetail.aspx?UptReference=" + UptReference + "&TransferId=" + TransferId;

            if (window != null) {
                url += "&tabframename=" + window.name;
                url += "&rlistframename=" + window.name
            }
            if (window.parent != null) {
                url += "&pawinid=" + window.parent.name;
                url += "&pframename=" + window.parent.name;
            }

            window.top.newWindowRefleX(url, { maximized: false, width: 900, height: 600, resizable: true, modal: true, maximizable: false });
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:KeyMap runat="server" ID="KeyMap1">
            <rx:KeyBinding>
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="ToolbarButtonFind.click(e);" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:KeyMap runat="server" ID="KeyMap2">
            <rx:KeyBinding Ctrl="true">
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="ToolbarButtonClear.click(e);" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:Hidden ID="hdnEntityId" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnRecid" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnViewList" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnViewDefaultEditPage" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnPoolId" runat="server" Value="4">
        </rx:Hidden>
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Button ID="btnInfo" runat="server" Download="True" Hidden="True">
            <AjaxEvents>
                <Click OnEvent="btnInformationOnEvent">
                </Click>
            </AjaxEvents>
        </rx:Button>
        <table style="width: 100%">
            <tr>
                <td>
                    <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="80" AutoWidth="true"
                        Border="true" Frame="true" Title="SEARCH">
                        <Tools>
                            <Items>
                                <rx:ToolButton IconCls="icon-information" runat="server" ID="btnInformation">
                                    <Listeners>
                                        <Click Handler="OpenHelp(1)" />
                                    </Listeners>
                                </rx:ToolButton>
                            </Items>
                        </Tools>
                        <Body>
                            <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="33%">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout1" runat="server">
                                        <Body>

                                            <cc1:CrmComboComp runat="server" ID="new_CountryId" ObjectId="201500026"
                                                UniqueName="new_CountryId" Width="150"
                                                PageSize="500" FieldLabel="200" Mode="Remote">
                                                <DataContainer>
                                                    <DataSource OnEvent="new_CountryLoad">
                                                    </DataSource>
                                                </DataContainer>
                                                <Listeners>
                                                </Listeners>
                                                <AjaxEvents>
                                                </AjaxEvents>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout4">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_SenderCorporationId" ObjectId="201500026" UniqueName="new_SenderCorporationId"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                                <Filters>
                                                    <cc1:ComboFilter FromObjectId="201500026" FromUniqueName="new_CountryId" ToObjectId="201100034"
                                                        ToUniqueName="new_CountryID" />
                                                </Filters>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout ID="Rl1" runat="server">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_SenderOfficeId" ObjectId="201500026" UniqueName="new_SenderOfficeId"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                                <Filters>
                                                    <cc1:ComboFilter FromObjectId="201500026" FromUniqueName="new_SenderCorporationId" ToObjectId="201100040"
                                                        ToUniqueName="new_CorporationID" />
                                                </Filters>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout runat="server" ID="ColoumnLayout2" ColumnWidth="33%">
                                <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout2">
                                        <Body>
                                            <rx:MultiField ID="RxM" runat="server">
                                                <Items>
                                                    <cc1:CrmDateFieldComp ID="new_FormTransactionDate1" runat="server" ObjectId="201100097"
                                                        UniqueName="new_FormTransactionDate1" FieldLabelWidth="160" Width="100">
                                                    </cc1:CrmDateFieldComp>
                                                    <rx:Label runat="server" Text="  " ID="lbl1" Width="10">
                                                    </rx:Label>
                                                    <cc1:CrmDateFieldComp ID="new_FormTransactionDate2" runat="server" ObjectId="201100097"
                                                        FieldLabelShow="false" UniqueName="new_FormTransactionDate2" FieldLabelWidth="100"
                                                        Width="100">
                                                    </cc1:CrmDateFieldComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>

                                    <rx:RowLayout runat="server" ID="RowLayout12">
                                        <Body>
                                            <rx:MultiField ID="MultiField12" runat="server">
                                                <Items>
                                                    <cc1:CrmTextFieldComp ID="ProcessMonitoring" runat="server" ObjectId="201100097"
                                                        UniqueName="ProcessMonitoring" FieldLabelWidth="160" Width="230">
                                                    </cc1:CrmTextFieldComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout9">
                                        <Body>
                                            <rx:MultiField ID="MultiField2" runat="server">
                                                <Items>
                                                    <cc1:CrmTextFieldComp ID="new_IntegrationReference" runat="server" ObjectId="201500026"
                                                        UniqueName="new_IntegrationReference" FieldLabelWidth="160" Width="230">
                                                    </cc1:CrmTextFieldComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>



                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="33%">
                                <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout7">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_GsmCountryId" ObjectId="201500026"
                                                RequirementLevel="None" UniqueName="new_GsmCountryId" Width="200"
                                                LookupViewUniqueName="GsmCountryComboView" PageSize="50" FieldLabelWidth="160" Mode="Remote">
                                                <DataContainer>
                                                    <DataSource OnEvent="new_GsmCountryIdLoad">
                                                    </DataSource>
                                                </DataContainer>
                                                <AjaxEvents>
                                                    <Change OnEvent="new_GsmCountryIdChangeOnEvent">
                                                    </Change>
                                                </AjaxEvents>

                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout3">
                                        <Body>
                                            <cc1:CrmPhoneFieldComp runat="server" ID="new_GsmNumber" ObjectId="201500026"
                                                UniqueName="new_GsmNumber" RequirementLevel="None" FieldLabel="200" Value=""
                                                HiddenCountryCode="false">
                                            </cc1:CrmPhoneFieldComp>
                                        </Body>
                                    </rx:RowLayout>




                                </Rows>
                            </rx:ColumnLayout>
                        </Body>
                        <Buttons>
                            <rx:Button runat="server" ID="UserPoolMap" Text="Alan Listesi" Icon="ApplicationViewList" Width="100">
                                <Listeners>
                                    <Click Handler="ShowUserPoolMap(hdnPoolId.getValue(),hdnViewList.getValue());" />
                                </Listeners>
                            </rx:Button>
                            <rx:Button runat="server" ID="ToolbarButtonLog" Text="(F9)" Icon="Book"
                                Width="100">
                                <Listeners>
                                    <Click Handler="LogWindow();" />
                                </Listeners>
                            </rx:Button>
                            <rx:Button runat="server" ID="ToolbarButtonFind" Text="(F9)" Icon="MagnifierZoomIn"
                                Width="100">
                                <Listeners>
                                    <Click Handler="GridPanelMonitoring.reload();" />
                                </Listeners>
                            </rx:Button>
                            <rx:Button runat="server" ID="ToolbarButtonClear" Text="(Ctrl+F9)" Icon="Erase">
                                <Listeners>
                                    <Click Handler="ToolbarButtonClearOnClik();" />
                                </Listeners>
                            </rx:Button>
                        </Buttons>
                    </rx:PanelX>
                </td>
            </tr>
        </table>
        <rx:GridPanel runat="server" ID="GridPanelMonitoring" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
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
                <DataSource OnEvent="ToolbarButtonFindClick">
                </DataSource>
                <Parameters>
                    <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                    <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                </Parameters>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server" ShowNumber="true"
                    SingleSelect="true">
                    <Listeners>
                        <%--<RowDblClick Handler="ShowDetailWindow(GridPanelMonitoring.id,GridPanelMonitoring.selectedRecord.ID);" />--%>
                        <RowDblClick Handler="ShowGsmPaymentClick(GridPanelMonitoring.selectedRecord.ID);" />
                    </Listeners>
                </rx:RowSelectionModel>
            </SelectionModel>
            <BottomBar>
                <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelMonitoring">
                </rx:PagingToolBar>
            </BottomBar>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>
    </form>
</body>
</html>
