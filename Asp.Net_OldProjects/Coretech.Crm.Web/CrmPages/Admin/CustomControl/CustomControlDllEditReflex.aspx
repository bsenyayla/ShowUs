<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_CustomControl_CustomControlDllEditReflex" Codebehind="CustomControlDllEditReflex.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <div style="display: none">
        <rx:Hidden ID="hCustomControlDllId" runat="server">
        </rx:Hidden>
    </div>
    <div style="padding: 5px;">
        <div style="height:80px">
            <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="100%">
                <Rows>
                    <rx:RowLayout ID="RowLayout2" runat="server">
                        <Body>
                            <rx:TextField ID="TxtDllName" runat="server" FieldLabel="Name" AutoWidth="true" />
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout ID="RowLayout3" runat="server">
                        <Body>
                            <rx:CheckField ID="ChkDataBase" runat="server" Checked="true" FieldLabel="Database" />
                        </Body>
                    </rx:RowLayout>
                    <rx:RowLayout runat="server" ID="RowLayout8">
                        <Body>
                            <rx:FileUpload ID="FileUpload1" runat="server" EmptyText="Dosya Seç" FieldLabel="Dil" Width="200"
                                AutoWidth="true">
                            </rx:FileUpload>
                        </Body>
                    </rx:RowLayout>
                </Rows>
            </rx:ColumnLayout>
        </div>
        <table width="100%">
            <tr align="center">
                <td align="right">
                    <rx:Button ID="btnSave" runat="server" Text="Save" Width="80">
                        <AjaxEvents>
                            <Click OnEvent="UploadClick">
                            </Click>
                        </AjaxEvents>
                    </rx:Button>
                </td>
                <td align="left">
                    <rx:Button ID="btnReset" runat="server" Text="Reset" Width="80">
                        <AjaxEvents>
                            <Click OnEvent="ResetClick">
                            </Click>
                        </AjaxEvents>
                    </rx:Button>
                </td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
