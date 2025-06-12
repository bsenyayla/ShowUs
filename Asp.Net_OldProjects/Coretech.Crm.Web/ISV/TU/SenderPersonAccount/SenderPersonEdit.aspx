<%@ Page Language="C#" AutoEventWireup="true" Inherits="Sender_SenderPersonEdit" ValidateRequest="false" CodeBehind="SenderPersonEdit.aspx.cs" %>

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
        <rx:Hidden ID="new_SenderPersonId" runat="server" />
        <rx:Hidden ID="new_ConfirmStatus" runat="server" />
        <rx:Hidden ID="hdnComeFromKps" runat="server" Value="false" />
        <rx:Hidden ID="IsDisabled" runat="server" Value="true" />
        <rx:Hidden ID="new_MobilUserId" runat="server" Value="true" />
        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="600" AutoWidth="true" Title="Gönderici Yetkilisi İşlemleri"
            customcss="Section3" Collapsed="false" Collapsible="false" Border="false" Frame="false">
            <Body>
                <rx:Fieldset runat="server" ID="FieldsetButtons" AutoHeight="Normal" Height="20" AutoWidth="true" CustomCss="Section1" Collapsible="false" Border="false">
                    <Body>

                        <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="5%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout12">
                                    <Body>
                                        <rx:Button ID="btnNew" runat="server" Text="Yeni" Icon="Page">
                                            <AjaxEvents>
                                                <Click OnEvent="btnNew_Click"></Click>
                                            </AjaxEvents>
                                        </rx:Button>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>

                        <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="5%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout13">
                                    <Body>

                                        <rx:Button ID="btnSave" runat="server" Text="Kaydet" Icon="PageSave">
                                            <AjaxEvents>
                                                <Click OnEvent="btnSave_Click"></Click>
                                            </AjaxEvents>
                                        </rx:Button>

                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>

                        <rx:ColumnLayout runat="server" ID="ColumnLayout11" ColumnWidth="7%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout18">
                                    <Body>

                                        <rx:Button ID="btnDisable" runat="server" Text="Kullanıcı İptal" Icon="Decline" Visible="true">
                                            <AjaxEvents>
                                                <Click OnEvent="btnDisable_Click"></Click>
                                            </AjaxEvents>
                                        </rx:Button>

                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>

                </rx:Fieldset>
                <rx:Fieldset runat="server" ID="FieldsetSenderInfo" AutoHeight="Normal" Height="20" AutoWidth="true"
                    CustomCss="Section1" Collapsible="false" Border="false">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="60%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout9">
                                    <Body>
                                        <cc1:CrmComboComp runat="server" ID="new_SenderId" ObjectId="201500041" UniqueName="new_SenderId"
                                            LookupViewUniqueName="CORPORATED_SENDER_LIST" RequirementLevel="BusinessRequired" Width="150" PageSize="50"
                                            FieldLabel="150">
                                            <AjaxEvents>
                                            </AjaxEvents>
                                        </cc1:CrmComboComp>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:Fieldset>
                <rx:Fieldset runat="server" ID="FieldsetSenderPersonInfo" AutoHeight="Normal" Height="100" AutoWidth="true"
                    CustomCss="Section1" Collapsible="false" Border="false">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="60%">
                            <Rows>

                                <rx:RowLayout runat="server" ID="RowLayout3">
                                    <Body>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdendificationNumber1"  RequirementLevel="BusinessRequired" ObjectId="201500041" UniqueName="new_SenderIdendificationNumber1"
                                            Width="150">
                                        </cc1:CrmTextFieldComp>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout10">
                                    <Body>
                                        <cc1:CrmComboComp runat="server" ID="new_NationalityID" ObjectId="201500041"
                                            UniqueName="new_NationalityID" Width="150"
                                            LookupViewUniqueName="NATIONALITY_LOOKUP" PageSize="50" FieldLabel="200">
                                        </cc1:CrmComboComp>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout4">
                                    <Body>
                                        <rx:Button ID="btnSearch" runat="server" Text="Sorgula" Icon="Find">
                                            <AjaxEvents>
                                                <Click OnEvent="btnSearch_Click"></Click>
                                            </AjaxEvents>
                                        </rx:Button>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="25%">
                            <Rows>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:Fieldset>
                <rx:Fieldset runat="server" ID="FieldsetSenderPersonDetailInfo" AutoHeight="Normal" Height="200" AutoWidth="true"
                    CustomCss="Section1" Collapsible="false" Border="false">
                    <Body>
                        <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="60%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout1">
                                    <Body>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_Name" ObjectId="201500041" UniqueName="new_Name" RequirementLevel="BusinessRequired"
                                            Width="150">
                                        </cc1:CrmTextFieldComp>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout5">
                                    <Body>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_MiddleName" ObjectId="201500041" UniqueName="new_MiddleName"
                                            Width="150">
                                        </cc1:CrmTextFieldComp>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout2">
                                    <Body>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_LastName" ObjectId="201500041" UniqueName="new_LastName" RequirementLevel="BusinessRequired"
                                            Width="150">
                                        </cc1:CrmTextFieldComp>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout14">
                                    <Body>
                                        <cc1:CrmComboComp runat="server" ID="new_HomeCountry" ObjectId="201500041"
                                            RequirementLevel="BusinessRequired" UniqueName="new_HomeCountry" Width="150" LookupViewUniqueName="COUNTRY_LOOKUP"
                                            PageSize="50" FieldLabel="200">
                                        </cc1:CrmComboComp>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout6">
                                    <Body>
                                        <cc1:CrmTextFieldComp runat="server" ID="new_E_Mail" ObjectId="201500041" UniqueName="new_E_Mail" RequirementLevel="BusinessRequired"
                                            Width="150">
                                        </cc1:CrmTextFieldComp>
                                    </Body>
                                </rx:RowLayout>
                                <rx:RowLayout runat="server" ID="RowLayout7">
                                    <Body>
                                        <cc1:CrmComboComp runat="server" ID="new_GSMCountryId" ObjectId="201500041"  RequirementLevel="BusinessRequired"
                                           UniqueName="new_GSMCountryId" Width="150"
                                            LookupViewUniqueName="COUNTRYTELEPHONELOOKUP">
                                            <Listeners>
                                                <Change Handler="new_CustAccountTypeId_Change();"></Change>
                                            </Listeners>
                                        </cc1:CrmComboComp>
                                        <cc1:CrmPhoneFieldComp runat="server" ID="new_GSM" ObjectId="201500041" UniqueName="new_GSM" RequirementLevel="BusinessRequired"
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
                        <rx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="40%">
                            <Rows>
                                <rx:RowLayout runat="server" ID="RowLayout16">
                                    <Body>
                                        <rx:Button ID="btnSendMail" runat="server" Text="Sifre Gönder" Icon="PageGo" Visible="true">
                                            <AjaxEvents>
                                                <Click OnEvent="btnSendMail_Click"></Click>
                                            </AjaxEvents>
                                        </rx:Button>
                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>
                </rx:Fieldset>
            </Body>
        </rx:PanelX>
    </form>
</body>
</html>
<script>

    function new_CustAccountTypeId_Change() {
        document.getElementById('_new_GSM').value = new_GSMCountryId.selectedRecord.new_TelephoneCode;

    }

</script>


