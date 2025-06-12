using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
//using Coretech.Crm.Web.UI;
using System;
using System.Collections.Generic;

using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Object;

public partial class Accounting_OfficeAccounts : BasePage
{
    #region Page Events

    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
        }
        base.OnPreInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            CreateViewGrid();
            OfficeLoad(null, null);
            List<Dictionary<string, object>> officeData = New_OfficeId.DataSource as List<Dictionary<string, object>>;
            if (officeData != null && officeData.Count > 0)
            {
                New_OfficeId.SetValue(officeData[0]["ID"], officeData[0]["VALUE"]);
            }
        }
    }

    #endregion

    #region Control Events

    protected void OfficeLoad(object sender, AjaxEventArgs e)
    {
        string sql = @"SELECT Distinct O.New_OfficeId AS ID,
                OfficeName AS VALUE,
                OfficeName,
                new_CorporationIDName	   
            FROM tvNew_Office(@SystemUser) O
            INNER JOIN vNew_OfficeAccount OA ON OA.new_OfficeId=O.New_OfficeId            
            where O.DeletionStateCode=0 AND OA.DeletionStateCode=0 ";

        const string sort = "";
        var like = New_OfficeId.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("OFFICE_LOOKUP2");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = New_OfficeId.Start();
        var limit = New_OfficeId.Limit();
        var spList = new List<CrmSqlParameter>()
        {
		    new CrmSqlParameter
			{
				Dbtype = DbType.Guid,
				Paramname = "SystemUser",
				Value = App.Params.CurrentUser.SystemUserId
			}                   
		};

        if (!string.IsNullOrEmpty(like))
        {
            sql += " AND O.OfficeName LIKE @OfficeName + '%' ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.String,
                    Paramname = "OfficeName",
                    Value = like
                });
        }

        var t = gpc.GetFilterData(sql, viewqueryid, sort, spList, start, limit, out cnt);
        New_OfficeId.TotalCount = cnt;
        New_OfficeId.DataSource = t;
        New_OfficeId.DataBind();
    }

    protected void BtnAraClick(object sender, AjaxEventArgs e)
    {
        BindData();
    }

    #endregion

    #region Methods

    private void TranslateMessage()
    {
        ToolbarButtonFind.Text = CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_BTNARA");
        //ToolbarButtonClear.Text = CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_BTNTEMIZLE");
        pnlSEARCHGeneral.Title = CrmLabel.TranslateMessage("CRM.NEW_OFFICEACCOUNT_BALANCE_LIST_TITLE");
    }

    private void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("OFFICE_ACCOUNT_BALANCE_LIST", GridPanelPayments);
        string strSelected;
        strSelected = ViewFactory.GetViewIdbyUniqueName("OFFICE_ACCOUNT_BALANCE_LIST").ToString();
        hdnViewList.Value = strSelected;

        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
        var DefaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnViewDefaultEditPage.Value = DefaultEditPage;
    }

    private void BindData()
    {
        string strSql = @"
           SELECT DISTINCT          
            oa.New_OfficeAccountId ID,
            oa.OfficeAccount VALUE,
            oa.new_OfficeIdName,
            oa.new_OperationTypeName,
            oa.new_CurrencyIdName,
            oa.new_IBAN,
            oa.OfficeAccount,    
            ISNULL(oa.new_Balance, 0) new_Balance
        FROM tvNew_OfficeAccount(@SystemUser) oa
        WHERE oa.DeletionStateCode = 0 
        AND oa.new_OfficeId = @OfficeId";

        var spList = new List<CrmSqlParameter>();

        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("OFFICE_ACCOUNT_BALANCE_LIST");
        var sort = string.Empty;

        spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "SystemUser", Value = App.Params.CurrentUser.SystemUserId });
        spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "OfficeId", Value = ValidationHelper.GetGuid(New_OfficeId.Value) });

        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelPayments.Start();
        var limit = GridPanelPayments.Limit();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        SetBalances(t);
        GridPanelPayments.TotalCount = cnt;

        GridPanelPayments.DataSource = t;
        GridPanelPayments.DataBind();
    }

    private void SetBalances(List<Dictionary<string, object>> data)
    {
        try
        {
            if (data != null && data.Count > 0)
            {
                TuFactory.WebServicesRemote.AccountBalance accountBalanceFactory = new TuFactory.WebServicesRemote.AccountBalance();
                WSAccountBalanceList accountBalanceList = new WSAccountBalanceList() { HESAP_LISTESI = new List<WSAccountBalance>() };
                for (int i = 0; i < data.Count; i++)
                {
                    WSAccountBalance accountBalance = new WSAccountBalance() { HESAP_NO = data[i]["VALUE"].ToString() };
                    accountBalanceList.HESAP_LISTESI.Add(accountBalance);
                }
                WSAccountBalanceList retAccountBalanceList = accountBalanceFactory.GetAccountBalance(accountBalanceList);
                if (retAccountBalanceList.Status.RESPONSE == WsStatus.response.Success)
                {
                    if (retAccountBalanceList.HESAP_LISTESI != null && retAccountBalanceList.HESAP_LISTESI.Count > 0)
                    {
                        for (int j = 0; j < data.Count; j++)
                        {
                            for (int i = 0; i < retAccountBalanceList.HESAP_LISTESI.Count; i++)
                            {

                                if (retAccountBalanceList.HESAP_LISTESI[i].HESAP_NO == data[j]["VALUE"].ToString())
                                {
                                    data[j]["new_Balance"] = retAccountBalanceList.HESAP_LISTESI[i].BAKIYE;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        catch
        {

        }
    }

    #endregion
}