<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_Reports_ReportViewer"
    ValidateRequest="false" Codebehind="ReportViewer.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<%@ Register TagPrefix="uc1" TagName="ConditionBuilder" Src="~/CrmPages/Admin/WorkFlow/ConditionBuilder.ascx" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style>
        .hide-toolbar .x-html-editor-tb
        {
            display: none !important;
        }
        SPAN.DataSlugStyle
        {
            tab-index: -1;
            background-color: #FFFF33;
            height: 17px;
            padding-top: 1px;
            padding-right: 2px;
            padding-left: 2px;
            overflow-y: hidden;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ext:Hidden ID="hdnReportId" runat="server" />
        <ext:ViewPort ID="ViewPort1" runat="server" AutoWidth="true">
            <Body>
                <ext:FitLayout ID="FitLayout1" runat="server">
                    <ext:Panel ID="Panel1" runat="server" AutoWidth="true">
                        <TopBar>
                            <ext:Toolbar ID="Toolbar1" runat="server">
                                <Items>
                                    <ext:Button Icon="Disk" ID="BtnSave" Text="Save & Run" runat="server">
                                        <Listeners>
                                            <Click Handler="
                                GenerateXml(#{WhereTree})
                                " />
                                        </Listeners>
                                    </ext:Button>
                                </Items>
                            </ext:Toolbar>
                        </TopBar>
                        <Body>
                            <ext:TabPanel ID="TabPanel1" runat="server" AutoWidth="true">
                                <Tabs>
                                    <ext:Tab Title="Where" AutoHeight="true">
                                        <Body>
                                            <uc1:ConditionBuilder ID="CBuilder" runat="server" />
                                        </Body>
                                    </ext:Tab>
                                    <ext:Tab Title="Report"  Id="ReportTab" runat="server" Height="800">
                                        <AutoLoad Url="about:blank" Mode="IFrame" ShowMask="true">
                                           
                                        </AutoLoad>
                                        <Body>
                                        </Body>
                                    </ext:Tab>
                                </Tabs>
                            </ext:TabPanel>
                        </Body>
                    </ext:Panel>
                </ext:FitLayout>
            </Body>
        </ext:ViewPort>
    </div>
    </form>
</body>
</html>
<script type="text/javascript">
    var _C_ClientId = null;
    function Get(id, Type) {
        if (Type == "C") {
            if (!IsNull(_C_ClientId)) {
                return eval(_C_ClientId + "_" + id)
            }
            else {
                return eval(id)
            }
        }
    }

    function GenerateXml(tp) {
        alert();
        var tpXml;
        strXml = "<filter id='" + hdnReportId.getValue() + "' >";
        strXml += getChildeXml(tp.root)
        strXml += "</filter >";
        tpXml = strXml;

        alert(tpXml);
        Coolite.AjaxMethods.UpdateView(tpXml);
    }
</script>
