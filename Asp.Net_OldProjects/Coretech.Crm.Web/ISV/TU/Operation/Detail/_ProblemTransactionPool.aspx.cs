using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Info;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using System.Linq;
using TuFactory.Data;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using TuFactory.Pool;
using Coretech.Crm.Objects.Crm.Labels;

public partial class Operation_Detail_ProblemTransactionPool : BasePage
{
    private TuUserApproval _userApproval = null;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private TuUser _activeUser = null;
    private void TranslateMessages()
    {

        btnDownload.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
        var all = CrmLabel.TranslateMessage("CRM.ENTITY_ALL");

        new_CorporationId.EmptyText = all;
        new_OfficeId.EmptyText = all;


        new_SenderCountryID.EmptyText = all;
        new_FormTransactionTypeID.EmptyText = all;



    }
    protected void btnInformationOnEvent(object sender, AjaxEventArgs e)
    {
        var infoList = Info.GetEntityHelpsByName("MONITORING", this);
        if (infoList == null) return;
        var b = HttpContext.Current;
        b.Response.ClearContent();
        b.Response.ClearHeaders();
        b.Response.Clear();
        var f = new FileInfo(Server.MapPath(infoList.Command));
        var fs = File.Open(Server.MapPath(infoList.Command), FileMode.Open);

        var ms = new MemoryStream();
        fs.CopyTo(ms);

        var buffer = ms.ToArray();

        b.Response.AddHeader("Content-Disposition", string.Format(CultureInfo.InvariantCulture, "attachment; filename=\"{0}\"", new object[] { f.Name }));
        var length = buffer.Length;
        b.Response.AddHeader("ContentLength", length.ToString(CultureInfo.InvariantCulture));
        if (buffer.Length > 0)
        {
            b.Response.BinaryWrite(buffer);
        }
        b.Response.Flush();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        _activeUser = ufFactory.GetActiveUser();
        RowCount.SetIValue(0);

        if (!RefleX.IsAjxPostback)
        {
            TranslateMessages();
            FillLogInfo();
            new_CorporationId.Value = _activeUser.CorporationId.ToString();
            new_OfficeId.Value = _activeUser.OfficeId.ToString();
            if (new_FormTransactionDate1.Value != null)
            {
                new_FormTransactionDate2.Value = new_FormTransactionDate1.Value;
            }

            if (!_userApproval.ShowCancelPool)
            {
                Response.End();
            }

            if (!_userApproval.CancelStartOldDate)
            {
                RxM.Disabled = true;
            }
            pnl1.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_SEARCH");
            CreateViewGrid();
        }

    }
    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("ViewProblemTransactionList", GridPanelMonitoring);
        string strSelected;
        strSelected = ViewFactory.GetViewIdbyUniqueName("ViewProblemTransactionList").ToString();
        hdnViewList.Value = strSelected;

        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
        var DefaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnViewDefaultEditPage.Value = DefaultEditPage;

        var getColumnList = new UserPoolMapDb().GetColumnList(Convert.ToInt32(hdnPoolId.Value), ValidationHelper.GetGuid(strSelected), new UserPoolMapDb().GetAttributeListString(new UserPoolMapDb().getColumnSet(gpw.View.ColumnSetXml)));
        List<GridColumns> lstAddetColumn = GridPanelMonitoring.ColumnModel.Columns.ToList();
        GridPanelMonitoring.ClearColumns();

