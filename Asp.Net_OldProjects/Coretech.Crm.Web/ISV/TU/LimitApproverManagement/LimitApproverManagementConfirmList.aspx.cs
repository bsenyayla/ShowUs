using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using Newtonsoft.Json;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;
using Coretech.Crm.Factory.Exporter;
using System.Web;
using TuFactory.Corporation;
using TuFactory.LimitApproverManagement;

public partial class LimitApproverManagementConfirmList : BasePage
{
    MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
    LimitApproverManagementConfirmFactory fac = new LimitApproverManagementConfirmFactory();

    protected void Page_Load(object sender, EventArgs e)
    {
        
        if (!RefleX.IsAjxPostback)
        {
            RR.RegisterIcon(Icon.Add);
            AddMessages();
            SetDefaults();
            newSenderLoad(null, null);
        }
       
    }
    private TuUser _activeUser;

    private void SetDefaults()
    {
        var ufFactory = new TuUserFactory();
        _activeUser = ufFactory.GetActiveUser();
        CreatedOnS.Value = DateTime.Now.Date;
        CreatedOnE.Value = DateTime.Now.Date;
    }

    protected void newSenderLoad(object sender, AjaxEventArgs e)
    {
        try
        {
            string strSql = @"SELECT 
                                s.new_SenderId ID,
	                            s.Sender VALUE,
                                new_SenderId,
                                Sender,
	                            new_Name,
                                new_MiddleName,
                                new_LastName,
                                new_GenderID,
                                new_GenderIDName,
                                new_BirthPlace,
                                new_IdendificationCardTypeID,
                                new_IdendificationCardTypeIDName,
                                new_IdentityNo,
                                new_SenderIdendificationNumber1,
                                new_SenderIdendificationNumber2
                            From vNew_Sender S (NoLock)
                            WHERE DeletionStateCode=0 AND S.new_CustAccountTypeIdName = 'Tüzel'
								  AND EXISTS(SELECT 1 FROM vNew_SenderPerson P (NoLock) WHERE P.new_SenderId = s.New_SenderId)
                                  AND EXISTS(SELECT 1 FROM vNew_CustAccountAuth A (NoLock) WHERE A.new_SenderId = s.New_SenderId AND A.new_ConfirmStatus = 3)
                            ORDER BY new_Name asc";

            StaticData sd = new StaticData();
            DataSet ds = sd.ReturnDataset(strSql);
            if (ds.Tables[0].Rows.Count > 0)
            {
                new_SenderId.TotalCount = ds.Tables[0].Rows.Count;
                new_SenderId.DataSource = ds.Tables[0];
                new_SenderId.DataBind();
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.Sender.SenderBlocked.SenderPersonBlockedForm.newSenderLoad", "Exception");
        }
    }

    protected void newSenderPersonLoad(object sender, AjaxEventArgs e)
    {
        try
        {
            string strSql = @"SELECT 
                                s.new_SenderPersonId ID,
	                            s.FullName VALUE,
                                new_SenderPersonId,
                                s.FullName,
                                s.new_SenderId,
                                s.new_SenderIdName,
	                            new_Name,
                                new_MiddleName,
                                new_LastName,
                                new_GenderID,
                                new_GenderIDName,
                                new_BirthPlace,
                                new_IdendificationCardTypeID,
                                new_IdendificationCardTypeIDName,
                                new_IdentityNo,
                                new_SenderIdendificationNumber1,
                                new_SenderIdendificationNumber2,
                                S.new_E_Mail,
                                S.new_GSM,
                                S.new_TaxNo,
                                S.new_NationalityIDName,
								S.new_NationalityIDName,
								S.new_HomeCountryName,
                                S.new_ConfirmStatus
                            From  nltvNew_SenderPerson(@SystemUserId) S
                            WHERE DeletionStateCode=0 
									AND S.new_SenderId = @SenderId
                                    AND EXISTS(SELECT 1 FROM vNew_CustAccountAuth A (NoLock) 
                                                WHERE A.new_SenderPersonId = s.New_SenderPersonId 
                                                    AND A.new_ConfirmStatus = 3)
                            ORDER BY new_Name asc";

            StaticData sd = new StaticData();
            sd.ClearParameters();
            sd.AddParameter("SenderId", DbType.Guid, ValidationHelper.GetGuid(new_SenderId.Value));
            sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId));
            DataSet ds = sd.ReturnDataset(strSql);
            if (ds.Tables[0].Rows.Count > 0)
            {
                new_SenderPersonId.TotalCount = ds.Tables[0].Rows.Count;
                new_SenderPersonId.DataSource = ds.Tables[0];
                new_SenderPersonId.DataBind();
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.LimitApproverManagement.LimitApproverManagementDetail.newSenderPersonLoad", "Exception");
        }
    }

