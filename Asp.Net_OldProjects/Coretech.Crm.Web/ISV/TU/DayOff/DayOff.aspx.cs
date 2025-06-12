using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Data;
using TuFactory.DayOff.Repository;
using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.Factory;
using TuFactory.Utility;

public partial class DayOff_DayOff : BasePage
{
    public class DayOffCreate
    {
        public DateTime StartDate { get; set; }

        public DateTime EndDate { get; set; }

        public Guid SystemUserId { get; set; }

        public void Do()
        {
            DayOffDb db = new DayOffDb();
            db.CreateDayOffData(this.StartDate, this.EndDate, this.SystemUserId);
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {}

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
        messageBox.Height = 220;
        messageBox.Show(messageText);
    }

    protected void BtnDayOffList_Click(object sender, AjaxEventArgs e)
    {
        GridPanelMainAccountOnEvent(sender, e);
    }

    protected void BtnDayOffDataCreate_Click(object sender, AjaxEventArgs e)
    {
        if (LockManager.Lock("CreateDayOff", null))
        {
            try
            {
                DateTime? startDate = DayOffStartDate.Value;
                DateTime? endDate = DayOffEndDate.Value;

                string validationMsg = ValidateDates(startDate, endDate, 15);
                if (string.IsNullOrEmpty(validationMsg))
                {
                    CreateDayOffDataAsync(startDate.Value, endDate.Value);
                    ShowMessage("İşlem tamamlandığında mail gönderilecektir.");
                }
                else
                {
                    ShowMessage(validationMsg);
                }
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }
        else
        {
            ShowMessage("Çalışan bir gün sonu işlemi bulunduğu için, işlem başlatılamamıştır.");
        }
    }

    System.Threading.Tasks.Task CreateDayOffDataAsync(DateTime startDate, DateTime endDate)
    {
        DayOffCreate dayoffCreator = new DayOffCreate() { StartDate = startDate, EndDate = endDate, SystemUserId = App.Params.CurrentUser.SystemUserId };

        var task = System.Threading.Tasks.Task.Factory.StartNew(() =>
        {
            dayoffCreator.Do();
        });

        task.ContinueWith(t =>
        {
            if (t.Exception != null)
            {
                LogUtil.WriteException(t.Exception, "CreateDayOffDataAsync");
            }
            else
            {
                if (task.IsCompleted)
                {
                    DayOffDb db = new DayOffDb();
                    db.SendDayOffCreationCompletedMail(startDate, endDate);
                    LockManager.Unlock("CreateDayOff");
                }
                else
                {
                    LogUtil.Write("CreateDayOffDataAsync tamamlanamadı.", "CreateDayOffDataAsync");
                }
            }
        });

        return task;
    }

    protected void BtnDayOffClose_Click(object sender, AjaxEventArgs e)
    {
        QScript("var answer = confirm('Gün sonu hareketlerini kapatma, o güne ait mutabakat tamamlandıktan sonra yapılmalıdır. Kapatma işlemini tamamlamayı doğruluyor musunuz?');if (answer){ console.log('yes');}else{return;}");

        DateTime? startDate = DayOffStartDate.Value;
        DateTime? endDate = DayOffEndDate.Value;

        string validationMsg = ValidateDates(startDate, endDate, 15);
        if (string.IsNullOrEmpty(validationMsg))
        {
            try
            {
                DayOffDb db = new DayOffDb();

                DataTable dt = new DataTable();
                dt = db.GetProblemDayoffRows(ValidationHelper.GetDate(DayOffStartDate.Value), ValidationHelper.GetDate(DayOffEndDate.Value));
                if (dt.Rows.Count > 0)
                {
                    ShowMessage("Gün sonu kayıtlarında sorunlu işlemler bulunmaktadır, aktarım için öncelikle bu sorunlu işlemlerin düzeltilmesi gerekmektedir. Sorunlu işlemleri 'Verileri Sına' tuşuna basarak gözlemleyebilirsiniz.");
                }
                else
                {
                    db.DayOffClose(ValidationHelper.GetDate(DayOffStartDate.Value), ValidationHelper.GetDate(DayOffEndDate.Value));
                    QScript("alert('Gün Kapama İşlemi Başarıyla Tamamlandı.'); GridPanelMainAccount.reload();");
                }
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }
        else
        {
            ShowMessage(validationMsg);
        }
    }

    protected void BtnReSendData_Click(object sender, AjaxEventArgs e)
    {
        DateTime? startDate = DayOffStartDate.Value;
        DateTime? endDate = DayOffEndDate.Value;

        string validationMsg = ValidateDates(startDate, endDate, 15);
        if (string.IsNullOrEmpty(validationMsg))
        {
            try
            {
                DayOffDb db = new DayOffDb();
                db.ReSendDayOffData(ValidationHelper.GetDate(DayOffStartDate.Value), ValidationHelper.GetDate(DayOffEndDate.Value));
                ShowMessage("Gün sonu kayıtlarının aktarımı tekrar başlatılmıştır. Aktarım durumunu, \"Gün Sonu Listesi\" tuşuna tıklayarak gözlemleyebilirsiniz.");
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }
        else
        {
            ShowMessage(validationMsg);
        }
    }

    protected void BtnDayOffExcelExport_Click(object sender, AjaxEventArgs e)
    {
        DateTime? startDate = DayOffStartDate.Value;
        DateTime? endDate = DayOffEndDate.Value;

        string validationMsg = ValidateDates(startDate, endDate, 30);
        if (string.IsNullOrEmpty(validationMsg))
        {
            DayOffDb db = new DayOffDb();
            DataTable dt = new DataTable();
            dt = db.GetDayOffData(ValidationHelper.GetDate(DayOffStartDate.Value), ValidationHelper.GetDate(DayOffEndDate.Value));
            if (dt.Rows.Count > 0)
            {
                var n = string.Format("DayOff-Export-{0:yyyy-MM-dd_hh-mm-ss-tt}.xls", DateTime.Now);
                Export.ExportDownloadData(dt, n);
            }
        }
        else
        {
            ShowMessage(validationMsg);
        }        
    }

    protected void GridPanelMainAccountOnEvent(object sender, AjaxEventArgs e)
    {
        DateTime? startDate = DayOffStartDate.Value;
        DateTime? endDate = DayOffEndDate.Value;

        string validationMsg = ValidateDates(startDate, endDate, 30);
        if (string.IsNullOrEmpty(validationMsg))
        {
            DayOffDb db = new DayOffDb();
            DataTable dt = new DataTable();
            dt = db.GetDayOffStatusReport(ValidationHelper.GetDate(DayOffStartDate.Value), ValidationHelper.GetDate(DayOffEndDate.Value));
            if (dt.Rows.Count > 0)
            {
                GridPanelMainAccount.DataSource = dt;
                GridPanelMainAccount.TotalCount = dt.Rows.Count;
                GridPanelMainAccount.DataBind();
            }
        }
        else
        {
            ShowMessage(validationMsg);
        } 
    }

    protected void BtnValidReport_Click(object sender, AjaxEventArgs e)
    {
        DayoffValidateReportGridOnLoad(sender, e);
        DayoffValidateReportGrid2OnLoad(sender, e);
        windowReport.Show();
    }

    protected void DayoffValidateReportGridOnLoad(object sender, AjaxEventArgs e)
    {
        DateTime? startDate = DayOffStartDate.Value;
        DateTime? endDate = DayOffEndDate.Value;

        string validationMsg = ValidateDates(startDate, endDate, 30);
        if (string.IsNullOrEmpty(validationMsg))
        {
            DayOffDb db = new DayOffDb();
            DataTable dt = new DataTable();
            dt = db.GetDayoffValidateReport(ValidationHelper.GetDate(DayOffStartDate.Value), ValidationHelper.GetDate(DayOffEndDate.Value));
            if (dt.Rows.Count > 0)
            {
                DayoffValidateReportGrid.DataSource = dt;
                DayoffValidateReportGrid.TotalCount = dt.Rows.Count;
                DayoffValidateReportGrid.DataBind();
            }
        }
        else
        {
            ShowMessage(validationMsg);
        }
    }

    protected void DayoffValidateReportGrid2OnLoad(object sender, AjaxEventArgs e)
    {
        DateTime? startDate = DayOffStartDate.Value;
        DateTime? endDate = DayOffEndDate.Value;

        string validationMsg = ValidateDates(startDate, endDate, 30);
        if (string.IsNullOrEmpty(validationMsg))
        {
            DayOffDb db = new DayOffDb();
            DataTable dt = new DataTable();
            dt = db.GetProblemDayoffRows(ValidationHelper.GetDate(DayOffStartDate.Value), ValidationHelper.GetDate(DayOffEndDate.Value));
            if (dt.Rows.Count > 0)
            {
                DayoffValidateReportGrid2.DataSource = dt;
                DayoffValidateReportGrid2.TotalCount = dt.Rows.Count;
                DayoffValidateReportGrid2.DataBind();
            }
        }
        else
        {
            ShowMessage(validationMsg);
        }
    }
}