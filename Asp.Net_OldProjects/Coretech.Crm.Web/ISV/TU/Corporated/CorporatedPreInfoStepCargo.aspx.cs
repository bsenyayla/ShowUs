using ApiFactory.AssManager;
using ApiFactory.CorparateCentralRegistrySystemManager;
using ApiFactory.CustomerManager;
using ApiFactory.IssManager;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.Corporation;
using TuFactory.Domain.Api.Models;


namespace Coretech.Crm.Web.ISV.TU.Corporated
{
    public partial class CorporatedPreInfoStepCargo : BasePage
    {
        CorporatedPreInfoFactory fc = new CorporatedPreInfoFactory();
        protected void Page_Load(object sender, EventArgs e)
        {

            hdnRecId.Value = QueryHelper.GetString("RecordId");
            hdnStatusId.Value = QueryHelper.GetString("StatusId");
            string islem = ValidationHelper.GetString(QueryHelper.GetString("islem"));
            
            if (islem == "formClose")
            {
                ScriptManager.RegisterClientScriptBlock(this, typeof(Page), "Script", "window.top.R.WindowMng.getActiveWindow().hide();", true);
                return;
            }
            Guid recId = ValidationHelper.GetGuid(hdnRecId.Value);
            DataTable dt = fc.GetCorporatedPreInfo(recId);

            new_StatusId.SetReadOnly(true);
            new_StatusId.SetDisabled(true);
            new_NationalityId.SetDisabled(true);
            new_HomeCountryId.SetDisabled(true);
            new_CorparateName.SetReadOnly(true);
            new_CorparateCentralRegistryServiceNumber.SetReadOnly(true);
            new_CorparateTaxNo.SetReadOnly(true);
            new_MobilePhone.SetReadOnly(true);
            new_EMail.SetReadOnly(true);
            new_New_CorporatedType.SetReadOnly(true);
            new_New_CorporatedType.SetDisabled(true);

            if (dt.Rows.Count>0)
            {
                new_New_CorporatedType.SetValue(dt.Rows[0]["new_New_CorporatedType"].ToString());
                new_StatusId.SetValue(dt.Rows[0]["new_StatusId"].ToString());
                new_CorparateCentralRegistryServiceNumber.SetValue(dt.Rows[0]["new_CorparateCentralRegistryServiceNumber"].ToString());
                new_CorparateName.SetValue(dt.Rows[0]["new_CorparateName"].ToString());
                new_CorparateTaxNo.SetValue(dt.Rows[0]["new_CorparateTaxNo"].ToString());
                new_MobilePhone.SetValue(dt.Rows[0]["new_MobilePhone"].ToString());
                new_EMail.SetValue(dt.Rows[0]["new_EMail"].ToString());
                new_CorparateCentralRegistryServiceQueryRefNumber.SetValue(dt.Rows[0]["new_CorparateCentralRegistryServiceQueryRefNumber"].ToString());
                new_NationalityId.SetValue(dt.Rows[0]["new_NationalityId"].ToString());
                new_HomeCountryId.SetValue(dt.Rows[0]["new_HomeCountryId"].ToString());
              

                if (ValidationHelper.GetGuid( hdnRecId.Value) != Guid.Empty)
                {
                    new_StatusId.SetReadOnly(true);

                }
            }

            /*
            string islem = QueryHelper.GetString("islem");
            if (!String.IsNullOrEmpty(islem))
            {
                ClientScript.get(this.GetType(), "msg", "<script language=javascript>closeWindowAscx("+ islem + ");</script>");
            }
            */
        }

