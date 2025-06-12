using System;
using TuFactory.Integration3rd;

public partial class IntegrationManuel_IntegrationMonitoring : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        IntegrationTest t = new IntegrationTest();
        Literal1.Text = t.Test();
    }
}