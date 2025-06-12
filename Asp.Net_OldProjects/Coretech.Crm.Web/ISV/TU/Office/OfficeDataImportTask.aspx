<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OfficeDataImportTask.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Office.OfficeDataImportTask" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <rx:RegisterResources runat="server" ID="RR" />
            <br />
            <rx:PanelX ID="winWrapper" runat="server" Border="false" Padding="true" Title="Tanımlar">
                <Body>
                    <rx:Label ID="label1" runat="server" ImageUrl="../../../images/database-export.png" ImageHeight="36" ImageWidth="36" Width="40" Text="<b>Yeni Aktarım İşlemleri">
                    </rx:Label>
                    <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="100%">
                        <Rows>

                            <rx:RowLayout runat="server" ID="RowLayout2">
                                <Body>
                                    <rx:TextField ID="txtDescription" runat="server" FieldLabel="Aktarım Başlığı" RequirementLevel="BusinessRequired" FieldLabelWidth="15"></rx:TextField>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout runat="server" ID="RowLayout1">
                                <Body>
                                    <rx:FileUpload ID="upload1" runat="server" FieldLabel="Dosya" RequirementLevel="BusinessRequired"></rx:FileUpload>
                                </Body>
                            </rx:RowLayout>
<%--                            <rx:RowLayout runat="server" ID="RowLayout3">
                                <Body>
                                    <rx:ComboField ID="cfInterval" runat="server" FieldLabel="Süre (Dakika)" RequirementLevel="BusinessRequired">
                                        <Items>
                                            <rx:ListItem Text="1" Value="1" />
                                            <rx:ListItem Text="5" Value="5" />
                                            <rx:ListItem Text="15" Value="15" />
                                            <rx:ListItem Text="30" Value="30" />
                                            <rx:ListItem Text="60" Value="60" />
                                        </Items>
                                    </rx:ComboField>
                                </Body>
                            </rx:RowLayout>--%>
                            <rx:RowLayout runat="server" ID="RowLayout5">
                                <Body>
                                    <rx:CheckField ID="chkSentMail" runat="server" FieldLabel="Beni mail ile bilgilendir"></rx:CheckField>
                                    <br />
                                    <br />
                                    <br />
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                    <br />
                    <br />
                    <br />
                    <rx:ToolBar runat="server" ID="ToolBar2">
                        <Items>
                            <rx:ToolbarFill runat="server" ID="ToolbarFill1">
                            </rx:ToolbarFill>
                            <rx:ToolbarButton runat="server" ID="BtnSave" Text="Kaydet" Icon="DatabaseSave"
                                Width="100">
                                <AjaxEvents>
                                    <Click OnEvent="BtnSaveClick" Before="return CrmValidateForm(msg,e);">
                                        <EventMask ShowMask="true" Msg="Lütfen bekleyiniz. İşlem dosya yükleme sebebi ile zaman alabilir." />
                                    </Click>

                                </AjaxEvents>
                            </rx:ToolbarButton>
                            <rx:ToolbarButton runat="server" ID="BtnSaveAndImport" Text="Kaydet ve Aktarıma Başla" Icon="DatabaseSave"
                                Width="100">
                                <AjaxEvents>
                                    <Click OnEvent="BtnSaveAndImportClick" Before="return CrmValidateForm(msg,e);">

                                    </Click>
                                </AjaxEvents>
                            </rx:ToolbarButton>
                        </Items>
                    </rx:ToolBar>
                </Body>
            </rx:PanelX>

        </div>
    </form>
</body>
</html>
