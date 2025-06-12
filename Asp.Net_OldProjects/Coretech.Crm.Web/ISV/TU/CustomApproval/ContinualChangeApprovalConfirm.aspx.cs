using Coretech.Crm.Utility.Util;
using System.Data;
using TuFactory.CustomApproval;

namespace Coretech.Crm.Web.ISV.TU.CustomApproval
{
    public partial class ContinualChangeApprovalConfirm : CustomApprovalPage<ContinualChangeSimpleApproval>
    {
        protected override void SetApprovalData()
        {
            lApprovalDesc.Text = this.Approval.ApprovalDescription;

            DataSet changesSet = this.Approval.GetChanges();

            for (int i = 0; i < changesSet.Tables["ChangesTable"].Columns.Count; i++)
            {
                SetGridColumn(changesSet.Tables["ChangesTable"].Columns[i]);
            }

            for (int i = 0; i < gpChanges.ColumnModel.Columns.Count; i++)
            {
                gpChanges.ColumnModel.Columns[i].Width = ValidationHelper.GetInteger(changesSet.Tables["WidthsTable"].Rows[i]["Width"], 100);
            }

            gpChanges.DataSource = changesSet.Tables["ChangesTable"];
            gpChanges.DataBind();
        }

        void SetGridColumn(DataColumn dataColumn)
        {
            gpChanges.ColumnModel.Columns.Add
            (
                new RefleXFrameWork.GridColumns()
                {
                    Header = dataColumn.Caption,
                    ColumnId = dataColumn.Ordinal.ToString(),
                    DataIndex = dataColumn.ColumnName,
                    Sortable = false,
                    MenuDisabled = true
                }
            );
        }
    }
}