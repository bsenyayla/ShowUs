using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using System;
using System.Data;

public partial class AccountDashboard_AccountDashboard : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void lbCorporationAccount_Click(object sender, EventArgs e)
    {
        var sd = new StaticData();
        sd.AddParameter("operationType", DbType.Int16, 1);
        DataTable dt = sd.ReturnDatasetSp(@"spTUAccountReport").Tables[0];

        string tablestring = "";
        tablestring = tablestring + @"<h2>Dashboard / Kurum Hesap Yapısı </h2><hr /><table id=""example"" class=""table table-striped table-bordered"" cellspacing=""0"" width=""100%"">
<thead><tr><th>Kurum Adı</th><th>Durum</th><th>Hesap Tipi</th</tr></thead><tbody>";

        if (dt.Rows.Count > 0)
        {
            foreach (DataRow dr in dt.Rows)
            {
                tablestring = tablestring
                    + "<tr><td>" + dr[0].ToString()
                    + "</td><td>" + dr[2].ToString()
                    + "</td><td>" + dr[1].ToString()
                    + "</td></tr>";
            }
        }
        tablestring = tablestring + "</tbody></table>";
        Grid.InnerHtml = tablestring;
    }

    protected void lbAccountCount_Click(object sender, EventArgs e)
    {
        var sd = new StaticData();
        sd.AddParameter("operationType", DbType.Int16, 8);
        DataTable dt = sd.ReturnDatasetSp(@"spTUAccountReport").Tables[0];

        string tablestring = "";
        tablestring = tablestring + @"<h2>Dashboard / Hesap Sayıları </h2><hr /><table id=""Count"" class=""table table-striped table-bordered"" cellspacing=""0"" width=""100%"">
                                        <thead>
                                        <tr>
                                        <th>Hesap Tipi</th>
                                        <th>Sayı</th>
                                        <th>rw</th>
                                        </tr>
                                        </thead>
                                        <tbody>";

        if (dt.Rows.Count > 0)
        {
            foreach (DataRow dr in dt.Rows)
            {
                tablestring = tablestring
                    + "<tr><td>" + dr[0].ToString()
                    + "</td><td>" + dr[1].ToString()
                    + "</td><td>" + dr[2].ToString()
                    + "</td</tr>";
            }
        }

        tablestring = tablestring + "</tbody></table>";
        Grid.InnerHtml = tablestring;
    }

    protected void lbExternalAccount_Click(object sender, EventArgs e)
    {
        var sd = new StaticData();
        sd.AddParameter("operationType", DbType.Int16, 2);
        DataTable dt = sd.ReturnDatasetSp(@"spTUAccountReport").Tables[0];

        string tablestring = "";
        tablestring = tablestring + @"<h2>Dashboard / Upt Dışı Hesaplar </h2><hr /><table id=""example"" class=""table table-striped table-bordered"" cellspacing=""0"" width=""100%"">
                                        <thead>
                                        <tr>
                                        <th>Kurum Adı</th>
                                        <th>Ofis Adı</th>
                                        <th>Hesap Tipi</th>
<th>Bakiye Döviz Cinsi</th>
                                        <th>Hesap No</th>
                                        <th>Açıklama</th>
                                        <th>Ana Hesap</th>
                                        
                                        <th>Bakiye Tutmaz</th>
                                        </tr>
                                        </thead>
                                        <tbody>";
        if (dt.Rows.Count > 0)
        {
            foreach (DataRow dr in dt.Rows)
            {
                tablestring = tablestring
                    + "<tr><td>" + dr[0].ToString()
                    + "</td><td>" + dr[1].ToString()
                    + "</td><td>" + dr[2].ToString()
                    + "</td><td>" + dr[6].ToString()
                    + "</td><td>" + dr[3].ToString()
                    + "</td><td>" + dr[4].ToString()
                    + "</td><td>" + dr[5].ToString()
                    + "</td><td>" + dr[7].ToString()
                    + "</td</tr>";
            }
        }
        tablestring = tablestring + "</tbody></table>";
        Grid.InnerHtml = tablestring;
    }

    protected void lbPrivlegeAccount_Click(object sender, EventArgs e)
    {
        var sd = new StaticData();
        sd.AddParameter("operationType", DbType.Int16, 4);
        DataTable dt = sd.ReturnDatasetSp(@"spTUAccountReport").Tables[0];

        string tablestring = "";
        tablestring = tablestring + @"<h2>Dashboard / Özel Hesaplar </h2><hr /><table id=""example"" class=""table table-striped table-bordered"" cellspacing=""0"" width=""100%"">
                                        <thead>
                                        <tr>
                                        <th>Hesap Tipi</th>
                                        <th>Bakiye Döviz Cinsi</th>
                                        <th>Hesap No</th>
                                        <th>Açıklama</th>
                                        <th>Ana Hesap</th>
                                        <th>Bakiye Tutmaz</th>
                                        </tr>
                                        </thead>
                                        <tbody>";

        if (dt.Rows.Count > 0)
        {
            foreach (DataRow dr in dt.Rows)
            {
                tablestring = tablestring
                    + "<tr><td>" + dr[0].ToString()
                    + "</td><td>" + dr[1].ToString()
                    + "</td><td>" + dr[2].ToString()
                    + "</td><td>" + dr[3].ToString()
                    + "</td><td>" + dr[4].ToString()
                    + "</td><td>" + dr[5].ToString()
                    + "</td</tr>";
            }
        }
        tablestring = tablestring + "</tbody></table>";
        Grid.InnerHtml = tablestring;
    }

    protected void lbInternalAccount_Click(object sender, EventArgs e)
    {
        var sd = new StaticData();
        sd.AddParameter("operationType", DbType.Int16, 3);
        DataTable dt = sd.ReturnDatasetSp(@"spTUAccountReport").Tables[0];

        string tablestring = "";
        tablestring = tablestring + @"<h2>Dashboard / Upt İçi Hesaplar </h2><hr /><table id=""example"" class=""table table-striped table-bordered"" cellspacing=""0"" width=""100%"">
                                        <thead>
                                        <tr>
                                        <th>Kurum Adı</th>
                                        <th>Ofis Adı</th>
                                        <th>Hesap Tipi</th>
                                        <th>Bakiye Döviz Cinsi</th>
                                        <th>Hesap No</th>
                                        <th>Açıklama</th>
                                        <th>Ana Hesap</th>
                                        <th>Bakiye Tutmaz</th>
                                        </tr>
                                        </thead>
                                        <tbody>";

        if (dt.Rows.Count > 0)
        {
            foreach (DataRow dr in dt.Rows)
            {
                tablestring = tablestring
                    + "<tr><td>" + dr[0].ToString()
                    + "</td><td>" + dr[1].ToString()
                    + "</td><td>" + dr[2].ToString()
                    + "</td><td>" + dr[3].ToString()
                    + "</td><td>" + dr[4].ToString()
                    + "</td><td>" + dr[5].ToString()
                    + "</td><td>" + dr[6].ToString()
                    + "</td><td>" + dr[7].ToString()

                    + "</td</tr>";
            }
        }

        tablestring = tablestring + "</tbody></table>";
        Grid.InnerHtml = tablestring;
    }

    protected void lbMpoOtherAccount_Click(object sender, EventArgs e)
    {
        var sd = new StaticData();
        sd.AddParameter("operationType", DbType.Int16, 5);
        DataTable dt = sd.ReturnDatasetSp(@"spTUAccountReport").Tables[0];

        string tablestring = "";
        tablestring = tablestring + @"<h2>Dashboard / MPO Diğer Hesaplar </h2><hr /><table id=""example"" class=""table table-striped table-bordered"" cellspacing=""0"" width=""100%"">
                                        <thead>
                                        <tr>
                                        <th>Kurum Adı</th>
                                        <th>Ofis Adı</th>
                                        <th>Hesap Tipi</th>
                                        <th>Bakiye Döviz Cinsi</th>
                                        <th>Hesap No</th>
                                        <th>Açıklama</th>
                                        <th>Ana Hesap</th>
                                        <th>Bakiye Tutmaz</th>
                                        </tr>
                                        </thead>
                                        <tbody>";

        if (dt.Rows.Count > 0)
        {
            foreach (DataRow dr in dt.Rows)
            {
                tablestring = tablestring
                    + "<tr><td>" + dr[0].ToString()
                    + "</td><td>" + dr[1].ToString()
                    + "</td><td>" + dr[2].ToString()
                    + "</td><td>" + dr[3].ToString()
                    + "</td><td>" + dr[4].ToString()
                    + "</td><td>" + dr[5].ToString()
                    + "</td><td>" + dr[6].ToString()
                    + "</td><td>" + dr[7].ToString()
                    + "</td</tr>";
            }
        }
        tablestring = tablestring + "</tbody></table>";
        Grid.InnerHtml = tablestring;
    }

    protected void Redirect_Click(object sender, EventArgs e)
    {
        string path =  HTTPUtil.GetWebAppRoot().ToString() + "/CrmPages/main1.aspx";
        Response.Redirect(path);
    }

    protected void lbNotDefined_Click(object sender, EventArgs e)
    {
        var sd = new StaticData();
        sd.AddParameter("operationType", DbType.Int16, 6);
        DataTable dt = sd.ReturnDatasetSp(@"spTUAccountReport").Tables[0];

        string tablestring = "";
        tablestring = tablestring + @"<h2>Dashboard / Sorunlu Hesaplar </h2><hr /><table id=""example"" class=""table table-striped table-bordered"" cellspacing=""0"" width=""100%"">
                                        <thead>
                                        <tr>
                                        <th>Hesap No</th>
                                        <th>Bakiye Döviz Cinsi</th>
                                        <th>Açıklama</th>
                                        <th>Ana Hesap</th>
                                        <th>Bakiye Tutmaz</th>
                                        </tr>
                                        </thead>
                                        <tbody>";
        if (dt.Rows.Count > 0)
        {
            foreach (DataRow dr in dt.Rows)
            {
                tablestring = tablestring
                    + "<tr><td>" + dr[0].ToString()
                    + "</td><td>" + dr[1].ToString()
                    + "</td><td>" + dr[2].ToString()
                    + "</td><td>" + dr[3].ToString()
                    + "</td><td>" + dr[4].ToString()
                    + "</td</tr>";
            }
        }

        tablestring = tablestring + "</tbody></table>";
        Grid.InnerHtml = tablestring;
    }

    protected void lbAkustikAccount_Click(object sender, EventArgs e)
    {
        var sd = new StaticData();
        sd.AddParameter("operationType", DbType.Int16, 7);
        DataTable dt = sd.ReturnDatasetSp(@"spTUAccountReport").Tables[0];

        string tablestring = "";
        tablestring = tablestring + @"<h2>Dashboard / Akustik Hesapları </h2><hr /><table id=""example"" class=""table table-striped table-bordered"" cellspacing=""0"" width=""100%"">
                                        <thead>
                                        <tr>
                                        <th>Kurum Adı</th>
                                        <th>Ofis Adı</th>
                                        <th>Hesap Tipi</th>
                                        <th>Bakiye Döviz Cinsi</th>
                                        <th>Hesap No</th>
                                        <th>Açıklama</th>
                                        </tr>
                                        </thead>
                                        <tbody>";

        if (dt.Rows.Count > 0)
        {
            foreach (DataRow dr in dt.Rows)
            {
                tablestring = tablestring
                    + "<tr><td>" + dr[0].ToString()
                    + "</td><td>" + dr[1].ToString()
                    + "</td><td>" + dr[2].ToString()
                    + "</td><td>" + dr[3].ToString()
                    + "</td><td>" + dr[4].ToString()
                    + "</td><td>" + dr[5].ToString()
                    + "</td</tr>";
            }
        }

        tablestring = tablestring + "</tbody></table>";
        Grid.InnerHtml = tablestring;
    }


}


