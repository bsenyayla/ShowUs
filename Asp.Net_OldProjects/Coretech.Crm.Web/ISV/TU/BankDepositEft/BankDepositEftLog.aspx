<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BankDepositEftLog.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.BankDepositEft.BankDepositEftLog" %>


<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <rx:RegisterResources runat="server" ID="RR" />
            <rx:PanelX runat="server" ID="PanelX3" AutoHeight="Normal" Height="300" AutoWidth="true"
                Border="false">
                <Body>
                    <body>
                        <rx:GridPanel runat="server" ID="GrdBankDepositEftLog" Title="Kurum Entegrasyon Eft Log" Height="250"
                            AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Remote" AjaxPostable="true">
                            <DataContainer>
                                <DataSource OnEvent="ToolbarButtonFindBankDepositEftLogClick">
                                </DataSource>


                            </DataContainer>
                            <ColumnModel>
                                <Columns>
                                    <rx:GridColumns ColumnId="CreatedOnUtcTime" Width="150" ColumnType="Normal" Header="Tarih" DataIndex="CreatedOnUtcTime">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="CreatedByName" Width="150" ColumnType="Normal" Header="Oluşturan" DataIndex="CreatedByName">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="new_Data" Width="150" ColumnType="Normal" Header="İstek" DataIndex="new_Data">
                                    </rx:GridColumns>
                                    <rx:GridColumns ColumnId="new_DataOut" Width="150" ColumnType="Normal" Header="Cevap" DataIndex="new_DataOut">
                                    </rx:GridColumns>
                                </Columns>
                            </ColumnModel>
                            <SpecialSettings>
                                <rx:RowExpander Template="<b>İstek</b><br/><br/>{new_Data}<br/><br/><b>Cevap</b><br/><br/>{new_DataOut}"
                                    Collapsed="true" />
                            </SpecialSettings>
                            <SelectionModel>
                                <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                                </rx:RowSelectionModel>
                            </SelectionModel>
                            <BottomBar>
                                <rx:PagingToolBar runat="server" ID="PagingToolBar2" Enabled="true" ControlId="GrdBankDepositEftLog">
                                    <Buttons>
                                    </Buttons>
                                </rx:PagingToolBar>
                            </BottomBar>
                            <LoadMask ShowMask="true" />
                        </rx:GridPanel>
                    </body>
                </Body>
            </rx:PanelX>
        </div>
    </form>
</body>
</html>
