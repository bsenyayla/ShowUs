<%@ Page Language="C#" AutoEventWireup="true" Inherits="UnitTest_ThreadTest" CodeBehind="ThreadTest.aspx.cs" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
        <script src="https://code.jquery.com/jquery-3.2.1.js" integrity="sha256-DZAnKJ/6XZ9si04Hgrsxu/8s717jcIzLy3oi35EouyE=" crossorigin="anonymous"></script>
    <script src="http://ajax.aspnetcdn.com/ajax/jquery.ui/1.12.1/jquery-ui.min.js"></script>
    <script type="text/javascript">

        $(function ()
        {
            $('#defaultOpen').click(function () {
                e.preventDefault();
                openCity(event, 'London');
            });

            $('#defaultOpen2').click(function (e) {
                e.preventDefault();
                openCity(event, 'Paris');
            });

            $('#defaultOpen3').click(function () {
                e.preventDefault();
                openCity(event, 'Tokyo');
            });
            
        });

        function openCity(evt, cityName) {
            var i, tabcontent, tablinks;
            tabcontent = document.getElementsByClassName("tabcontent");

            for (i = 0; i < tabcontent.length; i++) {
                tabcontent[i].style.display = "none";
            }

            tablinks = document.getElementsByClassName("tablinks");

            for (i = 0; i < tablinks.length; i++) {
                tablinks[i].className = tablinks[i].className.replace(" active", "");
            }


            document.getElementById(cityName).style.display = "block";
            evt.currentTarget.className += " active";
        }
    </script>
    <style type="text/css">
        * {
            box-sizing: border-box;
        }

        body {
            font-family: "Lato", sans-serif;
        }

        /* Style the tab */
        .tab {
            float: left;
            border: 1px solid #ccc;
            background-color: #f1f1f1;
            width: 30%;
            height: 300px;
        }

            /* Style the buttons inside the tab */
            .tab button {
                display: block;
                background-color: inherit;
                color: black;
                padding: 22px 16px;
                width: 100%;
                border: none;
                outline: none;
                text-align: left;
                cursor: pointer;
                transition: 0.3s;
                font-size: 17px;
            }

                /* Change background color of buttons on hover */
                .tab button:hover {
                    background-color: #ddd;
                }

                /* Create an active/current "tab button" class */
                .tab button.active {
                    background-color: #ccc;
                }

        /* Style the tab content */
        .tabcontent {
            float: left;
            padding: 0px 12px;
            border: 1px solid #ccc;
            width: 70%;
            border-left: none;
            height: 300px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />


        <p>Click on the buttons inside the tabbed menu:</p>

        <div class="tab">
            <button class="tablinks" id="defaultOpen">London</button>
            <button class="tablinks" id="defaultOpen2">Paris</button>
            <button class="tablinks" id="defaultOpen3">Tokyo</button>
        </div>

        <div id="London" class="tabcontent">
            <h3>London</h3>
            <p>London is the capital city of England.</p>
        </div>

        <div id="Paris" class="tabcontent">
            <h3>Paris</h3>
            <p>Paris is the capital of France.</p>
        </div>

        <div id="Tokyo" class="tabcontent">
            <h3>Tokyo</h3>
            <p>Tokyo is the capital of Japan.</p>
        </div>


        <script type="text/javascript">


            // Get the element with id="defaultOpen" and click on it
            //document.getElementById("defaultOpen").click();
        </script>
    </form>
</body>
</html>
