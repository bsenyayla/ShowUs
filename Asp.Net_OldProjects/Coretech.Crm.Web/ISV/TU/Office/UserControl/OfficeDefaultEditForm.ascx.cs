using System;
using System.Web.UI;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using RefleXFrameWork;
using Coretech.Crm.Utility.Util;
using TuFactory.Sender.CorporateAccountSender.Model;
using TuFactory.Sender.CorporateAccountSender;
using System.Linq;
using Coretech.Crm.PluginData;
using System.Data;
using TuFactory.CloudService;
using Integration3rd.Cloud.Domain.Request;
using UPTCache = UPT.Shared.CacheProvider.Service;
using UPTCacheObjects = UPT.Shared.CacheProvider.Model;

public partial class Office_UserControl_OfficeDefaultEditForm : UserControl
{
    CloudServiceFactory fac = new CloudServiceFactory();

    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected override void OnInit(EventArgs e)
    {
        var p = this.Page as BasePage;

        if (p != null)
        {
            p.AfterSaveHandler += p_AfterSaveHandler;
        }

        try { 
            var btnPassive = Page.FindControl("btnPassive_Container") as ToolbarButton;
            var btnActive = Page.FindControl("btnActive_Container") as ToolbarButton;
            var btnDelete = Page.FindControl("btnDelete_Container") as ToolbarButton;
            //var btnSave = Page.FindControl("btnSave_Container") as ToolbarButton;

            if (btnActive!=null)
                btnActive.AjaxEvents.Click.Event += new RefleXFrameWork.AjaxComponentListener.AjaxEventHandler(btn_BeforActiveClick);

            if (btnPassive != null)
                btnPassive.AjaxEvents.Click.Event += new RefleXFrameWork.AjaxComponentListener.AjaxEventHandler(btn_BeforePassiveClick);

            if (btnDelete != null)
                btnDelete.AjaxEvents.Click.Event += new RefleXFrameWork.AjaxComponentListener.AjaxEventHandler(btn_BeforeDeleteClick);

            //if (btnSave != null)
              //  btnSave.AjaxEvents.Click.Event += new RefleXFrameWork.AjaxComponentListener.AjaxEventHandler(btn_BeforeSaveClick);
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "Office_UserControl_OfficeDefaultEditForm.OnInit", "Exception");
        }
    }
    private void p_AfterSaveHandler(Guid recId, DynamicFactory df, DynamicEntity de, bool IsUpdate)
    {
        //

    }

    void btn_BeforeSaveClick(object sender, RefleXFrameWork.AjaxEventArgs e)
    {

        string paymentExpCode = "";
        Guid recId = Guid.Empty;
        try
        {
            var hdnRecId = Page.FindControl("hdnRecid_Container") as Hidden;
            if (hdnRecId != null)
            {
                recId = ValidationHelper.GetGuid(hdnRecId.Value);

                


                string officeCode = "";
                var firm = CloudBuildFirmInfo(true);

                //paymentExpCode boş ise yeni kayıttır
                if (String.IsNullOrEmpty( firm.paymentExpCode ))
                {
                    //var result = fac.GetFirmListCode(firm.accountingCode);
                    //if (result == null)
                    
                        //fac.SubFirmAddNew(firm);
                        fac.OfficeCloudAddFirm(firm, recId);

                }else{
                        fac.OfficeCloudUpdateFirm(firm, recId, paymentExpCode);
                }
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex);
        }
       
    }


    void btn_BeforePassiveClick(object sender, RefleXFrameWork.AjaxEventArgs e)
    {

        Guid recId = Guid.Empty;
        var hdnRecId = Page.FindControl("hdnRecid_Container") as Hidden;
        if (hdnRecId != null)
            recId = ValidationHelper.GetGuid(hdnRecId.Value);


        var btnPassive = Page.FindControl("btnPassive_Container") as ToolbarButton;

        if (btnPassive != null)
        {
            var officeAfterSaveDb = new TuFactory.Office.OfficeFactory();
            officeAfterSaveDb.OfficeUserPassive(recId, true);


            
            var firm = CloudBuildFirmInfo(false);
            fac.OfficeCloudUpdateFirm(firm, recId, firm.paymentExpCode);
        }
    }

    void btn_BeforActiveClick(object sender, RefleXFrameWork.AjaxEventArgs e)
    {

        Guid recId = Guid.Empty;
        var hdnRecId = Page.FindControl("hdnRecid_Container") as Hidden;
        if (hdnRecId != null)
            recId = ValidationHelper.GetGuid(hdnRecId.Value);


        var btnActive = Page.FindControl("btnActive_Container") as ToolbarButton;

        if (btnActive != null)
        {
            var officeAfterSaveDb = new TuFactory.Office.OfficeFactory();
            officeAfterSaveDb.OfficeUserPassive(recId, false);

            var firm = CloudBuildFirmInfo(true);
            fac.OfficeCloudUpdateFirm(firm, recId, firm.paymentExpCode);
        }
    }

    void btn_BeforeDeleteClick(object sender, RefleXFrameWork.AjaxEventArgs e)
    {

        Guid recId = Guid.Empty;
        var hdnRecId = Page.FindControl("hdnRecid_Container") as Hidden;
        if (hdnRecId != null)
            recId = ValidationHelper.GetGuid(hdnRecId.Value);


        var btnActive = Page.FindControl("btnDelete_Container") as ToolbarButton;

        if (btnActive != null)
        {
            var officeAfterSaveDb = new TuFactory.Office.OfficeFactory();
            officeAfterSaveDb.OfficeUserDelete(recId);
        }
    }

    protected void BtnGetFromService_OnClick(object sender, AjaxEventArgs e)
    {
        try
        {
            var VergiNo = Page.FindControl("new_TaxCode_Container") as TextField;
            var TaxOffice = Page.FindControl("new_TaxOffice_Container") as TextField;
            var CityId = Page.FindControl("new_CityId_Container") as ComboField;  
            var Address = Page.FindControl("new_Adress_Container") as TextAreaField;
            var EMail = Page.FindControl("new_EMail_Container") as TextField;
            var Fax = Page.FindControl("new_Fax_Container") as TextField;
            var Telephone = Page.FindControl("new_Telephone_Container") as TextField;


            CorporateAccountSenderFactory tuzelFac = new CorporateAccountSenderFactory();

            CorporatedAccountInfoResponse response = tuzelFac.GetCorporatedAccountSenderInfo(new CorporatedAccountInfoRequest()
            {
                vergiNo = VergiNo.Value,
                kullaniciAdiSoyadi = "UPT",
                kullaniciKodu = "UPT"

            });

            if (response != null && response.firmaListesi != null && response.firmaListesi.Count > 0)
            {

                CorporatedAccountDetailResponse detailResponse = tuzelFac.GetCorporatedAccountSenderDetail(new CorporatedAccountDetailRequest()
                {
                    MersisNo = response.firmaListesi[0].mersisNo,
                    SorguRefNo = response.sorguRefNo
                });

                Address.SetValue(detailResponse.adresBilgileri.adresListesi[0].adres);
                TaxOffice.SetValue(response.firmaListesi[0].vergiDairesi);
                EMail.SetValue(detailResponse.iletisimBilgileri.iletisimListesi?.FirstOrDefault(x => x.iletisimTuru == "E Posta")?.iletisimBilgisi);
                Fax.SetValue(detailResponse.iletisimBilgileri.iletisimListesi?.FirstOrDefault(x => x.iletisimTuru == "Fax")?.iletisimBilgisi);
                Telephone.SetValue(detailResponse.iletisimBilgileri.iletisimListesi?.FirstOrDefault(x => x.iletisimTuru == "İş Tel")?.iletisimBilgisi);

                //SetCountry(detailResponse.adresBilgileri.adresListesi[0].ulkeAdi);

                CityId.SetValue(GetIntegrationCityId(detailResponse.adresBilgileri.adresListesi[0].ilId));

            }
            else
            {
                MessageBox msg = new MessageBox();
                msg.Show("Bu vergi no ile kurum bulunamadı!");
            }
        }
        catch (Exception ex)
        {
            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
        }

    }

    private string GetIntegrationCityId(string cityCode)
    {
        try
        {
            var sd = new StaticData();
            sd.AddParameter("@CityCode", DbType.String, cityCode);
            DataTable dt = sd.ReturnDataset(@"
                                             Select New_IntegrationCitiesId from vnew_Integrationcities(nolock)
                                             where
                                             DeletionStateCode=0
                                             and new_CityCode =@CityCode
                                             and new_IntegrationChannelId is null").Tables[0];

            return dt.Rows[0]["New_IntegrationCitiesId"].ToString();

        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex);
            return string.Empty;
        }

    }

    private SubFirmRequest CloudBuildFirmInfo(bool status = true)
    {
        string cityCode;
        int cityCodeNumber;
        try
        {
            Guid cityId;
            
            string paymentExpCode = "";
            string cloudReserverdFiel = "";
            string cityName = "";

            var _new_CorporationID =   Page.FindControl("new_CorporationID_Container") as ComboField;
            var _new_OwnOfficeCode = Page.FindControl("new_OwnOfficeCode_Container") as TextField;
            string officeCode = _new_OwnOfficeCode != null ? _new_OwnOfficeCode.Value : "";
            var _OfficeName = Page.FindControl("OfficeName_Container") as TextField;
            var _new_Adress = Page.FindControl("new_Adress_Container") as TextField;
            var _new_CityId = Page.FindControl("new_CityId_Container") as ComboField;
            var _new_TelephoneCode = Page.FindControl("new_TelephoneCode_Container") as TextField;
            var _new_Telephone = Page.FindControl("new_Telephone_Container") as TextField;
            var _new_TaxOffice = Page.FindControl("new_TaxOffice_Container") as TextField;
            var _new_TaxCode = Page.FindControl("new_TaxCode_Container") as TextField;
            var _new_BDDKCode = Page.FindControl("new_BDDKCode_Container") as TextField;
            var _new_CloudPaymentExpCode = Page.FindControl("new_CloudPaymentExpCode_Container") as TextField;
            var _new_BranchNo = Page.FindControl("new_BranchNo_Container") as TextField;
            var _new_ReferenceCode = Page.FindControl("new_ReferenceCode_Container") as TextField;

            Guid corporationId = ValidationHelper.GetGuid(_new_CorporationID.Value);
            UPTCacheObjects.Corporation corporation = UPTCache.CorporationService.GetCorporationByCorporationId(corporationId);

            string branchNo = ValidationHelper.GetString(_new_BranchNo.Value);
            string referenceCode = ValidationHelper.GetString(_new_ReferenceCode.Value);





            if (_new_CloudPaymentExpCode != null)
                paymentExpCode = ValidationHelper.GetString(_new_CloudPaymentExpCode.Value);

            if (_new_CityId != null)
            {
                cityId = ValidationHelper.GetGuid(_new_CityId.Value);
                var city = UPTCache.CityService.GetCityByCityId(cityId);
                if (city != null)
                    cityCode = ValidationHelper.GetString(city.CityCode);
                //var t = c.GetCityByCityId(cityId);
            }

            cityId = ValidationHelper.GetGuid(_new_CityId.Value);
            //cityName = ValidationHelper.GetString(config.DynamicEntity.GetLookupValue("new_CityId"));
            //cityName = ((Coretech.Crm.Objects.Crm.Dynamic.DynamicObject.CrmReference)(config.DynamicEntity["new_CityId"])).name;

            try
            {
                if (cityId != Guid.Empty)
                {
                    //vNew_IntegrationCities tablosunda olan new_CityCode değeri string olmayabilir. string konrulü yapılıyor.
                    cityCode = GetIntegrationCitiesCode(cityId);

                    //cityCode değeri  sayı ise değer  cityCodeNumber değişkenine aktarılır
                    bool result = int.TryParse(cityCode, out cityCodeNumber);
                    if (!result)
                    {
                        cityCode = UPTCache.CityService.GetCityByCityName(cityName).CityCode;

                        result = int.TryParse(cityCode, out cityCodeNumber);
                        if (!result)
                        {
                            cityCodeNumber = 0;
                        }
                    }
                }
                else
                    cityCodeNumber = 0;
            }
            catch (Exception ex2)
            {
                LogUtil.WriteException(ex2, "TuPlugin.OfficeAfterCreateUpdateOfficeAfterCreateUpdate.OfficeAddCloudFirm", "Exception");
                cityCodeNumber = 0;
            }


            SubFirmRequest firm = new SubFirmRequest();
            firm.accountingCode = officeCode;
            firm.firmName = _OfficeName != null ? _OfficeName.Value : "";
            firm.address = _new_Adress != null ? _new_Adress.Value : "";
            firm.county = ""; //ilçe
            firm.cityID = cityCodeNumber; //plaka
            firm.phone = _new_Telephone != null ? _new_Telephone.Value : "";
            firm.taxOffice = _new_TaxOffice != null ? _new_TaxOffice.Value : "";
            firm.taxNumber = _new_TaxCode != null ? _new_TaxCode.Value : "";
            firm.status = status == true ? EnumStatus.Active : EnumStatus.Passive;

            firm.paymentExpCode = paymentExpCode;

            //kurum ne kolauy değil ise 
            if (corporation.CorporationCode != "CO0000161CO")
                firm.reserved = branchNo;
            else
                firm.reserved = referenceCode;

            return firm;
        }
        catch (Exception ex)
        {
            return new SubFirmRequest();
        }
    }

    private string GetIntegrationCitiesCode(Guid cityId)
    {
        var sd = new StaticData();

        sd.AddParameter("Id", DbType.Guid, cityId);
        string gdret = ValidationHelper.GetString(sd.ExecuteScalar("select top 1 new_CityCode FROM vNew_IntegrationCities ict (NoLock) where ict.New_IntegrationCitiesId = @Id "));
        return gdret;
    }

    //private void SetCountry(string countryName)
    //{
    //    var CountryId = Page.FindControl("new_CountryID_Container") as ComboField;
    //    var SalesManager = Page.FindControl("new_SalesManager_Container") as TextField;

    //    try
    //    {
    //        var sd = new StaticData();
    //        sd.AddParameter("@CountryName", DbType.String, countryName);
    //        DataTable dt = sd.ReturnDataset(@"select New_CountryId from vNew_Country where CountryName = upper(@CountryName)").Tables[0];
    //        var countryId = ValidationHelper.GetGuid(dt.Rows[0]["New_CountryId"].ToString());
    //        CountryId.SetIValue(countryId);


    //        if(countryName == "Türkiye")
    //        {
    //            SalesManager.SetVisible(true);
    //        }
    //    }
    //    catch (Exception ex)
    //    {
    //        LogUtil.WriteException(ex);
    //    }
    //}
}
