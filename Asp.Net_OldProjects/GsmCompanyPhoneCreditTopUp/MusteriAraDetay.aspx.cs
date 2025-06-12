using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class MusteriAraDetay : System.Web.UI.Page
{
    MainClass m = new MainClass();
    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack)
        {
            return;
        }
        Application[m.UserNameWithDomain] = ddlProje.SelectedValue;
        Application[m.UserName] = ddlProje.SelectedValue;
    }
    string strAcb = "server=olympos;Database=AcbDb;User Id=Report_User;Password=M0xe11-";
    protected void btnTelefonAra_Click(object sender, EventArgs e)
    {
        if (txtTelefonNo.Text.Trim().Length != 10)
        {
            Label1.Text = "Geçerli Bir Telefon Numarası Giriniz.";
            return;
        }
        else
        {
            Label1.Text = "";
        }
        System.Data.SqlClient.SqlConnection con = new System.Data.SqlClient.SqlConnection(strAcb);
        System.Data.SqlClient.SqlCommand com = new System.Data.SqlClient.SqlCommand("select m.Id as Id,m.Ad as Ad,Soyad,Cinsiyet,TckimlikNo,Dogumtarih,CepTelefon,EvTelefon,Istelefon,i.Ad as Sehir,s.Ad as Sektor,Agent as Kayıdı_Alan_Kisi,IzinOnayTarih,IzinOnayAgent,IzinOnaySonuc  from Musteri m left join Sehir i on i.Id=m.SehirId  left join Sektor s on s.Id = m.SektorId where Proje=@proje and (ceptelefon=@Tel or IsTelefon=@Tel or EvTelefon=@Tel)", con);
        com.Parameters.AddWithValue("@Tel", txtTelefonNo.Text);
        com.Parameters.AddWithValue("@proje", Application[m.UserName].ToString());
        System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(com);
        System.Data.DataTable dt = new System.Data.DataTable();

        da.Fill(dt);
        bool kisitlitelyetki = false;
        dbAcbDbDataContext context = new dbAcbDbDataContext();
        var kisitliyetkivar = (from x in context.Yetkilers where x.Domainname == m.UserName && x.KisitliTelYetki == true select x).SingleOrDefault();
        if (kisitliyetkivar != null)
        {
            kisitlitelyetki = kisitliyetkivar.KisitliTelYetki.Value;
        }
        else
        {
            foreach (System.Data.DataRow dr in dt.Rows)
            {
                if (dr["CepTelefon"] != System.DBNull.Value && dr["CepTelefon"].ToString().Length > 8)
                {
                    dr["CepTelefon"] = dr["CepTelefon"].ToString().Replace(dr["CepTelefon"].ToString().Substring(5, 3), "***");
                }
                if (dr["Istelefon"] != System.DBNull.Value && dr["Istelefon"].ToString().Length > 8)
                {
                    dr["Istelefon"] = dr["Istelefon"].ToString().Replace(dr["Istelefon"].ToString().Substring(5, 3), "***");
                }
                if (dr["EvTelefon"] != System.DBNull.Value && dr["EvTelefon"].ToString().Length > 8)
                {
                    dr["EvTelefon"] = dr["EvTelefon"].ToString().Replace(dr["EvTelefon"].ToString().Substring(5, 3), "***");
                }
            }
        }

        GridView1.DataSource = dt;
        GridView1.DataBind();


        //bool detayyetki = false;
        //var detayyetkivar = (from x in context.Yetkilers where x.Domainname == m.UserName && x.DetayGormeYetki == true select x).SingleOrDefault();
        //if (detayyetkivar != null)
        //{
        //    detayyetki = detayyetkivar.DetayGormeYetki.Value;

        //}
        //if (detayyetki==true)
        //{
        //    GridView1.Columns[0].Visible = true;
        //}
        //else
        //{
        //    GridView1.Columns[0].Visible = false;   
        //}
    }

   
    protected void btnTcKimlikAra_Click(object sender, EventArgs e)
    {
        if (txtTcKimlikNo.Text.Trim().Length != 11)
        {
            Label1.Text = "Geçerli Bir TC Kimlik Numarası Giriniz.";
            return;
        }
        else
        {
            Label1.Text = "";
        }

        System.Data.SqlClient.SqlConnection con = new System.Data.SqlClient.SqlConnection(strAcb);
        System.Data.SqlClient.SqlCommand com = new System.Data.SqlClient.SqlCommand("select m.Id as Id,m.Ad as Ad,Soyad,Cinsiyet,TckimlikNo,Dogumtarih,CepTelefon,EvTelefon,Istelefon,i.Ad as Sehir,s.Ad as Sektor,Agent  as Kayıdı_Alan_Kisi,IzinOnayTarih,IzinOnayAgent,IzinOnaySonuc  from Musteri m left join Sehir i on i.Id=m.SehirId  left join Sektor s on s.Id = m.SektorId where Proje=@proje and (TcKimlikNo=@TcKimlikNo)", con);
        com.Parameters.AddWithValue("@TcKimlikNo", txtTcKimlikNo.Text);
        com.Parameters.AddWithValue("@proje", Application[m.UserName].ToString());
        System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(com);
        System.Data.DataTable dt = new System.Data.DataTable();

        da.Fill(dt);

        foreach (System.Data.DataRow dr in dt.Rows)
        {
            if (dr["CepTelefon"] != System.DBNull.Value && dr["CepTelefon"].ToString().Length > 8)
            {
                dr["CepTelefon"] = dr["CepTelefon"].ToString().Replace(dr["CepTelefon"].ToString().Substring(5, 3), "***");
            }
            if (dr["Istelefon"] != System.DBNull.Value && dr["Istelefon"].ToString().Length > 8)
            {
                dr["Istelefon"] = dr["Istelefon"].ToString().Replace(dr["Istelefon"].ToString().Substring(5, 3), "***");
            }
            if (dr["EvTelefon"] != System.DBNull.Value && dr["EvTelefon"].ToString().Length > 8)
            {
                dr["EvTelefon"] = dr["EvTelefon"].ToString().Replace(dr["EvTelefon"].ToString().Substring(5, 3), "***");
            }
        }

        GridView1.DataSource = dt;
        GridView1.DataBind();
        //bool detayyetki = false;
        //dbAcbDbDataContext context = new dbAcbDbDataContext();
        //var detayyetkivar = (from x in context.Yetkilers where x.Domainname == m.UserName && x.DetayGormeYetki == true select x).SingleOrDefault();
        //if (detayyetkivar != null)
        //{
        //    detayyetki = detayyetkivar.DetayGormeYetki.Value;

        //}
        //if (detayyetki == true)
        //{
        //    GridView1.Columns[0].Visible = true;
        //}
        //if (detayyetki == true)
        //{
        //    GridView1.Columns[0].Visible = true;
        //}
        //else
        //{
        //    GridView1.Columns[0].Visible = false;
        //}
    }

    protected void btnAdSoyadAra_Click(object sender, EventArgs e)
    {
        if (txtAd.Text.Trim().Length + txtSoyad.Text.Trim().Length < 5)
        {
            Label1.Text = "Ad ve soyad karakterlerinin toplamı en az 5 olmalıdır.";
            return;
        }
        else
        {
            Label1.Text = "";
        }

        System.Data.SqlClient.SqlConnection con = new System.Data.SqlClient.SqlConnection(strAcb);
        System.Data.SqlClient.SqlCommand com = new System.Data.SqlClient.SqlCommand("select m.Id as Id,m.Ad as Ad,Soyad,Cinsiyet,TckimlikNo,Dogumtarih,CepTelefon,EvTelefon,Istelefon,i.Ad as Sehir,s.Ad as Sektor,Agent as Kayıdı_Alan_Kisi,IzinOnayTarih,IzinOnayAgent,IzinOnaySonuc from Musteri m left join Sehir i on i.Id=m.SehirId  left join Sektor s on s.Id = m.SektorId  where m.Ad like '%" + txtAd.Text + "%' and Soyad like '%" + txtSoyad.Text + "%' and Proje=@proje", con);
        com.Parameters.AddWithValue("@Ad", txtAd.Text);
        com.Parameters.AddWithValue("@Soyad", txtSoyad.Text);
        com.Parameters.AddWithValue("@proje", Application[m.UserName].ToString());
        System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(com);
        System.Data.DataTable dt = new System.Data.DataTable();

        da.Fill(dt);

        foreach (System.Data.DataRow dr in dt.Rows)
        {
            if (dr["CepTelefon"] != System.DBNull.Value && dr["CepTelefon"].ToString().Length > 8)
            {
                dr["CepTelefon"] = dr["CepTelefon"].ToString().Replace(dr["CepTelefon"].ToString().Substring(5, 3), "***");
            }
            if (dr["Istelefon"] != System.DBNull.Value && dr["Istelefon"].ToString().Length > 8)
            {
                dr["Istelefon"] = dr["Istelefon"].ToString().Replace(dr["Istelefon"].ToString().Substring(5, 3), "***");
            }
            if (dr["EvTelefon"] != System.DBNull.Value && dr["EvTelefon"].ToString().Length > 8)
            {
                dr["EvTelefon"] = dr["EvTelefon"].ToString().Replace(dr["EvTelefon"].ToString().Substring(5, 3), "***");
            }
        }
        GridView1.DataSource = dt;
        GridView1.DataBind();
        //bool detayyetki = false;
        //dbAcbDbDataContext context = new dbAcbDbDataContext();
        //var detayyetkivar = (from x in context.Yetkilers where x.Domainname == m.UserName && x.DetayGormeYetki == true select x).SingleOrDefault();
        //if (detayyetkivar != null)
        //{
        //    detayyetki = detayyetkivar.DetayGormeYetki.Value;

        //}
        //if (detayyetki == true)
        //{
        //    GridView1.Columns[0].Visible = true;
        //}
        //if (detayyetki == true)
        //{
        //    GridView1.Columns[0].Visible = true;
        //}
        //else
        //{
        //    GridView1.Columns[0].Visible = false;
        //}
    }

    public static string TurkceKarakterTemizleVeKucukHarfYap(string deger)
    {
        string result = deger.ToUpper();

        result = result.Replace("ü", "Ü");
        result = result.Replace("ğ", "Ğ");
        result = result.Replace("ş", "Ş");
        result = result.Replace("i", "İ");
        result = result.Replace("ı", "I");
        result = result.Replace("ç", "Ç");
        result = result.Replace("ö", "Ö");

        return result;
    }

    protected void ImageButton1_Click(object sender, ImageClickEventArgs e)
    {
        Response.Redirect("yenimusteri.aspx");
    }
    protected void ddlProje_SelectedIndexChanged(object sender, EventArgs e)
    {
        Application[m.UserNameWithDomain] = ddlProje.SelectedValue;
        Application[m.UserName] = ddlProje.SelectedValue;
    }
}
