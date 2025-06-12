using System;
using System.Collections.Generic;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;
using TuFactory.Integration3rd;
using TuFactory.Object.Confirm;
using TuFactory.Integrationd3rdLayer.Object;

public partial class Operation_Detail_ReadOnly : BasePage
{
    private readonly ConfirmFactory cf = new ConfirmFactory();
    private readonly MessageBox ms = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private TuUserApproval _userApproval = null;

    private void TranslateMessages()
    {
        ToolbarButtonLog.Text = CrmLabel.TranslateMessage("CRM.MENU.LOG");
        hdnOnayMessage.Value = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CONFIRMED");
        ToolbarButtonMd.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING_DETAIL");
        Btn3rdDetail.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_BTN3RDDETAIL");
    }


    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        var dynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_TransferEdit.GetHashCode(), null);

        var dynamicSecurityMobileDocument = DynamicFactory.GetSecurity(TuEntityEnum.New_MobileDocument.GetHashCode(), null);

        if (!RefleX.IsAjxPostback)
        {
            TranslateMessages();
            hdnObjectId.Value = QueryHelper.GetString("objectid");
            hdnRecid.Value = QueryHelper.GetString("recid");
            hdndoReceipt.Value = QueryHelper.GetString("doReceipt");
            hdndoReceiptEdit.Value = QueryHelper.GetString("doReceiptEdit");
            var poolId = QueryHelper.GetInteger("PoolId", 0);
            var readonlyform = string.Empty;
            switch (ValidationHelper.GetInteger(hdnObjectId.Value))
            {
                case (int)TuEntityEnum.New_Transfer:
                    readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_PAGE"));
                    hdnEntityId.Value = App.Params.CurrentEntity[TuEntityEnum.New_Transfer.GetHashCode()].EntityId.ToString();
                    break;
                case (int)TuEntityEnum.New_Payment:
                    readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("PAYMENT_READONLY_PAGE"));
                    hdnEntityId.Value = App.Params.CurrentEntity[TuEntityEnum.New_Payment.GetHashCode()].EntityId.ToString();
                    ToolbarButtonLog.Hide();
                    break;
                case (int)TuEntityEnum.New_RefundTransfer:
                    var readonlyformTmp = ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_PAGE"));

                    var queryTmp = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyformTmp },
                                {"ObjectId", TuEntityEnum.New_Transfer.GetHashCode().ToString()},
                            };
                    var urlparamTmp = QueryHelper.AddUrlString("/CrmPages/AutoPages/EditReflex.aspx", queryTmp);
                    ClientScript.RegisterClientScriptBlock(typeof(string), "transferUrl", "var transferUrl=" + SerializeString(urlparamTmp) + ";", true);
                    break;
            }
            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyform},
                                {"ObjectId", hdnObjectId.Value},
                                {"recid", hdnRecid.Value}
                            };
            string urlparam = QueryHelper.RefreshUrl(query);
            PanelIframe.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);

            if (dynamicSecurityMobileDocument.PrvRead)
            {
                BtnTransferDocumentShow.Visible = true;
            }
            else
            {
                BtnTransferDocumentShow.Visible = false;
            }

            if (poolId == 8)
            {
                ToolbarButtonEntLog.Visible = true;                
            }
            else
            {
                ToolbarButtonEntLog.Visible = false;                
            }

            /*Entegrasyon Class*/
            var i3Rd = new Integration3Rd();
            string str = i3Rd.GetTransferIntegrationCode(ValidationHelper.GetGuid(hdnRecid.Value), null);
            if (str == string.Empty)
            {
                Btn3rdDetail.Visible = false;
            }
            if (!string.IsNullOrEmpty(str))
            {
                string IntegrationAssembly = i3Rd.GetIntegrationClassByIntegrationChannelCode(str, null);

                if (IntegrationAssembly == string.Empty)
                {
                    Btn3rdDetail.Visible = false;
                }
            }



            var cf = new ConfirmFactory();
            var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(hdnRecid.Value));
            if (poolId == 8)
            {
                if (ts == TuConfirmStatus.GonderimYeniKayit)
                {

                    TuFactory.Integrationd3rdLayer.Integrationd3rd Integrator = i3Rd.GetIntegratorByTransferId(ValidationHelper.GetGuid(hdnRecid.Value));
                    if (Integrator == null)
                    {
                        btnCorpCancel.Visible = false;
                    }
                    else
                    {
                        btnCorpCancel.Visible = true;
                    }


                }
                else if (ts == TuConfirmStatus.GonderimOdemeOnProvizyon)
                {
                    Integration3Rd i3rd = new Integration3Rd();
                    TuFactory.Integrationd3rdLayer.Integrationd3rd Integrator = i3rd.GetPaymentIntegratorByTransferId(ValidationHelper.GetGuid(hdnRecid.Value), null);
                    if (Integrator == null)
                    {
                        btnCorpCancel.Visible = false;
                    }
                    else
                    {
                        btnCorpCancel.Visible = true;
                    }
                }
            }




        }

    }

    protected void IntegrationCorpCancel(object sender, AjaxEventArgs e)
    {
        var cf = new ConfirmFactory();
        var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(hdnRecid.Value));
        try
        {
            if (ts == TuConfirmStatus.GonderimYeniKayit)
            {
                var i3Rd = new Integration3Rd();
                string str = i3Rd.GetTransferIntegrationCode(ValidationHelper.GetGuid(hdnRecid.Value), null);

                TuFactory.Integrationd3rdLayer.Integrationd3rd Integrator = i3Rd.GetIntegratorByTransferId(ValidationHelper.GetGuid(hdnRecid.Value));

                TransferReturnType ret = Integrator.IntegrateTransferCancel(new IntegrateInput { TransferId = ValidationHelper.GetGuid(hdnRecid.Value), SystemUserId = App.Params.CurrentUser.SystemUserId });

                if (ret.OutputStatus.RESPONSE == IntegrationStatus.response.Success)
                {
                    ms.Show(".", ".", "Kurum İptal servisi çağrıldı.");
                }
                else
                {
                    ms.Show(".", ".", ret.OutputStatus.RESPONSE_DATA);
                }
            }
            else if (ts == TuConfirmStatus.GonderimOdemeOnProvizyon)
            {
                Integration3Rd i3rd = new Integration3Rd();

                TuFactory.Integrationd3rdLayer.Integrationd3rd Integrator = i3rd.GetPaymentIntegratorByTransferId(ValidationHelper.GetGuid(hdnRecid.Value), null);
                if (Integrator != null)
                {
                    PaymentReturnType ret = Integrator.IntegratePaymentCancel(new IntegrateInput { TransferId = ValidationHelper.GetGuid(hdnRecid.Value), SystemUserId = App.Params.CurrentUser.SystemUserId });

                    if (ret.OutputStatus.RESPONSE == IntegrationStatus.response.Success)
                    {
                        ms.Show(".", ".", "Kurum İptal servisi çağrıldı.");
                    }
                    else
                    {
                        ms.Show(".", ".", ret.OutputStatus.RESPONSE_DATA);
                    }
                }

            }


        }
        catch (Exception ex)
        {
            ms.Show(".", ".", ex.Message);
            return;

        }










    }
}