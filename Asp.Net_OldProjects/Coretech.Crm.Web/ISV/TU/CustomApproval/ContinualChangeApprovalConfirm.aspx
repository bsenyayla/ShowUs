<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContinualChangeApprovalConfirm.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.CustomApproval.ContinualChangeApprovalConfirm" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <rx:RegisterResources runat="server" ID="RR" />
            <p><strong><rx:Label ID="lApprovalDesc" runat="server"></rx:Label></strong></p>
            <p>&nbsp;</p>
            <rx:PanelX ID="Pnl1" runat="server">
                <Body>
                    <rx:GridPanel runat="server" ID="gpChanges" AutoWidth="true" Editable="false" Mode="Local" AutoLoad="false" AjaxPostable="true">
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="false" />
                        </SelectionModel>
                    </rx:GridPanel>
                </Body>
            </rx:PanelX>
        </div>
    </form>
</body>
</html>