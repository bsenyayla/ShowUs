using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using DotNet.SFtp.jsch;
using RefleXFrameWork;
using TuFactory.FtpTransfer;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;
using System.Web;
using Coretech.Crm.Objects.Crm;
using System.Linq;
using TuFactory.Data;
using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Factory.Crm.Approval;
using TuFactory.Domain.Company;

namespace FtpFileTransfer_FileTransfer
{
    public partial class _FileTransferInput : BasePage
    {
        private TuUserFactory uf = new TuUserFactory();
        TuUserApproval _ua = new TuUserApproval();
        private bool operationWaitConfirm = true;

        protected void Translate()
        {
            GetList.Text = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_GETFILELIST");
            DownloadFile.Text = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_FTP_FILE_DOWNLOAD");
            btnFind.Text = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_FIND");
            FtpReadFileDetail.Title = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_READ_FILE_DETAILS");
            btnTransfer.Text = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_TRANSFER");
            btnApproved.Text = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_APPROVED");
            btnTransmitError.Text = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_TRANSFERGETERROR");
            AllFiles.FieldLabel = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_ALLFILES");
            //AkbFromCorp.Text = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_AKBFROMCORP");

            TotalGrid.ColumnModel.Columns[0].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_TOTALGRID_QUANTITY");
            TotalGrid.ColumnModel.Columns[1].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_TOTALGRID_TOTALAMOUNT");
            TotalGrid.ColumnModel.Columns[2].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_TOTALGRID_CURRENCY");

            GridFtpRead.ColumnModel.Columns[0].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_ISTRANSFERED");
            GridFtpRead.ColumnModel.Columns[1].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_ISAPPROVED");
            GridFtpRead.ColumnModel.Columns[2].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_TRANSFERSTATUS");
            GridFtpRead.ColumnModel.Columns[3].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_TRANSFERDATE");
            GridFtpRead.ColumnModel.Columns[4].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_FTPTYPENAME");
            GridFtpRead.ColumnModel.Columns[5].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_FILEDIRECTIONNAME");
            GridFtpRead.ColumnModel.Columns[6].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_FILENAME");
            GridFtpRead.ColumnModel.Columns[7].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_FILEPATH");
            GridFtpRead.ColumnModel.Columns[8].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_CORPORATIONNAME");
            GridFtpRead.ColumnModel.Columns[9].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_TOTALCOUNT");
            GridFtpRead.ColumnModel.Columns[10].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_DOWNLOADCOUNT");
            GridFtpRead.ColumnModel.Columns[11].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_NOTERRORCOUNT");
            GridFtpRead.ColumnModel.Columns[12].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_ERRORCOUNT");

            FtpList.ColumnModel.Columns[0].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_FTPLIST_DOWNLOADED");
            FtpList.ColumnModel.Columns[1].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_FTPLIST_NAME");
            FtpList.ColumnModel.Columns[2].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_FTPLIST_SIZE");
            FtpList.ColumnModel.Columns[3].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_FTPLIST_MODIFIED");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            _ua = uf.GetApproval(App.Params.CurrentUser.SystemUserId);
            operationWaitConfirm = IsConfirmed();
            if (!RefleX.IsAjxPostback)
            {
                if (!_ua.FtpDownload && !_ua.FtpConfirm)
                {
                    GridFtpRead.Visible = false;
                    PanelX2.Visible = false;
                    FtpList.AutoHeight = EHeight.Auto;
                    FtpList.Visible = false;
                    PanelX1.Visible = false;
                    GridFtpRead.AutoHeight = EHeight.Auto;
                }
                if (_ua.FtpDownload)
                {
                    GridFtpRead.Visible = true;
                    PanelX2.Visible = true;
                    FtpList.AutoHeight = EHeight.Normal;
                }

                if (_ua.FtpConfirm && !_ua.FtpDownload)
                {
                    FtpList.Visible = false;
                    PanelX1.Visible = false;
                    GridFtpRead.AutoHeight = EHeight.Auto;
                }

                var headerResult = DynamicFactory.GetSecurity(TuEntityEnum.New_FtpReadFileHeader.GetHashCode(), null);
                if (!headerResult.PrvRead)
                {
                    GridFtpRead.Visible = false;
                    PanelX2.Visible = false;
                    FtpList.AutoHeight = EHeight.Auto;
                }

                var headerResultdetail = DynamicFactory.GetSecurity(TuEntityEnum.New_FtpReadFileDetail.GetHashCode(), null);
                if (!headerResultdetail.PrvRead)
                    FtpReadFileDetail.Visible = false;
                else
                {
                    CreateViewGrid();
                }



                Translate();
                new_Date2.Value = DateTime.Today;
                new_Date1.Value = DateTime.Today.AddDays(-7);

                QScript(_ua.FtpUseButtons ? "btnTransmitError.show();" : "btnTransmitError.hide();");
                QScript(_ua.FtpUseButtons ? "ToolBar1.show();" : "ToolBar1.hide();");

            }
        }

        protected void btnTransferErrorOnEvent(object sender, AjaxEventArgs e)
        {
            try
            {
                if (!_ua.FtpConfirm && operationWaitConfirm)
                {
                    throw new Exception("the user does not have necessary rights");
                }

                var ft = new FtpTransferFactory();
                var lines = ft.FtpConfirmErrorLog(ValidationHelper.GetGuid(FtpReadFileHeaderId.Value));
                lines = lines.Substring(0, lines.Length - 2);
                var ftp = new FtpTransferFactory();

                FtpFileUploadManager ftpFileUploadManager = new FtpFileUploadManager();

                var fileName = ftpFileUploadManager.UploadFtpFile(ValidationHelper.GetGuid(FtpReadFileHeaderId.Value), lines);

                var byteArray = Encoding.UTF8.GetBytes(lines);
                var stream = new MemoryStream(byteArray);

                HttpContext.Current.Response.Clear();
                HttpContext.Current.Response.ClearContent();
                HttpContext.Current.Response.ClearHeaders();
                HttpContext.Current.Response.StatusCode = 200;
                HttpContext.Current.Response.ContentType = "application/octet-stream";
                HttpContext.Current.Response.Charset = "utf-8";
                HttpContext.Current.Response.Cache.SetNoServerCaching();
                HttpContext.Current.Response.Cache.SetMaxAge(TimeSpan.Zero);
                HttpContext.Current.Response.AddHeader("Content-Disposition", String.Format("attachment;filename=\"" + fileName.FileName + "\""));
                HttpContext.Current.Response.AddHeader("Content-Length", stream.Length.ToString());
                HttpContext.Current.Response.BinaryWrite(byteArray);
                HttpContext.Current.Response.Flush();
                HttpContext.Current.Response.End();
            }
            catch (CrmException exx)
            {
                e.Success = false;
                e.Message = exx.ErrorMessage;
            }
            catch (Exception ex)
            {
                e.Success = false;
                e.Message = ex.Message;
            }
        }

