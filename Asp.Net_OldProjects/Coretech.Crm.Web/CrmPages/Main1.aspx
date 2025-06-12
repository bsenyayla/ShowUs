<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Main1"
    ValidateRequest="false" ViewStateMode="Enabled" EnableViewState="True" CodeBehind="Main1.aspx.cs" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="../js/globalDelete.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script src="../js/globalAssign.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script src="../js/Global.js?<%=App.Params.AppVersion %>" type="text/javascript"></script>
    <script src="../js/IeVersion.js?<%=App.Params.AppVersion %>"></script>

    <link href="../ISV/TU/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../ISV/TU/fonts/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../../js/jquery.min.js" type="text/javascript"></script>
    <script src="../../../../ISV/TU/js/bootstrap.min.js" type="text/javascript"></script>


    <%--<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" />--%>
    <%--    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" />--%>
    <%--    <script
        src="https://code.jquery.com/jquery-3.3.1.js"
        integrity="sha256-2Kok7MbOyxpgUVvAk/HJ2jigOSYS2auK4Pfzbm7uH60="
        crossorigin="anonymous" type="text/javascript"></script>--%>
    <!-- Latest compiled and minified JavaScript -->
    <%--    <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js" type="text/javascript"></script>--%>

    <style type="text/css">
        .dropbtn {
            color: white;
            padding: 16px;
            font-size: 16px;
            border: none;
        }

        .dropdown {
            position: relative;
            display: inline-block;
        }

        .dropdown-content {
            display: none;
            position: absolute;
            background-color: #f1f1f1;
            min-width: 270px;
            box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
            z-index: 1;
        }

            .dropdown-content a {
                color: black;
                padding: 12px 16px;
                text-decoration: none;
                display: block;
            }

                .dropdown-content a:hover {
                    background-color: #ddd;
                }

        .dropdown:hover .dropdown-content {
            display: block;
        }

        .dropdown:hover .dropbtn {
            background-color: #3e8e41;
        }
    </style>

    <style type="text/css">
        #myInput {
            background-image: url('../images/searchicon.png'); /* Add a search icon to input */
            background-position: 10px 12px; /* Position the search icon */
            background-repeat: no-repeat; /* Do not repeat the icon image */
            width: 100%; /* Full-width */
            font-size: 16px; /* Increase font-size */
            padding: 12px 20px 12px 40px; /* Add some padding */
            border: 1px solid #ddd; /* Add a grey border */
            margin-bottom: 12px; /* Add some space below the input */
        }

        #myUL {
            /* Remove default list styling */
            list-style-type: none;
            padding: 0;
            margin: 0;
        }

            #myUL li a {
                border: 1px solid #ddd; /* Add a border to all links */
                margin-top: -1px; /* Prevent double borders */
                background-color: #f6f6f6; /* Grey background color */
                padding: 12px; /* Add some padding */
                text-decoration: none; /* Remove default text underline */
                font-size: 18px; /* Increase the font-size */
                color: black; /* Add a black text color */
                display: block; /* Make it into a block element to fill the whole list */
            }

                #myUL li a:hover:not(.header) {
                    background-color: #eee; /* Add a hover effect to all links, except for headers */
                }



        #accordian {
            background: #ffffff;
            width: 100%;
            color: black;
        }



            #accordian h3 {
                background: #ffffff;
                /*background: linear-gradient(#DEF5DA, #D1F2CB);*/
                background: linear-gradient(#C04612,#EA5B1C);
            }

                #accordian h3 a {
                    padding: 0 10px;
                    font-size: 17px;
                    line-height: 35px;
                    display: block;
                    /*color: black;*/
                    color: white;
                    text-decoration: none;
                }

                #accordian h3:hover {
                    text-shadow: 0 0 1px rgba(10, 69, 151, 0.7);
                }

        i {
            margin-right: 10px;
        }

        #accordian li {
            list-style-type: none;
        }

        #accordian ul ul li a,
        #accordian h4 {
            color: black;
            text-decoration: none;
            font-size: 15px;
            line-height: 35px;
            display: block;
            padding: 0 20px;
            transition: all 0.15s;
            position: relative;
        }

            #accordian ul ul li a:hover {
                background: #0A4597;
                border-left: 10px solid lightgreen;
                color: white;
            }

        #accordian ul ul {
            display: none;
        }

        #accordian li.active > ul {
            display: block;
        }

        #accordian ul ul ul {
            margin-left: 15px;
            border-left: 1px dotted rgba(0, 0, 0, 0.5);
        }

        #accordian a:not(:only-child):after {
            content: "\f104";
            font-family: fontawesome;
            position: absolute;
            right: 10px;
            top: 0;
            font-size: 30px;
        }

        #accordian .active > a:not(:only-child):after {
            content: "\f107";
            font-size: 30px;
        }




        loading-mask {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            z-index: 20000;
            background-color: white;
        }

        .status {
            color: #555;
        }

        .x-progress-wrap.left-align .x-progress-text {
            text-align: left;
        }

        .x-progress-wrap.custom {
            height: 17px;
            border: 1px solid #686868;
            overflow: hidden;
            padding: 0 2px;
        }

        .ext-ie .x-progress-wrap.custom {
            height: 19px;
        }

        .custom .x-progress-inner {
            height: 17px;
            background: #fff;
        }
    </style>


    <style>
        /*!
 * Start Bootstrap - Simple Sidebar HTML Template (https://startbootstrap.com)
 * Code licensed under the Apache License v2.0.
 * For details, see http://www.apache.org/licenses/LICENSE-2.0.
 */

        /* Toggle Styles */

        #wrapper {
            padding-left: 0;
            -webkit-transition: all 0.5s ease;
            -moz-transition: all 0.5s ease;
            -o-transition: all 0.5s ease;
            transition: all 0.5s ease;
        }

            #wrapper.toggled {
                padding-left: 400px;
            }

        #sidebar-wrapper {
            z-index: 1000;
            position: fixed;
            left: 400px;
            width: 0;
            height: 100%;
            margin-left: -400px;
            overflow-y: auto;
            background: #000;
            -webkit-transition: all 0.5s ease;
            -moz-transition: all 0.5s ease;
            -o-transition: all 0.5s ease;
            transition: all 0.5s ease;
        }

        #wrapper.toggled #sidebar-wrapper {
            width: 250px;
        }

        #page-content-wrapper {
            width: 100%;
            position: absolute;
            padding: 5px;
        }

        #wrapper.toggled #page-content-wrapper {
            position: absolute;
            margin-right: -400px;
        }

        /* Sidebar Styles */

        .sidebar-nav {
            position: absolute;
            top: 0;
            width: 400px;
            margin: 0;
            padding: 0;
            list-style: none;
        }

            .sidebar-nav li {
                text-indent: 20px;
                line-height: 40px;
            }

                .sidebar-nav li a {
                    display: block;
                    text-decoration: none;
                    color: #999999;
                }

                    .sidebar-nav li a:hover {
                        text-decoration: none;
                        color: #fff;
                        background: rgba(255,255,255,0.2);
                    }

                    .sidebar-nav li a:active,
                    .sidebar-nav li a:focus {
                        text-decoration: none;
                    }

            .sidebar-nav > .sidebar-brand {
                height: 65px;
                font-size: 18px;
                line-height: 60px;
            }

                .sidebar-nav > .sidebar-brand a {
                    color: #999999;
                }

                    .sidebar-nav > .sidebar-brand a:hover {
                        color: #fff;
                        background: none;
                    }

        @media(min-width:768px) {
            #wrapper {
                padding-left: 400px;
            }

                #wrapper.toggled {
                    padding-left: 0;
                }

            #sidebar-wrapper {
                width: 400px;
            }

            #wrapper.toggled #sidebar-wrapper {
                width: 0;
            }

            #page-content-wrapper {
                position: relative;
            }

            #wrapper.toggled #page-content-wrapper {
                position: relative;
                margin-right: 0;
            }
        }
    </style>

