using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using StandartLibrary.Models.ViewModels.Metrics;
using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using StandartLibrary.Models.ViewModels.Request;
using System.Globalization;

namespace CRCAPI.Services.Services
{
    [TransientDependency(ServiceType = typeof(IMetricsService))]
    public class MetricsService : IMetricsService
    {
        private readonly IUnitOfWork<CrcmsDbContext> unitOfWork;
        public MetricsService(IUnitOfWork<CrcmsDbContext> unitOfWork)
        {
            this.unitOfWork = unitOfWork;
        }

        public StatisticsInfo GetStat(MetricsRequest metricsRequest)
        {
            try
            {

                CrcmsDbContext db = unitOfWork.Context;
                DateTime dtStart;
                DateTime dtEnd;

                bool isStartDateValid = DateTime.TryParseExact(metricsRequest.StartDate, "yyyy.MM.dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtStart);
                bool isEndDateValid = DateTime.TryParseExact(metricsRequest.EndDate, "yyyy.MM.dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtEnd);

                if (!isStartDateValid || !isEndDateValid)
                {
                    throw new BusinessException("Dates must be both valid");
                }

                if (dtStart >= dtEnd)
                {
                    throw new BusinessException("Start Date Must be less than end date");
                }

                var workedDocumentCount = (from j in ((
                                                from a in db.Areas
                                                join t in db.Timers on a.AreaId equals t.AreaId
                                                join b in db.LocalizedProperty on a.AreaId equals b.EntityId
                                                join c in db.LocalizedProperty on a.GroupId equals c.EntityId
                                                where b.Language == "tr" && b.Entity == "Area"
                                                    && c.Language == "tr" && c.Entity == "Group"
                                                    && a.GroupId > 0
                                                    && t.DateFinish >= dtStart && t.DateFinish < dtEnd
                                                select new { Group = c.Value, Area = b.Value, t.DocumentId, ReferenceId = (t.ReferenceId ?? 0) }
                                                ).Distinct())
                                           group j by j.Group into grpJ
                                           select new { grpJ.Key, sayi = grpJ.Count() }).ToDictionary(a => a.Key, b => b.sayi);

                StatisticsInfo statisticsInfo = new StatisticsInfo();
                statisticsInfo.LocalUserCount = db.LocalUser.Where(x => x.IsDeleted == false).Count();
                statisticsInfo.CrcRequestCount = db.CrcRequest.Where(x => x.CreateDate >= dtStart && x.CreateDate < dtEnd).Count();
                statisticsInfo.ActiveUserCount = db.UserActivityLog.Where(x => x.CreateDate >= dtStart && x.CreateDate < dtEnd).Select(x => x.UserId).Distinct().Count();
                statisticsInfo.AcceptedCrcRequesCount = (
                    from a in db.CrcRequest
                    join b in db.CrcRequestComponent on a.RequestId equals b.CrcRequestId
                    join c in db.ReceptionItem on b.CrcRequestComponentId equals c.RequestComponentId
                    where a.CreateDate >= dtStart && a.CreateDate < dtEnd
                    select a.RequestId
                    ).Distinct().Count();
                statisticsInfo.AcceptedDocumentCount = (
                        from a in db.Documents
                        join b in db.ReceptionItem on a.DocumentId equals b.DocumentId
                        join c in db.Reception on b.ReceptionId equals c.ReceptionId
                        where c.ReceptionDate >= dtStart && c.ReceptionDate < dtEnd
                        select a.DocumentId
                    ).Distinct().Count();
                statisticsInfo.DispatchedDocumentCount = (
                        from a in db.Dispatch
                        join b in db.DispatchItem on a.DispatchId equals b.DispatchId
                        where a.DispatchDate >= dtStart && a.DispatchDate < dtEnd
                        select b.DocumentId
                    ).Distinct().Count();
                statisticsInfo.ZsrtDocumentCount = (
                       from a in db.CounterLists
                       join b in db.Documents on a.DocumentId equals b.DocumentId
                       join c in db.DocumentType on b.DocumentType.DocumentTypeId equals c.DocumentTypeId
                       where new string[] { "K1", "RO", "CR" }.Contains(c.Code) && b.ArrivalMonth >= dtStart && b.ArrivalMonth < dtEnd
                       select b.DocumentId
                    ).Distinct().Count();
                statisticsInfo.NonZsrtDocumentCount = (
                   from a in db.CounterLists
                   join b in db.Documents on a.DocumentId equals b.DocumentId
                   join c in db.DocumentType on b.DocumentType.DocumentTypeId equals c.DocumentTypeId
                   where !(new string[] { "K1", "RO", "CR" }.Contains(c.Code)) && b.ArrivalMonth >= dtStart && b.ArrivalMonth < dtEnd
                   select b.DocumentId
                ).Distinct().Count();
                statisticsInfo.DefectListCount = (
                    from a in db.DocumentAttributes
                    where a.DefectListDone == 1 && a.DefectListDate >= dtStart && a.DefectListDate < dtEnd
                    select a.DocumentId
                ).Distinct().Count();
                statisticsInfo.PartsCollectDocumentCount = (
                    from a in db.OrderedPartsRequests
                    where a.RequestDate >= dtStart && a.RequestDate < dtEnd
                    select a.PartsOrderId
                ).Distinct().Count();
                statisticsInfo.WorkingDocuments = workedDocumentCount;

                return statisticsInfo;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
