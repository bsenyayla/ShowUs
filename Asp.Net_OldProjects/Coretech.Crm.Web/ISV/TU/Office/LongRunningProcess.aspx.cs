using System;
using System.Data;
using System.Threading;
using System.Data.OleDb;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.PluginData;
using Coretech.Crm.Factory;
using TuFactory.Data;
using TuFactory.Object;
using TuFactory.LogoTiger;
using TuFactory.LogoTiger.Objects;
using TuFactory.WebServicesRemote;
using System.Data.Common;

public partial class LongRunningProcess : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            DbTransaction trans = null;
            //string strUploadPath = "OfficeData\\";
            //string fileNme = Coretech.Crm.Factory.App.Params.GetConfigKeyValue("LocalPath") + strUploadPath + DateTime.Now.ToString("yyyyMMddhhmmss_") + "Error.Log";
            //StreamWriter sw = new StreamWriter(fileNme);

            string Path = Request.QueryString.Get("Path");
            //if (!Path.Contains("xlsx") || !Path.Contains("xls"))
            //{
            //    Response.Write("<script type=\"text/javascript\">parent.MessagePanel('<strong>Bilgilendirme</strong><br /><br />Dosya aktarım için uygun değil. Desteklenen Formatlar <strong>*.xlsx Excel Workbook | *.xls Excel 97-2000 Workbook<strong/>');</script>");
            //    Response.Flush();
            //    return;
            //}

            DataSet ds = ImportExcelXLS(Path, true);
            if (ds.Tables["ofisler$"] == null && ds.Tables["Kullanicilar$"] == null && ds.Tables["Hesaplar$"] == null && ds.Tables["IslemTipi$"] == null)
            {
                Response.Write("<script type=\"text/javascript\">parent.MessagePanel('<strong>Uyarı</strong><br /><br /><strong>Dosya içeriği bozuk.</strong> Dosya içerisindeki çalışma sayfası adlarını kontrol ediniz.</strong><br /><br />Beklenen içerik aşağıdaki gibidir<br /><ul>Ofisler<br />Hesaplar<br />IslemTipi<br />Kullanicilar<br /></ul>');</script>");
                Response.Flush();
                return;
            }

            UpdateProgress(0, "Lütfen Bekleyiniz...", "");

            #region Ofisler

            int i = ds.Tables["ofisler$"].Rows.Count;
            int ii = 0;

            int SuccessCountOffice = 0;
            int ErrorCountOffice = 0;

            if (i > 0)
            {

                foreach (DataRow itemOfis in ds.Tables["ofisler$"].Rows)
                {
                    ii++;
                    try
                    {
                        AddOffice(itemOfis[0].ToString(), itemOfis[1].ToString(), itemOfis[2].ToString(), itemOfis[3].ToString(),
                            itemOfis[4].ToString(), itemOfis[5].ToString(), itemOfis[6].ToString(), itemOfis[7].ToString());
                        UpdateProgress(ii, " | " + i.ToString() + " Ofis Aktarılıyor.", "");
                        SuccessCountOffice++;
                    }
                    catch (Exception ex)
                    {
                        string message = itemOfis[0].ToString() + " | " + itemOfis[1].ToString() + " | " +
                            itemOfis[2].ToString() + " | " + itemOfis[3].ToString() + " | " + itemOfis[4].ToString() + " | " + itemOfis[5].ToString() + " | " + itemOfis[6].ToString() + " | " + itemOfis[7].ToString();
                        //sw.WriteLine("Ofisler\n");
                        //sw.WriteLine(message);
                        //sw.WriteLine("\n");

                        UpdateProgress(ii, " | " + i.ToString() + " Ofis Aktarılıyor.", string.Format(
                            @"<div class=""block""><div class=""tags""><a href="" class=""tag""><span>Ofis</span></a></div><div class=""block_content""><h2 class=""title""><a>{0}</a></h2><p class=""excerpt"">{1}</p></div></div><br />",
                            ex.Message, message));
                        ErrorCountOffice++;
                    }
                }

                UpdateProgress(0, " | " + i.ToString() + " Ofis Bitti ", "");

            }

            #endregion

            #region Kullanicilar

            int j = ds.Tables["Kullanicilar$"].Rows.Count;
            int jj = 0;

            int SuccessCountKullanicilar = 0;
            int ErrorCountKullanicilar = 0;

            if (j > 0)
            {
                /* Ofis Hesapları */
                foreach (DataRow itemKullanicilar in ds.Tables["Kullanicilar$"].Rows)
                {
                    jj++;
                    try
                    {
                        AddOfficeUser(itemKullanicilar[0].ToString(), itemKullanicilar[1].ToString(), itemKullanicilar[2].ToString(), itemKullanicilar[3].ToString(), itemKullanicilar[4].ToString());
                        UpdateProgress(jj, " | " + j.ToString() + " Kullanıcılar Aktarılıyor.", "");
                        SuccessCountKullanicilar++;
                    }
                    catch (Exception ex)
                    {
                        string message = itemKullanicilar[0].ToString() + " | " + itemKullanicilar[1].ToString() + " | " +
                            itemKullanicilar[2].ToString() + " | " + itemKullanicilar[3].ToString() + " | " + itemKullanicilar[4].ToString();
                        //sw.WriteLine("Kullanicilar\n");
                        //sw.WriteLine(message);
                        //sw.WriteLine("\n");
                        UpdateProgress(jj, " | " + j.ToString() + " Kullanıcılar Aktarılıyor.", string.Format(
                            @"<div class=""block""><div class=""tags""><a href="" class=""tag""><span>Kullanıcılar</span></a></div><div class=""block_content""><h2 class=""title""><a>{0}</a></h2><p class=""excerpt"">{1}</p></div></div><br />",
                            ex.Message, message));
                        ErrorCountKullanicilar++;
                    }
                }

                UpdateProgress(0, " | " + j.ToString() + " Kullanıcılar Bitti ", "");
            }

            #endregion

            #region Hesaplar

            int k = ds.Tables["Hesaplar$"].Rows.Count;
            int kk = 0;

            int SuccessCountHesaplar = 0;
            int ErrorCountHesaplar = 0;

            if (k > 0)
            {

                foreach (DataRow itemHesaplar in ds.Tables["Hesaplar$"].Rows)
                {
                    kk++;
                    try
                    {
                        ValidationResult result = new ValidationResult();
                        result = GetValidationResult(itemHesaplar[0].ToString(), itemHesaplar[1].ToString(), itemHesaplar[2].ToString(), itemHesaplar[4].ToString());
                        if (result == null)
                        {
                            throw new Exception("Validation Hatası");
                        }
                        else
                        {
                            string IBAN;
                            this.Check(result.CorporationId, result.OfficeId, result.CurrencyId, itemHesaplar[3].ToString(), result.OperationType, out IBAN);
                            Guid officeAccountId = Guid.Empty;
                            this.AddOfficeAccount(result.CorporationId, result.OfficeId, itemHesaplar[3].ToString(), result.CurrencyId, IBAN, result.OperationType, trans, out officeAccountId);
                            this.AfterSave(result.CorporationId, result.OfficeId, result.CurrencyId, itemHesaplar[3].ToString(), result.OperationType, IBAN, officeAccountId,trans);
                            UpdateProgress(kk, " | " + k.ToString() + " Hesaplar Aktarılıyor.", "");
                            SuccessCountHesaplar++;
                        }
                    }
                    catch (Exception ex)
                    {
                        string message = itemHesaplar[0].ToString() + " | " + itemHesaplar[1].ToString() + " | " +
                            itemHesaplar[2].ToString() + " | " + itemHesaplar[3].ToString() + " | " + itemHesaplar[4].ToString();
                        //sw.WriteLine("Hesaplar\n");
                        //sw.WriteLine(message);
                        //sw.WriteLine("\n");
                        UpdateProgress(kk, " | " + k.ToString() + " Hesaplar Aktarılıyor.", string.Format(
                            @"<div class=""block""><div class=""tags""><a href="" class=""tag""><span>Hesaplar</span></a></div><div class=""block_content""><h2 class=""title""><a>{0}</a></h2><p class=""excerpt"">{1}</p></div></div><br />",
                            ex.Message, message));
                        ErrorCountHesaplar++;
                    }

                }

                UpdateProgress(0, " | " + kk.ToString() + " Hesaplar Bitti ", "");
            }
            #endregion

            #region IslemTipi

            int l = ds.Tables["IslemTipi$"].Rows.Count;
            int ll = 0;

            int SuccessCountIslemTipi = 0;
            int ErrorCountIslemTipi = 0;

            if (l > 0)
            {
                foreach (DataRow itemIslemTipi in ds.Tables["IslemTipi$"].Rows)
                {
                    ll++;
                    try
                    {
                        this.AddOfficeTransactionType(itemIslemTipi[0].ToString(), itemIslemTipi[1].ToString(), itemIslemTipi[2].ToString(), itemIslemTipi[3].ToString(),
                            ValidationHelper.GetDecimal(itemIslemTipi[5], 0), itemIslemTipi[4].ToString(), itemIslemTipi[6].ToString());

                        UpdateProgress(ll, " | " + l.ToString() + " Islem Tipleri Aktarılıyor.", "");
                        SuccessCountIslemTipi++;
                    }
                    catch (Exception ex)
                    {
                        string message = itemIslemTipi[0].ToString() + " | " + itemIslemTipi[1].ToString() + " | " +
                            itemIslemTipi[2].ToString() + " | " + itemIslemTipi[3].ToString() + " | " + itemIslemTipi[4].ToString()
                            + " | " + itemIslemTipi[5].ToString() + " | " + itemIslemTipi[6].ToString();
                        //sw.WriteLine("IslemTipleri\n");
                        //sw.WriteLine(message);
                        //sw.WriteLine("\n");
                        UpdateProgress(ll, " | " + l.ToString() + " Islem Tipleri Aktarılıyor.", string.Format(
                            @"<div class=""block""><div class=""tags""><a href="" class=""tag""><span>Islem Tipi</span></a></div><div class=""block_content""><h2 class=""title""><a>{0}</a></h2><p class=""excerpt"">{1}</p></div></div><br />",
                            ex.Message, message));
                        ErrorCountIslemTipi++;
                    }

                }

                UpdateProgress(0, " | " + ll.ToString() + " Islem Tipi Bitti ", "");
            }

            #endregion

            UpdateProgress(0, " | " + 0 + " Rapor Bitti ", "");

            //sw.Close();

            Response.Write(string.Format("<script type,\"text/javascript\">parent.MessagePanel('<strong><i class, \"fa fa-thumbs-o-up\"></i> Tebrikler</strong><br /><br /><strong>Data Aktarımı Tamamlandı.</strong> Data aktarımı sayısal olarak aşağıdaki gibidir.</strong><br /><br /><table border=\"1\"><tr><th></th><th>Toplam Kayıt</th><th>Başarılılar</th><th> Hatalılar </th></tr><tr><td>Ofis</td><td>{0}</td><td>{1}</td><td>{2}</td></tr><tr><td>Kullanıcılar</td><td>{3}</td><td>{4}</td><td>{5}</td></tr><tr><td>Hesaplar</td><td>{6}</td><td>{7}</td><td>{8}</td></tr><tr><td>İşlem Tipi</td><td>{9}</td><td>{10}</td><td>{11}</td></tr></table>');</script>",
                ii, SuccessCountOffice, ErrorCountOffice, jj, SuccessCountKullanicilar, ErrorCountKullanicilar, kk, SuccessCountHesaplar, ErrorCountHesaplar, ll, SuccessCountIslemTipi, ErrorCountIslemTipi));
            Response.Flush();

        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex);
        }
    }

    public void AddOfficeUser(string CorporationCode, string OfficeName, string FirstName, string LastName, string Email)
    {
        StaticData sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId == Guid.Empty ? Guid.Parse("00000000-AAAA-BBBB-CCCC-000000000001")
            : App.Params.CurrentUser.SystemUserId);
        sd.AddParameter("CorporationCode", DbType.String, CorporationCode);
        sd.AddParameter("OfficeName", DbType.String, OfficeName);
        sd.AddParameter("FirstName", DbType.String, FirstName);
        sd.AddParameter("LastName", DbType.String, LastName);
        sd.AddParameter("Email", DbType.String, Email);
        DataTable dt = sd.ReturnDatasetSp("spTuCreateBayiUser").Tables[0];
        if (dt.Rows.Count > 0)
        {
            SecurityFactory.UserSendPasswordLink(dt.Rows[0][0].ToString());
        }
    }

    public void AddOffice(string CorporationCode, string OfficeName, string RootOfficeName, string CityCode, string Address, string Phone, string Email, string CountryCode)
    {
        StaticData sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId == Guid.Empty ? Guid.Parse("00000000-AAAA-BBBB-CCCC-000000000001")
            : App.Params.CurrentUser.SystemUserId);
        sd.AddParameter("CorporationCode", DbType.String, CorporationCode);
        sd.AddParameter("OfficeName", DbType.String, OfficeName);
        sd.AddParameter("RootOfficeName", DbType.String, RootOfficeName);
        sd.AddParameter("CityCode", DbType.String, CityCode);
        sd.AddParameter("Address", DbType.String, Address);
        sd.AddParameter("Phone", DbType.String, Phone);
        sd.AddParameter("Email", DbType.String, Email);
        sd.AddParameter("CountryCode", DbType.String, CountryCode);

        sd.ExecuteNonQuerySp("spTuCreateBayi");
    }

    public void AddOfficeTransactionType(string CorporationCode, string OfficeName, string TransactionTypeName, string ProcessTypeName, decimal Limit, string CurrencyName, string CountryName)
    {
        StaticData sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId == Guid.Empty ? Guid.Parse("00000000-AAAA-BBBB-CCCC-000000000001")
            : App.Params.CurrentUser.SystemUserId);
        sd.AddParameter("CorporationCode", DbType.String, CorporationCode);
        sd.AddParameter("OfficeName", DbType.String, OfficeName);
        sd.AddParameter("CurrenyCode", DbType.String, CurrencyName);
        sd.AddParameter("TransactionTypeName", DbType.String, TransactionTypeName);
        sd.AddParameter("ProcessTypeName", DbType.String, ProcessTypeName);
        sd.AddParameter("Limit", DbType.Decimal, ValidationHelper.GetDecimal(Limit, 0));
        sd.AddParameter("CountryCode", DbType.String, CountryName);

        sd.ExecuteNonQuerySp("spTuCreateBayiTransactionType");
    }

    public void AddOfficeAccount(Guid CorporationId, Guid OfficeId, string AccountNo, Guid CurrencyId, string Iban, int OperationType, DbTransaction trans, out Guid Id)
    {
        StaticData sd = new StaticData();
        DataTable dt = new DataTable();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId == Guid.Empty ? Guid.Parse("00000000-AAAA-BBBB-CCCC-000000000001")
            : App.Params.CurrentUser.SystemUserId);
        sd.AddParameter("CorporationId", DbType.Guid, CorporationId);
        sd.AddParameter("OfficeId", DbType.Guid, OfficeId);
        sd.AddParameter("AccountNo", DbType.String, AccountNo);
        sd.AddParameter("CurrencyId", DbType.Guid, CurrencyId);
        sd.AddParameter("Iban", DbType.String, Iban);
        sd.AddParameter("OperationType", DbType.Int32, OperationType);
        //sd.ExecuteNonQuerySp("spTuCreateBayiAccount");
        dt = sd.ReturnDatasetSp("spTuCreateBayiAccount").Tables[0];
        if (dt.Rows.Count > 0)
            Id = ValidationHelper.GetGuid(dt.Rows[0]["ID"]);
        else
            Id = Guid.Empty;
    }

    protected void UpdateProgress(int PercentComplete, string Message, string errorMessage)
    {
        // Write out the parent script callback.
        Response.Write(String.Format("<script type=\"text/javascript\">parent.UpdateProgress({0}, '{1}' , '{2}');</script>", PercentComplete, Message, errorMessage));
        // To be sure the response isn't buffered on the server.    
        Response.Flush();
    }

    private static DataSet ImportExcelXLS(string FileName, bool hasHeaders)
    {
        string HDR = hasHeaders ? "Yes" : "No";
        string strConn;
        if (FileName.Substring(FileName.LastIndexOf('.')).ToLower() == ".xlsx")
            strConn = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + FileName + ";Extended Properties=\"Excel 12.0;HDR=" + HDR + ";IMEX=0\"";
        else
            strConn = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + FileName + ";Extended Properties=\"Excel 8.0;HDR=" + HDR + ";IMEX=0\"";

        DataSet output = new DataSet();

        using (OleDbConnection conn = new OleDbConnection(strConn))
        {
            conn.Open();

            DataTable schemaTable = conn.GetOleDbSchemaTable(
                OleDbSchemaGuid.Tables, new object[] { null, null, null, "TABLE" });

            foreach (DataRow schemaRow in schemaTable.Rows)
            {
                string sheet = schemaRow["TABLE_NAME"].ToString();

                if (!sheet.EndsWith("_"))
                {
                    try
                    {
                        OleDbCommand cmd = new OleDbCommand("SELECT * FROM [" + sheet + "]", conn);
                        cmd.CommandType = CommandType.Text;

                        DataTable outputTable = new DataTable(sheet);
                        output.Tables.Add(outputTable);
                        new OleDbDataAdapter(cmd).Fill(outputTable);
                    }
                    catch (Exception ex)
                    {
                        throw new Exception(ex.Message + string.Format("Sheet:{0}.File:F{1}", sheet, FileName), ex);
                    }
                }
            }
        }
        return output;
    }

    public void Check(Guid new_CorparationID, Guid new_OfficeId, Guid new_CurrencyId, string AccountNo, int OperationType, out string IBAN)
    {
        Thread.Sleep(1000);

        string CheckObject = string.Empty;
        var ac = new Account();
        var account = new WSAccount();
        var cdb = new CorporationDb();
        string customerNumber = string.Empty;
        string isoCurrencyCode = string.Empty;
        Guid recId = Guid.Empty;
        IBAN = string.Empty;

        /* CREATE - UPDATE */

        try
        {

            if (new_OfficeId != null && new_OfficeId != Guid.Empty)
            {
                CheckObject = "O";
                recId = Guid.Empty;
                cdb.OfficeAccountInfo(new_OfficeId, new_CurrencyId, out customerNumber, out isoCurrencyCode);
                account.HESAP_NO = AccountNo;
                account.ACCOUNTTYPE = OperationType;
            }



            account.IBAN = "";

            account.MUSTERI_NO = 0;

            account.PARAKOD = isoCurrencyCode;


            if (CheckObject != "P")
            {
                //Bu hesap özel hesaplarda varmı kontrolü
                if (CheckPrivilegeAccount(account.HESAP_NO))
                {
                    throw new Exception("Hesap özel hesaplarda kullanıkmış., Hata oluştu");
                }

                //Akustik kontrolü


            }


            if (ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("LOGO_ISACTIVE", "false")))
            {
                if (!string.IsNullOrEmpty(account.HESAP_NO))
                {
                    if (CheckObject == "O")
                    {
                        CheckUpdateAccountUpt(recId, "O", account.HESAP_NO, account.ACCOUNTTYPE, account.PARAKOD, null, new_OfficeId);
                    }
                    else if (CheckObject == "P")
                    {
                        CheckUpdateAccountUpt(recId, "P", account.HESAP_NO, account.ACCOUNTTYPE, account.PARAKOD, null, null);
                    }
                }
            }

            /*Kurum ve Ofis hesaplarında OperationType = 1,2,3,4,5,6 olanlar için  Accounts tablosuna kayıt atılmayacağı için kontrol yapmıycaz.*/
            /* idi şuanda bankada sorguluyoruz */
            if (CheckObject == "O" && (account.ACCOUNTTYPE > 0 && account.ACCOUNTTYPE < 7))
            {
                try
                {
                    account = ac.GetAccount(account);
                    //config.DynamicEntity.AddStringProperty("CorporationAccount", account.HESAP_NO_OUT);

                    if (string.IsNullOrEmpty(account.HESAP_NO_OUT) && string.IsNullOrEmpty(account.IBAN_OUT))
                    {
                        throw new Exception("[AKUSTİK] : Hesap bulunamadı");
                    }

                    IBAN = account.IBAN_OUT;
                    return;
                }
                catch (Exception ex)
                {
                    throw ex;
                }

            }


        }
        catch (Exception ex)
        {
            throw ex;
        }
        /* Logo hesaplarında 7,8,9,10,11,12  Olan hesaplarının kontrolü için. */
        if (ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("LOGO_ISACTIVE", "false")) && account.ACCOUNTTYPE == 7
            || account.ACCOUNTTYPE == 9
            || account.ACCOUNTTYPE == 10
            || account.ACCOUNTTYPE == 11
            || account.ACCOUNTTYPE == 12)
        {
            CheckLogoTigerAccount(account.HESAP_NO, isoCurrencyCode);
        }
    }

    public void AfterSave(Guid new_CorparationID, Guid new_OfficeId, Guid new_CurrencyId, string AccountNo, int OperationType, string IBAN, Guid recId, DbTransaction trans)
    {
        string CheckObject = string.Empty;
        var account = new WSAccount();
        var cdb = new CorporationDb();
        string customerNumber = string.Empty;
        string isoCurrencyCode = string.Empty;

        /* CREATE - UPDATE */
        try
        {
            if (new_OfficeId != null && new_OfficeId != Guid.Empty)
            {
                CheckObject = "O";
                //recId = Guid.Empty;
                cdb.OfficeAccountInfo(new_OfficeId, new_CurrencyId, out customerNumber, out isoCurrencyCode);
                account.HESAP_NO = AccountNo;
                account.ACCOUNTTYPE = OperationType;
            }

            account.IBAN = IBAN;
            account.PARAKOD = isoCurrencyCode;

            if (!string.IsNullOrEmpty(account.HESAP_NO))
            {
                AccountTransactionDb accountTransactionDb = new AccountTransactionDb();

                if (CheckObject == "O")
                {
                    accountTransactionDb.InsertUpdateAccountUpt(recId, "O", account.HESAP_NO, account.ACCOUNTTYPE, account.PARAKOD, null, new_OfficeId, Guid.Parse("00000000-AAAA-BBBB-CCCC-000000000001"));
                }
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private void CheckLogoTigerAccount(string accountNumber, string currencyCode)
    {
        LogoTigerWebService ltService = new LogoTigerWebService();
        LogoTigerWebServiceCheckAccountResponse ltCheckAccountResponse = ltService.CheckAccount(new LogoTigerWebServiceCheckAccountRequest()
        {
            AccountNumber = accountNumber,
            Currency = currencyCode
        });
        if (ltCheckAccountResponse.Status.ResponseCode != "000") //Success
        {
            throw new Exception("[LOGO TIGER] : " + ltCheckAccountResponse.Status.ResponseCode + " - " + ltCheckAccountResponse.Status.ResponseMessage);
        }
    }

    private bool CheckPrivilegeAccount(string accountNumber)
    {
        bool result = false;
        StaticData sd = new StaticData();
        sd.AddParameter("@AccountNo", DbType.String, accountNumber);
        var checkResult = sd.ExecuteScalarSp("spTUCheckIsPrivilegedAccount");
        if (Convert.ToInt32(checkResult) > 0)
        {
            result = true;
        }

        return result;
    }

    public void CheckUpdateAccountUpt(Guid recId, string checkObject, string hesapNo, int? accountType, string paraKod, Guid? CorporationId, Guid? OfficeId)
    {
        var sd = new StaticData();
        const string sql = @"SpCheckAccountUnique";
        sd.AddParameter("AccountNumber", DbType.String, hesapNo);
        sd.AddParameter("CurrencyCode", DbType.String, paraKod);
        sd.AddParameter("AccountType", DbType.Int32, accountType);
        if (CorporationId != Guid.Empty)
        {
            sd.AddParameter("CorporationId", DbType.Guid, CorporationId);
        }
        if (OfficeId != Guid.Empty)
        {
            sd.AddParameter("OfficeId", DbType.Guid, OfficeId);
        }
        if (recId != Guid.Empty)
        {
            sd.AddParameter("RecId", DbType.Guid, recId);
        }

        sd.AddParameter("CheckObject", DbType.String, checkObject);


        sd.ExecuteNonQuerySp(sql);
    }

    public ValidationResult GetValidationResult(string CorporationCode, string OfficeName, string CurrencyCode, string OperationTypeName)
    {
        ValidationResult result = new ValidationResult();

        StaticData sd = new StaticData();
        sd.AddParameter("CorporationCode", DbType.String, CorporationCode);
        sd.AddParameter("OfficeName", DbType.String, OfficeName);
        sd.AddParameter("CurrenyCode", DbType.String, CurrencyCode);
        sd.AddParameter("OperationTypeName", DbType.String, OperationTypeName);
        DataTable dt = new DataTable();
        dt = sd.ReturnDatasetSp("spTuBayiValidationList").Tables[0];

        if (dt.Rows.Count > 0)
        {
            result.CorporationId = ValidationHelper.GetGuid(dt.Rows[0][0]);
            result.OfficeId = ValidationHelper.GetGuid(dt.Rows[0][1]);
            result.CurrencyId = ValidationHelper.GetGuid(dt.Rows[0][2]);
            result.OperationType = ValidationHelper.GetInteger(dt.Rows[0][3], 0);
        }

        return result;
    }
}

public class ValidationResult
{
    public Guid CorporationId { get; set; }
    public Guid OfficeId { get; set; }
    public Guid CurrencyId { get; set; }
    public int OperationType { get; set; }
    public string IBAN { get; set; }
}