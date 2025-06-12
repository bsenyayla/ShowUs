<%@ Page Language="C#" AutoEventWireup="true"
    ValidateRequest="false" Inherits="Spread_Spread" Codebehind="Spread.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="New_SpreadId" runat="server" />
        <rx:Hidden runat="server" ID="hdnReportId" />
        <rx:Hidden runat="server" ID="hdnRecId" />
        <rx:Fieldset runat="server" ID="PanelX3" AutoHeight="Normal" Height="160" AutoWidth="true"
            CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false" Title="Spread Tanımı">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_CorporationId" ObjectId="201500010" UniqueName="new_CorporationId" RequirementLevel="BusinessRequired"
                                    LookupViewUniqueName="CorpComboView" Width="150">
                                    <AjaxEvents>
                                        <Change OnEvent="new_CorporationIdChange">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <cc1:CrmDecimalComp runat="server" ID="new_Rate" ObjectId="201500010" Hidden="false" RequirementLevel="BusinessRequired"
                                    Height="60" UniqueName="new_Rate" FieldLabel="200">
                                </cc1:CrmDecimalComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_FromCurrencyId" ObjectId="201500010" UniqueName="new_FromCurrencyId" RequirementLevel="BusinessRequired"
                                    LookupViewUniqueName="SYSTEM_CURRENCY_LOOKUP" Width="150">
                                    <DataContainer>
                                        <DataSource OnEvent="new_FromCurrencyonEvent">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_FromCurrencyChange">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_ToCurrencyId" ObjectId="201500010" UniqueName="new_ToCurrencyId" RequirementLevel="BusinessRequired"
                                    LookupViewUniqueName="SYSTEM_CURRENCY_LOOKUP" Width="150">
                                    <DataContainer>
                                        <DataSource OnEvent="new_ToCurrencyonEvent">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_ToCurrencyChange">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>&nbsp;</Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <rx:Button ID="btnSave" runat="server" Icon="Disk" Text="Kaydet"
                                    Width="60">
                                    <AjaxEvents>
                                        <Click OnEvent="btnSaveOnEvent" Before="CrmValidateForm(msg,e);">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout66">
                            <Body>
                                <rx:Label ID="lblError" runat="server" Visible="false">
                                </rx:Label>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout13" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderAccountId" ObjectId="201500010" UniqueName="new_SenderAccountId" RequirementLevel="BusinessRequired"
                                    LookupViewUniqueName="AccountLookupView" Width="150">
                                    <DataContainer>
                                        <DataSource OnEvent="new_SenderAccountIdonEvent">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_SenderAccountIdChange">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout runat="server" ID="RowLayout8">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientAccountId" ObjectId="201500010" UniqueName="new_RecipientAccountId" RequirementLevel="BusinessRequired"
                                    LookupViewUniqueName="AccountLookupView" Width="150">
                                    <DataContainer>
                                        <DataSource OnEvent="new_RecipientAccountIdonEvent">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="new_RecipientAccountIdChange">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>

    </form>

</body>
</html>
