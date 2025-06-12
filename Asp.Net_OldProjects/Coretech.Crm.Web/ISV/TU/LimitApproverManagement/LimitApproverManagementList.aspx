<%@ Page Language="C#" AutoEventWireup="true" Inherits="LimitApproverManagementList" Codebehind="LimitApproverManagementList.aspx.cs" ValidateRequest="false" %>
 
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
            var islemTip = "";
            defaulteditpageid = "012B2D8A-3078-4226-8C5C-6EA607FB02C9";

            /*
            if (hdnTransactionType.getValue() == 1)
                islemTip == "yeniKayit";
            else if (hdnTransactionType.getValue() == 2)
                islemTip == "duzeltme";
            else if (hdnTransactionType.getValue() == 3)
                islemTip == "guncelleme";
            */

            //statü onay bekliyor ise, işlem tipi Düzeltme Olarak açılır
            if (hdnStatusId.getValue() == 2) {
                islemTip = "guncelleme"
                var config = "../ISV/TU/LimitApproverManagement/LimitApproverManagementDetail.aspx?StatusId=" + hdnStatusId.getValue() + "&RecordId=" + hdnRecId.getValue() + "&IslemTip=" + islemTip;
                var title = "Limit ve Onaycı Yönetimi - Onay";
            } else if (hdnStatusId.getValue() == 3) {
                islemTip = "yeniKayit"
                var config = "../ISV/TU/LimitApproverManagement/LimitApproverManagementDetail.aspx?StatusId=" + hdnStatusId.getValue() + "&RecordId=" + hdnRecId.getValue() + "&IslemTip=" + islemTip;
                var title = "Limit ve Onaycı Yönetimi - Onay";
            } else if (hdnStatusId.getValue() == 4) {
                islemTip = "duzeltme"
                var config = "../ISV/TU/LimitApproverManagement/LimitApproverManagementDetail.aspx?StatusId=" + hdnStatusId.getValue() + "&RecordId=" + hdnRecId.getValue() + "&IslemTip=" + islemTip;
                var title = "Limit ve Onaycı Yönetimi - Onay";
            } else {
                return;
            }


            window.top.newWindow(config, { title: title, width: 1000, height: 600, resizable: false });
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
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="40%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout101" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderId" ObjectId="202000027" UniqueName="new_SenderId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" LookupViewUniqueName="Kurumsal Gönderici Listesi_Mobile" RequirementLevel="None" AutoLoad="true" >
                                    <DataContainer>
                                        <DataSource OnEvent="newSenderLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                         <Change OnEvent="SenderOnChange">
                                         </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                   <cc1:CrmComboComp runat="server" ID="new_SenderPersonId" ObjectId="202000027" UniqueName="new_SenderPersonId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" LookupViewUniqueName="Yetkili Lookup" RequirementLevel="None" AutoLoad="true" >
                                    <DataContainer>
                                        <DataSource OnEvent="newSenderPersonLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_Status" ObjectId="202000027" UniqueName="new_Status"
                                    Width="150" PageSize="50" FieldLabel="150">
                                 </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="60%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout11" runat="server">
                            <Body>

                                <rx:MultiField runat="server" ID="CreatedOnmf" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmDateFieldComp ID="CreatedOnS" runat="server" ObjectId="202000027" UniqueName="CreatedOn"
                                            FieldLabelShow="False" Width="82" PageSize="50">
                                        </cc1:CrmDateFieldComp>
                                        <cc1:CrmDateFieldComp ID="CreatedOnE" runat="server" ObjectId="202000027" UniqueName="CreatedOn"
                                            FieldLabelShow="False" Width="82" PageSize="50">
                                        </cc1:CrmDateFieldComp>
                                    </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnNewRecord" Text="Yeni" Icon="Add"
                    Width="100">
                  <AjaxEvents>
                      <Click OnEvent="btnNewRecord_Click" ></Click>
                  </AjaxEvents>
                </rx:Button>
                <rx:Button runat="server" ID="btnRefresh" Text="" Icon="Magnifier"
                    Width="100">
                    <Listeners>
                        <Click Handler="GridPanelCorporatedPreInfoList.reload();"></Click>
                    </Listeners>
                </rx:Button>
            </Buttons>
        </rx:PanelX>
  
            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnTransactionType" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusId" runat="server"></rx:Hidden>
            <rx:GridPanel runat="server" ID="GridPanelCorporatedPreInfoList" AutoWidth="true" AutoHeight="Auto"
            Height="150" Editable="false" Mode="Remote" AutoLoad="false" Width="1200" AjaxPostable="true">
                <DataContainer>
                    <DataSource OnEvent="GpCorporatedPreInfoListReload">
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
                        
                            <rx:GridColumns ColumnId="SenderId" Width="100" Header="Id" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="SenderId" />

                            <rx:GridColumns ColumnId="SenderName" Width="250" Header="Firma Unvan" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SenderName" />

                            <rx:GridColumns ColumnId="SenderPersonId" Width="100" Header="SenderPersonId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="SenderPersonId" />

                            <rx:GridColumns ColumnId="SenderPersonName" Width="250" Header="Yetkili" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SenderPersonName" />

                            <rx:GridColumns ColumnId="new_TransactionType" Width="100" Header="new_TransactionType" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_TransactionType" />

                            <rx:GridColumns ColumnId="TransactionTypeName" Width="150" Header="İşlem Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TransactionTypeName" />

                            <rx:GridColumns ColumnId="new_Status" Width="100" Header="new_Status" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_Status" />

                            <rx:GridColumns ColumnId="new_StatusIdName" Width="150" Header="Durum" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_StatusIdName" />

                            <rx:GridColumns ColumnId="Olusturan" Width="150" Header="Oluşturan" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="Olusturan" />

                            <rx:GridColumns ColumnId="CreatedOn" Width="90" Header="Oluşturma Zamanı" Sortable="true"
                            MenuDisabled="true" Hidden="false" DataIndex="CreatedOn"/>

                            <rx:GridColumns ColumnId="Duzenleyen" Width="150" Header="Düzenleyen" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="Duzenleyen" />

                            <rx:GridColumns ColumnId="ModifiedTime" Width="150" Header="Düzenlenme Zamanı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ModifiedTime" />
                    </Columns>
                </ColumnModel>
                <SelectionModel>
                    <rx:RowSelectionModel ID="gpSenderDocumentRowSelectionModel" runat="server" ShowNumber="true"
                        SingleSelect="true">
                        <Listeners>
                            <RowDblClick Handler="hdnRecId.setValue(GridPanelCorporatedPreInfoList.selectedRecord.Id);hdnTransactionType.setValue(GridPanelCorporatedPreInfoList.selectedRecord.new_TransactionType);hdnStatusId.setValue(GridPanelCorporatedPreInfoList.selectedRecord.new_Status);ShowDetail();"></RowDblClick>
                        </Listeners>
                        <AjaxEvents>
                        </AjaxEvents>
                    </rx:RowSelectionModel>
                </SelectionModel>
                    <BottomBar>
                        <rx:PagingToolBar runat="server" ID="PagingToolBar1" Enabled="true" ControlId="GridPanelCorporatedPreInfoList">
                            <Buttons>
                                <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload">
                                    <AjaxEvents>
                                        <Click OnEvent="GpCorporatedPreInfoListReload">
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
