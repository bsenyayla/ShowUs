using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.CustomApproval;
using TuFactory.Object.User;
using TuFactory.TuUser;
using TuFactory.Utility;

namespace Coretech.Crm.Web.ISV.TU.CustomApproval
{
    public partial class ApprovalList : BasePage
    {
        public class ApprovalData
        {
            public Guid ApprovalId { get; set; }

            public string ApprovalType { get; set; }

            public string ApprovalKey { get; set; }

            public string ApprovalDescription { get; set; }

            public string ApprovalStatus { get; set; }

            public string CreateUserFullName { get; set; }

            public string CreateDate { get; set; }

            public string ApprovalUrl { get; set; }

            public string ApprovalExplanation { get; set; }
        }

        public class ApprovalHistoryData
        {
            public Guid ApprovalHistoryId { get; set; }

            public string ApprovalStatus { get; set; }

            public string ApprovalUserFullName { get; set; }

            public string CreateDate { get; set; }
        }

        string ValidateFilter()
        {
            string result = string.Empty;
            if (string.IsNullOrEmpty(tfKey.Value))
            {
                result = ValidateDates(dfStartDate.Value, dfEndDate.Value, 15);
            }
            return result;
        }

        string ValidateDates(DateTime? startDate, DateTime? endDate, int dateRange)
        {
            if (startDate.HasValue && endDate.HasValue)
            {
                int days = endDate.Value.Subtract(startDate.Value).Days;
                if (days < 0)
                {
                    return "Bitiş tarihi, başlangıç tarihinden küçük olamaz.";
                }
                if (days > dateRange)
                {
                    return string.Format("{0} günden daha uzun aralık için arama yapılamaz.", dateRange);
                }
            }
            else
            {
                return "Arama için, başlangıç tarihi ve bitiş tarihi veya referans bilgileri zorunludur.";
            }
            return string.Empty;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                string type = Request.QueryString["type"];
                switch (type)
                {
                    case "accounting":
                        SetLabels("Referans");
                        break;
                    case "kvkk":
                        SetLabels("Müşteri");
                        windowDetail.Width = 600;
                        windowDetail.Height = 300;
                        break;
                    default:
                        SetLabels("Referans");
                        break;
                }

                dfStartDate.Value = DateTime.Today;
                dfEndDate.Value = DateTime.Today;
            }
        }

        void SetLabels(string keyLabel)
        {
            tfKey.FieldLabel = keyLabel;
            gpApproval.ColumnModel.Columns[1].Header = keyLabel;
        }