</head>
<script type="text/javascript" language="javascript">
    window.addEventListener("keydown", checkKeyPressed, false);
    function checkKeyPressed(e) {
        if (e.keyCode == "118") {
            var config = "/isv/tu/dev/Developer.aspx";
            window.top.newWindow(config, { title: 'Analysts & Developers', width: 300, height: 300, resizable: true });
        }
    }
    function Navigate(name, value) {
        if (value != "") {

            PnlCenter.setTitle(name);
            PnlCenter.load(value);
            topFunction();
        }
    }
    function NewWindow() {
        var config = "/isv/tu/transfer/TransferMainNew.aspx";
        window.top.newWindow(config, { title: 'Gönderim İşlemleri', width: 800, height: 350, resizable: true });
    }


</script>
<body>
    <form id="form1" runat="server">
        <ajx:RegisterResources runat="server" ID="RR" />
        <ajx:MenuBar ID="MenuBar1" runat="server" AutoWidth="true" Hidden="true">
            <Items>
                <ajx:MenuBarItem Fill="true" />
                <ajx:MenuBarItem ID="PasswordHistory">
                </ajx:MenuBarItem>
                <ajx:MenuBarItem Text="Welcome" Icon="User">
                    <Menu>
                        <ajx:Menu runat="server" ID="usermenu">
                            <Items>
                                <ajx:MenuItem runat="server" ID="pchange" Text="Şifre Değiştir">
                                    <Listeners>
                                        <Click Handler="PnlCenter.load('Admin/Administrations/User/UserPassWord.aspx');" />
                                    </Listeners>
                                </ajx:MenuItem>
                                <ajx:MenuSeparator runat="server" ID="sp1">
                                </ajx:MenuSeparator>
                                <ajx:MenuItem runat="server" ID="ChangeBu" Text="CHANGEBU">
                                    <Menu>
                                        <ajx:Menu runat="server" ID="ChangeBuMenu">
                                        </ajx:Menu>
                                    </Menu>
                                </ajx:MenuItem>
                            </Items>
                        </ajx:Menu>
                    </Menu>
                </ajx:MenuBarItem>
                <ajx:MenuBarItem Text="Home Page" Icon="ApplicationHome">
                    <Menu>
                        <ajx:Menu runat="server" ID="mnuHome">
                            <Items>
                                <ajx:MenuItem runat="server" ID="home" Text="Home Page" Icon="ApplicationHome">
                                    <Listeners>
                                        <Click Handler="document.location.href = '../CrmPages/Main1.aspx';" />
                                    </Listeners>
                                </ajx:MenuItem>
                                <ajx:MenuSeparator runat="server" ID="MenuSeparator1">
                                </ajx:MenuSeparator>
                                <ajx:MenuItem runat="server" ID="CrmCalendar" Text="Calendar" Icon="Calendar">
                                    <Listeners>
                                        <Click Handler="PnlCenter.setTitle('Takvim');PnlCenter.load('AutoPages/Calendar.aspx');" />
                                    </Listeners>
                                </ajx:MenuItem>
                                <ajx:MenuSeparator runat="server" ID="MenuSeparator2">
                                </ajx:MenuSeparator>

                            </Items>
                        </ajx:Menu>
                    </Menu>
                </ajx:MenuBarItem>
                <ajx:MenuBarItem Text="Logout" Icon="Disconnect">
                    <Menu>
                        <ajx:Menu runat="server" ID="Menu1">
                            <Items>
                                <ajx:MenuItem runat="server" ID="MenuItem1" Text="Logout" Icon="Disconnect">
                                    <Listeners>
                                        <Click Handler="document.location.href = '../Login.aspx?dologin=0';" />
                                    </Listeners>
                                </ajx:MenuItem>
                            </Items>
                        </ajx:Menu>
                    </Menu>
                </ajx:MenuBarItem>
            </Items>
        </ajx:MenuBar>




        <div id="wrapper" onmouseover="R.reSize();">

            <!-- Sidebar -->
            <div id="sidebar-wrapper" style="background-color: white; padding-left: 5px; overflow: hidden;">
                <div style="height: 100px; border: 1px">




                    <p class="text-center" style="font-size: 20px; font-weight: bold; color: #0A4597; margin-bottom: 10px; margin-top: 10px; cursor: pointer;" onclick="openMainPage()">&#9851;&nbsp;|&nbsp;UPT Ödeme Hizmetleri A.Ş.</p>

                    <div>
                        <input type="text" id="myInput" onkeyup="myFunction()" placeholder="Menü bul.." style="border-radius: 25px">
                        <ul id="myUL">
                        </ul>
                    </div>
                    <div id="accordian">
                        <ul id="acc" class="acc" style="overflow: auto; height: calc(100vh - 135px)">
                        </ul>
                    </div>

                </div>

            </div>
            <!-- /#sidebar-wrapper -->

            <!-- Page Content -->
            <div id="page-content-wrapper" style="margin-left: -15px">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-lg-12">
                            <span id="menu_toggle" class="menu-toggle" style="font-size: 20px; font-weight: bold; color: #EA5B1C; cursor: pointer;" onclick="openNav();" onmouseout="R.reSize();" onmouseup="R.reSize();">Menü</span>

                            <span id="Bu_Label" class="text-center" style="font-size: 20px; font-weight: bold; color: #303030;">.</span>


                            <div class="dropdown pull-right">
                                <p id="MenuUserName" style="font-size: 20px; color: #303030;"></p>
                                <div class="dropdown-content">
                                    <div class="text-center">
                                        <img src="../images/if_avatar_1814089.png" />
                                    </div>

                                    <a href="#" id="LastLoginLabel" class="text-center" style="font-size: 20px; color: #303030;">.</a>
                                    <a href="#" id="ServerIp" class="text-center" style="font-size: 20px; color: #303030;">.</a>
                                    <a href="#" id="changePassword" onclick="PnlCenter.load('Admin/Administrations/User/UserPassWord.aspx');">&#9851; Şifre Değiştir</a>
                                    <a href="../Login.aspx?dologin=0" id="logout">&#9735; Oturumu Kapat</a>
                                </div>
                            </div>

                            <ajx:PanelX runat="server" ID="PnlCenter" Frame="true" Border="false" AutoWidth="true" Padding="false"
                                AutoHeight="Auto" Height="550" Title="&nbsp;">
                                <Body>
                                </Body>
                            </ajx:PanelX>

                        </div>
                </div>
            </div>
        </div>
        <!-- /#page-content-wrapper -->



        </div>
        <!-- /#wrapper -->
        <script>
            $(".menu-toggle").click(function (e) {
                e.preventDefault();
                $("#wrapper").toggleClass("toggled");
                R.reSize();
            });
        </script>






        <ajx:Window ID="WindowDeleteList" runat="server" Title="CRM_DLETELIST" Height="250"
            Border="false" Resizable="false" CloseAction="Hide" Width="550" Modal="true"
            Icon="Delete" ShowOnLoad="false" Maximizable="false">
            <Body>
                <ajx:GridPanel runat="server" ID="WindowDeleteListGrid" AutoHeight="Auto" AutoWidth="true"
                    StickObj="wbody_WindowDeleteList" Height="188" Mode="Local" AutoLoad="false">
                    <DataContainer>
                        <DataSource>
                            <Columns>
                                <ajx:Column Name="ID" />
                                <ajx:Column Name="NAME" />
                                <ajx:Column Name="OBJECTID" />
                            </Columns>
                        </DataSource>
                    </DataContainer>
                    <SelectionModel>
                        <ajx:RowSelectionModel runat="server">
                        </ajx:RowSelectionModel>
                    </SelectionModel>
                    <ColumnModel>
                        <Columns>
                            <ajx:GridColumns Width="25" Sortable="false" MenuDisabled="true" Header=" ">
                                <Renderer Handler="return DeleteTemplate(record, row, col, td);" />
                            </ajx:GridColumns>
                            <ajx:GridColumns Sortable="false" MenuDisabled="true" DataIndex="NAME" Header="...."
                                Width="200">
                            </ajx:GridColumns>
                            <ajx:GridColumns Sortable="false" MenuDisabled="true" DataIndex="" Header="" Width="300">
                            </ajx:GridColumns>
                        </Columns>
                    </ColumnModel>
                    <TopBar>
                        <ajx:ToolBar ID="ToolBar2" runat="server">
                            <Items>
                                <ajx:Button ID="BtnDeleteOk" Icon="Delete" Width="60" runat="server" Text="CRM_DELETE">
                                    <Listeners>
                                        <Click Handler="window.top.GlobalDeleteAllList(this)" />
                                    </Listeners>
                                </ajx:Button>
                                <ajx:ToolbarSeparator ID="ToolbarSeparator3" runat="server">
                                </ajx:ToolbarSeparator>
                                <ajx:ProgressBar runat="server" ID="WindowDeleteListProgress" Width="250">
                                </ajx:ProgressBar>
                            </Items>
                        </ajx:ToolBar>
                    </TopBar>
                </ajx:GridPanel>
            </Body>
        </ajx:Window>
        <ajx:Window ID="WindowAssignList" runat="server" Title="CRM_ASSIGN" Height="250"
            Border="false" Resizable="false" Maximizable="false" CloseAction="Hide" Width="500"
            Modal="True" Icon="Attach" ShowOnLoad="false">
            <Body>
                <ajx:GridPanel runat="server" ID="WindowAssignListGrid" AutoWidth="true" AutoHeight="Auto"
                    StickObj="wbody_WindowAssignList" Height="190" Mode="Local" AutoLoad="false">
                    <TopBar>
                        <ajx:ToolBar ID="Toolbar3" runat="server">
                            <Items>
                                <%-- <ajx:ComboField runat="server" ID="UserCmp" DisplayField="FullName" ValueField="SystemUserId"
                                FieldLabelShow="false" FieldLabel="SYSTEMUSER_USERNAME" Width="200" Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="StoreOnRefreshData">
                                        <Columns>
                                            <ajx:Column Name="SystemUserId" />
                                            <ajx:Column Name="FullName" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </ajx:ComboField>--%>
                                <cc1:CrmComboComp runat="server" ID="UserCmp" RequirementLevel="BusinessRequired"
                                    UniqueName="SystemUserId" Width="150" ObjectId="1" PageSize="50" FieldLabel="200"
                                    LookupViewUniqueName="User LookUp" Disabled="false">
                                </cc1:CrmComboComp>
                                <ajx:ToolbarSeparator ID="ToolbarSeparator1" runat="server">
                                </ajx:ToolbarSeparator>
                                <ajx:Button ID="BtnAssignOk" Icon="Attach" MinWidth="80" runat="server" Text="CRM_ASSIGN">
                                    <Listeners>
                                        <Click Handler="window.top.GlobalAssignAllList(this)" />
                                    </Listeners>
                                </ajx:Button>
                                <ajx:ToolbarSeparator ID="ToolbarSeparator2" runat="server">
                                </ajx:ToolbarSeparator>
                                <ajx:ProgressBar runat="server" ID="WindowAssignListProgress" Width="200">
                                </ajx:ProgressBar>
                            </Items>
                        </ajx:ToolBar>
                    </TopBar>
                    <DataContainer>
                        <DataSource>
                            <Columns>
                                <ajx:Column Name="ID" />
                                <ajx:Column Name="NAME" />
                                <ajx:Column Name="OBJECTID" />
                            </Columns>
                        </DataSource>
                    </DataContainer>
                    <SelectionModel>
                        <ajx:RowSelectionModel ID="RowSelectionModel1" runat="server" />
                    </SelectionModel>
                    <ColumnModel>
                        <Columns>
                            <ajx:GridColumns Width="25" Sortable="false" MenuDisabled="true" Header=" ">
                                <Renderer Handler="return AssignTemplate(record, row, col, td);" />
                            </ajx:GridColumns>
                            <ajx:GridColumns Sortable="false" MenuDisabled="true" DataIndex="NAME" Header="...."
                                Width="300">
                            </ajx:GridColumns>
                        </Columns>
                    </ColumnModel>
                </ajx:GridPanel>
            </Body>
        </ajx:Window>
    </form>
    <script type="text/javascript">
        window.onscroll = function () { scrollFunction() };
        //Menu
        $(document).ready(function () {


            var str = AjaxMethods.GetHomePageParameters().value;
            var res = str.split(";");

            document.getElementById("Bu_Label").innerHTML = ' | ' + res[0];
            document.getElementById("MenuUserName").innerHTML = "<b>&#9977; " + " " + res[7] + ",  &nbsp;&nbsp;  " + res[1] + " &#9777;</b>";
            document.getElementById("LastLoginLabel").innerHTML = res[2];
            document.getElementById("menu_toggle").innerHTML = res[6];
            document.getElementById("changePassword").innerHTML = res[9];
            document.getElementById("logout").innerHTML = res[8];
            document.getElementById("ServerIp").innerHTML = res[10];
            
            var input = document.getElementById("myInput");
            input.placeholder = res[5];


            var data = AjaxMethods.GenerateMenuHtml('A').value;
            document.getElementById("acc").innerHTML = data.MasterMenu;
            document.getElementById("myUL").innerHTML = data.ContentMenu;
            myUlHide();


            $("#accordian a").click(function () {
                var link = $(this);
                var closest_ul = link.closest("ul");
                var parallel_active_links = closest_ul.find(".active")
                var closest_li = link.closest("li");
                var link_status = closest_li.hasClass("active");
                var count = 0;

                closest_ul.find("ul").slideUp(function () {
                    if (++count == closest_ul.find("ul").length)
                        parallel_active_links.removeClass("active");
                });

                if (!link_status) {
                    closest_li.children("ul").slideDown();
                    closest_li.addClass("active");
                }
            })

        })

        function topFunction() {
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
        }

        function myFunction() {

            myUlShow();
            // Declare variables
            var input, filter, ul, li, a, i;
            input = document.getElementById('myInput');
            if (document.getElementById('myInput').value === '') {
                myUlHide();
                return;
            }
            filter = input.value.toUpperCase();
            ul = document.getElementById("myUL");
            li = ul.getElementsByTagName('li');

            // Loop through all list items, and hide those who don't match the search query
            for (i = 0; i < li.length; i++) {
                a = li[i].getElementsByTagName("a")[0];
                if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
                    li[i].style.display = "";
                } else {
                    li[i].style.display = "none";
                }
            }

        }

        function myUlHide() {
            // Declare variables
            var input, filter, ul, li, a, i;
            input = document.getElementById('myInput');
            filter = input.value.toUpperCase();
            ul = document.getElementById("myUL");
            li = ul.getElementsByTagName('li');

            // Loop through all list items, and hide those who don't match the search query
            for (i = 0; i < li.length; i++) {

                li[i].style.display = "none";

            }

        }

        function myUlShow() {
            // Declare variables
            var input, filter, ul, li, a, i;
            input = document.getElementById('myInput');
            filter = input.value.toUpperCase();
            ul = document.getElementById("myUL");
            li = ul.getElementsByTagName('li');

            // Loop through all list items, and hide those who don't match the search query
            for (i = 0; i < li.length; i++) {

                li[i].style.display = "";

            }

        }


        function openMainPage() {
            document.location.href = '../CrmPages/Main1.aspx';
        }

    </script>
</body>
</html>
<script language="javascript">
    document.onload = checkVersion();


</script>
