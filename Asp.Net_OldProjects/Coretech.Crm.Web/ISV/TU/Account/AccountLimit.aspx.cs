using System;
using System.Data;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object;
using System.Collections.Generic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Web.UI.RefleX.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Factory.Crm.Approval;

using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Factory.Crm;

public partial class Account_AccountLimit : BasePage
{
    #region Variables

    private DynamicSecurity _dynamicSecurity;

    #endregion

    protected override void OnPreInit(EventArgs e)
    {
        New_AccountLimitId.Value = QueryHelper.GetString("recid");
        if (!RefleX.IsAjxPostback)
        {

        }
        base.OnPreInit(e);

    }

    protected void Page_Load(object sender, EventArgs e)
    {
        _dynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_AccountLimit.GetHashCode(), null);
        if (!(_dynamicSecurity.PrvCreate || _dynamicSecurity.PrvRead || _dynamicSecurity.PrvWrite))
            Response.End();

        if (!RefleX.IsAjxPostback)
        {
            hdnRecId.Value = New_AccountLimitId.Value;

            var approvalCannotUpdate = ApprovalFactory.CheckApprovalByRecordId(TuEntityEnum.New_AccountLimit.GetHashCode(),
                        ValidationHelper.GetGuid(hdnRecId.Value));

            if (approvalCannotUpdate)
            {
                lblError.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_APPROVAL_CANNOT_UPDATE);
                lblError.Visible = true;
                btnSave.Visible = false;

            }

            LoadData();


        }
    }

    protected void new_AccountOnEvent(object sender, AjaxEventArgs e)
    {

        //        const string strSql = @"SELECT DISTINCT ac.New_AccountsId AS ID, ac.new_AccountNo AS VALUE,ac.New_AccountsId,
        //                                ac.new_AccountNo,SUBSTRING(ac.new_Description,0,LEN(ac.new_Description)-2) AS new_Description,
        //                                ac.new_Balance,ac.new_BalanceCurrency,ac.new_BalanceCurrencyName
        //                                FROM vNew_Accounts ac
        //                                INNER JOIN vNew_CorporationAccount ca ON ca.new_AccountId = ac.New_AccountsId
        //                                WHERE ca.DeletionStateCode=0 AND ac.DeletionStateCode=0 AND ca.new_OperationType<>9 ";

        string strSql = @"SELECT 
                                    ac.New_AccountsId AS ID,
                                    ac.new_AccountNo AS VALUE,
                                    ac.New_AccountsId,
                                    ac.new_AccountNo,
                                    SUBSTRING(ac.new_Description,0,LEN(ac.new_Description)-2) AS new_Description,
                                    ac.new_Balance,
                                    ac.new_BalanceCurrency,
                                    ac.new_BalanceCurrencyName
                                FROM vNew_Accounts(NOLOCK) ac 
                                WHERE ac.DeletionStateCode = 0 ";
        string searchSqlExt = " and  ac.new_AccountNo like '%{0}%' ";
        var searchtext = this.Context.Items["query"] != null ? this.Context.Items["query"].ToString() : "";
        if (!string.IsNullOrEmpty(searchtext))
            searchSqlExt = string.Format(searchSqlExt, searchtext);
        else
            searchSqlExt = " ";

        strSql = strSql + searchSqlExt;

        
        const string sort = "[{\"field\":\"new_Description\",\"direction\":\"Asc\"}]";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("AccountLookupView");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_Account.Start();
        var limit = new_Account.Limit();
        var spList = new List<CrmSqlParameter>();
        //var prm1 = new CrmSqlParameter
        //{
        //    Dbtype = DbType.Guid,
        //    Paramname = "CorporationID",
        //    Value = ValidationHelper.GetGuid(new_CorporationId.Value)
        //};
        //spList.Add(prm1);



        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_Account.TotalCount = cnt;
        new_Account.DataSource = t;
        new_Account.DataBind();
    }

    private void LoadData()
    {
        if (string.IsNullOrEmpty(New_AccountLimitId.Value))
        {
            return;
        }

        DynamicFactory df;
        df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };


        var limit = df.Retrieve(TuEntityEnum.New_AccountLimit.GetHashCode(),
                                          ValidationHelper.GetGuid(New_AccountLimitId.Value),
                                          DynamicFactory.RetrieveAllColumns);


        new_Account.FillDynamicEntityData(limit);
        new_Limit.FillDynamicEntityData(limit);

    }

    protected void btnSaveOnEvent(object sender, AjaxEventArgs e)
    {
        StaticData sd = new StaticData();
        sd.AddParameter("AccountId", DbType.Guid, ValidationHelper.GetGuid(new_Account.Value));

        if (!string.IsNullOrEmpty(New_AccountLimitId.Value))
        {
            sd.AddParameter("AccountLimitId", DbType.Guid, ValidationHelper.GetGuid(New_AccountLimitId.Value));
        }

        var accountLimitUnique = ValidationHelper.GetBoolean(sd.ExecuteScalarSp("spTuCheckAccountLimitUnique"));
        if (!accountLimitUnique)
        {
            var msg = new MessageBox { Width = 500 };
            msg.Show("Benzer tanım mevcut, lütfen kontrol edin!");
            return;
        }



        QScript("LogCurrentPage();");
        var trans = (new StaticData()).GetDbTransaction();
        var df = new DynamicFactory(ERunInUser.CalingUser);
        df.CheckConfirm = true;

        df.GetBeginTrans(trans);
        Guid recId = Guid.Empty;
        try
        {
            var de = new DynamicEntity(TuEntityEnum.New_AccountLimit.GetHashCode());

            if (!string.IsNullOrEmpty(New_AccountLimitId.Value))
            {
                de.AddKeyProperty("New_AccountLimitId", ValidationHelper.GetGuid(New_AccountLimitId.Value));
            }

            de.AddLookupProperty("new_Account", "", ValidationHelper.GetGuid(new_Account.Value));
            de.AddDecimalProperty("new_Limit", ValidationHelper.GetDecimal(new_Limit.Value, 0));

            /*Onay mekanizması ekranında base tablodaki birincil ad alanı hatalı eksik oluşuyordu, onun için eklendi.*/
            ((Lookup)de.Properties["new_Account"]).name = new_Account.SelectedItems[0].VALUE;


            if (string.IsNullOrEmpty(New_AccountLimitId.Value))
            {
                recId = df.Create("New_AccountLimit", de);
            }
            else
            {
                df.Update("New_AccountLimit", de);
                recId = ValidationHelper.GetGuid(New_AccountLimitId.Value);
            }
            df.CommitTrans();
        }
        catch (Exception ex)
        {
            e.Message = ex.Message;
            e.Success = false;
            df.RollbackTrans();
        }

        if (recId != Guid.Empty)
        {
            QScript("alert('Hesap Limiti Tanımı yapıldı.');");
        }

        QScript("RefreshParetnGridForCashTransaction(true);");


    }
}