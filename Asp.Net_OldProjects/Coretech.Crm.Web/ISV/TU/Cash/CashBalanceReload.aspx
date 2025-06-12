<%@ Page Language="C#" AutoEventWireup="true" Inherits="Cash_CashBalanceReload" Codebehind="CashBalanceReload.aspx.cs" %>


<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="JS/TransferFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:PanelX runat="server" ID="pnl1" Height="500" AutoWidth="true"
            Border="false" Title="SEARCH">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="100" ColumnLayoutLabelWidth="40">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="New_CashId" ObjectId="201300002" UniqueName="new_CashNameID"
                                    LookupViewUniqueName="KASALISTESI" Width="150">
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="50" ColumnLayoutLabelWidth="40">
                    <Rows>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <rx:Button runat="server" Text="Bakiyeleri Yenile" ID="btnReloadBalance" Style="margin-left: 10px;">
                                    <AjaxEvents>
                                        <Click OnEvent="BtnReloadBalanceClick"></Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>

            </Body>
        </rx:PanelX>
    </form>
</body>
</html>

