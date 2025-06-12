using StandartLibrary.Models.ViewModels.Request;
using StandartLibrary.Models.ViewModels.Response;
using System.Collections.Generic;

namespace CRCAPI.Services.Interfaces
{
    public interface IProcessService
    {
        UpdateStatusResponse UpdateStatus(UpdateStatusRequest request, string transactionId);

        void RetryFailedProcesses();

        WorkOrderStatusResponse GetWorkOrderStatus(WorkOrderStatusRequest request);

        List<WorkOrderStatusResponse> GetWorkOrderStatusList(WorkOrderStatusListRequest request);
    }
}
