using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.ISV.TU.Office.OfficeData;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.Office;
using TuFactory.Office.Model;

namespace Coretech.Crm.Web.ISV.TU.Office
{
    public partial class OfficeDataImport : BasePage
    {

        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void GetData(object sender, AjaxEventArgs e)
        {
            DataTable dt = new OfficeDataManager().GetOfficeData(ValidationHelper.GetInteger(txtSearch.Value, 0), ValidationHelper.GetDate(txtStartDate.Value),
                ValidationHelper.GetDate(txtEndDate.Value));
            gpOfficeData.DataSource = dt;
            gpOfficeData.DataBind();

        }

        protected void GetDataDetail(object sender, AjaxEventArgs e)
        {
            DataTable dt = new OfficeDataManager().GetOfficeDataDetail(ValidationHelper.GetInteger(hdnSelectedId.Value, 0));
            gpOfficeDataImportDetail.DataSource = dt;
            gpOfficeDataImportDetail.DataBind();
        }

        protected void FileDownload(object sender, AjaxEventArgs e)
        {
            if (!string.IsNullOrEmpty(hdnFilePath.Value))
            {
                Downloadfile(hdnFilePath.Value);
            }
        }

        private void Downloadfile(string sFilePath)
        {
            var file = new System.IO.FileInfo(sFilePath);
            using (var impersonator = new Impersonator())
            {
                impersonator.Impersonate(ExcelImportFactory.ImporterUser, ExcelImportFactory.ImporterDomain, ExcelImportFactory.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);
                Response.Clear();
                Response.AddHeader("Content-Disposition", "attachment; filename=" + file.Name);
                Response.AddHeader("Content-Length", file.Length.ToString(CultureInfo.InvariantCulture));
                Response.ContentType = "application/octet-stream";
                Response.WriteFile(file.FullName);
                Response.End();
            }
        }

        protected void ImportManuelStart(object sender, AjaxEventArgs e)
        {
            if (ValidationHelper.GetInteger(hdnStatusCode.Value, 0) != 0)
            {
                QScript("alert('Dosya statüsü aktarıma uygun değil ya da dosya zaten aktarılmış');");
                return;
            }

                if (ValidationHelper.GetInteger(hdnSelectedId.Value, 0)!=0)
            {
                QScript("alert('" + string.Format("{0} nolu aktarımı manuel başlatmak için [Tamam] butonuna basınız. Bu işlem biraz zaman alabilir.", ValidationHelper.GetInteger(hdnSelectedId.Value, 0)) + "')");
                new OfficeDataImportDb().OfficeDataImportUpdateStatus(ValidationHelper.GetInteger(hdnSelectedId.Value, 0), (int)OfficeDataImportStatus.Processing);
                RunAsync(ValidationHelper.GetInteger(hdnSelectedId.Value, 0), App.Params.CurrentUser.SystemUserId);
            }
            else
            {
                QScript("alert('Lütfen aktarmak istediğiniz dosyayı seçiniz.');");
            }
        }

        public System.Threading.Tasks.Task RunAsync(int processId, Guid SystemUserId)
        {
            var task = System.Threading.Tasks.Task.Factory.StartNew(() =>
            {
                new OfficeDataImportFactory().Run(processId, SystemUserId, this.Context);
            });

            task.ContinueWith(t =>
            {
                if (t.Exception != null)
                {
                    LogUtil.WriteException(t.Exception, "Coretech.Crm.Web.ISV.TU.Office.RunAsync");
                }
                else
                {
                    if (task.IsCompleted)
                    {
                        new OfficeDataImportDb().SendMail(processId);
                        new OfficeDataImportDb().OfficeDataImportUpdateStatus(ValidationHelper.GetInteger(hdnSelectedId.Value, 0), (int)OfficeDataImportStatus.Completed);

                    }
                    else
                    {
                        LogUtil.Write(string.Format("{0} Nolu dosya aktarılamadı.", processId), "Coretech.Crm.Web.ISV.TU.Office.RunAsync");
                    }
                }
            });

            return task;
        }
    }
}