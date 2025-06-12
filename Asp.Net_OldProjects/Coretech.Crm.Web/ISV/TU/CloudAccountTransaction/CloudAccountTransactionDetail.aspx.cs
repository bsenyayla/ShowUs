using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Network;
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
using TuFactory.CloudService;
using Integration3rd.Cloud.Domain.Response;
using UPT.Shared.Service.Office.Service;
using UPTCache = UPT.Shared.CacheProvider.Service;
using UPTCacheObjects = UPT.Shared.CacheProvider.Model;
using TuFactory.CustomApproval;
using Integration3rd.Cloud.Domain;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.WorkFlow;
using TuFactory.Object;

namespace Coretech.Crm.Web.ISV.TU.CloudAccountTransaction
{
    public partial class CloudAccountTransactionDetail : BasePage
    {
        
        CloudServiceFactory fac = new CloudServiceFactory();
        protected void Page_Load(object sender, EventArgs e)
        {

            Guid officeId;
            hdnRecId.Value = QueryHelper.GetString("RecordId");
            //string islem = QueryHelper.GetString("SourceFormType");

            DynamicFactory df;
            df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };

            var tr = df.Retrieve(TuEntityEnum.New_CloudAccountTransaction.GetHashCode(),
                                   ValidationHelper.GetGuid(hdnRecId.Value),
                                   DynamicFactory.RetrieveAllColumns);



            if (!RefleX.IsAjxPostback)
            {

                BtnSave.SetVisible(false);
                BtnCancel.SetVisible(false);
                new_VirmanIdName.FieldLabel = ("Virman No");

                if (ValidationHelper.GetGuid(hdnRecId.Value) != Guid.Empty)
                {


                    DataTable rec = fac.GetCloudAccountTransactionId(ValidationHelper.GetGuid(hdnRecId.Value));

                    if (rec.Rows.Count <= 0)
                        return;

                    int errorStatus = ValidationHelper.GetInteger(rec.Rows[0]["new_ErrorStatus"].ToString(), -1);
                    int cloudStatus = ValidationHelper.GetInteger(rec.Rows[0]["new_CloudPaymentStatus"].ToString(), -1);

                    hdnCloudStatusId.SetValue(cloudStatus);
                    officeId = ValidationHelper.GetGuid(rec.Rows[0]["new_OfficeId"].ToString());
                    if (officeId != Guid.Empty)
                        new_OfficeId.FillDynamicEntityData(tr);


                    //ofis tanımı bulanamadı durumunda
                    if (cloudStatus == (int)CloudPaymentStatus.ESLESTIRME_ISLEMI_REDDEDILDI || cloudStatus == (int)CloudPaymentStatus.ESLSME_YAPILAMADI)
                    {
                        new_OfficeId.SetReadOnly(false);
                        BtnSave.SetVisible(true);

                    }

                    if (cloudStatus == (int)CloudPaymentStatus.ESLESTIRME_ISLEMI_REDDEDILDI || cloudStatus == (int)CloudPaymentStatus.ESLSME_YAPILAMADI
                        ||
                        (cloudStatus == (int)CloudPaymentStatus.ISLEM_SIRASINDA_HATA && errorStatus == (int)ErrorStatus.OFIS_PASIF_DURUM)
                     )
                    {
                        BtnCancel.SetVisible(true);
                    }


                    cloudPaymentDateS.SetValue(rec.Rows[0]["CloudPaymentDate"].ToString());
                    new_CloudPaymentId.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_CloudPaymentId"].ToString()));
                    Reference.SetValue(ValidationHelper.GetString(rec.Rows[0]["Reference"].ToString()));
                    //new_Amount.SetValue(ValidationHelper.GetDecimal(rec.Rows[0]["new_Amount"].ToString(),0));
                    new_Amount.SetValue(rec.Rows[0]["new_Amount"].ToString());
                    new_CurrencyCode.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_CurrencyCode"].ToString()));
                    new_PaymentExpCode.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_PaymentExpCode"].ToString()));
                    new_SenderFullName.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_SenderFullName"].ToString()));
                    new_SenderIdentityNo.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_SenderIdentityNo"].ToString()));
                    new_SenderIban.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_SenderIban"].ToString()));
                    new_RecipientIban.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_RecipientIban"].ToString()));
                    new_RecipentBankName.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_RecipentBankName"].ToString()));
                    new_ErrorStatus.SetValue(ValidationHelper.GetInteger(rec.Rows[0]["new_ErrorStatus"].ToString(), -1));
                    new_ErrorExplanation.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_ErrorExplanation"].ToString()));
                    new_Explanation.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_Explanation"].ToString()));
                    new_VirmanIdName.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_VirmanIdName"].ToString()));
                    new_BankTransactionRefNo.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_BankTransactionRefNo"].ToString()));
                    new_NKolayLimitRefNo.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_NKolayLimitRefNo"].ToString()));
                    if (rec.Rows[0]["new_NKolayAccountTransferCompleted"].ToString() != null)
                        new_NKolayAccountTransferCompleted.SetValue(ValidationHelper.GetBoolean(rec.Rows[0]["new_NKolayAccountTransferCompleted"].ToString()));

                    if (rec.Rows[0]["new_IsNKolayLimitCreate"].ToString() != null)
                        new_IsNKolayLimitCreate.SetValue(ValidationHelper.GetBoolean(rec.Rows[0]["new_IsNKolayLimitCreate"].ToString()));

                    if (rec.Rows[0]["new_IsNkolayRepresentative"].ToString() != null)
                        new_IsNkolayRepresentative.SetValue(ValidationHelper.GetBoolean(rec.Rows[0]["new_IsNkolayRepresentative"].ToString()));

                }
            }

        }

