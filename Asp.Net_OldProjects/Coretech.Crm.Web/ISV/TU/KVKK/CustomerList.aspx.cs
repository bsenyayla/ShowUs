using Coretech.Crm.Factory;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Data;
using TuFactory.CustomApproval.KVKK;
using TuFactory.CustomerData;

namespace Coretech.Crm.Web.ISV.TU.KVKK
{
    public partial class CustomerList : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void GetCustomerList(object sender, AjaxEventArgs e)
        {
            string validationResult = ValidateSearch();
            if (string.IsNullOrEmpty(validationResult))
            {
                CustomerDataLoad(null, null);
            }
            else
            {
                MessageBox messageBox = new MessageBox()
                {
                    Modal = true,
                    MessageType = EMessageType.Error,
                    Width = 400,
                    Height = 200
                };
                messageBox.Show(validationResult);
            }
        }

        protected void CustomerDataLoad(object sender, AjaxEventArgs e)
        {
            DataTable dt = CustomerDataProtectionService.GetCustomerList(tfName.Value.Trim(), tfIdentificationNumber.Value.Trim(), tfIdentityNo.Value.Trim());
            gpCustomers.DataSource = dt;
            gpCustomers.TotalCount = dt.Rows.Count;
            gpCustomers.DataBind();
        }

        protected void ShowHistory(object sender, AjaxEventArgs e)
        {
            var rowSelectionModel = ((RowSelectionModel)gpCustomers.SelectionModel[0]);
            if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
            {
                Guid customerId = ValidationHelper.GetGuid(rowSelectionModel.SelectedRows[0].CustomerId);
                pnlHistory.LoadUrl(string.Format("CustomerHistory.aspx?CustomerId={0}", customerId));
                windowHistory.Show();
            }
        }

        protected void ShowPermissions(object sender, AjaxEventArgs e)
        {
            var rowSelectionModel = ((RowSelectionModel)gpCustomers.SelectionModel[0]);
            if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
            {
                Guid customerId = ValidationHelper.GetGuid(rowSelectionModel.SelectedRows[0].CustomerId);
                pnlPermissions.LoadUrl(string.Format("CustomerDataPermissions.aspx?CustomerId={0}", customerId));
                windowPermissions.Show();
            }
        }

        protected void CustomerDataDelete(object sender, AjaxEventArgs e)
        {
            var rowSelectionModel = ((RowSelectionModel)gpCustomers.SelectionModel[0]);
            if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
            {
                Guid customerId = ValidationHelper.GetGuid(rowSelectionModel.SelectedRows[0].CustomerId);
                string customerCode = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].CustomerCode);
                string customerName = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].CustomerName);
                string hasDeleteRequestTaken = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].HasDeleteRequestTaken);
                if (hasDeleteRequestTaken == "H")
                {
                    CustomerDataDeletionApproval approval = new CustomerDataDeletionApproval()
                    {
                        CustomerId = customerId,
                        HasDeleteRequestTaken = true,
                        DeleteRequestDate = DateTime.Now,
                        ApprovalKey = customerId.ToString(),
                        ApprovalDescription = customerCode + " - " + customerName,
                        CreateUser = new TuFactory.Domain.SystemUser() { SystemUserId = App.Params.CurrentUser.SystemUserId }
                    };
                    string saveRet = approval.Save();
                    if (string.IsNullOrEmpty(saveRet))
                    {
                        MessageBox messageBox = new MessageBox() { MessageType = EMessageType.Information, Width = 500, Height = 200 };
                        messageBox.Show("Veri silme talebiniz alınmıştır, onay beklemektedir.");
                    }
                    else
                    {
                        MessageBox messageBox = new MessageBox() { MessageType = EMessageType.Error, Width = 500, Height = 200 };
                        messageBox.Show(saveRet);
                    }
                }
                else
                {
                    MessageBox messageBox = new MessageBox() { MessageType = EMessageType.Error, Width = 500, Height = 200 };
                    messageBox.Show("Veri silinme talebi daha önceden alınmıştır.");
                }
            }
        }

        string ValidateSearch()
        {
            if (string.IsNullOrEmpty(tfIdentificationNumber.Value.Trim()) && string.IsNullOrEmpty(tfIdentityNo.Value.Trim()))
            {
                return "Vatandaşlık no ya da kimlik no alanlarından birini girmek zorunludur";
            }
            return string.Empty;
        }
    }
}