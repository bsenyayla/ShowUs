<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Administrations_User_UserPassWord" Codebehind="UserPassWord.aspx.cs" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:PanelX runat="server" ID="panel1" AutoHeight="Normal" Height="110" AutoWidth="true">
        <Body>
            <rx:ColumnLayout ID="FormLayout1" runat="server" LabelSeparator="" LabelWidth="150"
                ColumnWidth="30%">
                <Rows>
                    <rx:RowLayout runat="server" ID="RowLayout2">
                        <Body>
                             <cc1:CrmLabelField runat="server" ID="UserCmp" 
                                RequirementLevel="BusinessRequired" UniqueName="SystemUserId" Width="150" ObjectId="1"
                                PageSize="50" FieldLabel="200">
                            </cc1:CrmLabelField>
                            <rx:TextField runat="server" ID="password1" FieldLabel="OldPassword" InputType="Password"
                                FType="Password" Width="200">
                            </rx:TextField>
                            <rx:TextField runat="server" ID="password2" FieldLabel="NewPassword" InputType="Password"
                                FType="Password" Width="200">
                            </rx:TextField>
                            <rx:TextField runat="server" ID="password3" FieldLabel="NewPasswordControl" InputType="Password"
                                FType="Password">
                            </rx:TextField>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
        </Body>
        <Buttons>
            <rx:Button runat="server" ID="Save" Text="Save" Icon="DiskBlack" Width="100">
                <AjaxEvents>
                    <Click OnEvent="SaveOnEvent">
                    </Click>
                </AjaxEvents>
            </rx:Button>
        </Buttons>
    </rx:PanelX>
    <rx:PanelX ID="HiddenSecurityPolicy" runat="server" AutoHeight="Normal" Height="70"
        AutoWidth="true">
        <AutoLoad Url="about:blank" />
    </rx:PanelX>
    </form>
</body>
</html>
