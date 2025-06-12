using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Web.UI;
using TuFactory.Sender;

public partial class CustAccount_CustomerAccountsDetail_CustAccountAddPage : BasePage
{
    private int eurCustAccounts;
    private int usdCustAccounts;
    private int tryCustAccounts;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {

            Guid senderId = ValidationHelper.GetGuid(Page.Request.QueryString["senderID"]);
            if (senderId != Guid.Empty)
            {
                SenderAfterSaveDb senderDb = new SenderAfterSaveDb();

                DataTable dt = senderDb.GetSenderCustAccounts(senderId);

                hdnCustAccountTypeId.Value = senderDb.GetSenderCustAccountType(senderId);

                if (dt != null)
                {
                    eurCustAccounts = 0;
                    usdCustAccounts = 0;
                    tryCustAccounts = 0;

                    foreach (DataRow item in dt.Rows)
                    {
                        if (item["CurrencyCode"].ToString() == "EUR")
                        {
                            checkEur.Checked = true;
                            eurCustAccounts++;
                        }
                        else if (item["CurrencyCode"].ToString() == "USD")
                        {
                            checkUsd.Checked = true;
                            usdCustAccounts++;
                        }
                        else if (item["CurrencyCode"].ToString() == "TRY")
                        {
                            checkTry.Checked = true;
                            tryCustAccounts++;
                        }
                    }

                    hdnEurCount.Value = eurCustAccounts.ToString();
                    hdnUsdCount.Value = usdCustAccounts.ToString();
                    hdnTryCount.Value = tryCustAccounts.ToString();

                    lblEurCount.Text = eurCustAccounts.ToString();
                    lblUsdCount.Text = usdCustAccounts.ToString();
                    lblTryCount.Text = tryCustAccounts.ToString();
                }
            }
        }
    }

    protected override void OnPreInit(EventArgs e)
    {
        base.OnPreInit(e);
    }


    protected void btnCreateCustAccount(object sender, AjaxEventArgs e)
    {
        bool eur = false;
        bool usd = false;
        bool tl = false;

        if (checkEur.Checked)
        {
            eur = true;
        }
        if (checkUsd.Checked)
        {
            usd = true;
        }
        if (checkTry.Checked)
        {
            tl = true;
        }

        StaticData sd = new StaticData();
        DbTransaction tr = sd.GetDbTransaction();

        Guid tryId = UPT.Shared.CacheProvider.Service.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId;
        Guid usdId = UPT.Shared.CacheProvider.Service.CurrencyService.GetCurrencyByCurrencyCode("USD").CurrencyId;
        Guid eurId = UPT.Shared.CacheProvider.Service.CurrencyService.GetCurrencyByCurrencyCode("EUR").CurrencyId;

        try
        {
            var senderAfterSaveDb = new TuFactory.Sender.SenderAfterSaveDb();

            Guid senderId = ValidationHelper.GetGuid(Page.Request.QueryString["senderID"]);

            Guid CustAccountTypeId = ValidationHelper.GetGuid(hdnCustAccountTypeId.Value);

            var custAccountTypeCode = GetCustAccountTypeCode(ValidationHelper.GetGuid(CustAccountTypeId));

            if (eur)
            {
                if ((custAccountTypeCode =="002" && Convert.ToInt32(hdnEurCount.Value) <2) || (custAccountTypeCode == "001" && Convert.ToInt32(hdnEurCount.Value) == 0))
                {
                    var custAccountId = senderAfterSaveDb.CreateCustAccount(senderId, eurId, App.Params.CurrentUser.CorporationId, App.Params.CurrentUser.Office.OfficeId, tr);
                }
                else
                {
                    throw new Exception("EUR için Maksimum hesap limitini aşamazsınız.");                  
                }
            }
            if (usd)
            {
                if ((custAccountTypeCode == "002" && Convert.ToInt32(hdnUsdCount.Value) < 2) || (custAccountTypeCode == "001" && Convert.ToInt32(hdnUsdCount.Value) == 0))
                {
                    var custAccountId = senderAfterSaveDb.CreateCustAccount(senderId, usdId, App.Params.CurrentUser.CorporationId, App.Params.CurrentUser.Office.OfficeId, tr);
                }
                else
                {
                    throw new Exception("USD için Maksimum hesap limitini aşamazsınız.");
                }
            }
            if (tl)
            {
                if ((custAccountTypeCode == "002" && Convert.ToInt32(hdnTryCount.Value) < 2) || (custAccountTypeCode == "001" && Convert.ToInt32(hdnTryCount.Value) == 0))
                {
                    var custAccountId = senderAfterSaveDb.CreateCustAccount(senderId, tryId, App.Params.CurrentUser.CorporationId, App.Params.CurrentUser.Office.OfficeId, tr);
                }
                else
                {
                    throw new Exception("TRY için Maksimum hesap limitini aşamazsınız.");
                }
            }

            StaticData.Commit(tr);

            QScript("alert('Hesap açma işlemi tamamlandı.');");
            QScript(" RefreshParetnGrid(true); ");

        }
        catch (Exception ex)
        {
            LogUtil.Write(ex.Message);
            StaticData.Rollback(tr);
            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
            return;
         
        }
    }

    private string GetCustAccountTypeCode(Guid CustAccountTypeId)
    {
        string result = string.Empty;
        if (CustAccountTypeId == Guid.Empty)
            return result;

        DataTable dt = new DataTable();

        try
        {
            var sd = new StaticData();
            sd.AddParameter("CustAccountTypeId", DbType.Guid, CustAccountTypeId);
            dt = sd.ReturnDataset(@"Select new_EXTCODE From vNew_CustAccountType(NoLock)
                                            Where DeletionStateCode = 0 And New_CustAccountTypeId = @CustAccountTypeId
                                            ").Tables[0];
            result = ValidationHelper.GetString(dt.Rows[0]["new_EXTCODE"]);
        }
        catch (Exception ex)
        {
            throw ex;
        }

        return result;
    }
}