        protected void newOfficeLoad(object sender, AjaxEventArgs e)
        {
            try
            {
                //OFF7879512
                string nkolayOnYuzOfficeCode = App.Params.GetConfigKeyValue("NkolayOnYuzOfficeCode");

                string strSql = @"SELECT 
                                O.New_OfficeId ID,
	                            O.OfficeName VALUE,
	                            O.new_CorporationID,
	                            O.new_CorporationIDName,
                                O.New_OfficeId,
                                O.OfficeName,
	                            O.new_CountryID,
	                            O.new_CountryIDName,
	                            new_StateId,
	                            new_StateIdName,
	                            new_CityId,
	                            new_CityIdName,
                                new_Adress,
                                new_ZipCode,
	                            new_Telephone,
	                            new_BrandId,
	                            new_BrandIdName,
	                            new_OwnOfficeCode,
	                            new_ReferenceCode,
	                            new_RefId,
	                            new_BranchNo,
                                new_BDDKCode,
                                new_BrandIdName
                            From  nltvNew_Office(@SystemUserId) O
                            WHERE O.DeletionStateCode=0 
                                AND O.new_CloudFirmCode is not null 
                                AND O.statuscode = 1
                                    /* N KOLAY ÖN YÜZÜNÜ KULLANAN BAYİLER listeye gelmesin */
                                and NOT EXISTS (SELECT 1 FROM vNew_Office OFC WHERE OFC.New_OfficeId = O.new_ParentOfficeID 
                                                AND OFC.DeletionStateCode = 0 AND OFC.new_OwnOfficeCode = @NkolayOfficeCode) ";

                string searchtext = this.Context.Items["query"] != null ? this.Context.Items["query"].ToString() : "";

                if (!string.IsNullOrEmpty(searchtext))
                    strSql += " AND O.OfficeName LIKE '%" + searchtext + "%'";


                strSql += " ORDER BY O.OfficeName asc ";

                StaticData sd = new StaticData();
                sd.ClearParameters();
                sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId));
                sd.AddParameter("NkolayOfficeCode", DbType.String, ValidationHelper.GetString(nkolayOnYuzOfficeCode));
                DataSet ds = sd.ReturnDataset(strSql);
                if (ds.Tables[0].Rows.Count > 0)
                {
                    new_OfficeId.TotalCount = ds.Tables[0].Rows.Count;
                    new_OfficeId.DataSource = ds.Tables[0];
                    new_OfficeId.DataBind();
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.CloudAccountTransaction.CloudAccountTransactionList.newOfficeLoad", "Exception");
            }
        }

        //reddedildi
        protected void Rejected(object sender, AjaxEventArgs e)
        {
            try
            {
                Guid refId = ValidationHelper.GetGuid(hdnRecId.Value);

                int status = 4;
                int? transactionType = ValidationHelper.GetInteger(hdnTransactionTypeId.Value);
                Guid systemUserId = ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId);
                string rejectDescription = ValidationHelper.GetString(new_RejectDescription.Value);
                
                windowReject.Hide();
                //var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                //ms.Show(".", "İlgili işlem, reddedildi");

                var config = "/ISV/TU/LimitApproverManagement/LimitApproverManagementDetail.aspx?RecordId=" + refId + "&islem=islemTamamOnay&IslemTip=" + hdnTransactionType.Value.ToString();
                Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.CloudAccountTransaction.CloudAccountTransactionList.Denied", "Exception");

                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "Hata!! İşlem Yapılamadı");
            }
        }

        protected void SaveOnEvent(object sender, AjaxEventArgs e)
        {
            int nKolayDelegate = 0;
            string resultStr ="";
            try
            {

                    
                    Guid officeId = ValidationHelper.GetGuid(new_OfficeId.Value);
                    if (officeId == Guid.Empty)
                    {
                        ShowMessage("Eşleştirme işlemi için Ofis seçmegirilmelidir.");
                        return;
                    }

                    BankPaymentListResponseItem request = new BankPaymentListResponseItem();
                    string nKolayCorparationCode = App.Params.GetConfigKeyValue("CloudUptNKolayCorparationCode", string.Empty);
                    OfficeService officeService = new OfficeService();
                    var office = officeService.GetOfficeByOfficeIDBasic(officeId);
                    UPTCacheObjects.Corporation corporation = UPTCache.CorporationService.GetCorporationByCorporationId(ValidationHelper.GetGuid(office.CorporationID));

                    request.corparationId = ValidationHelper.GetGuid(office.CorporationID);
                    request.corparationName = ValidationHelper.GetString(corporation.CorporationName);
                    request.corparationCode = ValidationHelper.GetString(corporation.CorporationCode);


                    Guid recId = ValidationHelper.GetGuid(hdnRecId.Value);
                    //var result = fac.UpdateOffice(recId, officeId);

                    //nkolay temsilci ise temsilci olarak işaretle
                    if (request.corparationCode == nKolayCorparationCode)
                        nKolayDelegate = 1;
                    else
                        nKolayDelegate = 0;

                   

                    string bankTranNumber = Reference.Value.Trim();
                    if (!string.IsNullOrEmpty(bankTranNumber))
                    {
                        var result = fac.UpdateOffice(recId, officeId, nKolayDelegate);
                        CloudAccountTransactionApproval approval = new CloudAccountTransactionApproval()
                        {
                            ApprovalKey = bankTranNumber,
                            CreateUser = new TuFactory.Domain.SystemUser() { SystemUserId = App.Params.CurrentUser.SystemUserId },
                            CloudAccountTransacionId = recId,
                            OfficeId = officeId,
                            PaymentId = Convert.ToInt32(new_CloudPaymentId.Value),
                            Reference = bankTranNumber,
                            CloudPaymentStatus = ValidationHelper.GetInteger( hdnCloudStatusId.Value)
                        };
                        resultStr = approval.Save();
                        if (string.IsNullOrEmpty(resultStr))
                        {

                            var config = "/ISV/TU/CloudAccountTransaction/CloudAccountTransactionDetail.aspx?RecordId=" + hdnRecId.Value + "&islem=islemOnay";
                            Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);
                        }
                        else
                        {
                            ShowMessage(resultStr);
                        }
                    }
                    else
                    {
                        ShowMessage("İşlem referans numarası bilgisi girilmelidir.");
                        return;
                    }

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.CloudAccountTransaction.CloudAccountTransactionList.SaveOnEvent", "Exception");

                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "Hata!! İşlem Yapılamadı");
            }
        }


        protected void CancelOnEvent(object sender, AjaxEventArgs e)
        {
            int nKolayDelegate = 0;
            string resultStr = "";
            try
            {
                Guid officeId = ValidationHelper.GetGuid(new_OfficeId.Value);

                Guid recId = ValidationHelper.GetGuid(hdnRecId.Value);
                //var result = fac.UpdateOffice(recId, officeId);


                string bankTranNumber = Reference.Value.Trim();
                if (!string.IsNullOrEmpty(bankTranNumber))
                {
                    var result = fac.UpdateCloudStatus(recId, CloudPaymentStatus.ONAY_BEKLIYOR);
                    CloudAccountTransactionApproval approval = new CloudAccountTransactionApproval()
                    {
                        ApprovalKey = bankTranNumber,
                        CreateUser = new TuFactory.Domain.SystemUser() { SystemUserId = App.Params.CurrentUser.SystemUserId },
                        CloudAccountTransacionId = recId,
                        OfficeId = officeId,
                        PaymentId = Convert.ToInt32(new_CloudPaymentId.Value),
                        Reference = bankTranNumber,
                        CloudPaymentStatus = (int) CloudPaymentStatus.IPTAL_EDILDI
                    };
                    resultStr = approval.Save();
                    if (string.IsNullOrEmpty(resultStr))
                    {

                        var config = "/ISV/TU/CloudAccountTransaction/CloudAccountTransactionDetail.aspx?RecordId=" + hdnRecId.Value + "&islem=islemOnay";
                        Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);
                    }
                    else
                    {
                        ShowMessage(resultStr);
                    }
                }
                else
                {
                    ShowMessage("İşlem referans numarası bilgisi girilmelidir.");
                    return;
                }

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.CloudAccountTransaction.CloudAccountTransactionList.CancelOnEvent", "Exception");

                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "Hata!! İşlem Yapılamadı");
            }
        }

        void ShowMessage(string messageText)
        {
            MessageBox messageBox = new MessageBox();
            messageBox.Width = 400;
            messageBox.Height = 200;
            messageBox.Show(messageText);
        }

    }
}