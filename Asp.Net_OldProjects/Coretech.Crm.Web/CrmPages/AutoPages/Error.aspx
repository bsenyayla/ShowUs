<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_Error" Codebehind="Error.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .editable
        {
            font: 18px Tahoma;
            padding: 3px 5px;
            cursor: pointer;
            margin-bottom: 20px;
            background-color: #ffc;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ext:ViewPort runat="server">
            <Body>
                <ext:FitLayout>
                    <ext:CenterLayout runat="server">
                        <ext:Panel runat="server">
                            <Body>
                                <ext:Panel runat="server" Height="100">
                                    <Body>
                                        <ext:Label ID="LblError"  runat="server" Cls="editable" Icon="Error">
                                        </ext:Label>
                                    </Body>
                                </ext:Panel>
                                <ext:Panel>
                                    <Body>
                                        <ext:Button ID="Button1" Text="Tamam" runat="server">
                                            <Listeners>
                                                <Click Handler="top.Ext.WindowMgr.getActive().close();" />
                                            </Listeners>
                                        </ext:Button>
                                    </Body>
                                </ext:Panel>
                            </Body>
                        </ext:Panel>
                    </ext:CenterLayout>
                </ext:FitLayout>
            </Body>
        </ext:ViewPort>
    </div>
    </form>
</body>
</html>
