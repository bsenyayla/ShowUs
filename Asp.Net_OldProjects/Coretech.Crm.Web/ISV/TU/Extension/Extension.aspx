<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Extension.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Extension.Extension" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Extension Mapping</title>
</head>
<body>
    <rx:RegisterResources runat="server" ID="RR" />
    <rx:Hidden ID="HdnRecId" runat="server" />
    <form id="form1" runat="server">
        <div>
            <rx:ToolBar ID="toolBar" runat="server">
                <Items>
                    <rx:Label ID="label2" runat="server" ImageUrl="../images/if_extension_79880.png" ImageHeight="36" ImageWidth="36" Width="40">
                    </rx:Label>
                    <rx:Label ID="FrmInfo" runat="server" Text="<b>&nbsp;&nbsp;Extension Definition</b>" Width="110" ForeColor="White"></rx:Label>

                    <rx:ToolbarSeparator ID="ToolbarSeparator7" runat="server"></rx:ToolbarSeparator>

                    <rx:ToolbarButton ID="BtnSave" runat="server" Icon="DatabaseSave" Text="Save">
                        <AjaxEvents>
                            <Click OnEvent="Save_Event" Before="return CrmValidateForm(msg,e);"></Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                </Items>
            </rx:ToolBar>
            <rx:PanelX ID="winWrapper" runat="server" Border="false" Padding="true" Height="160" AutoHeight="Normal">
                <Body>
                    <rx:PanelX runat="server" ID="pnlContent" Border="false" Padding="true">
                        <Body>
                            <rx:ColumnLayout runat="server" ID="ColumnLayout3" ColumnWidth="75%">
                                <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout12">
                                        <Body>
                                            <cc1:CrmComboComp runat="server" ID="New_ExtensionId" ObjectId="201700030" UniqueName="New_ExtensionId" RequirementLevel="BusinessRequired"
                                                Width="150" Mode="Remote">
                                                <AjaxEvents>
                                                    <Change OnEvent="ExtensionChange_Event"></Change>
                                                </AjaxEvents>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout1">
                                        <Body>
                                            <cc1:CrmComboComp ID="new_CorporationId" runat="server" ObjectId="201500039" UniqueName="new_CorporationId" RequirementLevel="BusinessRequired"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout2">
                                        <Body>
                                            <cc1:CrmComboComp ID="New_ExtensionTokenId" runat="server" ObjectId="201700031" UniqueName="New_ExtensionTokenId"
                                                FieldLabelWidth="100" Width="130" PageSize="50">
                                                <Filters>
                                                    <cc1:ComboFilter FromObjectId="201500039" FromUniqueName="new_CorporationId" ToObjectId="201700031"
                                                        ToUniqueName="new_CorporationId" />
                                                </Filters>
                                            </cc1:CrmComboComp>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout3">
                                        <Body>
                                            <rx:CheckField ID="Asynchronous" runat="server" FieldLabel="<b>Asynchronous</b>">
                                            </rx:CheckField>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout6">
                                        <Body>
                                            <rx:CheckField ID="iscash" runat="server" FieldLabel="<b>Cash</b>">
                                            </rx:CheckField>
                                        </Body>
                                    </rx:RowLayout>
                                    <rx:RowLayout runat="server" ID="RowLayout5">
                                        <Body>
                                            <rx:TextField ID="txtUrl" runat="server" FieldLabel="<b>Url</b>" RequirementLevel="BusinessRequired">
                                            </rx:TextField>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                            <rx:ColumnLayout runat="server" ID="ColumnLayout2" ColumnWidth="25%">
                                <Rows>
                                    <rx:RowLayout runat="server" ID="RowLayout4">
                                        <Body>
                                            <rx:Button ID="Information" Icon="Information" runat="server" Text="<b>Information</b>">
                                                <AjaxEvents>
                                                    <Click OnEvent="BtnShowInformationPAge">
                                                    </Click>
                                                </AjaxEvents>
                                            </rx:Button>
                                        </Body>
                                    </rx:RowLayout>
                                </Rows>
                            </rx:ColumnLayout>
                        </Body>
                    </rx:PanelX>
                </Body>
            </rx:PanelX>
            <rx:PanelX runat="server" ID="Panel_Extension" AutoHeight="Normal" Height="200" AutoWidth="true"
                CustomCss="Section2" Title="Extension Detail" Collapsed="false" Collapsible="true" ReadOnly="true" Enabled="false"
                Border="false">
                <AutoLoad Url="about:blank" />
                <Body>
                </Body>
            </rx:PanelX>
        </div>
    </form>
</body>
</html>

