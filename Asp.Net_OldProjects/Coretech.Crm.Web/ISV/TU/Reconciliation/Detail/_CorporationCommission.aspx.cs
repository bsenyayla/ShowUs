using System;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.Transfer;
using Coretech.Crm.Factory;
using System.Data;
using TuFactory.TuUser;
using TuFactory.Object.User;
using TuFactory.Reconciliation.Objects;
using System.Collections.Generic;
using TuFactory.Integrationd3rdLayer.Object;
using TuFactory.Data;
using Coretech.Crm.Factory.Exporter;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_CorporationCommission : BasePage
    {
        private TuUserApproval _userApproval = null;

        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };

        protected void GetReConciliationClick(object sender, AjaxEventArgs e)
        {
            if (new_StartDate.Value.HasValue && new_EndDate.Value.HasValue && !string.IsNullOrEmpty(new_Corporation.Value))
            {
                double dateDiff = (ValidationHelper.GetDate(new_EndDate.Value) - ValidationHelper.GetDate(new_StartDate.Value)).TotalDays;
                if (dateDiff > 3)
                {
                    MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                    msg.Show("", "", " Tarih aralığınız 4 günden fazla olmamalıdır.");
                }
                else
                {
                    CorporationDb cdb = new CorporationDb();

                    GrdCorpComissionReport.DataSource = cdb.GetCorporationTransactionWithCommission(ValidationHelper.GetDate(new_StartDate.Value), ValidationHelper.GetDate(new_EndDate.Value), ValidationHelper.GetGuid(new_Corporation.Value));
                    GrdCorpComissionReport.DataBind();
                }
            }
            else
            {
                MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                msg.Show("", "", " Lütfen tarih ve kurum seçiniz.");
            }

        }

        protected void ToolbarButtonFind2Click(object sender, AjaxEventArgs e)
        {
            if (new_StartDate.Value.HasValue && new_StartDate.Value.HasValue && !string.IsNullOrEmpty(new_Corporation.Value))
            {
                CorporationDb cdb = new CorporationDb();

                DataTable dt = cdb.GetCorporationTransactionWithCommission(ValidationHelper.GetDate(new_StartDate.Value), ValidationHelper.GetDate(new_EndDate.Value), ValidationHelper.GetGuid(new_Corporation.Value));

                if (dt.Rows.Count > 0)
                {
                    var n = string.Format("Kurum Komisyon Rapor-{0:yyyy-MM-dd_hh-mm-ss-tt}.xls", DateTime.Now);
                    Export.ExportDownloadData(dt, n);
                }
            }

        }

        protected void Page_Load(object sender, EventArgs e)
        {
            var ufFactory = new TuUserFactory();
            _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

            if (!RefleX.IsAjxPostback)
            {
                new_StartDate.Value = DateTime.Now;
                new_EndDate.Value = DateTime.Now;
            }

        }




    }
}