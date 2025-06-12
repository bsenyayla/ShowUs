using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.UI.WebControls;
using TuFactory.CreditCheck;
using TuFactory.CreditCheck.Domain;
using TuFactory.Object;
using TuFactory.Sender;
using UPT.WebServices.Shared.Transfer.Business.Request.PageService;

public partial class CreditCheck_CreditCheck : BasePage
{
    static List<Credit> requestedCredits = new List<Credit>();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            new_SenderAndReceiverIsEqual.FieldLabel = "Gönderici ve Alıcı Aynı Kişidir";
            IdentificationNumber.FieldLabel = "TC Kimlik No";
        }
    }


    private decimal DecimalParse(string Amount)
    {
        decimal result = 0;

        System.Globalization.CultureInfo customCulture = (System.Globalization.CultureInfo)System.Threading.Thread.CurrentThread.CurrentCulture.Clone();
        customCulture.NumberFormat.NumberDecimalSeparator = ".";

        result = decimal.Parse(Amount, customCulture);

        return result;
    }

    private string MaskName(string fullName)
    {
        string maskedName = string.Empty;
        if (!string.IsNullOrEmpty(fullName))
        {
            string[] Names = fullName.Split(' ');
            foreach (string item in Names)
            {
                int count = item.Length;
                string fisrtCharacter = item.Substring(0, 1);
                string lastCharacter = item.Substring(item.Length - 1, 1);
                string maskName = fisrtCharacter.PadRight(count - 1, '*') + lastCharacter;

                maskedName += " " + maskName;
            }
            return maskedName;

        }
        else
        {
            return "";
        }
    }

    protected void GridPanelClick(object sender, EventArgs e)
    {
    }
    protected void btnPay_Click(object sender, EventArgs e)
    {
        if (!ValidationHelper.GetBoolean(new_SenderAndReceiverIsEqual.Value))
        {
            GiveAlertMessage("Lütfen Gönderici ve Alıcı aynı Kişidir seçeneğini işaretleyip tekrar deneyiniz.");
            return;
        }

        CreditCheckFactory ccf = new CreditCheckFactory();
        string urlparam;
        string urlPage;
        var credit = requestedCredits.Where(item => item.DATA_ID == ValidationHelper.GetGuid(txtPayID.Value)).FirstOrDefault();
        ccf.CreateCreditPayInfo(credit);

        var validationResult = new DomainPageTransferValidationService().ValidateCreditTransaction(new TuFactory.Domain.Transfer() { CreditDataId = ValidationHelper.GetGuid(txtPayID.Value) });
        if (!string.IsNullOrEmpty(validationResult))
        {
            GiveAlertMessage(validationResult, EMessageType.Error);
            return;
        }

        SenderFactory sf = new SenderFactory();
        var resp = sf.CheckIfTurkishSenderExists(credit.VATANDASLIK_NO);
        if (!resp.result)
        {
            var query = new Dictionary<string, string>
            {
                {"ObjectId", ((int) TuEntityEnum.New_Sender).ToString()},
                {"creditDataID", txtPayID.Value},
                {"gridpanelid", ""},
                {"fromCheckCredit","1"},
                {"defaulteditpageid", "c72ab70f-eafb-e511-b4e3-54442fe8720d"}
            };
            urlPage = "/CrmPages/AutoPages/EditReflex.aspx";
            urlparam = QueryHelper.RefreshUrl(query);
            QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '" + urlPage + urlparam + "',{ maximized: false, width: 1100, height: 500, resizable: true, modal: true, maximizable: false });");
        }
        else
        {
            var query = new Dictionary<string, string>
            {
                {"ObjectId", ((int) TuEntityEnum.New_Transfer).ToString()},
                {"mode", "-1"},
                {"creditDataID", txtPayID.Value},
                {"gridpanelid", "GridPanelViewer"},
                {"defaulteditpageid", "67b76827-666a-492c-9ec9-a7d03c8ae6f0"},
                {"rlistframename","Frame_PnlCenter"},
                {"senderID",ValidationHelper.GetString(resp.SenderID)},
                {"fromCheckCredit","1"}
            };
            urlPage = "/isv/tu/transfer/TransferMain.aspx";
            urlparam = QueryHelper.RefreshUrl(query);
            QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '" + urlPage + urlparam + "', { maximized: true, resizable: false, modal: true });");
        }
    }
    protected void Search_Click(object sender, EventArgs e)
    {
        try
        {
            CreditCheckFactory ccf = new CreditCheckFactory();
            if (!ccf.Save(ValidationHelper.GetString(IdentificationNumber.Value), ValidationHelper.GetBoolean(new_SenderAndReceiverIsEqual.Value)))
            {
                GiveAlertMessage("İşleminizi gerçekleştiremiyoruz.");
                return;
            }

            Customer customer = ccf.GetCustomerCredit(ValidationHelper.GetString(IdentificationNumber.Value).Trim());

            if (customer.serviceException)
            {
                GiveAlertMessage("Kredi servisi çalıştırılamadı. Lütfen tekrar deneyiniz.");
                return;
            }

            if (customer.Status.RESPONSE == TuFactory.Object.WsStatus.response.Success)
            {
                lblName.Clear();
                lblName.SetValue("Adı Soyadı: " + MaskName(customer.FullName));
                requestedCredits = customer.lCredit;
                var payedCredits = ccf.GetPayedCredits(ValidationHelper.GetString(IdentificationNumber.Value));

                var credits = (from row in customer.lCredit
                               where !payedCredits.Any(p => (p.BASVURU_NO == row.BASVURU_NO) && (p.TAKSIT_NO == row.TAKSIT_NO))
                               select new Credit()
                               {
                                   AD_SOYAD = row.AD_SOYAD,
                                   BASVURU_NO = row.BASVURU_NO,
                                   DATA_ID = row.DATA_ID,
                                   HESAP_NO = row.HESAP_NO,
                                   VATANDASLIK_NO = row.VATANDASLIK_NO,
                                   TUTAR = DecimalParse(row.TUTAR).ToString("c", CultureInfo.CreateSpecificCulture("tr-TR")),
                                   TAKSIT_NO = row.TAKSIT_NO
                               }).OrderBy(r => r.TAKSIT_NO).ToList();

                GridPanelCredits.DataSource = credits;
                GridPanelCredits.DataBind();
            }
            else
            {
                GiveAlertMessage("TCKN'ye ait ödeme bulunamamıştır.");
            }
        }
        catch (Exception ex)
        {
            MessageBox m = new MessageBox();
            m.Width = 500;
            m.Show(ex.Message);
        }
    }

    public void GiveAlertMessage(string message, EMessageType messageType = EMessageType.Information)
    {
        MessageBox m = new MessageBox();
        m.Width = 500;
        m.Height = 150;
        m.MessageType = messageType;
        m.Show(message);
    }
}