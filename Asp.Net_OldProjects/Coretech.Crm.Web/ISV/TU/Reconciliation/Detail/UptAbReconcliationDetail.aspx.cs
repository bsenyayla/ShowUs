using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Reflection;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Data;
using TuFactory.Integration3rd;
using TuFactory.Integrationd3rdLayer.Object;
using TuFactory.Object;
using TuFactory.Object.Integration3Rd;
using TuFactory.Object.User;
using TuFactory.Reconciliation;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_Detail_UptAbReconcliationDetail : BasePage
    {
        private TuUserApproval _userApproval = null;

        protected override void OnPreInit(EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                var uptReference = QueryHelper.GetString("UptReference");
                pnlManualPreaccounting.LoadUrl(string.Format("/ISV/TU/Reconciliation/Detail/ManualPreaccountingDetail.aspx?reference={0}&transactionType={1}", uptReference, string.Empty));
                pnlManualBankAccounting.LoadUrl(string.Format("/ISV/TU/FreeAccounting/ManuelAbAccounting.aspx?reference={0}", uptReference));
            }
            base.OnPreInit(e);
        }

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
}