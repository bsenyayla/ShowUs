using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.ViewModels;
using StandartLibrary.Models.ViewModels.Common;
using StandartLibrary.Models.ViewModels.Crcms;
using StandartLibrary.Models.ViewModels.Request;
using System;
using System.Collections.Generic;
using System.Linq;
using static StandartLibrary.Models.ViewModels.Crcms.StatisticView;

namespace CRCAPI.Services
{
    [TransientDependency(ServiceType = typeof(IStatisticService))]
    public class StatisticService : IStatisticService
    {
        private readonly IUnitOfWork<CrcmsDbContext> unitOfWork;
        private readonly IRedisCoreManager redisCoreManager;

        public StatisticService(IUnitOfWork<CrcmsDbContext> unitOfWork, IRedisCoreManager redisCoreManager) {
            this.unitOfWork = unitOfWork;
            this.redisCoreManager = redisCoreManager;
        }

        #region Total Component Count

        public TotalComponentGraphData GetTotalComponentData(StatisticRequest req) {
            TotalComponentGraphData retVal = new TotalComponentGraphData();

            var pureData = (from doc in unitOfWork.Context.Documents
                          join smsc in unitOfWork.Context.SMCSComponentGroups on doc.SmcsCode equals smsc.Code
                          join grp in unitOfWork.Context.Groups on smsc.GroupId equals grp.GroupId
                          join ri in unitOfWork.Context.ReceptionItem on doc.DocumentId equals ri.DocumentId
                          join re in unitOfWork.Context.Reception on ri.ReceptionId equals re.ReceptionId
                          where     doc.DispatchDate == null 
                                && re.ReceptionDate !=null
                                && new string[] { "Open", "Estimate" }.Contains(doc.USERSTATUS)
                                && (req.Group == "0" || req.Group == grp.GroupId.ToString())
                                && (req.Segment == "0" || req.Segment == doc.Segment)
                                //&& (doc.ArrivalMonth >= req.BeginDate && doc.ArrivalMonth <= req.EndDate)
                                && (re.ReceptionDate >= req.BeginDate && re.ReceptionDate <= req.EndDate)
                            select new {
                              GroupId   = grp.GroupId,
                              GroupName = grp.Name,
                              Segment   = doc.Segment,
                              SegmentText = doc.SegmentText,
                              Date      = re.ReceptionDate,
                              Year      = re.ReceptionDate.Year,
                              Month     = re.ReceptionDate.Month,
                              Day       = re.ReceptionDate.Day,
                          }).ToList();

            var tmpSegment = (from rpt in pureData
                              group rpt by new {
                                  rpt.SegmentText,
                                  rpt.Year,
                                  rpt.Month,
                                  rpt.Day
                              } into gcs
                              select new TotalNumberOfComponents {
                                  Name = gcs.Key.SegmentText,
                                  Date = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString().PadLeft(2, '0') + "-" + gcs.Key.Day.ToString().PadLeft(2,'0'),
                                  Count = gcs.Count()
                              } ).ToList();

            var tmpGroup = (from rpt in pureData
                            group rpt by new {
                                rpt.GroupName,
                                rpt.Year,
                                rpt.Month,
                                rpt.Day
                            } into gcs
                            select new TotalNumberOfComponents {
                                Name = gcs.Key.GroupName,
                                Date = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString().PadLeft(2, '0') + "-" + gcs.Key.Day.ToString().PadLeft(2, '0'),
                                Count = gcs.Count()
                            }).ToList();


            retVal.Total = (from rpt in pureData
                                  group rpt by new {
                                      rpt.Year,
                                      rpt.Month,
                                      rpt.Day
                                  } into gcs
                              orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
                              select new GraphicDataModel.GraphValue  {
                                  Key  = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString().PadLeft(2, '0') + "-" + gcs.Key.Day.ToString().PadLeft(2, '0'),
                                  Value = gcs.Count().ToString()
                              }
                             ).ToList();

            retVal.Segment = PrepareGraphData(tmpSegment);
            retVal.Group = PrepareGraphData(tmpGroup);
            retVal.TotalCount = pureData.Count().ToString();
            return retVal;
        }

        #endregion Total Component Count

        #region Output Count
        public OutputGraphData GetOutput(StatisticRequest req) {
            OutputGraphData retVal = new OutputGraphData();

            var pureData = (from doc in unitOfWork.Context.Documents
                          join smsc in unitOfWork.Context.SMCSComponentGroups on doc.SmcsCode equals smsc.Code
                          join grp in unitOfWork.Context.Groups on smsc.GroupId equals grp.GroupId
                          join ri in unitOfWork.Context.ReceptionItem on doc.DocumentId equals ri.DocumentId
                          join re in unitOfWork.Context.Reception on ri.ReceptionId equals re.ReceptionId
                            where doc.DispatchDate != null
                                && re.ReceptionDate != null
                                && (req.Group == "0" || req.Group == grp.GroupId.ToString())
                                && (req.Segment == "0" || req.Segment == doc.Segment)
                                //&& (doc.ArrivalMonth >= req.BeginDate && doc.ArrivalMonth <= req.EndDate)
                                && (re.ReceptionDate >= req.BeginDate && re.ReceptionDate <= req.EndDate)
                            select new {
                                GroupId = grp.GroupId,
                                GroupName = grp.Name,
                                Segment = doc.Segment,
                                SegmentText = doc.SegmentText,
                                Date = re.ReceptionDate,
                                Year = re.ReceptionDate.Year,
                                Month = re.ReceptionDate.Month,
                                Day = re.ReceptionDate.Day,
                            }).ToList();

            var tmpGroup = (from rpt in pureData
                            group rpt by new {
                                rpt.GroupName,
                                rpt.Year,
                                rpt.Month,
                                rpt.Day
                            } into gcs
                            orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
                            select new TotalNumberOfComponents {
                                Name = gcs.Key.GroupName,
                                Date = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString().PadLeft(2, '0') + "-" + gcs.Key.Day.ToString().PadLeft(2, '0'),
                                Count = gcs.Count()
                            }).ToList();


            var tmpSegment = (from rpt in pureData
                              group rpt by new {
                                  rpt.SegmentText,
                                  rpt.Year,
                                  rpt.Month,
                                  rpt.Day
                              } into gcs
                              orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
                              select new TotalNumberOfComponents {
                                  Name = gcs.Key.SegmentText,
                                  Date = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString().PadLeft(2, '0') + "-" + gcs.Key.Day.ToString().PadLeft(2, '0'),
                                  Count = gcs.Count()
                              }).ToList();

            retVal.Total = (from rpt in pureData
                            group rpt by new {
                                rpt.Year,
                                rpt.Month,
                                rpt.Day
                            } into gcs
                            orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
                            select new GraphicDataModel.GraphValue {
                                Key = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString().PadLeft(2, '0') + "-" + gcs.Key.Day.ToString().PadLeft(2, '0'),
                                Value = gcs.Count().ToString()
                            }
                 ).ToList();

            retVal.Group = PrepareGraphData(tmpGroup);
            retVal.Segment = PrepareGraphData(tmpSegment);

            retVal.TotalCount = retVal.Group.Count().ToString();

            return retVal;
        }

        

        


