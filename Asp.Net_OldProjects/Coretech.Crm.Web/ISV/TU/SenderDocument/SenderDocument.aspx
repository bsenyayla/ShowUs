<%@ Page Language="C#" AutoEventWireup="true" Inherits="SenderDocument_SenderDocument" Codebehind="SenderDocument.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="Js/SenderDocument.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <rx:RegisterResources runat="server" ID="RR" />
            <%--<rx:PanelX runat="server" ID="Fieldset2" AutoHeight="Normal" Height="20" AutoWidth="true"
                 Collapsible="false" Border="false">
                <Body>
                    <rx:ColumnLayout runat="server" ID="ColumnLayout12" ColumnWidth="100%">
                        <Rows>
                            <rx:RowLayout runat="server" ID="RowLayout15">
                                <Body>
                                    <rx:FileUpload ID="senderDocumentFile" runat="server" Width="100" FieldLabel="Dosya">
                                    </rx:FileUpload>
                                </Body>
                            </rx:RowLayout>
                        </Rows>
                    </rx:ColumnLayout>
                </Body>
            </rx:PanelX>--%>
        </div>
    </form>
</body>
</html>
