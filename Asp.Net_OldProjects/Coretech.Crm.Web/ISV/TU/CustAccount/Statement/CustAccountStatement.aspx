<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_Statement_CustAccountStatement" Codebehind="CustAccountStatement.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
        <style type="text/css">
        body .x-label
        {
            white-space: normal !important;
        }
    </style>
    <script src="../Js/Statement.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="hdnReportId">
        </rx:Hidden>
        <rx:PanelX runat="server" ID="Pnl1" Height="400" AutoHeight="Auto">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="40%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout101" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountTypeId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountTypeId" RequirementLevel="BusinessRecommend"
                                    FieldLabelWidth="100" Width="200" PageSize="50">
                                    <Listeners>
                                        <Change Handler="new_CustAccountTypeId_Change();"></Change>
                                    </Listeners>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="R1" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_SenderId" runat="server" ObjectId="201500039" UniqueName="new_SenderId"
                                    FieldLabelWidth="100" Width="200" PageSize="50" FieldLabelShow="True" RequirementLevel="BusinessRecommend">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201500039" FromUniqueName="new_CustAccountTypeId" ToObjectId="201100052" ToUniqueName="new_CustAccountTypeId" />
                                    </Filters>
                                    <AjaxEvents>
                                        <Change OnEvent="new_SenderId_OnChange">
                                        </Change>
                                    </AjaxEvents>
                                    <Listeners>
                                        <Change Handler="new_SenderId_Change();"></Change>
                                    </Listeners>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountId" RequirementLevel="BusinessRequired"
                                    FieldLabelWidth="100" Width="200" PageSize="50" FieldLabelShow="true">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201500039" FromUniqueName="new_SenderId" ToObjectId="201500042" ToUniqueName="new_SenderId" />
                                    </Filters>
                                    <AjaxEvents>
                                        <Change OnEvent="new_CustAccountId_OnChange">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout4" ColumnWidth="45%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmTextFieldComp ID="txtEmail" runat="server" ObjectId="201600005" UniqueName="new_Email" RequirementLevel="BusinessRequired">
                                </cc1:CrmTextFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <cc1:CrmDateFieldComp ID="cmbStatementDateStart" runat="server" ObjectId="201600005"
                                    Width="100" RequirementLevel="BusinessRequired" UniqueName="new_StartDate">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>
                                <cc1:CrmDateFieldComp ID="cmbStatementDateEnd" runat="server" ObjectId="201600005"
                                     UniqueName="new_EndDate" FieldLabelWidth="100" RequirementLevel="BusinessRequired"
                                    Width="100">
                                </cc1:CrmDateFieldComp>

                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout15" ColumnWidth="15%">
                    <Rows>
                        <rx:RowLayout ID="CommandButton" runat="server">
                            <Body>
                                <rx:Button ID="btnPdfWatch" runat="server" Icon="PageWhiteAcrobat" Text="Pdf Önizle" Width="100">
                                    <AjaxEvents>
                                        <Click OnEvent="btnPdfWatch_OnClick">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <rx:Label ID="emptyLbl" runat="server"></rx:Label>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <rx:Button ID="btnPdfMail" runat="server" Icon="Email" Text="Pdf E-Mail Gönder" Width="120" Download="true">
                                    <AjaxEvents>
                                        <Click OnEvent="btnPdfMail_OnClick" Before="IsValidEmail(e, txtEmail.getValue());">
                                            <EventMask ShowMask="true" />
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
    </form>
</body>
</html>
<script>
    function new_CustAccountTypeId_Change() {
        new_SenderId.clear();
        //new_SenderId.change();
        new_CustAccountId.clear();
        txtEmail.clear();
    }
    function new_SenderId_Change() {
        new_CustAccountId.clear();
        txtEmail.clear();
        txtEmail.setValue(AjaxMethods.GetEmailAdress(new_SenderId.getValue()).value);
    }

    function IsValidEmail(e, email) {


        if (email == '')
            return true;



        // Get email parts
        var emailParts = email.split('@');

        // There must be exactly 2 parts
        if (emailParts.length !== 2) {
            alert("E-mail formatı yanlış.");
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }

        // Name the parts
        var emailName = emailParts[0];
        var emailDomain = emailParts[1];

        // === Validate the parts === \\

        // Must be at least one char before @ and 3 chars after
        if (emailName.length < 1 || emailDomain.length < 3) {
            alert("E-mail formatı yanlış.");
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }

        // Define valid chars
        var validChars = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '.', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '_', '-'];

        // emailName must only include valid chars
        for (var i = 0; i < emailName.length; i += 1) {
            if (validChars.indexOf(emailName.charAt(i)) < 0) {
                alert("E-mail formatı yanlış.");
                window.returnValue = false;
                e.returnValue = false;
                return false;
            }
        }
        // emailDomain must only include valid chars
        for (var j = 0; j < emailDomain.length; j += 1) {
            if (validChars.indexOf(emailDomain.charAt(j)) < 0) {
                alert("E-mail formatı yanlış.");
                window.returnValue = false;
                e.returnValue = false;
                return false;
            }
        }

        // Domain must include but not start with .
        if (emailDomain.indexOf('.') <= 0) {
            alert("E-mail formatı yanlış.");
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }

        // Domain's last . should be 2 chars or more from the end
        var emailDomainParts = emailDomain.split('.');
        if (emailDomainParts[emailDomainParts.length - 1].length < 2) {
            alert("E-mail formatı yanlış.");
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }

        return true;
    }
</script>