        #endregion Output Count

        #region Input Count
        public InputGraphData GetInput(StatisticRequest req) {
            InputGraphData retVal = new InputGraphData();
            var pureData = (from doc in unitOfWork.Context.Documents
                          join smsc in unitOfWork.Context.SMCSComponentGroups on doc.SmcsCode equals smsc.Code
                          join grp in unitOfWork.Context.Groups on smsc.GroupId equals grp.GroupId
                          join rei in unitOfWork.Context.ReceptionItem on doc.DocumentId equals rei.DocumentId
                          join re in unitOfWork.Context.Reception on rei.ReceptionId equals re.ReceptionId
                          where     doc.DispatchDate != null
                                && re.ReceptionDate != null
                                && (req.Group == "0" || req.Group == grp.GroupId.ToString())
                                && (req.Segment == "0" || req.Segment == doc.Segment)
                                //&& (doc.ArrivalMonth >= req.BeginDate && doc.ArrivalMonth <= req.EndDate)
                                && (re.ReceptionDate >= req.BeginDate && re.ReceptionDate <= req.EndDate)
                            select new  {
                              GroupId = grp.GroupId,
                              GroupName = grp.Name,
                              Segment=doc.Segment,
                              SegmentText=doc.SegmentText,
                              Date = re.ReceptionDate,
                              Year = re.ReceptionDate.Year,
                              Month = re.ReceptionDate.Month,
                              Day = re.ReceptionDate.Day,
                          }
              ).ToList();

            var tmpSegment = (from rpt in pureData
                        group rpt by new {
                            rpt.SegmentText,
                            rpt.Year,
                            rpt.Month,
                            rpt.Day
                        } into gcs
                              orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
                              select new TotalNumberOfComponents {
                            Name = gcs.Key.SegmentText,
                            Date = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString().PadLeft(2, '0') + "-" + gcs.Key.Day.ToString().PadLeft(2, '0'),
                            Count = gcs.Count()
                        }
                      ).ToList();
            
            var tmpGroup = (from rpt in pureData
                        group rpt by new {
                            rpt.GroupName,
                            rpt.Year,
                            rpt.Month,
                            rpt.Day
                        } into gcs
                            orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
                            select new TotalNumberOfComponents {
                            Name = gcs.Key.GroupName,
                            Date = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString().PadLeft(2, '0') + "-" + gcs.Key.Day.ToString().PadLeft(2, '0'),
                            Count = gcs.Count()
                        }
            ).ToList();

            retVal.Total = (from rpt in pureData
                            group rpt by new {
                                rpt.Year,
                                rpt.Month,
                                rpt.Day
                            } into gcs
                            orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
                            select new GraphicDataModel.GraphValue {
                                Key = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString().PadLeft(2, '0') + "-" + gcs.Key.Day.ToString().PadLeft(2, '0'),
                                Value = gcs.Count().ToString()
                            }).ToList();

            retVal.Segment = PrepareGraphData(tmpSegment);
            retVal.Group = PrepareGraphData(tmpGroup);
            retVal.TotalCount = pureData.Count().ToString();

            return retVal;
        }
        

        
        #endregion Input Count

