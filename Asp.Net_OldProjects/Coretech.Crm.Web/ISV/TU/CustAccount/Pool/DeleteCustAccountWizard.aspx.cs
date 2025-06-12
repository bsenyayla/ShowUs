using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using Newtonsoft.Json;
using RefleXFrameWork;
using TuFactory.CustAccount.Business;
using Object = TuFactory.CustAccount.Object;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;
using TuFactory.CustAccount.Business.Service;
using Domain.Entities;
using Services.Interfaces;
using Services;
using TuFactory.Domain.Enums;

public partial class CustAccount_Pool_DeleteCustAccountWizard : BasePage
{
    #region Variables
    private TuUser _activeUser = null;
    private string _CountryCurrencyID;
    private DynamicSecurity DynamicSecurity;
    bool isNewAmount;
    private bool isTuzel;
    private const string aboutblank = "about:blank";
    #endregion
    private void AddMessages()
    {
        var Messages = new
        {
            //NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_CONFIRM"),
            //NEW_CUSTACCOUNTOPERATION_SURE_REJECT = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATION_SURE_REJECT")
        };
        RegisterClientScriptBlock("DasMessages", string.Format("var DasMessages={0};", JsonConvert.SerializeObject(Messages)));
        const string strCustAccountTypeCodetemp = "var CustAccountType_{0} = \"{1}\";";
        var sb = new StringBuilder();

        foreach (var item in new CustAccountOperations().GetCustAccountTypeList())
        {
            sb.AppendLine(string.Format(strCustAccountTypeCodetemp, item.Code, item.Id.ToLower()));
        }

        RegisterClientScriptBlock("strCustAccountTypeCodetemp", sb.ToString());
        sb.Clear();


    }
    private void SetDefaults()
    {
        mfsender.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_SenderId",
         TuEntityEnum.New_CustAccountOperations.GetHashCode());
        lblnew_CustAccountTypeId2.FieldLabel =
        lblnew_CustAccountTypeId3.FieldLabel =
        CrmLabel.TranslateAttributeLabelMessage("new_CustAccountTypeId", TuEntityEnum.New_CustAccountOperations.GetHashCode());
        mlCustAccount2.FieldLabel =
        mlCustAccount3.FieldLabel =
        CrmLabel.TranslateAttributeLabelMessage("new_CustAccountId", TuEntityEnum.New_CustAccountOperations.GetHashCode());
        new_IdentityWasSeenReadOnly.FieldLabel = CrmLabel.TranslateAttributeLabelMessage("new_IdentityWasSeen", TuEntityEnum.New_CustAccountOperations.GetHashCode());

        lblnew_SenderId2.FieldLabel =
        lblnew_SenderId3.FieldLabel =
        CrmLabel.TranslateAttributeLabelMessage("new_SenderId", TuEntityEnum.New_CustAccountOperations.GetHashCode());


