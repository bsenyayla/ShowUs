<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Approval_ApprovalView" Codebehind="ApprovalView.aspx.cs" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style type="text/css">
        #loading-mask {
            position: absolute;
            top: 0;
            left: 0;
            width: 99%;
            height: 99%;
            z-index: 70000;
            background: #c8cbd0;
            opacity: <%=Otheropacity%>;
            -moz-opacity: <%=Otheropacity%>;
            filter: alpha(opacity=<%=Ieopacity%>);
            border: 0;
            font-family: tahoma,arial,verdana,sans-serif;
            font-size: 11px;
            font-weight: bold;
        }

        #loading {
            position: absolute;
            top: 40%;
            left: 45%;
            z-index: 70001;
        }

            #loading SPAN {
                color: white;
                font-family: Arial;
                font-size: small;
                background: url('<%=GlobalConfig.Settings.ResourcePath%>/Themes/Slate/Images/loading.gif') no-repeat left center;
                padding: 5px 30px;
                display: block;
            }

        .fixed-toolbar {
            position: fixed !important;
            top: 0px;
            width: 96%;
            z-index: 8999;
        }

        .fixed-label {
            position: absolute;
            top: 0px;
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div style="display: none" runat="server" id="ScriptIframe">
        </div>
        <div id="loading-mask">
            <div id="loading">
                <span id="loading-message"></span>
            </div>
        </div>
        <ajx:RegisterResources runat="server" ID="RR" />
        <ajx:TabPanel runat="server" ID="Tabpanel1" AutoHeight="Auto" AutoWidth="true">
            <Tabs>
                <ajx:Tab runat="server" ID="FirstTab" TabMode="Div" Url="" Title="..." Closeable="false">
                    <Body>
                    </Body>
                </ajx:Tab>
            </Tabs>
            <Listeners>
                <TabClose Handler="return TabCloseControl(el,e);" />
            </Listeners>
        </ajx:TabPanel>
        <div style="display: none">
            <ajx:Hidden runat="server" ID="RedirectType" Value="1">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnObjectId">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnEntityName">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnEntityId">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnRecid">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnRecidName">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnDefaultEditPageId">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnTitle">
            </ajx:Hidden>
            <ajx:Hidden runat="server" ID="hdnRedirectUrl">
            </ajx:Hidden>
        </div>
        <ajx:KeyMap runat="server" ID="KeyMap1">
            <ajx:KeyBinding StopEvent="true">
                <Keys>
                    <ajx:Key Code="ESC">
                        <Listeners>
                            <Event Handler="" />
                        </Listeners>
                    </ajx:Key>
                </Keys>
            </ajx:KeyBinding>
        </ajx:KeyMap>
        <ajx:KeyMap runat="server" ID="KeyMap2">
            <ajx:KeyBinding StopEvent="false">
                <Keys>
                    <ajx:Key Code="BACKSPACE">
                        <Listeners>
                            <Event Handler="stopRKey(e);" />
                        </Listeners>
                    </ajx:Key>
                </Keys>
            </ajx:KeyBinding>
        </ajx:KeyMap>
        <ajx:KeyMap runat="server" ID="KeyMap3">
            <ajx:KeyBinding StopEvent="false">
                <Keys>
                    <ajx:Key Code="ENTER">
                        <Listeners>
                            <Event Handler="stopRKey(e);" />
                        </Listeners>
                    </ajx:Key>
                </Keys>
            </ajx:KeyBinding>
        </ajx:KeyMap>
        <div runat="server" id="Container" class="Crm-container ">
            <ajx:ToolBar runat="server" ID="EditToolbar" CustomCss="fixed-toolbar">
                <Items>
                    <ajx:ToolbarButton runat="server" ID="BtnConfirm" Width="70" Text="Confirm" Icon="Add">
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
                    <ajx:ToolbarButton runat="server" ID="BtnEdit" Width="70" Text="Edit" Icon="Pencil">
                        <AjaxEvents>
                            <Click OnEvent="BtnEditClick" Before="return BeforeRedirect();" >
                                <EventMask ShowMask="true" />

                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                </Items>
            </ajx:ToolBar>

            <ajx:PanelX runat="server" ID="PnlMain" Frame="false" Border="false" AutoHeight="Full"
                AutoWidth="true">
            </ajx:PanelX>

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
        </div>
    </form>
</body>
</html>
<script>
    function BeforeRedirect() {
        return confirm(CRM_APPROVALRECORD_THIS_RECORD_WILL_BE_DELETE);
    }
    
</script>
