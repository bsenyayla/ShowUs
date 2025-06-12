<%@ Control Language="C#" AutoEventWireup="true" Inherits="Fraud_CustAccountReadonlyDirection" Codebehind="CustAccountReadonlyDirection.ascx.cs" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<rx:PanelX runat="server" AutoHeight="Normal" Height="840" Border="true" ID="PanelCustomerDetail"
    Frame="true">
    <Body>
        <rx:PanelX ID="PanelLblMessage" runat="server" AutoHeight="Normal" Height="20">
            <Body>
                <rx:Label ID="LblOperationDetail" runat="server" Icon="ApplicationEdit"></rx:Label>
            </Body>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="PanelCustomerAccountOperation" AutoHeight="Normal" Height="840" Border="false"
            Frame="true">
            <AutoLoad Url="about:blank" ShowMask="true" />
            <Body>
            </Body>
        </rx:PanelX>
    </Body>
</rx:PanelX>
