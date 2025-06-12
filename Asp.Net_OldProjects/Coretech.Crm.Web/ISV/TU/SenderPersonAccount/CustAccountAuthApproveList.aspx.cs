using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;

public partial class Sender_CustAccountAuthApproveList : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {

        }
    }

    protected void GpCustAccountsAuthApproveReload(object sender, AjaxEventArgs e)
    {
        var sort = GpCustAccountsAuthApprove.ClientSorts() ?? string.Empty;
        var dtb = GetCustAccountAuthApprovePendingSelectSql(new_SenderId.Value, new_SenderPersonId.Value, new_CustAccountId.Value, UserName.Value);

        var start = GpCustAccountsAuthApprove.Start();
        var limit = GpCustAccountsAuthApprove.Limit();

        var t = dtb;
        GpCustAccountsAuthApprove.TotalCount = t.Rows.Count;

        GpCustAccountsAuthApprove.DataSource = t;
        GpCustAccountsAuthApprove.DataBind();
    }

    protected void RowDblClickOnEvent(object sender, AjaxEventArgs e)
    {

        if (!string.IsNullOrEmpty(hdnCustAccountAuthApproveID.Value))
            QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/ISV/TU/SenderPersonAccount/CustAccountAuthApprove.aspx?CustAccountAuthApproveId=" + hdnCustAccountAuthApproveID.Value + "', {title: 'Kullanıcı Yetki Yönetimi', maximized: false, width: 900, height: 550, resizable: true, modal: false, maximizable: true });");
    }

    private DataTable GetCustAccountAuthApprovePendingSelectSql(string SenderId, string SenderPersonId, string CustAccountsId, string UserName)
    {
        StaticData sd = new StaticData();

        string strSql = @"
                       SELECT 
                       cap.New_CustAccountAuthApprovePoolId as ID,
                       ca.new_IBAN,
                       sp.FullName as VALUE,                      
                       aut.Label as new_AuthType,
                       cat.New_CustAccountId,
                       ca.CustAccountNumber,
                       su.UserName,
                       capt.Label as new_ActionType
                       FROM 
                       vNew_CustAccountAuthApprovePool cap
                       inner join  vNew_CustAccountAuth cat on cat.new_CustAccountAuthId = cap.new_CustAccountAuthId
                       INNER JOIN vNew_SenderPerson sp on sp.New_SenderPersonId = cat.new_SenderPersonId
                       INNER JOIN vNew_CustAccounts ca on ca.New_CustAccountsId = cat.new_CustAccountId
                       INNER JOIN [dbo].[new_PLNew_CustAccountAuth_new_AuthType] aut ON aut.Value =  cap.new_AuthType
                       left JOIN vSystemUser su on su.SystemUserId = sp.new_MobilUserId
                       inner join [dbo].[new_PLNew_CustAccountAuthApprovePool_new_ActionType] capt on capt.Value = cap.new_ActionType";
        strSql += " WHERE 1=1 AND cap.new_ConfirmStatus= 2 AND cap.DeletionStateCode=0";


        var spList = new List<CrmSqlParameter>();

        if (!string.IsNullOrEmpty(SenderId))
        {
            strSql += " AND cat.new_SenderId =@SenderId ";

            sd.AddParameter("SenderId", DbType.Guid, ValidationHelper.GetGuid(SenderId));
        }

        if (!string.IsNullOrEmpty(SenderPersonId))
        {
            strSql += " AND cat.new_SenderPersonId =@SenderPersonId ";

            sd.AddParameter("SenderPersonId", DbType.Guid, ValidationHelper.GetGuid(SenderPersonId));
        }

        if (!string.IsNullOrEmpty(CustAccountsId))
        {
            strSql += " AND cat.New_CustAccountId =@CustAccountId ";

            sd.AddParameter("CustAccountId", DbType.Guid, ValidationHelper.GetGuid(CustAccountsId));
        }

        if (!string.IsNullOrEmpty(UserName))
        {
            strSql += " AND su.UserName =@UserName ";

            sd.AddParameter("UserName", DbType.String, ValidationHelper.GetString(UserName));
        }

        var result = sd.ReturnDataset(strSql).Tables[0];
        return result;
    }
}
