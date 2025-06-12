using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using System;
using System.Data;

public partial class Reconcliation_Detail_UptReconcliationDetail : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        var uptReference = QueryHelper.GetString("UptReference");

        var bankTransactionNumber = QueryHelper.GetString("BankTransactionNumber");

        if (!string.IsNullOrEmpty(uptReference))
        {
            StaticData sd = new StaticData();
            sd.AddParameter("TransactionReference", System.Data.DbType.String, uptReference);

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

        if (string.IsNullOrEmpty(uptReference) && !string.IsNullOrEmpty(bankTransactionNumber))
        {
            StaticData sd = new StaticData();
            sd.AddParameter("BankTransactionNumber", System.Data.DbType.String, bankTransactionNumber);

            DataSet ds = sd.ReturnDatasetSp("spGetBankTransactionDetail");

            if (ds.Tables.Count > 0)
            {
                gvBank.DataSource = ds.Tables[0];
                gvBank.DataBind();
            }

        }

    }

}