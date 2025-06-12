using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
//using Coretech.Crm.Web.UI;
using System;
using System.Collections.Generic;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using TuFactory.Object.User;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;

public partial class Payment_PaymentLocations : BasePage
{

    private Guid _newCorporationCountryId;
    private TuUserApproval _userApproval = null;
    MessageBox messageBox = new MessageBox();

    private string pCountryId
    {
        get
        {
            if (!RefleX.IsAjxPostback)
            {
                return QueryHelper.GetString("CountryId");
            }

            return new_CountryID.Value;
        }
    }

    private string pCorporationId
    {
        get
        {
            if (!RefleX.IsAjxPostback)
            {
                return QueryHelper.GetString("CorporationId");
            }

            return new_CorporationID.Value;
        }
    }

    private string pBrandId
    {
        get
        {
            if (!RefleX.IsAjxPostback)
            {
                return QueryHelper.GetString("BrandId");
            }

            return new_BrandId.Value;
        }
    }

    private string pCityId
    {
        get
        {
            if (!RefleX.IsAjxPostback)
            {
                return QueryHelper.GetString("CityId");
            }

            return new_CityId.Value;
        }
    }

    private string pStateId
    {
        get
        {
            if (!RefleX.IsAjxPostback)
            {
                return QueryHelper.GetString("StateId");
            }

            return new_StateId.Value;
        }
    }

    DynamicEntity _deTransfer = new DynamicEntity(TuEntityEnum.New_Transfer.GetHashCode());
    private string _confirmStatus;

