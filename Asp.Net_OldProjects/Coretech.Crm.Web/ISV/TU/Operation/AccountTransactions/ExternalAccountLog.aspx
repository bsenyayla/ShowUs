<%@ Page Language="C#" AutoEventWireup="true" Inherits="ExternalAccountLogPage" Codebehind="ExternalAccountLog.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="Js/_Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:GridPanel runat="server" ID="gvLog" AutoWidth="true" Editable="false" Mode="Remote" AutoLoad="true" AjaxPostable="true">
            <DataContainer>
                <DataSource OnEvent="LogDataBind">
                </DataSource>
            </DataContainer>
            <SelectionModel>
                <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" ShowNumber="true">
                </rx:RowSelectionModel>
            </SelectionModel>
            <ColumnModel>
                <Columns>
                    <rx:GridColumns ColumnId="BANKA_ISLEM_NO" Width="85" Header="Banka İşlem No" Sortable="false" MenuDisabled="true" Hidden="false" DataIndex="BANKA_ISLEM_NO" />
                    <rx:GridColumns ColumnId="BANKA_FIS_NO" Width="80" Header="Banka Fiş No" Sortable="false" MenuDisabled="true" Hidden="false" DataIndex="BANKA_FIS_NO" />
                    <rx:GridColumns ColumnId="AKTARIM_DURUMU" Width="170" Header="Aktarım Durumu" Sortable="false" MenuDisabled="true" Hidden="false" DataIndex="AKTARIM_DURUMU" />
                    <rx:GridColumns ColumnId="AKTARIM_SONUCU_ACIKLAMASI" Width="250" Header="Aktarım Sonucu Açıklaması" Sortable="false" MenuDisabled="true" Hidden="false" DataIndex="AKTARIM_SONUCU_ACIKLAMASI" />
                    <rx:GridColumns ColumnId="KULLANICI" Width="120" Header="Kullanıcı" Sortable="false" MenuDisabled="true" Hidden="false" DataIndex="KULLANICI" />
                    <rx:GridColumns ColumnId="TARIH" Width="128" Header="Tarih" Sortable="false" MenuDisabled="true" Hidden="false" DataIndex="TARIH" />
                </Columns>
            </ColumnModel>
            <LoadMask ShowMask="true" />
        </rx:GridPanel>
    </form>
</body>
</html>
