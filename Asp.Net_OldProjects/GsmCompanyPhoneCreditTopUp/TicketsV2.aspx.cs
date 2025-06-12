using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;
using System.Collections.Generic;
using System.Data.SqlClient;

public partial class Yonetim_TicketsV2 : System.Web.UI.Page
{
    MainClass m = new MainClass();
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        dbAcbDbDataContext context = new dbAcbDbDataContext();

        context.Connection.ConnectionString = "Data Source=olympos;Initial Catalog=AcbDb;User ID=Report_User; Password=M0xe11-";

        string user = m.UserName;

        ddlDepartman.DataSource = context.TicketDepartmans.Where(p => p.TicketDepartmanPersonels.Any(x => x.Personel == user));
        ddlDepartman.DataTextField = "Ad";
        ddlDepartman.DataValueField = "Id";
        ddlDepartman.DataBind();
        ddlDepartman.AppendDataBoundItems = true;
        ddlDepartman.Items.Insert(0, "Tümü");

        System.Collections.Generic.List<int> departmans = new System.Collections.Generic.List<int>();
        foreach (ListItem item in ddlDepartman.Items)
        {
            if (item.Value == "Tümü") continue;
            departmans.Add(Convert.ToInt32(item.Value));
        }

        List<TicketNeden> ticketNedens = context.TicketNedens.Where(p => p.UstNedenId == null).ToList();
        List<TicketNeden> clearTicketNedens = new List<TicketNeden>();

        for (int i = 0; i < ticketNedens.Count; i++)
        {
            foreach (int dp in departmans)
            {
                if (ticketNedens[i].DepartmanId == dp)
                {
                    clearTicketNedens.Add(ticketNedens[i]);
                    break;
                }
            }
        }

        ddlKategori.DataSource = clearTicketNedens;
        ddlKategori.DataTextField = "Ad";
        ddlKategori.DataValueField = "Id";
        ddlKategori.DataBind();
        ddlKategori.AppendDataBoundItems = true;
        ddlKategori.Items.Insert(0, "Tümü");

        if (ddlDepartman.Items.Count == 1)
        {
            Response.Redirect("../SatisError.aspx?ErrCode=104");
            return;
        }

        ddlDurum.DataSource = context.TicketStatus;
        ddlDurum.DataTextField = "Ad";
        ddlDurum.DataValueField = "Id";
        ddlDurum.DataBind();
        ddlDurum.AppendDataBoundItems = true;
        ddlDurum.Items.Insert(0, "Tümü");

        ddlKapanmaNeden.DataSource = context.TicketSonucs;
        ddlKapanmaNeden.DataTextField = "Ad";
        ddlKapanmaNeden.DataValueField = "Id";
        ddlKapanmaNeden.DataBind();
        ddlKapanmaNeden.AppendDataBoundItems = true;
        ddlKapanmaNeden.Items.Insert(0, "Tümü");

        ddlAltKategori.Items.Add("Tümü");

