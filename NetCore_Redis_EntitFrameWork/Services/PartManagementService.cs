using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;

namespace CRCAPI.Services.Services
{
    [ScopedDependency(ServiceType = typeof(IPartManagementService))]
    public class PartManagementService : IPartManagementService
    {
        private readonly ICrmService crmService;
        private readonly IUnitOfWork<CrcmsDbContext> unitOfWork;
        private readonly ILogCoreMan logCoreMan;

        public PartManagementService(ICrmService crmService, IUnitOfWork<CrcmsDbContext> unitOfWork, ILogCoreMan logCoreMan)
        {
            this.crmService = crmService;
            this.unitOfWork = unitOfWork;
            this.logCoreMan = logCoreMan;
        }
        public void GetParts(string param)
        {

            var documentList = unitOfWork.GetRepository<Document>().List().Where(x => x.USERSTATUS == "Open").Select(x => new { x.DocumentId, x.DocumentNumber }).ToList();

            var documentNumberList = documentList.Select(x => x.DocumentNumber).ToList();

            var counterOrderedParts = unitOfWork.GetRepository<CounterOrderedParts>().List().ToList();

            foreach (var doc in documentNumberList)
            {
                try
                {
                    var isExistPartManagementDetailList = false;

                    var isExistcounterOrderedPartsReNew = false;

                    var docList = new List<string>();

                    docList.Add(doc);

                    var result = crmService.GetPartStatus(docList);

                    var counterOrderedPartsReNew = counterOrderedParts.Where(x => FeedWithZero(x.DocumentNumber) == doc).ToList();

                    if (counterOrderedPartsReNew != null)
                    {
                        foreach (var item in counterOrderedPartsReNew)
                        {
                            unitOfWork.GetRepository<CounterOrderedParts>().Delete(item);
                        }
                    }

                    if (result != null)
                    {
                        if (result.PartManagementDetailList != null)
                        {
                            foreach (var part in result.PartManagementDetailList)
                            {
                                unitOfWork.GetRepository<CounterOrderedParts>().Add(new CounterOrderedParts
                                {
                                    DocumentNumber = part.WorkOrderNumber,
                                    CreateDate = part.PartOrderCreateDate,
                                    DateStock = part.DeliveryDate,
                                    DateStockStr = part.DeliveryDate.ToString(),
                                    Number = part.PartNumber,
                                    Description = part.PartName,
                                    Segment = part.MainItem,
                                    Count = part.OrderedCount,
                                    ConfirmedCount = part.ConfirmedCount,
                                    DecisionCount = part.DecisionCount,
                                    CustomsCount = part.CustomsCount,
                                    Item = part.Item,
                                    ItemCreateDate = part.ItemCreateDate,
                                    ItemGuid = part.ItemGuid,
                                    ItemUpdateDate = part.ItemUpdateDate,
                                    MainItem = part.MainItem,
                                    MainItemGuid = part.MainItemGuid,
                                    OpenCount = part.OpenCount,
                                    OrderedCount = part.OrderedCount,
                                    PartName = part.PartName,
                                    PartNumber = part.PartNumber,
                                    PartOrderCreateDate = part.PartOrderCreateDate,
                                    PartOrderNumber = part.PartOrderNumber,
                                    RemainingCount = part.RemainingCount,
                                    ReservationCount = part.ReservationCount,
                                    RoadCount = part.RoadCount,
                                    ServiceCount = part.ServiceCount,
                                    ShipmentCount = part.ShipmentCount,
                                    Source = part.Source,
                                    Status = part.Status,
                                    StatusCode = part.StatusCode,
                                    Unit = part.Unit,
                                    WorkOrderNumber = part.WorkOrderNumber,
                                    DocumentId = documentList.Where(x => x.DocumentNumber == FeedWithZero(part.WorkOrderNumber)).Select(x => x.DocumentId).FirstOrDefault()
                                });
                            }
                        }
                    }

                    if (result != null)
                    {
                        if (result.PartManagementDetailList != null)
                        {
                            if (result.PartManagementDetailList.Count > 0)
                            {
                                isExistPartManagementDetailList = true;
                            }
                        }
                    }

                    if (counterOrderedPartsReNew != null)
                    {
                        if (counterOrderedPartsReNew.Count > 0)
                        {
                            isExistcounterOrderedPartsReNew = true;
                        }
                    }

                    if (isExistPartManagementDetailList == true || isExistcounterOrderedPartsReNew == true)
                    {
                        unitOfWork.SaveChangesByTransaction();
                    }
                }
                catch (Exception ex)
                {
                    logCoreMan.Error("Exception :" + ex.Message, ex);
                }
            }
        }
        public List<Document> GetPartDocuments()
        {
            var counter = unitOfWork.GetRepository<CounterList>();
            var filterDocId = counter.List(x => x.CounterStatusId == (int)CounterStatus.Approved && x.CustomerApproval_ExistsSpareParts == true
                    ).Select(x => x.DocumentId).ToArray();

            var userSmcsCode = unitOfWork.GetRepository<Document>().List().Select(x => x.SmcsCode).Distinct().ToArray();
            var documents = unitOfWork.GetRepository<Document>().List(x => filterDocId.Contains(x.DocumentId)).ToList();

            return documents;
        }

        public List<string> GetPartDocumentNumbers()
        {

            var documentNumbers = (from d in unitOfWork.Context.Documents
                                   join cl in unitOfWork.Context.CounterLists on d.DocumentId equals cl.DocumentId
                                   where d.USERSTATUS != "Closed"
                                          && d.USERSTATUS != "Cancel"
                                          && d.USERSTATUS != "Completed"
                                          && cl.CounterStatusId >= (int)CounterStatus.Start
                                          && cl.CustomerApproval_ExistsSpareParts == true
                                          && d.DispatchDate == null
                                   select d.DocumentNumber).Union(
                        (from d in unitOfWork.Context.Documents
                         join cl in unitOfWork.Context.CounterLists on d.DocumentId equals cl.DocumentId
                         join b in unitOfWork.Context.DocumentTypes on d.DocumentTypeId equals b.DocumentTypeId

                         where d.USERSTATUS != "Closed"
                                && d.USERSTATUS != "Cancel"
                                && d.USERSTATUS != "Completed"
                                && cl.CounterStatusId >= (int)CounterStatus.Start
                                && d.DispatchDate == null
                                && !string.IsNullOrEmpty(b.Code)
                                && new string[] { "K1", "RO", "CR" }.Contains(b.Code)
                         select d.DocumentNumber)
                ).ToList();

            return documentNumbers;
        }

        private string FeedWithZero(string workOrder)
        {
            string feedLines = string.Empty;
            for (int i = 0; i < 10 - workOrder.Length; i++)
            {
                feedLines += "0";
            }
            return string.Format("{0}{1}", feedLines, workOrder);
        }
    }
}