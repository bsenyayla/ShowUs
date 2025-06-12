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
    public partial class CorporatedPreInfoNewRegistrationControl : BasePage
    {
        CorporatedPreInfoFactory fc = new CorporatedPreInfoFactory();
        protected void Page_Load(object sender, EventArgs e)
        {

            //if (!RefleX.IsAjxPostback)
            
                hdnRecId.Value = QueryHelper.GetString("RecordId");
                hdnStatusId.Value = QueryHelper.GetString("StatusId");

                Guid recId = ValidationHelper.GetGuid(hdnRecId.Value);
                DataTable dt = fc.GetCorporatedPreInfo(recId);

                new_StatusId.SetReadOnly(true);
                new_StatusId.SetDisabled(true);
                new_NationalityId.SetDisabled(true);
                new_HomeCountryId.SetDisabled(true);
                new_CorparateName.SetReadOnly(true);
                new_CorparateTaxNo.SetReadOnly(true);
                new_MobilePhone.SetReadOnly(true);
                new_EMail.SetReadOnly(true);


                if (dt.Rows.Count > 0)
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
                    CorporatedPreInfoDocument();

                    if (ValidationHelper.GetGuid(hdnRecId.Value) != Guid.Empty)
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

        protected void RecordUpdate(object sender, AjaxEventArgs e)
        {

            try
            {
                Guid recId = ValidationHelper.GetGuid(hdnRecId.Value);
                Guid corporatedType = ValidationHelper.GetGuid(new_New_CorporatedType.Value);

                fc.CorporatedPreInfoCorporatedTypeUpdate(recId, corporatedType);
                CorporatedPreInfoDocument();

            }
            catch (Exception ex)
            {

                throw ex;
            }
        }


        protected void RecordAccept(object sender, AjaxEventArgs e)
        {
            try
            {
                if (new_New_CorporatedType.Value == "")
                {
                    var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                    ms.Show(".", "Hata! Firma tipi alanı boş olamaz!");
                    return;
                }

                
                if (((DataTable)GridPanelConfirmHistory.DataSource).Rows.Count <= 0 )
                {
                    var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                    ms.Show(".", "Hata! Yüklenmesi gereken tanımlı evrak bulunamadı. Firma tipi seçerek, Güncelle yapamınız gerekmektedir!");
                    return;
                }
                

                Guid recId = ValidationHelper.GetGuid(hdnRecId.Value);
                DataTable dt = fc.GetCorporatedPreInfoDocument(recId);

                if (dt.Rows.Count <=0 )
                {
                    var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                    ms.Show(".", "Hata!! Dosya listesi bulunamadı!");
                    return;
                }

                var results = from DataRow myRow in dt.Rows
                              where (int)myRow["Uploaded"] == 0 && (int) myRow["RequirementId"] != 3
                              select myRow;

                if (results.Count() > 1)
                {
                    var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                    ms.Show(".", "Hata!! Yüklenmeyen Dosyalar var!");
                }
                else
                {
                    //Statu : 2. Kurye aşamasında
                    fc.CorporatedPreInfoCorporatedStatusUpdate(recId, 2);

                    var config = "/ISV/TU/Corporated/CorporatedPreInfoNewRegistrationControl.aspx?StatusId=" + hdnStatusId.Value + "&RecordId=" + hdnRecId.Value + "&islem=islemTamam";

                    Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

        }

        
        protected void FileUpload(object sender, AjaxEventArgs e)
        {

            try
            {
                //Page.Header.DataBind();
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

                        windowFileUpload.Hide();

                        var config = "/ISV/TU/Corporated/CorporatedPreInfoNewRegistrationControl.aspx?StatusId=" + hdnStatusId.Value + "&RecordId=" + hdnRecId.Value + "&mesajVer=dosyaYuklendi&mesaj=Dosya Yüklendi.";
                        Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);


                        //var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                        //ms.Show(".", "Dosya yüklendi.");
                        //windowFileUpload.Hide();
                        //QScript("window.top.R.WindowMng.getActiveWindow().hide();");

                        //var config = "/ISV/TU/Corporated/CorporatedPreInfoNewRegistrationFileUpload.aspx?RecordId=" + hdnRecId.Value + "&islem=dosyaYuklendi";
                        //Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);
                    }
                }
                

            }
            catch (Exception ex)
            {

                throw ex;
            }
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

        protected void GrdCorporatedPreInfoDocument(object sender, AjaxEventArgs e)
        {

            CorporatedPreInfoDocument();
        }

        private void CorporatedPreInfoDocument()
        {
            Guid recId = ValidationHelper.GetGuid(hdnRecId.Value);
            DataTable dt = fc.GetCorporatedPreInfoDocument(recId);

            GridPanelConfirmHistory.DataSource = dt;
            GridPanelConfirmHistory.DataBind();
         
        }


        protected void DeleteDocument(object sender, AjaxEventArgs e)
        {
            var degerler = ((RowSelectionModel)GridPanelConfirmHistory.SelectionModel[0]);
            if (degerler != null && degerler.SelectedRows != null)
            {
                Guid id = ValidationHelper.GetGuid(degerler.SelectedRows.ID);
                var sd = new StaticData();
                sd.AddParameter("id", DbType.Guid, id);
                sd.AddParameter("systemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
                sd.ExecuteNonQuerySp("spDeleteTransferDocument");
                GridPanelConfirmHistory.Reload();
            }
        } 
          
        protected void Process(object sender, AjaxEventArgs e)
        {
            var degerler = ((RowSelectionModel)GridPanelConfirmHistory.SelectionModel[0]);
            if (degerler != null && degerler.SelectedRows != null)
            {

                if (degerler.SelectedRows.FILEPATH == null)
                    return;
                string filename = Path.GetFullPath(degerler.SelectedRows.FILEPATH);
                var fileInfo = new FileInfo(filename);

                using (var impersonator = new Impersonator())
                {
                    impersonator.Impersonate(ExcelImportFactory.ImporterUser, ExcelImportFactory.ImporterDomain, ExcelImportFactory.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);
                    if (!fileInfo.Exists)
                    {
                        throw new FileNotFoundException("File to download was not found \n İndirmek İçin Dosya Bulunamadı.", filename);
                    }
                    Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileInfo.Name);
                    //response.AddHeader("Content-Length", fileInfo.Length.ToString());
                    if (fileInfo.Name.EndsWith(".png"))
                    {
                        Response.ContentType = "image/x-png";
                    }
                    Response.WriteFile(fileInfo.FullName);
                    Response.Flush();
                    Response.End();
                    Response.Close();
                }
            }
        }

        
    }
}