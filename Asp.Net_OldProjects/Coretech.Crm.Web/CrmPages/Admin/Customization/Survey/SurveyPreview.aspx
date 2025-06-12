<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Survey_SurveyPreview" Codebehind="SurveyPreview.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ext:Hidden runat="server" ID="hdnSurveyId" />
    <ext:Hidden runat="server" ID="hdnSurveyRecordId" />
    <ext:Hidden runat="server" ID="hdnObjectid" />
    <ext:Hidden runat="server" ID="hdnRecordid" />
    <ext:Panel runat="server" ID="SurveyPanel" Frame="false" Border="false" BodyStyle="padding:10px">
        <TopBar>
            <ext:Toolbar runat="server">
                <Items>
                    <ext:ToolbarButton Icon="ScriptSave" Text="Anketi Kaydet" OnClick="ScriptSave" AutoPostBack="true">
                    </ext:ToolbarButton>
                </Items>
            </ext:Toolbar>
        </TopBar>
    </ext:Panel>
    </form>
</body>
</html>
