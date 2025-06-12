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

public partial class _CustomerReportList : BasePage
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
         CrmLabel.TranslateMessage("CRM.ENTITY_FILTER_EMPTY_TEXT");
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
                            WHERE DeletionStateCode=0 
                                  AND s.new_Channel = 10  
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
            LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.CorporatedReport._CustomerReportList.newSenderLoad", "Exception");
        }
    }

    protected void newSenderPersonLoad(object sender, AjaxEventArgs e)
    {
        try
        {
            string strSql = @"SELECT 
                                SP.new_SenderPersonId ID,
	                            SP.FullName VALUE,
                                SP.new_SenderPersonId,
                                SP.FullName,
                                SP.new_SenderId,
                                SP.new_SenderIdName,
	                            SP.new_Name,
                                SP.new_MiddleName,
                                SP.new_LastName,
                                SP.new_GenderID,
                                SP.new_GenderIDName,
                                SP.new_BirthPlace,
                                SP.new_IdendificationCardTypeID,
                                SP.new_IdendificationCardTypeIDName,
                                SP.new_IdentityNo,
                                SP.new_SenderIdendificationNumber1,
                                SP.new_SenderIdendificationNumber2,
                                SP.new_E_Mail,
                                SP.new_GSM,
                                SP.new_TaxNo,
                                SP.new_NationalityIDName,
								SP.new_NationalityIDName,
								SP.new_HomeCountryName,
                                SP.new_ConfirmStatus
                            From  nltvNew_SenderPerson(@SystemUserId) SP
                            inner join vNew_Sender (NOLOCK) s on s.New_SenderId = sp.new_SenderId 
                            WHERE SP.DeletionStateCode=0 
									AND SP.new_SenderId = @SenderId
                                    AND s.new_Channel = 10 
                            ORDER BY SP.new_Name asc";

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
            LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.CorporatedReport._CustomerReportList.newSenderPersonLoad", "Exception");
        }
    }

    protected void SenderOnChange(object sender, AjaxEventArgs e)
    {
        new_SenderPersonId.SetValue("");
        newSenderPersonLoad(null, null);
        //SenderPersonList();
    }



    protected void GpCorporatedPreInfoListReload(object sender, AjaxEventArgs e)
    {
        

        var sd = new StaticData();
        var sort = GridPanelCorporatedPreInfoList.ClientSorts() ?? string.Empty;


        string strSql = @" select 
                                case when s.new_CustAccountTypeIdName = 'Gerçek' then s.new_MobileUserId else sp.new_MobilUserId end as Id,
	                            s.new_CustAccountTypeIdName,
	                            case when s.new_CustAccountTypeIdName = 'Gerçek' then s.new_MobileUserId else sp.new_MobilUserId end as UserId,
	                            case when s.new_CustAccountTypeIdName = 'Gerçek' then s.new_MobileUserIdName else sp.new_MobilUserIdname end as UserName,
	                            case when s.new_CustAccountTypeIdName = 'Gerçek' then s.new_ProfessionIDName else sp.new_ProfessionIDName end new_ProfessionIDName ,
	                            case when s.new_CustAccountTypeIdName = 'Gerçek' then s.new_WorkingStyleIdName else sp.new_WorkingStyleIdName end new_WorkingStyleIdName,
	                            case when s.new_CustAccountTypeIdName = 'Gerçek' then s.new_NationalityIDName else sp.new_NationalityIDName end new_NationalityIDName,
	                            case when s.new_CustAccountTypeIdName = 'Gerçek' then s.new_ProfessionID else sp.new_ProfessionID end new_ProfessionID,
	                            case when s.new_CustAccountTypeIdName = 'Gerçek' then s.new_WorkingStyleId else sp.new_WorkingStyleId end as new_WorkingStyleId,
	                            case when s.new_CustAccountTypeIdName = 'Gerçek' then s.new_NationalityID else sp.new_NationalityID end as new_NationalityID ,
	                            case when s.new_CustAccountTypeIdName = 'Gerçek' then s.new_HomeCountryName else sp.new_HomeCountryName end as new_HomeCountryName,
	                            case when s.new_CustAccountTypeIdName = 'Gerçek' then s.CreatedOn else sp.CreatedOn end as CreatedOn,
                                FORMAT(dbo.fnUTCToLocalTimeForUser((case when s.new_CustAccountTypeIdName = 'Gerçek' then s.CreatedOn else sp.CreatedOn end),@SystemuserId),'dd.MM.yyyy') CreatedOnUtcTime,
	                            s.new_SenderId senderId,
	                            s.Sender SenderName,
                                sp.new_SenderPersonId SenderPersonId,
	                            sp.FullName SenderPersonName
                            from vNew_Sender s (NoLock)
                            LEFT JOIN vSystemUser su (NoLock) on su.SystemUserId = s.new_MobileUserId AND su.DeletionStateCode  = 0  
                            left join vNew_SenderPerson (NOLOCK) sp on sp.new_SenderId = s.New_SenderId AND sp.DeletionStateCode = 0 and sp.new_MobilUserId IS NOT NULL 
                            where s.new_Channel = 10  
	                            AND s.DeletionStateCode = 0 ";

        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];


        //var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("ViewCorporatedPreInfoList");
        var spList = new List<CrmSqlParameter>();

        if (!string.IsNullOrEmpty(new_SenderId.Value))
        {
            strSql += " AND S.new_SenderId = @new_SenderId ";
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
            strSql += " AND SP.new_SenderPersonId=@new_SenderPersonId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_SenderPersonId",
                    Value = ValidationHelper.GetGuid(new_SenderPersonId.Value)
                }
                );
        }

        if (!string.IsNullOrEmpty(new_CustAccountTypeId.Value))
        {
            strSql += " AND s.new_CustAccountTypeId =@new_CustAccountTypeId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_CustAccountTypeId",
                    Value = ValidationHelper.GetGuid(new_CustAccountTypeId.Value)
                }
                );
        }


        if (!string.IsNullOrEmpty(new_ProfessionID.Value))
        {
            strSql += " AND (case when s.new_CustAccountTypeIdName = 'Gerçek' then s.new_ProfessionID else sp.new_ProfessionID end) = @new_ProfessionID ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_ProfessionID",
                    Value = ValidationHelper.GetGuid(new_ProfessionID.Value)
                }
                );
        }

        if (!string.IsNullOrEmpty(new_NationalityID.Value))
        {
            strSql += " AND (case when s.new_CustAccountTypeIdName = 'Gerçek' then s.new_NationalityID else sp.new_NationalityID end) = @new_NationalityID ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_NationalityID",
                    Value = ValidationHelper.GetGuid(new_NationalityID.Value)
                }
                );
        }


        if (!string.IsNullOrEmpty(new_HomeCountry.Value))
        {
            strSql += " AND (case when s.new_CustAccountTypeIdName = 'Gerçek' then s.new_HomeCountry else sp.new_HomeCountry end) = @new_HomeCountry ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_HomeCountry",
                    Value = ValidationHelper.GetGuid(new_HomeCountry.Value)
                }
                );
        }

        if (CreatedOnS.Value.HasValue)
        {
            strSql += " AND CAST(CONVERT(varchar,s.CreatedOn,23) AS datetime) >= @CreatedOns ";
            
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
            strSql += " AND CAST(CONVERT(varchar,s.CreatedOn,23) AS datetime) <=  @CreatedOnE ";
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