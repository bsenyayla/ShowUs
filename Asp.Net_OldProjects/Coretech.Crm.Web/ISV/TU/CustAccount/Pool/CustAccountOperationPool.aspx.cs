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

public partial class CustAccount_Pool_CustAccountOperationPool : BasePage
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
    private TuUser _activeUser = null;

    private void SetDefaults()
    {
        var ufFactory = new TuUserFactory();
        _activeUser = ufFactory.GetActiveUser();
        CreatedOnS.Value=DateTime.Now.Date;
    }

    private void PrepareItems()
    {

        var ds = DynamicFactory.GetSecurity(TuEntityEnum.New_CustAccountOperations.GetHashCode(), null);
        //if (!ds.PrvCreate)
        //{
        //    btnAddNewCustAccountOperation.Hide();
        //    //  BtnCreateTender.Hide();
        //}

        TuUserApproval userApproval = new TuUserFactory().GetApproval(App.Params.CurrentUser.SystemUserId);
        //Hesap açma yetkisi yoksa
        //if(!userApproval.CustAccountOpenAccount)
        //{
        //    btnAddNewCustAccountOperation.Hide();
        //}
        //Hesap kapama yetkisi yoksa
        if(!userApproval.CustAccountCloseAccount)
        {
            btnDeleteNewCustAccountOperation.Hide();
        }
        ////Hem Hesap Açma hem Hesap Kapama yetkisi yok ise Arama butonu kaldırılır.
        //if(!userApproval.CustAccountOpenAccount && !userApproval.CustAccountCloseAccount)
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
        new_CustAccountOperationTypeId.EmptyText =   
        new_CustAccountTypeId.EmptyText =
        new_CustAccountTypeId.EmptyText =
        new_CustAccountCurrencyId.EmptyText =
         CrmLabel.TranslateMessage("CRM.ENTITY_FILTER_EMPTY_TEXT");
        btnRefresh.Text = CrmLabel.TranslateMessage("CRM_TOOLSEARCH");
        btnDeleteNewCustAccountOperation.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_DELETE_ACCOUNT");
        //btnAddNewCustAccountOperation.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_CREATE_ACCOUNT");
    }

    private string GetListName()
    {
        return "CUSTACCOUNT_OPERATIONS_LIST";
        //if (Conti.ActiveUser.UserRoleList.ContainsKey(UserRoleKeyName.SalesManager) || Conti.ActiveUser.UserRoleList.ContainsKey(UserRoleKeyName.PricingManager))
        //    return CustAccountOperationConstants.ContiSales;
        //if (Conti.ActiveUser.UserRoleList.ContainsKey(UserRoleKeyName.RegionalManager))
        //    return CustAccountOperationConstants.Region;
        //if (Conti.ActiveUser.UserRoleList.ContainsKey(UserRoleKeyName.Dealer))
        //    return CustAccountOperationConstants.Dealer;
        //if (Conti.ActiveUser.UserRoleList.ContainsKey(UserRoleKeyName.Cod))
        //    return CustAccountOperationConstants.ContiSales;

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
        string strSql = @" SELECT New_CustAccountOperationsId AS ID ,
       CustAccountOperationName AS VALUE, 
       new_AmountCurrencyName AS new_Amount_CurrencyName,
       new_CalculatedExpenseAmountCurrencyName AS new_CalculatedExpenseAmount_CurrencyName,
       new_ExpenseAmountCurrencyName AS new_ExpenseAmount_CurrencyName,
       new_ReceivedAmount1CurrencyName AS new_ReceivedAmount1_CurrencyName,
       new_ReceivedAmount2CurrencyName AS new_ReceivedAmount2_CurrencyName,
       new_ReceivedExpenseAmountCurrencyName AS new_ReceivedExpenseAmount_CurrencyName,
       new_TotalReceivedAmountCurrencyName AS new_TotalReceivedAmount_CurrencyName,
       ca.CustAccountNumber,
       tnr.* 
       FROM tvNew_CustAccountOperations(@SystemUserId) tnr
       INNER JOIN vNew_CustAccounts ca ON ca.New_CustAccountsId = tnr.new_CustAccountId  
	   INNER JOIN vNew_CustAccountOperationType vncaot ON tnr.new_CustAccountOperationTypeId=vncaot.New_CustAccountOperationTypeId
       WHERE 1=1 AND tnr.StatusCode=1  AND vncaot.DeletionStateCode=0 AND vncaot.statuscode=1";

        #region Hesap Kapatma/Açma Yetkisi
        //Sadece Hesap Açma
        if (userApproval.CustAccountOpenAccount && !userApproval.CustAccountCloseAccount)
            strSql += " AND (vncaot.new_EXTCODE = '001') "; //Hesap Açma
        //Sadece Hesap Kapatma
        else if (userApproval.CustAccountCloseAccount && !userApproval.CustAccountOpenAccount)
            strSql += " AND (vncaot.new_EXTCODE = '004') "; //Hesap Kapatma
        //Hem Hesap Kapatma Hem Hesap Açma
        else if (userApproval.CustAccountCloseAccount && userApproval.CustAccountOpenAccount)
            strSql += " AND (vncaot.new_EXTCODE = '004' OR vncaot.new_EXTCODE = '001') "; 
        #endregion

        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var spList = new List<CrmSqlParameter>();


        if (!string.IsNullOrEmpty(new_CustAccountTypeId.Value))
        {
            strSql += " AND tnr.new_CustAccountTypeId=@new_CustAccountTypeId ";
            spList.Add(
                new CrmSqlParameter()
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_CustAccountTypeId",
                    Value = ValidationHelper.GetGuid(new_CustAccountTypeId.Value)
                }
                );
        }

        if (!string.IsNullOrEmpty(new_SenderId.Value))
        {
            strSql += " AND tnr.new_SenderId=@new_SenderId ";
            spList.Add(
                new CrmSqlParameter()
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_SenderId",
                    Value = ValidationHelper.GetGuid(new_SenderId.Value)
                }
                );
        }
        if (!string.IsNullOrEmpty(new_CustAccountOperationTypeId.Value))
        {
            strSql += " AND tnr.new_CustAccountOperationTypeId=@new_CustAccountOperationTypeId ";
            spList.Add(
                new CrmSqlParameter()
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_CustAccountOperationTypeId",
                    Value = ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value)
                }
                );
        }
       
        if (CreatedOnS.Value.HasValue)
        {
            strSql += " AND tnr.CreatedOnUtcTime>=@CreatedOns";
            var CreatedOnSs = sd.FnLocalTimeToUtcForUser(CreatedOnS.Value.Value, App.Params.CurrentUser.SystemUserId);
            spList.Add(
                new CrmSqlParameter()
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
                new CrmSqlParameter()
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

        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null &&
            ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
            gpw.Export(dtb);
        }

        gpCustAccountOperationHeader.DataSource = t;
        gpCustAccountOperationHeader.DataBind(); ;
    }

    protected void btnConfirm_OnClick(object sender, AjaxEventArgs e)
    {
        try
        {
            var newCustAccountOperationId = GetSelectedOrderHeaderId();
            //CustAccountOperationBusiness.ConfirmCustAccountOperationOrder(newCustAccountOperationId, new_Comment.Value);
            //ContiBase.Alert("CRM.NEW_CustAccountOperation_CONFIRMED");
        }

        catch (TuException exc)
        {

            //ContiBase.Alert(exc.StrErrorContainer);
        }
    }

    protected void BtnOrderDetail_OnClick(object sender, AjaxEventArgs e)
    {
        throw new NotImplementedException();
    }

    protected void btnReject_OnClick(object sender, AjaxEventArgs e)
    {


        try
        {
            var newCustAccountOperationId = GetSelectedOrderHeaderId();
            //CustAccountOperationBusiness.ConRejectCustAccountOperationOrder(newCustAccountOperationId, new_Comment.Value);
            //ContiBase.Alert("CRM.NEW_CustAccountOperation_REJECTED");
        }
        catch (TuException exc)
        {
            //ContiBase.Alert(exc.StrErrorContainer);

        }
    }

    protected void BtnSendToConfirmAgainClick(object sender, AjaxEventArgs e)
    {
        try
        {
            var newCustAccountOperationId = GetSelectedOrderHeaderId();
            //CustAccountOperationBusiness.SendToConfirm(newCustAccountOperationId);
        }
        catch (TuException exc)
        {
            //ContiBase.Alert(exc.StrErrorContainer, ContiBase.MessageType.Warning);

        }
    }

    protected void BtnSendToCOD_Click(object sender, AjaxEventArgs e)
    {
        try
        {
            var newCustAccountOperationId = GetSelectedOrderHeaderId();
            //CustAccountOperationBusiness.SendToCOD(newCustAccountOperationId);
        }
        catch (TuException exc)
        {
            //ContiBase.Alert(exc.StrErrorContainer, ContiBase.MessageType.Warning);
        }
    }


}