        #region Süreç bazlı komponent sayısı
        public ProcessBasedGraphData GetProcessBased(StatisticRequest req) {
            ProcessBasedGraphData retVal = new ProcessBasedGraphData();

            var docRes1 = (from dat in unitOfWork.Context.DocumentAttributes
                           join pbs in unitOfWork.Context.PlanBoardStates on dat.ShortPlanStatusId equals pbs.ShortPlanStatusID
                           join doc in unitOfWork.Context.Documents on dat.DocumentId equals doc.DocumentId
                           join ri in unitOfWork.Context.ReceptionItem on doc.DocumentId equals ri.DocumentId
                           join dg in unitOfWork.Context.Groups on ri.GroupId equals dg.GroupId
                           where (req.Group == "0" || req.Group == dg.GroupId.ToString())
                                && (req.Segment == "0" || req.Segment == doc.Segment)
                                && (doc.ArrivalMonth >= req.BeginDate && doc.ArrivalMonth <= req.EndDate)
                           
                           select new {
                               ProcessStatu = (
                                   pbs.StatusNameEn == "Awaiting Wash" ? "Teklif Öncesi" :
                                   pbs.StatusNameEn == "Awaiting Disassemble" ? "Teklif Öncesi" :
                                   pbs.StatusNameEn == "Disassemble" ? "Teklif Öncesi" :
                                   pbs.StatusNameEn == "Awaiting Defect List" ? "Teklif Öncesi" :
                                   pbs.StatusNameEn == "Defect List" ? "Teklif Öncesi" :
                                   pbs.StatusNameEn == "Measurement In Process" ? "Teklif Öncesi" :
                                   pbs.StatusNameEn == "Awaiting Quotation" ? "Teklif" :
                                   pbs.StatusNameEn == "Awating Signed Quotation" ? "Teklif" :
                                   pbs.StatusNameEn == "Quotation" ? "Teklif" : "Teklif Sonrası"  ),
                               Group = dg.Name,
                               SegmentText = doc.SegmentText,
                               Date = doc.ArrivalMonth.Value.ToShortDateString()
                           }
                         ).ToList();


            var docRes = (from tbl in docRes1
                          group tbl by new {
                              tbl.ProcessStatu,
                              tbl.Date
                          } into gcs
                          orderby gcs.Key.ProcessStatu , gcs.Key.Date
                          select new StandartLibrary.Models.ViewModels.Crcms.StatisticView.TotalNumberOfComponents {
                              Name = gcs.Key.ProcessStatu,
                              Date = gcs.Key.Date,
                              Count = gcs.Count()
                          }
                      ).ToList();

            List<GraphicDataModel> compGrap = new List<GraphicDataModel>();

            var WorksKey = docRes.Select(x => x.Name).Distinct().ToList();
            var DatesKey = docRes.Select(x => x.Date).Distinct().ToList();

            foreach (string drDateKey in DatesKey) {
                List<string> usedKeyList = new List<string>();
                List<GraphicDataModel.GraphValue> grapValues = new List<GraphicDataModel.GraphValue>();

                var tmpDocList = docRes.Where(x => x.Date == drDateKey).ToList();
                foreach (TotalNumberOfComponents drDoc in tmpDocList) {
                    usedKeyList.Add(drDoc.Name);
                    grapValues.Add(new GraphicDataModel.GraphValue {
                        Key = drDoc.Name,
                        Value = drDoc.Count.ToString()
                    });
                }

                //Key listesinde olan ama datada olmayan keyler sıfır olarak eklenecek.
                foreach (string strKey in WorksKey) {
                    if (usedKeyList.Contains(strKey)) continue;

                    usedKeyList.Add(strKey);
                    grapValues.Add(new GraphicDataModel.GraphValue {
                        Key = strKey,
                        Value = "0"
                    });
                }
                compGrap.Add(new GraphicDataModel {
                    Date = drDateKey,
                    GraphValues = grapValues
                });
            }

            retVal.ProcessBasedData = compGrap;
            retVal.TotalCount = compGrap.Count().ToString();

            return retVal;
        }


        #endregion Süreç bazlı komponent sayısı

        #region Financial Status
        public FinancialGraphData GetFinancialStatus(StatisticRequest req) {
            FinancialGraphData retVal = new FinancialGraphData();

            var docRes = (from doc in unitOfWork.Context.Documents
                          join smsc in unitOfWork.Context.SMCSComponentGroups on doc.SmcsCode equals smsc.Code
                          join grp in unitOfWork.Context.Groups on smsc.GroupId equals grp.GroupId
                          join ri in unitOfWork.Context.ReceptionItem on doc.DocumentId equals ri.DocumentId
                          join re in unitOfWork.Context.Reception on ri.ReceptionId equals re.ReceptionId
                          where doc.DispatchDate != null 
                                &&  new string[] { "E0001", "E0003", "E0004", "E0005", "E0006", "E0007", "E0008", "E0010", "E0009" }.Contains(doc.QuotationDocStatus)
                                && (req.Group == "0" || req.Group == grp.GroupId.ToString())
                                && (req.Segment == "0" || req.Segment == doc.Segment)
                                //&& (doc.ArrivalMonth >= req.BeginDate && doc.ArrivalMonth <= req.EndDate)
                                && (re.ReceptionDate >= req.BeginDate && re.ReceptionDate <= req.EndDate)

                          group doc by new {
                              doc.QuotationDocStatus,
                              doc.QuotationDocStatusText,
                              doc.QuotationCurrency
                          } into gcs
                          orderby gcs.Key.QuotationDocStatusText
                          select new StatisticView.TotalNumberOfComponents {
                              Date = gcs.Key.QuotationDocStatusText.Trim(),
                              Name = gcs.Key.QuotationCurrency,
                              Count = (int)gcs.Sum(x => x.QuotationAmount.Value)
                          }
                          ).ToList();


            List<GraphicDataModel> compGrap = new List<GraphicDataModel>();

            var WorksKey = docRes.Select(x => x.Name).Distinct().ToList();
            var DatesKey = docRes.Select(x => x.Date).Distinct().ToList();

            foreach (string drDateKey in DatesKey) {
                List<string> usedKeyList = new List<string>();
                List<GraphicDataModel.GraphValue> grapValues = new List<GraphicDataModel.GraphValue>();


                var tmpDocList = docRes.Where(x => x.Date == drDateKey).ToList();
                foreach (TotalNumberOfComponents drDoc in tmpDocList) {
                    usedKeyList.Add(drDoc.Name);
                    grapValues.Add(new GraphicDataModel.GraphValue {
                        Key = drDoc.Name,
                        Value = drDoc.Count.ToString()
                    });
                }

                //Key listesinde olan ama datada olmayan keyler sıfır olarak eklenecek.
                foreach (string strKey in WorksKey) {
                    if (usedKeyList.Contains(strKey)) continue;

                    usedKeyList.Add(strKey);
                    grapValues.Add(new GraphicDataModel.GraphValue {
                        Key = strKey,
                        Value = "0"
                    });
                }
                compGrap.Add(new GraphicDataModel {
                    Date = drDateKey,
                    GraphValues = grapValues
                });
            }

            retVal.FinancialGraphValues = compGrap;
            retVal.InvoicedCount = "9,455.00";
            retVal.NotInvoicedCount = "0";
            return retVal;


        }

        #endregion Financial Status

