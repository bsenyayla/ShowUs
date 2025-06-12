using System;

public partial class MonitorRedirect : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Redirect("https://uptuat3.aktifbank.com.tr/ISV/TU/Operation/Detail/_Monitoring.aspx");
    }
}