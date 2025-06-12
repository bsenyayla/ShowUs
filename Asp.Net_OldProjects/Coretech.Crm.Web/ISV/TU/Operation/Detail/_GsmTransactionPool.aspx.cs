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
using Upt.GsmPayment.Domain;
using Upt.GsmPayment.Business;

public partial class Operation_Detail_GsmTransactionPool : BasePage
{
    private TuUserApproval _userApproval = null;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private TuUser _activeUser = null;
    private void TranslateMessages()
    {

        var all = CrmLabel.TranslateMessage("CRM.ENTITY_ALL");

        new_SenderCorporationId.EmptyText = all;
        new_SenderOfficeId.EmptyText = all;
        new_CountryId.EmptyText = all;

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

        if (!RefleX.IsAjxPostback)
        {
            new_GsmNumber.Clear();
            SetGsmCountryTelephoneCode();
            TranslateMessages();
            FillLogInfo();
            new_SenderCorporationId.Value = _activeUser.CorporationId.ToString();
            new_SenderOfficeId.Value = _activeUser.OfficeId.ToString();
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
        gpc.CreateViewGrid("GsmPaymentView", GridPanelMonitoring);
        string strSelected;
        strSelected = ViewFactory.GetViewIdbyUniqueName("GsmPaymentView").ToString();
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

    protected void new_GsmCountryIdLoad(object sender, AjaxEventArgs e)
    {
        var like = new_GsmCountryId.Query();
        List<GsmCountry> list = GetGsmCountries(like);

        new_GsmCountryId.TotalCount = list.Count;
        new_GsmCountryId.DataSource = list;
        new_GsmCountryId.DataBind();
    }

    private List<GsmCountry> GetGsmCountries(string key)
    {
        GsmCountryService service = new GsmCountryService();

        return service.GetGsmCountries(key, App.Params.CurrentUser.SystemUserId);

    }

    protected void new_GsmCountryIdChangeOnEvent(object sender, AjaxEventArgs e)
    {
    }

    private void SetGsmCountryTelephoneCode()
    {
        //Gsm ülkesinin telefon kodunu js tarafından setliyoruz, cs tarafından setledeğimizde bug var, 
        //  telefon numarasını girildikten sonra ülkeyi değiştirisen kontroö dağılıyor, 
        //  ülke kodunu başa değil sona setliyor.


        new_GsmCountryId.Listeners.Change.Handler = @"if(new_GsmCountryId.selectedRecord.new_TelephoneCode != undefined)
                                                        {
                                                            document.getElementById('_new_GsmNumber').value = new_GsmCountryId.selectedRecord.new_TelephoneCode; 
                                                        }";
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

    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        var sd = new StaticData();
        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;
        string strSql = @"SELECT New_GsmPaymentId AS ID,New_GsmPaymentId,Reference AS VALUE,Reference,Mt.CreatedOn,CreatedOnUtcTime,Mt.ModifiedOn,ModifiedOnUtcTime,
Mt.CreatedBy,Mt.CreatedByName,Mt.ModifiedBy
                            ,Mt.ModifiedByName
                            ,new_GsmOperatorId
                            ,new_GsmOperatorIdName                           
                            ,new_IntegrationReference
                            ,new_PackageName
                            ,new_PackageCode
                            ,new_PackageAmount
                            ,new_PackageAmountCurrency
                            ,new_PackageAmountCurrencyName
                            ,new_PackageAmountCurrencyName AS new_PackageAmount_CurrencyName
                            ,new_Amount
                            ,new_AmountCurrency
                            ,new_AmountCurrencyName
                            ,new_AmountCurrencyName AS new_Amount_CurrencyName
                            ,new_ReceivedAmount1
                            ,new_ReceivedAmount1Currency
                            ,new_ReceivedAmount1CurrencyName
                            ,new_ReceivedAmount1CurrencyName AS new_ReceivedAmount1_CurrencyName
                            ,new_ReceivedAmount2
                            ,new_ReceivedAmount2Currency
                            ,new_ReceivedAmount2CurrencyName
                            ,new_ReceivedAmount2CurrencyName AS new_ReceivedAmount2_CurrencyName
                            ,new_ExpenseAmount
                            ,new_ExpenseAmountCurrency
                            ,new_ExpenseAmountCurrencyName
                            ,new_ExpenseAmountCurrencyName AS new_ExpenseAmount_CurrencyName
                            ,new_CommissionAmount
                            ,new_CommissionAmountCurrency
                            ,new_CommissionAmountCurrencyName
                            ,new_CommissionAmountCurrencyName AS new_CommissionAmount_CurrencyName
                            ,new_LoadStatus
                            ,new_LoadStatusName
                            ,new_LoadStatusDesc
                            ,Mt.new_GsmEntegrationChannelId
                            ,Mt.new_GsmEntegrationChannelIdName
                            ,Mt.new_GsmCountryId
                            ,new_GsmCountryIdName
                            ,new_ExpenseId
                            ,new_ExpenseIdName
                            ,new_PackageTypeName
                            ,new_PackageTypeIntegratorCode
                            ,new_PackageExParam1
                            ,new_PackageExParam2
                            ,new_IntegrationRequestId
                            ,new_SenderCorporationId
                            ,new_SenderCorporationIdName
                            ,new_RecipientCorporationId
                            ,new_RecipientCorporationIdName
                            ,new_SenderId
                            ,new_SenderIdName
                            ,new_MuhasebeTutar
                            ,new_MuhasebeTutarCurrency
                            ,new_MuhasebeTutarCurrencyName
                            ,new_MuhasebeTutarCurrencyName AS new_MuhasebeTutar_CurrencyName
                            ,new_MuhasebeMasrafTutar
                            ,new_MuhasebeMasrafTutarCurrency
                            ,new_MuhasebeMasrafTutarCurrencyName
                            ,new_MuhasebeMasrafTutarCurrencyName AS new_MuhasebeMasrafTutar_CurrencyName
                            ,new_BankTransactionNumber
                            ,new_SenderOfficeId
                            ,new_SenderOfficeIdName
                            ,Mt.new_CountryIdName
                            ,Mt.new_CountryId
                            ,new_ReceivedExpenseAmount
                            ,new_ReceivedExpenseAmountCurrency
                            ,new_ReceivedExpenseAmountCurrencyName 
                            ,new_ReceivedExpenseAmountCurrencyName  AS new_ReceivedExpenseAmount_CurrencyName   
							,GC.new_TelephoneCode + new_GsmNumber AS  new_GsmNumber                    
FROM nltvNew_GsmPayment(@SystemUserId) Mt 
INNER JOIN vNew_GsmCountry(NOLOCK) GC ON GC.New_GsmCountryId =Mt.new_GsmCountryId
WHERE 1=1  ";



        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();

        bool isParameterUsed = false;


        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("GsmPaymentView");
        var spList = new List<CrmSqlParameter>();

        //spList.Add(new CrmSqlParameter()
        //{
        //    Dbtype = DbType.Guid,
        //    Paramname = "SystemUserId",
        //    Value = ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId)
        //});

        if (new_CountryId.Value != "")
        {
            isParameterUsed = true;
            strSql += " And Mt.new_CountryId=@new_Country ";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_Country",
                Value = ValidationHelper.GetGuid(new_CountryId.Value)
            });
        }
        if (new_SenderCorporationId.Value != "")
        {
            isParameterUsed = true;
            strSql += " And Mt.new_SenderCorporationId=@new_SenderCorporationId ";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_SenderCorporationId",
                Value = ValidationHelper.GetGuid(new_SenderCorporationId.Value)
            });
        }


        if (new_FormTransactionDate1.Value != null)
        {
            isParameterUsed = true;
            strSql += " And Mt.CreatedOn>=@new_FormTransactionDate1 ";
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





        if (ProcessMonitoring.Value != "")
        {
            isParameterUsed = true;
            //strSql += " And MT.ProcessMonitoring like '%'+@ProcessMonitoring +'%'";
            strSql += " And MT.Reference = @ProcessMonitoring";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "ProcessMonitoring",
                Value = ValidationHelper.GetString(ProcessMonitoring.Value)
            });
        }

        if (!string.IsNullOrEmpty(new_IntegrationReference.Value))
        {
            isParameterUsed = true;
            //strSql += " And MT.ProcessMonitoring like '%'+@ProcessMonitoring +'%'";
            strSql += " And MT.new_IntegrationReference like '%'+ @IntegrationReference +'%'";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "IntegrationReference",
                Value = ValidationHelper.GetString(new_IntegrationReference.Value)
            });
        }

        if (!string.IsNullOrEmpty(new_GsmNumber.Value))
        {
            isParameterUsed = true;
            //strSql += " And MT.ProcessMonitoring like '%'+@ProcessMonitoring +'%'";
            strSql += " And GC.new_TelephoneCode + new_GsmNumber  like '%'+ @GsmNumber +'%'";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "GsmNumber",
                Value = ValidationHelper.GetString(new_GsmNumber.Value.Replace(" ", ""))
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



        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelMonitoring.Start();
        var limit = GridPanelMonitoring.Limit();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        GridPanelMonitoring.TotalCount = cnt;

        //List<string> fields = new List<string>() { "new_RecipientFullName" };
        //t = cryptor.DecryptFieldsInFilterData(fields, t);

        //if (!_userApproval.ReferenceCanBeSeen)
        //{
        //    List<Dictionary<string, object>> maskedList = new List<Dictionary<string, object>>();

        //    foreach (var item in t)
        //    {
        //        string tu_Ref = item.Where(x => x.Key.Equals("ProcessMonitoring")).Select(x => x.Value).FirstOrDefault().ToString();
        //        var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref); // string.Concat(tu_Ref.Substring(0, 3), "".PadRight(8, 'X'));

        //        item["ProcessMonitoring"] = masked_tu_ref;
        //        item["new_TransferIdName"] = masked_tu_ref;
        //        if (!string.IsNullOrEmpty(item["new_TransferPaymentIdName"].ToString()))
        //            item["new_TransferPaymentIdName"] = masked_tu_ref;
        //        item["VALUE"] = masked_tu_ref;

        //        maskedList.Add(item);
        //    }

        //    GridPanelMonitoring.DataSource = maskedList;
        //    GridPanelMonitoring.DataBind();
        //}
        //else
        //{
        GridPanelMonitoring.DataSource = t;
        GridPanelMonitoring.DataBind();
        //}

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