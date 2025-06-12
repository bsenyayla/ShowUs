<%@ Page Language="C#" AutoEventWireup="true" Inherits="ExcelImport_Import" Codebehind="Import.aspx.cs" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>jQuery UI Progressbar - Default functionality</title>

    <meta charset="utf-8">

    <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
    <script src="//code.jquery.com/jquery-1.10.2.js"></script>
    <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
    <link rel="stylesheet" href="/resources/demos/style.css">
    <script>
        $(document).ready(function () {
            // TODO: revert the line below in your actual code
            //$("#progressbar").progressbar();
            setTimeout(updateProgress, 100);
        });

        function updateProgress() {
            $.ajax({
                type: "POST",
                url: "Default.aspx/GetData",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (msg) {
                    // TODO: revert the line below in your actual code
                    //$("#progressbar").progressbar("option", "value", msg.d);
                    $("#percentage").text(msg.d);
                    if (msg.d < 100) {
                        setTimeout(updateProgress, 100);
                    }
                }
            });
        }
    </script>

</head>


<body>
    <form id="form1" runat="server">
        <div>
            <!--<div id="progressbar" runat="server">
            </div>

            <asp:Button ID="Button1" runat="server" Text="Button" OnClick="Button1_Click" />-->


            <asp:Button ID="Button2" runat="server" Text="Button1" OnClick="Button1_Click" />
            Percentage:<asp:Label ID="percentage" runat="server"></asp:Label>

        </div>
    </form>
</body>
</html>
