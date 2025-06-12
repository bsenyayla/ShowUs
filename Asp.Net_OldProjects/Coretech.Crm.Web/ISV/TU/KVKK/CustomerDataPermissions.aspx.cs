using Coretech.Crm.Utility.Util;
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.CustomerData;
using TuFactory.Utility;

namespace Coretech.Crm.Web.ISV.TU.KVKK
{
    public partial class CustomerDataPermissions : Page
    {
        protected Guid CustomerId => ValidationHelper.GetGuid(Request.QueryString["CustomerId"]);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                DataTable dtCustomer = CustomerDataProtectionService.GetCustomerDataPermissions(this.CustomerId);
                lCustomerCode.Text = ValidationHelper.GetString(dtCustomer.Rows[0]["CustomerCode"]);
                lCustomerName.Text = ValidationHelper.GetString(dtCustomer.Rows[0]["CustomerName"]);
                CustomerDataUsagePermissionType oldPermissionValue = (CustomerDataUsagePermissionType)ValidationHelper.GetInteger(dtCustomer.Rows[0]["DataUsagePermissions"]);
                hOldPermissions.Value = ((int)oldPermissionValue).ToString();
                hDataUsagePermissionsGiven.Value = ValidationHelper.GetBoolean(dtCustomer.Rows[0]["DataUsagePermissionsGiven"]).ToString();

                DataTable dt = new DataTable();
                dt.Columns.Add("Permission");
                dt.Columns.Add("PermissionName");
                dt.Columns.Add("IsAllowed");

                SetPermissionDataRow(dt, oldPermissionValue, CustomerDataUsagePermissionType.UPT);
                //SetPermissionDataRow(dt, oldPermissionValue, CustomerDataUsagePermissionType.Bank);
                //SetPermissionDataRow(dt, oldPermissionValue, CustomerDataUsagePermissionType.AbroadPartners);
                //SetPermissionDataRow(dt, oldPermissionValue, CustomerDataUsagePermissionType.Other);

                rpPermissions.DataSource = dt;
                rpPermissions.DataBind();
            }
        }

        void SetPermissionDataRow(DataTable dt, CustomerDataUsagePermissionType oldPermissionValue, CustomerDataUsagePermissionType permissionType)
        {
            DataRow dr = dt.NewRow();
            dr["Permission"] = (int)permissionType;
            dr["PermissionName"] = EnumHelper.GetDescription(permissionType);
            dr["IsAllowed"] = oldPermissionValue.HasFlag(permissionType);
            dt.Rows.Add(dr);
        }

        protected void PermissionItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                CheckBox cfIsAllowed = e.Item.FindControl("cfIsAllowed") as CheckBox;
                Label lPermissionName = e.Item.FindControl("lPermissionName") as Label;
                HiddenField hPermission = e.Item.FindControl("hPermission") as HiddenField;

                DataRowView dr = e.Item.DataItem as DataRowView;
                cfIsAllowed.Checked = ValidationHelper.GetBoolean(dr["IsAllowed"], false);
                lPermissionName.Text = ValidationHelper.GetString(dr["PermissionName"]);
                hPermission.Value = ValidationHelper.GetString(dr["Permission"]);
            }
        }

        protected void SavePermissions(object sender, EventArgs e)
        {
            bool dataUsagePermissionsGiven = ValidationHelper.GetBoolean(hDataUsagePermissionsGiven.Value);
            if (dataUsagePermissionsGiven)
            {
                CustomerDataUsagePermissionType oldPermissionValue = (CustomerDataUsagePermissionType)ValidationHelper.GetInteger(hOldPermissions.Value, 0);
                string customerCode = lCustomerCode.Text;
                string customerName = lCustomerName.Text;

                int permissionValue = 0;
                for (int i = 0; i < rpPermissions.Items.Count; i++)
                {
                    if (rpPermissions.Items[i].ItemType == ListItemType.Item || rpPermissions.Items[i].ItemType == ListItemType.AlternatingItem)
                    {
                        CheckBox cfIsAllowed = rpPermissions.Items[i].FindControl("cfIsAllowed") as CheckBox;
                        if (cfIsAllowed.Checked)
                        {
                            HiddenField hPermission = rpPermissions.Items[i].FindControl("hPermission") as HiddenField;
                            permissionValue += ValidationHelper.GetInteger(hPermission.Value, 0);
                        }
                    }
                }

                string saveRet = CustomerDataProtectionService.CustomerDataProtectionPermissionChangeRequest(this.CustomerId, customerCode, customerName, (CustomerDataUsagePermissionType)permissionValue);
                if (string.IsNullOrEmpty(saveRet))
                {
                    lResult.Text = "İzin değişim talebi onaya gönderildi.";
                }
                else
                {
                    lResult.Text = saveRet;
                }
                bSavePermissions.Enabled = false;
            }
            else
            {
                lResult.Text = "Bu ekrandan müşterinin veri kullanımına izin verdiği kanalları Hayır (H) olarak güncelleyebilirsiniz. Müşteri, verilerinin kullanımına izin vermek istiyorsa herhangi bir yurtiçi UPT noktasından işlem yapması yeterlidir.";
            }
        }
    }
}