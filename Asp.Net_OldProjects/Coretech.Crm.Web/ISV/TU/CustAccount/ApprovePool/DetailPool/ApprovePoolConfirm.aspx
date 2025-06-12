<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_ApprovePool_DetailPool_ApprovePoolConfirm" Codebehind="ApprovePoolConfirm.aspx.cs" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR" />
        <rx:PanelX runat="server" ID="PanelX3" AutoHeight="Auto" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="False">
            <TopBar>
                <rx:ToolBar ID="toolTop" runat="server">
                    <Items>
                        <rx:Label runat="server" ID="lblInfo" Text="" Hidden="true" Icon="Information" ForeColor="White"></rx:Label>
                    </Items>
                </rx:ToolBar>
            </TopBar>
            <Body>
                <rx:PanelX runat="server" ID="CustAccountOperationsDetail"  Title="İşlem Detayı" AutoHeight="Auto" AutoWidth="True">
                    <AutoLoad Url="about:blank" ShowMask="true" />
                </rx:PanelX>       
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="btnConfirm" Hidden="true" Icon="Tick" Text="CRM.NEW_CUSTACCOUNTAPRROVEPOOL_APPROVEACTION" 
                    Width="120">
                    <AjaxEvents>
                        <Click OnEvent="btnConfirmOnClick">
                        </Click>
                    </AjaxEvents>
                </rx:Button>
                 <rx:Button runat="server" ID="btnReject" Hidden="true" Icon="Cancel" Text="CRM.NEW_CUSTACCOUNTAPRROVEPOOL_REJECTACTION" 
                    Width="120">
                    <Listeners>
                        <Click Handler="windowReject.show();" />
                    </Listeners>
                </rx:Button>

            </Buttons>
        </rx:PanelX>
        <rx:Window ID="windowReject" runat="server" Width="500" Height="120" Modal="true" 
        CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
        CloseAction="Hide" ShowOnLoad="false">
        <Body>
             <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="100%">
                <Rows>
                    <rx:RowLayout ID="RowLayout3" runat="server">
                        <Body>
                            <cc1:CrmTextAreaComp ID="txtRejectReason" runat="server" ObjectId="201600009" AjaxPostable="true" UniqueName="new_RejectPurpose">
                            </cc1:CrmTextAreaComp>
                         </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
            <rx:ToolBar runat="server" ID="ToolBar2">
                <Items>
                    <rx:ToolbarFill runat="server" ID="ToolbarFill2">
                    </rx:ToolbarFill>
                    <rx:ToolbarButton runat="server" ID="ToolbarButtonReject" 
                        Icon="Cancel" Width="100">
                        <AjaxEvents>
                            <Click OnEvent="btnRejectOnClick">
                                <EventMask ShowMask="true" Msg="Canceling..." />
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                </Items>
            </rx:ToolBar>
        </body>
        </rx:Window>
    </form>
</body>
</html>