        protected void GetApprovalList(object sender, AjaxEventArgs e)
        {
            string validationResult = ValidateFilter();
            if (string.IsNullOrEmpty(validationResult))
            {
                ApprovalDataLoad(null, null);
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

        protected void ApprovalDataLoad(object sender, AjaxEventArgs e)
        {
            ApprovalManager approvalManager = new ApprovalManager();

            List<ApprovalTypes> approvalTypes = new List<ApprovalTypes>();
            string type = Request.QueryString["type"];
            switch (type)
            {
                case "accounting":
                    approvalTypes.Add(ApprovalTypes.FreePreAccountingApproval);
                    approvalTypes.Add(ApprovalTypes.ManualBankAccountingApproval);
                    approvalTypes.Add(ApprovalTypes.ManualPreAccountingApproval);
                    approvalTypes.Add(ApprovalTypes.BankTransactionNumberUpdateApproval);
                    approvalTypes.Add(ApprovalTypes.ExternalAccountTransactionUpdateApproval);
                    break;
                case "kvkk":
                    approvalTypes.Add(ApprovalTypes.CustomerDataProtectionApproval);
                    approvalTypes.Add(ApprovalTypes.CustomerDataDeletionApproval);
                    break;
                default:
                    approvalTypes.Add(ApprovalTypes.FreePreAccountingApproval);
                    approvalTypes.Add(ApprovalTypes.ManualBankAccountingApproval);
                    approvalTypes.Add(ApprovalTypes.ManualPreAccountingApproval);
                    approvalTypes.Add(ApprovalTypes.BankTransactionNumberUpdateApproval);
                    approvalTypes.Add(ApprovalTypes.ExternalAccountTransactionUpdateApproval);
                    approvalTypes.Add(ApprovalTypes.CloudAccountTransactionOfficeApproval);
                    approvalTypes.Add(ApprovalTypes.SweepInstructionsApproval);
                    break;
            }

            List<Approval> list = approvalManager.GetApprovalList(dfStartDate.Value, dfEndDate.Value, tfKey.Value.Trim(), cfStatus.Checked, approvalTypes);

            List<ApprovalData> dataList = new List<ApprovalData>();

            for (int i = 0; i < list.Count; i++)
            {
                dataList.Add
                (
                    new ApprovalData()
                    {
                        ApprovalId = list[i].ApprovalId,
                        ApprovalKey = list[i].ApprovalKey,
                        ApprovalDescription = list[i].ApprovalDescription,
                        ApprovalType = EnumHelper.GetDescription(list[i].ApprovalType.Type),
                        ApprovalStatus = EnumHelper.GetDescription(list[i].ApprovalStatus),
                        CreateUserFullName = list[i].CreateUser.FullName,
                        CreateDate = list[i].CreateDate.ToString("dd.MM.yyyy HH:mm:ss"),
                        ApprovalUrl = list[i].ApprovalType.ApprovalUrl,
                        ApprovalExplanation = list[i].ApprovalExplanation
                    }
                );
            }

            dtApprovalList = ToDataTable(dataList);


            gpApproval.DataSource = dataList;
            gpApproval.TotalCount = dataList.Count;
            gpApproval.DataBind();
        }

        List<ApprovalHistoryData> historyList;

        protected void ApprovalHistoryDataLoad(object sender, AjaxEventArgs e)
        {
            gpHistory.DataSource = historyList;
            gpHistory.TotalCount = historyList.Count;
            gpHistory.DataBind();
        }
        DataTable dtApprovalList
        {
            get
            {
                return Session["ApprovalListData"] as DataTable;
            }
            set
            {
                Session["ApprovalListData"] = value;
            }
        }

        protected void ExportToExcel(object sender, AjaxEventArgs e)
        {
            var n = string.Format("Approval_List_{0:yyyy_MM_dd_hh_mm_ss}.xls", DateTime.Now);

            if (dtApprovalList != null)
            {
                Export.ExportDownloadData(dtApprovalList, n);
            }
            else
            {
                ShowMessage("Listelenmiş kayıt bulunamadı");
            }

        }

        protected void ShowDetail(object sender, AjaxEventArgs e)
        {
            var rowSelectionModel = ((RowSelectionModel)gpApproval.SelectionModel[0]);
            if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
            {
                Guid approvalId = ValidationHelper.GetGuid(rowSelectionModel.SelectedRows[0].ApprovalId);
                pnlDetail.LoadUrl(string.Format(ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].ApprovalUrl) + "?mode=approval&approvalId={0}", approvalId));
                windowDetail.Show();
            }
        }

        protected void ShowHistory(object sender, AjaxEventArgs e)
        {
            var rowSelectionModel = ((RowSelectionModel)gpApproval.SelectionModel[0]);
            if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
            {
                Guid approvalId = ValidationHelper.GetGuid(rowSelectionModel.SelectedRows[0].ApprovalId);

                ApprovalManager approvalManager = new ApprovalManager();
                List<ApprovalHistory> list = approvalManager.GetApprovalHistoryList(approvalId);

                historyList = new List<ApprovalHistoryData>();
                for (int i = 0; i < list.Count; i++)
                {
                    historyList.Add
                    (
                        new ApprovalHistoryData()
                        {
                            ApprovalHistoryId = list[i].ApprovalHistoryId,
                            ApprovalStatus = EnumHelper.GetDescription(list[i].ApprovalStatus),
                            ApprovalUserFullName = list[i].ApprovalUser.FullName,
                            CreateDate = list[i].CreateDate.ToString("dd.MM.yyyy HH:mm:ss")
                        }
                    );
                }

                ApprovalHistoryDataLoad(null, null);
                windowHistory.Show();
            }
        }
        void ShowMessage(string messageText)
        {
            MessageBox messageBox = new MessageBox();
            messageBox.Width = 360;
            messageBox.Height = 150;
            messageBox.Show(messageText);
        }
        DataTable ToDataTable<T>(IList<T> data)
        {
            PropertyDescriptorCollection props =
                TypeDescriptor.GetProperties(typeof(T));
            DataTable table = new DataTable();
            for (int i = 0; i < props.Count; i++)
            {
                PropertyDescriptor prop = props[i];
                table.Columns.Add(prop.Name, prop.PropertyType);
            }
            object[] values = new object[props.Count];
            foreach (T item in data)
            {
                for (int i = 0; i < values.Length; i++)
                {
                    values[i] = props[i].GetValue(item);
                }
                table.Rows.Add(values);
            }
            return table;
        }
    }
}