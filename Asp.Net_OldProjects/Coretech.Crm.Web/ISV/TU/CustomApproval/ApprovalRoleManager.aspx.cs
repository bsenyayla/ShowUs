using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.CustomApproval;
using TuFactory.Utility;

namespace Coretech.Crm.Web.ISV.TU.CustomApproval
{
    public partial class ApprovalRoleManager : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                cfApprovalTypes.Items.Add(new System.Web.UI.WebControls.ListItem("Seçiniz.", "-1"));

                IEnumerable<ApprovalTypes> approvalTypes = Enum.GetValues(typeof(ApprovalTypes)).Cast<ApprovalTypes>();
                for (int i = 0; i < approvalTypes.Count(); i++)
                {
                    cfApprovalTypes.Items.Add(new System.Web.UI.WebControls.ListItem(EnumHelper.GetDescription(approvalTypes.ElementAt(i)),((int)approvalTypes.ElementAt(i)).ToString()));
                }
            }
        }

        protected void GetRoles(object sender, EventArgs e)
        {
            lResult.Visible = false;

            int selectedValue = ValidationHelper.GetInteger(cfApprovalTypes.SelectedValue, -1);
            if (selectedValue != -1)
            {
                ApprovalTypes approvalType = (ApprovalTypes)selectedValue;
                TuFactory.CustomApproval.ApprovalRoleManager approvalRoleManager = new TuFactory.CustomApproval.ApprovalRoleManager();
                rpRoles.DataSource = approvalRoleManager.GetCustomApprovalRoles(approvalType);
                rpRoles.DataBind();
                bSetRoles.Visible = true;
            }
            else
            {
                bSetRoles.Visible = false;                
                rpRoles.DataSource = null;
                rpRoles.DataBind();
            }
        }

        protected void RolesDataBound(object sender, RepeaterItemEventArgs e)
        {
            if(e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                HiddenField hRoleId = e.Item.FindControl("hRoleId") as HiddenField;
                Literal lRoleName = e.Item.FindControl("lRoleName") as Literal;
                CheckBox cbMaker = e.Item.FindControl("cbMaker") as CheckBox;
                CheckBox cbChecker = e.Item.FindControl("cbChecker") as CheckBox;

                DataRowView dr = e.Item.DataItem as DataRowView;
                hRoleId.Value = dr["ROLE_ID"].ToString();
                lRoleName.Text = dr["ROLE_NAME"].ToString();
                cbMaker.Checked = ValidationHelper.GetBoolean(dr["MAKER"], false);
                cbChecker.Checked = ValidationHelper.GetBoolean(dr["CHECKER"], false);
            }
        }

        protected void SetRoles(object sender, EventArgs e)
        {
            ApprovalTypes approvalType = (ApprovalTypes)ValidationHelper.GetInteger(cfApprovalTypes.SelectedValue);
            List<ApprovalRole> approvalRoleList = new List<ApprovalRole>();
            for (int i = 0; i < rpRoles.Items.Count; i++)
            {
                if (rpRoles.Items[i].ItemType == ListItemType.Item || rpRoles.Items[i].ItemType == ListItemType.AlternatingItem)
                {
                    HiddenField hRoleId = rpRoles.Items[i].FindControl("hRoleId") as HiddenField;
                    Literal lRoleName = rpRoles.Items[i].FindControl("lRoleName") as Literal;
                    CheckBox cbMaker = rpRoles.Items[i].FindControl("cbMaker") as CheckBox;
                    CheckBox cbChecker = rpRoles.Items[i].FindControl("cbChecker") as CheckBox;

                    ApprovalRole approvalRole = new ApprovalRole();
                    approvalRole.ApprovalType = approvalType;
                    approvalRole.RoleId = ValidationHelper.GetGuid(hRoleId.Value);
                    approvalRole.Maker = cbMaker.Checked;
                    approvalRole.Checker = cbChecker.Checked;

                    approvalRoleList.Add(approvalRole);
                }
            }


            TuFactory.CustomApproval.ApprovalRoleManager approvalRoleManager = new TuFactory.CustomApproval.ApprovalRoleManager();
            DataTable oldRolesTable = approvalRoleManager.GetCustomApprovalRoles(approvalType);

            Guid oldRoleId;
            bool oldMaker;
            bool oldChecker;
            ApprovalRole newRole;

            List<ApprovalRole> newApprovalRoleList = new List<ApprovalRole>();

            for (int i = 0; i < oldRolesTable.Rows.Count; i++)
            {
                oldRoleId = ValidationHelper.GetGuid(oldRolesTable.Rows[i]["ROLE_ID"].ToString());
                oldMaker = ValidationHelper.GetBoolean(oldRolesTable.Rows[i]["MAKER"], false);
                oldChecker = ValidationHelper.GetBoolean(oldRolesTable.Rows[i]["CHECKER"], false);

                newRole = approvalRoleList.Single(a => a.RoleId == oldRoleId);
                if((newRole.Maker != oldMaker) || (newRole.Checker != oldChecker))
                {
                    newApprovalRoleList.Add(newRole);
                }
            }

            if (newApprovalRoleList.Count > 0)
            {
                string result = approvalRoleManager.SetCustomApprovalRoles(newApprovalRoleList);

                if (result == string.Empty)
                {
                    lResult.Text = "Rol tanımı yapılmıştır.";
                }
                else
                {
                    lResult.Text = result;
                }
            }
            else
            {
                lResult.Text = "Rol tanımlarında bir değişiklik yapılmamıştır.";
            }
            lResult.Visible = true;
        }
    }
}