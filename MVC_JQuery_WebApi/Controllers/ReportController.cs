using OfficeOpenXml;
using PagedList;
using SharedCRCMS.Models;
using SharedCRCMS.Service;
using StandartLibrary.Models.Enums;
using System;
using System.Linq;
using System.Web.Mvc;

namespace Counter.Controllers
{
    [Authorize]
    [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW)]
    public class ReportController : BaseController
    {
        private CRCMSEntities db = new CRCMSEntities();

        [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R)]
        public ActionResult Index()
        {
            return View("Report");
        }

        [HttpPost]
        public JsonResult GetList()
        {
            var pauses = db.ServiceEngineer_Pause.ToArray();
            var userSmcsCode = new Counter.Controllers.AJAXController().GetUserGroupSmscCode(User);
            var projectsList = (from one in db.ServiceEngineer_List.ToList()
                                join two in db.Documents.Where(x => userSmcsCode.Contains(x.SmcsCode)).ToList() on one.DocumentId equals two.DocumentId
                                join three in db.DocumentAttributes.ToList() on one.DocumentId equals three.DocumentId
                                select (new
                                {
                                    two.DocumentNumber,
                                    TimeToCheckDocument = (new TimeSpan(0)).ToString(Counter.Lang.Resources.TimeSpanFormat), //Время на проверку
                                    Defectlist_WaitingTimeToStartPreparation = (one.DefectList_StartDate != null && three.DisassembleFinish != null) ? (one.DefectList_StartDate.Value - three.DisassembleFinish.Value).ToString(Counter.Lang.Resources.TimeSpanFormat) : "",//.ToString(StandartLibrary.Lang.Resources.TimeSpanFormat) : "", //Время ожидания начала подготовки дефектовки
                                    Defectlist_StartDate = one.DefectList_StartDate, //Дата начала дефектовки
                                    Defectlist_TotalTimeSpent = one.DefectList_StartDate != null && one.DefectList_StopDate != null ? (one.DefectList_StopDate.Value - one.DefectList_StartDate.Value).ToString(Counter.Lang.Resources.TimeSpanFormat) : "",//.ToString(StandartLibrary.Lang.Resources.TimeSpanFormat) : "", //Общее время работы над дефектовкой
                                    Defectlist_TheMainTimeSpent = one.DefectList_StartDate != null && one.DefectList_StopDate != null ? (one.DefectList_StopDate.Value - one.DefectList_StartDate.Value - new TimeSpan(pauses.Where(x => x.DocumentId == one.DocumentId && x.Type == 1 && x.StopDate != null).Sum(x => (x.StopDate.Value - x.StartDate).Ticks))).ToString(Counter.Lang.Resources.TimeSpanFormat) : "",//.ToString(StandartLibrary.Lang.Resources.TimeSpanFormat) : "", //Основное время работы над дефектовкой
                                    Defectlist_TimePausesWork = new TimeSpan(pauses.Where(x => x.DocumentId == one.DocumentId && x.Type == 1 && x.StopDate != null).Sum(x => (x.StopDate.Value - x.StartDate).Ticks)).ToString(Counter.Lang.Resources.TimeSpanFormat),//.ToString(StandartLibrary.Lang.Resources.TimeSpanFormat), //Время пауз работы над дефектовкой
                                    Defectlist_CausesOfPauses = string.Concat(pauses.Where(x => x.DocumentId == one.DocumentId && x.Type == 1 && x.StopDate != null).Select(x => x.Description)), //Причины пауз
                                    UploadDateAdditionalWork = DateTime.Now, //Дата загрузки Additional work документа
                                    Report_StartDate = one.PreparingOfReport_StartDate, //Дата начала отчета
                                    Report_CompletionDate = one.PreparingOfReport_StopDate, //Дата завершения отчета
                                    Report_TotalTimeSpent = one.PreparingOfReport_StartDate != null && one.PreparingOfReport_StopDate != null ? (one.PreparingOfReport_StopDate.Value - one.PreparingOfReport_StartDate.Value).ToString(Counter.Lang.Resources.TimeSpanFormat) : "",//.ToString(StandartLibrary.Lang.Resources.TimeSpanFormat) : "", //Общее время работы над отчетом
                                    Report_CausesOfPauses = string.Concat(pauses.Where(x => x.DocumentId == one.DocumentId && x.Type == 2 && x.StopDate != null).Select(x => x.Description)), //Причины пауз
                                    Defectlist_ReturnToRework = false, //Возврат на переделку дефектовки(yes or no)
                                    Defectlist_TheReasonForRemaking = "", //Причина переделки дефектовки
                                })).ToList();
            try
            {
                int recordsCount = projectsList.Count();
                int pageSize = int.Parse(Request["length"]);
                pageSize = pageSize < 0 ? recordsCount : pageSize;
                int fromRow = int.Parse(Request["start"]);
                int sEcho = int.Parse(Request["draw"]);
                int pageNumber = (fromRow + pageSize) / pageSize;
                if (pageNumber == 0) pageNumber = 1;
                return Json(new { draw = sEcho, recordsTotal = recordsCount, recordsFiltered = recordsCount, data = projectsList.ToPagedList(pageNumber, pageSize) }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { draw = 0, recordsTotal = 0, recordsFiltered = 0, data = "" }, JsonRequestBehavior.AllowGet);
            }
        }

        private string GetStrValueFromObject(object value)
        {
            if (value == null)
                return "";
            else if (value.GetType() == typeof(int))
                return value.ToString();
            else if (value.GetType() == typeof(decimal))
                return value.ToString().Replace(",", ".");
            else if (value.GetType() == typeof(double))
                return value.ToString().Replace(",", ".");
            else if (value.GetType() == typeof(DateTime))
                return ((DateTime)value).ToString("dd.MM.yyyy");
            else if (value.GetType() == typeof(bool))
                return ((bool)value).ToString();
            else
                return value.ToString();
        }

        public FileContentResult GetExcel()
        {
            var pauses = db.ServiceEngineer_Pause.ToArray();
            var items = (from one in db.ServiceEngineer_List.ToList()
                         join two in db.Documents.ToList() on one.DocumentId equals two.DocumentId
                         join three in db.DocumentAttributes.ToList() on one.DocumentId equals three.DocumentId
                         select (new
                         {
                             two.DocumentNumber,
                             TimeToCheckDocument = (new TimeSpan(0)).ToString(Counter.Lang.Resources.TimeSpanFormat),//.ToString(StandartLibrary.Lang.Resources.TimeSpanFormat), //Время на проверку
                             Defectlist_WaitingTimeToStartPreparation = (one.DefectList_StartDate != null && three.DisassembleFinish != null) ? (one.DefectList_StartDate.Value - three.DisassembleFinish.Value).ToString(Counter.Lang.Resources.TimeSpanFormat) : "",//.ToString(StandartLibrary.Lang.Resources.TimeSpanFormat) : "", //Время ожидания начала подготовки дефектовки
                             Defectlist_StartDate = one.DefectList_StartDate, //Дата начала дефектовки
                             Defectlist_TotalTimeSpent = one.DefectList_StartDate != null && one.DefectList_StopDate != null ? (one.DefectList_StopDate.Value - one.DefectList_StartDate.Value).ToString(Counter.Lang.Resources.TimeSpanFormat) : "",//.ToString(StandartLibrary.Lang.Resources.TimeSpanFormat) : "", //Общее время работы над дефектовкой
                             Defectlist_TheMainTimeSpent = one.DefectList_StartDate != null && one.DefectList_StopDate != null ? (one.DefectList_StopDate.Value - one.DefectList_StartDate.Value - new TimeSpan(pauses.Where(x => x.DocumentId == one.DocumentId && x.Type == 1 && x.StopDate != null).Sum(x => (x.StopDate.Value - x.StartDate).Ticks))).ToString(Counter.Lang.Resources.TimeSpanFormat) : "",//.ToString(StandartLibrary.Lang.Resources.TimeSpanFormat) : "", //Основное время работы над дефектовкой
                             Defectlist_TimePausesWork = new TimeSpan(pauses.Where(x => x.DocumentId == one.DocumentId && x.Type == 1 && x.StopDate != null).Sum(x => (x.StopDate.Value - x.StartDate).Ticks)).ToString(Counter.Lang.Resources.TimeSpanFormat),//.ToString(StandartLibrary.Lang.Resources.TimeSpanFormat), //Время пауз работы над дефектовкой
                             Defectlist_CausesOfPauses = string.Concat(pauses.Where(x => x.DocumentId == one.DocumentId && x.Type == 1 && x.StopDate != null).Select(x => x.Description)), //Причины пауз
                             UploadDateAdditionalWork = DateTime.Now, //Дата загрузки Additional work документа
                             Report_StartDate = one.PreparingOfReport_StartDate, //Дата начала отчета
                             Report_CompletionDate = one.PreparingOfReport_StopDate, //Дата завершения отчета
                             Report_TotalTimeSpent = one.PreparingOfReport_StartDate != null && one.PreparingOfReport_StopDate != null ? (one.PreparingOfReport_StopDate.Value - one.PreparingOfReport_StartDate.Value).ToString(Counter.Lang.Resources.TimeSpanFormat) : "",//.ToString(StandartLibrary.Lang.Resources.TimeSpanFormat) : "", //Общее время работы над отчетом
                             Report_CausesOfPauses = string.Concat(pauses.Where(x => x.DocumentId == one.DocumentId && x.Type == 2 && x.StopDate != null).Select(x => x.Description)), //Причины пауз
                             Defectlist_ReturnToRework = false, //Возврат на переделку дефектовки(yes or no)
                             Defectlist_TheReasonForRemaking = "", //Причина переделки дефектовки
                         })).ToList();
            var eP = new ExcelPackage();

            eP.Workbook.Properties.Title = @StandartLibrary.Lang.Resources.Report_5468;
            eP.Workbook.Properties.Company = "XXXXXXX";
            var sheet = eP.Workbook.Worksheets.Add(@StandartLibrary.Lang.Resources.Report_5468);
            var row = 1;
            var col = 1;

            sheet.Column(1).Width = 15;
            sheet.Cells[row, col].Value = Counter.Lang.Resources.Наряд;
            sheet.Column(2).Width = 21;
            sheet.Cells[row, col + 1].Value = Counter.Lang.Resources.ВремяОжиданияНачалаПодготовкиДефектовки;
            sheet.Column(3).Width = 24;
            sheet.Cells[row, col + 2].Value = Counter.Lang.Resources.ДатаНачалаДефектовки;
            sheet.Column(4).Width = 24;
            sheet.Cells[row, col + 3].Value = Counter.Lang.Resources.ОбщееВремяРаботыНадДефектовкой;
            sheet.Column(5).Width = 24;
            sheet.Cells[row, col + 4].Value = Counter.Lang.Resources.ОсновноеВремяРаботыНадДефектовкой;
            sheet.Column(6).Width = 25;
            sheet.Cells[row, col + 5].Value = Counter.Lang.Resources.ВремяПаузРаботыНадДефектовкой;
            sheet.Column(7).Width = 25;
            sheet.Cells[row, col + 6].Value = Counter.Lang.Resources.ПричиныПауз;
            sheet.Column(8).Width = 25;
            sheet.Cells[row, col + 7].Value = Counter.Lang.Resources.ДатаЗагрузкиAdditionalWorkДокумента;
            sheet.Column(9).Width = 23;
            sheet.Cells[row, col + 8].Value = Counter.Lang.Resources.ДатаНачалаОтчета;
            sheet.Column(10).Width = 23;
            sheet.Cells[row, col + 9].Value = Counter.Lang.Resources.ДатаЗавершенияОтчета;
            sheet.Column(11).Width = 25;
            sheet.Cells[row, col + 10].Value = Counter.Lang.Resources.ОбщееВремяРаботыНадОтчетом;
            sheet.Column(12).Width = 25;
            sheet.Cells[row, col + 11].Value = Counter.Lang.Resources.ПричиныПауз;
            sheet.Column(13).Width = 25;
            sheet.Cells[row, col + 12].Value = Counter.Lang.Resources.ВозвратНаПеределкуДефектовки;
            sheet.Column(14).Width = 25;
            sheet.Cells[row, col + 13].Value = Counter.Lang.Resources.ПричинаПеределкиДефектовки;
            sheet.Cells[row, col, row, col + 13].Style.Font.Bold = true;

            row++;
            foreach (var item in items)
            {
                sheet.Cells[row, col].Value = GetStrValueFromObject(item.DocumentNumber);
                sheet.Cells[row, col + 1].Value = GetStrValueFromObject(item.Defectlist_WaitingTimeToStartPreparation); //Время ожидания начала подготовки дефектовки
                sheet.Cells[row, col + 2].Value = GetStrValueFromObject(item.Defectlist_StartDate); //Дата начала дефектовки
                sheet.Cells[row, col + 3].Value = GetStrValueFromObject(item.Defectlist_TotalTimeSpent); //Общее время работы над дефектовкой
                sheet.Cells[row, col + 4].Value = GetStrValueFromObject(item.Defectlist_TheMainTimeSpent);  //Основное время работы над дефектовкой
                sheet.Cells[row, col + 5].Value = GetStrValueFromObject(item.Defectlist_TimePausesWork); //Время пауз работы над дефектовкой
                sheet.Cells[row, col + 6].Value = GetStrValueFromObject(item.Defectlist_CausesOfPauses); //Причины пауз
                sheet.Cells[row, col + 7].Value = GetStrValueFromObject(item.UploadDateAdditionalWork); //Дата загрузки Additional work документа
                sheet.Cells[row, col + 8].Value = GetStrValueFromObject(item.Report_StartDate); //Дата начала отчета
                sheet.Cells[row, col + 9].Value = GetStrValueFromObject(item.Report_CompletionDate); //Дата завершения отчета
                sheet.Cells[row, col + 10].Value = GetStrValueFromObject(item.Report_TotalTimeSpent); //Общее время работы над отчетом
                sheet.Cells[row, col + 11].Value = GetStrValueFromObject(item.Report_CausesOfPauses); //Причины пауз
                sheet.Cells[row, col + 12].Value = item.Defectlist_ReturnToRework ? StandartLibrary.Lang.Resources.Yes_5728 : ""; //Возврат на переделку дефектовки(yes or no)
                sheet.Cells[row, col + 13].Value = GetStrValueFromObject(item.Defectlist_TheReasonForRemaking); //Причина переделки дефектовки
                row++;
            }

            return File(eP.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", Counter.Lang.Resources.ПринятыеНаряды + DateTime.Now.ToString("yyyy_MM_dd_hh_ss") + ".xlsx");
        }
    }
}