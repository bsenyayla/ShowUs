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
using Coretech.Crm.Factory;
using System.Data.Common;
using TuFactory.MessageQueue;

public partial class RefundTransfer_RefundTransferQueue : BasePage
{
    #region Variables

    private DynamicSecurity _dynamicSecurity;

    #endregion

    protected override void OnPreInit(EventArgs e)
    {
        hdnRecId.Value = QueryHelper.GetString("recid");
        if (!RefleX.IsAjxPostback)
        {

        }
        base.OnPreInit(e);

    }

    protected void Page_Load(object sender, EventArgs e)
    {
        _dynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_RefundTransferQueue.GetHashCode(), null);
        if (!(_dynamicSecurity.PrvCreate || _dynamicSecurity.PrvRead || _dynamicSecurity.PrvWrite))
            Response.End();

        if (!RefleX.IsAjxPostback)
        {


            var approvalCannotUpdate = ApprovalFactory.CheckApprovalByRecordId(TuEntityEnum.New_RefundTransferQueue.GetHashCode(),
                        ValidationHelper.GetGuid(hdnRecId.Value));

            if (approvalCannotUpdate)
            {
                lblError.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_APPROVAL_CANNOT_UPDATE);
                lblError.Visible = true;
                btnSend.Visible = false;

            }

            LoadData();


        }
    }



    private void LoadData()
    {
        if (string.IsNullOrEmpty(hdnRecId.Value))
        {
            btnSend.Visible = true;
            return;
        }

        DynamicFactory df;
        df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };


        var refundTransferQueue = df.Retrieve(TuEntityEnum.New_RefundTransferQueue.GetHashCode(),
                                          ValidationHelper.GetGuid(hdnRecId.Value),
                                          DynamicFactory.RetrieveAllColumns);


        TuReferans.FillDynamicEntityData(refundTransferQueue);
        new_BankTransactionNumber.FillDynamicEntityData(refundTransferQueue);
        btnSend.Visible = false;

    }

    protected void btnSendOnEvent(object sender, AjaxEventArgs e)
    {
        if (TuReferans.IsEmpty)
        {
            var msg = new MessageBox { Width = 500 };
            msg.Show("Referans girmelisiniz");
            return;
        }

        if (new_BankTransactionNumber.IsEmpty)
        {
            var msg = new MessageBox { Width = 500 };
            msg.Show("Banka işlem no girmelisiniz");
            return;
        }

        StaticData sd = new StaticData();

        DbTransaction tr = sd.GetDbTransaction();

        try
        {

            sd.AddParameter("TuReferans", DbType.String, ValidationHelper.GetString(TuReferans.Value));
            sd.AddParameter("BankTransactionNumber", DbType.String, ValidationHelper.GetString(new_BankTransactionNumber.Value));
            sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId));


            sd.ExecuteNonQuerySp("spTuInsertRefundTransferQueue", tr);




            TuFactory.Object.Refund.WSRefundTransferRequest request = new TuFactory.Object.Refund.WSRefundTransferRequest();

            request.BANKA_ISLEM_NO = ValidationHelper.GetString(new_BankTransactionNumber.Value);
            request.TU_REFERANS = ValidationHelper.GetString(TuReferans.Value);

            var ret = new TuFactory.Object.Refund.WSRefundTransferRequest
            {
                RefundTransferRequestStatus = new WsStatus()
            };

            UPTMQ.SendMessage("RefundTransfer", ValidationHelper.GetString(TuReferans.Value), request, App.Params.CurrentUser.SystemUserId.ToString());
            ret.RefundTransferRequestStatus.RESPONSE = WsStatus.response.Success;
            ret.RefundTransferRequestStatus.RESPONSE_DATA = string.Empty;

            
            StaticData.Commit(tr);


        }
        catch (Exception)
        {
            StaticData.Rollback(tr);
            throw;
        }










        QScript("LogCurrentPage();");
        var trans = (new StaticData()).GetDbTransaction();





        QScript("alert('İade Talebi gönderildi.');");


        QScript("RefreshParetnGridForCashTransaction(true);");


    }
}