        protected void btnApprovedOnEvent(object sender, AjaxEventArgs e)
        {
            try
            {
                if (_ua.FtpDownload)
                {
                    var sd = new StaticData();
                    sd.AddParameter("FtpReadFileHeaderId", DbType.Guid, ValidationHelper.GetGuid(FtpReadFileHeaderId.Value));
                    sd.ExecuteScalar(@"
                    update vNew_FtpReadFileHeader set new_Approved = 1 where New_FtpReadFileHeaderId = @FtpReadFileHeaderId
                    ");
                    var msg = new MessageBox { Width = 500 };
                    msg.Show(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_APPROVED_COMPLETE"));
                }
            }
            catch (Exception ex)
            {
                e.Success = false;
                e.Message = ex.Message;
            }
        }

        protected void btnTransferOnEvent(object sender, AjaxEventArgs e)
        {
            try
            {
                if (!_ua.FtpConfirm && operationWaitConfirm)
                {
                    throw new Exception("the user does not have necessary rights");
                }

                var ft = new FtpTransferFactory();
                FtpReadFileHeaderManager ftpReadFileHeaderManager = new FtpReadFileHeaderManager();

                /*Dosya işleniyor statüsünde ise izin verme*/
                var lst = ftpReadFileHeaderManager.GetFtpReadFileHeader(ValidationHelper.GetGuid(CrmComboComp2.Value), ValidationHelper.GetGuid(FtpReadFileHeaderId.Value));
                if (lst.Count == 1)
                {
                    if (lst[0].TransferStatus == TuFactory.Data.FtpTransferData.FileTransferStatus.FileTransfering)
                    {
                        throw new Exception("File is transfering another process");
                    }
                }

                ft.FtpReadFileDetailTransfer(ValidationHelper.GetGuid(FtpReadFileHeaderId.Value), ValidationHelper.GetGuid(CrmComboComp2.Value), false, this.Context);
                FtpReadFileDetailGridPanel.Reload();
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "FileTransferInput.Aktar", "Ftp");
                e.Success = false;
                e.Message = ex.Message;
            }
        }

        protected void btnFtpUpdateStatusBack(object sender, AjaxEventArgs e)
        {
            var ft = new FtpTransferFactory();
            FtpReadFileHeaderManager ftpReadFileHeaderManager = new FtpReadFileHeaderManager();

            /*Dosya işleniyor statüsünde ise izin verme*/
            var lst = ftpReadFileHeaderManager.GetFtpReadFileHeader(ValidationHelper.GetGuid(CrmComboComp2.Value), ValidationHelper.GetGuid(FtpReadFileHeaderId.Value));

            if (lst.Count == 1)
            {
                if (lst[0].TransferStatus == TuFactory.Data.FtpTransferData.FileTransferStatus.FileWaiting)
                {
                    throw new Exception("Dosya işlenme sırası bekliyor");
                }
            }

            var trans = (new StaticData()).GetDbTransaction();
            var df = new DynamicFactory(ERunInUser.CalingUser);

            /*yalandan confirm*/
            df.CheckConfirm = true;

            df.GetBeginTrans(trans);
            Guid recId = Guid.Empty;
            try
            {
                var de = new DynamicEntity(TuEntityEnum.New_FtpReadFileHeader.GetHashCode());

                if (!string.IsNullOrEmpty(FtpReadFileHeaderId.Value))
                {
                    de.AddKeyProperty("New_FtpReadFileHeaderId", ValidationHelper.GetGuid(FtpReadFileHeaderId.Value));

                }

                de.AddPicklistProperty("new_FileTransferStatus", 1);
                ((Picklist)de.Properties["new_FileTransferStatus"]).name = "Dosya Aktarılmayı bekliyor.";

                df.Update("New_FtpReadFileHeader", de);

                df.CommitTrans();


                //QScript("alert('Dosya onaya düşmüştür, sistem onay kaydından ilerletiniz.');");
                QScript("btnUpdateStatus.hide();");

            }
            catch (TuException ex)
            {
                e.Message = ex.ErrorMessage;
                e.Success = false;
                df.RollbackTrans();
            }
            catch (CrmException ex)
            {
                e.Message = ex.ErrorMessage;
                e.Success = false;
                df.RollbackTrans();
            }
            catch (Exception ex)
            {
                e.Message = ex.Message;
                e.Success = false;
                df.RollbackTrans();
            }
        }

        protected void btnFtpTransferLogOnEvent(object sender, AjaxEventArgs e)
        {
            Guid ftpReadFileHeaderId = ValidationHelper.GetGuid(FtpReadFileHeaderId.Value);

            wFptTransferLog.Show();
            FptTransferLogGridPanel.Reload();
            fptTransferLogDetailGridPanel.Reload();
        }

        protected void Process(object sender, AjaxEventArgs e)
        {
            var degerler = ((RowSelectionModel)GridFtpRead.SelectionModel[0]);
            StringBuilder sb = new StringBuilder();

            if (degerler.SelectedRows == null)
            {
                QScript("alert('Ooops! Dosya seçimi yapılmamış.');");
                return;
            }

            if (degerler.SelectedRows != null && degerler.SelectedRows[0]["FilePath"] != null && degerler.SelectedRows[0]["FilePath"] != "")
            {
                try
                {
                    string filePath = degerler.SelectedRows[0]["FilePath"];
                    string text = string.Empty;

                    using (var impersonator = new Impersonator())
                    {
                        impersonator.Impersonate(ExcelImportFactory.ImporterUser, ExcelImportFactory.ImporterDomain, ExcelImportFactory.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);
                        using (StreamReader reader = new StreamReader(filePath))
                        {
                            text = reader.ReadToEnd();
                        }
                    }

                    string[] pathParts = filePath.Split("\\".ToCharArray());

                    string file = pathParts[pathParts.Length - 1];
                    Response.ContentType = "text/plain";
                    Response.AddHeader("Content-disposition", "attachment; filename=" + file);
                    Response.Write(text);
                    Response.End();
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }
        }

        protected void new_CorporationLoad(object sender, AjaxEventArgs e)
        {

            string strSql = @"Select distinct C.New_CorporationId ID, C.New_CorporationId,new_CorporationCode, CorporationName ,new_CorporationCode CODE, CorporationName VALUE from vNew_Corporation C inner join
vNew_FtpFileHeader f on c.New_CorporationId = f.new_CorporationId
Where  C.DeletionStateCode=0";
            const string sort = "";
            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CorpComboView");
            var gpc = new GridPanelCreater();
            int cnt;
            var start = new_CorporationId.Start();
            var limit = new_CorporationId.Limit();
            var like = new_CorporationId.Query();
            var splist = new List<CrmSqlParameter>();


            if (!string.IsNullOrEmpty(like))
            {

                strSql += " AND C.CorporationName LIKE  @Corporation + '%' ";
                splist.Add(
                    new CrmSqlParameter
                    {
                        Dbtype = DbType.String,
                        Paramname = "Corporation",
                        Value = like
                    });
            }

            var t = gpc.GetFilterData(strSql, viewqueryid, sort, splist, start, limit, out cnt);
            new_CorporationId.TotalCount = cnt;
            new_CorporationId.DataSource = t;
            new_CorporationId.DataBind();
        }

        protected void new_CrmComboComp1Load(object sender, AjaxEventArgs e)
        {

            string strSql = @"Select distinct C.New_CorporationId ID, C.New_CorporationId,new_CorporationCode, CorporationName ,new_CorporationCode CODE, CorporationName VALUE from vNew_Corporation C inner join
vNew_FtpFileHeader f on c.New_CorporationId = f.new_CorporationId
Where  C.DeletionStateCode=0";
            const string sort = "";
            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CorpComboView");
            var gpc = new GridPanelCreater();
            int cnt;
            var start = CrmComboComp1.Start();
            var limit = CrmComboComp1.Limit();
            var like = CrmComboComp1.Query();
            var splist = new List<CrmSqlParameter>();


            if (!string.IsNullOrEmpty(like))
            {

                strSql += " AND C.CorporationName LIKE  @Corporation + '%' ";
                splist.Add(
                    new CrmSqlParameter
                    {
                        Dbtype = DbType.String,
                        Paramname = "Corporation",
                        Value = like
                    });
            }

            var t = gpc.GetFilterData(strSql, viewqueryid, sort, splist, start, limit, out cnt);
            CrmComboComp1.TotalCount = cnt;
            CrmComboComp1.DataSource = t;
            CrmComboComp1.DataBind();
        }

        protected void DownloadFileOnEvent(object sender, AjaxEventArgs e)
        {
            try
            {
                if (!_ua.FtpDownload)
                {
                    return;
                }
                if (string.IsNullOrEmpty(new_FtpFileHeaderId.Value))
                {
                    new MessageBox(string.Format(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_FtpFileHeaderId.FieldLabel));
                    new_FtpFileHeaderId.Focus();
                    return;
                }

                var sel = ((RowSelectionModel)FtpList.SelectionModel[0]);

                CompanyParameter companyParameter = new CompanyParameter();

                companyParameter.CompanyId = App.Params.CurrentUser.CompanyId;

                companyParameter.ApplicationParams = new Dictionary<string, string>();
                companyParameter.ApplicationParams.Add("AZURE_FTPSTORAGE_ACCOUNT_NAME", App.Params.GetConfigKeyValue("AZURE_FTPSTORAGE_ACCOUNT_NAME"));
                companyParameter.ApplicationParams.Add("AZURE_FTPSTORAGE_ACCOUNT_KEY", App.Params.GetConfigKeyValue("AZURE_FTPSTORAGE_ACCOUNT_KEY"));
                companyParameter.ApplicationParams.Add("AZURE_FTPSTORAGE_SHARE_NAME", App.Params.GetConfigKeyValue("AZURE_FTPSTORAGE_SHARE_NAME"));


                if (sel.SelectedRows != null)
                {
                    FtpFileDownloadManager ftpFileDownloadManager = new FtpFileDownloadManager();

                    //ftpFileDownloadManager.DownloadFtpFile(ValidationHelper.GetGuid(new_FtpFileHeaderId.Value), "FtpDocumentNew.txt", DateTime.Now, false);
                    ftpFileDownloadManager.DownloadFtpFile(ValidationHelper.GetGuid(new_FtpFileHeaderId.Value), sel.SelectedRows.Name, ValidationHelper.GetDate(sel.SelectedRows.Modified), false, companyParameter);
                }
                else
                {
                    if (!FileUpload1.IsEmpty)
                    {
                        FtpFileUploadManager ftpFileUploadManager = new FtpFileUploadManager();
                        ftpFileUploadManager.UploadFile(ValidationHelper.GetGuid(new_FtpFileHeaderId.Value), FileUpload1, companyParameter);
                    }
                    else
                    {
                        new MessageBox("Lütfen Bir Dosya Seçiniz!");
                    }
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "FileTransferInput.DosyaIndir", "Ftp");
                e.Success = false;
                e.Message = ex.Message;
            }
        }

        protected void GetListOnEvent(object sender, AjaxEventArgs e)
        {
            try
            {
                FtpFileManager ftpFileManager = new FtpFileManager();
                FtpList.DataSource = ftpFileManager.GetList(ValidationHelper.GetGuid(new_FtpFileHeaderId.Value), AllFiles.Checked);
                FtpList.DataBind();

            }
            catch (SftpException sfex)
            {
                e.Success = false;
                e.Message = sfex.message;
                LogUtil.Write(sfex.Message);
            }
            catch (TuException ex)
            {
                ex.Show();
                LogUtil.Write(ex.Message);
            }
            catch (Exception ex)
            {
                e.Success = false;
                e.Message = ex.Message;
                LogUtil.Write(ex.Message);
            }
        }

        protected void GetFtpReadFile(object sender, AjaxEventArgs e)
        {
            try
            {
                if (new_Date1.Value > DateTime.MinValue && new_Date2.Value > DateTime.MinValue && !string.IsNullOrEmpty(CrmComboComp2.Value))
                {
                    FtpReadFileHeaderManager ftpReadFileHeaderManager = new FtpReadFileHeaderManager();

                    var lst = ftpReadFileHeaderManager.GetFtpReadFile(new_Date1.Value, new_Date2.Value, ValidationHelper.GetGuid(CrmComboComp2.Value));

                    var sd = new StaticData();

                    for (int i = lst.Count - 1; i >= 0; i--)
                    {
                        if (_ua.FtpDownload && !_ua.FtpConfirm && !operationWaitConfirm)
                        {
                            lst.RemoveAt(i);
                            continue;
                        }
                        if (_ua.FtpDownload && !_ua.FtpConfirm && lst[i].Approved && operationWaitConfirm && !lst[i].Aktar)
                        {
                            lst.RemoveAt(i);
                            continue;
                        }

                        if (_ua.FtpConfirm && !_ua.FtpDownload && !lst[i].Approved && operationWaitConfirm)
                        {
                            lst.RemoveAt(i);
                            continue;
                        }

                        sd.AddParameter("New_FtpReadFileHeaderId", DbType.Guid, lst[i].FtpReadFileHeaderId);

                        var dt = sd.ReturnDataset(@"
                    select CAST(CONVERT(varchar, CAST(sum(new_FileLineAmount) AS money), 1) AS varchar) Total, new_FileLineAmountCurrency from vNew_FtpReadFileDetail
                    where new_FtpReadFileHeaderId = @New_FtpReadFileHeaderId
                    group by new_FileLineAmountCurrency
                ").Tables[0];

                        var ct = "";
                        for (int j = 0; j < dt.Rows.Count; j++)
                        {
                            ct += "#" + dt.Rows[j]["Total"] + " " + dt.Rows[j]["new_FileLineAmountCurrency"] + "# ";
                        }
                        lst[i].Currency = ct;
                    }

                    GridFtpRead.DataSource = lst;
                    GridFtpRead.DataBind();
                }
                else
                {
                    if (new_Date1.Value <= DateTime.MinValue)
                    {
                        new MessageBox(string.Format(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_Date1.FieldLabel));
                        new_Date1.Focus();
                    }
                    if (new_Date2.Value <= DateTime.MinValue)
                    {
                        new MessageBox(string.Format(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_Date2.FieldLabel));
                        new_Date2.Focus();
                    }
                    if (string.IsNullOrEmpty(CrmComboComp2.Value))
                    {
                        new MessageBox(string.Format(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), CrmComboComp2.FieldLabel));
                        CrmComboComp2.Focus();
                    }
                }
            }
            catch (Exception ex)
            {
                e.Success = false;
                e.Message = ex.Message;
            }
        }

        public void CreateViewGrid()
        {
            var gpc = new GridPanelCreater();
            gpc.CreateViewGrid("READE_FILE_DETAIL", FtpReadFileDetailGridPanel);
            var strSelected = ViewFactory.GetViewIdbyUniqueName("READE_FILE_DETAIL").ToString();
            if (string.IsNullOrEmpty(strSelected))
                return;
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));










            gpc = new GridPanelCreater();
            gpc.CreateViewGrid("FtpTransferLodDetailView", fptTransferLogDetailGridPanel);

            strSelected = ViewFactory.GetViewIdbyUniqueName("FtpTransferLodDetailView").ToString();

            Guid QueryId = ValidationHelper.GetGuid(strSelected);

            //hdnViewList.Value = strSelected;

            if (string.IsNullOrEmpty(strSelected))
                return;
            gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));