        #region CRC Request Count
        public CRCRequestGraphData GetCRCRequestCount(StatisticRequest req) {
            CRCRequestGraphData retVal = new CRCRequestGraphData();


            List<GraphicDataModel.GraphValue> docRes =
                                      (from rc in
                                           (
                                                (from rc in unitOfWork.Context.CrcRequest
                                                 join co in unitOfWork.Context.CrcRequestComponent on rc.RequestId equals co.CrcRequestId into crcGrop
                                                 from crc in crcGrop.DefaultIfEmpty()
                                                 join t in (

                                                               from ri in unitOfWork.Context.ReceptionItem
                                                               join doc in unitOfWork.Context.Documents on ri.DocumentId equals doc.DocumentId
                                                               join smsc in unitOfWork.Context.SMCSComponentGroups on doc.SmcsCode equals smsc.Code
                                                               join grp in unitOfWork.Context.Groups on smsc.GroupId equals grp.GroupId
                                                               select new { ri, doc, grp.GroupId }
                                                            ) on crc.CrcRequestComponentId equals t.ri.RequestComponentId into documentGRoup
                                                 from docGrp in documentGRoup.DefaultIfEmpty()

                                                 where req.BeginDate <= rc.CreateDate
                                                         && req.EndDate >= rc.CreateDate
                                                 && (req.Group == "0" || req.Group == docGrp.GroupId.ToString())
                                                 && (req.Segment == "0" || req.Segment == docGrp.doc.Segment)
                                                 select rc).Distinct())
                                       group rc by new {
                                           rc.CreateDate.Value.Year,
                                           rc.CreateDate.Value.Month,
                                           rc.CreateDate.Value.Day
                                       } into gcs
                                       orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
                                       select new GraphicDataModel.GraphValue {
                                           Key = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString().PadLeft(2, '0') + "-" + gcs.Key.Day.ToString().PadLeft(2, '0'),
                                           Value = gcs.Count().ToString()
                                       }).ToList();
            
            retVal.CrcRequestGraphValues = docRes;
            retVal.TotalCount = docRes.Count().ToString();

            return retVal;
        }
        #endregion CRC Request Count

        #region TAT
        public TatGraphData GetTatData(StatisticRequest req) {
            TatGraphData retTatData = new TatGraphData();

            var pureData = (from d in unitOfWork.Context.Documents
                            join m in unitOfWork.Context.Models on d.ModelId equals m.ModelId
                            join da in unitOfWork.Context.DocumentAttributesDispatches on d.DocumentId equals da.DocumentId
                            join cl in unitOfWork.Context.CounterLists on d.DocumentId equals cl.DocumentId into subCounter
                            from subCl in subCounter.DefaultIfEmpty()
                            join co in (from cox in unitOfWork.Context.CounterOrderedParts
                                        group cox by cox.DocumentId into grpOrder
                                        select new {
                                            DocumentId = grpOrder.Key,
                                            PartsSellingDate = grpOrder.Max(y => y.CreateDate),
                                            PartsStockDate = grpOrder.Max(y => y.DateStock),
                                            PartsSalesDate = grpOrder.Min(y => y.PartOrderCreateDate)
                                        }) on d.DocumentId equals co.DocumentId into subParts
                            from sub in subParts.DefaultIfEmpty()
                            join g in unitOfWork.Context.Groups on da.GroupId equals g.GroupId
                            join ri in unitOfWork.Context.ReceptionItem on d.DocumentId equals ri.DocumentId into dri
                            from ri in dri.DefaultIfEmpty()
                            join cr in unitOfWork.Context.CrcRequestComponent on ri.RequestComponentId equals cr.CrcRequestComponentId into dcr
                            from cr in dcr.DefaultIfEmpty()
                            join car in unitOfWork.Context.CrcArrivalReasons on cr.ComponentArrivalReason equals car.ArrivalReasonOrder into crcar
                            from car in crcar.DefaultIfEmpty()
                            where d.DispatchDate != null
                                && (req.Group == "0" || req.Group == g.GroupId.ToString())
                                && (req.Segment == "0" || req.Segment == d.Segment)
                                && (d.ArrivalMonth >= req.BeginDate && d.ArrivalMonth <= req.EndDate)

                            select new TatViewModelSecond {
                                DispatchDate = da.DispatchDate,
                                HasTest = da.HasTest ?? false,
                                DocumentId = d.DocumentId,
                                Segment = d.SegmentText,
                                City = (from rix in unitOfWork.Context.ReceptionItem
                                        join rm in unitOfWork.Context.Reception on rix.ReceptionId equals rm.ReceptionId
                                        where rix.ReceptionItemId ==
                                        (from ri in unitOfWork.Context.ReceptionItem
                                         where ri.DocumentId == d.DocumentId
                                         select ri.ReceptionItemId).FirstOrDefault()
                                        select rm.City).FirstOrDefault(),
                                MachineSerialNo = d.MachinesSN,
                                MachineModel = m.Name,
                                ComponentArrivalReasonId = car != null ? car.ArrivalReasonOrder : 0,
                                ComponentArrivalReason = car != null ? car.Name : string.Empty,
                                Workshop = g.Name,
                                CustomerName = d.Customer.Name,
                                DocumentNumber = d.DocumentNumber,
                                ArrivalDate = d.ArrivalMonth ?? DateTime.Now,
                                DisassembleDateStartActual = da.DisassembleStart,
                                DisassembleDateEndActual = da.DisassembleFinish,
                                ExpertiseDateActual = da.DefectListDate,
                                ProposalDateActual = subCl != null ? subCl.PreparingQuotation_CompletedDate : null,
                                ProposalApproveDateActual = subCl != null ? subCl.CustomerApproval_ApprovedDate : null,
                                PartsSellingDate = sub != null ? sub.PartsSellingDate : null,
                                ProposalDateStart = subCl != null ? subCl.PreparingQuotation_StartDate : null,
                                //QuotationAnswerDate = subCl != null ? (subCl.CounterStatusId == (int)CounterStatus.QuotationRejected ? subCl.CustomerApproval_AnswerReceivedDate : (DateTime?)null) : (DateTime?)null,
                                AssemblyStartDateActual = (
                                                            g.GroupId == (int)StandartLibrary.Models.Enums.Group.Engine ?
                                                            (
                                                                (from m in unitOfWork.Context.Timers
                                                                 where m.DocumentId == d.DocumentId
                                                                 &&
                                                                    (
                                                                        (from a in unitOfWork.Context.Areas
                                                                         where a.Segment == (int)StandartLibrary.Models.Enums.AreaSegment.ShortBlockAssembly
                                                                             && a.GroupId == g.GroupId
                                                                         select a.AreaId)).Contains(m.AreaId)
                                                                 select m.DateStart).Any() ? (from m in unitOfWork.Context.Timers
                                                                                              where m.DocumentId == d.DocumentId
                                                                                              &&
                                                                                                 (
                                                                                                     (from a in unitOfWork.Context.Areas
                                                                                                      where a.Segment == (int)StandartLibrary.Models.Enums.AreaSegment.ShortBlockAssembly
                                                                                                          && a.GroupId == g.GroupId
                                                                                                      select a.AreaId)).Contains(m.AreaId)
                                                                                              select m.DateStart).Min() : da.AssembleStart)
                                                                : (
                                                            (from m in unitOfWork.Context.Timers
                                                             where m.DocumentId == d.DocumentId
                                                             &&
                                                                (
                                                                    (from a in unitOfWork.Context.Areas
                                                                     where a.Segment != (int)StandartLibrary.Models.Enums.AreaSegment.ShortBlockAssembly
                                                                         && a.GroupId != (int)StandartLibrary.Models.Enums.Group.Engine
                                                                     select a.AreaId)).Contains(m.AreaId)
                                                             select m.DateStart).Any() ? (from m in unitOfWork.Context.Timers
                                                                                          where m.DocumentId == d.DocumentId
                                                                                          &&
                                                                                             (
                                                                                                 (from a in unitOfWork.Context.Areas
                                                                                                  where a.Segment != (int)StandartLibrary.Models.Enums.AreaSegment.ShortBlockAssembly
                                                                                                      && a.GroupId != (int)StandartLibrary.Models.Enums.Group.Engine
                                                                                                  select a.AreaId)).Contains(m.AreaId)
                                                                                          select m.DateStart).FirstOrDefault() : da.AssembleStart)
                                                            ),
                                AssemblyEndDateActual = da.AssembleFinish,

                                TestDateActual = da.TestStart,
                                //CompletionDateExpected = da.TestFinish,
                                TestFinishDate = da.TestFinish,
                                PaintingDateActual = da.PaintStart,
                                PaintingDateEnd = da.PaintFinish,
                                PartsCompletionDate = sub != null ? sub.PartsStockDate : null
                                //PartsWaitingtime = sub != null ? ((sub.PartsStockDate.HasValue && sub.PartsSellingDate.HasValue) ? DbFunctions.DiffDays(sub.PartsSellingDate.Value, sub.PartsStockDate.Value) : (double?)null) : (double?)null
                            }
                            ).ToList();


            retTatData.TotalCount = pureData.Count().ToString();

            retTatData.TatSegmentData = (from tbl in pureData
                                         group tbl by new {
                                             tbl.Segment
                                         } into gcs
                                         select new TatGraphData.TatGraphValue {
                                             Key = gcs.Key.Segment,
                                             CompetionValue = (gcs.Sum(x => x.TatCompletionActual) / gcs.Count()).ToString("F"),
                                             ProposalValue = (gcs.Sum(x => x.ProposalTatActual) / gcs.Count()).ToString("F")
                                         }
          ).ToList();

            retTatData.TatWorkshopData = (from tbl in pureData
                                          group tbl by new {
                                              tbl.Workshop
                                          } into gcs
                                          select new TatGraphData.TatGraphValue {
                                              Key = gcs.Key.Workshop,
                                              CompetionValue = (gcs.Sum(x => x.TatCompletionActual) / gcs.Count()).ToString("F"),
                                              ProposalValue = (gcs.Sum(x => x.ProposalTatActual) / gcs.Count()).ToString("F")
                                          }
          ).ToList();


            retTatData.TatDateAverageData = (from tbl in pureData
                                             group tbl by new {
                                                 tbl.DispatchDate,
                                                 tbl.ProposalTatActual,
                                                 tbl.TatCompletionActual
                                             } into gcs
                                             orderby gcs.Key.DispatchDate
                                             select new TatGraphData.TatGraphValue {
                                                 Key = gcs.Key.DispatchDate.Value.ToShortDateString(),
                                                 CompetionValue = (gcs.Sum(x => x.TatCompletionActual) / gcs.Count()).ToString("F"),
                                                 ProposalValue = (gcs.Sum(x => x.ProposalTatActual) / gcs.Count()).ToString("F")
                                             }
              ).ToList();


            /*
                ProposalTatActual=Gerçekleşen teklif  tat
                TatCompetionActual=gerçekşelen bitiş tat
             */


            return retTatData;
        }
        #endregion TAT

