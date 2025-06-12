using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Data;
using TuFactory.Exceptions;
using TuFactory.MarketingPermission;
using TuFactory.Object.Marketing;

public partial class Transfer_Marketing : BasePage
{
    Guid SenderId;
    Guid recId;
    int ObjectId;
    protected void Page_Load(object sender, EventArgs e)
    {

        if (!RefleX.IsAjxPostback)
        {
            var IsUserTR = CheckUser();

            ObjectId = ValidationHelper.GetInteger(QueryHelper.GetString("objectId"), 0);

            if (ObjectId == 201100072) //transfer
            {
                recId = ValidationHelper.GetGuid(QueryHelper.GetString("recid"));
                SenderId = GetSenderIdByTransferId(recId);
            }
            if (ObjectId == 201100075) //payment
            {
                recId = ValidationHelper.GetGuid(QueryHelper.GetString("recid"));
                SenderId = GetSenderIdByPaymentId(recId);
            }

            if (IsUserTR > 0)
            {
                fieldsetMarketing.SetVisible(true);


                MarketingPermissionFactory marketing = new MarketingPermissionFactory();
                var senderPermission = marketing.GetMarketingBySender(SenderId);

                if (senderPermission.Rows.Count > 0)
                {
                    foreach (DataRow item in senderPermission.Rows)
                    {
                        if (ValidationHelper.GetInteger(item["new_PermissionType"]) == (int)PermissionType.ARAMA)
                        {
                            checkArama.SetValue(ValidationHelper.GetBoolean(item["new_Permission"]));
                        }
                        if (ValidationHelper.GetInteger(item["new_PermissionType"]) == (int)PermissionType.MESAJ)
                        {
                            checkMesaj.SetValue(ValidationHelper.GetBoolean(item["new_Permission"]));
                        }
                        if (ValidationHelper.GetInteger(item["new_PermissionType"]) == (int)PermissionType.EPOSTA)
                        {
                            checkEposta.SetValue(ValidationHelper.GetBoolean(item["new_Permission"]));
                        }
                    }
                }
            }
            else
            {
                fieldsetMarketing.SetVisible(false);
            }

        }
    }

    protected void btnMarketingPermission(object sender, AjaxEventArgs e)
    {
        try
        {
            ObjectId = ValidationHelper.GetInteger(QueryHelper.GetString("objectId"),0);

            if (ObjectId == 201100072) // transfer
            {
                recId = ValidationHelper.GetGuid(QueryHelper.GetString("recid"));
                SenderId = GetSenderIdByTransferId(recId);
            }
            if(ObjectId == 201100075) //payment
            {
                recId = ValidationHelper.GetGuid(QueryHelper.GetString("recid"));
                SenderId = GetSenderIdByPaymentId(recId);
            }
          
            MarketingPermissionFactory marketing = new MarketingPermissionFactory();

            marketing.InsertMarketingPermissionManagement(SenderId, ValidationHelper.GetBoolean(checkArama.Value), PermissionType.ARAMA);
            marketing.InsertMarketingPermissionManagement(SenderId, ValidationHelper.GetBoolean(checkMesaj.Value), PermissionType.MESAJ);
            marketing.InsertMarketingPermissionManagement(SenderId, ValidationHelper.GetBoolean(checkEposta.Value), PermissionType.EPOSTA);

            QScript("alert('İzinler güncellendi');");
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    private Guid GetSenderIdByTransferId(Guid TransferId)
    {
        try
        {
            StaticData sd = new StaticData();
            sd.AddParameter("TransferId", DbType.Guid, TransferId);
            return ValidationHelper.GetGuid(sd.ExecuteScalar(@"SELECT New_SenderId FROM vNew_Transfer(nolock) WHERE new_TransferId = @TransferId"), Guid.Empty);
        }
        catch (Exception)
        {
            return Guid.Empty;
        }
    }

    private Guid GetSenderIdByPaymentId(Guid PaymentId)
    {
        try
        {
            StaticData sd = new StaticData();
            sd.AddParameter("PaymentId", DbType.Guid, PaymentId);
            return ValidationHelper.GetGuid(sd.ExecuteScalar(@"SELECT new_Customer FROM vNew_Payment(nolock) WHERE new_PaymentId = @PaymentId"), Guid.Empty);
        }
        catch (Exception)
        {
            return Guid.Empty;
        }
    }
    private int CheckUser()
    {
        StaticData sd = new StaticData();
        string SqlStr = @"select COUNT(1) FROM vSystemUser WHERE new_CorporationId IN
                                                (select New_CorporationId from vNew_Corporation where new_CountryId IN
                                                (select New_CountryId from vNew_Country where new_CountryShortCode = 'TR'))
                                                AND SystemUserId = @UserID";
        sd.AddParameter("UserID", DbType.Guid, ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId));
        int IsUserTR = ValidationHelper.GetInteger(sd.ExecuteScalar(SqlStr), 0);

        return IsUserTR;
    }
}