            var getColumnList = new UserPoolMapDb().GetColumnList(Convert.ToInt32(0), QueryId, new UserPoolMapDb().GetAttributeListString(new UserPoolMapDb().getColumnSet(gpw.View.ColumnSetXml)));
            List<GridColumns> lstAddetColumn = fptTransferLogDetailGridPanel.ColumnModel.Columns.ToList();
            fptTransferLogDetailGridPanel.ClearColumns();

            foreach (GridColumns item in lstAddetColumn)
            {
                var count = (from c in getColumnList
                             where c.AttributeName == item.Header && c.Hide == true
                             select c).Count();
                if (count == 0)
                    fptTransferLogDetailGridPanel.AddColumn(item);
            }
            fptTransferLogDetailGridPanel.ReConfigure();











        }

        protected void TotalGridDataSource(object sender, AjaxEventArgs e)


        {
            var sd = new StaticData();
            sd.AddParameter("New_FtpReadFileHeaderId", DbType.Guid, ValidationHelper.GetDBGuid(FtpReadFileHeaderId.Value));

            var where = "";
            if (_ua.FtpDownload && !_ua.FtpConfirm && !operationWaitConfirm)
                where = " and isnull(h.new_Approved,0) = 3";
            if (_ua.FtpDownload && !_ua.FtpConfirm && operationWaitConfirm)
                where = " and isnull(h.new_Approved,0) = 0";
            if (!_ua.FtpDownload && _ua.FtpConfirm && operationWaitConfirm)
                where = " and isnull(h.new_Approved,0) = 1";
            if (_ua.FtpDownload && _ua.FtpConfirm && operationWaitConfirm)
                where = " and isnull(h.new_Approved,0) in (0,1)";

            sd.ClearParameters();
            sd.AddParameter("FtpReadFileHeaderId", DbType.Guid, ValidationHelper.GetDBGuid(FtpReadFileHeaderId.Value));
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);

            var strSql = string.Format(@" select count(new_FileLineAmount) Quantity,sum(new_FileLineAmount) TotalAmount,new_FileLineAmountCurrency Currency from dbo.tvNew_FtpReadFileDetail(@SystemUserId) as Mt 
                    Where mt.new_FtpReadFileHeaderId=@FtpReadFileHeaderId 
and exists (select * from vNew_FtpReadFileHeader h where DeletionStateCode = 0 and h.New_FtpReadFileHeaderId = mt.new_FtpReadFileHeaderId {0})
group by new_FileLineAmountCurrency
", where);
            var dt = sd.ReturnDataset(strSql).Tables[0];

            TotalGrid.TotalCount = dt.Rows.Count;

            TotalGrid.DataSource = dt;
            TotalGrid.DataBind();

        }

        protected void FptTransferLogGridPanelOnLoad(object sender, AjaxEventArgs e)
        {
            var sd = new StaticData();
            sd.AddParameter("FtpReadFileHeaderId", DbType.Guid, ValidationHelper.GetDBGuid(FtpReadFileHeaderId.Value));
            DataSet ds = sd.ReturnDatasetSp("spTuGetFtpTransferLog");
            lblCorporatioNamen.Clear();
            lblFtpReadFileHeaderName.Clear();
            lblCorporatioNamen.SetValue("Kurum: " + ds.Tables[1].Rows[0]["CorporationName"].ToString());
            lblFtpReadFileHeaderName.SetValue("Dosya: " + ds.Tables[1].Rows[0]["FileName"].ToString());


            FptTransferLogGridPanel.DataSource = ds.Tables[0];
            FptTransferLogGridPanel.DataBind();
        }

        protected void FptTransferLogDetailGridPanelOnLoad(object sender, AjaxEventArgs e)
        {
            if (e.ExtraParams != null && e.ExtraParams["FullList"] != null && ValidationHelper.GetInteger(e.ExtraParams["FullList"]) == 1)
            {
                chckSuccess.SetValue(true);
                chckError.SetValue(true);
                chckSuccess.SetIValue(true);
                chckError.SetIValue(true);
                hdnFtpTransferLogId.Clear();
                btnFtpTransferLogOnEvent(sender, e);
                return;
            }


            DataTable dt = new DataTable();
            string sql = @"SELECT New_FtpTransferLogDetailId AS ID,New_FtpTransferLogDetailId,FileTransactionNumber AS VALUE ,fd.new_FileTransactionNumber AS FileTransactionNumber,
                                dbo.fnUTCToLocalTimeForUser(ld.CreatedOn,@SystemUserId) AS CreatedOn,
                                ld.CreatedOn AS CreatedOnUtcTime,ld.CreatedByName,ld.new_FtpReadFileHeaderIdName ,ld.new_TransferIdName,new_ErrorCode,new_ErrorText
	                      FROM vNew_FtpTransferLogDetail (NOLOCK) ld
						  INNER JOIN vNew_FtpReadFileDetail (NOLOCK) fd ON fd.New_FtpReadFileDetailId = ld.new_FtpReadFileDetailId
	                      WHERE ld.new_FtpReadFileHeaderId=@FtpReadFileHeaderId AND ld.DeletionStateCode=0";


            var sort = fptTransferLogDetailGridPanel.ClientSorts();
            if (sort == null)
            { sort = string.Empty; }

            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("FtpTransferLodDetailView");
            var spList = new List<CrmSqlParameter>();
            spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "FtpReadFileHeaderId", Value = ValidationHelper.GetDBGuid(FtpReadFileHeaderId.Value) });
            //spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "SystemUserId", Value = ValidationHelper.GetDBGuid(App.Params.CurrentUser.SystemUserId) });


            Guid ftpTransferLogId = Guid.Empty;

            ftpTransferLogId = ValidationHelper.GetGuid(hdnFtpTransferLogId.Value, Guid.Empty);

            //var sm = (RowSelectionModel)FptTransferLogGridPanel.SelectionModel[0];
            //if (sm != null)
            //{
            //    if (sm.SelectedRows != null)
            //    {
            //        ftpTransferLogId = ValidationHelper.GetGuid(sm.SelectedRows[0]["ID"], Guid.Empty);
            //    }
            //}


            if (ftpTransferLogId != Guid.Empty)
            {
                spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "FtpTransferLogId", Value = ftpTransferLogId });

                sql += " AND new_FtpTransferLogId = @FtpTransferLogId";

            }

            if (chckSuccess.Checked && !chckError.Checked)
            {
                sql += " AND ld.new_TransferId IS NOT NULL";
            }
            else if (!chckSuccess.Checked && chckError.Checked)
            {
                sql += " AND ld.new_TransferId IS NULL";
            }
            else if (!chckSuccess.Checked && !chckError.Checked)
            {
                sql += " AND 1=2";
            }






            var gpc = new GridPanelCreater();
            var cnt = 0;
            var start = fptTransferLogDetailGridPanel.Start();
            var limit = fptTransferLogDetailGridPanel.Limit();
            var t = gpc.GetFilterData(sql, viewqueryid, sort, spList, start, limit, out cnt, out dt);
            fptTransferLogDetailGridPanel.TotalCount = cnt;

            if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            {
                var gpw = new GridPanelView(0, ValidationHelper.GetGuid(ViewFactory.GetViewIdbyUniqueName("FtpTransferLodDetailView").ToString()));
                gpw.Export(dt);
            }



            fptTransferLogDetailGridPanel.DataSource = t;
            fptTransferLogDetailGridPanel.DataBind();

        }

        protected void FptTransferAllPartialLogDetailGridPanelOnLoad(object sender, AjaxEventArgs e)
        {
            var filename = GetReadFileHeaderFileName(ValidationHelper.GetGuid(FtpReadFileHeaderId.Value));

            DataTable dt = new DataTable();
            string sql = @"SELECT New_FtpTransferLogDetailId AS ID,New_FtpTransferLogDetailId,FileTransactionNumber AS VALUE ,fd.new_FileTransactionNumber AS FileTransactionNumber,
                                dbo.fnUTCToLocalTimeForUser(ld.CreatedOn,@SystemUserId) AS CreatedOn,
                                ld.CreatedOn AS CreatedOnUtcTime,ld.CreatedByName,ld.new_FtpReadFileHeaderIdName ,ld.new_TransferIdName,new_ErrorCode,new_ErrorText
	                      FROM vNew_FtpTransferLogDetail (NOLOCK) ld
						  INNER JOIN vNew_FtpReadFileDetail (NOLOCK) fd ON fd.New_FtpReadFileDetailId = ld.new_FtpReadFileDetailId
                          INNER JOIN vNew_FtpReadFileHeader (NOLOCK) rfd ON 
                          rfd.New_FtpReadFileHeaderId = fd.New_FtpReadFileHeaderId
	                      WHERE rfd.FileName like ''+@FileName+'%' AND ld.DeletionStateCode=0";


            var sort = fptTransferLogDetailGridPanel.ClientSorts();
            if (sort == null)
            { sort = string.Empty; }

            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("FtpTransferLodDetailView");
            var spList = new List<CrmSqlParameter>();
            spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "FileName", Value = ValidationHelper.GetString(filename) });

            var gpc = new GridPanelCreater();
            var cnt = 0;
            var start = fptTransferLogDetailGridPanel.Start();
            var limit = fptTransferLogDetailGridPanel.Limit();
            var t = gpc.GetFilterData(sql, viewqueryid, sort, spList, start, limit, out cnt, out dt);
            fptTransferLogDetailGridPanel.TotalCount = cnt;

            if (e.ExtraParams != null && e.ExtraParams["PartialFullList"] != null && ValidationHelper.GetInteger(e.ExtraParams["PartialFullList"]) == 1)
            {
                var gpw = new GridPanelView(0, ValidationHelper.GetGuid(ViewFactory.GetViewIdbyUniqueName("FtpTransferLodDetailView").ToString()));
                gpw.Export(dt);
            }


            fptTransferLogDetailGridPanel.DataSource = t;
            fptTransferLogDetailGridPanel.DataBind();

        }

        protected void FtpReadFileDetailGridPanelOnload(object sender, AjaxEventArgs e)
        {
            var sd = new StaticData();
            sd.AddParameter("New_FtpReadFileHeaderId", DbType.Guid, ValidationHelper.GetDBGuid(FtpReadFileHeaderId.Value));
            var sortDb = ValidationHelper.GetInteger(sd.ExecuteScalar(@"
                select h.new_LineOrderBy from vNew_FtpReadFileHeader rh
                inner join vNew_FtpFileHeader h on rh.new_FtpFileHeader = h.New_FtpFileHeaderId
                where 1=1
                and rh.DeletionStateCode = 0
                and h.DeletionStateCode = 0
                and rh.New_FtpReadFileHeaderId = @New_FtpReadFileHeaderId
            "), 0);

            string where = "";
            if (_ua.FtpDownload && !_ua.FtpConfirm && !operationWaitConfirm)
                where = " and isnull(h.new_Approved,0) = 3";
            if (_ua.FtpDownload && !_ua.FtpConfirm && operationWaitConfirm)
                where = " and 1 = case when h.statuscode = 2 and isnull(h.new_Approved,0) = 1 then 1 when h.statuscode <> 2 and isnull(h.new_Approved,0) = 0 then 0 end";
            if (!_ua.FtpDownload && _ua.FtpConfirm && operationWaitConfirm)
                where = " and isnull(h.new_Approved,0) = 1";
            if (_ua.FtpDownload && _ua.FtpConfirm && operationWaitConfirm)
                where = " and isnull(h.new_Approved,0) in (0,1)";
            var sort = "";
            if (sortDb == 0)
            {
                sort = "[{\"field\":\"new_FileLineAmount\",\"direction\":\"Asc\"}]";
            }
            if (sortDb == 1)
            {
                sort = "[{\"field\":\"new_FileLineAmount\",\"direction\":\"Desc\"}]";
            }
            if (sortDb == 2)
            {
                sort = "[{\"field\":\"LineNumber\",\"direction\":\"Asc\"}]";
            }
            var strSql = string.Format(@" 
select Mt.LineNumber AS VALUE ,Mt.New_FtpReadFileDetailId AS ID , 
Mt.New_FtpReadFileDetailId,
Mt.LineNumber,
Mt.CreatedOn,
Mt.CreatedOnUtcTime,
Mt.ModifiedOn,
Mt.ModifiedOnUtcTime,
Mt.CreatedBy,
Mt.CreatedByName,
Mt.ModifiedBy,
Mt.ModifiedByName,
Mt.OwningUser,
Mt.OwningUserName,
Mt.OwningBusinessUnit,
Mt.OwningBusinessUnitName,
Mt.DeletionStateCode,
Mt.statuscode,
Mt.statuscodeName,
Mt.new_FtpReadFileHeaderId,
Mt.new_FtpReadFileHeaderIdName,
Mt.new_FileTransactionNumber,
Mt.new_FileLineTransactionDate,
Mt.new_FileLineTransactionDateUtcTime,
case 
    when f.new_FtpType IN( 1,4,5,6)   then new_FileLineAmount
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,4)
end new_FileLineAmount,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_FileLineAmountCurrency
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,5)
end new_FileLineAmountCurrency,
Mt.new_FileLineBranch,
Mt.new_FileLineSenderFirstName,
Mt.new_FileLineSenderLastName,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_FileLineSenderCode
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,17)
end new_FileLineSenderCode,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_FileLineSenderId
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,19)
end new_FileLineSenderId,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_FileLineSourceTransactionType
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,10)
end new_FileLineSourceTransactionType,
Mt.new_FileLineCorrespondingBranchCity,
Mt.new_FileLineCorrespondingBranchName,
Mt.new_FileLineCorrespondingBranchCode,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_FileLineBank
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,20)
end new_FileLineBank,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_FileLineBankBranch
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,21)
end new_FileLineBankBranch,
Mt.new_FileLineRecipientName,
Mt.new_FileLineRecipientLastName,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_FileLineRecipientAccountNumber
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,8)
end new_FileLineRecipientAccountNumber,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_FileLineRecipientRecipientAddress
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,9)
end new_FileLineRecipientRecipientAddress,
Mt.new_FileLineRecipientPhone,
Mt.new_FileLineRecipientCode,
Mt.new_FileLineDescription,
case 
    when f.new_FtpType IN( 1,4,5,6,8,9,10) then new_TransferId 
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,0)
end new_TransferId,
case 
    when f.new_FtpType IN( 1,4,5,6,8,9,10) then new_TransferIdName
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,1)
end new_TransferIdName,
Mt.new_PaymentId,
Mt.new_PaymentIdName,
case 
    when f.new_FtpType IN( 1,4,5,6,9,10) then new_FileLineSenderFullName
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,2)
end new_FileLineSenderFullName,
case 
    when f.new_FtpType IN( 1,4,5,6,9,10) then new_FileLineRecipientFullName
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,3)
end new_FileLineRecipientFullName,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_FileLineSourceTransactionTypeCode
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,18)
end new_FileLineSourceTransactionTypeCode,
Mt.new_FileLineRecipientCountryCode,
isnull(dbo.fnGetFtpErrorCode(@SystemUserId,new_ConfirmErrorCode),new_ConfirmErrorLogText) new_ConfirmErrorLogText,
Mt.new_ReceivedExpenseAmount,
Mt.new_ReceivedExpenseAmountCurrency,
Mt.new_ExpenseCurrency_RateType,
Mt.new_ReceivedExpenseAmountCurrencyParity,
Mt.new_FileLineConfirmStatus,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_FileLineRecipientIBAN
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,6)
end new_FileLineRecipientIBAN,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_FileLineRecipientCardNumber
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,7)
end new_FileLineRecipientCardNumber,
Mt.new_FileLineEftPaymentMethod,
Mt.new_ConfirmErrorCode,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_SenderCountry
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,11)
end new_SenderCountry,
Mt.new_FileLineRecipientPhoneArea,
Mt.new_FileLineRecipientPhoneCountryCode,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_FileLineSenderAddress
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,12)
end new_FileLineSenderAddress,
Mt.new_ExtCode1,
Mt.new_ExtCode2,
Mt.new_ExtCode3,
Mt.new_ExtCode4,
Mt.new_ExtCode5,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_MuhasebeTutar
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,13)
end new_MuhasebeTutar,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_MuhasebeTutarCurrency
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,14)
end new_MuhasebeTutarCurrency,
Mt.new_MuhasebeTutarCurrencyParity,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_CommissionAmount
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,15)
end new_CommissionAmount,
case 
    when f.new_FtpType IN( 1,4,5,6) then new_CommissionAmountCurrency
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,16)
end new_CommissionAmountCurrency,
Mt.new_CommissionAmountCurrencyParity,
Mt.new_UserDescription,
Mt.new_UserNote,
Mt.new_RecipientIdentificatonCardTypeNo,
Mt.new_RecipientIdentificatonCardType,
new_FileLineRecipientCountryName
from   dbo.tvNew_FtpReadFileDetail(@SystemUserId) as Mt 
inner join vNew_FtpReadFileHeader hf on hf.New_FtpReadFileHeaderId = mt.new_FtpReadFileHeaderId
inner join vNew_FtpFileHeader f on f.New_FtpFileHeaderId = hf.new_FtpFileHeader
                    Where mt.new_FtpReadFileHeaderId=@FtpReadFileHeaderId 