        foreach (GridColumns item in lstAddetColumn)
        {
            var count = (from c in getColumnList
                         where c.AttributeName == item.Header && c.Hide == true
                         select c).Count();
            if (count == 0)
                GridPanelMonitoring.AddColumn(item);
        }
        GridPanelMonitoring.ReConfigure();
    }


    private string GetFilterValidation()
    {
        string errMsg = string.Empty;

        if (!string.IsNullOrEmpty(ProcessMonitoring.Value))
        {
            return errMsg;
        }
        else
        {
            errMsg = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_REF_NOT_NULL");
        }
        return errMsg;
    }

    protected void BtnBugFixOnEvent(object sender, AjaxEventArgs e)
    {
        var degerler = ((CheckSelectionModel)GridPanelMonitoring.SelectionModel[0]);
        if (degerler != null && degerler.SelectedRows != null)
        {
            foreach (var row in degerler.SelectedRows)
            {
                var fileTransactionNumber = ValidationHelper.GetString(row.new_FileTransactionNumber);

                if(string.IsNullOrEmpty(fileTransactionNumber))
                {
                    GridPanelMonitoring.ClearSelection();
                    QScript("alert('Listede geçersiz kayıt vardır.');return false;");
                    return;
                }
            }
            
            foreach (var row in degerler.SelectedRows)
            {
                var transferId = ValidationHelper.GetGuid(row.New_TransferId);
                var problemTransactionPoolFactory = new ProblemTransactionPoolFactory();
                problemTransactionPoolFactory.ClearFileTransactionNumber(transferId);
            }

            GridPanelMonitoring.ClearSelection();
            QScript("alert('İşlem başarıyla tamamlandı.');return false;");
            ToolbarButtonFindClick(sender, e);
        }
        else
        {
            GridPanelMonitoring.ClearSelection();
            QScript("alert('Listede hiç kayıt yok ya da seçim yapılmamış');return false;");
            return;
        }
    }
    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {

        DataTable dt;
        string systemUserInformation = "SELECT TOP 1 LanguageId FROM vSystemUser (NoLock) WHERE SystemUserId = @SystemUserId ";

        StaticData sd2 = new StaticData();
        sd2.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);

        dt = sd2.ReturnDataset(systemUserInformation).Tables[0];
        string languageId = ValidationHelper.GetString(dt.Rows[0]["LanguageId"]);

        var sd = new StaticData();
        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;
        string strSql = @"Select TransferTuref AS VALUE ,Mt.New_TransferId AS ID ,Mt.New_TransferId AS New_TransferId,Mt.TransferTuRef,new_FileTransactionNumber,
                            new_ConfirmStatus,new_ConfirmStatusName,Mt.CreatedBy,Mt.CreatedByName,
							DATEADD(hour,3,Mt.CreatedOn) AS CreatedOn,
							Mt.CreatedOn AS CreatedOnUtcTime,
							Mt.new_RecipientCorporationId,Mt.new_RecipientCorporationIdName,
                            new_TargetTransactionTypeID,new_TargetTransactionTypeIDName,Mt.new_RecipientFullName,Mt.new_SenderIDName,
							new_SenderCountryID,new_SenderCountryIDName,new_CorporationID,new_CorporationIDName,Mt.new_RecipientCountryID,Mt.new_RecipientCountryID AS new_RecipientCountry,
                            Mt.new_RecipientCountryIDName, Mt.new_RecipientCountryIDName AS new_RecipientCountryName,
							new_Amount,new_AmountCurrency,new_AmountCurrencyName,new_AmountCurrencyName AS new_Amount_CurrencyName,
							ch.Value AS new_Channel,ch.Label AS new_ChannelName,
							new_IntegrationChannel,new_IntegrationChannelName,
							new_TransactionTargetOptionID,new_TransactionTargetOptionIDName,new_OfficeID,new_OfficeIDName,
                            new_BANKA_ISLEM_NO
                            from  vNew_Transfer(NOLOCK) as Mt
                            
							left join new_PLNew_Transfer_new_Channel ch (NoLock) ON ch.Value=Mt.new_Channel
                            Where 1=1 
                            and (
                                Mt.New_ConfirmStatus IN (Select New_ConfirmStatusId From vNew_ConfirmStatus(NOLOCK) WHERE DeletionStateCode=0 AND new_Code in ('TR000','TR013'))                                
                            ) ";





        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();

        bool isParameterUsed = false;


        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("ViewProblemTransactionList");
        var spList = new List<CrmSqlParameter>();
        spList.Clear();


        if (!String.IsNullOrEmpty(languageId))
            strSql += " And  ch.LangId = ISNULL(" + languageId + ",1055) ";
        else
            strSql += " And  ch.LangId = 1055 ";

        /*
        spList.Add(new CrmSqlParameter()
        {
            Dbtype = DbType.Guid,
            Paramname = "SystemUserId",
            Value = ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId)
        });
        */

        if (new_SenderCountryID.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_SenderCountryID=@new_Country";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_Country",
                Value = ValidationHelper.GetGuid(new_SenderCountryID.Value)
            });
        }

        if (!String.IsNullOrEmpty(new_OfficeId.Value))
        {
            isParameterUsed = true;
            strSql += " And Mt.new_OfficeID=@new_OfficeID ";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_OfficeID",
                Value = ValidationHelper.GetGuid(new_OfficeId.Value)
            });
        }


        if (new_CorporationId.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_CorporationId=@new_CorporationId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_CorporationId",
                Value = ValidationHelper.GetGuid(new_CorporationId.Value)
            });
        }
        if (new_RecipientCorporationId.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_RecipientCorporationId=@new_RecipientCorporationId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_RecipientCorporationId",
                Value = ValidationHelper.GetGuid(new_RecipientCorporationId.Value)
            });
        }

        if (new_FormReceiverCountryId.Value != "")
        {
            isParameterUsed = true;
            strSql += " And Mt.new_RecipientCountryID=@RecipientCountryID";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "RecipientCountryID",
                Value = ValidationHelper.GetGuid(new_FormReceiverCountryId.Value)
            });
        }





        if (new_FormTransactionDate1.Value != null)
        {
            isParameterUsed = true;
            strSql += " And Mt.CreatedOn>=@new_FormTransactionDate1";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "new_FormTransactionDate1",
                Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_FormTransactionDate1.Value), App.Params.CurrentUser.SystemUserId)
            });
        }

        if (new_FormTransactionDate2.Value != null)
        {
            isParameterUsed = true;
            strSql += " And Mt.CreatedOn < @new_FormTransactionDate2";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "new_FormTransactionDate2",
                Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_FormTransactionDate2.Value).AddDays(1), App.Params.CurrentUser.SystemUserId)
            });
        }


        if (new_FormTransactionTypeID.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_TargetTransactionTypeID=@new_FormTransactionTypeID";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormTransactionTypeID",
                Value = ValidationHelper.GetGuid(new_FormTransactionTypeID.Value)
            });
        }


        if (ProcessMonitoring.Value != "")
        {
            isParameterUsed = true;
            //strSql += " And MT.ProcessMonitoring like '%'+@ProcessMonitoring +'%'";
            strSql += " And MT.TransferTuref = @ProcessMonitoring";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "ProcessMonitoring",
                Value = ValidationHelper.GetString(ProcessMonitoring.Value)
            });
        }

        if (!string.IsNullOrEmpty(new_FileTransactionNumber.Value))
        {
            isParameterUsed = true;
            //strSql += " And MT.ProcessMonitoring like '%'+@ProcessMonitoring +'%'";
            strSql += " And MT.new_FileTransactionNumber like '%'+ @FileTransactionNumber +'%'";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "FileTransactionNumber",
                Value = ValidationHelper.GetString(new_FileTransactionNumber.Value)
            });
        }


        if (!isParameterUsed)
        {
            string filtermsg = GetFilterValidation();
            if (!string.IsNullOrEmpty(filtermsg))
            {
                var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", filtermsg);

                GridPanelMonitoring.DataBind();
                return;
            }
        }


        List<Dictionary<string, object>> t;
        DataTable dtb;



        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelMonitoring.Start();
        var limit = GridPanelMonitoring.Limit();
        t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);

        GridPanelMonitoring.TotalCount = cnt;


        RowCount.SetIValue(cnt);
        RowCount.SetValue(cnt);
        RowCount.Value = cnt.ToString();
        List<string> fields = new List<string>() { "new_RecipientFullName" };
        t = cryptor.DecryptFieldsInFilterData(fields, t);


        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {

            var gpw = new GridPanelView(201100072, ValidationHelper.GetGuid(viewqueryid));
            gpw.Export(dtb);

        }

        if (!_userApproval.ReferenceCanBeSeen)
        {
            List<Dictionary<string, object>> maskedList = new List<Dictionary<string, object>>();

            foreach (var item in t)
            {
                string tu_Ref = item.Where(x => x.Key.Equals("ProcessMonitoring")).Select(x => x.Value).FirstOrDefault().ToString();
                var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref); // string.Concat(tu_Ref.Substring(0, 3), "".PadRight(8, 'X'));

                item["ProcessMonitoring"] = masked_tu_ref;
                item["new_TransferIdName"] = masked_tu_ref;
                if (!string.IsNullOrEmpty(item["new_TransferPaymentIdName"].ToString()))
                    item["new_TransferPaymentIdName"] = masked_tu_ref;
                item["VALUE"] = masked_tu_ref;

                maskedList.Add(item);
            }

            GridPanelMonitoring.DataSource = maskedList;
            GridPanelMonitoring.DataBind();
        }
        else
        {
            GridPanelMonitoring.DataSource = t;
            GridPanelMonitoring.DataBind();
        }

    }

    protected void ToolbarButtonTransferClick(object sender, AjaxEventArgs e)
    {

    }
    protected void ToolbarButtonPaymentClick(object sender, AjaxEventArgs e)
    {
    }

    private void HoldResume(ETuHoldResume action)
    {
        if (!_userApproval.ApprovalHoldResume)
        {
            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true };
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOUHAVENOT_PERMISSION"));

            return;
        }

        var degerler = ((RowSelectionModel)GridPanelMonitoring.SelectionModel[0]);
        if (degerler != null && degerler.SelectedRows != null)
        {

            try
            {
                var objectId = ValidationHelper.GetInteger(degerler.SelectedRows.ObjectId);
                var processMonitoringId = ValidationHelper.GetGuid(degerler.SelectedRows.ID);
                var cf = new ConfirmFactory();

                cf.ConfirmHoldResume(action, objectId, processMonitoringId);
                if (action == ETuHoldResume.Hold)
                    _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_HOLD_OK"));
                else if (action == ETuHoldResume.Resume)
                    _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_RESUME_OK"));

                QScript("ToolbarButtonFind.click();");
            }
            catch (TuException ex)
            {
                _msg.Show(".", ex.ErrorMessage);

            }
            catch (Exception ex)
            {

                _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            }


            //GridPanelMonitoring.Reload();
        }
        else
        {
            _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PLACE_SELECT_RECORD"));
        }
    }
    protected void BtnHoldClick(object sender, AjaxEventArgs e)
    {
        HoldResume(ETuHoldResume.Hold);


    }
    protected void BtnResumeClick(object sender, AjaxEventArgs e)
    {
        HoldResume(ETuHoldResume.Resume);
    }

    private void FillLogInfo()
    {
        var id = Guid.Parse("caa07ae3-b1e8-410b-be1f-63ede1aa6862");
        var recId = new TuFactory.Data.LogDb().GetLastRecordId(id);

        hdnEntityId.SetValue(id);
        hdnRecid.SetValue(recId);
    }

    protected void new_CountryLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"/* DECLARE @SystemUserId UNIQUEIDENTIFIER =  '00000001-2211-44A8-BAAA-89AC131336A9' */
            DECLARE @LangId AS INT
            DECLARE @TempLangId AS INT
            SELECT @LangId = LanguageId FROM vSystemUser
            WHERE SystemUserId = @SystemUserId     
            SELECT		
                        c.new_CountryID AS ID, 
						cE.new_TelephoneCode,
                        CASE @TempLangId 
                             WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                             ELSE cl.Value
                        END AS CountryName,
                        CASE @TempLangId 
                             WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                             ELSE cl.Value
                        END AS VALUE
            FROM New_CountryBase c
            INNER JOIN New_CountryLabel cl
            ON c.New_CountryId = cl.New_CountryId AND cl.LangId = @LangId
			INNER JOIN New_CountryExtension cE
			ON c.New_CountryId = cE.New_CountryId
                 WHERE 
			C.DeletionStateCode = 0
			AND cE.new_TelephoneCode IS NOT NULL
			";

        StaticData sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);

        //var like = new_SenderCountryID.Query();
        var like = ((CrmComboComp)sender).Query();
        if (!string.IsNullOrEmpty(like))
        {
            strSql += @" AND (CASE @TempLangId 
                                WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                                ELSE cl.Value
                                END LIKE '%' + @CountryName + '%' OR CASE @TempLangId 
                                WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                                ELSE cl.Value
                                END LIKE '%' + UPPER(@CountryNameTR COLLATE SQL_Latin1_General_CP1_CI_AS) + '%' )";

            sd.AddParameter("CountryName", DbType.String, like.Replace("İ", "I"));
            like = like.Replace("i", "İ");
            like = like.Replace("ı", "I");
            sd.AddParameter("CountryNameTR", DbType.String, like);
        }

        strSql += " ORDER BY CountryName";

        BindCombo(((CrmComboComp)sender), sd, strSql);
    }

    protected void new_RecipientCorporationLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"Select c.New_CorporationCode As new_CorporationCode, c.New_CorporationId AS ID, c.CorporationName AS CorporationName, c.CorporationName AS VALUE from nltvNew_Corporation(@SystemUserId) c
                        Where c.DeletionStateCode = 0 And statuscode = 1";

        StaticData sd = new StaticData();

        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

        if (_userApproval.AllRecipientCorporation)
        {
            sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid("00000000-AAAA-BBBB-CCCC-000000000001"));
        }
        else
        {
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        }

        var like = ((CrmComboComp)sender).Query();
        if (!string.IsNullOrEmpty(like))
        {
            strSql += @" AND c.CorporationName LIKE '%' + @CorporationName + '%' ";
            sd.AddParameter("CorporationName", DbType.String, like);
        }

        strSql += " ORDER BY c.CorporationName";

        BindCombo(((CrmComboComp)sender), sd, strSql);
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

}