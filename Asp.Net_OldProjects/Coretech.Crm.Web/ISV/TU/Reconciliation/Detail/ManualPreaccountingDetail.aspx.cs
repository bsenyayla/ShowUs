using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using System;
using System.Data;
using TuFactory.CustomApproval;

namespace Coretech.Crm.Web.ISV.TU.Reconciliation.Detail
{
    public partial class ManualPreaccountingDetail : CustomApprovalPage<ManualPreAccountingApproval>
    {
        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };

        private string Reference;
        private string TransactionType;

        protected override void SetApprovalData()
        {
            ManualPreAccountingApproval item = base.Approval;
            switch (item.ManualPreaccountingType)
            {
                case ManualPreaccountingTypes.FreeReceipt:
                    new_MasterOperationTypeLabel.SetValue(item.OperationTypeLabel);
                    break;
                case ManualPreaccountingTypes.ReverseReceipt:
                    new_TransactionNumber.Value = item.TransactionNumber;
                    break;
            }

            this.Reference = item.TransactionReference;
            this.TransactionType = item.TransactionType;

            lblTransaction.SetValue(string.Format("{0} / {1}", this.Reference, this.TransactionType));
            lblFreeText.SetValue(string.Format("{0} / {1}", this.Reference, this.TransactionType));
                    
            new_TransactionNumber.Disabled = true;
            new_MasterOperationTypeLabel.Disabled = true;
            btnCreateReverseReceipt.Visible = false;
            btnCreateFreeReceipt.Visible = false;

            AccTranDataLoad(null, null);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                string mode = QueryHelper.GetString("mode");
                if (mode.ToLower() != "approval")
                {
                    this.Reference = QueryHelper.GetString("reference");
                    this.TransactionType = QueryHelper.GetString("transactionType");
                    lblTransaction.SetValue(string.Format("{0} / {1}", this.Reference, this.TransactionType));
                    lblFreeText.SetValue(string.Format("{0} / {1}", this.Reference, this.TransactionType));
                    AccTranDataLoad(null, null);
                }
            }            
        }

        protected void AccTranDataLoad(object sender, AjaxEventArgs e)
        {
            DataTable dt = new DataTable();

            string reference = this.Reference;

            var sd = new StaticData();
            string query = @"SELECT
	            AT.new_TransactionNumber AS [ISLEM_NO],
	            AT.new_TransactionTypeIdName AS [HESAP_HAREKET_TIPI],
	            ISNULL(MOTL.Label,'') AS [ISLEM_TIPI],
	            AT.new_Amount AS [TUTAR],
	            AT.new_AmountCurrencyName AS [DOVIZ_CINSI],
	            AT.new_AccountIdName AS [HESAP],
	            AT.new_Direction AS [YON],
	            AT.new_LogoAccountIdName AS [LOGO_HESAP],
	            AT.new_LogoDirection AS [LOGO_YON],
	            AT.CreatedByName AS [OLUSTURAN],
	            AT.CreatedOn AS [TARIH]
            FROM vNew_AccountTransactions AT (NOLOCK)
            LEFT JOIN new_PLNew_AccountTransactions_new_MasterOperationTypeLabel MOTL
            ON AT.new_MasterOperationTypeLabel = MOTL.Value AND MOTL.LangId = 1055
            WHERE AT.new_MasterTransactionReference = @Ref
            AND AT.DeletionStateCode = 0
            ORDER BY 1";
            sd.AddParameter("Ref", DbType.String, reference);
            dt = sd.ReturnDataset(query).Tables[0];

            gpAccTran.DataSource = dt;
            gpAccTran.DataBind();
        }

        protected void CreateReverseReceipt(object sender, AjaxEventArgs e)
        {
            this.Reference = QueryHelper.GetString("reference");
            this.TransactionType = QueryHelper.GetString("transactionType");

            string transactioNumber = new_TransactionNumber.Value;
            if (!string.IsNullOrEmpty(transactioNumber))
            {
                ManualPreAccountingApproval approval = new ManualPreAccountingApproval()
                {
                    ApprovalKey = this.Reference,
                    CreateUser = new TuFactory.Domain.SystemUser() { SystemUserId = App.Params.CurrentUser.SystemUserId },
                    ManualPreaccountingType = ManualPreaccountingTypes.ReverseReceipt,
                    TransactionNumber = transactioNumber,
                    TransactionReference = this.Reference,
                    TransactionType = this.TransactionType
                };

                string saveRet = approval.Save();
                if (string.IsNullOrEmpty(saveRet))
                {
                    MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                    msg1.Show("", "", "İşleminiz onaya gönderildi.");
                    return;
                }
                else
                {
                    MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
                    msg1.Show(saveRet);
                    return;
                }
            }
            else
            {
                MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
                msg1.Show("", "", "İşlem numarası bilgisi doldurulmalıdır.");
            }
        }

        protected void CreateFreeReceipt(object sender, AjaxEventArgs e)
        {
            this.Reference = QueryHelper.GetString("reference");
            this.TransactionType = QueryHelper.GetString("transactionType");

            string TransactionReference = this.Reference;

            var operationTypeLabel = new_MasterOperationTypeLabel.Value;

            if (string.IsNullOrEmpty(operationTypeLabel))
            {
                MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
                msg1.Show("", "", "İşlem tipi bilgisi doldurulmalıdır.");
                return;
            }

            if (!string.IsNullOrEmpty(TransactionReference))
            {
                ManualPreAccountingApproval approval = new ManualPreAccountingApproval()
                {
                    ApprovalKey = this.Reference,
                    CreateUser = new TuFactory.Domain.SystemUser() { SystemUserId = App.Params.CurrentUser.SystemUserId },
                    ManualPreaccountingType = ManualPreaccountingTypes.FreeReceipt,
                    TransactionReference = TransactionReference,
                    OperationTypeLabel = operationTypeLabel,
                    TransactionType = this.TransactionType
                };

                string saveRet = approval.Save();
                if (string.IsNullOrEmpty(saveRet))
                {
                    MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                    msg1.Show("", "", "İşleminiz onaya gönderildi.");
                    return;
                }
                else
                {
                    MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
                    msg1.Show(saveRet);
                    return;
                }
            }
            else
            {
                MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
                msg1.Show("", "", "İşlem referansı bilgisi doldurulmalıdır.");
            }
        }

        protected override void AfterApprove()
        {
            try
            {
                this.Reference = this.Approval.TransactionReference;
                this.TransactionType = this.Approval.TransactionType;

                AccTranDataLoad(null, null);
            }
            catch
            { }
        }
    }
}