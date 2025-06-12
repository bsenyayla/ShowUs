<%@ Control Language="C#" AutoEventWireup="true" Inherits="SenderDocument_FileUploaderUC" Codebehind="FileUploader.ascx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<rx:PanelX runat="server" ID="Fieldset2" AutoHeight="Normal" Height="30" AutoWidth="true"
    Collapsible="false" Border="false">
    <Body>
        <rx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="100%">
            <Rows>
                <rx:RowLayout runat="server" ID="RowLayout5">
                    <Body>

                        <rx:MultiField ID="mfFileSys" FieldLabel="Dosya" runat="server">
                            <Items>
                                <rx:FileUpload ID="senderDocumentFile" runat="server" AutoWidth="true" FieldLabelShow ="false">
                                </rx:FileUpload>
                                <rx:Label runat="server" Text="  " ID="lbl1" Width="10"></rx:Label>
                                <rx:Button runat="server" ID="btnDownload" Icon="DiskDownload" Text="İndir" Download="true">
                                    <AjaxEvents>
                                        <Click OnEvent="btnDownload_OnClick"></Click>
                                    </AjaxEvents>
                                </rx:Button>
                            </Items>
                        </rx:MultiField>

                    </Body>
                </rx:RowLayout>
            </Rows>
        </rx:ColumnLayout>
    </Body>
</rx:PanelX>


