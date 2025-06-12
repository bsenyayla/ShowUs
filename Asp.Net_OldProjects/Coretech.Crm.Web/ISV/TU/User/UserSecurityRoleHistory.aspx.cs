using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Coretech.Crm.Web.ISV.TU.User
{
    public partial class UserSecurityRoleHistory : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            hdnRecId.Value = QueryHelper.GetString("RecordId");
            hdnObjectId.Value = QueryHelper.GetString("ObjectId");

        }


        protected void UserSecurityRoleHistoryEvent(object sender, AjaxEventArgs e)
        {
            var sd = new StaticData();
            sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid( hdnRecId.Value));
            DataTable dt = sd.ReturnDatasetSp("spUserSecurityRoleHistory").Tables[0];

            GridPanelConfirmHistory.DataSource = dt;
            GridPanelConfirmHistory.DataBind();
        }

        
        protected void Process(object sender, AjaxEventArgs e)
        {
            var degerler = ((RowSelectionModel)GridPanelConfirmHistory.SelectionModel[0]);
            if (degerler != null && degerler.SelectedRows != null)
            {

                if (degerler.SelectedRows.FILEPATH == null)
                    return;
                string filename = Path.GetFullPath(degerler.SelectedRows.FILEPATH);
                var fileInfo = new FileInfo(filename);

                using (var impersonator = new Impersonator())
                {
                    impersonator.Impersonate(ExcelImportFactory.ImporterUser, ExcelImportFactory.ImporterDomain, ExcelImportFactory.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);
                    if (!fileInfo.Exists)
                    {
                        throw new FileNotFoundException("File to download was not found \n İndirmek İçin Dosya Bulunamadı.", filename);
                    }
                    Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileInfo.Name);
                    //response.AddHeader("Content-Length", fileInfo.Length.ToString());
                    if (fileInfo.Name.EndsWith(".png"))
                    {
                        Response.ContentType = "image/x-png";
                    }
                    Response.WriteFile(fileInfo.FullName);
                    Response.Flush();
                    Response.End();
                    Response.Close();
                }
            }
        }

        
    }
}