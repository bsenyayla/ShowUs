<%@ Page Language="C#" AutoEventWireup="true"
    ValidateRequest="false" Inherits="Transfer_TransferEditMain" CodeBehind="TransferEditMain.aspx.cs" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <style>
        .Section3 {
            margin-bottom: 2px !important;
            padding: 5px !important;
            overflow: hidden !important;
        }
    </style>
    <script type="text/javascript">
       
    </script>
    <title></title>
     <script src="JS/TransferEditMainFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="New_TransferId" runat="server" />
        <rx:Hidden ID="New_TransferEditId" runat="server" />
        <rx:PanelX runat="server" ID="PanelX3" AutoHeight="Normal" Height="300" AutoWidth="true"
            CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientCountryID" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientCountryID" Width="150"
                                    PageSize="50" FieldLabel="200" LookupViewUniqueName="NAKIT_ODEMEYAPABILEN_ULKELER"
                                    Disabled="true" Mode="Remote">
                                </cc1:CrmComboComp>
                                <cc1:CrmComboComp runat="server" ID="new_TransactionTargetOptionID" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_TransactionTargetOptionID"
                                    Disabled="true" Width="150" PageSize="50" FieldLabel="150" Mode="Remote">
                                    <DataContainer>
                                        <DataSource OnEvent="new_TransactionTargetOptionIDOnEvent">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_RecipientIDChangeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                               <%-- <cc1:CrmComboComp runat="server" ID="new_ConfirmStatus" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_ConfirmStatus" Width="150"
                                    PageSize="50" FieldLabel="200" Disabled="true" Mode="Remote">
                                </cc1:CrmComboComp>--%>
                                <cc1:CrmBooleanComp ID="new_IbanisNotKnown" runat="server" ObjectId="201100072" UniqueName="new_IbanisNotKnown">
                                </cc1:CrmBooleanComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientIBAN" ObjectId="201100072"
                                    UniqueName="new_RecipientIBAN" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmComboComp runat="server" ID="new_EftBank" ObjectId="201100072" UniqueName="new_EftBank"
                                    Width="150" PageSize="50" FieldLabel="200">
                                </cc1:CrmComboComp>
                                <cc1:CrmComboComp runat="server" ID="new_EftCity" ObjectId="201100072" UniqueName="new_EftCity"
                                    Width="150" PageSize="50" FieldLabel="200">
                                </cc1:CrmComboComp>
                                <cc1:CrmComboComp runat="server" ID="new_EftBranch" ObjectId="201100072" UniqueName="new_EftBranch"
                                    Width="150" PageSize="50" FieldLabel="200">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100072" FromUniqueName="new_EftCity" ToObjectId="201100089"
                                            ToUniqueName="new_CityID" />
                                    </Filters>
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientAccountNumber" ObjectId="201100072"
                                    UniqueName="new_RecipientAccountNumber" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientCardNumber" ObjectId="201100072"
                                    UniqueName="new_RecipientCardNumber" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmComboComp runat="server" ID="new_EftPaymentMethodID" ObjectId="201100072"
                                    UniqueName="new_EftPaymentMethodID" Width="150" PageSize="50" FieldLabel="200">
                                </cc1:CrmComboComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientName" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientMiddleName" ObjectId="201100072"
                                    RequirementLevel="None" UniqueName="new_RecipientMiddleName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientLastName" ObjectId="201100072"
                                    RequirementLevel="BusinessRequired" UniqueName="new_RecipientLastName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderID" ObjectId="201100072" UniqueName="new_SenderID"
                                    Disabled="true" Width="150" PageSize="50" FieldLabel="150">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>
                                <rx:Button runat="server" ID="btnSenderEditUpdate" Icon="UserEdit" Text="SenderEditUpdate"
                                    Width="100">
                                    <Listeners>
                                        <Click Handler="window.top.IsvWindowContainer=window;ShowEditWindow(null,new_SenderID.getValue(),'8d6b7207-251c-4a08-a0fc-b52b7d490965','201100052');" />
                                    </Listeners>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout8">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientMotherName" ObjectId="201100072"
                                    UniqueName="new_RecipientMotherName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientFatherName" ObjectId="201100072"
                                    UniqueName="new_RecipientFatherName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <%--<cc1:CrmTextFieldComp runat="server" ID="new_RecipientHomeTelephone" ObjectId="201100072"
                                UniqueName="new_RecipientHomeTelephone" FieldLabel="200">
                            </cc1:CrmTextFieldComp>
                            <cc1:CrmTextFieldComp runat="server" ID="new_RecipientWorkTelephone" ObjectId="201100072"
                                UniqueName="new_RecipientWorkTelephone" FieldLabel="200">
                            </cc1:CrmTextFieldComp>--%>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientGSMCountryId" ObjectId="201100072"
                                    RequirementLevel="None" UniqueName="new_RecipientGSMCountryId" Width="150"
                                    LookupViewUniqueName="COUNTRYTELEPHONELOOKUP" PageSize="50" FieldLabel="200">
                                </cc1:CrmComboComp>
                                <cc1:CrmPhoneFieldComp runat="server" ID="new_RecipientGSM" ObjectId="201100072"
                                    UniqueName="new_RecipientGSM" RequirementLevel="None" FieldLabel="200"
                                    HiddenCountryCode="false">
                                </cc1:CrmPhoneFieldComp>
                                <cc1:CrmDateFieldComp ID="new_RecipientBirthDate" runat="server" ObjectId="201100072"
                                    UniqueName="new_RecipientBirthDate" FieldLabel="200">
                                </cc1:CrmDateFieldComp>
                                <cc1:CrmTextAreaComp runat="server" ID="new_RecipientAddress" ObjectId="201100072"
                                    Height="80" UniqueName="new_RecipientAddress" FieldLabel="200">
                                </cc1:CrmTextAreaComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="33%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout9">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipienNickName" ObjectId="201100072"
                                    UniqueName="new_RecipienNickName" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RecipientEmail" ObjectId="201100072"
                                    UniqueName="new_RecipientEmail" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:Fieldset runat="server" ID="PanelX2" AutoHeight="Normal" Height="190" AutoWidth="true"
            CustomCss="Section2" Title="Sender Information" Collapsed="false" Collapsible="true"
            Border="false">
            <AutoLoad Url="../Transfer/TransferSenderFind.aspx" />
            <Body>
            </Body>
        </rx:Fieldset>
        <rx:ToolBar runat="server" ID="ToolBarMain">
            <Items>
                <rx:ToolbarFill runat="server" ID="tf1" />
                <rx:ToolbarButton runat="server" ID="btnSave" runat="server" Icon="Disk" Text="Kaydet"
                    Width="100">
                    <AjaxEvents>
                        <Click OnEvent="btnSaveOnEvent" Before="CrmValidateForm(msg,e);">
                        </Click>
                    </AjaxEvents>
                </rx:ToolbarButton>
            </Items>
        </rx:ToolBar>
    </form>
</body>
</html>
