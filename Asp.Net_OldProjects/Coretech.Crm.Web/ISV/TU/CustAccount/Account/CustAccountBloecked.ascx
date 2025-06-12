<%@ Control Language="C#" AutoEventWireup="true" Inherits="CustAccount_Account_CustAccountBloecked" Codebehind="CustAccountBloecked.ascx.cs" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register TagPrefix="cc1" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate" Assembly="Coretech.Crm.Web.UI.RefleX" %>
<style>
    .warning {
        display: block;
        margin-bottom: 5px;
        background-color: orange;
        border: 1px;
        border-left: 10px green solid;
        padding: 10px;
        border-radius: 4px;
        font-family: sans-serif;
        font-size: 14px;
    }
</style>
<p runat="server" id="pmessage"></p>
<rx:Window ID="windowBlocked" runat="server" Width="700" Height="300" Modal="true"
    CenterOnLoad="true" WindowCenter="false" Closable="true" Maximizable="false" Resizable="false"
    CloseAction="Hide" ShowOnLoad="false"
    Title="Hesaba Bloke Koy">
    <Body>
        <table>
            <tr>
                <td style="width: 300px">
                    <cc1:CrmPicklistComp ID="BlockedType" runat="server" ObjectId="201500042"
                        UniqueName="new_BlockedType" FieldLabelWidth="100" Width="150"
                        PageSize="50">
                        <AjaxEvents>
                            <Change OnEvent="BlockedTypeChanged"></Change>
                        </AjaxEvents>
                    </cc1:CrmPicklistComp>

                </td>
                  <th rowspan="2" style="width: 300px">
                    <cc1:CrmTextAreaComp ID="BlockDescription" runat="server" UniqueName="new_BlockedDescription" ObjectId="201500042" FieldLabelWidth="100">
                    </cc1:CrmTextAreaComp>
                </th>
            </tr>
            <tr>
                <td style="width: 300px">
                    <cc1:CrmDecimalComp ID="BlockedAmount" runat="server" ObjectId="201500042"
                        UniqueName="new_BlockedAmount" FieldLabelWidth="100" Width="150"
                        PageSize="50" Disabled="true">
                    </cc1:CrmDecimalComp>
                </td>
            </tr>
            <tr>
                <td>
                    <cc1:CrmDateFieldComp ID="BlockedStartDate" UniqueName="new_BlockedStartDate" ObjectId="201500042" FieldLabelWidth="100" Width="150" runat="server"
                        PageSize="50">
                    </cc1:CrmDateFieldComp>

                </td>
                <td style="width: 200px">
                    <cc1:CrmDateFieldComp ID="BlockedEndDate" runat="server" ObjectId="201500042" UniqueName="new_BlockedEndDate"
                        PageSize="50" FieldLabelWidth="100" Width="150">
                    </cc1:CrmDateFieldComp>
                </td>
            </tr>
        </table>
    </Body>

    <Buttons>
        <rx:Button runat="server" Icon="CoinsDelete" ID="windowBlockedBtnOk"
            Text="CRM.NEW_CUSTACCOUNTS_BLOCKED">
            <AjaxEvents>
                <Click OnEvent="windowBlockedBtnOkClick"></Click>
            </AjaxEvents>
        </rx:Button>
    </Buttons>

</rx:Window>
<rx:Window ID="windowUnBlocked" runat="server" Width="700" Height="300" Modal="true"
    CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
    CloseAction="Hide" ShowOnLoad="false"
    Title="Bloke Kaldır">
    <Body>
        <table>
            <tr>
                <td style="width: 300px">
                    <cc1:CrmPicklistComp ID="RBlockedType" runat="server" ObjectId="201500042"
                        UniqueName="new_BlockedType" FieldLabelWidth="100" Width="150" Disabled="true"
                        PageSize="50">
                    </cc1:CrmPicklistComp>

                </td>
                <th rowspan="2" style="width: 300px">
                    <cc1:CrmTextAreaComp ID="RBlockDescription" runat="server" UniqueName="new_BlockedDescription" ObjectId="201500042" FieldLabelWidth="100">
                    </cc1:CrmTextAreaComp>
                </th>
            </tr>
            <tr>
                <td style="width: 300px">
                    <cc1:CrmDecimalComp ID="RBlockedAmount" runat="server" ObjectId="201500042" Disabled="true"
                        UniqueName="new_BlockedAmount" FieldLabelWidth="100" Width="150"
                        PageSize="50">
                    </cc1:CrmDecimalComp>

                </td>
                <td style="width: 300px"></td>
            </tr>
            <tr>
                <td>
                    <cc1:CrmDateFieldComp ID="RBlockedStartDate" UniqueName="new_BlockedStartDate" ObjectId="201500042" FieldLabelWidth="100" Width="150" runat="server"
                        PageSize="50" Disabled="true">
                    </cc1:CrmDateFieldComp>

                </td>
                <td style="width: 200px">
                    <cc1:CrmDateFieldComp ID="RBlockedEndDate" runat="server" ObjectId="201500042" UniqueName="new_BlockedEndDate"
                        PageSize="50" FieldLabelWidth="100" Width="150" Disabled="true">
                    </cc1:CrmDateFieldComp>
                </td>
            </tr>
        </table>
    </Body>

    <Buttons>
        <rx:Button runat="server" Icon="CoinsAdd" ID="windowUnBlockedBtnOk"
            Text="CRM.NEW_CUSTACCOUNTS_UNBLOCKED">
            <AjaxEvents>
                <Click OnEvent="windowUnBlockedBtnOkClick"></Click>
            </AjaxEvents>
        </rx:Button>
    </Buttons>

</rx:Window>

<script>
    function showWindowBlocked() {

        s1_Container.style.height = "600px";
        windowBlocked.show();

        windowBlocked.setPosition(windowBlocked.getX(), 50);

    }
    function showWindowUnBlocked() {
        s1_Container.style.height = "600px";
        windowUnBlocked.show();
        windowUnBlocked.setPosition(windowUnBlocked.getX(), 50);

    }

</script>
