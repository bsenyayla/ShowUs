<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TransferDocument.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Transfer.TransferDocument" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        function checkDelete() {
            var ret = confirm('Seçili döküman silinecek, Emin misiniz?');
            return ret;
        }

        function checkDeleteAll() {
            var ret = confirm('Tüm dökümanlar silinecek, Emin misiniz?');
            return ret;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <div>
            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnObjectId" runat="server"></rx:Hidden>
            <rx:GridPanel runat="server" ID="GridPanelConfirmHistory" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
                Height="500" AutoLoad="true" Width="1200" Mode="Remote" AjaxPostable="true">
                <DataContainer>
                    <DataSource OnEvent="DocumentHistory">
                    </DataSource>
                </DataContainer>  
                <ColumnModel>
                    <Columns>
                        <rx:GridColumns ColumnId="ID" Width="100" Header="Tarih" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="ID" />
                        <rx:GridColumns ColumnId="TransferTuRef" Width="100" Header="UPT Referans" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TransferTuRef" />
                        <rx:GridColumns ColumnId="STATUS" Width="100" Header="Islem Durum" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="STATUS" />
                        <rx:GridColumns ColumnId="OPERATIONTYPENAME" Width="100" Header="Islem Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="OPERATIONTYPENAME" />
                        <rx:GridColumns ColumnId="CREATEDON" Width="100" Header="Tarih" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="CREATEDON" />
                        <rx:GridColumns ColumnId="DOCUMENTTYPE" Width="150" Header="Döküman Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="DOCUMENTTYPE" />
                        <rx:GridColumns ColumnId="USERNAME" Width="75" Header="Kullanıcı Adı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="USERNAME" />
                        <rx:GridColumns ColumnId="FILEPATH" Width="350" Header="Dosya Yolu" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="FILEPATH">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnType="Check" ColumnId="REQUIRED" Width="100" Header="Zorunlu Mu" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="REQUIRED" Editable="false">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnType="Check" ColumnId="UPLOADED" Width="100" Header="Yüklendi Mi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="UPLOADED" Editable="false">
                        </rx:GridColumns>
                    </Columns>
                </ColumnModel>
                <SelectionModel>
                    <rx:CheckSelectionModel ID="GridPanelMonitoringRowSelectionModel1" runat="server"
                        ShowNumber="true">
                        <%--<Listeners>
                            <RowDblClick Handler="ShowWindow(GridPanelMonitoring.id,GridPanelMonitoring.selectedRecord.ID,GridPanelMonitoring.selectedRecord.ObjectId,1);" />
                        </Listeners>--%>
                    </rx:CheckSelectionModel>
                   <%-- <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true" SingleSelect="true">
                    </rx:RowSelectionModel>--%>
                </SelectionModel>
                <LoadMask ShowMask="true" />
                <TopBar>
                    <rx:ToolBar ID="toolBar1" runat="server">
                        <Items>
                            <rx:Label ID="label1" runat="server" ImageUrl="../../../images/if_phone_transfer_32587.png" ImageHeight="36" ImageWidth="36" Width="40">
                            </rx:Label>
                            <rx:ToolbarSeparator ID="ToolbarSeparator7" runat="server"></rx:ToolbarSeparator>
                            <rx:ToolbarButton ID="ToolbarButton4" runat="server" Icon="TimeGo" Text="<b>Dosyayı İndir</b>" Download="true">
                                <AjaxEvents>
                                    <Click OnEvent="Process"></Click>
                                </AjaxEvents>
                            </rx:ToolbarButton>

                            <rx:ToolbarButton ID="BtnDeleteAll" runat="server" Icon="Delete" Text="<b>Tüm Dökümanları Sil</b>">
                                <AjaxEvents>
                                    <Click OnEvent="DeleteDocumentAll" Before="return checkDeleteAll();">
                                        <EventMask ShowMask="true" Msg="Siliniyor..." />
                                    </Click>
                                </AjaxEvents>
                            </rx:ToolbarButton>

                             
                            <rx:ToolbarButton ID="BtnDelete" runat="server" Icon="Delete" Text="<b>Seçili Dökümanı Sil</b>">
                                <AjaxEvents>
                                    <Click OnEvent="DeleteDocument" Before="return checkDelete();">
                                        <EventMask ShowMask="true" Msg="Siliniyor..." />
                                    </Click>
                                </AjaxEvents>
                            </rx:ToolbarButton>
                             
                        </Items>
                    </rx:ToolBar>
                </TopBar>

            </rx:GridPanel>
        </div>
    </form>
</body>
</html>