    protected void SenderOnChange(object sender, AjaxEventArgs e)
    {
        new_SenderPersonId.SetValue("");
        newSenderPersonLoad(null, null);
        //SenderPersonList();
    }

    private void AddMessages()
    {
        CreatedOnmf.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("CreatedOn",
            TuEntityEnum.New_CustAccountOperations.GetHashCode());
        
        var Messages = new
        {
            NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM"),
            NEW_CUSTACCOUNTOPERATION_SURE_REJECT = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_REJECT")
        };
        RegisterClientScriptBlock("DasMessages", string.Format("var DasMessages={0};", JsonConvert.SerializeObject(Messages)));

        new_SenderId.EmptyText =
        new_SenderPersonId.EmptyText =
        new_Status.EmptyText =
        new_Status.EmptyText  = CrmLabel.TranslateMessage("CRM.ENTITY_FILTER_EMPTY_TEXT");
        btnRefresh.Text = CrmLabel.TranslateMessage("CRM_TOOLSEARCH");

        //btnCashTransaction.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_CASH_ACCOUNT");
        //btnDepositOperation.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_DEPOSIT_ACCOUNT"); 
    }

    private string GetListName()
    {
        return "CORPORATED_BLOCKED_TRANSACTION_LIST";
       //throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM.ENTITY_NEEDS_PERMISSION"), "RegionalManager,SalesManager,Administrator,PricingManager,Dealer"));

    }

    protected override void OnInit(EventArgs e)
    {
        var gpc = new GridPanelCreater();
        //gpc.CreateViewGridModels(GetListName(), gpCustAccountOperationHeader, true);
        base.OnInit(e);
    }

    protected void btnNewRecord_Click(object sender, AjaxEventArgs e)
    {

        try
        {


            Guid transactionId;
            int transactionType;
            int corporateTypeId;
            Guid systemUserId = App.Params.CurrentUser.SystemUserId;

            BasePage.QScript("var url = window.top.GetWebAppRoot + '/ISV/TU/LimitApproverManagement/LimitApproverManagementHeader.aspx?ObjectId=202000018&islemTip=yeniKayit" +
                             "&gridpanelid=GridPanelMonitoring&PoolId=3'; window.top.newWindowRefleX(url, { maximized: false, width: 1000, height: 600, resizable: true, modal: true, maximizable: false });");

            //var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            //ms.Show(".", "İlgili işlem onaylandı.");

        }
        catch (Exception ex)
        {

            var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", "Hata!! İşlem Yapılamadı");

            LogUtil.WriteException(ex, "LimitApproverManagementConfirmList.btnNewRecord_Click", "Exception");
            throw ex;
        }

    }


