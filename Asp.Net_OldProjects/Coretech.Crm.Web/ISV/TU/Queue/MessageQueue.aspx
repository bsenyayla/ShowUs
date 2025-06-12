<%@ Page Language="C#" AutoEventWireup="true" Inherits="Queue_MessageQueue" Codebehind="MessageQueue.aspx.cs" ValidateRequest="false" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title></title>
</head>
<body>
    <rx:RegisterResources runat="server" ID="RR" />
    <form id="form1" runat="server">
        <div>
            <table style="width: 100%">
                <tr>
                    <td>
                        <rx:PanelX runat="server" ID="PanelX1" AutoHeight="Normal" Height="40" AutoWidth="true"
                            Border="true" Frame="true">
                            <Body>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="30%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout1" runat="server">
                                            <Body>
                                                <rx:ComboField runat="server" ID="cfQueue" Mode="Remote" FieldLabel="Kuyruk Yolu" DisplayField="QUEUE_PATH"  ValueField="MESSAGE_QUEUE_ID" 
                                                    RequirementLevel="BusinessRequired">
                                                    <DataContainer>
                                                        <DataSource OnEvent="QueueListDataBind">
                                                            <Columns>
                                                                <rx:Column Name="QUEUE_PATH" Width="300" />
                                                                <rx:Column Name="FORMATTER_TYPE" Width="0" Hidden="true" />
                                                            </Columns>
                                                        </DataSource>
                                                    </DataContainer>
                                                </rx:ComboField>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColoumnLayout2" ColumnWidth="30%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout2" runat="server">
                                            <Body>
                                                <rx:DateField ID="dStartDate" runat="server" FieldLabel="Başlangıç Tarihi" RequirementLevel="BusinessRequired"></rx:DateField>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="30%">
                                    <Rows>
                                        <rx:RowLayout ID="RowLayout3" runat="server">
                                            <Body>
                                                <rx:DateField ID="dEndDate" runat="server" FieldLabel="Bitiş Tarihi" RequirementLevel="BusinessRequired"></rx:DateField>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="10%">
                                    <Rows>
                                        <rx:RowLayout runat="server" ID="RowLayout4">
                                            <Body>
                                                <rx:Button ID="btnList" runat="server" Text="Getir" Icon="Find">
                                                    <AjaxEvents>
                                                        <Click OnEvent="ListDataClick"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Body>
                                        </rx:RowLayout>
                                    </Rows>
                                </rx:ColumnLayout>
                            </Body>
                        </rx:PanelX>
                    </td>
                </tr>
            </table>
            <rx:PanelX ID="pData" runat="server">
                <Body>
                    <rx:GridPanel runat="server" ID="gData" AutoWidth="true" Editable="false" Mode="Local" AutoLoad="false" AjaxPostable="true">
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="MESSAGE_ID" ColumnId="0" DataIndex="MESSAGE_ID" Width="0" Hidden="true" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="MESAJ BELİRTECİ" ColumnId="0" DataIndex="DATA_KEY" Width="300" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="OLUŞMA TARİHİ" ColumnId="1" DataIndex="CREATE_DATE_FORMATTED" Width="200" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="MESSAGE_STATUS" ColumnId="2" DataIndex="MESSAGE_STATUS" Width="0" Hidden="true" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="MESAJ DURUMU" ColumnId="3" DataIndex="MESSAGE_STATUS_TEXT" Width="200" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="MESSAGE_PROCESS_ID" ColumnId="4" DataIndex="MESSAGE_PROCESS_ID" Width="0" Hidden="true" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="PROCESS_STATUS" ColumnId="4" DataIndex="PROCESS_STATUS" Width="0" Hidden="true" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="İŞLEME DURUMU" ColumnId="5" DataIndex="PROCESS_STATUS_TEXT" Width="200" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="DENEME SAYISI" ColumnId="6" DataIndex="PROCESS_RETRY_COUNT" Width="120" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns ColumnId="btnDetail" Width="30" Header="TARİHÇE" Sortable="false" MenuDisabled="true">
                                    <Commands>
                                        <rx:ImageCommand Icon="Book">
                                            <AjaxEvents>
                                                <Click OnEvent="ShowHistory">
                                                </Click>
                                            </AjaxEvents>
                                        </rx:ImageCommand>
                                    </Commands>
                                </rx:GridColumns>
                                <rx:GridColumns ColumnId="btnReprocess" Width="30" Header="YENİDEN İŞLE" Sortable="false" MenuDisabled="true">
                                    <Commands>
                                        <rx:ImageCommand Icon="Reload">
                                            <AjaxEvents>
                                                <Click OnEvent="Reprocess">
                                                </Click>
                                            </AjaxEvents>
                                        </rx:ImageCommand>
                                    </Commands>
                                </rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SpecialSettings>
                            <rx:RowExpander Template="<pre lang='xml'>{DATA_FORMATTED}</pre>" Collapsed="true" />
                         </SpecialSettings> 
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                    </rx:GridPanel>
                </Body>
            </rx:PanelX>
        </div>
        <div>
            <rx:Window ID="windowHistory" runat="server" Width="800" Height="600" Modal="true"
                CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="true" Resizable="false"
                CloseAction="Hide" ShowOnLoad="false" Title="Tarihçe">
                <Body>
                    <p>Kuyruk Tarihçesi</p>
                    <rx:GridPanel runat="server" ID="gMessageHistory" AutoHeight="Normal" Height="200" Editable="false" Mode="Local" AutoLoad="false" 
                        AjaxPostable="true">
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="DURUM" ColumnId="0" DataIndex="MESSAGE_STATUS" Width="300" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="KULLANICI" ColumnId="1" DataIndex="USERNAME" Width="200" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="TARİH" ColumnId="2" DataIndex="CREATE_DATE_FORMATTED" Width="200" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel2" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                    </rx:GridPanel>
                    <p>İşleme Tarihçesi</p>
                    <rx:GridPanel runat="server" ID="gProcessHistory" AutoHeight="Normal" Height="350" Editable="false" Mode="Local" AutoLoad="false" 
                        AjaxPostable="true">
                        <ColumnModel>
                            <Columns>
                                <rx:GridColumns Header="DURUM" ColumnId="0" DataIndex="PROCESS_STATUS" Width="300" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="KULLANICI" ColumnId="1" DataIndex="USERNAME" Width="200" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                                <rx:GridColumns Header="TARİH" ColumnId="2" DataIndex="CREATE_DATE_FORMATTED" Width="200" Sortable="false" MenuDisabled="true"></rx:GridColumns>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <rx:RowSelectionModel ID="RowSelectionModel3" runat="server" ShowNumber="true">
                            </rx:RowSelectionModel>
                        </SelectionModel>
                    </rx:GridPanel>
                </Body>
            </rx:Window>
        </div>
    </form>
</body>
</html>
