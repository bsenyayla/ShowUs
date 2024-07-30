using StandartLibrary.Models.ViewModels.Metrics;
using StandartLibrary.Models.ViewModels.Request;
using System;
using System.Collections.Generic;
using System.Text;

namespace CRCAPI.Services.Interfaces
{
    public interface IMetricsService
    {
        StatisticsInfo GetStat(MetricsRequest metricRequst);
    }
}
