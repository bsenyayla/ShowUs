using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using StandartLibrary.Models.DataModels;
using System;
using System.Linq;

namespace CRCAPI.Services
{
    [TransientDependency(ServiceType = typeof(IDocumentService))]
    public class DocumentService : IDocumentService
    {
        private readonly IUnitOfWork<CrcmsDbContext> unitOfWork;
        private readonly ICrmService crmService;
        private readonly ILogCoreMan logMan;
        public DocumentService(IUnitOfWork<CrcmsDbContext> unitOfWork, ICrmService crmService, ILogCoreMan logMan)
        {
            this.unitOfWork = unitOfWork;
            this.crmService = crmService;
            this.logMan = logMan;
        }

        public int FindDocumentNumberWithWorkOrderNumber(string orderNumber)
        {
            var documentId = unitOfWork.GetRepository<Document>().List(x => x.DocumentNumber == orderNumber.PadLeft(10, '0')).Select(x => x.DocumentId).FirstOrDefault();
            return documentId;
        }
        public int FindDocumentSegmentIdWithWorkOrderNumberSegmentCode(string orderNumber, int segmentCode)
        {
            var documentSegmentId = unitOfWork.GetRepository<DocumentSegment>().List(x => x.DocumentNumber == orderNumber.PadLeft(10, '0')&& x.SegmentCode== segmentCode).Select(x => x.DocumentSegmentId).FirstOrDefault();
            return documentSegmentId;
        }

        public void UpdateDispatchedDocuments() 
        {
            var documents = unitOfWork.GetRepository<Document>().List(x => x.DispatchDate == null);
            foreach (var item in documents)
            {
                try
                {
                    var dispatchItem = unitOfWork.GetRepository<DispatchItem>().List(x => x.DocumentId == item.DocumentId);
                    if (dispatchItem != null && dispatchItem.Any())
                    {
                        var dispatch = unitOfWork.GetRepository<Dispatch>().GetById(dispatchItem.First().DispatchId);

                        if (dispatch != null)
                        {
                            var document =  unitOfWork.GetRepository<Document>().GetById(item.DocumentId);

                            if (dispatch.DispatchDate != null && dispatch.DispatchDate != DateTime.MinValue && dispatch.DispatchDate != DateTime.MaxValue)
                            {
                                document.DispatchDate = dispatch.DispatchDate;
                                unitOfWork.GetRepository<Document>().Update(document);
                                unitOfWork.SaveChanges();
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    logMan.Error(" Error while updating dispatched document  " + item.DocumentNumber, ex);
                }
            }
        }


        public void UpdateDocuments()
        {
            var documents = unitOfWork.GetRepository<Document>().List(x => x.USERSTATUS != "Closed" && x.USERSTATUS != "Cancel" && x.USERSTATUS != "Completed" );

            foreach (var item in documents) {
                try
                {
                    crmService.BindWorkOrder(item.DocumentNumber);
                }
                catch (Exception ex) {
                    logMan.Error(" Error while updating document  " + item.DocumentNumber, ex);
                }
            }
        }
    }
}