        var ufFactory = new TuUserFactory();
        _activeUser = ufFactory.GetActiveUser();
        new_CorporationId.Value = _activeUser.CorporationId.ToString();
        new_OfficeId.Value = _activeUser.OfficeId.ToString();

    }
    public bool isTuzelAccountType()
    {
        var tuzelid = string.Empty;
        var gercekid = string.Empty;
        foreach (var item in new CustAccountOperations().GetCustAccountTypeList())
        {
            if (item.Code == "001")
                gercekid = item.Id.ToLower();
            if (item.Code == "002")
                tuzelid = item.Id.ToLower();
        }
        return new_CustAccountTypeId.Value == tuzelid;
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        isTuzel = isTuzelAccountType();
        DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_CustAccountType.GetHashCode(), null);
        if (!(DynamicSecurity.PrvCreate || DynamicSecurity.PrvRead || DynamicSecurity.PrvWrite))
            Response.End();

        var sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        var dt =
            sd.ReturnDataset(
                @"
SELECT 
u.new_CorporationID,c.new_CountryID,u.new_OfficeID , co.new_CurrencyID,new_CurrencyIDName,c.new_IsPartlyCollection,
o.new_CountryID OfficeCountryId,cao.New_CustAccountOperationTypeId as CustAccountOperationTypeId
FROM vSystemUser(nolock) u
INNER JOIN vNew_Corporation c on u.new_CorporationID = c.New_CorporationId
INNER JOIN vNew_Office o on o.New_OfficeId=u.new_OfficeID
LEFT OUTER JOIN vnew_country co ON co.New_CountryId=c.new_CountryID 
LEFT OUTER JOIN vnew_custaccountOperationType cao on cao.new_EXTCODE='004' and cao.DeletionStateCode=0
Where SystemUserId = @SystemUserId
")
                .Tables[0];

        if (dt.Rows.Count > 0)
        {

            _CountryCurrencyID = ValidationHelper.GetString(dt.Rows[0]["new_CurrencyID"]);
            new_CorporationId.SetValue(ValidationHelper.GetString(dt.Rows[0]["new_CorporationID"]));
            new_CustAccountOperationTypeId.Value = ValidationHelper.GetString(dt.Rows[0]["CustAccountOperationTypeId"]);
            new_CorporationCountryId.Value = ValidationHelper.GetString(dt.Rows[0]["new_CountryID"]);
        }

        if (!RefleX.IsAjxPostback)
        {
            RR.RegisterIcon(Icon.Add);
            AddMessages();
            PrepareItems();
            SetDefaults();
            QScript("pageLoad();");
        }

    }

    private void PrepareItems()
    {
        TuUserApproval userApproval = new TuUserFactory().GetApproval(App.Params.CurrentUser.SystemUserId);
        //Bakiye görme yetkisi yoksa
        if (!userApproval.CustAccountBalanceView)
        {
            new_CustAccountBalance.Hide();
            QScript("comboViewHideBalance();");
        }
    }

    #region ComponentEvents
    protected void new_CustAccountId_OnChange(object sender, AjaxEventArgs e)
    {

        var custAccountId = Guid.Empty;
        if (!string.IsNullOrEmpty(new_CustAccountId.Value))
        {
            custAccountId = ValidationHelper.GetGuid(new_CustAccountId.Value);
            var isRestricted = new CustAccountOperations().CanDisabled(custAccountId);
            if (!isRestricted)
            {
                new_CustAccountId.Clear();
                Upt.Alert(
                    string.Format(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_RESTRICTEDFORCASH"), new_CustAccountId.SelectedItems[0].VALUE)
                    );

                return;
            }
            var message = new CustAccountOperations().IsAvailableCustAccount(custAccountId);
            if (message != string.Empty)
            {
                new_CustAccountId.Clear();
                Upt.Alert(message);

                return;
            }

        }
        else
        {
            CustAccountIdDetail.AutoLoad.Url = aboutblank;
            CustAccountIdDetail.LoadUrl(CustAccountIdDetail.AutoLoad.Url);

        }

        RefreshCustAccount(custAccountId);
        SetCustAccountCurrencyId(custAccountId);
    }
    private void RefreshCustAccount(Guid custAccountId)
    {
        var ms = new MessageBox { Modal = true };


        if (custAccountId != Guid.Empty)
        {
            var readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_NEW_CUSTACCOUNTS_FORM"));

            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyform},
                                {"ObjectId",( (int)TuEntityEnum.New_CustAccounts).ToString()},
                                {"recid", custAccountId.ToString()},
                                {"mode", "-1"}
                            };
            var urlparam = QueryHelper.RefreshUrl(query);
            CustAccountIdDetail.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            CustAccountIdDetail.LoadUrl(CustAccountIdDetail.AutoLoad.Url);
            QScript(" R.reSize();");
        }
        else
        {
            if (!new_SenderId.IsEmpty)
            {
                ms.MessageType = EMessageType.Error;
                ms.Show(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_CUSTACCOUNT_NOT_FOUND"));
            }
        }
    }
    private void SetCustAccountCurrencyId(Guid custAccountId)
    {
        var df = new DynamicFactory(ERunInUser.CalingUser);
        var de = df.RetrieveWithOutPlugin(TuEntityEnum.New_CustAccounts.GetHashCode(), custAccountId, new[] { "new_CustAccountCurrencyId", "new_Balance", "new_SenderId", "new_CustAccountTypeId" });
        var currency = de.GetLookupValue("new_CustAccountCurrencyId");
        var balance = de.GetDecimalValue("new_Balance");

        if (balance != 0)
        {
            new_CustAccountId.Clear();
            Upt.Alert(
                string.Format(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_BALANCE_MUST_EQUAL_ZERO"), new_CustAccountId.SelectedItems[0].VALUE)
                );

            return;
        }

        if (currency != Guid.Empty)
        {
            var sender = de.Properties["new_SenderId"] as Lookup;
            var custAccountTypeId = de.Properties["new_CustAccountTypeId"] as Lookup;

            new_CustAccountCurrencyId.SetValue(ValidationHelper.GetString(((Lookup)de["new_CustAccountCurrencyId"]).Value), ((Lookup)de["new_CustAccountCurrencyId"]).name);
            new_CustAccountCurrencyId.Value = ValidationHelper.GetString(currency);
            new_CustAccountBalance.SetValue(ValidationHelper.GetString(balance));
            if (sender != null && sender.Value != ValidationHelper.GetGuid(new_SenderId.Value))
            {
                new_SenderId.SetValue(sender.Value.ToString(), sender.name);
                new_SenderId.Value = sender.Value.ToString();
                new_SenderId_OnChange(null, null);
            }
            if (custAccountTypeId != null && custAccountTypeId.Value != ValidationHelper.GetGuid(new_CustAccountTypeId.Value))
            {
                new_CustAccountTypeId.SetValue(custAccountTypeId.Value.ToString(), custAccountTypeId.name);
                new_CustAccountTypeId.Value = custAccountTypeId.Value.ToString();
            }

        }
        else
        {
            new_CustAccountCurrencyId.Clear();
            new_CustAccountBalance.Clear();
        }
    }

    protected void new_SenderId_OnChange(object sender, AjaxEventArgs e)
    {
        var senderId = ValidationHelper.GetGuid(new_SenderId.Value);
        if (senderId != Guid.Empty)
        {
            var df = new DynamicFactory(ERunInUser.SystemAdmin);
            var desender = df.RetrieveWithOutPlugin(TuEntityEnum.New_Sender.GetHashCode(), senderId, new[] { "new_CustAccountTypeId" });
            var CustAccountTypeId = desender.GetLookupValue("new_CustAccountTypeId");

            if (CustAccountTypeId != ValidationHelper.GetGuid(new_CustAccountTypeId.Value))
            {
                new_CustAccountTypeId.Value = CustAccountTypeId.ToString();
                new_CustAccountTypeId.SetValue(((Lookup)desender["new_CustAccountTypeId"]).Value.ToString(), ((Lookup)desender["new_CustAccountTypeId"]).name);
                isTuzel = isTuzelAccountType();
            }

        }
        else
        {
            new_CustAccountId.Clear();
            new_CustAccountCurrencyId.Clear();
            new_CustAccountBalance.Clear();
            CustAccountIdDetail.AutoLoad.Url = aboutblank;
            SenderDetail.AutoLoad.Url = aboutblank;
            CustAccountIdDetail.AutoLoad.Url = aboutblank;
            CustAccountIdDetail.LoadUrl(CustAccountIdDetail.AutoLoad.Url);
            SenderDetail.AutoLoad.Url = aboutblank;
            SenderDetail.LoadUrl(SenderDetail.AutoLoad.Url);
        }
        RefreshSender(senderId);
    }
    private void RefreshSender(Guid senderId)
    {
        var ms = new MessageBox { Modal = true };

        if (senderId != Guid.Empty)
        {
            var readonlyRealform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_FOR_CUSTACCOUNT_REAL_FORM"));
            var readonlyTuzelform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_FOR_CUSTACCOUNT_CORP_FORM"));

            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", isTuzel ? readonlyTuzelform : readonlyRealform},
                                {"ObjectId",( (int)TuEntityEnum.New_Sender).ToString()},
                                {"recid", senderId.ToString()},
                                {"mode", "-1"}
                            };
            var urlparam = QueryHelper.RefreshUrl(query);
            SenderDetail.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            SenderDetail.LoadUrl(SenderDetail.AutoLoad.Url);
            QScript(" R.reSize();");
        }
        else
        {
            if (!new_SenderId.IsEmpty)
            {
                ms.MessageType = EMessageType.Error;
                ms.Show(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDER_NOT_FOUND"));
            }
        }
    }
    protected void new_SenderPersonId_OnChange(object sender, AjaxEventArgs e)
    {
        var senderPersonId = ValidationHelper.GetGuid(new_SenderPersonId.Value);
        var ms = new MessageBox { Modal = true };

        if (senderPersonId != Guid.Empty)
        {
            var readonlyRealform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("READONLY_SENDER_PERSON_FORM"));
            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid",  readonlyRealform},
                                {"ObjectId",( (int)TuEntityEnum.New_SenderPerson).ToString()},
                                {"recid", senderPersonId .ToString()},
                                {"mode", "-1"}
                            };
            var urlparam = QueryHelper.RefreshUrl(query);
            SenderPersonDetail.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            SenderPersonDetail.LoadUrl(SenderPersonDetail.AutoLoad.Url);
            QScript(" R.reSize();");
        }
        else
        {
            if (!new_SenderId.IsEmpty)
            {
                ms.MessageType = EMessageType.Error;
                ms.Show(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDER_NOT_FOUND"));
            }
        }
    }
    #region Control Event Methods

    CloseAccountItem GetCloseAccountItem()
    {
        #region CloseAccountItem Object

        CloseAccountItem closeAccountItem = new CloseAccountItem();

        closeAccountItem.CustAccountOperationType = new CustAccountOperationType()
        {
            CustAccountOperationTypeId = ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value)
        };

        closeAccountItem.Sender = new Sender()
        {
            SenderId = ValidationHelper.GetGuid(new_SenderId.Value)
        };

        closeAccountItem.CustAccountType = new CustAccountType()
        {
            CustAccountTypeId = ValidationHelper.GetGuid(new_CustAccountTypeId.Value)
        };

        closeAccountItem.CustAccountCurrency = new Currency()
        {
            CurrencyId = ValidationHelper.GetGuid(new_CustAccountCurrencyId.Value)
        };

        closeAccountItem.Corporation = new Corporation()
        {
            CorporationId = ValidationHelper.GetGuid(new_CorporationId.Value)
        };

        closeAccountItem.Office = new Office()
        {
            OfficeId = ValidationHelper.GetGuid(new_OfficeId.Value)
        };

        closeAccountItem.CustAccount = new CustAccount()
        {
            CustAccountId = ValidationHelper.GetGuid(new_CustAccountId.Value)
        };


        closeAccountItem.SenderIdentificationCardType = new IdentificatonCardType()
        {
            New_IdentificatonCardTypeId = ValidationHelper.GetGuid(new_SenderIdentificationCardTypeID.Value)
        };

        closeAccountItem.IdentityWasSeen = ValidationHelper.GetBoolean(new_IdentityWasSeen.Value);
        closeAccountItem.SenderIdentificationCardNo = ValidationHelper.GetString(new_SenderIdentificationCardNo.Value);
        closeAccountItem.SenderPerson = new SenderPerson()
        {
            SenderPersonId = ValidationHelper.GetGuid(new_SenderPersonId.Value)
        };

        #endregion



        return closeAccountItem;
    }

    protected void btnFinishOnClickEvent2(object sender, AjaxEventArgs e)
    {
        try
        {
            ICustAccountOperationService<object> _service = new CloseAccountService<object>();
            ICustAccountItem cashCreateAccountItem = GetCloseAccountItem();
            var response = _service.Request(cashCreateAccountItem);

            switch (response.OperationLevel)
            {
                case OperationLevel.AgeCheck:
                case OperationLevel.AccountCheckLimit:
                case OperationLevel.Calculate:
                    Alert(response.RETURN_DESCRIPTION);
                    break;
                case OperationLevel.CreateException:
                case OperationLevel.PreAccountingBalanceCheck:
                case OperationLevel.PrepareStatuUpdateException:
                    // Mesaj alt methodlardan throw edilecek
                    break;
                case OperationLevel.ConfirmCheck:
                case OperationLevel.FraudCheck:
                    if (response.ResponseStatus == ServiceResponseStatus.Error)
                    {
                        BasePage.QScript("btnFinis.hide();");
                        Alert(response.RETURN_DESCRIPTION);
                        BasePage.QScript("RefreshParetnGrid(true);");
                        return;
                    }
                    break;
                default:
                    break;
            }

            Response.Redirect("CustAccountRouter.aspx?recid=" + cashCreateAccountItem.CustAccountOperationId);
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "CustAccount_Pool_DepositTransaction");
            Alert(ex.Message);
            BasePage.QScript("RefreshParetnGrid(true);");
        }
    }

    protected void btnFinishOnClickEvent(object sender, AjaxEventArgs e)
    {
        if (ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("WORK_WITH_THE_NEW_CUSTACCOUNT_SERVICE")))
        {
            btnFinishOnClickEvent2(sender, e);
            return;
        }

        StaticData sd = new StaticData();
        var tr = sd.GetDbTransaction();
        DynamicFactory df = new DynamicFactory(ERunInUser.CalingUser);
        df.GetBeginTrans(tr);
        DynamicEntity de = new DynamicEntity(TuEntityEnum.New_CustAccountOperations.GetHashCode());
        try
        {

            de.AddLookupProperty("new_CustAccountOperationTypeId", "",
                ValidationHelper.GetGuid(new_CustAccountOperationTypeId.Value));
            de.AddLookupProperty("new_SenderId", "", ValidationHelper.GetGuid(new_SenderId.Value));
            de.AddLookupProperty("new_CustAccountTypeId", "", ValidationHelper.GetGuid(new_CustAccountTypeId.Value));
            de.AddLookupProperty("new_CustAccountCurrencyId", "",
                ValidationHelper.GetGuid(new_CustAccountCurrencyId.Value));
            de.AddLookupProperty("new_CorporationId", "", ValidationHelper.GetGuid(new_CorporationId.Value));
            de.AddLookupProperty("new_OfficeId", "", ValidationHelper.GetGuid(new_OfficeId.Value));
            de.AddLookupProperty("new_CustAccountId", "", ValidationHelper.GetGuid(new_CustAccountId.Value));


            de.AddLookupProperty("new_SenderIdentificationCardTypeID", "",
                ValidationHelper.GetGuid(new_SenderIdentificationCardTypeID.Value));
            de.AddBooleanProperty("new_IdentityWasSeen", ValidationHelper.GetBoolean(new_IdentityWasSeen.Value));
            de.AddStringProperty("new_SenderIdentificationCardNo",
                ValidationHelper.GetString(new_SenderIdentificationCardNo.Value));
            de.AddLookupProperty("new_SenderPersonId", "", ValidationHelper.GetGuid(new_SenderPersonId.Value));
            var id = df.Create(TuEntityEnum.New_CustAccountOperations.GetHashCode(), de);

            #region CheckForParameters
            sd.AddParameter("CustAccountOperationsId", DbType.Guid, id);
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            var ret = ValidationHelper.GetString(sd.ExecuteScalarSp("SpTuCustAccountDeleteAccountCheck", tr));
            if (!string.IsNullOrEmpty(ret))
            {
                throw new TuException(ValidationHelper.GetString(ret), "CUST001");
            }

            /*Statu Update edildi*/
            CustAccountApprovePoolService approvePoolService = new CustAccountApprovePoolService();
            Object.CustAccountApprovePoolResponse approvePoolResponse = approvePoolService.ApproveStageProcess(id, tr);
            /*Eğer Onay İşlemi Set Edilmemiş ise Otomatik olarak Onaylanır*/
            if (approvePoolResponse.result)
            {
                approvePoolService.ApproveCustAccountOperation(id, tr);
            }


            sd.AddParameter("CustAccountOperationsId", DbType.Guid, id);
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            ValidationHelper.GetString(sd.ExecuteScalarSp("SpTuCustAccountDeleteAccountPrepare", tr));

            #endregion
            StaticData.Commit(tr);
            if (!approvePoolResponse.result)
            {
                Alert(approvePoolResponse.message);
                BasePage.QScript("RefreshParetnGrid(true);");
            }
            else
            {
                Response.Redirect("CustAccountRouter.aspx?recid=" + id);
            }
        }
        catch (CrmException exc)
        {
            StaticData.Rollback(tr);
            var msg = new MessageBox();
            msg.Show(exc.ErrorMessage);
        }
        catch (TuException exc)
        {
            StaticData.Rollback(tr);
            exc.Show();
        }
        catch (Exception exc)
        {
            StaticData.Rollback(tr);
        }

        StaticData.Commit(tr);
    }
    #endregion

    protected void new_CountryIdentificationTypeLoad(object sender, AjaxEventArgs e)
    {


        var dft = new DynamicFactory(ERunInUser.CalingUser);
        DynamicEntity trt = new DynamicEntity();
        if (!isTuzel)
        {
            trt = dft.RetrieveWithOutPlugin(TuEntityEnum.New_Sender.GetHashCode(), ValidationHelper.GetGuid(new_SenderId.Value), new string[] { "new_NationalityID" });
        }
        else
        {
            trt = dft.RetrieveWithOutPlugin(TuEntityEnum.New_SenderPerson.GetHashCode(), ValidationHelper.GetGuid(new_SenderPersonId.Value), new string[] { "new_NationalityID" });
        }
        Guid new_NationalityID = ValidationHelper.GetGuid(trt.GetLookupValue("new_NationalityID"));

        if (new_NationalityID == Guid.Empty)
        {
            var m = new MessageBox { Width = 400, Height = 180 };
            var msg2 = CrmLabel.TranslateMessage("Uyruk Seçimi Yapılmamış.");
            m.Show(msg2);
            return;
        }

        string strSql = @"

Declare @Data table(new_IdentificationCardType UniqueIdentifier, new_IdentificationCardTypeName nvarchar(100))
            Declare @ExtCode nvarchar(50)
            Declare @Domesic bit
            Declare @Foreigner bit
            Select @ExtCode = new_ExtCode from vNew_nationality(nolock) where New_nationalityId = @NationalityID and DeletionStateCode = 0
            if @ExtCode = 'TR'
            BEGIN
	            Set @Domesic = 1
	            Set @Foreigner = 0
            END
            ELSE
            BEGIN
	            Set @Domesic = 0
	            Set @Foreigner = 1
            END


            If (@Domesic = 1)
            BEGIN
	            IF EXISTS(Select * from vNew_CountryIdentificatonCardType(nolock) cict inner join
	            vNew_CountryIDCTAuth(nolock) cicta
	            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
	            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsDomestic,0) = @Domesic
				and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0))
	            BEGIN
		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict inner join
		            vNew_CountryIDCTAuth(nolock) cicta
		            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsDomestic,0) = @Domesic
					and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0)
	            END

		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict 
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cict.DeletionStateCode = 0 and ISNULL(cict.new_IsDomestic,0) = @Domesic
					and cict.New_CountryIdentificatonCardTypeId not in
						(
							Select cict.New_CountryIdentificatonCardTypeId from vNew_CountryIdentificatonCardType(nolock) cict inner join
							vNew_CountryIDCTAuth(nolock) cicta
							on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
							where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsDomestic,0) = 0
							and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0)
						)

            END

            If (@Foreigner = 1)
            BEGIN
	            IF EXISTS(Select * from vNew_CountryIdentificatonCardType(nolock) cict inner join
	            vNew_CountryIDCTAuth(nolock) cicta
	            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
	            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsForeigner,0) = @Foreigner
				and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0))
	            BEGIN
		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict inner join
		            vNew_CountryIDCTAuth(nolock) cicta
		            on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsForeigner,0) = @Foreigner
					and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0)
	            END

		            Insert Into @Data
		            Select cict.new_IdentificationCardType,cict.new_IdentificationCardTypeName from vNew_CountryIdentificatonCardType(nolock) cict 
		            where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cict.DeletionStateCode = 0 and ISNULL(cict.new_IsForeigner,0) = @Foreigner
					and cict.New_CountryIdentificatonCardTypeId not in
						(
							Select cict.New_CountryIdentificatonCardTypeId from vNew_CountryIdentificatonCardType(nolock) cict inner join
							vNew_CountryIDCTAuth(nolock) cicta
							on cict.New_CountryIdentificatonCardTypeId = cicta.new_CountryIDCTypeId
							where cict.new_CountryID = @CountryId and cict.DeletionStateCode = 0 and cicta.DeletionStateCode = 0 and ISNULL(cicta.new_IsForeigner,0) = 0
							and cicta.new_CorporationId = (Select top 1 new_CorporationId from vSystemUser(nolock) Where SystemUserId = @SystemUserId and DeletionStateCode = 0)
						)

            END

		  Select distinct new_IdentificationCardType AS ID, l.Value AS VALUE, l.Value AS new_IdentificationCardTypeName from vNew_IdentificatonCardType(nolock) cict 
		  INNER JOIN @Data d On cict.New_IdentificatonCardTypeId = d.new_IdentificationCardType
		  LEFT JOIN New_IdentificatonCardTypeLabel(nolock) l On cict.New_IdentificatonCardTypeId = l.New_IdentificatonCardTypeId
		  Where cict.DeletionStateCode = 0 And l.LangId = (SELECT vsu.LanguageId FROM dbo.vSystemUser(nolock) vsu   WHERE  vsu.SystemUserId	= @SystemUserId AND vsu.DeletionStateCode = 0)";

        StaticData sd = new StaticData();
        sd.AddParameter("CountryId", DbType.Guid, ValidationHelper.GetGuid(new_CorporationCountryId.Value));
        sd.AddParameter("NationalityID", DbType.Guid, ValidationHelper.GetGuid(trt.GetLookupValue("new_NationalityID")));
        sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId));

        var like = new_SenderIdentificationCardTypeID.Query();

        if (!string.IsNullOrEmpty(like))
        {

            strSql += " AND l.Value LIKE  @new_IdentificationCardTypeName + '%' ";
            sd.AddParameter("new_IdentificationCardTypeName", DbType.String, like);
        }

        BindCombo(new_SenderIdentificationCardTypeID, sd, strSql);
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

    #endregion
    public class Upt
    {
        public static void AlertMessage(String message)
        {
            Alert(CrmLabel.TranslateMessage(message));
        }
        public static void Alert(String message)
        {
            QScript("Upt.alert(" + BasePage.SerializeString(message) + ",1,'');");
        }
    }


}