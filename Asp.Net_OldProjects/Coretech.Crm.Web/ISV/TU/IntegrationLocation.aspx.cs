using System;
using RefleXFrameWork;
using Coretech.Crm.Utility.Util;

public partial class IntegrationLocation : RefleXPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        fuLocation.MaxLength = 2147483647;
        if (!IsPostBack && !RefleX.IsAjxPostback)
        {

        }
        entegrationCode = QueryHelper.GetString("extcode");
    }
    public string entegrationCode = string.Empty;



    protected void BtnEnterClick(object sender, AjaxEventArgs e)
    {
        //if (string.IsNullOrEmpty(fuLocation.FileName))
        //{
        //    new MessageBox("Lütfen Dosya Seçiniz");
        //    return;
        //}
        //Integration3Rd i3rd = new Integration3Rd();

        //string name = Guid.NewGuid().ToString();
        //string fullname = string.Format("{0}_{1}", name, fuLocation.FileName);
        //fuLocation.PostedFile.SaveAs(@"C:/Locations/Download/" + fullname);

        //i3rd.InsertUpdateLocations(entegrationCode, @"C:/Locations/Download/" + fullname);
        //System.IO.Path.GetFullPath(fuLocation.PostedFile.FileName)



    }

}