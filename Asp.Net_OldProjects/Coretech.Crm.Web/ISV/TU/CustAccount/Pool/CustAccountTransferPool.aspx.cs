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

public partial class CustAccount_Pool_CustAccountTransferPool : BasePage
{
    private Guid GetSelectedOrderHeaderId()
    {
        var gp = gpCustAccountOperationHeader;
        if (gp != null)
        {
            var selmode = gp.SelectionModel[0] as RowSelectionModel;
            var sr = selmode.SelectedRows;
            if (sr != null)
            {
                foreach (var item in sr)
                {
                    var id = ValidationHelper.GetGuid(item.ID);
                    return id;
                }
            }
        }
        throw new TuException(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_MUST_SELECT_RECORD"), "AC0001");

    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            RR.RegisterIcon(Icon.Add);
            CreateViewGrid();
            //new_CustAccountTypeId.SetValue(Conti.ActiveUser.UserDealerId.ToString());
            AddMessages();
            PrepareItems();
            SetDefaults();
        }

    }
    private TuUser _activeUser;

    private void SetDefaults()
    {
        var ufFactory = new TuUserFactory();
        _activeUser = ufFactory.GetActiveUser();
      
        CreatedOnS.Value = DateTime.Now.Date;
    }

    private void PrepareItems()
    {

        var ds = DynamicFactory.GetSecurity(TuEntityEnum.New_CustAccountOperations.GetHashCode(), null);
        if (!ds.PrvCreate)
        {
          
        }
        TuUserApproval userApproval = new TuUserFactory().GetApproval(App.Params.CurrentUser.SystemUserId);
        //Hesaptan para çekme yetkisi yoksa
        if (!userApproval.CustAccountWithdraw)
        {
         
        }
        //Hesaba Para Yatırma yetkisi yoksa
        if (!userApproval.CustAccountDeposit)
        {
           
        }

        //if(!userApproval.CustAccountWithdraw && !userApproval.CustAccountDeposit)
        //{
        //    btnRefresh.Hide();
        //}
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

        new_CustAccountTypeId.EmptyText =
        new_SenderId.EmptyText =
      
       
        new_CustAccountTypeId.EmptyText =
        new_CustAccountTypeId.EmptyText =
       
    
         CrmLabel.TranslateMessage("CRM.ENTITY_FILTER_EMPTY_TEXT");
        btnRefresh.Text = CrmLabel.TranslateMessage("CRM_TOOLSEARCH");

    }

    private string GetListName()
    {
        return "CustAccountOperationHeaderView";
       //throw new Exception(string.Format(CrmLabel.TranslateMessage("CRM.ENTITY_NEEDS_PERMISSION"), "RegionalManager,SalesManager,Administrator,PricingManager,Dealer"));

    }

