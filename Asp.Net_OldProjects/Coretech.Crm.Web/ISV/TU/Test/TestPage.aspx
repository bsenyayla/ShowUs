<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false" CodeBehind="TestPage.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.Test.TestPage" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
    <script src="../Js/Global.js"></script>
    <script src="JS/TransferMainFactory.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script src="../Sender/Js/SenderFactory.js"></script>
    <script type="text/javascript">
        function ShowWindow(GridId, Id, ObjectId, PoolId) {
            var url = window.top.GetWebAppRoot + "/ISV/TU/Operation/Detail/_TransactionRouter.aspx?recid=" + Id + "&ObjectId=" + ObjectId;
            url += "&gridpanelid=" + GridId
            url += "&PoolId=" + PoolId

            //if (window != null) {
            //    url += "&tabframename=" + window.name;
            //    url += "&rlistframename=" + window.name
            //}
            //if (window.parent != null) {
            //    url += "&pawinid=" + window.parent.name;
            //    url += "&pframename=" + window.parent.name;
            //}

            window.top.newWindowRefleX(url, { maximized: false, width: 900, height: 600, resizable: true, modal: true, maximizable: false });
        }
    </script>
    <style>
        /*acc begin*/

        body {
            color: #6a6c6f;
            background-color: #f1f3f6;
            margin-top: 30px;
        }

        .container {
            max-width: 960px;
        }

        .panel-default > .panel-heading {
            color: #333;
            background-color: #fff;
            border-color: #e4e5e7;
            padding: 0;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
        }

            .panel-default > .panel-heading a {
                display: block;
                padding: 10px 15px;
            }

                .panel-default > .panel-heading a:after {
                    content: "";
                    position: relative;
                    top: 1px;
                    display: inline-block;
                    font-family: 'Glyphicons Halflings';
                    font-style: normal;
                    font-weight: 400;
                    line-height: 1;
                    -webkit-font-smoothing: antialiased;
                    -moz-osx-font-smoothing: grayscale;
                    float: right;
                    transition: transform .25s linear;
                    -webkit-transition: -webkit-transform .25s linear;
                }

                .panel-default > .panel-heading a[aria-expanded="true"] {
                    background-color: #eee;
                }

                    .panel-default > .panel-heading a[aria-expanded="true"]:after {
                        content: "\2212";
                        -webkit-transform: rotate(180deg);
                        transform: rotate(180deg);
                    }

                .panel-default > .panel-heading a[aria-expanded="false"]:after {
                    content: "\002b";
                    -webkit-transform: rotate(90deg);
                    transform: rotate(90deg);
                }

        .accordion-option {
            width: 100%;
            float: left;
            clear: both;
            margin: 15px 0;
        }

            .accordion-option .title {
                font-size: 20px;
                font-weight: bold;
                float: left;
                padding: 0;
                margin: 0;
            }

            .accordion-option .toggle-accordion {
                float: right;
                font-size: 16px;
                color: #6a6c6f;
            }

                .accordion-option .toggle-accordion:before {
                    content: "Tümünü Genişlet";
                }

                .accordion-option .toggle-accordion.active:before {
                    content: "Tümünü Daralt";
                }

        /*acc end*/
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <div>
            <div class="container">
                <rx:Button ID="Btn" runat="server" Text="Iptal">
                     <Listeners>
                         <Click Handler="ShowWindow('GridPanelMonitoring','57e75d2f-3db1-4f2a-84d1-b2cf765f8154','201100072','3');" />
                     </Listeners>
                </rx:Button>
                <asp:TextBox ID="TextBox1" runat="server"></asp:TextBox>



            </div>

        </div>
    </form>
</body>
</html>