        #region Capacity
        public CapacityGraphData GetCapacityOccupancyData(StatisticRequest req) {
            CapacityGraphData retVal = new CapacityGraphData();

            var userCount = (from usr in unitOfWork.Context.Users
                             where usr.IsActive == true
                             && usr.EmployeeTypeId == 1
                             group usr by new {
                                 usr.GroupId
                             } into gcs

                             select new {
                                 GroupId = gcs.Key.GroupId,
                                 Count = gcs.Count()
                             }
                            );

            var sevkBisi =
                          from doc in unitOfWork.Context.Documents
                              join smsc in unitOfWork.Context.SMCSComponentGroups on doc.SmcsCode equals smsc.Code
                              join grp in unitOfWork.Context.Groups on smsc.GroupId equals grp.GroupId
                          join cm in unitOfWork.Context.SMCSComponents on doc.SmcsCode equals cm.Code


                          where doc.DispatchDate != null
                          && (req.Group=="0" || req.Group==grp.GroupId.ToString())
                          && (req.Segment=="0" || req.Segment==doc.Segment)
                          && (doc.DispatchDate >= req.BeginDate && doc.DispatchDate <= req.EndDate)


                          group doc by new {
                              doc.SmcsCode

                          } into gcs
                          select new {
                              Key = gcs.Key.SmcsCode,
                              Value = gcs.Count()
                          };

           var capacity = (
                            from cap in unitOfWork.Context.CapacityCalcConsts
                            join usr in userCount on cap.GroupId equals usr.GroupId
                            join svk in sevkBisi on cap.ComponentCode equals svk.Key into svkGrp
                            from svk in svkGrp.DefaultIfEmpty()
                            select new {
                                cap.GroupId,
                                cap.Process,
                                cap.ComponentCode,
                                UserCount = usr.Count,
                                UserRatio_1 = cap.TechDay / usr.Count,
                                UserRatio_2 = Math.Round(20 / (cap.TechDay / usr.Count), 2),
                                UserRatio_3 = Math.Round(20 / (cap.TechDay / usr.Count), 2),
                                UserRatio_P = 100 / Math.Round(20 / (cap.TechDay / usr.Count), 2),
                                DispatchedDocCount = (svk != null ? svk.Value : 0),
                                CapacityOccupancyRatio = (100 / Math.Round(20 / (cap.TechDay / usr.Count), 2) * (svk != null ? svk.Value : 0))
                            }).ToList();


            decimal avgCapacity = capacity.Select(x => x.CapacityOccupancyRatio).Average();
            retVal.CapacityRatio = avgCapacity.ToString("F");


            retVal.ProcessGraphValues = (from rpt in capacity
                                         select new GraphicDataModel.GraphValue {
                                             Key = rpt.Process,
                                             Value = rpt.CapacityOccupancyRatio.ToString("F")
                                         }).ToList();

            retVal.GroupGraphValues = (from ii in capacity
                                       group ii by new {
                                           ii.GroupId
                                       } into gcs
                                       select new GraphicDataModel.GraphValue {
                                           Key = unitOfWork.Context.Groups.Where(x => x.GroupId == gcs.Key.GroupId).Select(x => x.Name).FirstOrDefault(),
                                           Value = gcs.Average(x => x.CapacityOccupancyRatio).ToString("F")
                                       }
                                        ).ToList();
            return retVal;
        }
        #endregion Capacity

