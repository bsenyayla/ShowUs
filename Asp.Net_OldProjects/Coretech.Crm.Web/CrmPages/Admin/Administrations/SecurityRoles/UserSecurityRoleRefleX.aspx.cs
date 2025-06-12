using System;
using System.Collections.Generic;
using System.Linq;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Crm.Dynamic;
using RefleXFrameWork;
using Coretech.Crm.Web.UI.RefleX;

public partial class CrmPages_Admin_Administrations_SecurityRoles_UserSecurityRoleRefleX : AdminPage
{
    private List<UserRole> _currentUserRoles = new List<UserRole>();
    public CrmPages_Admin_Administrations_SecurityRoles_UserSecurityRoleRefleX()
    {
        ObjectId = EntityEnum.Systemuser.GetHashCode();
    }
    void TranslateMessage()
    {

        _grdsma.ColumnModel.Columns[0].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_ROLE_NAME);
        _grdsma.ColumnModel.Columns[1].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_ROLE_STARTDATE);
        _grdsma.ColumnModel.Columns[2].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_ROLE_ENDDATE);

        RollAdd.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_ROLE_ADD);
        QScript("window.top.R.WindowMng.getActiveWindow().setTitle(" + ScriptCreater.SerializeString(CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_ROLE_SCREEN)) + ");");

        //BtnClear.ToolTip = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_ROLE_SCREEN);

    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Systemuser PrvCreate,PrvWrite");
        }
        //if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        //{
        //    Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Systemuser PrvCreate,PrvDelete,PrvWrite");
        //}
        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
        }
    }

    protected void StoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        var scr = new SecurityFactory();
        _currentUserRoles = scr.GetUserRoles(ValidationHelper.GetGuid(QueryHelper.GetString("RecordId")));
        Session["_currentUserRoles"] = _currentUserRoles;
        _grdsma.DataSource = _currentUserRoles;
        _grdsma.DataBind();

        _grdsma.ClearSelection();

        for (int i = 0; i < _currentUserRoles.Count; i++)
        {
            if (_currentUserRoles[i].Selected)
            {
                _grdsma.SetSelectedRowsIndex(i, true);
            }
        }
    }

    protected void RollAddOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {

            var degerler = ((CheckSelectionModel)_grdsma.SelectionModel[0]).SelectedRows;

            int ikCount = 0;

            if (degerler != null)
            {
                var datas = new List<UserSecurity>();
                foreach (var item in degerler)
                {
                    if (ValidationHelper.GetGuid(item.RoleId) == ValidationHelper.GetGuid("00000023-F232-4F48-B4CA-E9477A844273")) // *IK Giris
                    {
                        ikCount++;
                    }
                    if (ValidationHelper.GetGuid(item.RoleId) == ValidationHelper.GetGuid("00000023-3D32-4D65-955E-C80EB84610FC")) // *IK Onay
                    {
                        ikCount++;
                    }
                    if (ikCount == 2)
                    {
                        new MessageBox("IK Giriş ve IK Onay rolleri aynı kişi için seçilemez");
                        return;
                    }
                    var us = new UserSecurity
                    {
                        RoleId = ValidationHelper.GetGuid(item.RoleId),
                        SystemUserId = ValidationHelper.GetGuid(QueryHelper.GetString("RecordId")),
                        EndDate = ValidationHelper.ParseObj2NullDateTime(item.EndDate),
                        StartDate = ValidationHelper.ParseObj2NullDateTime(item.StartDate)
                    };
                    datas.Add(us);
                }

                var sf = new SecurityFactory();

                _currentUserRoles = sf.GetUserRoles(ValidationHelper.GetGuid(QueryHelper.GetString("RecordId")));

                var targetSystemUserId = ValidationHelper.GetGuid(QueryHelper.GetString("RecordId"));

                sf.SaveUserSecurityRoll(datas, targetSystemUserId);

                sf.SaveUserSecurityRollLogHistory(GenerateUserRoleLogHistory(datas, targetSystemUserId), targetSystemUserId);

                _grdsma.Reload();

                new MessageBox(CrmLabel.TranslateMessage(LabelEnum.USER_ROLES_SAVED));

            }
        }
        catch (Exception ex)
        {
            e.Message = ex.Message;
            e.Success = false;
        }
    }

    #region RoleLogHistory
    private List<UserRoleLogHistory> GenerateUserRoleLogHistory(List<UserSecurity> newRoles, Guid userId)
    {
        var scr = new SecurityFactory();

        List<UserRoleLogHistory> result = new List<UserRoleLogHistory>();

        var oldList = _currentUserRoles.Where(x => x.Selected).ToList();

        oldList.ForEach((x) =>
        {
            result.Add(new UserRoleLogHistory()
            {
                OldRoleId = x.RoleId,
                SystemUserId = userId
            });
        });

        if (oldList.Count > 0)
        {
            for (int i = 0; i < result.Count; i++)
            {
                var obj = newRoles.Where(item => item.RoleId == result[i].OldRoleId);
                if (obj.Any())
                    result[i].RoleId = obj.First().RoleId;
                else
                    result[i].RoleId = null;
            }


            for (int i = 0; i < newRoles.Count; i++)
            {
                var obj = result.Where(item => item.RoleId == newRoles[i].RoleId);
                if (!obj.Any())
                {
                    result.Add(new UserRoleLogHistory()
                    {
                        RoleId = newRoles[i].RoleId,
                        SystemUserId = userId
                    });
                }
            }
        }
        else
        {
            newRoles.ForEach((x) =>
            {
                result.Add(new UserRoleLogHistory()
                {
                    OldRoleId = null,
                    RoleId = x.RoleId,
                    SystemUserId = userId
                });
            });
        }

        return result.Where(x => x.OldRoleId != x.RoleId).ToList();
    }
    #endregion
}