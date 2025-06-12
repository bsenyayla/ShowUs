<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerList.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.KVKK.CustomerList" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        body .x-label {
            white-space: normal !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <rx:RegisterResources runat="server" ID="RR" />
            <rx:PanelX runat="server" ID="pnlSearch" Height="40" AutoHeight="Normal" AutoWidth="true" Border="true">
                <Body>
                    <rx:ColumnLayout runat="server" ID="cl1" ColumnWidth="23%">
                        <Rows>
                            <rx:RowLayout ID="rl1" runat="server">
                                <Body>
                                    <rx:TextField ID="tfName" runat="server" FieldLabel="Ad Soyad"></rx:TextField>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout runat="server" ID="cl2" ColumnWidth="23%">
                        <Rows>
                            <rx:RowLayout ID="rl2" runat="server">
                                <Body>
                                    <rx:TextField ID="tfIdentificationNumber" runat="server" FieldLabel="Vatandaşlık No" RequirementLevel="BusinessRequired"></rx:TextField>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout runat="server" ID="cl3" ColumnWidth="23%">
                        <Rows>
                            <rx:RowLayout ID="rl3" runat="server">
                                <Body>
                                    <rx:TextField ID="tfIdentityNo" runat="server" FieldLabel="Kimlik No" RequirementLevel="BusinessRequired" ></rx:TextField>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <rx:ColumnLayout runat="server" ID="cl4" ColumnWidth="14%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="rl4">
                                <Body>
                                    <rx:Button ID="btnList" runat="server" Text="Getir" Icon="Find">
                                        <AjaxEvents>
                                            <Click OnEvent="GetCustomerList"></Click>
                                        </AjaxEvents>
                                    </rx:Button>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                </Body>
            </rx:PanelX>
            <rx:PanelX ID="pnlList" runat="server">
                <Body>
                    <rx:GridPanel runat="server" ID="gpCustomers" AutoWidth="true" Editable="false" Mode="Local" AutoLoad="false" AjaxPostable="true">
                        <DataContainer>
                            <DataSource OnEvent="CustomerDataLoad">
                            </DataSource>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="" ColumnId="0" Width="55" Sortable="false" MenuDisabled="true" Align="Left">
                                    <Commands>
                                        <rx:ImageCommand Icon="Key" Text="İzinler">
                                            <AjaxEvents>
                                                <Click OnEvent="ShowPermissions">
                                                </Click>
                                            </AjaxEvents>
                                        </rx:ImageCommand>
                                    </Commands>
                                </rx:GridColumns>
                                <rx:GridColumns Header="" ColumnId="1" Width="75" Sortable="false" MenuDisabled="true">
                                    <Commands>
                                        <rx:ImageCommand Icon="Delete" Text="Veri Silme">
                                            <AjaxEvents>
                                                <Click Before="return confirm('Müşteriye ait veriler 10 yıl sonra silinecektir. İşlemi devam ettirmek için Tamam tuşuna tıklayınız.')" OnEvent="CustomerDataDelete">
                                                </Click>
                                            </AjaxEvents>
                                        </rx:ImageCommand>
                                    </Commands>
                                </rx:GridColumns>
                                <rx:GridColumns Header="" ColumnId="2" Width="60" Sortable="false" MenuDisabled="true">
                                    <Commands>
                                        <rx:ImageCommand Icon="ApplicationSideList" Text="Tarihçe">
                                            <AjaxEvents>
                                                <Click OnEvent="ShowHistory">
                                                </Click>
                                            </AjaxEvents>
                                        </rx:ImageCommand>
                                    </Commands>
                                </rx:GridColumns>
                                <rx:GridColumns Header="Id" ColumnId="3" DataIndex="CustomerId" Hidden="true" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Müşteri Kodu" ColumnId="4" DataIndex="CustomerCode" Width="75" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Müşteri Adı" ColumnId="5" DataIndex="CustomerName" Width="150" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Uyruk" ColumnId="6" DataIndex="CustomerNationality" Width="150" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Vatandaşlık No" ColumnId="7" DataIndex="CustomerIdentificationNumber" Width="150" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Kimlik Tipi" ColumnId="8" DataIndex="CustomerIdentityCardType" Width="150" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Kimlik No" ColumnId="9" DataIndex="CustomerIdentityNo" Width="150" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="İzin (UPT)" ColumnId="10" DataIndex="UPTPermission" Width="60" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <%--                                <rx:GridColumns Header="İzin (Banka)" ColumnId="11" DataIndex="BankPermission" Width="70" Sortable="false" MenuDisabled="true"></rx:GridColumns>  
                                <rx:GridColumns Header="İzin (Yurtdışı)" ColumnId="12" DataIndex="AbroadPartnerPermission" Width="75" Sortable="false" MenuDisabled="true"></rx:GridColumns>  
                                <rx:GridColumns Header="İzin (Diğer)" ColumnId="13" DataIndex="OtherPermission" Width="65" Sortable="false" MenuDisabled="true"></rx:GridColumns>--%>
                                <rx:GridColumns Header="İzin Tarihi" ColumnId="14" DataIndex="PermissionDate" Width="110" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Edinim Süreci" ColumnId="15" DataIndex="Workflow" Width="100" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Edinim Kanalı - Kurum" ColumnId="16" DataIndex="CorporationName" Width="125" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Edinim Kanalı - Ofis" ColumnId="17" DataIndex="OfficeName" Width="150" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Müşteri Onay Türü" ColumnId="18" DataIndex="ConfirmType" Width="100" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Veri Silme Talebi" ColumnId="19" DataIndex="HasDeleteRequestTaken" Width="90" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Silme Talep Tarihi" ColumnId="20" DataIndex="DeleteRequestDate" Width="110" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                    </rx:GridPanel>
                </Body>
                <Buttons>
                    <rx:Button runat="server" ID="bCustomerDataDelete" Hidden="true">
                        <AjaxEvents>
                            <Click OnEvent="CustomerDataDelete">
                            </Click>
                        </AjaxEvents>
                    </rx:Button>
                </Buttons>
            </rx:PanelX>
            <rx:Window ID="windowPermissions" runat="server" Width="600" Height="350" Modal="true"
                CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
                CloseAction="Hide" ShowOnLoad="false" Title="İzinler">
                <Body>
                    <rx:PanelX runat="server" ID="pnlPermissions" AutoHeight="Normal" Height="350" AutoWidth="true"
                        CustomCss="Section2" Collapsed="false" Collapsible="true"
                        Border="false">
                        <AutoLoad Url="about:blank" />
                        <Body>
                        </Body>
                    </rx:PanelX>
                </Body>
            </rx:Window>
            <rx:Window ID="windowHistory" runat="server" Width="1000" Height="400" Modal="true"
                CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
                CloseAction="Hide" ShowOnLoad="false" Title="Tarihçe">
                <Body>
                    <rx:PanelX runat="server" ID="pnlHistory" AutoHeight="Normal" Height="370" AutoWidth="true"
                        CustomCss="Section2" Collapsed="false" Collapsible="true"
                        Border="false">
                        <AutoLoad Url="about:blank" />
                        <Body>
                        </Body>
                    </rx:PanelX>
                </Body>
            </rx:Window>
        </div>
    </form>
</body>
</html>
