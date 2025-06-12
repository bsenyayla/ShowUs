<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManualPreaccountingDetail.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Reconciliation.Detail.ManualPreaccountingDetail" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <rx:RegisterResources runat="server" ID="RR" />
            <rx:PanelX ID="PanelX2" runat="server" AutoHeight="Normal" Height="50" Width="300" ContainerPadding="true" Title="Ters Fiş">
                <Body>
                    <rx:ColumnLayout runat="server" ID="ColumnLayout8" ColumnWidth="100%">
                        <Rows>

                            <rx:RowLayout ID="RowLayout3" runat="server">
                                <Body>
                                    <rx:ColumnLayout runat="server" ID="c234234" ColumnWidth="20%">
                                        <Rows>
                                            <rx:RowLayout ID="RowLayout8" runat="server">
                                                <Body>
                                                    <strong>
                                                        <rx:Label ID="lblTransaction" runat="server"></rx:Label>
                                                    </strong>
                                                </Body>
                                            </rx:RowLayout>
                                        </Rows>
                                    </rx:ColumnLayout>
                                    <rx:ColumnLayout runat="server" ID="ColumnLayout9" ColumnWidth="40%">
                                        <Rows>
                                            <rx:RowLayout runat="server" ID="r123">
                                                <Body>
                                                    <cc1:CrmTextFieldComp runat="server" ID="new_TransactionNumber" ObjectId="201400027"
                                                        UniqueName="new_TransactionNumber" FieldLabelWidth="70" Width="230" PageSize="50">
                                                    </cc1:CrmTextFieldComp>
                                                </Body>
                                            </rx:RowLayout>
                                        </Rows>
                                    </rx:ColumnLayout>
                                    <rx:ColumnLayout runat="server" ID="c23412" ColumnWidth="10%">
                                        <Rows>
                                            <rx:RowLayout runat="server" ID="r345232">
                                                <Body>
                                                    <rx:Button ID="btnCreateReverseReceipt" runat="server" Text="Tersini Oluştur">
                                                        <AjaxEvents>
                                                            <Click OnEvent="CreateReverseReceipt" Before="return confirm('Ters fiş oluşturmak istediğinizden emin misiniz?');">
                                                            </Click>
                                                        </AjaxEvents>
                                                    </rx:Button>
                                                </Body>
                                            </rx:RowLayout>
                                        </Rows>
                                    </rx:ColumnLayout>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <br />
                </Body>
            </rx:PanelX>
            <rx:PanelX ID="PanelX4" runat="server" AutoHeight="Normal" Height="50" Width="300" ContainerPadding="true" Title="Serbest Fiş">
                <Body>
                    <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="100%">
                        <Rows>
                            <rx:RowLayout ID="RowLayout4" runat="server">
                                <Body>
                                    <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="20%">
                                        <Rows>
                                            <rx:RowLayout ID="RowLayout5" runat="server">
                                                <Body>
                                                    <strong>
                                                        <rx:Label ID="lblFreeText" runat="server"></rx:Label>
                                                    </strong>
                                                </Body>
                                            </rx:RowLayout>
                                        </Rows>
                                    </rx:ColumnLayout>
                                    <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="40%">
                                        <Rows>
                                            <rx:RowLayout runat="server" ID="RowLayout6">
                                                <Body>
                                                    <rx:ComboField runat="server" ID="new_MasterOperationTypeLabel" FieldLabel="İşlem Tipi" EmptyText="Seçiniz...">
                                                        <Items>
                                                            <rx:ListItem Text="Gonderim" Value="1" />
                                                            <rx:ListItem Text="Ödeme" Value="2" />
                                                            <rx:ListItem Text="İade Gönderim Talep (EFT-SWFIT)" Value="4" />
                                                            <rx:ListItem Text="İade Gönderim Onay (EFT-SWFIT)" Value="5" />
                                                            <rx:ListItem Text="İade Ödeme" Value="3" />
                                                            <rx:ListItem Text="Gonderim İptal" Value="14" />
                                                            <rx:ListItem Text="Ödeme İptal" Value="15" />
                                                            <rx:ListItem Text="İade Ödeme İptal" Value="16" />
                                                        </Items>
                                                    </rx:ComboField>
                                                </Body>
                                            </rx:RowLayout>
                                        </Rows>
                                    </rx:ColumnLayout>
                                    <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="10%">
                                        <Rows>
                                            <rx:RowLayout runat="server" ID="RowLayout7">
                                                <Body>
                                                    <rx:Button ID="btnCreateFreeReceipt" runat="server" Text="Serbest Fiş Oluştur">
                                                        <AjaxEvents>
                                                            <Click OnEvent="CreateFreeReceipt" Before="return confirm('Serbest fiş oluşturmak istediğinizden emin misiniz?');">
                                                            </Click>
                                                        </AjaxEvents>

                                                    </rx:Button>
                                                </Body>
                                            </rx:RowLayout>
                                        </Rows>
                                    </rx:ColumnLayout>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <br />
                </Body>
            </rx:PanelX>
            <rx:PanelX ID="PanelX3" runat="server" AutoHeight="Normal" Height="500" ContainerPadding="true">
                <Body>
                    <rx:GridPanel runat="server" ID="gpAccTran" AutoWidth="true" Editable="false" Mode="Local" AutoLoad="false" AjaxPostable="true">
                        <DataContainer>
                            <DataSource OnEvent="AccTranDataLoad">
                            </DataSource>
                            <Parameters>
                                <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                                <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                            </Parameters>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="İŞLEM NO" DataIndex="ISLEM_NO" Width="100"></rx:GridColumns>
                                <rx:GridColumns Header="HESAP HAREKET TİPİ" DataIndex="HESAP_HAREKET_TIPI" Width="250"></rx:GridColumns>
                                <rx:GridColumns Header="İŞLEM TİPİ" DataIndex="ISLEM_TIPI" Width="100"></rx:GridColumns>
                                <rx:GridColumns Header="TUTAR" DataIndex="TUTAR" Width="100"></rx:GridColumns>
                                <rx:GridColumns Header="DÖVİZ CİNSİ" DataIndex="DOVIZ_CINSI" Width="100"></rx:GridColumns>
                                <rx:GridColumns Header="HESAP" DataIndex="HESAP" Width="150"></rx:GridColumns>
                                <rx:GridColumns Header="YÖN" DataIndex="YON" Width="50"></rx:GridColumns>
                                <rx:GridColumns Header="LOGO HESAP" DataIndex="LOGO_HESAP" Width="150"></rx:GridColumns>
                                <rx:GridColumns Header="LOGO YÖN" DataIndex="LOGO_YON" Width="80"></rx:GridColumns>
                                <rx:GridColumns Header="OLUŞTURAN" DataIndex="OLUSTURAN" Width="150"></rx:GridColumns>
                                <rx:GridColumns Header="TARİH" DataIndex="TARIH" Width="150"></rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                        <BottomBar>
                            <rx:PagingToolBar ID="PagingToolBar1" runat="server" ControlId="gpAccTran">
                            </rx:PagingToolBar>
                        </BottomBar>
                    </rx:GridPanel>
                </Body>
            </rx:PanelX>
        </div>
    </form>
</body>
</html>
