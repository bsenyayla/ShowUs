<%@ Page Language="C#" AutoEventWireup="true" Inherits="Sender_CorporateAccountSender" ValidateRequest="false" CodeBehind="CorporateAccountSender.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="Js/SenderFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="hdnSorguRefNo" runat="server" />
        <rx:Hidden ID="hdnSenderId" runat="server" />
        <rx:Fieldset runat="server" ID="FieldsetSenderInfo" AutoHeight="Normal" Height="100" AutoWidth="true"
            CustomCss="Section1" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_MersisNumber" ObjectId="201100052" UniqueName="new_MersisNumber"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                         <rx:RowLayout runat="server" ID="RowLayout12">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="Sender" ObjectId="201100052" UniqueName="Sender"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                       
                        <rx:RowLayout runat="server" ID="RowLayout19">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="50%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout20">
                                            <Body>
                                                <buttons> <rx:Button runat="server" ID="btnCorporationFind" Text="Firma Sorgula" Icon="MagnifierZoomIn"
                                        Width="110">
                                        <AjaxEvents>
                                            <Click OnEvent="btnCorporationFindClick">
                                                <EventMask ShowMask="true" />
                                            </Click>
                                        </AjaxEvents>
                                    </rx:Button></buttons>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                 <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="50%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout21">
                                            <Body>
                                                <buttons> <rx:Button runat="server" ID="Button1" Text="Firma Aç" Icon="BookmarkGo"
                                        Width="110">
                                        <AjaxEvents>
                                            <Click OnEvent="btnCorporationNewClick">
                                                <EventMask ShowMask="true" />
                                            </Click>
                                        </AjaxEvents>
                                    </rx:Button></buttons>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>

                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="50%">
                    <Rows>
                       
                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_RegistryNumber" ObjectId="201100052" UniqueName="new_RegistryNumber"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                         <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdendificationNumber1" ObjectId="201100052" UniqueName="new_SenderIdendificationNumber1"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="new_TaxNo" ObjectId="201100052" UniqueName="new_TaxNo"
                                    Width="150">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:Fieldset>
        <rx:Window ID="windowTuzelInfo" runat="server" Width="600" Height="400" Modal="true" WindowCenter="true"
            Closable="true" Maximizable="false" Resizable="false" CloseAction="Hide" ShowOnLoad="false"
            Title="Tüzel Müşteri Bilgileri">
            <Body>
                <rx:PanelX ID="PanelX1" runat="server" ContainerPadding="true" Padding="true" Border="false">
                    <Body>

                        <rx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="100%" BorderStyle="None">
                            <Rows>
                                <rx:RowLayout ID="RowLayout5" runat="server">
                                    <Body>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="50%">
                                            <Rows>
                                                <rx:RowLayout runat="server" ID="RowLayout7">
                                                    <Body>
                                                        <cc1:CrmTextFieldComp runat="server" ID="SenderInfo" ObjectId="201100052" UniqueName="Sender"
                                                            Width="150">
                                                        </cc1:CrmTextFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout ID="RowLayout14" runat="server">
                                                    <Body>
                                                        <cc1:CrmTextFieldComp runat="server" ID="new_MersisNumberInfo" ObjectId="201100052" UniqueName="new_MersisNumber"
                                                            Width="150">
                                                        </cc1:CrmTextFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout ID="RowLayout9" runat="server">
                                                    <Body>
                                                        <cc1:CrmTextFieldComp runat="server" ID="new_CompanyNeviGrupInfo" ObjectId="201900014" UniqueName="new_CompanyNeviGrup"
                                                            Width="150">
                                                        </cc1:CrmTextFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout ID="RowLayout10" runat="server">
                                                    <Body>
                                                        <cc1:CrmTextFieldComp runat="server" ID="new_CompanyLegalStatusInfo" ObjectId="201900014" UniqueName="new_CompanyLegalStatus"
                                                            Width="150">
                                                        </cc1:CrmTextFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout ID="RowLayout16" runat="server">
                                                    <Body>
                                                        <cc1:CrmTextFieldComp runat="server" ID="new_TradeRegistryOfficeNameInfo" ObjectId="201900014" UniqueName="new_TradeRegistryOfficeName"
                                                            Width="150">
                                                        </cc1:CrmTextFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout ID="RowLayout17" runat="server">
                                                    <Body>
                                                        <cc1:CrmTextFieldComp runat="server" ID="new_TradeRegistryOfficeCode" ObjectId="201900014" UniqueName="new_TradeRegistryOfficeCode"
                                                            Width="150">
                                                        </cc1:CrmTextFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout ID="RowLayout18" runat="server">
                                                    <Body>
                                                        <cc1:CrmTextFieldComp runat="server" ID="new_TradeRegistryOfficeCity" ObjectId="201900014" UniqueName="new_TradeRegistryOfficeCity"
                                                            Width="150">
                                                        </cc1:CrmTextFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>
                                        <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="50%">
                                            <Rows>
                                                <rx:RowLayout ID="RowLayout15" runat="server">
                                                    <Body>
                                                        <cc1:CrmTextFieldComp runat="server" ID="new_SenderIdendificationNumber1Info" ObjectId="201100052" UniqueName="new_SenderIdendificationNumber1"
                                                            Width="150">
                                                        </cc1:CrmTextFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout6">
                                                    <Body>
                                                        <cc1:CrmTextFieldComp runat="server" ID="new_TaxNoInfo" ObjectId="201100052" UniqueName="new_TaxNo"
                                                            Width="150">
                                                        </cc1:CrmTextFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout13">
                                                    <Body>
                                                        <cc1:CrmTextFieldComp runat="server" ID="new_TaxOfficeInfo" ObjectId="201900014" UniqueName="new_TaxOffice"
                                                            Width="150">
                                                        </cc1:CrmTextFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout8">
                                                    <Body>
                                                        <cc1:CrmTextFieldComp runat="server" ID="new_RegistryNumberInfo" ObjectId="201100052" UniqueName="new_RegistryNumber"
                                                            Width="150">
                                                        </cc1:CrmTextFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                                <rx:RowLayout runat="server" ID="RowLayout11">
                                                    <Body>
                                                        <cc1:CrmDateFieldComp runat="server" ID="new_RegistrationDateInfo" ObjectId="201900014" UniqueName="new_RegistrationDate"
                                                            Width="150">
                                                        </cc1:CrmDateFieldComp>
                                                    </Body>
                                                </rx:RowLayout>
                                            </Rows>
                                        </rx:ColumnLayout>

                                    </Body>
                                </rx:RowLayout>
                            </Rows>
                        </rx:ColumnLayout>
                    </Body>

                </rx:PanelX>
            </Body>
            <Buttons>
                <rx:Button ID="btnSaveCustomer" runat="server" Text="Tüzel Müşteri Kaydet" Icon="BookmarkGo">
                    <AjaxEvents>
                        <Click OnEvent="btnTuzelSenderInfoSave_Click" Success="windowTuzelInfo.hide();"></Click>
                    </AjaxEvents>
                </rx:Button>
                   <rx:Button ID="btnGoCustomer" runat="server" Text="Tüzel Müşteriye Git" Icon="BookmarkGo">
                    <AjaxEvents>
                        <Click OnEvent="btnTuzelSenderInfoLoad_Click" Success="windowTuzelInfo.hide();"></Click>
                    </AjaxEvents>
                </rx:Button>
                 <rx:Button ID="btnUpdateCustomer" runat="server" Text="Tüzel Müşteri Güncelle" Icon="BookEdit">
                    <AjaxEvents>
                        <Click OnEvent="btnTuzelSenderInfoUpdate_Click" Success="windowTuzelInfo.hide();"></Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:Window>
    </form>
</body>
</html>
