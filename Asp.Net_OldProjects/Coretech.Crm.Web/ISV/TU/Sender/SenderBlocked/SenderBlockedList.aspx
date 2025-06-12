<%@ Page Language="C#" AutoEventWireup="true" Inherits="SenderBlockedList" Codebehind="SenderBlockedList.aspx.cs" %>
 
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>

 
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script type="text/javascript">
        function ShowDetail() {
            //var config = "../ISV/TU/Transfer/TransferDocument.aspx?ObjectId=" + operationTypeId.getValue() + "&RecordId=" + transferId.getValue();
            var defaulteditpageid = "";
            
            if (corporateType.getValue() == 1) {
                defaulteditpageid = "1433D224-D027-EA11-A76F-A01D480B4D85";
                var config = "/CrmPages/AutoPages/EditReflex.aspx?ObjectId=201900037&recId=" + blockedId.getValue() + "&defaulteditpageid=" + defaulteditpageid + "&SourceFormType=NormList";
                window.top.newWindow(config, { title: 'Bloke Işlemi', width: 700, height: 300, resizable: false });
            } else {
                defaulteditpageid = "C40A4F65-D027-EA11-A76F-A01D480B4D85";
                var config = "/ISV/TU/Sender/SenderBlocked/SenderPersonBlockedForm.aspx?SourceForm=CustomerAccount&fromCustomerAccountScreen=2&RecordId=" + blockedId.getValue();
                window.top.newWindow(config, { title: 'Bloke Işlemi', width: 700, height: 500, resizable: false });
            }

        }

        function ActionTemplate(Value) {
            //if (TransferId == "" || Action == 0 || TuStatusCode == 'TR002A')
            //    return RefNumber;
            
            if (Value == 0)
                return "<img src='" + GetWebAppRoot + "/images/1495118945_error.png' width=12 height=12 />";
            else if (Value == 1)
                return "<img src='" + GetWebAppRoot + "/images/success.png' width=12 height=12 />";
            else
                return "<img src='" + GetWebAppRoot + "/images/ico_18_role_x.gif' width=12 height=12 />";
           

        }
    </script>
    <script src="../Js/global.js"></script>
        <style type="text/css">
        body .x-label
        {
            white-space: normal !important;
        }
    </style>
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
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="30%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout101" runat="server">
                            <Body>

                                            <cc1:CrmPicklistComp runat="server" ID="new_CustomerType" ObjectId="201900037" UniqueName="new_CustomerType"
                                                Width="150" PageSize="50" FieldLabel="150">
                                            </cc1:CrmPicklistComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_TransactionType" ObjectId="201900037" UniqueName="new_TransactionType"
                                    Width="150" PageSize="50" FieldLabel="150">
                                 </cc1:CrmPicklistComp>

                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="30%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>

                                <rx:MultiField runat="server" ID="mfsender" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmComboComp ID="new_SenderId" runat="server" ObjectId="201500039" UniqueName="new_SenderId"
                                            FieldLabelWidth="100" Width="200" PageSize="50" FieldLabelShow="False">
                                        </cc1:CrmComboComp>

                                    </Items>
                                </rx:MultiField>


                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout10">
                            <Body>
                                <rx:MultiField runat="server" ID="CreatedOnmf" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmDateFieldComp ID="CreatedOnS" runat="server" ObjectId="201500039" UniqueName="CreatedOn"
                                            FieldLabelShow="False" Width="82" PageSize="50">
                                        </cc1:CrmDateFieldComp>
                                        <cc1:CrmDateFieldComp ID="CreatedOnE" runat="server" ObjectId="201500039" UniqueName="CreatedOn"
                                            FieldLabelShow="False" Width="82" PageSize="50">
                                        </cc1:CrmDateFieldComp>

                                    </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="40%">
                    <Rows>

                        <rx:RowLayout ID="RowLayout11" runat="server">
                            <Body>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnAddCorporate" Text="Bireysel Müşteri" Icon="Add"
                    Width="150">
                  <AjaxEvents>
                      <Click OnEvent="btnAddCorporateEditUpdate_Click" ></Click>
                  </AjaxEvents>
                </rx:Button>
                <rx:Button runat="server" ID="btnAddCorporatePerson" Text="Tüzel Müşteri" Icon="Add"
                    Width="120">
                    <AjaxEvents>
                      <Click OnEvent="btnAddCorporatePersonEditUpdate_Click" ></Click>
                  </AjaxEvents>
                </rx:Button>
                <rx:Button runat="server" ID="btnRefresh" Text="" Icon="Magnifier"
                    Width="120">
                    <Listeners>
                        <Click Handler="GridPanelCorporateBlockedList.reload();"></Click>
                    </Listeners>

                </rx:Button>
            </Buttons>
        </rx:PanelX>
  
            <rx:Hidden ID="blockedId" runat="server"></rx:Hidden>
            <rx:Hidden ID="transactionTypeId" runat="server"></rx:Hidden>
            <rx:Hidden ID="corporateType" runat="server"></rx:Hidden>
        
            <rx:Hidden ID="transferId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnObjectId" runat="server"></rx:Hidden>
            <rx:GridPanel runat="server" ID="GridPanelCorporateBlockedList" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
                <DataContainer>
                    <DataSource OnEvent="GpCorporateBlockedListReload">
                    </DataSource>
                    <Parameters>
                        <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                        <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                    </Parameters>
                </DataContainer>  
                <ColumnModel>
                    <Columns>
                        <rx:GridColumns ColumnId="Id" Width="100" Header="Id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="Id" />
                        <rx:GridColumns ColumnId="CorporateType" Width="100" Header="CorporateType" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="CorporateType" />
                        <rx:GridColumns ColumnId="CorporateTypeName" Width="100" Header="Hesap Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="CorporateTypeName" />
                        <rx:GridColumns ColumnId="CustomerCode" Width="100" Header="Müşteri Kodu" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="CustomerCode" />
                        <rx:GridColumns ColumnId="SenderFullName" Width="250" Header="Müşteri İsim" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SenderFullName">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="IdentityNo" Width="100" Header="Kimlik No" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="IdentityNo">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="BirthDate" Width="100" Header="Doğum Tarihi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="BirthDate">                            
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="FatherName" Width="100" Header="Baba Adı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="FatherName">                            
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="TransactionType" Width="100" Header="İşlem Tip" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="TransactionType">                            
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="TransactionTypeName" Width="100" Header="İşlem Tip" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TransactionTypeName">                            
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="BlockedDate" Width="150" Header="Bloke İstek Tarihi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="BlockedDate">                            
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="BlockedReasonId" Width="100" Header="Bloke nedeni id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="BlockedReasonId">                            
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="Bloke Nedeni" Width="100" Header="Bloke Nedeni" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="BlockedReasonName">                            
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="BlockedStatus" Width="100" Header="Bloke Durum Id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="BlockedStatus">                            
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="BlockedStatusName" Width="100" Header="Durum" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="BlockedStatusName">                            
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="BlockedUserId" Width="100" Header="Bloke Eden Id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="BlockedUserId">                            
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="BlockedUserName" Width="100" Header="Bloke Eden" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="BlockedUserName">                            
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="BlockedApprovalUserId" Width="100" Header="Bloke Onaylayan Id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="BlockedApprovalUserId">                            
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="BlockedApprovalUserName" Width="100" Header="Bloke Onaylayan" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="BlockedApprovalUserName">                            
                        </rx:GridColumns>
                    </Columns>
                </ColumnModel>
                <SelectionModel>
                    <rx:RowSelectionModel ID="gpSenderDocumentRowSelectionModel" runat="server" ShowNumber="true"
                        SingleSelect="true">
                        <Listeners>
                            <RowDblClick Handler="blockedId.setValue(GridPanelCorporateBlockedList.selectedRecord.Id);transactionTypeId.setValue(GridPanelCorporateBlockedList.selectedRecord.TransactionType);corporateType.setValue(GridPanelCorporateBlockedList.selectedRecord.CorporateType);ShowDetail();"></RowDblClick>
                        </Listeners>
                        <AjaxEvents>
                        </AjaxEvents>
                    </rx:RowSelectionModel>
                </SelectionModel>
                <BottomBar>
                    <rx:PagingToolBar runat="server" ID="PagingToolBar2" ControlId="GridPanelCorporateBlockedList">
                    </rx:PagingToolBar>
                </BottomBar>
                <LoadMask ShowMask="true" />


            </rx:GridPanel>

    </form>
</body>
</html>
<script type="text/javascript">

    function Confirm() {
        Conti.confirm(
          DasMessages.NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM,
          Conti.MessageType.Question,
          "btnConfirm_Hidden.click();",
          ""
      );
    }
    function Reject() {
        Conti.confirm(
          DasMessages.NEW_CUSTACCOUNTOPERATION_SURE_REJECT,
          Conti.MessageType.Question,
          "btnReject_Hidden.click();",
          ""
      );
    }

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

        for (var i = 0; i < objArr.length; i++) {
            objArr[i].clear();
            objArr[i].focus();
        }
    }

</script>
