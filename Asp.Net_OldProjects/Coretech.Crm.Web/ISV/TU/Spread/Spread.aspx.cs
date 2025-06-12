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

public partial class Spread_Spread : BasePage
{
    #region Variables

    private DynamicSecurity _dynamicSecurity;

    #endregion

    protected override void OnPreInit(EventArgs e)
    {
        New_SpreadId.Value = QueryHelper.GetString("recid");
        if (!RefleX.IsAjxPostback)
        {

        }
        base.OnPreInit(e);

    }

    protected void Page_Load(object sender, EventArgs e)
    {
        _dynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_Spread.GetHashCode(), null);
        if (!(_dynamicSecurity.PrvCreate || _dynamicSecurity.PrvRead || _dynamicSecurity.PrvWrite))
            Response.End();

        if (!RefleX.IsAjxPostback)
        {
            hdnRecId.Value = New_SpreadId.Value;

            var approvalCannotUpdate = ApprovalFactory.CheckApprovalByRecordId(TuEntityEnum.New_Spread.GetHashCode(),
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

    protected void new_FromCurrencyonEvent(object sender, AjaxEventArgs e)
    {
        if (new_CorporationId.IsEmpty)
        {
            var msg = new MessageBox { Width = 500 };
            msg.Show("Kurum Seçmelisiniz!");
            return;
        }

        const string strSql = @"SELECT distinct c.CurrencyId AS ID,c.Currencyname AS VALUE,c.CurrencyId,c.ISOCurrencyCode,c.Currencyname,c.CurrencySymbol
                                    FROM vNew_CorporationAccount ca
                                    INNER JOIN vCurrency c ON c.CurrencyId = ca.new_CurrencyID
                                    WHERE  ca.new_CorparationID=@CorporationID AND ca.DeletionStateCode=0 AND c.DeletionStateCode=0";
        const string sort = "";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("SYSTEM_CURRENCY_LOOKUP");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_FromCurrencyId.Start();
        var limit = new_FromCurrencyId.Limit();
        var spList = new List<CrmSqlParameter>();
        var prm1 = new CrmSqlParameter
        {
            Dbtype = DbType.Guid,
            Paramname = "CorporationID",
            Value = ValidationHelper.GetGuid(new_CorporationId.Value)
        };
        spList.Add(prm1);



        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_FromCurrencyId.TotalCount = cnt;
        new_FromCurrencyId.DataSource = t;
        new_FromCurrencyId.DataBind();
    }

    protected void new_ToCurrencyonEvent(object sender, AjaxEventArgs e)
    {
        if (new_CorporationId.IsEmpty)
        {
            var msg = new MessageBox { Width = 500 };
            msg.Show("Kurum Seçmelisiniz!");
            return;
        }

        if (new_FromCurrencyId.IsEmpty)
        {
            var msg = new MessageBox { Width = 500 };
            msg.Show("Mevcut Dövizi Seçmelisiniz!");
            return;
        }

        const string strSql = @"SELECT distinct c.CurrencyId AS ID,c.Currencyname AS VALUE,c.CurrencyId,c.ISOCurrencyCode,c.Currencyname,c.CurrencySymbol
                                    FROM vNew_CorporationAccount ca
                                    INNER JOIN vCurrency c ON c.CurrencyId = ca.new_CurrencyID
                                    WHERE  ca.new_CorparationID=@CorporationID AND ca.DeletionStateCode=0 AND c.DeletionStateCode=0 AND c.CurrencyId <> @FromCurrencyId";
        const string sort = "";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("SYSTEM_CURRENCY_LOOKUP");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_ToCurrencyId.Start();
        var limit = new_ToCurrencyId.Limit();
        var spList = new List<CrmSqlParameter>();
        var prm1 = new CrmSqlParameter
        {
            Dbtype = DbType.Guid,
            Paramname = "CorporationID",
            Value = ValidationHelper.GetGuid(new_CorporationId.Value)
        };
        spList.Add(prm1);

        var prm2 = new CrmSqlParameter
        {
            Dbtype = DbType.Guid,
            Paramname = "FromCurrencyId",
            Value = ValidationHelper.GetGuid(new_FromCurrencyId.Value)
        };
        spList.Add(prm2);



        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_ToCurrencyId.TotalCount = cnt;
        new_ToCurrencyId.DataSource = t;
        new_ToCurrencyId.DataBind();
    }

    protected void new_SenderAccountIdonEvent(object sender, AjaxEventArgs e)
    {
        if (new_CorporationId.IsEmpty)
        {
            var msg = new MessageBox { Width = 500 };
            msg.Show("Kurum Seçmelisiniz!");
            return;
        }

        string strSql = @"SELECT DISTINCT ac.New_AccountsId AS ID, ac.new_AccountNo AS VALUE,ac.New_AccountsId,
                                ac.new_AccountNo,new_Description,ac.new_Balance,ac.new_BalanceCurrency,ac.new_BalanceCurrencyName
                                FROM vNew_Accounts ac
                                INNER JOIN vNew_CorporationAccount ca ON ca.new_AccountId = ac.New_AccountsId
                                WHERE ca.DeletionStateCode=0 AND ac.DeletionStateCode=0 AND ca.new_CorparationID =@CorporationId  AND ca.new_OperationType<>9";
        const string sort = "";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("AccountLookupView");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_SenderAccountId.Start();
        var limit = new_SenderAccountId.Limit();
        var spList = new List<CrmSqlParameter>();
        var prm1 = new CrmSqlParameter
        {
            Dbtype = DbType.Guid,
            Paramname = "CorporationId",
            Value = ValidationHelper.GetGuid(new_CorporationId.Value)
        };
        spList.Add(prm1);

        if (!new_FromCurrencyId.IsEmpty)
        {
            strSql += @"AND ac.new_BalanceCurrency = @FromCurrencyId";

            var prm3 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "FromCurrencyId",
                Value = ValidationHelper.GetGuid(new_FromCurrencyId.Value)
            };
            spList.Add(prm3);

        }


        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_SenderAccountId.TotalCount = cnt;
        new_SenderAccountId.DataSource = t;
        new_SenderAccountId.DataBind();
    }

    protected void new_RecipientAccountIdonEvent(object sender, AjaxEventArgs e)
    {
        if (new_CorporationId.IsEmpty)
        {
            var msg = new MessageBox { Width = 500 };
            msg.Show("Kurum Seçmelisiniz!");
            return;
        }

        if (new_SenderAccountId.IsEmpty)
        {
            var msg = new MessageBox { Width = 500 };
            msg.Show("Mevcut Hesabı Seçmelisiniz!");
            return;
        }

        string strSql = @"SELECT DISTINCT ac.New_AccountsId AS ID, ac.new_AccountNo AS VALUE,ac.New_AccountsId,
                                ac.new_AccountNo,new_Description,ac.new_Balance,ac.new_BalanceCurrency,ac.new_BalanceCurrencyName
                                FROM vNew_Accounts ac
                                INNER JOIN vNew_CorporationAccount ca ON ca.new_AccountId = ac.New_AccountsId
                                WHERE ca.DeletionStateCode=0 AND ac.DeletionStateCode=0 AND ca.new_CorparationID =@CorporationId AND ac.New_AccountsId<>@SenderAccountId  AND ca.new_OperationType<>9 ";
        const string sort = "";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("AccountLookupView");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_RecipientAccountId.Start();
        var limit = new_RecipientAccountId.Limit();
        var spList = new List<CrmSqlParameter>();
        var prm1 = new CrmSqlParameter
        {
            Dbtype = DbType.Guid,
            Paramname = "CorporationId",
            Value = ValidationHelper.GetGuid(new_CorporationId.Value)
        };
        spList.Add(prm1);

        var prm2 = new CrmSqlParameter
        {
            Dbtype = DbType.Guid,
            Paramname = "SenderAccountId",
            Value = ValidationHelper.GetGuid(new_SenderAccountId.Value)
        };
        spList.Add(prm2);

        if (!new_ToCurrencyId.IsEmpty)
        {
            strSql += @"AND ac.new_BalanceCurrency = @ToCurrencyId";

            var prm3 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "ToCurrencyId",
                Value = ValidationHelper.GetGuid(new_ToCurrencyId.Value)
            };
            spList.Add(prm3);

        }


        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_RecipientAccountId.TotalCount = cnt;
        new_RecipientAccountId.DataSource = t;
        new_RecipientAccountId.DataBind();
    }

