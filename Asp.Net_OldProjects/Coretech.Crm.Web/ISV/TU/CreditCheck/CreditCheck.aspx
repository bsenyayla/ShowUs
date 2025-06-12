<%@ Page Language="C#" AutoEventWireup="true" Inherits="CreditCheck_CreditCheck" CodeBehind="CreditCheck.aspx.cs" %>

<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:TextField runat="server" ID="txtPayID" Hidden="true"></rx:TextField>
        <rx:PanelX runat="server" ID="pnl_Screen1" Height="100" AutoHeight="Normal" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="false" Title="AKTİFBANK ÖDEMESİ">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="70%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout9">
                            <Body>
                                <cc1:CrmBooleanComp runat="server" ID="new_SenderAndReceiverIsEqual" ObjectId="201500025" UniqueName="new_SenderAndReceiverIsEqual"></cc1:CrmBooleanComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <table style="width: 100%">
                                    <tr>
                                        <td>
                                            <rx:NumericField runat="server" ID="IdentificationNumber"></rx:NumericField>

                                        </td>
                                    </tr>
                                </table>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="rl1" runat="server">
                            <Body>
                                <rx:Button runat="server" ID="btnSearch" Icon="Magnifier" Text="Ara">
                                    <AjaxEvents>
                                        <Click OnEvent="Search_Click" Before="btnSearchClickValidate(e);"></Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="30%">
                    <Rows>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:PanelX runat="server" ID="PanelX1" Height="450" AutoHeight="Normal" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="100%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <rx:GridPanel runat="server" ID="GridPanelCredits" AutoWidth="true" AutoHeight="Normal"
                                    Height="400" Editable="false" Mode="Local" AutoLoad="false" AjaxPostable="true" Collapsible="false">
                                    <DataContainer>
                                    </DataContainer>
                                    <ColumnModel>
                                        <Columns>
                                            <rx:GridColumns ColumnId="DATA_ID" Width="200" Header="ID" Sortable="false"
                                                MenuDisabled="true" Hidden="true" DataIndex="DATA_ID" />
                                            <rx:GridColumns ColumnId="BASVURU_NO" Width="90" Header="Numara" Sortable="false"
                                                MenuDisabled="true" Hidden="false" DataIndex="BASVURU_NO" />
                                            <rx:GridColumns ColumnId="HESAP_NO" Width="400" Header="IBAN No" Sortable="false"
                                                MenuDisabled="true" Hidden="false" DataIndex="HESAP_NO" />
                                            <rx:GridColumns ColumnId="TUTAR" Width="200" Header="Tutar" Sortable="false"
                                                MenuDisabled="true" Hidden="false" DataIndex="TUTAR" />
                                        </Columns>
                                    </ColumnModel>
                                    <SelectionModel>
                                        <rx:RowSelectionModel ID="RowSelectionGridPanel" runat="server" ShowNumber="true" SingleSelect="true"></rx:RowSelectionModel>
                                    </SelectionModel>
                                    <BottomBar>
                                        <rx:ToolBar runat="server" ID="GridPanelCreditsToolBar">
                                            <Items>
                                                <rx:ToolbarFill runat="server" ID="toolBarfill"></rx:ToolbarFill>
                                                <rx:Button ID="btnPay" runat="server" Text="Ödeme Yap">
                                                    <AjaxEvents>
                                                        <Click OnEvent="btnPay_Click" Before="ValidatiBtnPay_Click(e);SetPayID();"></Click>
                                                    </AjaxEvents>
                                                </rx:Button>
                                            </Items>
                                        </rx:ToolBar>
                                    </BottomBar>
                                    <LoadMask ShowMask="true" />
                                </rx:GridPanel>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
        <rx:Label ID="lblName" runat="server"></rx:Label>
    </form>
</body>
</html>
<script>
    function btnSearchClickValidate(e) {
        if (IdentificationNumber.getValue().length < 10 || IdentificationNumber.getValue().length > 11) {
            alert("Lütfen TCKN bilgisini kontrol ediniz.");
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
        if (!new_SenderAndReceiverIsEqual.getValue()) {
            alert("Lütfen Gönderici ve Alıcı aynı Kişidir seçeneğini işaretleyip tekrar deneyiniz.");
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
    }
    function ValidatiBtnPay_Click(e) {
        if (GridPanelCredits.selectedRecJson == "") {
            alert("Lütfen ödeme yapılacak kaydı seçiniz.");
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
        //if (!confirm(GridPanelCredits.selectedRecords.TUTAR + " kredi ödemesi yapılacaktır. İşleme devam etmek istiyor musunuz?")) {
        if (!confirm("İşleme devam etmek istiyor musunuz?")) {
            window.returnValue = false;
            e.returnValue = false;
            return false;
        }
        return true;
    }

    function SetPayID() {
        txtPayID.setValue(GridPanelCredits.selectedRecord.DATA_ID);
    }
</script>
