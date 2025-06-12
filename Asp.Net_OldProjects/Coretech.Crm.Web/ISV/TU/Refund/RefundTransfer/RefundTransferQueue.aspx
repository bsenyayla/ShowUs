<%@ Page Language="C#" AutoEventWireup="true"
    ValidateRequest="false" Inherits="RefundTransfer_RefundTransferQueue" Codebehind="RefundTransferQueue.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
       
        <rx:Hidden runat="server" ID="hdnReportId" />
        <rx:Hidden runat="server" ID="hdnRecId" />
        <rx:Fieldset runat="server" ID="PanelX3" AutoHeight="Normal" Height="160" AutoWidth="true"
            CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false" Title="İade Gönderim Emri">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="50%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="TuReferans" ObjectId="201800017" UniqueName="TuReferans" RequirementLevel="BusinessRequired"
                                     Width="150">
                                    
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                          <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>&nbsp;</Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                               <cc1:CrmTextFieldComp runat="server" ID="new_BankTransactionNumber" ObjectId="201800017" UniqueName="new_BankTransactionNumber" RequirementLevel="BusinessRequired"
                                     Width="150">
                                    
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>

         
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <rx:Button ID="btnSend" runat="server" Icon="ApplicationGo" Text="Gönder"
                                    Width="60">
                                    <AjaxEvents>
                                        <Click OnEvent="btnSendOnEvent" Before="CrmValidateForm(msg,e);">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout66">
                            <Body>
                                <rx:Label ID="lblError" runat="server" Visible="false">
                                </rx:Label>
                            </Body>
                        </rx:RowLayout>

                    </Rows>
                </rx:ColumnLayout>
                
            </Body>
        </rx:Fieldset>

    </form>

</body>
</html>
