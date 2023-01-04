using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.ViewModels;
using StandartLibrary.Models.ViewModels.Common;
using System.Collections.Generic;
using System.Linq;

namespace CRCAPI.Services
{
    [TransientDependency(ServiceType = typeof(IAreaService))]
    public class AreaService : IAreaService
    {
        private readonly IUnitOfWork<CrcmsDbContext> unitOfWork;
        private readonly IRedisCoreManager redisCoreManager;
        public AreaService(IUnitOfWork<CrcmsDbContext> unitOfWork, IRedisCoreManager redisCoreManager)
        {
            this.unitOfWork = unitOfWork;
            this.redisCoreManager = redisCoreManager;
        }


        public bool CheckIfAreaExists(int areaId)
        {
            var area = unitOfWork.GetRepository<Area>().List(x => x.AreaId == areaId).FirstOrDefault();  ////bir gruba baglı olmayanlar listelenmesin..
            if (area == null)
            {
                return false;
            }
            return true;
        }


        /// <summary>
        /// returns the list of the ares from db... foskan 17.10.2019
        /// </summary>
        /// <returns></returns>
        public List<AreaViewModel> GetAreaList()
        {
            /// wekingte arealar patladıgı için bu sekilde bir workaround düşünüldü ilerde kaldıralacak...
            var wekingIntegrationInfo = redisCoreManager.GetObject<WekingIntegration>(RedisConstants.WEKING_INTEGRATION);
            int increaseNumber = wekingIntegrationInfo.AreaIncreaseNumber;
            var returnList = new List<AreaViewModel>();
            var areas = unitOfWork.GetRepository<Area>().List(x => x.GroupId != 0 && x.LayoutPosition != null );  ////bir gruba baglı olmayanlar listelenmesin..
            var groups = unitOfWork.GetRepository<Group>().List();

            returnList = areas.Select(x => new AreaViewModel()
            {
                AreaId = (x.AreaId + increaseNumber).ToString(),
                AreaName = x.FullName,
                GroupCode = groups.Where(a => a.GroupId == x.GroupId).Select(a => a.Code).FirstOrDefault(),
                SegmentCode = x.Segment.ToString(),
                MultipleOrder = x.MultipleOrders == null ? false : x.MultipleOrders
            }).ToList();

            return returnList;
        }

    }
}
