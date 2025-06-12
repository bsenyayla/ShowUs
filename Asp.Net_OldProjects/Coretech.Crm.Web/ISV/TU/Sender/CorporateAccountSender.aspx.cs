using System;
using System.Collections.Generic;
using AjaxPro;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object.AjaxObject;
using TuFactory.Sender;
using Coretech.Crm.PluginData;
using System.Data.Common;
using static TuFactory.Fraud.FraudScanFactory;
using TuFactory.Sender.CorporateAccountSender;
using TuFactory.Sender.CorporateAccountSender.Model;
using System.Data;

public partial class Sender_CorporateAccountSender : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
        }
    }

    protected void btnCorporationFindClick(object sender, AjaxEventArgs e)
    {
        CorporateAccountSenderFactory tuzelFac = new CorporateAccountSenderFactory();

        CorporatedAccountInfoRequest request = new CorporatedAccountInfoRequest()
        {
            mersisNo = new_MersisNumber.Value,
            tcKimlikNo = new_SenderIdendificationNumber1.Value,
            vergiNo = new_TaxNo.Value,
            kullaniciAdiSoyadi = "UPT",
            kullaniciKodu = "UPT"
        };

        DataTable dt = tuzelFac.GetCorporatedAccountSender(request);
        if (dt != null)
        {
            windowTuzelInfo.Show();

            hdnSenderId.SetIValue(dt.Rows[0]["new_SenderId"]);
            SenderInfo.SetValue(dt.Rows[0]["Sender"]);
            new_SenderIdendificationNumber1Info.SetValue(dt.Rows[0]["new_SenderIdendificationNumber1"]);
            new_MersisNumberInfo.SetValue(dt.Rows[0]["new_MersisNumber"]);
            new_TaxNoInfo.SetValue(dt.Rows[0]["new_TaxNo"]);

            btnGoCustomer.SetVisible(true);
            btnUpdateCustomer.SetVisible(true);
            btnSaveCustomer.SetVisible(false);

            MessageBox msg = new MessageBox();
            msg.Show("Girilen bilgilere ait müşteri sistemde mevcut!");


        }
        else
        {
            CorporatedAccountInfoResponse response = tuzelFac.GetCorporatedAccountSenderInfo(new CorporatedAccountInfoRequest()
            {
                mersisNo = new_MersisNumber.Value,
                tcKimlikNo = new_SenderIdendificationNumber1.Value,
                vergiNo = new_TaxNo.Value,
                kullaniciAdiSoyadi = "UPT",
                kullaniciKodu = "UPT"

            });

            if (response != null && response.firmaListesi != null && response.firmaListesi.Count > 0)
            {
                windowTuzelInfo.Show();

                hdnSorguRefNo.SetIValue(response.sorguRefNo);
                SenderInfo.SetValue(response.firmaListesi[0].unvani);
                new_SenderIdendificationNumber1Info.SetValue(response.firmaListesi[0].tcKimlikNo);
                new_MersisNumberInfo.SetValue(response.firmaListesi[0].mersisNo);
                new_TaxNoInfo.SetValue(response.firmaListesi[0].vergiNo);
                new_RegistryNumberInfo.SetValue(response.firmaListesi[0].sicilNo);
                new_CompanyNeviGrupInfo.SetValue(response.firmaListesi[0].FirmaNeviGrup);
                new_CompanyLegalStatusInfo.SetValue(response.firmaListesi[0].firmaYasalDurumu);
                new_RegistrationDateInfo.SetValue(ValidationHelper.GetDate(response.firmaListesi[0].tescilTarihi));
                new_TaxOfficeInfo.SetValue(response.firmaListesi[0].vergiDairesi);
                new_TradeRegistryOfficeNameInfo.SetValue(response.firmaListesi[0].tsm);
                new_TradeRegistryOfficeCode.SetValue(response.firmaListesi[0].tsmNo);
                new_TradeRegistryOfficeCity.SetValue(response.firmaListesi[0].tsmIl);

                new_MersisNumber.SetValue(response.firmaListesi[0].mersisNo);

                btnGoCustomer.SetVisible(false);
                btnSaveCustomer.SetVisible(true);
                btnUpdateCustomer.SetVisible(false);
            }
            else
            {
                MessageBox msg = new MessageBox();
                msg.Show("Girilen bilgilere ait müşteri bulunamadı!");
            }
        }
    }

    protected void btnTuzelSenderInfoLoad_Click(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(hdnSenderId.Value))
        {
            var senderId = hdnSenderId.Value;
            var formId = "D59AB4DE-F995-E611-A984-54442FE8720D";
            Response.Redirect(string.Format("~/CrmPages/AutoPages/EditReflex.aspx?defaulteditpageid={0}&ObjectId=201100052&mode=1&recId={1}", formId, senderId));
        }
    }

    protected void btnTuzelSenderInfoSave_Click(object sender, AjaxEventArgs e)
    {
        CorporateAccountSenderFactory tuzelFac = new CorporateAccountSenderFactory();
        CorporatedAccountDetailResponse detailResponse = null;
        Guid senderId = Guid.Empty;
        StaticData sd = new StaticData();
        DbTransaction tr = sd.GetDbTransaction();

        if (!string.IsNullOrEmpty(hdnSorguRefNo.Value) && !String.IsNullOrEmpty(SenderInfo.Value))
        {

            try
            {
                detailResponse = tuzelFac.GetCorporatedAccountSenderDetail(new CorporatedAccountDetailRequest()
                {
                    MersisNo = new_MersisNumber.Value,
                    SorguRefNo = hdnSorguRefNo.Value
                });


                CorporatedAccountInfoResponse InfoResponse = new CorporatedAccountInfoResponse();

                InfoResponse.firmaListesi = new List<Firma>();
                InfoResponse.firmaListesi.Add(new Firma()
                {
                    mersisNo = new_MersisNumberInfo.Value,
                    FirmaNeviGrup = new_CompanyNeviGrupInfo.Value,
                    sicilNo = new_RegistryNumberInfo.Value,
                    tcKimlikNo = new_SenderIdendificationNumber1Info.Value,
                    unvani = SenderInfo.Value,
                    vergiNo = new_TaxNoInfo.Value,
                    firmaYasalDurumu = new_CompanyLegalStatusInfo.Value,
                    tescilTarihi = new_RegistrationDateInfo.Value.ToString(),
                    vergiDairesi = new_TaxOfficeInfo.Value,
                    tsm = new_TradeRegistryOfficeNameInfo.Value,
                    tsmNo = new_TradeRegistryOfficeCode.Value,
                    tsmIl = new_TradeRegistryOfficeCity.Value
                });

                senderId = tuzelFac.SaveCorporatedAccountSender(InfoResponse, tr);

                tuzelFac.SaveCorporatedAccountSenderDetail(detailResponse, senderId, tr);

                int fraudStatus;
                bool customerFraudCheck = true;
                var senderAfterSaveDb = new TuFactory.Sender.SenderAfterSaveDb();

                fraudStatus = senderAfterSaveDb.GetSenderFraudStatus(senderId);

                if (fraudStatus == CustomerFraudStatus.NotFraud.GetHashCode())
                {
                    customerFraudCheck = senderAfterSaveDb.CustomerFraudCheckWithTran(senderId, tr);
                }
                else if (fraudStatus == CustomerFraudStatus.FraudWaiting.GetHashCode() || fraudStatus == CustomerFraudStatus.FraudRejected.GetHashCode())
                {
                    customerFraudCheck = false;
                }
                else if (fraudStatus == CustomerFraudStatus.FraudConfirmed.GetHashCode())
                {
                    customerFraudCheck = true;
                }

                StaticData.Commit(tr);

            }
            catch (Exception ex)
            {
                StaticData.Rollback(tr);
                throw ex;
            }

            if (senderId != Guid.Empty)
            {
                //senderId = ValidationHelper.GetGuid("A8FB0723-884F-E911-80BF-005056B200B3");

                QScript("alert('Tüzel Müşteri tanımı yapıldı.');");
                var formId = "D59AB4DE-F995-E611-A984-54442FE8720D";
                Response.Redirect(string.Format("~/CrmPages/AutoPages/EditReflex.aspx?defaulteditpageid={0}&ObjectId=201100052&mode=1&recid={1}", formId, senderId));

            }

        }

    }

    protected void btnTuzelSenderInfoUpdate_Click(object sender, AjaxEventArgs e)
    {
        CorporateAccountSenderFactory tuzelFac = new CorporateAccountSenderFactory();
        StaticData sd = new StaticData();
        DbTransaction tr = sd.GetDbTransaction();
        Guid senderId = ValidationHelper.GetGuid(hdnSenderId.Value);
        try
        {
            CorporatedAccountInfoResponse response = tuzelFac.GetCorporatedAccountSenderInfo(new CorporatedAccountInfoRequest()
            {
                mersisNo = new_MersisNumber.Value,
                tcKimlikNo = new_SenderIdendificationNumber1.Value,
                vergiNo = new_TaxNo.Value,
                kullaniciAdiSoyadi = "UPT",
                kullaniciKodu = "UPT"

            });

          

            if (!string.IsNullOrEmpty(response.sorguRefNo) && !String.IsNullOrEmpty(SenderInfo.Value))
            {
                CorporatedAccountDetailResponse detailResponse = tuzelFac.GetCorporatedAccountSenderDetail(new CorporatedAccountDetailRequest()
                {
                    MersisNo = response.firmaListesi[0].mersisNo,
                    SorguRefNo = response.sorguRefNo
                });

                CorporatedAccountInfoResponse InfoResponse = new CorporatedAccountInfoResponse();

                InfoResponse.firmaListesi = new List<Firma>();

                InfoResponse.firmaListesi.Add(new Firma()
                {
                    mersisNo = response.firmaListesi[0].mersisNo,
                    FirmaNeviGrup = response.firmaListesi[0].FirmaNeviGrup,
                    sicilNo = response.firmaListesi[0].sicilNo,
                    tcKimlikNo = response.firmaListesi[0].tcKimlikNo,
                    unvani = response.firmaListesi[0].unvani,
                    vergiNo = response.firmaListesi[0].vergiNo,
                    firmaYasalDurumu = response.firmaListesi[0].firmaYasalDurumu,
                    tescilTarihi = response.firmaListesi[0].tescilTarihi,
                    vergiDairesi = response.firmaListesi[0].vergiDairesi,
                    tsm = response.firmaListesi[0].tsm,
                    tsmNo = response.firmaListesi[0].tsmNo,
                    tsmIl = response.firmaListesi[0].tsmIl
                });

                tuzelFac.UpdateCorporatedAccountSender(InfoResponse, senderId, tr);

                tuzelFac.UpdateCorporatedAccountSenderDetail(detailResponse, senderId, tr);

                int fraudStatus;
                bool customerFraudCheck = true;
                var senderAfterSaveDb = new TuFactory.Sender.SenderAfterSaveDb();

                fraudStatus = senderAfterSaveDb.GetSenderFraudStatus(senderId);

                if (fraudStatus == CustomerFraudStatus.NotFraud.GetHashCode())
                {
                    customerFraudCheck = senderAfterSaveDb.CustomerFraudCheckWithTran(senderId, tr);
                }
                else if (fraudStatus == CustomerFraudStatus.FraudWaiting.GetHashCode() || fraudStatus == CustomerFraudStatus.FraudRejected.GetHashCode())
                {
                    customerFraudCheck = false;
                }
                else if (fraudStatus == CustomerFraudStatus.FraudConfirmed.GetHashCode())
                {
                    customerFraudCheck = true;
                }

                StaticData.Commit(tr);
            }
        }
        catch (Exception ex)
        {
            StaticData.Rollback(tr);
            throw ex;
        }

        QScript("alert('Tüzel Müşteri güncellemesi yapıldı.');");
        var formId = "D59AB4DE-F995-E611-A984-54442FE8720D";
        Response.Redirect(string.Format("~/CrmPages/AutoPages/EditReflex.aspx?defaulteditpageid={0}&ObjectId=201100052&mode=1&recid={1}", formId, senderId));

    }

    protected void btnCorporationNewClick(object sender, AjaxEventArgs e)
    {
        var formId = "D834CB22-77A9-E511-B92D-54442FE8720D";

        Response.Redirect(string.Format("~/CrmPages/AutoPages/EditReflex.aspx?defaulteditpageid={0}&ObjectId=201100052&mode=1", formId));

    }

    #region AjaxMethods
    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {

        [AjaxMethod()]
        public AjxKpsPerson GetKpsData(string senderIdendificationNumber1, string nationalityId)
        {
            var ret = new AjxKpsPerson();
            var sf = new SenderFactory();
            try
            {
                ret = sf.GetKpsData(senderIdendificationNumber1, ValidationHelper.GetGuid(nationalityId));
            }
            catch (Exception)
            {
                ret.new_cameFromKps = false;
            }

            return ret;
        }

    }
    private void ShowMessage(string message, EMessageType messageType, string title)
    {
        MessageBox msgBox = new MessageBox();
        msgBox.MessageType = messageType;
        msgBox.Title = title;
        msgBox.MsgType = MessageBox.EMsgType.Html;
        msgBox.Modal = true;
        msgBox.Show(title, "", message);
    }
    #endregion
}