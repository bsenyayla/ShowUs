<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerHistory.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.KVKK.CustomerHistory" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <rx:RegisterResources runat="server" ID="RR" />
            <rx:PanelX ID="pnlList" runat="server">
                <Body>
                    <rx:GridPanel runat="server" ID="gpHistory" AutoWidth="true" Editable="false" Mode="Local" AutoLoad="false" AjaxPostable="true">
                        <DataContainer>
                            <DataSource OnEvent="HistoryDataLoad">
                            </DataSource>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="Operasyon" ColumnId="1" DataIndex="TransactionType" Width="100" Sortable="false" MenuDisabled="true"></rx:GridColumns>        
                                <rx:GridColumns Header="İşlem Tipi" ColumnId="2" DataIndex="LogType" Width="100" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Log Verisi" ColumnId="3" DataIndex="LogDataHeader" Width="300" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Onay Tipi" ColumnId="4" DataIndex="ApprovalType" Width="100" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Onay Durumu" ColumnId="5" DataIndex="ApprovalStatus" Width="100" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Kullanıcı" ColumnId="6" DataIndex="UserFullname" Width="150" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="Tarih" ColumnId="7" DataIndex="CreateDateStr" Width="150" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                        <SpecialSettings>
                            <rx:RowExpander Template="{LogData}" Collapsed="true" />
                        </SpecialSettings>
                    </rx:GridPanel>
                </Body>
            </rx:PanelX>
        </div>
    </form>
</body>
</html>