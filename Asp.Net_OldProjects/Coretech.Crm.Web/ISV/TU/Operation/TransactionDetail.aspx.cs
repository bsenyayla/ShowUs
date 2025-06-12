using Coretech.Crm.PluginData;
using System;
using System.Data;

public partial class Operation_TransactionDetail : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void GetDetail(object sender, EventArgs e)
    {
        string reference = tReference.Text;

        StaticData sd = new StaticData();
        sd.AddParameter("TransactionReference", System.Data.DbType.String, reference);

        DataSet ds = sd.ReturnDatasetSp("spGetTransactionDetail");

        for (int i = 0; i < ds.Tables[1].Rows.Count; i++)
	    {
            ds.Tables[1].Rows[i]["TARİH"] = DateTime.Parse(ds.Tables[1].Rows[i]["TARİH"].ToString()).ToLocalTime();
		}

        for (int i = 0; i < ds.Tables[2].Rows.Count; i++)
        {
            ds.Tables[2].Rows[i]["OLUŞTURULMA TARİHİ"] = DateTime.Parse(ds.Tables[2].Rows[i]["OLUŞTURULMA TARİHİ"].ToString()).ToLocalTime();
        }

        for (int i = 0; i < ds.Tables[4].Rows.Count; i++)
        {
            ds.Tables[4].Rows[i]["OLUŞTURULMA TARİHİ"] = DateTime.Parse(ds.Tables[4].Rows[i]["OLUŞTURULMA TARİHİ"].ToString()).ToLocalTime();
        }

        for (int i = 0; i < ds.Tables[5].Rows.Count; i++)
        {
            ds.Tables[5].Rows[i]["OLUŞTURULMA TARİHİ"] = DateTime.Parse(ds.Tables[5].Rows[i]["OLUŞTURULMA TARİHİ"].ToString()).ToLocalTime();
        }

        gvBank.DataSource = ds.Tables[0];
        gvBank.DataBind();

        gvUpt.DataSource = ds.Tables[1];
        gvUpt.DataBind();

        gvTransfer.DataSource = ds.Tables[2];
        gvTransfer.DataBind();

        gvPayment.DataSource = ds.Tables[3];
        gvPayment.DataBind();

        gvRefundPayment.DataSource = ds.Tables[4];
        gvRefundPayment.DataBind();

        gvRefundTransfer.DataSource = ds.Tables[5];
        gvRefundTransfer.DataBind();
    }
}