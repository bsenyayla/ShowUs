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

namespace Coretech.Crm.Web.ISV.TU.Transfer
{
    public partial class TransferDocument : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            hdnRecId.Value = QueryHelper.GetString("RecordId");
            hdnObjectId.Value = QueryHelper.GetString("ObjectId");

            var dt = UserDocumentRole();

            if (dt.Rows.Count <=0)
            {
                BtnDeleteAll.SetVisible(false);
                BtnDelete.SetVisible(false);
            }

        }


        protected void DocumentHistory(object sender, AjaxEventArgs e)
        {
            var sd = new StaticData();
            sd.AddParameter("transferId", DbType.Guid, ValidationHelper.GetGuid(hdnRecId.Value));
            sd.AddParameter("OperationType", DbType.Int32, hdnObjectId.Value); 
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            DataTable dt = sd.ReturnDatasetSp("spGetTransferDocument").Tables[0];

            GridPanelConfirmHistory.DataSource = dt;
            GridPanelConfirmHistory.DataBind();
        }

        protected void DeleteDocument(object sender, AjaxEventArgs e)
        {
            Guid refId = Guid.Empty;
            var degerler = ((CheckSelectionModel)GridPanelConfirmHistory.SelectionModel[0]);
            if (degerler != null && degerler.SelectedRows != null)
            {
                foreach (var row in degerler.SelectedRows)
                {
                    Guid id = ValidationHelper.GetGuid(row.ID);
                    var sd = new StaticData();
                    sd.AddParameter("id", DbType.Guid, id);
                    sd.AddParameter("systemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
                    sd.ExecuteNonQuerySp("spDeleteTransferDocument");
                    GridPanelConfirmHistory.Reload();
                }
            }
        }


        public DataTable UserDocumentRole()
        {
            DataTable dt = new DataTable();
            try
            {
                
                var sd = new StaticData();
                sd.AddParameter("systemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
                var selectQuery = @"SELECT  
		                                MDU.*
	                                FROM  UserRole S (NoLock) 
	                                INNER JOIN Role R (NoLock) ON R.RoleId = S.RoleId
	                                INNER JOIN TBL_MOBILE_DOCUMENT_USER_ROLE MDU (NoLock) ON MDU.RoleId = R.RoleId
	                                WHERE	1=1
			                                AND S.SystemUserId = @SystemuserId 
			                                AND MDU.SeesAllData = 1";
                dt = sd.ReturnDataset(selectQuery).Tables[0];
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex);
            }
            return dt;
        }

        protected void DeleteDocumentAll(object sender, AjaxEventArgs e)
        {
                Guid transferId = ValidationHelper.GetGuid(hdnRecId.Value);
                int operationType = Convert.ToInt32( hdnObjectId.Value);
                var sd = new StaticData();
                sd.AddParameter("TRANSFERID", DbType.Guid, transferId);
                sd.AddParameter("OPERATIONTYPE", DbType.Int32, operationType);
                sd.AddParameter("SYSTEMUSERID", DbType.Guid, App.Params.CurrentUser.SystemUserId);
                sd.ExecuteNonQuerySp("spDeleteTransferDocumentAll");
                GridPanelConfirmHistory.Reload();
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