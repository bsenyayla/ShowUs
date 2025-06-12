using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Criteria;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.FtpTransfer;
using System.Web;
using System.IO;
using TuFactory.Object;
using TuFactory.Data;
using Coretech.Crm.Factory;
using TuFactory.TuUser;
using TuFactory.Object.User;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;

public partial class FtpFileTransfer__FileTransfer_FTPSendTransfer : BasePage
{
    private TuUserFactory uf = new TuUserFactory();
    TuUserApproval _ua = new TuUserApproval();

    protected void Translate()
    {
        CreateFile.Text = CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_DOSYA_OLUSTUR");
        Button1.Text = CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_CRM_DOSYA_LISTESI");
        btnShowWindow.Text = CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_SHOW_TRANSFER_LIST");
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            _ua = uf.GetApproval(App.Params.CurrentUser.SystemUserId);

            Translate();
            CreateViewGrid();
            PageSessionId.Value = GuidHelper.New().ToString();

            QScript(_ua.FtpUseButtons ? "pnlRecords.show();" : "pnlRecords.hide();");
            QScript(_ua.FtpUseButtons ? "BtnDelete.show();" : "BtnDelete.hide();");
        }
    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("FTPWRITELIST", GridPanel1);
        var strSelected = ViewFactory.GetViewIdbyUniqueName("FTPWRITELIST").ToString();

