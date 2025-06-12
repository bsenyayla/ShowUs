using System;
using System.Collections.Generic;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object;
public partial class UserAdmin_RoleConfirmDefault : BasePage
{
    public DynamicSecurity DynamicSecurity;
    public int ObjectId { get; set; }

    public UserAdmin_RoleConfirmDefault()
    {

        ObjectId = TuEntityEnum.New_RoleConfirmer.GetHashCode();
    }
    void TranslateMessage()
    {

        _grdsma.ColumnModel.Columns[0].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_ROLE_NAME);
        _grdsma.ColumnModel.Columns[1].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_USERNAME);
        _grdsma.ColumnModel.Columns[2].Header = CrmLabel.TranslateMessage("CRM.NEW_CONFIRMSTATUS_NEW_CONFIRMTYPE_ONAY TIPI");

        RollAdd.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE);
        RollCancel.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);

        //BtnClear.ToolTip = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_ROLE_SCREEN);

    }
    protected void Page_Load(object sender, EventArgs e)
    {
        DynamicSecurity = DynamicFactory.GetSecurity(ObjectId, null);


        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=UserRoleConfirm PrvCreate,PrvDelete,PrvWrite");
        }
        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
        }
    }

    protected void StoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        var scr = new TuFactory.TuUser.TuUserFactory();
        var list = scr.GetTuUserRoleList();

        _grdsma.DataSource = list;
        _grdsma.DataBind();

        _grdsma.ClearSelection();
    }

    protected void RollAddOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var degerler = ((CheckSelectionModel)_grdsma.SelectionModel[0]).SelectedRows;

            if (degerler != null)
            {
                var datas = new List<TuUserRole>();
                foreach (var item in degerler)
                {
                    var us = new TuUserRole
                                {
                                    RoleId = ValidationHelper.GetGuid(item.RoleId),
                                    SystemUserId = ValidationHelper.GetGuid(item.SystemUserId),
                                    TableType = ValidationHelper.GetInteger(item.TableType),
                                    ActiveId = ValidationHelper.GetGuid(item.ActiveId)
                                };
                    datas.Add(us);
                }

                var scr = new TuFactory.TuUser.TuUserFactory();
                scr.SaveTuUserRoleList(datas);

                scr.UpdateTuUserRoleLogHistory(datas);

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
    protected void RollCancelOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var degerler = ((CheckSelectionModel)_grdsma.SelectionModel[0]).SelectedRows;

            if (degerler != null)
            {
                var datas = new List<TuUserRole>();
                foreach (var item in degerler)
                {
                    var us = new TuUserRole
                    {
                        RoleId = ValidationHelper.GetGuid(item.RoleId),
                        SystemUserId = ValidationHelper.GetGuid(item.SystemUserId),
                        TableType = ValidationHelper.GetInteger(item.TableType),
                        ActiveId = ValidationHelper.GetGuid(item.ActiveId)
                    };
                    datas.Add(us);
                }

                var scr = new TuFactory.TuUser.TuUserFactory();
                scr.CancelTuUserRoleList(datas);

                scr.UpdateTuUserRoleLogHistory(datas);

                _grdsma.Reload();

                new MessageBox(CrmLabel.TranslateMessage(LabelEnum.USER_ROLES_CANCELED));
            }
        }
        catch (Exception ex)
        {
            e.Message = ex.Message;
            e.Success = false;
        }
    }
}