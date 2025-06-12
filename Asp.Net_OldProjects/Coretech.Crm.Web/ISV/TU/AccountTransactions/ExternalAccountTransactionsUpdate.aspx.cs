using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.CustomApproval;

namespace Coretech.Crm.Web.ISV.TU.AccountTransactions
{
    public partial class ExternalAccountTransactionsUpdate : CustomApprovalPage<ExternalAccountTransactionUpdateApproval>
    {
        protected override void SetApprovalData()
        {
            bSearch.Hide();
            bRefresh.Hide();
            tBankTranNumber.Value = this.Approval.BankTransactionNumber;
            tBankTranNumber.SetDisabled(true);
            Search(null, null);
        }

        protected void Search(object sender, AjaxEventArgs e)
        {
            string bankTranNumber = tBankTranNumber.Value.Trim();
            if (!string.IsNullOrEmpty(bankTranNumber))
            {
                gpItems.DataSource = GetData(bankTranNumber);
                gpItems.DataBind();
            }
            else
            {
                ShowMessage("Arama için banka işlem numarası bilgisi girilmelidir.");
            }
        }

        protected void Refresh(object sender, AjaxEventArgs e)
        {
            string bankTranNumber = tBankTranNumber.Value.Trim();
            if (!string.IsNullOrEmpty(bankTranNumber))
            {
                ExternalAccountTransactionUpdateApproval approval = new ExternalAccountTransactionUpdateApproval()
                {
                    ApprovalKey = bankTranNumber,
                    CreateUser = new TuFactory.Domain.SystemUser() { SystemUserId = App.Params.CurrentUser.SystemUserId },
                    BankTransactionNumber = bankTranNumber
                };
                string result = approval.Save();
                if (string.IsNullOrEmpty(result))
                {
                    ShowMessage("Banka işlem numarası için banka hesap hareketleri tekrar aktarıma açılacaktır; işlem onay beklemektedir.");
                }
                else
                {
                    ShowMessage(result);
                }
            }
            else
            {
                ShowMessage("Bank işlem numarası bilgisi girilmelidir.");
            }
        }

        DataTable GetData(string bankTranNumber)
        {
            StaticData sd = new StaticData();
            sd.AddParameter("BankTransactionNumber", System.Data.DbType.String, bankTranNumber);
            return sd.ReturnDatasetSp("spGetExternalAccountTransactionsByBankTranNumber").Tables[0];
        }

        void ShowMessage(string messageText)
        {
            MessageBox messageBox = new MessageBox();
            messageBox.Width = 400;
            messageBox.Height = 200;
            messageBox.Show(messageText);
        }
    }
}