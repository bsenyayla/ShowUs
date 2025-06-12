using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Integration3rd.Cloud.Domain;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.CloudService;
using TuFactory.CustomApproval;

namespace Coretech.Crm.Web.ISV.TU.AccountTransactions
{
    public partial class CloudAccountTransactionDetailApproval : CustomApprovalPage<CloudAccountTransactionApproval>
    {
        CloudServiceFactory fac = new CloudServiceFactory();

        protected override void SetApprovalData()
        {
            Guid officeId;
            int? cancelTransaction = this.Approval.CloudPaymentStatus;
            txtRecId.Value = ValidationHelper.GetString(this.Approval.CloudAccountTransacionId.ToString());


            DataTable rec = fac.GetCloudAccountTransactionId(ValidationHelper.GetGuid(txtRecId.Value));

            if (rec.Rows.Count <= 0)
                return;

            if (cancelTransaction == (int)CloudPaymentStatus.IPTAL_EDILDI)
                lCancelTransaction.SetVisible(true);
            else
                lCancelTransaction.SetVisible(false);


            int status = ValidationHelper.GetInteger(rec.Rows[0]["new_ErrorStatus"].ToString(), -1);

            officeId = ValidationHelper.GetGuid(rec.Rows[0]["new_OfficeId"].ToString());
            if (officeId != Guid.Empty)
                new_OfficeId.SetValue(officeId);

            //ofis tanımı bulanamadı durumunda
            if (status == 2 || officeId == Guid.Empty)
            {
                new_OfficeId.SetReadOnly(false);
                //BtnSave.SetVisible(true);
 
            }


            cloudPaymentDateS.SetValue(rec.Rows[0]["CloudPaymentDate"].ToString());
            new_CloudPaymentId.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_CloudPaymentId"].ToString()));
            Reference.SetValue(ValidationHelper.GetString(rec.Rows[0]["Reference"].ToString()));
            //new_Amount.SetValue(ValidationHelper.GetDecimal(rec.Rows[0]["new_Amount"].ToString(),0));
            new_Amount.SetValue(rec.Rows[0]["new_Amount"].ToString());
            new_CurrencyCode.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_CurrencyCode"].ToString()));
            new_PaymentExpCode.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_PaymentExpCode"].ToString()));
            new_SenderFullName.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_SenderFullName"].ToString()));
            new_SenderIdentityNo.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_SenderIdentityNo"].ToString()));
            new_SenderIban.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_SenderIban"].ToString()));
            new_RecipientIban.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_RecipientIban"].ToString()));
            new_RecipentBankName.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_RecipentBankName"].ToString()));
            new_ErrorStatus.SetValue(ValidationHelper.GetInteger(rec.Rows[0]["new_ErrorStatus"].ToString(), -1));
            new_ErrorExplanation.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_ErrorExplanation"].ToString()));
            new_Explanation.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_Explanation"].ToString()));
            new_VirmanIdName.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_VirmanIdName"].ToString()));
            new_BankTransactionRefNo.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_BankTransactionRefNo"].ToString()));
            new_NKolayLimitRefNo.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_NKolayLimitRefNo"].ToString()));
            if (rec.Rows[0]["new_NKolayAccountTransferCompleted"].ToString() != null)
                new_NKolayAccountTransferCompleted.SetValue(ValidationHelper.GetBoolean(rec.Rows[0]["new_NKolayAccountTransferCompleted"].ToString()));

            if (rec.Rows[0]["new_IsNKolayLimitCreate"].ToString() != null)
                new_IsNKolayLimitCreate.SetValue(ValidationHelper.GetBoolean(rec.Rows[0]["new_IsNKolayLimitCreate"].ToString()));

            if (rec.Rows[0]["new_IsNkolayRepresentative"].ToString() != null)
                new_IsNkolayRepresentative.SetValue(ValidationHelper.GetBoolean(rec.Rows[0]["new_IsNkolayRepresentative"].ToString()));
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