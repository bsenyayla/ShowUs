using AjaxPro;
using DotNet.SFtp.java.lang;
using System;

public partial class ExcelImport_Import : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [System.Web.Services.WebMethod]
    public static string GetText()
    {
        for (int i = 0; i < 10; i++)
        {
            // In actual projects this action may be a database operation.    
            //For demsonstration I have made this loop to sleep.    
            Thread.Sleep(2600);
        }
        return "Download Complete...";
    }

    [AjaxMethod]
    protected void Button1_Click(object sender, EventArgs e)
    {
        percentage.Text = "100";
    }
}