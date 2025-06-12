using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class _Default : System.Web.UI.Page {
    MainClass m = new MainClass();

    protected void Page_Load(object sender, EventArgs e) {
        if (IsPostBack) return;
        Application["Paketler"] = null;
        Dictionary<string, string> dicProje = new Dictionary<string, string>();
        dicProje.Add("ACB M", "ACB-MOBIL");
        dicProje.Add("ACB M - 2", "ACB-MOBIL");
        dicProje.Add("ACB S", "ACB-SIGORTA");
        dicProje.Add("ACE", "ACE");
        dicProje.Add("MAPFRE SIGORTA", "MAPFRE-SIGORTA");
        dicProje.Add("ZURICH SIGORTA", "ZURICH-SIGORTA");
        dicProje.Add("AK SIGORTA", "AK-SIGORTA");
        dicProje.Add("AVIVA SIGORTA", "AVIVA-SIGORTA");
        dicProje.Add("YÖNETIM", "ACB-MOBIL");
        dicProje.Add("ING EMEKLILIK", "ING-EMEKLILIK");
        dicProje.Add("SAGLIK KART", "SAGLIK-KART");
        webmenu.DataTextField = "Key";
        webmenu.DataValueField = "Value";
        webmenu.DataSource = dicProje;
        webmenu.DataBind();

        //var proje = dicProje.OrderBy(emp => Guid.NewGuid()).ToDictionary(p=>p.Key,p=>p.Value).Take(1);
        dbAcbDbDataContext contextA = new dbAcbDbDataContext();
        var sayfafullyetki = (from x in contextA.SayfaFullYetkis where x.Domainname == m.UserName select new { x.Proje, x.Domainname, x.Id }).ToList();

        if (sayfafullyetki.Count() <= 0) {
            IKDataContext context = new IKDataContext();
            var proje1 = (from x in context.Persons
                          where x.DomainName == m.UserName
                          select new { x.Proje }).FirstOrDefault();

            if (dicProje.ContainsKey(proje1.Proje) == false) {
                Response.Write("<script language=javascript> alert('Hatalı proje . Tanımlı olan projeniz , bir SCRM projesi değildir. Eğer bu sayfayı görmeniz gerektiğini düşünüyor iseniz IK dan Proje bilginizin değiştirilmesi talep ediniz.'); </script>");
                return;
            }

            var proje2 = (from x in dicProje where x.Key == proje1.Proje select new { x.Value }).FirstOrDefault();
            Application[m.UserNameWithDomain] = proje1.Proje;
            Application[m.UserName] = proje2.Value;
            yetkiDoldur();
        }
        else {
            foreach (var item in dicProje) {
                if (sayfafullyetki.Where(p => p.Proje == item.Key).Count() <= 0) {
                    webmenu.Items.Remove(new ListItem(item.Key, item.Value));
                }
            }
            Application[m.UserNameWithDomain] = null;
            Application[m.UserName] = null;
            webmenu.Visible = true;
            webmenu.Items.Insert(0, new ListItem("Seçiniz", "0"));
        }
    }

    private void yetkiDoldur() {

        dbAcbDbDataContext context = new dbAcbDbDataContext();

        var SayfaFullYetki = (from x in context.SayfaFullYetkis
                              where x.Domainname == m.UserName
                              select x).FirstOrDefault();

        var yetkiDoldur = (from x in context.SayfaYetkis
                           where x.Grup == (Application[m.UserNameWithDomain] != null ? Application[m.UserNameWithDomain].ToString() : "") && x.Sayfa.MenuVisible == true
                           orderby x.Sayfa.sira
                           select new {
                               x.sayfaId,
                               x.Sayfa.SayfaAdi,
                               x.Sayfa.Link,
                               x.Sayfa.Aciklama,
                               x.Sayfa.Resim
                           }).ToList();
        if (SayfaFullYetki != null && yetkiDoldur.Count < 1) {
            var yetkiDoldurDpmain = (from x in context.Sayfas where x.MenuVisible == true orderby x.sira select new { SayfaId = x.Id, x.SayfaAdi, x.Link, x.Aciklama, x.Resim }).ToList();
            DataList1.DataSource = yetkiDoldurDpmain;
            DataList1.DataBind();
            Application[m.UserNameWithDomain] = webmenu.SelectedItem.Text;
            Application[m.UserName] = webmenu.SelectedValue;
            lblsonuc.Text = "<b>" + webmenu.SelectedItem.Text + " projesine geçmiş durumdasınız!</b>";

            lblsonuc.Visible = true;
            return;
        }


        if (yetkiDoldur.Count() > 0) {
            DataList1.DataSource = yetkiDoldur;
            DataList1.DataBind();
        }
        else {
            var yetkiDoldurDpmain = (from x in context.SayfaYetkis where x.Grup == m.UserName && x.Sayfa.MenuVisible == true orderby x.Sayfa.sira select new { x.sayfaId, x.Sayfa.SayfaAdi, x.Sayfa.Link, x.Sayfa.Aciklama, x.Sayfa.Resim }).ToList();
            DataList1.DataSource = yetkiDoldurDpmain;
            DataList1.DataBind();
            Application[m.UserNameWithDomain] = webmenu.SelectedItem.Text;
            Application[m.UserName] = webmenu.SelectedValue;
            lblsonuc.Text = "<b>" + webmenu.SelectedItem.Text + " projesine geçmiş durumdasınız!</b>";

            lblsonuc.Visible = true;
        }
    }
    protected void ddlproje_SelectedIndexChanged(object sender, EventArgs e) {
        Application[m.UserNameWithDomain] = null;
        Application[m.UserName] = null;
        yetkiDoldur();

    }
}
