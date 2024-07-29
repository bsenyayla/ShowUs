using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.ViewModels.Request;
using System.Collections.Generic;
using System.Runtime.CompilerServices;

namespace CRCAPI.Services.Interfaces
{
    public interface IDowloadLogService
    {
        void Log(DowloadLogRequest request, [CallerMemberName] string memberName = "");
        List<DownloadLog> GetDownloadLogsByAttachmentId(int attachmentId);
        List<DownloadLog> GetDownloadLogsByUser(string TechnicianSapNumber);
    }
}
