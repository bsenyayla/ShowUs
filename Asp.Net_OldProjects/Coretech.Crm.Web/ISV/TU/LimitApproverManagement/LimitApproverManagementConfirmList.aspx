<%@ Page Language="C#" AutoEventWireup="true" Inherits="LimitApproverManagementConfirmList" Codebehind="LimitApproverManagementConfirmList.aspx.cs" ValidateRequest="false" %>
 
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
            
            
            if (hdnTransactionType.getValue() == 1) {
                islemTip = "yeniKayit";
            } else if (hdnTransactionType.getValue() == 2) {
                islemTip = "duzeltme";
            } else if (hdnTransactionType.getValue() == 3) {
                islemTip = "guncelleme";
            }

            if (hdnStatusId.getValue() == 2 ) {
                var config = "../ISV/TU/LimitApproverManagement/LimitApproverManagementDetailConfirmScreen.aspx?StatusId=" + hdnStatusId.getValue() + "&RecordId=" + hdnRecId.getValue() + "&IslemTip=" + islemTip;
                var title = "Limit ve Onaycı Yönetimi - Onay";
                window.top.newWindow(config, { title: title, width: 800, height: 400, resizable: false });
            } else {
                return;
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
        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="90" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Listele">
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

<%--                <rx:Button runat="server" ID="btnAccept" Text="Onayla" Icon="Accept"
                    Width="100">
                  <AjaxEvents>
                      <Click OnEvent="btnAcceptEditUpdate_Click" ></Click>
                  </AjaxEvents>
                </rx:Button>
                <rx:Button runat="server" ID="btnCancel" Text="Reddet" Icon="Cancel"
                    Width="100">
                    <AjaxEvents>
                      <Click OnEvent="btnCancelEditUpdate_Click" ></Click>
                  </AjaxEvents>
                </rx:Button>--%>
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

