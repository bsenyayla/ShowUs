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
    public partial class CorporatedPreInfoNewRegistrationFileUpload : BasePage
    {
        CorporatedPreInfoFactory fc = new CorporatedPreInfoFactory();
        
        protected void Page_Load(object sender, EventArgs e)
        {
            hdnRecId.Value = QueryHelper.GetString("RecordId");
            hdnMersisNo.Value = QueryHelper.GetString("MersisNo");
            hdnStatusId.Value = QueryHelper.GetString("StatusId");
            hdnDocumentId.Value = QueryHelper.GetString("DocumentId");
            hdnDocumentName.Value = QueryHelper.GetString("DocumentName");
            lblDocumentName.Text = hdnDocumentName.Value;

        }

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
                        string mersisNo = hdnMersisNo.Value;
                        
                        //ServiceResponse<DocumentFileWriterResponse> fileInfo = customer.FileWriter(content,mersisNo);


                        //if (fileInfo.Code != ApiStatusCode.TransactionSuccessful.GetHashCode())
                        //{
                        //    throw new CrmException(fileInfo.Message);
                        //}

                        //sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(systemUserId));
                        //sd.AddParameter("PreCorporateId", DbType.Guid, ValidationHelper.GetGuid(request.PreCorporateId));
                        //sd.AddParameter("DocumentTypeId", DbType.Guid, ValidationHelper.GetGuid(request.DocumentTypeId));
                        //sd.AddParameter("FullPath", DbType.String, ValidationHelper.GetString(fileInfo.Response.FullPath));

                        //var dt = sd.ReturnDatasetSp("spApiCreatePreCorporateDocument").Tables[0];

                        PreCorporateDocumentRequest doc = new PreCorporateDocumentRequest();
                        doc.PreCorporateId = recId;
                        doc.CorparateCentralRegistrySystemNo = mersisNo;
                        doc.DocumentContent =  Convert.ToBase64String( content);
                        doc.DocumentTypeId = ValidationHelper.GetGuid(hdnDocumentId.Value);
                        ServiceResponse<PreCorporateDocumentResponse>  fileInfo = customer.CreatePreCorporateDocument(doc);
                        if (fileInfo.Code != ApiStatusCode.TransactionSuccessful.GetHashCode())
                        {
                            throw new CrmException(fileInfo.Message);
                        }

                        //var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                        //ms.Show(".", "İlgili işlem onaylandı.");
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