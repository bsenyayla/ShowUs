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

public partial class Sender_CustAccountAuthList : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            
        }
    }

    protected void GpCustAccountsAuthReload(object sender, AjaxEventArgs e)
    {
        var sort = GpCustAccountsAuth.ClientSorts() ?? string.Empty;
        var dtb = GetCustAccountsSelectSql(new_SenderId.Value, new_SenderPersonId.Value, new_CustAccountId.Value, UserName.Value);
      
        var start = GpCustAccountsAuth.Start();
        var limit = GpCustAccountsAuth.Limit();

        var t = dtb;
        GpCustAccountsAuth.TotalCount = t.Rows.Count;

        GpCustAccountsAuth.DataSource = t;
        GpCustAccountsAuth.DataBind();
    }

    protected void RowDblClickOnEvent(object sender, AjaxEventArgs e)
    {
       

        if (!string.IsNullOrEmpty(hdnCustAccountAuthID.Value))
            QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/ISV/TU/SenderPersonAccount/CustAccountAuthEdit.aspx?CustAccountAuthId=" + hdnCustAccountAuthID.Value + "', {title: 'Kullanıcı Yetki Yönetimi', maximized: false, width: 900, height: 550, resizable: true, modal: false, maximizable: true });");

    }

    protected void btnNewAuth_Click(object sender, AjaxEventArgs e)
    {
        MessageBox msgBox = new MessageBox();
        var custAccountId = ValidationHelper.GetString(new_SenderId.Value);
        var senderId = ValidationHelper.GetString(new_SenderPersonId.Value);
        var senderPersonId = ValidationHelper.GetString(new_CustAccountId.Value);

        if (string.IsNullOrEmpty(custAccountId) || string.IsNullOrEmpty(senderId) || string.IsNullOrEmpty(senderPersonId))
           msgBox.Show("Müşteri, Kullanıcı ve Hesap seçimi zorunludur.");        
        else
        QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/ISV/TU/SenderPersonAccount/CustAccountAuthEdit.aspx?custAccountId=" + new_CustAccountId.Value + "&senderId=" + new_SenderId.Value + "&senderPersonId=" + new_SenderPersonId.Value + "', {title: 'Kullanıcı Yetki Yönetimi', maximized: false, width: 900, height: 550, resizable: true, modal: false, maximizable: true });");
    }

    private DataTable GetCustAccountsSelectSql(string SenderId, string SenderPersonId, string CustAccountsId, string UserName)
    {
        StaticData sd = new StaticData();

        string strSql = @"
                       SELECT 
                       cat.New_CustAccountAuthId as ID,
                       ca.new_IBAN,
                       sp.FullName as VALUE,
                       sp.new_SenderId,
                       sp.new_SenderPersonId,
                       aut.Label as new_AuthType,
                       cat.New_CustAccountId,
                       ca.CustAccountNumber,
                       su.UserName,
                       cs.Label as ConfirmStatus
                       FROM vNew_CustAccountAuth cat
                       INNER JOIN vNew_SenderPerson sp on sp.New_SenderPersonId = cat.new_SenderPersonId
                       INNER JOIN vNew_CustAccounts ca on ca.New_CustAccountsId = cat.new_CustAccountId
                       INNER JOIN [dbo].[new_PLNew_CustAccountAuth_new_AuthType] aut ON aut.Value =  cat.new_AuthType
                       left JOIN vSystemUser su on su.SystemUserId = sp.new_MobilUserId
                       inner join [new_PLNew_CustAccountAuth_new_ConfirmStatus] cs on cs.Value= cat.new_ConfirmStatus";
        strSql += " WHERE 1=1 AND cat.DeletionStateCode = 0 ";


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
