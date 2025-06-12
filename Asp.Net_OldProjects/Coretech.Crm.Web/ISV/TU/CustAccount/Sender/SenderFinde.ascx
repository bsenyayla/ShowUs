<%@ Control Language="C#" AutoEventWireup="true" Inherits="CustAccount_Sender_SenderFinde" Codebehind="SenderFinde.ascx.cs" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>

<rx:Window ID="windowSenderSelector" runat="server" Width="800" Height="450" Modal="true"
    CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
    CloseAction="Hide" ShowOnLoad="false"
    Title="Gelismis Musteri Arama">
    <Body> 
        <rx:KeyMap runat="server" ID="KeyMap1">
            <rx:KeyBinding>
                <Keys>
                    <rx:Key Code="ENTER">
                        <Listeners>
                            <Event Handler="gpSenderSelector.reload();" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:PanelX runat="server" ID="windowSenderSelectorPanel1" AutoHeight="Normal" Height="90" AutoWidth="False" Width="790" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Listele">
            <Body>
                <table>
                    <tr>
                        <td style="width: 300px">
                            <cc1:CrmComboComp ID="Sendernew_NationalityID" runat="server" ObjectId="201100052"
                                UniqueName="new_NationalityID" FieldLabelWidth="100" Width="150"
                                PageSize="50">
                            </cc1:CrmComboComp>

                        </td>
                        <td style="width: 300px">
                            <cc1:CrmTextFieldComp ID="Sendernew_SenderNumber" runat="server" ObjectId="201100052" UniqueName="new_SenderNumber"
                                PageSize="50" FieldLabelWidth="100" Width="150">
                            </cc1:CrmTextFieldComp>
                        </td>
                        <td style="width: 300px">
                            <cc1:CrmTextFieldComp ID="SenderSender" runat="server" ObjectId="201100052" UniqueName="Sender"
                                PageSize="50" FieldLabelWidth="100" Width="150">
                            </cc1:CrmTextFieldComp>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <cc1:CrmComboComp ID="Sendernew_CustAccountTypeId" UniqueName="new_CustAccountTypeId" ObjectId="201100052" FieldLabelWidth="100" Width="150" runat="server"
                                PageSize="50">
                            </cc1:CrmComboComp>

                        </td>
                        <td style="width: 200px">
                            <cc1:CrmTextFieldComp ID="Sendernew_SenderIdendificationNumber1" runat="server" ObjectId="201100052" UniqueName="new_SenderIdendificationNumber1"
                                PageSize="50" FieldLabelWidth="100" Width="150">
                            </cc1:CrmTextFieldComp>
                        </td>
                        <td style="width: 200px">
                            <cc1:CrmTextFieldComp ID="new_SenderIdendificationNumber1Vkn" runat="server" ObjectId="201100052" UniqueName="new_SenderIdendificationNumber1" 
                                PageSize="50" FieldLabelWidth="100" Width="150">
                            </cc1:CrmTextFieldComp>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 200px">
                        <cc1:CrmTextFieldComp ID="Sendernew_CardNumber" runat="server" ObjectId="201600019" UniqueName="CardNumber"
                                FieldLabelWidth="100" Width="150">
                            </cc1:CrmTextFieldComp>
                        </td>
                        <td colspan="2"></td>
                    </tr>
                </table>
            </Body>
            <Buttons>
                <rx:Button runat="server" ID="windowSenderSelectorPanel1ToolbarButtonFind" Text="Listele" Icon="MagnifierZoomIn"
                    Width="100">
                    <Listeners>
                        <Click Handler="gpSenderSelector.reload();" />
                    </Listeners>
                </rx:Button>

            </Buttons>
        </rx:PanelX>
        <rx:GridPanel ID="gpSenderSelector" runat="server" AutoHeight="Normal" Height="210"
            AutoWidth="true" DisableSelection="true"
            FieldLabelShow="true" Mode="Remote" AutoLoad="False">
            <BottomBar>
                <rx:PagingToolBar ID="gpSenderSelectorPagingToolBar2" runat="server" ControlId="gpSenderSelector">
                    <Buttons>
                        <rx:SmallButton Download="true" Icon="PageWhiteExcel" ID="gpSenderSelectorPagingToolBar2SmallButton2" ToolTip="Export">
                            <AjaxEvents>
                                <Click OnEvent="gpSenderSelectorReload">
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
            <ColumnModel>
                <Columns>
                </Columns>
            </ColumnModel>
            <SelectionModel>
                <rx:RowSelectionModel ID="gpSenderSelectorRowSelection" runat="server" ShowNumber="True">
                    <Listeners>
                        <RowDblClick Handler="windowSenderSelectorBtnSelectSender.click();"></RowDblClick>
                    </Listeners>
                </rx:RowSelectionModel>
            </SelectionModel>
            <DataContainer>
                <DataSource OnEvent="gpSenderSelectorReload"></DataSource>
                <Parameters>
                    <rx:Parameter Name="start" Value="1" Mode="Value"></rx:Parameter>
                    <rx:Parameter Name="limit" Value="50" Mode="Value"></rx:Parameter>
                </Parameters>
            </DataContainer>

        </rx:GridPanel>
    </Body>
    <Buttons>
        <rx:Button runat="server" Icon="Add" ID="windowSenderSelectorBtnSelectSender"
            Text="Seç">
            <Listeners>
                <Click Handler=""></Click>
            </Listeners>
        </rx:Button>
    </Buttons>

</rx:Window>
