using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using UPT.Shared.CacheProvider;
using UPT.Shared.CacheProvider.Model.Cache;
using System.Runtime.Serialization.Formatters.Binary;
using System.IO;

public partial class CacheMonitor_CacheMonitor : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            FillCacheComboData();
        }

        txtDatetime.Text = DateTime.Now.Date.ToString("dd.MM.yyyy");

        CacheInformation cacheInformation = GlobalCacheManager.Instance.GetCacheInformation();
        //lblCacheSize.Text = AutoFileSize(cacheInformation.Size);
        lblCacheCount.Text = cacheInformation.Count.ToString();
    }

    private void FillCacheMonitor()
    {
        GridView1.DataSource = new UPT.Shared.CacheProvider.Repository.SharedDb().CacheMonitorSelectStatus(Convert.ToDateTime(txtDatetime.Text));
        GridView1.DataBind();
    }

    private void FillCacheComboData()
    {
        ddlModel.DataSource = Enum.GetValues(typeof(UPT.Shared.CacheProvider.Model.Entity));
        ddlModel.DataBind();
    }

    protected void btnCacheData_Click(object sender, EventArgs e)
    {
        var data = GlobalCacheManager.Instance.GetItem(ddlModel.SelectedValue);
        if (data != null)
        {
            lblModelSize.Text = AutoFileSize(GetObjectSize(data));
            GridView1.DataSource = data;
            GridView1.DataBind();
            lblRowCount.Text = GridView1.Rows.Count.ToString();
        }
        else
        {
            Page.ClientScript.RegisterStartupScript(this.GetType(), "CallMyFunction", string.Format("alert({0} - Seçmiş olduğunuz model cache üzerinde yok yada artık kullanılamıyor.);",ddlModel.SelectedValue), true);
            return;
        }
    }

    protected void btnCacheSet_Click(object sender, EventArgs e)
    {
        try
        {
            new UPT.Shared.CacheProvider.GlobalCacheInitializer().CreateCache();
        }
        catch (Exception ex)
        {
            throw ex;
        }
        
    }

    private static long GetObjectSize(object obj)
    {
        var bf = new BinaryFormatter();
        var ms = new MemoryStream();
        bf.Serialize(ms, obj);
        var size = ms.Length;
        ms.Dispose();
        return size;
    }

    public static string AutoFileSize(long number)
    {
        double tmp = number;
        string suffix = " B ";
        if (tmp > 1024) { tmp = tmp / 1024; suffix = " KB"; }
        if (tmp > 1024) { tmp = tmp / 1024; suffix = " MB"; }
        if (tmp > 1024) { tmp = tmp / 1024; suffix = " GB"; }
        if (tmp > 1024) { tmp = tmp / 1024; suffix = " TB"; }
        return tmp.ToString("n") + suffix;
    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        UPT.Shared.CacheProvider.GlobalCacheManager.Instance.GetItem(ddlModel.SelectedValue, true);
    }

    protected void Button2_Click(object sender, EventArgs e)
    {
        FillCacheMonitor();
    }

    protected void Button3_Click(object sender, EventArgs e)
    {
        var a = UPT.Shared.CacheProvider.Service.AccountService.GetAccountByAccountId(Guid.Parse("1c56dd04-3158-488c-846f-066e73591339"));
    }

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        //HtmlImage img = new HtmlImage() { Src = "~/ISV/TU/images/add_16x16.gif" };
        //HtmlImage img2 = new HtmlImage() { Src = "~/ISV/TU/images/delete_16x16.gif" };
        //if (e.Row.RowIndex == -1)
        //    return;

        //if (e.Row.Cells[1].Text == "1")
        //{
        //    e.Row.Cells[1].Controls.Add(img);
        //}
        //else
        //{
        //    e.Row.Cells[1].Controls.Add(img2);
        //}
    }
    protected void GridView1_DataBound(object sender, EventArgs e)
    {

    }
    protected void Button4_Click(object sender, EventArgs e)
    {
        //new TransferService().Get(Guid.Parse("0BFC8B28-456D-4B57-8FB9-6EB63DD0102F"));
    }
}