    protected override void OnInit(EventArgs e)
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGridModels(GetListName(), gpCustAccountOperationHeader, true);
        base.OnInit(e);
    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid(GetListName(), gpCustAccountOperationHeader, true);
    }

    protected void gpCustAccountOperationHeaderRowSelect(object sender, AjaxEventArgs e)
    {
        var orderheaderId = GetSelectedOrderHeaderId();
        //var status = CustAccountOperationBusiness.GetCustAccountOperationStatus(orderheaderId);

    }

    protected void GpCustAccountOperationHeaderReload(object sender, AjaxEventArgs e)
    {
        TuUserApproval userApproval = new TuUserFactory().GetApproval(App.Params.CurrentUser.SystemUserId);
        var sd = new StaticData();
        var sort = gpCustAccountOperationHeader.ClientSorts() ?? string.Empty;
        string strSql = @"  SELECT New_CustAccountOperationsHeaderId AS ID ,  CustAccountOperationsHeaderRef AS VALUE, 
 new_TransferType,new_TransferTypeName,tnr.CreatedOn,CreatedOnUtcTime,tnr.CreatedBy,tnr.CreatedByName,
 New_CustAccountOperationsHeaderId,CustAccountOperationsHeaderRef,
 new_SenderCustAccountOperationsId,new_SenderCustAccountOperationsIdName,
 new_ReceiverCustAccountOperationsId,new_ReceiverCustAccountOperationsIdName,
 new_SenderAccountId,new_SenderAccountIdName,
 new_ReceiverAccountId,new_ReceiverAccountIdName,new_SendAmount,
                                new_SendAmountCurrencyName AS new_SendAmount_CurrencyName,
                               new_RecipientAmount,new_RecipientAmountCurrencyName AS new_RecipientAmount_CurrencyName,
							   new_OriginalParity,new_MarginParity
                            FROM nltvNew_CustAccountOperationsHeader(@SystemUserId) tnr 
							INNER JOIN vNew_CustAccounts(nolock) sca ON sca.New_CustAccountsId = tnr.new_SenderAccountId
							INNER JOIN vNew_CustAccounts(nolock) rca ON rca.New_CustAccountsId = tnr.new_ReceiverAccountId
WHERE 1=1 AND tnr.DeletionStateCode=0   ";
        ////Nakit Çekme/Yatırma Yetkisi var ise
        //if (userApproval.CustAccountWithdraw && userApproval.CustAccountDeposit)
        //{
        //    strSql += " AND (vncaot.new_EXTCODE = '010' OR vncaot.new_EXTCODE = '011')";
        //}
        ////Sadece Nakit Çekme Yatkisi var ise
        //if (userApproval.CustAccountWithdraw && !userApproval.CustAccountDeposit)
        //{
        //    strSql += " AND (vncaot.new_EXTCODE = '003')";
        //}
        ////Sadece Nakit Yatırma Yatkisi var ise
        //if (!userApproval.CustAccountWithdraw && userApproval.CustAccountDeposit)
        //{
        //    strSql += " AND (vncaot.new_EXTCODE = '002')";
        //}

        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var spList = new List<CrmSqlParameter>();


        //if (!string.IsNullOrEmpty(new_CustAccountTypeId.Value))
        //{
        //    strSql += " AND tnr.new_CustAccountTypeId=@new_CustAccountTypeId ";
        //    spList.Add(
        //        new CrmSqlParameter
        //        {
        //            Dbtype = DbType.Guid,
        //            Paramname = "new_CustAccountTypeId",
        //            Value = ValidationHelper.GetGuid(new_CustAccountTypeId.Value)
        //        }
        //        );
        //}

        if (!string.IsNullOrEmpty(new_SenderId.Value))
        {
            strSql += " AND (sca.new_SenderId=@new_SenderId OR rca.new_SenderId=@new_SenderId ) ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_SenderId",
                    Value = ValidationHelper.GetGuid(new_SenderId.Value)
                }
                );
        }

        if (!string.IsNullOrEmpty(new_TransferType.Value))
        {
            strSql += " AND tnr.new_TransferType=@new_TransferType ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Int32,
                    Paramname = "new_TransferType",
                    Value = ValidationHelper.GetInteger(new_TransferType.Value)
                }
                );
        }
        //if (!string.IsNullOrEmpty(new_CustAccountOperationTypeId.Value))
        //{
        //    strSql += " AND tnr.new_CustAccountOperationTypeId=@new_CustAccountOperationTypeId ";
        //    spList.Add(
        //        new CrmSqlParameter
        //        {
        //            Dbtype = DbType.Guid,
        //            Paramname = "new_CustAccountOperationTypeId",
        //            Value = ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value)
        //        }
        //        );
        //}
        //if (!string.IsNullOrEmpty(new_CorporationId.Value))
        //{
        //    strSql += " AND tnr.new_CorporationId=@new_CorporationId ";
        //    spList.Add(
        //        new CrmSqlParameter
        //        {
        //            Dbtype = DbType.Guid,
        //            Paramname = "new_CorporationId",
        //            Value = ValidationHelper.GetGuid(new_CorporationId.Value)
        //        }
        //        );
        //}
        //if (!string.IsNullOrEmpty(new_OfficeId.Value))
        //{
        //    strSql += " AND tnr.new_OfficeId=@new_OfficeId ";
        //    spList.Add(
        //        new CrmSqlParameter
        //        {
        //            Dbtype = DbType.Guid,
        //            Paramname = "new_OfficeId",
        //            Value = ValidationHelper.GetGuid(new_OfficeId.Value)
        //        }
        //        );
        //}
        if (CreatedOnS.Value.HasValue)
        {
            strSql += " AND tnr.CreatedOnUtcTime>=@CreatedOns";
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

            strSql += " AND tnr.CreatedOnUtcTime<=DATEADD(day,1,@CreatedOnE)";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.Date,
                    Paramname = "CreatedOnE",
                    Value = CreatedOnEe
                }
                );
        }
        var gpc = new GridPanelCreater();

        int cnt;
        var start = gpCustAccountOperationHeader.Start();
        var limit = gpCustAccountOperationHeader.Limit();
        var dtb = new DataTable();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb, false);
        gpCustAccountOperationHeader.TotalCount = cnt;

        this.dtCustAccountsTransaction = dtb;

        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null &&
            ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
            gpw.Export(dtb);
        }

        gpCustAccountOperationHeader.DataSource = t;
        gpCustAccountOperationHeader.DataBind(); ;
    }

    DataTable dtCustAccountsTransaction
    {
        get
        {
            return Session["CustomerAccounts"] as DataTable;
        }
        set
        {
            Session["CustomerAccounts"] = value;
        }
    }

    protected void ExportToExcel(object sender, AjaxEventArgs e)
    {
        var n = string.Format("Hesaplar Arası Transfer_{0:yyyy_MM_dd_hh_mm_ss}.xls", DateTime.Now);
        Export.ExportDownloadData(dtCustAccountsTransaction, n);
    }

    protected void btnConfirm_OnClick(object sender, AjaxEventArgs e)
    {
       
    }

    protected void BtnOrderDetail_OnClick(object sender, AjaxEventArgs e)
    {
        throw new NotImplementedException();
    }

    protected void btnReject_OnClick(object sender, AjaxEventArgs e)
    {


    }

    protected void BtnSendToConfirmAgainClick(object sender, AjaxEventArgs e)
    {
       
    }

    protected void BtnSendToCOD_Click(object sender, AjaxEventArgs e)
    {
        
    }


}