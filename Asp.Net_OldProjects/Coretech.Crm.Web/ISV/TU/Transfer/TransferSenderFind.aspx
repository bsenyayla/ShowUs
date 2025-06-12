<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Transfer_TransferSenderFind" ValidateRequest="false" CodeBehind="TransferSenderFind.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <style>
        .trgclear {
            margin: 1px -5px 0 !important;
        }

            .trgclear span {
                cursor: pointer;
                background: url("<%=GlobalConfig.Settings.ResourcePath%>/Themes/Slate/Images/clear-trigger.gif");
                background-repeat: no-repeat;
                background-color: transparent;
                background-position: 0px -1px;
                border: 0 none;
                height: 17px !important;
                margin: 0 !important;
                padding: 0 !important;
                top: 1px !important;
                width: 16px !important;
                z-index: 2;
                border: 0 solid #B5B8C8;
            }
                    body .x-label
        {
                white-space: normal !important;
        }
    </style>
    <title></title>
    <script src="JS/TransferFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="ClearButton" runat="server" />
        <rx:Hidden ID="MainCurrency" runat="server" />
        <rx:KeyMap runat="server" ID="KeyMap1">
            <rx:KeyBinding>
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="ToolbarButtonFind.click(e);" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:KeyMap runat="server" ID="KeyMap2">
            <rx:KeyBinding Ctrl="true">
                <Keys>
                    <rx:Key Code="F9">
                        <Listeners>
                            <Event Handler="ToolbarButtonClear.click(e);" />
                        </Listeners>
                    </rx:Key>
                </Keys>
            </rx:KeyBinding>
        </rx:KeyMap>
        <rx:Window ID="SenderEditWindow" runat="server" Width="900" Height="500" Modal="true"
            Border="false" Closable="true" Maximizable="false" Resizable="true" CloseAction="Hide"
            ShowOnLoad="false" Title="Sender Information">
        </rx:Window>

        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="50" AutoWidth="true"
            Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout1" ColumnWidth="25%">

                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout1">
                            <Body>
                                <cc1:CrmComboComp ID="new_CustAccountTypeId" runat="server" ObjectId="201500039" UniqueName="new_CustAccountTypeId"
                                    FieldLabelWidth="100" Width="200" PageSize="50">
                                    <AjaxEvents>
                                        <Change OnEvent="CustAccountTypeOnEvent">
                                        </Change>
                                    </AjaxEvents>
                                </cc1:CrmComboComp>

                                <cc1:CrmComboComp runat="server" ID="new_SenderID" ObjectId="201100072" UniqueName="new_SenderID"
                                    ComboSearchCharCount="5" LookupViewUniqueName="FINDE_SENDER_LOOKUP" Width="150"
                                    PageSize="50" FieldLabel="200">

                                    <DataContainer>
                                        <DataSource OnEvent="new_SenderIDOnEvent">
                                        </DataSource>
                                    </DataContainer>
                                    <AjaxEvents>
                                        <Change OnEvent="ToolbarButtonFindClick">
                                        </Change>
                                    </AjaxEvents>
                                    <Listeners>
                                        <%-- <Blur Handler="if(!R.isEmpty(new_SenderID.getValue()))parent.window.new_RecipientID.focus();" />--%>
                                    </Listeners>
                                </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout3">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderNumber" runat="server" FieldLabel="200" ObjectId="201100052"
                                    UniqueName="new_SenderNumber" Width="150">
                                    <Listeners>
                                        <Blur Handler="if(!R.isEmpty(new_SenderNumber.getValue())){ToolbarButtonFind.click(e);parent.window.new_RecipientID.focus();}" />
                                    </Listeners>
                                </cc1:CrmTextFieldComp>

                                <cc1:CrmComboComp runat="server" ID="new_SenderPersonId" ObjectId="201100072" UniqueName="new_SenderPersonId" Hidden="true"
                                    Width="150" PageSize="50" FieldLabel="150">
                                    <Filters>
                                        <cc1:ComboFilter FromObjectId="201100072" FromUniqueName="new_SenderID" ToObjectId="201100072" ToUniqueName="new_SenderID" />
                                    </Filters>
                                </cc1:CrmComboComp>


                                <%--                                <cc1:CrmComboComp runat="server" Disabled="True" FieldLabelShow="False" Width="50" ID="new_CustAccountCurrencyId" ObjectId="201500039" UniqueName="new_CustAccountCurrencyId" LookupViewUniqueName="CURRENCY_TR" RequirementLevel="BusinessRequired">
                                </cc1:CrmComboComp>
                                <rx:TextField runat="server" ID="new_CustAccountBalance" Width="50" Disabled="True" />--%>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout4">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_NationalityID" ObjectId="201100052" UniqueName="new_NationalityID"
                                    Width="150" PageSize="50" FieldLabel="150">
                                    <Listeners>
                                        <Blur Handler="if(!R.isEmpty(new_NationalityID.getValue())){ToolbarButtonFind.click(e);parent.window.new_RecipientID.focus();}" />
                                    </Listeners>
                                </cc1:CrmComboComp>


                                <rx:MultiField runat="server" ID="mfCustAccount" FieldLabelShow="True" FieldLabelWidth="100" RequirementLevel="BusinessRecommend">
                                    <Items>
                                        <cc1:CrmComboComp ID="new_CustAccountId" runat="server" ObjectId="201500039" LookupViewUniqueName="CUSTACCOUNTS_LOOKUP" UniqueName="new_CustAccountId" RequirementLevel="BusinessRecommend"
                                            FieldLabelWidth="123" Width="200" PageSize="50">
                                            <DataContainer>
                                                <DataSource OnEvent="new_CustAccountId_OnEvent">
                                                </DataSource>
                                            </DataContainer>
                                            <AjaxEvents>
                                                <Change OnEvent="new_CustAccountId_OnChange">
                                                </Change>
                                            </AjaxEvents>
                                        </cc1:CrmComboComp>
                                        <cc1:CrmComboComp runat="server" Disabled="True" FieldLabelShow="False" Width="50" ID="new_CustAccountCurrencyId" ObjectId="201500039" UniqueName="new_CustAccountCurrencyId" LookupViewUniqueName="CURRENCY_TR" RequirementLevel="BusinessRequired">
                                        </cc1:CrmComboComp>
                                        <rx:TextField runat="server" ID="new_CustAccountBalance" Width="50" Disabled="True" />
                                    </Items>
                                </rx:MultiField>


                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout4" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout5">
                            <Body>
                                <cc1:CrmTextFieldComp ID="new_SenderIdendificationNumber1" runat="server" ObjectId="201100052"
                                    UniqueName="new_SenderIdendificationNumber1" FieldLabelShow="false">
                                    <Listeners>
                                        <Blur Handler="ToolbarButtonFind.click(e);parent.window.new_RecipientID.focus();" />
                                    </Listeners>
                                </cc1:CrmTextFieldComp>

                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>




        <rx:PanelX runat="server" ID="SenderDetailMain"  AutoWidth="true" Disabled="true"
            Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout5" ColumnWidth="75%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout2">
                            <Body>
                                <rx:PanelX runat="server" ID="SenderDetail" AutoWidth="true">
                                    <AutoLoad Url="about:blank" ShowMask="true" />
                                </rx:PanelX>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
                <rx:ColumnLayout runat="server" ID="ColumnLayout6" ColumnWidth="25%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout6">
                            <Body>
                                <buttons>
                                <rx:Button runat="server" ID="btnSenderEditUpdate" Icon="UserEdit" Text="SenderEditUpdate"
                                    Width="150">
                                    <%--<Listeners>
                                        <Click Handler="window.top.IsvWindowContainer=window;ShowEditWindow(null,new_SenderID.getValue(),'8d6b7207-251c-4a08-a0fc-b52b7d490965','201100052');" />
                                    </Listeners>--%>
                                    <AjaxEvents>
                                        <Click OnEvent="btnSenderEditUpdate_Click">
                                        </Click>
                                    </AjaxEvents>
                                </rx:Button>
                                <rx:Button runat="server" ID="ToolbarButtonFind" Text="(F9)" Icon="MagnifierZoomIn"
                                        Width="150">
                                        <AjaxEvents>
                                            <Click OnEvent="ToolbarButtonFindClick">
                                                <EventMask ShowMask="true" />
                                            </Click>
                                        </AjaxEvents>
                                    </rx:Button>
                                    <rx:Button runat="server" ID="ToolbarButtonClear" Text="(Ctrl+F9)" Icon="Erase" Width="150">
                                        <Listeners>
                                            <Click Handler="ToolbarButtonClear_Clear()" />
                                        </Listeners>
                                    </rx:Button>
                            </buttons>
                            </Body>
                        </rx:RowLayout>
                    </Rows>
                </rx:ColumnLayout>
            </Body>
        </rx:PanelX>
    </form>
</body>
</html>