        private List<GraphicDataModel> PrepareGraphData(List<StatisticView.TotalNumberOfComponents> docRes) {
            List<GraphicDataModel> compGrap = new List<GraphicDataModel>();
            var WorksKey = docRes.Select(x => x.Name).Distinct().ToList();
            var DatesKey = docRes.Select(x => x.Date).Distinct().ToList();

            foreach (string drDateKey in DatesKey) {
                List<string> usedKeyList = new List<string>();
                List<GraphicDataModel.GraphValue> grapValues = new List<GraphicDataModel.GraphValue>();


                var tmpDocList = docRes.Where(x => x.Date == drDateKey).ToList();
                foreach (TotalNumberOfComponents drDoc in tmpDocList) {
                    usedKeyList.Add(drDoc.Name);
                    grapValues.Add(new GraphicDataModel.GraphValue {
                        Key = drDoc.Name,
                        Value = drDoc.Count.ToString()
                    });
                }

                //Key listesinde olan ama datada olmayan keyler sıfır olarak eklenecek.
                foreach (string strKey in WorksKey) {
                    if (usedKeyList.Contains(strKey)) continue;
                    usedKeyList.Add(strKey);
                    grapValues.Add(new GraphicDataModel.GraphValue {
                        Key = strKey,
                        Value = "0"
                    });
                }
                compGrap.Add(new GraphicDataModel {
                    Date = drDateKey,
                    GraphValues = grapValues
                });
            }
            return compGrap;
        }

        //public List<GraphicDataModel> GetInputCountForSegment(StatisticRequest req) {
        //    var docRes = (from doc in unitOfWork.Context.Documents
        //                  join rei in unitOfWork.Context.ReceptionItem on doc.DocumentId equals rei.DocumentId
        //                  join rec in unitOfWork.Context.Reception on rei.ReceptionId equals rec.ReceptionId
        //                  where doc.DispatchDate != null

        //                  group doc by new {
        //                      doc.SegmentText,
        //                      rec.ReceptionDate.Year,
        //                      rec.ReceptionDate.Month,
        //                      rec.ReceptionDate.Day
        //                  } into gcs
        //                  orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
        //                  select new StandartLibrary.Models.ViewModels.Crcms.StatisticView.TotalNumberOfComponents {
        //                      Name = gcs.Key.SegmentText,
        //                      Date = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString() + "-" + gcs.Key.Day.ToString(),
        //                      Count = gcs.Count()
        //                  }

        //                  ).ToList();

        //    List<GraphicDataModel> compGrap = new List<GraphicDataModel>();

        //    var WorksKey = docRes.Select(x => x.Name).Distinct().ToList();
        //    var DatesKey = docRes.Select(x => x.Date).Distinct().ToList();

        //    foreach (string drDateKey in DatesKey) {
        //        List<string> usedKeyList = new List<string>();
        //        List<GraphicDataModel.GraphValue> grapValues = new List<GraphicDataModel.GraphValue>();


        //        var tmpDocList = docRes.Where(x => x.Date == drDateKey).ToList();
        //        foreach (TotalNumberOfComponents drDoc in tmpDocList) {
        //            usedKeyList.Add(drDoc.Name);
        //            grapValues.Add(new GraphicDataModel.GraphValue {
        //                Key = drDoc.Name,
        //                Value = drDoc.Count.ToString()
        //            });
        //        }

        //        //Key listesinde olan ama datada olmayan keyler sıfır olarak eklenecek.
        //        foreach (string strKey in WorksKey) {
        //            if (usedKeyList.Contains(strKey)) continue;
        //            usedKeyList.Add(strKey);
        //            grapValues.Add(new GraphicDataModel.GraphValue {
        //                Key = strKey,
        //                Value = "0"
        //            });
        //        }
        //        compGrap.Add(new GraphicDataModel {
        //            Date = drDateKey,
        //            GraphValues = grapValues
        //        });
        //    }
        //    return compGrap;
        //}

        //public List<GraphicDataModel> GetInputCountForGroup(StatisticRequest req) {
        //    var docRes = (from doc in unitOfWork.Context.Documents
        //                  join smsc in unitOfWork.Context.SMCSComponentGroups on doc.SmcsCode equals smsc.Code
        //                  join grp in unitOfWork.Context.Groups on smsc.GroupId equals grp.GroupId
        //                  join rei in unitOfWork.Context.ReceptionItem on doc.DocumentId equals rei.DocumentId
        //                  join rec in unitOfWork.Context.Reception on rei.ReceptionId equals rec.ReceptionId
        //                  where doc.DispatchDate != null
        //                  group grp by new {
        //                      grp.Name,
        //                      rec.ReceptionDate.Year,
        //                      rec.ReceptionDate.Month,
        //                      rec.ReceptionDate.Day
        //                  } into gcs
        //                  orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
        //                  select new StandartLibrary.Models.ViewModels.Crcms.StatisticView.TotalNumberOfComponents {
        //                      Name = gcs.Key.Name.Trim(),
        //                      Date = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString() + "-" + gcs.Key.Day.ToString(),
        //                      Count = gcs.Count()
        //                  }

