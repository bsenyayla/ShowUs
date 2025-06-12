using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Web.UI;
using TuFactory.Sender;
using TuFactory.Sender.CorporateAccountSender;
using TuFactory.Sender.CorporateAccountSender.Model;
using static TuFactory.Fraud.FraudScanFactory;

public partial class Sender_UserControl_SenderCDDConfirm : UserControl
{
    Guid senderID = ValidationHelper.GetGuid(QueryHelper.GetString("recId"));
    int? cddStatus = ValidationHelper.GetInteger(QueryHelper.GetInteger("cddStatus"));
    private ComboField corporatedType;
    private CheckField isDomestic;
    private TextField mersis;
    private TextField taxNo;
    int? FraudStatus;

    protected override void OnInit(EventArgs e)
    {
        var senderAfterSaveDb = new SenderAfterSaveDb();
        FraudStatus = senderAfterSaveDb.GetSenderFraudStatus(senderID);
        var cddExpireDate = senderAfterSaveDb.GetSenderCDDStatusExpireDate(senderID);

        var docCount = senderAfterSaveDb.GetSenderDocuments(senderID);

        if (FraudStatus == CustomerFraudStatus.FraudConfirmed.GetHashCode())
        {
            if (cddExpireDate <= DateTime.Now.Date || (cddStatus != 2 && cddStatus != 3))
            {
                BtnCDDSendToConfirm.Visible = true;
            }
        }

        if (cddExpireDate <= DateTime.Now.Date || (cddStatus != 2 && cddStatus != 3))
        {
            BtnSenderUpdate.Visible = true;
            BtnUpdateFromService.Visible = true;
        }

        if (docCount >= 5)
        {
            btnCreateDocuments.SetVisible(false);
        }

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        corporatedType = (Page.FindControl("new_CorporatedTypeId_Container") as ComboField);
        isDomestic = (Page.FindControl("new_IsDomestic_Container") as CheckField);
        mersis = (Page.FindControl("new_MersisNumber_Container") as TextField);
        taxNo = (Page.FindControl("new_TaxNo_Container") as TextField);
    }

    protected void SenderCDDSendToConfirm(object sender, AjaxEventArgs e)
    {
        try
        {
            SenderFactory senderF = new SenderFactory();

            string result = senderF.ConfirmSenderCDD(senderID);

            MessageBox msg = new MessageBox();
            msg.Show(result);
        }
        catch (Exception ex)
        {

            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
        }

    }

    protected void UpdateSenderType(object sender, AjaxEventArgs e)
    {
        try
        {
            SenderFactory senderF = new SenderFactory();

            string result = senderF.UpdateSenderType(senderID, ValidationHelper.GetGuid(corporatedType.Value), ValidationHelper.GetBoolean(isDomestic.Value, false));
            MessageBox msg = new MessageBox();
            msg.Show(result);
        }
        catch (Exception ex)
        {


            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
        }

    }

    protected void UpdateSenderFromService(object sender, AjaxEventArgs e)
    {
        var mersisNumber = ValidationHelper.GetString(mersis.Value, "");
        var vergiNumarası = ValidationHelper.GetString(taxNo.Value, "");
        MessageBox msg = new MessageBox();
        StaticData sd = new StaticData();
        DbTransaction tr = sd.GetDbTransaction();

        CorporateAccountSenderFactory tuzelFac = new CorporateAccountSenderFactory();

        try
        {
            CorporatedAccountInfoResponse response = tuzelFac.GetCorporatedAccountSenderInfo(new CorporatedAccountInfoRequest()
            {
                mersisNo = mersisNumber,
                kullaniciAdiSoyadi = "UPT",
                kullaniciKodu = "UPT"

            });

            Guid senderId = ValidationHelper.GetGuid(senderID);

            if (!string.IsNullOrEmpty(response.sorguRefNo))
            {
                CorporatedAccountDetailResponse detailResponse = tuzelFac.GetCorporatedAccountSenderDetail(new CorporatedAccountDetailRequest()
                {
                    MersisNo = response.firmaListesi[0].mersisNo,
                    SorguRefNo = response.sorguRefNo
                });


                if (detailResponse.islemSonucu != "1")
                {
                    throw new Exception(detailResponse.hataAciklama);
                }


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
                msg = new MessageBox();
                msg.Show("Tüzel Müşteri bilgisi güncellendi");

            }
            else
            {
                msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information, Height = 150 };
                msg.Show(response.hataAciklama);
            }
        }
        catch (Exception ex)
        {
            StaticData.Rollback(tr);
            msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }

    protected void SenderDocumentCerate(object sender, AjaxEventArgs e)
    {
        try
        {
            if (string.IsNullOrEmpty(ValidationHelper.GetString(corporatedType.Value)))
            {
                throw new Exception("Tüzel türü boş olamaz.");
            }

            SenderFactory senderF = new SenderFactory();

            StaticData sd = new StaticData();
            DbTransaction tr = sd.GetDbTransaction();

            senderF.InsertSenderDocuments(senderID, tr);

            tr.Commit();
            btnCreateDocuments.SetVisible(false);


            MessageBox msg = new MessageBox();
            msg.Show("Dokümanlar oluşturuldu. Lütfen listeyi yenileyiniz.");
        }
        catch (Exception ex)
        {
            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);

        }

    }
}
