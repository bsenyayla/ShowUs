<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_Detail_ProblemTransactionPool" ValidateRequest="false" CodeBehind="_ProblemTransactionPool.aspx.cs" %>

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
        <rx:Hidden ID="RowCount" runat="server"></rx:Hidden>
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
                    <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="132" AutoWidth="true"
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
                            <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="40%">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout1" runat="server">
                                        <Body>
                                            <%--<cc1:CrmComboComp ID="new_SenderCountryID" runat="server" ObjectId="201100097" UniqueName="new_SenderCountryID"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                            </cc1:CrmComboComp>--%>
                                            <cc1:CrmComboComp runat="server" ID="new_SenderCountryID" ObjectId="201100097"
                                                UniqueName="new_SenderCountryID" Width="150"
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
                                            <cc1:CrmComboComp runat="server" ID="new_CorporationId" ObjectId="201100097" UniqueName="new_CorporationId"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                                <Filters>
                                                    <cc1:ComboFilter FromObjectId="201100097" FromUniqueName="new_SenderCountryID" ToObjectId="201100034"
                                                        ToUniqueName="new_SenderCountryID" />
                                                </Filters>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout ID="Rl1" runat="server">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_OfficeId" ObjectId="201100097" UniqueName="new_OfficeId"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                                <Filters>
                                                    <cc1:ComboFilter FromObjectId="201100097" FromUniqueName="new_CorporationId" ToObjectId="201100040"
                                                        ToUniqueName="new_CorporationID" />
                                                </Filters>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>

                                    <rx:RowLayout runat="server" ID="RowLayout5">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_FormReceiverCountryId" ObjectId="201100097" UniqueName="new_FormReceiverCountryId"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>

                                    <rx:RowLayout runat="server" ID="RowLayout3">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_RecipientCorporationId" ObjectId="201100097" UniqueName="new_RecipientCorporationId"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
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
                                                    <cc1:CrmTextFieldComp ID="new_FileTransactionNumber" runat="server" ObjectId="201100072"
                                                        UniqueName="new_FileTransactionNumber" FieldLabelWidth="160" Width="230">
                                                    </cc1:CrmTextFieldComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>



                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="28%">
                                <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout6">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_FormTransactionTypeID" ObjectId="201100097"
                                                LookupViewUniqueName="TRANSACTIONTYPE_GONDERIM" UniqueName="new_FormTransactionTypeID"
                                                FieldLabelWidth="160" Width="100" PageSize="50">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>




                                </Rows>
                            </rx:ColumnLayout>
                        </Body>
                        <Buttons>
                            <rx:Button runat="server" ID="BtnBugFix" Text="Hata Ayıkla" Icon="Bug" Width="100">
                                <AjaxEvents>
                                    <Click OnEvent="BtnBugFixOnEvent" Before="
                                        var x = document.getElementsByClassName('xtb-text')[2].innerText
                                        var rowCount = x.substring(x.indexOf('/') + 1, x.lenght);
                                        if(rowCount.trim() == '0')
                                        {
                                            alert('Listede hiç kayıt bulunamadı.'); return false;
                                        }
                                        else
                                        {
                                            var fileTransactionNumber = GridPanelMonitoring.selectedRecord.new_FileTransactionNumber;    
                                            if(fileTransactionNumber.match(/HATA_PTP/))
                                            {
                                                alert('bu kayıt için daha önce aksiyon alınmış.'); return false;
                                            }
                                            if(fileTransactionNumber == null || fileTransactionNumber == '')
                                            {
                                                alert('Bu kayıt aksiyon almaya uygun değil'); return false;
                                            }
                                        }
                                        ">
                                    </Click>
                                </AjaxEvents>
                            </rx:Button>
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
                <rx:CheckSelectionModel ID="CheckSelectionModel1" runat="server"
                    ShowNumber="true">
                    <Listeners>
                        <RowDblClick Handler="ShowWindow(GridPanelMonitoring.id,GridPanelMonitoring.selectedRecord.ID,201100072,1);" />
                    </Listeners>
                </rx:CheckSelectionModel>
            </SelectionModel>

          
            <BottomBar>
                <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelMonitoring">
                    <Buttons>
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
    </form>
</body>
</html>