        btnUzerimdekiAktifTicketlar_Click(null, null);
    }

    protected void btnAra_Click(object sender, EventArgs e)
    {
        string query = "";

        query += "select t.Id,t.Tarih,m.Ad+' '+m.Soyad as Müşteri,m.Id as MusteriId,m.Ceptelefon,tn.Ad as Kategori,tn2.Ad as AltKategori,t.Aciklama,t.TicketAgent,tst.Ad as Durum,t.DurumAgent,ts.Ad as Sonuc,t.SonucTarih,t.SonucAgent,t.EkBilgiTarih1 as UyelikTarih,t.EkBilgi1 as uyelikAgent,o.Ad as Oneri,Ekbilgi2 as Paket1,Ekbilgi3 as Paket2,Ekbilgi4 as Paket3,Ekbilgi5 as MusteriId,EkbilgiInt1 as Paket1Fiyat,EkbilgiInt2 as Paket2Fiyat,EkbilgiInt3 as Paket3Fiyat,EkbilgiTarih1 as Paket1Tarih,EkbilgiTarih2 as Paket2Tarih,EkbilgiTarih3 as Paket3Tarih from Ticket as t\r\n";
        query += "left outer join Musteri as m on m.Id=t.MusteriId\r\n";
        query += "left outer join TicketNeden as tn on t.TicketNedenId=tn.Id\r\n";
        query += "left outer join TicketNeden as tn2 on t.TicketAltNedenId=tn2.Id\r\n";
        query += "left outer join TicketSonuc as ts on t.SonucId=ts.Id\r\n";
        query += "left outer join TicketKaynak as tk on t.TicketKaynakId=tk.Id\r\n";
        query += "left outer join TicketDepartman as td on t.DepartmanId=td.Id\r\n";
        query += "left outer join TicketStatus as tst on t.StatusId=tst.Id\r\n";
        query += "left outer join TicketOneri as o on o.Id=t.OneriId\r\n";
        query += "where 1=1 and t.Proje='"+Application[m.UserName].ToString()+"'\r\n";

        SqlConnection con = new SqlConnection("Data Source=olympos;Initial Catalog=AcbDb;User ID=Report_User; Password=M0xe11-");

        //SqlConnection con = new SqlConnection(@"Data Source=.\SQLEXPRESS;Initial Catalog=TurkcellKontorDB;Trusted_Connection=true;");

        SqlCommand com = new SqlCommand();
        com.Connection = con;

        int sayac = 1;
        if (ddlDepartman.SelectedValue != "Tümü")
        {
            query += " and t.DepartmanId=@DepartmanId";
            com.Parameters.AddWithValue("@DepartmanId", ddlDepartman.SelectedValue);
        }
        else
        {
            string subQuery = " and (";
            foreach (ListItem li in ddlDepartman.Items)
            {
                if (li.Value == "Tümü") continue;
                subQuery += "t.DepartmanId=@dep" + sayac.ToString() + " or ";
                com.Parameters.AddWithValue("@dep" + sayac.ToString(), li.Value);
                sayac++;
            }

            subQuery = subQuery.Remove(subQuery.Length - 4, 4);

            subQuery += ") ";
            query += subQuery;
        }

        if (ddlKategori.SelectedValue != "Tümü")
        {
            query += " and t.TicketNedenId=@KategoriId";
            com.Parameters.AddWithValue("@KategoriId", ddlKategori.SelectedValue);
        }

        if (ddlAltKategori.SelectedValue != "Tümü")
        {
            query += " and t.TicketAltNedenId=@AltKategoriId";
            com.Parameters.AddWithValue("@AltKategoriId", ddlAltKategori.SelectedValue);
        }

        if (ddlTur.SelectedValue != "Tümü")
        {
            if (ddlTur.SelectedValue == "Boştaki")
            {
                query += " and ( t.StatusId=1 ";


                dbAcbDbDataContext context = new dbAcbDbDataContext();
                foreach (var item in context.TicketStatus.Where(p => p.TicketDepartman != null))
                {
                    query += " or t.StatusId=" + item.Id;
                }
                query += ")";

            }
            else if (ddlTur.SelectedValue == "Aktif")
            {
                query += " and t.StatusId<>1 and t.SonucTarih is null";
                dbAcbDbDataContext context = new dbAcbDbDataContext();
                foreach (var item in context.TicketStatus.Where(p => p.TicketDepartman != null))
                {
                    query += " and t.StatusId<>" + item.Id + " ";
                }
            }
            else if (ddlTur.SelectedValue == "Kapalı")
            {
                query += " and t.SonucTarih is not null";
            }
        }

        if (ddlKiminUzerinde.SelectedValue != "Tümü")
        {
            if (ddlKiminUzerinde.SelectedValue == "Benim")
            {
                query += " and t.DurumAgent=@DurumAgent";
                com.Parameters.AddWithValue("@DurumAgent", ddlKiminUzerinde.SelectedValue);
            }
            else if (ddlKiminUzerinde.SelectedValue == "Diğer Kişiler")
            {
                query += " and t.DurumAgent<>@DurumAgent and t.SonucAgent is not null";
                com.Parameters.AddWithValue("@DurumAgent", ddlKiminUzerinde.SelectedValue);
            }
        }

        if (ddlDurum.SelectedValue != "Tümü")
        {
            query += " and t.StatusId=@StatusId";
            com.Parameters.AddWithValue("@StatusId", ddlDurum.SelectedValue);
        }


        if (ddlKapanmaNeden.SelectedValue != "Tümü")
        {
            query += " and t.SonucId=@SonucId";
            com.Parameters.AddWithValue("@SonucId", ddlKapanmaNeden.SelectedValue);
        }

        if (txtMusteriTelefon.Text.Trim() != "")
        {
            query += " and m.TelefonNo=@TelefonNo";
            com.Parameters.AddWithValue("@TelefonNo", txtMusteriTelefon.Text);
        }


        if (txtAcilisTarihBaslangic.Text.Trim() != "")
        {
            query += " and t.Tarih>=@Tarih";
            com.Parameters.AddWithValue("@Tarih", Convert.ToDateTime(txtAcilisTarihBaslangic.Text));
        }

        if (txtAcilisTarihBitis.Text.Trim() != "")
        {
            query += " and t.Tarih<=@Tarih2";
            DateTime xd = Convert.ToDateTime(txtAcilisTarihBitis.Text);
            com.Parameters.AddWithValue("@Tarih2", new DateTime(xd.Year, xd.Month, xd.Day, 23, 59, 59));
        }

        if (txtKapanisTarihBaslangic.Text.Trim() != "")
        {
            query += " and t.SonucTarih>=@Tarih3";
            DateTime xd = Convert.ToDateTime(txtKapanisTarihBaslangic.Text);
            com.Parameters.AddWithValue("@Tarih3", xd);
        }


        if (txtKapanisTarihBitis.Text.Trim() != "")
        {
            DateTime xd = Convert.ToDateTime(txtKapanisTarihBitis.Text);
            query += " and t.SonucTarih<=@Tarih4";
            com.Parameters.AddWithValue("@Tarih4", new DateTime(xd.Year, xd.Month, xd.Day, 23, 59, 59));
        }

        if (txtAcanPersonel.Text.Trim() != "")
        {
            query += " and t.TicketAgent=@TicketAgent";
            com.Parameters.AddWithValue("@TicketAgent",  txtAcanPersonel.Text.Trim());
        }

        if (txtKapatanPersonel.Text.Trim() != "")
        {
            query += " and t.Sonuc=@SonucAgent";
            com.Parameters.AddWithValue("@SonucAgent",  txtKapatanPersonel.Text.Trim());
        }


        query += " order by t.Tarih";

        com.CommandText = query;

        SqlDataAdapter da = new SqlDataAdapter(com);
        System.Data.DataTable dt = new System.Data.DataTable();
        da.Fill(dt);

        GridView1.DataKeyNames = new string[] { "Id" };
        GridView1.DataSource = dt;
        GridView1.DataBind();
    }

    protected void ddlKategori_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlKategori.SelectedValue == "Tümü")
        {
            ddlAltKategori.Items.Clear();
            ddlAltKategori.Items.Add("Tümü");
            return;
        }


        ddlAltKategori.Items.Clear();
        dbAcbDbDataContext context = new dbAcbDbDataContext();
        //context.Connection.ConnectionString = "Data Source=olympos;Initial Catalog=TurkcellKontorDB;User ID=Report_User; Password=M0xe11-";

        ddlAltKategori.DataSource = context.TicketNedens.Where(p => p.UstNedenId == Convert.ToInt32(ddlKategori.SelectedValue));
        ddlAltKategori.DataTextField = "Ad";
        ddlAltKategori.DataValueField = "Id";
        ddlAltKategori.DataBind();
        ddlAltKategori.AppendDataBoundItems = true;
        ddlAltKategori.Items.Insert(0, "Tümü");


    }

    protected void ExceleAktarClick(object sender, EventArgs e)
    {
        string fileName = Guid.NewGuid().ToString("N").Substring(0, 12);
        string attachment = "attachment; filename=" + fileName + ".xls";
        Response.ClearContent();
        Response.Buffer = true;

        Response.AddHeader("content-disposition", attachment);
        Response.ContentType = "application/vnd.ms-excel";


        Response.Charset = "ISO-8859-9";

        System.IO.StringWriter sw = new System.IO.StringWriter();
        HtmlForm frm = new HtmlForm();
        HtmlTextWriter htw = new HtmlTextWriter(sw);
        GridView1.Parent.Controls.Add(frm);
        frm.Attributes["runat"] = "server";
        frm.Controls.Add(GridView1);
        frm.RenderControl(htw);
        Response.Write(sw.ToString());
        Response.End();
    }

    protected void ddlDepartman_SelectedIndexChanged(object sender, EventArgs e)
    {
        ddlKategori.Items.Clear();
        dbAcbDbDataContext context = new dbAcbDbDataContext();
        //context.Connection.ConnectionString = "Data Source=olympos;Initial Catalog=TurkcellKontorDB;User ID=Report_User; Password=M0xe11-";

        if (ddlDepartman.SelectedValue == "Tümü")
        {
            List<int> departmans = new List<int>();
            foreach (ListItem item in ddlDepartman.Items)
            {
                if (item.Value == "Tümü") continue;
                departmans.Add(Convert.ToInt32(item.Value));
            }

            List<TicketNeden> ticketNedens = context.TicketNedens.Where(p => p.UstNedenId == null).ToList();
            List<TicketNeden> clearTicketNedens = new List<TicketNeden>();


            for (int i = 0; i < ticketNedens.Count; i++)
            {
                foreach (int dp in departmans)
                {
                    if (ticketNedens[i].DepartmanId == dp)
                    {
                        clearTicketNedens.Add(ticketNedens[i]);
                        break;
                    }
                }
            }


            ddlKategori.DataSource = clearTicketNedens;
            ddlKategori.DataTextField = "Ad";
            ddlKategori.DataValueField = "Id";
            ddlKategori.DataBind();
            ddlKategori.AppendDataBoundItems = true;
            ddlKategori.Items.Insert(0, "Tümü");
        }
        else
        {
            int departmanId = Convert.ToInt32(ddlDepartman.SelectedValue);
            ddlKategori.DataSource = context.TicketNedens.Where(p => p.DepartmanId == departmanId && p.UstNedenId == null);
            ddlKategori.DataTextField = "Ad";
            ddlKategori.DataValueField = "Id";
            ddlKategori.DataBind();
            ddlKategori.AppendDataBoundItems = true;
            ddlKategori.Items.Insert(0, "Tümü");
        }

        ddlKategori_SelectedIndexChanged(null, null);
    }

    protected void btnUzerimdekiAktifTicketlar_Click(object sender, EventArgs e)
    {
        string query = "";
        string user = m.UserName;

        query += "select t.Id,t.Tarih,m.Ad+' '+m.Soyad as Müşteri,m.Id as MusteriId,m.ceptelefon,tn.Ad as Kategori,tn2.Ad as AltKategori,t.Aciklama,t.TicketAgent,tst.Ad as Durum,t.DurumAgent,ts.Ad as Sonuc,t.SonucTarih,t.SonucAgent,t.EkBilgiTarih1 as UyelikTarih,t.EkBilgi1 as uyelikAgent,o.Ad as Oneri,Ekbilgi2 as Paket1,Ekbilgi3 as Paket2,Ekbilgi4 as Paket3,Ekbilgi5 as MusteriId,EkbilgiInt1 as Paket1Fiyat,EkbilgiInt2 as Paket2Fiyat,EkbilgiInt3 as Paket3Fiyat,EkbilgiTarih1 as Paket1Tarih,EkbilgiTarih2 as Paket2Tarih,EkbilgiTarih3 as Paket3Tarih from Ticket as t\r\n";
        query += "left outer join Musteri as m on m.Id=t.MusteriId\r\n";
        query += "left outer join TicketNeden as tn on t.TicketNedenId=tn.Id\r\n";
        query += "left outer join TicketNeden as tn2 on t.TicketAltNedenId=tn2.Id\r\n";
        query += "left outer join TicketSonuc as ts on t.SonucId=ts.Id\r\n";
        query += "left outer join TicketKaynak as tk on t.TicketKaynakId=tk.Id\r\n";
        query += "left outer join TicketDepartman as td on t.DepartmanId=td.Id\r\n";
        query += "left outer join TicketStatus as tst on t.StatusId=tst.Id\r\n";
        query += "left outer join TicketOneri as o on o.Id=t.OneriId\r\n";
        query += "where 1=1 and t.Proje='"+Application[m.UserName].ToString()+"'\r\n";
        query += " and DurumAgent=@statusAgent and SonucTarih is null and t.StatusId<>1";

        dbAcbDbDataContext context = new dbAcbDbDataContext();
        foreach (var item in context.TicketStatus.Where(p => p.TicketDepartman != null))
        {
            query += " and t.StatusId<>" + item.Id + " ";
        }

        query += " order by t.Tarih";

        SqlConnection con = new SqlConnection(@"Data Source=olympos;Initial Catalog=AcbDb;User ID=Report_User; Password=M0xe11-;");


        SqlCommand com = new SqlCommand(query, con);
        com.Parameters.AddWithValue("@statusAgent", user);


        SqlDataAdapter da = new SqlDataAdapter(com);
        System.Data.DataTable dt = new System.Data.DataTable();
        da.Fill(dt);

        GridView1.DataKeyNames = new string[] { "Id" };
        GridView1.DataSource = dt;
        GridView1.DataBind();


    }

    protected void btnDepartmanımdakiBostakiTicketlar_Click(object sender, EventArgs e)
    {

        SqlConnection con = new SqlConnection(@"Data Source=olympos;Initial Catalog=AcbDb;User ID=Report_User; Password=M0xe11-;");
        SqlCommand com = new SqlCommand("", con);

        string query = "";
        string user = m.UserNameWithDomain;

        query += "select t.Id,t.Tarih,m.Ad+' '+m.Soyad as Müşteri,m.Id as MusteriId,m.ceptelefon,tn.Ad as Kategori,tn2.Ad as AltKategori,t.Aciklama,t.TicketAgent,tst.Ad as Durum,t.DurumAgent,ts.Ad as Sonuc,t.SonucTarih,t.SonucAgent,t.EkBilgiTarih1 as UyelikTarih,t.EkBilgi1 as uyelikAgent,o.Ad as Oneri,Ekbilgi2 as Paket1,Ekbilgi3 as Paket2,Ekbilgi4 as Paket3,Ekbilgi5 as MusteriId,EkbilgiInt1 as Paket1Fiyat,EkbilgiInt2 as Paket2Fiyat,EkbilgiInt3 as Paket3Fiyat,EkbilgiTarih1 as Paket1Tarih,EkbilgiTarih2 as Paket2Tarih,EkbilgiTarih3 as Paket3Tarih from Ticket as t\r\n";
        query += "left outer join Musteri as m on m.Id=t.MusteriId\r\n";
        query += "left outer join TicketNeden as tn on t.TicketNedenId=tn.Id\r\n";
        query += "left outer join TicketNeden as tn2 on t.TicketAltNedenId=tn2.Id\r\n";
        query += "left outer join TicketSonuc as ts on t.SonucId=ts.Id\r\n";
        query += "left outer join TicketKaynak as tk on t.TicketKaynakId=tk.Id\r\n";
        query += "left outer join TicketDepartman as td on t.DepartmanId=td.Id\r\n";
        query += "left outer join TicketStatus as tst on t.StatusId=tst.Id\r\n";
        query += "left outer join TicketOneri as o on o.Id=t.OneriId\r\n";
        query += "where 1=1 and t.Proje='"+Application[m.UserName].ToString()+"'\r\n";

        int sayac = 1;
        string subQuery = " and (";
        foreach (ListItem li in ddlDepartman.Items)
        {
            if (li.Value == "Tümü") continue;
            subQuery += "t.DepartmanId=@dep" + sayac.ToString() + " or ";
            com.Parameters.AddWithValue("@dep" + sayac.ToString(), li.Value);
            sayac++;
        }

        subQuery = subQuery.Remove(subQuery.Length - 4, 4);

        subQuery += ") ";
        query += subQuery;

        query += " and ( t.StatusId=1 ";

        dbAcbDbDataContext context = new dbAcbDbDataContext();
        foreach (var item in context.TicketStatus.Where(p => p.TicketDepartman != null))
        {
            query += " or t.StatusId=" + item.Id;
        }
        query += ")";

        query += " order by t.Tarih";

        com.CommandText = query;

        SqlDataAdapter da = new SqlDataAdapter(com);
        System.Data.DataTable dt = new System.Data.DataTable();
        da.Fill(dt);

        GridView1.DataSource = dt;
        GridView1.DataBind();

    }
    protected void ImageButton1_Click(object sender, ImageClickEventArgs e)
    {
        Response.Redirect("../default.aspx");
    }
}
