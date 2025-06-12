using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using Newtonsoft.Json;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using TuFactory.CustAccount.Business;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;

public partial class CustAccount_Pool_UptCardTransactionPool : BasePage
{

    protected override void OnInit(EventArgs e)
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGridModels(GetListName(), gpUptCardOperationHeader, true);
        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            RR.RegisterIcon(Icon.Add);
            CreateViewGrid();
            //new_CustAccountTypeId.SetValue(Conti.ActiveUser.UserDealerId.ToString());
            AddMessages();
            SetDefaults();
        }
    }

    private TuUser _activeUser;
    private void SetDefaults()
    {
        var ufFactory = new TuUserFactory();
        _activeUser = ufFactory.GetActiveUser();
        new_CorporationId.Value = _activeUser.CorporationId.ToString();
        new_OfficeId.Value = _activeUser.OfficeId.ToString();
        CreatedOnS.Value = DateTime.Now.Date;
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

        new_SenderId.EmptyText =
        new_CorporationId.EmptyText =
        new_OfficeId.EmptyText =
        new_CustAccountCurrencyId.EmptyText =
        new_CustAccountOperationTypeId.EmptyText =
         CrmLabel.TranslateMessage("CRM.ENTITY_FILTER_EMPTY_TEXT");
        btnRefresh.Text = CrmLabel.TranslateMessage("CRM_TOOLSEARCH");
        btnTransferToUptCard.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_TRANSFER_TO_UPTCARD");
    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid(GetListName(), gpUptCardOperationHeader, true);
    }

    private string GetListName()
    {
        return "CUSTACCOUNT_UPT_CARD_TRANSACTION_LIST";
    }

    protected void GpUptCardOperationHeaderReload(object sender, AjaxEventArgs e)
    {
        var sort = gpUptCardOperationHeader.ClientSorts() ?? string.Empty;
        CustAccountOperations custOperations = new CustAccountOperations();
        string sql = custOperations.GetUptCardOperationsSelectSql();
        List<CrmSqlParameter> sqlParameters = custOperations.GetUptCardOperationsSelectParameters(ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value)
                , ValidationHelper.GetGuid(new_SenderId.Value), ValidationHelper.GetGuid(new_CustAccountCurrencyId.Value),ValidationHelper.GetGuid(new_CorporationId.Value)
                , ValidationHelper.GetGuid(new_OfficeId.Value), CreatedOnS.Value, CreatedOnE.Value, ref sql);

        var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var gpc = new GridPanelCreater();
        int cnt;
        var start = gpUptCardOperationHeader.Start();
        var limit = gpUptCardOperationHeader.Limit();
        var dtb = new DataTable();
        var t = gpc.GetFilterData(sql, viewqueryid, sort, sqlParameters, start, limit, out cnt, out dtb, false);
        gpUptCardOperationHeader.TotalCount = cnt;

        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null &&
            ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
            gpw.Export(dtb);
        }

        gpUptCardOperationHeader.DataSource = t;
        gpUptCardOperationHeader.DataBind(); ;
    }
}