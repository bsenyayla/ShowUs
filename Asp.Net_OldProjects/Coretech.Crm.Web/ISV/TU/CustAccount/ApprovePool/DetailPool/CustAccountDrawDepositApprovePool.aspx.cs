using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.CustAccount.Business.Service;
using TuFactory.CustAccount.Object;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;


public partial class CustAccount_ApprovePool_DetailPool_CustAccountDrawDepositApprovePool :BasePage
{
    CustAccountApprovePoolService approvePoolService = new CustAccountApprovePoolService();
    protected override void OnInit(EventArgs e)
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGridModels(GetListName(), gpCustAccountOperationHeader, true);
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
    protected void GpCustAccountOperationHeaderReload(object sender, AjaxEventArgs e)
    {
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        var spList = new List<CrmSqlParameter>();
        string strFilterSql = approvePoolService.GetFiltersForCustAccountTransactionApproveList(out spList, new_CustAccountTypeId, new_SenderId
            , new_CustAccountOperationTypeId, new_CorporationId, new_OfficeId, CreatedOnS, CreatedOnE, new_CustAccountApprovePoolStatusRef);
        GridDataResponse gdr = approvePoolService.GetCustAccountTransactionApproveList(gpCustAccountOperationHeader, viewqueryid, strFilterSql, spList);
        gpCustAccountOperationHeader.TotalCount = gdr.TotalRecordCount;
        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null &&
            ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
            gpw.Export(gdr.Data);
        }
        gpCustAccountOperationHeader.DataSource = gdr.GridData;
        gpCustAccountOperationHeader.DataBind();
    }
    private TuUser _activeUser = null;

    private void SetDefaults()
    {
        var ufFactory = new TuUserFactory();
        _activeUser = ufFactory.GetActiveUser();
        new_CorporationId.Value = _activeUser.CorporationId.ToString();
        new_OfficeId.Value = _activeUser.OfficeId.ToString();
        CreatedOnS.Value = DateTime.Now.Date;
        new_CustAccountApprovePoolStatusRef.Value = approvePoolService.GetApprovePoolStatusId(CustAccountApprovePoolStatus.WaitingApproval).ToString();
    }
    private void AddMessages()
    {
        CreatedOnmf.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("CreatedOn",
            TuEntityEnum.New_CustAccountOperations.GetHashCode());
        mfsender.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_SenderId",
            TuEntityEnum.New_CustAccountOperations.GetHashCode());
        new_CustAccountTypeId.EmptyText =
        new_SenderId.EmptyText =
        new_CustAccountOperationTypeId.EmptyText =
        new_CorporationId.EmptyText =
        new_CustAccountTypeId.EmptyText =
        new_CustAccountTypeId.EmptyText =
        new_OfficeId.EmptyText =
        new_CustAccountCurrencyId.EmptyText =
        new_CustAccountApprovePoolStatusRef.EmptyText =
         CrmLabel.TranslateMessage("CRM.ENTITY_FILTER_EMPTY_TEXT");
        btnRefresh.Text = CrmLabel.TranslateMessage("CRM_TOOLSEARCH");
    }
    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid(GetListName(), gpCustAccountOperationHeader, true);
    }
    private string GetListName()
    {
        return "CUSTACCOUNT_OPERATIONS_APPROVEPOOL_DEPOSIT_WITHDRAW_LIST";
    }

}