    protected void btnAcceptEditUpdate_Click(object sender, AjaxEventArgs e)
    {
        try
        {
            Guid refId = ValidationHelper.GetGuid(hdnRecId.Value);

            int status = 3;
            int? transactionType = ValidationHelper.GetInteger(hdnTransactionType.Value);
            Guid systemUserId = ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId);
            fac.UpdateHeaderConfirmStatus(refId, status, transactionType,"", systemUserId);

            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", "İlgili işlem, onaylandı");
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "LimitApproverManagementConfirmList.btnAcceptEditUpdate_Click", "Exception");
            throw ex;
        }

    }

    protected void btnCancelEditUpdate_Click(object sender, AjaxEventArgs e)
    {
        try
        {
            Guid refId = ValidationHelper.GetGuid(hdnRecId.Value);

            int status = 4;
            int? transactionType = ValidationHelper.GetInteger(hdnTransactionType.Value);
            Guid systemUserId = ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId);
            fac.UpdateHeaderConfirmStatus(refId, status, transactionType, "", systemUserId);

            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", "İlgili işlem, reddedildi");

        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "LimitApproverManagementConfirmList.btnbtnCancelEditUpdate_Click", "Exception");
            throw ex;
        }
    }

    protected void GpCorporatedPreInfoListReload(object sender, AjaxEventArgs e)
    {
       
        var sd = new StaticData();
        var sort = GridPanelCorporatedPreInfoList.ClientSorts() ?? string.Empty;

        string strSql = @" SELECT 
	                            A.New_LimitApproverManagementConfirmId Id,
	                            A.new_SenderId SenderId,
	                            A.new_SenderIdName SenderName,
	                            A.new_SenderPersonId SenderPersonId,
	                            A.new_SenderPersonIdName SenderPersonName,
                                A.new_TransactionType,
                                TT.Label TransactionTypeName,
	                            A.new_Status,
                                STT.Label new_StatusIdName,
                                FORMAT(dbo.fnUTCToLocalTimeForUser(A.CreatedOn,@SystemuserId),'dd.MM.yyyy') CreatedOnUtcTime,
								A.CreatedByName Olusturan,
	                            A.CreatedOn,
								A.ModifiedByName Duzenleyen,
								A.ModifiedOn,
                                FORMAT(dbo.fnUTCToLocalTimeForUser(A.ModifiedOn,@SystemuserId),'dd.MM.yyyy') ModifiedTime                            
                            FROM nltvNew_LimitApproverManagementConfirm(@SystemuserId) A
                            LEFT JOIN New_PLNew_LimitApproverManagementConfirm_new_Status STT (NoLock) ON  STT.LangId = 1055 and STT.Value = A.new_Status
                            LEFT JOIN New_PLNew_LimitApproverManagementConfirm_new_TransactionType TT (NoLock) ON  TT.LangId = 1055 and TT.Value = A.new_TransactionType
                            WHERE 1=1  AND ISNULL(A.new_Status,0) > 0 ";

        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];


        //var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("ViewCorporatedPreInfoList");
        var spList = new List<CrmSqlParameter>();

        if (!string.IsNullOrEmpty(new_SenderId.Value))
        {
            strSql += " AND A.new_SenderId = @new_SenderId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_SenderId",
                    Value = ValidationHelper.GetGuid(new_SenderId.Value)
                }
                );
        }


        if (!string.IsNullOrEmpty(new_SenderPersonId.Value))
        {
            strSql += " AND A.new_SenderPersonId=@new_SenderPersonId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_SenderPersonId",
                    Value = ValidationHelper.GetGuid(new_SenderPersonId.Value)
                }
                );
        }

        if (!string.IsNullOrEmpty(new_Status.Value))
        {
            strSql += " AND A.new_Status=@new_Status ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Int32,
                    Paramname = "new_Status",
                    Value = ValidationHelper.GetInteger(new_Status.Value)
                }
                );
        }


        if (CreatedOnS.Value.HasValue)
        {
            strSql += " AND CAST(CONVERT(varchar,A.CreatedOn,23) AS datetime) >= @CreatedOns ";
            //var CreatedOnSs = sd.FnLocalTimeToUtcForUser(CreatedOnS.Value.Value, App.Params.CurrentUser.SystemUserId);
            var CreatedOnSs = CreatedOnS.Value.Value;
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Date,
                    Paramname = "CreatedOns",
                    Value = CreatedOnSs
                }
                );
        }
        if (CreatedOnE.Value.HasValue)
        {
            //var CreatedOnEe = sd.FnLocalTimeToUtcForUser(CreatedOnE.Value.Value, App.Params.CurrentUser.SystemUserId);

            //strSql += " AND A.CreatedOn<=DATEADD(day,1,@CreatedOnE)";
            strSql += " AND CAST(CONVERT(varchar,A.CreatedOn,23) AS datetime) <=  @CreatedOnE ";
            var CreatedOnEe = CreatedOnE.Value.Value;
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Date,
                    Paramname = "CreatedOnE",
                    Value = CreatedOnEe
                }
                );
        }



        //foreach (var crmSqlParameter in spList)
        //{
        //    sd.AddParameter(crmSqlParameter.Paramname, crmSqlParameter.Dbtype, crmSqlParameter.Value);
        //}

        //DataTable dt = sd.ReturnDataset(strSql).Tables[0];

        //GridPanelCorporatedPreInfoList.TotalCount = dt.Rows.Count;
        //GridPanelCorporatedPreInfoList.DataSource = dt;
        //GridPanelCorporatedPreInfoList.DataBind();

        //strSql += " order by A.CreatedOn DESC ";

        DataTable dt = new DataTable();
        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelCorporatedPreInfoList.Start();
        var limit = GridPanelCorporatedPreInfoList.Limit();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dt);
        GridPanelCorporatedPreInfoList.TotalCount = cnt;

        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
            gpw.Export(dt);
        }


        GridPanelCorporatedPreInfoList.DataSource = t;
        GridPanelCorporatedPreInfoList.DataBind();

    }


    protected void ToExcelExport(object sender, AjaxEventArgs e)
    {
        try
        {



            var recId = hdnRecId.Value;

            //UptTransactionReport reconcliationFactory = new CorporatedPreInfoFactory();

            //var header = reconcliationFactory.GetUptTransactionReportExportData(ValidationHelper.GetGuid(recId));
            var header = "";

            string strXml = "";/// header.File.Trim();

            this.Response.Clear();
            this.Response.AddHeader("Content-Disposition", "attachment; filename=submittedData.xml");
            //this.Response.AddHeader("Content-Length", strXml.Length.ToString());
            this.Response.ContentType = "application/xml";
            this.Response.Write(strXml);

            //this.Response.End();
            this.Response.Flush();
            HttpContext.Current.ApplicationInstance.CompleteRequest();
            this.Response.End();
            //this.Response.WriteFile(Server.MapPath("~/test.xml"));


        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message.ToString());
            throw;
        }



    }







}