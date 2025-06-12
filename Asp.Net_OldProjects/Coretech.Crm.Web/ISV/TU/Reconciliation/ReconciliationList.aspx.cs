using System;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using Coretech.Crm.Factory;

public partial class Reconciliation_ReconciliationList : BasePage
{
    private void TranslateMessage()
    {
        TabAb.Title = CrmLabel.TranslateMessage("CRM.NEW_RECONCILIATION_AB");
        TabCorporation.Title = CrmLabel.TranslateMessage("CRM.NEW_RECONCILIATION_CORPORATION");
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
            bool isLogoActive = ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("LOGO_ISACTIVE", "false"));
            TabLogo.Hidden = !isLogoActive;
            //TabAb.Hidden = isLogoActive;
            TabAb2.Hidden = !isLogoActive;
            TabOnlineUPT.Hidden = true;
            //TabAb.Hidden = false;
            //TabAb2.Hidden = true;
            TabUptBankCheck.Hidden = !ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("IS_UPT_BANK_RECONCILIATION_ACTIVE", "false"));
        }
    }
}