    void GetTransferData()
    {
        var df = new DynamicFactory(ERunInUser.SystemAdmin);
        _deTransfer = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(hdnTransferId.Value), new string[] { "new_TestQuestionID", "new_TestQuestionReply", "TransferTuRef", "new_RecipientName", "new_RecipientLastName", "new_SenderID" });
        var cf = new ConfirmFactory();
        _confirmStatus = cf.GetTransactionStatus(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(hdnTransferId.Value));
    }

    private void TranslateMessage()
    {
        ToolbarButtonFind.Text = CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_BTNARA");
        ToolbarButtonClear.Text = CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_BTNTEMIZLE");
        pnlSEARCHGeneral.Title = CrmLabel.TranslateMessage("CRM.NEW_OFFICE_PAYMENT_OFFICES");
        //btnRefund.Text = CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_IADESINEBASLA");


    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("PAYMENT_LOCATIONS", GridPanelPayments);
        string strSelected;
        strSelected = ViewFactory.GetViewIdbyUniqueName("PAYMENT_LOCATIONS").ToString();
        hdnViewList.Value = strSelected;

        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
        var DefaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnViewDefaultEditPage.Value = DefaultEditPage;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            bool autoFind = false;

            CreateViewGrid();

            DynamicFactory df = new DynamicFactory(ERunInUser.SystemAdmin);
            DynamicEntity de = null;

            if (QueryHelper.GetString("CountryId") != string.Empty)
            {
                new_CountryID.SetValue(ValidationHelper.GetGuid(QueryHelper.GetString("CountryId")));
                autoFind = true;
            }

            if (QueryHelper.GetString("CorporationId") != string.Empty)
            {
                Guid corporationId = ValidationHelper.GetGuid(QueryHelper.GetString("CorporationId"));
                de = df.RetrieveWithOutPlugin(TuEntityEnum.New_Corporation.GetHashCode(), corporationId, new string[] { "CorporationName" });
                new_CorporationID.SetValue(corporationId, de.GetStringValue("CorporationName"));
                autoFind = true;
            }

            if (QueryHelper.GetString("BrandId") != string.Empty)
            {
                Guid brandId = ValidationHelper.GetGuid(QueryHelper.GetString("BrandId"));
                de = df.RetrieveWithOutPlugin(TuEntityEnum.New_IntegrationBrands.GetHashCode(), brandId, new string[] { "BrandName" });
                new_BrandId.SetValue(brandId, de.GetStringValue("BrandName"));
                autoFind = true;
            }
            if (QueryHelper.GetString("StateId") != string.Empty)
            {
                Guid stateId = ValidationHelper.GetGuid(QueryHelper.GetString("StateId"));
                de = df.RetrieveWithOutPlugin(TuEntityEnum.New_IntegrationStates.GetHashCode(), stateId, new string[] { "IntegrationStateName" });
                new_StateId.SetValue(stateId, de.GetStringValue("IntegrationStateName"));
                autoFind = true;
            }
            if (QueryHelper.GetString("CityId") != string.Empty)
            {
                Guid cityId = ValidationHelper.GetGuid(QueryHelper.GetString("CityId"));
                de = df.RetrieveWithOutPlugin(TuEntityEnum.New_IntegrationCities.GetHashCode(), cityId, new string[] { "IntegrationCityName" });
                new_CityId.SetValue(cityId, de.GetStringValue("IntegrationCityName"));
                autoFind = true;
            }

            if (autoFind)
            {
                //BindData();
            }
        }
    }

    // dropdown events

    protected void New_CountryIdLoad(object sender, AjaxEventArgs e)
    {
        string sql = @" /*DECLARE @SystemUserId UNIQUEIDENTIFIER =  '00000000-AAAA-BBBB-CCCC-000000000001' */
                              
            DECLARE @SystemUserOfficeId AS UNIQUEIDENTIFIER
			DECLARE @SystemUserCorporationId AS UNIQUEIDENTIFIER
			SELECT 
				@SystemUserOfficeId = new_OfficeID,
				@SystemUserCorporationId = new_CorporationID
			FROM SystemUserExtension u
			WHERE u.SystemUserId = @SystemUserId

            /*DECLARE @SystemUserOfficeId AS UNIQUEIDENTIFIER
            SELECT @SystemUserOfficeId = new_OfficeID FROM SystemUserExtension u
            WHERE u.SystemUserId = @SystemUserId*/

            DECLARE @NakitOdeme AS UNIQUEIDENTIFIER
            SELECT @NakitOdeme = New_TransactionTypeId FROM vNew_TransactionType
            WHERE new_ExtCode = '008' AND DeletionStateCode = 0

            DECLARE @IsmeGonderim AS UNIQUEIDENTIFIER
            SELECT @IsmeGonderim = New_TransactionTypeId FROM vNew_TransactionType
            WHERE new_ExtCode = '001' AND DeletionStateCode = 0

            DECLARE @HesabaGonderim AS UNIQUEIDENTIFIER
            SELECT @HesabaGonderim = New_TransactionTypeId FROM vNew_TransactionType
            WHERE new_ExtCode = '011' AND DeletionStateCode = 0

            DECLARE @HesabaOdeme AS UNIQUEIDENTIFIER
            SELECT @HesabaOdeme = New_TransactionTypeId FROM vNew_TransactionType
            WHERE new_ExtCode = '012' AND DeletionStateCode = 0

            DECLARE @EFTGonderim AS UNIQUEIDENTIFIER
            SELECT @EFTGonderim = New_TransactionTypeId FROM vNew_TransactionType
            WHERE new_ExtCode = '002' AND DeletionStateCode = 0

            DECLARE @SwiftGonderim AS UNIQUEIDENTIFIER
            SELECT @SwiftGonderim = New_TransactionTypeId FROM vNew_TransactionType
            WHERE new_ExtCode = '003' AND DeletionStateCode = 0

            CREATE TABLE #SystemUserOfficeTransactionTypes
            (
                  TransactionTypeId UNIQUEIDENTIFIER 
            )

            INSERT #SystemUserOfficeTransactionTypes
            SELECT DISTINCT ott.new_TransactionTypeID
            FROM vNew_OfficeTransactionType ott
            WHERE ott.new_OfficeID = @SystemUserOfficeId AND ott.DeletionStateCode=0

            SELECT 
                        c.new_CountryID AS ID, 
                        c.new_TelephoneCode,
                        c.CountryName,
                        c.CountryName AS CountryName,
                        c.CountryName AS VALUE
            FROM tvNew_Country(@SystemUserId) c
            WHERE c.new_CountryID IN
            (
                  SELECT new_CountryID FROM (
                        --Kurumun ofislerinin isme gonderim yetkisi varsa; nakit odeme yapabilen ofislerin ulkeleri
                        SELECT DISTINCT new_CountryID 
                        FROM OfficeTransactionTypeCumulativeTable ctt
                        WHERE
                        (
                              ctt.new_TransactionTypeID = @NakitOdeme /* Nakit odeme yetkisi */
                             -- AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @IsmeGonderim) /* Isme gonderim yetkisi kontrolu */
                        )
                        OR
                        (
                              ctt.new_TransactionTypeID = @HesabaOdeme /* Hesaba odeme yetkisi */              
                              --AND EXISTS (SELECT 1 FROM #SystemUserOfficeTransactionTypes WHERE TransactionTypeId = @HesabaGonderim) /* Hesaba gonderim yetkisi kontrolu */
                        )
                        AND new_CountryID NOT IN
						(
							SELECT DISTINCT cbc.new_CountryId FROM vNew_CorporationBlockedCountries cbc
							WHERE cbc.new_CountryId = ctt.new_CountryID 
							AND cbc.new_CorporationId = @SystemUserCorporationId 
							AND cbc.DeletionStateCode = 0
							AND CBC.new_BlockedCorporation is null
				
							UNION
				
							SELECT DISTINCT cbc.new_CountryId FROM vNew_CorporationBlockedCountries cbc
							WHERE cbc.new_CountryId = ctt.new_CountryID 
							AND cbc.new_CorporationId = @SystemUserCorporationId 
							AND cbc.DeletionStateCode = 0
							AND CBC.new_BlockedCorporation is not null 
							AND cbc.new_BlockedCorporation <> ctt.New_CorporationId
						)                     
                  ) AS T
        )";

        const string sort = "";
        var like = new_CountryID.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("COUNTRY_LOOKUP");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_CountryID.Start();
        var limit = new_CountryID.Limit();
        var spList = new List<CrmSqlParameter>()
        {

        };



        StaticData sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);

        if (!string.IsNullOrEmpty(like))
        {
            sql += @" AND c.CountryName LIKE @CountryName + '%' ";
            sd.AddParameter("CountryName", DbType.String, like);
        }

        BindCombo(new_CountryID, sd, sql);



        //var t = gpc.GetFilterData(sql, viewqueryid, sort, spList, start, limit, out cnt);
        //new_CountryID.TotalCount = cnt;
        //new_CountryID.DataSource = t;
        //new_CountryID.DataBind();
    }

    private void BindCombo(CrmComboComp combo, StaticData sd, string strSql)
    {
        var start = combo.Start() - 1;
        var limit = combo.Limit();

        if (start < 0)
        {
            start = 0;
        }

        BindCombo(combo, sd, strSql, start, limit);
    }

    private void BindCombo(CrmComboComp combo, StaticData sd, string strSql, int start, int limit)
    {
        var t = sd.ReturnDataset(strSql).Tables[0];

        //var start = combo.Start() - 1;
        //var limit = combo.Limit();

        DataTable t2 = t.Clone();

        var end = start + limit > t.Rows.Count ? t.Rows.Count : start + limit;

        for (int i = start; i < end; i++)
        {
            DataRow dr = t2.NewRow();
            dr.ItemArray = t.Rows[i].ItemArray;
            t2.Rows.Add(dr);
        }

        combo.TotalCount = t.Rows.Count;
        combo.DataSource = t2;
        combo.DataBind();
    }

    protected void New_CountryIdChangeOnEvent(object sender, AjaxEventArgs e)
    {




        new_CorporationID.Clear();
        new_StateId.Clear();
        new_BrandId.Clear();
        new_CityId.Clear();


        //New_CorporationIdLoad(null, null);
    }

    protected void New_CorporationIdLoad(object sender, AjaxEventArgs e)
    {

        string sql = @"SELECT * FROM
		               (
			                    SELECT DISTINCT 
			                    CASE ISNULL(ctt.new_UseUptPool,0) WHEN 0 THEN ctt.New_CorporationId ELSE '00000000-0000-0000-0000-000000000001' END AS ID,
	                            CASE ISNULL(ctt.new_UseUptPool,0) WHEN 0 THEN ctt.CorporationName ELSE 'Upt Havuzu' END AS VALUE,
	                            CASE ISNULL(ctt.new_UseUptPool,0) WHEN 0 THEN ctt.CorporationName ELSE 'Upt Havuzu' END AS CorporationName,
	                            CASE ISNULL(ctt.new_UseUptPool,0) WHEN 0 THEN ctt.new_CorporationCode ELSE '' END AS new_CorporationCode	   
                                
			                    FROM OfficeTransactionTypeCumulativeTable ctt (NoLock)
                                INNER JOIN New_CorporationBase cb  (NoLock) on cb.New_CorporationId = ctt.New_CorporationId
                                INNER JOIN New_CorporationExtension ce  (NoLock) on ce.New_CorporationId = ctt.New_CorporationId
			                    WHERE ctt.new_CountryId = @CountryId 
                                    AND ctt.new_ExtCode = '008' /* Nakit Odeme */
                                    AND cb.DeletionStateCode = 0
                                    AND cb.statuscode = 1
                                    and ce.new_CorporationTransactionRestriction IN (2,3) /* İşlem alabilir ve İşlem Gönderir-Alabilir */
	                                AND ctt.New_CorporationId NOT IN
				                    (					      
                                        SELECT DISTINCT cbc.new_BlockedCorporation 
					                    FROM vNew_CorporationBlockedCountries cbc (NoLock)
		                                WHERE cbc.new_CountryID = @CountryId AND cbc.DeletionStateCode = 0
					                    AND cbc.new_CorporationId = ctt.New_CorporationId
		                                AND CBC.new_BlockedCorporation is not null 
	                                )  
                       ) 
		               AS T";

        const string sort = "";
        var like = new_CorporationID.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CorpComboView");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_CorporationID.Start();
        var limit = new_CorporationID.Limit();
        var spList = new List<CrmSqlParameter>(){
                        new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "CountryId",
                                    Value = ValidationHelper.GetGuid(new_CountryID.Value)
                                }
        };





        if (!string.IsNullOrEmpty(like))
        {

            sql += " WHERE T.CorporationName LIKE  @Corporation + '%' ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.String,
                    Paramname = "Corporation",
                    Value = like
                });
        }

        var t = gpc.GetFilterData(sql, viewqueryid, sort, spList, start, limit, out cnt);
        new_CorporationID.TotalCount = cnt;
        new_CorporationID.DataSource = t;
        new_CorporationID.DataBind();



    }

    protected void New_CorporationIdChangeOnEvent(object sender, AjaxEventArgs e)
    {
        new_BrandId.Clear();
        new_StateId.Clear();
        new_CityId.Clear();
    }

    protected void New_IntegrationStatesIdLoad(object sender, AjaxEventArgs e)
    {
        string sql = @" 
        select 
	        s.New_IntegrationStatesId AS ID,
	        s.IntegrationStateName AS VALUE,
	        s.IntegrationStateName,
	        s.new_StateCode 
        from vNew_IntegrationStates s
        INNER JOIN New_CorporationBase crp 
        ON s.new_CorporationId = crp.New_CorporationId AND crp.DeletionStateCode = 0 AND crp.statuscode = 1
        where
	        s.DeletionStateCode = 0 
        and
            s.new_CountryId = @CountryId";

        const string sort = "";
        var like = new_StateId.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("REGION_LOOKUP_VIEW");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_CorporationID.Start();
        var limit = new_CorporationID.Limit();
        var spList = new List<CrmSqlParameter>(){

                        new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "CountryId",
                                    Value = ValidationHelper.GetGuid(new_CountryID.Value)
                                }
        };




        if (!String.IsNullOrEmpty(new_CorporationID.Value) && new_CorporationID.Value != "00000000-0000-0000-0000-000000000001")
        {
            sql += " and s.new_CorporationId = @CorporationId";
            CrmSqlParameter prm2 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "CorporationId",
                Value = ValidationHelper.GetGuid(new_CorporationID.Value)
            };
            spList.Add(prm2);
        }
        else if (new_CorporationID.Value == "00000000-0000-0000-0000-000000000001")
        {
            sql += " and s.new_CorporationId in (Select New_CorporationId from vNew_Corporation corp where corp.new_UseUptPool=1 and corp.new_CountryID=@CountryId)";
        }


        if (!string.IsNullOrEmpty(like))
        {

            sql += " and s.IntegrationStateName LIKE  @IntegrationStateName + '%' ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.String,
                    Paramname = "IntegrationStateName",
                    Value = like
                });
        }

        var t = gpc.GetFilterData(sql, viewqueryid, sort, spList, start, limit, out cnt);
        new_StateId.TotalCount = cnt;
        new_StateId.DataSource = t;
        new_StateId.DataBind();
    }

    protected void New_IntegrationStatesIdChangeOnEvent(object sender, AjaxEventArgs e)
    {
        new_CityId.Clear();
        new_BrandId.Clear();
    }

    protected void New_IntegrationCitiesIdLoad(object sender, AjaxEventArgs e)
    {
        string sql = @" 
        select 
	        c.New_IntegrationCitiesId AS ID,
	        c.IntegrationCityName AS VALUE,
	        c.IntegrationCityName,
	        c.new_CityCode 
        from 
	        vNew_IntegrationCities c
        INNER JOIN New_CorporationBase crp 
        ON c.new_CorporationId = crp.New_CorporationId AND crp.DeletionStateCode = 0 AND crp.statuscode = 1
        where
	        c.DeletionStateCode = 0         
        and
            c.new_CountryId = @CountryId
        ";

        const string sort = "";
        var like = new_CityId.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CITY_LOOKUP_VIEW");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_CorporationID.Start();
        var limit = new_CorporationID.Limit();
        var spList = new List<CrmSqlParameter>(){

                        new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "CountryId",
                                    Value = ValidationHelper.GetGuid(new_CountryID.Value)
                                }
        };

        if (!String.IsNullOrEmpty(new_StateId.Value))
        {
            sql += " and c.new_StateId = @StateId";
            CrmSqlParameter prm1 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "StateId",
                Value = ValidationHelper.GetGuid(new_StateId.Value)
            };
            spList.Add(prm1);
        }

        if (!String.IsNullOrEmpty(new_CorporationID.Value) && new_CorporationID.Value != "00000000-0000-0000-0000-000000000001")
        {
            sql += " and c.new_CorporationId = @CorporationId";
            CrmSqlParameter prm2 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "CorporationId",
                Value = ValidationHelper.GetGuid(new_CorporationID.Value)
            };
            spList.Add(prm2);
        }
        else if (new_CorporationID.Value == "00000000-0000-0000-0000-000000000001")
        {
            sql += " and c.new_CorporationId in (Select New_CorporationId from vNew_Corporation corp where corp.new_UseUptPool=1 and corp.new_CountryID=@CountryId)";
        }

        if (!string.IsNullOrEmpty(like))
        {

            sql += " and c.IntegrationCityName LIKE  @IntegrationCityName + '%' ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.String,
                    Paramname = "IntegrationCityName",
                    Value = like
                });
        }

        var t = gpc.GetFilterData(sql, viewqueryid, sort, spList, start, limit, out cnt);
        new_CityId.TotalCount = cnt;
        new_CityId.DataSource = t;
        new_CityId.DataBind();
    }

    protected void New_IntegrationCitiesIdChangeOnEvent(object sender, AjaxEventArgs e)
    {
        new_BrandId.Clear();
    }

    protected void New_IntegrationBrandsIdLoad(object sender, AjaxEventArgs e)
    {
        /**/


        //        string sql = @" 
        //        select Distinct
        //	        b.New_IntegrationBrandsId AS ID,
        //	        b.BrandName AS VALUE,
        //	        b.BrandName,
        //	        b.new_BrandCode 
        //        from 
        //	        vNew_IntegrationBrands b
        //            INNER JOIN New_CorporationBase crp 
        //            ON b.new_CorporationId = crp.New_CorporationId AND crp.DeletionStateCode = 0 AND crp.statuscode = 1
        //            inner join vNew_IntegrationCityBrands cb on cb.new_BrandId = b.New_IntegrationBrandsId
        //            inner join vNew_IntegrationCities ic on ic.New_IntegrationCitiesId=cb.new_CityId
        //            
        //        where
        //	        b.DeletionStateCode = 0        
        //        and
        //            ic.new_CountryID = @CountryId ";

        string sql = @"select Distinct
	        b.New_IntegrationBrandsId AS ID,
	        b.BrandName AS VALUE,
	        b.BrandName,
	        b.new_BrandCode 
        from 
	        vNew_IntegrationBrands b
            INNER JOIN New_CorporationBase crp 
            ON b.new_CorporationId = crp.New_CorporationId AND crp.DeletionStateCode = 0 AND crp.statuscode = 1
            left join vNew_IntegrationCityBrands cb on cb.new_BrandId = b.New_IntegrationBrandsId
            left join vNew_IntegrationCities ic on ic.New_IntegrationCitiesId=cb.new_CityId            
        where
	        b.DeletionStateCode = 0        
        and
            b.new_CountryId = @CountryId";

        const string sort = "";
        var like = new_BrandId.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("BRAND_LOOKUP_VIEW");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_CorporationID.Start();
        var limit = new_CorporationID.Limit();
        var spList = new List<CrmSqlParameter>(){

                                new CrmSqlParameter
                                {
                                    Dbtype = DbType.Guid,
                                    Paramname = "CountryId",
                                    Value = ValidationHelper.GetGuid(new_CountryID.Value)
                                }
        };

        if (!String.IsNullOrEmpty(new_StateId.Value))
        {
            sql += "  and ic.new_StateId = @StateId";
            CrmSqlParameter prm1 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "StateId",
                Value = ValidationHelper.GetGuid(new_StateId.Value)
            };
            spList.Add(prm1);
        }
        if (!String.IsNullOrEmpty(new_CityId.Value))
        {
            sql += "  and ic.New_IntegrationCitiesId = @CityId";
            CrmSqlParameter prm2 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "CityId",
                Value = ValidationHelper.GetGuid(new_CityId.Value)
            };
            spList.Add(prm2);
        }
        if (!String.IsNullOrEmpty(new_CorporationID.Value) && new_CorporationID.Value != "00000000-0000-0000-0000-000000000001")
        {
            sql += " and b.new_CorporationId = @CorporationId";
            CrmSqlParameter prm3 = new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "CorporationId",
                Value = ValidationHelper.GetGuid(new_CorporationID.Value)
            };
            spList.Add(prm3);
        }
        else if (new_CorporationID.Value == "00000000-0000-0000-0000-000000000001")
        {
            sql += " and ic.new_CorporationId in (Select New_CorporationId from vNew_Corporation corp where corp.new_UseUptPool=1 and corp.new_CountryID=@CountryId)";
        }



        if (!string.IsNullOrEmpty(like))
        {

            sql += " and b.BrandName LIKE  @BrandName + '%' ";
            spList.Add(
                new CrmSqlParameter
                {
                    Dbtype = DbType.String,
                    Paramname = "BrandName",
                    Value = like
                });
        }

        var t = gpc.GetFilterData(sql, viewqueryid, sort, spList, start, limit, out cnt);
        new_BrandId.TotalCount = cnt;
        new_BrandId.DataSource = t;
        new_BrandId.DataBind();


    }

    protected void New_IntegrationBrandsIdChangeOnEvent(object sender, AjaxEventArgs e)
    {

    }

    // dropdown events sonu

    protected void BtnAraClick(object sender, AjaxEventArgs e)
    {
        BindData();
    }

    private void BindData()
    {

        if (string.IsNullOrEmpty(pCountryId))
        {
            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", "Arama yapmak için ülke seçmelisiniz!");
            GridPanelPayments.DataBind();
            return;
        }

        if (string.IsNullOrEmpty(pCorporationId))
        {
            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", "Arama yapmak için kurum seçmelisiniz!");
            GridPanelPayments.DataBind();
            return;
        }

        string strSql = @"
           SELECT Distinct          
	            o.New_OfficeId ID,
	            o.OfficeName VALUE,
                o.OfficeName, 
	            o.new_CorporationIDName,
	            o.new_CountryIDName,
	            o.new_StateIdName,
	            o.new_CityIdName,
	            o.new_BrandIdName,
	            o.new_Adress,
	            o.new_Telephone,
	            o.new_Fax,
	            o.new_EMail
            FROM vNew_OfficeTransactionType ott
            INNER JOIN vNew_TransactionType tt
            ON ott.new_TransactionTypeID = tt.New_TransactionTypeId AND tt.DeletionStateCode = 0
            INNER JOIN vNew_Office o 
            ON ott.new_OfficeID = o.New_OfficeId AND o.DeletionStateCode = 0 
            INNER JOIN vNew_Corporation c on c.New_CorporationId=o.new_CorporationID and c.DeletionStateCode=0 AND c.statuscode = 1
            LEFT OUTER JOIN vNew_IntegrationChannel ic on ic.New_IntegrationChannelId =c.new_IntegrationChannelId AND ic.DeletionStateCode=0
			--INNER JOIN vNew_IntegrationCountryCodes icc on icc.new_IntegrationChannelId=ic.New_IntegrationChannelId AND icc.new_CountryId=o.new_CountryID AND icc.DeletionStateCode=0
 
            WHERE ott.DeletionStateCode = 0 
            AND tt.new_ExtCode = '008'
            AND
			(
			(ic.New_IntegrationChannelId IS NULL)
			OR
			(ISNULL(ic.new_IntegratorAssembly, '') = '')			
			OR 
			(
				ic.New_IntegrationChannelId IS NOT NULL
				AND ott.new_CountryID IN
				(SELECT DISTINCT icc.new_CountryId FROM vNew_IntegrationCountryCodes icc
				WHERE new_IntegrationChannelId = ic.New_IntegrationChannelId AND icc.DeletionStateCode = 0)
			)
			)";

        var spList = new List<CrmSqlParameter>();

        if (ValidationHelper.GetGuid(pCountryId) != Guid.Empty)
        {
            strSql += " AND o.new_CountryID = @CountryId";
            spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "CountryId", Value = ValidationHelper.GetGuid(pCountryId) });
        }


        if (ValidationHelper.GetGuid(pCorporationId) != Guid.Empty)
        {
            if (pCorporationId != "00000000-0000-0000-0000-000000000001")
            {
                strSql += " and o.new_CorporationID = @CorporationId";
                spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "CorporationId", Value = ValidationHelper.GetGuid(pCorporationId) });

            }
            else
            {
                strSql += " AND c.new_UseUptPool=1";

            }

        }

        if (ValidationHelper.GetGuid(pBrandId) != Guid.Empty)
        {
            strSql += " and o.new_BrandId =  @BrandId";
            spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "BrandId", Value = ValidationHelper.GetGuid(pBrandId) });
        }

        if (!string.IsNullOrEmpty(new_StateId.Value))
        {
            strSql += " and o.new_StateId = @StateId";
            spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "StateId", Value = ValidationHelper.GetGuid(new_StateId.Value) });
        }

        if (!string.IsNullOrEmpty(new_CityId.Value))
        {
            strSql += " and o.new_CityId = @CityId";
            spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "CityId", Value = ValidationHelper.GetGuid(new_CityId.Value) });
        }

        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("PAYMENT_LOCATIONS");
        var sort = string.Empty;


        //spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "CountryId", Value = ValidationHelper.GetGuid(New_CountryId.Value) });

        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelPayments.Start();
        var limit = GridPanelPayments.Limit();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        GridPanelPayments.TotalCount = cnt;

        GridPanelPayments.DataSource = t;
        GridPanelPayments.DataBind();

    }

    protected void GridToPdf(Object sender, AjaxEventArgs e)
    {
        string countryId = new_CountryID.Value;
        string corpId = new_CorporationID.Value;
        string cityId = new_CityId.Value;
        string stateId = new_StateId.Value;
        string brandId = new_BrandId.Value;


        string strSql = @"select top 1 ReportsId from vReports where ReportName ='OfficeToPdf'";
        var spList = new List<CrmSqlParameter>();

        string reportId = new StaticData().ExecuteScalar(strSql).ToString();

        string parameters = "";
        QScript(
            "window.top.newWindowRefleX(window.top.GetWebAppRoot + '/CrmPages/AutoPages/Reports/ShowReport.aspx?&ReportId=" +
            reportId + "&exportType=PDF&Parameters=CountryId;CorpId;CityId;StateId;BrandId&"
            + "p0=" + countryId + "&"
            + "p1=" + corpId + "&"
            + "p2=" + cityId + "&"
            + "p3=" + stateId + "&"
            + "p4=" + brandId
            + "', { maximized: false, width: 890, height: 600, resizable: true, modal: true, maximizable: false });");
    }

    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
        }
        base.OnPreInit(e);
    }



}