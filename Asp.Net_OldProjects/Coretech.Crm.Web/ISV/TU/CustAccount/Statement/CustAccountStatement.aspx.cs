using System;
using System.Web.UI;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using AjaxPro;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.WorkFlow;
using TuFactory.Object;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using TuFactory.CustAccount.Business.Service;
using TuFactory.CustAccount.Business;
using TuFactory.CustAccount.Object;
using TuFactory.CustAccount.Object.Common;
using Newtonsoft.Json;
using Coretech.Crm.Factory.Crm;

public partial class CustAccount_Statement_CustAccountStatement : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            Utility.RegisterTypeForAjax(typeof(AjaxMethods));
            Page.ClientScript.RegisterStartupScript(typeof(string), "EmailSentMessage", "var EmailSentMessage="
                + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTSTATEMENT_EMAIL_SENT")) + ";", true);
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
            }
        }
        else
        {
            new_CustAccountId.Clear();
        }
    }

    protected void new_CustAccountId_OnChange(object sender, AjaxEventArgs e)
    {
        var custAccountId = Guid.Empty;
        if (!string.IsNullOrEmpty(new_CustAccountId.Value))
        {
            custAccountId = ValidationHelper.GetGuid(new_CustAccountId.Value);
        }
        var df = new DynamicFactory(ERunInUser.CalingUser);
        var de = df.RetrieveWithOutPlugin(TuEntityEnum.New_CustAccounts.GetHashCode(), custAccountId, new[] { "new_CustAccountCurrencyId",
            "new_Balance", "new_SenderId", "new_CustAccountTypeId" });
        var currency = de.GetLookupValue("new_CustAccountCurrencyId");
        var balance = de.GetDecimalValue("new_Balance");
        if (currency != Guid.Empty)
        {
            var senderF = de.Properties["new_SenderId"] as Lookup;
            var custAccountTypeId = de.Properties["new_CustAccountTypeId"] as Lookup;
            if (senderF != null && senderF.Value != ValidationHelper.GetGuid(new_SenderId.Value))
            {
                new_SenderId.SetValue(senderF.Value.ToString(), senderF.name);
                new_SenderId.Value = senderF.Value.ToString();
                new_SenderId_OnChange(null, null);
            }
            if (custAccountTypeId != null && custAccountTypeId.Value != ValidationHelper.GetGuid(new_CustAccountTypeId.Value))
            {
                new_CustAccountTypeId.SetValue(custAccountTypeId.Value.ToString(), custAccountTypeId.name);
                new_CustAccountTypeId.Value = custAccountTypeId.Value.ToString();
            }
        }
    }

    protected void btnPdfWatch_OnClick(object sender, AjaxEventArgs e)
    {
        CustAccountStatementFactory casf = new CustAccountStatementFactory();
        var reportID = casf.GetReportId();
        if (reportID == Guid.Empty)
        {
            QScript("alert('[Müşteri Hesap Ekstresi] adlı rapor yok ya da artık görüntülenemiyor.');");
        }
        else
        {
            if(!checkMandotaryFields(false))
            {
                QScript("alert('Lütfen zorunlu alanları doldurarak extre oluşturmayı deneyiniz');");
                return;
            }
            else
            {
                QScript(string.Format("hdnReportId.setValue('{0}');", reportID));
                QScript("ShowAccountStatementReport(1);");
            }
        }
    }

    private bool checkMandotaryFields(bool isEmailMand)
    {
        if(new_CustAccountTypeId.RequirementLevel== RLevel.BusinessRequired && String.IsNullOrEmpty(new_CustAccountTypeId.Value))
        {
            return false;
        }
        if (new_SenderId.RequirementLevel == RLevel.BusinessRequired && String.IsNullOrEmpty(new_SenderId.Value))
        {
            return false;
        }
        if (new_CustAccountId.RequirementLevel == RLevel.BusinessRequired && String.IsNullOrEmpty(new_CustAccountId.Value))
        {
            return false;
        }
        if (cmbStatementDateStart.RequirementLevel == RLevel.BusinessRequired && cmbStatementDateStart.Value ==null)
        {
            return false;
        }
        if (cmbStatementDateEnd.RequirementLevel == RLevel.BusinessRequired && cmbStatementDateEnd.Value==null)
        {
            return false;
        }
        if (isEmailMand && txtEmail.RequirementLevel == RLevel.BusinessRequired && String.IsNullOrEmpty(txtEmail.Value))
        {
            return false;
        }
        return true;
    }

    protected void btnPdfMail_OnClick(object sender, AjaxEventArgs e)
    {
        if (!checkMandotaryFields(true))
        {
            QScript("alert('Lütfen zorunlu alanları doldurarak extre oluşturmayı deneyiniz');");
            return;
        }
        CustAccountStatementService statementService = new CustAccountStatementService();
        CustAccountStatement statement = new CustAccountStatement()
        {
            AccountId = ValidationHelper.GetGuid(new_CustAccountId.Value),
            StartDate = ValidationHelper.GetDate(cmbStatementDateStart.Value),
            EndDate = ValidationHelper.GetDate(cmbStatementDateEnd.Value)
        };
        statementService.SendEmailStatement(statement, txtEmail.Value, CustAccountStatementFileFormat.Extension.Pdf, true);
        QScript("alert(EmailSentMessage);");
    }

    [AjaxNamespace("AjaxMethods")]
    
    public class AjaxMethods
    {
        [AjaxMethod()]
        public string GetEmailAdress(Guid senderID)
        {
            return CustAccountStatementService.GetSenderEmailAdress(senderID);
        }
    }
}