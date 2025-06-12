using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using RefleXFrameWork;
using System;
using System.Data;
using System.Web.UI;
using TuFactory.CustomApproval;

namespace Coretech.Crm.Web.ISV.TU.AccountTransactions
{
    public partial class BTNUpdate : CustomApprovalPage<BankTransactionNumberUpdateApproval>
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if(!Page.IsPostBack)
            {
            }
        }

        protected override void SetApprovalData()
        {
            bSearch.Hide();
            bSave.Hide();
            tTranNumber.Value = this.Approval.TransactionNumber;
            tBTN.Value = this.Approval.BankTransactionNumber;
            tTranNumber.SetDisabled(true);
            tBTN.SetDisabled(true);
            Search(null, null);
        }

        protected void Search(object sender, AjaxEventArgs e)
        {
            string tranNumber = tTranNumber.Value.Trim();
            if (!string.IsNullOrEmpty(tranNumber))
            {
                gpItems.DataSource = GetData(tranNumber);
                gpItems.DataBind();
            }
            else
            {
                ShowMessage("Arama için referans bilgisi girilmelidir.");
            }
        }

        protected void Save(object sender, AjaxEventArgs e)
        {
            string tranNumber = tTranNumber.Value.Trim();
            string bankTranNumber = tBTN.Value.Trim();
            if (!string.IsNullOrEmpty(tranNumber))
            {
                BankTransactionNumberUpdateApproval approval = new BankTransactionNumberUpdateApproval()
                {
                    ApprovalKey = tranNumber,
                    CreateUser = new TuFactory.Domain.SystemUser() { SystemUserId = App.Params.CurrentUser.SystemUserId },
                    TransactionNumber = tranNumber,
                    BankTransactionNumber = bankTranNumber
                };
                string result = approval.Save();
                if (string.IsNullOrEmpty(result))
                {
                    ShowMessage("Banka işlem numarası güncelleme işleminiz alındı; onay beklemektedir.");
                }
                else
                {
                    ShowMessage(result);
                }
            }
            else
            {
                ShowMessage("İşlem numarası bilgisi girilmelidir.");
            }
        }

        DataTable GetData(string tranNumber)
        {
            StaticData sd = new StaticData();
            sd.AddParameter("TranNumber", System.Data.DbType.String, tranNumber);
            return sd.ReturnDatasetSp("spGetAccountTransactionsByTranNumber").Tables[0];
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