and exists (select * from vNew_FtpReadFileHeader h where DeletionStateCode = 0 and h.New_FtpReadFileHeaderId = mt.new_FtpReadFileHeaderId {0})
", where);

            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("READE_FILE_DETAIL");
            var spList = new List<CrmSqlParameter>
                             {
                                 new CrmSqlParameter
                                     {
                                         Dbtype = DbType.Guid,
                                         Paramname = "FtpReadFileHeaderId",
                                         Value = ValidationHelper.GetGuid(FtpReadFileHeaderId.Value)
                                     }
                             };
            var gpc = new GridPanelCreater();
            int cnt;
            var start = FtpReadFileDetailGridPanel.Start();
            var limit = FtpReadFileDetailGridPanel.Limit();
            var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
            FtpReadFileDetailGridPanel.TotalCount = cnt;

            if (!_ua.ReferenceCanBeSeen)
            {
                List<Dictionary<string, object>> maskedList = new List<Dictionary<string, object>>();

                foreach (var item in t)
                {
                    string tu_Ref = item.Where(x => x.Key.Equals("new_TransferIdName")).Select(x => x.Value).FirstOrDefault().ToString();
                    var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref); //string.Concat(tu_Ref.Substring(0, 3), "".PadRight(8, 'X'));

                    item["new_TransferIdName"] = masked_tu_ref;
                    if (!string.IsNullOrEmpty(item["new_PaymentIdName"].ToString()))
                        item["new_PaymentIdName"] = masked_tu_ref;

                    maskedList.Add(item);
                }

                FtpReadFileDetailGridPanel.DataSource = maskedList;
                FtpReadFileDetailGridPanel.DataBind();
            }
            else
            {
                FtpReadFileDetailGridPanel.DataSource = t;
                FtpReadFileDetailGridPanel.DataBind();
            }

            var sm = (RowSelectionModel)GridFtpRead.SelectionModel[0];
            if (sm != null)
            {
                if (sm.SelectedRows != null)
                {
                    var fType = (EFtpCorpType)(ValidationHelper.GetInteger(sm.SelectedRows[0]["FtpType"], 1) - 1);

                    if (fType != EFtpCorpType.NOTE)
                    {
                        QScript(_ua.FtpConfirm && _ua.FtpUseButtons ? "btnTransfer.show();" : "btnTransfer.hide();");
                        QScript("NoteEdit.hide();");
                    }
                    else
                    {
                        QScript(_ua.FtpUseButtons ? "NoteEdit.show();" : "NoteEdit.hide();");
                        QScript("btnTransfer.hide();");
                    }
                }
            }

            if (!string.IsNullOrEmpty(FtpReadFileHeaderId.Value))
            {
                var approvalCannotUpdate = ApprovalFactory.CheckApprovalByRecordId(TuEntityEnum.New_FtpReadFileHeader.GetHashCode(),
                   ValidationHelper.GetGuid(FtpReadFileHeaderId.Value));

                if (approvalCannotUpdate)
                {
                    btnUpdateStatus.Hidden = true;
                    QScript("btnUpdateStatus.hide();");
                }
                else
                {
                    btnUpdateStatus.Hidden = false;
                    QScript("btnUpdateStatus.show();");
                }
            }



            if (_ua.FtpDownload && _ua.FtpUseButtons && operationWaitConfirm)
            {
                QScript("btnApproved.show();");
            }
            else
            {
                QScript("btnApproved.hide();");
            }
        }

        private bool IsConfirmed()
        {
            const string sql = "select new_IsConfirmed from vNew_FtpFileHeader Where New_FtpFileHeaderId=@New_FtpFileHeaderId";
            var sd = new StaticData();
            sd.AddParameter("New_FtpFileHeaderId", DbType.Guid, ValidationHelper.GetGuid(CrmComboComp2.Value));
            var ret = ValidationHelper.GetBoolean(sd.ExecuteScalar(sql));
            return ret;

        }

        protected void btnAkbFromCorp(object sender, AjaxEventArgs e)
        {
            try
            {
                new_UserNote.Clear();
                var sm = (RowSelectionModel)FtpReadFileDetailGridPanel.SelectionModel[0];
                if (sm != null)
                {
                    if (sm.SelectedRows != null)
                    {
                        new_UserNote.SetValue(sm.SelectedRows[0]["new_UserNote"]);
                        Window1.Show();

                    }
                }
            }
            catch (Exception ex)
            {
                e.Success = false;
                e.Message = ex.Message;
            }
        }

        protected void btnNoteEdit(object sender, AjaxEventArgs e)
        {
            try
            {
                new_UserNote.Clear();
                var sm = (RowSelectionModel)FtpReadFileDetailGridPanel.SelectionModel[0];
                if (sm != null)
                {
                    if (sm.SelectedRows != null)
                    {
                        new_UserNote.SetValue(sm.SelectedRows[0]["new_UserNote"]);
                        Window1.Show();

                    }
                }
            }
            catch (Exception ex)
            {
                e.Success = false;
                e.Message = ex.Message;
            }
        }

        protected void RowSelect(object sender, AjaxEventArgs e)
        {
            try
            {
                var sm = (RowSelectionModel)GridFtpRead.SelectionModel[0];
                if (sm != null)
                {
                    if (sm.SelectedRows != null)
                    {
                        FtpReadFileHeaderId.SetIValue(sm.SelectedRows[0]["FtpReadFileHeaderId"]);
                        FtpReadFileDetail.Show();
                        FtpReadFileDetailGridPanel.Reload();
                        var fType = (EFtpCorpType)(ValidationHelper.GetInteger(sm.SelectedRows[0]["FtpType"], 1) - 1);

                        switch (fType)
                        {
                            case EFtpCorpType.NOTE:
                                QScript("NoteEdit.show();");
                                break;

                        }

                    }
                }

            }
            catch (Exception ex)
            {
                e.Success = false;
                e.Message = ex.Message;
            }
        }

        protected void FtpTransferLogSelect(object sender, AjaxEventArgs e)
        {
            var sm = (RowSelectionModel)FptTransferLogGridPanel.SelectionModel[0];
            if (sm != null)
            {
                if (sm.SelectedRows != null)
                {
                    Guid ftpTransferLogId = ValidationHelper.GetGuid(sm.SelectedRows[0]["ID"], Guid.Empty);

                    hdnFtpTransferLogId.SetValue(ftpTransferLogId);
                    hdnFtpTransferLogId.SetIValue(ftpTransferLogId);
                    hdnFtpTransferLogId.Value = ValidationHelper.GetString(ftpTransferLogId);

                    fptTransferLogDetailGridPanel.Reload();
                }
            }



        }

        protected void btnUpdateOnEvent(object sender, AjaxEventArgs e)
        {
            try
            {
                var sm = (RowSelectionModel)FtpReadFileDetailGridPanel.SelectionModel[0];
                if (sm != null)
                {
                    if (sm.SelectedRows != null)
                    {
                        var sd = new StaticData();
                        sd.AddParameter("new_UserNote", DbType.AnsiString, new_UserNote.Value);
                        sd.AddParameter("New_FtpReadFileDetailId", DbType.Guid,
                                        ValidationHelper.GetGuid(sm.SelectedRows[0]["New_FtpReadFileDetailId"]));
                        sd.ExecuteNonQuery(
                            @"update vnew_ftpreadfiledetail set new_UserNote = @new_UserNote where New_FtpReadFileDetailId = @New_FtpReadFileDetailId");

                        var tf = new FtpTransferFactory();
                        var transId = tf.GetTransferId(ValidationHelper.GetGuid(sm.SelectedRows[0]["New_FtpReadFileDetailId"]));
                        if (transId != Guid.Empty)
                        {
                            sd.ClearParameters();
                            sd.AddParameter("FtpReadFileDetailId", DbType.Guid,
                                            ValidationHelper.GetGuid(sm.SelectedRows[0]["New_FtpReadFileDetailId"]));
                            sd.AddParameter("new_TransferId", DbType.Guid, transId);
                            sd.ExecuteNonQuery(@"
                                update vNew_FtpReadFileDetail set new_TransferId = @new_TransferId
		                        WHERE 1=1
	                        AND New_FtpReadFileDetailId = @FtpReadFileDetailId
                        ");
                        }
                        FtpReadFileDetailGridPanel.Reload();
                    }
                }
            }
            catch (Exception ex)
            {
                e.Success = false;
                e.Message = ex.Message;
            }
        }

        private string GetReadFileHeaderFileName(Guid ftpReadFileHeaderId)
        {
            var sd = new StaticData();
            sd.AddParameter("ftpReadFileHeaderId", DbType.Guid, ftpReadFileHeaderId);

            var dt = sd.ReturnDataset(@"SELECT FileName FROM vNew_FtpReadFileHeader WHERE New_FtpReadFileHeaderId = @ftpReadFileHeaderId").Tables[0];

            if (dt.Rows.Count > 0)
                return Path.GetFileNameWithoutExtension(ValidationHelper.GetString(dt.Rows[0]["FileName"]));
            else return string.Empty;
        }

    }
}