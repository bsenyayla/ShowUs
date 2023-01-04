using OfficeOpenXml;
using SharedCRCMS.Models;
using SharedCRCMS.Service;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.Enums;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Counter.Controllers
{
    [Authorize]
    [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW)]
    public class UploadPartsStatusController : BaseController
    {
        private CRCMSEntities db = new CRCMSEntities();

        // GET: UploadPartsStatus
        public ActionResult Index()
        {
            return View("UploadPartsStatus");
        }

        public ActionResult UploadPartsStatus()
        {
            bool isSavedSuccessfully = true;
            try
            {
                var fileName = Request.Files[0].FileName;
                HttpPostedFileBase file = Request.Files[0];
                //Save file content goes here

                if (file != null && file.ContentLength > 0)
                {
                    using (var package = new ExcelPackage(file.InputStream))
                    {
                        var workbook = package.Workbook;
                        var worksheet = workbook.Worksheets["parts status"];

                        db.Configuration.AutoDetectChangesEnabled = false;
                        db.Configuration.ValidateOnSaveEnabled = false;

                        var lstInsert = new List<CounterPartsStatus>();
                        int lastRow = worksheet.Dimension.End.Row;
                        var rowNumber = 0;
                        var docs = db.Documents.ToList();
                        while (true)
                        {
                            rowNumber++;
                            if (rowNumber > lastRow)
                                break;
                            var newRow = new CounterPartsStatus();
                            try
                            {
                                var DocumentNumber = worksheet.Cells["A" + rowNumber.ToString()].Value.ToString();
                                if (DocumentNumber.Length == 0)
                                    continue;

                                var docItem = docs.SingleOrDefault(x => x.DocumentNumber != null && x.DocumentNumber.Trim('0') == DocumentNumber.Trim('0'));
                                if (docItem == null)
                                    continue;
                                newRow.DocumentId = docItem.DocumentId;
                                ExcelRange cell = null;
                                cell = worksheet.Cells["B" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    var sDate = cell.Value.ToString().Trim().Replace("\\", ".").Replace("/", ".");
                                    if (sDate.Length > 10)
                                        sDate = sDate.Substring(0, 10);
                                    var aDate = sDate.Split(new string[] { "." }, StringSplitOptions.None);
                                    newRow.OrderDate = new DateTime(int.Parse(aDate[2].Trim()), int.Parse(aDate[1].Trim()), int.Parse(aDate[0].Trim()));
                                }
                                cell = worksheet.Cells["C" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    newRow.Segment = int.Parse(cell.Value.ToString());
                                }
                                cell = worksheet.Cells["D" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    newRow.Name = cell.Value.ToString();
                                }
                                cell = worksheet.Cells["E" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    newRow.PartNumber = cell.Value.ToString();
                                }
                                cell = worksheet.Cells["F" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    newRow.Defect = decimal.Parse(cell.Value.ToString().Replace(".", ","));
                                }
                                cell = worksheet.Cells["G" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    newRow.Wait = decimal.Parse(cell.Value.ToString().Replace(".", ","));
                                }
                                cell = worksheet.Cells["H" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    newRow.InStock = decimal.Parse(cell.Value.ToString().Replace(".", ","));
                                }
                                cell = worksheet.Cells["I" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    newRow.InTransit = decimal.Parse(cell.Value.ToString().Replace(".", ","));
                                }
                                cell = worksheet.Cells["J" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    newRow.OrderKZ = decimal.Parse(cell.Value.ToString().Replace(".", ","));
                                }
                                cell = worksheet.Cells["K" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    newRow.OrderCAT = decimal.Parse(cell.Value.ToString().Replace(".", ","));
                                }
                                cell = worksheet.Cells["L" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    newRow.OrderTotal = decimal.Parse(cell.Value.ToString().Replace(".", ","));
                                }
                                cell = worksheet.Cells["M" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    newRow.Status = cell.Value.ToString();
                                }
                                cell = worksheet.Cells["N" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    newRow.SerialNumber = cell.Value.ToString();
                                }
                                cell = worksheet.Cells["O" + rowNumber.ToString()];
                                if (cell.Value != null && cell.Value.ToString().Length > 0)
                                {
                                    newRow.Component = cell.Value.ToString();
                                }
                            }
                            catch (Exception ex)
                            {
                                var ddd = 1;
                                ddd++;
                            }
                            lstInsert.Add(newRow);
                        }
                        db.Counter_PartsStatus.RemoveRange(db.Counter_PartsStatus);
                        db.Counter_PartsStatus.AddRange(lstInsert);

                        db.SaveChanges();
                        RecalcPartsStatus(db);
                    }
                }
            }
            catch (Exception ex)
            {
                var m = ex.Message;
                isSavedSuccessfully = false;
            }

            if (isSavedSuccessfully)
            {
                return Json(new { Status = "ok" });
            }
            else
            {
                return Json(new { Status = "error" });
            }
        }

        public static void RecalcPartsStatus(CRCMSEntities db, int documentId = 0)
        {
            var counterPartsStatusDocId = db.Counter_PartsStatus.Where(x => documentId == 0 || x.DocumentId == documentId).Select(x => x.DocumentId).Distinct().ToArray();
            var counterPartsStatus = db.Counter_PartsStatus.ToArray();
            var counterItems = db.Counter_List.Where(x => counterPartsStatusDocId.Contains(x.DocumentId));
            foreach (var docId in counterPartsStatusDocId)
            {
                var counterDoc = counterItems.FirstOrDefault(x => x.DocumentId == docId);
                if (counterDoc == null)
                    continue;
                var items = counterPartsStatus.Where(x => x.DocumentId == docId);
                var items2 = counterPartsStatus.Where(x => x.DocumentId == docId && x.Wait <= 0 || x.Wait <= x.InStock);
                if (items.Count() == items2.Count())
                {
                    counterDoc.InPartsOrdering_IsAllPartsInAvalible = true;
                    counterDoc.InPartsOrdering_AllPartsInAvalibleDate = DateTime.Now;
                    if (counterDoc.CounterStatusId == (int)CounterStatus.AnswerReceived)
                        counterDoc.CounterStatusId = (int)CounterStatus.Approved;
                }
                else
                {
                    counterDoc.InPartsOrdering_IsAllPartsInAvalible = null;
                    counterDoc.InPartsOrdering_AllPartsInAvalibleDate = null;
                    if (counterDoc.CounterStatusId == (int)CounterStatus.Approved)
                        counterDoc.CounterStatusId = (int)CounterStatus.AnswerReceived;
                }
            }
            db.SaveChanges();
        }
    }
}