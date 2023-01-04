using StandartLibrary.Models.ViewModels;
using StandartLibrary.Models.ViewModels.Request;
using StandartLibrary.Models.ViewModels.Response;
using System.Collections.Generic;
using Microsoft.AspNetCore.Http;
using StandartLibrary.Models.Enums;
using CRCAPI.Services.Models.CrcTransfer;

namespace CRCAPI.Services.Interfaces
{
    public interface IAttachmentService
    {
        void SaveFile(List<IFormFile> files, int documentId, UploadType uploadType, string userId = "", string userName = "", int zoneId = 0);
        AddAttachmentResponse AddAttachment(AddAttachmentRequest request);
        List<AttachmentResponse> GetAttachments(GetAttachmentListRequest request);
        List<AttachmentResponse> GetBoomAttachments(GetAttachmentListRequest request);
        AttachmentResponse GetAttachment(GetAttachmentRequest request);
        WorkOrderInfoAttachmentResponse GetAttachmentContent(int attachmentId);
        void SaveFile(List<CrcComponentsCreateOrEditModel> components, int documentId, UploadType internalRequestComponent, string createUser1, string createUser2);
    }
}