        gpc.CreateViewGrid("PROCESSMONITORING", GridPanelMonitoring);

        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));


        var gpc2 = new GridPanelCreater();
        gpc2.CreateViewGrid("READE_FILE_DETAIL", FtpReadFileDetailGridPanel);
        var strSelected2 = ViewFactory.GetViewIdbyUniqueName("READE_FILE_DETAIL").ToString();
        if (string.IsNullOrEmpty(strSelected2))
            return;
        var gpw2 = new GridPanelView(0, ValidationHelper.GetGuid(strSelected2));
    }

    // bu method FtpWriteFileHeader yerine FtpReadFileHeader olmak üzere değişti
    protected void GridPanelOnload(object sender, AjaxEventArgs e)
    {

        var strSql = @"
            select 
t.FileName AS VALUE ,t.New_FtpReadFileHeaderId AS ID ,h1.new_CorporationIdName
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
            --inner join vnew_FtpReadFileHeader h on h.New_FtpReadFileHeaderId = t.new_FtpReadFileHeaderId
            inner join vnew_FtpFileHeader h1 on h1.New_FtpFileHeaderId = t.new_FtpFileHeaderId
where 1=1 and  h1.new_FtpType in (4,7,9,1) --h1.new_FtpType = 4
and (@Corp is null or h1.new_CorporationId= @Corp)
and (@Ftp is null or h1.New_FtpFileHeaderId= @Ftp)
        ";



        //        var strSql = @"
        //            select 
        //                t.FileName AS VALUE ,t.New_FtpReadFileHeaderId AS ID ,h1.new_CorporationIdName
        //                ,t.New_FtpReadFileHeaderId
        //                ,t.FileName
        //	            ,t.CreatedOn
        //	            ,t.CreatedOnUtcTime
        //	            ,t.ModifiedOn
        //	            ,t.ModifiedOnUtcTime
        //	            ,t.CreatedBy
        //	            ,t.CreatedByName
        //	            ,t.ModifiedBy
        //	            ,t.ModifiedByName
        //	            ,t.OwningUser
        //	            ,t.OwningUserName
        //	            ,t.OwningBusinessUnit
        //	            ,t.OwningBusinessUnitName
        //	            ,t.DeletionStateCode
        //	            ,t.statuscode
        //	            ,t.statuscodeName
        //
        //	            ,t.new_FilePath
        //                    from   dbo.tvNew_FtpReadFileHeader(@SystemUserId) as t 
        //                    --inner join vnew_FtpReadFileHeader h on h.New_FtpReadFileHeaderId = t.new_FtpReadFileHeaderId
        //                    inner join vnew_FtpFileHeader h1 on h1.New_FtpFileHeaderId = t.new_FtpFileHeader
        //                where 1=1 and h1.new_FtpType = 4
        //                            and (@Corp is null or h1.new_CorporationId= @Corp)
        //                            and (@Ftp is null or h1.New_FtpFileHeaderId= @Ftp)
        //                    ";

        // ftp dosya seçimi combosundaki iptal seçildiğinde boş gelmesine burda breakpointte sql e bakıcam !!!

        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("FTPWRITELIST"); //  ViewFactory.GetViewIdbyUniqueName("FTPWRITELIST");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = GridPanel1.Start();
        var limit = GridPanel1.Limit();
        var spList = new List<CrmSqlParameter>
                             {
                                 
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
                                     }
                             };

        const string sort = "[{\"field\":\"CreatedOn\",\"direction\":\"Desc\"}]";
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        GridPanel1.TotalCount = cnt;

        GridPanel1.DataSource = t;
        GridPanel1.DataBind();
    }

    protected void RowSelect(object sender, AjaxEventArgs e)
    {
        try
        {
            var sm = (RowSelectionModel)GridPanel1.SelectionModel[0];
            if (sm != null)
            {
                if (sm.SelectedRows != null)
                {
                    FtpReadFileHeaderId.SetIValue(sm.SelectedRows[0]["new_FtpReadFileHeaderId"]);
                    FtpReadFileDetailPopup.Show();
                    //FtpReadFileDetailGridPanelOnload(null, null);
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

    // popup gridin onloadı
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
        /*
        if (_ua.FtpDownload && !_ua.FtpConfirm && !operationWaitConfirm)
            where = " and isnull(h.new_Approved,0) = 3";
        if (_ua.FtpDownload && !_ua.FtpConfirm && operationWaitConfirm)
            where = " and 1 = case when h.statuscode = 2 and isnull(h.new_Approved,0) = 1 then 1 when h.statuscode <> 2 and isnull(h.new_Approved,0) = 0 then 0 end";
        if (!_ua.FtpDownload && _ua.FtpConfirm && operationWaitConfirm)
            where = " and isnull(h.new_Approved,0) = 1";
        if (_ua.FtpDownload && _ua.FtpConfirm && operationWaitConfirm)
            where = " and isnull(h.new_Approved,0) in (0,1)";
         * */
        var sort = "";

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
Mt.new_CalculatedAmountForExternalBanks,
Mt.new_ExchangeRateFromExternalBanks,
new_PaymentCurrencyCodeForExternalBanks,
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
    when f.new_FtpType IN( 1,4,5,6,8,9) then new_TransferId 
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,0)
end new_TransferId,
case 
    when f.new_FtpType IN( 1,4,5,6,8,9) then new_TransferIdName
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,1)
end new_TransferIdName,
Mt.new_PaymentId,
Mt.new_PaymentIdName,
case 
    when f.new_FtpType IN( 1,4,5,6,9) then new_FileLineSenderFullName
    when f.new_FtpType IN( 2,3) then dbo.fnGetFtpType(Mt.new_FileTransactionNumber,2)
end new_FileLineSenderFullName,
case 
    when f.new_FtpType IN( 1,4,5,6,9) then new_FileLineRecipientFullName
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
Mt.new_UserNote
from   dbo.tvNew_FtpReadFileDetail(@SystemUserId) as Mt 
inner join vNew_FtpReadFileHeader hf on hf.New_FtpReadFileHeaderId = mt.new_FtpReadFileHeaderId
inner join vNew_FtpFileHeader f on f.New_FtpFileHeaderId = hf.new_FtpFileHeader
                    Where mt.new_FtpReadFileHeaderId=@FtpReadFileHeaderId 
and exists (select * from vNew_FtpReadFileHeader h where DeletionStateCode = 0 and h.New_FtpReadFileHeaderId = mt.new_FtpReadFileHeaderId {0})
", where);

        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("READE_FILE_DETAIL"); //FTP_READ_FILE_DETAIL_2
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

        FtpReadFileDetailGridPanel.DataSource = t;
        FtpReadFileDetailGridPanel.DataBind();


        /*
        var sm = (RowSelectionModel)GridFtpRead.SelectionModel[0];
        if (sm != null)
        {
            if (sm.SelectedRows != null)
            {
                var fType =
                    (FtpTransferFactory.EFtpCorpType)
                    (ValidationHelper.GetInteger(sm.SelectedRows[0]["FtpType"], 1) - 1);

                if (fType != FtpTransferFactory.EFtpCorpType.NOTE)
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


        if (_ua.FtpDownload && _ua.FtpUseButtons && operationWaitConfirm)
        {
            QScript("btnApproved.show();");
        }
        else
        {
            QScript("btnApproved.hide();");
        }
         * */
    }

    protected void BtnRemoveClick(object sender, AjaxEventArgs e)
    {
        var stepId = ValidationHelper.GetGuid(PageSessionId.Value);
        var mylist = new List<Guid>();

        var selmod = GridPanelMonitoring.SelectionModel[0] as CheckSelectionModel;
        foreach (var mode in selmod.SelectedRows)
        {
            mylist.Add(ValidationHelper.GetGuid(mode.ID));
        }

        if (mylist.Count > 0)
            try
            {
                FtpTransferFactory.RemoveCriteria(stepId, mylist);
                GridPanelMonitoring.Reload();
            }
            catch (TuException tu)
            {
                tu.Show();

            }
            catch (Exception)
            {
                throw;
            }

    }

    protected void btnAddClick(object sender, AjaxEventArgs e)
    {
        var df = new DynamicFactory(ERunInUser.SystemAdmin);
        var de = df.Retrieve(TuEntityEnum.New_FtpFileHeader.GetHashCode(),
                                       ValidationHelper.GetGuid(CrmComboComp2.Value), new string[] { "new_CriteriaGroupsId", "New_FtpFileHeaderId" });
        var criteriaGroupsId = new Guid();
        var stepId = ValidationHelper.GetGuid(PageSessionId.Value);
        var objectId = TuEntityEnum.New_Transfer.GetHashCode();
        Guid resultId;

        if (de.GetLookupValue("new_CriteriaGroupsId") != Guid.Empty)
        {
            criteriaGroupsId = de.GetLookupValue("new_CriteriaGroupsId");
        }

        if (ValidationHelper.GetGuid(New_TransferId.Value) == Guid.Empty)
        {
            new MessageBox(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), New_TransferId.FieldLabel));
            New_TransferId.Focus();
            return;
        }
        else
        {
            resultId = ValidationHelper.GetGuid(New_TransferId.Value);
            New_TransferId.Clear();
        }

        try
        {
            FtpTransferFactory.AddNewCriteria(criteriaGroupsId, stepId, objectId, resultId);
            GridPanelMonitoring.Reload();
        }
        catch (TuException tu)
        {
            tu.Show();

        }
        catch (Exception)
        {
            throw;
        }

    }

    protected void btnShowWindowOnEvent(object sender, AjaxEventArgs e)
    {
        if (CrmComboComp2.IsEmpty)
        {
            new MessageBox(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), CrmComboComp2.FieldLabel));
            CrmComboComp2.Focus();
            return;
        }
        else
        {
            QScript("TransferWindowList.show();");
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

    private void BindCombo(CrmComboComp combo, StaticData sd, string strSql)
    {
        var start = combo.Start() - 1;
        var limit = combo.Limit();

        if (start < 0)
        {
            start = 0;
        }

        BindCombo(combo, sd, strSql, start, limit);
    }

    private void BindCombo(CrmComboComp combo, StaticData sd, string strSql, int start, int limit)
    {
        var t = sd.ReturnDataset(strSql).Tables[0];

        //var start = combo.Start() - 1;
        //var limit = combo.Limit();

        DataTable t2 = t.Clone();

        var end = start + limit > t.Rows.Count ? t.Rows.Count : start + limit;

        for (int i = start; i < end; i++)
        {
            DataRow dr = t2.NewRow();
            dr.ItemArray = t.Rows[i].ItemArray;
            t2.Rows.Add(dr);
        }

        combo.TotalCount = t.Rows.Count;
        combo.DataSource = t2;
        combo.DataBind();
    }

    protected void CreateFileOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            if (!CrmComboComp2.IsEmpty)
            {
                var ftp = new FtpTransferFactory();
                FtpFileUploadManager ftpFileUploadManager = new FtpFileUploadManager();
                var stepId = ValidationHelper.GetGuid(PageSessionId.Value);
                var ftpReadFileHeaderId = Guid.Empty;
                var sb = new StringBuilder();
                var sbFile = new StringBuilder();
                var fileName = new UploadFileInfo();
                sb.Clear();
                string result = ftp.FtpMapDetailListForCriteriaGroup(stepId, ValidationHelper.GetGuid(CrmComboComp2.Value), out ftpReadFileHeaderId);

                if (result != string.Empty)
                {
                    sbFile.Append(result);
                }

                if (!string.IsNullOrEmpty(sbFile.ToString()))
                {
                    fileName = ftpFileUploadManager.UploadFtpFile(ftpReadFileHeaderId, sbFile.ToString(), ValidationHelper.GetGuid(CrmComboComp2.Value));

                    var df = new DynamicFactory(ERunInUser.CalingUser);
                    var deHead = new DynamicEntity(TuEntityEnum.New_FtpReadFileHeader.GetHashCode());
                    deHead.AddKeyProperty("New_FtpReadFileHeaderId", ftpReadFileHeaderId);
                    deHead.AddStringProperty("FileName", fileName.FileName);
                    df.Update(TuEntityEnum.New_FtpReadFileHeader.GetHashCode(), deHead);
                }
                else
                {
                    new MessageBox(CrmLabel.TranslateMessage("CRM.NEW_FTPWELCOMESCREEN_FILE_NOT_FOUND"));
                    CreateFile.AjaxEvents.Click.EventMask.ShowMask = false;
                    return;
                }
                var ftpData = FtpDataManager.FillFtpData(ValidationHelper.GetGuid(CrmComboComp2.Value));
                var type = ftpData.FtpType;
                var ftpUser = ftpData.SystemUserId;
                if (type == TuFactory.FtpTransfer.EFtpCorpType.SENDTO_CORP_CANCEL)
                {
                    FtpTransferFactory.UpdateCancelTransferAfterFTpUpload(stepId, ftpUser);
                }
                else if (type == TuFactory.FtpTransfer.EFtpCorpType.SENDTO_CORP)
                {
                    var staticData = new StaticData();
                    staticData.AddParameter("stepId", DbType.Guid, stepId);
                    DataTable dt = staticData.ReturnDataset("Select ObjectId from CriteriaGroupsResults Where StepId = @stepId").Tables[0];
                    if ((int)dt.Rows[0]["ObjectId"] == TuEntityEnum.New_Payment.GetHashCode())
                        FtpTransferFactory.UpdatePaymentTransferAfterFtpUpload(stepId, ftpUser); /* Ödeme */
                    else
                        FtpTransferFactory.UpdateTransferStatusAfterFTpUpload(stepId, ftpUser); /* O zaman Transferdir */
                }
                else if (type == TuFactory.FtpTransfer.EFtpCorpType.SENDTO_CORP_EDIT)
                {
                    FtpTransferFactory.UpdateEditTransferAfterFTpUpload(stepId, ftpUser);

                }

                var msgText = "Aktarım Tamamlandı.";

                var msg = new MessageBox { Width = 500 };
                msg.Show(msgText);

                FtpTransferData.FtpSendMail(App.Params.CurrentUser.SystemUserId, ValidationHelper.GetGuid(CrmComboComp2.Value),
                                            ftpReadFileHeaderId, fileName.FileName, msgText,
                                            App.Params.CurrentUser.InternalEMailAddress, true, 150, null, stepId);



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

                if (CrmComboComp2.IsEmpty)
                {
                    new MessageBox(string.Format(CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"), CrmComboComp2.FieldLabel));
                    CrmComboComp2.Focus();
                    CreateFile.AjaxEvents.Click.EventMask.ShowMask = false;
                    return;
                }

            }
        }
        catch (Exception ex)
        {
            e.Success = false;
            e.Message = ex.Message;
            new MessageBox("Error", "", e.Message);
            CreateFile.AjaxEvents.Click.EventMask.ShowMask = false;
            LogUtil.WriteException(ex);
        }
        CreateFile.AjaxEvents.Click.EventMask.ShowMask = false;
    }



    protected void CreateCriteriaGroupsToTransfer(object sender, AjaxEventArgs e)
    {
        var df = new DynamicFactory(ERunInUser.SystemAdmin);
        var de = df.Retrieve(TuEntityEnum.New_FtpFileHeader.GetHashCode(),
                                       ValidationHelper.GetGuid(CrmComboComp2.Value), new string[] { "new_CriteriaGroupsId", "New_FtpFileHeaderId" });
        if (de.GetLookupValue("new_CriteriaGroupsId") != Guid.Empty)
        {
            var cf = new CriteriaFactory();
            cf.ExecuteCriteriaWithSql(ValidationHelper.GetGuid(de.GetLookupValue("new_CriteriaGroupsId")), ValidationHelper.GetGuid(PageSessionId.Value));
            GridPanelMonitoring.Reload();
            QScript("TransferWindowList.show();");

        }

    }
    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;
        string strSql =
           @"
        	Select Mt.ProcessMonitoring AS VALUE ,
Mt.New_ProcessMonitoringId AS ID ,
Mt.ProcessMonitoring,Mt.new_TransactionItemId,
Mt.new_TransactionItemIdName,
Mt.new_TransactionDate,Mt.new_TransactionDateUtcTime ,
Mt.new_TransactionAmount,
Mt.new_TransactionAmountCurrencyName AS new_TransactionAmount_CurrencyName,Mt.new_TransactionAmountCurrency,Mt.new_TransactionAmountCurrencyName,Mt.new_CostAmount,Mt.new_CostAmountCurrencyName AS new_CostAmount_CurrencyName,Mt.new_CostAmountCurrency,Mt.new_CostAmountCurrencyName,
Mt.new_SenderId,Mt.new_SenderIdName,
Mt.new_SenderNumber,
Mt.new_SenderIdentificationCardNumber,Mt.new_RecipientFullName,Mt.new_RecipientCountry,Mt.new_RecipientCountryName,Mt.OwningUser,Mt.OwningUserName,Mt.ObjectId, 
Mt.new_TransactionConfirmId,
Mt.new_TransactionConfirmIdName,
Mt.new_ConfirmStatus,
Mt.new_ConfirmStatusName ,
Mt.new_OperationType,
Mt.new_OperationTypeName,
Mt.new_SourceTransactionTypeID,
Mt.new_SourceTransactionTypeIDName,
Mt.new_TargetTransactionTypeID,
Mt.new_TargetTransactionTypeIDName,
Mt.new_ReceivedAmount1,
Mt.new_ReceivedAmount1Currency,
Mt.new_ReceivedAmount1CurrencyName,
Mt.new_ReceivedAmount2,
Mt.new_ReceivedAmount2Currency,
Mt.new_ReceivedAmount2CurrencyName,
Mt.new_TotalReceivedAmount,
Mt.new_TotalReceivedAmountCurrency,
Mt.new_TotalReceivedAmountCurrencyName,
Mt.new_ReceivedAmount1CurrencyName as new_ReceivedAmount1_CurrencyName,
Mt.new_ReceivedAmount2CurrencyName as new_ReceivedAmount2_CurrencyName,
Mt.new_TotalReceivedAmountCurrencyName as new_TotalReceivedAmount_CurrencyName,
Mt.new_UpdateUserId,
Mt.new_UpdateUserIdName,
Mt.new_UpdateConfirmRejectUserId,
Mt.new_UpdateConfirmRejectUserIdName,
Mt.new_CorporationId,
Mt.new_CorporationIdName,
Mt.new_OfficeId,
Mt.new_OfficeIdName,
Mt.new_PayingCorporationId,
Mt.new_PayingCorporationIdName,
Mt.new_PayingOfficeId,
Mt.new_PayingOfficeIdName,
Mt.new_PayingUserId,
Mt.new_PayingUserIdName,
Mt.new_PaymentDate,
Mt.new_PaymentDateUtcTime,
new_TransferPaymentId,
new_TransferPaymentIdName,
new_FileTransactionNumber,
new_CountryName,
Mt.new_TransferIdName,
Mt.new_TransferId,
Mt.new_NationalityID,
Mt.new_NationalityIDName,
Mt.new_SenderCountryIDName,
Mt.new_SenderCountryID,
Mt.new_CancelDate,
Mt.new_CancelDateUtcTime
from  dbo.tvNew_ProcessMonitoring(@SystemUserId) as Mt
INNER JOIN CriteriaGroupsResults (NOLOCK) cr on cr.ResultId=Mt.New_ProcessMonitoringId and MT.ObjectId=cr.ObjectId
Where 1=1 AND
cr.StepId=@StepId
";

        string strSqlTransfer = @"
        select 
tr.New_TransferId as ID,
tr.TransferTuRef as VALUE,
tr.New_TransferId as New_ProcessMonitoringId,
tr.TransferTuRef as ProcessMonitoring,
tr.CreatedOn,tr.CreatedOnUtcTime ,tr.ModifiedOn,tr.ModifiedOnUtcTime ,tr.CreatedBy,tr.CreatedByName,tr.ModifiedBy,tr.ModifiedByName,tr.OwningUser,tr.OwningUserName,tr.OwningBusinessUnit,tr.OwningBusinessUnitName,tr.DeletionStateCode,tr.statuscode,
tr.new_CorporationCountryID as new_Country,
tr.new_CorporationCountryIDName as new_CountryName,
tr.new_CorporationId,
tr.new_CorporationIdName,
tr.new_OfficeId,
tr.new_OfficeIdName,
tr.New_TransactionItemID,
tr.New_TransactionItemIDName ,
tr.CreatedOn as new_TransactionDate,
tr.CreatedOnUtcTime as new_TransactionDateUtcTime,
tr.new_Amount as new_TransactionAmount,
tr.new_AmountCurrency	as new_TransactionAmountCurrency,
tr.new_AmountCurrencyName as new_TransactionAmount_CurrencyName,
tr.new_AmountCurrencyName as new_TransactionAmountCurrencyName,
tr.new_ExpenseAmount as new_CostAmount ,
tr.new_ExpenseAmountCurrency as new_CostAmountCurrency,
tr.new_ExpenseAmountCurrencyName as new_CostAmount_CurrencyName,
tr.new_ExpenseAmountCurrencyName as new_CostAmountCurrencyName,
tr.new_SenderID,
CASE WHEN ISNULL(tr.new_SenderMiddleName,'') <> '' THEN 
ISNULL(tr.new_SenderName,'')+' '+ISNULL(tr.new_SenderMiddleName,'')+' '+ISNULL(tr.new_SenderLastName,'')			
ELSE 
ISNULL(tr.new_SenderName,'')+' '+ISNULL(tr.new_SenderLastName,'')		
END	 as new_SenderIDName,
--tr.new_SenderIDName,
tr.new_SenderIdentificationCardNo as new_SenderIdentificationCardNumber,
cast(NULL as datetime)			 new_FormTransactionDate1,
cast(NULL as datetime)			 new_FormTransactionDate2,
cast(NULL as float)				 new_FormAmount1,
cast(NULL as float)				 new_FormAmount2,
cast(NULL as uniqueidentifier)	 new_FormAmount2Currency,
cast(NULL as nvarchar(100))		 new_FormAmount2CurrencyName,
cast(NULL as uniqueidentifier)	 new_FormTransactionItemId,
cast(NULL as nvarchar(100))		 new_FormTransactionItemIdName,
cast(NULL as uniqueidentifier)	 new_FormTransactionAmountCurrency,
cast(NULL as nvarchar(100))		 new_FormTransactionAmountCurrencyName,
cast(NULL as uniqueidentifier)	 new_FormReceiverCountryId,
cast(NULL as nvarchar(100))		 new_FormReceiverCountryIdName,
cast(NULL as nvarchar(100))		 new_FormCustomerNumber,
CASE WHEN ISNULL(tr.new_RecipientMiddleName,'') <> '' THEN 
			ISNULL(tr.new_RecipientName,'')+' '+ISNULL(tr.new_RecipientMiddleName,'')+' '+ISNULL(tr.new_RecipientLastName,'')			
			ELSE 
			ISNULL(tr.new_RecipientName,'')+' '+ISNULL(tr.new_RecipientLastName,'')		
			END	as new_RecipientFullName,

--isnull(tr.new_RecipientName,'')+' '+isnull(tr.new_RecipientLastName,'') as new_RecipientFullName,
tr.new_RecipientCountryID  as new_RecipientCountry ,tr.new_RecipientCountryIDName as new_RecipientCountryIdName ,
cast(201100072 as int) as ObjectId , --Gonderim Islemleri
se.new_SenderNumber as new_SenderNumber,
tr.new_ConfirmRevisionNumber,
tr.new_ConfirmStatus,
tr.new_ConfirmStatusName,
tr.new_TransactionConfirmId,
tr.new_TransactionConfirmIdName,
1 as new_OperationType,
ot.Label as  new_OperationTypeName,
tr.new_SourceTransactionTypeID,
tr.new_SourceTransactionTypeIDName,
tr.new_TargetTransactionTypeID,
tr.new_TargetTransactionTypeIDName,
tr.new_ReceivedAmount1,
tr.new_ReceivedAmount1Currency,
tr.new_ReceivedAmount1CurrencyName,
tr.new_ReceivedAmount2,
tr.new_ReceivedAmount2Currency,
tr.new_ReceivedAmount2CurrencyName,
tr.new_TotalReceivedAmount,
tr.new_TotalReceivedAmountCurrency,
tr.new_TotalReceivedAmountCurrencyName,
tr.new_UpdateUserId,
tr.new_UpdateUserIdName,
tr.new_UpdateConfirmRejectUserId,
tr.new_UpdateConfirmRejectUserIdName,
p.new_PaidByCorporation,
p.new_PaidByCorporationName,
p.new_PaidByOffice,
p.new_PaidByOfficeName,
tr.new_PayingUserId,
tr.new_PayingUserIdName,
tr.new_PaymentDate,
tr.new_PaymentDateUtcTime,
tr.new_PaymentId		as new_TransferPaymentId,
new_PaymentIdName	as new_TransferPaymentIdName,
new_FileTransactionNumber,
tr.TransferTuRef	AS new_TransferIdName,
tr.New_TransferId	AS new_TransferId,
se.new_NationalityID,
se.new_NationalityIDName,
tr.new_SenderCountryIDName,
tr.new_SenderCountryID,
tr.new_CancelDate,
tr.new_CancelDateUtcTime,
NULL Fake,
tr.new_RecipientCorporationId,
tr.new_RecipientCorporationIdName
 from nltvnew_Transfer (@SystemUserId) tr left outer join vnew_sender se on tr.new_SenderID=se.New_SenderId
	  left outer join systemuserbase (nolock) u on u.SystemUserId=@SystemUserId
	  Left outer join new_PLNew_ProcessMonitoring_new_OperationType (nolock) ot on ot.Value=1 and ot.LangId=u.LanguageId
	  left outer join vNew_Payment (nolock) p on (tr.New_TransferId = p.new_TransferID AND p.statuscode=1)
	  INNER JOIN CriteriaGroupsResults cr on cr.ResultId=tr.New_TransferId 
      Where 1=1 AND 
      cr.StepId=@StepId
        ";
        string strSqlRefundPayment = @"";
        //if(_userApproval.ApprovalConfirm)
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("PROCESSMONITORING");
        var spList = new List<CrmSqlParameter>();

        spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "StepId", Value = ValidationHelper.GetGuid(PageSessionId.Value) });

        var gpc = new GridPanelCreater();

        var cnt = 0;
        var start = GridPanelMonitoring.Start();
        var limit = GridPanelMonitoring.Limit();
        var dtb = new DataTable();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
        GridPanelMonitoring.TotalCount = cnt;

        try
        {
            if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            {
                var gpw = new GridPanelView(0, viewqueryid);
                gpw.Export(dtb);

            }

        }
        catch (Exception)
        {

            throw;
        }
        GridPanelMonitoring.DataSource = t;
        GridPanelMonitoring.DataBind();

    }

}