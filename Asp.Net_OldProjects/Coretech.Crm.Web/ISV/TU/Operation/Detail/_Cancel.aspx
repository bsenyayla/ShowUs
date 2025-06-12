<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_Detail_Cancel" Codebehind="_Cancel.aspx.cs" %>

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
    <rx:Hidden runat="server" ID="hdnObjectId">
    </rx:Hidden>
    <rx:Hidden runat="server" ID="hdnRecId">
    </rx:Hidden>
    <rx:PanelX runat="server" ID="PanelIframe" AutoHeight="Normal" Height="530" Border="false"
        Frame="true">
        <AutoLoad Url="about:blank" ShowMask="true" />
        <Body>
        </Body>
    </rx:PanelX>
    <rx:ToolBar runat="server" ID="ToolBarMain">
        <Items>
            <rx:ToolbarButton runat="server" ID="ToolbarButtonConfirm" Text="CONFIRM" Icon="Tick"
                Width="100">
                <AjaxEvents>
                    <Click OnEvent="Confirm">
                        <EventMask ShowMask="true" Msg="Confirming..." />
                    </Click>
                </AjaxEvents>
            </rx:ToolbarButton>
            <rx:ToolbarButton runat="server" ID="ToolbarButtonReject" Text="REJECT" Icon="Cancel"
                Width="100">
                <Listeners>
                    <Click Handler="windowReject.show();" />
                </Listeners>
            </rx:ToolbarButton>
            <rx:ToolbarFill runat="server" ID="tf1">
            </rx:ToolbarFill>
        </Items>
    </rx:ToolBar>
    <rx:Window ID="windowReject" runat="server" Width="500" Height="200" Modal="true"
        CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
        CloseAction="Hide" ShowOnLoad="false"
        Title="REJECT">
        <Body>
            <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="100%">
                <Rows>
                    <rx:RowLayout ID="RowLayout1" runat="server">
                        <Body>
                            <cc1:CrmComboComp runat="server" ID="new_ConfirmReasonId"  LookupViewUniqueName="CONFIRM_REASON_LOOKUP" ObjectId="201100097" UniqueName="new_ConfirmReasonId"
                                FieldLabelWidth="120" Width="130" PageSize="50" RequirementLevel="BusinessRequired">
                                <Listeners>
                                    <Change Handler="" />
                                </Listeners>
                            </cc1:CrmComboComp>
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout runat="server" ID="RowLayout2">
                        <Body>
                            <cc1:CrmTextAreaComp ID="new_ConfirmReasonDescription" runat="server" ObjectId="201100097"
                                UniqueName="new_ConfirmReasonDescription" FieldLabelWidth="120" Width="130" CaseType="UpperCase"
                                MaxLength="100" RequirementLevel="BusinessRecommend">
                            </cc1:CrmTextAreaComp>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ToolBar runat="server" ID="ToolBar1">
                <Items>
                    <rx:ToolbarFill runat="server" ID="ToolbarFill1">
                    </rx:ToolbarFill>
                    <rx:ToolbarButton runat="server" ID="ToolbarButtonReject1" Text="REJECT" Icon="Cancel"
                        Width="100">
                        <AjaxEvents>
                            <Click OnEvent="Reject">
                                <EventMask ShowMask="true" Msg="Confirming..." />
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                </Items>
            </rx:ToolBar>
        </Body>
    </rx:Window>
    </form>
</body>
</html>
