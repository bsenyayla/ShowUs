<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profession.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Profession.Profession" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="hdnSenderId" runat="server"></rx:Hidden>
        <div>
            <rx:PanelX runat="server" ID="pnlMain">
                <Body>
                    <rx:PanelX ID="pnl2" runat="server" ContainerPadding="true" Padding="true" Border="false">
                        <Body>
                            <br />
                            <h4>
                                <b id="bId">

                                </b>
                            </h4>
                            <br />

                            <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="100%" BorderStyle="None">
                                <Rows>
                                    <rx:RowLayout ID="RowLayout5" runat="server">
                                        <Body>
                                            <cc1:CrmComboComp ID="new_ProfessionID" runat="server" ObjectId="201100052" UniqueName="new_ProfessionID" RequirementLevel="BusinessRequired"
                                                FieldLabelWidth="100" Width="50" PageSize="50">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout ID="RowLayout1" runat="server">
                                        <Body>
                                            <cc1:CrmComboComp ID="new_WorkingStyleId" runat="server" ObjectId="201100052" UniqueName="new_WorkingStyleId" RequirementLevel="BusinessRequired"
                                                FieldLabelWidth="100" Width="50" PageSize="50" LookupViewUniqueName="WorkingStyle_Combo_View">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                        </Body>
                    </rx:PanelX>
                </Body>
                <Buttons>
                    <rx:Button ID="BtnContinue" runat="server" Text="CRM.NEW_FRAUDLOG_BTN_CONTINUE" Icon="BookmarkGo">
                        <AjaxEvents>
                            <Click OnEvent="btnSenderProfessionUpdate_Click" Success="hide();" Before="CrmValidateForm(msg,e);"></Click>
                        </AjaxEvents>
                    </rx:Button>
                </Buttons>
            </rx:PanelX>
        </div>
    </form>
</body>
</html>
