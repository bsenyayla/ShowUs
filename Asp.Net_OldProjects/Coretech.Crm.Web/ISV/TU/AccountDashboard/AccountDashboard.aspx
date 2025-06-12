<%@ Page Language="C#" AutoEventWireup="true" Inherits="AccountDashboard_AccountDashboard" Codebehind="AccountDashboard.aspx.cs" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Account Dashboard</title>
    <link href="../css/bootstrap.min.css" rel="stylesheet" />
    <link href="../css/font-awesome.min.css" rel="stylesheet" />
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/r/bs-3.3.5/jq-2.1.4,dt-1.10.8/datatables.min.css" />
    <link href="../css/Custom.css" rel="stylesheet" />
</head>
<body class="nav-md">

    <form id="form1" runat="server">
        <div class="container body">
            <div class="main_container">
                <div class="col-md-3 left_col">
                    <div class="left_col scroll-view">

                        <div class="navbar nav_title">
                            <a href="#" class="site_title"><span>Hesaplar</span></a>
                        </div>
                        <div class="clearfix"></div>

                        <!-- sidebar menu -->
                        <div id="sidebar-menu" class="main_menu_side hidden-print main_menu">

                            <div class="menu_section">
                                <ul class="nav side-menu">
                                    <li><a><i class="fa fa-home"></i>Dashboard<span class="fa fa-chevron-down"></span></a>
                                        <ul id="Dashboard" class="nav child_menu" style="display: grid">
                                            <li>
                                                <asp:LinkButton CssClass="a" ID="lbCorporationAccount" Text="Kurum Hesap Yapısı" OnClick="lbCorporationAccount_Click" runat="server" />
                                            </li>

                                            <li>
                                                <asp:LinkButton CssClass="a" ID="lbPrivlegeAccount" Text="Özel Hesaplar" OnClick="lbPrivlegeAccount_Click" runat="server" />
                                            </li>
                                            <li>
                                                <asp:LinkButton CssClass="a" ID="lbInternalAccount" Text="Upt İçi Hesaplar" OnClick="lbInternalAccount_Click" runat="server" />
                                            </li>
                                            <li>
                                                <asp:LinkButton CssClass="a" ID="lbExternalAccount" Text="Upt Dışı Hesaplar" OnClick="lbExternalAccount_Click" runat="server" />
                                            </li>
                                            <li>
                                                <asp:LinkButton CssClass="a" ID="lbMpoOtherAccount" Text="MPO Diğer Hesaplar" OnClick="lbMpoOtherAccount_Click" runat="server" />
                                            </li>
                                            <li>
                                                <asp:LinkButton CssClass="a" ID="lbAkustikAccount" Text="Akustik Hesapları" OnClick="lbAkustikAccount_Click" runat="server" />
                                            </li>
                                            <li>
                                                <asp:LinkButton CssClass="a" ID="lbAccountCount" Text="Hesap Sayıları" OnClick="lbAccountCount_Click" runat="server" />
                                            </li>
                                            <li>
                                                <asp:LinkButton CssClass="a" ID="lbNotDefined" Text="Sorunlu Hesaplar" OnClick="lbNotDefined_Click" runat="server" />
                                            </li>
                                        </ul>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- top navigation -->
                <div class="top_nav">

                    <div class="nav_menu">
                        <nav class="" role="navigation">
                            <div class="nav toggle">
                                <a id="menu_toggle"><i class="fa fa-th"></i></a>
                            </div>

                            <ul class="nav navbar-nav navbar-right">
                                <li class="">
                                    <asp:LinkButton CssClass="a" ID="LinkButton1" runat="server">
                                        Yenile <span class="fa fa-refresh"></span>
                                    </asp:LinkButton>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </div>
                <div id="Grid" runat="server" class="right_col" role="main">
                </div>
            </div>

        </div>
    </form>
    <script src="../js/jquery.min.js"></script>
    <script src="../js/bootstrap.min.js"></script>
    <script src="../js/custom.js"></script>

    <script type="text/javascript" src="https://cdn.datatables.net/r/bs-3.3.5/jqc-1.11.3,dt-1.10.8/datatables.min.js"></script>
    
    <script type="text/javascript" charset="utf-8">
        $(document).ready(function () {
            $('#example').DataTable({
                "paging": false,
                "language": {
                    "search": "Filtre "
                }

            });
        });


    </script>
    <script type="text/javascript" charset="utf-8">
        $(document).ready(function () {
            $('#Count').DataTable({
                "paging": false,
                "order": [[2, "asc"]],
                "columnDefs": [
            {
                "targets": [2],
                "visible": false,
                "searchable": true
            }
                ],
                "language": {
                    "search": "Filtre "
                }
            });
        });
    </script>

</body>
</html>
