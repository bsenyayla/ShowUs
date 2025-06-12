<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_ApprovePool_DetailPool_CustAccountOpenCloseApprovePool" Codebehind="CustAccountOpenCloseApprovePool.aspx.cs" %>
<%@ Register Src="../../Sender/SenderFinde.ascx" TagPrefix="uc1" TagName="SenderFinde" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../Js/global.js"></script>
    <script src="./Js/Confirm.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:KeyMap runat="server" ID="KeyMap1">
            <rx:KeyBinding>
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="gpCustAccountOperationHeader.reload();" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="90" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Listele">
            <Tools>
                <Items>
                    <rx:ToolButton ToolTypeIcon="Refresh" runat="server" ID="btnInformation">
                        <Listeners>
                            <Click Handler="ClearAll();" />
                        </Listeners>
                    </rx:ToolButton>
                </Items>
            </Tools>
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout7" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountOperationTypeId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountOperationTypeId"
                                    FieldLabelWidth="100" Width="130" PageSize="50" LookupViewUniqueName="CUSTACCOUNTOPERATIONTYPE_NOT_TRANSACTIONAL">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout101" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountTypeId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountTypeId"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>

                                <rx:MultiField runat="server" ID="mfsender" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmComboComp ID="new_SenderId" runat="server" ObjectId="201500039" UniqueName="new_SenderId"
                                            FieldLabelWidth="100" Width="200" PageSize="50" FieldLabelShow="False">
                                        </cc1:CrmComboComp>
                                       <rx:Button runat="server" ID="btnSenderFinde" Icon="Magnifier">
                                           <Listeners>
                                               <Click Handler="UptSenderSelector.Show();"></Click>
                                           </Listeners>
                                       </rx:Button>

                                    </Items>
                                </rx:MultiField>


                            </Body>
                        </rx:RowLayout>
                    </Rows>

                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout2" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountCurrencyId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountCurrencyId"
                                    FieldLabelWidth="100" Width="130" PageSize="50" LookupViewUniqueName="CURRENCY_TR">
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout8" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_CorporationId" runat="server" ObjectId="201500039" UniqueName="new_CorporationId"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_OfficeId" runat="server" ObjectId="201500039" UniqueName="new_OfficeId"
                                    FieldLabelWidth="100" Width="130" PageSize="50">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201500039" FromUniqueName="new_CorporationId" ToObjectId="201100040"
                                            ToUniqueName="new_CorporationID" />
                                    </Filters>
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout10">
                            <Body>
                                <rx:MultiField runat="server" ID="CreatedOnmf" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmDateFieldComp ID="CreatedOnS" runat="server" ObjectId="201500039" UniqueName="CreatedOn"
                                            FieldLabelShow="False" Width="70" PageSize="50">
                                        </cc1:CrmDateFieldComp>
                                        <cc1:CrmDateFieldComp ID="CreatedOnE" runat="server" ObjectId="201500039" UniqueName="CreatedOn"
                                            FieldLabelShow="False" Width="70" PageSize="50">
                                        </cc1:CrmDateFieldComp>

                                    </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout11" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountApprovePoolStatusRef" runat="server" ObjectId="201600009" UniqueName="new_CustAccountApprovePoolStatusRef">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnRefresh" Text="" Icon="Magnifier"
                    Width="120">
                    <Listeners>
                        <Click Handler="gpCustAccountOperationHeader.reload();"></Click>
                    </Listeners>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
        <rx:GridPanel runat="server" ID="gpCustAccountOperationHeader" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
            <Tools>
                <Items>
                    <rx:ToolButton runat="server" ID="ToolButton1" ToolTypeIcon="Maximize">
                        <Listeners>
                            <Click Handler="gpCustAccountOperationHeader.fullScreen();" />
                        </Listeners>
                    </rx:ToolButton>
                </Items>
            </Tools>
            <DataContainer>
                <DataSource OnEvent="GpCustAccountOperationHeaderReload">
                </DataSource>
                <Parameters>
                    <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                    <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                </Parameters>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="gpCustAccountOperationHeaderRowSelectionModel1" runat="server" 
                    ShowNumber="true">
                    <Listeners>
                        <RowDblClick Handler="ShowConfirmWindow(gpCustAccountOperationHeader.selectedRecord.ID);" />
                    </Listeners>
                </rx:RowSelectionModel>
            </SelectionModel>
            <BottomBar>
                <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="gpCustAccountOperationHeader">
                </rx:PagingToolBar>
            </BottomBar>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>


        <uc1:SenderFinde runat="server" ID="SenderFinde" SelectedFunction="SetUser();"  />
    </form>
</body>
</html>
<script>
    function SetUser() {
        //   debugger;

        if (UptSenderSelector.SelectedSender.length > 0)
            new_SenderId.setValue(UptSenderSelector.SelectedSender[0].Value, UptSenderSelector.SelectedSender[0].Key);
    }

    function ClearAll() {
        var objArr = new Array();

        if (typeof (new_CustAccountOperationTypeId) != "undefined")
            objArr.push(new_CustAccountOperationTypeId);
        if (typeof (new_CustAccountTypeId) != "undefined")
            objArr.push(new_CustAccountTypeId);
        if (typeof (new_SenderId) != "undefined")
            objArr.push(new_SenderId);
        if (typeof (new_CustAccountCurrencyId) != "undefined")
            objArr.push(new_CustAccountCurrencyId);
        if (typeof (new_CorporationId) != "undefined")
            objArr.push(new_CorporationId);
        if (typeof (new_OfficeId) != "undefined")
            objArr.push(new_OfficeId);
        if (typeof (CreatedOnS) != "undefined")
            objArr.push(CreatedOnS);
        if (typeof (CreatedOnE) != "undefined")
            objArr.push(CreatedOnE);
        if (typeof (new_CustAccountApprovePoolStatusRef) != "undefined")
            objArr.push(new_CustAccountApprovePoolStatusRef);

        for (var i = 0; i < objArr.length; i++) {
            objArr[i].clear();
            objArr[i].focus();
        }
    }
</script>