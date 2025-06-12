<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_EditTabs"
    ValidateRequest="false" Codebehind="EditTabs.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork"
    TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR"/>
    <ajx:TabPanel runat="server" ID="Tabpanel1" AutoHeight="Auto" AutoWidth="true">
        <Tabs>
            <ajx:Tab runat="server" ID="Tab1" TabMode="Frame" Url="" Title="..." Closeable="false">
            </ajx:Tab>
        </Tabs>
        <Listeners>
            <TabClose Handler="return TabCloseControl(el,e);" />
        </Listeners>
    </ajx:TabPanel>
    </form>
</body>
</html>
