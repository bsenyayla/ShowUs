using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.ViewModels;
using StandartLibrary.Models.ViewModels.Crcms;
using StandartLibrary.Models.ViewModels.Request;
using StandartLibrary.Models.ViewModels.Response;
using System;
using System.Collections.Generic;
using System.Text;

namespace CRCAPI.Services.Interfaces
{
    public interface IStatisticService
    {

        TotalComponentGraphData GetTotalComponentData(StatisticRequest req);

        //List<GraphicDataModel> GetTotalComponentCountForComponentGroup(StatisticRequest req);
        //List<GraphicDataModel> GetTotalComponentCountForSegment(StatisticRequest req);

        
        
        
        #region Input Count

        InputGraphData GetInput(StatisticRequest req);

        //List<GraphicDataModel> GetInputCountForGroup(StatisticRequest req);
        //List<GraphicDataModel> GetInputCountForSegment(StatisticRequest req);
        #endregion Input Count

        #region Output Count
        OutputGraphData GetOutput(StatisticRequest req);
        #endregion Output Count

        #region Süreç bazlı komponent sayısı
        ProcessBasedGraphData GetProcessBased(StatisticRequest req);
        #endregion Süreç bazlı komponent sayısı

        #region Financial Status
        FinancialGraphData GetFinancialStatus(StatisticRequest req);
        #endregion Financial Status

        #region CRC Request
        CRCRequestGraphData GetCRCRequestCount(StatisticRequest req);
        #endregion CRC Request


        TatGraphData GetTatData(StatisticRequest req);

        CapacityGraphData GetCapacityOccupancyData(StatisticRequest req);


        //List<Group> GetGroupList();
        //List<SegmentView> GetSegmentList();
        //List<AreaViewModel> GetAreaList();
        //List<Models.Region> GetLocationList();
        //bool CheckIfAreaExists(int areaId);
    }
}