<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false" Inherits="TransferEdit_TransferEditMessage3rd" Codebehind="TransferEditMessage3rd.aspx.cs" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden ID="New_TransferId" runat="server" />
        <rx:PanelX runat="server" ID="PanelX3" AutoHeight="Normal" Height="300" AutoWidth="true"
            CustomCss="Section3" Collapsed="false" Collapsible="false" Border="false">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColumnLayout7" ColumnWidth="100%">
                    <Rows>
                        <rx:RowLayout runat="server" ID="RowLayout7">
                            <Body>
                                <cc1:CrmTextFieldComp runat="server" ID="TransferTuRef" ObjectId="201100072" ReadOnly="True"
                                    UniqueName="TransferTuRef" FieldLabel="200">
                                </cc1:CrmTextFieldComp>
                                
                                <cc1:CrmTextAreaComp runat="server" ID="new_EditMessage3rd" ObjectId="201100072"
                                    UniqueName="new_EditMessage3rd" FieldLabel="200" Width="400" Height="200">
                                </cc1:CrmTextAreaComp>

                            </Body>
                        </rx:RowLayout>


                    </Rows>
                </rx:ColumnLayout>


            </Body>
        </rx:PanelX>
        <rx:ToolBar runat="server" ID="ToolBarMain">
        <Items>
            <rx:ToolbarFill runat="server" ID="tf1" />
            <rx:ToolbarButton runat="server" ID="btnSave" runat="server" Icon="Disk" Text="Kaydet"
                Width="100">
                <AjaxEvents>
                    <Click OnEvent="btnSaveOnEvent" Before="CrmValidateForm(msg,e);">
                    </Click>
                </AjaxEvents>
            </rx:ToolbarButton>
        </Items>
    </rx:ToolBar>
    </form>
</body>
</html>

