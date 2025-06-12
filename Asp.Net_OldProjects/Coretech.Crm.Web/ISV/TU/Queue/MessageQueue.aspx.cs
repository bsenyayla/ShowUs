using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Data;
using TuFactory.DayOff.Repository;
using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using TuFactory.MessageQueue;

public partial class Queue_MessageQueue: BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            dStartDate.Value = DateTime.Today;
            dEndDate.Value = DateTime.Today;
        }
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
                return string.Format("{0} günden daha uzun aralık için gün sonu yapılamaz.", dateRange);
            }
        }
        else
        {
            return "Başlangıç tarihi ve bitiş tarihi bilgileri zorunludur.";
        }
        return string.Empty;
    }

    void ShowMessage(string messageText)
    {
        MessageBox messageBox = new MessageBox();
        messageBox.Width = 400;
        messageBox.Height = 200;
        messageBox.Show(messageText);
    }

    protected void QueueListDataBind(object sender, AjaxEventArgs e)
    {
        DataTable dt = UPTMQPage.GetQueues();
        cfQueue.DataSource = dt;
        cfQueue.DataBind();
    }

    protected void ListDataClick(object sender, AjaxEventArgs e)
    {
        MessageListDataBind();
    }

    protected void MessageListDataBind()
    {
        if (string.IsNullOrEmpty(cfQueue.Value))
        {
            ShowMessage("Kuyruk yolu bilgisi zorunludur.");
            return;
        }

        DateTime? startDate = dStartDate.Value;
        DateTime? endDate = dEndDate.Value;
        string validationMsg = ValidateDates(startDate, endDate, 5);
        if (string.IsNullOrEmpty(validationMsg))
        {
            DataTable dt = UPTMQPage.GetMessages(startDate.Value, endDate.Value, ValidationHelper.GetGuid(cfQueue.Value));
            gData.DataSource = dt;
            gData.TotalCount = dt.Rows.Count;
            gData.DataBind();
        }
        else
        {
            ShowMessage(validationMsg);
        } 
    }

    protected void ShowHistory(object sender, AjaxEventArgs e)
    {
        var rowSelectionModel = ((RowSelectionModel)gData.SelectionModel[0]);
        if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
        {
            Guid messageId = ValidationHelper.GetGuid(rowSelectionModel.SelectedRows[0].MESSAGE_ID);
            MessageHistoryOnLoad(messageId);
            ProcessHistoryOnLoad(messageId);
            windowHistory.Show();
            return;
        }
    }

    protected void Reprocess(object sender, AjaxEventArgs e)
    {
        var rowSelectionModel = ((RowSelectionModel)gData.SelectionModel[0]);
        if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
        {
            int messageStatus = ValidationHelper.GetInteger(rowSelectionModel.SelectedRows[0].MESSAGE_STATUS);
            int processStatus = -1;
            if (rowSelectionModel.SelectedRows[0].PROCESS_STATUS != null)
            {
                processStatus = ValidationHelper.GetInteger(rowSelectionModel.SelectedRows[0].PROCESS_STATUS);
            }

            if (processStatus == -1)
            {
                Guid messageId = ValidationHelper.GetGuid(rowSelectionModel.SelectedRows[0].MESSAGE_ID);
                string result = UPTMQPage.UpdateMessageAsUnread(messageId, App.Params.CurrentUser.SystemUserId);
                if (string.IsNullOrEmpty(result))
                {
                    ShowMessage("İşlem yeniden işleme alınmıştır ve tekrar işlenecektir.");
                }
                else
                {
                    ShowMessage(string.Format("Hata oluştu: {0}", result));
                }
            }
            else if (messageStatus == 2 && processStatus != 3)
            {
                Guid messageProcessId = ValidationHelper.GetGuid(rowSelectionModel.SelectedRows[0].MESSAGE_PROCESS_ID);
                UPTMQPage.Reprocess(messageProcessId, App.Params.CurrentUser.SystemUserId);
                MessageListDataBind();
                ShowMessage("İşlem yeniden işleme alınmıştır ve tekrar işlenecektir.");
            }
            else
            {
                ShowMessage("İşlem yeniden işlenmeye uygun değildir.");
            }
        }
    }

    protected void MessageHistoryOnLoad(Guid messageId)
    {
        DataTable dt = UPTMQPage.GetMessageHistory(messageId);
        gMessageHistory.DataSource = dt;
        gMessageHistory.TotalCount = dt.Rows.Count;
        gMessageHistory.DataBind();
    }

    protected void ProcessHistoryOnLoad(Guid messageId)
    {
        DataTable dt = UPTMQPage.GetProcessHistory(messageId);
        gProcessHistory.DataSource = dt;
        gProcessHistory.TotalCount = dt.Rows.Count;
        gProcessHistory.DataBind();
    }
}