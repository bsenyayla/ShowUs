using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.ViewModels.Request;
using StandartLibrary.Models.ViewModels.Response;
using System;
using System.Linq;

namespace CRCAPI.Services
{
    [TransientDependency(ServiceType = typeof(IChecklistService))]
    public class ChecklistService : IChecklistService
    {
        private readonly IUnitOfWork<CrcmsDbContext> crcmsUnitOfWork;
       // private readonly IUnitOfWork<ClcrcDbContext> clcrcUnitOfWork;
        private readonly IDocumentService documentservice;

        public ChecklistService(IUnitOfWork<CrcmsDbContext> crcmsUnitOfWork, IDocumentService documentservice)
        {
            this.crcmsUnitOfWork = crcmsUnitOfWork;
            //this.clcrcUnitOfWork = clcrcUnitOfWork;
            this.documentservice = documentservice;
        }

        public CheckForSubmitedCheckListResponse CheckForSubmitedCheckLists(CheckForSubmitedCheckListRequest request)
        {

            var groups = crcmsUnitOfWork.GetRepository<Group>().List();
            var ers = groups.Where(x => x.Code == Constants.ERS).FirstOrDefault();

            CheckForSubmitedCheckListResponse response = new CheckForSubmitedCheckListResponse
            {
                AllowForSubmit = false
            };


            var areaId = Convert.ToInt32(request.AreaId);
            var documentId = documentservice.FindDocumentNumberWithWorkOrderNumber(request.OrderNumber);
            if (documentId == 0)
            {
                throw new BusinessException("Wrong work order number", StandartLibrary.Models.Enums.ErrorCode.WrongWorkOrderNumber);
            }

            var area = crcmsUnitOfWork.GetRepository<Area>().List(f => f.AreaId == areaId).FirstOrDefault();
            if (area.GroupId == ers.GroupId)
            {
                response.AllowForSubmit = true;
            }





            ///Checklist Modülü şimdilik kullanılmayacagından kapatıldı....  ilerde düşünülecek  ....
            //var checklistRequest = clcrcUnitOfWork.GetRepository<CheckListRequest>().List(c => c.DocumentId == documentId && c.SegmentId == segment.SegmentId).Count() > 0;
            //if (checklistRequest)
            //{
            //    response.IsSubmitted = 1;
            //}



            //// ilgili alanda ait checklist template var mı ? yoksa kontrol ve işlem kesmeye ihtiyaç yok ...
            //var templates = clcrcUnitOfWork.GetRepository<TemplateArea>().List(w => w.AreaId == areaId).Select(s => s.TemplateId).ToArray();

           /* var templateCount = clcrcUnitOfWork.GetRepository<TemplateArea>().Count(w => w.AreaId == areaId);
            if (templateCount > 0)
            {
                var templates = clcrcUnitOfWork.GetRepository<TemplateArea>().List(w => w.AreaId == areaId).Select(s => s.TemplateId).ToArray();
                var checklistCount = clcrcUnitOfWork.GetRepository<CheckList>().Count(w => templates.Contains(w.TemplateId) && w.DocumentId == documentId && w.SubmitDate != null) > 0;
                if (checklistCount)
                {
                    response.AllowForSubmit = true;
                }
            }
            else
            {
                response.AllowForSubmit = true;
            }*/
            return response;
        }
    }
}