using System;
using TuFactory;

public partial class Workflow : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        string turef = TextBox1.Text;

        TransferCancelProcessService service = new TransferCancelProcessService();
        service.Do(turef);
    }
}