        //                  ).ToList();

        //    List<GraphicDataModel> compGrap = new List<GraphicDataModel>();

        //    var WorksKey = docRes.Select(x => x.Name).Distinct().ToList();
        //    var DatesKey = docRes.Select(x => x.Date).Distinct().ToList();

        //    foreach (string drDateKey in DatesKey) {
        //        List<string> usedKeyList = new List<string>();
        //        List<GraphicDataModel.GraphValue> grapValues = new List<GraphicDataModel.GraphValue>();


        //        var tmpDocList = docRes.Where(x => x.Date == drDateKey).ToList();
        //        foreach (TotalNumberOfComponents drDoc in tmpDocList) {
        //            usedKeyList.Add(drDoc.Name);
        //            grapValues.Add(new GraphicDataModel.GraphValue {
        //                Key = drDoc.Name,
        //                Value = drDoc.Count.ToString()
        //            });
        //        }

        //        //Key listesinde olan ama datada olmayan keyler sıfır olarak eklenecek.
        //        foreach (string strKey in WorksKey) {
        //            if (usedKeyList.Contains(strKey)) continue;

        //            usedKeyList.Add(strKey);
        //            grapValues.Add(new GraphicDataModel.GraphValue {
        //                Key = strKey,
        //                Value = "0"
        //            });
        //        }
        //        compGrap.Add(new GraphicDataModel {
        //            Date = drDateKey,
        //            GraphValues = grapValues
        //        });
        //    }
        //    return compGrap;
        //}
        //public List<GraphicDataModel> GetTotalComponentCountForComponentGroup(StatisticRequest req) {
        //    var docRes = (from doc in unitOfWork.Context.Documents
        //                  join smsc in unitOfWork.Context.SMCSComponentGroups on doc.SmcsCode equals smsc.Code
        //                  join grp in unitOfWork.Context.Groups on smsc.GroupId equals grp.GroupId
        //                  where doc.DispatchDate != null &&
        //                        new string[] { "Open", "Estimate" }.Contains(doc.USERSTATUS)

        //                  group grp by new {
        //                      grp.Name,
        //                      doc.DocumentCreateDate.Value.Year,
        //                      doc.DocumentCreateDate.Value.Month,
        //                      doc.DocumentCreateDate.Value.Day
        //                  } into gcs
        //                  orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
        //                  select new StandartLibrary.Models.ViewModels.Crcms.StatisticView.TotalNumberOfComponents {
        //                      Name = gcs.Key.Name.Trim(),
        //                      Date = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString() + "-" + gcs.Key.Day.ToString(),
        //                      Count = gcs.Count()
        //                  }

        //                  ).ToList();

        //    List<GraphicDataModel> compGrap = new List<GraphicDataModel>();

        //    var WorksKey = docRes.Select(x => x.Name).Distinct().ToList();
        //    var DatesKey = docRes.Select(x => x.Date).Distinct().ToList();

        //    foreach (string drDateKey in DatesKey) {
        //        List<string> usedKeyList = new List<string>();
        //        List<GraphicDataModel.GraphValue> grapValues = new List<GraphicDataModel.GraphValue>();


        //        var tmpDocList = docRes.Where(x => x.Date == drDateKey).ToList();
        //        foreach (TotalNumberOfComponents drDoc in tmpDocList) {
        //            usedKeyList.Add(drDoc.Name);
        //            grapValues.Add(new GraphicDataModel.GraphValue {
        //                Key = drDoc.Name,
        //                Value = drDoc.Count.ToString()
        //            });
        //        }

        //        //Key listesinde olan ama datada olmayan keyler sıfır olarak eklenecek.
        //        foreach (string strKey in WorksKey) {
        //            if (usedKeyList.Contains(strKey)) continue;

        //            usedKeyList.Add(strKey);
        //            grapValues.Add(new GraphicDataModel.GraphValue {
        //                Key = strKey,
        //                Value = "0"
        //            });
        //        }
        //        compGrap.Add(new GraphicDataModel {
        //            Date = drDateKey,
        //            GraphValues = grapValues
        //        });
        //    }
        //    return compGrap;
        //}

        //public List<GraphicDataModel> GetTotalComponentCountForSegment(StatisticRequest req) {
        //    var docRes = (from doc in unitOfWork.Context.Documents
        //                  where doc.DispatchDate != null &&
        //                        new string[] { "Open", "Estimate" }.Contains(doc.USERSTATUS)

        //                  group doc by new {
        //                      doc.SegmentText,
        //                      doc.DocumentCreateDate.Value.Year,
        //                      doc.DocumentCreateDate.Value.Month,
        //                      doc.DocumentCreateDate.Value.Day
        //                  } into gcs
        //                  orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
        //                  select new StandartLibrary.Models.ViewModels.Crcms.StatisticView.TotalNumberOfComponents {
        //                      Name = gcs.Key.SegmentText,
        //                      Date = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString() + "-" + gcs.Key.Day.ToString(),
        //                      Count = gcs.Count()
        //                  }

        //                  ).ToList();

        //    List<GraphicDataModel> compGrap = new List<GraphicDataModel>();

        //    var WorksKey = docRes.Select(x => x.Name).Distinct().ToList();
        //    var DatesKey = docRes.Select(x => x.Date).Distinct().ToList();

        //    foreach (string drDateKey in DatesKey) {
        //        List<string> usedKeyList = new List<string>();
        //        List<GraphicDataModel.GraphValue> grapValues = new List<GraphicDataModel.GraphValue>();