        protected void FormClose(object sender, AjaxEventArgs e)
        {
            string config = "ISV/TU/Corporated/CorporatedPreInfoStepCargo.aspx?StatusId=" + new_StatusId.Value + "&RecordId=" + hdnRecId.Value + "&islem=formClose";
            Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);
        }

        
        protected void FileUpload(object sender, AjaxEventArgs e)
        {
            CorporatedPreInfoFactory fc = new CorporatedPreInfoFactory();
            try
            {
                Guid recId = ValidationHelper.GetGuid(hdnRecId.Value);

                if (!senderDocumentFile.HasFile)
                {
                    throw new CrmException("Lütfen dosya seçiniz.");
                }

                if (senderDocumentFile.HasFile)
                {
                    if (!CheckContentType(senderDocumentFile.PostedFile.ContentType))
                    {
                        throw new CrmException("Lütfen pdf, word ya da jpg/jpeg dosyası yükleyin.");
                    }
                    else
                    {


                        ApiFactory.CustomerManager.CustomerFactory customer = new ApiFactory.CustomerManager.CustomerFactory();
                        byte[] content = senderDocumentFile.FileBytes;
                        string mersisNo = new_CorparateCentralRegistryServiceNumber.Value;

                        ServiceResponse<DocumentFileWriterResponse> fileInfo = customer.FileWriter(content, mersisNo);
                        if (fileInfo.Code != ApiStatusCode.TransactionSuccessful.GetHashCode())
                        {
                            throw new CrmException(fileInfo.Message);
                        }
                        fc.PreCorporatePaymentServiceContractFileUpdate(recId, fileInfo.Response.FullPath);

                        CorporateRequest request = fc.GetCorporatedPreInfoModel(recId);

                        ServiceResponse<CorporateResponse> corporatedPreInfo = ConvertToCorporate(request);

                        

                        if (corporatedPreInfo.Code != ApiStatusCode.TransactionSuccessful.GetHashCode())
                        {
                            
                            var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                            ms.Show(".", corporatedPreInfo.Message);

                            LogUtil.WriteException(new CrmException(corporatedPreInfo.Message), "Coretech.Crm.Web.ISV.TU.Corporated.CorporatedPreInfoStepCargo.FileUpload");
                            return;
                        }

                        fc.CorporatedPreInfoCorporatedStatusUpdate(recId, 4);

                        if (!corporatedPreInfo.Response.AmlFraudCheck )
                        {
                            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                            ms.Show(".", "Talebiniz alınmış olup üç iş günü içerisinde talebiniz ile ilgili size dönüş yapılacaktır");
                        }

                        //QScript("window.top.R.WindowMng.getActiveWindow().hide();");
                        string config = "ISV/TU/Corporated/CorporatedPreInfoStepCargo.aspx?StatusId=" + new_StatusId.Value + "&RecordId=" + hdnRecId.Value + "&islem=islemTamam";
                        Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);
                    }
                }
            }
            catch (CrmException ex)
            {
                
                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", ex.ErrorMessage);

                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.Corporated.CorporatedPreInfoStepCargo.FileUpload");
            }
            catch (Exception ex)
            {
                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", ex.Message);

                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.Corporated.CorporatedPreInfoStepCargo.FileUpload");
            }

        }
        
        /*
        protected void FileUpload(object sender, AjaxEventArgs e)
        {

            try
            {
                Guid recId = ValidationHelper.GetGuid(hdnRecId.Value);


                if (senderDocumentFile.HasFile)
                {
                    if (!CheckContentType(senderDocumentFile.PostedFile.ContentType))
                    {
                        throw new CrmException("Lütfen pdf, word ya da jpg/jpeg dosyası yükleyin.");
                    }
                    else
                    {
                        ApiFactory.CustomerManager.CustomerFactory customer = new ApiFactory.CustomerManager.CustomerFactory();
                        byte[] content = senderDocumentFile.FileBytes;
                        string mersisNo = new_CorparateCentralRegistryServiceNumber.Value;

                        PreCorporateDocumentRequest doc = new PreCorporateDocumentRequest();
                        doc.PreCorporateId = recId;
                        doc.CorparateCentralRegistrySystemNo = mersisNo;
                        doc.DocumentContent = Convert.ToBase64String(content);
                        doc.DocumentTypeId = ValidationHelper.GetGuid(documentId.Value);
                        ServiceResponse<PreCorporateDocumentResponse> fileInfo = customer.CreatePreCorporateDocument(doc);
                        if (fileInfo.Code != ApiStatusCode.TransactionSuccessful.GetHashCode())
                        {
                            throw new CrmException(fileInfo.Message);
                        }

                        var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                        ms.Show(".", "Dosya yüklendi.");
                        //windowFileUpload.Hide();
                        //QScript("window.top.R.WindowMng.getActiveWindow().hide();");

                        var config = "/ISV/TU/Corporated/CorporatedPreInfoNewRegistrationFileUpload.aspx?RecordId=" + hdnRecId.Value + "&islem=dosyaYuklendi";
                        Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);
                    }
                }

            }
            catch (Exception ex)
            {

                throw ex;
            }
        }
        */
        public ServiceResponse<CorporateResponse> ConvertToCorporate(CorporateRequest request)
        {
            //ServiceResponse<CorporateResponse> test = new ServiceResponse<CorporateResponse>();

            Guid senderId = Guid.Empty;
            bool amlFraudCheck = false;
            var issResponse = new ServiceResponse<IssResponse>();
            var assResponse = new ServiceResponse<AssResponse>();
            //CorparateCentralRegistrySystem - Kurumsal Merkezi Kayıt Sistem Sorgusu - Mersis
            var ccrsResponse = new ServiceResponse<CorparateCentralRegistrySystem>();
            var response = new ServiceResponse<CorporateResponse>();

            var issFactory = new IssFactory();
            var assFactory = new AssFactory();
            var ccrsFactory = new CorparateCentralRegistrySystemFactory();
            var factory = new CustomerFactory();

            try
            {
                if (String.IsNullOrEmpty(request.CorparateCentralRegistrySystemNo))
                {

                    response.Code = ApiStatusCode.Invalid.GetHashCode();
                    response.Message = "CorparateCentralRegistrySystemNo alanı boş olamaz.";
                    return response;
                }


                ccrsResponse = ccrsFactory.GetByCorporate(request.CorparateCentralRegistrySystemNo);
                if (ccrsResponse.Response != null)
                {
                    if (ValidationHelper.GetGuid(ccrsResponse.Response.SenderId) == Guid.Empty)
                    {
                        try
                        {
                            CorparateCentralRegistrySystemResult ccrsResult = ccrsFactory.AddCorparate(ccrsResponse);
                            senderId = ccrsResult.SenderId;
                            amlFraudCheck = ccrsResult.AmlFraudCheck;
                        }
                        catch (Exception ex)
                        {
                            senderId = Guid.Empty;
                            amlFraudCheck = false;
                            throw ex;
                        }

                    }
                    else
                    {
                        senderId = ccrsResponse.Response.SenderId;
                        amlFraudCheck = ccrsResponse.Response.AmlFraudStatus == 2;
                    }
                }
            }
            catch (Exception ex)
            {
                response.Code = ApiStatusCode.Invalid.GetHashCode();
                response.Message = ex.Message.ToString();
                return response;
            }

            if (ValidationHelper.GetGuid(senderId) == Guid.Empty)
            {

                return response;
            }

            request.SenderId = senderId;

           
            try
            {
                // Kps 
                issResponse = issFactory.GetIss(request.IdentificationNumber);
                if (issResponse.Response != null)
                {
                    request.DateOfBirth = issResponse.Response.DateOfBirth;
                    request.PlaceOfBirth = issResponse.Response.PlaceOfBirth;
                    request.Fathername = issResponse.Response.Fathername;
                    request.Mothername = issResponse.Response.Mohtername;
                    request.Firstname = issResponse.Response.Firstname;
                    request.Lastname = issResponse.Response.Lastname;
                }

                // Aps
                assResponse = assFactory.GetAss(request.IdentificationNumber);
                if (issResponse.Response != null)
                {
                    request.HomeCity = assResponse.Response.CityName;
                    request.Address = assResponse.Response.HomeAdress;
                }

                response = factory.CreateCorporate(request);
                response.Response.AmlFraudCheck = amlFraudCheck;
                if (response.Code != ApiStatusCode.TransactionSuccessful.GetHashCode())
                {
                    
                    return response;
                }

            }
            catch (Exception ex)
            {
                response.Code = ApiStatusCode.Invalid.GetHashCode();
                response.Message = ex.Message.ToString();
                response.Response.AmlFraudCheck = false;
                //throw ex;
            }


            return response;
        }

        private bool CheckContentType(string contentType)
        {
            bool result = false;

            switch (contentType)
            {
                case "image/jpeg":
                case "application/pdf":
                case "application/msword":
                case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
                case "image/png":
                    result = true;
                    break;
                default:
                    result = false;
                    break;
            }

            return result;
        }

    }
}