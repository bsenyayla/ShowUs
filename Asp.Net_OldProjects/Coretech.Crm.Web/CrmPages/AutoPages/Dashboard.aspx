<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_Dashboard" Codebehind="Dashboard.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <ajx:RegisterResources runat="server" ID="RR" />
    <ajx:MenuBar runat="server" ID="DashTool" AutoWidth="true">
        <Items>
            <ajx:MenuBarItem Text="Dashboard" runat="server">
                <Menu>
                    <ajx:Menu runat="server" ID="Menu1">
                        <Items>
                            <ajx:MenuItem runat="server" ID="Setting" Text="Dashboard Ayarları" Icon="ApplicationEdit">
                                <Listeners>
                                    <Click Handler="DashSettings.show();" />
                                </Listeners>
                            </ajx:MenuItem>
                            <ajx:MenuItem runat="server" ID="UserSave" Text="Kullanıcı Ayarlarını Kaydet" Icon="UserEdit">
                                <AjaxEvents>
                                    <Click OnEvent="SaveTab">
                                        <EventMask ShowMask="true" Msg="Kayıt Ediliyor..." />
                                        <ExtraParams>
                                            <ajx:Parameter Mode="Raw" Name="Windows" Value="GetWindows();" />
                                        </ExtraParams>
                                    </Click>
                                </AjaxEvents>
                            </ajx:MenuItem>
                        </Items>
                    </ajx:Menu>
                </Menu>
            </ajx:MenuBarItem>
            <ajx:MenuBarItem Text="Görünüm" runat="server">
                <Menu>
                    <ajx:Menu runat="server" ID="Menu2">
                        <Items>
                            <ajx:MenuItem runat="server" ID="MenuItem1" Text="Tüm Pencereleri Basamakla" Icon="ApplicationCascade">
                                <Listeners>
                                    <Click Handler="CascAllWin();" />
                                </Listeners>
                            </ajx:MenuItem>
                            <ajx:MenuItem runat="server" ID="MenuItem2" Text="Tüm Pencereleri Döşe" Icon="ApplicationTileHorizontal">
                                <Menu>
                                    <ajx:Menu runat="server" ID="Menu3">
                                        <Items>
                                            <ajx:MenuItem runat="server" ID="N2" Text="2xn">
                                                <Listeners>
                                                    <Click Handler="TileAllWin(2);" />
                                                </Listeners>
                                            </ajx:MenuItem>
                                            <ajx:MenuItem runat="server" ID="N3" Text="3xn">
                                                <Listeners>
                                                    <Click Handler="TileAllWin(3);" />
                                                </Listeners>
                                            </ajx:MenuItem>
                                            <ajx:MenuItem runat="server" ID="N4" Text="4xn">
                                                <Listeners>
                                                    <Click Handler="TileAllWin(4);" />
                                                </Listeners>
                                            </ajx:MenuItem>
                                            <ajx:MenuItem runat="server" ID="N5" Text="5xn">
                                                <Listeners>
                                                    <Click Handler="TileAllWin(5);" />
                                                </Listeners>
                                            </ajx:MenuItem>
                                            <ajx:MenuItem runat="server" ID="N6" Text="6xn">
                                                <Listeners>
                                                    <Click Handler="TileAllWin(6);" />
                                                </Listeners>
                                            </ajx:MenuItem>
                                        </Items>
                                    </ajx:Menu>
                                </Menu>
                            </ajx:MenuItem>
                        </Items>
                    </ajx:Menu>
                </Menu>
            </ajx:MenuBarItem>
        </Items>
    </ajx:MenuBar>
    <ajx:TabPanel runat="server" ID="DashboardTabs" AutoHeight="Auto" AutoWidth="true">
        <Tabs>
            <ajx:Tab runat="server" ID="Default" Title="Varsayılan" Closeable="false" TabMode="Frame"
                Url="DashboardTabs.aspx">
            </ajx:Tab>
        </Tabs>
    </ajx:TabPanel>
    <ajx:Window runat="server" ID="DashSettings" Width="700" Height="460" Dragable="true"
        CloseAction="Hide" BodyStyle="padding:10px;" Resizable="false" CenterOnLoad="true"
        Maximizable="false" Minimizable="false" Modal="true" ShowOnLoad="false" Title="Dashboard Ayarları">
        <Body>
            <ajx:Fieldset runat="server" ID="PnlSettings" Height="30" AutoHeight="Normal" Title="Bilgiler" Collapsible="false"
                Width="650" AutoWidth="false">
                <Body>
                    <ajx:ColumnLayout runat="server" ID="cl0" ColumnWidth="50%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout1" runat="server">
                                <Body>
                                    <ajx:ComboField runat="server" ID="TabsList" FieldLabel="Sekme Listesi" Width="200"
                                        Editable="false">
                                        <Items>
                                            <ajx:ListItem Value="NewGuid" Text="Yeni Sekme" />
                                        </Items>
                                        <Listeners>
                                            <Change Handler="ComboControl();ReportList.reload();" />
                                        </Listeners>
                                    </ajx:ComboField>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                    <ajx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="50%">
                        <Rows>
                            <ajx:RowLayout ID="RowLayout2" runat="server">
                                <Body>
                                    <ajx:TextField runat="server" ID="TabName" FieldLabel="Sekme İsmi" Width="200" ReadOnly="false">
                                    </ajx:TextField>
                                </Body>
                            </ajx:RowLayout>
                        </Rows>
                    </ajx:ColumnLayout>
                </Body>
            </ajx:Fieldset>
            <ajx:PanelX runat="server" ID="pnlGrd" Width="650" Height="300" AutoHeight="Normal"
                Title="Listesi">
                <Body>
                    <ajx:GridPanel runat="server" ID="ReportList" Height="250" Width="650" AutoWidth="true"
                        AutoHeight="Normal" PostAllData="true" Editable="true" AutoLoad="true" Mode="Remote">
                        <DataContainer>
                            <DataSource OnEvent="List">
                                <Columns>
                                    <ajx:Column Name="dashboardreportsId">
                                    </ajx:Column>
                                    <ajx:Column Name="reportname">
                                    </ajx:Column>
                                    <ajx:Column Name="ViewQueryId">
                                    </ajx:Column>
                                    <ajx:Column Name="DynamicUrlId">
                                    </ajx:Column>
                                    <ajx:Column Name="Url">
                                    </ajx:Column>
                                    <%--<ajx:Column Name="Closable">
                                    </ajx:Column>
                                    <ajx:Column Name="Resizable">
                                    </ajx:Column>
                                    <ajx:Column Name="Maximizable">
                                    </ajx:Column>
                                    <ajx:Column Name="Minimizable">
                                    </ajx:Column>--%>
                                </Columns>
                            </DataSource>
                            <Parameters>
                                <ajx:Parameter Mode="Value" Name="start" Value="0" />
                                <ajx:Parameter Mode="Value" Name="limit" Value="100" />
                            </Parameters>
                        </DataContainer>
                        <ColumnModel>
                            <Columns>
                                <ajx:GridColumns DataIndex="reportname" Header="Rapor Adı" Width="400" MenuDisabled="true" Sortable="false">
                                </ajx:GridColumns>
                               <%-- <ajx:GridColumns DataIndex="Closable" Header="Closable" Width="70" ColumnType="Check"
                                    Hidden="false">
                                </ajx:GridColumns>
                                <ajx:GridColumns DataIndex="Resizable" Header="Resizable" Width="70" ColumnType="Check"
                                    Hidden="false">
                                </ajx:GridColumns>
                                <ajx:GridColumns DataIndex="Maximizable" Header="Maximizable" Width="70" ColumnType="Check"
                                    Hidden="false">
                                </ajx:GridColumns>
                                <ajx:GridColumns DataIndex="Minimizable" Header="Minimizable" Width="70" ColumnType="Check"
                                    Hidden="false">
                                </ajx:GridColumns>--%>
                            </Columns>
                        </ColumnModel>
                        <SelectionModel>
                            <ajx:CheckSelectionModel ID="CheckSelectionModel1" runat="server">
                            </ajx:CheckSelectionModel>
                        </SelectionModel>
                        <LoadMask ShowMask="true" Msg="Yükleniyor..." />
                        <BottomBar>
                            <ajx:PagingToolBar runat="server" ID="PagingToolBar1" ControlId="ReportList">
                            </ajx:PagingToolBar>
                        </BottomBar>
                    </ajx:GridPanel>
                </Body>
                <Buttons>
                    <ajx:Button runat="server" Text="Kaydet" ID="btnSave" Icon="ScriptSave">
                        <AjaxEvents>
                            <Click OnEvent="Save">
                            </Click>
                        </AjaxEvents>
                    </ajx:Button>
                    <ajx:Button runat="server" Text="Sil" ID="ToolbarButton4" Icon="ScriptDelete">
                        <AjaxEvents>
                            <Click OnEvent="Delete" Success="CloseAndRefresh();">
                            </Click>
                        </AjaxEvents>
                    </ajx:Button>
                    <ajx:Button runat="server" Text="Kaydet ve Kapat" ID="ToolbarButton3" Icon="ScriptStart">
                        <AjaxEvents>
                            <Click OnEvent="Save" Success="CloseAndRefresh();">
                            </Click>
                        </AjaxEvents>
                    </ajx:Button>
                </Buttons>
            </ajx:PanelX>
        </Body>
    </ajx:Window>
    </form>
</body>
</html>
<script type="text/javascript" language="javascript">
    var CascAllWin = function () {
        var frm = DashboardTabs.getActiveIFrame();
        frm.R.WindowMng.cascade();
    }
    var TileAllWin = function (sutun) {
        var frm = DashboardTabs.getActiveIFrame();
        frm.R.WindowMng.tile(sutun);
    }
    function ComboControl() {
        if (TabsList.getValue() == "NewGuid") {
            TabName.clear();
        }
        else {
            TabName.setValue(TabsList.getRawValue());
        }
    }
    function CloseAndRefresh() {
        document.location.href = document.location.href;
    }
    function GetWindows() {
        var json = "";
        var wins = { TabId: DashboardTabs.getActiveTab(), Tabs: [] };
        for (var i = 0; i < DashboardTabs.getActiveIFrame().R.WindowMng.windows.length; i++) {
            var w = DashboardTabs.getActiveIFrame().R.WindowMng.windows[i];
            var item = {
                Title: w.title,
                Maximized: w.maximized,
                Minimized: w.minimized,
                Width: w.width,
                Height: w.height,
                X: w.getX(),
                Y: w.getY()
            };

            wins["Tabs"].push(item);
        }
        json = JSON.encode(wins);
        return json;
    }
</script>