    protected void new_CorporationIdChange(object sender, AjaxEventArgs e)
    {
        ClearAll();
    }

    protected void new_FromCurrencyChange(object sender, AjaxEventArgs e)
    {
        if (!new_FromCurrencyId.IsEmpty && !new_ToCurrencyId.IsEmpty)
        {
            if (new_FromCurrencyId.Value == new_ToCurrencyId.Value)
            {
                var msg = new MessageBox { Width = 500 };
                msg.Show("Aynı döviz cinsini seçemezsiniz!");
                new_FromCurrencyId.Clear();
                return;
            }
        }
        new_SenderAccountId.Clear();
    }

    protected void new_ToCurrencyChange(object sender, AjaxEventArgs e)
    {
        if (!new_FromCurrencyId.IsEmpty && !new_ToCurrencyId.IsEmpty)
        {
            if (new_FromCurrencyId.Value == new_ToCurrencyId.Value)
            {
                var msg = new MessageBox { Width = 500 };
                msg.Show("Aynı döviz cinsini seçemezsiniz!");
                new_ToCurrencyId.Clear();
                return;
            }
        }

        new_RecipientAccountId.Clear();
    }

    protected void new_SenderAccountIdChange(object sender, AjaxEventArgs e)
    {
        if (!new_SenderAccountId.IsEmpty)
        {
            StaticData sd = new StaticData();
            sd.AddParameter("AccountId", DbType.Guid, ValidationHelper.GetGuid(new_SenderAccountId.Value));
            var ds = sd.ReturnDataset(@"SELECT new_BalanceCurrency,new_BalanceCurrencyName FROM vNew_Accounts WHERE DeletionStateCode=0 AND New_AccountsId=@AccountId");

            if (ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    new_FromCurrencyId.SetValue(ValidationHelper.GetGuid(ds.Tables[0].Rows[0]["new_BalanceCurrency"]), ValidationHelper.GetString(ds.Tables[0].Rows[0]["new_BalanceCurrencyName"]));
                }
            }
        }
    }

    protected void new_RecipientAccountIdChange(object sender, AjaxEventArgs e)
    {
        if (!new_RecipientAccountId.IsEmpty)
        {
            StaticData sd = new StaticData();
            sd.AddParameter("AccountId", DbType.Guid, ValidationHelper.GetGuid(new_RecipientAccountId.Value));
            var ds = sd.ReturnDataset(@"SELECT new_BalanceCurrency,new_BalanceCurrencyName FROM vNew_Accounts WHERE DeletionStateCode=0 AND New_AccountsId=@AccountId");

            if (ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    new_ToCurrencyId.SetValue(ValidationHelper.GetGuid(ds.Tables[0].Rows[0]["new_BalanceCurrency"]), ValidationHelper.GetString(ds.Tables[0].Rows[0]["new_BalanceCurrencyName"]));
                }
            }
        }
    }

    private void ClearAll()
    {
        new_FromCurrencyId.Clear();
        new_ToCurrencyId.Clear();
        new_SenderAccountId.Clear();
        new_RecipientAccountId.Clear();
        new_Rate.Clear();
    }

    private void LoadData()
    {
        if (string.IsNullOrEmpty(New_SpreadId.Value))
        {
            return;
        }

        DynamicFactory df;
        df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };


        var spread = df.Retrieve(TuEntityEnum.New_Spread.GetHashCode(),
                                          ValidationHelper.GetGuid(New_SpreadId.Value),
                                          DynamicFactory.RetrieveAllColumns);


        new_CorporationId.FillDynamicEntityData(spread);
        new_FromCurrencyId.FillDynamicEntityData(spread);
        new_ToCurrencyId.FillDynamicEntityData(spread);
        new_SenderAccountId.FillDynamicEntityData(spread);
        new_RecipientAccountId.FillDynamicEntityData(spread);
        new_Rate.FillDynamicEntityData(spread);

    }

    protected void btnSaveOnEvent(object sender, AjaxEventArgs e)
    {
        if (new_CorporationId.IsEmpty)
        {
            var msg = new MessageBox { Width = 500 };
            msg.Show("Kurum Seçmelisiniz!");
            return;
        }

        StaticData sd = new StaticData();
        sd.AddParameter("CorporationId", DbType.Guid, ValidationHelper.GetGuid(new_CorporationId.Value));
        sd.AddParameter("RecipientAccountId", DbType.Guid, ValidationHelper.GetGuid(new_RecipientAccountId.Value));
        sd.AddParameter("SenderAccountId", DbType.Guid, ValidationHelper.GetGuid(new_SenderAccountId.Value));
        if (!string.IsNullOrEmpty(New_SpreadId.Value))
        {
            sd.AddParameter("SpreadId", DbType.Guid, ValidationHelper.GetGuid(New_SpreadId.Value));
        }

        var spreadUnique = ValidationHelper.GetBoolean(sd.ExecuteScalarSp("spTuCheckSpreadUnique"));
        if (!spreadUnique)
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
            var de = new DynamicEntity(TuEntityEnum.New_Spread.GetHashCode());

            if (!string.IsNullOrEmpty(New_SpreadId.Value))
            {
                de.AddKeyProperty("New_SpreadId", ValidationHelper.GetGuid(New_SpreadId.Value));
            }

            de.AddLookupProperty("new_CorporationId", "", ValidationHelper.GetGuid(new_CorporationId.Value));
            de.AddLookupProperty("new_FromCurrencyId", "", ValidationHelper.GetGuid(new_FromCurrencyId.Value));
            de.AddLookupProperty("new_ToCurrencyId", "", ValidationHelper.GetGuid(new_ToCurrencyId.Value));
            de.AddLookupProperty("new_SenderAccountId", "", ValidationHelper.GetGuid(new_SenderAccountId.Value));
            de.AddLookupProperty("new_RecipientAccountId", "", ValidationHelper.GetGuid(new_RecipientAccountId.Value));
            de.AddDecimalProperty("new_Rate", ValidationHelper.GetDecimal(new_Rate.Value, 0));

            ((Lookup)de.Properties["new_CorporationId"]).name = new_CorporationId.SelectedItems[0].VALUE;
            ((Lookup)de.Properties["new_FromCurrencyId"]).name = new_FromCurrencyId.SelectedItems[0].VALUE;
            ((Lookup)de.Properties["new_ToCurrencyId"]).name = new_ToCurrencyId.SelectedItems[0].VALUE;
            ((Lookup)de.Properties["new_SenderAccountId"]).name = new_SenderAccountId.SelectedItems[0].VALUE;
            ((Lookup)de.Properties["new_RecipientAccountId"]).name = new_RecipientAccountId.SelectedItems[0].VALUE;

            if (string.IsNullOrEmpty(New_SpreadId.Value))
            {
                recId = df.Create("New_Spread", de);
            }
            else
            {
                df.Update("New_Spread", de);
                recId = ValidationHelper.GetGuid(New_SpreadId.Value);
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
            QScript("alert('Spread Tanımı yapıldı.');");
        }

        QScript("RefreshParetnGridForCashTransaction(true);");


    }
}