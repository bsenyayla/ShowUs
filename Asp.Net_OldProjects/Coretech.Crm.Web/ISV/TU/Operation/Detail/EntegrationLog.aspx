<%@ Page Language="C#" AutoEventWireup="true" Inherits="Operation.Detail.Operation_Detail_EntegrationLog" CodeBehind="EntegrationLog.aspx.cs" %>


<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="JS/TransferFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="TransferId" runat="server" />
         <rx:Hidden ID="hdnRecId" runat="server" />
        
        <rx:Hidden ID="PaymentId" runat="server" />
        <rx:Hidden ID="RefundpaymentId" runat="server" />
        <rx:Hidden ID="TransferReference" runat="server" />
        <rx:Hidden ID="TransactionType" runat="server" />

        <%--      <rx:PanelX ID="PanelX1" runat="server" AutoHeight="Normal" Height="600" Width="500" ContainerPadding="true" Title="Hesap Hareketleri">
            <Body>
                <div>

                    <asp:GridView ID="gvTransactionHistory" runat="server" Font-Size="Medium" Caption="İşlem Tarihçesi" EmptyDataText="Ya varsa?"></asp:GridView>
                    <p>&nbsp;</p>
                    <asp:GridView ID="gvEntegrationLog" runat="server" Font-Size="Medium" Caption="Entegrasyon Log" EmptyDataText="Ya varsa?"></asp:GridView>
                    <p>&nbsp;</p>

                </div>
            </Body>
        </rx:PanelX>--%>

        <rx:PanelX runat="server" ID="PanelX3" AutoHeight="Normal" Height="300" AutoWidth="true"
            Border="false">
            <Body>
                <body>
                    <rx:GridPanel runat="server" ID="GrdEntegrationlog" Title="Entegrasyon Log" Height="250"
                        AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Remote" AjaxPostable="true">
                        <DataContainer>
                            <DataSource OnEvent="ToolbarButtonFindEntegrationlogClick">
                            </DataSource>
                            <Parameters>
                                <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                                <rx:Parameter Name="limit" Value="20" Mode="Value"></rx:Parameter>
                            </Parameters>
                        </DataContainer>

                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                        <BottomBar>
                            <rx:PagingToolBar runat="server" ID="PagingToolBar2" Enabled="true" ControlId="GrdEntegrationlog">
                                <Buttons>
                                    <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="btnDownload2">
                                        <AjaxEvents>
                                            <Click OnEvent="ToolbarButtonFindEntegrationlogClick">
                                                <EventMask ShowMask="false" />
                                                <ExtraParams>
                                                    <rx:Parameter Name="Excel" Value="1" Mode="Value" />
                                                </ExtraParams>
                                            </Click>
                                        </AjaxEvents>
                                    </rx:SmallButton>
                                </Buttons>
                            </rx:PagingToolBar>
                        </BottomBar>
                        <LoadMask ShowMask="true" />
                    </rx:GridPanel>
                </body>
            </Body>
        </rx:PanelX>
    </form>
    <p>
    </p>
</body>
</html>

