using System;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object.User;
using TuFactory.TuUser;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Web.UI.RefleX.View;
using Coretech.Crm.Factory.Exporter;

public partial class Account_Monitoring : BasePage
{
    #region Variables

    private DynamicSecurity _dynamicSecurityTransfer;
    private DynamicSecurity _dynamicSecurityPayment;
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };

    #endregion

    private void TranslateMessages()
    {


    }

    protected void GridPanelMainAccountOnEvent(object sender, AjaxEventArgs e)
    {
        MainGridSelectedRow.Clear();
        //GridPanelMainAccountDetail.Reload();
        DataTable dt = new DataTable();
        var sd = new StaticData();
        string sql = @"Select  ac.New_AccountsId AS new_AccountId,
	                          ac.new_AccountNo,
	                          ac.new_BalanceCurrency AS new_CurrencyId,
	                          ac.new_BalanceCurrencyName AS new_CurrencyIdName,
                              ac.AccountNumber AS new_AccountNumber ,
	                          ISNULL(ac.new_Balance,0) AS new_Balance,
                            ISNULL(ac.new_MinimumBalance,0) AS new_MinimumBalance,
                            ISNULL(AL.new_Limit,0) AS new_Limit,
                            ISNULL(ac.new_Balance,0) - ISNULL(ac.new_MinimumBalance,0) + ISNULL(AL.new_Limit,0) AS new_UsableBalance,

                            ISNULL(TBL.new_Balance,0) AS new_TotalBalance,
                            ISNULL(TBL.new_MinimumBalance,0) AS new_TotalMinimumBalance,
                            ISNULL(TBL.new_Limit,0) AS new_TotalLimit,
                            (ISNULL(TBL.new_UsableBalance, 0)) AS new_TotalUsableBalance
                        From vNew_Accounts (NOLOCK) ac
						INNER JOIN 
						(
							Select DISTINCT ac.new_ParentAccountId,SUM(ISNULL(ac.new_Balance,0)) AS new_Balance,
							SUM(ISNULL(ac.new_MinimumBalance,0)) AS new_MinimumBalance,
							SUM(ISNULL(AL.new_Limit,0)) AS new_Limit,
							SUM(ISNULL(ac.new_Balance,0) - ISNULL(ac.new_MinimumBalance,0) + ISNULL(AL.new_Limit,0))  AS new_UsableBalance
							From vNew_Accounts (NOLOCK) ac
							LEFT JOIN vNew_AccountLimit (NOLOCK) AL ON ac.New_AccountsId = AL.new_Account AND AL.DeletionStateCode = 0
							WHERE ac.DeletionStateCode=0 
							GROUP BY ac.new_ParentAccountId
						)  TBL ON TBL.new_ParentAccountId = ac.New_AccountsId
                        INNER JOIN vNew_PrivilegedAccounts (NOLOCK) pa ON pa.new_AccountId = ac.New_AccountsId
                        LEFT JOIN vNew_AccountLimit AL ON ac.New_AccountsId = AL.new_Account AND AL.DeletionStateCode = 0
                        WHERE pa.DeletionStateCode=0 and ac.DeletionStateCode=0 AND pa.new_AccountType IN (2)";
      




        dt = sd.ReturnDataset(sql).Tables[0];

        GridPanelMainAccount.DataSource = dt;
        GridPanelMainAccount.TotalCount = dt.Rows.Count;
        GridPanelMainAccount.DataBind();
    }

    protected void GridPanelMainAccountDetailOnEvent(object sender, AjaxEventArgs e)
    {
        DataTable dt = new DataTable();
        var sd = new StaticData();
        string sql = @"Select DISTINCT ac.New_AccountsId AS new_AccountId,
	                          ac.new_AccountNo,
	                          ac.new_BalanceCurrency AS new_CurrencyId,
	                          ac.new_BalanceCurrencyName AS new_CurrencyIdName,
							  CORP.New_CorporationId,
							  ISNULL(CORP.CorporationName,Office.OfficeName) AS new_CorporationIdName,                              
                              ac.AccountNumber AS new_AccountNumber  ,
	                          ISNULL(ac.new_Balance,0) AS new_Balance,
                            ISNULL(ac.new_MinimumBalance,0) AS new_MinimumBalance,
                            ISNULL(AL.new_Limit,0) AS new_Limit,
                            (ISNULL(ac.new_Balance,0) - ISNULL(ac.new_MinimumBalance,0) + ISNULL(AL.new_Limit,0))  AS new_UsableBalance,
                            convert(NVARCHAR, new_LastBalanceUpdateTime, 120) AS new_LastBalanceUpdateTime
                        From vNew_Accounts (NOLOCK) ac
                        LEFT JOIN vNew_AccountLimit (NOLOCK) AL ON ac.New_AccountsId = AL.new_Account AND AL.DeletionStateCode = 0
						LEFT JOIN vNew_CorporationAccount (NOLOCK) CA On CA.new_AccountId = ac.New_AccountsId And CA.DeletionStateCode = 0
						LEFT JOIN vNew_Corporation (NOLOCK) CORP On CORP.New_CorporationId = CA.new_CorparationID and CORP.DeletionStateCode = 0
                        LEFT JOIN vNew_OfficeAccount (NOLOCK) OA On OA.new_AccountId = ac.New_AccountsId And OA.DeletionStateCode = 0
						LEFT JOIN vNew_Office (NOLOCK) Office On Office.New_OfficeId = OA.new_OfficeID and Office.DeletionStateCode = 0
                        WHERE ac.DeletionStateCode=0 AND ac.new_ParentAccountId =@AccountId ";

        sd.AddParameter("AccountId", DbType.Guid, ValidationHelper.GetGuid(MainGridSelectedRow.Value));

        if (!string.IsNullOrEmpty(new_CorporationId.Value))
        {
            sql += " AND (CORP.New_CorporationId=@CorporationId OR Office.new_CorporationID =@CorporationId) ";
            sd.AddParameter("CorporationId", DbType.Guid, ValidationHelper.GetGuid(new_CorporationId.Value));
        }

        if (!string.IsNullOrEmpty(AccountNo.Value))
        {
            sql += @" AND ac.New_AccountNo LIKE '%" + AccountNo.Value + "%'";
            //sd.AddParameter("AccountNo", DbType.String, AccountNo.Value);
        }
        sql += " ORDER BY 6";

        dt = sd.ReturnDataset(sql).Tables[0];


        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {
            if (dt.Rows.Count > 0)
            {
                var n = string.Format("Hesap Bakiye Detay-{0:yyyy-MM-dd_hh-mm-ss-tt}.xls", DateTime.Now);
                Export.ExportDownloadData(dt, n);
            }
        }

        GridPanelMainAccountDetail.DataSource = dt;
        GridPanelMainAccountDetail.TotalCount = dt.Rows.Count;
        GridPanelMainAccountDetail.DataBind();
    }

    protected void SearchOnEvent(object sender, AjaxEventArgs e)
    {
        GridPanelMainAccountOnEvent(sender, e);
    }

    protected void RowClickOnEvent(object sender, AjaxEventArgs e)
    {
        GridPanelMainAccountDetailOnEvent(sender, e);
    }

    //protected void DetailRowClickOnEvent(object sender, AjaxEventArgs e)
    //{
    //    GridPanelAccountBalanceHistoryOnEvent(sender, e);
    //}



    protected void CorporationChangeOnEvent(object sender, AjaxEventArgs e)
    {
        GridPanelMainAccountDetailOnEvent(sender, e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        _activeUser = ufFactory.GetActiveUser();
        if (!RefleX.IsAjxPostback)
        {
            AccountTransactionDate1.Value = DateTime.Now;
            AccountTransactionDate2.Value = DateTime.Now;

            //BtnSearch.Focus();          

        }
    }

    protected void GridPanelAccountBalanceHistoryOnEvent(object sender, AjaxEventArgs e)
    {

        if (AccountTransactionDate1.Value == null || AccountTransactionDate2.Value == null)
        {
            var msg = "Tarih aralığı girmelisiniz";
            var m = new MessageBox { Width = 400, Height = 180 };

            m.Show(msg);
            return;
        }

        DataTable dt = new DataTable();
        var sd = new StaticData();
        sd.AddParameter("@AccountId", DbType.Guid, ValidationHelper.GetGuid(DetailGridSelectedRow.Value));
        sd.AddParameter("@date1", DbType.DateTime, ValidationHelper.GetDate(AccountTransactionDate1.Value));
        sd.AddParameter("@date2", DbType.DateTime, ValidationHelper.GetDate(AccountTransactionDate2.Value));
        dt = sd.ReturnDatasetSp("spTUGetAccountBalanceHistory").Tables[0];


        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {
            if (dt.Rows.Count > 0)
            {
                var n = string.Format("Hesap hareket listesi-{0:yyyy-MM-dd_hh-mm-ss-tt}.xls", DateTime.Now);
                Export.ExportDownloadData(dt, n);
            }
        }


        GridPanelAccountBalanceHistory.DataSource = dt;
        GridPanelAccountBalanceHistory.TotalCount = dt.Rows.Count;
        GridPanelAccountBalanceHistory.DataBind();
    }

    protected void CorporationLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"Select DISTINCT crp.New_CorporationId AS ID,
                        CorporationName AS VALUE,
                        crp.New_CorporationId,
                        CorporationName ,
                        new_CorporationCode
                        From vNew_Corporation crp (NOLOCK)
                        INNER JOIN vNew_CorporationAccount ca ON ca.new_CorparationID = crp.New_CorporationId
                        INNER JOIN vNew_Accounts ac ON ac.New_AccountsId = ca.new_AccountId
                        INNER JOIN vNew_Accounts pac ON pac.New_AccountsId =ac.new_ParentAccountId
                        WHERE ac.DeletionStateCode=0 and ca.DeletionStateCode=0 and crp.DeletionStateCode=0 AND pac.DeletionStateCode=0
                        AND pac.New_AccountsId = @AccountId";

        StaticData sd = new StaticData();
        if (ValidationHelper.GetGuid(MainGridSelectedRow.Value, Guid.Empty) != Guid.Empty)
        {
            sd.AddParameter("AccountId", DbType.Guid, ValidationHelper.GetGuid(MainGridSelectedRow.Value));
        }
        else
        {
            var msg = "Önce Ana hesap seçmelisiniz.";
            var m = new MessageBox { Width = 400, Height = 180 };

            m.Show(msg);
            return;
        }


        var like = new_CorporationId.Query();

        if (!string.IsNullOrEmpty(like))
        {

            strSql += " AND CorporationName LIKE  @Corporation + '%' ";
            sd.AddParameter("Corporation", DbType.String, like);
        }

        strSql += " ORDER BY CorporationName";

        DataTable dt = sd.ReturnDataset(strSql).Tables[0];

        new_CorporationId.TotalCount = dt.Rows.Count;
        new_CorporationId.DataSource = dt;
        new_CorporationId.DataBind();

    }


}