<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ApprovalList.ascx.cs" Inherits="Coretech.Crm.Web.CrmPages.Admin.Approval.ApprovalList" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<ajx:ToolbarButton runat="server" ID="BtnConfirm" Width="70" Text="Confirm" Icon="Accept">
    <AjaxEvents>
        <Click OnEvent="BtnConfirmClick">
            <EventMask ShowMask="true" />
            <ExtraParams>
                <ajx:Parameter Name="Action" Value="1"></ajx:Parameter>
            </ExtraParams>
        </Click>
    </AjaxEvents>
</ajx:ToolbarButton>
<ajx:ToolbarButton runat="server" ID="BtnReject" Width="70" Text="Save" Icon="Cancel">
    <Listeners>
        <Click Handler="windowReject.show();" />
    </Listeners>
</ajx:ToolbarButton>
<ajx:Window ID="windowReject" runat="server" Width="500" Height="120" Modal="true"
    CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
    CloseAction="Hide" ShowOnLoad="false"
    Title="REJECT">
    <Body>
        <ajx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="100%">
            <Rows>

                <ajx:RowLayout runat="server" ID="RowLayout2">
                    <Body>
                        <cc1:CrmTextAreaComp ID="Comment" runat="server" ObjectId="57"
                            UniqueName="Comment" FieldLabelWidth="120" Width="130" CaseType="UpperCase"
                            MaxLength="100" RequirementLevel="BusinessRecommend">
                        </cc1:CrmTextAreaComp>
                    </Body>
                </ajx:RowLayout>
            </Rows>
        </ajx:ColumnLayout>
        <ajx:ToolBar runat="server" ID="ToolBar1">
            <Items>
                <ajx:ToolbarFill runat="server" ID="ToolbarFill1">
                </ajx:ToolbarFill>
                <ajx:ToolbarButton runat="server" ID="BtnRejectReal" Text="REJECT" Icon="Cancel"
                    Width="100">
                    <AjaxEvents>
                        <Click OnEvent="BtnRejectClick">
                            <EventMask ShowMask="true" Msg="Confirming..." />
                        </Click>
                    </AjaxEvents>
                </ajx:ToolbarButton>
            </Items>
        </ajx:ToolBar>
    </Body>
</ajx:Window>
