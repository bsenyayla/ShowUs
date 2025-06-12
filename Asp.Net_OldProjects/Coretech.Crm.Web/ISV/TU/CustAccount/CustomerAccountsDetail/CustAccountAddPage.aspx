<%@ Page Language="C#" AutoEventWireup="true" Inherits="CustAccount_CustomerAccountsDetail_CustAccountAddPage" CodeBehind="CustAccountAddPage.aspx.cs" %>

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
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="hdnCustAccountTypeId" />
         <rx:Hidden runat="server" ID="hdnEurCount" />
         <rx:Hidden runat="server" ID="hdnUsdCount" />
         <rx:Hidden runat="server" ID="hdnTryCount" />

        <rx:PanelX ID="panel11" runat="server" Title="Upt Hesap Açma">
            <Body>
                <rx:ColumnLayout ID="column111" runat="server">
                    <Rows>
                        <rx:RowLayout ID="RowLayout9" runat="server">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout31" ColumnWidth="33%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout10" runat="server">
                                            <Body>
                                                <rx:CheckField FieldLabelWidth="50" ID="checkEur" runat="server" FieldLabel="EURO"></rx:CheckField>
                                            </Body>
                                        </rx:RowLayout>
                                        <rx:RowLayout ID="RowLayout1" runat="server">
                                            <Body>

                                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="40%">
                                                    <Rows>
                                                        <rx:RowLayout ID="RowLayout4" runat="server">
                                                            <Body>
                                                                <rx:Label ID="Label2" runat="server" Text="Hesap Adedi :"></rx:Label>

                                                            </Body>
                                                        </rx:RowLayout>
                                                    </Rows>
                                                </rx:ColumnLayout>
                                                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="40%">
                                                    <Rows>
                                                        <rx:RowLayout ID="RowLayout5" runat="server">
                                                            <Body>
                                                                <rx:Label ID="lblEurCount" runat="server"></rx:Label>
                                                            </Body>
                                                        </rx:RowLayout>
                                                    </Rows>
                                                </rx:ColumnLayout>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>

                                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="33%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout11" runat="server">
                                            <Body>
                                                <rx:CheckField ID="checkUsd" runat="server" FieldLabel="USD"></rx:CheckField>
                                            </Body>
                                        </rx:RowLayout>
                                    <%--    <rx:RowLayout ID="RowLayout2" runat="server">
                                            <Body>
                                                <rx:TextField ID="textUsdCount" runat="server" FieldLabel="Hesap Adedi" ReadOnly="true"></rx:TextField>
                                            </Body>
                                        </rx:RowLayout>--%>
                                          <rx:RowLayout ID="RowLayout2" runat="server">
                                            <Body>

                                                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="40%">
                                                    <Rows>
                                                        <rx:RowLayout ID="RowLayout6" runat="server">
                                                            <Body>
                                                                <rx:Label ID="Label1" runat="server" Text="Hesap Adedi :"></rx:Label>

                                                            </Body>
                                                        </rx:RowLayout>
                                                    </Rows>
                                                </rx:ColumnLayout>
                                                <rx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="40%">
                                                    <Rows>
                                                        <rx:RowLayout ID="RowLayout7" runat="server">
                                                            <Body>
                                                                <rx:Label ID="lblUsdCount" runat="server"></rx:Label>
                                                            </Body>
                                                        </rx:RowLayout>
                                                    </Rows>
                                                </rx:ColumnLayout>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="33%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout12" runat="server">
                                            <Body>
                                                <rx:CheckField ID="checkTry" runat="server" FieldLabel="TRY"></rx:CheckField>
                                            </Body>
                                        </rx:RowLayout>
                                      <rx:RowLayout ID="RowLayout3" runat="server">
                                            <Body>

                                                <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="40%">
                                                    <Rows>
                                                        <rx:RowLayout ID="RowLayout8" runat="server">
                                                            <Body>
                                                                <rx:Label ID="Label3" runat="server" Text="Hesap Adedi :"></rx:Label>

                                                            </Body>
                                                        </rx:RowLayout>
                                                    </Rows>
                                                </rx:ColumnLayout>
                                                <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="40%">
                                                    <Rows>
                                                        <rx:RowLayout ID="RowLayout13" runat="server">
                                                            <Body>
                                                                <rx:Label ID="lblTryCount" runat="server"></rx:Label>
                                                            </Body>
                                                        </rx:RowLayout>
                                                    </Rows>
                                                </rx:ColumnLayout>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="row123" runat="server">
                            <Body>
                                <rx:Button ID="BtnContinue" runat="server" Text="CRM.NEW_FRAUDLOG_BTN_CONTINUE" Icon="BookmarkGo">
                                    <AjaxEvents>
                                        <Click OnEvent="btnCreateCustAccount"></Click>
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
