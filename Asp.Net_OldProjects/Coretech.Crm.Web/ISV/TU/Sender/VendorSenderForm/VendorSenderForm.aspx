<%@ Page Language="C#" AutoEventWireup="true" Inherits="Sender_VendorSenderForm_VendorSenderForm" Codebehind="VendorSenderForm.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<%@ Register Src="./MaskedTextControl/MaskedText.ascx" TagPrefix="uc1" TagName="MaskedTextField" %>
<%@ Register Src="./MaskedDateControl/MaskedDate.ascx" TagPrefix="uc2" TagName="MaskedDateField" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script src="../Js/VendorSenderFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:TextField runat="server" ID="hdnRecid" Hidden="true"></rx:TextField>
        <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="100%">
            <Rows>
                <rx:RowLayout runat="server" ID="RowLayout3">
                    <Body>
                        <rx:ToolBar runat="server" ID="toolBarOne">
                            <Items>
                                <rx:ToolbarButton runat="server" ID="btnSave" Icon="Disk">
                                    <AjaxEvents>
                                        <Click Before="ControlIfRequiredFieldsAreSet(e);" OnEvent="SaveClick">
                                        </Click>
                                    </AjaxEvents>
                                </rx:ToolbarButton>
                            </Items>

                        </rx:ToolBar>
                    </Body>
                </rx:RowLayout>
                <rx:RowLayout runat="server" ID="RowLayout4">
                    <Body>
                        <rx:PanelX runat="server" ID="pnl_General" AutoHeight="Normal" Height="80" AutoWidth="true" Collapsed="false" Collapsible="False"
                            Border="true" Frame="true">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="50%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout7">
                                            <Body>
                                                <cc1:CrmComboComp runat="server" ObjectId="201100052" UniqueName="new_NationalityID" ID="new_NationalityID" RequirementLevel="BusinessRequired">
                                                </cc1:CrmComboComp>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout8">
                                            <Body>
                                                <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdendificationNumber1" ObjectId="201100052" UniqueName="new_SenderIdendificationNumber1" RequirementLevel="BusinessRequired" />
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout5">
                                            <Body>
                                                <rx:Label ID="lblEmpty" runat="server"></rx:Label>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout11">
                                            <Body>
                                                <rx:Button runat="server" ID="KpsButton" Width="200">
                                                    <Listeners>
                                                        <Click Handler="SetKpsData();" />
                                                    </Listeners>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="50%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout1">
                                            <Body>
                                                <cc1:CrmComboComp runat="server" ObjectId="201100052" UniqueName="new_IdendificationCardTypeID" ID="new_IdendificationCardTypeID" RequirementLevel="BusinessRequired">
                                                </cc1:CrmComboComp>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout runat="server" ID="RowLayout2">
                                            <Body>
                                                <uc1:MaskedTextField runat="server" ID="new_IdentityNo" ObjectId="201100052" UniqueName="new_IdentityNo" ParentType="Container" RequirementLevel="BusinessRequired" />
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                            </Body>
                        </rx:PanelX>
                    </Body>
                </rx:RowLayout>
                <rx:RowLayout runat="server" ID="RowLayout6">
                    <Body>
                        <rx:PanelX runat="server" ID="PanelDetail" AutoHeight="Normal" Height="350" AutoWidth="true" Collapsed="false" Collapsible="False"
                            Border="true" Frame="false">
                            <Body>
                                <rx:Fieldset runat="server" ID="PanelIdentityInfo" AutoHeight="Normal" Height="100" AutoWidth="true"
                                    Collapsed="false" Collapsible="false" Border="false">
                                    <Body>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="50%">
                                            <Rows>
                                                <rx:RowLayout runat="server" ID="RowLayout9">
                                                    <Body>
                                                        <uc1:MaskedTextField runat="server" ID="new_Name" ObjectId="201100052" UniqueName="new_Name" ParentType="Container" RequirementLevel="BusinessRequired" />
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout12">
                                                    <Body>
                                                        <uc1:MaskedTextField runat="server" ID="new_MiddleName" ObjectId="201100052" UniqueName="new_MiddleName" ParentType="Container" RequirementLevel="None" />
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout14">
                                                    <Body>
                                                        <uc1:MaskedTextField runat="server" ID="new_LastName" ObjectId="201100052" UniqueName="new_LastName" ParentType="Container" RequirementLevel="BusinessRequired" />
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout15">
                                                    <Body>
                                                        <uc1:MaskedTextField runat="server" ID="new_BirthPlace" ObjectId="201100052" UniqueName="new_BirthPlace" ParentType="Container" RequirementLevel="BusinessRequired" />
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout16">
                                                    <Body>
                                                        <uc2:MaskedDateField runat="server" ID="new_BirthDate" ObjectId="201100052" UniqueName="new_BirthDate" ParentType="Container" RequirementLevel="BusinessRequired" />
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="50%">
                                            <Rows>
                                                <rx:RowLayout runat="server" ID="RowLayout10">
                                                    <Body>
                                                        <uc1:MaskedTextField runat="server" ID="new_MotherName" ObjectId="201100052" UniqueName="new_MotherName" ParentType="Container" RequirementLevel="None" />
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout13">
                                                    <Body>
                                                        <uc1:MaskedTextField runat="server" ID="new_FatherName" ObjectId="201100052" UniqueName="new_FatherName" ParentType="Container" RequirementLevel="None" />
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout17">
                                                    <Body>
                                                        <uc1:MaskedTextField runat="server" ID="new_PlaceOfIdendity" ObjectId="201100052" UniqueName="new_PlaceOfIdendity" ParentType="Container" RequirementLevel="None" />
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout18">
                                                    <Body>
                                                        <cc1:CrmDateFieldComp runat="server" ID="new_DateOfIdendity" ObjectId="201100052" UniqueName="new_DateOfIdendity" RequirementLevel="None" />
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout19">
                                                    <Body>
                                                        <cc1:CrmDateFieldComp runat="server" ID="new_ValidDateOfIdendity" ObjectId="201100052" UniqueName="new_ValidDateOfIdendity" RequirementLevel="None" />
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                    </Body>
                                </rx:Fieldset>
                                <rx:Fieldset runat="server" ID="PanelContactInfo" AutoHeight="Normal" Height="100" AutoWidth="true"
                                    Collapsed="false" Collapsible="false" Border="false">
                                    <Body>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="50%">
                                            <Rows>
                                                <rx:RowLayout runat="server" ID="RowLayout20">
                                                    <Body>
                                                        <cc1:CrmComboComp runat="server" ObjectId="201100052" UniqueName="new_HomeCountry" ID="new_HomeCountry" RequirementLevel="BusinessRequired">
                                                        </cc1:CrmComboComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout21">
                                                    <Body>
                                                        <cc1:CrmTextFieldComp runat="server" ObjectId="201100052" UniqueName="new_HomeCity" ID="new_HomeCity" RequirementLevel="BusinessRequired">
                                                        </cc1:CrmTextFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout22">
                                                    <Body>
                                                        <cc1:CrmNumberComp runat="server" ObjectId="201100052" UniqueName="new_HomeZipCode" ID="new_HomeZipCode" RequirementLevel="None">
                                                        </cc1:CrmNumberComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout23">
                                                    <Body>
                                                        <cc1:CrmComboComp runat="server" ObjectId="201100052" UniqueName="new_GSMCountryId" ID="new_GSMCountryId" RequirementLevel="BusinessRequired">
                                                            <Listeners>
                                                                <Change Handler="GsmCountryOnChange();" />
                                                            </Listeners>
                                                        </cc1:CrmComboComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout24">
                                                    <Body>
                                                        <cc1:CrmPhoneFieldComp runat="server" ObjectId="201100052" UniqueName="new_GSM" ID="new_GSM" RequirementLevel="BusinessRequired" />
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="50%">
                                            <Rows>
                                                <rx:RowLayout runat="server" ID="RowLayout25">
                                                    <Body>
                                                        <cc1:CrmTextAreaComp runat="server" ObjectId="201100052" UniqueName="new_HomeAdress" ID="new_HomeAdress" RequirementLevel="BusinessRequired">
                                                        </cc1:CrmTextAreaComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout26">
                                                    <Body>
                                                        <cc1:CrmComboComp runat="server" ObjectId="201100052" UniqueName="new_SenderSegmentationID" ID="new_SenderSegmentationID" Hidden="true">
                                                        </cc1:CrmComboComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout27">
                                                    <Body>
                                                        <cc1:CrmTextFieldComp runat="server" ObjectId="201100052" UniqueName="new_E_Mail" ID="new_E_Mail">
                                                        </cc1:CrmTextFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                    </Body>
                                </rx:Fieldset>
                                <rx:Fieldset runat="server" ID="PanelDisabled" AutoHeight="Normal" Height="50" AutoWidth="true"
                                    Collapsed="false" Collapsible="false" Border="false">
                                    <Body>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="50%">
                                            <Rows>
                                                <rx:RowLayout runat="server" ID="RowLayout28">
                                                    <Body>
                                                        <cc1:CrmBooleanComp runat="server" ObjectId="201100052" UniqueName="new_CameFromKps" ID="new_CameFromKps" Disabled="true" ReadOnly="true">
                                                        </cc1:CrmBooleanComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout29">
                                                    <Body>
                                                        <cc1:CrmBooleanComp runat="server" ObjectId="201100052" UniqueName="new_cameFromAps" ID="new_cameFromAps" Disabled="true" ReadOnly="true">
                                                        </cc1:CrmBooleanComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout31">
                                                    <Body>
                                                        <cc1:CrmBooleanComp runat="server" ObjectId="201100052" UniqueName="new_IsDomestic" ID="new_IsDomestic" Disabled="true" ReadOnly="true" Hidden="true">
                                                        </cc1:CrmBooleanComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout32">
                                                    <Body>
                                                        <cc1:CrmPicklistComp runat="server" ObjectId="201100052" UniqueName="new_ChannelCreated" ID="new_ChannelCreated" Disabled="true" ReadOnly="true" Hidden="true">
                                                        </cc1:CrmPicklistComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout33">
                                                    <Body>
                                                        <cc1:CrmPicklistComp runat="server" ObjectId="201100052" UniqueName="new_ChannelModified" ID="new_ChannelModified" Disabled="true" ReadOnly="true" Hidden="true">
                                                        </cc1:CrmPicklistComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout34">
                                                    <Body>
                                                        <cc1:CrmTextAreaComp runat="server" ObjectId="201100052" UniqueName="new_CorporationCreated" ID="new_CorporationCreated" Disabled="true" ReadOnly="true" Hidden="true">
                                                        </cc1:CrmTextAreaComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                 <rx:RowLayout runat="server" ID="RowLayout35">
                                                    <Body>
                                                        <cc1:CrmTextAreaComp runat="server" ObjectId="201100052" UniqueName="new_CorporationModified" ID="new_CorporationModified" Disabled="true" ReadOnly="true" Hidden="true">
                                                        </cc1:CrmTextAreaComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout36">
                                                    <Body>
                                                        <cc1:CrmComboComp runat="server" ObjectId="201100052" UniqueName="new_CountryOfIdendity" ID="new_CountryOfIdendity" Disabled="true" ReadOnly="true" Hidden="true">
                                                        </cc1:CrmComboComp>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="50%">
                                            <Rows>
                                                <rx:RowLayout runat="server" ID="RowLayout30">
                                                    <Body>
                                                        <cc1:CrmComboComp runat="server" UniqueName="new_HomeCityId" ID="new_HomeCityId" ObjectId="201100052" Hidden="true"></cc1:CrmComboComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout37">
                                                    <Body>
                                                        <cc1:CrmComboComp runat="server" ObjectId="201100052" UniqueName="new_GenderID" ID="new_GenderID" Disabled="true" ReadOnly="true" Hidden="true">
                                                        </cc1:CrmComboComp>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>

                                    </Body>
                                </rx:Fieldset>
                            </Body>
                        </rx:PanelX>
                    </Body>
                </rx:RowLayout>
            </Rows>
        </rx:ColumnLayout>
    </form>
</body>
</html>
