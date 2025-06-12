<%@ Page Language="C#" AutoEventWireup="true" Inherits="Sender_SenderPersonApproval" ValidateRequest="false" CodeBehind="SenderPersonApproval.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

</head>

<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
         <rx:Hidden ID="New_SenderPersonApprovePoolId" runat="server" />
        <rx:Hidden ID="new_SenderPersonId" runat="server" />
        <rx:Hidden ID="new_ConfirmStatus" runat="server" />
        <rx:Hidden ID="new_ActionType" runat="server" />
        <rx:Hidden ID="new_MobilUserId" runat="server" />
        <rx:Hidden ID="CreatedBy" runat="server" />
        <rx:Fieldset runat="server" ID="FieldsetSenderPersonDetailInfo" AutoHeight="Normal" Height="250" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="60%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdendificationNumber1" ObjectId="201500041" UniqueName="new_SenderIdendificationNumber1" ReadOnly="true"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout10">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_NationalityID" ObjectId="201500041" UniqueName="new_NationalityID" Width="150" Disabled="true"
                                    LookupViewUniqueName="NATIONALITY_LOOKUP" PageSize="50" FieldLabel="200">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_Name" ObjectId="201500041" UniqueName="new_Name" ReadOnly="true"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_MiddleName" ObjectId="201500041" UniqueName="new_MiddleName" ReadOnly="true"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_LastName" ObjectId="201500041" UniqueName="new_LastName" ReadOnly="true"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout14">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_HomeCountry" ObjectId="201500041" ReadOnly="true" UniqueName="new_HomeCountry" Width="150" LookupViewUniqueName="COUNTRY_LOOKUP"
                                    PageSize="50" FieldLabel="200">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_E_Mail" ObjectId="201500041" UniqueName="new_E_Mail" ReadOnly="true"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_GSMCountryId" ObjectId="201500041" Disabled="true" UniqueName="new_GSMCountryId" Width="150"
                                    LookupViewUniqueName="COUNTRYTELEPHONELOOKUP">
                                    <Listeners>
                                        <Change Handler="new_CustAccountTypeId_Change();"></Change>
                                    </Listeners>
                                </cc1:CrmComboComp>
                                <cc1:CrmPhoneFieldComp runat="server" ID="new_GSM" ObjectId="201500041" UniqueName="new_GSM" ReadOnly="true"
                                    Width="150">
                                </cc1:CrmPhoneFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout8">
                            <Body>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>


        <rx:Fieldset runat="server" ID="FieldsetUserCode" AutoHeight="Normal" Height="50" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="60%">
                    <Rows>

                        <rx:RowLayout runat="server" ID="RowLayout11">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="UserName" ObjectId="1" UniqueName="UserName" ReadOnly="true"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="40%">
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:Fieldset runat="server" ID="FieldsetApprove" AutoHeight="Normal" Height="20" Collapsible="false" Border="false">
            <Body>

                <rx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="10%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout15">
                            <Body>
                                <rx:Button ID="btnApprove" runat="server" Text="Onayla" Icon="Accept" Visible="true">
                                    <AjaxEvents>
                                        <Click OnEvent="btnApprove_Click"></Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

                <rx:ColumnLayout runat="server" ID="ColumnLayout10" ColumnWidth="10%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout17">
                            <Body>

                                <rx:Button ID="btnReject" runat="server" Text="Reddet" Icon="Decline" Visible="true">
                                    <AjaxEvents>
                                        <Click OnEvent="btnReject_Click"></Click>
                                    </AjaxEvents>
                                </rx:Button>

                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

            </Body>

        </rx:Fieldset>

    </form>
</body>
</html>



