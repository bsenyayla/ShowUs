using SharedStandartLibrary.Models.SapIntegrationModels.WorkOrderDetails.Request;
using StandartLibrary.Models.SapIntegrationModels.WorkOrderDetails.Response;
using StandartLibrary.Models.ViewModels.PartManagement;
using StandartLibrary.Models.ViewModels.Request;
using StandartLibrary.Models.ViewModels.WorkOrder;
using System.Collections.Generic;

namespace CRCAPI.Services.Interfaces
{
    public interface ICrmService
    {
        PartManagementResult GetPartStatus(List<string> workOrderNumberList);
        int BindWorkOrder(string workOrderNumber);
        void UpdateZsrtQuotation();

        //QuotationResult GetQuotation(string workOrderNumber);
        //QuotationOutputResult QuotationOutput(string formName, string quotationNo);
        WorkOrderResult GetWorkOrderByWorkOrderNumber(string workOrderNumber, out int documentId);
        bool AddCRCDocumentAttacments();
        List<WorkOrderInfosResponse> GetWorkOrderDetailsByCutomerNo(string cusCode, List<string> docIds);
    }
}
