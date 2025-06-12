<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UptionReportDateControl.ascx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Reports.UptionReportDateControl" %>


<%@ Import Namespace="Coretech.Crm.Factory" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<style>
    #MultiField1 {
        padding-top: 15px;
    }
</style>
<rx:PanelX runat="server" ID="Fieldset2" AutoHeight="Normal" Height="80" AutoWidth="true"
    Collapsible="false" Border="false" BorderStyle="None">
    <Body>
        <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="100%">
            <Rows>
                <rx:RowLayout ID="RowLayout1" runat="server">
                    <Body>
                        <rx:MultiField ID="RxM" runat="server">
                            <Items>
                                <cc1:CrmDateFieldComp ID="new_FormTransactionDate1" runat="server" ObjectId="201100097"
                                    UniqueName="new_FormTransactionDate1" FieldLabelWidth="160" Width="100">
                                    <AjaxEvents>
                                        <Change OnEvent="FormTransactionDate1OnEvent"></Change>
                                    </AjaxEvents>
                                </cc1:CrmDateFieldComp>
                                <rx:Label runat="server" Text="  " ID="lbl1" Width="10">
                                </rx:Label>
                                <cc1:CrmDateFieldComp ID="new_FormTransactionDate2" runat="server" ObjectId="201100097"
                                    FieldLabelShow="false" UniqueName="new_FormTransactionDate2" FieldLabelWidth="160"
                                    Width="100">
                                    <AjaxEvents>
                                         <Change OnEvent="FormTransactionDate2OnEvent"></Change>
                                    </AjaxEvents>
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
            </Rows>
        </rx:ColumnLayout>

    </Body>
</rx:PanelX>
