using System;
using System.Collections.Generic;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Users;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Factory.Crm.Share;
using Coretech.Crm.Objects.Crm.Share;

public partial class CrmPages_Admin_Share_Share : BasePage
{
    private DynamicSecurity _dynamicSecurity;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack && !Ext.IsAjaxRequest)
        {

            hdnRecid.Value = QueryHelper.GetString("RecordId");
            hdnObjectId.Value = QueryHelper.GetString("ObjectId");

        }
        FillSecurity();
        if (!(_dynamicSecurity.PrvShare))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=PrvShare");
        }
    }
    void FillSecurity()
    {
        _dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                          (ValidationHelper.GetGuid(hdnRecid.Value)));
    }
    protected void StoreUserOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var uf = new UsersFactory();
        StoreUser.DataSource = uf.GetUserList();
        StoreUser.DataBind();
    }

    protected void StoreTeamOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var sf = new ShareFactory();
        StoreTeam.DataSource = sf.GetTeamList();
        StoreTeam.DataBind();
    }

    protected void Store1_Refresh(object sender, StoreRefreshDataEventArgs e)
    {
        var sf = new ShareFactory();
        var sharedList = sf.GetSharedList(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                          ValidationHelper.GetGuid(hdnRecid.Value));
        Store1.DataSource = sharedList;
        Store1.DataBind();
    }
    protected void BtnSave_Click(object sender, AjaxEventArgs e)
    {
        
        var objectId = ValidationHelper.GetInteger(hdnObjectId.Value, 0);
        var recid = ValidationHelper.GetGuid(hdnRecid.Value);
        var values = e.ExtraParams["Values"];
        var degerler = JSON.Deserialize<Dictionary<string, string>[]>(values);
        var saveList = new List<Share>();
        var sf = new ShareFactory();
        foreach (var t in degerler)
        {
            saveList.Add(
                new Share
                {
                    PrvRead = ValidationHelper.GetBoolean(t["PrvRead"]),
                    PrvAssign = ValidationHelper.GetBoolean(t["PrvAssign"]),
                    PrvShare = ValidationHelper.GetBoolean(t["PrvShare"]),
                    PrvDelete = ValidationHelper.GetBoolean(t["PrvDelete"]),
                    PrvWrite = ValidationHelper.GetBoolean(t["PrvWrite"]),
                    ObjectId = objectId,
                    RecordId = recid,
                    ShareId = ValidationHelper.GetGuid(t["ShareId"]),
                    SystemUserId = ValidationHelper.GetGuid(t["SystemUserId"]),
                    TeamId = ValidationHelper.GetGuid(t["TeamId"]),
                    
                }
                );
        }
        
        sf.InsertUpdateShareList(saveList);
        e.Success = true;
    }
}