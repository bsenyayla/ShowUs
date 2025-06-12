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
using TuFactory.SenderBlocked;
using Coretech.Crm.Objects.Crm.Dynamic.Security;

public partial class SenderBlockedApprovalList : BasePage
{

    private DynamicSecurity DynamicSecurity;

    protected void Page_Load(object sender, EventArgs e)
    {
        
        if (!RefleX.IsAjxPostback)
        {
            DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_CorporatedBlockedApproval.GetHashCode(), null);
            //yetkisi yoksa butonları gizle
            if (!DynamicSecurity.PrvAppend)
            {
                btnAccept.Visible = false;
                btnCancel.Visible = false;
            }

            RR.RegisterIcon(Icon.Add);
            AddMessages();
            SetDefaults();
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
        mfsender.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_SenderId",
            TuEntityEnum.New_CustAccountOperations.GetHashCode());
        var Messages = new
        {
            NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM"),
            NEW_CUSTACCOUNTOPERATION_SURE_REJECT = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_REJECT")
        };
        RegisterClientScriptBlock("DasMessages", string.Format("var DasMessages={0};", JsonConvert.SerializeObject(Messages)));

        new_CustomerType.EmptyText =
        new_SenderId.EmptyText =
        new_CustomerType.EmptyText =
        new_CustomerType.EmptyText =
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
    }


    protected void btnAcceptEditUpdate_Click(object sender, AjaxEventArgs e)
    {

        try
        {
            if (ValidationHelper.GetGuid(blockedId.Value.ToString()) == Guid.Empty)
                return;

            Guid transactionId;
            int transactionType;
            int corporateTypeId;
            Guid systemUserId = App.Params.CurrentUser.SystemUserId;
            int confirmStatus = 2;

            transactionId = Guid.Parse(blockedId.Value.ToString());
            transactionType = Convert.ToInt32(transactionTypeId.Value.ToString());
            corporateTypeId = Convert.ToInt32(corporateType.Value.ToString());

            SenderBlockedFactory set = new SenderBlockedFactory();

            set.Confirm(transactionId, corporateTypeId, transactionType, confirmStatus, systemUserId);

            GpCorporateBlockedListReload(sender, e);


            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", "İlgili işlem onaylandı.");

        }
        catch (Exception ex)
        {

            var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", "Hata!! İşlem Yapılamadı");

            LogUtil.WriteException(ex, "SenderBlockedApprovalList.btnAcceptEditUpdate_Click", "Exception");
            throw ex;
        }


        //GridPanelConfirmHistory.DataBind();
    }

    protected void btnbtnCancelEditUpdate_Click(object sender, AjaxEventArgs e)
    {

        try
        {
            if (ValidationHelper.GetGuid(blockedId.Value.ToString()) == Guid.Empty)
                return;

            Guid transactionId;
            int transactionType;
            int corporateTypeId;
            Guid systemUserId = App.Params.CurrentUser.SystemUserId;
            int confirmStatus = 3;

            transactionId = Guid.Parse(blockedId.Value.ToString());
            transactionType = Convert.ToInt32(transactionTypeId.Value.ToString());
            corporateTypeId = Convert.ToInt32(corporateType.Value.ToString());

            SenderBlockedFactory set = new SenderBlockedFactory();

            set.Confirm(transactionId, corporateTypeId, transactionType, confirmStatus, systemUserId);

            GpCorporateBlockedListReload(sender, e);

            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", "İlgili işlem reddedildi.");

        }
        catch (Exception ex)
        {
            var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", "Hata!! İşlem Yapılamadı");

            LogUtil.WriteException(ex, "SenderBlockedApprovalList.btnbtnCancelEditUpdate_Click", "Exception");
            throw ex;
        }
    }

    protected void GpCorporateBlockedListReload(object sender, AjaxEventArgs e)
    {
        

        var sd = new StaticData();
        var sort = GridPanelCorporateBlockedList.ClientSorts() ?? string.Empty;
        string strSql = @" SELECT *
                            FROM fnTuGetSenderAndPersonBlockedList(@SystemUserId) tnr 
					        WHERE 1=1 AND BlockedStatus = 1  ";

        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];


        var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var spList = new List<CrmSqlParameter>();

        spList.Add(
                  new CrmSqlParameter
                  {
                      Dbtype = DbType.Guid,
                      Paramname = "SystemUserId",
                      Value = ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId)
                  }
                  );


        if (!string.IsNullOrEmpty(new_CustomerType.Value))
        {
            strSql += " AND tnr.CorporateType=@CorporateType ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Int32,
                    Paramname = "CorporateType",
                    Value = ValidationHelper.GetInteger(new_CustomerType.Value)
                }
                );
        }


        if (!string.IsNullOrEmpty(new_TransactionType.Value))
        {
            strSql += " AND tnr.TransactionType=@TransactionType ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Int32,
                    Paramname = "TransactionType",
                    Value = ValidationHelper.GetInteger(new_TransactionType.Value)
                }
                );
        }

        if (!string.IsNullOrEmpty(new_SenderId.Value))
        {
            strSql += " AND tnr.SenderId = @new_SenderId ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_SenderId",
                    Value = ValidationHelper.GetGuid(new_SenderId.Value)
                }
                );
        }


        if (CreatedOnS.Value.HasValue)
        {
            strSql += " AND tnr.CreatedOn>=@CreatedOns";
            var CreatedOnSs = sd.FnLocalTimeToUtcForUser(CreatedOnS.Value.Value, App.Params.CurrentUser.SystemUserId);
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
            var CreatedOnEe = sd.FnLocalTimeToUtcForUser(CreatedOnE.Value.Value, App.Params.CurrentUser.SystemUserId);

            strSql += " AND tnr.CreatedOn<=DATEADD(day,1,@CreatedOnE)";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Date,
                    Paramname = "CreatedOnE",
                    Value = CreatedOnEe
                }
                );
        }



        foreach (var crmSqlParameter in spList)
        {
            sd.AddParameter(crmSqlParameter.Paramname, crmSqlParameter.Dbtype, crmSqlParameter.Value);
        }

        DataTable dt = sd.ReturnDataset(strSql).Tables[0];

        GridPanelCorporateBlockedList.TotalCount = dt.Rows.Count;
        GridPanelCorporateBlockedList.DataSource = dt;
        GridPanelCorporateBlockedList.DataBind();


    }
    









}