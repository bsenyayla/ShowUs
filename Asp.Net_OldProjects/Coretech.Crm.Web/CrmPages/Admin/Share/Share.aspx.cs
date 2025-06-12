using System;
using System.Collections.Generic;
using System.Web.UI;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Share;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Share;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;

public partial class CrmPages_Admin_Share_ShareReflex : BasePage
{
    private DynamicSecurity _dynamicSecurity;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack && !RefleX.IsAjxPostback)
        {

            hdnRecid.Value = QueryHelper.GetString("RecordId");
            hdnObjectId.Value = QueryHelper.GetString("ObjectId");
            this.RR.RegisterIcon(Icon.User);
            this.RR.RegisterIcon(Icon.GroupAdd);
            this.RR.RegisterIcon(Icon.FolderUser);

            fillList();
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
    void fillList()
    {
        var sf = new ShareFactory();
        var sharedList = sf.GetSharedList(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                          ValidationHelper.GetGuid(hdnRecid.Value));
        GridShare.DataSource = sharedList;
        GridShare.DataBind();

    }
    protected void BtnSave_Click(object sender, AjaxEventArgs e)
    {

        var objectId = ValidationHelper.GetInteger(hdnObjectId.Value, 0);
        var recid = ValidationHelper.GetGuid(hdnRecid.Value);
        
        var saveList = new List<Share>();
        var sf = new ShareFactory();
        foreach (var t in GridShare.AllRows)
        {
            saveList.Add(
                new Share
                {
                    PrvRead = ValidationHelper.GetBoolean(t["PrvRead"],false),
                    PrvAssign = ValidationHelper.GetBoolean(t["PrvAssign"], false),
                    PrvShare = ValidationHelper.GetBoolean(t["PrvShare"], false),
                    PrvDelete = ValidationHelper.GetBoolean(t["PrvDelete"], false),
                    PrvWrite = ValidationHelper.GetBoolean(t["PrvWrite"], false),
                    ObjectId = objectId,
                    RecordId = recid,
                    ShareId = ValidationHelper.GetGuid(t["ShareId"]),
                    SystemUserId = ValidationHelper.GetGuid(t["SystemUserId"]),
                    TeamId = ValidationHelper.GetGuid(t["TeamId"]),
                    RoleId = ValidationHelper.GetGuid(t["RoleId"]),

                }
                );
        }

        sf.InsertUpdateShareList(saveList);
        e.Success = true;
    }
}