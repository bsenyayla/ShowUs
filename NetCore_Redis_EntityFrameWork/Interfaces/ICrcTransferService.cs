using System;
using System.Collections.Generic;
using CRCAPI.Services.Models.CrcTransfer;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.EntityModels;
using StandartLibrary.Models.ViewModels.CrcComponentTransfer;

namespace CRCAPI.Services.Interfaces
{
    public interface ICrcTransferService
    {
        InternalRequest CreateInternalRequest(CrcComponentTransferCreateOrEditModel crcComponentTransferCreateViewModel);
        CrcTransferRequestsResponse GetInternalRequestList(JqueryDatatableParam parameters, int sortColumnIndex, string sortDirection);
        InternalRequestDetailView GetInternalRequest(Guid id);
        InternalRequest EditInternalRequest(CrcComponentTransferCreateOrEditModel model);
        string DeleteInternalRequest(Guid id, string loggedUser);
        List<WorkStatusModel> GetWorkStatus(string documentId);
    }
}