        //        var tmpDocList = docRes.Where(x => x.Date == drDateKey).ToList();
        //        foreach (TotalNumberOfComponents drDoc in tmpDocList) {
        //            usedKeyList.Add(drDoc.Name);
        //            grapValues.Add(new GraphicDataModel.GraphValue {
        //                Key = drDoc.Name,
        //                Value = drDoc.Count.ToString()
        //            });
        //        }

        //        //Key listesinde olan ama datada olmayan keyler sıfır olarak eklenecek.
        //        foreach (string strKey in WorksKey) {
        //            if (usedKeyList.Contains(strKey)) continue;

        //            usedKeyList.Add(strKey);
        //            grapValues.Add(new GraphicDataModel.GraphValue {
        //                Key = strKey,
        //                Value = "0"
        //            });
        //        }
        //        compGrap.Add(new GraphicDataModel {
        //            Date = drDateKey,
        //            GraphValues = grapValues
        //        });
        //    }
        //    return compGrap;
        //}

        //private List<GraphicDataModel> GetOutputForGroup(StatisticRequest req) {
        //    var docRes = (from doc in unitOfWork.Context.Documents
        //                  join smsc in unitOfWork.Context.SMCSComponentGroups on doc.SmcsCode equals smsc.Code
        //                  join grp in unitOfWork.Context.Groups on smsc.GroupId equals grp.GroupId
        //                  where doc.DispatchDate != null
        //                        && (req.Group == "0" || req.Group == grp.GroupId.ToString())
        //                        && (req.Segment == "0" || req.Segment == doc.Segment)
        //                        && (doc.DispatchDate >= req.BeginDate && doc.DispatchDate <= req.EndDate)
        //                  group grp by new {
        //                      grp.Name,
        //                      doc.DocumentCreateDate.Value.Year,
        //                      doc.DocumentCreateDate.Value.Month,
        //                      doc.DocumentCreateDate.Value.Day
        //                  } into gcs
        //                  orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
        //                  select new StatisticView.TotalNumberOfComponents {
        //                      Name = gcs.Key.Name.Trim(),
        //                      Date = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString() + "-" + gcs.Key.Day.ToString(),
        //                      Count = gcs.Count()
        //                  }
        //                  ).ToList();

        //    List<GraphicDataModel> compGrap = new List<GraphicDataModel>();

        //    var WorksKey = docRes.Select(x => x.Name).Distinct().ToList();
        //    var DatesKey = docRes.Select(x => x.Date).Distinct().ToList();

        //    foreach (string drDateKey in DatesKey) {
        //        List<string> usedKeyList = new List<string>();
        //        List<GraphicDataModel.GraphValue> grapValues = new List<GraphicDataModel.GraphValue>();


        //        var tmpDocList = docRes.Where(x => x.Date == drDateKey).ToList();
        //        foreach (TotalNumberOfComponents drDoc in tmpDocList) {
        //            usedKeyList.Add(drDoc.Name);
        //            grapValues.Add(new GraphicDataModel.GraphValue {
        //                Key = drDoc.Name,
        //                Value = drDoc.Count.ToString()
        //            });
        //        }

        //        //Key listesinde olan ama datada olmayan keyler sıfır olarak eklenecek.
        //        foreach (string strKey in WorksKey) {
        //            if (usedKeyList.Contains(strKey)) continue;

        //            usedKeyList.Add(strKey);
        //            grapValues.Add(new GraphicDataModel.GraphValue {
        //                Key = strKey,
        //                Value = "0"
        //            });
        //        }
        //        compGrap.Add(new GraphicDataModel {
        //            Date = drDateKey,
        //            GraphValues = grapValues
        //        });
        //    }
        //    return compGrap;
        //}

        //private List<GraphicDataModel> GetOutputForSegment(StatisticRequest req) {
        //    var docRes = (from doc in unitOfWork.Context.Documents
        //                  where doc.DispatchDate != null
        //                        && (req.Segment == "0" || req.Segment == doc.Segment)
        //                        && (doc.DispatchDate >= req.BeginDate && doc.DispatchDate <= req.EndDate)
        //                  group doc by new {
        //                      doc.SegmentText,
        //                      doc.DocumentCreateDate.Value.Year,
        //                      doc.DocumentCreateDate.Value.Month,
        //                      doc.DocumentCreateDate.Value.Day
        //                  } into gcs
        //                  orderby gcs.Key.Year, gcs.Key.Month, gcs.Key.Day
        //                  select new StatisticView.TotalNumberOfComponents {
        //                      Name = gcs.Key.SegmentText,
        //                      Date = gcs.Key.Year.ToString() + "-" + gcs.Key.Month.ToString() + "-" + gcs.Key.Day.ToString(),
        //                      Count = gcs.Count()
        //                  }

        //                  ).ToList();

        //    List<GraphicDataModel> compGrap = new List<GraphicDataModel>();

        //    var WorksKey = docRes.Select(x => x.Name).Distinct().ToList();
        //    var DatesKey = docRes.Select(x => x.Date).Distinct().ToList();

        //    foreach (string drDateKey in DatesKey) {
        //        List<string> usedKeyList = new List<string>();
        //        List<GraphicDataModel.GraphValue> grapValues = new List<GraphicDataModel.GraphValue>();


        //        var tmpDocList = docRes.Where(x => x.Date == drDateKey).ToList();
        //        foreach (TotalNumberOfComponents drDoc in tmpDocList) {
        //            usedKeyList.Add(drDoc.Name);
        //            grapValues.Add(new GraphicDataModel.GraphValue {
        //                Key = drDoc.Name,
        //                Value = drDoc.Count.ToString()
        //            });
        //        }

        //        //Key listesinde olan ama datada olmayan keyler sıfır olarak eklenecek.
        //        foreach (string strKey in WorksKey) {
        //            if (usedKeyList.Contains(strKey)) continue;

        //            usedKeyList.Add(strKey);
        //            grapValues.Add(new GraphicDataModel.GraphValue {
        //                Key = strKey,
        //                Value = "0"
        //            });
        //        }
        //        compGrap.Add(new GraphicDataModel {
        //            Date = drDateKey,
        //            GraphValues = grapValues
        //        });
        //    }
        //    return compGrap;
        //}

    }
}
