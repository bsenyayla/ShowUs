<%@ Page Language="C#" AutoEventWireup="true" Inherits="Sender_SenderPersonApprovalList" ValidateRequest="false" CodeBehind="SenderPersonApprovalList.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../Js/global.js"></script>
    
</head>

<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
      <rx:Hidden runat="server" ID="hdnSenderPersonApproveID"></rx:Hidden>
     <rx:Hidden runat="server" ID="hdnActionType"></rx:Hidden>
        <rx:KeyMap runat="server" ID="KeyMap1">
            <rx:KeyBinding>
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="GpSenderPersonApprovalList.reload();" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="85" AutoWidth="true" Collapsed="false" Collapsible="False"
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
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="33%">
                    <Rows>
                          <rx:RowLayout runat="server" ID="RowLayout9">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderId" ObjectId="201500041" UniqueName="new_SenderId"
                                    LookupViewUniqueName="CORPORATED_SENDER_LIST" Width="150" PageSize="50"
                                    FieldLabel="150">
                                    <AjaxEvents>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                     <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_E_Mail" ObjectId="201500041" UniqueName="new_E_Mail"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                      
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="33%">
                    <Rows>                    
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdendificationNumber1" ObjectId="201500041" UniqueName="new_SenderIdendificationNumber1"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                      </Rows>
                </rx:ColumnLayout>         
                    
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnRefresh" Text="" Icon="Magnifier"
                    Width="50">
                    <Listeners>
                        <Click Handler="GpSenderPersonApprovalList.reload();"></Click>
                    </Listeners>
                </rx:Button>
            </Buttons>

        </rx:PanelX>
        <rx:GridPanel runat="server" ID="GpSenderPersonApprovalList" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
            <Tools>
                <Items>
                    <rx:ToolButton runat="server" ID="ToolButton1" ToolTypeIcon="Maximize">
                        <Listeners>
                            <Click Handler="GpSenderPersonApprovalList.fullScreen();" />
                        </Listeners>
                    </rx:ToolButton>
                </Items>
            </Tools>
            <DataContainer>
                <DataSource OnEvent="GpSenderPersonApprovalListReload">
                </DataSource>
                <Parameters>
                    <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                    <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                </Parameters>
            </DataContainer>

             <ColumnModel>
                    <Columns>
                        <rx:GridColumns ColumnId="Id" Width="100" Header="Id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="ID" />
                        <rx:GridColumns ColumnId="VALUE" Width="100" Header="Ad" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="VALUE" /> 
                         <rx:GridColumns ColumnId="Sender" Width="150" Header="Müşteri" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="Sender" />                  
                         <rx:GridColumns ColumnId="new_MiddleName" Width="100" Header="Orta Ad" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_MiddleName" />
                         <rx:GridColumns ColumnId="new_LastName" Width="100" Header="Soyad" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_LastName" />
                             <rx:GridColumns ColumnId="new_SenderIdendificationNumber1" Width="100" Header="Kimlik No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_SenderIdendificationNumber1" />
                        <rx:GridColumns ColumnId="new_NationalityIDName" Width="100" Header="Uyruk" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_NationalityIDName" />
                          <rx:GridColumns ColumnId="new_HomeCountryName" Width="150" Header="Ülke" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_HomeCountryName" />
                        <rx:GridColumns ColumnId="new_E_Mail" Width="150" Header="Mail Adresi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_E_Mail" />                    
                           <rx:GridColumns ColumnId="new_ActionType" Width="150" Header="İşlem Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_ActionType" />
                         <rx:GridColumns ColumnId="ActionTypeValue" Width="100" Header="İşlem Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="ActionTypeValue" />
                    </Columns>
                </ColumnModel>

            <SelectionModel>
                <rx:RowSelectionModel ID="GpSenderPersonApprovalRowSelectionModel" runat="server" ShowNumber="true"
                    SingleSelect="true">
                    <AjaxEvents>
                        <RowDblClick Before="hdnSenderPersonApproveID.setValue(GpSenderPersonApprovalList.selectedRecord.ID);hdnActionType.setValue(GpSenderPersonApprovalList.selectedRecord.ActionTypeValue)"
                            OnEvent="RowDblClickOnEvent">
                        </RowDblClick>
                    </AjaxEvents>
                </rx:RowSelectionModel>
            </SelectionModel>
            <BottomBar>
                <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GpSenderPersonApprovalList">
                </rx:PagingToolBar>
            </BottomBar>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>

    </form>
</body>
</html>

<script type="text/javascript">
    function RedirectToWindow(GridID) {
        var url = window.top.GetWebAppRoot;

    }

    function ClearAll() {
        var objArr = new Array();

        if (typeof (new_CustAccountTypeId) != "undefined")
            objArr.push(new_CustAccountTypeId);
        if (typeof (Sender) != "undefined")
            objArr.push(Sender);
        if (typeof (new_NationalityID) != "undefined")
            objArr.push(new_NationalityID);
        if (typeof (new_SenderNumber) != "undefined")
            objArr.push(new_SenderNumber);
        if (typeof (new_SenderIdendificationNumber1) != "undefined")
            objArr.push(new_SenderIdendificationNumber1);

        for (var i = 0; i < objArr.length; i++) {
            objArr[i].clear();
            objArr[i].focus();
        }
    }
</script>

