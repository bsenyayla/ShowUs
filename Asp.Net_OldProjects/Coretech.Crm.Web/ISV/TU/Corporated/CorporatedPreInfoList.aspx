<%@ Page Language="C#" AutoEventWireup="true" Inherits="CorporatedPreInfoList" Codebehind="CorporatedPreInfoList.aspx.cs" %>
 
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
            
            defaulteditpageid = "012B2D8A-3078-4226-8C5C-6EA607FB02C9";

            if (hdnStatusId.getValue() == 0 || hdnStatusId.getValue() == 1) {
                var config = "/ISV/TU/Corporated/CorporatedPreInfoNewRegistrationControl.aspx?StatusId=" + hdnStatusId.getValue() + "&RecordId=" + hdnRecId.getValue();
                var title = "Tüzel Onboarding Başvuru Belge Kontrol Ekranı";
                window.top.newWindow(config, { title: title, width: 900, height: 600, resizable: false });
            } else if (hdnStatusId.getValue() == 2) {
                var config = "../ISV/TU/Corporated/CorporatedPreInfoStepCargo.aspx?StatusId=" + hdnStatusId.getValue() + "&RecordId=" + hdnRecId.getValue();
                var title = "Tüzel Onboarding Başvuru Kurye Aşamasında Ekranı";
                window.top.newWindow(config, { title: title, width: 800, height: 400, resizable: false });
            } else {
                return;
            }

            //var config = "/CrmPages/AutoPages/EditReflex.aspx?ObjectId=201900037&recId=" + hdnRecId.getValue() + "&defaulteditpageid=" + defaulteditpageid + "&SourceFormType=NormList";

            
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
                            <Event Handler="GridPanelCorporatedPreInfoList.reload();" />
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
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="40%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout101" runat="server">
                            <Body>

                                            <cc1:CrmComboComp runat="server" ID="new_New_CorporatedType" ObjectId="201900030" UniqueName="new_New_CorporatedType"
                                                Width="150" PageSize="50" FieldLabel="150">
                                            </cc1:CrmComboComp>

                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_StatusId" ObjectId="201900030" UniqueName="new_StatusId"
                                    Width="150" PageSize="50" FieldLabel="150">
                                 </cc1:CrmPicklistComp>

                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="60%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>

                                <rx:MultiField runat="server" ID="mfsender" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmTextFieldComp ID="new_CorparateCentralRegistryServiceNumber" runat="server" ObjectId="201900030" UniqueName="new_CorparateCentralRegistryServiceNumber"
                                            FieldLabelWidth="150" Width="150" PageSize="50" FieldLabelShow="True">
                                        </cc1:CrmTextFieldComp>


                                    </Items>
                                </rx:MultiField> 


                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout10">
                            <Body>

                                <rx:MultiField runat="server" ID="MultiField1" FieldLabelShow="True">
                                    <Items>
                                        <cc1:CrmTextFieldComp ID="new_CorparateName" runat="server" ObjectId="201900030" UniqueName="new_CorparateName"
                                            FieldLabelWidth="150" Width="150" PageSize="50" FieldLabelShow="True">
                                        </cc1:CrmTextFieldComp>


                                    </Items>
                                </rx:MultiField>                                
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="50%">
                    <Rows>

                        <rx:RowLayout ID="RowLayout11" runat="server">
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
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnRefresh" Text="" Icon="Magnifier"
                    Width="120">
                    <Listeners>
                        <Click Handler="GridPanelCorporatedPreInfoList.reload();"></Click>
                    </Listeners>

                </rx:Button>
            </Buttons>
        </rx:PanelX>
  
            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
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
                        
                            <rx:GridColumns ColumnId="CorparateName" Width="250" Header="Firma Unvan" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="CorparateName" />

                            <rx:GridColumns ColumnId="new_UserNameSurname" Width="100" Header="Yetkili" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_UserNameSurname" />

                            <rx:GridColumns ColumnId="new_MobilePhone" Width="100" Header="Telefon" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_MobilePhone" />

                            <rx:GridColumns ColumnId="new_EMail" Width="200" Header="E-Mail" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_EMail" />

                            <rx:GridColumns ColumnId="new_CorparateTaxNo" Width="100" Header="Vergi Numarası" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_CorparateTaxNo" />

                            <rx:GridColumns ColumnId="new_New_CorporatedTypeName" Width="100" Header="Firma Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_New_CorporatedTypeName" />

                            <rx:GridColumns ColumnId="new_StatusId" Width="100" Header="new_StatusId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="new_StatusId" />

                            <rx:GridColumns ColumnId="new_StatusIdName" Width="150" Header="Durum" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="new_StatusIdName" />

                            <rx:GridColumns ColumnId="CreatedOn" Width="150" Header="İşlem Tarih" Sortable="true"
                            MenuDisabled="true" Hidden="false" DataIndex="CreatedOn"/>
                    </Columns>
                </ColumnModel>
                <SelectionModel>
                    <rx:RowSelectionModel ID="gpSenderDocumentRowSelectionModel" runat="server" ShowNumber="true"
                        SingleSelect="true">
                        <Listeners>
                            <RowDblClick Handler="hdnRecId.setValue(GridPanelCorporatedPreInfoList.selectedRecord.Id);hdnStatusId.setValue(GridPanelCorporatedPreInfoList.selectedRecord.new_StatusId);ShowDetail();"></RowDblClick>
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
