using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.ISV.TU.Office.OfficeData;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.IO;
using TuFactory.Office;
using TuFactory.Office.Model;

namespace Coretech.Crm.Web.ISV.TU.Office
{
    public partial class OfficeDataImportTask : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void BtnSaveClick(object sender, AjaxEventArgs e)
        {
            try
            {
                FileInfo fi = new FileInfo(SaveFileServer(upload1.FileName));
                var officeDataManager = new OfficeDataManager();
                var result = officeDataManager.SaveOfficeData(txtDescription.Value, fi.Name, fi.FullName, 0, ValidationHelper.GetBoolean(chkSentMail.Value));
                e.Success = true;
                QScript("alert('" + string.Format("{0} nolu aktarım numarası ile işleminizi takip edebilirsiniz.", result) + "');window.top.R.WindowMng.getActiveWindow().hide();");
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex);
                throw ex;
            }
        }

        protected void BtnSaveAndImportClick(object sender, AjaxEventArgs e)
        {
            try
            {
                FileInfo fi = new FileInfo(SaveFileServer(upload1.FileName));
                var officeDataManager = new OfficeDataManager();
                var result = officeDataManager.SaveOfficeData(txtDescription.Value, fi.Name, fi.FullName, 0, ValidationHelper.GetBoolean(chkSentMail.Value));
                e.Success = true;
                QScript("alert('" + string.Format("{0} nolu aktarım numarası ile işleminizi takip edebilirsiniz.", result) + "');window.top.R.WindowMng.getActiveWindow().hide();");
                new OfficeDataImportDb().OfficeDataImportUpdateStatus(ValidationHelper.GetInteger(result, 0), (int)OfficeDataImportStatus.Processing);
                RunAsync(result, App.Params.CurrentUser.SystemUserId);
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex);
                throw ex;
            }
        }

        private string SaveFileServer(string file)
        {
            FileInfo fi = new FileInfo(file);
            string fileFullName = DateTime.Now.ToString("yyyyMMddhhmmss_") + file;
            using (var impersonator = new Impersonator())
            {
                impersonator.Impersonate(ExcelImportFactory.ImporterUser, ExcelImportFactory.ImporterDomain, ExcelImportFactory.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);
                upload1.PostedFile.SaveAs(Path.Combine(ExcelImportFactory.ImportPath, fi.Name));             
            }

            return Path.Combine(ExcelImportFactory.ImportPath, fi.Name);
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
                    if (!task.IsCompleted)
                    {
                        LogUtil.Write(string.Format("{0} Nolu dosya aktarılamadı.", processId), "Coretech.Crm.Web.ISV.TU.Office.RunAsync");
                    }
                    else
                    {
                        new OfficeDataImportDb().SendMail(processId);
                        new OfficeDataImportDb().OfficeDataImportUpdateStatus(ValidationHelper.GetInteger(processId, 0), (int)OfficeDataImportStatus.Completed);
                    }
                }
            });

            return task;
        }
    }
}