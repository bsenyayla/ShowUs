<%@ Page Language="C#" AutoEventWireup="true" Inherits="BalanceStatements_Form" ValidateRequest="false" Codebehind="BalanceStatementForm.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script src="js/_BalanceStatementForm.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="hdnRecid">
        </rx:Hidden>
        <rx:Hidden runat="server" ID="hdnReportId">
        </rx:Hidden>



        <rx:PanelX runat="server" ID="Pnl1" Height="1000" AutoHeight="Auto" Title="Arama Kriterleri">
            <Body>
                <asp:Label ID="Header1" runat="server" Font-Bold="true" Font-Size="Large" Text="&nbspHesap Ekstresi / Account Statement"></asp:Label>
                <br />
                <br />
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="35%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_Corporation" ObjectId="201500008" RequirementLevel="BusinessRequired" UniqueName="new_Corporation"
                                    Width="150" PageSize="500" FieldLabel="200" Mode="Remote">
                                    <DataContainer>
                                        <DataSource OnEvent="CorporationLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_AccStatementID" ObjectId="201500008" RequirementLevel="BusinessRequired" UniqueName="new_AccStatementID"
                                    Width="150" PageSize="500" FieldLabel="200" Mode="Remote" LookupViewId="051F4E4B-227C-4CD9-9F6F-2A59B0BF366D">
                                    <DataContainer>
                                        <DataSource OnEvent="AccStatementLoad">
                                            <Columns>
                                                <rx:Column Name="VALUE" DataType="String" Width="400" Title="Tanım"></rx:Column>
                                            </Columns>
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="35%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <cc1:CrmDateFieldComp ID="new_StartDate" UniqueName="new_StartDate" runat="server" ObjectId="201500008" DateFormat="dd.MM.yyyy" RequirementLevel="BusinessRequired" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmDateFieldComp ID="new_EndDate" UniqueName="new_EndDate" runat="server" ObjectId="201500008" DateFormat="dd.MM.yyyy" RequirementLevel="BusinessRequired" FieldLabel="200" FieldLabelWidth="498" Width="400">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout15" ColumnWidth="20%">
                    <Rows>
                        <rx:RowLayout ID="CommandButton" runat="server">
                            <Body>
                                <rx:Button ID="btnSave" runat="server" Icon="PageWhiteAcrobat" Text="Pdf Önizle" Width="100">
                                    <AjaxEvents>
                                        <Click OnEvent="btnSaveOnEvent">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="20%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <rx:Button ID="Button1" runat="server" Icon="PageExcel" Text="Excel'e Gönder" Width="100" Download="true">
                                    <AjaxEvents>
                                        <Click OnEvent="btnSaveOnEvent2">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <br />
            </Body>
        </rx:PanelX>

    </form>
</body>
</html>

