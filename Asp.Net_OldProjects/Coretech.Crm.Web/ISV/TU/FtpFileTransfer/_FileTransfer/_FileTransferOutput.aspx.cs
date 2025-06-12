using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.FtpTransfer;
using System.Web;
using System.IO;
using TuFactory.TuUser;
using TuFactory.Object.User;
using Coretech.Crm.Factory;

public partial class FtpFileTransfer__FileTransfer_FileTransferOutput : BasePage
{
    private TuUserFactory uf = new TuUserFactory();
    TuUserApproval _ua = new TuUserApproval();

    protected void Translate()
    {
        CreateFile.Text = CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_DOSYA_OLUSTUR");
        Button1.Text = CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_DOSYA_LISTESI");
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            _ua = uf.GetApproval(App.Params.CurrentUser.SystemUserId);
            Translate();
            CreateViewGrid();
            QScript(_ua.FtpUseButtons ? "CreateFile.show();" : "CreateFile.hide();");
        }
    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("FTPWRITELIST", GridPanel1);
        var strSelected = ViewFactory.GetViewIdbyUniqueName("FTPWRITELIST").ToString();
        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
    }

    protected void GridPanelOnload(object sender, AjaxEventArgs e)
    {
        #region sql string
        var strSql = @"
            select 
t.FileName AS VALUE ,t.New_FtpWriteFileHeaderId AS ID ,h1.new_CorporationIdName
,t.New_FtpWriteFileHeaderId
,t.FileName
,t.CreatedOn
,t.CreatedOnUtcTime
,t.ModifiedOn
,t.ModifiedOnUtcTime
,t.CreatedBy
,t.CreatedByName
,t.ModifiedBy
,t.ModifiedByName
,t.OwningUser
,t.OwningUserName
,t.OwningBusinessUnit
,t.OwningBusinessUnitName
,t.DeletionStateCode
,t.statuscode
,t.statuscodeName
,t.ParentNew_FtpWriteFileHeaderId
,t.ParentNew_FtpWriteFileHeaderIdName
,t.new_FilePath
,t.new_FtpReadFileHeaderId
,t.new_FtpReadFileHeaderIdName
,t.new_FtpPath
,t.new_FtpAddress
            from   dbo.tvNew_FtpWriteFileHeader(@SystemUserId) as t 
            inner join vnew_FtpReadFileHeader h on h.New_FtpReadFileHeaderId = t.new_FtpReadFileHeaderId
            inner join vnew_FtpFileHeader h1 on h1.New_FtpFileHeaderId = h.new_FtpFileHeader

where 1=1
and (@BeginDate is null or t.CreatedOnUtcTime >=  dbo.fnLocalTimeToUTCForUser(@BeginDate,@SystemUserId) )
and (@EndDate is null or t.CreatedOnUtcTime <=  dbo.fnLocalTimeToUTCForUser(@EndDate+1,@SystemUserId) )
and (@Corp is null or h1.new_CorporationId= @Corp)
and (@Ftp is null or h1.New_FtpFileHeaderId= @Ftp) 
and (@OutputFtpFileHeaderId is null or h1.new_OutputFtpFileHeaderId=@OutputFtpFileHeaderId)
        ";

        var strPaySql = @"select distinct
t.FileName AS VALUE ,t.New_FtpWriteFileHeaderId AS ID ,h1.new_CorporationIdName
,t.New_FtpWriteFileHeaderId
,t.FileName
,t.CreatedOn
,t.CreatedOnUtcTime
,t.ModifiedOn
,t.ModifiedOnUtcTime
,t.CreatedBy
,t.CreatedByName
,t.ModifiedBy
,t.ModifiedByName
,t.OwningUser
,t.OwningUserName
,t.OwningBusinessUnit
,t.OwningBusinessUnitName
,t.DeletionStateCode
,t.statuscode
,t.statuscodeName
,t.ParentNew_FtpWriteFileHeaderId
,t.ParentNew_FtpWriteFileHeaderIdName
,t.new_FilePath
,t.new_FtpReadFileHeaderId
,t.new_FtpReadFileHeaderIdName
,t.new_FtpPath
,t.new_FtpAddress
            from   dbo.tvNew_FtpWriteFileHeader(@SystemUserId) as t 
            inner join vnew_FtpReadFileHeader h on h.New_FtpReadFileHeaderId = t.new_FtpReadFileHeaderId
            inner join vnew_FtpFileHeader h1 on h1.New_FtpFileHeaderId = h.new_FtpFileHeader
            inner join vNew_FtpReadFileDetail fd on fd.new_FtpReadFileHeaderId=h.New_FtpReadFileHeaderId
            inner join vNew_Transfer tr on tr.New_TransferId=fd.new_TransferId
            inner join tvNew_Payment(@SystemUserId) p on p.new_TransferID=tr.New_TransferId

where 1=1 and tr.DeletionStateCode=0 and p.DeletionStateCode=0
--and (@BeginDate is null or t.CreatedOnUtcTime >=  dbo.fnLocalTimeToUTCForUser(@BeginDate,@SystemUserId) )
--and (@EndDate is null or t.CreatedOnUtcTime <=  dbo.fnLocalTimeToUTCForUser(@EndDate+1,@SystemUserId) )
and (@BeginDate is null or p.CreatedOnUtcTime >=  dbo.fnLocalTimeToUTCForUser(@BeginDate,@SystemUserId) )
and (@EndDate is null or p.CreatedOnUtcTime <=  dbo.fnLocalTimeToUTCForUser(@EndDate+1,@SystemUserId) )
and (@Corp is null or h1.new_CorporationId= @Corp)
and (@Ftp is null or h1.New_FtpFileHeaderId= @Ftp)
and (@OutputFtpFileHeaderId is null or h1.new_OutputFtpFileHeaderId=@OutputFtpFileHeaderId)";
        #endregion


        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("FTPWRITELIST");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = GridPanel1.Start();
        var limit = GridPanel1.Limit();
        var spList = new List<CrmSqlParameter>
                             {
                                 new CrmSqlParameter
                                     {
                                         Dbtype = DbType.DateTime,
                                         Paramname = "BeginDate",
                                         Value = ValidationHelper.GetDate(new_Date1.Value)
                                     },
                                     new CrmSqlParameter
                                     {
                                         Dbtype = DbType.DateTime,
                                         Paramname = "EndDate",
                                         Value = ValidationHelper.GetDate(new_Date2.Value)
                                     },
                                     new CrmSqlParameter
                                     {
                                         Dbtype = DbType.Guid,
                                         Paramname = "Corp",
                                         Value = ValidationHelper.GetGuid(CrmComboComp1.Value)
                                     },
                                     new CrmSqlParameter
                                     {
                                         Dbtype = DbType.Guid,
                                         Paramname = "Ftp",
                                         Value = ValidationHelper.GetGuid(CrmComboComp2.Value)
                                     },
                                     new CrmSqlParameter
                                     {
                                         Dbtype = DbType.Guid,
                                         Paramname = "OutputFtpFileHeaderId",
                                         Value = ValidationHelper.GetGuid(FtpFileOutputHeaderId.Value)
                                     }
                             };

        const string sort = "[{\"field\":\"CreatedOn\",\"direction\":\"Desc\"}]";


        if (!new_PayDate1.IsEmpty || !new_PayDate2.IsEmpty)
        {
            var t = gpc.GetFilterData(strPaySql, viewqueryid, sort, spList, start, limit, out cnt);
            GridPanel1.TotalCount = cnt;
            GridPanel1.DataSource = t;
            GridPanel1.DataBind();
        }
        else
        {
            var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
            GridPanel1.TotalCount = cnt;
            GridPanel1.DataSource = t;
            GridPanel1.DataBind();
        }


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
    protected void CreateFileOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            if (
                ((!new_Date1.IsEmpty && !new_Date2.IsEmpty && CrmComboComp3.IsEmpty) || (!new_PayDate1.IsEmpty && !new_PayDate1.IsEmpty && CrmComboComp3.IsEmpty) || (new_Date1.IsEmpty && new_Date2.IsEmpty && !CrmComboComp3.IsEmpty)) &&
                !FtpFileOutputHeaderId.IsEmpty && !CrmComboComp2.IsEmpty)
            {
                FtpFileUploadManager ftpFileUploadManager = new FtpFileUploadManager();

                FtpReadFileHeaderManager ftpReadFileHeaderManager = new FtpReadFileHeaderManager();
                
                var lst = new List<Guid>();
                if (!CrmComboComp3.IsEmpty)
                {
                    lst = ftpReadFileHeaderManager.GetFtpReadFileHeaderList(null, null, ValidationHelper.GetGuid(CrmComboComp2.Value), ValidationHelper.GetGuid(CrmComboComp3.Value));
                }
                else
                {
                    if (!new_PayDate1.IsEmpty || !new_PayDate2.IsEmpty)
                    {
                        lst = ftpReadFileHeaderManager.GetFtpReadFileHeaderListByPaydate(new_PayDate1.Value, new_PayDate2.Value, ValidationHelper.GetGuid(CrmComboComp2.Value), Guid.Empty);
                    }
                    else
                    {
                        lst = ftpReadFileHeaderManager.GetFtpReadFileHeaderList(new_Date1.Value, new_Date2.Value, ValidationHelper.GetGuid(CrmComboComp2.Value), Guid.Empty);
                    }
                }
                //var lst = !CrmComboComp3.IsEmpty ? ftp.GetFtpReadFileHeaderList(null, null, ValidationHelper.GetGuid(CrmComboComp2.Value), ValidationHelper.GetGuid(CrmComboComp3.Value)) : ftp.GetFtpReadFileHeaderList(new_Date1.Value, new_Date2.Value, ValidationHelper.GetGuid(CrmComboComp2.Value), Guid.Empty);

                var ft = new FtpTransferFactory();
                var sb = new StringBuilder();
                var sbFile = new StringBuilder();
                var fileName = new UploadFileInfo();
                List<Guid> ftpReadFileHeaderIdList = new List<Guid>();
                foreach (var o in lst)
                {
                    sb.Clear();
                    string result;
                    if (!new_PayDate1.IsEmpty || !new_PayDate2.IsEmpty)
                    {
                        result = ft.FtpMapDetailList(ValidationHelper.GetGuid(o), ValidationHelper.GetGuid(FtpFileOutputHeaderId.Value), new_PayDate1.Value, new_PayDate2.Value);
                    }
                    else
                    {
                        result = ft.FtpMapDetailList(ValidationHelper.GetGuid(o), ValidationHelper.GetGuid(FtpFileOutputHeaderId.Value), null, null);
                    }
                    if (result != string.Empty)
                    {
                        //sb.AppendLine(ft.FtpMapDetailList(ValidationHelper.GetGuid(o), ValidationHelper.GetGuid(FtpFileOutputHeaderId.Value)));
                        //sb.AppendLine(result);
                        ftpReadFileHeaderIdList.Add(ValidationHelper.GetGuid(o));
                        sbFile.Append(result);
                    }

                    //if (!string.IsNullOrEmpty(sb.ToString()))
                    //{
                    //    fileName = ftp.UploadFtpFile(ValidationHelper.GetGuid(o), sb.ToString(), ValidationHelper.GetGuid(FtpFileOutputHeaderId.Value));
                    //}
                    //else
                    //{
                    //    new MessageBox(CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_FILE_NOT_FOUND"));
                    //    return;
                    //}

                }

                if (!string.IsNullOrEmpty(sbFile.ToString()) && ftpReadFileHeaderIdList.Count > 0)
                {
                    fileName = ftpFileUploadManager.UploadFtpFile(ftpReadFileHeaderIdList, sbFile.ToString(), ValidationHelper.GetGuid(FtpFileOutputHeaderId.Value));
                }
                else
                {
                    new MessageBox(CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_FILE_NOT_FOUND"));
                    return;
                }

                var byteArray = Encoding.UTF8.GetBytes(sbFile.ToString());
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
            else
            {
                if (CrmComboComp3.IsEmpty)
                {
                    if (new_Date1.IsEmpty)
                    {
                        new MessageBox(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_Date1.FieldLabel));
                        new_Date1.Focus();
                        return;
                    }
                    if (new_Date2.IsEmpty)
                    {
                        new MessageBox(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), new_Date2.FieldLabel));
                        new_Date2.Focus();
                        return;
                    }
                }
                if (CrmComboComp2.IsEmpty)
                {
                    new MessageBox(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), CrmComboComp2.FieldLabel));
                    CrmComboComp2.Focus();
                    return;
                }
                if (FtpFileOutputHeaderId.IsEmpty)
                {
                    new MessageBox(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), FtpFileOutputHeaderId.FieldLabel));
                    FtpFileOutputHeaderId.Focus();
                    return;
                }
            }
        }
        catch (Exception ex)
        {
            e.Success = false;
            e.Message = ex.Message;
            LogUtil.WriteException(ex);
        }
    }
}