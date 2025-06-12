using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Object.User;

public partial class Cash_CashBalanceReload : BasePage
{
    private TuUserApproval _userApproval = null;

    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {

        }
        base.OnPreInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {

        if (App.Params.CurrentUser.SystemUserId != ValidationHelper.GetGuid("00000000-AAAA-BBBB-CCCC-000000000001"))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Role PrvCreate,PrvDelete,PrvWrite");
        }
    }

    protected void BtnReloadBalanceClick(object sender, EventArgs e)
    {
        var sd = new StaticData();

        var selct = @"spResetCashBalance";
        if (!string.IsNullOrEmpty(New_CashId.Value))
        {
            sd.AddParameter("CCashId", DbType.Guid, ValidationHelper.GetGuid(New_CashId.Value));
        }
        try
        {
            sd.ExecuteNonQuerySp("spResetCashBalance");
            QScript("alert('Yenileme işlemi tamamlandı.');");
        }
        catch (Exception ex)
        {
            QScript("alert('" + ex.Message + "');");
        }






    }

    protected void new_CashNameIDonEvent(object sender, AjaxEventArgs e)
    {
        const string strSql = @"select new_CashId ID,new_CashId,CashName VALUE,CashName,new_OfficeNameName Office from vNew_Cash where DeletionStateCode=0";
        const string sort = "";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CashLookup");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = New_CashId.Start();
        var limit = New_CashId.Limit();
        var spList = new List<CrmSqlParameter>();




        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        New_CashId.TotalCount = cnt;
        New_CashId.DataSource = t;
        New_CashId.DataBind();
    }

    protected void new_TransactionTypeChange(object sender, AjaxEventArgs e)
    {

    }





}