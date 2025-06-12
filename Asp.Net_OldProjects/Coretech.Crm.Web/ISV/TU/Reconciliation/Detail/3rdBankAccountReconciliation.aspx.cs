using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using TuFactory.Corporation;
using TuFactory.Transfer;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_3rdBankAccountReconciliation : BasePage
    {
        private Guid QueryId = Guid.Empty;
        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };

        protected void Page_Load(object sender, EventArgs e)
        {

            if (!RefleX.IsAjxPostback)
            {
                new_StartDate.Value = DateTime.Now;
                new_EndDate.Value = DateTime.Now;
            }
        }

        protected void new_EftBankLoad(object sender, AjaxEventArgs e)
        {
            var corporationCode = App.Params.GetConfigKeyValue("3RDBANKACCOUNT_CORPORATION_CODE");

            string strSql = @"SELECT e.new_EftBankID as ID,  e.EftBankName as VALUE, e.new_ExternalCode,new_TCMBCode ,c.new_CorporationCode, e.new_CorporationIdName,e.EftBankName 
                              FROM vNew_EFTBANK e
                              INNER JOIN vnew_Corporation c on c.new_CorporationId = e.new_CorporationId where e.DeletionStateCode =0 ";

            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("EFT_BANKS_LOOKUP");
            var gpc = new GridPanelCreater();
            int cnt;
            var start = new_EftBank.Start();
            var limit = new_EftBank.Limit();
            var spList = new List<CrmSqlParameter>() { };


            strSql += " AND c.new_CorporationCode = @corporationCode ";

            CrmSqlParameter spItem = new CrmSqlParameter
            {
                Dbtype = DbType.String,
                Paramname = "corporationCode",
                Value = ValidationHelper.GetString(corporationCode)
            };
            spList.Add(spItem);


            const string sort = "[{\"field\":\"EftBankName\",\"direction\":\"Asc\"}]";

            var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);

            new_EftBank.TotalCount = cnt;
            new_EftBank.DataSource = t;
            new_EftBank.DataBind();

        }

        protected void SaveReConciliation(object sender, AjaxEventArgs e)
        {
            CorporationFactory corporationFactory = new CorporationFactory();
            var startDate = ValidationHelper.GetDate(new_StartDate.Value);
            var endDate = ValidationHelper.GetDate(new_EndDate.Value);
            Guid recId = Guid.NewGuid();
            try
            {
                QScript("LogCurrentPage();");

                var corporationCode = App.Params.GetConfigKeyValue("3RDBANKACCOUNT_CORPORATION_CODE");
                var integrationChannelId = corporationFactory.GetIntegrationChannelIdByCorporationCode(corporationCode);

                ReConciliationFactory.Instance.GetNkolayEFTReconciliationData(recId, startDate, endDate, integrationChannelId);

                if (recId != null && recId != Guid.Empty)
                {
                    hdnRecId.SetValue(recId);
                }
                else
                {
                    MessageBox msg = new MessageBox() { Height = 200 };
                    msg.Show("Hata", "Bilinmeyen Hata!");
                }

                ToolbarButtonTransactionTotalClick(sender, e);
            }
            catch (Exception ex)
            {
                MessageBox msg = new MessageBox() { Height = 200 };
                msg.Show("Hata", "", "İşlem sırasında bir hata ile karşılaşıldı. <br/> Hata: " + ex.Message);
            }

        }

        protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
        {
            StaticData sd = new StaticData();

            string sql = @"SELECT 
       [New_NkolayBankReconciliationDetailId] AS ID
      ,[new_TransferTuRef]
      ,[new_Amount]
      ,[new_NkolayBankReconciliationId]
      ,[new_PartnerRef] AS VALUE
      ,[new_PartnerRef]
      ,[new_DifferenceAmount]
      ,[new_ReconcliationStatus]
      ,[new_CurrencyId]
      ,[new_PartnerStatus]
      ,[new_ReconciliationDate]
      ,[new_TransferAmount]
      ,[new_EftBankId]
      ,[new_EftBankIdName]
      ,[new_TransferCurrencyId]
      ,new_TransferCurrencyIdName
      ,new_CurrencyIdName
     ,rs.Label as new_ReconcliationStatusName
  FROM [vNew_NkolayBankReconciliationDetail]  rd
  inner join [dbo].[new_PLNew_NkolayBankReconciliationDetail_new_ReconcliationStatus] rs on rs.Value= rd.new_ReconcliationStatus  WHERE 1 = 1 ";

            var spList = new List<CrmSqlParameter>();

            if (!string.IsNullOrEmpty(cmbCurrency.Value))
            {

                sql += " AND new_CurrencyIdName = @CurrencyCode";
                sd.AddParameter("CurrencyCode", DbType.String, cmbCurrency.Value);

            }

            if (!string.IsNullOrEmpty(new_ReconcliationStatus.Value))
            {
                sql += " AND new_ReconcliationStatus = @ReconcliationStatus";
                sd.AddParameter("ReconcliationStatus", DbType.Int32, ValidationHelper.GetInteger(new_ReconcliationStatus.Value));
            }
            if (!string.IsNullOrEmpty(TransferTuRef.Value))
            {
                sql += " AND new_TransferTuRef = @TuRefNumber";
                sd.AddParameter("TransferTuRef", DbType.String, TransferTuRef.Value);
            }

            if (!string.IsNullOrEmpty(new_FileTransactionNumber.Value))
            {
                spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "PartnerRef", Value = new_FileTransactionNumber.Value });

                sql += " AND new_PartnerRef = @PartnerRef";
                sd.AddParameter("PartnerRef", DbType.String, new_FileTransactionNumber.Value);
            }

            if (!string.IsNullOrEmpty(new_EftBank.Value))
            {
                spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "EftBank", Value = new_EftBank.Value });

                sql += " AND new_EftBankId = @EftBank";
                sd.AddParameter("EftBank", DbType.Guid, new_EftBank.Value);
            }

            var data = sd.ReturnDataset(sql).Tables[0];

            if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            {
                var viewqueryid = ViewFactory.GetViewIdbyUniqueName("NKOLAY_RECONCILIATION_DETAIL");
                var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
                gpw.Export(data);
            }

            GrdReConciliation.DataSource = data;
            GrdReConciliation.DataBind();
        }

        protected void ToolbarButtonFindProblemTransactionClick(object sender, AjaxEventArgs e)
        {
            StaticData sd = new StaticData();

            string sql = @"SELECT 
       [New_NkolayBankReconciliationDetailId] AS ID
      ,[new_TransferTuRef]
      ,[new_Amount]
      ,[new_NkolayBankReconciliationId]
      ,[new_PartnerRef] AS VALUE
      ,[new_PartnerRef]
      ,[new_DifferenceAmount]
      ,[new_ReconcliationStatus]
      ,[new_CurrencyId]
      ,[new_PartnerStatus]
      ,[new_ReconciliationDate]
      ,[new_TransferAmount]
      ,[new_EftBankId]
      ,[new_EftBankIdName]
      ,[new_TransferCurrencyId]
      ,new_TransferCurrencyIdName
      ,new_CurrencyIdName
     ,rs.Label as new_ReconcliationStatusName
  FROM [vNew_NkolayBankReconciliationDetail]  rd
  inner join [dbo].[new_PLNew_NkolayBankReconciliationDetail_new_ReconcliationStatus] rs on rs.Value= rd.new_ReconcliationStatus  WHERE rd.new_ReconcliationStatus != 1 ";

            var spList = new List<CrmSqlParameter>();

            if (!string.IsNullOrEmpty(cmbCurrency.Value))
            {

                sql += " AND new_CurrencyIdName = @CurrencyCode";
                sd.AddParameter("CurrencyCode", DbType.String, cmbCurrency.Value);

            }

          
            if (!string.IsNullOrEmpty(TransferTuRef.Value))
            {
                sql += " AND new_TransferTuRef = @TuRefNumber";
                sd.AddParameter("TransferTuRef", DbType.String, TransferTuRef.Value);
            }

            if (!string.IsNullOrEmpty(new_FileTransactionNumber.Value))
            {
                spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "PartnerRef", Value = new_FileTransactionNumber.Value });

                sql += " AND new_PartnerRef = @PartnerRef";
                sd.AddParameter("PartnerRef", DbType.String, new_FileTransactionNumber.Value);
            }

            if (!string.IsNullOrEmpty(new_EftBank.Value))
            {
                spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "EftBank", Value = new_EftBank.Value });

                sql += " AND new_EftBankId = @EftBank";
                sd.AddParameter("EftBank", DbType.Guid, new_EftBank.Value);
            }

            var data = sd.ReturnDataset(sql).Tables[0];

            if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            {
                var viewqueryid = ViewFactory.GetViewIdbyUniqueName("NKOLAY_RECONCILIATION_DETAIL");
                var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
                gpw.Export(data);
            }

            GrdProblemReconciliation.DataSource = data;
            GrdProblemReconciliation.DataBind();
        }

        protected void ToolbarButtonTransactionTotalClick(object sender, AjaxEventArgs e)
        {
            StaticData sd = new StaticData();

            var data = sd.ReturnDatasetSp("spTuGetNkolayReconciliationTotal").Tables[0];

            GrdTotal.DataSource = data;
            GrdTotal.DataBind();
        }
    }
}