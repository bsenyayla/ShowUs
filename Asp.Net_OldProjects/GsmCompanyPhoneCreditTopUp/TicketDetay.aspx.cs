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

public partial class Yonetim_TicketDetay : System.Web.UI.Page
{
    MainClass m = new MainClass();
    protected void Page_Load(object sender, EventArgs e)
    {
      
        if (string.IsNullOrEmpty(Request.QueryString["Id"])) return;

        ddlAktivite.Attributes.Add("onchange", "setSonucVisible()");

        if (Page.IsPostBack) return;

        Doldur();
        
        HyperLink1.NavigateUrl = "../MusteriIslem.aspx?MusteriId=" + hdnMusteriId.Value;
    }


    void Doldur()
    {
        int id = Convert.ToInt32(Request.QueryString["Id"]);

        dbAcbDbDataContext context = new dbAcbDbDataContext();
        //context.Connection.ConnectionString = "Data Source=olympos;Initial Catalog=TurkcellKontorDB;User ID=Report_User; Password=M0xe11-";


        Ticket ticket = context.Tickets.FirstOrDefault(p => p.Id == id);
         hdnMusteriId.Value = ticket.MusteriId.ToString();
        lblAciklama.Text = ticket.Aciklama;
        lblAgent.Text = ticket.TicketAgent.Replace(@"SPEAK\", "");
        lblAltKategori.Text = ticket.TicketAltNedenId.HasValue ? ticket.TicketNeden1.Ad : "";
        lblDurum.Text = ticket.TicketStatus.Ad;
        lblKategori.Text = ticket.TicketNeden.Ad;
        lblMusteri.Text = ticket.Musteri.Ad + " " + ticket.Musteri.Soyad;
        lblTelefonNo.Text = ticket.Musteri.CepTelefon;
        lblTicketTarih.Text = ticket.Tarih.Value.ToShortDateString() + " " + ticket.Tarih.Value.ToLongTimeString();

        if (ticket.TicketSonuc != null)
        {
            lblSonuc.Text = ticket.TicketSonuc.Ad;
            lblSonucTarih.Text = ticket.SonucTarih.Value.ToShortDateString() + " " + ticket.SonucTarih.Value.ToLongTimeString();
            Div3.Visible = false;
            Div4.Visible = false;
        }

        var activities = from x in context.TicketActivities where x.TicketId == id select new { x.Id, x.Agent, x.Aciklama, x.Tarih, Status = x.TicketStatus.Ad, Sonuc = x.Ticket.TicketSonuc.Ad };

        DataList1.DataSource = activities;
        DataList1.DataBind();

        ddlAktivite.DataTextField = "Ad";
        ddlAktivite.DataValueField = "Id";



        IQueryable<TicketStatus> status = null;
        if (activities.Count() == 1)
        {
            status = context.TicketStatus.Where(p => p.Id == 2 || p.TicketDepartman != null);
        }
        else if ((ticket.TicketActivities.OrderBy(p => p.Tarih).Last().TicketStatus.TicketDepartman != null))
        {
            status = context.TicketStatus.Where(p => p.Id == 2 || p.TicketDepartman != null);
        }
        else
        {
            status = context.TicketStatus.Where(p => p.Id != 1);
        }


        ddlAktivite.DataSource = status;
        ddlAktivite.DataBind();

        ddlSonuc.DataTextField = "Ad";
        ddlSonuc.DataValueField = "Id";
        int xxxxx = context.TicketSonucs.Where(p => p.AktifMi == true).OrderBy(p => p.SiraNo).Count();
        ddlSonuc.DataSource = context.TicketSonucs.Where(p => p.AktifMi.Value).OrderBy(p => p.SiraNo);
        ddlSonuc.DataBind();

        ddlOneri.DataTextField = "Ad";
        ddlOneri.DataValueField = "Id";

        ddlOneri.DataSource = (from x in context.TicketOneris select x).ToList();
        ddlOneri.DataBind();
        ddlOneri.AppendDataBoundItems = true;
        ddlOneri.Items.Insert(0, "");
      
    }

    protected void btnKaydet_Click(object sender, EventArgs e)
    {
      
        if (string.IsNullOrEmpty(Request.QueryString["Id"])) return;

        int id = Convert.ToInt32(Request.QueryString["Id"]);

        dbAcbDbDataContext context = new dbAcbDbDataContext();
        Ticket ticket = context.Tickets.FirstOrDefault(p => p.Id == id);
        TicketActivity ticketActivity = new TicketActivity();

        ticketActivity.Aciklama = txtAciklama.Text;
        ticketActivity.Agent = m.UserName;
        ticketActivity.IP = Request.UserHostAddress;
        ticketActivity.StatusId = Convert.ToInt32(ddlAktivite.SelectedValue);
        ticketActivity.Tarih = DateTime.Now;
        ticketActivity.TicketId = id;
        ticketActivity.Proje = Application[m.UserName].ToString();
        ticket.StatusId = Convert.ToInt32(ddlAktivite.SelectedValue);
        ticket.DurumAgent = m.UserName;
        ticket.StatusTarih = DateTime.Now;
        ticket.Proje = Application[m.UserName].ToString();

        if (ticketActivity.StatusId == 4)
        {
            ticket.SonucId = Convert.ToInt32(ddlSonuc.SelectedValue);
            ticket.SonucTarih = DateTime.Now;
            ticket.SonucAgent = m.UserName;
            if (Application[m.UserNameWithDomain]!= null && Application[m.UserNameWithDomain].ToString()=="ACB-MOBIL")
            {
                ticket.OneriId = Convert.ToInt32(ddlOneri.SelectedValue);
            }
        }
        TicketStatus status = context.TicketStatus.FirstOrDefault(p => p.Id == ticketActivity.StatusId);
        if (status.TicketDepartman != null)
        {
            ticket.DepartmanId = status.AktarilacakDepartmanId;
        }

     
        context.TicketActivities.InsertOnSubmit(ticketActivity);
        context.SubmitChanges();


        if (cbAciklamayaEkle.Checked && cbAciklamayaEkle.Visible)
        {
            ticket.Musteri.Aciklama = txtAciklama.Text;
        }
        context.SubmitChanges();
        Doldur();
    }
    protected void ImageButton1_Click(object sender, ImageClickEventArgs e)
    {
        Response.Redirect("ticketsV2.aspx");
    }
}
