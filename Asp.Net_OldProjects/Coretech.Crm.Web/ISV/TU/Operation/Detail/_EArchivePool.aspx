<%@ Page Language="C#" AutoEventWireup="true" Inherits="_EArchivePool_Monitoring" ValidateRequest="false" CodeBehind="_EArchivePool.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        function ShowTransferDocument() {
            var config = "../ISV/TU/Transfer/TransferDocument.aspx?ObjectId=" + operationTypeId.getValue() + "&RecordId=" + transferId.getValue();
            window.top.newWindow(config, { title: 'Mobile Document', width: 800, height: 500, resizable: false });
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
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript">
    

    </script>
    <style type="text/css">
        .auto-style1 {
            width: 100%;
        }

        .auto-style2 {
            width: 38px;
        }
    </style>
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
        <rx:Hidden ID="hdnViewListTotal" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnViewDefaultEditPage" runat="server">
        </rx:Hidden>
        <rx:Hidden ID="hdnPoolId" runat="server" Value="1">
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
                    <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="190" AutoWidth="true"
                        Title="SEARCH">

                        <Body>
                            <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="40%">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout1" runat="server">
                                        <Body>
                                            <%--<cc1:CrmComboComp ID="new_SenderCountryID" runat="server" ObjectId="201100097" UniqueName="new_SenderCountryID"
                                                FieldLabelWidth="100" Width="130" PageSize="50" >
                                            </cc1:CrmComboComp>--%>
                                            <cc1:CrmComboComp runat="server" ID="new_SenderCountryID" ObjectId="201100097"
                                                UniqueName="new_SenderCountryID" Width="50" FieldLabelWidth="500" ColumnLayoutLabelWidth="500"
                                                PageSize="500" Mode="Remote">
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
                                    <rx:RowLayout runat="server">
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
                                    <rx:RowLayout runat="server" ID="RowLayout16">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_PayingCorporationId" ObjectId="201100097" UniqueName="new_PayingCorporationId"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout20">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_PayingOfficeId" ObjectId="201100097" UniqueName="new_PayingOfficeId"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                                <Filters>
                                                    <cc1:ComboFilter FromObjectId="201100097" FromUniqueName="new_PayingCorporationId" ToObjectId="201100040"
                                                        ToUniqueName="new_CorporationID" />
                                                </Filters>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout9">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_FormConfirmStatusId" ObjectId="201100097"
                                                UniqueName="new_FormConfirmStatusId" FieldLabelWidth="70" Width="230" PageSize="50"
                                                LookupViewUniqueName="CONFIRM_STATUS_LOOKUP">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>

                                    <rx:RowLayout runat="server" ID="RowLayout19">
                                        <Body>
                                            <cc1:CrmTextFieldComp runat="server" ID="new_FileTransactionNumber" ObjectId="201100097"
                                                UniqueName="new_FileTransactionNumber" FieldLabelWidth="70" Width="230" PageSize="50">
                                            </cc1:CrmTextFieldComp>
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
                                    <rx:RowLayout runat="server" ID="RowLayout3">
                                        <Body>
                                            <rx:MultiField ID="MultiField1" runat="server">
                                                <Items>
                                                    <cc1:CrmDecimalComp ID="new_FormAmount1" runat="server" ObjectId="201100097" UniqueName="new_FormAmount1"
                                                        FieldLabelWidth="160" Width="100">
                                                    </cc1:CrmDecimalComp>
                                                    <rx:Label runat="server" Text="  " ID="Label1" Width="10">
                                                    </rx:Label>
                                                    <cc1:CrmDecimalComp ID="new_FormAmount2" runat="server" ObjectId="201100097" FieldLabelShow="false"
                                                        UniqueName="new_FormAmount2" FieldLabelWidth="160" Width="100">
                                                    </cc1:CrmDecimalComp>
                                                    <rx:Label runat="server" Text="  " ID="Label3" Width="10" />

                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>

                                    <rx:RowLayout runat="server" ID="RowLayout5">
                                        <Body>
                                            <rx:MultiField ID="MultiField4" runat="server">
                                                <Items>
                                                    <cc1:CrmComboComp runat="server" ID="new_FormTransactionAmountCurrency" ObjectId="201100097"
                                                        UniqueName="new_FormTransactionAmountCurrency" FieldLabelWidth="160" Width="70"
                                                        PageSize="50" FieldLabelShow="true">
                                                    </cc1:CrmComboComp>
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
                                    <%--                                    <rx:RowLayout runat="server" ID="RowLayout21">
                                        <Body>
                                            <rx:MultiField ID="MultiField6" runat="server">
                                                <Items>
                                                    <cc1:CrmTextFieldComp ID="new_SerialNumber" runat="server" ObjectId="201100097"
                                                        UniqueName="new_SerialNumber" FieldLabelWidth="110" Width="230">
                                                    </cc1:CrmTextFieldComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>--%>


                                    <%--
                                    <rx:RowLayout runat="server" ID="RowLayout10">
                                        <Body>
                                            <rx:MultiField ID="MultiField2" runat="server">
                                                <Items>
                                                    <cc1:CrmPicklistComp runat="server" ID="new_OperationType" ObjectId="201100097" UniqueName="new_OperationType"
                                                        FieldLabelWidth="160" Width="230">
                                                    </cc1:CrmPicklistComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>
                                    --%>
                                 <rx:RowLayout runat="server" ID="RowLayout13">
                                        <Body>
                                            <rx:ComboField ID="cmbEArchiveOperationType" runat="server" FieldLabel="İşlem Tipi" FieldLabelWidth="160" Width="230" AutoWidth="false">
                                                <Items>
                                                    <rx:ListItem Text="Tümü" Value="" />
                                                    <rx:ListItem Text="Gönderim" Value="0" />
                                                    <rx:ListItem Text="Ödeme" Value="1" />
                                                    <rx:ListItem Text="Gönderim Iptal" Value="2" />
                                                    <rx:ListItem Text="Gönderim Iade" Value="3" />
                                                </Items>
                                            </rx:ComboField>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout10">
                                        <Body>
                                            <rx:ComboField ID="cmbEArchiveTransactionStatus" runat="server" FieldLabel="Tarama Durumu" FieldLabelWidth="160" Width="230" AutoWidth="false">
                                                <Items>
                                                    <rx:ListItem Text="Tümü" Value="" />
                                                    <rx:ListItem Text="Tarama Bekliyor" Value="10" />
                                                    <rx:ListItem Text="Eksik Evrak" Value="20" />
                                                    <rx:ListItem Text="Tamamlandı" Value="100" />
                                                </Items>
                                            </rx:ComboField>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout22">
                                        <Body>
                                            <rx:MultiField ID="MultiField3" runat="server">
                                                <Items>
                                                    <cc1:CrmDateFieldComp ID="new_PaymentDate2" runat="server" DateMode="Date" ObjectId="201100097"
                                                        UniqueName="new_PaymentDate2" FieldLabelWidth="160" Width="100" MaxLength="300">
                                                    </cc1:CrmDateFieldComp>
                                                    <rx:Label runat="server" Text="  " ID="Label2" Width="10">
                                                    </rx:Label>
                                                    <cc1:CrmDateFieldComp ID="new_PaymentDate3" runat="server" ObjectId="201100097" FieldLabelShow="false"
                                                        UniqueName="new_PaymentDate2" FieldLabelWidth="100" Width="100">
                                                    </cc1:CrmDateFieldComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>
                                    <%--                                    <rx:RowLayout runat="server" ID="RowLayout14">
                                        <Body>
                                            <rx:MultiField ID="MultiField4" runat="server">
                                                <Items>
                                                    <cc1:CrmDateFieldComp ID="new_CancelDate1" runat="server" DateMode="Date" ObjectId="201100097"
                                                        UniqueName="new_CancelDate" FieldLabelWidth="110" Width="100" MaxLength="300">
                                                    </cc1:CrmDateFieldComp>
                                                    <rx:Label runat="server" Text="  " ID="Label4" Width="10">
                                                    </rx:Label>
                                                    <cc1:CrmDateFieldComp ID="new_CancelDate2" runat="server" DateMode="Date" ObjectId="201100097"
                                                        FieldLabelShow="false" UniqueName="new_CancelDate" FieldLabelWidth="100" Width="100">
                                                    </cc1:CrmDateFieldComp>
                                                </Items>
                                            </rx:MultiField>
                                        </Body>
                                    </rx:RowLayout>--%>
                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="28%">
                                <Rows>
  
                                    <%--                                    <rx:RowLayout runat="server" ID="RowLayout13">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_FormSourceTransactionTypeID" ObjectId="201100097"
                                                LookupViewUniqueName="TRANSACTIONTYPE_TAHSILAT" UniqueName="new_FormSourceTransactionTypeID"
                                                FieldLabelWidth="100" Width="100" PageSize="50">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>--%>
                                    <rx:RowLayout runat="server" ID="RowLayout7">
                                        <Body>
                                            <%--<cc1:CrmComboComp runat="server" ID="new_FormReceiverCountryId" ObjectId="201100097"
                                                UniqueName="new_FormReceiverCountryId" FieldLabelWidth="100" Width="100" PageSize="50">
                                            </cc1:CrmComboComp>--%>
                                            <cc1:CrmComboComp runat="server" ID="new_FormReceiverCountryId" ObjectId="201100097"
                                                UniqueName="new_FormReceiverCountryId" Width="150"
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
                                    <%--                                    <rx:RowLayout runat="server" ID="RowLayout5">
                                        <Body>
                                            <cc1:CrmTextFieldComp runat="server" ID="new_FormCustomerNumber" ObjectId="201100097"
                                                UniqueName="new_FormCustomerNumber" FieldLabelWidth="100" Width="100">
                                            </cc1:CrmTextFieldComp>
                                        </Body>
                                    </rx:RowLayout>--%>
                                    <rx:RowLayout runat="server" ID="RowLayout8">
                                        <Body>
                                            <cc1:CrmTextFieldComp runat="server" ID="new_SenderId" ObjectId="201100097" UniqueName="new_SenderId"
                                                FieldLabelWidth="100" Width="100">
                                            </cc1:CrmTextFieldComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout11">
                                        <Body>
                                            <cc1:CrmTextFieldComp runat="server" ID="new_RecipientFullName" ObjectId="201100097"
                                                UniqueName="new_RecipientFullName" FieldLabelWidth="100" Width="100" PageSize="50">
                                            </cc1:CrmTextFieldComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout15">
                                        <Body>
                                            <%--                                            <cc1:CrmComboComp runat="server" ID="new_RecipientCorporationId" ObjectId="201100097" UniqueName="new_RecipientCorporationId"
                                                FieldLabelWidth="70" Width="230" PageSize="50">
                                            </cc1:CrmComboComp>--%>

                                            <cc1:CrmComboComp runat="server" ID="new_RecipientCorporationId" ObjectId="201100097"
                                                UniqueName="new_RecipientCorporationId" Width="150"
                                                PageSize="500" FieldLabel="200" Mode="Remote">
                                                <DataContainer>
                                                    <DataSource OnEvent="new_RecipientCorporationLoad">
                                                    </DataSource>
                                                </DataContainer>
                                                <Listeners>
                                                </Listeners>
                                                <AjaxEvents>
                                                </AjaxEvents>
                                            </cc1:CrmComboComp>

                                        </Body>
                                    </rx:RowLayout>
                                    <%--                                    <rx:RowLayout runat="server" ID="RowLayout18">
                                        <Body>
                                            <cc1:CrmPicklistComp runat="server" ID="new_Channel" ObjectId="201100097" UniqueName="new_Channel"
                                                FieldLabelWidth="70" Width="230" PageSize="50">
                                            </cc1:CrmPicklistComp>
                                        </Body>
                                    </rx:RowLayout>--%>
                                      <rx:RowLayout runat="server" ID="RowLayout23">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="new_InstructionStartCorporationId" ObjectId="201100097" UniqueName="new_InstructionStartCorporationId"
                                                FieldLabelWidth="70" Width="230" PageSize="50">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                        </Body>
                        <Buttons>
           
                            <rx:Button runat="server" ID="ToolbarButtonFind" Text="(F9)" Icon="MagnifierZoomIn"
                                Width="100">
                                <Listeners>
                                    <Click Handler="GridPanelConfirmHistory.reload();" />
                                </Listeners>
                            </rx:Button>
                            
                        </Buttons>
                    </rx:PanelX>
                </td>
            </tr>
        </table>


               <rx:Hidden ID="operationTypeId" runat="server"></rx:Hidden>
                <rx:Hidden ID="transferId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnObjectId" runat="server"></rx:Hidden>
            <rx:GridPanel runat="server" ID="GridPanelConfirmHistory" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
                Height="300" AutoLoad="false" Width="1200" Mode="Remote" AjaxPostable="true">
                <DataContainer>
                    <DataSource OnEvent="EArchivePoolList">
                    </DataSource>
                    <Parameters>
                        <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                        <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                    </Parameters>
                </DataContainer>  
                <ColumnModel>
                    <Columns>
                        <rx:GridColumns ColumnId="TRANSFERID" Width="100" Header="TRANSFERID" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="TRANSFERID" />
                        <rx:GridColumns ColumnId="TRANSFERTUREF" Width="100" Header="UPT Referans" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TRANSFERTUREF" />
                        <rx:GridColumns ColumnId="TRANSACTION_TIME" Width="100" Header="İşlem Zamanı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TRANSACTION_TIME">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="OPERATIONTYPENAME" Width="100" Header="İşlem Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="OPERATIONTYPENAME">                            
                        </rx:GridColumns>

                        <rx:GridColumns ColumnId="SIGNATURECUSTOMERINFO" Width="100" Header="Form İmza" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SIGNATURECUSTOMERINFO">       
                            <Renderer Handler="return ActionTemplate(record.data.SIGNATURECUSTOMERINFO)" />                     
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="SIGNATUREIPAZ" Width="100" Header="Ipaz Izni İmza" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SIGNATUREIPAZ">              
                            <Renderer Handler="return ActionTemplate(record.data.SIGNATUREIPAZ)" />              
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="SIGNATUREKVKK" Width="100" Header="Kvkk İmza" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SIGNATUREKVKK">        
                            <Renderer Handler="return ActionTemplate(record.data.SIGNATUREKVKK)" />                    
                        </rx:GridColumns>


                        <rx:GridColumns ColumnId="Pasaport" Width="100" Header="Pasaport" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="Pasaport">
                            <Renderer Handler="return ActionTemplate(record.data.PASAPORT)" />
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="KIMLIK_ON" Width="100" Header="Kimlik Ön" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="KIMLIK_ON">
                            <Renderer Handler="return ActionTemplate(record.data.KIMLIK_ON)" />
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="KIMLIK_ARKA" Width="100" Header="Kimlik Arka" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="KIMLIK_ARKA">
                            <Renderer Handler="return ActionTemplate(record.data.KIMLIK_ARKA)" />
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="TALIMAT_FORMU" Width="100" Header="Talimat Formu" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TALIMAT_FORMU">
                            <Renderer Handler="return ActionTemplate(record.data.TALIMAT_FORMU)" />
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="Dekont" Width="100" Header="Dekont" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="Dekont">
                            <Renderer Handler="return ActionTemplate(record.data.DEKONT)" />
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="IPTAL_DEKONT" Width="100" Header="Iptal Dekont" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="IPTAL_DEKONT">
                            <Renderer Handler="return ActionTemplate(record.data.IPTAL_DEKONT)" />
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="IADE_DEKONT" Width="100" Header="Iade Dekont" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="IADE_DEKONT">
                            <Renderer Handler="return ActionTemplate(record.data.IADE_DEKONT)" />
                        </rx:GridColumns>

                        <rx:GridColumns ColumnId="OPERATIONTYPE" Width="100" Header="OPERATIONTYPE" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="OPERATIONTYPE" />

                        <rx:GridColumns ColumnId="STATUS" Width="100" Header="Durum" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="STATUS" Editable="false">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="AMOUNT" Width="100" Header="Tutar" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="AMOUNT" Editable="false">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="AMOUNT_CURRENCY_NAME" Width="100" Header="Döviz Cinsi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="AMOUNT_CURRENCY_NAME" Editable="false">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="SENDER" Width="200" Header="Gönderici" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SENDER" Editable="false">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="RECIPIENT" Width="200" Header="Alıcı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="RECIPIENT" Editable="false">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="SENDER_CORPORATION" Width="150" Header="Gonderen Kurum" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SENDER_CORPORATION" Editable="false">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="SENDER_OFFICE" Width="150" Header="Gonderen Ofis" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="SENDER_OFFICE" Editable="false">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="TRANSFER_OWNING_USERNAME" Width="100" Header="İşlem Yapan" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TRANSFER_OWNING_USERNAME" Editable="false">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="PAIDBYOFFICENAME" Width="100" Header="Ödeme Yapan Ofis" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="PAIDBYOFFICENAME" Editable="false">
                        </rx:GridColumns>
                    </Columns>
                </ColumnModel>
                <SelectionModel>
                    <rx:RowSelectionModel ID="gpSenderDocumentRowSelectionModel" runat="server" ShowNumber="true"
                        SingleSelect="true">
                        <Listeners>
                            <RowDblClick Handler="operationTypeId.setValue(GridPanelConfirmHistory.selectedRecord.OPERATIONTYPE);transferId.setValue(GridPanelConfirmHistory.selectedRecord.TRANSFERID);ShowTransferDocument();"></RowDblClick>
                        </Listeners>
                        <AjaxEvents>
                        </AjaxEvents>
                    </rx:RowSelectionModel>
                </SelectionModel>
                <BottomBar>
                    <rx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="GridPanelConfirmHistory">
                    </rx:PagingToolBar>
                </BottomBar>
                <LoadMask ShowMask="true" />


            </rx:GridPanel>
 
    </form>
</body>
</html>
