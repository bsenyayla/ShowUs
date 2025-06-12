<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation_Detail_CancelRequest" Codebehind="_CancelRequest.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script type="text/javascript">

        var trStatus = 'TR010';

        function checkStatus() {
            if (trStatus == 'TR000E' || trStatus == 'PA004A') {
                var ret = confirm('Bu işlem onaya düşmeden iptal edilecektir, İşlemi iptal etmek istediğinizden emin misiniz?');
                return ret;
            }
            else {
                return true;
            }
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="hdnObjectId">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnRecId">
        </rx:Hidden>
        <rx:PanelX runat="server" ID="PanelIframe" AutoHeight="Normal" Height="450" Border="false"
            Frame="true">
            <AutoLoad Url="about:blank" ShowMask="true" />
            <Body>
            </Body>
        </rx:PanelX>
        <rx:PanelX ID="pnl2" runat="server" ContainerPadding="true" Padding="true" Height="500"  Border="false" >
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="100%" BorderStyle="None">
                   <Rows>
                        <rx:RowLayout ID="RowLayout5" runat="server">
                        <Body>
                            <cc1:CrmComboComp ID="new_CancelReason" runat="server" ObjectId="201100072" UniqueName="new_CancelReason" RequirementLevel="BusinessRequired"
                                FieldLabelWidth="100" Width="50" PageSize="50" >
                             </cc1:CrmComboComp>

                                <cc1:CrmTextFieldComp runat="server" ID="new_CancelExplanation" ObjectId="201100072"
                                    UniqueName="new_CancelExplanation" Width="150" PageSize="50" FieldLabel="200" RequirementLevel="BusinessRecommend">
                                </cc1:CrmTextFieldComp>
                        </Body>
                        </rx:RowLayout>
                   </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>

                                    
        <rx:ToolBar runat="server" ID="ToolBarMain">
            <Items>
                <rx:ToolbarButton runat="server" ID="ToolbarButtonConfirm" Text="CONFIRM" Icon="Cancel"
                    Width="100">
                    <AjaxEvents>


                        <Click OnEvent="CancelRequest" Before="return checkStatus();">
                            <EventMask ShowMask="true" Msg="Confirming..." />
                        </Click>

                        <%--<Click OnEvent="CancelRequest" Before="return confirm('İşlemi iptal etmek istediğinizden emin misiniz?');">
                            <EventMask ShowMask="true" Msg="Confirming..." />
                        </Click>--%>
                    </AjaxEvents>
                </rx:ToolbarButton>

                <rx:ToolbarFill runat="server" ID="tf1">
                </rx:ToolbarFill>
            </Items>
        </rx:ToolBar>

    </form>
</body>
</html>
